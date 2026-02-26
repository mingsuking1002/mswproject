# 🟢 완료
# SPEC_Map_Games_48x48_TileField — games 맵 48x48 타일 필드 생성

## 0. 상태 이력

- `2026-02-26` `🟡 대기중` 요청 접수
- `2026-02-26` `🔵 진행중` games 맵 RectTile 기반 48x48 필드 구성 시작
- `2026-02-26` `🟢 완료` 타일맵 엔티티/빌더 컴포넌트/.codeblock 동기화 및 문서 갱신 완료

---

## 1. 요구사항 요약

1. `games` 맵에 48px 그리드 타일로 구성된 필드 생성
2. 타일 개수는 `48 x 48` 칸
3. 플레이어가 이동 가능한(비충돌) 기본 타일 사용

---

## 2. 변경 파일

- `map/games.map`
- `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.mlua`
- `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.codeblock`
- `기획서/4.부록/Code_Documentation.md`

---

## 3. 구현 상세

### 3-1. 맵 엔티티 추가

- 신규 엔티티 경로: `/maps/games/MapleMapLayer/GRBaseRectTileMap`
- 컴포넌트:
  - `MOD.Core.TransformComponent`
  - `MOD.Core.RectTileMapComponent`
- 설정:
  - `GridSize = (48, 48)`
  - `TileSetRUID = "tileset://4e5436fa-e939-4c4d-9dfc-c441842dfe1e"`

### 3-2. 빌더 컴포넌트 추가

- 컴포넌트명: `GamesRectTileMapBuilderComponent`
- 부착 위치: `/maps/games` 루트 엔티티
- 동작:
  1. `OnBeginPlay` 서버에서 RectTileMap 컴포넌트 확보
  2. `GridPixelSize=48`, `TileCountX=48`, `TileCountY=48` 기본값 적용
  3. 타일 이름 `Henesys_soil_1`로 `BoxFill(0,0) -> (47,47)` 채우기
  4. 이름 채우기 실패 시 `BoxFill(1, ...)` 인덱스 fallback

---

## 4. 검증 체크리스트

- [x] `map/games.map` JSON 파싱 성공
- [x] `/maps/games` 루트에 `script.GamesRectTileMapBuilderComponent` 추가 확인
- [x] `/maps/games/MapleMapLayer/GRBaseRectTileMap` 엔티티 존재 확인
- [x] `GamesRectTileMapBuilderComponent.mlua` ↔ `.codeblock` 동기화 일치

---

## 5. 런타임 확인 항목 (Maker Play)

- [ ] `games` 진입 시 48x48칸 타일 필드가 표시되는지
- [ ] 마우스/키보드로 플레이어가 타일 필드 위를 정상 이동하는지
- [ ] 플레이 중 재진입 시 필드가 동일 크기(48x48)로 유지되는지

## 6. 2026-02-26 Update: Global TileSet Switch + Center Spawn

### Status History
- `2026-02-26` `🔵 진행중` global tileset reference switched to image `c2e42c0bf3754e73979553c8d0f32ac1` (via single-tile tileset)
- `2026-02-26` `🟢 완료` player center spawn at tile-field center implemented

### Applied
- New tileset resource: `RootDesk/MyDesk/games_base.tileset`
  - TileSet id: `tileset://1a9d9bb4-4d5e-4f39-90d0-5c8ec2c3d26b`
  - Single tile image id: `c2e42c0bf3754e73979553c8d0f32ac1`
- `games.map` tilemap references updated to the new tileset id (global tileset-level switch)
- `Map01BootstrapComponent` center spawn logic added:
  - `SpawnAtRectTileCenterOnConfigure`
  - `CenterSpawnRectTilePath`
  - `CenterSpawnTileCountX/Y`
  - `ApplyCenterSpawnOncePerUser`

### Static Checks
- [x] `games_base.tileset` JSON parse success
- [x] `games.map` JSON parse success
- [x] `Map01BootstrapComponent.mlua` ↔ `.codeblock` sync match
- [x] `GamesRectTileMapBuilderComponent.mlua` ↔ `.codeblock` sync match

## 7. 2026-02-26 Update: In-Game Lag Mitigation (Bootstrap Reconfigure Loop)

### Status History
- `2026-02-26` `🔵 진행중` in-game periodic full reconfigure loop profiling and mitigation
- `2026-02-26` `🟢 완료` periodic configure changed to unconfigured-user only + warmup auto stop

