# Project GR Workspace Reproduce Guide

## 1. Goal
이 문서는 현재 구현 상태를 로컬 워크스페이스에서 동일하게 재현하기 위한 절차를 정의합니다.

## 1.1 Related Plan
기능 플로우차트, 테스트 매트릭스, 누락 우선순위는 아래 문서를 기준으로 관리합니다.

- `mswproject/RootDesk/MyDesk/ProjectGR/FLOW_TEST_GAP_PLAN.md`

## 2. Fast Check
아래 명령으로 재현 가능 상태를 검증합니다.

```powershell
powershell -ExecutionPolicy Bypass -File _scripts/repro_projectgr_workspace.ps1
```

SPEC 상태 자동 보정까지 하려면:

```powershell
powershell -ExecutionPolicy Bypass -File _scripts/repro_projectgr_workspace.ps1 -Fix
```

ProjectGR 스크립트를 `.codeblock` Source/Target 형태로 강제 동기화하려면:

```powershell
powershell -ExecutionPolicy Bypass -File _scripts/convert_projectgr_mlua_to_codeblock.ps1
```

## 2.1 Script Format Requirement
Project GR 로컬 워크스페이스 기본은 `.mlua source mode`입니다.

- 기본 모드(권장):
- `RootDesk/MyDesk/ProjectGR/Components/*.codeblock`은 메타데이터(`Source = 0`)로 유지
- 실제 실행 스크립트 본문은 동일 basename의 `.mlua` 파일에 존재
- 대체 모드(선택):
- `convert_projectgr_mlua_to_codeblock.ps1` 실행 시 `Source = 1` + `Target` 본문 모드로 전환 가능

변경 후 Maker에서 아래 순서로 반영하세요.
1. `Reimport All`
2. Maker 재시작

## 3. Required Files
다음 컴포넌트/맵 파일이 모두 존재해야 합니다.

- `mswproject/RootDesk/MyDesk/ProjectGR/Components/MovementComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/ReloadComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/FireSystemComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/ProjectileComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/WeaponWheelUIComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/RankingComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/RankingUIComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/LobbyFlowComponent.codeblock`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/Map01BootstrapComponent.codeblock`
- `mswproject/map/lobby.map`

추가로 기본 모드에서는 위 각 `.codeblock`과 동일 basename의 `.mlua` 파일이 모두 존재해야 합니다.

## 4. Workspace Binding Checklist
Maker에서 실제 플레이 재현을 위해 아래 바인딩을 확인합니다.

- `DefaultPlayer`(또는 플레이어 엔티티)에 핵심 컴포넌트 부착:
`MovementComponent`, `CameraFollowComponent`, `HPSystemComponent`, `ReloadComponent`, `FireSystemComponent`, `WeaponSwapComponent`, `WeaponWheelUIComponent`, `TagManagerComponent`, `SpeedrunTimerComponent`, `RankingComponent`, `RankingUIComponent`, `LobbyFlowComponent`
- `/maps/lobby/LobbyBootstrap`에 `Map01BootstrapComponent` 부착
- `/maps/map01/Map01Bootstrap`에 `Map01BootstrapComponent` 부착
- `FireSystemComponent.ProjectileModelId`에 실제 투사체 모델 ID 설정
- 투사체 모델 엔티티에 `ProjectileComponent` 포함
- `WeaponWheelUIComponent.WheelRoot`를 실제 방사형 메뉴 UI 엔티티에 연결
- `SpeedrunTimerComponent.TimerTextEntity`를 타이머 텍스트 UI 엔티티에 연결
- `RankingUIComponent.RankingTextEntity`, `RankingUIComponent.MyRankTextEntity`를 랭킹 UI 텍스트 엔티티에 연결
- `LobbyFlowComponent.StartButtonPath`가 `/ui/DefaultGroup/GRStartButton`를 가리키는지 확인

## 5. Acceptance
아래가 모두 만족되면 재현 성공입니다.

- `_scripts/repro_projectgr_workspace.ps1` 결과가 `PASS`
- 스크립트 포맷 조건 충족
- 기본 모드: `*.codeblock Source=0` + 동일 basename `*.mlua` 스크립트 본문 존재
- 대체 모드: `*.codeblock Source=1` + `Target` 스크립트 본문 존재
- `작업명세서/SPEC_*.md` 8개 상태가 모두 `# 🟢 완료`
- `기획서/4.부록/Code_Documentation.md`에 14개 컴포넌트 섹션 존재

