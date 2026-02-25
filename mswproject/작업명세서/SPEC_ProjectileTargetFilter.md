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

---

## § 완료 결과

- `ProjectileComponent`의 몬스터 타깃 필터(`IsMonsterEntity`)가 단일/광역 경로 모두 적용된 상태를 재검증함.
- `HPSystemComponent.ResolveIncomingDamage`에 투사체 수신 방어(`ShouldIgnoreProjectileDamage`)를 추가해 플레이어 피격 경로를 이중 차단함.
- 최종 정책: 플레이어는 `monster` 소유로 식별된 투사체만 피해 허용, 그 외(`player/unknown`) 소유 투사체 피해는 무시.

---

## § 2026-02-25 추가 보완 (타일 충돌/데미지 누락)

- 상태 전이: `🟡 분석` -> `🔵 구현` -> `🟢 완료`

### 보완 내용

1. `ProjectileComponent`
- `ConfigureProjectilePhysicsServer()` 추가: `PhysicsRigidbody`를 `BodyType.Dynamic`, `CollisionDetectionMode.Continuous`로 설정하고 접촉 이벤트를 강제 활성화.
- `OnUpdate` 물리 이동 경로를 `SetLinearVelocity` 우선으로 변경해 고속 화살의 타일 관통/정지 이슈를 완화.
- `HandlePhysicsContactBeginEvent`에서 `ContactedBodyEntity=nil` 케이스를 환경 충돌로 간주해 즉시 소멸/폭발 처리.
- `ResolveMonsterDamageTargetEntity()` 추가: 충돌한 자식 콜라이더에서 부모 체인으로 올라가 몬스터 `HPSystem`을 해석해 데미지 누락 방지.
- `IsSameOrChildOfEntity()` 추가: 발사자 본체/자식 콜라이더와의 초기 겹침 오탐을 차단.

2. `FireSystemComponent`, `TurretAIComponent`
- 투사체 스폰 직후 `PhysicsRigidbody` 설정을 `Dynamic + Continuous + NeverSleep`으로 통일.
- 서버 물리 권한(`SetServerAsPhysicsOwner`)을 부여해 접촉 이벤트 발생 주체를 일관화.

### 검증 기준

- 화살(arrow) 투사체가 지형/타일 충돌 시 관통하지 않고 즉시 소멸한다.
- 몬스터 히트박스가 자식 엔티티여도 부모 `HPSystem`으로 데미지가 반영된다.
- 플레이어는 기존 정책대로 플레이어 소유 투사체에 피격되지 않는다.
