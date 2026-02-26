# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

smite 무기 타입의 공격 좌표 결정 방식을 무기별로 분리한다.
- **궁니르**: 마우스 커서 위치에 이펙트 → 해당 위치 단일 타격 (기존 유지)
- **데스페라도**: 마우스 어디를 클릭하든 **플레이어 현재 좌표**에 이펙트 → 해당 위치 타격

---

## 2. 수정 대상

* **Component:** `FireSystemComponent`
* **파일:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
* **Execution Space:** `[Server Only]`
* **수정 메서드:** `SmiteAttackServer` (532행)

---

## 3. 수정 사항

### `SmiteAttackServer` 수정 — 무기ID별 타격 좌표 분기

**변경 전** (532행):
```lua
method boolean SmiteAttackServer(Vector2 targetWorldPosition)
    local didSpawnVisual = self:SpawnSmiteVisualServer(targetWorldPosition)
    ...
```

**변경 후**:
```lua
method boolean SmiteAttackServer(Vector2 targetWorldPosition)
    -- [NEW] 무기별 타격 좌표 결정
    local smitePosition = self:ResolveSmiteTargetPosition(targetWorldPosition)

    local didSpawnVisual = self:SpawnSmiteVisualServer(smitePosition)
    local damage = self:CalculateFinalDamage()
    if damage <= 0 then
        return didSpawnVisual
    end

    local radiusSnapshot = math.max(self.SplashSize, 0)
    local delaySnapshot = math.max(self.SmiteDamageDelay, 0)
    if delaySnapshot > 0 then
        self:ScheduleSmiteDamageServer(smitePosition, damage, radiusSnapshot, delaySnapshot)
        return true
    end

    local didDamage = self:ApplySmiteDamageAtPositionServer(smitePosition, radiusSnapshot, damage)
    if didDamage == true then
        return true
    end
    return didSpawnVisual
end
```

### `ResolveSmiteTargetPosition` 신규

```lua
method Vector2 ResolveSmiteTargetPosition(Vector2 targetWorldPosition)
    local weaponId = tostring(self.CurrentWeaponId)

    -- WeaponData 참조: smite_target_mode 컬럼 또는 ID 직접 판별
    if self:IsPlayerPositionSmite(weaponId) == true then
        local playerPos = self.Entity.TransformComponent.WorldPosition
        if playerPos ~= nil then
            return Vector2(playerPos.x, playerPos.y)
        end
    end

    -- 궁니르 및 기타: 마우스 커서 위치 그대로
    return targetWorldPosition
end

method boolean IsPlayerPositionSmite(string weaponId)
    -- WeaponData에서 smite_target_mode 읽기
    -- "self" → 플레이어 좌표 (deathperado)
    -- "cursor" 또는 미지정 → 마우스 커서 (기본)
    local mode = self:GetSmiteTargetModeFromWeaponData(weaponId)
    return mode == "self"
end

method string GetSmiteTargetModeFromWeaponData(string weaponId)
    if weaponId == nil or weaponId == "" then return "cursor" end
    -- WeaponData 테이블에서 smite_target_mode 컬럼 조회
    -- 캐시된 WeaponSwapComponent.SlotData 또는 _DataService:GetTable("WeaponData") 사용
    -- 미지정 시 기본값 "cursor" 반환
    return "cursor"  -- Codex가 실제 DataService 조회 로직 구현
end
```

---

## 4. DataTable 연동

`WeaponData` 테이블에 smite 좌표 모드 컬럼 추가:

| 컬럼 | 값 | 설명 | 적용 무기 |
|---|---|---|---|
| `smite_target_mode` | `"cursor"` | 마우스 커서 위치 (기본값) | 궁니르 |
| `smite_target_mode` | `"self"` | 플레이어 현재 좌표 | deathperado |

---

## 5. 연동 컴포넌트

| 컴포넌트 | 영향 |
|---|---|
| `WeaponSwapComponent` | 변경 없음 (SmiteDamageDelay/SmiteVisualLifetime 캡처 기존 유지) |
| `TurretAIComponent` | 변경 없음 (터렛의 smite는 자체 `ApplySmiteDamageServer` 사용) |

---

## 6. 기획서 참조

* PD 직접 지시 (2026-02-26)

## 7. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

## 8. 주의/최적화 포인트

* **기존 로직 보존**: `targetWorldPosition`을 `smitePosition`으로 치환만 하고, 나머지 데미지/비주얼 플로우는 완전 유지
* **WeaponData 참조 필수**: `smite_target_mode` 컬럼으로 판별. ID 하드코딩 금지
* **deathperado**: `smite_target_mode = "self"` → 플레이어 좌표
* **궁니르 단일 타격 유지**: `SplashSize == 0` → `FindNearestDamageTargetServer` → 1마리만 (기존 그대로)

---
