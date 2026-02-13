# Phase 1: Player & Character Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 11개  
> **카테고리**: Player/Movement (3개), Avatar System (8개)

---

## 📊 Phase 1 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **PlayerController** | 3 | 13 | 2 | 플레이어 입력 제어 |
| **Movement** | 3 | 7 | 2 | 이동/점프 제어 |
| **Chat** | 7 | 0 | 1 | 채팅 기능 |
| **AvatarRenderer** | 6 | 8 | 2 | 아바타 렌더링 (월드) |
| **AvatarGUIRenderer** | 7 | 5 | 0 | 아바타 렌더링 (UI) |
| **AvatarBodyActionSelector** | 2 | 0 | 1 | 몸 동작 선택 |
| **AvatarFaceActionSelector** | 3 | 0 | 0 | 표정 선택 |
| **AvatarStateAnimation** | 2 | 4 | 1 | 상태 애니메이션 |
| **CostumeManager** | 20 | 2 | 2 | 코스튬 관리 |
| **NameTag** | 7 | 0 | 0 | 이름표 |
| **ChatBalloon** | 15 | 0 | 1 | 말풍선 |
| **총계** | **75** | **39** | **12** | - |

---

## 1. PlayerControllerComponent

### 📝 개요
- **용도**: 플레이어의 입력과 액션을 연동하고 제어
- **필수도**: ⭐⭐⭐⭐⭐ (플레이어 제어 필수)
- **핵심 기능**: 키 입력 → 액션 매핑, 커스텀 액션 정의

### Properties (3개)

| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `AlwaysMovingState` | boolean | ✅ | 항상 걷기 애니메이션 재생 여부 |
| `FixedLookAt` | int32 | ✅ | 이동 시 바라보는 방향 고정 |
| `LookDirectionX` | float | ✅ | 현재 X축 바라보는 방향 (양수=오른쪽, 음수=왼쪽) |

### Methods (13개)

#### 액션 핸들러 (ScriptOverridable)
```lua
void ActionAttack()           -- Attack 키 입력 시
void ActionCrouch()           -- Crouch 키 입력 시
void ActionDownJump()         -- 아래 점프 시
void ActionEnterPortal()      -- Portal 키 입력 시
void ActionInteraction(KeyboardKey key, boolean isKeyDown)  -- Interaction 키 입력 시
void ActionJump()             -- Jump 키 입력 시
void ActionSit()              -- Sit 키 입력 시
```

#### 키 매핑 관리 (ClientOnly)
```lua
void AddCondition(string actionName, func -> boolean conditionFunction)
    -- 액션 발동 조건 추가

string GetActionName(KeyboardKey key)
    -- 키에 매핑된 액션 이름 반환

void RemoveActionKey(KeyboardKey key)
    -- 키에 연결된 액션 제거

void RemoveAllActionKeyByActionName(string actionName)
    -- 액션 이름에 연결된 모든 키 제거

void SetActionKey(KeyboardKey key, string actionName, func -> boolean conditionFunction = nil)
    -- 키와 액션 매핑
```

### Events (2개)

| Event | 발생 조건 |
|-------|----------|
| `ChangedLookAtEvent` | 캐릭터 바라보는 방향 변경 시 |
| `PlayerActionEvent` | 플레이어가 액션 사용 시 |

### 사용 패턴

#### 커스텀 키 매핑
```lua
[client only]
void OnBeginPlay()
{
    -- B키로 공격, N키로 점프
    self.Entity.PlayerControllerComponent:SetActionKey(KeyboardKey.B, "Attack")
    self.Entity.PlayerControllerComponent:SetActionKey(KeyboardKey.N, "Jump")
    
    -- 커스텀 액션
    self.Entity.PlayerControllerComponent:SetActionKey(KeyboardKey.G, "MyCustomAction")
}

[self]
HandlePlayerActionEvent(PlayerActionEvent event)
{
    local actionName = event.ActionName
    log("Action: " .. actionName)
}
```

---

## 2. MovementComponent

### 📝 개요
- **용도**: Rigidbody/Kinematicbody/Sideviewbody 제어
- **필수도**: ⭐⭐⭐⭐⭐ (이동 제어 필수)
- **핵심 기능**: 속력/점프력 간단 조정

### Properties (3개)

| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `InputSpeed` | float | ✅ | 이동 속력 (Rigidbody/Kinematic/Sideview 모두 적용) |
| `IsClimbPaused` | boolean | ✅ ReadOnly | 등반 중 멈춘 상태 확인 |
| `JumpForce` | float | ✅ | 점프 힘 (값이 클수록 높게 점프) |

### Methods (7개)

```lua
boolean DownJump()
    -- 아래로 점프, 성공 여부 반환

boolean IsFaceLeft()
    -- 왼쪽을 향하는지 여부 반환

boolean Jump()
    -- 점프, 성공 여부 반환

void MoveToDirection(Vector2 direction, float deltaTime)
    -- direction 방향으로 이동 (사다리 타고 있을 때만 deltaTime 적용)

void SetPosition(Vector2 position)
    -- 로컬 좌표 기준 위치 설정

void SetWorldPosition(Vector2 position)
    -- 월드 좌표 기준 위치 설정

void Stop()
    -- 이동 멈춤
```

### Events (2개)

