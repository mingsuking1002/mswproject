# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

1스테이지 보스 처치 후 보스 사망 위치에 포탈 생성 → 플레이어가 접근하여 F키 → 페이크 로딩 UI → 맵 배경 RUID 교체 + `GameTimerComponent.CurrentStageId = 2` → 2스테이지 몬스터(`MonsterData.spawn_stage == 2`) 소환 개시. **표시 타이머(인게임 UI)는 그대로 유지**, 스폰 시간 참조 타이머만 초기화.

---

## 2. 컴포넌트 정의

### 2-1. `RoundTransitionComponent` (신규 — 플레이어 엔티티에 부착)

* **Execution Space:** `[Server Only]` (스테이지 전환), `[Client Only]` (로딩 UI, 포탈 상호작용)
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/RoundTransitionComponent.mlua`

---

## 3. Properties

| 이름 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `Stage2BackgroundRuid` | string | `""` | 2스테이지 맵 배경 RUID |
| `PortalInteractRadius` | number | `2.0` | 포탈 F키 상호작용 반경 |
| `FakeLoadingDuration` | number | `1.5` | 페이크 로딩 시간(초) |
| `PortalModelId` | string | `""` | 포탈 엔티티 모델 ID |
| `EnableDebugLogs` | boolean | `true` | 디버그 로그 |

---

## 4. Required MSW Services

* `_SpawnService` — 포탈 엔티티 생성
* `_TimerService` — 로딩 시간 타이머
* `_EntityService` — 엔티티 탐색

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `MonsterSpawnComponent` | `OnBossDefeatedServer()` → 포탈 생성. `CurrentStageId` 변경 시 `spawn_stage` 필터 자동 전환 (890행). 스폰 타이머 리셋용 `_T.StageSpawnElapsed = 0` 추가 |
| `GameTimerComponent` | `CurrentStageId = 2` 설정. `ElapsedTime`은 **리셋하지 않음** (표시 타이머 유지) |
| `BackgroundComponent` | `ChangeBackgroundByTemplateRUID(Stage2BackgroundRuid)` — 맵 배경 교체 |
| `Map01BootstrapComponent` | 자동 부착 목록에 `RoundTransitionComponent` 추가 |
| `BossAIComponent` | 보스 사망 시 `RoundTransitionComponent:SpawnPortalAtPositionServer(deathPos)` 호출 |

---

## 6. 타이머 분리 설계 (★ 핵심)

| 타이머 | 스테이지 전환 시 | 역할 |
|---|---|---|
| `GameTimerComponent.ElapsedTime` | **유지 (리셋 안 함)** | 인게임 UI 표시용 |
| `_T.StageSpawnElapsed` (신규) | **0으로 초기화** | `MonsterData.spawn_time`, `BossData.spawn_time` 비교용 |

### `MonsterSpawnComponent.ResolveCurrentSpawnContext` 수정

```pseudocode
-- 기존: context.ElapsedSec = timerComponent.ElapsedTime
-- 변경: 스테이지별 스폰 경과 시간 사용
if _T.StageSpawnElapsed ~= nil then
    context.ElapsedSec = _T.StageSpawnElapsed
else
    context.ElapsedSec = timerComponent.ElapsedTime
end
```

### `_T.StageSpawnElapsed` 누적

기존 `SpawnTick` 또는 `StateMonitorTimer`에서:
```pseudocode
-- IsLobby 아닐 때만 누적
_T.StageSpawnElapsed = _T.StageSpawnElapsed + (현재 ElapsedTime - 이전 ElapsedTime)
```

또는 더 단순하게:
```pseudocode
-- 스테이지 전환 시점의 ElapsedTime을 기록
_T.StageStartElapsedTime = GameTimerComponent.ElapsedTime

-- ResolveCurrentSpawnContext에서:
context.ElapsedSec = GameTimerComponent.ElapsedTime - _T.StageStartElapsedTime
```

---

## 7. Logic Architecture

### 7-1. 포탈 생성 (`SpawnPortalAtPositionServer`)

보스 사망 직후 호출:

```pseudocode
method void SpawnPortalAtPositionServer(Vector3 deathPos)
    local portalEntity = _SpawnService:SpawnByModelId(PortalModelId, "Portal", deathPos, Entity.CurrentMap)
    _T.PortalEntity = portalEntity
    _T.PortalPosition = deathPos
