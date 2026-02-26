# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

보스 리빌딩 시스템 구현. 보스(`mon_type == "boss"`)는 기존 스폰 시스템과 별도로 동작하며, **플레이어 위치 기반 몬스터 소환 + 가속/감속 패턴**을 수행한다. 보스 처치 시 스테이지 분기(1→2스테이지 보상, 2→무한모드 전환)를 처리한다.

---

## 2. 컴포넌트 정의

### 2-1. `BossAIComponent` (신규 — 보스 엔티티에 부착)

* **Execution Space:** `[Server Only]`
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/BossAIComponent.mlua`
* **역할:** 보스 공격 패턴(몬스터 소환), 소환 몬스터 가속/감속, 사망 이벤트 발행

---

## 3. Properties — `BossAIComponent`

| 이름 | 타입 | 기본값 | 설명 |
|---|---|---|---|
| `AttackInterval` | number | `2.0` | 공격 주기(초). 보스1=2.0, 보스2=1.5 |
| `SummonMonsterId` | string | `""` | 소환할 몬스터 DataID. 보스1=`mon_n007`, 보스2=`mon_n014` |
| `SpeedBoostMultiplier` | number | `2.0` | 소환 몬스터 초기 이속 배율 |
| `SlowdownRadius` | number | `3.0` | 플레이어 근처 감속 반경 |
| `GungnirDamageRatio` | number | `0.5` | 궁니르 피해 절반 적용 비율 |
| `BossDataTableName` | string | `"BossData"` | 보스 전용 데이터 테이블 |
| `BossStageId` | integer | `1` | 이 보스가 속한 스테이지 (1 or 2) |
| `EnableDebugLogs` | boolean | `true` | 디버그 로그 |

---

## 4. Required MSW Services

* `_TimerService` — 공격 주기 타이머 (보스 자체 타이머, 보스 생존 중에만 작동)
* `_DataService` — `BossData` + 소환 몬스터 데이터 로드

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `MonsterSpawnComponent` | 보스 스폰 시 `IsBossPhase = true` + `StopSpawning()`. 보스 사망 시 `OnBossDefeatedServer()` 호출 |
| `GameTimerComponent` | 보스 사망 후 스테이지 분기: `CurrentStageId` 변경, `PauseGame()`/`ResumeGame()` |
| `MonsterChaseComponent` | 소환된 몬스터에 부착, 가속/감속 로직 연동 |
| `HPSystemComponent` | 보스 HP 관리, 사망 감지 |
| `PenaltySystemComponent` | 보스전 중에도 패널티 정상 작동 (변경 없음) |
| `FireSystemComponent` | 궁니르 무기 판별 → 보스에 데미지 절반 적용 |
| `ShopManagerComponent` | 보스 처치 후 상점 오픈 (기존 플로우) |
| `InfiniteModeComponent` | 2스테이지 보스 처치 → 무한모드 전환 |

---

## 6. Logic Architecture

### 6-1. 보스 스폰 (기존 MonsterSpawnComponent 플로우)

기존 `SpawnTick`에서 `BossRows` 감지 → `SpawnMonsterByRow(bossRow, pos, true)` → `IsBossPhase = true` + `StopSpawning()` → 이 부분은 **이미 구현됨** (771행). 추가로:

```pseudocode
-- SpawnMonsterByRow에서 isBoss == true 일 때:
소환된 보스 엔티티에 BossAIComponent 동적 부착
BossAIComponent.AttackInterval = BossData에서 읽기
BossAIComponent.SummonMonsterId = BossData에서 읽기
BossAIComponent.BossStageId = GameTimerComponent.CurrentStageId
```

### 6-2. 보스 공격 패턴 (`BossAIComponent.StartAttackLoopServer`)

```pseudocode
OnBeginPlay:
    소환 몬스터 데이터 캐시
    StartAttackLoopServer()

method StartAttackLoopServer():
    _T.AttackTimerId = _TimerService:SetTimerRepeat(function()
        -- IsLobby 가드
        local playerEntity = 플레이어 엔티티 탐색
        local playerPos = playerEntity.TransformComponent.WorldPosition

        -- 플레이어 시야 내 위치에 몬스터 1마리 소환
        -- (플레이어 시야 범위 2배 거리에서 스폰)
        local spawnPos = CalcViewportSpawnPosition(playerPos)
        local monster = SpawnSummonedMonster(spawnPos)

        -- 소환된 몬스터에 가속 부여
        if monster ~= nil then
            local movement = monster:GetComponent("MovementComponent")
            if movement ~= nil then
                movement.SpeedMultiplier = SpeedBoostMultiplier
            end
            -- 감속 체크를 위해 _T.SummonedMonsters에 등록
            table.insert(_T.SummonedMonsters, {Entity = monster, Boosted = true})
        end
    end, AttackInterval, 0)
```

### 6-3. 소환 몬스터 감속 체크 (`CheckSlowdownServer`)

StateMonitorTimer 또는 자체 타이머에서 주기적 호출:

```pseudocode
for _, info in pairs(_T.SummonedMonsters) do
    if info.Boosted == true then
        local dist = Distance(info.Entity, playerEntity)
        if dist <= SlowdownRadius then
            -- 기본 이동속도로 복원
            info.Entity.MovementComponent.SpeedMultiplier = 1.0
            info.Boosted = false
        end
    end
