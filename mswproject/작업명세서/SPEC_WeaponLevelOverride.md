# 🟡 대기중

---

**[Codex용 작업 명세서]**

## § 1 개요

WeaponData(베이스 스펙)는 건드리지 않고, **WeaponLevelOverrideData** 테이블로 레벨별 변경분만 덮어쓴다.
레벨업 시 유효 스탯을 재계산하고 **전투 컴포넌트를 원자적으로 재주입**한다.

---

## § 2 신규 DataTable — `WeaponLevelOverrideData`

### 2-1. 파일

| 항목 | 값 |
|------|-----|
| 경로 | `RootDesk/MyDesk/ProjectGR/Data/WeaponLevelOverrideData.csv` |
| Maker UserDataSet | `WeaponLevelOverrideData.userdataset` (Maker에서 생성) |

### 2-2. 컬럼 정의

| 컬럼명 | 자료형 | 설명 |
|--------|--------|------|
| `id` | STRING | 행 고유 키 (예: `bow_2`) |
| `weapon_id` | STRING | WeaponData의 id (예: `bow`) |
| `level` | INT | 이 행이 적용되는 레벨 |
| `enabled` | INT | 1=활성, 0=비활성 |
| `fire_rate` | FLOAT | 오버라이드 발사 딜레이 (빈 값=베이스 유지) |
| `reload_time` | FLOAT | 오버라이드 장전 시간 |
| `max_basic_resource` | INT | 오버라이드 최대 탄약 |
| `dmg_raito` | FLOAT | 오버라이드 데미지 비율 |
| `projectile_id` | STRING | 오버라이드 투사체 ID |
| `summon_id` | STRING | 오버라이드 소환체 ID |

> **적용 규칙**: 값이 빈 문자열 / `-` / `null` / `nil` → 해당 컬럼은 베이스 유지.
> **유니크 키**: (weapon_id, level) 조합당 1개 row만 허용. 로드 시 중복 발견 → log_warning 후 첫 번째 row 사용.

### 2-3. 예시 데이터 (2행)

```
id,weapon_id,level,enabled,fire_rate,reload_time,max_basic_resource,dmg_raito,projectile_id,summon_id
bow_2,bow,2,1,0.35,,,,,
bow_5,bow,5,1,0.3,2.5,90,,,
```

---

## § 3 수정 대상 컴포넌트

### 3-1. `WeaponLevelUpComponent.mlua` — 오버라이드 로더 & 머지

* **Component Name:** `WeaponLevelUpComponent` (기존 파일 수정)
* **Execution Space:** `[Server Only]`

#### Properties 추가

```
property string WeaponLevelOverrideTableName = "WeaponLevelOverrideData"
```

#### 캐시 (`_T`)

```
self._T.OverrideByWeaponLevel = {}   -- key: "weapon_id|level" → row data table
self._T.IsOverrideLoaded = false
```

#### 신규 메서드

1. **`LoadWeaponLevelOverrideRowsServer()`** `[ServerOnly]`
   - `_DataService:GetTable(self.WeaponLevelOverrideTableName)` → `GetAllRow()`
   - 각 row에서 `weapon_id`, `level`, `enabled` 읽기.
   - `enabled ~= 1` → skip.
   - 캐시 키 = `weapon_id .. "|" .. tostring(level)`.
   - 중복 키 → `log_warning` 후 skip.
   - row의 오버라이드 컬럼들을 table로 저장.

2. **`GetOverrideForWeaponLevel(string weaponId, integer level)`** → `table or nil`
   - 캐시에서 `weaponId .. "|" .. tostring(level)` 조회.
   - 없으면 `nil` 반환.

3. **`MergeOverrideIntoSlotData(table slotData, string weaponId, integer level)`** `[ServerOnly]`
   - override = `self:GetOverrideForWeaponLevel(weaponId, level)`.
   - override == nil → return (베이스 유지).
   - 오버라이드 컬럼 매핑:

   | override 컬럼 | slotData 필드 | 파싱 |
   |--------------|--------------|------|
   | `fire_rate` | `.FireCooldown` | `tonumber`, > 0 |
   | `reload_time` | `.ReloadTime` | `tonumber`, > 0 |
   | `max_basic_resource` | `.MaxAmmo` | `math.floor(tonumber)`, > 0 |
   | `dmg_raito` | `.DamageRatioOverride` (신규 필드) | `tonumber`, > 0 |
   | `projectile_id` | `.ProjectileId` | string, ~= "" |
   | `summon_id` | `.SummonId` | string, ~= "" |

   - `projectile_id`/`summon_id`가 변경되면 → `slotData.NeedsProjectileRequery = true` 플래그 설정.
   - `DamageRatioOverride`가 설정되면 → 이 값이 WeaponData의 `dmg_raito`를 대체.

