# 🟢 완료
# SPEC_Lobby — 로비 시스템 (랭킹 UI + 게임 시작)

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `LobbyFlowComponent` (Bootstrap 레이어) |
| **기능 요약** | 로비에서 랭킹 UI 표시 + GAME START 버튼으로 `IsLobbyActive` 전환, 필요 시 맵 이동 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 랭킹 시스템 기획.md` |
| **연관 SPEC** | `SPEC_RankingSystem.md`, `SPEC_LobbyUIFix.md`, `SPEC_ModularRefactor.md` |
| **모듈화 규칙** | `GRUtilModule:BootstrapUtil()` 반환을 `self._T.GRUtil`에 캐시해 사용 |

---

## 2. 범위 (이 SPEC이 다루는 것)

| 포함 | 미포함 |
|---|---|
| 로비 상태(`IsLobbyActive`) 권위 제어 | 인게임 전투 로직 |
| 시작/랭킹 UI 가시성 제어 | 랭킹 저장/정렬 알고리즘 |
| GAME START 버튼 클릭 서버 라우팅 | GameOver 세부 연출 |
| `UseMapSplit` 기반 선택적 맵 이동 | 리소스(스프라이트/사운드) 제작 |

---

## 3. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 로비 상태 플래그 | `[server only]` | `IsLobbyActive` 변경 및 Sync 전파 |
| 시작 버튼 입력 | `[client only]` | `GRStartButton` 클릭 이벤트만 허용 |
| 시작 요청 처리 | `[server]` | 소유자 검증 후 `SetLobbyStateServer(false)` |
| UI 가시성 적용 | `[client only]` | `ApplyLobbyUIClient(isLobby)` 단일 책임 |
| 맵 이동(옵션) | `[server only]` | `UseMapSplit=true`일 때만 `_RoomService:MoveUserToStaticRoom` |

---

## 4. Properties

### LobbyFlowComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsLobbyActive` | `boolean` | `@Sync` | `true` | 현재 로비 상태 여부 |
| `UseMapSplit` | `boolean` | `None` | `false` | 맵 분리 이동 사용 여부 (`false`면 상태 전환만 수행) |
| `LobbyMapName` | `string` | `None` | `"games"` | 로비 맵 이름 |
| `InGameMapName` | `string` | `None` | `"games"` | 인게임 맵 이름 |
| `AutoOpenRankingOnLobby` | `boolean` | `None` | `true` | 로비 진입 시 랭킹 자동 조회 |
| `LobbyRankingTab` | `integer` | `None` | `1` | 로비 기본 랭킹 탭 (1=타임어택) |
| `StartButtonPath` | `string` | `None` | `"/ui/DefaultGroup/GRStartButton"` | 시작 버튼 UI 경로 |
| `RankingTextPath` | `string` | `None` | `"/ui/DefaultGroup/GRRankingText"` | 랭킹 텍스트 경로 |
| `MyRankTextPath` | `string` | `None` | `"/ui/DefaultGroup/GRMyRankText"` | 내 순위 텍스트 경로 |
| `UIRootPath` | `string` | `None` | `"/ui/DefaultGroup"` | UI 루트 경로 |

---

## 5. UI 엔티티 배치

> UI 단일 기준 경로: `/ui/DefaultGroup/`

| 엔티티 | 초기 상태 | 로비(`IsLobbyActive=true`) | 인게임(`IsLobbyActive=false`) |
|---|---|---|---|
| `GRStartButton` | `enable: true` | ✅ 표시 | ❌ 숨김 |
| `GRRankingText` | `enable: true` | ✅ 표시 | ❌ 숨김 |
| `GRMyRankText` | `enable: true` | ✅ 표시 | ❌ 숨김 |

---

## 6. 로직 흐름

### 6-1. 월드 접속 → 로비 초기화

