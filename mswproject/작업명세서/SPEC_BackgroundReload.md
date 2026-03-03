# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `ReloadComponent` (기존 수정) + `WeaponSwapComponent` (설정 변경)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

현재 무기 교체 시 재장전이 **강제 취소**되고 소모된 마나도 복구되지 않는 문제.
→ 무기 교체해도 **이전 무기의 재장전이 백그라운드에서 계속 진행**되도록 변경.

---

## §2. 변경 파일 및 내용

### 2-1. `ReloadComponent.mlua` — `SetCurrentWeaponSlot` 수정

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
**줄 274:**

```diff
         local prevSlot = self.CurrentWeaponSlot
         self._T.AmmoBySlot[prevSlot] = self.CurrentAmmo

-        self:CancelReloadForSlot(prevSlot)
+        -- 이전 슬롯 재장전 취소하지 않음 (백그라운드 재장전 유지)
+        -- Sync 상태만 해제 (HUD 표시용)
+        if prevSlot == self.CurrentWeaponSlot then
+            self.IsReloading = false
+            self:SetCurrentReloadWindowSync(0, 0)
+        end
```

즉 `CancelReloadForSlot(prevSlot)` 한 줄을 삭제하면 됨.
`_T.ReloadTimerBySlot[prevSlot]`의 타이머가 살아있어서 `CompleteReload(prevSlot)`가 자동 호출됨.

> **이미 L294에서** 새 슬롯으로 전환 시 해당 슬롯의 재장전 상태를 복원하는 코드가 구현되어 있음:
> ```lua
> self.IsReloading = self:IsReloadingInSlot(slot)
> ```

---

### 2-2. `WeaponSwapComponent.mlua` — `CancelReloadOnSwap` 비활성화

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
**줄 71:**

```diff
-    property boolean CancelReloadOnSwap = true
+    property boolean CancelReloadOnSwap = false
```

이 값이 `false`면 `TagManagerComponent.ApplyCharacterState`에서도 재장전 취소를 건너뜀 (L474 분기).

---

## §3. 변경하지 않는 부분

- `CompleteReload(slot)` — 이미 슬롯 독립적으로 동작. 현재 슬롯이 아닌 경우에도 `_T.AmmoBySlot[slot]`에 탄약 충전됨 (L224). Sync Property(`CurrentAmmo`)는 현재 활성 슬롯일 때만 갱신 (L226-231). **변경 불필요.**
- `CancelReloadForSlot` / `CancelCurrentReload` — 메서드 자체는 유지 (태그 교체 등 다른 시스템에서 필요 시 호출)

---

## §4. 동작 요약 (변경 후)

```
슬롯1 재장전 시작 (마나 1 소모, 타이머 시작)
   → 무기 교체 → 슬롯2로 전환
   → 슬롯1 타이머는 계속 진행 (백그라운드)
   → 타이머 완료 → CompleteReload(1) → _T.AmmoBySlot[1] = MaxAmmo
   → 슬롯1로 다시 교체하면 탄약 가득 찬 상태로 복원
```

---

## §5. 주의사항

- 마나 소모 시점은 **재장전 시작 시 1회**이므로, 백그라운드 완료 시 추가 소모 없음.
- 태그(캐릭터 교체) 시에는 별도로 `CancelReloadOnSwap` 플래그를 참조하므로 태그에도 동일 적용됨.

---

## §6. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `ReloadComponent.mlua` L274: `self:CancelReloadForSlot(prevSlot)` 삭제
2. `WeaponSwapComponent.mlua` L71: `CancelReloadOnSwap = false`로 변경
