# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `MonsterSpawnComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

2스테이지 보스 처치 후 무한모드 재진입 팝업 대신, **즉시 게임 종료 → 랭킹 등록 → 결과 UI → 로비 복귀** 처리.

---

## §2. 변경 내용 (1파일, 1군데)

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
**L1832~1845** (stage > 1 분기):

```diff
-        local infinite = self:ResolveComponentSafe(self.Entity, "InfiniteModeComponent", "CurrentScore")
-        if infinite ~= nil then
-            if infinite.OnBossKilledServer ~= nil then
-                pcall(function()
-                    infinite:OnBossKilledServer("stage2_boss")
-                end)
-                return
-            end
-            if infinite.ActivateInfiniteModeServer ~= nil then
-                pcall(function()
-                    infinite:ActivateInfiniteModeServer(true)
-                end)
-            end
-        end
+        local infinite = self:ResolveComponentSafe(self.Entity, "InfiniteModeComponent", "CurrentScore")
+        if infinite ~= nil then
+            if infinite.FinalizeNormalClearServer ~= nil then
+                pcall(function()
+                    infinite:FinalizeNormalClearServer()
+                end)
+                return
+            end
+        end
```

### 기존 `FinalizeNormalClearServer` (L249) 동작 (변경 불필요):
1. `SubmitNormalScoreServer()` → `RankingComponent.SubmitNormalRecordServer(score)` 호출 → 랭킹 등록
2. `ShowResultAndReturnLobbyServer("NORMAL MODE CLEAR", score, submitted, false)` → 결과 UI 표시
3. `ResultDelaySeconds`초 후 `FinishRunAndReturnLobbyServer()` → `LobbyFlowComponent.HandleRunCompletedServer()` → 로비 복귀

---

## §3. 결과 플로우

```
2스테이지 보스 처치
  → FinalizeNormalClearServer()
    → SubmitNormalScoreServer() → 랭킹 등록 ✅
    → ShowResultAndReturnLobbyServer("NORMAL MODE CLEAR", score)
      → 결과 패널 표시 (Score / Best / Ranking Submitted)
      → 3초 후 자동 로비 복귀
```

---

## §4. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `MonsterSpawnComponent.mlua` L1832~1845에서 `OnBossKilledServer` 호출을 `FinalizeNormalClearServer` 호출로 교체
