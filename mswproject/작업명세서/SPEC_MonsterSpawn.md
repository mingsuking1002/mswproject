# 🟢 완료
# SPEC_MonsterSpawn — 몬스터 등장 시스템 v1.1 (구현 반영본)

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `MonsterSpawnComponent` |
| **기능 요약** | 플레이어 주변 도넛 범위 랜덤 스폰, 스테이지/시간 기반 웨이브 판정, 보스 페이즈 전환, 드랍 메타 캐시 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 몬스터 등장 시스템 v.1.1.md` |
| **모듈화 레이어** | `Combat` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 데이터 로드 | `[server only]` | `_DataService:GetTable`로 `SpawnConfig`/`MonsterData` 로드 |
| 스폰 상태 모니터 | `[server only]` | 타이머 기반(`StateMonitorInterval`)으로 로비/상점 상태 반영 |
| 스폰 루프 | `[server only]` | `_TimerService:SetTimerRepeat` 기반 주기 처리 |
| 좌표 계산/검증 | `[server only]` | 도넛 반경 내 좌표 생성 및 기본 범위 체크 |
| 몬스터 생성 | `[server only]` | `_SpawnService:SpawnByModelId` |
| 보스 페이즈 전환 | `[server only]` | 보스 스폰 성공 시 일반 스폰 중단 |

---

## 3. Properties

### 3-1. DataTable / 설정

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `SpawnConfigTableName` | `string` | `None` | `"SpawnConfig"` | 스폰 설정 테이블명 |
| `MonsterDataTableName` | `string` | `None` | `"MonsterData"` | 웨이브+드랍 통합 몬스터 테이블명 |
| `SpawnWaveTableName` | `string` | `None` | `""` | 구버전 호환 별칭(비어있지 않으면 fallback로 사용) |
| `MonsterContainerName` | `string` | `None` | `"MonsterContainer"` | 맵 내 몬스터 부모 엔티티 이름 |
| `StateMonitorInterval` | `number` | `None` | `0.2` | 스폰 가능 상태 재평가 주기(초) |

### 3-2. 런타임 상태

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsSpawnActive` | `boolean` | `Sync` | `false` | 스폰 시스템 활성 여부 |
| `IsBossPhase` | `boolean` | `Sync` | `false` | 보스 페이즈 여부 |
| `MonsterParentEntity` | `Entity` | `None` | `nil` | 스폰 몬스터 부모 엔티티 |

---

## 4. 공개 인터페이스(확장 포인트)

| Method | 설명 |
|---|---|
| `LoadMonsterDataFromTable()` | 통합 몬스터 테이블 로드 |
| `ResolveSpawnCandidates(stage, elapsedSec)` | 현재 스테이지/시간의 스폰 후보 계산 |
| `BuildSpawnMetaFromRow(row)` | 드랍/보상 연동용 메타 생성 |
| `ApplyMonsterStatsIfAvailable(entity, row)` | 스탯 적용 어댑터 훅(미정 명세 대응) |
| `GetSpawnMetaByEntity(entity)` | 스폰 메타 조회 API |

---

## 5. 로직 흐름

### 5-1. 시작/초기화
1. `OnInitialize`: 런타임 캐시 초기화(`_T.SpawnedMonsters`, `_T.SpawnMetaByEntity` 등)
2. `OnBeginPlay`: `LoadSpawnDataFromTable()` → `ResolveMonsterParentEntity()` → 상태 모니터 타이머 시작
3. 데이터 누락/로드 실패 시 `IsSpawnActive=false` 유지 + 로그 출력

### 5-2. 스폰 상태 전환
- `RefreshSpawnStateServer()`가 단일 게이트 역할 수행
- 조건: 데이터 준비 완료, 보스 페이즈 아님, `MonsterContainer` 존재, 로비/상점 아님
- 조건 만족 시 `StartSpawning()`, 불만족 시 `StopSpawning()`

### 5-3. SpawnTick
1. 현재 컨텍스트 계산(`SpeedrunTimerComponent.CurrentStageId`, `ElapsedTime`)
2. `ResolveSpawnCandidates(stage, elapsedSec)`로 후보 분리(`NormalRows`, `BossRows`)
3. 보스 후보 존재 시 최신 시간 보스 1회 스폰 후 `IsBossPhase=true`, 일반 스폰 중단
4. 일반 후보는 `SpawnPerTick`/`MaxFieldMonsters`/`MaxRetryCount` 제약으로 생성
5. 생성 성공 시 메타 저장 + `ApplyMonsterStatsIfAvailable()` 호출

