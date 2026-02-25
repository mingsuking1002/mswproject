# 🟢 완료

---
**[Codex용 작업 명세서]**

* **Component Name:** `ProjectileComponent` 수정 (타깃 필터링 추가)
* **Execution Space:** `[Server Only]`
* **Properties:**
  - 신규 추가 없음. 기존 `OwnerEntity` 활용.
* **Required MSW Services:**
  - 해당 없음
* **연동 컴포넌트:**
  - `HPSystemComponent`: 피격 대상에서 `ApplyDamage` 호출 유지
  - `FireSystemComponent`: 투사체 스폰 시 `OwnerEntity`에 플레이어 Entity 전달 (기존 동작 유지)

---

## § 핵심 변경 사항

### 문제
`HandleTriggerEnterEvent`와 `IsDamageTargetCandidate`에서 충돌한 엔티티에 `HPSystemComponent`만 있으면 **무조건 데미지** 입힘.
→ 플레이어가 쏜 투사체가 **자기 자신 또는 다른 플레이어 캐릭터**도 피격시킴.

### 해결: `IsMonsterEntity` 판별 함수 추가

```
method boolean IsMonsterEntity(Entity target)
  -- 1) PlayerComponent가 있으면 → 플레이어 → false
  -- 2) MonsterChaseComponent가 있으면 → 몬스터 → true
  -- 3) 둘 다 없으면 → false (안전 기본값)
end
```

### 적용 위치 (2곳)

**① `HandleTriggerEnterEvent` (단일 투사체 충돌)**
- 기존: `HPSystemComponent` 존재 여부만 확인 후 `ApplyDamage`
- 수정: `self:IsMonsterEntity(hitEntity) == false` 이면 `return` (관통, 데미지 안 줌)

**② `IsDamageTargetCandidate` (광역/Area 폭발)**
- 기존: `HPSystemComponent` + 사망 체크만
- 수정: `self:IsMonsterEntity(candidate) == false` 이면 `return false`

---

## § 의사코드

```
-- HandleTriggerEnterEvent 내부, OwnerEntity 필터 직후:
if self:IsMonsterEntity(hitEntity) == false then
    return  -- 플레이어/아군은 무시하고 투사체 관통
end

-- IsDamageTargetCandidate 내부, OwnerEntity 필터 직후:
if self:IsMonsterEntity(candidate) == false then
    return false
end
```

---

* **기획서 참조:** `Data_System_Integration_Report.md`
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - `MonsterChaseComponent` 가 없는 보스 등도 있을 수 있으므로 `HPSystemComponent`에 `IsMonster` 같은 Property가 생기면 그걸 우선 체크하는 방식으로 확장 가능. 현재는 `PlayerComponent` 유무로 판별하는 것이 가장 안전.
