# 🟢 완료
# SPEC_HPSystem — 체력(HP) 및 게임오버 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `HPSystemComponent` |
| **기능 요약** | 캐릭터별 정수 HP 관리, 피격 무적, 위기 알림, 게임오버 처리 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 체력(HP) 및 게임오버 시스템.md` |
| **모듈화 레이어** | `Combat` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 피격 판정 (충돌) | `[server only]` | TriggerEnter로 데미지 수신 |
| HP 차감 계산 | `[server only]` | 데미지 공식 적용, 무적 체크 |
| 무적 타이머 | `[server only]` | `_TimerService`로 무적 해제 |
| HP바 갱신, 깜빡임 | `[client only]` | Sync된 HP 변경 감지 → UI 연출 |
| 위기 알림 (붉은 점멸) | `[client only]` | HP 비율 계산 → 이펙트 토글 |
| 게임오버 UI | `[client only]` | HP ≤ 0 감지 → 결과 화면 호출 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `MaxHP` | `integer` | `Sync` | `100` | 최대 체력 |
| `CurrentHP` | `integer` | `Sync` | `100` | 현재 체력 |
| `DamageReduction` | `integer` | `None` | `0` | 피해 감소 수치 |
| `IsInvincible` | `boolean` | `Sync` | `false` | 무적 상태 여부 |
| `InvincibleDuration` | `number` | `None` | `1.0` | 피격 무적 시간 (초) |
| `CriticalHPRatio` | `number` | `None` | `0.3` | 위기 알림 기준 비율 |
| `IsDead` | `boolean` | `Sync` | `false` | 사망 여부 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_TimerService` | 무적 시간 타이머 |
| `TriggerComponent` | 적 투사체/몸통 충돌 감지 |
| `SpriteRendererComponent` | 무적 깜빡임 연출 |

---

## 5. 로직 흐름

### 5-1. 피격 처리 (서버)
1. TriggerEnter → IsInvincible/IsDead 체크 → 데미지 계산 → HP 차감
2. 무적 활성화 → 타이머로 해제

### 5-2. 사망 판정 (서버)
- CurrentHP ≤ 0 → IsDead = true → CanMove = false → 즉시 게임오버

### 5-3. 클라이언트 연출
- Sync 감지 → HP바, 깜빡임, 위기 점멸, 게임오버 UI

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

해당 없음 (HP바는 HUDComponent 관할)

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.HPSystemComponent` | `MaxHP=100, CurrentHP=100` | Map01BootstrapComponent가 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `MovementComponent` | Core | `CanMove = false` — 사망 시 이동 차단 |
| `TagManagerComponent` | Meta | HP 데이터 스왑 |
| `FireSystemComponent` | Combat | 데미지 공식의 적 공격력 수신 |
| `LobbyFlowComponent` | Bootstrap | IsDead → HandleStageFailedServer |

---

## 8. 주의/최적화 포인트

- HP는 **정수(Integer)** — 기획서 확정
- 무적 중 추가 피격 = 판정 자체를 무시
- 사망 후 추가 피격 = 무시

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

- [ ] Player 엔티티의 `HPSystemComponent` 부착/사망→복귀 시나리오를 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

