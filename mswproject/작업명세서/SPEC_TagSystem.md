# 🟢 완료
# SPEC_TagSystem — 캐릭터 태그(교체) 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `TagManagerComponent` |
| **기능 요약** | 2인 캐릭터 실시간 교체, 개별 HP/탄창, 태그 스킬 발동 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 캐릭터 태그(교체) 시스템.md` |
| **모듈화 레이어** | `Meta` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 태그 키 입력 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 서버에 태그 요청 | Client → Server | `@EventSender` |
| 태그 로직 (검증/스왑) | `[server only]` | 쿨타임, 상태 검증 후 교체 |
| 외형/HUD 갱신 | `[client only]` | Sync 감지 → UI/스프라이트 교체 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentCharIndex` | `integer` | `Sync` | `1` | 현재 활성 캐릭터 (1=A, 2=B) |
| `TagCooldown` | `number` | `None` | `3.0` | 태그 쿨타임 (초) |
| `IsTagReady` | `boolean` | `Sync` | `true` | 태그 가능 여부 |
| `InvincibleTime` | `number` | `None` | `0.5` | 교체 무적 시간 |
| `IsTagLocked` | `boolean` | `Sync` | `false` | 태그 금지 상태 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | 태그 키 입력 감지 |
| `_TimerService` | 태그 쿨타임, 무적 시간 타이머 |
| `AvatarRendererComponent` | 캐릭터 외형 변경 |

---

## 5. 로직 흐름

### 5-1. 태그 요청 (클라이언트)
태그 키 → IsTagReady/IsTagLocked 체크 → 서버 요청

### 5-2. 태그 실행 (서버)
조건 검증 → 현재 캐릭터 데이터 백업 → 대기 캐릭터 로드 → 외형 변경 → 무적 → 쿨타임

### 5-3. 데이터 스왑 대상
HP, 잔탄(4슬롯), 장착무기, 장전상태 — 위치/각도는 계승

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

해당 없음 (HUD에서 태그 쿨타임 표시)

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.TagManagerComponent` | `TagCooldown=3.0` | 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `HPSystemComponent` | Combat | 데이터 스왑 + 무적 |
| `ReloadComponent` | Combat | 재장전 취소 + 탄약 백업 |
| `WeaponSwapComponent` | Meta | 4슬롯 무기 상태 백업/로드 |
| `FireSystemComponent` | Combat | 무기 스탯 반영 |
| `MovementComponent` | Core | 태그 연출 중 CanMove 제어 |

---

## 8. 주의/최적화 포인트

- 현재 캐릭터 사망 시 자동 태그 없음 — 즉시 게임오버 (기획서 확정)
- 대기 중 HP/탄창 회복 없음 — 상태 그대로 보존
- 벽 근처 태그 시 끼임 가능 → 위치 보정 고려

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Meta` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] 태그 교체 시 HP/탄약/무기 상태 스왑과 무적 윈도우를 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

