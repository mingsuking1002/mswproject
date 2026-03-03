# 🟡 대기중

---

**[Codex용 작업 명세서]**

* **Component Name:** 다수 — 키 바인딩 일괄 변경
* **Execution Space:** `[둘 다]` (파일별 상이)

---

## §1. 개요

키 매핑을 아래와 같이 변경한다:

| 기능 | 변경 전 | 변경 후 |
|---|---|---|
| 태그(캐릭터 교체) | `Q` | `Tab` |
| 포션 사용 | `E` | `Q` |
| 상점/무기교체/포탈 | `F` | `E` |

---

## §2. 변경 대상 파일 (총 5개)

### 2-1. `TagManagerComponent.mlua` — Q → Tab
**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
**줄 96:**
```diff
-        if event.key ~= KeyboardKey.Q then
+        if event.key ~= KeyboardKey.Tab then
```

---

### 2-2. `GRInventoryComponent.mlua` — E → Q
**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/GRInventoryComponent.mlua`
**줄 36:**
```diff
-        if event.key ~= KeyboardKey.E then
+        if event.key ~= KeyboardKey.Q then
```

---

### 2-3. `WeaponSwapComponent.mlua` — F → E
**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
**줄 114:**
```diff
-        if key == KeyboardKey.F then
+        if key == KeyboardKey.E then
```

---

### 2-4. `ShopManagerComponent.mlua` — F → E
**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
**줄 1360:**
```diff
-        if key == KeyboardKey.F then
+        if key == KeyboardKey.E then
```

---

### 2-5. `RoundTransitionComponent.mlua` — F → E
**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/RoundTransitionComponent.mlua`
**줄 25:**
```diff
-        if event.key ~= KeyboardKey.F then
+        if event.key ~= KeyboardKey.E then
```

---

## §3. 충돌 해소: RankingUIComponent (Tab 키)

`RankingUIComponent.mlua` 줄 88에서 `KeyboardKey.Tab`을 랭킹 탭 전환에 사용 중.
**해결:** Tab 키 핸들러 제거 (랭킹 탭 전환은 UI 버튼으로만 조작).

**파일:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.mlua`
**줄 82~103 전체 핸들러 삭제:**
```diff
-    -- Optional tab toggle key for quick mode switch while testing ranking layout.
-    @EventSender("Service", "InputService")
-    handler HandleKeyDownEvent(KeyDownEvent event)
-        if event == nil then
-            return
-        end
-        if event.key ~= KeyboardKey.Tab then
-            return
-        end
-
-        local nextTab = 2
-        if self.CurrentTab == 2 then
-            nextTab = 1
-        end
-
-        if self._T.IsLobbyState == true and self._T.IsRankingPanelOpen == true then
-            self:OpenRankingPanelClient(nextTab)
-            return
-        end
-
-        self:SetCurrentTabClient(nextTab)
-    end
```

---

## §4. 변경하지 않는 항목

- `InteractionComponent` (`KeyboardKey.E`) — MSW 네이티브 컴포넌트. 현재 프로젝트에서 직접 사용하지 않으므로 변경 불필요.
- `MovementComponent` (WASD/방향키) — 변경 없음.

---

## §5. 주의사항

- 각 파일의 키 값만 1개씩 변경하는 단순 치환 작업.
- **반드시 Maker Script Editor에서 직접 수정** (코드블록 파일이 아닌 mlua 소스).
- 변경 후 플레이 테스트에서 키 충돌 없음 확인 필요.

---

## §6. 기획서 참조

- PD 직접 지시 (2026-03-03)

---

## §7. 구현 방식

**MCP + Maker 직접 작업:**
1. 위 5개 파일의 지정된 줄에서 KeyboardKey 값을 각각 변경
2. RankingUIComponent의 HandleKeyDownEvent 핸들러 전체 삭제
3. 변경 후 테스트 플레이로 확인:
   - Tab → 태그 교체 작동
   - Q → 포션 사용 작동
   - E → 상점/무기교체/포탈 작동
