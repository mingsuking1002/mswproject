# 🟡 대기중

---
**[Codex용 작업 명세서]**

## §1 개요

몬스터 처치 시 `MonsterData.drop_id` → `DropData` → `ItemData` 파이프라인으로 아이템을 필드에 스폰하고, 플레이어 접근 시 자석 효과로 끌어당겨 획득하는 시스템.

---

## §2 신규 컴포넌트

### 2-1. `ItemDropManagerComponent` (플레이어 엔티티에 부착)
* **Execution Space:** `[Server Only]` (드랍 판정·골드 지급), `[Client Only]` (자석 이동 연출)
* **역할:** DropData 파싱, 확률 판정, 아이템 엔티티 스폰, 자석 흡수, 효과 적용

#### Properties
```
property string DropDataTableName   = "DropData"
property string ItemDataTableName   = "ItemData"
property number MagnetRadius        = 3.0      // 자석 발동 반경 (월드 단위)
property number PickupRadius        = 0.5      // 획득 판정 반경
property number MagnetSpeed         = 12.0     // 끌려오는 속도
property number ScatterRadius       = 2.0      // 사망 위치에서 흩어지는 반경
property number ScatterAirTime      = 0.4      // 체공(튕김) 시간 — 이 동안 획득 불가
property integer MaxFieldItems      = 50       // 필드 아이템 상한 (풀링 대용)
```

#### Required MSW Services
- `_DataService`, `_SpawnService`, `_TimerService`, `_EntityService`

---

## §3 데이터 테이블 연동

### MonsterData.csv → DropData.csv
- 몬스터 사망 시 `SpawnMeta.DropId` (= `MonsterData.drop_id`) 를 키로 `DropData` 행을 조회.
- `DropData`는 슬롯 3개: `drop_item_1/2/3`, 각각 `_rate`(확률 0~1), `_amount`(수량).

### DropData.csv → ItemData.csv
- `drop_item_N` 값이 `ItemData.item_id`와 매칭.
- `ItemData.effect_type`으로 효과 분기:
  - `heal_hp` → `HPSystemComponent:HealHP(effect_value_1)`
  - `a_mag` / `b_mag` → `ReloadComponent` 탄약 보충
  - `None` (gold) → `GoldComponent:AddGold(amount)`

### DropData 내 drop_item_1이 빈 값인 행 처리
- `normal_drop01~05`의 `drop_item_1`은 현재 빈 값 → 해당 슬롯은 스킵 처리.

---

## §4 연동 컴포넌트 (기존 시스템)

| 기존 컴포넌트 | 연동 방식 |
|---|---|
| `MonsterSpawnComponent` | `BeginMonsterDeathSequenceServer()` 직후에 `ItemDropManagerComponent:ExecuteDropServer(deathPosition, dropId)` 호출 추가. `SpawnMeta`에서 `DropId` 가져옴. |
| `GoldComponent` | `AddGold(amount)` 호출 (이미 API 존재, 호출자만 없음) |
| `HPSystemComponent` | `HealHP(amount)` 또는 기존 HP 회복 메서드 호출 |
| `ReloadComponent` | 탄약 보충용 메서드 호출 |
| `InfiniteModeComponent` | 변경 없음 (점수는 이미 별도 파이프라인) |
| `Map01BootstrapComponent` | 컴포넌트 자동 부착 목록에 `ItemDropManagerComponent` 추가 |

---

## §5 로직 구조

### 5-1. 초기화 (`OnBeginPlay`)
- `_DataService:GetTable("DropData")` → `_T.DropCache[id]` 로 캐싱.
- `_DataService:GetTable("ItemData")` → `_T.ItemCache[item_id]` 로 캐싱.
- `_T.FieldItems = {}` (현재 필드에 있는 아이템 엔티티 목록)

### 5-2. 드랍 실행 (`ExecuteDropServer`)
```
입력: deathPosition(Vector2), dropId(string)
1. dropRow = _T.DropCache[dropId] → 없으면 return
2. for slot = 1, 3:
     itemId  = dropRow["drop_item_" .. slot]
     rate    = dropRow["drop_item_" .. slot .. "_rate"]
     amount  = dropRow["drop_item_" .. slot .. "_amount"]
     if itemId == nil or itemId == "" then continue end
     if math.random() > rate then continue end
     for i = 1, amount:
       SpawnFieldItemServer(deathPosition, itemId)
```

