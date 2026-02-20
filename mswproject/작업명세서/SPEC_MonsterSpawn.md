# 🟡 대기중
# SPEC_MonsterSpawn — 몬스터 등장 시스템 v.1.1

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `MonsterSpawnComponent` |
| **기능 요약** | 플레이어 주변 도넛 범위 내 랜덤 좌표에 몬스터 주기적 스폰, 시간대별 구성 변화, 보스 등장 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 몬스터 등장 시스템 v.1.1.md` |
| **모듈화 레이어** | `Combat` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 스폰 타이머 관리 | `[server only]` | `_TimerService:SetTimerRepeat`로 주기 실행 |
| 도넛 좌표 계산 | `[server only]` | 플레이어 WorldPosition 기반 랜덤 좌표 산출 |
| 유효성 검증 & Retry | `[server only]` | 좌표 재시도 로직 |
| 엔티티 생성 | `[server only]` | `_SpawnService:SpawnByModelId` |
| 시간대 판정 | `[server only]` | `SpeedrunTimerComponent.ElapsedTime` 참조 |
| 보스 스폰 | `[server only]` | 맵 중앙(0,0) 고정 좌표 |
| 스폰 일시정지 | `[server only]` | 안전 지대(상점/컷신) 시 타이머 정지 |

---

## 3. Properties

### 3-1. DataTable 참조

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `SpawnConfigTableName` | `string` | `None` | `"SpawnConfig"` | 스폰 설정 DataTable명 |
| `SpawnWaveTableName` | `string` | `None` | `"SpawnWaveData"` | 시간대별 웨이브 DataTable명 |

### 3-2. 런타임 상태 (코드 전용)

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsSpawnActive` | `boolean` | `Sync` | `false` | 스폰 시스템 활성 여부 |
| `IsBossPhase` | `boolean` | `Sync` | `false` | 보스 페이즈 전환 여부 |
| `MonsterParentEntity` | `Entity` | `None` | `nil` | 스폰 몬스터 부모 엔티티 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_DataService` | `GetTable(tableName)` — SpawnConfig / SpawnWaveData 로드 |
| `_TimerService` | 스폰 주기 반복 타이머, 보스 스폰 예약 |
| `_SpawnService` | `SpawnByModelId(id, name, Vector3, parent)` — 몬스터 엔티티 생성 |
| `TransformComponent` | `.WorldPosition` — 플레이어 좌표 실시간 조회 |
| `math.random` / `math.cos` / `math.sin` | 도넛 랜덤 좌표 계산 (각도 + 반경) |

---

## 5. 로직 흐름

### 5-1. 초기화 (`OnBeginPlay`, 서버)
1. GRUtil 부트스트랩 → 스폰 카운터/타이머 ID 초기화
2. `LoadSpawnDataFromTable()` — DataTable 2종 로드 → `_T.Config`, `_T.Waves`에 캐시
3. `_T.SpawnedMonsters = {}` — 스폰된 몬스터 추적 테이블

> DataTable 로드 실패 시 `log_error` 후 스폰 비활성 유지 (방어)

### 5-2. 스폰 시작 / 정지
- `StartSpawning()` → `_TimerService:SetTimerRepeat(SpawnTick, SpawnInterval)` → `IsSpawnActive = true`
- `StopSpawning()` → `_TimerService:ClearTimer` → `IsSpawnActive = false`
- 안전지대 진입 시 `StopSpawning()`, 이탈 시 `StartSpawning()`

### 5-3. SpawnTick 핵심 루프 (플로우차트 기반)
```
for i = 1, SpawnPerTick do
    if #SpawnedMonsters >= MaxFieldMonsters → break (다음 스폰 시간 대기)
    for retry = 1, MaxRetryCount do
        좌표 = CalcDonutPosition(플레이어 위치)
        if 좌표 유효 → SpawnMonster(좌표) → break
    end