end
```

### 6-4. 궁니르 데미지 절반 (`FireSystemComponent` 수정)

`CalculateFinalDamage` 또는 데미지 적용 시점에:

```pseudocode
-- 타겟이 보스인지 확인 (SpawnMeta.MonType == "boss")
-- 현재 무기가 궁니르인지 확인
if 타겟이보스 and 무기가궁니르 then
    finalDamage = finalDamage * GungnirDamageRatio  -- 0.5
end
```

### 6-5. 보스 사망 처리 (`OnBossDefeatedServer`)

`MonsterSpawnComponent`에서 보스 엔티티 사망 감지 후 호출:

```pseudocode
method void OnBossDefeatedServer()
    IsBossPhase = false
    _T.BossSpawnedEntity = nil

    local stageId = GameTimerComponent.CurrentStageId

    if stageId == 1 then
        -- 1스테이지 보스 처치 → 보상 상점 + 포탈 생성
        ShopManager:OpenBossRewardShopServer()
        -- 상점 닫힌 후 → 포탈 엔티티 활성화
        -- 플레이어가 포탈 근처에서 F키 → TransitionToStage2Server()
    elseif stageId == 2 then
        -- 2스테이지 보스 처치 → 선택 UI 표시
        -- 선택지 A: 무한모드 진입 → InfiniteModeComponent:ActivateInfiniteModeServer(true)
        -- 선택지 B: 로비 복귀 → LobbyFlowComponent:SetLobbyStateServer(true)
    end
end
```

### 6-6. 보스 사망 감지

기존 `ProcessMonsterDeathSequenceServer`에서 사망 처리 시:

```pseudocode
if _T.BossSpawnedEntity == deathEntity then
    OnBossDefeatedServer()
end
```

### 6-7. 스테이지 전환 — 포탈 + 맵 RUID 교체

1스테이지 보스 처치 후 포탈 엔티티 활성화 → F키로 상호작용:

```pseudocode
-- 포탈 근처 F키 → TransitionToStage2Server()
method void TransitionToStage2Server()
    -- 검은 로딩 UI 표시 (Client)
    ShowBlackTransitionUIClient()
    -- 맵 RUID만 교체 (실제 맵 이동 아님)
    local mapEntity = Entity.CurrentMap
    mapEntity.MapComponent.MapRuid = Stage2MapRuid
    -- 스테이지 ID 변경
    GameTimerComponent.CurrentStageId = 2
    GameTimerComponent:ResetRun()
    GameTimerComponent:StartRunWithCountdown()
    -- 로딩 UI 해제
    HideBlackTransitionUIClient()
end
```

### 6-8. 2스테이지 보스 처치 후 선택 UI

```pseudocode
-- 선택지 UI 표시 (Client)
-- [무한모드 진입] → InfiniteModeComponent:ActivateInfiniteModeServer(true)
-- [로비 복귀] → LobbyFlowComponent:SetLobbyStateServer(true)
```

---

## 7. 몬스터 소환 위치 — 시야 내 스폰

기획서: **"몬스터 스폰 시스템을 무시하고 플레이어 시야 내에서 몬스터 소환"**

```pseudocode
method Vector3 CalcViewportSpawnPosition(playerPos)
    local angle = math.random() * 2 * math.pi
    local radius = ViewportRadius * 2  -- 화면 밖 가장자리
    return Vector3(
        playerPos.x + math.cos(angle) * radius,
        playerPos.y + math.sin(angle) * radius, 0
    )
end
```

---

## 8. DataTable 연동 — `BossData` (별도 테이블)

| 컬럼 | 타입 | 설명 | 예시 |
|---|---|---|---|
| `id` | string (PK) | 보스 ID | `"boss_01"` |
| `mon_type` | string | `"boss"` | `"boss"` |
| `mon_hp` | integer | 보스 HP | `5000` |
| `mon_atk` | integer | 보스 공격력 | `0` (직접 공격 없음) |
| `atk_interval` | number | 소환 주기(초) | `2.0` / `1.5` |
| `summon_id` | string | 소환 몬스터 ID | `"mon_n007"` / `"mon_n014"` |
| `speed_boost` | number | 소환 몬스터 가속 배율 | `2.0` |
| `slowdown_radius` | number | 감속 반경 | `3.0` |
| `model_type` | string | 보스 모델 | (보스 모델 ID) |
| `spawn_time` | number | 등장 시간(분) | `14` |
| `stage_id` | integer | 소속 스테이지 | `1` / `2` |

---

## 9. 기획서 참조

* `기획서/2.세부 시스템/v.1.1예인해_보스_리빌딩_시스템.docx_1.png`
* `기획서/2.세부 시스템/v.1.1예인해_보스_리빌딩_시스템.docx_2.png`

---

## 10. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

---

## 11. 주의/최적화 포인트

* **보스 공격 타이머**: 보스 자체의 `_TimerService:SetTimerRepeat`로 구현. 보스 사망 시 `OnEndPlay`에서 자동 정리
* **소환 몬스터 풀링**: `_T.SummonedMonsters` 목록 관리, 사망/파괴된 엔티티 주기적 정리
* **궁니르 판별**: `WeaponSwapComponent` 또는 `Projectile_data`의 무기 ID로 궁니르 여부 확인
* **IsLobby 가드**: 보스 공격 루프 콜백 최상단에 IsLobby 가드 적용
* **스테이지 전환 타이밍**: 보스 사망 → 보상 상점 오픈 → 상점 닫힘 → 새 스테이지 시작. 순차적 처리 필요

---