| Event | 발생 조건 |
|-------|----------|
| `ChangedMovementInputEvent` | 이동 입력 변경 시 |
| `ClimbPauseEvent` | 등반 중 멈췄을 때 |

### 사용 패턴

#### 자동 이동 + 트리거 반응
```lua
[Sync]
boolean IsStarted = false
[Sync]
boolean IsFinished = false

[client only]
void OnUpdate(number delta)
{
    if self.IsFinished then
        self.Entity.MovementComponent:Stop()
        return
    end
    
    -- 왼쪽을 보면 시작
    if self.IsStarted == false and self.Entity.MovementComponent:IsFaceLeft() then
        self.IsStarted = true
    end
    
    if self.IsStarted then
        self.Entity.MovementComponent:MoveToDirection(Vector2(1,0), delta)
    end
}

[client only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    
    if other.Name == "JumpTrigger" then
        self.Entity.MovementComponent.JumpForce = 1.5
        self.Entity.MovementComponent:Jump()
    elseif other.Name == "DownJumpTrigger" then
        self.Entity.MovementComponent:DownJump()
    elseif other.Name == "FinishTrigger" then
        self.IsFinished = true
    end
}
```

---

## 3. ChatComponent

### 📝 개요
- **용도**: 플레이어 간 채팅 기능 제공
- **필수도**: ⭐⭐⭐ (멀티플레이어 시 필요)
- **핵심 기능**: 채팅, 감정 표현, 말풍선 연동

### Properties (7개)

| Property | Type | MakerOnly | 설명 |
|----------|------|-----------|------|
| `ChatEmotionDuration` | float | | 아바타 감정 표현 지속 시간 |
| `EnableVoiceChat` | boolean | ✅ | 보이스 채팅 버튼 표시/사용 여부 |
| `Expand` | boolean | | 채팅창 펼치기 기능 |
| `HideWorldChatButton` | boolean | ✅ | 월드 채팅 버튼 숨기기 |
| `MessageAlignBottom` | boolean | ✅ | 채팅 메시지 하단 정렬 |
| `UseChatBalloon` | boolean | | 채팅 메시지를 말풍선으로 표현 |
| `UseChatEmotion` | boolean | | 채팅으로 아바타 감정 표현 사용 |

### Events (1개)

| Event | 발생 조건 |
|-------|----------|
| `ChatEvent` | 대화 입력 시 (Space: Client) |

### 사용 패턴

#### 감정 표현 감지 및 지속 시간 조정
```lua
[self]
HandleChatEvent(ChatEvent event)
{
    local message = event.Message
    local senderName = event.SenderName
    local userId = event.UserId
    
    -- 로컬 플레이어만 처리
    local localId = _UserService.LocalPlayer.OwnerId
    if string.compare(localId, userId) == false then
        return
    end
    
    local lowerMessage = string.lower(message)
    
    -- EmotionalType 검색 (23개)
    local findEmotion = EmotionalType.Invalid
    for i = 1, 23 do
        local key = string.lower(tostring(EmotionalType.CastFrom(i)))
        if lowerMessage:find(key, 1, true) then
            findEmotion = EmotionalType.CastFrom(i)
            break
        end
    end
    
    if findEmotion == EmotionalType.Invalid then
        return
    end
    
    -- 감정 표현 길이에 따라 지속 시간 조정
    local duration = #tostring(findEmotion)
    
    local chatComponent = self.Entity.ChatComponent
    if chatComponent then
        chatComponent.UseChatEmotion = true
        chatComponent.ChatEmotionDuration = duration
    end
    
    local balloonComponent = _UserService.LocalPlayer.ChatBalloonComponent
    if balloonComponent then
        balloonComponent.ShowDuration = duration
    end
}
```

---

## 🎯 Phase 1 핵심 패턴

### 1. 플레이어 제어 시스템
```lua
-- PlayerController: 키 매핑
self.Entity.PlayerControllerComponent:SetActionKey(KeyboardKey.E, "Interact")

-- Movement: 이동/점프
self.Entity.MovementComponent.InputSpeed = 5.0
self.Entity.MovementComponent.JumpForce = 10.0
self.Entity.MovementComponent:Jump()
```

### 2. 아바타 커스터마이징
```lua
-- 코스튬 변경
local costume = self.Entity.CostumeManagerComponent
costume:SetEquip(MapleAvatarItemCategory.Hair, "hair_ruid")
costume:SetEquip(MapleAvatarItemCategory.Coat, "coat_ruid")

-- 색상 변경
self.Entity.AvatarRendererComponent:SetColor(1, 0, 0, 1)  -- 빨간색
self.Entity.AvatarRendererComponent:SetAlpha(0.5)  -- 반투명
```

### 3. 감정 표현 시스템
```lua
-- 월드 아바타
self.Entity.AvatarRendererComponent:PlayEmotion(EmotionalType.Love, 5)

-- UI 아바타
self.Entity.AvatarGUIRendererComponent:PlayEmotion(EmotionalType.Glitter, 3)
```

### 4. 이름표 & 말풍선
```lua
-- 이름표
local nametag = self.Entity.NameTagComponent
nametag.Name = "Player1"
nametag.FontColor = Color.cyan

-- 말풍선
local balloon = self.Entity.ChatBalloonComponent
balloon.Message = "Hello!"
balloon.ShowDuration = 3.0
```

---

> **학습 완료**: 2026-02-08  
> **다음 목표**: Phase 2 - AI Components 학습
