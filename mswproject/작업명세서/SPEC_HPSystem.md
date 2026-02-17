# 🟢 완료
# SPEC_HPSystem — 체력(HP) 및 게임오버 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `HPSystemComponent` |
| **기능 요약** | 캐릭터별 정수 HP 관리, 피격 무적, 위기 알림, 게임오버 처리 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 체력(HP) 및 게임오버 시스템.md` |

### 핵심 동작
- 피격 시 `(적 공격력 - 피해 감소량)` 만큼 HP 차감
- 피격 직후 무적 시간 적용 (깜빡임 연출)
- HP 30% 미만 시 위기 알림 (화면 붉은 점멸)
- HP ≤ 0 시 게임오버 → 결과 화면 표시

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
| `DamageReduction` | `integer` | `None` | `0` | 피해 감소 수치 (방어력) |
| `IsInvincible` | `boolean` | `Sync` | `false` | 무적 상태 여부 |
| `InvincibleDuration` | `number` | `None` | `1.0` | 피격 무적 시간 (초) |
| `CriticalHPRatio` | `number` | `None` | `0.3` | 위기 알림 기준 비율 (30%) |
| `IsDead` | `boolean` | `Sync` | `false` | 사망 여부 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_TimerService` | 무적 시간 타이머 |
| `TriggerComponent` | 적 투사체/몸통 충돌 감지 |
| `SpriteRendererComponent` | 무적 깜빡임 연출 (Alpha/Color 토글) |

---

## 5. 로직 흐름

### 5-1. 피격 처리 (서버)
1. 적 투사체/엔티티와 충돌 발생 (TriggerEnter)
2. `IsInvincible == true` 또는 `IsDead == true`이면 무시
3. 데미지 계산: `실제 데미지 = max(적 공격력 - DamageReduction, 0)`
4. `CurrentHP = max(CurrentHP - 실제 데미지, 0)`
5. 무적 활성화: `IsInvincible = true` → `_TimerService`로 `InvincibleDuration` 후 해제

### 5-2. 사망 판정 (서버)
- `CurrentHP ≤ 0` 시 `IsDead = true`
- 외부 시스템에 사망 이벤트 전파 (MovementComponent → `CanMove = false` 등)
- **현재 캐릭터 사망 = 즉시 게임오버** (자동 태그 교체 없음 — 기획서 확정)

### 5-3. 회복 처리 (서버)
- 회복 아이템 획득 시: `CurrentHP = min(CurrentHP + 회복량, MaxHP)` — 최대 초과 불가

### 5-4. 클라이언트 연출
- `CurrentHP` Sync 변경 감지 → HP바 UI 갱신
- `IsInvincible` Sync → 캐릭터 스프라이트 깜빡임 시작/종료
- `CurrentHP / MaxHP < CriticalHPRatio` → 화면 가장자리 붉은 점멸 활성화
- `IsDead` Sync → 쓰러짐 모션 재생, 조작 차단, 결과 화면 팝업

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `MovementComponent` | `CanMove = false` | 사망 시 이동 차단 |
| `TagManagerComponent` | 이벤트 수신 | 태그 시 HP를 캐릭터별 데이터로 교체 |
| `FireSystemComponent` | 피격 데이터 참조 | 데미지 공식의 적 공격력 수신 |
| `GameManagerComponent` | 게임오버 이벤트 | `IsDead = true` → 게임 루프 정지/결과 화면 |

---

## 7. 주의 사항

- [ ] HP는 **정수(Integer)** — 기획서 확정
- [ ] 무적 중 추가 피격 = 데미지 0 (판정 자체를 무시)
- [ ] 사망 후 추가 피격 = 무시
- [ ] 적과 동시 사망 = 패배(게임오버) 처리
- [ ] 회복 아이템 관련 별도 기획서 없음 → 수신 인터페이스만 열어둘 것

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
