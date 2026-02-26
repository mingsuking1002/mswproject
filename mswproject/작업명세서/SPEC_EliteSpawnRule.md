# 🟢 완료

---

**[Codex용 작업 명세서]**

## 1. 개요

`mon_type == "elite"` 몬스터를 기존 `SpawnTick`에서 **완전 분리**한다. `MonsterSpawnComponent.StateMonitorTimer`의 주기적 콜백 내에서 `GameTimerComponent.ElapsedTime`이 해당 elite의 `spawn_time(분)`에 도달했는지 체크하고, 도달 시 해당 ID의 elite를 **1마리만** 스폰한다.

---

## 2. 수정 대상

* **Component:** `MonsterSpawnComponent`
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
* **Execution Space:** `[Server Only]`

---

## 3. 수정 사항

### 3-1. `ResolveSpawnCandidates` — elite 제외

```pseudocode
if IsBossRow(row) then → BossRows
elseif IsEliteRow(row) then → continue  -- NormalRows에 넣지 않음
else → NormalRows
```

### 3-2. `IsEliteRow` 신규

```pseudocode
method boolean IsEliteRow(row)
    return string.lower(GetRowString(row, "mon_type", "")) == "elite"
end
```

### 3-3. `CheckEliteSpawnsServer` 신규 — StateMonitorTimer 콜백에 추가

`RefreshSpawnStateServer` 호출 시점에 함께 실행 (기존 StateMonitorTimer 콜백에 1줄 추가):

```pseudocode
-- StateMonitorTimer 콜백 (610행 부근)
local callback = function()
    self:RefreshSpawnStateServer()
    self:UpdateMonsterHPBarsServer()
    self:ProcessMonsterDeathSequenceServer()
    self:CheckEliteSpawnsServer()   -- [NEW]
end
```

```pseudocode
method void CheckEliteSpawnsServer()
    if _T.MonsterRows == nil then return end
    if IsSafeZoneActiveServer() then return end  -- IsLobby 가드

    local timerComp = ResolveComponentSafe(Entity, "GameTimerComponent", "ElapsedTime")
    if timerComp == nil then return end
    local elapsed = timerComp.ElapsedTime

    for _, row in pairs(_T.MonsterRows) do
        if IsEliteRow(row) == false then continue end

        local eliteId = GetRowString(row, "id", "")
        if eliteId == "" then continue end
        if _T.EliteSpawnedSet[eliteId] == true then continue end

        local spawnSec = GetSpawnMinuteFromRow(row) * 60
        if spawnSec < 0 then continue end
        if elapsed < spawnSec then continue end

        -- 도달 → 1마리 스폰
        SpawnEliteOnceServer(row, eliteId)
    end
end
```

### 3-4. `SpawnEliteOnceServer` 신규

```pseudocode
method void SpawnEliteOnceServer(row, eliteId)
    if _T.EliteSpawnedSet[eliteId] == true then return end

    local pos = CalcDonutPosition()
    if pos ~= nil and IsValidSpawnPosition(pos) then
        local spawned = SpawnMonsterByRow(row, pos, false)
        if spawned ~= nil and isvalid(spawned) then
            _T.EliteSpawnedSet[eliteId] = true
        end
    end
end
```

### 3-5. 초기화/리셋

| 위치 | 처리 |
|---|---|
| `OnInitialize` | `_T.EliteSpawnedSet = {}` |
| `LoadMonsterDataFromTable` | `_T.EliteSpawnedSet = {}` |
| `ActivateInfiniteModeServer` | 리로드 시 자동 리셋 |

---

## 4. 기획서 참조

* PD 직접 지시 (2026-02-26)

## 5. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

## 6. 주의/최적화 포인트

* **SpawnTick과 완전 독립**: elite는 NormalRows에 진입하지 않음
* **GameTimerComponent.ElapsedTime 기반**: Pause 시 자동으로 멈춤 → 별도 보정 불필요
* **StateMonitorTimer 주기(0.2s)**: elite 스폰 정밀도는 ±0.2초 → 충분
* **IsLobby 가드**: `IsSafeZoneActiveServer()` 체크로 로비 중 스폰 차단

---
