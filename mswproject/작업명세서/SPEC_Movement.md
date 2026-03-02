# 🟢 완료
# SPEC_Movement — 8방향 이동 + 카메라 시스템

## 0. 상태 이력

| 일시 | 상태 | 비고 |
|---|---|---|
| 2026-03-03 | 🟡 대기중 | 카메라 first-stop(카메라 먼저 정지) 요청 접수 |
| 2026-03-03 | 🔵 진행중 | CameraFollowComponent 경계 분리/재시도/하드락 적용 구현 시작 |
| 2026-03-03 | 🟢 완료 | `.mlua`/`.codeblock` 동기화 및 문서 갱신 완료 |
| 2026-03-03 | 🟡 대기중 | 카메라를 맵 타일 경계 기준으로 정렬 요청 접수 |
| 2026-03-03 | 🔵 진행중 | RectTileMap 경계 우선 계산(타일 경계 기준) 반영 시작 |
| 2026-03-03 | 🟢 완료 | 카메라 타일 경계 기준 정렬 및 문서 갱신 완료 |
| 2026-03-03 | 🟡 대기중 | 캐릭터 이동 경계를 CenterSpawn RectTile 기준으로 통일 요청 접수 |
| 2026-03-03 | 🔵 진행중 | Movement/Bootstrap 경계를 RectTile 기준 우선 계산으로 통일 작업 시작 |
| 2026-03-03 | 🟢 완료 | 캐릭터 이동 경계도 CenterSpawn RectTile 기준으로 동기화 완료 |
| 2026-03-03 | 🟡 대기중 | 카메라 제한 제거 + 캐릭터 중심(0,0) 고정 요청 접수 |
| 2026-03-03 | 🔵 진행중 | CameraFollowComponent 경계/부트스트랩 로직 제거 및 하드락 추적 단순화 시작 |
| 2026-03-03 | 🟢 완료 | 카메라 제한 제거 완료 (`UseCustomBound=false`, `CameraOffset=(0,0)` 고정) |

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `MovementComponent`, `CameraFollowComponent` |
| **기능 요약** | WASD 8방향 캐릭터 이동 + 카메라 추적 (맵 경계 클램핑) |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 기본 이동 기획 v.1.2.md` |
| **모듈화 레이어** | `Core` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| WASD 입력 감지 | `[client only]` | `_InputService` → `IsKeyPressed()` |
| 이동 벡터 계산 | `[client only]` | 방향 벡터 정규화(Normalize) |
| 위치 이동 (물리) | `[server]` | RigidbodyComponent 또는 TransformComponent |
| 카메라 추적 | `[client only]` | 카메라 위치 = 캐릭터 위치 (`CameraOffset=(0,0)`, 경계 클램프 없음) |

---

## 3. Properties

### MovementComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `MoveSpeed` | `number` | `None` | `1.0` | 기본 이동 속도 |
| `SpeedMultiplier` | `number` | `Sync` | `1.0` | 속도 배율 |
| `CanMove` | `boolean` | `Sync` | `true` | 이동 가능 여부 |
| `FacingDirection` | `integer` | `Sync` | `1` | 현재 바라보는 방향 (1~8) |

### CameraFollowComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CameraOffset` | `Vector2` | `None` | `(0, 0)` | 카메라 오프셋 (캐릭터 중심 0,0 유지) |
| `ForceHardLockFollow` | `boolean` | `None` | `true` | DeadZone/SoftZone/Damping 0 강제 여부 |
| `CameraApplyRetryInterval` | `number` | `None` | `0.2` | 카메라 적용 재시도 간격(초) |
| `CameraApplyRetryMaxCount` | `integer` | `None` | `10` | 카메라 적용 최대 재시도 횟수 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | WASD 키 입력 감지 |
| `TransformComponent` | 캐릭터 위치/회전 제어 |
| `RigidbodyComponent` | 물리 기반 이동 (충돌/슬라이드) |
| `StateComponent` | 이동/정지 애니메이션 상태 전환 |
| `_CameraService` | 카메라 위치 제어 |
| `_EntityService` | bootstrap 엔티티/컴포넌트 조회 |
| `_TimerService` | 카메라 적용 재시도 타이머 |

