# 메이플스토리 월드 완전 API 레퍼런스

> 이 문서는 메이플스토리 월드의 **모든 API 카테고리**를 상세히 문서화한 종합 레퍼런스입니다.

---

# Part 0: API 형식 가이드

## 0.1 API 형식

```
타입 이름(인자타입 인자이름)
```

| 요소 | 설명 |
|------|------|
| **타입** | 리턴 타입 |
| **이름** | API 프로퍼티/함수/이벤트 이름 |
| **인자 타입** | 파라미터 타입 |
| **인자 이름** | 파라미터 이름 |

### 특수 표기
- `=nil` : 생략 가능한 파라미터 (예: `CollisionGroup=nil`)
- `any... args` : 가변 파라미터

---

## 0.2 배지 시스템 (17개)

### 🔄 동기화 정보

| 배지 | 의미 |
|------|------|
| `Sync` | 서버→클라이언트 값 동기화 |

### 📍 실행공간 제어

| 배지 | 의미 |
|------|------|
| `ReadOnly` | 읽기 전용 (덮어쓸 수 없음) |
| `ControlOnly` | 조작 권한 환경 전용 |
| `MakerOnly` | 메이커에서만 사용 가능 |
| `ReleaseOnly` | 출시된 월드에서만 사용 |
| `ServerOnly` | 서버 전용 함수 |
| `ClientOnly` | 클라이언트 전용 함수 |
| `Server` | 서버에서 실행 (클라이언트 호출 시 서버에 요청) |
| `Client` | 클라이언트에서 실행 (서버 호출 시 클라이언트에 전달) |

### 📦 프로퍼티/함수 관련

| 배지 | 의미 |
|------|------|
| `HideFromInspector` | 프로퍼티 창에 미노출 (스크립트로만 접근) |
| `Yield` | 수행 중 스크립트 실행 중단 (비동기) |
| `Static` | 전역 접근 가능 |
| `ScriptOverridable` | 재정의 가능 함수 |
| `Abstract` | 추상화된 API (직접 생성 불가) |

### ⚠️ API 상태

| 배지 | 의미 |
|------|------|
| `Deprecated` | 더 이상 사용하지 않음 |
| `Preview` | 크리에이터 선공개 (정식 배포와 다를 수 있음) |

### 🎯 이벤트 공간

| 배지 | 의미 |
|------|------|
| `Space: Server` | 서버에서 이벤트 발생 |
| `Space: Client` | 클라이언트에서 이벤트 발생 |
| `Space: Editor` | 에디터에서 이벤트 발생 |
| `Space: All` | 서버/클라이언트 모두에서 발생 |

---

## 0.3 LogMessages 분류

| 접두사 | 레벨 | 설명 |
|--------|------|------|
| `LIA` | Info | 정보성 메시지 |
| `LWA` | Warning | 문제가 있지만 동작함 |
| `LEA` | Error | 정상 동작 불가 |

---

# Part 1: Components (100개+)

## 1.1 플레이어/캐릭터 관련

| Component | 설명 |
|-----------|------|
| `PlayerComponent` | 플레이어 엔티티 정의 |
| `PlayerControllerComponent` | 플레이어 조작 제어 |
| `MovementComponent` | 이동 기능. RigidbodyComponent 자동 감지하여 제어 |
| `AvatarRendererComponent` | 아바타 렌더링 |
| `AvatarGUIRendererComponent` | 아바타 GUI 렌더링 |
| `AvatarBodyActionSelectorComponent` | 아바타 몸 동작 선택 |
| `AvatarFaceActionSelectorComponent` | 아바타 표정 선택 |
| `AvatarStateAnimationComponent` | 아바타 상태 애니메이션 |
| `CostumeManagerComponent` | 코스튬 관리 |
| `NameTagComponent` | 이름표 표시 |
| `ChatComponent` | 채팅 기능 |
| `ChatBalloonComponent` | 채팅 말풍선 |

### 1.1.1 PlayerComponent
플레이어 엔티티를 정의하고 HP, 닉네임, 리스폰 등의 기본 기능을 제공합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 | 동기화 |
|:--|:--|:--|:--:|
| `Hp` | integer | 현재 체력 | Sync |
| `MaxHp` | integer | 최대 체력 | Sync |
| `Nickname` | string | 닉네임 | Sync |
| `ProfileCode` | string | 프로필 코드 (ReadOnly) | Sync |
| `PVPMode` | boolean | PVP 가능 여부 | Sync |
| `RespawnDuration` | float | 리스폰 대기 시간 | Sync |
| `RespawnPosition` | Vector3 | 리스폰 위치 | Sync |
| `UserId` | string | 유저 식별자 (ReadOnly) | Sync |

#### Methods
```lua
-- 상태 확인
boolean IsDead()

-- 이동 (Server)
void MoveToEntity(string entityID)
void MoveToEntityByPath(string worldPath)
void MoveToMapPosition(string mapID, Vector2 targetPosition)
void SetPosition(Vector3 position)
void SetWorldPosition(Vector3 worldPosition)

-- 리스폰/사망 처리
void ProcessDead(string targetUserId=nil) -- [Client]
void ProcessRevive(string targetUserId=nil) -- [Client]
void Respawn() -- [Overridable]
```

### 1.1.2 PlayerControllerComponent
플레이어의 입력과 액션(점프, 공격 등)을 제어합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `AlwaysMovingState` | boolean | 항상 걷기 애니메이션 재생 여부 |
| `FixedLookAt` | int32 | 시선 고정 방향 |
| `LookDirectionX` | float | 현재 바라보는 X축 방향 |

#### Methods
```lua
-- 액션 핸들러 (재정의 가능)
void ActionAttack()
void ActionCrouch()
void ActionDownJump()
void ActionEnterPortal()
void ActionJump()
void ActionSit()

-- 액션 키 매핑 (ClientOnly)
void SetActionKey(KeyboardKey key, string actionName, func conditionFunction=nil)
void RemoveActionKey(KeyboardKey key)
string GetActionName(KeyboardKey key)
```

### 1.1.3 AvatarRendererComponent
아바타 형태의 엔티티를 렌더링하는 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 | 동기화 |
|:--|:--|:--|:--:|
| `MaterialId` | string | 적용할 머티리얼 ID | Sync |
| `OrderInLayer` | int32 | 레이어 내 렌더링 순서 | - |
| `PlayRate` | float | 애니메이션 재생 속도 | Sync |
| `ShowDefaultWeaponEffects` | boolean | 무기 기본 이펙트/사운드 재생 여부 | Sync |
| `SortingLayer` | string | 렌더링 레이어 이름 | Sync |
| `Enable` | boolean | 활성화 여부 | Sync |

#### Methods
```lua
void ChangeMaterial(string materialId)
Entity GetAvatarRootEntity() -- [ClientOnly]
Entity GetBodyEntity() -- [ClientOnly]
Entity GetFaceEntity() -- [ClientOnly]
void PlayEmotion(EmotionalType emotionalType, float duration, string targetUserId=nil) -- [Client]
void SetAlpha(float alpha, string targetUserId=nil) -- [Client]
```

### 1.1.4 AvatarGUIRendererComponent
아바타를 UI 상에 렌더링하는 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Color` | Color | 틴트 색상 |
| `FlipX` | boolean | X축 반전 |
| `FlipY` | boolean | Y축 반전 |
| `MaterialId` | string | 머티리얼 ID |
| `PlayRate` | float | 재생 속도 |

### 1.1.5 AvatarStateAnimationComponent
아바타의 상태(State)에 따라 재생될 애니메이션을 관리합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `StateToAvatarBodyActionSheet` | SyncDictionary | 상태-액션 매핑 테이블 |
| `IsLegacy` | boolean | 레거시 지원 여부 |

### 1.1.6 AvatarActionSelector
* `AvatarBodyActionSelectorComponent`: 아바타 몸 동작 선택
* `AvatarFaceActionSelectorComponent`: 아바타 표정 선택

## 1.2 AI/인공지능

### 1.2.1 AIComponent
엔티티에 행동 트리(Behavior Tree) 기반의 AI를 부여하는 기본 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `IsLegacy` | boolean | 레거시 시스템 지원 여부 (Deprecated 예정) |
| `LogEnabled` | boolean | 행동 트리 실행 로그 출력 여부 (MakerOnly) |
| `UpdateAuthority` | UpdateAuthorityType | 업데이트 권한 (Server/Client) |
| `Enable` | boolean | 활성화 여부 |

#### Methods
```lua
-- 리프 노드(Action) 생성
BTNode CreateLeafNode(string nodeName, func<float> onBehaveFunction)

-- 특정 타입의 노드 생성
BTNode CreateNode(string nodeType, string nodeName=nil, func<float> onBehaveFunction=nil)

-- 루트 노드 설정
void SetRootNode(BTNode node)
```

### 1.2.2 AIChaseComponent
플레이어나 특정 대상을 자동으로 추적하는 AI 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `DetectionRange` | float | 추적 감지 거리 |
| `IsChaseNearPlayer` | boolean | 범위 내 가장 가까운 플레이어 자동 추적 여부 |
| `TargetEntityRef` | EntityRef | 추적 대상 엔티티 (ReadOnly) |

#### Methods
```lua
-- 현재 추적 대상 반환
Entity GetCurrentTarget()

-- 추적 대상 설정 (IsChaseNearPlayer는 false로 변경됨)
void SetTarget(Entity targetEntity)
```

### 1.2.3 AIWanderComponent
주변을 무작위로 배회하는 AI 컴포넌트입니다. 별도의 고유 프로퍼티는 없으나, AIComponent의 기본 기능을 상속받아 배회 동작을 수행합니다. StateComponent가 필요합니다.

#### Properties
*Inherits properties from `AIComponent`*

#### Methods
*Inherits methods from `AIComponent`*

## 1.3 변환/위치

| Component | 주요 프로퍼티 | 설명 |
|-----------|-------------|------|
| `TransformComponent` | Position(X,Y,Z), Rotation(Z), Scale | 위치, 크기, 회전 조정 |
| `UITransformComponent` | - | UI 요소의 위치/크기/회전 |

## 1.4 렌더링/그래픽

### 1.4.1 SpriteRendererComponent
스프라이트 또는 애니메이션 클립을 출력하는 핵심 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 | 동기화 |
|:--|:--|:--|:--:|
| `SpriteRUID` | string | 스프라이트/애니메이션 리소스 ID | Sync |
| `Color` | Color | 스프라이트 색상 (틴트) | Sync |
| `FlipX` | boolean | X축 반전 여부 | Sync |
| `FlipY` | boolean | Y축 반전 여부 | Sync |
| `DrawMode` | SpriteDrawMode | 그리기 모드 (Simple, Sliced, Tiled) | Sync |
| `TiledSize` | Vector2 | Tiled/Sliced 모드 크기 | Sync |
| `OrderInLayer` | int32 | 레이어 내 렌더링 순서 (높을수록 앞) | Sync |
| `SortingLayer` | string | 렌더링 레이어 이름 | Sync |
| `PlayRate` | float | 애니메이션 재생 속도 | Sync |
| `StartFrameIndex` | int32 | 애니메이션 시작 프레임 | Sync |
| `EndFrameIndex` | int32 | 애니메이션 끝 프레임 | Sync |
| `MaterialID` | string | 적용할 머티리얼 ID | Sync |
| `IgnoreMapLayerCheck` | boolean | 맵 레이어 자동 치환 무시 여부 | Sync |
| `Enable` | boolean | 컴포넌트 활성화 여부 | Sync |
| `Entity` | Entity | 소유 엔티티 (ReadOnly) | - |

#### Methods
```lua
-- 머티리얼 교체
void ChangeMaterial(string materialId)

-- 투명도 설정 (0.0 ~ 1.0)
void SetAlpha(float alpha)

-- [Inherited] 실행 환경 확인
boolean IsClient()
boolean IsServer()
```

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `SpriteAnimPlayerStartEvent` | 애니메이션 시작 시 |
| `SpriteAnimPlayerEndEvent` | 애니메이션 종료 시 |
| `SpriteAnimPlayerChangeFrameEvent` | 프레임 변경 시 |
| `SortingLayerChangedEvent` | SortingLayer 변경 시 |
| `OrderInLayerChangedEvent` | OrderInLayer 변경 시 |

#### 예제 코드
```lua
[server only]
void OnBeginPlay()
{
    -- 랜덤하게 스프라이트 변경
    local meso = _UtilLogic:RandomIntegerRange(1, 1500)
    local sprite = self.Entity.SpriteRendererComponent
    
    if meso < 100 then
        sprite.SpriteRUID = "000001" -- 동전
    else
        sprite.SpriteRUID = "000002" -- 지폐
    end
    
    -- 투명도 반으로 설정
    sprite:SetAlpha(0.5)
}
```

### 1.4.2 [목록] 기타 렌더링 컴포넌트
| Component | 설명 |
|-----------|------|
| `SpriteGUIRendererComponent` | GUI용 스프라이트 |
| `SkeletonRendererComponent` | 스켈레톤(Spine) 렌더링 |
| `SkeletonGUIRendererComponent` | GUI용 스켈레톤 |
| `PixelRendererComponent` | 픽셀(도트) 렌더링 |
| `PixelGUIRendererComponent` | GUI용 픽셀 |
| `LineRendererComponent` | 라인 렌더링 |
| `LineGUIRendererComponent` | GUI용 라인 |
| `PolygonRendererComponent` | 다각형 렌더링 |
| `PolygonGUIRendererComponent` | GUI용 다각형 |
| `TextRendererComponent` | 텍스트 렌더링 |
| `TextGUIRendererComponent` | GUI용 텍스트 |
| `RawImageRendererComponent` | Raw 이미지 (URL 등) |

## 1.5 물리/이동

| Component | 설명 |
|-----------|------|
| `RigidbodyComponent` | 물리 바디 |
| `PhysicsRigidbodyComponent` | 물리 리지드바디 |
| `PhysicsColliderComponent` | 물리 충돌체 |
| `PhysicsSimulatorComponent` | 물리 시뮬레이터 |
| `KinematicbodyComponent` | 키네마틱 바디 |
| `SideviewbodyComponent` | 사이드뷰 바디 |
| `DistanceJointComponent` | 거리 조인트 |
| `RevoluteJointComponent` | 회전 조인트 |
| `PrismaticJointComponent` | 직선 조인트 |
| `PulleyJointComponent` | 도르래 조인트 |
| `WeldJointComponent` | 용접 조인트 |
| `WheelJointComponent` | 바퀴 조인트 |
| `FootholdComponent` | 발판 |
| `CustomFootholdComponent` | 커스텀 발판 |

물리 엔진과 관련된 움직임, 충돌 처리 등을 담당하는 컴포넌트들입니다.


### 1.5.1 RigidbodyComponent
메이플스토리 스타일의 물리 움직임(중력, 가감속)을 제공합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Gravity` | float | 중력값 |
| `Mass` | float | 질량 |
| `WalkSpeed` | float | 지형 이동 최대 속도 |
| `JumpBias` | float | 점프 초기 속도 |
| `DownJumpSpeed` | float | 하향 점프 속도 |
| `AirAccelerationX` | float | 공중 가속도 (X축) |
| `AirDecelerationX` | float | 공중 감속도 (X축) |
| `KinematicMove` | boolean | 탑다운 이동 모드 여부 |
| `IsBlockVerticalLine` | boolean | 세로 지형 막힘 여부 |
| `IsolatedMove` | boolean | 발판 끝에서 떨어지지 않음 |

#### Methods
```lua
-- 이동/힘 적용
void AddForce(Vector2 forcePower)
void SetForce(Vector2 forcePower)
void Stop() -- [MovementComponent]
boolean DownJump()
boolean Jump()

-- 위치 설정
void SetPosition(Vector2 position)
void SetWorldPosition(Vector2 position)

-- 부착
void AttachTo(string entityId, Vector3 offset)
void Detach()

-- 정보 확인
Foothold GetCurrentFoothold()
boolean IsOnGround()
```

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `FootholdCollisionEvent` | 발판 충돌 시 |
| `FootholdEnterEvent` | 발판 진입 시 |
| `FootholdLeaveEvent` | 발판 이탈 시 |
| `RigidbodyAttachEvent` | AttachTo 되었을 때 |
| `RigidbodyDetachEvent` | Detach 되었을 때 |

### 1.5.2 MovementComponent
이동 입력을 받아 Rigidbody 등을 제어하는 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 | 동기화 |
|:--|:--|:--|:--:|
| `InputSpeed` | float | 입력에 따른 이동 속력 | Sync |
| `JumpForce` | float | 점프 힘 | Sync |
| `IsClimbPaused` | boolean | 등반 중지 상태 (ReadOnly) | Sync |

#### Methods
```lua
-- 이동 제어
void MoveToDirection(Vector2 direction, float deltaTime)
boolean Jump()
boolean DownJump()
void Stop()

-- 상태 확인
boolean IsFaceLeft()
```

### 1.5.3 TriggerComponent
충돌 영역을 설정하고 감지하는 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `ColliderType` | ColliderType | 충돌체 형태 (Box, Circle, Polygon) |
| `BoxSize` | Vector2 | Box 형태 크기 |
| `CircleRadius` | float | Circle 형태 반지름 |
| `ColliderOffset` | Vector2 | 충돌체 중심 오프셋 |
| `CollisionGroup` | CollisionGroup | 충돌 그룹 |
| `IsPassive` | boolean | 수동 충돌 검사 여부 (성능 최적화) |
| `Enable` | boolean | 활성화 여부 |

#### Methods (Overridable)
```lua
void OnEnterTriggerBody(TriggerEnterEvent enterEvent)
void OnLeaveTriggerBody(TriggerLeaveEvent leaveEvent)
void OnStayTriggerBody(TriggerStayEvent stayEvent)
```

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `TriggerEnterEvent` | 충돌 영역 진입 시 |
| `TriggerLeaveEvent` | 충돌 영역 이탈 시 |
| `TriggerStayEvent` | 충돌 영역 유지 시 (매 프레임) |
| `RawImageGUIRendererComponent` | GUI용 Raw 이미지 |
| `ImageComponent` | 이미지 표시 |
| `BackgroundComponent` | 배경 렌더링 |
| `CameraComponent` | 카메라 제어 |
| `MaskComponent` | 마스크 효과 (자식 클리핑) |
| `ClimbableSpriteRendererComponent` | 사다리/로프 등 등반 가능 스프라이트 |
| `OverlayLightComponent` | 오버레이 조명 효과 |
| `LightComponent` | 일반 조명 |

## 1.6 파티클/이펙트

| Component | 설명 |
|-----------|------|
| `BaseParticleComponent` | 파티클 기본 (추상) |
| `BasicParticleComponent` | 기본 파티클 |
| `AreaParticleComponent` | 영역 파티클 |
| `SpriteParticleComponent` | 스프라이트 파티클 |
| `UIBaseParticleComponent` | UI 파티클 기본 |
| `UIBasicParticleComponent` | UI 기본 파티클 |
| `UIAreaParticleComponent` | UI 영역 파티클 |
| `UISpriteParticleComponent` | UI 스프라이트 파티클 |
| `HitEffectSpawnerComponent` | 피격 이펙트 생성 |
| `DamageSkinSpawnerComponent` | 데미지 스킨 생성 |

## 1.7 전투/상호작용

| Component | 설명 |
|-----------|------|
| `AttackComponent` | 공격 기능 |
| `HitComponent` | 피격 처리 |
| `DamageSkinComponent` | 데미지 스킨 표시 |
| `DamageSkinSettingComponent` | 데미지 스킨 설정 |
| `InteractionComponent` | 상호작용 기능 |
| `TriggerComponent` | 트리거 영역 감지 |

## 1.8 애니메이션/트윈

| Component | 설명 |
|-----------|------|
| `StateAnimationComponent` | 상태 기반 애니메이션 |
| `StateComponent` | 상태 관리 |
| `StateStringToAvatarActionComponent` | 상태→아바타 동작 변환 |
| `StateStringToMonsterActionComponent` | 상태→몬스터 동작 변환 |
| `TweenBaseComponent` | 트윈 기본 (추상) |
| `TweenCircularComponent` | 원형 트윈 |
| `TweenFloatingComponent` | 부유 트윈 |
| `TweenLineComponent` | 직선 트윈 |

### 1.8.1 StateAnimationComponent
상태(State) 변화에 따라 재생될 애니메이션을 지정하는 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `ActionSheet` | SyncDictionary | 애니메이션 이름과 Clip 매핑 (Legacy) |

#### Methods
```lua
-- 상태 변경 이벤트 수신
void ReceiveStateChangeEvent(IEventSender sender, StateChangeEvent stateEvent)

-- 매핑 관리
void SetActionSheet(string key, string animationClipRuid)
void RemoveActionSheet(string key)
```

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `AnimationClipEvent` | 애니메이션 클립 변경 시 |




## 1.9 맵/타일

| Component | 설명 |
|-----------|------|
| `MapComponent` | 맵 정의 |
| `MapLayerComponent` | 맵 레이어 |
| `TileMapComponent` | 타일맵 |
| `RectTileMapComponent` | 사각형 타일맵 |
| `ClimbableComponent` | 등반 가능 오브젝트 |
| `PortalComponent` | 포탈 |
| `SpawnLocationComponent` | 스폰 위치 |
| `WorldComponent` | 월드 컴포넌트 |
| `GridComponent` | 그리드 |

### 1.9.1 PortalComponent
플레이어를 다른 위치나 맵으로 이동시키는 포탈 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `PortalEntityRef` | EntityRef | 연결된 목적지 포탈 엔티티 |
| `BoxSize`, `BoxOffset` | Vector2 | 충돌 영역 크기 및 위치 |
| `CollisionGroup` | CollisionGroup | 충돌 그룹 |

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `PortalUseEvent` | 포탈 이용 시 |


## 1.11 사운드/멀티미디어

### 1.11.1 SoundComponent
효과음 또는 배경음악을 재생하고 관리합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 | 동기화 |
|:--|:--|:--|:--:|
| `AudioClipRUID` | string | 오디오 리소스 ID | Sync |
| `Bgm` | boolean | 배경음악 여부 | Sync |
| `Loop` | boolean | 반복 재생 여부 | Sync |
| `Volume` | float | 음량 (0~1) | Sync |
| `Pitch` | float | 음높이/속도 (0~3) | Sync |
| `PlayOnEnable` | boolean | 활성화 시 자동 재생 | Sync |
| `Mute` | boolean | 음소거 여부 | Sync |
| `HearingDistance` | float | 소리 감지 거리 | Sync |

#### Methods
```lua
void Play(string targetUserId=nil)
void Stop(string targetUserId=nil)
void Pause(string targetUserId=nil)
void Resume(string targetUserId=nil)

-- 재생 정보
boolean IsPlaying()
float GetTimePosition() -- [Client]
float GetTotalTime() -- [Client]
void SetTimePosition(float time) -- [Client]

-- 설정
void SetListenerEntity(Entity entity) -- [Client]
```


| Component | 설명 |
|-----------|------|
| `UIGroupComponent` | UI 그룹 |
| `ButtonComponent` | 버튼 (KeyCode 바인딩 가능) |
| `SliderComponent` | 슬라이더 |
| `TextComponent` | 텍스트 (TextAlignment 지원) |
| `TextInputComponent` | 텍스트 입력 |
| `TextGUIRendererInputComponent` | GUI 텍스트 입력 |
| `GridViewComponent` | 그리드 뷰 |
| `ScrollLayoutGroupComponent` | 스크롤 레이아웃 |
| `CanvasGroupComponent` | 캔버스 그룹 |
| `JoystickComponent` | 조이스틱 |
| `TouchReceiveComponent` | 터치 수신 |
| `UITouchReceiveComponent` | UI 터치 수신 |

### 1.10.1 UITransformComponent
UI 엔티티의 위치, 크기, 회전을 제어하는 필수 컴포넌트입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `AnchoredPosition` | Vector2 | 앵커 기준 상대 위치 |
| `SizeDelta` | Vector2 | 앵커 기준 크기 변화량 |
| `AnchorMin` | Vector2 | 앵커 최소 좌표 (0~1) |
| `AnchorMax` | Vector2 | 앵커 최대 좌표 (0~1) |
| `Pivot` | Vector2 | 회전/크기 조절의 중심점 |

### 1.10.2 ButtonComponent
클릭/터치 가능한 버튼 기능을 제공합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Transition` | TransitionType | 상태 변화 효과 (ColorTint, SpriteSwap 등) |
| `TargetGraphic` | Entity | 효과 대상 그래픽 엔티티 |
| `NormalColor`, `HighlightedColor` | Color | 상태별 색상 |
| `PressedColor`, `DisabledColor` | Color | 상태별 색상 |
| `ClickSoundId` | string | 클릭 사운드 RUID |
| `Enable` | boolean | 활성화 여부 |

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `ButtonClickEvent` | 버튼 클릭 시 |

### 1.10.3 TextComponent
UI에 텍스트를 표시합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Text` | string | 출력할 문자열 |
| `Font` | string | 폰트 이름 |
| `FontSize` | int32 | 폰트 크기 |
| `Alignment` | TextAnchor | 텍스트 정렬 방식 |
| `Color` | Color | 텍스트 색상 |
| `LineSpacing` | float | 줄 간격 |
| `Enable` | boolean | 활성화 여부 |

### 1.10.4 ImageComponent
UI에 이미지나 스프라이트를 표시합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `ImageRUID` | string | 이미지 RUID |
| `Color` | Color | 틴트 색상 |
| `Type` | ImageType | 표시 방식 (Simple, Sliced, Tiled, Filled) |
| `FillAmount` | float | Filled 타입 시 채움 비율 (0~1) |
| `PreserveAspect` | boolean | 원본 비율 유지 여부 |
| `RaycastTarget` | boolean | 입력 감지 여부 |

#### Methods
```lua
void SetNativeSize() -- 원본 크기로 설정
```

