# 🟢 완료
# SPEC_Lobby — 로비 시스템 (랭킹 UI + 게임 시작)

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `LobbyFlowComponent` (Bootstrap 레이어) |
| **기능 요약** | 로비에서 랭킹 UI 표시 + GAME START 버튼 → MAP01 맵 전환 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 랭킹 시스템 기획.md` |
| **연관 SPEC** | `SPEC_RankingSystem.md` (데이터/UI 컴포넌트) |
| **모듈화 규칙** | `SPEC_ModularRefactor.md` 준수 (`_GRUtil` 사용, Bootstrap 레이어) |

---

## 2. 범위 (이 SPEC이 다루는 것)

| 포함 | 미포함 |
|---|---|
| 로비 맵 진입 시 UI 초기화 | 인게임 전투 로직 |
| 랭킹 UI 표시 (RankingUIComponent 호출) | 랭킹 데이터 저장/조회 (SPEC_RankingSystem) |
| GAME START 버튼 클릭 → MAP01 이동 | MAP01 내 게임플레이 (별도 SPEC) |
| 맵 전환 시 UI 가시성 전환 | GameOver → 로비 복귀 (추후 확장) |

---

## 3. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 로비 상태 플래그 | `[server only]` | `IsLobbyActive` — Sync로 클라에 전파 |
| 랭킹 데이터 요청 | `[client → server]` | 로비 진입 시 자동 요청 |
| UI 가시성 제어 | `[client only]` | 로비/인게임 상태별 일괄 전환 |
| GAME START 처리 | `[client]` → `[server]` | 버튼 클릭 → 서버 검증 → 맵 이동 |
| 맵 이동 | `[server only]` | `_RoomService:MoveUserToStaticRoom` 서버 권위 |

---

## 4. Properties

### LobbyFlowComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsLobbyActive` | `boolean` | `@Sync` | `true` | 현재 로비 상태 여부 |
| `UseMapSplit` | `boolean` | `None` | `true` | lobby↔map01 맵 분리 사용 |
| `LobbyMapName` | `string` | `None` | `"lobby"` | 로비 맵 이름 |
| `InGameMapName` | `string` | `None` | `"map01"` | 인게임 맵 이름 |
| `AutoOpenRankingOnLobby` | `boolean` | `None` | `true` | 로비 진입 시 랭킹 자동 조회 |
| `LobbyRankingTab` | `integer` | `None` | `1` | 로비에서 기본 열릴 랭킹 탭 (1=타임어택) |
| `StartButtonPath` | `string` | `None` | `"/ui/DefaultGroup/GRStartButton"` | 시작 버튼 UI 경로 |
| `RankingTextPath` | `string` | `None` | `"/ui/DefaultGroup/GRRankingText"` | 랭킹 텍스트 UI 경로 |
| `MyRankTextPath` | `string` | `None` | `"/ui/DefaultGroup/GRMyRankText"` | 내 순위 텍스트 UI 경로 |
| `UIRootPath` | `string` | `None` | `"/ui/DefaultGroup"` | UI 그룹 루트 |

---

## 5. UI 엔티티 배치

> 모든 UI는 `/ui/DefaultGroup/` 단일 소스 (SPEC_LobbyUIFix §3 확정)

| 엔티티 | 위치 | 초기 상태 | 로비 | 인게임 |
|---|---|---|---|---|
| `GRStartButton` | `/ui/DefaultGroup/` | `enable: true` | ✅ 표시 | ❌ 숨김 |
| `GRRankingText` | `/ui/DefaultGroup/` | `enable: true` | ✅ 표시 | ❌ 숨김 |
| `GRMyRankText` | `/ui/DefaultGroup/` | `enable: true` | ✅ 표시 | ❌ 숨김 |

---

## 6. 로직 흐름

### 6-1. 월드 접속 → 로비 초기화

