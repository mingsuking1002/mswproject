# 🟢 완료
# SPEC_WeaponSwap — 무기 교체 시스템 (Weapon Swap)

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `WeaponSwapComponent`, `WeaponWheelUIComponent` |
| **기능 요약** | F키 → 시간정지 → 방사형 메뉴(4슬롯) → 무기 선택 → 교체 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 무기 교체 (Weapon Swap).md` |
| **모듈화 레이어** | `Meta` (WeaponSwap) / `UI` (WeaponWheel) |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| F키 입력 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 시간 정지 | `[server]` | TimeScale or 일시정지 플래그 |
| 방사형 메뉴 UI | `[client only]` | UI 렌더링 + 입력 처리 |
| 무기 교체 확정 | Client → Server | `@EventSender` |
| 데이터 교체 | `[server only]` | 무기 스탯/잔탄 스왑 |

---

## 3. Properties

### WeaponSwapComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentWeaponSlot` | `integer` | `Sync` | `1` | 현재 장착 슬롯 (1~4) |
| `WeaponSlotCount` | `integer` | `None` | `4` | 슬롯 개수 |
| `IsSwapMenuOpen` | `boolean` | `Sync` | `false` | 메뉴 열림 여부 |
| `Weapon1_Data` ~ `Weapon4_Data` | `table` | `None` | `{}` | 슬롯별 무기 데이터 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | F키 입력, 메뉴 내 마우스/키보드 |
| `_UtilLogic` | TimeScale 제어 |

---

## 5. 로직 흐름

### 5-1. 메뉴 열기
F키 → 조건 체크 → IsSwapMenuOpen = true → 시간 정지 → UI 표시

### 5-2. 슬롯 선택
마우스/WASD 기반 4영역 하이라이트

### 5-3. 교체 확정
좌클릭 → 서버 전달 → CurrentWeaponSlot 변경 → 게임 재개

### 5-4. 캐릭터별 독립 저장
태그 시 4슬롯 전체 백업/로드

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| `확인/추가` | `GRWeaponWheel` | `UITransformComponent`, `SpriteGUIRendererComponent` | `enable: false, visible: false` | 화면 중앙, 360×360 | 방사형 메뉴 컨테이너 |

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.WeaponSwapComponent` | `WeaponSlotCount=4` | 자동 부착 |
| Player Entity (Bootstrap 자동) | `script.WeaponWheelUIComponent` | 기본값 | 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `MovementComponent` | Core | `CanMove` 제어 — 메뉴 열림 시 이동 차단 |
| `FireSystemComponent` | Combat | `CanAttack` 제어 + 무기 스탯 반영 |
| `ReloadComponent` | Combat | 재장전 취소 + 데이터 스왑 |
| `TagManagerComponent` | Meta | 캐릭터별 무기 백업/로드 |
| `SpeedrunTimerComponent` | Meta | 메뉴 열림 시 타이머 정지 |

---

## 8. 주의/최적화 포인트

- 무기 4종 스펙은 추후 CSV/테이블로 관리
- 방사형 메뉴 UI 디자인은 별도 UI 기획서 필요 → 최소 기능 우선

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Meta`/`UI` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] `GRWeaponWheelRoot` 표시/하이라이트/선택 확정 동작을 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

