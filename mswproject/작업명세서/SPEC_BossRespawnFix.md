# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `MonsterSpawnComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

보스 처치 후 `IsBossPhase = false` → 스폰 재개 → `ResolveSpawnCandidates`에서 경과시간 ≥ 14분이므로 보스 후보가 다시 선택되어 **재스폰**되는 버그.
→ 스테이지별로 보스를 한 번만 스폰하도록 필터링 추가.

---

## §2. 변경 내용 (1파일, 3군데)

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`

### 2-1. `OnInitialize` — 보스 처치 플래그 초기화 (L49 부근)

```diff
         self._T.BossSpawnedEntity = nil
+        self._T.BossDefeatedByStage = {}
```

### 2-2. `ResolveSpawnCandidates` — 처치 보스 필터링 (L1102)

```diff
             if self:IsBossRow(row) == true then
+                local rowStage = self:GetRowInteger(row, "spawn_stage", 1)
+                if self._T.BossDefeatedByStage[rowStage] == true then
+                    continue
+                end
                 table.insert(result.BossRows, row)
```

### 2-3. 보스 사망 처리 시 플래그 설정

보스 사망 후 `IsBossPhase = false`로 리셋하는 곳(기존 `OnBossDefeatedServer` 또는 `ProcessMonsterDeathSequenceServer`)에서:

```diff
         self.IsBossPhase = false
         self._T.BossSpawnedEntity = nil
+        self._T.BossDefeatedByStage[보스의_stage_id] = true
```

> `BossAIComponent.BossStageId` 또는 `GameTimerComponent.CurrentStageId`에서 stage 값을 읽으면 됨.

---

## §3. 리셋 시점

`KillAllMonstersServer` (L897) / `ActivateInfiniteModeServer` (L642) 에서 이미 `IsBossPhase = false` 리셋 중.
여기에 `BossDefeatedByStage` 초기화도 추가:

```diff
         self._T.BossSpawnedEntity = nil
         self.IsBossPhase = false
+        self._T.BossDefeatedByStage = {}
```

→ 로비 복귀/무한모드 전환 시 보스가 다시 스폰 가능해짐 (정상 동작).

---

## §4. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `OnInitialize`에 `_T.BossDefeatedByStage = {}` 추가
2. `ResolveSpawnCandidates`의 보스 분기에 stage별 필터 추가
3. 보스 사망 처리에서 `BossDefeatedByStage[stageId] = true` 설정
4. `KillAllMonstersServer` / `ActivateInfiniteModeServer`에서 리셋
