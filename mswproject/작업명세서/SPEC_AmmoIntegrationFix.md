# 🟢 완료

---
**[Codex용 작업 명세서]**

* **Component Name:** `ReloadComponent` 및 `WeaponSwapComponent` (탄약 연동 버그 픽스)
* **Execution Space:** `[Server Only]` 및 `[둘 다]`
* **Properties:**
  - `ReloadComponent`: 단일 `MaxAmmo` 프로퍼티 유지 (현재 무기 UI 용도)
* **Required MSW Services:**
  - 해당 없음
* **연동 컴포넌트:**
  - `WeaponSwapComponent` → `ReloadComponent`

---

## § 핵심 문제 파악 (버그 내용)

이전 감사(Audit)에서 놓쳤던 치명적인 버그가 있습니다.
`WeaponSwapComponent`가 `WeaponData.csv`에서 `max_basic_resource`를 읽어오지만, 이를 `ReloadComponent`의 **최대 장탄수(`MaxAmmo`)로 넘겨주지 않고 있습니다.**
결과적으로 `ReloadComponent`의 기본 프로퍼티인 `MaxAmmo = 30`으로 고정되어, **활(70발) 등 모든 무기가 30발로 강제 클램핑(Clamping)** 되고, 재장전 시에도 30발까지만 채워지는 문제가 발생합니다.

더 나아가, 백그라운드 재장전(교체된 상태에서 뒤에서 장전 완료)을 지원하려면 `ReloadComponent` 내부에서 **슬롯별 최대 장탄수**를 별도로 기억해야 합니다.

---

## § 해결 방법 (수정 지시)

### 1. `ReloadComponent` 수정 (슬롯별 MaxAmmo 지원)

**`OnInitialize` 내부:**
```lua
-- _T.AmmoBySlot 아래에 MaxAmmoBySlot 테이블 추가
self._T.MaxAmmoBySlot = {}

for slot = 1, slotCount do
    -- 기존: self._T.AmmoBySlot[slot] = self.MaxAmmo
    self._T.MaxAmmoBySlot[slot] = self.MaxAmmo  -- 기본값 할당
    self._T.AmmoBySlot[slot] = self.MaxAmmo
    -- ...
end
```

**새로운 API 추가 (`SetSlotMaxAmmo`):**
```lua
@ExecSpace("ServerOnly")
method void SetSlotMaxAmmo(integer slot, integer maxAmmo)
    if self:IsValidSlot(slot) == false then return end
    local finalMax = math.max(1, maxAmmo)
    self._T.MaxAmmoBySlot[slot] = finalMax
    
    if slot == self.CurrentWeaponSlot then
        self.MaxAmmo = finalMax
    end
end
```

**기존 메서드 보정:**
- `SetSlotAmmo`:
  ```lua
  local currentMax = self._T.MaxAmmoBySlot[slot] or self.MaxAmmo
  local clampedAmmo = math.max(0, math.min(ammo, currentMax))
  ```
- `CompleteReload`:
  ```lua
  local currentMax = self._T.MaxAmmoBySlot[slot] or self.MaxAmmo
  self._T.AmmoBySlot[slot] = currentMax
  if slot == self.CurrentWeaponSlot then
      self.CurrentAmmo = currentMax
      self.IsReloading = false
  end
  ```
- `SetCurrentWeaponSlot`:
  ```lua
  -- 타겟 슬롯으로 넘어갈 때 MaxAmmo도 갱신해주기
  local targetMax = self._T.MaxAmmoBySlot[targetSlot] or self.MaxAmmo
  self.MaxAmmo = targetMax
  ```

---

### 2. `WeaponSwapComponent` 수정 (MaxAmmo 캡처 및 전달)

**`NormalizeSlotData` 수정:**
```lua
-- 기존에는 data.Ammo 에 덮어쓰기만 했음. data.MaxAmmo 보존 추가
if data.MaxAmmo == nil then 
    data.MaxAmmo = self.DefaultMaxAmmo or 30 
end

local maxAmmoCsv = self:GetRowInteger(row, "max_basic_resource", data.MaxAmmo)
if maxAmmoCsv > 0 then
    data.MaxAmmo = maxAmmoCsv
    -- 단, 처음 초기화 시 잔탄(data.Ammo)이 세팅되지 않았다면 꽉 채움
    if data.Ammo == nil then
        data.Ammo = maxAmmoCsv
    end
end
```

**`CaptureRuntimeToSlot` 수정:**
```lua
-- reloadComponent 에서 MaxAmmo 도 가져와서 캐싱
local maxOk, maxResult = pcall(function()
    return reloadComponent._T.MaxAmmoBySlot[finalSlot]
end)
if maxOk == true and maxResult ~= nil then
    data.MaxAmmo = maxResult
end
```

**`ApplySlotDataToCombat` 수정:**
`ReloadTime`, `FireRate` 세팅하는 아래 부분에 `SetSlotMaxAmmo` 호출 추가:
```lua
pcall(function()
    reloadComponent:SetSlotMaxAmmo(finalSlot, data.MaxAmmo)
end)
```

---

* **기획서 참조:** [시스템] 무기 교체 (Weapon Swap).md / WeaponData.csv
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - 기존에는 단순히 무기별 "현재 총알(Ammo)"만 슬롯에 저장했습니다. 이 버그를 잡기 위해 슬롯 데이터 구조에 `MaxAmmo`를 명시적으로 추가하고 동기화하는 것입니다.