### Applied
- `Map01BootstrapComponent` periodic configure policy changed to avoid full `ConfigurePlayer()` on already-configured user entities.
- `map/games.map` builder override optimized: `ClearBeforeFill` set to `false` to reduce one-time map build clear cost.
- Added properties:
  - `PeriodicConfigureOnlyForUnconfiguredUsers = true`
  - `StopPeriodicConfigureAfterWarmup = true`
  - `PeriodicConfigureWarmupTicks = 10`
- Added runtime caches/methods:
  - `_T.ConfiguredEntityByUserId`
  - `_T.PeriodicConfigureTickCount`
  - `MarkUserConfiguredServer()`
  - `IsUserConfigureCurrentServer()`
  - `ResetUserConfigureStateServer()`
- User lifecycle handling:
  - `HandleUserEnterEvent` now resets per-user cache and triggers forced one-time configure.
  - `HandleUserLeaveEvent` now clears per-user cache for rejoin safety.
- `.codeblock(Target mLua)` synchronized with `.mlua`.

### Static Checks
- [x] `Map01BootstrapComponent.mlua` contains new periodic configure guard properties/methods.
- [x] `Map01BootstrapComponent.codeblock` JSON parse success.
- [x] `Map01BootstrapComponent.codeblock` `Target` matches `.mlua` source.
- [x] `map/games.map` JSON parse success after `ClearBeforeFill=false` override.

## 8. 2026-02-26 Update: Temporary TileMap Load Disable

### Status History
- `2026-02-26` `🔵 진행중` games 타일맵 로딩 경로 임시 비활성화
- `2026-02-26` `🟢 완료` 빌더/타일맵/센터스폰 비활성화 적용

### Applied
- `script.GamesRectTileMapBuilderComponent`
  - `Enable = false`
  - `RebuildOnBeginPlay = false`
- `script.Map01BootstrapComponent`
  - `SpawnAtRectTileCenterOnConfigure = false`
- `/maps/games/MapleMapLayer/GRBaseRectTileMap`
  - entity `enable = false`, `visible = false`
  - `MOD.Core.RectTileMapComponent.Enable = false`

### Static Checks
- [x] `map/games.map` JSON parse success after temporary disable.

## 9. 2026-02-26 Update: Safe TileMap Visual Re-Enable (No Kinematicbody)

### Status History
- `2026-02-26` `🔵 진행중` MCP 가이드 기준 타일맵 가림/충돌 이슈 안전 복구
- `2026-02-26` `🟢 완료` 바닥 전용 렌더 설정으로 타일맵 재활성화

### Applied
- `script.GamesRectTileMapBuilderComponent`
  - `Enable = false` 유지
  - `RebuildOnBeginPlay = false` 유지
- `/maps/games/MapleMapLayer/GRBaseRectTileMap`
  - entity `enable = true`, `visible = true`
  - `MOD.Core.RectTileMapComponent.Enable = true`
  - `IgnoreMapLayerCheck = false`
  - `OrderInLayer = -1000`
  - `PhysicsInteractable = false` 유지
- `games_base.tileset`
  - 타일 이미지는 `datas[0].Id`에 이미지 RUID 입력 방식 유지 (`c2e42c0bf3754e73979553c8d0f32ac1`)

### Static Checks
- [x] `map/games.map` JSON parse success after safe visual re-enable.
- [x] `RootDesk/MyDesk/games_base.tileset` image RUID entry 확인.

## 10. 2026-02-26 Update: TileMap Occlusion Emergency Fix (MapLayer Sort)

### Status History
- `2026-02-26` `🔵 진행중` 타일맵이 플레이어/오브젝트를 가리는 레이어 우선순위 긴급 조정
- `2026-02-26` `🟢 완료` MapLayer 정렬 우선순위 하향 적용

### Applied
- `/maps/games/MapleMapLayer` `MOD.Core.MapLayerComponent.LayerSortOrder` 값을 `0 -> -100`으로 변경.
- 기존 안전 설정 유지:
  - `GRBaseRectTileMap.RectTileMapComponent.OrderInLayer = -1000`
  - `PhysicsInteractable = false`
  - `IgnoreMapLayerCheck = false`

### Static Checks
- [x] `map/games.map` JSON parse success after layer sort fix.

