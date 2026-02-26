# 🟢 완료
# SPEC_UI_PopuiGroup_WeaponWheel — PopuiGroup 기반 무기 스왑 원형창 분리/재구현

## 0. 상태 이력

- `2026-02-26` `🟡 대기중` 접수
- `2026-02-26` `🔵 진행중` `DefaultGroup` 분리 + `PopuiGroup`/스크립트 이관 시작
- `2026-02-26` `🟢 완료` `PopuiGroup` 무기휠 분리, 슬롯/중앙 동적 연동, `.codeblock` 동기화, 문서 갱신 완료
- `2026-02-26` `🔵 진행중` 무기휠 슬롯 클릭 확정 입력 경로 추가
- `2026-02-26` `🟢 완료` 기존 키 입력 + UI 슬롯 클릭 병행 스왑 확정 지원
- `2026-02-26` `🔵 진행중` 클릭 입력 정책 변경(아이콘 클릭은 선택만, Space 확정 유지)
- `2026-02-26` `🟢 완료` 무기 아이콘 버튼 클릭 선택 + Space 확정 정책 반영

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `PopuiGroup`(신규 UIGroup), `WeaponSwapComponent`, `WeaponWheelUIComponent` |
| **대상 파일** | `ui/DefaultGroup.ui`, `ui/PopuiGroup.ui`, `WeaponSwapComponent.(mlua/codeblock)`, `WeaponWheelUIComponent.(mlua/codeblock)` |
| **실행 공간** | `[ServerOnly]` 슬롯 Sync 스냅샷 작성, `[ClientOnly/Client]` 원형 UI 렌더 |
| **기능 요약** | 무기휠을 `DefaultGroup`에서 완전 제거하고 `PopuiGroup`으로 이관, 4슬롯 이름/아이콘/LV/EXP + 중앙 초상 동적 표시 |

---

## 2. UI 엔티티 분리/구성

### 2-1. 제거 (`DefaultGroup`)

- `/ui/DefaultGroup/GRWeaponWheelRoot`
- `/ui/DefaultGroup/GRWeaponWheelRoot/Slot1`
- `/ui/DefaultGroup/GRWeaponWheelRoot/Slot2`
- `/ui/DefaultGroup/GRWeaponWheelRoot/Slot3`
- `/ui/DefaultGroup/GRWeaponWheelRoot/Slot4`

### 2-2. 신규 (`PopuiGroup`)

- 루트: `/ui/PopuiGroup` (`UIGroupComponent`, `GroupOrder=4`, `DefaultShow=true`)
- 딤: `/ui/PopuiGroup/GRWeaponWheelDim`
- 휠 루트: `/ui/PopuiGroup/GRWeaponWheelRoot` (`enable/visible=false` 기본)
- 원형 배경 스프라이트: `499c70eab41cfeb418a3ad9f87fd0285`
- 슬롯 구조: `/Slot1~4/{WeaponIcon,WeaponNameText,LevelText,ExpBack,ExpBack/Fore,Highlight}`
- 중앙 구조: `/CenterPortrait`, `/CenterWeaponNameText`, `/CenterLevelText`, `/CenterExpBack/Fore`

---

## 3. 스크립트/인터페이스 변경

### 3-1. `WeaponSwapComponent`

#### Properties (@Sync)

- `Slot1WeaponId/Name/SpriteRuid/Level/Exp/RequiredExp`
- `Slot2WeaponId/Name/SpriteRuid/Level/Exp/RequiredExp`
- `Slot3WeaponId/Name/SpriteRuid/Level/Exp/RequiredExp`
- `Slot4WeaponId/Name/SpriteRuid/Level/Exp/RequiredExp`

#### Server Methods

- `RefreshWheelSlotUISyncServer()`
- `ApplyWheelSlotSyncBySlotServer(slot, weaponId, weaponName, spriteRuid, level, exp, requiredExp)`

#### 호출 지점

- `OnInitialize`
- `InitSlotsFromPlayerbleData`
- `OpenSwapMenuServer`
- `ApplySlotDataToCombat`
- `ImportWeaponSwapState`

### 3-2. `WeaponWheelUIComponent`

- `WheelRootPath` 기본값: `/ui/PopuiGroup/GRWeaponWheelRoot`
- `WheelDimPath` 추가: `/ui/PopuiGroup/GRWeaponWheelDim`
- 기존 `"/ui/DefaultGroup/GRWeaponWheelRoot"` 하드코드 제거
- 슬롯 아이콘 클릭 선택 옵션:
  - `EnableSlotClickSwap = true`
  - `SlotClickDebounce = 0.1`