### 1.10.5 TextInputComponent
사용자로부터 텍스트 입력을 받습니다. ButtonComponent와 함께 사용하여 입력창을 구성할 수 있습니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Text` | string | 현재 입력된 텍스트 |
| `PlaceHolder` | string | 입력 전 안내 문구 |
| `CharacterLimit` | int32 | 최대 글자 수 |
| `ContentType` | InputContentType | 입력 타입 (Standard, Password, Email 등) |
| `LineType` | InputLineType | 줄 바꿈 설정 (SingleLine, MultiLine 등) |
| `IsFocused` | boolean | 포커스 여부 (ReadOnly) |

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `TextInputEndEditEvent` | 입력 종료 시 |
| `TextInputSubmitEvent` | 엔터 키 입력 시 |
| `TextInputValueChangeEvent` | 값 변경 시 |

### 1.10.6 SliderComponent
수치를 조절할 수 있는 슬라이더 바입니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `Value` | float | 현재 값 |
| `MinValue` | float | 최소 값 |
| `MaxValue` | float | 최대 값 |
| `Direction` | SliderDirection | 슬라이더 방향 (LeftToRight, BottomToTop 등) |
| `UseIntegerValue` | boolean | 정수 값만 사용 여부 |

#### Events
| 이벤트 | 설명 |
|:--|:--|
| `SliderValueChangedEvent` | 값 변경 시 |

### 1.10.7 ScrollLayoutGroupComponent
스크롤 가능한 뷰를 구성하고 자식 요소들을 자동 정렬합니다.

#### Properties
| 프로퍼티 | 타입 | 설명 |
|:--|:--|:--|
| `CellSize` | Vector2 | 그리드 셀 크기 |
| `Spacing` | Vector2 | 아이템 간 간격 |
| `Constraint` | GridLayoutConstraint | 행/열 고정 설정 |
| `UseScroll` | boolean | 스크롤 기능 사용 여부 |
| `HorizontalScrollBarDirection` | Direction | 가로 스크롤바 방향 |
| `VerticalScrollBarDirection` | Direction | 세로 스크롤바 방향 |

#### Methods
```lua
void SetScrollNormalizedPosition(UITransformAxis axis, float value)
void ResetScrollPosition(UITransformAxis axis)
```

## 1.11 사운드/멀티미디어

| Component | 설명 |
|-----------|------|
| `SoundComponent` | 사운드 재생 |
| `YoutubePlayerCommonComponent` | YouTube 공통 |
| `YoutubePlayerGUIComponent` | YouTube GUI |
| `YoutubePlayerWorldComponent` | YouTube 월드 |
| `WebViewComponent` | 웹뷰 |
| `WebSpriteComponent` | 웹 스프라이트 |

## 1.12 기타

| Component | 설명 |
|-----------|------|
| `TagComponent` | 태그 부여 |
| `InventoryComponent` | 인벤토리 관리 |
| `DirectionSynchronizerComponent` | 방향 동기화 |

---

# Part 2: Services (시스템 서비스)

## 2.1 _EntityService

엔티티 탐색, 생성, 삭제를 위한 핵심 서비스입니다.

| 함수 | 설명 |
|------|------|
| `GetEntityByPath(path)` | 월드 경로로 엔티티 찾기 |
| `GetEntityByName(name)` | 이름으로 엔티티 찾기 |
| `GetEntitiesByTag(tag)` | 태그로 엔티티들 찾기 |
| `GetEntityByModelId(modelId)` | 모델 ID로 엔티티 찾기 |
| `Destroy(entity)` | 엔티티 즉시 파괴 |
| `Destroy(entity, delay)` | 지연 후 엔티티 파괴 |
| `SpawnByModelId(modelId, pos)` | 모델 ID로 스폰 |
| `IsValid(entity)` | 엔티티 유효성 확인 |

```lua
-- 사용 예시
local player = _EntityService:GetEntityByName("Player")
_EntityService:Destroy(enemy)
local npc = _EntityService:SpawnByModelId("model_npc_01", Vector2(100, 100))
```

---

## 2.2 _RoomService

룸 생성, 사용자 이동, 룸 간 통신을 담당합니다.

| 함수 | 설명 |
|------|------|
| `CreateInstanceRoom(mapId)` | 인스턴스 룸 생성 |
| `MoveUsersToInstanceRoom(users, roomId, mapId)` | 인스턴스 룸으로 이동 |
| `MoveUsersToStaticRoom(users, mapId)` | 정적 룸으로 이동 |
| `GetSharedMemory(key)` | 공유 메모리 가져오기 |
| `SetSharedMemory(key, value)` | 공유 메모리 설정 |
| `SendEventToAllRooms(event)` | 모든 룸에 이벤트 전송 |
| `RegisterRoomEventHandler(handler)` | 룸 이벤트 핸들러 등록 |

---

## 2.3 _InputService

사용자 입력(키보드, 마우스, 터치) 처리 서비스입니다.

| 함수 | 설명 |
|------|------|
| `IsKeyPressed(keyCode)` | 키 누름 상태 확인 |
| `GetMousePosition()` | 마우스 위치 |
| `IsMouseOverUI()` | UI 위에 마우스 있는지 |
| `SetCursorVisible(visible)` | 커서 표시/숨김 |
| `SetCursorImage(image)` | 커서 이미지 변경 |

| 이벤트 | 설명 |
|--------|------|
| `KeyDownEvent` | 키 누름 |
| `KeyUpEvent` | 키 뗌 |
| `MouseScrollEvent` | 마우스 스크롤 |
| `TouchEvent` | 터치 (모바일) |
| `MultiTouchEvent` | 멀티터치 (모바일) |

---

## 2.4 _HttpService

외부 HTTP 요청 서비스입니다.

| 함수 | 설명 |
|------|------|
| `GetAsync(url)` | GET 요청 |
| `GetAsync(url, headers)` | 헤더 포함 GET |
| `PostAsync(url, data)` | POST 요청 |
| `PostAsync(url, data, headers)` | 헤더 포함 POST |

**제한 사항:**
- 요청 수: 분당 **120회**
- 타임아웃: **30초**
- TLS: **1.2 이상**
- 응답 버퍼: **10MB**

```lua
-- 사용 예시
local response = _HttpService:GetAsync("https://api.example.com/data")
log(response)
```

---

## 2.5 _WorldInstanceService

월드 인스턴스 간 통신 및 데이터 공유 서비스입니다.

| 함수 | 설명 |
|------|------|
| `GetSharedMemory(key)` | 월드 인스턴스 공유 메모리 가져오기 |
| `SetSharedMemory(key, value)` | 월드 인스턴스 공유 메모리 설정 |
| `SendEventToAllInstances(event)` | 모든 인스턴스에 이벤트 전송 |
| `SendEventToInstance(instanceId, event)` | 특정 인스턴스에 이벤트 전송 |
| `RegisterEventHandler(handler)` | 이벤트 핸들러 등록 |

---

## 2.6 _DataStorageService

데이터 영속 저장 서비스입니다.

| 함수 | 설명 |
|------|------|
| `GetCreatorDataStorage()` | 크리에이터 데이터 저장소 |
| `GetUserDataStorage(userId)` | 유저별 데이터 저장소 |
| `GetGlobalDataStorage()` | 전역 데이터 저장소 |
| `DeleteCreatorDataStorage()` | 크리에이터 데이터 동기 삭제 |
| `DeleteCreatorDataStorageAsync()` | 크리에이터 데이터 비동기 삭제 |

**데이터 저장소 종류:**
| 저장소 | 범위 | 설명 |
|--------|------|------|
| `CreatorDataStorage` | 크리에이터 | 크리에이터 전용 데이터 |
| `UserDataStorage` | 유저별 | 각 유저의 개인 데이터 |
| `GlobalDataStorage` | 월드 전체 | 모든 유저가 접근 가능한 데이터 |

---

## 2.7 _UserService

유저 관리 서비스입니다.

| 프로퍼티 | 설명 |
|----------|------|
| `LocalPlayer` | 현재 플레이어 (ClientOnly) |
| `UserEntities` | 모든 유저 엔티티 목록 (Key: UserId, Value: Entity) |
| `Users` | 모든 유저 정보 (UserId, ProfileName, ProfileCode) |

| 함수 | 설명 |
|------|------|
| `GetUserByProfileCode(code)` | 프로필 코드로 유저 찾기 |
| `GetUserByUserId(userId)` | 유저 ID로 찾기 |
| `GetUserCount()` | 현재 접속 유저 수 |
| `GetUsersByMap(mapId)` | 특정 맵의 유저들 |

| 이벤트 | 설명 |
|--------|------|
| `UserEnterEvent` | 유저 입장 시 |
| `UserLeaveEvent` | 유저 퇴장 시 |

---

## 2.8 추가 Services (16개)

| Service | 설명 |
|---------|------|
| `_BadgeService` | 배지 관리 |
| `_CameraService` | 카메라 제어 |
| `_CollisionService` | 충돌 그룹 관리 |
| `_DamageSkinService` | 데미지 스킨 관리 |
| `_DataService` | 데이터 관리 |
| `_DynamicMapService` | 동적 맵 생성/관리 |
| `_EditorService` | 에디터 전용 기능 (MakerOnly) |
| `_EffectService` | 이펙트 생성/관리 |
| `_EntryService` | 월드 진입 관리 |
| `_InstanceMapService` | 인스턴스 맵 관리 |
| `_ItemService` | 아이템 관리 |
| `_LocalizationService` | 다국어 지원 |
| `_MobileShareService` | 모바일 공유 기능 |
| `_SoundService` | 사운드 재생/관리 |
| `_SpawnService` | 스폰 관리 |
| `_TeleportService` | 텔레포트 관리 |
| `_TimerService` | 타이머/시간 관리 |
| `_WorldShopService` | 월드 상점 관리 |

> **📌 총 Services 개수: 23개**

---

# Part 3: Events

## 3.1 주요 이벤트 목록

| Event | 공간 | 설명 |
|-------|------|------|
| `UserEnterEvent` | Server | 유저 입장 |
| `UserLeaveEvent` | Server | 유저 퇴장 |
| `TriggerEnterEvent` | All | 트리거 영역 진입 |
| `TriggerStayEvent` | All | 트리거 영역 머무름 |
| `TriggerLeaveEvent` | All | 트리거 영역 이탈 |
| `KeyDownEvent` | Client | 키 누름 |
| `KeyUpEvent` | Client | 키 뗌 |
| `ActionStateChangedEvent` | All | 액션 상태 변경 |
| `AnimationClipEvent` | All | 애니메이션 클립 이벤트 |
| `AttackEvent` | All | 공격 이벤트 |
| `HitEvent` | All | 피격 이벤트 |

## 3.2 추가 이벤트 (카테고리별)

### 상호작용 이벤트
| Event | 설명 |
|-------|------|
| `InteractionEnterEvent` | 상호작용 영역 진입 |
| `InteractionLeaveEvent` | 상호작용 영역 이탈 |

### 애니메이션 이벤트
| Event | 설명 |
|-------|------|
| `SpriteAnimPlayerStartEvent` | 스프라이트 애니메이션 시작 |
| `SpriteAnimPlayerEndEvent` | 스프라이트 애니메이션 종료 |
| `SpriteAnimPlayerChangeFrameEvent` | 프레임 변경 |
| `SpriteAnimPlayerEndFrameEvent` | 마지막 프레임 도달 |
| `SpriteGUIAnimPlayerStartEvent` | GUI 스프라이트 애니메이션 시작 |
| `SpriteGUIAnimPlayerEndEvent` | GUI 스프라이트 애니메이션 종료 |

## 3.3 커스텀 이벤트 생성

MyDesk에서 `Create EventType`을 통해 커스텀 이벤트를 생성할 수 있습니다.

---

# Part 4: Logics (게임 로직)

## 4.1 math API

| 속성 | 타입 | 설명 |
|------|------|------|
| `math.pi` | number | π (3.14159...) |
| `math.huge` | number | 최대 실수값 |
| `math.mininteger` | integer | 최소 정수값 |
| `math.maxinteger` | integer | 최대 정수값 |

| 함수 | 설명 |
|------|------|
| `math.abs(x)` | 절대값 |
| `math.ceil(x)` | 올림 |
| `math.floor(x)` | 내림 |
| `math.sqrt(x)` | 제곱근 |
| `math.exp(x)` | e^x |
| `math.log(x)` | 자연 로그 |
| `math.min(x, ...)` | 최소값 |
| `math.max(x, ...)` | 최대값 |
| `math.modf(x)` | 정수부, 소수부 분리 |
| `math.sin(x)`, `cos(x)`, `tan(x)` | 삼각함수 |
| `math.asin(x)`, `acos(x)`, `atan(x)` | 역삼각함수 |
| `math.deg(x)` | 라디안→도 |
| `math.rad(x)` | 도→라디안 |
| `math.random()` | [0,1) 난수 |
| `math.random(n)` | [1,n] 정수 난수 |
| `math.random(m, n)` | [m,n] 정수 난수 |
| `math.randomseed(x)` | 난수 시드 설정 |
| `math.ult(m, n)` | 부호없는 정수 비교 |

---

## 4.2 string API

| 함수 | 설명 |
|------|------|
| `string.len(s)` | 길이 |
| `string.upper(s)` | 대문자 변환 |
| `string.lower(s)` | 소문자 변환 |
| `string.reverse(s)` | 역순 |
| `string.sub(s, i, j)` | 부분 문자열 |
| `string.find(s, pattern, init, plain)` | 패턴 찾기 |
| `string.gsub(s, pattern, repl, n)` | 패턴 치환 |
| `string.gmatch(s, pattern)` | 패턴 반복자 |
| `string.format(fmt, ...)` | 포맷 문자열 |
| `string.byte(s, i, j)` | 문자→숫자 코드 |
| `string.char(...)` | 숫자 코드→문자 |
| `string.rep(s, n, sep)` | 반복 연결 |

---

## 4.3 table API

| 함수 | 설명 |
|------|------|
| `table.insert(t, value)` | 끝에 추가 |
| `table.insert(t, pos, value)` | 위치에 삽입 |
| `table.remove(t, pos)` | 제거 |
| `table.sort(t, comp)` | 정렬 |
| `table.concat(t, sep, i, j)` | 문자열 연결 |
| `table.move(a1, f, e, t, a2)` | 요소 이동 |
| `table.pack(...)` | 테이블로 패킹 |
| `table.unpack(t, i, j)` | 테이블 언패킹 |
| `table.keys(t)` | 키 목록 반환 |
| `table.values(t)` | 값 목록 반환 |
| `table.clear(t)` | 모든 값 nil로 설정 |
| `table.initialize(t1, t2)` | t1을 t2로 초기화 |
| `table.create(size, value)` | 배열 생성 |

---

## 4.4 Lua 전역 함수

| 함수 | 설명 |
|------|------|
| `pairs(t)` | 테이블(사전) 순회. 순서 보장 안됨 |
| `ipairs(t)` | 배열 순회. 인덱스 1부터 순차적 |
| `type(v)` | 값의 타입 반환 ("table", "integer", "float", "boolean", "nil" 등) |
| `tostring(v)` | 값→문자열 변환 |
| `tonumber(v)` | 값→숫자 변환 |
| `log(msg)` | 콘솔 출력 **(print 대신 사용)** |
| `wait(sec)` | 스크립트 실행 대기 (Yield) |

> **⚠️ 주의**: `print()` 함수 대신 `log()` 함수를 사용해야 합니다!

---

## 4.5 MSW 전용 전역 객체

| 객체 | 설명 |
|------|------|
| `self` | 현재 스크립트 컴포넌트 |
| `self.Entity` | 스크립트가 부착된 엔티티 |
| `_EntityService` | 엔티티 관리 서비스 |
| `_RoomService` | 룸 관리 서비스 |
| `_InputService` | 입력 서비스 |
| `_HttpService` | HTTP 요청 서비스 |
| `_WorldInstanceService` | 월드 인스턴스 서비스 |
| `_DataStorageService` | 데이터 저장 서비스 |
| `_UserService` | 유저 관리 서비스 |
| `Vector2` / `Vector3` | 벡터 타입 |
| `Color` | 색상 타입 |

---

# Part 5: Misc (고유 타입)

| 타입 | 설명 |
|------|------|
| `Vector2` | 2D 벡터 (x, y) |
| `Vector2Int` | 2D 정수 벡터 |
| `Vector3` | 3D 벡터 (x, y, z) |
| `Vector4` | 4D 벡터 (Color로도 사용) |
| `Color` | RGBA 색상 |
| `Entity` | 게임 오브젝트 컨테이너 |
| `Component` | 기능 단위 (엔티티에 부착) |
| `ComponentRef` | 컴포넌트 참조 |
| `DateTime` | 날짜/시간 |
| `TimeSpan` | 시간 간격 |
| `RectOffset` | 사각형 오프셋 (상하좌우) |

## Vector2 주요 함수

| 함수 | 설명 |
|------|------|
| `Vector2.Distance(a, b)` | 거리 계산 |
| `Vector2.Angle(a, b)` | 두 벡터 사이 각도 |
| `Vector2.Normalize(v)` | 정규화 |
| `ToVector3()` | Vector3(x, y, 0)으로 변환 |

---

# Part 6: Enums (열거형)

## 6.1 KeyboardKey (KeyCode)

| 키 | 값 | 키 | 값 |
|---|---|---|---|
| Backspace | 8 | Tab | 9 |
| Return (Enter) | 13 | Space | 32 |
| A-Z | 65-90 | 0-9 | 48-57 |
| F1-F12 | 112-123 | NumPad 0-9 | 96-105 |
| Up | 38 | Down | 40 |
| Left | 37 | Right | 39 |
| LeftShift | 160 | RightShift | 161 |
| LeftCtrl | 162 | RightCtrl | 163 |

## 6.2 CollisionGroup

| 그룹 | 설명 |
|------|------|
| `Default` | 기본 충돌 그룹 |
| `TriggerBox` | 트리거 박스 그룹 |
| `HitBox` | 히트박스 그룹 |

> 최대 **15개**의 커스텀 충돌 그룹 생성 가능

## 6.3 ColliderType

물리 충돌체의 모양을 정의합니다.

| 값 | 설명 |
|----|------|
| `Undefined` | 미정의 |
| `Box` | 박스형 |
| `Circle` | 원형 |
| `Polygon` | 다각형 |

## 6.4 BodyType

물리 바디의 타입을 정의합니다.

| 값 | 설명 |
|----|------|
| `Static` | 정적 (움직이지 않음) |
| `Dynamic` | 동적 (물리 엔진 제어) |
| `Kinematic` | 키네마틱 (스크립트 제어) |

## 6.5 MapleAvatarBodyActionState

아바타 액션 상태를 정의합니다.

| 값 | 설명 |
|----|------|
| `Invalid` | 무효 |
| `Stand` | 서있기 |
| `Walk` | 걷기 |
| `Attack` | 공격 |
| `Alert` | 경계 |
| `Crouch` | 앉기 |
| `Fall` | 낙하 |
| `Sit` | 앉아있기 |
| `Rope` | 로프 타기 |
| `Ladder` | 사다리 타기 |
| `Dead` | 사망 |
| `Blink` | 깜빡임 |
| `Fly` | 비행 |
| `Heal` | 회복 |
| `Hit` | 피격 |

## 6.6 TextAlignmentType

텍스트 정렬 타입입니다.

| 값 | 설명 |
|----|------|
| `UpperLeft` | 좌상단 |
| `UpperCenter` | 상단 중앙 |
| `UpperRight` | 우상단 |
| `MiddleLeft` | 중앙 좌측 |
| `MiddleCenter` | 정중앙 |
| `MiddleRight` | 중앙 우측 |
| `LowerLeft` | 좌하단 |
| `LowerCenter` | 하단 중앙 |
| `LowerRight` | 우하단 |

---

# Part 7: LogMessages (에러 코드 레퍼런스)

> 스크립트 실행 중 발생하는 로그 메시지 코드 전체 목록입니다.
> 접두사: `LIA`(Info), `LWA`(Warning), `LEA`(Error)

---

## 7.1 Error Level (LEA-XXXX) - 약 80개

정상 동작 불가 상태의 에러입니다. 반드시 수정이 필요합니다.

### 구문 분석 에러 (1001-1013)

| ID | 이름 | 설명 |
|----|------|------|
| `LEA-1001` | ExpectedSymbol | 코드 구성에 필요한 심볼 누락 |
| `LEA-1002` | NoReturnStatement | 반환값 필요 함수에 반환문 없음 |
| `LEA-1003` | NeedPairKeyword | 쌍이 맞지 않음 (if-end 등) |
| `LEA-1004` | DuplicateLabel | 라벨 중복 정의 |
| `LEA-1005` | UnexpectedSymbol | 예상치 못한 심볼 사용 |
| `LEA-1006` | InvalidString | 유효하지 않은 문자열 |
| `LEA-1007` | UnfinishedString | 끝나지 않은 문자열 |
| `LEA-1008` | InvalidEscapeSequense | 유효하지 않은 이스케이프 시퀀스 |
| `LEA-1009` | FunctionArgumentExpected | 함수 인수 누락 |
| `LEA-1010` | UseVarargOutsideVarargFunction | 가변인자 없는 함수에서 `...` 사용 |
| `LEA-1011` | JumpScopeOfLocal | goto-label 사이 로컬 변수 선언 |
| `LEA-1012` | NoVisibleLabel | label을 찾을 수 없음 |
| `LEA-1013` | NotAllowMultipleCompoundAssignment | 다중 복합 할당 불가 |

### 타입/함수 호출 에러 (1101-1123)

| ID | 이름 | 설명 |
|----|------|------|
| `LEA-1101` | UnavailableMethodCall | `.` 대신 `:` 사용 필요 |
| `LEA-1102` | TooManyParameter | 인수 개수 초과 |
| `LEA-1103` | ParameterTypeMismatch | 매개변수 타입 불일치 |
| `LEA-1104` | AssignTypeMismatch | 할당 타입 불일치 |
| `LEA-1105` | TableKeyTypeMismatch | 테이블 키 타입 불일치 |
| `LEA-1107` | ReturnValueFromVoidFunction | void 함수에서 값 반환 |
| `LEA-1108` | AssignToReadonlyProperty | **읽기 전용 프로퍼티에 할당** |
| `LEA-1117` | AnnotationNotFound | Annotation 없음 |
| `LEA-1118` | AnnotationTypeNotFound | Annotation 타입 없음 |
| `LEA-1120` | ReturnTypeMismatch | 반환 타입 불일치 |
| `LEA-1121` | NotEnoughArgument | 필수 인수 부족 |
| `LEA-1123` | ObsoleteAPIUsed | **폐기된 API 사용 (치명적!)** |

### 런타임 연산 에러 (2001-2011)

| ID | 이름 | 설명 |
|----|------|------|
| `LEA-2001` | AttemptToPerformArithmetic | 산술 연산 불가 타입 |
| `LEA-2002` | AttemptToGetLength | 길이 연산 불가 타입 |
| `LEA-2003` | AttemptToConcatenate | 문자열 연결 불가 타입 |
| `LEA-2004` | AttemptToCompare | 비교 연산 불가 타입 |
| `LEA-2005` | BadArgument | 잘못된 인수 |
| `LEA-2006` | ChainTooLong | 메타테이블 체인 과다 |
| `LEA-2007` | AttemptToIndex | 인덱싱 불가 타입 |
| `LEA-2008` | ForInitNeedNumber | for문 초기값 타입 오류 |
| `LEA-2009` | ForStepNeedNumber | for문 증감값 타입 오류 |
| `LEA-2010` | ForLimitNeedNumber | for문 제한값 타입 오류 |
| `LEA-2011` | AttemptToCall | 함수 호출 불가 타입 |

### 시스템/런타임 에러 (3001-3056)

| ID | 이름 | 설명 |
|----|------|------|
| `LEA-3001` | NotSupported | 지원하지 않는 기능 |
| `LEA-3002` | InvalidOperation | 현재 상태에서 유효하지 않은 호출 |
| `LEA-3003` | OutOfRange | 허용 범위 초과 |
| `LEA-3004` | MissingComponent | **컴포넌트 미존재** |
| `LEA-3005` | InvalidArgument | 유효하지 않은 인수 |
| `LEA-3006` | ArgumentNil | 인수가 nil |
| `LEA-3007` | ArgumentNilOrEmpty | 인수가 nil 또는 빈 문자열 |
| `LEA-3011` | NotFound | 찾을 수 없음 (문화권, 인덱스 등) |
| `LEA-3012` | MissingLayerOrder | LayerOrder 없음 |
| `LEA-3013` | CannotCreate | 생성 불가 (Layer, 인스턴스 룸 등) |
| `LEA-3014` | SignatureMismatch | 시그니처 불일치 |
| `LEA-3015` | CannotLoad | 로드 불가 (URL, 리소스, 데미지 스킨 등) |
| `LEA-3016` | InvalidFormat | 유효하지 않은 형식 |
| `LEA-3018` | InvalidData | 유효하지 않은 데이터 |
| `LEA-3021` | InvalidValue | 유효하지 않은 값 |
| `LEA-3022` | InvalidExecSpace | 유효하지 않은 실행공간 |
| `LEA-3023` | TypeMismatch | 타입 불일치 |
| `LEA-3024` | RequestFailed | 요청 실패 |
| `LEA-3027` | NotYetValid | 아직 유효하지 않음 |
| `LEA-3028` | MissingModel | 모델 미존재 |
| `LEA-3030` | InvalidType | 유효하지 않은 타입 |
| `LEA-3031` | FailedSendToServer | 서버 전송 실패 |
| `LEA-3032` | FailedSendToClient | 클라이언트 전송 실패 |
| `LEA-3033` | NilReference | **nil 참조** |
| `LEA-3034` | MissingFunction | 함수 미존재 |
| `LEA-3035` | InvalidStatus | 유효하지 않은 상태 |
| `LEA-3036` | InvalidCast | 값 변환 불가 |
| `LEA-3037` | MissingEssentialColumn | 필수 열 미존재 |
| `LEA-3038` | DuplicateComponent | 컴포넌트 중복 |
| `LEA-3039` | DuplicateName | 이름 중복 |
| `LEA-3040` | OutOfCurrentMap | 현재 맵 벗어남 |
| `LEA-3041` | NotRegistered | 미등록 (Service, Logic, Context 등) |
| `LEA-3042` | NotInitialized | 초기화되지 않음 |
| `LEA-3043` | MissingMapLayer | MapLayer 미존재 |
| `LEA-3044` | InvalidSerialization | 직렬화 불가 |
| `LEA-3046` | InternalError | 내부 오류 |
| `LEA-3049` | Timeout | 시간 초과 |
| `LEA-3051` | MemoryLeak | **메모리 누수** |
| `LEA-3052` | InvalidName | 유효하지 않은 이름 |
| `LEA-3053` | CannotDelete | 삭제 실패 |
| `LEA-3054` | CannotApply | 적용 실패 |
| `LEA-3056` | StackOverflow | **스택 오버플로우** |

### 데이터 검증 에러 (4002-4005)

| ID | 이름 | 설명 |
|----|------|------|
| `LEA-4002` | InvalidType | 타입 유효하지 않음 |
| `LEA-4003` | InvalidName | 이름 유효하지 않음 |
| `LEA-4004` | SignatureMismatch | 시그니처 불일치 |
| `LEA-4005` | InvalidValue | 값 유효하지 않음 |

---

## 7.2 Warning Level (LWA-XXXX) - 21개

문제가 있지만 실행은 가능한 경고입니다. 수정을 권장합니다.

### 코드 품질 경고 (1106-1122)

| ID | 이름 | 설명 |
|----|------|------|
| `LWA-1106` | NotRecommendedAssignment | 권장하지 않는 할당문 |
| `LWA-1109` | IntroduceGlobalVariable | **글로벌 변수 선언 (local 권장)** |
| `LWA-1110` | DeprecatedAPIUsed | **더 이상 사용하지 않는 API** |
| `LWA-1111` | UnbalancedAssignment | 할당문 좌우 길이 불일치 |
| `LWA-1112` | UnreachableCode | **도달할 수 없는 코드** |
| `LWA-1122` | ReturnValueExpected | void 함수를 값처럼 사용 |

### 런타임 경고 (3008-3055)

| ID | 이름 | 설명 |
|----|------|------|
| `LWA-3008` | AlreadyExist | 이미 존재함 (MapLayerName, Collider 등) |
| `LWA-3009` | InvalidValue | 값 유효하지 않음 |
| `LWA-3010` | NotSupported | 지원하지 않는 기능 |
| `LWA-3017` | OutOfRange | 허용 범위 벗어남 |
| `LWA-3019` | NotRecommendedValue | 권장하지 않는 값 |
| `LWA-3020` | Obsolete | 더 이상 사용하지 않는 기능 |
| `LWA-3026` | DuplicateRequest | 요청 중복 |
| `LWA-3029` | FailedSetDefault | 기본값 설정 실패 |
| `LWA-3047` | UnableToChange | 변경 불가 값 변경 시도 |
| `LWA-3048` | DuplicateComponent | 동일 타입 컴포넌트 중복 |
| `LWA-3055` | NotInitialized | 초기화되지 않음 |

### 모델/엔티티 경고 (4001-4013)

| ID | 이름 | 설명 |
|----|------|------|
| `LWA-4001` | EntityComponentPropertyValueTypeMismatch | 엔티티 컴포넌트 프로퍼티 값 오류 |
| `LWA-4011` | ModelPropertyValueTypeMismatch | 모델 프로퍼티 값 오류 |
| `LWA-4012` | ModelComponentPropertyValueTypeMismatch | 모델 컴포넌트 프로퍼티 값 오류 |
| `LWA-4013` | ModelDuplicateComponent | 모델 컴포넌트 중복 |

---

## 7.3 Info Level (LIA-XXXX) - 8개

정보성 메시지입니다. 참고용으로 확인하세요.

### 코드 분석 정보 (1113-1119)

| ID | 이름 | 설명 |
|----|------|------|
| `LIA-1113` | UnresolvedSymbol | 심볼을 찾을 수 없음 |
| `LIA-1114` | UnresolvedMember | 멤버를 찾을 수 없음 |
| `LIA-1115` | UnresolvedFunction | 함수를 찾을 수 없음 |
| `LIA-1116` | DuplicateLocal | 로컬 변수 중복 선언 |
| `LIA-1119` | DuplicateFunction | 함수 중복 정의 |

### 시스템 정보 (3025-3050)

| ID | 이름 | 설명 |
|----|------|------|
| `LIA-3025` | RequestFinished | 요청 완료 |
| `LIA-3045` | InfoMessage | 연결 상태 변경, 노드 반환 시 발생 |
| `LIA-3050` | InvalidEnvironment | 특정 환경에서만 동작하는 함수 사용 |

---

## 7.4 자주 발생하는 에러 해결 가이드

### LEA-1108: AssignToReadonlyProperty
```lua
-- ❌ 잘못된 코드
self.Entity.TransformComponent.Position.x = 100

