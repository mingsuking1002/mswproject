# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `WeaponSwapComponent` (기존 수정)
* **Execution Space:** `[Server Only]`

---

## §1. 개요

백그라운드 재장전 타이머는 유지되지만, 다시 해당 슬롯으로 교체할 때 `ApplySlotDataToCombat`의 `SetSlotAmmo`가 **캡처 시점의 0탄**으로 덮어써서 재장전 결과가 소실됨.

---

## §2. 원인

```
1. 슬롯1 재장전 중 (Ammo=0) → 무기 교체
2. CaptureRuntimeToSlot(1) → data.Ammo = 0 캡처
3. 백그라운드: CompleteReload(1) → AmmoBySlot[1] = MaxAmmo ✅
4. 다시 슬롯1로 교체
5. ApplySlotDataToCombat(1)
   → SetSlotAmmo(1, data.Ammo=0) → AmmoBySlot[1] = 0 ← 💥 덮어쓰기
```

---

## §3. 수정 내용 (1파일, 1군데)

**파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
**`ApplySlotDataToCombat` 메서드 내 `SetSlotAmmo` 호출 (L1221~1223):**

```diff
-            pcall(function()
-                reloadComponent:SetSlotAmmo(finalSlot, data.Ammo)
-            end)
+            pcall(function()
+                local liveAmmo = nil
+                if reloadComponent._T ~= nil and reloadComponent._T.AmmoBySlot ~= nil then
+                    liveAmmo = reloadComponent._T.AmmoBySlot[finalSlot]
+                end
+                if liveAmmo ~= nil and liveAmmo > data.Ammo then
+                    reloadComponent:SetSlotAmmo(finalSlot, liveAmmo)
+                else
+                    reloadComponent:SetSlotAmmo(finalSlot, data.Ammo)
+                end
+            end)
```

**로직:** `ReloadComponent._T.AmmoBySlot[slot]`(CompleteReload이 갱신한 최신값)이 `data.Ammo`(캡처 시점의 값)보다 크면 최신값 사용. 
→ 재장전 완료 후 돌아오면 가득 찬 탄약 유지 ✅
→ 재장전 미완료 시 기존 캡처값(0) 그대로 사용 ✅

---

## §4. 구현 방식

**Maker Script Editor에서 직접 수정:**
1. `WeaponSwapComponent.mlua`의 `ApplySlotDataToCombat` 메서드에서 `SetSlotAmmo` 호출부 수정
