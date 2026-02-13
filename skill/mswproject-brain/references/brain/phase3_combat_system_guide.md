# Phase 3: Combat System Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 3개  
> **카테고리**: Combat System (Attack/Hit/Damage)

---

## 📊 Phase 3 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **AttackComponent** | 0 | 10 | 1 | 공격 시스템 |
| **HitComponent** | 9 | 2 | 1 | 피격 시스템 |
| **DamageSkinComponent** | 0 | 0 | 0 | 대미지 스킨 표시 |
| **총계** | **9** | **12** | **2** | - |

---

## ⚔️ Combat System 개요

MapleStory Worlds의 전투 시스템은 **AttackComponent**와 **HitComponent**의 상호작용으로 구현됩니다.

### 핵심 메커니즘
1. **AttackComponent**: 공격 영역 설정 → 대미지 계산 → Attack 실행
2. **HitComponent**: 충돌 영역 설정 → 피격 판정 → OnHit 호출
3. **DamageSkinComponent**: 대미지 시각화 (DamageSkinSettingComponent와 연동)

### 전투 흐름
```
Attacker (AttackComponent)
    ↓ Attack(shape, attackInfo)
    ↓ CalcDamage() / CalcCritical()
    ↓
Defender (HitComponent)
    ↓ IsHitTarget() 판정
    ↓ OnHit(attacker, damage, isCritical, attackInfo, hitCount)
    ↓ HitEvent 발생
```

---

## 1. AttackComponent

### 📝 개요
- **용도**: HitComponent와 연동하여 공격 기능 구현
- **필수도**: ⭐⭐⭐⭐⭐ (전투 시스템 필수)
- **핵심 기능**: 공격 영역 설정, 대미지 계산, 크리티컬 시스템

### Properties (0개)

**모든 Properties는 Component에서 상속:**
- `Enable` (boolean, Sync): 컴포넌트 활성화 여부

### Methods (10개)

#### 공격 실행 (3가지 방식)
```lua
table<Component> Attack(Shape shape, string attackInfo, CollisionGroup collisionGroup = nil)
    -- shape 영역 내 HitComponent의 OnHit 호출 및 HitEvent 발생
    -- 공격 대상 HitComponent 리스트 반환
    -- attackInfo: 사용자 정의 데이터

table<Component> Attack(Vector2 size, Vector2 offset, string attackInfo, CollisionGroup collisionGroup = nil)
    -- 사각형 영역 공격
    -- size: 사각형 크기, offset: 엔티티 기준 중심 위치

table<Component> AttackFrom(Vector2 size, Vector2 position, string attackInfo, CollisionGroup collisionGroup = nil)
    -- 사각형 영역 공격 (월드 좌표)
    -- position: 월드 좌표 기준 중심 위치

void AttackFast(Shape shape, string attackInfo, CollisionGroup collisionGroup = nil)
    -- 반환값 없는 Attack (성능 최적화)
    -- table 객체 생성 방지로 성능 개선
```

#### 대미지 시스템 (ScriptOverridable)
```lua
integer CalcDamage(Entity attacker, Entity defender, string attackInfo)
    -- 대미지 값 계산
    -- 기본값: 1

boolean CalcCritical(Entity attacker, Entity defender, string attackInfo)
    -- 크리티컬 여부 판정
    -- 기본값: false (크리티컬 없음)

float GetCriticalDamageRate()
    -- 크리티컬 대미지 배율
    -- 기본값: 2.0 (2배)

int32 GetDisplayHitCount(string attackInfo)
    -- 대미지 분할 표시 횟수
    -- 기본값: 1 (1히트)
```

#### 공격 판정 (ScriptOverridable)
```lua
boolean IsAttackTarget(Entity defender, string attackInfo)
    -- defender가 공격 대상인지 판단
    -- false 반환 시 Attack/AttackFrom/AttackFast에서 제외
    -- 기본 동작:
    --   - defender StateComponent가 'DEAD'면 false
    --   - 양쪽 모두 플레이어이고 defender PVPMode=false면 false

void OnAttack(Entity defender)
    -- 공격 시 호출되는 함수
```

**Inherited from Component:**
- `boolean IsClient()`: 클라이언트 실행 환경 확인
- `boolean IsServer()`: 서버 실행 환경 확인

### Events (1개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `AttackEvent` | 엔티티가 공격할 때 | Server, Client |

### 사용 패턴

#### 커스텀 공격 시스템 구현
```lua
-- AttackComponent를 Extend한 스크립트

[server only]
void AttackNormal()
{
    local attackSize = Vector2(1, 1)
    local playerController = self.Entity.PlayerControllerComponent
    
    if playerController ~= nil then
        local attackOffset = Vector2(0.5 * playerController.LookDirectionX, 0.5)
        self:Attack(attackSize, attackOffset, nil, CollisionGroups.Monster)
    end
}

-- 대미지 계산 재정의
override int CalcDamage(Entity attacker, Entity defender, string attackInfo)
{
    return 50  -- 고정 50 대미지
}

-- 크리티컬 확률 30%
override boolean CalcCritical(Entity attacker, Entity defender, string attackInfo)
{
    return _UtilLogic:RandomDouble() < 0.3
}

-- 크리티컬 대미지 2배
override number GetCriticalDamageRate()
{
    return 2
}

[self]
HandlePlayerActionEvent(PlayerActionEvent event)
{
    if self:IsClient() then return end
    
    if event.ActionName == "Attack" then
        self:AttackNormal()
    end
}
```

