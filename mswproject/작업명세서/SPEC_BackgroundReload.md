# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `ReloadComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

무기 교체 시 재장전이 강제 취소되고 소모된 마나가 복구되지 않는 버그.
→ 무기 교체해도 **이전 무기의 재장전이 백그라운드에서 계속 진행**되도록 변경.

---

## §2. 변경 내용 (1개 파일, 1군데)

### `ReloadComponent.mlua` — `SetCurrentWeaponSlot` 수정

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`

**L274~279 영역의 다음 블록을 완전 삭제:**

```diff
         local prevSlot = self.CurrentWeaponSlot
         self._T.AmmoBySlot[prevSlot] = self.CurrentAmmo

-        -- Previous-slot reload is preserved so weapon swaps do not discard in-flight reload progress.
-        -- Only current-slot sync UI state is cleared while switching active slot context.
-        if prevSlot == self.CurrentWeaponSlot then
-            self.IsReloading = false
-            self:SetCurrentReloadWindowSync(0, 0)
-        end

         local targetMax = self._T.MaxAmmoBySlot[slot]
```

**삭제 이유:**
- `if prevSlot == self.CurrentWeaponSlot`은 L271에서 방금 할당한 값이므로 **항상 true**
- 매 교체 시 `IsReloading`이 무조건 `false`로 초기화 → 재장전 상태 소실
- 이 블록 없이도 L299에서 새 슬롯의 재장전 상태를 정확히 복원함:
  ```lua
  self.IsReloading = self:IsReloadingInSlot(slot)
  ```
- 타이머(`_T.ReloadTimerBySlot[prevSlot]`)는 건드리지 않으므로 `CompleteReload(prevSlot)` 콜백 정상 실행

---

## §3. 이미 적용된 사항 (확인만)

- `WeaponSwapComponent.mlua` L71: `CancelReloadOnSwap = false` ✅

---

## §4. 동작 요약 (수정 후)

```
슬롯1 재장전 시작 (마나 1 소모, 타이머 시작)
   → 무기 교체 → 슬롯2로 전환
   → 슬롯1 타이머 계속 진행 (백그라운드)
   → 타이머 완료 → CompleteReload(1) → AmmoBySlot[1] = MaxAmmo
   → 슬롯1로 다시 교체 시 탄약 가득 찬 상태 복원
```

---

## §5. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `ReloadComponent.mlua`의 `SetCurrentWeaponSlot` 메서드에서 L274~279의 if 블록 전체 삭제