## 11. 2026-02-26 Update: Alternative 1 적용 (타일맵 완전 비사용 + 단일 배경 스프라이트)

### Status History
- `2026-02-26` `🔵 진행중` TileMap 기능 비사용 전환 및 단일 배경 스프라이트 연출 전환
- `2026-02-26` `🟢 완료` `c2e42c0bf3754e73979553c8d0f32ac1` 배경 스프라이트 적용 완료

### Applied
- TileMap 완전 비사용 처리:
  - `script.GamesRectTileMapBuilderComponent.Enable = false` 유지
  - `script.GamesRectTileMapBuilderComponent.RebuildOnBeginPlay = false` 유지
  - `/maps/games/MapleMapLayer/GRBaseRectTileMap` entity `enable=false`, `visible=false`
  - `GRBaseRectTileMap.MOD.Core.RectTileMapComponent.Enable = false`
- Alternative 1 배경 스프라이트 추가:
  - 신규 엔티티: `/maps/games/MapleMapLayer/GRWorldBackdrop`
  - `MOD.Core.SpriteRendererComponent.SpriteRUID = c2e42c0bf3754e73979553c8d0f32ac1`
  - `MOD.Core.TransformComponent.Scale = (2034, 2034, 1)`
  - `OrderInLayer = -2000` (모든 게임플레이 오브젝트 뒤)

### Static Checks
- [x] `map/games.map` JSON parse success after Alternative 1 migration.
- [x] `GRWorldBackdrop` 엔티티 및 `SpriteRUID` 반영 확인.

## 12. 2026-02-26 Update: Player World-Bounds Clamp (Prevent Leaving Backdrop)

### Status History
- `2026-02-26` `🟡 대기중` prevent player leaving backdrop bounds request received
- `2026-02-26` `🔵 진행중` add server-authoritative movement clamp + bootstrap injection + map override
- `2026-02-26` `🟢 완료` `.mlua/.codeblock` sync and map override update completed

### Applied
- `MovementComponent`
  - Added world clamp properties:
    - `UseWorldBoundsClamp`
    - `WorldBoundsMinX/MaxX`
    - `WorldBoundsMinY/MaxY`
    - `WorldBoundsPadding`
  - Added `ApplyWorldBoundsClampServer(transform)` and invoked after both transform-move and rigidbody velocity paths.
- `Map01BootstrapComponent`
  - Added backdrop clamp config properties:
    - `ClampPlayerWithinBackdropBounds`
    - `BackdropCenterX/Y`
    - `BackdropSizeX/Y`
    - `BackdropBoundPadding`
  - In `ConfigurePlayer()`, injects calculated min/max bounds into `MovementComponent`.
- `map/games.map`
  - Added explicit `script.Map01BootstrapComponent` overrides:
    - `ForcePlayerTransformMovement = true`
    - `ClampPlayerWithinBackdropBounds = true`
    - `BackdropCenterX = 0`
    - `BackdropCenterY = 0`
    - `BackdropSizeX/Y` initial `2034` (later corrected to `20.34` in section 13)
    - `BackdropBoundPadding` initial `24` (later corrected to `0.25` in section 13)

### Static Checks
- [x] `MovementComponent.codeblock` `Target` exactly matches `MovementComponent.mlua`.
- [x] `Map01BootstrapComponent.codeblock` `Target` exactly matches `Map01BootstrapComponent.mlua`.
- [x] `map/games.map` JSON parse success after clamp override update.

## 13. 2026-02-26 Update: Backdrop Scale 4.8 정합 + Clamp 주입 안정화

### Status History
- `2026-02-26` `🟡 대기중` backdrop scale 축소(4.8) 이후 clamp 미동작 재현 접수
- `2026-02-26` `🔵 진행중` map override 단위 정합 및 런타임 주입 누락 fallback 보강
- `2026-02-26` `🟢 완료` `20.34/0.25` 재설정 + `MovementComponent` bootstrap fallback 적용

### Applied
- `map/games.map` `LobbyBootstrap.script.Map01BootstrapComponent` 오버라이드 값 보정:
  - `BackdropSizeX: 20.34`
  - `BackdropSizeY: 20.34`
  - `BackdropBoundPadding: 0.25`
- `MovementComponent` 서버 fallback 주입 추가:
  - `EnsureWorldBoundsBootstrapServer()`
  - `TryApplyWorldBoundsFromBootstrapServer()`
  - 호출 지점: `OnInitialize`, `OnUpdate`
