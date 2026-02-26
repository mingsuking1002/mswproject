# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

`mon_type == "elite"` 몬스터가 현재 normal과 동일하게 `spawn_time` 이후 **매 틱 반복 스폰**되는 문제를 수정한다. elite는 `spawn_time` 도달 시 **딱 1마리만** 스폰하고, 이후 반복 스폰 풀에서 제외한다.

---

## 2. 수정 대상

* **Component Name:** `MonsterSpawnComponent`
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
* **Execution Space:** `[Server Only]`

---

## 3. 현재 문제

`ResolveSpawnCandidates` (873행)에서:
```
if IsBossRow(row) then → BossRows
else → NormalRows   ← elite도 여기에 포함됨
```
→ `SpawnTick`에서 `NormalRows`를 매 틱 `SpawnPerTick`개씩 랜덤 선택하므로, elite가 normal과 섞여 **반복 스폰**됨.

---

## 4. 수정 사항

### 4-1. `ResolveSpawnCandidates` 수정

기존 2분류(`NormalRows`/`BossRows`)를 3분류로 변경:

```pseudocode
result.NormalRows = {}
result.EliteRows = {}   -- [NEW]
result.BossRows = {}

for row in MonsterRows:
    -- 기존 stage/spawn_time 필터 유지

    if IsBossRow(row) then
        table.insert(result.BossRows, row)
    elseif IsEliteRow(row) then          -- [NEW]
        table.insert(result.EliteRows, row)
    else
        table.insert(result.NormalRows, row)
    end
```

### 4-2. `IsEliteRow` 신규 메서드

```pseudocode
method boolean IsEliteRow(row)
    local monType = string.lower(GetRowString(row, "mon_type", ""))
    return monType == "elite"
end
```

### 4-3. `SpawnTick` 수정 — elite 1회 스폰 로직

보스 처리 직후, normal 루프 직전에 삽입:

```pseudocode
-- [NEW] Elite 1회 스폰
local eliteRows = candidates.EliteRows
if eliteRows ~= nil and #eliteRows > 0 then
    for _, eliteRow in pairs(eliteRows) do
        local eliteId = GetRowString(eliteRow, "id", "")
        if _T.EliteSpawnedSet[eliteId] ~= true then
            local pos = CalcDonutPosition()
            if pos ~= nil and IsValidSpawnPosition(pos) then
                local spawned = SpawnMonsterByRow(eliteRow, pos, false)
                if spawned ~= nil and isvalid(spawned) then
                    _T.EliteSpawnedSet[eliteId] = true
                end
            end
        end
    end
end
```

### 4-4. `_T.EliteSpawnedSet` 초기화

| 위치 | 처리 |
|---|---|
| `OnInitialize` | `_T.EliteSpawnedSet = {}` |
| `LoadMonsterDataFromTable` | `_T.EliteSpawnedSet = {}` (테이블 리로드 시 리셋) |
| `ActivateInfiniteModeServer` | `_T.EliteSpawnedSet = {}` (모드 전환 시 리셋) |

### 4-5. LobbyFlow 런 리셋 연동

`ResetShopStateServer`나 `HandleRunCompletedServer` 경로에서 이미 `MonsterSpawnComponent` 데이터를 리로드하므로, 4-4의 리셋이 자동 적용됨. 별도 작업 불필요.

---

## 5. 연동 컴포넌트

| 컴포넌트 | 영향 |
|---|---|
| `PenaltySystemComponent` | elite 판별 로직(222행)이 `mon_type`을 읽으므로 변경 없음. cull 대상에서 elite 제외가 이미 되어 있다면 유지 |
| `InfiniteModeComponent` | `ActivateInfiniteModeServer` 경로에서 `EliteSpawnedSet` 리셋만 추가 |

---

## 6. 기획서 참조

* PD 직접 지시 (2026-02-26)

---

## 7. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

---

## 8. 주의/최적화 포인트

* **`_T.EliteSpawnedSet`은 row ID 기반**: 동일 elite 행이 다른 stage에서 재등장할 수 있으므로, `stage + id` 복합키가 필요한지 PD 확인 필요
* **elite 스폰 위치**: normal과 동일하게 도넛 랜덤 위치 사용
* **elite 사망 후 재스폰 여부**: 현재 설계는 **1회 한정** (사망 후에도 재스폰 안 함). PD 의도와 다르면 `EliteSpawnedSet`에서 사망 시 제거 로직 추가

---
