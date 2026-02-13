# Phase 4: Animation & State Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 2개  
> **카테고리**: State Management & Animation

---

## 📊 Phase 4 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **StateComponent** | 1 | 6 | 3 | 상태 관리 시스템 |
| **StateAnimationComponent** | 1 | 4 | 1 | 상태 기반 애니메이션 |
| **총계** | **2** | **10** | **4** | - |

---

## 🎭 State System 개요

MapleStory Worlds의 상태 시스템은 **StateComponent**와 **StateAnimationComponent**의 조합으로 구현됩니다.

### 핵심 메커니즘
1. **StateComponent**: 사용자 정의 StateType으로 상태 정의 및 전이 규칙 설정
2. **StateAnimationComponent**: 상태 변화에 따른 애니메이션 자동 재생
3. **StateType**: 각 상태의 행동과 전이 조건을 정의하는 사용자 정의 타입

### 상태 시스템 흐름
```
StateComponent
    ↓ AddState("IDLE", IdleStateType)
    ↓ AddState("WALK", WalkStateType)
    ↓ AddCondition("IDLE", "WALK", false)
    ↓ StateType.OnConditionCheck() → true
    ↓ ChangeState("WALK")
    ↓ StateChangeEvent 발생
    ↓
StateAnimationComponent
    ↓ ReceiveStateChangeEvent()
    ↓ SetActionSheet("WALK", "walk_animation_ruid")
    ↓ AnimationClipEvent 발생
```

---

## 1. StateComponent

### 📝 개요
- **용도**: 사용자 정의 StateType으로 상태별 행동과 전이 규칙 정의/제어
- **필수도**: ⭐⭐⭐⭐⭐ (상태 기반 시스템 필수)
- **핵심 기능**: 상태 추가/제거, 상태 전이 조건 설정, 강제 상태 변경

### Properties (1개)

| Property | Type | Sync | ReadOnly | 설명 |
|----------|------|------|----------|------|
| `CurrentStateName` | string | ✅ | ✅ | 현재 상태 이름 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (6개)

#### 상태 관리
```lua
boolean AddState(string stateName, Type stateType)
    -- 사용자 정의 StateType으로 stateName 상태 추가
    -- 실패 시 false 반환

void RemoveState(string name)
    -- 지정한 상태 제거

boolean ChangeState(string stateName)
    -- 현재 상태를 강제 변경
```

#### 상태 전이 조건
```lua
boolean AddCondition(string stateName, string nextStateName, boolean reverseResult = false)
    -- stateName → nextStateName 전이 조건 설정
    -- StateType.OnConditionCheck() 반환값이 true면 전이 (reverseResult=false)
    -- reverseResult=true면 OnConditionCheck()가 false일 때 전이
    -- 실패 시 false 반환

void RemoveCondition(string stateName, string nextStateName)
    -- stateName → nextStateName 연결 제거
```

#### Deprecated
```lua
boolean AddState(string stateName, func updateFunction = nil)  [Deprecated]
    -- 사용 금지, AddState(string, Type) 사용

boolean AddCondition(string stateName, string nextStateName, func -> boolean conditionCheckFunction, boolean reverseResult = false)  [Deprecated]
    -- 사용 금지, AddCondition(string, string, boolean) 사용
```