- 의도:
  - `ConfigurePlayer()` 타이밍 누락 시에도 `/maps/games/LobbyBootstrap`에서 clamp 설정을 재시도 주입해 경계 미적용 상태를 방지.

### Static Checks
- [x] `map/games.map` JSON parse success after override correction (`20.34`, `0.25`).
- [x] `MovementComponent.codeblock` JSON parse success.
- [x] `MovementComponent.codeblock` `Target` exactly matches `MovementComponent.mlua`.
- [x] `Map01BootstrapComponent.codeblock` `Target` exactly matches `Map01BootstrapComponent.mlua`.

## 14. 2026-02-26 Update: GRWorldBackdrop 인식 기반 플레이어/몬스터 이동·스폰 경계 통합

### Status History
- `2026-02-26` `🟡 대기중` 플레이어/몬스터가 `GRWorldBackdrop` 기준으로만 이동/스폰되도록 전환 요청
- `2026-02-26` `🔵 진행중` backdrop entity 실측(bounds) 계산 + 플레이어/몬스터 경계 주입 경로 통합
- `2026-02-26` `🟢 완료` `.mlua/.codeblock` 동기화 및 정적 검증 완료

### Applied
- `Map01BootstrapComponent`
  - `GRWorldBackdrop` 기준 자동 bounds 동기화 추가:
    - `UseBackdropEntityAutoBounds`
    - `BackdropEntityPath`
    - `BackdropBoundsRefreshInterval`
    - `RefreshBackdropBoundsFromEntityServer()`
    - `TryResolveBackdropBoundsFromEntityServer()`
    - `ResolveBackdropSizeFromSpriteServer()` (`Sprite.Width/Height/PixelPerUnit + Transform.Scale` 기반)
  - 플레이어 스폰 fallback 추가:
    - `SpawnAtBackdropCenterOnConfigure`
    - `ApplyBackdropCenterSpawnServer()`
  - `ConfigurePlayer()`에서 경계 갱신 후 clamp 주입, `MonsterSpawnComponent`에 bootstrap 경로 전달.
  - `ConfigurePlayer()`에서 `MonsterSpawnComponent:RefreshBackdropBoundsCacheServer(true)` 즉시 호출로 초기 스폰 틱의 bounds 미해결 레이스를 완화.
- `MonsterSpawnComponent`
  - backdrop 경계 캐시/조회 추가:
    - `RestrictMonstersToBackdrop`
    - `BackdropBootstrapPath`
    - `BackdropBoundsRefreshInterval`
    - `RefreshBackdropBoundsCacheServer()`
    - `ResolveBackdropBoundsFromBootstrapServer()`
    - `IsInsideBackdropBoundsServer()`
  - 스폰 제한:
    - `IsValidSpawnPosition()`에 backdrop 내부 조건 추가.
    - `ResolveBossSpawnPositionServer()`로 보스 스폰도 backdrop 중심으로 제한.
  - 이동 제한:
    - `ApplyMonsterBackdropClampToMovementServer()` 추가.
    - `ApplyMonsterStatsIfAvailable()`에서 spawned/placed 몬스터 `MovementComponent`에 동일 world clamp 적용.
  - bounds 일관성:
    - `ResolveBackdropBoundsFromBootstrapServer()` 내부에서 `Map01BootstrapComponent:RefreshBackdropBoundsFromEntityServer(false)` 선호 호출 후 center/size를 읽어 stale bounds를 완화.
- `map/games.map`
  - `LobbyBootstrap.script.Map01BootstrapComponent`에 아래 오버라이드 명시 반영:
    - `UseBackdropEntityAutoBounds = true`
    - `BackdropEntityPath = "/maps/games/MapleMapLayer/GRWorldBackdrop"`
    - `BackdropBoundsRefreshInterval = 1.0`
    - `SpawnAtBackdropCenterOnConfigure = true`

### Static Checks
- [x] `Map01BootstrapComponent.codeblock` JSON parse success.
- [x] `Map01BootstrapComponent.codeblock` `Target` exactly matches `.mlua`.
- [x] `MonsterSpawnComponent.codeblock` JSON parse success.
- [x] `MonsterSpawnComponent.codeblock` `Target` exactly matches `.mlua`.
- [x] `map/games.map` JSON parse success.