#### 기존 메서드 수정

4. **`AddWeaponExpServer`** (L94 레벨업 후 블록)
   - 기존: `self:ApplyWeaponPowerToFireServer(weaponId)` + `self:RefreshCurrentWeaponProgressSyncServer(weaponId)`
   - **추가**: 레벨업(`didLevelUp == true`)이고 현재 장착 무기이면 → `self:RequestReapplyCurrentWeaponServer(weaponId, progress.Level)` 호출.

5. **`ApplyWeaponPowerToFireServer`** (L118)
   - 기존 `damageRatio` 계산 후, 오버라이드가 있으면 `DamageRatioOverride`로 교체.
   - 오버라이드 로드 확인: `if self._T.IsOverrideLoaded ~= true then self:LoadWeaponLevelOverrideRowsServer() end`
   - override의 `dmg_raito`가 유효하면 → `damageRatio = overrideDmgRatio`.

6. **`InitializeWeaponProgressServer`** (L50)
   - 오버라이드 테이블 선행 로드 추가: `if self._T.IsOverrideLoaded ~= true then self:LoadWeaponLevelOverrideRowsServer() end`

---

### 3-2. `WeaponSwapComponent.mlua` — 재주입 메서드

* **Component Name:** `WeaponSwapComponent` (기존 파일 수정)
* **Execution Space:** `[Server Only]`

#### 신규 메서드

1. **`ReapplyCurrentWeaponByLevelServer(string weaponId, integer level)`** `[ServerOnly]`

   **핵심 로직 (의사코드):**
   ```
   finalSlot = self.CurrentWeaponSlot
   data = self:GetSlotDataBySlot(finalSlot)
   data = self:NormalizeSlotData(data, finalSlot)

   -- 1) 런타임 상태 스냅샷 (보존 대상)
   savedAmmo = data.Ammo
   savedIsReloading = data.IsReloading
   -- ReloadComponent에서 현재 장전 진행률도 보존
   reloadComp = resolve ReloadComponent
   savedReloadTimerId = reloadComp._T.ReloadTimerBySlot[finalSlot]
   savedReloadEndTime = reloadComp._T.ReloadEndTimeBySlot[finalSlot]

   -- 2) 베이스 재적용
   self:ApplyWeaponRowToSlotDataServer(data, weaponId)

   -- 3) 오버라이드 머지
   weaponLevel = resolve WeaponLevelUpComponent
   if weaponLevel ~= nil then
       weaponLevel:MergeOverrideIntoSlotData(data, weaponId, level)
   end

   -- 4) 파생 재조회 (projectile_id/summon_id 변경 시)
   if data.NeedsProjectileRequery == true then
       ProjectileData/SummonData 재조회 (기존 ApplyWeaponRowToSlotDataServer L490-600 로직 재사용)
   end

   -- 5) 탄약 클램프 (MaxAmmo가 변경되었을 수 있음)
   if data.MaxAmmo changed then
       data.Ammo = math.min(savedAmmo, data.MaxAmmo)
   else
       data.Ammo = savedAmmo
   end

   -- 6) slotData 저장
   self:SetSlotDataBySlot(finalSlot, data)

   -- 7) 전투 컴포넌트 재주입 (ApplySlotDataToCombat 재사용)
   --    단, 장전 상태는 덮지 않음
   self:ApplySlotDataToCombatPreservingReload(finalSlot, savedIsReloading, savedReloadTimerId, savedReloadEndTime)
   ```

