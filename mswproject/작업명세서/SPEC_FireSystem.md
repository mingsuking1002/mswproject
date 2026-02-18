# 🟢 완료
# SPEC_FireSystem — 탑뷰 타겟팅 발사 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `FireSystemComponent`, `ProjectileComponent` |
| **기능 요약** | 마우스 클릭 좌표 → 월드 변환 → 캐릭터 회전 → 투사체 생성/발사 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 탑뷰 타겟팅 발사 시스템.md` |
| **모듈화 레이어** | `Combat` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 좌클릭 입력 | `[client only]` | `_InputService` → `ScreenTouchEvent` |
| 스크린→월드 좌표 변환 | `[client only]` | `_UILogic:ScreenToWorldPosition()` |
| 발사 요청 | Client → Server | `@EventSender`로 발사 방향 전달 |
| 발사 조건 검증 | `[server only]` | 잔탄, 쿨타임, 상태 체크 |
| 투사체 생성 | `[server only]` | 엔티티 생성 + 속도 부여 |
| 투사체 충돌 판정 | `[server only]` | TriggerEnter → 데미지 → 소멸 |
| 이펙트/사운드 | `[client only]` | 총구 화염, 발사음 |

---

## 3. Properties

### FireSystemComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `FireCooldown` | `number` | `None` | `0.5` | 발사 쿨타임 |
| `IsFireReady` | `boolean` | `Sync` | `true` | 발사 가능 여부 |
| `CanAttack` | `boolean` | `Sync` | `true` | 공격 가능 상태 |
| `MuzzleOffset` | `Vector2` | `None` | `(0.5, 0.2)` | 총구 위치 보정 |
| `ProjectileModelId` | `string` | `None` | `""` | 투사체 모델 ID |

### ProjectileComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `Speed` | `number` | `None` | `20.0` | 투사체 비행 속도 |
| `MaxRange` | `number` | `None` | `15.0` | 최대 사거리 |
| `Lifetime` | `number` | `None` | `2.0` | 최대 생존 시간 |
| `Damage` | `integer` | `None` | `10` | 기본 데미지 |
| `Spread` | `number` | `None` | `0` | 탄 퍼짐 각도 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | 좌클릭 감지 |
| `_UILogic` | ScreenToWorldPosition() |
| `_TimerService` | 발사 쿨타임 타이머 |
| `_EntityService` | 투사체 엔티티 동적 생성 |
| `TriggerComponent` | 투사체 충돌 감지 |

---

## 5. 로직 흐름

### 5-1. 발사 요청 (클라이언트)
1. 좌클릭 → 스크린→월드 변환 → 조건 체크 → 서버 요청

### 5-2. 발사 실행 (서버)
1. 조건 재검증 → 방향 벡터 → 투사체 생성 → 잔탄 차감 → 쿨타임 설정

### 5-3. 투사체 진행 (서버)
- 적 충돌: 데미지 → 소멸 / 지형 충돌: 소멸 / 사거리 초과: 소멸

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

해당 없음

### 6-2. 맵 엔티티 (`games.map`)

| 작업 | 엔티티 경로 | 컴포넌트 | 속성 | 비고 |
|---|---|---|---|---|
| `확인` | `/maps/games/GRProjectileTemplate` | `TransformComponent`, `script.ProjectileComponent`, `TriggerComponent` (`SpriteRendererComponent` 선택) | `enable: false` | 투사체 템플릿 엔티티 |

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.FireSystemComponent` | `FireCooldown=0.5` | 자동 부착 |
| GRProjectileTemplate | `script.ProjectileComponent` | `Speed=20, Damage=10` | 투사체 템플릿 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `ReloadComponent` | Combat | 잔탄 참조 — 0이면 발사 차단 |
| `WeaponSwapComponent` | Meta | 현재 무기 쿨타임/데미지/투사체 ID |
| `MovementComponent` | Core | 발사 방향으로 캐릭터 회전 |
| `HPSystemComponent` | Combat | 적→플레이어 피격 시 HP 차감 |

---

## 8. 주의/최적화 포인트

- 투사체 풀링 고려 (대량 발사 시 성능)
- 쿨타임 중 재클릭 → 입력 완전 무시
- 이미 발사된 투사체는 발사 시점 데미지 유지
- 발사 선행조건: `ProjectileModelId` 또는 `GRProjectileTemplate` 중 하나는 반드시 유효

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Combat` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] `/maps/games/GRProjectileTemplate` 배치와 런타임 발사 동작을 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