### 5-4. 좌표/유효성
- 도넛 반경(`InnerRadius~OuterRadius`) 랜덤 좌표 생성
- v1.1 기준 기본 반경 검증만 수행(NavMesh 고급 검증 미구현)

---

## 6. DataTable 설계

### 6-1. `SpawnConfig` (1행)

| Column | Type | 설명 |
|---|---|---|
| `InnerRadius` | `number` | 도넛 최소 반경 |
| `OuterRadius` | `number` | 도넛 최대 반경 |
| `SpawnInterval` | `number` | 스폰 주기(초) |
| `SpawnPerTick` | `integer` | 회당 생성 수 |
| `MaxFieldMonsters` | `integer` | 필드 최대 몬스터 수 |
| `MaxRetryCount` | `integer` | 좌표 재시도 횟수 |

### 6-2. `MonsterData` (웨이브+드랍 통합)

| Column | Type | 설명 |
|---|---|---|
| `id` | `string` | 몬스터 식별자 |
| `name` | `string` | 표시 이름 |
| `mon_type` | `string` | `normal`/`elite`/`boss` |
| `model_type` | `string` | 스폰 모델 ID(빈 값 허용, 타입별 fallback 지원) |
| `mon_hp`, `mon_atk`, `mon_spd` | `number/integer` | 스탯 값 |
| `spawn_stage` | `integer` | 출현 스테이지 |
| `spawn_time (min)` | `number` | 분 단위 출현 시간 |
| `gold` | `integer` | 처치 보상 골드 메타 |
| `drop_item_*` | `string/number/integer` | 드랍 메타 컬럼 |
| `sprite_ruid`, `sound_ruid`, `death_effect_ruid` | `string` | 연출 리소스 메타 |

---

## 7. 미정 영역 처리(확장 용이성 우선)

1. 드랍 지급 로직: **미구현** (`BuildSpawnMetaFromRow`로 메타만 보관)
2. 몬스터 스탯 적용: 대상 컴포넌트 존재 시에만 안전 적용, 없으면 스킵
3. 고급 좌표 검증(NavMesh): **미구현**, 기본 반경+재시도 유지
4. 변경 포인트 고정: `Resolve*`, `Build*`, `Apply*` 계층으로 후속 교체 가능

---

## 8. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `Map01BootstrapComponent` | `AttachRequiredComponentsServer` 필수 목록에 `MonsterSpawnComponent` 추가 |
| `SpeedrunTimerComponent` | `CurrentStageId`, `ElapsedTime` 읽어 스폰 시점 판정 |
| `LobbyFlowComponent` | `IsLobbyActive=true`면 스폰 정지 |
| `ShopManagerComponent` | `IsShopOpen=true`면 스폰 정지 |
| `GRUtilModule` | 안전한 컴포넌트 조회/연동 유틸 부트스트랩 |

---

## 9. 구현 체크리스트

- [x] `MonsterSpawnComponent.mlua` 신규 추가
- [x] `MonsterSpawnComponent.codeblock(Target mLua)` 신규 추가
- [x] `Map01BootstrapComponent` 자동 부착 목록에 `MonsterSpawnComponent` 추가
- [x] `Data/SpawnConfig.csv` 추가
- [x] `Data/MonsterData.csv` 추가(웨이브+드랍 통합)
- [x] DataTable 누락/부모 엔티티 누락 방어 로그 및 안전 정지 처리
- [x] `spawn_stage`, `spawn_time (min)` 기반 필터 로직 구현
- [x] 보스 시간대 진입 시 일반 스폰 중단 로직 구현
- [x] 로비/상점 상태 기반 스폰 정지/재개 로직 구현
- [x] `GetSpawnMetaByEntity` 조회 API 제공
- [x] `기획서/4.부록/Code_Documentation.md` 갱신

---

## 10. Maker 수동 백로그

- [ ] Maker DataTable에 `SpawnConfig.csv`, `MonsterData.csv` import
- [ ] `MonsterContainer` 엔티티를 대상 맵에 배치
- [ ] 몬스터 모델 리소스(`model_type`) 실제 연결 점검
- [ ] Maker Play 테스트로 웨이브/보스/안전지대 정지 동작 검증
- [ ] 후속 명세 수신 후 드랍 실지급/고급 좌표 검증/NavMesh 보강

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-20 |
| **상태** | 🟢 완료 |