## 6. Split Scene Setup (Applied)
`lobby.map` and `map01.map` include split-scene runtime bootstrap wiring:

- `/maps/lobby/LobbyBootstrap` with `Map01BootstrapComponent`

- `/maps/map01/Map01Bootstrap` with `Map01BootstrapComponent`
- `/maps/map01/GRProjectileTemplate`
- `/maps/map01/GRTimerText`
- `/maps/map01/GRRankingText`
- `/maps/map01/GRMyRankText`
- `/maps/map01/GRWeaponWheelRoot`

At play start in `lobby`, `Map01BootstrapComponent` auto-adds Project GR components and applies split flow (`LobbyMapName=lobby`, `InGameMapName=map01`).
When `GAME START` is pressed, `LobbyFlowComponent` moves the user to `map01`.
`DefaultGroup.ui` also includes `/ui/DefaultGroup/GRStartButton` for lobby start flow.

## 7. Maker Runbook (Phase 2/3)
Follow this exact order in Maker.

### 7.1 Open/Refresh
1. Close Maker completely.
2. Re-open the world from local workspace.
3. Open `lobby`.

### 7.2 Visual Setup (Manual in Maker)
1. Switch to `map01`, then select `/maps/map01/GRProjectileTemplate`.
2. Confirm components exist:
- `ProjectileComponent`
- `SpriteRendererComponent`
- `TriggerComponent`
3. Assign a projectile sprite in `SpriteRendererComponent`.
4. Set projectile collision group to `PlayerProjectile` (if group selector is available on Trigger/Collider).
5. Place or confirm terrain wall colliders and set them to `Terrain`.

### 7.3 Player Physics Setup (Manual in Maker)
1. Open `Global/DefaultPlayer`.
2. Ensure `RigidbodyComponent` exists.
3. Set:
- `BodyType = Dynamic`
- `GravityScale = 0`
- `FreezeRotationZ = true` (or equivalent rotation lock option)

### 7.4 Service Setup (Manual in Maker)
1. Open world/service settings.
2. Enable leaderboard-related service (`_LeaderBoardService`).
3. Enable data storage service (`_DataStorageService`).
4. Save settings.

### 7.5 Runtime Verification (Play)
1. Play from `lobby`.
2. Confirm ranking text is visible and `GAME START` button is visible.
3. Click `GAME START`; user moves to `map01`.
4. In `map01`, movement/attack HUD becomes active.
5. Check movement with `WASD`.
6. Check fire with touch/click.
7. Check reload with `R`.
8. Check weapon wheel with `F`.
9. Check tag switch with `Q`.

### 7.6 Lobby/InGame Flow Tuning
`LobbyFlowComponent` supports future tuning without code edits:

- `UseMapSplit = false`: same map에서 랭킹 로비 -> 시작 버튼 -> 즉시 전투 전환
- `UseMapSplit = true`: `LobbyMapName`/`InGameMapName` 분리 후 시작 버튼 시 인게임 맵 이동
- `InGameSpawnPosition`: 맵 분리 모드에서 시작 위치 지정
- `HideRankingDuringGameplay`, `HideTimerDuringLobby`, `HideCombatHUDInLobby`: UI 가시성 정책 조정

### 7.7 If Nothing Applies
1. Open console and confirm logs containing `Map01Bootstrap`.
2. If no bootstrap logs appear in lobby, verify `/maps/lobby/LobbyBootstrap` has `Map01BootstrapComponent`.
3. If start transition fails, verify `/maps/map01/Map01Bootstrap` has `Map01BootstrapComponent`.
4. Re-save both `lobby` and `map01`, restart Maker, and play again.
