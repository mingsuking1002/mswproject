# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `MonsterSpawnComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

1스테이지 보스 처치 후 **포탈 생성 + E키 상호작용** 과정을 제거.
보스 처치 → 보상 상점 → 상점 닫힘 → **즉시 2스테이지 전환** (타이머 초기화 포함).

---

## §2. 변경 내용 (1파일, 1군데)

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
**L1823~1828:**

```diff
-            local transition = self:ResolveComponentSafe(self.Entity, "RoundTransitionComponent", "PortalInteractRadius")
-            if transition ~= nil and transition.SpawnPortalAtPositionServer ~= nil and deathPos ~= nil then
-                pcall(function()
-                    transition:SpawnPortalAtPositionServer(deathPos)
-                end)
-            end
+            local transition = self:ResolveComponentSafe(self.Entity, "RoundTransitionComponent", "PortalInteractRadius")
+            if transition ~= nil and transition.ExecuteStageTransitionServer ~= nil then
+                pcall(function()
+                    transition:ExecuteStageTransitionServer()
+                end)
+            end
```

포탈 생성 대신 `ExecuteStageTransitionServer()`를 직접 호출.
이 메서드가 이미 다음을 처리함:
- 몬스터 전부 제거 (`KillAllMonstersServer`)
- 로딩 UI 표시 → `FakeLoadingDuration`초 대기
- `CurrentStageId = 2` 설정
- 스폰 재개 (`RefreshSpawnStateServer`)
- 포탈 정리 (`ClearPortalServer` — 포탈이 없으면 자동 스킵)
- 로딩 UI 해제

---

## §3. 상점과의 순서

현재 코드에서 상점 오픈(L1812)이 포탈 생성(L1824)보다 먼저 호출됨.
변경 후에도 **상점이 먼저 열리고**, 상점이 닫힌 후 전환이 실행되어야 자연스러움.

**현재 코드에서는 상점과 전환이 동시에 실행됨.** 상점 닫힘과 동기화하려면 `ShopManagerComponent`의 상점 닫힘 콜백에서 전환을 호출해야 하나, **현재 그런 구조가 아님**.

→ **단순 해결:** 상점 오픈 제거하고 바로 전환 실행. 또는 상점은 유지하되, 상점 안에서 전환 함수를 호출하도록 연동.

> **PD 판단 필요:** 보스 처치 후 보상 상점을 유지할지, 상점 없이 바로 2스테이지로 넘길지?

---

## §4. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `MonsterSpawnComponent.mlua` L1823~1828에서 `SpawnPortalAtPositionServer` → `ExecuteStageTransitionServer`로 변경
