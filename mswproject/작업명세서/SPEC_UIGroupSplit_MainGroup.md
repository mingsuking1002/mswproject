# 🟢 완료
# SPEC_UIGroupSplit_MainGroup — DefaultGroup 인게임 전용화 + MainGroup 분리

## 0. 상태 이력

- `2026-02-26` `🟡 대기중` 접수
- `2026-02-26` `🔵 진행중` UI 분리/스크립트 경로 이관 시작
- `2026-02-26` `🟢 완료` MainGroup 분리 + 경로 폴백 + 문서화 완료
- `2026-02-26` `🔵 진행중` `GRScoreText`를 `DefaultGroup`으로 복귀 처리 시작
- `2026-02-26` `🟢 완료` `GRScoreText` UI/스크립트 경로를 `DefaultGroup` 기준으로 재동기화

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `MainGroup`(신규 UI Group), `DefaultGroup`(인게임 전용) |
| **대상 파일** | `ui/MainGroup.ui`, `ui/DefaultGroup.ui` |
| **실행 공간** | `[Client Only]` UI 렌더링/이벤트 |
| **기능 요약** | 로비/랭킹/게임오버 UI를 `MainGroup`으로 분리하고, `DefaultGroup`은 인게임 HUD/전투 UI만 유지 |
| **연관 컴포넌트** | `LobbyFlowComponent`, `RankingUIComponent`, `InfiniteModeComponent`, `Map01BootstrapComponent` |

---

## 2. Entity 이동 매핑

### 2-1. `DefaultGroup` -> `MainGroup` 완전 이동

- `/ui/DefaultGroup/GRStartButton`
- `/ui/DefaultGroup/GRLobbyPanel` (+ 하위 `GRLobbyTitleText`, `GRRankingOpenButton`)
- `/ui/DefaultGroup/GRRankingPanel` (+ 하위 11개)
- `/ui/DefaultGroup/GRResultPanel`
- `/ui/DefaultGroup/GRReentryPopup` (+ 하위 `AcceptButton`, `DeclineButton`)

### 2-2. `MainGroup` 신규 추가

- `/ui/MainGroup/GRRankingText`
- `/ui/MainGroup/GRMyRankText`

### 2-3. `DefaultGroup` 유지(인게임 전용)

- 인게임 HUD/레거시 HUD: `GRTimerText`, `GRHPText`, `GRAmmoText`, `GRCooldownText`, `GRWeaponText`, `GRScoreText`, `GRHUD_*`, `GRReloadFollowBack*`, `GRWeaponRightBottomHUD*`
- 전투 중 UI: `GRWeaponWheelRoot*`, `ShopPanel*`, `ShopDimOverlay`
- 시스템 기본: `UIJoystick`, `UIChat`

---

## 3. 스크립트 Path 변경표

| 파일 | 변경 핵심 |
|---|---|
| `LobbyFlowComponent.mlua` | 기본 경로를 `/ui/MainGroup/...`로 변경, `UIRootFallbackPath` 추가, Main->Default 루트 폴백 |
| `RankingUIComponent.mlua` | 랭킹 UI 경로를 `/ui/MainGroup/...`로 변경, `UIRootPath/UIRootFallbackPath` 추가, 하드코드 루트 제거 |
| `InfiniteModeComponent.mlua` | 결과/재진입 경로는 `/ui/MainGroup/...` 유지, 점수(`ScoreTextPath`)는 `/ui/DefaultGroup/GRScoreText`로 복귀 |
| `Map01BootstrapComponent.mlua` | `LobbyUIRootPath` 기본값을 `/ui/MainGroup`으로 변경 |
| `map/games.map` | `LobbyBootstrap.Map01BootstrapComponent.LobbyUIRootPath`를 `/ui/MainGroup`으로 변경 |

---

## 4. Logic Architecture / 주의사항

- 로비/랭킹/게임오버 UI는 `MainGroup`을 1차 소스로 사용.
- 런타임 안전성을 위해 `ResolveUIEntity`는 `Main exact -> Main root leaf -> Default root leaf` 순으로 폴백.
- `GRRankingText/GRMyRankText`는 레거시 참조 호환을 위해 `MainGroup`에 신규 생성.
- 상점/무기휠/패널티/태그스킬 UI 경로는 이번 범위에서 유지.

---

## 5. 검증 체크리스트

- [x] `ui/DefaultGroup.ui` JSON 파싱 성공
- [x] `ui/MainGroup.ui` JSON 파싱 성공
- [x] 이동 대상 path가 `DefaultGroup.ui`에서 제거됨
- [x] 이동 대상 path + 신규 2개 path가 `MainGroup.ui`에 존재
- [x] `GRScoreText`는 `DefaultGroup.ui`에 1개 존재하고 `MainGroup.ui`에는 존재하지 않음
- [x] 4개 `.mlua` 경로 변경 반영
- [x] 4개 `.codeblock`에 `.mlua` 내용 동기화 반영
- [x] `map/games.map` UI 루트 오버라이드 반영
