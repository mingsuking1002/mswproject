# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

현재 무한 재장전 시스템을 **탄창 소모형**으로 개편하고, 즉시 회복이던 **포션을 아이템화**하여 저장 후 E키로 사용하는 시스템을 추가한다. 두 시스템 모두 `ItemData` 테이블의 정보를 참조한다.

---

## 2. 컴포넌트 정의

### 2-1. `InventoryComponent` (신규)

* **Execution Space:** `[Server Only]` (재고 변경), `[Client Only]` (UI 표시)
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InventoryComponent.mlua`
* **역할:** 탄창(캐릭터별)·포션(공용)의 보유 수량 관리 + E키 포션 사용 + 재장전 시 탄창 소모 게이트

---

## 3. Properties

| 이름 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `MagazineA` | integer (Sync) | `0` | 캐릭터 A 탄창 보유량 |
| `MagazineB` | integer (Sync) | `0` | 캐릭터 B 탄창 보유량 |
| `PotionCount` | integer (Sync) | `0` | 포션 보유량 (공용) |
| `MaxMagazine` | integer | `99` | 캐릭터당 탄창 최대치 |
| `MaxPotion` | integer | `10` | 포션 최대치 |
| `PotionHealAmount` | integer | `0` | 포션 회복량 (ItemData에서 로드) |
| `ItemDataTableName` | string | `"ItemData"` | 아이템 테이블명 |
| `MagazineAItemId` | string | `"a_mag"` | 캐릭터 A 탄창 아이템 ID |
| `MagazineBItemId` | string | `"b_mag"` | 캐릭터 B 탄창 아이템 ID |
| `PotionItemId` | string | `"heal_hp"` | 포션 아이템 ID |
| `NoAmmoMessageDuration` | number | `1.0` | "탄약이 없습니다" 표시 시간 |
| `EnableDebugLogs` | boolean | `true` | 디버그 로그 |

---

## 4. Required MSW Services

* `_DataService` — ItemData 로드
* `_TimerService` — 페이드 아웃 타이머

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `ReloadComponent` | `StartReloadForSlot` 진입 시 → `InventoryComponent:ConsumeMagazineServer()` 호출. false면 재장전 차단 |
| `TagManagerComponent` | `CaptureCurrentCharacterState`/`ApplyCharacterState`에 `MagazineA`/`MagazineB` 스왑 추가 |
| `ItemDropManagerComponent` | `PickupItemServer`에서 `a_mag`/`b_mag` → `AddMagazineServer()`, `heal_hp` → `AddPotionServer()` 호출 |
| `HUDComponent` | HP바 좌측에 포션 수량, 우측에 현재 캐릭터 탄창 수량 텍스트 추가 |
| `ShopManagerComponent` | 상점 탄약 슬롯 → 현재 캐릭터 탄창 보충으로 변경 |
| `Map01BootstrapComponent` | 자동 부착 목록에 `InventoryComponent` 추가 |
| `LobbyFlowComponent` | 런 종료 시 `ResetInventoryServer()` 호출 |

---

## 6. Logic Architecture

### 6-1. 초기화 (`OnBeginPlay`)

1. `_DataService:GetTable(ItemDataTableName)` → 포션 회복량 캐시
2. `MagazineA = 0`, `MagazineB = 0`, `PotionCount = 0`

### 6-2. 탄창 관련

**`ConsumeMagazineServer(charId)` → boolean**

```pseudocode
charId = TagManager.CurrentCharIndex 기반으로 "A" or "B" 판별
if charId == "A" then
    if MagazineA <= 0 then ShowNoAmmoMessage(); return false end
    MagazineA -= 1
else
    if MagazineB <= 0 then ShowNoAmmoMessage(); return false end
    MagazineB -= 1
