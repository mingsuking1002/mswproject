# 🔵 진행중

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 |
|---|---|
| 2026-03-03 | 🟡 대기중 |
| 2026-03-03 | 🔵 진행중 |

---

## 1. 개요

모든 캐릭터·무기의 개별 탄창(MagazineA/B)을 **하나의 통합 마나 풀**로 변경한다. 마나 1개 = 재장전 1회. UI에서 "탄창" → "마나"로 명칭 일괄 변경.

---

## 2. 수정 대상 파일 (7개)

### ① [MODIFY] GRInventoryComponent.mlua
- `MagazineA`, `MagazineB` 프로퍼티 → **`Mana` (integer, @Sync)** 단일 프로퍼티로 통합
- `MaxMagazine` → `MaxMana`
- `ConsumeMagazineServer()`: charId 분기 제거. `self.Mana -= 1` (0이면 실패)
- `AddMagazineServer(charId, amount)`: charId 무시, `self.Mana += amount` (MaxMana 클램프)
- `GetCurrentCharMagazine()`: charId 분기 제거, `return self.Mana`
- `SetCurrentCharMagazine(amount)`: charId 분기 제거, `self.Mana = amount`
- `ResetInventoryServer()`: `self.Mana = 0`
- **삭제 대상:** `MagazineAItemId` 프로퍼티, A/B 분기 로직
- `ShowNoAmmoMessageClient()`: 텍스트 "탄창이 부족합니다" → "마나가 부족합니다"

### ② [MODIFY] ReloadComponent.mlua
- `StartReloadForSlot`: `ConsumeMagazineServer("")` 호출 부분 — **변경 없음** (GRInventory 내부에서 통합 처리)
- 변경 최소: GRInventoryComponent 통합으로 자동 연동

### ③ [MODIFY] InGameHUDComponent.mlua

**텍스트 변경:**
- L519: `"탄창 "` → `"마나 "`
- L802: `"탄창 x"` → `"마나 x"`

**UI 엔티티 연결 (기존 경로 유지, 데이터 소스만 통합):**
- `MagazineTextEntity` (경로: `/ui/DefaultGroup/GRMagazineText`) — 기존 그대로 사용
- `RefreshInventoryTextsClient()` 내부:
  - `inventory.GetCurrentCharMagazine()` 호출 → (GRInventory 내부에서 통합 `Mana` 반환)
  - 표시 텍스트: `"마나 x" .. tostring(manaCount)`
- **갱신 트리거:** `OnSyncProperty`에서 `"Mana"` (기존 `"MagazineA"/"MagazineB"`)가 변경되면 `RefreshInventoryTextsClient()` 재호출 → UI 자동 갱신
- `MagazineTextPath` 프로퍼티명은 `ManaTextPath`로 리네임 (Maker 배치 Entity 이름도 변경 권장)
- L1340: `MagazineTextEntity` 캐시 → `ManaTextEntity`로 리네임

### ④ [MODIFY] ShopManagerComponent.mlua
- L603: `"탄창 보충"` → `"마나 보충"`
- L604: `"현재 캐릭터 탄창 1개 획득"` → `"마나 1개 획득"`

### ⑤ [MODIFY] ItemDropManagerComponent.mlua
- `a_mag`/`b_mag` 분기 → 통합: 둘 다 `inventory:AddMagazineServer("", amount)` 호출 (charId 무시)
- 또는 `a_mag`/`b_mag` 모두 동일 로직으로 마나 추가

### ⑥ [MODIFY] TagManagerComponent.mlua
- `MagazineA` 마커 참조 → `Mana`로 변경
- Tag swap 시 개별 탄창 보존 로직 제거 (통합이므로 불필요)

### ⑦ [MODIFY] LobbyFlowComponent.mlua
- `MagazineA` 마커 참조 → `Mana`로 변경

---

## 3. 데이터 테이블 변경

### ItemData.csv
- `mag_a` + `mag_b` 행 → **`mana`** 단일 행으로 통합 (또는 두 행 모두 effect_type을 `"mana"`로 변경)
- `effect_type`: `a_mag`/`b_mag` → `mana`

---

## 4. Properties (GRInventoryComponent 최종 형태)

| 타입 | 변수명 | 기본값 | 설명 |
|---|---|---|---|
| @Sync integer | Mana | 0 | 통합 마나 보유량 |
| integer | MaxMana | 99 | 최대 마나 |
| ~~MagazineA~~ | 삭제 | — | 제거 |
| ~~MagazineB~~ | 삭제 | — | 제거 |
| ~~MaxMagazine~~ | 삭제 | — | MaxMana로 대체 |

---

## 5. Required MSW Services

- 해당 없음 (기존 서비스 변경 없음)

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 변경 |
|---|---|---|
| ReloadComponent | `ConsumeMagazineServer` 호출 | 호출 인터페이스 유지, 내부만 통합 |
| ItemDropManagerComponent | `AddMagazineServer` 호출 | charId 무시, 통합 마나 추가 |
| TagManagerComponent | MagazineA/B 보존/복원 | 통합이므로 보존 불필요, Mana 마커로 변경 |
| LobbyFlowComponent | MagazineA 마커 | Mana 마커로 변경 |
| InGameHUDComponent | UI 텍스트 | "탄창" → "마나" |
| ShopManagerComponent | UI 텍스트 + 구매 로직 | "탄창" → "마나" |

---

## 7. Logic Architecture

### 재장전 흐름 (변경 후)
```
R키 → ReloadComponent.StartReloadForSlot(slot)
  → GRInventoryComponent.ConsumeMagazineServer("")
    → Mana >= 1? → Mana -= 1, return true
    → Mana == 0? → ShowNoAmmoMessageClient("마나가 부족합니다"), return false
  → 성공 시 ReloadTimer 시작 → 완료 시 CurrentAmmo = MaxAmmo
```

### 마나 획득 흐름
```
드롭 아이템 획득 (effect_type == "mana")
  → ItemDropManagerComponent → GRInventoryComponent.AddMagazineServer("", 1)
    → Mana = min(Mana + 1, MaxMana)
```

---

## 8. 기획서 참조

- PD 구두 지시 (2026-03-03): "모든 탄창 통합, 탄창 10개 = 재장전 10번, UI 명칭 마나로 변경"

---

## 9. 구현 방식

mcp 이용해서 직접 workspace에서 작업

---

## 10. 주의/최적화 포인트

- **하위 호환:** `ConsumeMagazineServer` / `AddMagazineServer` 함수명은 유지하되 charId 파라미터 무시 → 호출부 수정 최소화
- **Tag swap 단순화:** 통합 마나이므로 캐릭터 교체 시 개별 보존 불필요
- **codeblock 동기화 필수**
