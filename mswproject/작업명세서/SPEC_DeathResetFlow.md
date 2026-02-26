# 🟢 완료

---

**[Codex용 작업 명세서]**

## 1. 개요

플레이어 사망 시 게임 타이머 정지 + 조작 제한. 스타트 버튼 클릭 시 게임 전체를 초기화하여 처음부터 재시작.

---

## 2. 수정 대상

* **Component:** `HPSystemComponent`, `LobbyFlowComponent`
* **Execution Space:** `[Server Only]` (사망/리셋), `[Client Only]` (UI)

---

## 3. 수정 사항

### 3-1. 사망 시 게임 타이머 정지 + 공격 잠금 — `EvaluateDeath` (HPSystemComponent 399행)

**현재**: `SetCanMoveSafely(false)` + `NotifyGameOver()` 호출
**추가**: `GameTimerComponent` 정지 + `CanAttack = false`

```diff
 method void EvaluateDeath()
     ...
     self.IsDead = true
     self:ClearInvincibleWindowServer()
     self:SetCanMoveSafely(false)

+    -- [NEW] 공격 잠금
+    local fire = self:ResolveComponentSafe(self.Entity, "FireSystemComponent", "CanAttack")
+    if fire ~= nil then
+        fire.CanAttack = false
+    end
+
+    -- [NEW] 게임 타이머 정지
+    local timer = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
+    if timer ~= nil and timer.PauseGame ~= nil then
+        timer:PauseGame()
+    end

     if self.IsMonster == true then
         self:NotifyMonsterDeathSequenceServer()
         return
     end
     self:NotifyGameOver()
 end
```

### 3-2. 게임 전체 초기화 — `HandleRunCompletedServer` (LobbyFlowComponent 212행)

**현재**: 골드/상점/필드아이템 리셋 + `SetLobbyStateServer(true)`
**추가**: HP 리셋, 무기 리셋, 스폰 리셋, 타이머 리셋, 스테이지 ID 리셋

```diff
 method void HandleRunCompletedServer(boolean isClear)
     self:TryClearFieldItemsForOwnerServer()
     self:TryResetGoldForOwnerServer()
     self:TryResetShopForOwnerServer()
+    self:TryResetPlayerHPServer()
+    self:TryResetTimerServer()
+    self:TryResetMonsterSpawnServer()
+    self:TryResetWeaponServer()
     self:SetLobbyStateServer(true)
     self:MoveOwnerToLobbyMapIfNeeded()
 end
```

### 3-3. 신규 리셋 함수 — `LobbyFlowComponent`

```lua
-- HP 복구 + 사망 해제
method void TryResetPlayerHPServer()
    local hp = self:ResolveComponentSafe(self.Entity, "HPSystemComponent", "CurrentHP")
    if hp == nil then return end
    if hp.ReviveToFullHP ~= nil then
        hp:ReviveToFullHP()  -- IsDead=false, CurrentHP=MaxHP, 무적 해제
    end
end

-- 타이머 정지 + ElapsedTime 리셋 + StageId 1로
method void TryResetTimerServer()
    local timer = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
    if timer == nil then return end
    if timer.StopRun ~= nil then
        timer:StopRun()
    end
    timer.ElapsedTime = 0
    timer.CurrentStageId = 1
    timer.IsPaused = false
end

-- 몬스터 전부 제거 + 스폰 상태 리셋
method void TryResetMonsterSpawnServer()
    local spawn = self:ResolveComponentSafe(self.Entity, "MonsterSpawnComponent", "IsSpawnActive")
    if spawn == nil then return end
    if spawn.KillAllMonstersServer ~= nil then
        spawn:KillAllMonstersServer()
    end
    if spawn.StopSpawning ~= nil then
        spawn:StopSpawning()
    end
    spawn.IsBossPhase = false
    -- 스폰 타이머 기준점 초기화 (SPEC_RoundTransition 연동)
    spawn._T.StageStartElapsedTime = 0
    spawn._T.EliteSpawnedSet = {}
end

-- 무기 슬롯 초기 상태 복원
method void TryResetWeaponServer()
    local swap = self:ResolveComponentSafe(self.Entity, "WeaponSwapComponent", "CurrentWeaponSlot")
    if swap == nil then return end
    if swap.ResetToInitialWeaponServer ~= nil then
        swap:ResetToInitialWeaponServer()
    end
end
```

### 3-4. 재시작 시 타이머 + 스폰 재개 — `BeginInGameStateServer` (137행)

**현재 흐름**: `SetLobbyStateServer(false)` → `NotifyRunStartServer()` → `TryStartRunTimerServer()`

이 흐름으로 이미 충분. `SetLobbyStateServer(false)`가 이동/공격 잠금 해제하고, `TryStartRunTimerServer()`가 타이머 시작. 
**추가 필요**: 스폰 재개 호출.

```diff
 method void BeginInGameStateServer(string targetUserId)
     self:SetLobbyStateServer(false)
     self:NotifyRunStartServer()
     self:TryStartRunTimerServer()
+    self:TryResumeMonsterSpawnServer()
     ...
 end

+method void TryResumeMonsterSpawnServer()
+    local spawn = self:ResolveComponentSafe(self.Entity, "MonsterSpawnComponent", "IsSpawnActive")
+    if spawn == nil then return end
+    if spawn.StartSpawning ~= nil then
+        spawn:StartSpawning()
+    end
+end
```

---

## 4. 전체 플로우 정리

```
[사망]
HP <= 0 → EvaluateDeath()
   → IsDead = true
   → CanMove = false
   → CanAttack = false        ← NEW
   → GameTimer:PauseGame()    ← NEW
   → NotifyGameOver()
   → HandleStageFailedServer()
   → HandleRunCompletedServer(false)
      → 골드/상점/아이템/HP/타이머/스폰/무기 전체 리셋  ← NEW
      → SetLobbyStateServer(true) → 로비 상태
      → StartButton 표시

[재시작]
StartButton 클릭 → RequestStartGameServer()
   → BeginInGameStateServer()
      → SetLobbyStateServer(false) → 이동/공격 잠금 해제
      → NotifyRunStartServer() → InfiniteMode 리셋
      → TryStartRunTimerServer() → 타이머 시작
      → TryResumeMonsterSpawnServer()  ← NEW
```

---

## 5. 연동 컴포넌트

| 컴포넌트 | 영향 |
|---|---|
| `HPSystemComponent` | `EvaluateDeath`에 타이머 정지 + 공격 잠금 추가 |
| `LobbyFlowComponent` | `HandleRunCompletedServer`에 리셋 함수 4종 추가, `BeginInGameStateServer`에 스폰 재개 추가 |
| `GameTimerComponent` | `PauseGame()`/`StopRun()` 기존 API 사용 |
| `MonsterSpawnComponent` | `KillAllMonstersServer()`/`StopSpawning()`/`StartSpawning()` 기존 API 사용 |
| `WeaponSwapComponent` | `ResetToInitialWeaponServer()` — 없으면 신규 추가 필요 |

---

## 6. 기획서 참조

* PD 직접 지시 (2026-02-26)

## 7. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

## 8. 주의/최적화 포인트

* **`ReviveToFullHP()` 기존 API 활용**: HPSystem 389행에 이미 구현됨
* **타이머 리셋 순서**: `HandleRunCompletedServer`에서 리셋 → `BeginInGameStateServer`에서 재시작. 순서 보장 필수
* **몬스터 사망 분기**: `EvaluateDeath`에서 `IsMonster == true`일 때는 타이머 정지/공격 잠금 하지 않도록 주의 (기존 분기 유지)

---