```
Player 접속
→ Map01BootstrapComponent.ConfigurePlayer()
  → LobbyFlowComponent 추가 (IsLobbyActive=true, UseMapSplit=false)
→ [서버] SetLobbyStateServer(true)
  → 이동/공격 잠금 적용
→ [클라이언트] ApplyLobbyUIClient(true)
  → Start/Ranking/MyRank 표시
→ AutoOpenRankingOnLobby=true 이면 랭킹 탭 자동 오픈/요청
```

### 6-2. GAME START 버튼 클릭

```
Client: GRStartButton 클릭
→ OnStartButtonClickedClient()
  → 디바운스 체크
  → RequestStartGameServer(requestUserId)

Server: RequestStartGameServer()
  → 소유자 검증
  → SetLobbyStateServer(false)
    → IsLobbyActive=false (Sync)
    → 이동/공격 잠금 해제
  → UseMapSplit=true 이면 MoveUserToInGameMapByUserId()

Client: OnSyncProperty("IsLobbyActive", false)
→ ApplyLobbyUIClient(false)
  → Start/Ranking/MyRank 숨김
```

### 6-3. 맵 진입 시 안전 재적용

```
Client: OnMapEnter(enteredMap)
→ BindStartButtonClient() 재시도
→ UseMapSplit=true이고 enteredMap이 인게임이면 ApplyLobbyUIClient(false)
→ 그 외에는 ResolveEffectiveLobbyStateClient() 기준으로 UI 재적용
```

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `Map01BootstrapComponent` | Bootstrap | 플레이어 생성 시 LobbyFlow 속성 주입 |
| `RankingComponent` | Meta | 로비 진입 시 랭킹 스냅샷 요청 |
| `RankingUIComponent` | UI | 로비 탭 오픈/표시 제어 |
| `MovementComponent` | Core | 로비 상태에서 `CanMove=false` |
| `FireSystemComponent` | Combat | 로비 상태에서 `CanAttack=false` |
| `GRUtilModule` | Core | `self._T.GRUtil` 경유로 안전한 컴포넌트 접근 |

---

## 8. 맵 전환 API (옵션)

```lua
-- UseMapSplit=false (기본): 상태 전환만 수행, 맵 이동은 생략

-- UseMapSplit=true: 서버에서 명시적으로 이동
_RoomService:MoveUserToStaticRoom(userId, self.InGameMapName)
_RoomService:MoveUserToStaticRoom(userId, self.LobbyMapName)
```

---

## 9. 주의 사항

- UI 가시성 제어는 `LobbyFlowComponent` 단일 책임으로 유지한다.
- 시작 입력은 `GRStartButton` 클릭만 허용한다.
- `OnMapEnter`에서 UI를 즉시 재적용해 Sync 타이밍 경합을 흡수한다.
- 공통 유틸은 글로벌 직접 참조가 아니라 `self._T.GRUtil` 캐시를 표준으로 사용한다.

---

## 10. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, Bootstrap 레이어 반영
- [x] `@Sync property boolean IsLobbyActive` 반영
- [x] `UseMapSplit=false`, `LobbyMapName/InGameMapName="games"` 기본값 반영
- [x] 버튼 클릭 이벤트만 시작 입력으로 허용
- [x] `[server only]` 상태 전환 / `[client only]` UI 제어 분리
- [x] `self._T.GRUtil.ResolveComponent`, `self._T.GRUtil.TrySetCanMove` 경유 사용
- [x] `OnMapEnter` 클라이언트 UI 재적용 로직 반영
- [x] `nil`/`isvalid` 방어 + `pcall` 보호 반영
- [x] `기획서/4.부록/Code_Documentation.md`와 동기화
- [x] 상태 `🟢 완료` 유지

---

## 11. Maker 수동 백로그

- [ ] `GRStartButton` 클릭 시 로비 UI 숨김/인게임 UI 전환을 Maker Play에서 최종 확인
- [ ] `UseMapSplit=true` 임시 설정 시 room 이동 경로(`games`, `map://games`, `/maps/games`)를 Maker Play에서 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