-- ✅ 올바른 코드
self.Entity.TransformComponent.Position = Vector2(100, self.Entity.TransformComponent.Position.y)
```

### LEA-3004: MissingComponent
```lua
-- ❌ 잘못된 코드
local sprite = self.Entity.SpriteRendererComponent  -- 컴포넌트 없으면 에러

-- ✅ 올바른 코드
if self.Entity:HasComponent("SpriteRendererComponent") then
    local sprite = self.Entity.SpriteRendererComponent
end
```

### LEA-3033: NilReference
```lua
-- ❌ 잘못된 코드
local enemy = _EntityService:GetEntityByName("Enemy")
enemy.TransformComponent.Position = Vector2(0, 0)  -- enemy가 nil일 수 있음

-- ✅ 올바른 코드
local enemy = _EntityService:GetEntityByName("Enemy")
if isvalid(enemy) then
    enemy.TransformComponent.Position = Vector2(0, 0)
end
```

### LWA-1109: IntroduceGlobalVariable
```lua
-- ❌ 경고 발생
playerScore = 0  -- 글로벌 변수

-- ✅ 권장
local playerScore = 0  -- 로컬 변수
```

---

# Part 8: Services API 예문 모음

> 각 서비스별로 공식 문서에서 제공하는 실용적인 루아 코드 예문입니다.
> 모든 예문은 실제 게임 개발 시나리오에 기반합니다.

---

## 8.1 SpawnService - 엔티티 복제 및 생성

```lua
-- 엔티티 복제 및 모델 ID로 생성
[server only]
void OnBeginPlay()
{
    local entity = _EntityService:GetEntityByPath("Entity Path")
    local clone1 = _SpawnService:SpawnByEntity(entity, "clone1", Vector3(1, 0, 0))
    
    local modelId = "Model Entry Id"
    local clone2 = _SpawnService:SpawnByModelId(modelId, "clone2", Vector3(0, 1, 0), clone1)
}
```

## 8.2 InputService - 키보드 입력 처리

```lua
-- 키 입력으로 플레이어 상태 변경
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.Z then
        self.Entity.StateComponent:ChangeState("CROUCH")
        self.KeyDownTime = _UtilLogic.ElapsedSeconds
    end
}

[service: InputService]
HandleKeyUpEvent (KeyUpEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.Z then
        local force = (_UtilLogic.ElapsedSeconds - self.KeyDownTime) * 10
        self.Entity.RigidbodyComponent:SetForce(Vector2(0, force))
        self.Entity.StateComponent:ChangeState("JUMP")
    end
}
```

## 8.3 SoundService - BGM 재생 및 토글

```lua
-- BGM 재생 및 버튼으로 토글
[client only]
void OnBeginPlay()
{
    _SoundService:PlayBGM("92dc353287df4b7894dfcec950edea49", 1)
    
    local buttonClickCallback = function()
        if _SoundService:IsPlayBGM() then
            _SoundService:PauseBGM()
        else
            _SoundService:ResumeBGM()
        end
    end
    
    local bgmToggleButton = _SpawnService:SpawnByModelId("Model Entry ID", "BGMToggleButton", Vector3.zero, defaultUIGroup)
    bgmToggleButton:ConnectEvent(ButtonClickEvent, buttonClickCallback)
}
```

## 8.4 CameraService - 줌 인/아웃 제어

```lua
-- Shift 키로 타겟 엔티티 줌
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    if event.key == KeyboardKey.LeftShift then
        local targetEntity = _EntityService:GetEntityByPath(EntityPath)
        local targetCamera = targetEntity.CameraComponent
        
        _CameraService:SwitchCameraTo(targetCamera)
        _CameraService:ZoomTo(200, 1.0)
    end
}

[service: InputService]
HandleKeyUpEvent (KeyUpEvent event)
{
    if event.key == KeyboardKey.LeftShift then
        local targetCamera = _UserService.LocalPlayer.CameraComponent
        
        _CameraService:ZoomReset()
        _CameraService:SwitchCameraTo(targetCamera)
    end
}
```

## 8.5 TimerService - 반복 타이머 설정

```lua
-- 매 초마다 엔티티 회전 (시계 시침 효과)
Property:
[None]
integer TimerId = 0

[server only]
void OnBeginPlay()
{
    local repeatFunc = function()
        local transform = self.Entity.TransformComponent
        transform.ZRotation = transform.ZRotation - (360.0 / 60.0)
    end
    
    self.TimerId = _TimerService:SetTimerRepeat(repeatFunc, 1.0)
}

[server only]
void OnEndPlay()
{
    if self.TimerId > 0 then
        _TimerService:ClearTimer(self.TimerId)
    end
}
```

## 8.6 DataStorageService - 유저 데이터 저장/불러오기

```lua
-- 유저 데이터 저장
[server only]
void SavePlayerData(string UserId, integer score)
{
    local resultCode = _DataStorageService:SetIntValueAndWait(UserId, "PlayerScore", score)
    
    if resultCode ~= DataStorageResultCode.Success then
        log_error("데이터 저장 실패: " .. tostring(resultCode))
    end
}

-- 유저 데이터 불러오기
[server only]
integer LoadPlayerScore(string UserId)
{
    local resultCode, value = _DataStorageService:GetIntValueAndWait(UserId, "PlayerScore")
    
    if resultCode == DataStorageResultCode.Success then
        return value
    else
        return 0  -- 기본값
    end
}
```

## 8.7 TeleportService - 맵 이동

```lua
-- 특정 맵으로 유저 이동
[server only]
void TeleportToMap(string mapName)
{
    local players = _UserService:GetAllUserEntities()
    
    for _, player in pairs(players) do
        _TeleportService:TeleportToMap(player, mapName)
    end
}

-- 위치 지정 텔레포트
[server only]
void TeleportToPosition(Entity entity, Vector3 position)
{
    _TeleportService:TeleportToMapPosition(entity, position, entity.CurrentMapName)
}
```

## 8.8 ParticleService - 파티클 효과

```lua
-- 더블 점프 및 스킬 파티클 효과
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.Space or key == KeyboardKey.LeftAlt then
        if not self.Entity.RigidbodyComponent:IsOnGround() then
            local lookDirectionX = self.Entity.PlayerControllerComponent.LookDirectionX
            self.Entity.RigidbodyComponent:SetForce(Vector2(lookDirectionX * 5, 3))
            
            local options = {
                ["SortingLayer"] = self.Entity.AvatarRendererComponent.SortingLayer,
                ["Color"] = Color(0.25, 0.5, 0.5, 0.8)
            }
            local pos = self.Entity.TransformComponent.Position
            
            _ParticleService:PlayBasicParticle(BasicParticleType.PillarBurst, self.Entity, pos, 90 * lookDirectionX, Vector3.one, false, options)
        end
    elseif key == KeyboardKey.Q then
        self.ParticleSerial = _ParticleService:PlaySpriteParticleAttached(SpriteParticleType.StreamSharp, "000000", self.Entity, Vector3.zero, 0, Vector3.one, true)
    end
}
```

## 8.9 ItemService - 아이템 생성/삭제

```lua
-- 충돌 이벤트로 아이템 획득/사용/삭제
[self]
HandleTriggerEnterEvent (TriggerEnterEvent event)
{
    if self:IsClient() then return end
    
    local TriggerBodyEntity = event.TriggerBodyEntity
    local inventory = self.Entity.InventoryComponent
    local items = inventory:GetItemList()
    
    if TriggerBodyEntity.Name == "Get Item" then
        local newItem = _ItemService:CreateItem(TestItem, "Test Item", inventory)
        newItem.ItemCount = 3
    elseif TriggerBodyEntity.Name == "Give Item" then
        if #items > 0 then
            items[1].ItemCount = items[1].ItemCount - 1
            if items[1].ItemCount == 0 then
                _ItemService:RemoveItem(items[1])
            end
        end
    elseif TriggerBodyEntity.Name == "Trash Can" then
        if #items > 0 then
            _ItemService:RemoveItem(items[1])
        end
    end
}
```

## 8.10 RoomService - 인스턴스 룸 관리

```lua
-- 인스턴스 룸 생성 및 유저 입장
Property:
[None]
integer GameIdx = 0

[server only]
void EnterGame(table userIds)
{
    local roomKey = "Game" .. tostring(self.GameIdx)
    self.GameIdx = self.GameIdx + 1
    
    -- 맵 GameMap01, GameMap02를 사용하는 인스턴스 룸 생성
    local instanceRoom = _RoomService:CreateInstanceRoom(roomKey, {"GameMap01", "GameMap02"})
    
    if instanceRoom == nil then
        log_error("인스턴스 룸 생성 실패: " .. roomKey)
        return
    end
    
    -- 유저들을 인스턴스 룸으로 이동
    instanceRoom:MoveUsers(userIds, "GameMap01")
}

-- 정적 룸으로 복귀
[server only]
void ReturnToLobby(table userIds)
{
    _RoomService:MoveUsersToStaticRoom(userIds, "LobbyMap")
}
```

## 8.11 BadgeService - 배지 검색 및 지급

```lua
-- 조건에 맞는 배지 검색
void SearchAvailableNormalRareBadges()
{
    -- 노멀, 레어 등급이고 획득 가능 상태인 배지 검색
    local pages = _BadgeService:GetBadgeInfosAndWait({BadgeGrade.Normal, BadgeGrade.Rare}, BadgeStatus.Ing)
    
    while true do
        local pageDatas = pages:GetCurrentPageDatas()
        
        for _, badge in ipairs(pageDatas) do
            log("Badge Id: " .. badge.Id .. " Name: " .. badge.Name .. " Grade: " .. tostring(badge.Grade))
        end
        
        if pages.IsLastPage then break end
        pages:MoveToNextPageAndWait()
    end
}
```

## 8.12 DynamicMapService - 동적 맵 생성/관리

```lua
-- 동적 맵 생성 및 유저 입장
[server only]
boolean TryEnterPartyBossMap(table userList, string bossName, integer difficult)
{
    local bossMapName = bossName .. "Base" .. tostring(math.tointeger(difficult))
    local newMapName = bossName .. tostring(_UtilLogic:RandomInteger())
    
    -- 중복 이름 체크
    while not self:IsValidDynamicMapName(newMapName) do
        newMapName = bossName .. tostring(_UtilLogic:RandomInteger())
    end
    
    -- 동적 맵 생성
    local resultCode = _DynamicMapService:CreateDynamicMap(bossMapName, newMapName)
    
    if resultCode ~= DynamicMapResultCode.Success then
        self:OnError(resultCode)
        return false
    end
    
    -- 유저 이동 예약 및 실행
    for _, userId in pairs(userList) do
        local userEntity = _UserService:GetUserEntityByUserId(userId)
        _TeleportService:ReserveTeleportToMapPosition(userEntity, Vector3.zero, newMapName)
    end
    
    _TeleportService:TeleportReservedEntities()
    return true
}
```

## 8.13 LocalizationService - 다국어 번역

```lua
-- 다국어 텍스트 조회 및 포맷팅
[client only]
void OnBeginPlay()
{
    -- 현재 언어 설정 텍스트 가져오기
    local plainText = _LocalizationService:GetText("TEXT_TEST1")
    
    -- 특정 언어 Translator 가져오기
    local enTranslator = _LocalizationService:GetTranslatorForLocale("en")
    local koTranslator = _LocalizationService.LocalTranslator
    
    -- 포맷 텍스트 사용
    local formatTextEn = enTranslator:GetTextFormat("TEXT_TEST2", "world")
    local formatTextKo = koTranslator:GetTextFormat("TEXT_TEST2", "세상")
    
    log("plainText: ", plainText)
    log("formatText: ", formatTextEn, "/", formatTextKo)
    
    -- 스마트 포맷 (한국어 조사 처리)
    log(_LocalizationService:SmartFormat("안녕, {0}{0:hpp:아|야}!", "세상"))
}
```

## 8.14 ResourceService - 리소스 로드/캐시 관리

```lua
-- 리소스 프리로드 및 로딩 화면
[client only]
void ResourceLoadWithLoadingScreen()
{
    self:ShowLoadingScreen()
    
    local ruids = {
        "6d1a308b27164b02921d812b05c78cba",
        "0516d7594a394561893e04de713cfb6a",
        "ce55606c96d94c059227f2956a1ae786"
    }
    
    _ResourceService:PreloadAsync(ruids, function()
        self:HideLoadingScreen()
    end)
}

-- 캐시 제거 및 새 리소스 로드
[client only]
void UpgradeSkill(string id)
{
    local oldRuids = self.currentRuids
    _ResourceService:RemoveCaches(oldRuids)
    _ResourceService:UnloadUnusedResources(0)
    
    local newRuids = self:GetRuids(id)
    self.currentRuids = newRuids
    
    _ResourceService:PreloadAsync(newRuids, function()
        self:AfterLoadSkillResource()
    end)
}
```

## 8.15 MaterialService - 머티리얼 프로퍼티 제어

```lua
-- 플레이어를 따라다니는 조명 효과
Property:
[None]
string materialId = ""

[client only]
void OnBeginPlay()
{
    self.materialId = _EntryService:GetMaterialIdByName("TestMaterial")
}

[client only]
void OnUpdate(number delta)
{
    local playerWorldPosition = _UserService.LocalPlayer.TransformComponent.WorldPosition
    
    local targetScreenPos = _UILogic:WorldToScreenPosition(Vector2(playerWorldPosition.x, playerWorldPosition.y))
    targetScreenPos.x = targetScreenPos.x / _UILogic.ScreenWidth
    targetScreenPos.y = targetScreenPos.y / _UILogic.ScreenHeight
    
    local options = {["CenterPos"] = targetScreenPos}
    
    _MaterialService:ChangeMaterialProperty(self.materialId, options)
}
```

## 8.16 WorldInstanceService - 월드 인스턴스 통신

```lua
-- 유저 입장 시 모든 월드 인스턴스에 알림
[service: UserService]
HandleUserEnterEvent (UserEnterEvent event)
{
    local UserId = event.UserId
    local worldInstanceId = _WorldInstanceService.WorldInstanceId
    local user = _UserService:GetUserEntityByUserId(UserId)
    local nickname = user.PlayerComponent.Nickname
    
    local evt = MyUserEnterEvent()
    evt.WorldInstanceId = worldInstanceId
    evt.Nickname = nickname
    _WorldInstanceService:RequestSendEventToAllWorldInstancesAndWait(evt)
}

[service: WorldInstanceService]
HandleMyUserEnterEvent (MyUserEnterEvent event)
{
    local WorldInstanceId = event.WorldInstanceId
    local Nickname = event.Nickname
    local currWorldInstId = _WorldInstanceService.WorldInstanceId
    
    if currWorldInstId == WorldInstanceId then
        log("User '" .. Nickname .. "' has entered this world instance.")
    else
        log("User '" .. Nickname .. "' has entered another world instance.")
    end
}
```

## 8.17 LogService - 서버 로그 설정

```lua
-- 서버 로그 출력 여부 설정
[client only]
void OnBeginPlay()
{
    -- client와 server의 로그를 출력
    self:SetShouldShowServerLog(true)
    self:LogClient()
    self:LogServer()
    
    -- client의 로그만 출력
    self:SetShouldShowServerLog(false)
    self:LogClient()
    self:LogServer()
}

[server]
void LogServer()
{
    log("log server")
    log_warning("log_warning server")
    log_error("log_error server")
}

[client]
void LogClient()
{
    log("log client")
    log_warning("log_warning client")
    log_error("log_error client")
}
```

## 8.18 CollisionService - 충돌 감지 및 시뮬레이터

```lua
-- 엔티티 주위 반경 1 이내에 있는 TriggerComponent를 찾아 출력
[server only]
void OnBeginPlay()
{
    local simulator = _CollisionService:GetSimulator(self.Entity)
    local transform = self.Entity.TransformComponent
    
    -- TriggerComponent의 충돌 그룹 기본값은 'TriggerBox'입니다
    local overlaps = simulator:OverlapCircleAll("TriggerBox", transform.WorldPosition:ToVector2(), 1)
    
    for i = 1, #overlaps do
        local trigger = overlaps[i]
        
        if trigger.Entity == self.Entity then
            continue
        end
        
        if trigger.EnableInHierarchy == false then
            continue
        end
        
        log(trigger.Entity.Name)
    end
}
```

## 8.19 EffectService - 이펙트 재생 및 제거

```lua
Property:
number EffectSerial = 0

-- 2단 점프와 스킬 이펙트 예제
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.Space or key == KeyboardKey.LeftAlt then
        if not self.Entity.RigidbodyComponent:IsOnGround() then
            local lookDirectionX = self.Entity.PlayerControllerComponent.LookDirectionX
            self.Entity.RigidbodyComponent:SetForce(Vector2(lookDirectionX * 5, 3))
            
            local options = { ["FlipX"] = lookDirectionX > 0 }
            local pos = self.Entity.TransformComponent.Position
            
            _EffectService:PlayEffect("RUID", self.Entity, pos, 0, Vector3.one, false, options)
        end
    elseif key == KeyboardKey.Q then
        -- Q키를 누르면 루프 이펙트 시작
        self.EffectSerial = _EffectService:PlayEffectAttached("RUID", self.Entity, Vector3.zero, 0, Vector3.one, true)
    end
}

[service: InputService]
HandleKeyUpEvent (KeyUpEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.Q then
        -- Q키를 떼면 이펙트 제거
        _EffectService:RemoveEffect(self.EffectSerial)
        
        local pos = self.Entity.TransformComponent.Position
        _EffectService:PlayEffect("RUID", self.Entity, pos, 0, Vector3.one)
    end
}
```

## 8.20 HttpService - HTTP 요청 및 JSON 처리

```lua
-- HTTP GET/POST 요청 예제
[server only]
void GetAndWait()
{
    local headers = {["header1"] = "value1", ["header2"] = "value2"}
    local response = _HttpService:GetAndWait("https://WebUrl", headers)
    log(response)
}

[server only]
void PostAndWait()
{
    local headers = {["header1"] = "value1", ["header2"] = "value2"}
    local content = {["id"] = "msw123", ["password"] = "abcd1234"}
    local contentJson = _HttpService:JSONEncode(content)
    local response = _HttpService:PostAndWait("https://WebUrl", contentJson, HttpContentType.ApplicationJson, headers)
    log(response)
}

[server only]
void RequestAndWait()
{
    -- 반드시 헤더에 content-type이 포함되어 있어야 합니다
    local headers = {["content-type"] = "application/json"}
    local content = {["id"] = "msw123", ["password"] = "abcd1234"}
    local contentJson = _HttpService:JSONEncode(content)
    local response = _HttpService:RequestAndWait("https://WebUrl", "POST", contentJson, headers)
    log(response)
}
```

## 8.21 UserService - 유저 관리 및 이벤트

```lua
-- 유저 입장 시 닉네임 변경 예제
[server only] [service: UserService]
HandleUserEnterEvent (UserEnterEvent event)
{
    local UserId = event.UserId
    
    local userEntity = _UserService:GetUserEntityByUserId(UserId)
    local nametag = userEntity.NameTagComponent
    
    if UserId == "000000" then
        nametag.Name = "Admin"
        nametag.FontColor = Color.magenta
    else
        nametag.Name = "Player"
        nametag.FontColor = Color.cyan
    end
}

-- 유저 수 및 특정 맵의 유저 조회
[server]
void GetUserInfo()
{
    local userCount = _UserService:GetUserCount()
    log("현재 유저 수: " .. userCount)
    
    local usersInMap = _UserService:GetUsersByMapName("MainMap")
    for k, v in pairs(usersInMap) do
        log("맵 내 유저: " .. v.Name)
    end
}
```

## 8.22 EntityService - 엔티티 관리

```lua
-- 엔티티 삭제
[server]
void DestroyTargetEntity(string id)
{
    local entity = _EntityService:GetEntity(id)
    _EntityService:Destroy(entity)
}

-- 특정 경로의 엔티티들 활성화/비활성화
[server]
void EnablePathEntities(string path, boolean enable)
{
    local entities = _EntityService:GetEntitiesByPath(path)
    for k, v in pairs(entities) do
        v.Enable = enable
    end
}

-- 태그로 엔티티 찾아 표시/숨김
[server]
void VisibleTagEntities(string tag, boolean visible)
{
    local entities = _EntityService:GetEntitiesByTag(tag)
    for k, v in pairs(entities) do
        v.Visible = visible
    end
}

-- 특정 모델로 생성된 엔티티들 점프시키기
[server]
void JumpMoveMonsters()
{
    local entities = _EntityService:GetEntitiesSpawnedByModelId("model://movemonster")
    for k, v in pairs(entities) do
        v.RigidbodyComponent:AddForce(Vector2(0.0, 5.0))
    end
}
```

## 8.23 EntryService - 엔트리 ID 조회

```lua
-- 모델 이름으로 ID를 조회하여 스폰
local modelId = _EntryService:GetModelIdByName("NewModel")
if modelId ~= nil then 
    _SpawnService:SpawnByModelId(modelId, "NewEntity", Vector3.zero, self.Entity)   
end

-- DataSet, Material ID 조회
local dataSetId = _EntryService:GetDataSetIdByName("MyDataSet")
local materialId = _EntryService:GetMaterialIdByName("MyMaterial")
```

## 8.24 DataService - 데이터셋 조회

```lua
-- 데이터셋에서 데이터 읽기 예제
-- SampleDataSet: name, level, hp 컬럼 보유
[server only]
void OnBeginPlay()
{
    log(_DataService:GetRowCount("SampleDataSet")) -- 행 수
    log(_DataService:GetCell("SampleDataSet", 3, 3)) -- 3행 3열
    log(_DataService:GetCell("SampleDataSet", 2, "name")) -- 2행 name열
    
    local dataSet = _DataService:GetTable("SampleDataSet")
    log(dataSet:GetRowCount())
    log(dataSet:GetCell(1, 1))
    log(dataSet:GetCell(2, "level"))
    
    for i = 1, dataSet:GetRowCount() do
        log(dataSet:GetCell(i, "name"), dataSet:GetCell(i, "level"), dataSet:GetCell(i, "hp"))
    end
}
```

## 8.25 ScreenshotService - 스크린샷 캡처

```lua
-- 전체 화면 캡처
[client only]
void CaptureFullScreen()
{
    local error, fullPath = _ScreenshotService:CaptureFullScreenAsFileAndWait("Screenshot")
    
    if error == ScreenshotError.Success then
        log("저장되었습니다. " .. fullPath)
    end
}

