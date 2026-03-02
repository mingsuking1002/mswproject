# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 |
|---|---|
| 2026-03-03 | 🟡 대기중 |

---

## 1. 개요

현재 spawn_time을 경과한 **모든** 몬스터가 누적 풀에 포함되어 동시 스폰됨 → **해당 시간대의 최신 1종만** 스폰하도록 변경. 엘리트는 spawn_time에 **정확히 1회만** 출현하고 이후 재스폰 없음 보장.

---

## 2. 수정 대상 파일 (1개)

### [MODIFY] MonsterSpawnComponent.mlua

---

## 3. 변경 로직 상세

### ① Normal 몬스터: 누적 풀 → 교체 풀
**현재 (L1026~1067 `ResolveSpawnCandidates`):**
```
spawn_time <= currentMin 인 모든 row를 NormalRows에 추가 (누적)
→ PickRandomRow(NormalRows)
```

**변경 후:**
```
-- 현재 시간에 해당하는 spawn_time 구간의 최신 1종만 풀에 포함
-- 예: 3분이면 spawn_time=2인 row만 (spawn_time=0 은 제외)
for _, row in pairs(rows) do
    if monType == "normal" then
        local spawnMin = GetSpawnMinuteFromRow(row)
        if spawnMin < 0 then continue end
        if elapsedSec < (spawnMin * 60) then continue end
        -- ★ 핵심: 다음 row의 spawnTime보다 작은 경우만 포함
        -- 구현: 정렬된 spawn_time 구간 테이블(breakpoints) 사전 구축
        --       currentBreakpointMin = 마지막으로 도달한 spawn_time
        --       row.spawn_time == currentBreakpointMin 인 것만 NormalRows에 추가
        if spawnMin == currentBreakpointMin then
            table.insert(result.NormalRows, row)
        end
    end
end
```

**구현 방법:**
1. `OnInitialize` 또는 `LoadMonsterDataFromTable`에서 normal row의 spawn_time 값을 수집하여 **정렬된 breakpoints 배열** 구축 (예: `{0, 2, 4, 6, 8, 10, 12}`)
2. `ResolveSpawnCandidates`에서 `elapsedMin = math.floor(elapsedSec / 60)` 계산
3. breakpoints에서 `elapsedMin` 이하인 가장 큰 값 = `currentBreakpoint`
4. `row.spawn_time == currentBreakpoint`인 normal row만 `NormalRows`에 추가

### ② Elite 몬스터: 1회 스폰 강화
**현재 (`CheckEliteSpawnsServer` L1088~1160):**
- `EliteSpawnedSet[eliteId]`로 1회 체크 ← **이미 존재**
- 단, 시간이 지나면 과거 엘리트도 일괄 트리거될 수 있음

**변경 후 (보강):**
- **현재 로직 유지** (1회 체크 자체는 정상 동작)
- 추가 변경 없음 — `EliteSpawnedSet`가 이미 1회 제한 역할 수행
- 단, 디버그 패널 시간 +5분 시 과거 엘리트 일괄 스폰 방지:
  - `CheckEliteSpawnsServer`에서 `elapsed >= spawnSec` 검사 시 **정확히 해당 시간대인지** 검증
  - 구현: `spawnSec <= elapsed < (spawnSec + bufferSec)` 조건 추가 (buffer = SpawnInterval * 3 정도)
  - 또는: 시간 점프 감지 시 점프 이전 시간의 엘리트는 스킵

---

## 4. Properties (추가/변경)

- 없음 (기존 Property 변경 없음)
- `_T.NormalSpawnBreakpoints` — 런타임 배열 (정렬된 spawn_time 값)

---

## 5. Required MSW Services

- 해당 없음

---

## 6. 연동 컴포넌트

| 컴포넌트 | 관계 |
|---|---|
| GameTimerComponent | ElapsedTime 읽기 (기존 그대로) |
| InfiniteModeComponent | 무한모드 elapsed 읽기 (기존 그대로) |

---

## 7. 기획서 참조

- `기획서/1.핵심 시스템/[시스템] 몬스터 등장 시스템 v.1.1.md`
- PD 구두 지시 (2026-03-03): "spawn_time 시간대의 몬스터만 스폰, 엘리트 1회만"

---

## 8. 구현 방식

mcp 이용해서 직접 workspace에서 작업

---

## 9. 주의/최적화 포인트

- breakpoints 배열은 `LoadMonsterDataFromTable` 시 1회만 구축 → 스폰 틱마다 재계산 금지
- 같은 spawn_time을 가진 normal row가 여러 개일 수 있음 (같은 시간대 복수 몬스터 종류) → 해당 시간대의 모든 row 포함, PickRandomRow로 랜덤 선택
- **디버그 패널 시간 점프 시** 과거 엘리트 일괄 스폰 방지 주의