```
Player 접속
→ Map01BootstrapComponent.ConfigurePlayer()
  → LobbyFlowComponent 추가 (IsLobbyActive = true, UseMapSplit = true)
→ [서버] ApplyInitialServerState()
  → IsLobbyActive = true 확인
  → 이동/공격 잠금 (_GRUtil.TrySetCanMove(false), CanAttack = false)
→ [클라이언트] ApplyLobbyUIClient(true)
  → GRStartButton: Enable = true
  → GRRankingText: Enable = true
  → GRMyRankText: Enable = true
→ AutoOpenRankingOnLobby == true 이면:
  → RankingUIComponent.OpenTab(self.LobbyRankingTab)
  → RankingComponent.RequestRankingDataServer(tab, displayCount)
```

### 6-2. GAME START 버튼 클릭

```
Client: GRStartButton 클릭 이벤트
→ OnStartButtonClickedClient()
  → 디바운스 체크 (연타 방지)
  → RequestStartGameServer() [서버 RPC]

Server: RequestStartGameServer()
  → IsLobbyActive == true 확인 (이미 시작됨이면 무시)
  → SetLobbyStateServer(false)
    → IsLobbyActive = false (Sync → 클라이언트)
    → 이동/공격 잠금 해제
  → UseMapSplit == true 이면:
    → _RoomService:MoveUserToStaticRoom(userId, InGameMapName)

Client: OnSyncProperty("IsLobbyActive", false)
  → ApplyLobbyUIClient(false)
    → GRStartButton: Enable = false (숨김)
    → GRRankingText: Enable = false (숨김)
    → GRMyRankText: Enable = false (숨김)
```

### 6-3. MAP01 진입

```
Client: OnMapEnter(map01)
  → 안전장치: ApplyLobbyUIClient(false) 재호출
  → 인게임 UI 표시 (HUD, 타이머 등 — 다른 SPEC 관할)
```

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `Map01BootstrapComponent` | Bootstrap | `ConfigurePlayer`에서 LobbyFlow 속성 주입 |
| `RankingComponent` | Meta | 로비 진입 시 `RequestRankingDataServer` 호출 |
| `RankingUIComponent` | UI | 로비 진입 시 `OpenTab` → 랭킹 데이터 표시 |
| `MovementComponent` | Core | 로비: `CanMove = false` / 인게임: `true` |
| `FireSystemComponent` | Combat | 로비: `CanAttack = false` / 인게임: `true` |
| `GRUtilModule` | Core | `_GRUtil.TrySetCanMove`, `_GRUtil.ResolveComponent` 사용 |

---

## 8. 맵 전환 API

```lua
-- 서버에서 호출
-- lobby → map01
_RoomService:MoveUserToStaticRoom(userId, self.InGameMapName)

-- map01 → lobby (GameOver 시, 추후 구현)
_RoomService:MoveUserToStaticRoom(userId, self.LobbyMapName)
```

> ⚠️ RoomService API는 버전에 따라 다를 수 있으므로 문서 확인 후 사용. 현재 구현은 `MoveUserToStaticRoom` 기준.

---

## 9. 주의 사항

- **UI 가시성 단일 책임**: `LobbyFlowComponent`만 GR UI 엔티티의 Enable/Visible 제어
- **입력**: 버튼 클릭만 허용 (키보드 폴백 없음)
- **OnMapEnter 안전장치**: Sync 도착 전 UI 잔상 방지를 위해 맵 진입 시 클라이언트 측 UI 강제 재적용
- **`_GRUtil` 의존**: 중복 유틸 함수 대신 글로벌 테이블 사용 (SPEC_ModularRefactor 준수)

---

## 10. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, Bootstrap 레이어
- [x] `@Sync property boolean IsLobbyActive`
- [x] 밸런스/경로 수치 전부 `property`
- [x] `[server only]` 맵 이동 / `[client only]` UI 제어 분리
- [x] `_GRUtil.ResolveComponent`, `_GRUtil.TrySetCanMove` 사용 (중복 유틸 금지)
- [x] 버튼 클릭만 허용, 키보드 폴백 없음
- [x] `OnMapEnter` 클라이언트 분기로 UI 즉시 갱신
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |
