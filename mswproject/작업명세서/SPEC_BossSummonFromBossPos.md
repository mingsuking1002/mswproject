# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `BossAIComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

보스 몬스터 소환 위치를 **플레이어 주변 랜덤(반경 8)** → **보스 자체 위치(Entity.TransformComponent.WorldPosition)**로 변경.
소환된 몬스터는 **플레이어를 향해 가속 발사(던지기)**되며, 기존 감속 로직은 그대로 유지.

---

## §2. 변경 파일

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/BossAIComponent.mlua`

---

## §3. 변경 사항

### 3-1. `AttackTickServer` — 소환 위치 변경 (줄 79)

```diff
-        local spawnPos = self:CalcViewportSpawnPosition(playerPos3)
+        local bossPos = self.Entity.TransformComponent.WorldPosition
+        local spawnPos = Vector3(bossPos.x, bossPos.y, bossPos.z)
```

보스 엔티티의 현재 월드 좌표에서 소환.

### 3-2. `CalcViewportSpawnPosition` 삭제 또는 미사용 (줄 167~175)

더 이상 사용하지 않으므로 삭제하거나, 향후 확장용으로 남겨둬도 무방.
```diff
-    method Vector3 CalcViewportSpawnPosition(Vector3 playerPos)
-        local angle = math.random() * 2 * math.pi
-        local radius = 8
-        return Vector3(
-            playerPos.x + (math.cos(angle) * radius),
-            playerPos.y + (math.sin(angle) * radius),
-            playerPos.z
-        )
-    end
```

### 3-3. 가속 로직 — 변경 없음

기존 `SpeedBoostMultiplier = 2.0` 부여 + `CheckSlowdownServer` 감속 로직은 그대로 유지.
소환된 몬스터는 `MonsterChaseComponent`가 플레이어를 추적하므로, 보스 위치에서 소환되면 자연스럽게 플레이어 방향으로 2배속 돌진 = **던지기** 효과.

---

## §4. 동작 요약 (변경 후)

```
보스 위치에서 몬스터 소환
   → MonsterChaseComponent가 플레이어 방향 추적
   → SpeedMultiplier 2.0으로 빠르게 돌진 (던지기)
   → 플레이어 근처(반경 3) 도달 시 1.0으로 감속
```

---

## §5. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `BossAIComponent.mlua` 열기
2. 줄 79: `CalcViewportSpawnPosition` 호출 → 보스 위치로 교체
3. 줄 167~175: `CalcViewportSpawnPosition` 메서드 삭제
