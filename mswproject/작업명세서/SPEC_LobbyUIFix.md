# 🟡 대기중
# SPEC_LobbyUIFix — 로비↔map01 UI 잔류 버그 수정 & 게임 플로우 안정화

## 1. 개요

| 항목 | 내용 |
|---|---|
| **대상 컴포넌트** | `LobbyFlowComponent`, `SpeedrunTimerComponent`, `RankingUIComponent` |
| **기능 요약** | 로비 UI가 map01 전환 후 잔류하는 버그 수정 + 안정적 lobby↔map01 플로우 구현 |
| **기획서 참조** | 해당 없음 (TD 버그 수정 지침서 기반) |

### 현재 버그 증상
- 로비에서 GAME START → map01 진입 시 **로비 UI(랭킹, 스타트 버튼)가 화면에 잔류**
- `[CLIENT] [LobbyFlowComponent] Keyboard start fallback used.` 로그 발생
- 타이머 카운트다운 로직은 정상하지만 잔류 UI에 가려짐

---

## 2. 현재 엔티티 배치 현황 (확인 완료)

| 엔티티 이름 | `/ui/DefaultGroup/` | `/maps/map01/` | 비고 |
|---|:---:|:---:|---|
| `GRStartButton` | ✅ (ButtonComponent 포함) | ❌ | UI 전용 버튼 |
| `GRRankingText` | ✅ | ✅ | **중복 배치** |
| `GRMyRankText` | ✅ | ✅ | **중복 배치** |
| `GRTimerText` | ❌ | ✅ | UI 레이어에 없음 → **추가 필요** |
| `GRWeaponWheelRoot` | ✅ (enable=false) | ✅ | **중복 배치** |

---

## 3. TD 확정 사항

| 결정 항목 | 선택 | 설명 |
|---|---|---|
| UI Source of Truth | **선택지 A: `/ui/DefaultGroup` 단일화** | 모든 GR UI 엔티티는 `/ui/DefaultGroup/`만 사용. `/maps/map01/` 중복 엔티티 제거 |
| 시작 입력 | **선택지 A: 버튼 클릭만 허용** | 키보드 폴백(Enter/Space) 비활성화 |
| 게임 플로우 | **안정적 순환 구현** | lobby → GAME START → map01 → 플레이 → GameOver → lobby 복귀 |

---

## 4. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 로비 상태 전환 | `[server only]` | `IsLobbyActive` Sync로 권위 유지 |
| UI 가시성 제어 | `[client only]` | `ApplyLobbyUIClient`에서 일괄 처리 |
| 맵 이동 명령 | `[server only]` | `_RoomService:MoveToRoom` 서버 권위 |
| 맵 진입 UI 갱신 | `OnMapEnter` 내부 | 서버+클라이언트 분기 처리 |

---

## 5. 수정 대상 파일 및 변경 내역

### 5-1. LobbyFlowComponent.mlua (주요 수정)

#### A. 키보드 폴백 비활성화

```diff
-    property boolean EnableKeyboardStartFallback = true
+    property boolean EnableKeyboardStartFallback = false
```

#### B. map01 중복 엔티티 fallback 경로 제거 (UI는 DefaultGroup 단일 소스)

```diff
-    property string StartButtonFallbackPath = "/maps/map01/GRStartButton"
+    property string StartButtonFallbackPath = ""
```

```diff
-    property string RankingTextFallbackPath = "/maps/map01/GRRankingText"
-    property string MyRankTextFallbackPath = "/maps/map01/GRMyRankText"
+    property string RankingTextFallbackPath = ""
+    property string MyRankTextFallbackPath = ""
```

#### C. TimerText 경로를 UI 레이어로 변경

> ⚠️ **전제 조건**: map01.map에서 `GRTimerText` 제거 & DefaultGroup.ui에 `GRTimerText` 추가가 선행되어야 함 (아래 5-4 참조)

```diff
-    property string TimerTextPath = "/ui/DefaultGroup/GRTimerText"
+    property string TimerTextPath = "/ui/DefaultGroup/GRTimerText"
```
→ 경로 자체는 동일하나, **현재는 이 엔티티가 DefaultGroup.ui에 없어서 미작동**. 
DefaultGroup.ui에 `GRTimerText` 엔티티 추가 후 정상 동작.

#### D. `ForceApplyLobbyNamedEntitiesInCurrentMapClient` 조건 변경

현재 이 함수는 `currentMap` 자식을 탐색하므로 map01 월드 엔티티를 대상으로 함.
**UI를 DefaultGroup 단일화하면 이 함수의 역할이 축소됨.**

