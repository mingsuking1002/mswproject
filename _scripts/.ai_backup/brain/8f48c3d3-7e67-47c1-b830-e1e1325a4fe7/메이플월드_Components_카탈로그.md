# 메이플스토리 월드 Components 카탈로그

> 이 문서는 메이플스토리 월드의 모든 Component API를 기능별로 분류하여 정리한 카탈로그입니다.

---

## 1. Components 개요

**Component**란 월드 제작 시 엔티티(Entity)에 추가하여 사용하는 **기능 단위**입니다.
- 각 Component는 **프로퍼티(Properties)**와 **함수(Functions)**를 가집니다.
- 엔티티에 여러 Component를 조합하여 복잡한 기능을 구현할 수 있습니다.
- 모든 Component는 기본 `Component` 클래스를 상속합니다.

---

## 2. Component 분류표 (총 105개)

### 2.1 🎮 플레이어/캐릭터 관련 (12개)

| Component | 설명 |
|-----------|------|
| `PlayerComponent` | 플레이어 엔티티 정의 |
| `PlayerControllerComponent` | 플레이어 조작 제어 |
| `MovementComponent` | 이동 기능 |
| `AvatarRendererComponent` | 아바타 렌더링 |
| `AvatarGUIRendererComponent` | 아바타 GUI 렌더링 |
| `AvatarBodyActionSelectorComponent` | 아바타 몸 동작 선택 |
| `AvatarFaceActionSelectorComponent` | 아바타 표정 선택 |
| `AvatarStateAnimationComponent` | 아바타 상태 애니메이션 |
| `CostumeManagerComponent` | 코스튬 관리 |
| `NameTagComponent` | 이름표 표시 |
| `ChatComponent` | 채팅 기능 |
| `ChatBalloonComponent` | 채팅 말풍선 |

---

### 2.2 🤖 AI/인공지능 관련 (3개)

| Component | 설명 |
|-----------|------|
| `AIComponent` | AI 기본 컴포넌트 (추상) |
| `AIChaseComponent` | 추적 AI 행동 |
| `AIWanderComponent` | 배회 AI 행동 |

---

### 2.3 📐 변환/위치 관련 (2개)

| Component | 설명 |
|-----------|------|
| `TransformComponent` | 위치, 크기, 회전 조정 (2D 기준 X, Y 주로 사용, Z는 레이어 순서) |
| `UITransformComponent` | UI 요소의 위치/크기/회전 |

---

### 2.4 🖼️ 렌더링/그래픽 관련 (18개)

| Component | 설명 |
|-----------|------|
| `SpriteRendererComponent` | 스프라이트 렌더링 |
| `SpriteGUIRendererComponent` | GUI용 스프라이트 렌더링 |
| `SkeletonRendererComponent` | 스켈레톤(Spine) 렌더링 |
| `SkeletonGUIRendererComponent` | GUI용 스켈레톤 렌더링 |
| `PixelRendererComponent` | 픽셀 렌더링 |
| `PixelGUIRendererComponent` | GUI용 픽셀 렌더링 |
| `LineRendererComponent` | 라인 렌더링 |
| `LineGUIRendererComponent` | GUI용 라인 렌더링 |
| `PolygonRendererComponent` | 다각형 렌더링 |
| `PolygonGUIRendererComponent` | GUI용 다각형 렌더링 |
| `TextRendererComponent` | 텍스트 렌더링 |
| `TextGUIRendererComponent` | GUI용 텍스트 렌더링 |
| `RawImageRendererComponent` | Raw 이미지 렌더링 |
| `RawImageGUIRendererComponent` | GUI용 Raw 이미지 렌더링 |
| `ImageComponent` | 이미지 표시 |
| `BackgroundComponent` | 배경 렌더링 |
| `CameraComponent` | 카메라 제어 |
| `MaskComponent` | 마스크 효과 |

---

### 2.5 ✨ 파티클/이펙트 관련 (10개)

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

---

### 2.6 ⚔️ 전투/상호작용 관련 (6개)

| Component | 설명 |
|-----------|------|
| `AttackComponent` | 공격 기능 |
| `HitComponent` | 피격 처리 |
| `DamageSkinComponent` | 데미지 스킨 표시 |
| `DamageSkinSettingComponent` | 데미지 스킨 설정 |
| `InteractionComponent` | 상호작용 기능 |
| `TriggerComponent` | 트리거 영역 감지 |

---

### 2.7 🎬 애니메이션/트윈 관련 (7개)

