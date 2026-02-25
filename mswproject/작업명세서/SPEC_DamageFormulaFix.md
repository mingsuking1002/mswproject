# 🟢 완료

---
**[Codex용 작업 명세서]**

* **Component Name:** `WeaponLevelUpComponent` (데미지 계산 공식 수정)
* **Execution Space:** `[Server Only]`
* **Properties:**
  - 변경 없음
* **Required MSW Services:**
  - `_DataService`
* **연동 컴포넌트:**
  - `FireSystemComponent` (최종 타겟: `BaseWeaponAttack`)
  - `WeaponSwapComponent`

---

## § 로직 구조 (Logic Architecture)

**기존 문제점:**
`WeaponSwapComponent`가 `WeaponData.csv`에서 `dmg_raito`(무기 데미지 배율)를 적용하여 `FireSystemComponent.BaseWeaponAttack`을 세팅합니다. 하지만 이후 `WeaponLevelUpComponent`가 `ApplyWeaponPowerToFireServer`를 호출할 때, **기존 무기 배율(`dmg_raito`)을 무시하고 오로지 `캐릭터공격력(BasePlayerAtk) * 레벨업배율(LevelMultiplier)` 수식으로만 데미지를 덮어쓰는(Overwrite) 버그**가 있습니다.

**결과 달성 목표 (공식 통합):**
`최종 공격력 = 캐릭터 공격력(BasePlayerAtk) * 무기 배율(dmg_raito) * 레벨업 특성 배율(LevelMultiplier)`

### 1. `ApplyWeaponPowerToFireServer` 핵심 로직 수정

```lua
@ExecSpace("ServerOnly")
method integer ApplyWeaponPowerToFireServer(string weaponId)
    local finalWeaponId = weaponId
    if finalWeaponId == nil or finalWeaponId == "" then
        finalWeaponId = self:ResolveCurrentWeaponIdServer()
    end
    if finalWeaponId == nil or finalWeaponId == "" then return 0 end

    -- 1. 레벨업 데이터 (LevelMultiplier) 가져오기
    local progress = self:EnsureWeaponProgressByIdServer(finalWeaponId)
    if progress == nil then return 0 end
    local levelMultiplier = self:ResolveLevelMultiplierServer(finalWeaponId, progress.Level)
    if levelMultiplier == nil then levelMultiplier = 1.0 end

    -- 2. FireSystem에서 캐릭터 기본 공격력(BasePlayerAtk) 가져오기
    local fire = self:ResolveComponentSafe(self.Entity, "FireSystemComponent", "BaseWeaponAttack")
    if fire == nil then return 0 end
    local basePlayerAtk = 0
    local readAtkOk, readAtkValue = pcall(function() return fire.BasePlayerAtk end)
    if readAtkOk == true and readAtkValue ~= nil then
        basePlayerAtk = math.max(0, math.floor(readAtkValue))
    end

    -- 3. [NEW] WeaponData.csv 에서 원본 dmg_raito (무기 배율) 추출
    local dmgRatio = 1.0
    if self._T.WeaponConfigById ~= nil then
        local config = self._T.WeaponConfigById[finalWeaponId]
        if config ~= nil and config.DamageRatio ~= nil then
            dmgRatio = config.DamageRatio
        end
    else
        -- 로드 안 된 경우 테이블에서 직접 읽어오기
        local weaponRow = self:GetWeaponConfigFileRow(finalWeaponId)
        if weaponRow ~= nil then
            local ratio = self:GetRowNumber(weaponRow, "dmg_raito", -1)
            if ratio <= 0 then
                ratio = self:GetRowNumber(weaponRow, "dmg_ratio", 1.0)
            end
            if ratio > 0 then
                dmgRatio = ratio
            end
        end
    end

    -- 4. [FIX] 세 가지 배율 곱합으로 최종 공격력 산출
    local finalAttack = math.max(0, math.floor(basePlayerAtk * dmgRatio * levelMultiplier))

    -- 5. 적용
    pcall(function()
        fire.BaseWeaponAttack = finalAttack
    end)

    return finalAttack
end
```

### 2. `LoadWeaponConfigRowsServer` 수정 (`dmg_raito` 사전 적재 추가)

`WeaponLevelUpComponent`가 켤 때 `WeaponData.csv`를 읽어서 `WeaponConfigById`에 넣는 과정(`LoadWeaponConfigRowsServer`)이 있습니다.
여기서 추출하는 `config` 구조체에 `DamageRatio` 값을 추가해야 합니다.

```lua
-- LoadWeaponConfigRowsServer 반복문 내부 변경점:
-- 기존 config 추출 (StartLevel, MaxLevel, RequiredExp) 아래에 코드를 추가:

local config = {}
config.StartLevel = startLevel
config.MaxLevel = maxLevel
config.RequiredExp = requiredExp

-- [NEW] dmg_raito 파싱
local dmgRatio = self:GetRowNumber(row, "dmg_raito", -1)
if dmgRatio <= 0 then
    dmgRatio = self:GetRowNumber(row, "dmg_ratio", 1.0)
end
config.DamageRatio = math.max(0, dmgRatio)

cache[id] = config
```

---

* **기획서 참조:** [콘텐츠] v.2.0 무기 콘텐츠 기획-2.md (dmg_raito 연동)
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - `FireSystemComponent.BaseWeaponAttack`이 무기 배율(`dmg_raito`)과 렙업 배율이 곱해진 "최종 순수 무기 데미지"로 저장됨. 이후 실제로 투사체가 쏘일 때는, 이 값에 패시브(PassiveIncreasePercent)와 버프가 더/곱해져 최종 합산됨.
  - 이 명세서가 구현되면 타겟 무기별 고유 공격력(캐논 1.4배, 활 1.0배 등)과 레벨링 스탯이 완벽하게 반영됨.