**Inherited from Component:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (3개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `DeadEvent` | 상태가 DEAD로 전이할 때 | Server, Client |
| `ReviveEvent` | 플레이어가 부활할 때 | Server, Client |
| `StateChangeEvent` | 상태가 변경될 때 | Server, Client |

### 사용 패턴

#### 현재 상태 표시
```lua
[server only]
void OnBeginPlay()
{
    local state = self.Entity.StateComponent
    if state == nil then
        state = self.Entity:AddComponent("StateComponent")
    end
    
    local chatBallon = self.Entity.ChatBalloonComponent
    if chatBallon == nil then
        chatBallon = self.Entity:AddComponent("ChatBalloonComponent")
    end
    
    chatBallon.AutoShowEnabled = true
    chatBallon.ChatModeEnabled = false
    chatBallon.ShowDuration = 1
    chatBallon.HideDuration = 0
    chatBallon.FontSize = 2
}

[server only]
void OnUpdate(number delta)
{
    self.Entity.ChatBalloonComponent.Message = self.Entity.StateComponent.CurrentStateName
}
```

#### StateType 정의 및 상태 전이
```lua
-- StateType 정의 (별도 스크립트)
Type IdleStateType
{
    -- 상태 진입 시
    void OnEnter()
    {
        log("Entered IDLE state")
    }
    
    -- 상태 업데이트
    void OnUpdate(number delta)
    {
        -- IDLE 상태 로직
    }
    
    -- 상태 전이 조건 체크
    boolean OnConditionCheck()
    {
        -- 이동 입력이 있으면 true 반환
        return self.Entity.MovementComponent.InputSpeed > 0
    }
    
    -- 상태 종료 시
    void OnExit()
    {
        log("Exited IDLE state")
    }
}

Type WalkStateType
{
    boolean OnConditionCheck()
    {
        -- 이동 입력이 없으면 true 반환
        return self.Entity.MovementComponent.InputSpeed == 0
    }
}

-- StateComponent 설정
[server only]
void OnBeginPlay()
{
    local state = self.Entity.StateComponent
    
    -- 상태 추가
    state:AddState("IDLE", IdleStateType)
    state:AddState("WALK", WalkStateType)
    
    -- 전이 조건 설정
    state:AddCondition("IDLE", "WALK", false)  -- IDLE → WALK (조건 true 시)
    state:AddCondition("WALK", "IDLE", false)  -- WALK → IDLE (조건 true 시)
    
    -- 초기 상태 설정
    state:ChangeState("IDLE")
}
```

---

## 2. StateAnimationComponent

### 📝 개요
- **용도**: 상태 변화에 따라 재생될 애니메이션 지정
- **필수도**: ⭐⭐⭐⭐ (상태 기반 애니메이션 시)
- **핵심 기능**: State → Animation 매핑, 자동 애니메이션 재생

### Properties (1개)

| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `ActionSheet` | SyncDictionary<string, string> | ✅ | 애니메이션 이름 → AnimationClip 매핑 (IsLegacy=true 시) |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (4개)

```lua
void ReceiveStateChangeEvent(IEventSender sender, StateChangeEvent stateEvent)  [ScriptOverridable]
    -- StateChangeEvent 받았을 때 처리
    -- 기본 동작: State에 매핑된 AnimationClip 재생 (AnimationClipEvent 발생)

void SetActionSheet(string key, string animationClipRuid)
    -- StateToAvatarBodyActionSheet에 요소 추가
    -- IsLegacy=true면 ActionSheet에 추가
    -- PlayRate는 자동으로 1로 설정

void RemoveActionSheet(string key)
    -- StateToAvatarBodyActionSheet에서 key 제거
    -- IsLegacy=true면 ActionSheet에서 제거

string StateStringToAnimationKey(string stateName)  [ScriptOverridable]
    -- State에 매핑된 Animation 이름 반환
```

**Inherited from Component:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (1개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `AnimationClipEvent` | AnimationClip 변경이 필요할 때 | Client |

### 사용 패턴

#### 기본 상태 애니메이션 매핑
```lua
[server only]
void OnBeginPlay()
{
    local stateAnim = self.Entity.StateAnimationComponent
    
    -- 상태별 애니메이션 설정
    stateAnim:SetActionSheet("IDLE", "idle_animation_ruid")
    stateAnim:SetActionSheet("WALK", "walk_animation_ruid")
    stateAnim:SetActionSheet("RUN", "run_animation_ruid")
    stateAnim:SetActionSheet("JUMP", "jump_animation_ruid")
    stateAnim:SetActionSheet("ATTACK", "attack_animation_ruid")
    stateAnim:SetActionSheet("HIT", "hit_animation_ruid")
    stateAnim:SetActionSheet("DEAD", "dead_animation_ruid")
}
```

#### 랜덤 피격 애니메이션
```lua
-- StateAnimationComponent를 Extend한 스크립트

[None]
table<string> HitAnimations

void OnBeginPlay()
{
    -- 여러 피격 애니메이션 RUID 추가
    table.insert(self.HitAnimations, "hit_animation_1_ruid")
    table.insert(self.HitAnimations, "hit_animation_2_ruid")
    table.insert(self.HitAnimations, "hit_animation_3_ruid")
    table.insert(self.HitAnimations, "hit_animation_4_ruid")
}

void SetRandomHitAnimation()
{
    -- 랜덤 피격 애니메이션 선택
    local randomIndex = _UtilLogic:RandomIntegerRange(1, #self.HitAnimations)
    self:SetActionSheet("hit", self.HitAnimations[randomIndex])
}

override string StateStringToAnimationKey(string stateName)
{
    if stateName == "HIT" then
        -- HIT 상태일 때마다 랜덤 애니메이션 설정
        self:SetRandomHitAnimation()
    end
    
    return __base:StateStringToAnimationKey(stateName)
}
```

---

## 🎯 Phase 4 핵심 패턴

### 1. 기본 상태 머신 구현
```lua
-- StateType 정의
Type IdleState
{
    void OnEnter() { log("IDLE") }
    boolean OnConditionCheck() { return hasInput }
}

Type MoveState
{
    void OnEnter() { log("MOVE") }
    boolean OnConditionCheck() { return not hasInput }
}

-- StateComponent 설정
local state = entity.StateComponent
state:AddState("IDLE", IdleState)
state:AddState("MOVE", MoveState)
state:AddCondition("IDLE", "MOVE", false)
state:AddCondition("MOVE", "IDLE", false)
state:ChangeState("IDLE")
```

### 2. 상태 + 애니메이션 통합
```lua
-- StateComponent 설정
local state = entity.StateComponent
state:AddState("IDLE", IdleStateType)
state:AddState("WALK", WalkStateType)
state:AddCondition("IDLE", "WALK", false)

-- StateAnimationComponent 설정
local stateAnim = entity.StateAnimationComponent
stateAnim:SetActionSheet("IDLE", "idle_anim_ruid")
stateAnim:SetActionSheet("WALK", "walk_anim_ruid")

-- 상태 변경 시 자동으로 애니메이션 재생됨
state:ChangeState("WALK")  -- walk_anim_ruid 자동 재생
```

### 3. 조건부 상태 전이
```lua
Type IdleStateType
{
    boolean OnConditionCheck()
    {
        -- 체력이 0 이하면 DEAD로 전이
        if self.Entity.PlayerComponent.Health <= 0 then
            return true
        end
        return false
    }
}

-- IDLE → DEAD 조건 설정
state:AddCondition("IDLE", "DEAD", false)
```

### 4. reverseResult 활용
```lua
Type AliveStateType
{
    boolean OnConditionCheck()
    {
        -- 체력이 0보다 크면 true
        return self.Entity.PlayerComponent.Health > 0
    }
}

-- reverseResult=true: OnConditionCheck()가 false일 때 전이
-- 즉, 체력이 0 이하일 때 ALIVE → DEAD
state:AddCondition("ALIVE", "DEAD", true)
```

### 5. 강제 상태 변경
```lua
-- 특정 이벤트 발생 시 강제로 상태 변경
[self]
HandleHitEvent(HitEvent event)
{
    local damage = event.TotalDamage
    self.Health = self.Health - damage
    
    if self.Health <= 0 then
        -- 강제로 DEAD 상태로 변경
        self.Entity.StateComponent:ChangeState("DEAD")
    else
        -- 일시적으로 HIT 상태로 변경
        self.Entity.StateComponent:ChangeState("HIT")
        
        -- 0.5초 후 이전 상태로 복귀
        wait(0.5)
        self.Entity.StateComponent:ChangeState("IDLE")
    end
}
```

### 6. 상태 변경 이벤트 처리
```lua
[self]
HandleStateChangeEvent(StateChangeEvent event)
{
    local prevState = event.PrevStateName
    local newState = event.NewStateName
    
    log("State changed: " .. prevState .. " → " .. newState)
    
    if newState == "DEAD" then
        -- 사망 처리
        self:OnDeath()
    elseif newState == "ATTACK" then
        -- 공격 처리
        self:PerformAttack()
    end
}
```

### 7. 복잡한 상태 머신
```lua
-- 여러 상태 정의
state:AddState("IDLE", IdleStateType)
state:AddState("WALK", WalkStateType)
state:AddState("RUN", RunStateType)
state:AddState("JUMP", JumpStateType)
state:AddState("ATTACK", AttackStateType)
state:AddState("HIT", HitStateType)
state:AddState("DEAD", DeadStateType)

-- 전이 조건 설정
state:AddCondition("IDLE", "WALK", false)
state:AddCondition("WALK", "RUN", false)
state:AddCondition("RUN", "WALK", false)
state:AddCondition("WALK", "IDLE", false)
state:AddCondition("IDLE", "JUMP", false)
state:AddCondition("WALK", "JUMP", false)
state:AddCondition("IDLE", "ATTACK", false)
state:AddCondition("WALK", "ATTACK", false)

-- 모든 상태에서 HIT/DEAD로 전이 가능
for _, stateName in ipairs({"IDLE", "WALK", "RUN", "JUMP", "ATTACK"}) do
    state:AddCondition(stateName, "HIT", false)
    state:AddCondition(stateName, "DEAD", false)
end
```

---

## 🔗 관련 컴포넌트 & 타입

### 관련 컴포넌트
- **AvatarStateAnimationComponent**: 아바타 전용 상태 애니메이션 (Phase 1에서 학습)
- **SpriteRendererComponent**: 애니메이션 재생 대상

### 관련 타입
- **StateType**: 사용자 정의 상태 타입
  - `void OnEnter()`: 상태 진입 시
  - `void OnUpdate(number delta)`: 상태 업데이트
  - `boolean OnConditionCheck()`: 전이 조건 체크
  - `void OnExit()`: 상태 종료 시

### 관련 이벤트
- **StateChangeEvent**: 상태 변경 시 발생
  - `PrevStateName`: 이전 상태 이름
  - `NewStateName`: 새 상태 이름
- **DeadEvent**: DEAD 상태 전이 시
- **ReviveEvent**: 부활 시
- **AnimationClipEvent**: 애니메이션 클립 변경 시

---

## 📋 다음 단계

Phase 4 완료! 다음은:
- **Phase 5**: Sound Components (3개) - SoundComponent, BGMComponent, FootstepSoundComponent
- **Phase 6**: UI Advanced Components (5개) - ScrollViewComponent, SliderComponent 등

---

> **학습 완료**: 2026-02-08  
> **참고**: TweenComponent, AnimationComponent, AnimatorComponent는 API 문서가 존재하지 않아 제외되었습니다.  
> **다음 목표**: Phase 5 - Sound Components 학습