-- 특정 영역 캡처
[client only]
void CaptureRegion()
{
    local startPixel = Vector2(100, 100)
    local endPixel = Vector2(900, 900)
    local error, fullPath = _ScreenshotService:CaptureScreenRegionAsFileAndWait("Screenshot", startPixel, endPixel)
    
    if error == ScreenshotError.Success then
        log("저장되었습니다. " .. fullPath)
    end
}
```

## 8.26 ScreenTransitionService - 화면 전환 효과

```lua
-- Fade 효과 설정
[client only]
void SetupFadeEffects()
{
    -- Fade In/Out 효과 활성화
    _ScreenTransitionService:SetFadeInOutEnable(true)
    
    -- Fade 시간 설정 (0~3초)
    _ScreenTransitionService:SetFadeInTime(1.5)
    _ScreenTransitionService:SetFadeOutTime(1.0)
}

-- Dissolve 화면 전환 효과
[client only]
void PlayDissolveEffect()
{
    -- time: 지속시간(0~3초), includeUI: UI 포함여부, isHighPriority: Fade 차단여부
    _ScreenTransitionService:DissolveScreen(2.0, true, true)
}
```

## 8.27 TransformComponent - 위치/회전/크기 변환

```lua
-- 엔티티 회전 (매 프레임 Z축 회전)
Property:
[None]
number AngularSpeed = 360

Method:
[server only]
void OnUpdate (number delta)
{
    local transform = self.Entity.TransformComponent
    local zRotation = transform.ZRotation
    
    transform.ZRotation = zRotation + (self.AngularSpeed * delta)
}

-- 자유낙하 구현 (Translate 사용)
Property:
[Sync]
Vector3 CurrentVelocity = Vector3.zero

Property:
[Sync]
Vector3 Gravity = Vector3(0, -200, 0)

Method:
[server only]
void OnUpdate (number delta)
{
    local transform = self.Entity.TransformComponent
    
    self.CurrentVelocity = self.CurrentVelocity + (self.Gravity * delta)
    
    local deltaX = self.CurrentVelocity.x * delta
    local deltaY = self.CurrentVelocity.y * delta
    
    transform:Translate(deltaX, deltaY)
}
```

## 8.28 RigidbodyComponent - 물리 및 발판

```lua
-- AttachTo: 점프대에서 떨어지지 않게 하기
Property:
[Sync]
Entity LastJumpPad = nil

-- 점프대에 올라섰을 때
Function: HandleJumpPadEnter(Entity player, Entity jumpPad)
{
    local rb = player.RigidbodyComponent
    rb:AttachTo(jumpPad, JumpPadType.Normal)
    self.LastJumpPad = jumpPad
}

-- 점프대에서 내려올 때
Function: HandleJumpPadLeave(Entity player)
{
    local rb = player.RigidbodyComponent
    rb:Detach()
    self.LastJumpPad = nil
}

-- PredictFootholdEnd: 발판 끝 예측
[server only]
void CheckFootholdEnd()
{
    local rb = self.Entity.RigidbodyComponent
    local endPos = rb:PredictFootholdEnd(true)  -- true: 오른쪽 방향
    
    if endPos then
        log("발판 끝 위치: " .. tostring(endPos))
    end
}
```

## 8.29 SpriteRendererComponent - 스프라이트 렌더링

```lua
-- 메소 금액에 따라 다른 스프라이트 적용
Property:
[Sync]
number Meso = 0

Method:
[server only]
void OnBeginPlay ()
{
    self.Meso = _UtilLogic:RandomIntegerRange(1, 1500)
    local sprite = self.Entity.SpriteRendererComponent
    
    if self.Meso < 50 then
        sprite.SpriteRUID = "meso_bronze"
    elseif self.Meso < 100 then
        sprite.SpriteRUID = "meso_silver"
    elseif self.Meso < 1000 then
        sprite.SpriteRUID = "meso_gold"
    else
        sprite.SpriteRUID = "meso_bundle"
    end
}

-- 스프라이트 색상 및 투명도 변경
[client]
void SetSpriteAppearance(Color newColor, number alpha)
{
    local sprite = self.Entity.SpriteRendererComponent
    sprite.Color = newColor
    sprite:SetAlpha(alpha)  -- 0.0 ~ 1.0
    sprite.FlipX = true     -- X축 반전
}
```

## 8.30 TriggerComponent - 충돌 영역 감지

```lua
-- 플레이어가 힐링 영역에 들어왔을 때 체력 회복
Property:
[Sync]
boolean IsGettingHealed = false

Event Handler:
[server only] [self]
HandleTriggerEnterEvent (TriggerEnterEvent event)
{
    -- Parameters
    local TriggerBodyEntity = event.TriggerBodyEntity
    --------------------------------------------------------
    
    if TriggerBodyEntity.Name == "HealZone" then
        self.IsGettingHealed = true
    end
}

[server only] [self]
HandleTriggerLeaveEvent (TriggerLeaveEvent event)
{
    local TriggerBodyEntity = event.TriggerBodyEntity
    
    if TriggerBodyEntity.Name == "HealZone" then
        self.IsGettingHealed = false
    end
}

-- 매 프레임 체력 회복
[server only]
void OnUpdate(number delta)
{
    if self.IsGettingHealed then
        local hp = self.Entity.HPComponent
        hp:AddHP(10 * delta)  -- 초당 10 회복
    end
}
```

## 8.31 StateComponent - 상태 머신

```lua
-- 플레이어 상태를 ChatBalloon으로 표시
Method:
[server only]
void OnBeginPlay ()
{
    local state = self.Entity.StateComponent
    if state == nil then
        state = self.Entity:AddComponent("StateComponent")
    end
    
    local chatBalloon = self.Entity.ChatBalloonComponent
    if chatBalloon == nil then
        chatBalloon = self.Entity:AddComponent("ChatBalloonComponent")
    end
    
    -- ChatBalloon 설정
    self.Entity.ChatBalloonComponent.AutoShowEnabled = true
    self.Entity.ChatBalloonComponent.ChatModeEnabled = false
    self.Entity.ChatBalloonComponent.ShowDuration = 1
    self.Entity.ChatBalloonComponent.HideDuration = 0
    self.Entity.ChatBalloonComponent.FontSize = 2
}

