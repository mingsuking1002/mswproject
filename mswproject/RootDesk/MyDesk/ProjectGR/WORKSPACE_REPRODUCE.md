# Project GR Workspace Reproduce Guide

## 1. Goal
이 문서는 현재 구현 상태를 로컬 워크스페이스에서 동일하게 재현하기 위한 절차를 정의합니다.

## 2. Fast Check
아래 명령으로 재현 가능 상태를 검증합니다.

```powershell
powershell -ExecutionPolicy Bypass -File _scripts/repro_projectgr_workspace.ps1
```

SPEC 상태 자동 보정까지 하려면:

```powershell
powershell -ExecutionPolicy Bypass -File _scripts/repro_projectgr_workspace.ps1 -Fix
```

## 3. Required Component Files
다음 컴포넌트 파일이 모두 존재해야 합니다.

- `mswproject/RootDesk/MyDesk/ProjectGR/Components/MovementComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/ReloadComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/FireSystemComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/ProjectileComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/WeaponWheelUIComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/RankingComponent.mlua`
- `mswproject/RootDesk/MyDesk/ProjectGR/Components/RankingUIComponent.mlua`

## 4. Workspace Binding Checklist
Maker에서 실제 플레이 재현을 위해 아래 바인딩을 확인합니다.

- `DefaultPlayer`(또는 플레이어 엔티티)에 핵심 컴포넌트 부착:
`MovementComponent`, `CameraFollowComponent`, `HPSystemComponent`, `ReloadComponent`, `FireSystemComponent`, `WeaponSwapComponent`, `WeaponWheelUIComponent`, `TagManagerComponent`, `SpeedrunTimerComponent`, `RankingComponent`, `RankingUIComponent`
- `FireSystemComponent.ProjectileModelId`에 실제 투사체 모델 ID 설정
- 투사체 모델 엔티티에 `ProjectileComponent` 포함
- `WeaponWheelUIComponent.WheelRoot`를 실제 방사형 메뉴 UI 엔티티에 연결
- `SpeedrunTimerComponent.TimerTextEntity`를 타이머 텍스트 UI 엔티티에 연결
- `RankingUIComponent.RankingTextEntity`, `RankingUIComponent.MyRankTextEntity`를 랭킹 UI 텍스트 엔티티에 연결

## 5. Acceptance
아래가 모두 만족되면 재현 성공입니다.

- `_scripts/repro_projectgr_workspace.ps1` 결과가 `PASS`
- `작업명세서/SPEC_*.md` 8개 상태가 모두 `# 🟢 완료`
- `기획서/4.부록/Code_Documentation.md`에 12개 컴포넌트 섹션 존재

## 6. map01 Direct Setup (Applied)
`map01.map` already includes direct runtime bootstrap wiring:

- `/maps/map01/Map01Bootstrap` with `Map01BootstrapComponent`
- `/maps/map01/GRProjectileTemplate`
- `/maps/map01/GRTimerText`
- `/maps/map01/GRRankingText`
- `/maps/map01/GRMyRankText`
- `/maps/map01/GRWeaponWheelRoot`

At play start, `Map01BootstrapComponent` auto-adds Project GR components to player entities in `map01` and binds references without manual property binding.

## 7. Maker Runbook (Phase 2/3)
Follow this exact order in Maker.

### 7.1 Open/Refresh
1. Close Maker completely.
2. Re-open the world from local workspace.
3. Open `map01`.

### 7.2 Visual Setup (Manual in Maker)
1. Select `/maps/map01/GRProjectileTemplate`.
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
1. Play from `map01`.
2. Check movement with `WASD`.
3. Check fire with touch/click.
4. Check reload with `R`.
5. Check weapon wheel with `F`.
6. Check tag switch with `Q`.

### 7.6 If Nothing Applies
1. Open console and confirm logs containing `Map01Bootstrap`.
2. If no bootstrap logs appear, verify the entity `/maps/map01/Map01Bootstrap` exists and has `Map01BootstrapComponent`.
3. Re-save `map01`, restart Maker, and play again.