end
return true
```

**`AddMagazineServer(charId, amount)`**

```pseudocode
if charId == "A" then MagazineA = min(MagazineA + amount, MaxMagazine)
else MagazineB = min(MagazineB + amount, MaxMagazine)
```

**`ShowNoAmmoMessageClient()`** — [Client Only]

```pseudocode
"탄약이 없습니다" 텍스트 표시 → NoAmmoMessageDuration 후 페이드 아웃
```

### 6-3. 포션 관련

**E키 입력 → `RequestUsePotionServer()`**

```pseudocode
if PotionCount <= 0 then return
PotionCount -= 1
HPSystemComponent:Heal(PotionHealAmount)
```

**`AddPotionServer(amount)`**

```pseudocode
PotionCount = min(PotionCount + amount, MaxPotion)
```

### 6-4. 태그 스왑 연동

`TagManagerComponent.CaptureCurrentCharacterState`에 추가:
```pseudocode
state.MagazineCount = inventory:GetCurrentCharMagazine()
```

`TagManagerComponent.ApplyCharacterState`에 추가:
```pseudocode
inventory:SetCurrentCharMagazine(state.MagazineCount)
```

> 포션은 공용이므로 태그 스왑 시 변경 없음

### 6-5. 런 리셋 (`ResetInventoryServer`)

```pseudocode
MagazineA = 0; MagazineB = 0; PotionCount = 0
```

---

## 7. ReloadComponent 수정 사항

`StartReloadForSlot(slot)` 메서드 최상단에 탄창 소모 게이트 추가:

```pseudocode
-- 기존 재장전 가능 조건 체크 직후에:
local inventory = self:ResolveComponentSafe(self.Entity, "InventoryComponent", "MagazineA")
if inventory ~= nil then
    if inventory:ConsumeMagazineServer() == false then
        return  -- 탄창 없으면 재장전 불가
    end
end
```

---

## 8. ItemDropManagerComponent 수정 사항

`PickupItemServer`의 effect_type 분기에서:

```pseudocode
-- 기존: "a_mag"/"b_mag" → reloadComponent 탄약 보충
-- 변경: "a_mag" → inventory:AddMagazineServer("A", amount)
--        "b_mag" → inventory:AddMagazineServer("B", amount)
--        "heal_hp" → inventory:AddPotionServer(amount)  -- 즉시 회복 아닌 저장
```

---

## 9. HUDComponent 수정 사항

기존 4텍스트에 2개 추가:

| 위치 | 엔티티 경로 | 내용 |
|---|---|---|
| HP바 **좌측** | `/ui/DefaultGroup/GRPotionText` | `"🧪 x3"` (포션 보유량) |
| HP바 **우측** | `/ui/DefaultGroup/GRMagazineText` | `"📦 x5"` (현재 캐릭터 탄창) |

`RefreshHUDClient`에 추가:
```pseudocode
-- 포션 텍스트 갱신
potionText.Text = "🧪 x" .. inventory.PotionCount
-- 탄창 텍스트 갱신 (현재 캐릭터 기준)
local mag = (tagManager.CurrentCharIndex == 1) and inventory.MagazineA or inventory.MagazineB
magazineText.Text = "📦 x" .. mag
```

---

## 10. ShopManagerComponent 수정 사항

`ApplyAmmoPurchaseServer` 변경:
```pseudocode
-- 기존: 전 슬롯 탄약 MaxAmmo로 보충
-- 변경: 현재 캐릭터 탄창 N개 지급
local inventory = self:ResolveComponentSafe(self.Entity, "InventoryComponent", "MagazineA")
if inventory ~= nil then
    local charId = self:GetCurrentCharId()  -- TagManager 참조
    inventory:AddMagazineServer(charId, purchaseAmount)
end
```

---

## 11. 기획서 참조

* PD 직접 지시 (2026-02-26)
* `기획서/1.핵심 시스템/` 내 관련 문서

---

## 12. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

---

## 13. 주의/최적화 포인트

* **서버 권위**: 탄창/포션 수량 변경은 모든 경우 서버에서만. 클라이언트는 Sync 프로퍼티로 결과만 수신
* **OnUpdate 사용 금지**: 모든 수량 변경은 이벤트 기반(R키 재장전, E키 사용, 아이템 획득)
* **태그 스왑 안전**: 탄창은 캐릭터별 분리(`MagazineA`/`MagazineB`), 포션은 공용
* **페이드 아웃 메시지**: "탄약이 없습니다" 텍스트는 `_TimerService:SetTimerOnce`로 1초 후 제거
* **기존 DropSystem 호환**: `a_mag`/`b_mag`/`heal_hp` effect_type은 이미 ItemData에 정의됨 → 획득 경로만 변경

---
