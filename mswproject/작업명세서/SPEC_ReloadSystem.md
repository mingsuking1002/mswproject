# 🟢 완료
# SPEC_ReloadSystem — 잔탄 관리 및 재장전 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `ReloadComponent` |
| **기능 요약** | R키 수동 재장전, 무기별 개별 탄약/시간, 백그라운드 쿨타임 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 잔탄 관리 및 재장전 시스템.md` |
| **모듈화 레이어** | `Combat` |

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
| `MaxAmmo` | `integer` | `None` | `30` | 최대 탄약 수 |
| `CurrentAmmo` | `integer` | `Sync` | `30` | 현재 잔탄 |
| `ReloadTime` | `number` | `None` | `1.5` | 재장전 소요 시간 |
| `IsReloading` | `boolean` | `Sync` | `false` | 재장전 중 여부 |
| `FireRate` | `number` | `None` | `0.5` | 발사 딜레이 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | R키 입력 감지 |
| `_TimerService` | 재장전 타이머, 백그라운드 쿨타임 |

---

## 5. 로직 흐름

### 5-1. 재장전 시작
R키 → 서버 조건 체크 → IsReloading = true → 타이머 시작

### 5-2. 재장전 완료
CurrentAmmo = MaxAmmo → IsReloading = false

### 5-3. 재장전 취소
태그/무기 교체 시 즉시 취소, 탄약 미충전. 피격 시 유지.

### 5-4. 백그라운드 쿨타임
비활성 무기의 재장전 타이머는 계속 진행

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

해당 없음 (잔탄 UI는 HUDComponent 관할)

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.ReloadComponent` | `MaxAmmo=30, ReloadTime=1.5` | 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `FireSystemComponent` | Combat | IsReloading 참조 — 재장전 중 발사 차단 |
| `WeaponSwapComponent` | Meta | 교체 시 재장전 취소 |
| `TagManagerComponent` | Meta | 태그 시 재장전 취소, 데이터 백업 |
| `HUDComponent` | UI | 잔탄 표시, 재장전 게이지 |

---

## 8. 주의/최적화 포인트

- 재장전 중 이동은 가능 (이동 차단 안 함)
- 백그라운드 쿨타임이 핵심 — 무기별 독립 타이머

---

## 9. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트, `Combat` 레이어
- [ ] `_GRUtil` 사용 (중복 유틸 금지)
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil`/`isvalid` 방어 + `pcall` 보호
- [ ] **Maker 배치 (§6) 완료**
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |
