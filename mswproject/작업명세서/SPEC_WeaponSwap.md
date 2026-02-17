# 🟢 완료
# SPEC_WeaponSwap — 무기 교체 시스템 (Weapon Swap)

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `WeaponSwapComponent`, `WeaponWheelUIComponent` |
| **기능 요약** | F키 → 시간정지 → 방사형 메뉴(4슬롯) → 무기 선택 → 교체 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 무기 교체 (Weapon Swap).md` |

### 핵심 동작
- F키 → 게임 **일시정지** + 이동/공격 입력 차단
- 화면 중앙에 **4방향 방사형 메뉴(Radial Menu)** 팝업
- 마우스/WASD로 슬롯 선택 → 확정 시 무기 교체 + 게임 재개
- 캐릭터별 무기 상태(잔탄, 장전 상태) **독립 저장**

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| F키 입력 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 시간 정지 | `[server]` | TimeScale = 0 또는 게임 로직 일시정지 플래그 |
| 방사형 메뉴 UI | `[client only]` | UI 렌더링 + 입력 처리 |
| 무기 교체 확정 | Client → Server | `@EventSender`로 선택 슬롯 전달 |
| 데이터 교체 | `[server only]` | 무기 스탯/잔탄 스왑 |
| 게임 재개 | `[server]` | TimeScale 복원 |

---

## 3. Properties

### WeaponSwapComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentWeaponSlot` | `integer` | `Sync` | `1` | 현재 장착 슬롯 (1~4) |
| `WeaponSlotCount` | `integer` | `None` | `4` | 무기 슬롯 개수 (고정) |
| `IsSwapMenuOpen` | `boolean` | `Sync` | `false` | 교체 메뉴 열림 여부 |
| `Weapon1_Data` | `table` | `None` | `{}` | 슬롯1 무기 데이터 (ID, 잔탄, 장전상태) |
| `Weapon2_Data` | `table` | `None` | `{}` | 슬롯2 |
| `Weapon3_Data` | `table` | `None` | `{}` | 슬롯3 |
| `Weapon4_Data` | `table` | `None` | `{}` | 슬롯4 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | F키 입력, 메뉴 내 마우스/키보드 입력 |
| `_UtilLogic` | TimeScale 제어 (시간 정지/재개) |
| UI 시스템 | 방사형 메뉴 렌더링 |

---

## 5. 로직 흐름

### 5-1. 메뉴 열기
1. F키 입력 감지
2. 현재 상태 체크: 사망, CC기, 이미 메뉴 열림 → 진입 불가
3. `IsSwapMenuOpen = true`
4. **시간 정지:** 게임 월드 시간 정지 (UI 애니메이션은 유지)
5. 이동/공격 입력 차단 (`MovementComponent.CanMove = false`, `FireSystem.CanAttack = false`)
6. 화면 중앙에 방사형 메뉴 UI 표시 (4슬롯, 현재 무기 하이라이트)

### 5-2. 슬롯 선택
- 마우스 위치 기반으로 4개 영역 중 하나를 하이라이트
- 또는 WASD로 방향 선택 (W=상, D=우, S=하, A=좌)
- 현재 하이라이트된 슬롯 시각적 강조

### 5-3. 교체 확정
- 좌클릭 또는 키 떼기 → 선택 확정
- 서버에 선택 슬롯 번호 전달
- 서버: `CurrentWeaponSlot` 변경 → 무기 데이터 스왑
- `IsSwapMenuOpen = false` → 시간 재개, 입력 차단 해제

### 5-4. 취소
- F키 다시 누르기 또는 ESC → 교체 없이 메뉴 닫기 + 게임 재개

### 5-5. 캐릭터별 독립 저장
- 캐릭터 A의 4슬롯 무기 상태와 캐릭터 B의 4슬롯 무기 상태는 **완전 독립**
- 태그(교체) 시 현재 캐릭터 무기 상태를 백업하고, 교체 캐릭터 무기 상태를 로드
- A로 돌아올 때 **마지막에 들고 있던 무기**를 그대로 유지

---

## 6. 시간 정지 관련 주의

- `TimeScale = 0` 적용 시 UI 애니메이션까지 멈출 수 있음
- **해결 방안 (Codex 판단):**
  - 방법 A: `TimeScale = 0` + UI는 `unscaledDelta` 사용
  - 방법 B: 별도 `IsPaused` 플래그로 게임 로직만 정지 (타이머/이동/발사 등)
- 어느 방식이 MSW에서 더 적합한지 Codex가 확인 후 결정

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `MovementComponent` | `CanMove` 제어 | 메뉴 열림 시 이동 차단 |
| `FireSystemComponent` | `CanAttack` 제어 + 무기 스탯 반영 | 메뉴 열림 시 공격 차단, 교체 후 새 무기 데이터 |
| `ReloadComponent` | 재장전 취소 + 데이터 스왑 | 교체 시 재장전 취소, 슬롯별 잔탄 저장/로드 |
| `TagManagerComponent` | 캐릭터별 무기 백업/로드 | 태그 시 4슬롯 전체 백업 |
| `SpeedrunTimerComponent` | 타이머 정지 | 메뉴 열림 시 시간 측정 일시정지 |
| `HUDComponent` | Sync 감지 | 현재 무기 아이콘 교체 |

---

## 8. 주의 사항

- [ ] 무기 4종의 스펙(데미지, 탄약, 재장전시간 등)은 추후 별도 CSV/테이블로 관리 예정
- [ ] F키 입력은 무기 교체 전용 — 태그(캐릭터 교체)와 키 충돌 없는지 기획 확인 필요
  - 기획서 기준: 태그 = 별도 키, 무기 교체 = F키 (충돌 없음)
- [ ] 방사형 메뉴 UI 디자인은 별도 UI 기획서 필요 → 최소 기능으로 먼저 구현

---

## 9. Codex 구현 체크리스트

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