end
```

### 7-2. F키 상호작용 (`HandleKeyDownEvent`)

```pseudocode
handler HandleKeyDownEvent(KeyDownEvent event)
    if event.key ~= KeyboardKey.F then return end
    if _T.PortalEntity == nil then return end

    local dist = Distance(Entity.TransformComponent.WorldPosition, _T.PortalPosition)
    if dist > PortalInteractRadius then return end

    RequestStageTransitionServer()
end
```

### 7-3. 스테이지 전환 (`ExecuteStageTransitionServer`)

```pseudocode
method void ExecuteStageTransitionServer()
    -- 1. 모든 필드 몬스터 제거
    MonsterSpawnComponent:KillAllMonstersServer()

    -- 2. 스폰 중단
    MonsterSpawnComponent:StopSpawning()

    -- 3. 검은 로딩 UI 표시 (Client)
    ShowBlackLoadingUIClient()

    -- 4. 페이크 로딩 대기
    _TimerService:SetTimerOnce(function()

        -- 5. 맵 배경 RUID 교체
        local mapEntity = Entity.CurrentMap
        local bgComponent = mapEntity.BackgroundComponent
        bgComponent:ChangeBackgroundByTemplateRUID(Stage2BackgroundRuid)

        -- 6. 스테이지 ID 변경 (ElapsedTime은 유지!)
        GameTimerComponent.CurrentStageId = 2

        -- 7. 스폰 타이머 기준점 리셋
        MonsterSpawnComponent._T.StageStartElapsedTime = GameTimerComponent.ElapsedTime
        MonsterSpawnComponent._T.EliteSpawnedSet = {}

        -- 8. 포탈 제거
        _EntityService:Destroy(PortalEntity)
        _T.PortalEntity = nil

        -- 9. 스폰 재개 (spawn_stage == 2 필터 자동 적용)
        MonsterSpawnComponent:RefreshSpawnStateServer()

        -- 10. 로딩 UI 해제 (Client)
        HideBlackLoadingUIClient()

    end, FakeLoadingDuration)
end
```

### 7-4. 로딩 UI (Client Only)

```pseudocode
method void ShowBlackLoadingUIClient()
    -- 전체 화면 검은색 패널 + "Loading..." 텍스트 표시
    -- Entity Path: /ui/DefaultGroup/GRLoadingPanel
    local panel = _EntityService:GetEntityByPath("/ui/DefaultGroup/GRLoadingPanel")
    if panel ~= nil then panel.Enable = true end
end

method void HideBlackLoadingUIClient()
    local panel = _EntityService:GetEntityByPath("/ui/DefaultGroup/GRLoadingPanel")
    if panel ~= nil then panel.Enable = false end
end
```

---

## 8. MonsterSpawnComponent 수정 요약

| 수정 위치 | 내용 |
|---|---|
| `OnInitialize` | `_T.StageStartElapsedTime = 0` 추가 |
| `ResolveCurrentSpawnContext` | `context.ElapsedSec = ElapsedTime - _T.StageStartElapsedTime` |
| `ResolveSpawnCandidates` 890행 | 기존 `spawn_stage` 필터 **변경 없음** (CurrentStageId 자동 참조) |

---

## 9. Maker 배치

| 엔티티 | 위치 | 설명 |
|---|---|---|
| `GRLoadingPanel` | `/ui/DefaultGroup/GRLoadingPanel` | 전체 화면 검은색 패널 + 텍스트. 기본 `Enable = false` |
| 포탈 모델 | 동적 생성 | `SpawnByModelId`로 보스 사망 위치에 생성 |

---

## 10. 기획서 참조

* PD 직접 지시 (2026-02-26)
* `기획서/2.세부 시스템/v.1.1예인해_보스_리빌딩_시스템.docx` (스테이지 분기 규칙)

## 11. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

## 12. 주의/최적화 포인트

* **타이머 분리가 핵심**: `ElapsedTime`(표시)은 절대 리셋 안 함. `StageStartElapsedTime`(스폰 기준)만 갱신
* **BackgroundComponent API**: `ChangeBackgroundByTemplateRUID(ruid)` 사용. `MapComponent`에는 MapRuid 프로퍼티 없음
* **기존 spawn_stage 필터 활용**: `CurrentStageId` 변경만으로 `ResolveSpawnCandidates`가 자동으로 2스테이지 몬스터만 필터
* **elite 스폰 리셋**: `EliteSpawnedSet = {}` 초기화 → 2스테이지 elite도 정상 동작
* **포탈 충돌 방지**: 포탈은 시각적 엔티티만, 물리 충돌 없이 F키 거리 체크로 상호작용

---
