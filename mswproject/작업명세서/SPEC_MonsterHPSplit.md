# 🟢 완료

---
**[Codex용 작업 명세서]**

* **Component Name:** `HPSystemComponent` 수정 (몬스터용 무적 판정 분리)
* **Execution Space:** `[Server Only]`
* **Properties:**
  - `(boolean) IsMonster = false` — 신규. `true`이면 몬스터로 간주하여 **피격 시 무적(Invincibility) 윈도우를 적용하지 않음**.
* **Required MSW Services:**
  - 해당 없음
* **연동 컴포넌트:**
  - `MonsterSpawnComponent`: 몬스터 스폰 시 `HPSystemComponent.IsMonster = true` 세팅 필요
  - `ProjectileComponent`: 데미지 전달 방식 변경 없음 (`ApplyDamage` 호출 유지)

---

## § 핵심 변경 사항

### 문제
현재 `ApplyDamage` 에서 `IsInvincible == true` 이면 데미지를 무시함.
피격 후 `StartInvincibleWindow` 로 일정 시간 무적 부여.
→ **몬스터도 동일하게 무적 윈도우가 적용**되어, 다수 투사체 동시 피격 시 1발만 맞고 나머지 무시됨.

### 해결: `IsMonster` 플래그 기반 분기

`ApplyDamage` 함수 내부에서:
```
-- 기존 무적 체크:
if self.IsInvincible == true then return end

-- 수정:
if self.IsMonster == false and self.IsInvincible == true then
    return  -- 플레이어만 무적 판정 적용
end
-- 몬스터는 IsInvincible 무시 → 항상 데미지 수용
```

`StartInvincibleWindow` 호출부에서:
```
-- 기존: ApplyDamage 후 무조건 호출
-- 수정: self.IsMonster == false 일 때만 호출
if self.IsMonster == false then
    self:StartInvincibleWindow()
end
```

---

## § 몬스터 스폰 시 세팅

`MonsterSpawnComponent` 에서 몬스터 엔티티를 생성한 직후:
```
local hpSystem = monsterEntity:GetComponent("HPSystemComponent")
if hpSystem ~= nil then
    hpSystem.IsMonster = true
end
```

---

* **기획서 참조:** `[시스템] 체력(HP) 및 게임오버 시스템.md`
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - 보스도 몬스터이므로 보스 스폰 로직에서도 `IsMonster = true` 세팅 필요.
  - 플레이어 Entity에 `HPSystemComponent`가 붙어있을 때 `IsMonster`의 기본값이 `false`이므로 기존 플레이어 로직에는 영향 없음.