---

## 5. 로직 흐름

### 5-1. 이동 처리
1. 매 프레임 WASD 입력 조합 감지
2. 반대 키 동시 입력(W+S, A+D) 시 해당 축 0 처리
3. 방향 벡터 정규화 → 대각선 속도 보정 (√2/2 ≈ 0.7071)
4. 최종 이동량 = 정규화 벡터 × `MoveSpeed` × `SpeedMultiplier` × delta
5. `CanMove == false` 시 이동 무시

### 5-2. 방향/스프라이트
- 입력 벡터 기반으로 8방향 인덱스 계산 → `FacingDirection` 업데이트

### 5-3. 카메라 추적
- 기본 카메라 위치 = 캐릭터 위치 + `CameraOffset` (평상시 0,0 고정)
- 카메라 커스텀 경계는 사용하지 않음 (`UseCustomBound=false`)
- 경계/first-stop/부트스트랩 카메라 제한 로직 제거
- `ForceHardLockFollow=true`인 경우 `DeadZone/SoftZone/Damping=0`, `ScreenOffset=(0.5,0.5)` 적용
- 카메라 컴포넌트 초기화 레이스는 retry timer로 보완

### 5-4. 이동 경계 클램프
- `Map01BootstrapComponent.ResolveCenterSpawnRectBoundsServer()`에서 `CenterSpawnRectTilePath/CenterSpawnTileCountX/Y`를 기준으로 world-space 경계를 우선 계산
- RectTile 경계가 유효하면 `MovementComponent.WorldBoundsMin/Max`에 동일 값 주입, `WorldBoundsPadding=0`으로 유지(조기 정지 방지)
- RectTile 경계 계산 실패 시 기존 `BackdropCenter/Size + BackdropBoundPadding` 경계로 폴백
- `MovementComponent.TryApplyWorldBoundsFromBootstrapServer()`도 같은 우선순위(RectTile → Backdrop)로 동작해 타이밍 레이스 시에도 동일 기준 유지

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

해당 없음

### 6-2. 맵 엔티티 (`games.map`)

해당 없음 (플레이어 엔티티에 부착)

### 6-3. 글로벌/모델 (`DefaultPlayer.model`)

| 작업 | 대상 파일 | 변경 내용 | 비고 |
|---|---|---|---|
| `확인` | `Global/DefaultPlayer.model` | `RigidbodyComponent` 존재 확인 | GravityScale=0, FreezeRotationZ=true |

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.MovementComponent` | `MoveSpeed=1.0` | Map01BootstrapComponent가 자동 부착 |
| Player Entity (Bootstrap 자동) | `script.CameraFollowComponent` | 기본값 | Map01BootstrapComponent가 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `HPSystemComponent` | Combat | `CanMove` 제어 — 사망 시 이동 차단 |
| `TagManagerComponent` | Meta | `CanMove` 제어 — 태그 연출 중 이동 차단 |
| `WeaponSwapComponent` | Meta | `CanMove` 제어 — 무기 교체 중 이동 차단 |
| `FireSystemComponent` | Combat | `SpeedMultiplier` 참조 |
| `Map01BootstrapComponent` | Bootstrap | RectTile 기반 이동/카메라 경계 소스 제공 (실패 시 backdrop 폴백) |

---

## 8. 주의/최적화 포인트

- 대각선 보정값 ±0.7071은 기획서 확정 수치
- `OnUpdate`에서 입력 처리하되 물리 이동은 엔진에 위임
- 벽 슬라이드는 `RigidbodyComponent` 물리 충돌로 자연 처리
- 카메라는 경계 클램프를 사용하지 않고 캐릭터 중심 추적만 수행

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Core` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] Player 엔티티의 이동/카메라 컴포넌트 부착 및 WASD/카메라 추적 동작을 Maker Play에서 최종 확인
- [ ] 맵 4방향 이동 시 카메라는 계속 캐릭터 중심(`0,0`)을 유지하는지 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |
