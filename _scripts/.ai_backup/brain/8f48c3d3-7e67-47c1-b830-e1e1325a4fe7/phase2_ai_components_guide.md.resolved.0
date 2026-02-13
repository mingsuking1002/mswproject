# Phase 2: AI Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 3개  
> **카테고리**: AI System (Behavior Tree 기반)

---

## 📊 Phase 2 통계

| Component | Properties | Methods | 용도 |
|-----------|-----------|---------|------|
| **AIComponent** | 3 | 3 | 행동 트리 기반 AI |
| **AIChaseComponent** | 3 | 2 | 플레이어/엔티티 추적 |
| **AIWanderComponent** | 0 | 0 | 주변 배회 (AIComponent 상속) |
| **총계** | **6** | **5** | - |

---

## 🧠 AI 시스템 개요

MapleStory Worlds의 AI 시스템은 **Behavior Tree (행동 트리)** 패턴을 사용합니다.

### 핵심 개념
- **BTNode**: 행동 트리 노드 (Selector, Sequence, Action)
- **BehaviourTreeStatus**: Success, Failure, Running
- **StateComponent**: AI 컴포넌트 사용 시 자동 추가됨

### 노드 타입
1. **SelectorNode**: 자식 중 하나가 Success면 Success (OR 로직)
2. **SequenceNode**: 모든 자식이 Success면 Success (AND 로직)
3. **LeafNode (Action)**: 실제 행동을 수행하는 노드

---

## 1. AIComponent

### 📝 개요
- **용도**: 엔티티에 행동 트리 기반 AI 부여
- **필수도**: ⭐⭐⭐⭐⭐ (AI 시스템 기반)
- **핵심 기능**: Behavior Tree 구축, 커스텀 AI 로직

### Properties (3개)

| Property | Type | ReadOnly | 설명 |
|----------|------|----------|------|
| `IsLegacy` | boolean | ✅ | Legacy 시스템 사용 여부 (삭제 예정) |
| `LogEnabled` | boolean | ✅ | 행동 트리 실행 로그 출력 (메이커 전용) |
| `UpdateAuthority` | UpdateAuthorityType | ✅ | Server/Client 실행 권한 |

**Inherited from Component:**
- `Enable` (boolean, Sync): 컴포넌트 활성화 여부

### Methods (3개)

```lua
BTNode CreateLeafNode(string nodeName, func<float> -> BehaviourTreeStatus onBehaveFunction)
    -- Action 노드 생성
    -- onBehaveFunction: delta(프레임 시간)를 받아 BehaviourTreeStatus 반환

BTNode CreateNode(string nodeType, string nodeName = nil, func<float> -> BehaviourTreeStatus onBehaveFunction = nil)
    -- BTNodeType 기반 노드 생성
    -- nodeType: BTNodeType 타입명
    -- onBehaveFunction이 nil이 아니면 OnInit/OnBehave 대신 호출됨

void SetRootNode(BTNode node)
    -- 최상위 노드 설정 (AI 시작점)
```

**Inherited from Component:**
- `boolean IsClient()`: 클라이언트 실행 환경 확인
- `boolean IsServer()`: 서버 실행 환경 확인

### 사용 패턴

#### 몬스터 AI: 플레이어 감지 → 경고
```lua
-- AIComponent를 Extend한 스크립트 컴포넌트
[Sync]
number DetectDistance = 4

[server only]
void OnBeginPlay()
{
    local chatBallon = self.Entity.ChatBalloonComponent
    if chatBallon == nil then
        chatBallon = self.Entity:AddComponent(ChatBalloonComponent)
    end
    
    self._T.nearestPlayer = nil
    
    chatBallon.AutoShowEnabled = true
    chatBallon.ChatModeEnabled = false
    chatBallon.ShowDuration = 1
    chatBallon.HideDuration = 0
    chatBallon.FontSize = 1.5
    
    -- 플레이어 감지 함수
    local function isNearPlayer(deltaTime)
        local players = _UserService:GetUsersByMapComponent(self.Entity.CurrentMap.MapComponent)
        self._T.nearestPlayer = nil
        local dist = math.maxinteger
        
        for i, player in pairs(players) do
            if isvalid(player) then
                local distTemp = Vector2.Distance(
                    player.TransformComponent.Position:ToVector2(),
                    self.Entity.TransformComponent.Position:ToVector2()
                )
                dist = math.min(dist, distTemp)
                if dist <= self.DetectDistance then
                    self._T.nearestPlayer = player
                end
            end
        end
        
        if self._T.nearestPlayer == nil then
            return BehaviourTreeStatus.Failure
        else
            return BehaviourTreeStatus.Success
        end
    end
    
    -- 플레이어 바라보기
    local function lookAtNearestPlayer(deltaTime)
        local flipX = self.Entity.TransformComponent.Position.x < 
                      self._T.nearestPlayer.TransformComponent.Position.x
        self.Entity.SpriteRendererComponent.FlipX = flipX
        return BehaviourTreeStatus.Success
    end
    
    -- 경고 메시지
    local function warn(deltaTime)
        chatBallon.Message = "Don't come!"
        return BehaviourTreeStatus.Success
    end
    
    -- 수면 메시지
    local function sleep(deltaTime)
        chatBallon.Message = "Zzz..."
        return BehaviourTreeStatus.Success
    end
    
    -- Behavior Tree 구성
    local rootNode = SelectorNode("Root")
    
    local alertSeq = SequenceNode("AlertSequence")
    alertSeq:AttachChild(self:CreateLeafNode("IsNearPlayer", isNearPlayer))
    alertSeq:AttachChild(self:CreateLeafNode("LookAtNearestPlayer", lookAtNearestPlayer))
    alertSeq:AttachChild(self:CreateLeafNode("Warn", warn))
    
    rootNode:AttachChild(alertSeq)
    rootNode:AttachChild(self:CreateLeafNode("Sleep", sleep))
    
    self:SetRootNode(rootNode)
}
```

#### Behavior Tree 구조 설명
```
SelectorNode (Root)
├── SequenceNode (AlertSequence)
│   ├── IsNearPlayer (플레이어 감지)
│   ├── LookAtNearestPlayer (플레이어 바라보기)
│   └── Warn (경고 메시지)
└── Sleep (수면 메시지)

실행 로직:
1. AlertSequence 시도
   - IsNearPlayer Success → LookAtNearestPlayer → Warn → Root Success
   - IsNearPlayer Failure → Sleep → Root Success
```

---

## 2. AIChaseComponent

### 📝 개요
- **용도**: 플레이어나 엔티티를 추적하는 AI
- **필수도**: ⭐⭐⭐⭐ (추적 AI 필수)
- **핵심 기능**: 자동 플레이어 추적, 특정 대상 추적
- **자동 추가**: StateComponent가 없으면 자동 추가

### Properties (3개)

| Property | Type | ReadOnly | 설명 |
|----------|------|----------|------|
| `DetectionRange` | float | | 추적 감지 거리 (멀어지면 중단, 가까워지면 재시작) |
| `IsChaseNearPlayer` | boolean | | true면 DetectionRange 내 가장 가까운 플레이어 자동 추적 |
| `TargetEntityRef` | EntityRef | ✅ | 추적 대상 엔티티 (SetTarget으로 설정) |

**Inherited from AIComponent:**
- `IsLegacy`, `LogEnabled`, `UpdateAuthority`

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (2개)

```lua
Entity GetCurrentTarget()
    -- 현재 추적 중인 대상 엔티티 반환

void SetTarget(Entity targetEntity)
    -- targetEntity를 추적하도록 설정
    -- 호출 시 IsChaseNearPlayer 자동 비활성화
```

**Inherited from AIComponent:**
- `CreateLeafNode`, `CreateNode`, `SetRootNode`

### 사용 패턴

#### 공격받은 대상 추적하기
```lua
[server only]
void OnBeginPlay()
{
    local aiChaseComponent = self.Entity.AIChaseComponent
    if aiChaseComponent == nil then
        return
    end
    
    -- 자동 플레이어 추적 비활성화 (공격자만 추적)
    aiChaseComponent.IsChaseNearPlayer = false
    
    local chatBallon = self.Entity.ChatBalloonComponent
    if chatBallon == nil then
        chatBallon = self.Entity:AddComponent(ChatBalloonComponent)
    end
    
    chatBallon.ChatModeEnabled = false
    chatBallon.ShowDuration = 1
    chatBallon.HideDuration = 0
    chatBallon.FontSize = 1.2
}

[server only]
void OnUpdate(number delta)
{
    if self.Entity.ChatBalloonComponent == nil then
        return
    end

    local currentTargetEntity = self.Entity.AIChaseComponent:GetCurrentTarget()
    if currentTargetEntity == nil then
        self.Entity.ChatBalloonComponent.AutoShowEnabled = false
    else
        self.Entity.ChatBalloonComponent.AutoShowEnabled = true
        self.Entity.ChatBalloonComponent.Message = "target is " .. currentTargetEntity.Name
    end
}

[self]
HandleHitEvent(HitEvent event)
{
    -- HitComponent에서 발생 (Server, Client)
    local AttackerEntity = event.AttackerEntity
    
    if self.Entity.AIChaseComponent == nil then
        return
    end
    
    -- 공격자를 추적 대상으로 설정
    self.Entity.AIChaseComponent:SetTarget(AttackerEntity)
}
```