수정 방안:
1. `ForceApplyLobbyNamedEntitiesInCurrentMapClient` 내부에서 `/maps/*/GR*` 탐색 대신 **UIRoot(`/ui/DefaultGroup`) 내에서만** 탐색하도록 변경
2. 또는 `ApplyLobbyUIClient`에서 path 기반 제어가 정상 동작하면 **이 함수 호출 자체를 제거**

#### E. OnMapEnter 클라이언트 UI 즉시 갱신

현재 `OnMapEnter`는 `@ExecSpace("ServerOnly")`로만 동작.
맵 전환 직후 서버 Sync 도착 전 UI 잔상이 발생할 수 있으므로, **클라이언트 측 즉시 갱신 추가**:

```lua
-- 기존 서버 OnMapEnter 내부, 마지막에 클라이언트 갱신 호출 추가
-- (ExecSpace를 양쪽으로 분기하는 방식)
method void OnMapEnter(Entity enteredMap)
    -- [서버] 로비 상태 전환 로직 (기존 유지)
    if self.Entity.Environment:IsServer() then
        -- ... 기존 서버 로직 ...
    end
    
    -- [클라이언트] UI 즉시 갱신
    if self.Entity.Environment:IsClient() then
        if self.EnableLobbyFlow == false then
            return
        end
        local effectiveLobbyState = self:ResolveEffectiveLobbyStateClient()
        self:ApplyLobbyUIClient(effectiveLobbyState)
    end
end
```

> **주의**: MSW에서 `OnMapEnter`의 ExecSpace 제약을 확인할 것. 
> `@ExecSpace("ServerOnly")`를 제거하고 내부 분기하거나, 
> 서버 OnMapEnter에서 `ApplyLobbyUIClient`를 클라이언트로 호출하는 방식 사용.

#### F. GameOver → Lobby 복귀 안정화

`ReturnToLobbyOnRunComplete = true`일 때의 `CompleteRunAndReturnToLobby` 로직에서:

1. 서버: `IsLobbyActive = true` 설정 → `MoveOwnerToLobbyMapIfNeeded()` 호출
2. 클라이언트: Sync 수신 시 `ApplyLobbyUIClient(true)` 자동 실행
3. `OnMapEnter(lobby)` 발동 시 추가로 로비 UI 강제 적용

**확인 필요 사항:** 
- `MoveOwnerToLobbyMapIfNeeded()`에서 `_RoomService:MoveToRoom` 호출 후 플레이어가 lobby 맵으로 실제 이동하는지
- 이동 완료 후 `OnMapEnter`가 lobby 맵 기준으로 재발동되고 UI가 올바르게 전환되는지

---

### 5-2. SpeedrunTimerComponent.mlua

#### A. 타이머 텍스트 fallback 경로 제거

```diff
-    property string TimerTextFallbackPath = "/maps/map01/GRTimerText"
+    property string TimerTextFallbackPath = ""
```

#### B. 타이머 텍스트 가시성 LobbyFlow 존중

`TrySetTimerTextVisibleClient`와 `StartClientTimerTextLoop`에서 `Enable = true`를 강제하기 전에 
`LobbyFlowComponent.IsLobbyActive`를 체크해 **로비 상태면 타이머 텍스트를 표시하지 않도록** 가드 추가:

```lua
-- TrySetTimerTextVisibleClient 상단에 추가
local lobbyFlow = self.Entity:GetComponent("LobbyFlowComponent")
if lobbyFlow ~= nil and isvalid(lobbyFlow) == true then
    if lobbyFlow.IsLobbyActive == true and lobbyFlow.HideTimerDuringLobby == true then
        visible = false
    end
end
```

---

### 5-3. RankingUIComponent.mlua

#### A. fallback 경로 제거

```diff
-    property string RankingTextFallbackPath = "/maps/map01/GRRankingText"
-    property string MyRankTextFallbackPath = "/maps/map01/GRMyRankText"
+    property string RankingTextFallbackPath = ""
+    property string MyRankTextFallbackPath = ""
```

---

### 5-4. map01.map (Maker 작업 — 스크립트 아님)

> ⚠️ 이 작업은 **MSW Maker 에디터에서 수동으로** 진행해야 합니다.

| 작업 | 대상 엔티티 | 설명 |
|---|---|---|
| **제거** | `/maps/map01/GRRankingText` | DefaultGroup.ui에 이미 존재 (중복 제거) |
| **제거** | `/maps/map01/GRMyRankText` | DefaultGroup.ui에 이미 존재 (중복 제거) |
| **제거** | `/maps/map01/GRWeaponWheelRoot` | DefaultGroup.ui에 이미 존재 (중복 제거) |
| **이동** | `/maps/map01/GRTimerText` → `/ui/DefaultGroup/GRTimerText` | UI 레이어로 이동 |

### 5-5. DefaultGroup.ui (Maker 작업 — 스크립트 아님)

