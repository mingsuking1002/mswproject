# 🟢 완료
# SPEC_EngineSetup — 엔진 사전 세팅 지침서

## projectGR_main_proposal.md 를 토대로 환경 구축 지침

| 항목 | 내용 |
|---|---|
| **작업 순서** | **0번** — 모든 SPEC 코드 구현 전에 먼저 수행 |
| **작업 목적** | 기획서 기반으로 MSW Maker 엔진 환경을 세팅하여, 이후 코드(mlua)가 정상 동작할 기반 마련 |
| **작업 유형** | Codex(파일 편집) + 사용자(Maker GUI) 혼합 |
| **기획서 참조** | `기획서/` 전체 — 8개 SPEC 명세서에서 정의한 컴포넌트·충돌·서비스 요구사항 종합 |
| **선행 조건** | 8개 SPEC 명세서 작성 완료 |

### 핵심 원칙
- 기획서 → SPEC 명세서 → **이 지침서(환경 구축)** → SPEC별 코드 구현 순서로 진행
- Maker **닫힌 상태**에서 파일 편집 → 편집 후 Maker 재오픈
- Maker에서만 가능한 작업은 사용자가 직접 수행

---

## 2. 작업 분류

| 구분 | 작업 | 담당 |
|---|---|---|
| 🤖 | DefaultPlayer에 커스텀 컴포넌트 추가 | **Antigravity** (JSON 편집) |
| 🤖 | GRProjectileTemplate에 컴포넌트 추가 | **Antigravity** (JSON 편집) |
| 🤖 | CollisionGroup 레이어 추가 및 충돌 매트릭스 세팅 | **Antigravity** (JSON 편집) |
| 👤 | 스프라이트/이펙트/사운드 리소스 임포트 | **사용자** (Maker GUI) |
| 👤 | 지형/벽 충돌체 배치 | **사용자** (Maker GUI) |
| 👤 | LeaderBoard / DataStorage 서비스 활성화 | **사용자** (Maker 월드설정) |
| 👤 | 플레이 테스트 | **사용자** (Maker Play) |

---

## 3. 🤖 Antigravity 작업 상세

### 3-1. DefaultPlayer.model — 컴포넌트 등록

**대상 파일:** `Global/DefaultPlayer.model`

현재 `Components: []` (빈 배열) → 아래 커스텀 컴포넌트를 JSON에 추가

| 추가할 컴포넌트 | 관련 SPEC | 필수 |
|---|---|---|
| `MovementComponent` | SPEC_Movement | ✅ |
| `CameraFollowComponent` | SPEC_Movement | ✅ |
| `HPSystemComponent` | SPEC_HPSystem | ✅ |
| `FireSystemComponent` | SPEC_FireSystem | ✅ |
| `ReloadComponent` | SPEC_ReloadSystem | ✅ |
| `WeaponSwapComponent` | SPEC_WeaponSwap | ✅ |
| `TagManagerComponent` | SPEC_TagSystem | ✅ |
| `SpeedrunTimerComponent` | SPEC_SpeedrunTimer | ✅ |
| `RankingComponent` | SPEC_RankingSystem | ✅ |

> ⚠️ **주의:** Maker가 열려 있으면 파일 충돌 발생 → **Maker 닫힌 상태에서 편집**

### 3-2. map01.map — GRProjectileTemplate 컴포넌트 추가

**대상 파일:** `map/map01.map`

현재 `GRProjectileTemplate` 엔티티에 `TransformComponent`만 부착됨 → 추가 필요:

| 추가할 컴포넌트 | 용도 |
|---|---|
| `ProjectileComponent` | 투사체 로직 (이동/충돌/소멸) |
| `SpriteRendererComponent` | 총알 비주얼 |
| `TriggerComponent` | 충돌 감지 트리거 |

### 3-3. CollisionGroupSet — 충돌 레이어 추가

**대상 파일:** `Global/CollisionGroupSet.collisiongroupset`

현재 그룹: `Default`, `TriggerBox`, `HitBox`, `Interaction`, `Portal`, `Climbable`

**추가할 그룹:**

| 그룹 이름 | 용도 |
|---|---|
| `Player` | 플레이어 충돌체 |
| `Enemy` | 적 몬스터 충돌체 |
| `PlayerProjectile` | 플레이어 투사체 |
| `EnemyProjectile` | 적 투사체 |
| `Terrain` | 지형/벽 충돌체 |

**충돌 매트릭스 (충돌 활성화 쌍):**