-- 상태 변경 및 이벤트 처리
[server only]
void ChangePlayerState(string newState)
{
    local state = self.Entity.StateComponent
    state:ChangeState(newState)
    log("현재 상태: " .. state.CurrentStateName)
}
```

## 8.32 UtilLogic - 유틸리티 함수 모음

```lua
-- UtilLogic 기본 함수 사용 예제
[client only]
void OnBeginPlay ()
{
    -- 랜덤 정수 (0 ~ 2147483646)
    local randomInteger = _UtilLogic:RandomInteger()
    log("RandomInteger : " .. tostring(randomInteger))
    
    -- 범위 내 랜덤 정수 (min~max 포함)
    local randomIntegerRange = _UtilLogic:RandomIntegerRange(1, 5)
    log("RandomIntegerRange : " .. tostring(randomIntegerRange))  -- 1 ~ 5
    
    -- 랜덤 실수 (0.0 ~ 1.0 미만)
    local randomDouble = _UtilLogic:RandomDouble()
    log("RandomDouble : " ..  tostring(randomDouble))
    
    -- 빈 문자열 체크
    local empty = _UtilLogic:IsNilorEmptyString("")
    log("IsNilorEmptyString : " .. tostring(empty))  -- true
    
    -- 문자열 Trim
    local trim = _UtilLogic:Trim("[testString]", "[]")
    log("Trim : " .. tostring(trim))  -- testString
    
    -- 문자열 교체
    local replace = _UtilLogic:Replace("@!testString@!", "@!", "*")
    log("Replace : " .. tostring(replace))  -- *testString*
    
    -- 문자열 포함 확인
    local contains = _UtilLogic:Contains("abcdefg", "bcd")
    log("Contains : " .. tostring(contains))  -- true
    
    -- 문자열 분할
    local split = _UtilLogic:Split("1,2,3,4,5", ",")
    log("#Split : " .. tostring(#split))  -- 5
    
    -- 부분 문자열
    local subString = _UtilLogic:SubString("abcdefg", 1, 3)
    log("SubString : " .. tostring(subString))  -- abc
    
    -- 문자열 삽입
    local insert = _UtilLogic:Insert("abcde", 2, "123")
    log("Insert : " .. tostring(insert))  -- a123bcde
    
    -- Table <-> String 변환
    local table1 = { "first", "second" }
    local tableToString = _UtilLogic:TableToString(table1)
    log("TableToString : " .. tostring(tableToString))
    
    local table2 = _UtilLogic:StringToTable(tableToString)
    for i = 1, #table2 do
        log(table2[i])
    end
    
    -- 경과 시간
    local elapsed = _UtilLogic.ElapsedSeconds
    log("ElapsedSeconds: " .. tostring(elapsed))
}

-- 크리티컬 확률 계산 예제
boolean CalcCritical (Entity attacker, Entity defender, string attackInfo)
{
    return _UtilLogic:RandomDouble() < 0.3  -- 30% 확률
}

-- 게임 시간 배속 설정
[client]
void SetGameSpeed(number speed)
{
    _UtilLogic:SetClientTimeScale(speed)  -- 0~100, 기본값 1
}
```

## 8.33 Vector3 - 3차원 벡터 연산

```lua
-- Vector3 생성과 레퍼런스 동작
[server]
void OnBeginPlay()
{
    local v = Vector3(1.0, 2.0, 3.0)
    
    -- Position 변경 방법 1: 직접 대입
    self.Entity.TransformComponent.Position = v
    
    -- Position 변경 방법 2: 새 Vector3 생성
    self.Entity.TransformComponent.Position = Vector3(1.0, 2.0, 3.0)
    
    -- Position 변경 방법 3: 각 좌표 개별 수정
    local position = self.Entity.TransformComponent.Position
    position.x = 1.0
    position.y = 2.0
    position.z = 3.0
}

-- 상수 Vector와 연산
[server]
void MoveEntity()
{
    -- Vector3 상수: up, down, left, right, forward, back, zero, one
    self.Entity.TransformComponent.Position = self.Entity.TransformComponent.Position + Vector3.up * 10
    self.Entity.TransformComponent.Scale = Vector3.one * 2
}

-- 2D 거리 계산 (2D 게임 제작 시 권장)
[server]
void Calculate2DDistance()
{
    local myPos = self.Entity.TransformComponent.Position
    local otherPos = _EntityService:GetEntityByPath("OtherEntity").TransformComponent.Position
    
    -- 2D 게임에서는 Vector2로 변환해서 계산
    local myPosV2 = Vector2(myPos.x, myPos.y)
    local otherPosV2 = Vector2(otherPos.x, otherPos.y)
    
    local distance = Vector2.Distance(myPosV2, otherPosV2)
    log("2D distance: " .. tostring(distance))
}

-- Vector3 유용한 함수들
[server]
void VectorOperations()
{
    local a = Vector3(1, 0, 0)
    local b = Vector3(0, 1, 0)
    
    -- 두 벡터 사이 각도 (0~180)
    local angle = a:Angle(b)
    
    -- 내적
    local dot = a:Dot(b)
    
    -- 외적
    local cross = a:Cross(b)
    
    -- 거리
    local dist = a:Distance(b)
    
    -- 크기
    local mag = a:Magnitude()
    
    -- 정규화 (크기 1)
    local normalized = a:Normalize()
    
    -- 선형 보간 (t=0~1)
    local lerped = a:Lerp(b, 0.5)
    
    -- 구면 선형 보간
    local slerped = a:Slerp(b, 0.5)
    
    -- 복사본 생성
    local clone = a:Clone()
}
```

---

# Part 9: Enums 주요 타입 정리

## 9.1 KeyboardKey - 키보드 키 코드

키보드 입력을 처리할 때 사용되는 키 코드입니다. InputService와 함께 사용합니다.

| 이름 | 값 | 설명 |
|-----|---:|------|
| None | 0 | 유효하지 않은 키 |
| Backspace | 8 | 백스페이스 |
| Tab | 9 | 탭 |
| Return | 13 | Enter 키 |
| Escape | 27 | Esc 키 |
| Space | 32 | 스페이스 |
| Alpha0~9 | 48~57 | 키보드 상단 숫자 (0~9) |
| A~Z | 97~122 | 영문자 (A~Z) |
| Keypad0~9 | 256~265 | 숫자 키패드 (0~9) |
| UpArrow | 273 | 위쪽 화살표 |
| DownArrow | 274 | 아래쪽 화살표 |
| RightArrow | 275 | 오른쪽 화살표 |
| LeftArrow | 276 | 왼쪽 화살표 |
| F1~F15 | 282~296 | 펑션 키 |
| LeftShift | 304 | 왼쪽 Shift |
| RightShift | 303 | 오른쪽 Shift |
| LeftControl | 306 | 왼쪽 Ctrl |
| RightControl | 305 | 오른쪽 Ctrl |
| LeftAlt | 308 | 왼쪽 Alt |
| RightAlt | 307 | 오른쪽 Alt |
| Mouse0 | 323 | 마우스 왼쪽 버튼 |
| Mouse1 | 324 | 마우스 오른쪽 버튼 |
| Mouse2 | 325 | 마우스 가운데 버튼 |

```lua
-- KeyboardKey 사용 예제
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    -- 문자열을 KeyboardKey로 변환
    local spaceKey = KeyboardKey.CastFrom("Space")
    
    if event.key == KeyboardKey.Space then
        log("스페이스바 눌림")
        self:Jump()
    elseif event.key == KeyboardKey.Z then
        log("Z 키 (기본 공격)")
        self:Attack()
    elseif event.key == KeyboardKey.X then
        log("X 키 (스킬)")
        self:UseSkill()
    end
    
    -- 숫자를 KeyboardKey로 변환
    local numKey = KeyboardKey.CastFrom(97)  -- 97 = A 키
}
```

---

# Part 10: Lua Global 함수 정리

## 10.1 기본 출력/로그 함수

```lua
-- log: 정보 로그 출력 (가장 많이 사용)
log("Hello World")
log("Player HP:", playerHP, "Position:", position)

-- log_warning: 경고 로그 (주황색)
log_warning("잘못된 값입니다:", value)

-- log_error: 오류 로그 (빨간색)
log_error("치명적 오류 발생!")

-- print: 기본 출력 (log와 유사)
print("디버그용 출력")
```

## 10.2 대기/흐름 제어

```lua
-- wait: 지정된 시간(초) 동안 실행 중단
wait(1.5)  -- 1.5초 대기
log("1.5초 후 실행")

-- wait 사용 예제: 순차 실행
[server only]
void OnBeginPlay ()
{
    log("게임 시작!")
    wait(3)
    log("3초 후: 준비...")
    wait(2)
    log("2초 후: 시작!")
}
```

## 10.3 타입 변환 함수

```lua
-- tostring: 값을 문자열로 변환
local numStr = tostring(123)        -- "123"
local boolStr = tostring(true)      -- "true"
local vecStr = tostring(Vector3.one) -- "(1, 1, 1)"

-- tonumber: 문자열을 숫자로 변환
local num = tonumber("42")          -- 42
local hex = tonumber("ff", 16)      -- 255 (16진수)
local invalid = tonumber("abc")     -- nil (변환 불가)

-- type: 값의 타입을 문자열로 반환
type(123)        -- "number"
type("hello")    -- "string"
type(true)       -- "boolean"
type({})         -- "table"
type(nil)        -- "nil"
```

## 10.4 반복자 함수

```lua
-- ipairs: 숫자 인덱스 배열 순회 (1부터 순서대로)
local items = {"사과", "바나나", "체리"}
for index, value in ipairs(items) do
    log(index, value)  -- 1 사과, 2 바나나, 3 체리
end

-- pairs: 테이블 전체 순회 (순서 보장 X)
local player = {name = "Hero", level = 50, hp = 1000}
for key, value in pairs(player) do
    log(key, ":", value)
end
```

## 10.5 엔티티/컴포넌트 유효성 검사

```lua
-- isvalid: nil 및 삭제된 Entity/Component 확인
[server only]
void CheckEntity(Entity target)
{
    if isvalid(target) == false then
        log_warning("대상 엔티티가 유효하지 않음")
        return
    end
    
    -- 안전하게 접근 가능
    log(target.Name)
}

-- 컴포넌트 유효성 검사
local sprite = self.Entity.SpriteRendererComponent
if isvalid(sprite) then
    sprite.Color = Color.red
end
```

## 10.6 에러 처리

```lua
-- pcall: 보호 모드로 함수 호출 (오류 잡기)
local success, result = pcall(function()
    -- 오류가 발생할 수 있는 코드
    local data = _DataStorageService:GetAndWait(key)
    return data
end)

if success then
    log("결과:", result)
else
    log_error("오류 발생:", result)
end

-- assert: 조건이 false면 오류 발생
assert(value ~= nil, "값이 nil입니다!")
assert(count > 0, "카운트는 0보다 커야 합니다")

-- error: 즉시 오류 발생
if level < 0 then
    error("레벨은 음수가 될 수 없습니다")
end
```

## 10.7 테이블/메타테이블 함수

```lua
-- select: 인수 선택
local count = select("#", a, b, c)  -- 인수 개수: 3
local second = select(2, a, b, c)   -- b 반환

-- rawget/rawset: 메타테이블 무시하고 접근
local t = {}
rawset(t, "key", "value")   -- t["key"] = "value"
local v = rawget(t, "key")  -- "value"

-- setmetatable/getmetatable: 메타테이블 설정/조회
local mt = { __tostring = function() return "Custom" end }
setmetatable(t, mt)
```

---

# Part 11: Events 주요 이벤트 정리

## 11.1 KeyDownEvent - 키 누름 이벤트

키보드 키를 눌렀을 때 1회 발생합니다. **Client에서만 발생합니다.**

```lua
-- 속성: key (KeyboardKey) - 누른 키

[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    -- Parameters
    local key = event.key
    --------------------------------------------------------
    
    if key == KeyboardKey.Space then
        self:PlayerJump()
    elseif key == KeyboardKey.Z then
        self:PlayerAttack()
    elseif key == KeyboardKey.Escape then
        self:OpenMenu()
    end
}
```

## 11.2 KeyUpEvent - 키 뗌 이벤트

```lua
[service: InputService]
HandleKeyUpEvent (KeyUpEvent event)
{
    local key = event.key
    
    if key == KeyboardKey.LeftArrow or key == KeyboardKey.RightArrow then
        self:StopMoving()
    end
}
```

## 11.3 TriggerEnterEvent - 트리거 진입 이벤트

TriggerComponent의 영역이 겹치는 순간 발생합니다. **Server, Client 모두 발생합니다.**

```lua
-- 속성: TriggerBodyEntity (Entity) - 충돌한 TriggerBody 엔티티

[server only] [self]
HandleTriggerEnterEvent (TriggerEnterEvent event)
{
    -- Parameters
    local TriggerBodyEntity = event.TriggerBodyEntity
    --------------------------------------------------------
    
    -- 플레이어가 아이템에 닿았을 때
    if self.Entity.Name == "CoinPickup" then
        local player = TriggerBodyEntity
        if player.PlayerComponent ~= nil then
            self:GiveCoin(player)
            _SpawnService:Destroy(self.Entity)
        end
    end
}
```

## 11.4 TriggerLeaveEvent - 트리거 퇴장 이벤트

```lua
[server only] [self]
HandleTriggerLeaveEvent (TriggerLeaveEvent event)
{
    local TriggerBodyEntity = event.TriggerBodyEntity
    
    -- 안전 구역에서 나갔을 때
    if self.Entity.Name == "SafeZone" then
        local player = TriggerBodyEntity.PlayerComponent
        if player ~= nil then
            log(player.Name .. " 님이 안전 구역을 벗어났습니다")
            self:StartDamageTimer(TriggerBodyEntity)
        end
    end
}
```

## 11.5 CollisionEvent - 물리 충돌 이벤트

```lua
[server only] [self]
HandleCollisionEvent (CollisionEvent event)
{
    local OtherEntity = event.OtherEntity
    local CollisionType = event.CollisionType  -- Enter, Stay, Exit
    
    if CollisionType == CollisionEventType.Enter then
        log("충돌 시작: " .. OtherEntity.Name)
    elseif CollisionType == CollisionEventType.Exit then
        log("충돌 종료: " .. OtherEntity.Name)
    end
}
```

## 11.6 이벤트 핸들러 패턴 요약

```lua
-- 이벤트 핸들러 선언 형식
-- [실행 환경] [발생 조건]
-- HandleXxxEvent (XxxEvent event)

-- 실행 환경 옵션:
-- [server only]     서버에서만 실행
-- [client only]     클라이언트에서만 실행
-- [server, client]  양쪽에서 실행

-- 발생 조건 옵션:
-- [self]            자신의 엔티티 이벤트만
-- [any]             모든 엔티티 이벤트
-- [service: XXX]    특정 서비스 이벤트
```

---

# Part 12: Lua math 라이브러리

수학 연산을 위한 표준 Lua math 라이브러리입니다.

## 12.1 상수

| 상수 | 설명 |
|-----|------|
| `math.pi` | π (3.14159...) |
| `math.huge` | 무한대 (가장 큰 실수) |
| `math.mininteger` | 최소 정수 값 |
| `math.maxinteger` | 최대 정수 값 |

## 12.2 기본 연산

```lua
-- 반올림/올림/내림
math.floor(3.7)    -- 3 (내림)
math.ceil(3.2)     -- 4 (올림)
math.abs(-5)       -- 5 (절댓값)

-- 최대/최소
math.max(1, 5, 3)  -- 5
math.min(1, 5, 3)  -- 1

-- 범위 제한 (게임에서 매우 유용!)
local hp = math.clamp(currentHP, 0, maxHP)

-- 부호 확인
math.sign(-10)     -- -1
math.sign(10)      -- 1
math.sign(0)       -- 0
```

## 12.3 거듭제곱/제곱근

```lua
-- 제곱근
math.sqrt(16)      -- 4

-- 거듭제곱
math.pow(2, 3)     -- 8 (2^3)
-- 또는 연산자 사용
2 ^ 3              -- 8

-- 자연로그/상용로그
math.log(10)       -- 자연로그
math.log10(100)    -- 2 (상용로그)
math.exp(1)        -- 2.718... (e^1)
```

## 12.4 삼각함수 (라디안)

```lua
-- 기본 삼각함수
math.sin(math.pi / 2)  -- 1
math.cos(0)            -- 1
math.tan(math.pi / 4)  -- 1

-- 역삼각함수
math.asin(1)           -- π/2
math.acos(0)           -- π/2
math.atan(1)           -- π/4
math.atan(y, x)        -- atan2 (사분면 고려)

-- 쌍곡선 함수
math.sinh(x), math.cosh(x), math.tanh(x)

-- 각도 변환
math.rad(180)      -- π (도 → 라디안)
math.deg(math.pi)  -- 180 (라디안 → 도)
```

## 12.5 랜덤

```lua
-- 0~1 사이 실수
local r = math.random()           -- 0.0 ~ 0.999...

-- 1~n 사이 정수
local dice = math.random(6)       -- 1 ~ 6

-- m~n 사이 정수
local damage = math.random(10, 20) -- 10 ~ 20

-- 랜덤 시드 설정 (재현 가능한 랜덤)
math.randomseed(12345)
```

## 12.6 기타 유용한 함수

```lua
-- 실수 근사 비교 (부동소수점 오차 대응)
math.almostequal(0.1 + 0.2, 0.3)  -- true

-- 정수/소수 분리
local int, frac = math.modf(3.14)  -- 3, 0.14

-- 정수 변환
math.tointeger(3.0)    -- 3
math.tointeger(3.5)    -- nil

-- 타입 검사
math.type(3)       -- "integer"
math.type(3.14)    -- "float"
math.type("3")     -- nil
```

---

# Part 13: Lua string 라이브러리

문자열 처리를 위한 표준 Lua string 라이브러리입니다.

## 13.1 기본 조작

```lua
-- 대소문자 변환
string.upper("hello")      -- "HELLO"
string.lower("HELLO")      -- "hello"
-- 또는 메서드 호출
("hello"):upper()          -- "HELLO"

-- 길이
string.len("hello")        -- 5
#"hello"                   -- 5

-- 부분 문자열 추출
string.sub("Hello", 1, 3)  -- "Hel" (1~3번째)
string.sub("Hello", 2)     -- "ello" (2번째부터 끝까지)
string.sub("Hello", -2)    -- "lo" (뒤에서 2번째부터)

-- 반전
string.reverse("abc")      -- "cba"

-- 반복
string.rep("ab", 3)        -- "ababab"
string.rep("x", 3, "-")    -- "x-x-x"
```

## 13.2 검색 및 치환

```lua
-- 검색 (시작, 끝 인덱스 반환)
local s, e = string.find("Hello World", "World")  -- 7, 11
string.find("Hello", "x")  -- nil (없으면)

-- 패턴 매칭
string.match("player_123", "%d+")  -- "123"

-- 전역 치환
string.gsub("hello world", "world", "Lua")  -- "hello Lua", 1
string.gsub("aaa", "a", "b", 2)  -- "bba", 2 (최대 2회)

-- 반복자로 모든 매치 찾기
for word in string.gmatch("Hello World", "%w+") do
    log(word)  -- "Hello", "World"
end
```

## 13.3 포맷팅

```lua
-- 형식 문자열 (C의 printf 스타일)
string.format("HP: %d/%d", 50, 100)      -- "HP: 50/100"
string.format("%.2f", 3.14159)           -- "3.14"
string.format("%s: %d점", "플레이어", 1000)  -- "플레이어: 1000점"

-- 자주 쓰는 포맷 지정자
-- %d: 정수, %f: 실수, %s: 문자열
-- %.2f: 소수점 2자리, %05d: 5자리 0패딩
```

## 13.4 바이트/문자 변환

```lua
-- 문자 → 바이트 코드
string.byte("A")           -- 65
string.byte("ABC", 1, 3)   -- 65, 66, 67

-- 바이트 코드 → 문자
string.char(65)            -- "A"
string.char(65, 66, 67)    -- "ABC"
```

## 13.5 비교

```lua
-- 문자열 비교
string.compare("a", "b")   -- 음수 (a < b)
string.compare("b", "a")   -- 양수 (b > a)
string.compare("a", "a")   -- 0 (같음)

-- 동등 비교
string.equals("hello", "hello")  -- true
```

---

# Part 14: Lua table 라이브러리

테이블(배열/딕셔너리) 조작을 위한 라이브러리입니다.

## 14.1 요소 추가/제거

```lua
local items = {"사과", "바나나"}

-- 끝에 추가
table.insert(items, "체리")  -- {"사과", "바나나", "체리"}

-- 특정 위치에 삽입
table.insert(items, 2, "오렌지")  -- {"사과", "오렌지", "바나나", "체리"}

-- 마지막 요소 제거
local last = table.remove(items)  -- "체리" 반환

-- 특정 위치 제거
local removed = table.remove(items, 2)  -- "오렌지" 반환
```

## 14.2 정렬

```lua
local scores = {30, 10, 50, 20}

-- 기본 오름차순 정렬
table.sort(scores)  -- {10, 20, 30, 50}

-- 커스텀 정렬 (내림차순)
table.sort(scores, function(a, b)
    return a > b
end)  -- {50, 30, 20, 10}

-- 테이블 객체 정렬
local players = {
    {name = "A", score = 100},
    {name = "B", score = 50},
    {name = "C", score = 200}
}
table.sort(players, function(a, b)
    return a.score > b.score
end)
```

## 14.3 연결 및 변환

```lua
-- 테이블 → 문자열
local fruits = {"사과", "바나나", "체리"}
table.concat(fruits, ", ")       -- "사과, 바나나, 체리"
table.concat(fruits, "-", 1, 2)  -- "사과-바나나"

-- 테이블 언팩 (다중 반환)
local a, b, c = table.unpack(fruits)  -- "사과", "바나나", "체리"
```

## 14.4 키/값 추출

```lua
local player = {name = "Hero", level = 50}

-- 모든 키 추출
local keys = table.keys(player)    -- {"name", "level"}

-- 모든 값 추출
local values = table.values(player) -- {"Hero", 50}
```

## 14.5 테이블 초기화/복사

```lua
-- 빈 테이블로 초기화
table.clear(myTable)

-- 크기 지정 테이블 생성
local arr = table.create(10, 0)  -- {0,0,0,0,0,0,0,0,0,0}

-- 테이블 복사
table.initialize(dest, source)  -- source의 내용을 dest에 복사

-- 패킹
local packed = table.pack(1, 2, 3)  -- {1, 2, 3, n=3}
```

## 14.6 요소 이동

```lua
-- 테이블 간 요소 이동
local src = {1, 2, 3, 4, 5}
local dst = {}
table.move(src, 2, 4, 1, dst)  -- dst = {2, 3, 4}
```

---

# Part 15: Lua os 라이브러리

시간 및 날짜 처리를 위한 Lua 표준 라이브러리입니다.

## 15.1 현재 시간 가져오기

```lua
-- 현재 Unix 타임스탬프 (1970년 1월 1일부터의 초)
local timestamp = os.time()
log("현재 타임스탬프:", timestamp)

-- CPU 시간 (프로그램이 사용한 시간, 초 단위)
local cpuTime = os.clock()
```

## 15.2 날짜/시간 포맷팅

```lua
-- 기본 날짜 문자열
local dateStr = os.date()  -- "Wed Jan 15 14:30:45 2025" 형식

-- 커스텀 포맷
os.date("%Y-%m-%d")        -- "2025-01-15"
os.date("%H:%M:%S")        -- "14:30:45"
os.date("%Y년 %m월 %d일")   -- "2025년 01월 15일"

-- 특정 타임스탬프로부터
os.date("%Y-%m-%d", 1704067200)  -- 지정된 시간

-- 테이블 형태로 반환
local t = os.date("*t")
log(t.year, t.month, t.day)    -- 2025, 1, 15
log(t.hour, t.min, t.sec)      -- 14, 30, 45
log(t.wday)                    -- 4 (수요일, 1=일요일)
```

## 15.3 시간 차이 계산

```lua
-- 시작/종료 시간 측정
local startTime = os.time()
-- ... 작업 수행 ...
local endTime = os.time()

-- 차이 계산 (초 단위)
local elapsed = os.difftime(endTime, startTime)
log("경과 시간:", elapsed, "초")
```

## 15.4 특정 날짜의 타임스탬프

```lua
-- 테이블로 날짜 지정하여 타임스탬프 생성
local birthday = os.time({
    year = 2000,
    month = 5,
    day = 15,
    hour = 12,    -- 선택
    min = 0,      -- 선택
    sec = 0       -- 선택
})

-- 날짜 비교 예제
local now = os.time()
local daysSince = math.floor((now - birthday) / (24 * 60 * 60))
log("생일로부터", daysSince, "일 경과")
```

## 15.5 게임에서의 활용 예시

```lua
-- 일일 보상 시스템
[server only]
Function CheckDailyReward(string playerId)
{
    local lastLogin = _DataStorageService:GetData(playerId, "lastLogin")
    local today = os.date("%Y-%m-%d")
    
    if lastLogin ~= today then
        -- 일일 보상 지급
        GiveReward(playerId, "daily")
        _DataStorageService:SetData(playerId, "lastLogin", today)
    end
}

-- 이벤트 기간 체크
Function IsEventActive()
{
    local now = os.time()
    local eventStart = os.time({year=2025, month=1, day=1})
    local eventEnd = os.time({year=2025, month=1, day=31})
    
    return now >= eventStart and now <= eventEnd
}
```

---

# Part 16: Misc - Color API

색상 처리를 위한 Color 클래스입니다.

## 16.1 Color 생성

```lua
-- RGB로 생성 (0~1 범위)
local red = Color(1, 0, 0)           -- 빨강 (a = 1)
local green = Color(0, 1, 0)         -- 초록
local blue = Color(0, 0, 1)          -- 파랑

-- RGBA로 생성 (투명도 포함)
local semiTransparent = Color(1, 0, 0, 0.5)  -- 반투명 빨강

-- 프리셋 색상 사용
local black = Color.black      -- (0, 0, 0, 1)
local white = Color.white      -- (1, 1, 1, 1)
local red = Color.red          -- (1, 0, 0, 1)
local green = Color.green      -- (0, 1, 0, 1)
local blue = Color.blue        -- (0, 0, 1, 1)
local yellow = Color.yellow    -- (1, 0.92, 0.016, 1)
local cyan = Color.cyan        -- (0, 1, 1, 1)
local magenta = Color.magenta  -- (1, 0, 1, 1)
local gray = Color.gray        -- (0.5, 0.5, 0.5, 1)
local clear = Color.clear      -- (0, 0, 0, 0) 완전 투명
```

## 16.2 헥스 코드 변환

```lua
-- 헥스 코드로 Color 생성
local myColor = Color.FromHexCode("#FF5733")      -- RGB
local myColor2 = Color.FromHexCode("#FF5733CC")   -- RGBA

-- Color를 헥스 코드로 변환
local hex = Color.ToHexCode(myColor)  -- "#FF5733FF"
-- 또는 인스턴스 메서드
local hex = myColor:ToHexCode()

-- 정수 RGBA 변환
local colorInt = Color.ToRGBAInt(myColor)
local colorFromInt = Color.FromRGBAInt(0xFF5733FF)
```

## 16.3 색상 보간 (Lerp)

```lua
-- 두 색상 사이 보간 (t = 0~1)
local startColor = Color.red
local endColor = Color.blue
local midColor = Color.Lerp(startColor, endColor, 0.5)  -- 보라색

-- 인스턴스 메서드
local result = startColor:Lerp(endColor, 0.5)

-- 범위 제한 없는 보간
local extrapolated = Color.LerpUnclamped(startColor, endColor, 1.5)

-- 페이드 인/아웃 효과
[client only]
Function FadeOut(SpriteRendererComponent sprite, float duration)
{
    local startColor = sprite.Color
    local endColor = Color(startColor.r, startColor.g, startColor.b, 0)
    local elapsed = 0
    
    while elapsed < duration do
        elapsed = elapsed + _TimerService.DeltaTime
        local t = elapsed / duration
        sprite.Color = Color.Lerp(startColor, endColor, t)
        wait()
    end
}
```

## 16.4 HSV 색상 변환

```lua
-- HSV → RGB 변환 (H, S, V 모두 0~1 범위)
local rainbow = Color.HSVToRGB(0.5, 1, 1)  -- 청록색

-- RGB → HSV 변환
local h, s, v = Color.RGBToHSV(myColor)

-- 무지개 색상 순환
[client only]
Function RainbowEffect(SpriteRendererComponent sprite)
{
    local hue = 0
    while true do
        hue = (hue + 0.01) % 1
        sprite.Color = Color.HSVToRGB(hue, 1, 1)
        wait(0.05)
    end
}
```

## 16.5 색상 연산

```lua
-- 색상 더하기
local combined = Color.red + Color.green  -- 노란색

-- 색상 빼기
local diff = Color.white - Color.red  -- 청록색

-- 스칼라 곱셈 (밝기 조절)
local dimmed = Color.white * 0.5      -- 회색
local brighter = Color.gray * 2       -- 더 밝은 색

-- 색상끼리 곱셈 (마스킹)
local masked = Color.white * Color.red  -- 빨강

-- 나눗셈
local divided = Color.white / 2       -- 회색

-- 색상 비교
if Color.red == Color.red then
    log("같은 색상!")
end
```

## 16.6 유틸리티 메서드

```lua
-- 그레이스케일 값 계산
local grayValue = Color.Grayscale(myColor)  -- 0~1 값

-- 복사본 생성
local colorCopy = myColor:Clone()

-- 속성 접근
log(myColor.r, myColor.g, myColor.b, myColor.a)
```

---

# Part 17: Entity (엔티티)

Entity는 MSW 내에서 존재하는 모든 객체의 기본 단위입니다.

## 17.1 기본 속성

```lua
-- 엔티티 기본 정보
local entity = self.Entity
log(entity.Name)            -- 이름
log(entity.Id)              -- 고유 식별자
log(entity.Path)            -- 경로
log(entity.Enable)          -- 활성화 여부
log(entity.Visible)         -- 보임 여부

-- 계층 구조
local parent = entity.Parent           -- 부모 엔티티
local children = entity.Children        -- 자식 리스트
log(entity.CurrentMapName)             -- 현재 맵 이름
```

## 17.2 자식 엔티티 관리

```lua
-- 이름으로 자식 찾기
local child = entity:GetChildByName("ItemSlot")
local childRecursive = entity:GetChildByName("Button", true)  -- 하위 전체 검색

-- ID로 자식 찾기
local childById = entity:GetChild("entity_id")

-- 자식 엔티티 붙이기
entity:AttachChild(otherEntity)

-- 자식으로 편입
entity:AttachTo(parentEntity)

-- 부모로부터 분리
entity:Detach()
```

## 17.3 컴포넌트 관리

```lua
-- 컴포넌트 가져오기
local playerComp = entity:GetComponent("PlayerComponent")
local transform = entity.TransformComponent  -- 직접 접근도 가능

-- 컴포넌트 추가
local newComp = entity:AddComponent("TextComponent")

-- 컴포넌트 제거
entity:RemoveComponent("TextComponent")

-- 자식의 컴포넌트 검색
local childTexts = entity:GetChildComponentsByTypeName("TextComponent", true)
local firstText = entity:GetFirstChildComponentByTypeName("TextComponent", true)
```

## 17.4 엔티티 복제/소멸

```lua
-- 엔티티 복제
local clone = entity:Clone("ClonedEnemy")

-- 즉시 소멸
entity:Destroy()

-- 딜레이 후 소멸
entity:Destroy(3.0)  -- 3초 후
```

## 17.5 이벤트 연결

```lua
-- 이벤트 동적 연결
local handler = entity:ConnectEvent("TriggerEnterEvent", function(event)
    log("Trigger entered!")
end)

-- 이벤트 해제
entity:DisconnectEvent("TriggerEnterEvent", handler)

-- 이벤트 발생시키기
entity:SendEvent(MyCustomEvent())
```

## 17.6 활성화/보임 설정

```lua
-- 활성화 설정
entity:SetEnable(false)                    -- 비활성화
entity:SetEnable(true, true)               -- 활성화 + 리셋
entity:SetEnable(true, false, false)       -- 동기화 없이

-- 보임 설정
entity:SetVisible(false)
```

---

# Part 18: PlayerComponent (플레이어)

플레이어를 나타내고 관련 기능을 제공하는 컴포넌트입니다.

## 18.1 플레이어 정보

```lua
local player = self.Entity.PlayerComponent

-- 기본 정보
log(player.Nickname)       -- 닉네임
log(player.UserId)         -- 고유 사용자 ID (ClienT 제어에 사용)
log(player.ProfileCode)    -- 프로필 코드

-- 체력 관리
log(player.Hp)             -- 현재 HP
log(player.MaxHp)          -- 최대 HP
player.MaxHp = 200         -- 최대 HP 변경

-- 상태 확인
if player:IsDead() then
    log("플레이어가 죽었습니다")
end
```

## 18.2 리스폰 설정

```lua
-- 리스폰 시간 설정
player.RespawnDuration = 5.0  -- 5초 후 리스폰

-- 리스폰 위치 설정
player.RespawnPosition = Vector3(100, 50, 0)

-- 리스폰 수동 실행
player:Respawn()
```

## 18.3 죽음/부활 처리

```lua
-- 플레이어 죽이기 [Client]
player:ProcessDead()
player:ProcessDead(targetUserId)  -- 특정 유저에게만

-- 플레이어 부활 [Client]
player:ProcessRevive()
```

## 18.4 맵 이동

```lua
-- 엔티티 ID로 이동 [Server]
player:MoveToEntity("target_entity_id")

-- 경로로 이동 [Server]
player:MoveToEntityByPath("/World/Map2/SpawnPoint")

-- 특정 맵의 특정 위치로 [Server]
player:MoveToMapPosition("MapName", Vector2(100, 50))
```

## 18.5 위치 설정

```lua
-- 로컬 좌표 기준
player:SetPosition(Vector3(0, 10, 0))

-- 월드 좌표 기준
player:SetWorldPosition(Vector3(100, 50, 0))
```

## 18.6 PVP 모드

```lua
-- PVP 활성화/비활성화
player.PVPMode = true   -- 플레이어 간 공격 가능
player.PVPMode = false  -- 플레이어 간 공격 불가
```

## 18.7 체크포인트 예제

```lua
[server only] [self]
HandleTriggerEnterEvent (TriggerEnterEvent event)
{
    local TriggerBodyEntity = event.TriggerBodyEntity
    local player = self.Entity.PlayerComponent

    if TriggerBodyEntity.Name == "CheckPoint" then
        -- 체크포인트 위치를 리스폰 위치로
        player.RespawnPosition = TriggerBodyEntity.TransformComponent.Position
    elseif TriggerBodyEntity.Name == "DeathZone" then
        -- 죽음 처리
        player:ProcessDead()
    end
}
```

---

# Part 19: MovementComponent (이동)

Rigidbody/Kinematicbody/Sideviewbody 제어를 위한 이동 관련 기능입니다.

## 19.1 기본 속성

```lua
local movement = self.Entity.MovementComponent

-- 이동 속력 설정
movement.InputSpeed = 5.0   -- 높을수록 빠름

-- 점프 힘 설정
movement.JumpForce = 1.5    -- 높을수록 높이 점프

-- 등반 상태 확인 (읽기 전용)
if movement.IsClimbPaused then
    log("등반 중 멈춤")
end
```

## 19.2 이동 제어

```lua
-- 방향으로 이동
movement:MoveToDirection(Vector2(1, 0), deltaTime)  -- 오른쪽
movement:MoveToDirection(Vector2(-1, 0), deltaTime) -- 왼쪽
movement:MoveToDirection(Vector2(0, 1), deltaTime)  -- 위 (사다리)

-- 이동 멈추기
movement:Stop()
```

## 19.3 점프

```lua
-- 점프 실행 (성공 여부 반환)
local success = movement:Jump()
if success then
    log("점프 성공!")
end

-- 아래 점프 (발판 통과)
local downSuccess = movement:DownJump()
```

## 19.4 위치 설정

```lua
-- 로컬 좌표로 설정
movement:SetPosition(Vector2(100, 50))

-- 월드 좌표로 설정
movement:SetWorldPosition(Vector2(100, 50))
```

## 19.5 방향 확인

```lua
-- 왼쪽을 보고 있는지
if movement:IsFaceLeft() then
    log("왼쪽을 보고 있음")
else
    log("오른쪽을 보고 있음")
end
```

## 19.6 자동 이동 예제

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

    -- 왼쪽을 바라보면 자동 이동 시작
    if not self.IsStarted and self.Entity.MovementComponent:IsFaceLeft() then
        self.IsStarted = true
    end

    if self.IsStarted then
        self.Entity.MovementComponent:MoveToDirection(Vector2(1, 0), delta)
    end
}
```

---

# Part 20: TextComponent (텍스트)

화면에 텍스트를 출력하는 컴포넌트입니다. UITransformComponent와 함께 사용을 권장합니다.

## 20.1 기본 속성

```lua
local text = self.Entity.TextComponent

-- 텍스트 내용
text.Text = "Hello, World!"

-- 폰트 설정
text.FontSize = 24
text.Font = FontType.Default
text.FontColor = Color.white

-- 굵게/기울임
text.Bold = true
```

## 20.2 정렬 및 오버플로우

```lua
-- 텍스트 정렬
text.Alignment = TextAlignmentType.UpperLeft
text.Alignment = TextAlignmentType.MiddleCenter
text.Alignment = TextAlignmentType.LowerRight

-- 오버플로우 처리
text.Overflow = OverflowType.Truncate   -- 잘라내기
text.Overflow = OverflowType.Overflow   -- 넘치게

-- 영역에 맞게 크기 조절
text.BestFit = true
text.MinSize = 10
text.MaxSize = 50
```

## 20.3 외곽선/그림자

```lua
-- 외곽선
text.UseOutLine = true
text.OutlineColor = Color.black
text.OutlineWidth = 2.0

-- 그림자
text.DropShadow = true
text.DropShadowColor = Color.black
text.DropShadowAngle = 45.0
text.DropShadowDistance = 3.0
```

## 20.4 크기 조절

```lua
-- 텍스트에 맞게 크기 조절
text.SizeFit = true

-- 최대 너비/높이 제한
text.UseConstraintX = true
text.ConstraintX = 200.0
text.UseConstraintY = true
text.ConstraintY = 100.0

-- 행간
text.LineSpacing = 1.2
```

## 20.5 리치 텍스트

```lua
text.IsRichText = true
text.Text = "<color=red>빨강</color> <size=30>크게</size> <b>굵게</b>"
```

## 20.6 텍스트 너비/높이 계산

```lua
-- 텍스트 너비 계산 [ClientOnly, Yield]
local width = text:GetPreferredWidth("Hello World")

-- 고정 너비에서 높이 계산 [ClientOnly, Yield]
local height = text:GetPreferredHeight("Long text...", 200)
```

## 20.7 타이핑 효과 예제

```lua
Property:
[None] number TimerID = 0
[None] string RawMessage = ""
[None] number MessageIdx = 0

[client only]
void OnBeginPlay()
{
    local textComponent = self.Entity.TextComponent
    textComponent.Bold = true
    textComponent.FontColor = Color.white
    textComponent.UseOutLine = true
    textComponent.OutlineColor = Color.black

    self:ShowTypingEffect("안녕하세요. MSW에 오신 것을 환영합니다.", 0.1)
}

void ShowTypingEffect(string message, number interval)
{
    self.MessageIdx = 0
    self.RawMessage = message
    local messageLength = utf8.len(message)

    self.TimerID = _TimerService:SetTimerRepeat(function()
        if self.MessageIdx < messageLength then
            self.MessageIdx = self.MessageIdx + 1
            local currentString = _UtilLogic:SubString(self.RawMessage, 1, self.MessageIdx)
            self.Entity.TextComponent.Text = currentString
        else
            self.Entity.TextComponent.Text = ""
            self.MessageIdx = 0  -- 다시 시작
        end
    end, interval)
}
```

---

# Part 21: UtilLogic (유틸리티 로직)

UtilLogic은 다양한 유틸리티 함수들을 제공하는 로직 클래스입니다.

## 21.1 속성

```lua
-- 시간 관련
local elapsed = _UtilLogic.ElapsedSeconds        -- 월드 초기화 후 경과 시간 (초)
local serverElapsed = _UtilLogic.ServerElapsedSeconds  -- 서버 생성 후 경과 시간
```

## 21.2 난수 생성

```lua
-- 임의의 정수 (0 ~ 2147483646)
local randInt = _UtilLogic:RandomInteger()

-- 범위 내 정수 (min, max 포함)
local randRange = _UtilLogic:RandomIntegerRange(1, 100)

-- 임의의 실수 (0.0 ~ 1.0 미만)
local randDouble = _UtilLogic:RandomDouble()

-- GUID 생성
local guid = _UtilLogic:NewGuid()  -- 32자리 16진수 문자열
```

## 21.3 문자열 처리

```lua
-- 문자열 포함 확인
local contains = _UtilLogic:Contains("hello world", "world")  -- true

-- 문자열 분할
local parts = _UtilLogic:Split("a,b,c", ",")  -- {"a", "b", "c"}

-- 문자열 교체
local replaced = _UtilLogic:Replace("hello", "l", "L")  -- "heLLo"

-- 문자열 삽입
local inserted = _UtilLogic:Insert("abcde", 2, "123")  -- "a123bcde"

-- 부분 문자열
local sub = _UtilLogic:SubString("abcdefg", 1, 3)  -- "abc"

-- 문자열 제거
local removed = _UtilLogic:Remove("hello", "l")  -- "helo"

-- 공백 제거
local trimmed = _UtilLogic:Trim("  hello  ")
local trimStart = _UtilLogic:TrimStart("[text]", "[]")  -- "text]"
local trimEnd = _UtilLogic:TrimEnd("[text]", "[]")    -- "[text"

-- nil 또는 빈 문자열 확인
local isEmpty = _UtilLogic:IsNilorEmptyString("")  -- true
```

## 21.4 테이블 <-> 문자열 변환

```lua
-- 테이블을 문자열로
local myTable = {"first", "second"}
local tableStr = _UtilLogic:TableToString(myTable)

-- 문자열을 테이블로
local restoredTable = _UtilLogic:StringToTable(tableStr)
```

## 21.5 기하학 함수

```lua
-- 볼록 다각형 (Convex Hull)
local points = {Vector2(0,0), Vector2(1,0), Vector2(0.5,1)}
local convexPoints = _UtilLogic:ConvexHull(points)

-- 오목 다각형 (Concave Hull)
-- concavity: 0~1 (오목한 정도), samplingWeight: 1.0~1.2 권장
local concavePoints = _UtilLogic:ConcaveHull(points, 0.5, 1.1)

-- 스프라이트 테두리 점 획득 (ClientOnly)
local edgePoints = _UtilLogic:GetSpriteEdgePoints(sprite)
```

## 21.6 시간 조절

```lua
-- 클라이언트 게임 시간 속도 조절 (ClientOnly)
-- 기본값: 1.0, 범위: 0~100
_UtilLogic:SetClientTimeScale(0.5)  -- 2배 느리게
_UtilLogic:SetClientTimeScale(2.0)  -- 2배 빠르게
_UtilLogic:SetClientTimeScale(0)    -- 시간 정지
```

---

# Part 22: Vector2 & Vector3 (벡터)

Vector2는 2차원, Vector3는 3차원 벡터를 나타냅니다.

## 22.1 생성 및 상수

```lua
-- Vector2 생성
local v2 = Vector2(3, 4)
log(v2.x, v2.y)  -- 3, 4

-- Vector3 생성
local v3 = Vector3(1, 2, 3)
log(v3.x, v3.y, v3.z)  -- 1, 2, 3

-- 상수 벡터
Vector2.zero        -- (0, 0)
Vector2.one         -- (1, 1)
Vector2.up          -- (0, 1)
Vector2.down        -- (0, -1)
Vector2.left        -- (-1, 0)
Vector2.right       -- (1, 0)

Vector3.zero        -- (0, 0, 0)
Vector3.one         -- (1, 1, 1)
Vector3.up          -- (0, 1, 0)
Vector3.down        -- (0, -1, 0)
Vector3.left        -- (-1, 0, 0)
Vector3.right       -- (1, 0, 0)
Vector3.forward     -- (0, 0, 1)
Vector3.back        -- (0, 0, -1)
```

## 22.2 벡터 연산

```lua
local a = Vector2(1, 2)
local b = Vector2(3, 4)

-- 기본 연산
local sum = a + b           -- (4, 6)
local diff = a - b          -- (-2, -2)
local scaled = a * 2        -- (2, 4)
local divided = a / 2       -- (0.5, 1)

-- 역벡터
local neg = -a              -- (-1, -2)
```

## 22.3 벡터 함수

```lua
-- 거리
local distance = a:Distance(b)
local distanceStatic = Vector2.Distance(a, b)

-- 크기 (길이)
local magnitude = a:Magnitude()
local sqrMag = a:SqrMagnitude()  -- 제곱 (더 빠름)

-- 정규화 (크기 1로)
local normalized = a:Normalize()

-- 내적 (Dot Product)
local dot = a:Dot(b)

-- 각도
local angle = a:Angle(b)           -- 0~180
local signedAngle = a:SignedAngle(b)  -- -180~180

-- 보간
local lerped = a:Lerp(b, 0.5)      -- 선형 보간
local slerped = a:Slerp(b, 0.5)    -- 구면 선형 보간

-- 투영 (Projection)
local projected = a:Project(b)

-- 반사 (Reflection)
local reflected = a:Reflect(normal)

-- 수직 벡터 (Vector2 only)
local perpendicular = a:Perpendicular()  -- 반시계 90도 회전
```

## 22.4 Vector3 추가 함수

```lua
local v1 = Vector3(1, 0, 0)
local v2 = Vector3(0, 1, 0)

-- 외적 (Cross Product)
local cross = v1:Cross(v2)  -- (0, 0, 1)
local crossStatic = Vector3.Cross(v1, v2)

-- 평면에 사영
local projected = v1:ProjectOnPlane(planeNormal)
```

## 22.5 변환

```lua
-- Vector2 -> Vector3
local v3 = Vector2(1, 2):ToVector3()  -- (1, 2, 0)

-- Vector3 -> Vector2
local v2 = Vector3(1, 2, 3):ToVector2()  -- (1, 2)

-- 정수 변환 (Vector2Int)
local intVec = Vector2(1.5, 2.7):ToVector2Int()      -- 내림
local intVec2 = Vector2(1.5, 2.7):RoundToInt()       -- 반올림
local intVec3 = Vector2(1.5, 2.7):CeilToInt()        -- 올림
local intVec4 = Vector2(1.5, 2.7):FloorToInt()       -- 내림
```

---

# Part 23: DateTime (날짜/시간)

DateTime은 날짜와 시간을 나타내는 클래스입니다.

## 23.1 생성

```lua
-- 년/월/일로 생성
local date1 = DateTime(2024, 1, 15)

-- 년/월/일/시/분/초로 생성
local date2 = DateTime(2024, 1, 15, 10, 30, 45)

-- 밀리초 값으로 생성
local date3 = DateTime(1705315845000)

-- 문자열로 생성
local date4 = DateTime("2024-01-15 10:30:45")
local date5 = DateTime("15/01/2024", "dd/MM/yyyy")
```

## 23.2 현재 시간

```lua
-- UTC 기준 현재 시간
local now = DateTime.UtcNow
log(now.Year, now.Month, now.Day)
log(now.Hour, now.Minute, now.Second)
```

## 23.3 속성

```lua
local dt = DateTime.UtcNow

dt.Year          -- 년
dt.Month         -- 월 (1-12)
dt.Day           -- 일 (1-31)
dt.DayOfWeek     -- 요일 (DayOfWeekType enum)
dt.Hour          -- 시 (0-23)
dt.Minute        -- 분 (0-59)
dt.Second        -- 초 (0-59)
dt.Millisecond   -- 밀리초 (0-999)
dt.Elapsed       -- 밀리초 단위 정수

-- 상수
DateTime.MinValue  -- 최소값
DateTime.MaxValue  -- 최대값
```

## 23.4 연산

```lua
local dt1 = DateTime(2024, 1, 15)
local dt2 = DateTime(2024, 1, 20)

-- 비교
local isEqual = (dt1 == dt2)
local isBefore = (dt1 < dt2)
local isAfter = (dt1 > dt2)

-- 차이 계산 (TimeSpan 반환)
local diff = dt2 - dt1

-- TimeSpan 더하기/빼기
local dt3 = dt1 + TimeSpan.FromDays(5)
local dt4 = dt1 - TimeSpan.FromHours(12)
```

## 23.5 포맷팅

```lua
local dt = DateTime.UtcNow

-- 형식화된 문자열로 변환
local formatted = dt:ToFormattedString("yyyy-MM-dd HH:mm:ss")

-- 문화권 지정
local formattedKo = dt:ToFormattedString("yyyy년 MM월 dd일", "ko-KR")
```

## 23.6 로컬 시간 변환

```lua
-- UTC를 로컬 시간으로 변환 (ClientOnly)
local utcTime = DateTime.UtcNow
local localTime = _UtilLogic:GetLocalTimeFrom(utcTime)

-- 로컬 시간 여부 확인
local isLocal = localTime:IsLocalTime()
```

---

# Part 24: TimeSpan (시간 간격)

TimeSpan은 시간 간격을 나타내는 클래스입니다.

## 24.1 생성

```lua
-- 정적 메서드로 생성
local span1 = TimeSpan.FromDays(1)
local span2 = TimeSpan.FromHours(12)
local span3 = TimeSpan.FromMinutes(30)
local span4 = TimeSpan.FromSeconds(90)
local span5 = TimeSpan.FromMilliseconds(5000)
```

## 24.2 속성

```lua
local ts = TimeSpan.FromHours(25.5)

ts.Days         -- 일 부분
ts.Hours        -- 시간 부분 (0-23)
ts.Minutes      -- 분 부분 (0-59)
ts.Seconds      -- 초 부분 (0-59)
ts.Milliseconds -- 밀리초 부분 (0-999)

ts.TotalDays        -- 총 일수 (실수)
ts.TotalHours       -- 총 시간 (실수)
ts.TotalMinutes     -- 총 분 (실수)
ts.TotalSeconds     -- 총 초 (실수)
ts.TotalMilliseconds -- 총 밀리초 (정수)
```

## 24.3 연산

```lua
local ts1 = TimeSpan.FromHours(2)
local ts2 = TimeSpan.FromMinutes(30)

local sum = ts1 + ts2      -- 2시간 30분
local diff = ts1 - ts2     -- 1시간 30분

-- DateTime과 함께 사용
local future = DateTime.UtcNow + TimeSpan.FromDays(7)
```

---

# Part 25: InputService (입력 서비스)

InputService는 유저의 키보드, 마우스, 터치 입력을 처리합니다.

## 25.1 키보드 입력 확인

```lua
-- 특정 키가 눌린 상태인지 확인 (ClientOnly)
if _InputService:IsKeyPressed(KeyboardKey.Space) then
    log("Space is pressed")
end

-- 아무 키나 눌렸는지 확인
if _InputService:IsAnyKeyPressed() then
    log("Some key is pressed")
end
```

## 25.2 마우스/커서 제어

```lua
-- 커서 위치 가져오기 (ClientOnly)
local cursorPos = _InputService:GetCursorPosition()

-- 커서가 UI 위에 있는지 확인
local overUI = _InputService:IsPointerOverUI()

-- 커서 모양 변경
_InputService:SetCursor("spriteRUID", Vector2.zero)
_InputService:ResetCursor()

-- 커서 표시/숨기기
_InputService:SetCursorVisible(false)

-- 커서 잠금 모드 (PC only)
_InputService:CursorLockMode(CursorLockMode.Locked)
local mode = _InputService:GetCursorLockMode()
```

## 25.3 이벤트 핸들링

```lua
-- 키 이벤트 처리
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    if event.key == KeyboardKey.Z then
        log("Z 키 누름")
    end
}

HandleKeyUpEvent (KeyUpEvent event)
{
    log("키 뗌:", event.key)
}

HandleKeyHoldEvent (KeyHoldEvent event)
{
    log("키 홀드 중:", event.key)
}

-- 터치/클릭 이벤트
HandleScreenTouchEvent (ScreenTouchEvent event)
{
    local touchId = event.TouchId
    local touchPoint = event.TouchPoint
}

-- 마우스 이벤트
HandleMouseMoveEvent (MouseMoveEvent event)
{
    log("마우스 이동")
}

HandleMouseScrollEvent (MouseScrollEvent event)
{
    log("스크롤")
}

-- 모바일 핀치 이벤트
HandlePinchInOutEvent (PinchInOutEvent event)
{
    log("핀치 줌")
}
```

---

# Part 26: TimerService (타이머 서비스)

TimerService는 함수를 일정 시간 후 또는 반복적으로 호출합니다.

## 26.1 타이머 설정

```lua
-- 1회 실행 (delaySeconds 후 실행)
local timerId = _TimerService:SetTimerOnce(function()
    log("3초 후 실행됨")
end, 3.0)

-- 반복 실행
local repeatId = _TimerService:SetTimerRepeat(function()
    log("1초마다 실행")
end, 1.0, 0)  -- intervalSeconds, startDelaySeconds

-- 기본 타이머 (더 상세한 설정)
local id = _TimerService:SetTimer(
    self,           -- scriptable (소유자)
    callback,       -- 콜백 함수
    1.0,            -- intervalSeconds
    true,           -- isRepeat
    0               -- startDelaySeconds
)
```

## 26.2 타이머 해제

```lua
if timerId > 0 then
    _TimerService:ClearTimer(timerId)
end
```

## 26.3 시계 예제

```lua
-- 초침 회전 구현
Property:
[None]
integer TimerId = 0

Method:
[server only]
void OnBeginPlay()
{
    local rotateFunc = function()
        local transform = self.Entity.TransformComponent
        transform.ZRotation = transform.ZRotation - 6  -- 360/60
    end
    
    self.TimerId = _TimerService:SetTimerRepeat(rotateFunc, 1.0)
}

[server only]
void OnEndPlay()
{
    if self.TimerId > 0 then
        _TimerService:ClearTimer(self.TimerId)
    end
}
```

---

# Part 27: SoundService (사운드 서비스)

SoundService는 배경음악과 효과음을 재생합니다.

## 27.1 배경음악 (BGM)

```lua
-- 재생 (id: RUID, volume: 0.0~1.0)
_SoundService:PlayBGM("soundRUID", 0.8)

-- 일시정지 / 재개 / 정지
_SoundService:PauseBGM()
_SoundService:ResumeBGM()
_SoundService:StopBGM(true)  -- immediately

-- 재생 중인지 확인
if _SoundService:IsPlayBGM() then
    log("BGM 재생 중")
end

-- 볼륨 조절
_SoundService:SetBGMVolume(0.5)
```

## 27.2 효과음

```lua
-- 1회 재생
_SoundService:PlaySound("soundRUID", 1.0)

-- 반복 재생
_SoundService:PlayLoopSound("soundRUID", 0.8)

-- 위치 기반 재생 (3D 사운드)
_SoundService:PlaySoundAtPos("soundRUID", Vector3(100, 50, 0), listener, 1.0)
_SoundService:PlayLoopSoundAtPos("soundRUID", Vector3(100, 50, 0), listener, 0.8)

-- 정지 / 일시정지 / 재개
_SoundService:StopSound("soundRUID")
_SoundService:PauseSound("soundRUID")
_SoundService:ResumeSound("soundRUID")

-- 사운드 미리 로드
_SoundService:LoadSound("soundRUID")
```

## 27.3 특정 유저에게만 재생

```lua
-- 서버에서 특정 유저에게 재생
_SoundService:PlayBGM("soundRUID", 0.8, player.PlayerComponent.UserId)
_SoundService:PlaySound("soundRUID", 1.0, player.PlayerComponent.UserId)
```

---

# Part 28: Vector2Int (정수 벡터)

Vector2Int는 정수 좌표를 위한 2차원 벡터입니다.

## 28.1 생성 및 상수

```lua
-- 생성
local pos = Vector2Int(10, 20)
log(pos.x, pos.y)  -- 10, 20

-- 상수
Vector2Int.zero   -- (0, 0)
Vector2Int.one    -- (1, 1)
Vector2Int.up     -- (0, 1)
Vector2Int.down   -- (0, -1)
Vector2Int.left   -- (-1, 0)
Vector2Int.right  -- (1, 0)
```

## 28.2 연산

```lua
local a = Vector2Int(1, 2)
local b = Vector2Int(3, 4)

local sum = a + b           -- (4, 6)
local diff = a - b          -- (-2, -2)
local scaled = a * 2        -- (2, 4)
local divided = a / 2       -- (0, 1)
local neg = -a              -- (-1, -2)
```

## 28.3 함수

```lua
-- 거리, 크기, 각도
local distance = a:Distance(b)
local magnitude = a:Magnitude()
local sqrMag = a:SqrMagnitude()
local angle = a:Angle(b)
local signedAngle = a:SignedAngle(b)

-- 복사 및 변환
local copy = a:Clone()
local v2 = a:ToVector2()  -- Vector2로 변환
```

---

# Part 29: RectOffset (사각형 오프셋)

RectOffset은 사각형의 상하좌우 여백을 나타냅니다.

## 29.1 생성 및 속성

```lua
-- 생성: (left, right, top, bottom)
local offset = RectOffset(10, 10, 5, 5)

-- 속성 접근
log(offset.left)    -- 10
log(offset.right)   -- 10
log(offset.top)     -- 5
log(offset.bottom)  -- 5
```

## 29.2 복사

```lua
local copy = offset:Clone()
```

---

# Part 30: SpawnService (스폰 서비스)

SpawnService는 엔티티를 동적으로 생성(스폰)합니다.

## 30.1 엔티티 기반 스폰

```lua
-- 기존 엔티티를 복제하여 스폰
local original = _EntityService:GetEntityByPath("TemplateEntity")
local clone = _SpawnService:SpawnByEntity(
    original,               -- 원본 엔티티
    "ClonedEntity",         -- 새 엔티티 이름
    Vector3(100, 50, 0),    -- 스폰 위치
    nil,                    -- 부모 (nil이면 원본의 부모 사용)
    true                    -- 자식 포함 여부
)
```

## 30.2 모델 ID로 스폰

```lua
-- 모델 Entry ID로 스폰
local newEntity = _SpawnService:SpawnByModelId(
    "model_entry_id",       -- 모델 RUID
    "NewMonster",           -- 엔티티 이름
    Vector3(200, 100, 0),   -- 스폰 위치
    parentEntity            -- 부모 엔티티
)
```

## 30.3 몬스터 스폰 예제

```lua
[server only]
void OnBeginPlay()
{
    local template = _EntityService:GetEntityByPath("Monsters/Slime")
    
    for i = 1, 5 do
        local pos = Vector3(100 + i * 50, 100, 0)
        local monster = _SpawnService:SpawnByEntity(template, "Slime_" .. i, pos)
    end
}
```

---

# Part 31: UserService (유저 서비스)

UserService는 게임 내 유저 정보와 관리 기능을 제공합니다.

## 31.1 속성

```lua
-- 로컬 플레이어 (클라이언트 전용)
local me = _UserService.LocalPlayer

-- 모든 유저 엔티티 목록
local allUsers = _UserService.UserEntities  -- {userId: Entity}

-- 모든 유저 정보 목록
local users = _UserService.Users  -- {userId: User}
```

## 31.2 유저 조회

```lua
-- 유저 수 확인
local count = _UserService:GetUserCount()

-- UserId로 유저 엔티티 조회
local userEntity = _UserService:GetUserEntityByUserId(userId)

-- 프로필 코드로 유저 조회
local user = _UserService:GetUserByProfileCode(profileCode)

-- 특정 맵의 유저 조회
local usersInMap = _UserService:GetUsersByMapName("Town")
local usersInMap2 = _UserService:GetUsersByMapComponent(mapComponent)
```

## 31.3 유저 추방 (서버 전용)

```lua
_UserService:KickUser(userId, KickReason.Cheating)
```

## 31.4 이벤트

| 이벤트 | 설명 |
|--------|------|
| `UserEnterEvent` | 유저 입장 시 |
| `UserLeaveEvent` | 유저 퇴장 시 |
| `UserKickEvent` | 유저 추방 시 (서버) |
| `UserDisconnectEvent` | 네트워크 끊김 시 |
| `UserReconnectEvent` | 재접속 시 |

## 31.5 입장 이벤트 예제

```lua
[server only] [service: UserService]
HandleUserEnterEvent (UserEnterEvent event)
{
    local userId = event.UserId
    local userEntity = _UserService:GetUserEntityByUserId(userId)
    local nametag = userEntity.NameTagComponent
    
    nametag.Name = "Welcome, " .. userEntity.PlayerComponent.Nickname
    nametag.FontColor = Color.cyan
}
```

---

# Part 32: EffectService (이펙트 서비스)

EffectService는 시각 이펙트를 재생합니다.

## 32.1 고정 위치 이펙트

```lua
-- 고정 위치에 이펙트 재생
local serial = _EffectService:PlayEffect(
    "effectRUID",           -- 애니메이션 클립 RUID
    self.Entity,            -- instigator
    Vector3(100, 50, 0),    -- 위치
    0,                      -- Z축 회전
    Vector3.one,            -- 스케일
    false,                  -- 루프 여부
    nil                     -- 옵션
)
```

## 32.2 엔티티에 부착된 이펙트

```lua
-- 엔티티에 부착 (엔티티 따라 이동)
local serial = _EffectService:PlayEffectAttached(
    "effectRUID",
    self.Entity,            -- 부모 엔티티
    Vector3.zero,           -- 로컬 위치
    0,                      -- 로컬 Z회전
    Vector3.one,            -- 로컬 스케일
    true                    -- 루프
)
```

## 32.3 이펙트 제거

```lua
if serial > 0 then
    _EffectService:RemoveEffect(serial)
end
```

## 32.4 이펙트 옵션

```lua
local options = {
    ["FlipX"] = true,
    ["FlipY"] = false,
    ["Alpha"] = 0.8,
    ["Color"] = Color.red,
    ["PlayRate"] = 2.0,
    ["SortingLayer"] = "Foreground",
    ["OrderInLayer"] = 10
}

_EffectService:PlayEffect("ruid", entity, pos, 0, Vector3.one, false, options)
```

## 32.5 스킬 이펙트 예제

```lua
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    if event.key == KeyboardKey.Q then
        local pos = self.Entity.TransformComponent.Position
        local lookDir = self.Entity.PlayerControllerComponent.LookDirectionX
        
        local options = { ["FlipX"] = lookDir > 0 }
        _EffectService:PlayEffect("skillEffect", self.Entity, pos, 0, Vector3.one, false, options)
    end
}
```

---

# Part 33: TweenLogic (트윈 로직)

TweenLogic은 값의 부드러운 보간(Tween) 기능을 제공합니다.

## 33.1 직접 이동

```lua
-- 목표 위치로 이동
_TweenLogic:MoveTo(entity, Vector2(100, 50), 2.0, EaseType.QuartEaseOut)

-- 현재 위치 기준 오프셋 이동
_TweenLogic:MoveOffset(entity, Vector2(50, 0), 1.5, EaseType.Linear)
```

## 33.2 회전과 스케일

```lua
-- 회전 (반시계 방향)
_TweenLogic:RotateTo(entity, 90, 1.0, EaseType.SineEaseInOut)

-- 축 기준 회전
_TweenLogic:RotateAroundOffset(entity, 360, Vector2(0, 50), true, 3.0, EaseType.Linear)

-- 스케일 변경
_TweenLogic:ScaleTo(entity, Vector2(2, 2), 0.5, EaseType.BackEaseOut)
```

## 33.3 커스텀 트윈

```lua
-- 콜백 함수로 트윈
local tweener = _TweenLogic:PlayTween(
    0,                      -- 시작값
    100,                    -- 끝값
    2.0,                    -- 재생 시간
    EaseType.QuadEaseInOut, -- 이징 타입
    function(value)         -- 콜백
        self.Entity.TransformComponent.Position = Vector3(value, 0, 0)
    end
)
```

## 33.4 Tweener 객체

```lua
-- Tweener 생성
local tweener = _TweenLogic:MakeTween(0, 255, 1.0, EaseType.Linear, function(val)
    self.Entity.SpriteRendererComponent:SetAlpha(val / 255)
end)

-- 재생 제어
tweener:Play()
tweener:Pause()
tweener:Stop()
```

## 33.5 네이티브 트윈 (고성능)

```lua
-- 컴포넌트의 메서드를 직접 호출 (더 빠름)
local tweener = _TweenLogic:MakeNativeTween(
    1, 0, 3.0, EaseType.Linear,
    self.Entity.SpriteRendererComponent,
    "SetAlpha"
)
tweener:Play()
```

## 33.6 보간 값 계산

```lua
-- 단일 값 보간
local value = _TweenLogic:Ease(
    0,                  -- 시작값
    100,                -- 끝값
    2.0,                -- 전체 시간
    EaseType.QuartEaseIn,
    elapsedTime         -- 경과 시간
)
```

---

# Part 34: UILogic (UI 로직)

UILogic은 UI 좌표 변환 기능을 제공합니다.

## 34.1 속성

```lua
-- 화면 크기 (클라이언트 전용)
local width = _UILogic.ScreenWidth
local height = _UILogic.ScreenHeight
```

## 34.2 좌표 변환 메서드

```lua
-- Screen → World
local worldPos = _UILogic:ScreenToWorldPosition(screenPos)

-- Screen → UI
local uiPos = _UILogic:ScreenToUIPosition(screenPos)

-- Screen → 로컬 UI (특정 UI 기준)
local localPos = _UILogic:ScreenToLocalUIPosition(screenPos, uiTransformComponent)

-- UI → World
local worldPos = _UILogic:UIToWorldPosition(uiPos)

-- 로컬 UI → World
local worldPos = _UILogic:LocalUIToWorldPosition(localPos, uiTransformComponent)

-- World → Screen
local screenPos = _UILogic:WorldToScreenPosition(worldPos)
```

## 34.3 터치 위치로 텔레포트

```lua
[service: InputService]
HandleScreenTouchEvent (ScreenTouchEvent event)
{
    local touchPoint = event.TouchPoint
    local worldPos = _UILogic:ScreenToWorldPosition(touchPoint)
    local destination = Vector3(worldPos.x, worldPos.y, 0)
    
    _TeleportService:TeleportToMapPosition(
        _UserService.LocalPlayer,
        destination,
        _UserService.LocalPlayer.CurrentMapName
    )
}
```

## 34.4 터치 위치에 UI 이동

```lua
[service: InputService]
HandleScreenTouchEvent (ScreenTouchEvent event)
{
    local touchPoint = event.TouchPoint
    local uiPos = _UILogic:ScreenToUIPosition(touchPoint)
    
    self.followingUI.anchoredPosition = uiPos
}
```

---

# Part 35: DataService (데이터셋 서비스)

DataService는 미리 정의된 데이터셋에서 데이터를 읽어옵니다.

## 35.1 데이터 조회

```lua
-- 특정 셀 데이터 (행/열 인덱스로)
local value = _DataService:GetCell("ItemTable", 1, 2)

-- 특정 셀 데이터 (행 인덱스 + 열 이름으로)
local name = _DataService:GetCell("ItemTable", 1, "name")

-- 행 개수 조회
local rowCount = _DataService:GetRowCount("ItemTable")
```

## 35.2 테이블 전체 조회

```lua
-- 데이터셋 테이블 객체 얻기
local dataSet = _DataService:GetTable("MonsterData")

-- 테이블 순회
for i = 1, dataSet:GetRowCount() do
    local name = dataSet:GetCell(i, "name")
    local hp = dataSet:GetCell(i, "hp")
    log(name, hp)
end
```

## 35.3 아이템 데이터 로드 예제

```lua
[server only]
void LoadItems()
{
    local itemTable = _DataService:GetTable("ItemList")
    
    for i = 1, itemTable:GetRowCount() do
        local itemInfo = {
            id = itemTable:GetCell(i, "id"),
            name = itemTable:GetCell(i, "name"),
            price = tonumber(itemTable:GetCell(i, "price"))
        }
        self.itemData[itemInfo.id] = itemInfo
    end
}
```

---

# Part 36: TeleportService (텔레포트 서비스)

TeleportService는 엔티티를 특정 위치로 순간 이동시킵니다.

## 36.1 기본 텔레포트

```lua
-- 다른 엔티티 위치로 텔레포트
_TeleportService:TeleportToEntity(myEntity, targetEntity)

-- 특정 좌표로 텔레포트
_TeleportService:TeleportToMapPosition(myEntity, Vector3(100, 50, 0), "Town")

-- 엔티티 경로로 텔레포트
_TeleportService:TeleportToEntityPath(myEntity, "SpawnPoints/Point1")
```

## 36.2 예약 텔레포트

```lua
-- 여러 엔티티의 텔레포트를 예약
_TeleportService:ReserveTeleportToMapPosition(entity1, Vector3(100, 0, 0), "Map1")
_TeleportService:ReserveTeleportToMapPosition(entity2, Vector3(200, 0, 0), "Map1")
_TeleportService:ReserveTeleportToEntity(entity3, spawnPoint)

-- 예약된 모든 텔레포트 실행
_TeleportService:TeleportReservedEntities()

-- 예약 취소
_TeleportService:UnReserveTeleport(entity1)
_TeleportService:ClearReservation()  -- 전체 취소
```

## 36.3 월드 워프 (서버 전용)

```lua
-- 다른 월드로 워프 (동기)
local success = _TeleportService:WarpUserToWorldAndWait(userId, "world_id", "warpData")

-- 다른 월드로 워프 (비동기)
_TeleportService:WarpUserToWorldAsync(userId, "world_id", "warpData", function(success)
    if success then log("Warp succeeded") end
end)

-- 워프 기록 조회
local record = _TeleportService:GetWarpRecord(userId)
```

## 36.4 몬스터 모으기 스킬

```lua
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    if event.key == KeyboardKey.LeftShift then
        local me = _UserService.LocalPlayer
        local monsters = _EntityService:GetEntitiesByTag("Monster")
        
        for i = 1, #monsters do
            _TeleportService:TeleportToEntity(monsters[i], me)
        end
        
        -- 내 캐릭터는 위로 점프
        local pos = me.TransformComponent.Position
        _TeleportService:TeleportToMapPosition(me, pos + Vector3(0, 2, 0), me.CurrentMapName)
    end
}
```

---

# Part 37: CollisionService (충돌 서비스)

CollisionService는 충돌 관련 기능을 제공합니다.

## 37.1 CollisionSimulator 얻기

```lua
-- 엔티티로부터
local simulator = _CollisionService:GetSimulator(self.Entity)

-- 맵 이름으로
local simulator = _CollisionService:GetSimulator("Town")
```

## 37.2 충돌 그룹 확인

```lua
-- 두 충돌 그룹이 충돌하는지 확인
local canCollide = _CollisionService:IsCollidableBetweenCollisionGroups(group1, group2)

-- 특정 그룹과 충돌하는 모든 그룹 조회
local collidingGroups = _CollisionService:GetCollisionGroupsWith(filterGroup)
```

## 37.3 OverlapCircle (범위 내 충돌체 찾기)

```lua
local simulator = _CollisionService:GetSimulator(self.Entity)
local position = self.Entity.TransformComponent.WorldPosition:ToVector2()

-- 반경 1 내의 TriggerComponent 찾기
local overlaps = simulator:OverlapCircleAll("TriggerBox", position, 1)

for i = 1, #overlaps do
    local trigger = overlaps[i]
    
    if trigger.Entity ~= self.Entity and trigger.EnableInHierarchy then
        log(trigger.Entity.Name)
    end
end
```

## 37.4 범위 공격 예제

```lua
[server only]
void PerformAOEAttack(Vector3 center, number radius, number damage)
{
    local simulator = _CollisionService:GetSimulator(self.Entity)
    local overlaps = simulator:OverlapCircleAll("Monster", center:ToVector2(), radius)
    
    for i = 1, #overlaps do
        local monster = overlaps[i].Entity
        if monster.HealthComponent then
            monster.HealthComponent:TakeDamage(damage)
        end
    end
}
```

---

# Part 38: ScreenMessageLogic (화면 메시지 로직)

ScreenMessageLogic은 화면에 알림 메시지를 띄웁니다.

## 38.1 메시지 표시

```lua
-- 자신에게만 표시 (클라이언트 전용)
_ScreenMessageLogic:PrivateMsg("획득: 경험치 100")

-- 모든 유저에게 표시
_ScreenMessageLogic:PublicMsg("보스가 출현했습니다!")

-- 특정 유저에게 표시
_ScreenMessageLogic:PublicMsg("레벨업!", targetUserId)
```

## 38.2 유저 입장 알림 예제

```lua
[server only] [service: UserService]
HandleUserEnterEvent (UserEnterEvent event)
{
    local userId = event.UserId
    local userEntity = _UserService:GetUserEntityByUserId(userId)
    local userName = userEntity.NameTagComponent.Name
    
    _ScreenMessageLogic:PublicMsg(userName .. " 님이 입장했습니다.")
}
```

## 38.3 사망 메시지 예제

```lua
[client only] [self]
HandleDeadEvent (DeadEvent event)
{
    if _UserService.LocalPlayer ~= self.Entity then
        return
    end
    
    _ScreenMessageLogic:PrivateMsg("YOU DIED")
}
```

---

# Part 39: DataStorageService (데이터 저장 서비스)

DataStorageService는 플레이어 데이터를 영구적으로 저장하고 불러옵니다.

## 39.1 저장소 유형

```lua
-- 유저별 저장소 (유저당 개별)
local userStorage = _DataStorageService:GetUserDataStorage(userId)

-- 글로벌 저장소 (모든 유저 공유)
local globalStorage = _DataStorageService:GetGlobalDataStorage("Leaderboard")

-- SortableDataStorage (정렬 가능, 랭킹 등)
local sortableStorage = _DataStorageService:GetSortableDataStorage("Rankings")

-- CreatorDataStorage (제작자 전용)
local creatorStorage = _DataStorageService:GetCreatorDataStorage()
```

## 39.2 데이터 저장/로드 (동기)

```lua
[server only]
void SavePlayerData(string userId)
{
    local storage = _DataStorageService:GetUserDataStorage(userId)
    
    -- 저장 (동기)
    local errorCode = storage:SetAndWait("level", "10")
    local errorCode = storage:SetAndWait("gold", "5000")
    
    if errorCode == 0 then
        log("저장 성공")
    end
}

[server only]
void LoadPlayerData(string userId)
{
    local storage = _DataStorageService:GetUserDataStorage(userId)
    
    -- 로드 (동기)
    local errorCode, level = storage:GetAndWait("level")
    local errorCode, gold = storage:GetAndWait("gold")
    
    log("레벨:", level, "골드:", gold)
}
```

## 39.3 비동기 저장/로드

```lua
[server only]
void SaveAsync(string userId)
{
    local storage = _DataStorageService:GetUserDataStorage(userId)
    
    storage:SetAsync("score", "1000", function(errorCode, key)
        if errorCode == 0 then
            log(key .. " 저장 성공")
        end
    end)
}
```

---

# Part 40: ItemService (아이템 서비스)

ItemService는 아이템 생성, 삭제, 소유권 이전 등을 관리합니다.

## 40.1 아이템 생성

```lua
[server only]
void CreateItem()
{
    local inventory = self.Entity.InventoryComponent
    
    -- 아이템 생성 (타입, 데이터테이블명, 소유자 인벤토리)
    local newItem = _ItemService:CreateItem(EquipmentItem, "Sword01", inventory)
    newItem.ItemCount = 1
}
```

## 40.2 아이템 조회 및 삭제

```lua
-- GUID로 아이템 조회
local item = _ItemService:GetItemByGUID(itemGUID)

-- 소유자별 아이템 목록
local items = _ItemService:GetMODItemsByOwner(inventory)

-- 아이템 삭제
_ItemService:RemoveItem(item)
```

## 40.3 소유권 이전

```lua
[server only]
void TradeItem(Item item, Entity targetPlayer)
{
    local targetInventory = targetPlayer.InventoryComponent
    _ItemService:ChangeOwner(item, targetInventory)
}
```

## 40.4 아이템 획득/소모 예제

```lua
[self]
HandleTriggerEnterEvent (TriggerEnterEvent event)
{
    if self:IsClient() then return end
    
    local triggerBody = event.TriggerBodyEntity
    local inventory = self.Entity.InventoryComponent
    local items = inventory:GetItemList()
    
    if triggerBody.Name == "Get Item" then
        local newItem = _ItemService:CreateItem(TestItem, "TestItem", inventory)
        newItem.ItemCount = 3
    elseif triggerBody.Name == "Use Item" then
        if #items > 0 then
            items[1].ItemCount = items[1].ItemCount - 1
            if items[1].ItemCount == 0 then
                _ItemService:RemoveItem(items[1])
            end
        end
    end
}
```

---

# Part 41: HttpService (HTTP 서비스)

HttpService는 외부 서버와 HTTP 통신을 합니다.

## 41.1 GET 요청

```lua
[server only]
void FetchData()
{
    local headers = {["Authorization"] = "Bearer token123"}
    local response = _HttpService:GetAndWait("https://api.example.com/data", headers)
    
    -- JSON 파싱
    local data = _HttpService:JSONDecode(response)
    log(data.name)
}
```

## 41.2 POST 요청

```lua
[server only]
void SendData()
{
    local content = {
        ["userId"] = "player123",
        ["score"] = 9999
    }
    local jsonContent = _HttpService:JSONEncode(content)
    
    local response = _HttpService:PostAndWait(
        "https://api.example.com/submit",
        jsonContent,
        HttpContentType.ApplicationJson
    )
    
    log(response)
}
```

## 41.3 JSON 변환

```lua
-- 테이블 → JSON 문자열
local jsonStr = _HttpService:JSONEncode({name = "Player1", level = 10})

-- JSON 문자열 → 테이블
local tbl = _HttpService:JSONDecode('{"name": "Player1", "level": 10}')

-- URL 인코딩
local encoded = _HttpService:UrlEncode("한글 문자열")
```

## 41.4 유의사항

- 분당 최대 120회 요청 제한 (초과 시 30초 차단)
- 요청당 Timeout: 30초
- 응답 버퍼: 10MB 제한
- TLS 1.2 이상만 지원
- 80, 443 외 1024 미만 포트 제한

---

# Part 42: ParticleService (파티클 서비스)

ParticleService는 파티클(입자) 효과를 재생합니다.

## 42.1 BasicParticle (기본 파티클)

```lua
-- 고정 위치에 재생
local serial = _ParticleService:PlayBasicParticle(
    BasicParticleType.Explosion,    -- 파티클 타입
    self.Entity,                    -- instigator
    Vector3(100, 50, 0),           -- 위치
    0,                              -- Z축 회전
    Vector3(1, 1, 1),              -- 스케일
    false                           -- 루프 여부
)

-- 엔티티에 부착
local serial = _ParticleService:PlayBasicParticleAttached(
    BasicParticleType.Fire,
    self.Entity,                    -- 부모 엔티티
    Vector3(0, 1, 0),              -- 로컬 위치
    0,                              -- 로컬 회전
    Vector3(1, 1, 1),              -- 로컬 스케일
    true                            -- 루프
)
```

## 42.2 SpriteParticle (스프라이트 파티클)

```lua
-- 커스텀 스프라이트 사용
local serial = _ParticleService:PlaySpriteParticle(
    SpriteParticleType.BurstNova,
    "spriteRUID",                   -- 스프라이트 리소스 ID
    self.Entity,
    Vector3(0, 0, 0),
    0,
    Vector3(2, 2, 2),
    false,
    {["Color"] = Color(1, 0, 0, 1)} -- 옵션
)
```

## 42.3 AreaParticle (영역 파티클)

```lua
-- 범위 지정 파티클
local serial = _ParticleService:PlayAreaParticle(
    AreaParticleType.Rain,
    Vector2(10, 5),                 -- 영역 크기
    self.Entity,
    Vector3(0, 10, 0),
    0,
    Vector3(1, 1, 1),
    true                            -- 루프
)
```

## 42.4 파티클 제거

```lua
-- 루프 파티클 제거
_ParticleService:RemoveParticle(serial)
```

## 42.5 더블 점프 이펙트 예제

```lua
[service: InputService]
HandleKeyDownEvent (KeyDownEvent event)
{
    if event.key == KeyboardKey.Space then
        if not self.Entity.RigidbodyComponent:IsOnGround() then
            -- 더블 점프 힘 적용
            local lookDir = self.Entity.PlayerControllerComponent.LookDirectionX
            self.Entity.RigidbodyComponent:SetForce(Vector2(lookDir * 5, 3))
            
            -- 이펙트 재생
            local options = {
                ["SortingLayer"] = self.Entity.AvatarRendererComponent.SortingLayer,
                ["Color"] = Color(0.25, 0.5, 0.5, 0.8)
            }
            local pos = self.Entity.TransformComponent.Position
            
            _ParticleService:PlayBasicParticle(
                BasicParticleType.PillarBurst, 
                self.Entity, 
                pos, 
                90 * lookDir, 
                Vector3.one, 
                false, 
                options
            )
        end
    end
}
```

---

# Part 43: LocalizationService (다국어 서비스)

LocalizationService는 텍스트 번역 및 다국어 지원을 제공합니다.

## 43.1 현재 언어 확인

```lua
[client only]
void CheckLocale()
{
    -- 현재 언어 코드 (ko, en, ja 등)
    local locale = _LocalizationService.CurrentLocaleId
    log("현재 언어:", locale)
    
    -- 현재 언어 Translator
    local translator = _LocalizationService.LocalTranslator
}
```

## 43.2 번역 텍스트 조회

```lua
[client only]
void GetLocalizedText()
{
    -- 단순 텍스트 조회
    local text = _LocalizationService:GetText("TEXT_WELCOME")
    
    -- 포맷 적용 (파라미터 대입)
    local formatted = _LocalizationService:GetTextFormat("TEXT_GREETING", "플레이어")
    -- 예: "안녕, {0}!" → "안녕, 플레이어!"
}
```

## 43.3 Translator 활용

```lua
[client only]
void UseTranslator()
{
    -- 특정 언어 Translator 얻기
    local enTranslator = _LocalizationService:GetTranslatorForLocale("en")
    local koTranslator = _LocalizationService.LocalTranslator
    
    -- 영어: "Hello, world!"
    local enText = enTranslator:GetTextFormat("TEXT_GREETING", "world")
    
    -- 한국어: "안녕, 세상!"
    local koText = koTranslator:GetTextFormat("TEXT_GREETING", "세상")
}
```

## 43.4 SmartFormat (고급 포맷)

```lua
-- 한국어 조사 처리 (hpp)
local text1 = _LocalizationService:SmartFormat("안녕, {0}{0:hpp:아|야}!", "세상")
-- 결과: "안녕, 세상아!"

local text2 = _LocalizationService:SmartFormat("안녕, {0}{0:hpp:아|야}!", "세계")
-- 결과: "안녕, 세계야!"

-- 영어 복수형 처리 (p)
local text3 = enTranslator:GetTextFormat("TEXT_APPLE", 1)
-- "I have an apple."

local text4 = enTranslator:GetTextFormat("TEXT_APPLE", 5)
-- "I have 5 apples."
```

---

# Part 44: LogService (로그 서비스)

LogService는 로그 출력을 관리합니다.

## 44.1 서버 로그 표시 설정

```lua
[server only]
void ConfigureLog()
{
    -- 서버 로그를 클라이언트에 표시
    _LogService:SetShouldShowServerLog(true)
    
    -- 서버 로그 숨기기
    _LogService:SetShouldShowServerLog(false)
}
```

## 44.2 로그 함수들

```lua
-- 일반 로그
log("일반 메시지")

-- 경고 로그 (노란색)
log_warning("경고 메시지")

-- 에러 로그 (빨간색)
log_error("에러 메시지")
```

---

# Part 45: MaterialService (머티리얼 서비스)

MaterialService는 셰이더/머티리얼 속성을 실시간 제어합니다.

## 45.1 머티리얼 속성 변경

```lua
[client only]
void ChangeMaterial ()
{
    local materialId = _EntryService:GetMaterialIdByName("TestMaterial")
    
    local options = {
        ["CenterPos"] = Vector2(0.5, 0.5),
        ["Intensity"] = 1.5,
        ["Color"] = Color(1, 0, 0, 1)
    }
    
    _MaterialService:ChangeMaterialProperty(materialId, options)
}
```

## 45.2 플레이어 따라다니는 조명

```lua
[client only]
void OnUpdate (number delta)
{
    local playerPos = _UserService.LocalPlayer.TransformComponent.WorldPosition
    
    -- 월드 좌표 → 화면 좌표 변환
    local screenPos = _UILogic:WorldToScreenPosition(Vector2(playerPos.x, playerPos.y))
    screenPos.x = screenPos.x / _UILogic.ScreenWidth
    screenPos.y = screenPos.y / _UILogic.ScreenHeight
    
    local options = {["CenterPos"] = screenPos}
    
    _MaterialService:ChangeMaterialProperty(self.materialId, options)
}
```

---

# Part 46: ResourceService (리소스 서비스)

ResourceService는 리소스 로드, 캐시, 해제를 관리합니다.

## 46.1 리소스 프리로드

```lua
[client only]
void PreloadResources()
{
    local ruids = {
        "6d1a308b27164b02921d812b05c78cba",
        "0516d7594a394561893e04de713cfb6a"
    }
    
    -- 로딩 화면 표시
    self:ShowLoadingScreen()
    
    -- 비동기 로드
    _ResourceService:PreloadAsync(ruids, function(results)
        self:HideLoadingScreen()
        log("리소스 로드 완료")
    end)
}
```

## 46.2 스프라이트 직접 로드

```lua
-- 스프라이트 로드 (동기)
local sprite = _ResourceService:LoadSpriteAndWait("spriteRUID")

-- 애니메이션 클립 로드
local clip = _ResourceService:LoadAnimationClipAndWait("clipRUID")

-- 리소스 타입 확인
local resourceType = _ResourceService:GetTypeAndWait("someRUID")
```

## 46.3 캐시 관리

```lua
-- 특정 리소스 캐시 해제
local ruids = {"ruid1", "ruid2"}
_ResourceService:RemoveCaches(ruids)

-- 모든 캐시 비우기
_ResourceService:ClearCaches()

-- 미사용 리소스 메모리 해제 (5초 이상 미사용)
_ResourceService:UnloadUnusedResources(5)
```

## 46.4 스크린샷 업로드

```lua
-- 서버: 업로드 허용 콜백 등록
[server only]
void OnBeginPlay()
{
    _ResourceService:SetSpriteUploadValidationCallback(function(userId)
        return self:IsAuthorizedUser(userId)
    end)
}

-- 클라이언트: 스크린샷 업로드
[client only]
void UploadScreenshot()
{
    local err, pixelData = _ScreenshotService:CaptureFullScreenAsPixelDataAndWait()
    
    _ResourceService:RequestSpriteUploadAsync(pixelData, function(error, ruid)
        if error == ResourceUploadError.Success then
            self.Entity.SpriteRendererComponent.SpriteRUID = ruid
        end
    end)
}
```

---

# Part 47: BadgeService (배지 서비스)

BadgeService는 유저 배지 지급 및 조회 기능을 제공합니다.

## 47.1 배지 지급

```lua
[server only]
void AwardBadge(string badgeId)
{
    local userId = _UserService.LocalPlayer.UserId
    
    -- 배지 지급 (동기)
    local success = _BadgeService:AwardBadgeAndWait(userId, badgeId)
    
    if success then
        log("배지 지급 성공!")
    end
}
```

## 47.2 배지 보유 확인

```lua
-- 동기 방식
local hasBadge = _BadgeService:UserHasBadgeAndWait(userId, badgeId)

-- 비동기 방식
_BadgeService:UserHasBadgeAsync(userId, badgeId, function(uid, bid, hasBadge)
    if hasBadge then
        log(uid .. " 유저가 " .. bid .. " 배지를 보유 중")
    end
end)
```

## 47.3 배지 정보 조회

```lua
-- 단일 배지 정보
local badgeInfo = _BadgeService:GetBadgeInfoAndWait(badgeId)
log("배지 이름:", badgeInfo.Name)
log("배지 등급:", badgeInfo.Grade)

-- 조건별 배지 검색
local pages = _BadgeService:GetBadgeInfosAndWait(
    {BadgeGrade.Normal, BadgeGrade.Rare},  -- 등급 필터
    BadgeStatus.Ing                        -- 상태 필터
)

while true do
    local pageDatas = pages:GetCurrentPageDatas()
    for _, badge in ipairs(pageDatas) do
        log("Badge:", badge.Name, badge.Grade)
    end
    if pages.IsLastPage then break end
    pages:MoveToNextPageAndWait()
end
```

---

# Part 48: ScreenTransitionService (화면 전환 서비스)

ScreenTransitionService는 부드러운 화면 전환 효과를 제공합니다.

## 48.1 Fade In/Out 설정

```lua
[client only]
void ConfigureFade()
{
    -- Fade 활성화/비활성화
    _ScreenTransitionService:SetFadeInOutEnable(true)
    
    -- Fade In 시간 설정 (0~3초)
    _ScreenTransitionService:SetFadeInTime(1.5)
    
    -- Fade Out 시간 설정 (0~3초)
    _ScreenTransitionService:SetFadeOutTime(0.5)
}
```

## 48.2 Dissolve 효과

```lua
[client only]
void PlayDissolve()
{
    -- Dissolve 효과 실행
    _ScreenTransitionService:DissolveScreen(
        2.0,    -- 지속 시간 (0~3초)
        true,   -- UI 포함 여부
        true    -- Fade In/Out보다 우선 여부
    )
}
```

## 48.3 화면 전환 이벤트

```lua
-- Fade Out 시작 이벤트
[service: ScreenTransitionService]
HandleFadeOutStartEvent (FadeOutStartEvent event)
{
    log("Fade Out 시작")
}

-- Fade In 완료 이벤트
[service: ScreenTransitionService]
HandleFadeInEndEvent (FadeInEndEvent event)
{
    log("Fade In 완료")
}
```

---

# Part 49: ScreenshotService (스크린샷 서비스)

ScreenshotService는 화면 캡처 기능을 제공합니다.

## 49.1 전체 화면 캡처

```lua
[client only]
void CaptureScreen()
{
    -- 파일로 저장 (동기)
    local error, path = _ScreenshotService:CaptureFullScreenAsFileAndWait("Screenshot", true)
    
    if error == ScreenshotError.Success then
        log("저장 완료:", path)
    end
    
    -- 갤러리에 저장
    local error, path = _ScreenshotService:CaptureFullScreenToPhotoLibraryAndWait("Photo", true)
}
```

## 49.2 픽셀 데이터로 캡처

```lua
[client only]
void CaptureAsPixelData()
{
    -- 전체 화면 픽셀 데이터 (ResourceService 업로드용)
    local error, rawImage = _ScreenshotService:CaptureFullScreenAsPixelDataAndWait(true)
    
    if error == ScreenshotError.Success then
        -- 스프라이트로 업로드
        _ResourceService:RequestSpriteUploadAsync(rawImage, function(err, ruid)
            self.Entity.SpriteRendererComponent.SpriteRUID = ruid
        end)
    end
}
```

## 49.3 영역 캡처

```lua
[client only]
void CaptureRegion()
{
    local startPixel = Vector2(100, 100)
    local endPixel = Vector2(500, 500)
    
    -- 특정 영역 캡처
    local error, path = _ScreenshotService:CaptureScreenRegionAsFileAndWait(
        "RegionShot",
        startPixel,
        endPixel,
        true  -- UI 포함
    )
}
```

---

# Part 50: EntryService (엔트리 서비스)

EntryService는 엔트리(Model, DataSet, Material) ID 조회를 제공합니다.

## 50.1 ID 조회 함수들

```lua
-- Model ID 조회
local modelId = _EntryService:GetModelIdByName("PlayerModel")

-- DataSet ID 조회  
local dataSetId = _EntryService:GetDataSetIdByName("ItemTable")

-- Material ID 조회
local materialId = _EntryService:GetMaterialIdByName("GlowMaterial")
```

## 50.2 SpawnService와 연동

```lua
void SpawnModelByName()
{
    local modelId = _EntryService:GetModelIdByName("EnemyModel")
    
    if modelId ~= nil then
        _SpawnService:SpawnByModelId(
            modelId,
            "NewEnemy",
            Vector3(100, 50, 0),
            self.Entity
        )
    end
}
```

## 50.3 MaterialService와 연동

```lua
[client only]
void ApplyMaterial()
{
    local materialId = _EntryService:GetMaterialIdByName("VignetteMaterial")
    
    _MaterialService:ChangeMaterialProperty(materialId, {
        ["Intensity"] = 0.8,
        ["Color"] = Color(0, 0, 0, 1)
    })
}
```

---

# Part 51: DamageSkinService (대미지 스킨 서비스)

대미지 스킨 관련 기능을 제공합니다.

## 51.1 대미지 스킨 재생

```lua
-- 기본 대미지 스킨 재생
_DamageSkinService:Play(
    targetEntity,           -- 대상 엔티티
    "000000",               -- 스킨 ID
    0.05,                   -- 공격 딜레이
    {1, 2, 3},              -- 대미지 배열
    DamageSkinTweenType.Default,
    false,                  -- 크리티컬 여부
    Vector2(0, 0),          -- 오프셋
    Vector2(1, 1),          -- 스케일
    1,                      -- 재생 속도
    1,                      -- 알파값
    LitMode.Default         -- 라이트 모드
)

-- 텍스트 대미지 스킨 재생
_DamageSkinService:PlayTextDamage(
    targetEntity,
    "000000",
    DamageSkinTextType.Miss,
    DamageSkinTweenType.Default
)
```

## 51.2 대미지 스킨 프리로드

```lua
[client only]
void PreloadDamageSkin()
{
    _DamageSkinService:PreloadAsync("000000", function(success)
        if success then
            log("대미지 스킨 프리로드 완료")
        end
    end)
}
```

---

# Part 52: WorldShopService (월드 상점 서비스)

유료 재화를 통한 월드 내 상품 구매 관련 기능을 제공합니다.

## 52.1 상품 구매 처리 콜백 등록

```lua
[server only]
void OnBeginPlay()
{
    _WorldShopService:SetProcessPurchaseCallback(self.ProcessPurchase)
}

[server only]
boolean ProcessPurchase(any purchaseInfo)
{
    local userEntity = _UserService:GetUserEntityByUserId(purchaseInfo.UserId)
    
    if not _EntityService:IsValid(userEntity) then
        return false
    end
    
    -- 상품 지급 처리
    if purchaseInfo.ProductId == "coin1000" then
        userEntity.WalletComponent:AddCoin(1000)
    end
    
    _LogStorageService:LogPurchaseInfo(purchaseInfo, "Success")
    return true
}
```

## 52.2 상품 정보 조회

```lua
-- 단일 상품 정보 조회
local product = _WorldShopService:GetProductAndWait("productId")

-- 상품 목록 검색
local pages = _WorldShopService:GetProductsAndWait(
    WorldShopProductType.Item,
    WorldShopProductStatus.Ing
)

while true do
    local pageDatas = pages:GetCurrentPageDatas()
    
    for _, product in ipairs(pageDatas) do
        log("상품: " .. product.Name .. ", 가격: " .. tostring(product.Price))
    end
    
    if pages.IsLastPage then break end
    pages:MoveToNextPageAndWait()
end
```

## 52.3 구매 창 표시

```lua
[client only]
void PromptPurchaseItem(string productId)
{
    _WorldShopService:PromptPurchase(productId)
}

-- 이용권 보유 확인
local hasPass = _WorldShopService:UserHasPassAndWait(userId, productId)
```

---

# Part 53: 모바일 센서 서비스

## 53.1 MobileAccelerometerService (가속도 센서)

```lua
Property:
[None]
number ForcePower = 100

Method:
[client only]
void OnBeginPlay()
{
    if _MobileAccelerometerService:IsHWSupported() then
        _MobileAccelerometerService:Start()
        _UIToast:ShowMessage("가속도 센서 시작")
    end
}

void OnUpdate(number delta)
{
    if _MobileAccelerometerService:IsEnabled() then
        local accDir = _MobileAccelerometerService:GetLastAcceleration()
        local dir = Vector2(accDir.x, accDir.y)
        self:ApplyForce(dir)
    end
}

-- 센서 측정 중지
_MobileAccelerometerService:Stop()
```

## 53.2 MobileGyroscopeService (자이로스코프/중력 센서)

```lua
[client only]
void OnBeginPlay()
{
    if _MobileGyroscopeService:IsHWSupported() then
        local enabled = _MobileGyroscopeService:StartAndWait()
        if enabled then
            _UIToast:ShowMessage("자이로스코프 시작")
        end
    end
}

void OnUpdate(number delta)
{
    if _MobileGyroscopeService:IsEnabled() then
        -- 오일러 회전각
        local euler = _MobileGyroscopeService:GetAttitudeEuler()
        
        -- 중력 가속도
        local gravity = _MobileGyroscopeService:GetGravity()
        
        -- 초당 회전 변화량
        local rotRate = _MobileGyroscopeService:GetRotationRate()
        
        -- 사용자 선형 가속도
        local userAccel = _MobileGyroscopeService:GetUserAcceleration()
    end
}

-- 센서 측정 종료 (데이터 초기화 옵션)
_MobileGyroscopeService:StopAndWait(true)

-- 측정 주기 설정 (초 단위, 기본 0.2초)
_MobileGyroscopeService:SetUpdateInterval(0.1)
```

## 53.3 MobileVibratorService (진동)

```lua
[client only]
void VibrateDevice()
{
    if _MobileVibratorService:IsHWSupported() then
        _MobileVibratorService:Vibrate()
    end
}
```

## 53.4 MobileShareService (공유)

```lua
[client only]
void ShareFile(string filePath)
{
    local success = _MobileShareService:ShareFileAndWait(filePath)
    
    if success then
        _UIToast:ShowMessage("공유 성공!")
    else
        _UIToast:ShowMessage("공유 실패")
    end
}
```

---

# Part 54: ScreenRecordService (화면 녹화 서비스)

화면 녹화 기능을 제공합니다. 최대 녹화 시간은 2분입니다.

## 54.1 녹화 시작

```lua
[client only]
void StartRecording()
{
    -- 파일로 녹화 (모바일 공유용)
    local result = _ScreenRecordService:StartRecordToFileAndWait(
        ScreenRecordMode.ScreenAndGameAudio,
        false,  -- 시스템 UI 제외 여부
        function(filePath)
            log("녹화 완료: " .. filePath)
        end
    )
    
    -- 갤러리/사진앱으로 저장
    local result2 = _ScreenRecordService:StartRecordToPhotoLibraryAndWait(
        ScreenRecordMode.ScreenOnly,
        false
    )
}
```

## 54.2 녹화 제어

```lua
-- 녹화 상태 확인
local isRecording = _ScreenRecordService:IsRecording()

-- 남은 녹화 시간
local remainTime = _ScreenRecordService:RemainRecordTime()

-- 녹화 종료
local savedPath = _ScreenRecordService:FinishRecordAndWait()
```

## 54.3 마이크 설정

```lua
-- 사용 가능한 마이크 목록 조회
local mics = _ScreenRecordService:GetMicrophoneDevicesAndWait()

for i, mic in ipairs(mics) do
    log(i .. ": " .. mic.Name)
end

-- 현재 마이크 인덱스 확인
local currentIndex = _ScreenRecordService:GetMicrophoneIndexForRecording()

-- 마이크 설정
_ScreenRecordService:SetMicrophoneIndexForRecording(1)
```

## 54.4 녹화 모드 플랫폼별 지원

| 모드 | Windows/macOS | iOS | Android |
|:---:|:---:|:---:|:---:|
| ScreenOnly | O | O | O |
| ScreenAndGameAudio | O | O | O |
| ScreenAndMic | O | O | X |
| ScreenAndGameAudioAndMic | X | O | O |

---

# Part 55: LogStorageService (로그 저장 서비스)

기록을 저장하고 불러옵니다. 출시된 월드에서만 동작합니다.

## 55.1 구매 기록 저장

```lua
[server only]
void LogPurchase(any purchaseInfo)
{
    _LogStorageService:LogPurchaseInfo(purchaseInfo, "Item purchase completed")
}
```

## 55.2 구매 기록 조회

```lua
[server only]
void GetPurchaseLogs()
{
    local fromDate = DateTime(2024, 1, 1)
    local toDate = DateTime(2024, 12, 31)
    
    _LogStorageService:GetPurchaseLogPagesAsync(fromDate, toDate, function(pages)
        while true do
            local logs = pages:GetCurrentPageDatas()
            
            for _, log in ipairs(logs) do
                log(log)
            end
            
            if pages.IsLastPage then break end
            pages:MoveToNextPageAndWait()
        end
    end)
}
```

---

# Part 56: PolicyService (정책 서비스)

지역별 정책 정보를 확인할 수 있습니다. 출시된 월드에서만 동작합니다.

## 56.1 정책 정보 조회

```lua
[server only]
void CheckPolicy(string userId)
{
    -- 동기 방식
    local policyInfo = _PolicyService:GetPolicyInfoForUserAndWait(userId)
    
    if policyInfo then
        log("정책 정보: " .. tostring(policyInfo))
    end
    
    -- 비동기 방식
    _PolicyService:GetPolicyInfoForUserAsync(userId, function(policyInfo)
        if policyInfo then
            log("정책 정보 로드 완료")
        end
    end)
}
```

---

# Part 57: RateLimitService (호출량 제한 서비스)

스크립트 및 API의 사용량을 제한합니다.

## 57.1 서버 함수 호출 제한 설정

```lua
[server only]
void OnBeginPlay()
{
    -- 서비스 함수 제한
    _RateLimitService:SetServerFunctionRateLimitForService(
        "TeleportService",
        "TeleportToEntityPath",
        3,      -- 최대 토큰
        0.1     -- 초당 재충전 토큰
    )
    
    -- 로직 함수 제한
    _RateLimitService:SetServerFunctionRateLimitForLogic(
        "MyLogic",
        "MyFunction",
        3,
        0.1
    )
    
    -- 컴포넌트 함수 제한 (유저별)
    local userEntity = _UserService:GetUserEntityByUserId(userId)
    _RateLimitService:SetServerFunctionRateLimitForComponent(
        userEntity.Id,
        "PlayerComponent",
        "MoveToEntityByPath",
        3,
        0.1
    )
    
    -- 전체 서버 함수 호출량 제한
    _RateLimitService:SetTotalServerFunctionRateLimit(10, 1)
}
```

## 57.2 제한 초과 이벤트

```lua
Event Handler:
[server only] [service: RateLimitService]
HandleServerFunctionRateLimitEvent(ServerFunctionRateLimitEvent event)
{
    log("함수 호출량 제한 초과: " .. event.FunctionName)
}

HandleTotalServerFunctionRateLimitEvent(TotalServerFunctionRateLimitEvent event)
{
    log("총 서버 함수 호출량 제한 초과")
}
```

---

# Part 58: EditorService (에디터 서비스)

에디터 스크립트 관련 기능을 제공합니다.

## 58.1 맵 관리

```lua
-- 맵 생성
_EditorService:CreateMap(function(mapId)
    log("생성된 맵 ID: " .. mapId)
end)

-- 맵 삭제
_EditorService:DeleteMap(mapId)

-- 맵 불러오기 (저장 옵션)
_EditorService:LoadMap(mapId, true)

-- 맵 저장
_EditorService:SaveMap()

-- 시작 맵 설정
_EditorService:SetStartingMap(mapId)

-- 현재 맵 ID 조회
_EditorService:GetCurrentMap(function(mapId)
    log("현재 맵: " .. mapId)
end)

-- 모든 맵 목록
_EditorService:GetMaps(function(mapIds)
    for _, id in ipairs(mapIds) do
        log(id)
    end
end)
```

## 58.2 엔티티 관리

```lua
-- 엔티티 선택
_EditorService:SelectEntity(entityId)

-- 엔티티 이름 변경
_EditorService:RenameEntity(entity, "NewName")

-- 선택된 엔티티 복제
_EditorService:CloneSelectedEntity()

-- 엔티티 계층 순서 변경
_EditorService:SetSiblingIndex(entity, 0)
```

## 58.3 모델 관리

```lua
-- 선택된 모델 생성
_EditorService:CreateSelectedModel(
    Vector2(100, 200),
    true,  -- 생성 후 선택 여부
    function(entity)
        log("생성된 엔티티: " .. entity.Name)
    end
)

-- 모델 선택
_EditorService:SetSelectedModel(modelId)

-- 모델 프로퍼티 조회
_EditorService:GetModelProperty(modelId, "MyComponent", "MyProperty", function(value)
    log("프로퍼티 값: " .. value)
end)

-- 모델 프로퍼티 설정
_EditorService:SetModelProperty(modelId, "MyComponent", "MyProperty", "newValue")
```

## 58.4 카메라 제어

```lua
-- 카메라 위치 조회
_EditorService:GetCameraPosition(function(pos)
    log("카메라 위치: " .. tostring(pos))
end)

-- 카메라 위치 설정
_EditorService:SetCameraPosition(Vector3(100, 200, 0))

-- 카메라 줌 설정
_EditorService:SetCameraZoom(150)

-- 카메라 스크롤 모드 설정
_EditorService:SetCameraScrollMode(true)
```

## 58.5 DataSet 관리

```lua
-- 행 삽입
_EditorService:DataSetInsertRow("ItemTable")

-- 행 삭제
_EditorService:DataSetRemoveRow("ItemTable", 3)

-- 셀 값 설정
_EditorService:DataSetSetCell("ItemTable", 1, "Name", "Sword")
```

## 58.6 기타 기능

```lua
-- 알림 메시지
_EditorService:Notification("작업 완료!")

-- URL 열기
_EditorService:OpenUrl("공식 문서", "https://example.com")

-- 타일 선택
_EditorService:SetSelectedTile(tileRUID)

-- 작업 레이어 설정
_EditorService:SetWorkingLayer(2)

-- 마이홈 스크린샷 저장
_EditorService:SaveMyHome(function()
    log("마이홈 배경 저장됨")
end)

-- LiteDB 삭제
_EditorService:DeleteLiteDB()

-- 메이커 메뉴 삭제
_EditorService:RemoveMakerMenu("CustomMenu")
```

## 58.7 에디터 이벤트

```lua
Event Handler:
[service: EditorService]
HandleEnterEditorEvent(EnterEditorEvent event) { }
HandleEnterPlayEvent(EnterPlayEvent event) { }
HandleWorldLoadEditorEvent(WorldLoadEditorEvent event) { }
HandleEntityCreateEditorEvent(EntityCreateEditorEvent event) { }
HandleEntityDeleteEditorEvent(EntityDeleteEditorEvent event) { }
HandleEntitySelectEditorEvent(EntitySelectEditorEvent event) { }
HandleEntityDeselectEditorEvent(EntityDeselectEditorEvent event) { }
HandleScreenTouchEditorEvent(ScreenTouchEditorEvent event) { }
HandleScreenTouchHoldEditorEvent(ScreenTouchHoldEditorEvent event) { }
HandleScreenTouchReleaseEditorEvent(ScreenTouchReleaseEditorEvent event) { }
```

---

# Part 59: MaterialService (머티리얼 서비스)

머티리얼 프로퍼티를 제어합니다.

## 59.1 머티리얼 프로퍼티 변경

```lua
[client only]
void OnUpdate(number delta)
{
    -- 플레이어 위치 기반 비네팅 효과
    local materialId = _EntryService:GetMaterialIdByName("VignetteMaterial")
    local playerPos = _UserService.LocalPlayer.TransformComponent.WorldPosition
    
    local screenPos = _UILogic:WorldToScreenPosition(Vector2(playerPos.x, playerPos.y))
    screenPos.x = screenPos.x / _UILogic.ScreenWidth
    screenPos.y = screenPos.y / _UILogic.ScreenHeight
    
    _MaterialService:ChangeMaterialProperty(materialId, {
        ["CenterPos"] = screenPos,
        ["Intensity"] = 0.8,
        ["Color"] = Color(0.1, 0.1, 0.1, 1)
    })
}
```

---

# Part 60: DynamicMapService (동적 맵 서비스)

동적 맵 생성/삭제 기능을 제공합니다.

## 60.1 동적 맵 생성

```lua
-- 동적 맵 생성
_DynamicMapService:CreateDynamicMap("SourceMapName", "NewDynamicMap")

-- 동적 맵 삭제
_DynamicMapService:DestroyDynamicMap("NewDynamicMap")

-- 동적 맵 목록 조회
local mapList = _DynamicMapService:GetDynamicMapNameList()
for _, name in ipairs(mapList) do
    log("동적 맵: " .. name)
end
```

---

# Part 61: OverlayLightService (오버레이 조명 서비스)

오버레이 조명 생성/제어 기능을 제공합니다.

## 61.1 조명 생성

```lua
-- 스팟 조명 생성
local spotInfo = SpotLightInfo()
spotInfo.Position = Vector2(100, 200)
spotInfo.Color = Color(1, 1, 0.8, 1)
spotInfo.Intensity = 1.5
spotInfo.Range = 200

local lightSerial = _OverlayLightService:SpawnSpotTypeOverlayLight(spotInfo)

-- 글로벌 조명 생성
local globalInfo = GlobalLightInfo()
local lightSerial2 = _OverlayLightService:SpawnGlobalTypeOverlayLight(globalInfo)

-- 스프라이트 조명 생성
local spriteInfo = SpriteLightInfo()
local lightSerial3 = _OverlayLightService:SpawnSpriteTypeOverlayLight(spriteInfo)

-- 프리폼 조명 생성
local freeformInfo = FreeformLightInfo()
local lightSerial4 = _OverlayLightService:SpawnFreeformTypeOverlayLight(freeformInfo)
```

## 61.2 조명 제어

```lua
-- 조명 활성화/비활성화
_OverlayLightService:SetOverlayLightEnabled(true)

-- 조명 삭제
_OverlayLightService:DestroyOverlayLight(lightSerial)
```

---

# Part 62: WorldInstanceService (월드 인스턴스 서비스)

월드 인스턴스 간 통신 및 공유 메모리 기능을 제공합니다.

## 62.1 공유 메모리

```lua
-- 공유 메모리 획득
local sharedMemory = _WorldInstanceService:GetSharedMemory("PlayerData")

if sharedMemory then
    -- 데이터 읽기/쓰기
    sharedMemory:Set("key", value)
    local data = sharedMemory:Get("key")
end

-- 공유 메모리 해제
_WorldInstanceService:ReleaseSharedMemory("PlayerData")

-- 공유 메모리 삭제
_WorldInstanceService:DeleteSharedMemory("PlayerData")
```

## 62.2 인스턴스 간 이벤트 전송

```lua
-- 모든 인스턴스에 이벤트 전송 (동기)
_WorldInstanceService:RequestSendEventToAllWorldInstancesAndWait(myEvent)

-- 특정 인스턴스에 이벤트 전송
_WorldInstanceService:RequestSendEventToWorldInstance(targetInstanceId, myEvent)
```

## 62.3 인스턴스 정보 조회

```lua
-- 현재 Division 조회
local division = _WorldInstanceService:GetDivision()
```

---

# Part 63: InstanceMapService (인스턴스 맵 서비스) [Deprecated]

> ⚠️ **Deprecated**: 이 서비스는 더 이상 사용되지 않습니다. RoomService를 대신 사용하세요.

```lua
-- 기존 코드 (사용 중지 권장)
-- _InstanceMapService:CreateInstanceMap("key", {"map1", "map2"})
-- _InstanceMapService:GetOrCreateInstanceMap("key")
-- _InstanceMapService:IsInstance()

-- 대신 RoomService 사용
_RoomService:CreateRoom("roomKey", {"map1", "map2"})
```

---

# Part 64: 전체 Services 목록 요약

| Service | 설명 | 주요 메서드/기능 |
|:--|:--|:--|
| BadgeService | 배지 관리 | AwardBadge, UserHasBadge |
| CameraService | 카메라 제어 | SetTraceTarget, SetZoom |
| CollisionService | 충돌 감지 | RayCast, RayCastAll |
| DamageSkinService | 대미지 스킨 | Play, PlayTextDamage |
| DataService | 데이터 조회 | GetTable, GetColumn |
| DataStorageService | 데이터 저장 | Get, Set, LiteDB |
| DynamicMapService | 동적 맵 | Create, Destroy |
| EditorService | 에디터 기능 | CreateMap, SelectEntity |
| EffectService | 이펙트 재생 | Play, PlayAttached |
| EntityService | 엔티티 관리 | IsValid, GetEntity |
| EntryService | 엔트리 ID 조회 | GetModelIdByName |
| HttpService | HTTP 통신 | Get, Post |
| InputService | 입력 처리 | 키/터치 이벤트 |
| InstanceMapService | ⚠️ Deprecated | → RoomService |
| ItemService | 아이템 관리 | CreateItem, DeleteItem |
| LocalizationService | 다국어 | GetMessage |
| LogService | 로그 출력 | Log, LogWarning |
| LogStorageService | 로그 저장 | LogPurchaseInfo |
| MaterialService | 머티리얼 | ChangeMaterialProperty |
| MobileAccelerometerService | 가속도 센서 | Start, GetLastAcceleration |
| MobileGyroscopeService | 자이로스코프 | StartAndWait, GetRotationRate |
| MobileShareService | 공유 기능 | ShareFileAndWait |
| MobileVibratorService | 진동 | Vibrate |
| OverlayLightService | 오버레이 조명 | SpawnSpotLight |
| ParticleService | 파티클 | Spawn |
| PolicyService | 정책 정보 | GetPolicyInfoForUser |
| RateLimitService | 호출 제한 | SetServerFunctionRateLimit |
| ResourceService | 리소스 | RequestSpriteUpload |
| RoomService | 룸 관리 | CreateRoom, JoinRoom |
| ScreenRecordService | 화면 녹화 | StartRecord, FinishRecord |
| ScreenshotService | 스크린샷 | Capture |
| ScreenTransitionService | 화면 전환 | PlayTransition |
| SoundService | 사운드 | PlaySound |
| SpawnService | 스폰 | SpawnByModelId |
| TeleportService | 텔레포트 | TeleportToMap |
| TimerService | 타이머 | SetTimer |
| UserService | 유저 관리 | GetUser, LocalPlayer |
| WorldInstanceService | 인스턴스 관리 | GetSharedMemory |
| WorldShopService | 월드 상점 | PromptPurchase |

---

# Part 65: DefaultUserEnterLeaveLogic (유저 입/퇴장 로직)

유저의 입장과 퇴장에 관련된 기능을 제공합니다.

## 65.1 Properties

```lua
-- 플레이어 모델 ID (Copy Model ID로 복사)
string PlayerUri

-- 시작 맵 이름 (Copy Entry Path로 복사)
string StartPoint
```

## 65.2 기본 메서드 (Logic 상속)

```lua
-- 실행 환경 확인
local isClient = self:IsClient()
local isServer = self:IsServer()

-- 이벤트 연결
local handler = self:ConnectEvent("EventName", function(event)
    -- 핸들러 로직
end)

-- 이벤트 연결 해제
self:DisconnectEvent("EventName", handler)

-- 이벤트 발생
self:SendEvent(myEvent)
```

---

# Part 66: Logic (로직 기본 클래스)

모든 로직의 부모 클래스로, 로직의 기본 기능들을 제공합니다.

## 66.1 Methods

```lua
-- 이벤트 연결 (문자열 키)
EventHandlerBase ConnectEvent(string key, IScriptFunction eventHandler)

-- 이벤트 연결 (타입)
EventHandlerBase ConnectEvent(Type eventType, IScriptFunction eventHandler)

-- 이벤트 연결 해제
boolean DisconnectEvent(string key, EventHandlerBase eventHandler)
boolean DisconnectEvent(Type eventType, EventHandlerBase eventHandler)

-- 실행 환경 확인
boolean IsClient()  -- 클라이언트 여부
boolean IsServer()  -- 서버 여부

-- 이벤트 발생
void SendEvent(EventType sendEvent)
```

---

# Part 67: MaplePreferencesLogic (메이플 설정 로직)

메이플스토리의 설정 값이나 변수 값을 프로퍼티로 제공합니다.

## 67.1 사운드 Properties

| 프로퍼티 | 설명 | 동기화 |
|:--|:--|:--:|
| JumpSound | 점프 시 재생되는 소리 | Sync |
| DeathSound | 죽을 때 재생되는 소리 | Sync |

## 67.2 무기별 사운드 Properties

| 프로퍼티 | 무기 타입 | 동기화 |
|:--|:--|:--:|
| WeaponBowSound | 활 | Sync |
| WeaponCrossBowSound | 석궁 | Sync |
| WeaponDualBowSound | 듀얼보우건 | Sync |
| WeaponGunSound | 건 | Sync |
| WeaponCannonSound | 캐논 | Sync |
| WeaponKnuckleSound | 너클 | Sync |
| WeaponMaceSound | 메이스 | Sync |
| WeaponPoleArmSound | 폴암 | Sync |
| WeaponSpearSound | 창 | Sync |
| WeaponCaneSound | 케인 | Sync |
| WeaponSwordBSound | 한손검 (B타입) | Sync |
| WeaponSwordKSound | 카타나 (K타입) | Sync |
| WeaponSwordLSound | 양손검 (L타입) | Sync |
| WeaponSwordSSound | 단검 (S타입) | Sync |
| WeaponSwordZBSound | 대검 (ZB타입) | Sync |
| WeaponSwordZLSound | 태도 (ZL타입) | Sync |
| WeaponTGloveSound | ESP리미터, 매직건틀렛 | Sync |

## 67.3 사용 예제

```lua
[client only]
void OnBeginPlay()
{
    -- 점프/사망 소리 변경
    _MaplePreferencesLogic.JumpSound = "000000"
    _MaplePreferencesLogic.DeathSound = "000000"
    
    -- 모든 무기 효과음 제거
    _MaplePreferencesLogic.WeaponBowSound = ""
    _MaplePreferencesLogic.WeaponCaneSound = ""
    _MaplePreferencesLogic.WeaponCannonSound = ""
    -- ... (모든 무기 타입에 대해 동일하게 적용)
}
```

---

# Part 68: MODTweenLogic [Deprecated]

> ⚠️ **Deprecated**: 이 로직은 더 이상 사용되지 않습니다. **TweenLogic**, **TweenLineComponent**, **TweenFloatingComponent**, **TweenCircularComponent**를 대신 사용하세요.

## 68.1 Deprecated Methods

| 기존 메서드 | 대체 권장 |
|:--|:--|
| Ease() | _TweenLogic:Ease() |
| MoveTo() | _TweenLogic:MoveTo() 또는 TweenLineComponent |
| MoveToOffset() | _TweenLogic:MoveOffset() 또는 TweenLineComponent |
| StartFloating() | TweenFloatingComponent |
| StopFloating() | TweenFloatingComponent |
| StartRot() | _TweenLogic:RotateTo() 또는 TweenCircularComponent |
| StopRot() | _TweenLogic:RotateTo() 또는 TweenCircularComponent |

---

# Part 69: 전체 Logics 목록 요약

| Logic | 설명 | 주요 기능 |
|:--|:--|:--|
| DefaultUserEnterLeaveLogic | 유저 입/퇴장 | PlayerUri, StartPoint |
| Logic | 기본 클래스 | ConnectEvent, SendEvent |
| MaplePreferencesLogic | 메이플 설정 | 각종 사운드 프로퍼티 |
| MODTweenLogic | ⚠️ Deprecated | → TweenLogic 사용 |
| ScreenMessageLogic | 화면 메시지 | ShowMessage |
| TweenLogic | 트윈 애니메이션 | MoveTo, RotateTo, Ease |
| UILogic | UI 제어 | 화면 좌표 변환 |
| UtilLogic | 유틸리티 | 다양한 헬퍼 함수 |

---

# Part 70: Events (이벤트)

## 70.1 주요 이벤트 목록

| 이벤트 | 설명 | 발생 주체 (Service/Component) |
|:--|:--|:--|
| `KeyDownEvent` | 키보드 키 누름 | InputService |
| `KeyUpEvent` | 키보드 키 뗌 | InputService |
| `ScreenTouchEvent` | 화면 터치 | InputService |
| `ButtonClickEvent` | UI 버튼 클릭 | ButtonComponent |
| `TriggerEnterEvent` | 트리거 영역 진입 | TriggerComponent |
| `TriggerLeaveEvent` | 트리거 영역 이탈 | TriggerComponent |
| `FootholdCollisionEvent` | 발판 충돌 | RigidbodyComponent |
| `PortalUseEvent` | 포탈 이용 | PortalComponent |
| `StateChangeEvent` | 상태 변경 | StateComponent |
| `AnimationClipEvent` | 애니메이션 클립 변경 | StateAnimationComponent |
| `LogEvent` | 로그 발생 | LogService |
| `SliderValueChangedEvent` | 슬라이더 값 변경 | SliderComponent |
| `TextInputValueChangeEvent` | 텍스트 입력 값 변경 | TextInputComponent |
| `EntityCreateEvent` | 엔티티 생성 | EntityService (추정) |
| `EntityDestroyEvent` | 엔티티 파괴 | EntityService (추정) |

---

# Part 71: Enums (열거형)

## 71.1 주요 열거형 목록

| Enum | 설명 | 주요 값 |
|:--|:--|:--|
| `KeyboardKey` | 키보드 키 코드 | UpArrow, DownArrow, A, B, Space ... |
| `TextAnchor` | 텍스트 정렬 | UpperLeft, MiddleCenter, LowerRight ... |
| `CollisionGroup` | 충돌 그룹 | Default, Map, Trigger ... |
| `TransitionType` | UI 전환 효과 | ColorTint, SpriteSwap, Animation |
| `SliderDirection` | 슬라이더 방향 | LeftToRight, RightToLeft, BottomToTop, TopToBottom |
| `UpdateAuthorityType` | 업데이트 권한 | Client, Server |
| `ColliderType` | 충돌체 형태 | Box, Circle, Polygon |

---

# Part 72: Misc (기타/자료형)

## 72.1 주요 자료형

| 타입 | 설명 |
|:--|:--|
| `Vector2` | 2차원 벡터 (x, y) |
| `Vector3` | 3차원 벡터 (x, y, z) |
| `Color` | 색상 (r, g, b, a) |
| `EntityRef` | 엔티티 참조 |
| `ComponentRef` | 컴포넌트 참조 |
| `RUID` | 리소스 고유 식별자 (string) |
| `SyncDictionary` | 동기화 딕셔너리 |
| `SyncList` | 동기화 리스트 |

---


# Part 73: Lua (루아 표준 라이브러리)

메이플스토리 월드는 Lua 5.3을 기반으로 하며, 다음과 같은 표준 라이브러리를 지원합니다.

## 73.1 주요 라이브러리

| 라이브러리 | 설명 | 주요 함수 |
|:--|:--|:--|
| `math` | 수학 함수 | abs, ceil, floor, max, min, random, sin, cos ... |
| `string` | 문자열 조작 | byte, char, find, format, gsub, len, lower, sub ... |
| `table` | 테이블 조작 | concat, insert, remove, sort, unpack ... |
| `os` | 운영체제 (일부 제한) | time, date, difftime |
| `coroutine` | 코루틴 | create, resume, yield, status |

> **참고**: 일부 OS 및 I/O 관련 함수는 보안상의 이유로 사용이 제한될 수 있습니다.

---

# Part 74: 참고 링크

- [API Reference 가이드라인](https://maplestoryworlds-creators.nexon.com/ko/apiReference/How-to-use-API-Reference)

- [Components](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Components)
- [Events](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Events)
- [Services](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Services)
- [Logics](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Logics)
- [Misc](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Misc)
- [Enums](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Enums)
- [LogMessages](https://maplestoryworlds-creators.nexon.com/ko/apiReference/LogMessages)
  - [Error Level](https://maplestoryworlds-creators.nexon.com/ko/apiReference/LogMessages/ErrorLevel)
  - [Info Level](https://maplestoryworlds-creators.nexon.com/ko/apiReference/LogMessages/InfoLevel)
  - [Warning Level](https://maplestoryworlds-creators.nexon.com/ko/apiReference/LogMessages/WarningLevel)

