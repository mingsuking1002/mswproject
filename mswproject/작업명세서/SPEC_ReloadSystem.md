# 🟢 완료
# SPEC_ReloadSystem — 잔탄 관리 및 재장전 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `ReloadComponent` |
| **기능 요약** | R키 수동 재장전, 무기별 개별 탄약/시간, 백그라운드 쿨타임 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 잔탄 관리 및 재장전 시스템.md` |

### 핵심 동작
- R키 입력 → 재장전 시작 (무기별 소요 시간)
- 재장전 중 사격 불가, 이동은 가능
- 태그/무기 교체 시 재장전 **즉시 취소** (탄약 미충전)
- 비활성 무기의 재장전 쿨타임도 **백그라운드에서 계속 흐름**

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| R키 입력 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 재장전 요청 | Client → Server | `@EventSender` |
| 재장전 처리/타이머 | `[server only]` | 조건 체크, 타이머 시작 |
| 재장전 UI (게이지) | `[client only]` | Sync 감지 → 게이지 표시 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `MaxAmmo` | `integer` | `None` | `30` | 최대 탄약 수 (무기별) |
| `CurrentAmmo` | `integer` | `Sync` | `30` | 현재 잔탄 |
| `ReloadTime` | `number` | `None` | `1.5` | 재장전 소요 시간 (무기별) |
| `IsReloading` | `boolean` | `Sync` | `false` | 재장전 중 여부 |
| `FireRate` | `number` | `None` | `0.5` | 발사 딜레이 (무기별) — FireSystem 참조 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | R키 입력 감지 |
| `_TimerService` | 재장전 타이머, 백그라운드 쿨타임 |

---

## 5. 로직 흐름

### 5-1. 재장전 시작
1. R키 입력 감지 → 서버에 재장전 요청
2. 서버 조건 체크: `CurrentAmmo < MaxAmmo` AND `IsReloading == false` AND 상태이상 없음
3. 탄약이 이미 가득 차 있으면 → 무시 (불필요한 모션 방지)
4. `IsReloading = true` → 클라이언트에서 재장전 게이지/아이콘 표시
5. `_TimerService`로 `ReloadTime` 후 재장전 완료 콜백

### 5-2. 재장전 완료
- `CurrentAmmo = MaxAmmo`
- `IsReloading = false`
- 클라이언트에서 게이지 사라짐, 사격 가능 상태 복귀

### 5-3. 재장전 취소
- **태그(캐릭터 교체) 시:** 재장전 즉시 취소, 탄약 미충전
- **무기 교체(F키) 시:** 재장전 즉시 취소, 탄약 미충전
- **피격 시:** 재장전 **유지** (기획서 결정: 끊기면 난이도 과상승)

### 5-4. 백그라운드 쿨타임 (핵심)
- 비활성(교체된) 무기의 재장전 쿨타임 타이머는 **계속 흐른다**
- 다시 해당 무기로 돌아왔을 때 쿨타임이 끝났으면 즉시 사격 가능
- 구현 방식: 무기별 독립 타이머 or 교체 시점 timestamp 저장 방식 — Codex 판단

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `FireSystemComponent` | `IsReloading` 참조 | 재장전 중 발사 차단 |
| `WeaponSwapComponent` | 교체 이벤트 | 무기 교체 시 현재 무기 재장전 취소 |
| `TagManagerComponent` | 태그 이벤트 | 태그 시 재장전 취소, 데이터 백업 |
| `HUDComponent` | Sync 감지 | 잔탄 표시, 재장전 게이지 표시 |

---

## 7. 주의 사항

- [ ] 재장전 키(R)는 기획서 기준, 자동 재장전(잔탄 0 시)은 미정 → 기본 수동
- [ ] 재장전 중 이동은 가능 (이동 차단 안 함)
- [ ] 백그라운드 쿨타임이 핵심 차별점 — 반드시 무기별 독립 타이머

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
