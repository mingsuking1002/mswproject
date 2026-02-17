# 🟢 완료
# SPEC_Movement — 8방향 이동 + 카메라 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `MovementComponent`, `CameraFollowComponent` |
| **기능 요약** | WASD 8방향 캐릭터 이동 + 카메라 추적 (맵 경계 클램핑) |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 기본 이동 기획 v.1.2.md` |

### 핵심 동작
- WASD 단독/조합 입력 → 8방향 이동 (대각선 속도 보정 적용)
- 벽/장애물 충돌 시 멈추지 않고 **슬라이드**
- 카메라는 캐릭터 중앙 추적, **맵 끝에서는 더 이상 이동하지 않음**

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
| `MoveSpeed` | `number` | `None` | `1.0` | 기본 이동 속도 (버프/디버프 배율 적용 기준) |
| `SpeedMultiplier` | `number` | `Sync` | `1.0` | 속도 배율 (버프: 1.5, 감속: 0.5 등) |
| `CanMove` | `boolean` | `Sync` | `true` | 이동 가능 여부 (CC기, 상점, 사망 시 false) |
| `FacingDirection` | `integer` | `Sync` | `1` | 현재 바라보는 방향 (1~8, 스프라이트 교체용) |

### CameraFollowComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CameraOffset` | `Vector2` | `None` | `(0, 0)` | 카메라 오프셋 (캐릭터 정중앙 기준) |
| `MapBoundsMin` | `Vector2` | `None` | `(-50, -50)` | 맵 최소 경계 좌표 |
| `MapBoundsMax` | `Vector2` | `None` | `(50, 50)` | 맵 최대 경계 좌표 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | WASD 키 입력 감지 (`IsKeyPressed`) |
| `TransformComponent` | 캐릭터 위치/회전 제어 |
| `RigidbodyComponent` | 물리 기반 이동 (충돌/슬라이드) |
| `StateComponent` | 이동/정지 애니메이션 상태 전환 |
| `_CameraService` | 카메라 위치 제어 |

---

## 5. 로직 흐름

### 5-1. 이동 처리
1. 매 프레임 WASD 입력 조합 감지
2. 반대 키 동시 입력(W+S, A+D) 시 해당 축 0 처리
3. 방향 벡터 정규화 → 대각선 속도 뻥튀기 방지 (√2/2 ≈ 0.7071)
4. 최종 이동량 = 정규화 벡터 × `MoveSpeed` × `SpeedMultiplier` × delta
5. `CanMove == false` 시 이동 무시, 즉시 정지

### 5-2. 방향/스프라이트
- 입력 벡터 기반으로 8방향 인덱스 계산 → `FacingDirection` 업데이트
- 스프라이트/애니메이션 전환은 `FacingDirection` Sync 변경 감지로 처리

### 5-3. 카메라 추적
- 카메라 위치 = 캐릭터 위치 + `CameraOffset`
- 카메라 X/Y를 `MapBoundsMin` ~ `MapBoundsMax` 범위 내로 클램핑
- 맵 모서리에서는 캐릭터만 이동, 카메라는 고정

### 5-4. 조작 불가 처리
- 상점/UI 팝업/사망/CC기 시 → `CanMove = false` (외부 시스템이 제어)
- 창 비활성화(포커스 손실) 시 → 눌려있던 키 해제 처리, 즉시 정지

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `HPSystemComponent` | `CanMove` 제어 | 사망 시 이동 차단 |
| `TagManagerComponent` | `CanMove` 제어 | 태그 연출 중 이동 차단 |
| `WeaponSwapComponent` | `CanMove` 제어 | 무기 교체 팝업 중 이동 차단 |
| `FireSystemComponent` | `SpeedMultiplier` 참조 | 공격 중 감속 적용 시 |

---

## 7. 주의 사항

- [ ] 대각선 보정값 ±0.7071은 기획서 확정 수치
- [ ] 공격 중 이동 속도 감소 비율은 무기별로 다를 수 있음 → 미정, 기본 1.0 유지
- [ ] `OnUpdate`에서 입력 처리하되 물리 이동은 엔진에 위임 (직접 좌표 조작 최소화)
- [ ] 벽 슬라이드는 `RigidbodyComponent`의 물리 충돌로 자연 처리

---

## 8. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil` 체크, `isValid` 방어 코드
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