### 5-3. 필드 아이템 스폰 (`SpawnFieldItemServer`)
```
1. MaxFieldItems 초과 시 가장 오래된 아이템 파괴
2. 엔티티 생성 (SpawnByModelId 또는 빈 엔티티 + SpriteRenderer)
3. 랜덤 오프셋(ScatterRadius) 적용 → 목표 위치 계산
4. _T.FieldItems에 등록, 상태 = "airborne"
5. ScatterAirTime 후 상태 = "grounded" (SetTimerOnce)
```

### 5-4. 자석 흡수 (`OnUpdate` — Client)
```
1. _T.FieldItems 순회
2. 상태 == "grounded" && 플레이어와의 거리 <= MagnetRadius 이면:
   아이템을 플레이어 방향으로 MagnetSpeed * delta 만큼 이동
3. 거리 <= PickupRadius 이면:
   서버에 PickupRequestServer(itemEntityId, itemId) 전송
```

### 5-5. 획득 처리 (`PickupItemServer` — Server Only)
```
1. ItemData에서 effect_type 조회
2. 분기:
   - "heal_hp":  hpSystem 회복
   - "a_mag"/"b_mag": reloadComponent 탄약 보충
   - "None" (gold): goldComponent:AddGold(drop_amount)
3. 필드 아이템 엔티티 Destroy
4. _T.FieldItems에서 제거
```

### 5-6. 스테이지 전환/게임오버 시 정리
- `ClearAllFieldItemsServer()`: 필드의 모든 아이템 즉시 Destroy.
- `MonsterSpawnComponent.KillAllMonstersServer()` 호출 시점에 연동하거나, `LobbyFlow.HandleRunCompletedServer` 내에서 호출.

---

## §6 MonsterSpawnComponent 수정 지점

`BeginMonsterDeathSequenceServer()` 메서드 내부, 페이드 시작 직전에 1줄 추가:

```lua
-- BeginMonsterDeathSequenceServer 내부, PrepareDeadMonsterForFade 직후:

-- [NEW] 드랍 실행
local dropManager = self:ResolveComponentSafe(self.Entity, "ItemDropManagerComponent", "DropDataTableName")
if dropManager ~= nil and dropManager.ExecuteDropServer ~= nil then
    local deathPos = monsterEntity.TransformComponent.WorldPosition
    local dropId = ""
    if self._T.SpawnMetaByEntity ~= nil then
        local meta = self._T.SpawnMetaByEntity[monsterEntity]
        if meta ~= nil and meta.DropId ~= nil then
            dropId = tostring(meta.DropId)
        end
    end
    if dropId ~= "" then
        pcall(function()
            dropManager:ExecuteDropServer(Vector2(deathPos.x, deathPos.y), dropId)
        end)
    end
end
```

### SpawnMeta에 DropId 추가 확인
`MonsterSpawnComponent`가 몬스터를 스폰할 때 `SpawnMeta` 테이블을 만드는 부분에서, `MonsterData.drop_id` 컬럼을 읽어 `meta.DropId`로 저장해야 함. 기존에 `drop_id`를 읽는 코드가 있는지 확인 후, 없으면 추가:
```lua
meta.DropId = self:GetRowString(row, "drop_id", "")
```

---

## §7 Maker 배치

- `Map01BootstrapComponent`의 컴포넌트 자동 부착 목록에 `"ItemDropManagerComponent"` 추가.
- 아이템 엔티티 모델은 빈 엔티티 + `SpriteRendererComponent`로 동적 생성 (별도 프리팹 없이 코드로 생성).
- `ItemData.icon_ruid` 컬럼이 채워지면 해당 RUID를 스프라이트로 사용. 비어있으면 기본 아이콘 할당.

---

* **기획서 참조:** `기획서/1.핵심 시스템/[시스템] 아이템 드랍 및 획득 시스템 v 1.0.md`
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - `OnUpdate`에서 자석 이동은 **Client Only** 로 처리하여 서버 부하 최소화. 획득 판정만 서버.
  - `MaxFieldItems` 상한으로 대량 드랍 시 엔티티 폭발 방지.
  - `ScatterAirTime` 동안 획득 불가 → 시각적 튕김 연출과 획득 판정의 타이밍 분리.
  - 골드는 `GoldComponent.AddGold()` 활용 (이미 구현됨, 호출자만 연결하면 됨).