- 슬롯 버튼 바인딩/해제 메서드 추가:
  - `EnsureSlotButtonsBoundClient`
  - `BindSlotButtonClient`
  - `OnSlotClickedClient`
  - `GetSlotClickTargetEntityClient`
  - `UnbindSlotButtonClient`
  - `ClearSlotButtonsClient`
- 슬롯 렌더 추가:
  - `GetSlotSnapshotClient`
  - `ApplySlotSnapshotClient`
  - `SetGaugeRatioClient`, `SetTextEntityClient`, `SetSpriteEntityClient`
- 중앙 렌더 추가:
  - `ApplyCenterSnapshotClient`
  - `ResolveCenterPortraitRuidClient` (`CharacterDataInit.CurrentIdleRuid -> WeaponSwap.CurrentWeaponSpriteRuid`)
- 바인딩 라이프사이클:
  - `OnBeginPlay`, `OnMapEnter`, `ApplyWeaponWheelStateClient`에서 바인딩 보장
  - `OnEndPlay`에서 클릭 핸들러 해제

---

## 4. Services / 연동 컴포넌트

- `_EntityService`: UI 엔티티 path 해석
- `_DataService`: (`WeaponSwap`) `WeaponData/ProjectileData/SummonData` row 조회
- `WeaponLevelUpComponent`: `ExportWeaponProgressState()`로 슬롯 레벨/경험치 조회
- `CharacterDataInitComponent`: `CurrentIdleRuid`로 중앙 초상 동기화

---

## 5. Logic Architecture

1. 서버(`WeaponSwapComponent`)가 슬롯 데이터를 기준으로 UI Sync 스냅샷을 작성한다.
2. 클라이언트(`WeaponWheelUIComponent`)는 `ApplyWeaponWheelStateClient()` 호출 시 스냅샷을 읽어 슬롯/중앙 UI를 렌더한다.
3. 휠 표시/숨김은 `GRWeaponWheelRoot + GRWeaponWheelDim`를 함께 토글한다.
4. 하이라이트/현재 슬롯 스케일은 기존 정책(`HighlightScale/NormalScale`)을 유지한다.
5. 휠 오픈 상태에서 무기 `WeaponIcon` 클릭은 하이라이트 선택만 갱신하고, 확정은 `Space` 입력으로만 수행한다.

---

## 6. 주의사항

- 이번 작업 범위는 `스왑 원형창`만 포함하며 타 HUD 재배치는 제외.
- 무기휠은 `DefaultGroup` 폴백 없이 `PopuiGroup` 단일 경로로 운영.
- 중앙 초상은 런타임 데이터 미존재 시 빈 스프라이트 허용(치명 오류 방지).
- `.mlua` 변경은 동일 `.codeblock(Target mLua)`에 동기화 유지.

---

## 7. 검증 체크리스트

### 7-1. 정적 검증

- [x] `ui/DefaultGroup.ui` JSON 파싱 성공
- [x] `ui/PopuiGroup.ui` JSON 파싱 성공
- [x] `DefaultGroup.ui`에 `/ui/DefaultGroup/GRWeaponWheelRoot` 0건
- [x] `PopuiGroup.ui`에 `/ui/PopuiGroup/GRWeaponWheelRoot` + `Slot1~4` 각 1세트 존재
- [x] `WeaponWheelUIComponent`에서 `"/ui/DefaultGroup/GRWeaponWheelRoot"` 문자열 0건
- [x] `WeaponSwapComponent.mlua` ↔ `.codeblock` 동기화 일치
- [x] `WeaponWheelUIComponent.mlua` ↔ `.codeblock` 동기화 일치
- [x] `WeaponWheelUIComponent`에 슬롯 클릭 스왑 메서드(`OnSlotClickedClient`) 반영
- [x] `WeaponSwapComponent`에서 `Mouse0` 확정 제거, `Space` 확정 유지 반영

### 7-2. 런타임(Maker Play)

- [ ] `F` 입력 시 새 원형 스왑창 노출
- [ ] `W/A/S/D` 하이라이트 이동 및 슬롯 강조 정상
- [ ] 휠 오픈 상태에서 무기 아이콘 클릭 시 하이라이트/선택만 변경(즉시 확정 없음)
- [ ] `Space` 입력 시 현재 선택 슬롯으로 확정 스왑
- [ ] 슬롯명/LV/경험치 게이지 4슬롯 동적 반영
- [ ] 중앙 초상(태그 전환 포함) 갱신
- [ ] 선택 확정 시 무기 전환 후 창 닫힘/게임 재개 정상
- [ ] nil/미로딩 상황 fallback 렌더에서 NPE 없음