---

## 3. AIWanderComponent

### 📝 개요
- **용도**: 주변을 배회하는 AI
- **필수도**: ⭐⭐⭐ (배회 AI)
- **핵심 기능**: 자동 배회 (별도 설정 불필요)
- **자동 추가**: StateComponent가 없으면 자동 추가

### Properties (0개)

**모든 Properties는 AIComponent에서 상속:**
- `IsLegacy`, `LogEnabled`, `UpdateAuthority`
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (0개)

**모든 Methods는 AIComponent에서 상속:**
- `CreateLeafNode`, `CreateNode`, `SetRootNode`
- `IsClient`, `IsServer`

### 사용 패턴

#### 기본 배회 AI
```lua
-- AIWanderComponent를 엔티티에 추가하면 자동으로 배회합니다.
-- 별도의 스크립트 작성 없이 메이커에서 컴포넌트만 추가하면 됩니다.

-- 만약 배회 중 특정 조건에서 행동을 변경하고 싶다면
-- AIComponent를 Extend하여 커스텀 Behavior Tree를 구성하세요.
```

---

## 🎯 Phase 2 핵심 패턴

### 1. Behavior Tree 기본 구조
```lua
-- Selector: OR 로직 (하나만 성공하면 성공)
local rootNode = SelectorNode("Root")

-- Sequence: AND 로직 (모두 성공해야 성공)
local sequence = SequenceNode("MySequence")

-- Leaf Node: 실제 행동
local action = self:CreateLeafNode("MyAction", function(delta)
    -- 행동 로직
    return BehaviourTreeStatus.Success
end)

sequence:AttachChild(action)
rootNode:AttachChild(sequence)
self:SetRootNode(rootNode)
```

### 2. 조건부 AI 패턴
```lua
-- 조건 체크 함수
local function checkCondition(delta)
    if [조건] then
        return BehaviourTreeStatus.Success
    else
        return BehaviourTreeStatus.Failure
    end
end

-- 액션 함수
local function doAction(delta)
    -- 실행 로직
    return BehaviourTreeStatus.Success
end

-- Sequence로 연결 (조건 성공 시에만 액션 실행)
local seq = SequenceNode("ConditionalAction")
seq:AttachChild(self:CreateLeafNode("Check", checkCondition))
seq:AttachChild(self:CreateLeafNode("Action", doAction))
```

### 3. 추적 AI 패턴
```lua
-- 자동 플레이어 추적
self.Entity.AIChaseComponent.IsChaseNearPlayer = true
self.Entity.AIChaseComponent.DetectionRange = 10.0

-- 특정 대상 추적
self.Entity.AIChaseComponent:SetTarget(targetEntity)

-- 현재 추적 대상 확인
local target = self.Entity.AIChaseComponent:GetCurrentTarget()
if target ~= nil then
    log("Chasing: " .. target.Name)
end
```

### 4. 이벤트 기반 AI 전환
```lua
-- 평소: 배회
-- 공격받으면: 추적

[self]
HandleHitEvent(HitEvent event)
{
    -- 배회 AI 비활성화
    if self.Entity.AIWanderComponent then
        self.Entity.AIWanderComponent.Enable = false
    end
    
    -- 추적 AI 활성화
    if self.Entity.AIChaseComponent then
        self.Entity.AIChaseComponent.Enable = true
        self.Entity.AIChaseComponent:SetTarget(event.AttackerEntity)
    end
}
```

---

## 🔗 관련 컴포넌트

### StateComponent
- AI 컴포넌트 사용 시 자동 추가됨
- 엔티티의 상태 관리 (Idle, Walk, Attack 등)

### 관련 노드 타입
- **SelectorNode**: OR 로직 노드
- **SequenceNode**: AND 로직 노드
- **BTNode**: 행동 트리 노드 기본 타입

### 관련 Enum
- **BehaviourTreeStatus**: Success, Failure, Running
- **UpdateAuthorityType**: Server, Client

---

## 📋 다음 단계

Phase 2 완료! 다음은:
- **Phase 3**: Combat System (6개) - Attack, Hit, DamageSkin, DamageFont, HitScan, Spawner
- **Phase 4**: Animation & State (7개) - State, StateAnimation, Tween 등

---

> **학습 완료**: 2026-02-08  
> **다음 목표**: Phase 3 - Combat System Components 학습