2. **`ApplySlotDataToCombatPreservingReload(integer slot, boolean wasReloading, any savedTimerId, number savedEndTime)`** `[ServerOnly]`

   기존 `ApplySlotDataToCombat` (L894) 와 동일하되:
   - ReloadComponent에 MaxAmmo/Ammo 주입 시 **장전 진행 타이머를 취소하지 않음** (CancelReloadOnSwap 무시).
   - `wasReloading == true` 이고 savedTimerId가 유효하면 → 장전 상태 복원 (`IsReloading = true`, ReloadEndTime 유지).
   - FireCooldown이 변경되면 → `fireComponent.FireCooldown = data.FireCooldown` 반영, 하지만 진행 중인 쿨다운 타이머는 중단하지 않음.
   - WeaponModel 갱신은 생략 (같은 무기이므로 모델 불변).

   > **대안**: `ApplySlotDataToCombat`에 `boolean preserveReload` 파라미터를 추가하여 분기 처리도 가능. Codex 재량.

---

## § 4 레벨업 → 재주입 트리거 연결

### 4-1. `WeaponLevelUpComponent.AddWeaponExpServer` (L109 블록 확장)

```
-- 기존 코드 (L109-113):
local currentWeaponId = self:ResolveCurrentWeaponIdServer()
if currentWeaponId == weaponId then
    self:ApplyWeaponPowerToFireServer(weaponId)
    self:RefreshCurrentWeaponProgressSyncServer(weaponId)
end

-- ▼ 추가: 레벨업 시 full 재주입
if didLevelUp == true and currentWeaponId == weaponId then
    local swap = self:ResolveComponentSafe(self.Entity, "WeaponSwapComponent", "CurrentWeaponSlot")
    if swap ~= nil and swap.ReapplyCurrentWeaponByLevelServer ~= nil then
        pcall(function()
            swap:ReapplyCurrentWeaponByLevelServer(weaponId, progress.Level)
        end)
    end
end
```

> `ApplyWeaponPowerToFireServer`는 기존대로 매 발사마다 dmg 재계산에 사용.
> `ReapplyCurrentWeaponByLevelServer`는 **레벨업 시에만** fire_rate/reload_time/max_ammo 등 비-dmg 스탯까지 원자적으로 재주입.

---

## § 5 주의 / 최적화 포인트

| 항목 | 대책 |
|------|------|
| OnUpdate 사용 금지 | 모든 재주입은 이벤트(레벨업) 트리거. OnUpdate 무관. |
| 장전 중 레벨업 | ReloadTimer를 건드리지 않음. MaxAmmo만 갱신, 장전 완료 시 새 MaxAmmo로 채워짐. |
| 쿨다운 중 레벨업 | FireCooldown 값만 교체. 진행 중 타이머는 자연 만료. 다음 발사부터 새 쿨다운 적용. |
| 탄약 클램프 | 새 MaxAmmo < 현재 Ammo → `Ammo = MaxAmmo` 로 클램프. 반대는 그대로 유지. |
| 오버라이드 미존재 레벨 | override == nil → 베이스 유지. 에러 아님. |
| 방어 코드 일괄 | nil/isValid 체크, pcall 감싸기, GetRowString fallback 패턴 기존과 동일 적용. |

---

## § 6 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|----------|----------|
| `WeaponSwapComponent` | `ReapplyCurrentWeaponByLevelServer()` 신규 메서드 호출 대상 |
| `WeaponLevelUpComponent` | 오버라이드 로더/머지 추가, 레벨업 트리거 발신 |
| `FireSystemComponent` | `BaseWeaponAttack`, `FireCooldown` 등 재주입 대상 (읽기/쓰기) |
| `ReloadComponent` | `MaxAmmo`, `ReloadTime`, `FireRate` 재주입 대상 + 장전 상태 보존 |
| `WeaponModelComponent` | 레벨업 재주입 시에는 갱신 생략 (동일 무기) |

---

## § 7 기획서 참조

- `기획서/1.핵심 시스템/[시스템] 무기 레벨업 시스템 V 1.0.md` §3: "레벨업 시 공격력, 타격 범위, 공격 속도, 재장전 시간 상승"
- `기획서/1.핵심 시스템/[시스템] 무기 교체 (Weapon Swap).md`

## § 8 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야 하는 방식.

**구현 순서:**
1. `WeaponLevelOverrideData.csv` + `.userdataset` 생성 (Maker에서 DataSet 등록)
2. `WeaponLevelUpComponent.mlua` 수정 (오버라이드 로더/머지/트리거 추가)
3. `WeaponSwapComponent.mlua` 수정 (재주입 메서드 추가)
4. 테스트: 무기 레벨업 후 `fire_rate`/`reload_time` 등 변경 확인

---