| 쌍 | 설명 |
|---|---|
| Player ↔ Enemy | 플레이어-적 몸통 충돌 |
| Player ↔ EnemyProjectile | 적 총알에 피격 |
| Player ↔ Terrain | 벽 슬라이드 |
| PlayerProjectile ↔ Enemy | 아군 총알이 적 적중 |
| PlayerProjectile ↔ Terrain | 총알이 벽에 부딪혀 소멸 |
| Enemy ↔ Terrain | 적도 벽에 멈춤 |

**충돌 비활성 (기본):**

| 쌍 | 이유 |
|---|---|
| Player ↔ PlayerProjectile | 자기 총알에 맞으면 안 됨 |
| Enemy ↔ EnemyProjectile | 적이 아군 총알에 맞으면 안 됨 |

---

## 4. 👤 사용자 작업 상세

### 4-1. 스프라이트/이펙트 리소스 임포트

Maker에서 리소스를 임포트하여 **RUID 확보** 필요:

| 리소스 | 사용처 | 우선순위 |
|---|---|---|
| 총알 스프라이트 | `GRProjectileTemplate` SpriteRenderer | 🔴 높음 |
| 캐릭터 A 아바타/코스튬 | TagManager (외형 교체) | 🟡 중간 |
| 캐릭터 B 아바타/코스튬 | TagManager (외형 교체) | 🟡 중간 |
| 총구 화염 이펙트 | FireSystem 발사 연출 | 🟢 낮음 (후반) |
| 피격 이펙트 | HPSystem 피격 연출 | 🟢 낮음 (후반) |
| 발사음/빈 탄창 사운드 | FireSystem 사운드 | 🟢 낮음 (후반) |

> 리소스 임포트 후 RUID를 코드의 해당 Property에 설정해야 함

### 4-2. 지형/벽 충돌체 배치

맵에 이동 차단용 경계/장애물 배치:

1. Maker에서 map01 열기
2. 빈 엔티티 생성 → `TransformComponent` + `ColliderComponent`(Box) 추가
3. Collision Group을 **`Terrain`**으로 설정
4. 맵 가장자리에 보이지 않는 벽 배치 (또는 타일맵 콜라이더 활용)

### 4-3. 서비스 활성화

Maker → 월드 설정에서 확인/활성화:

| 서비스 | 사용 SPEC | 확인 사항 |
|---|---|---|
| `_LeaderBoardService` | SPEC_RankingSystem | 리더보드 기능 ON |
| `_DataStorageService` | SPEC_SpeedrunTimer, SPEC_RankingSystem | 데이터 저장 기능 ON |

### 4-4. DefaultPlayer 물리 설정 확인

Maker에서 DefaultPlayer 열고:

1. `RigidbodyComponent` 추가 (없으면)
2. **Body Type:** `Dynamic`
3. **Gravity Scale:** `0` (탑뷰이므로 중력 불필요)
4. **Freeze Rotation Z:** `true` (회전 방지)

> ⚠️ MSW 기본 플레이어는 횡스크롤용이라 중력이 1.0으로 설정되어 있을 수 있음 → 반드시 0으로 변경

---

## 5. 작업 순서 (Phase)

### Phase 1: 파일 편집 (Antigravity) — Maker 닫힌 상태에서
- [ ] `DefaultPlayer.model`에 9개 컴포넌트 등록
- [ ] `map01.map`의 GRProjectileTemplate에 3개 컴포넌트 추가
- [ ] `CollisionGroupSet`에 5개 그룹 + 매트릭스 추가

### Phase 2: Maker GUI 작업 (사용자) — Maker 열고
- [ ] 리소스 임포트 (최소한 총알 스프라이트)
- [ ] DefaultPlayer 물리 설정 (RigidbodyComponent, Gravity 0)
- [ ] 지형/벽 충돌체 배치
- [ ] LeaderBoard / DataStorage 서비스 활성화

### Phase 3: 검증
- [ ] Maker에서 Play → 캐릭터 WASD 이동 확인
- [ ] 좌클릭 발사 → 투사체 생성 확인
- [ ] 벽 충돌 → 슬라이드 확인
- [ ] 콘솔 에러 없음 확인

---

## 6. 주의 사항

- [ ] Phase 1 (파일 편집)은 반드시 **Maker를 닫은 상태**에서 진행
- [ ] 편집 후 Maker 재오픈 시 **워크스페이스 새로고침** 필요할 수 있음
- [ ] 컴포넌트 등록만으로는 동작 안 함 — mlua 코드 파일이 같은 이름으로 존재해야 함 (이미 완료)
- [ ] Collision Group ID는 고유한 GUID or 문자열 — 기존 패턴 따라 GUID 생성

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Antigravity (Phase 1) + 사용자 (Phase 2) |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