---

## 2. HitComponent

### 📝 개요
- **용도**: 충돌 영역 설정 및 AttackComponent 피격 처리
- **필수도**: ⭐⭐⭐⭐⭐ (전투 시스템 필수)
- **핵심 기능**: 충돌체 설정, 피격 판정, 피격 처리

### Properties (9개)

#### 충돌체 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `BoxOffset` | Vector2 | ✅ | Legacy 시스템 충돌체 중심점 (IsLegacy=true) |
| `BoxSize` | Vector2 | ✅ | 직사각형 충돌체 크기 |
| `CircleRadius` | float | ✅ | 원형 충돌체 반지름 (ColliderType=Circle) |
| `ColliderOffset` | Vector2 | ✅ | 충돌체 중심점 (IsLegacy=false, 신규 시스템) |
| `ColliderType` | ColliderType | ✅ | 충돌체 타입 (Box/Circle/Polygon) |
| `CollisionGroup` | CollisionGroup | ✅ | 충돌 그룹 |
| `IsLegacy` | boolean | ReadOnly | Legacy 시스템 사용 여부 |
| `PolygonPoints` | SyncList<Vector2> | ✅ | 다각형 충돌체 점 위치 (ColliderType=Polygon) |

#### Deprecated
| Property | 설명 |
|----------|------|
| `ColliderName` | Deprecated - CollisionGroup 사용 권장 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (2개)

```lua
boolean IsHitTarget(string attackInfo)  [ScriptOverridable]
    -- AttackComponent 공격을 받을지 판정
    -- 기본값: true

void OnHit(Entity attacker, integer damage, boolean isCritical, string attackInfo, int32 hitCount)  [ScriptOverridable]
    -- 피격 시 호출
    -- 기본 동작: HitEvent 발생
    -- attacker: 공격자 Entity
    -- damage: 대미지 값
    -- isCritical: 크리티컬 여부
    -- attackInfo: AttackComponent에서 전달된 사용자 정의 데이터
    -- hitCount: 대미지 분할 재생 횟수
```