| Component | 설명 |
|-----------|------|
| `StateAnimationComponent` | 상태 기반 애니메이션 |
| `StateComponent` | 상태 관리 |
| `StateStringToAvatarActionComponent` | 상태 문자열 → 아바타 동작 변환 |
| `StateStringToMonsterActionComponent` | 상태 문자열 → 몬스터 동작 변환 |
| `TweenBaseComponent` | 트윈 기본 (추상) |
| `TweenCircularComponent` | 원형 트윈 |
| `TweenFloatingComponent` | 부유 트윈 |
| `TweenLineComponent` | 직선 트윈 |

---

### 2.8 📦 물리/충돌 관련 (13개)

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

---

### 2.9 🗺️ 맵/타일 관련 (6개)

| Component | 설명 |
|-----------|------|
| `MapComponent` | 맵 정의 |
| `MapLayerComponent` | 맵 레이어 |
| `TileMapComponent` | 타일맵 |
| `RectTileMapComponent` | 사각형 타일맵 |
| `ClimbableComponent` | 등반 가능 오브젝트 |
| `ClimbableSpriteRendererComponent` | 등반 가능 스프라이트 렌더링 |
| `CustomFootholdComponent` | 커스텀 발판 |
| `PortalComponent` | 포탈 |
| `SpawnLocationComponent` | 스폰 위치 |

---

### 2.10 🎨 UI 관련 (12개)

| Component | 설명 |
|-----------|------|
| `UIGroupComponent` | UI 그룹 |
| `ButtonComponent` | 버튼 |
| `SliderComponent` | 슬라이더 |
| `TextComponent` | 텍스트 |
| `TextInputComponent` | 텍스트 입력 |
| `TextGUIRendererInputComponent` | GUI 텍스트 입력 렌더러 |
| `GridViewComponent` | 그리드 뷰 |
| `ScrollLayoutGroupComponent` | 스크롤 레이아웃 그룹 |
| `CanvasGroupComponent` | 캔버스 그룹 |
| `JoystickComponent` | 조이스틱 |
| `TouchReceiveComponent` | 터치 수신 |
| `UITouchReceiveComponent` | UI 터치 수신 |

---

### 2.11 🔊 사운드/멀티미디어 관련 (5개)

| Component | 설명 |
|-----------|------|
| `SoundComponent` | 사운드 재생 |
| `YoutubePlayerCommonComponent` | YouTube 플레이어 공통 |
| `YoutubePlayerGUIComponent` | YouTube 플레이어 GUI |
| `YoutubePlayerWorldComponent` | YouTube 플레이어 월드 |
| `WebViewComponent` | 웹뷰 |
| `WebSpriteComponent` | 웹 스프라이트 |

---

### 2.12 📦 기타 유틸리티 (4개)

| Component | 설명 |
|-----------|------|
| `TagComponent` | 태그 부여 |
| `InventoryComponent` | 인벤토리 관리 |
| `WorldComponent` | 월드 컴포넌트 |
| `DirectionSynchronizerComponent` | 방향 동기화 |

---

## 3. 주요 Component 상세

### 3.1 TransformComponent
**용도**: 엔티티의 위치, 크기, 회전 조정

```lua
-- 위치 설정
self.Entity.TransformComponent.Position = Vector2(100, 200)

-- 크기 설정
self.Entity.TransformComponent.Scale = Vector2(2, 2)

-- 회전 (Z축 기준)
self.Entity.TransformComponent.Rotation = 45
```

> **📌 참고**: 2D 게임 특성상 Position과 Scale은 주로 X, Y 값을 사용하며, Z 값은 엔티티의 **레이어 순서**에 영향을 줍니다.

---

### 3.2 MovementComponent
**용도**: 엔티티 이동 제어

```lua
-- 이동 속도 설정
self.Entity.MovementComponent.Speed = 200

-- 점프
self.Entity.MovementComponent:Jump()
```

---

### 3.3 TriggerComponent
**용도**: 특정 영역에 엔티티가 진입/이탈할 때 이벤트 발생

```lua
-- 트리거 진입 이벤트 핸들러
self.Entity.TriggerComponent.OnTriggerEnter:Connect(function(other)
    log("엔티티 진입: " .. other.Name)
end)
```

---

## 4. Component 사용 패턴

### 4.1 Component 가져오기
```lua
local transform = self.Entity.TransformComponent
local sprite = self.Entity.SpriteRendererComponent
```

### 4.2 Component 존재 여부 확인
```lua
if self.Entity.MovementComponent then
    -- MovementComponent가 있을 때만 실행
end
```

### 4.3 다른 엔티티의 Component 접근
```lua
local otherEntity = _EntityService:GetEntityByName("Player")
local otherPos = otherEntity.TransformComponent.Position
```

---

## 5. 참고 링크

- [Components 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Components)
- [API Reference 가이드라인](https://maplestoryworlds-creators.nexon.com/ko/apiReference/How-to-use-API-Reference)

