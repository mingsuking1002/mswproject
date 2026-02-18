# 🟢 완료
# SPEC_Movement — 8방향 이동 + 카메라 시스템

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
| 카메라 추적 | `[client only]` | 카메라 위치 = 캐릭터 위치 (맵 Bounds 내 클램핑) |

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
| `CameraOffset` | `Vector2` | `None` | `(0, 0)` | 카메라 오프셋 |
| `MapBoundsMin` | `Vector2` | `None` | `(-50, -50)` | 맵 최소 경계 |
| `MapBoundsMax` | `Vector2` | `None` | `(50, 50)` | 맵 최대 경계 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | WASD 키 입력 감지 |
| `TransformComponent` | 캐릭터 위치/회전 제어 |
| `RigidbodyComponent` | 물리 기반 이동 (충돌/슬라이드) |
| `StateComponent` | 이동/정지 애니메이션 상태 전환 |
| `_CameraService` | 카메라 위치 제어 |

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
- 카메라 위치 = 캐릭터 위치 + `CameraOffset`
- 맵 경계 클램핑

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

---

## 8. 주의/최적화 포인트

- 대각선 보정값 ±0.7071은 기획서 확정 수치
- `OnUpdate`에서 입력 처리하되 물리 이동은 엔진에 위임
- 벽 슬라이드는 `RigidbodyComponent` 물리 충돌로 자연 처리

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

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

