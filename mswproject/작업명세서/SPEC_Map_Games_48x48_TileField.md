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