end
```

### 5-4. 도넛 좌표 산출 (`CalcDonutPosition`)
- 각도 = `math.random() * 2 * math.pi`
- 반경 = `InnerRadius + math.random() * (OuterRadius - InnerRadius)`
- X = `playerX + 반경 * math.cos(각도)`, Y = `playerY + 반경 * math.sin(각도)`

### 5-5. 시간대별 몬스터 선택 (DataTable 기반)
- `_T.Waves` 테이블을 순회하여 현재 `elapsed`에 매칭되는 행 탐색
- 매칭된 행의 `MonsterModelId` + `SpawnWeight` 기반 가중치 랜덤 선택
- 보스 행(`IsBoss=true`) 매칭 시 → `StopSpawning()` → 보스 1마리 맵 중앙(0,0) 스폰

### 5-6. 몬스터 파괴 추적
- 스폰 시 `_T.SpawnedMonsters` 테이블에 등록
- 몬스터 사망/파괴 시 테이블에서 제거 (카운트 유지)

---

## 6. DataTable 설계

### 6-1. `SpawnConfig` — 스폰 설정 (1행)

| Column | Type | 예시값 | 설명 |
|---|---|---|---|
| `InnerRadius` | `number` | `500` | 도넛 최소 반경 |
| `OuterRadius` | `number` | `800` | 도넛 최대 반경 |
| `SpawnInterval` | `number` | `5.0` | 스폰 주기 (초) |
| `SpawnPerTick` | `integer` | `3` | 회당 생성 수 |
| `MaxFieldMonsters` | `integer` | `30` | 필드 최대 유지 수 |
| `MaxRetryCount` | `integer` | `10` | 좌표 재산출 최대 시도 |

### 6-2. `SpawnWaveData` — 시간대별 웨이브 (다행)

| Column | Type | 예시값 | 설명 |
|---|---|---|---|
| `WaveId` | `integer` | `1` | PK |
| `StartTime` | `number` | `0` | 이 웨이브 시작 시간 (초) |
| `EndTime` | `number` | `60` | 이 웨이브 종료 시간 (초, -1=무한) |
| `MonsterModelId` | `string` | `"mob_normal_01"` | 스폰할 모델 ID |
| `SpawnWeight` | `integer` | `100` | 가중치 (같은 시간대 내 확률 분배) |
| `IsBoss` | `boolean` | `false` | 보스 여부 (true 시 맵 중앙 고정) |

> 예시 2행만 기재. 전체 데이터는 기획팀이 CSV로 관리.

---

## 7. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 7-1. 맵 엔티티

| 엔티티 경로 (제안) | 역할 | 비고 |
|---|---|---|
| `map/Map01/MonsterContainer` | 스폰 몬스터 부모 엔티티 | 빈 Entity, 정리 용도 |

### 7-2. 모델 등록

- 일반/엘리트/보스 몬스터 모델을 Maker에서 생성 후 Model ID를 `SpawnWaveData`에 기입

### 7-3. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 비고 |
|---|---|---|
| Player Entity (Bootstrap 자동) | `script.MonsterSpawnComponent` | `Map01BootstrapComponent.AttachRequiredComponentsServer`에 추가 |

---

## 8. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `SpeedrunTimerComponent` | Meta | `.ElapsedTime` 읽기 — 웨이브 시간대 판정 |
| `LobbyFlowComponent` | Bootstrap | `.IsLobbyActive` — 로비 시 스폰 정지, 런 시작 시 `StartSpawning()` |
| `ShopManagerComponent` | Meta | `.IsShopOpen` — 상점 오픈 시 스폰 일시정지 |
| `HPSystemComponent` | Combat | 보스 충돌 데미지는 기존 TriggerEnter 로직 활용 |
| `Map01BootstrapComponent` | Bootstrap | `AttachRequiredComponentsServer`에 추가 필요 |

---

## 9. 주의/최적화 포인트

- **OnUpdate 사용 금지** — `_TimerService:SetTimerRepeat`로 구현
- **DataTable 로드 실패 시** — `log_error` + 스폰 비활성 유지 (절대 하드코딩 폴백 금지)
- **밸런스 수치 하드코딩 금지** — 모든 수치는 DataTable에서 읽기
- `MaxFieldMonsters` 상한 체크 필수 — 렉 방지
- Retry 무한루프 방지 — `MaxRetryCount` 초과 시 해당 턴 스폰 생략
- 보스 페이즈 → 일반 스폰 **완전 중단**
- `_T.SpawnedMonsters`는 서버 전용 — 동기화 불필요
- 좌표 유효성: v.1.1은 **기본 범위 체크만** (NavMesh 미구현, 나중 고도화)

---

## 10. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트, `Combat` 레이어
- [ ] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [ ] `[server only]` 전체 — 클라이언트 로직 없음
- [ ] `_DataService:GetTable`로 SpawnConfig / SpawnWaveData 로드 → `_T`에 캐시
- [ ] 밸런스 수치 하드코딩 **절대 금지** — DataTable 값만 사용
- [ ] `nil`/`isvalid` 방어 + `pcall` 보호
- [ ] `Map01BootstrapComponent`에 부착 등록 코드 추가
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 11. Maker 수동 백로그

- [ ] Maker에서 `SpawnConfig` / `SpawnWaveData` DataTable 생성 및 CSV import
- [ ] 일반/엘리트/보스 몬스터 모델 생성 후 Model ID를 `SpawnWaveData`에 기입
- [ ] `MonsterContainer` 빈 엔티티를 맵에 배치
- [ ] Maker Play 테스트 — 스폰 반경/주기/웨이브 전환 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-20 |
| **상태** | 🟡 대기중 |