| 작업 | 대상 엔티티 | 설명 |
|---|---|---|
| **추가** | `GRTimerText` | map01에서 이동. UITransformComponent + TextComponent 구성, 초기 `enable: false` |

---

## 6. 로직 흐름 (전체 게임 사이클)

### 6-1. 초기 진입 (월드 접속)
```
Player 접속 → Map01BootstrapComponent.ConfigurePlayer 
  → LobbyFlowComponent 추가 (IsLobbyActive = true, UseMapSplit = true)
  → ApplyInitialServerState() → ApplyLobbyUIClient(true)
  → 로비 UI 표시: GRStartButton(visible), GRRankingText(visible), GRTimerText(hidden)
```

### 6-2. GAME START
```
Client: GRStartButton 클릭 → HandleStartButtonClick
  → RequestStartGameServer() [서버로 RPC]
Server: SetLobbyStateServer(false)
  → IsLobbyActive = false (Sync → 클라이언트)
  → MoveOwnerToInGameMapIfNeeded() [lobby → map01]
  → SpeedrunTimerComponent.StartRunWithCountdown()
Client: OnSyncProperty("IsLobbyActive", false)
  → ApplyLobbyUIClient(false)
  → GRStartButton(hidden), GRRankingText(hidden), GRTimerText(visible)
  → 카운트다운 후 게임 시작
```

### 6-3. 플레이 중 (map01)
```
Timer 동작, Combat HUD 표시
SpeedrunTimerComponent가 GRTimerText.Text 갱신 (50ms 루프)
```

### 6-4. GameOver / RunComplete
```
Server: SpeedrunTimerComponent.CompleteRun()
  → 랭킹 제출
Server: LobbyFlowComponent.SetLobbyStateServer(true)
  → IsLobbyActive = true (Sync)
  → MoveOwnerToLobbyMapIfNeeded() [map01 → lobby]
Client: OnSyncProperty("IsLobbyActive", true)
  → ApplyLobbyUIClient(true)
  → GRStartButton(visible), GRRankingText(visible), GRTimerText(hidden)
Client: OnMapEnter(lobby)
  → 안전장치: ApplyLobbyUIClient(true) 재호출
```

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `Map01BootstrapComponent` | LobbyFlowComponent 초기 설정 | `EnableLobbyMapSplit`, `LobbyMapName`, `InGameMapName` 주입 |
| `SpeedrunTimerComponent` | 타이머 시작/정지 | `LobbyFlowComponent`가 `StartRunWithCountdown`/`ResetRun` 호출 |
| `RankingUIComponent` | 랭킹 표시 | `LobbyFlowComponent`가 visibility 제어, RankingUI는 텍스트 내용만 관리 |
| `HPSystemComponent` | GameOver 신호 | HP 0 → `LobbyFlowComponent`에 런 종료 알림 (추후 구현) |
| `MovementComponent` | 이동 잠금 | 로비 상태에서 `CanMove = false` |
| `FireSystemComponent` | 공격 잠금 | 로비 상태에서 `CanAttack = false` |

---

## 8. 주의/최적화 포인트

- **UI 가시성 제어 단일 책임**: `LobbyFlowComponent`만 UI Enable/Visible을 제어. `SpeedrunTimerComponent`와 `RankingUIComponent`는 **텍스트 콘텐츠와 데이터만** 관리
- **Sync 경합 방지**: `OnSyncProperty("IsLobbyActive")` 도착과 `OnMapEnter` 사이의 타이밍 갭을 `OnMapEnter` 내 클라이언트 측 UI 강제 적용으로 보정
- **`pcall` 방어**: 모든 UI 제어 호출에 `pcall` 유지 (엔티티 미로드 시점 보호)
- **중복 엔티티 제거 후 map01.map 슬림화**: 월드 공간에 불필요한 UI 텍스트 엔티티가 없어져 렌더링 부하 감소

---

## 9. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리 정확하게 지정
- [ ] `nil` 체크, `isvalid` 방어 코드 all paths
- [ ] `EnableKeyboardStartFallback = false` 반영
- [ ] fallback 경로들 빈 문자열(`""`) 처리 확인
- [ ] `ForceApplyLobbyNamedEntitiesInCurrentMapClient` - UIRoot 내 탐색으로 전환 or 제거
- [ ] `OnMapEnter` 클라이언트 분기 또는 별도 호출로 UI 즉시 갱신
- [ ] `SpeedrunTimerComponent` 내 `LobbyFlowComponent.IsLobbyActive` 가드 추가
- [ ] GameOver → lobby 복귀 시 UI 정상 전환 확인
- [ ] 완료 후 상태 `🟢 완료`로 변경
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
| **근거** | TD 버그 리뷰 지침서 (implementation_plan.md) |