**Inherited from Component:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (1개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `HitEvent` | 엔티티가 피격되었을 때 | Server, Client |

### 사용 패턴

#### 체력 시스템 + 충돌체 크기 변화
```lua
[Sync]
number Health = 1000
[None]
number InitialHealth = 0
[None]
Vector2 InitialBoxSize = Vector2(0, 0)

[server only]
void OnBeginPlay()
{
    self.InitialHealth = self.Health
    self.InitialBoxSize = self.Entity.HitComponent.BoxSize:Clone()
}

[server only] [self]
HandleHitEvent(HitEvent event)
{
    local TotalDamage = event.TotalDamage
    local hitComponent = self.Entity.HitComponent
    
    self.Health = self.Health - TotalDamage
    self.Health = math.max(self.Health, 0.0)
    
    if self.Health > 0.0 then
        -- 체력이 낮을수록 충돌체 커짐 (1~10배)
        local ratio = 10 - ((10 - 1) / self.InitialHealth) * self.Health
        hitComponent.BoxSize = self.InitialBoxSize * ratio
    else
        _EntityService:Destroy(self.Entity)
    end
}
```

#### 무적 시간 구현
```lua
-- HitComponent를 Extend한 스크립트

[None]
number ImmuneCooldown = 1  -- 1초 무적
[None]
number LastHitTime = 0

override boolean IsHitTarget(string attackInfo)
{
    local currentTime = _UtilLogic.ElapsedSeconds
    
    if self.LastHitTime + self.ImmuneCooldown < currentTime then
        self.LastHitTime = _UtilLogic.ElapsedSeconds
        return true
    end
    
    return false  -- 무적 시간 중
}
```

---

## 3. DamageSkinComponent

### 📝 개요
- **용도**: 대미지를 시각적으로 표현하는 스킨 구성
- **필수도**: ⭐⭐⭐ (대미지 표시 시)
- **핵심 기능**: 대미지 스킨 표시
- **연동**: DamageSkinSettingComponent에서 스킨 형식 지정

### Properties (0개)

**모든 Properties는 Component에서 상속:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (0개)

**모든 Methods는 Component에서 상속:**
- `boolean IsClient()`, `boolean IsServer()`

### 사용 패턴

```lua
-- DamageSkinComponent는 자동으로 동작합니다.
-- 대미지 스킨 형식은 공격자 엔티티의 DamageSkinSettingComponent에서 설정합니다.

-- 피격자 엔티티에 DamageSkinComponent 추가
local damageSkin = entity:AddComponent(DamageSkinComponent)

-- 공격자 엔티티에 DamageSkinSettingComponent 추가 및 설정
-- (별도 컴포넌트로 스킨 형식 지정)
```

---

## 🎯 Phase 3 핵심 패턴

### 1. 기본 공격/피격 시스템
```lua
-- 공격자 (AttackComponent)
[server only]
void Attack()
{
    local size = Vector2(2, 2)
    local offset = Vector2(1, 0)  -- 앞쪽 공격
    self:Attack(size, offset, "normal_attack", CollisionGroups.Monster)
}

-- 피격자 (HitComponent)
[server only] [self]
HandleHitEvent(HitEvent event)
{
    local damage = event.TotalDamage
    local attacker = event.AttackerEntity
    
    log("Hit by " .. attacker.Name .. " for " .. damage .. " damage")
    
    -- 체력 감소 로직
    self.Health = self.Health - damage
}
```

### 2. 크리티컬 시스템
```lua
-- AttackComponent 확장
override boolean CalcCritical(Entity attacker, Entity defender, string attackInfo)
{
    -- 크리티컬 확률 계산 (예: 공격자 스탯 기반)
    local critChance = attacker.StatComponent.CriticalRate or 0.1
    return _UtilLogic:RandomDouble() < critChance
}

override float GetCriticalDamageRate()
{
    -- 크리티컬 대미지 배율 (예: 공격자 스탯 기반)
    return self.Entity.StatComponent.CriticalDamage or 2.0
}
```

### 3. 스킬 기반 공격
```lua
-- attackInfo로 스킬 구분
[server only]
void UseSkill(string skillName)
{
    local size = Vector2(3, 3)
    local offset = Vector2(0, 0)
    
    -- attackInfo에 스킬 정보 전달
    self:Attack(size, offset, skillName, CollisionGroups.Monster)
}

-- 대미지 계산에서 스킬별 처리
override int CalcDamage(Entity attacker, Entity defender, string attackInfo)
{
    if attackInfo == "fireball" then
        return 100
    elseif attackInfo == "slash" then
        return 50
    else
        return 10
    end
}
```

### 4. 다중 히트 공격
```lua
-- AttackComponent 확장
override int32 GetDisplayHitCount(string attackInfo)
{
    if attackInfo == "multi_slash" then
        return 5  -- 5히트로 분할 표시
    else
        return 1
    end
}

-- 총 대미지는 동일하지만 5번에 나눠서 표시됨
```

### 5. 충돌체 타입별 설정
```lua
-- 사각형 충돌체
hitComponent.ColliderType = ColliderType.Box
hitComponent.BoxSize = Vector2(1, 2)
hitComponent.ColliderOffset = Vector2(0, 0.5)

-- 원형 충돌체
hitComponent.ColliderType = ColliderType.Circle
hitComponent.CircleRadius = 1.0
hitComponent.ColliderOffset = Vector2(0, 0)

-- 다각형 충돌체
hitComponent.ColliderType = ColliderType.Polygon
hitComponent.PolygonPoints:Add(Vector2(0, 0))
hitComponent.PolygonPoints:Add(Vector2(1, 0))
hitComponent.PolygonPoints:Add(Vector2(0.5, 1))
```

### 6. PVP 시스템
```lua
-- AttackComponent 확장
override boolean IsAttackTarget(Entity defender, string attackInfo)
{
    -- 기본 체크 (DEAD 상태, PVP 모드 등)
    if not self:base_IsAttackTarget(defender, attackInfo) then
        return false
    end
    
    -- 추가 조건 (같은 팀은 공격 불가)
    local attackerTeam = self.Entity.TeamComponent.TeamId
    local defenderTeam = defender.TeamComponent.TeamId
    
    if attackerTeam == defenderTeam then
        return false
    end
    
    return true
}
```

---

## 🔗 관련 컴포넌트 & 서비스

### 관련 컴포넌트
- **DamageSkinSettingComponent**: 대미지 스킨 형식 설정
- **StateComponent**: 엔티티 상태 관리 (DEAD 등)
- **PlayerComponent**: PVPMode 설정

### 관련 서비스
- **CollisionService**: 충돌 그룹 관리
- **EntityService**: 엔티티 생성/삭제

### 관련 타입
- **Shape**: 공격 영역 형태
- **CollisionGroup**: 충돌 그룹
- **ColliderType**: Box, Circle, Polygon

---

## 📋 다음 단계

Phase 3 완료! 다음은:
- **Phase 4**: Animation & State Components (7개) - StateComponent, StateAnimationComponent, TweenComponent 등
- **Phase 5**: Sound Components (3개) - SoundComponent, BGMComponent, FootstepSoundComponent

---

> **학습 완료**: 2026-02-08  
> **다음 목표**: Phase 4 - Animation & State Components 학습
