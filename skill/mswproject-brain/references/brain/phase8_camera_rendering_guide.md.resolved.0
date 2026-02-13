# Phase 8: Camera & Rendering Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 2개  
> **카테고리**: Camera & Rendering (카메라, 광원)

---

## 📊 Phase 8 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **CameraComponent** | 16 | 4 | 0 | 카메라 제어 (추적, 줌, 흔들기) |
| **LightComponent** | 18 | 0 | 0 | 광원 출력 (Spot, Freeform, Global, Sprite) |
| **총계** | **34** | **4** | **0** | - |

---

## 📷 Camera & Rendering System 개요

MapleStory Worlds의 카메라 및 렌더링 시스템은 **시각적 연출**을 담당합니다:

### 핵심 메커니즘
1. **CameraComponent**: 엔티티 추적, 줌, 카메라 흔들기, 영역 제한
2. **LightComponent**: 광원 출력 (Spot, Freeform, Global, Sprite)

### 카메라 추적 시스템

```
DeadZone (중앙 영역)
    ↓ 타겟이 DeadZone 내에 있으면 카메라 정지
SoftZone (외곽 영역)
    ↓ 타겟이 SoftZone에 들어오면 카메라 이동 시작
    ↓ Damping으로 부드럽게 이동
    ↓ 타겟을 DeadZone으로 되돌림
```

---

## 1. CameraComponent

### 📝 개요
- **용도**: 엔티티를 바라보는 카메라 기능 제공
- **필수도**: ⭐⭐⭐⭐⭐ (게임 필수)
- **핵심 기능**: 타겟 추적, 줌, 카메라 흔들기, 영역 제한, 회전

### Properties (16개)

#### 카메라 위치 & 추적
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `CameraOffset` | Vector2 | - | 카메라 위치 (월드 좌표 기준) |
| `ScreenOffset` | Vector2 | - | 대상 기준 스크린 비율 (0~1, 0.5=중앙) |
| `DeadZone` | Vector2 | - | 카메라가 타겟 유지하는 프레임 영역 |
| `SoftZone` | Vector2 | - | 타겟이 들어오면 카메라가 DeadZone으로 되돌리는 영역 |
| `Damping` | Vector2 | - | SoftZone에서 카메라 반응 속도 (작을수록 빠름) |

#### 카메라 제한 영역
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `UseCustomBound` | boolean | ✅ | true: 커스텀 영역 사용 (LeftBottom/RightTop) |
| `LeftBottom` | Vector2 | ✅ | 카메라 제한 영역 좌하단 |
| `RightTop` | Vector2 | ✅ | 카메라 제한 영역 우상단 |
| `ConfineCameraArea` | boolean | - | true: 카메라를 맵 발판 영역으로만 제한 |

#### 줌
| Property | Type | 설명 |
|----------|------|------|
| `IsAllowZoomInOut` | boolean | 줌 기능 사용 여부 |
| `ZoomRatio` | float | 줌 비율 (%, ZoomRatioMin~ZoomRatioMax) |
| `ZoomRatioMin` | float | 줌 비율 최솟값 (%, ≥30) |
| `ZoomRatioMax` | float | 줌 비율 최댓값 (%, ≤500) |

#### 기타
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `DutchAngle` | float | - | 카메라 회전 값 |
| `MaterialId` | string | ✅ | 렌더러에 적용할 머티리얼 ID |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (4개)

| Method | 설명 |
|--------|------|
| `GetBound()` | LeftBottom, RightTop으로 구성된 카메라 제한 영역 반환 |
| `SetZoomTo(float percent, float duration, string targetUserId=nil)` | 주어진 시간(초) 동안 카메라 확대 (Client) |
| `ShakeCamera(float intensity, float duration, string targetUserId=nil)` | 주어진 시간(초) 동안 카메라 진동 (Client) |
| `ChangeMaterial(string materialId)` | 렌더러 머티리얼 교체 |

### Events (0개)

없음

### 사용 패턴

#### 기본 카메라 설정
```lua
[server only]
void OnBeginPlay()
{
    local cam = self.Entity.CameraComponent
    
    -- 추적 영역
    cam.DeadZone = Vector2(2.0, 1.5)
    cam.SoftZone = Vector2(4.0, 3.0)
    cam.Damping = Vector2(0.5, 0.5)
    
    -- 줌
    cam.IsAllowZoomInOut = true
    cam.ZoomRatio = 100  -- 100%
    cam.ZoomRatioMin = 50
    cam.ZoomRatioMax = 200
    
    -- 영역 제한
    cam.ConfineCameraArea = true
}
```

#### 커스텀 카메라 영역
```lua
[server only]
void OnBeginPlay()
{
    local cam = self.Entity.CameraComponent
    
    -- 커스텀 영역 사용
    cam.UseCustomBound = true
    cam.LeftBottom = Vector2(-100, -100)
    cam.RightTop = Vector2(100, 100)
}
```

#### 줌 애니메이션
```lua
-- API 문서 예제: 4초 뒤 300% 줌
[server only]
void OnBeginPlay()
{
    local zoom = function()
        self.Entity.CameraComponent:SetZoomTo(300, 2)
    end
    _TimerService:SetTimerOnce(zoom, 4)
}
```

#### 카메라 흔들기 (폭발 효과)
```lua
[server only]
void OnExplosion()
{
    local cam = self.Entity.CameraComponent
    
    -- 강도 5.0, 지속시간 1초
    cam:ShakeCamera(5.0, 1.0)
}
```

#### 카메라 회전
```lua
[server only]
void RotateCamera(float angle)
{
    local cam = self.Entity.CameraComponent
    cam.DutchAngle = angle  -- 각도 (도)
}
```

#### 스크린 오프셋 (카메라 위치 조정)
```lua
[server only]
void OnBeginPlay()
{
    local cam = self.Entity.CameraComponent
    
    -- 타겟을 화면 왼쪽 1/3 지점에 배치
    cam.ScreenOffset = Vector2(0.33, 0.5)
    cam.ConfineCameraArea = false  -- ScreenOffset 사용 시 필요
}
```

---

## 2. LightComponent

### 📝 개요
- **용도**: 광원 출력 (TransformComponent와 함께 사용 권장)
- **필수도**: ⭐⭐⭐ (조명 효과 필요 시)
- **핵심 기능**: Spot/Freeform/Global/Sprite 광원, 색상, 강도, 감쇠

### Properties (18개)

#### 기본 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Type` | LightType | ✅ | 광원 종류 (Spot, Freeform, Global, Sprite) |
| `Color` | Color | ✅ | 광원 색상 |
| `Intensity` | float | ✅ | 광원 강도 |

#### Spot 타입 (원뿔형 광원)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `InnerRadius` | float | ✅ | 최대 밝기 내부 반경 (≤OuterRadius) |
| `OuterRadius` | float | ✅ | 외부 반경 (빛 강도 0%까지) |
| `SpotInnerAngle` | float | ✅ | 내부 각도 (100% 강도, ≤SpotOuterAngle) |
| `SpotOuterAngle` | float | ✅ | 외부 각도 (0% 강도까지) |

#### Freeform 타입 (자유 형태 광원)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `FreeformPoints` | SyncList\<Vector2\> | ✅ | 광원 모양 정의 점들 (≤2000개) |
| `FalloffDistance` | float | ✅ | FreeformPoints로부터 빛이 뻗어나가는 거리 |

#### Sprite 타입 (스프라이트 광원)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SpriteRUID` | string | ✅ | 스프라이트 RUID |
| `PlayRate` | float | ✅ | 애니메이션 재생 속도 |

#### 감쇠 & 렌더링
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `FalloffIntensity` | float | ✅ | 광원 경계선 부드러움 (클수록 흐릿) |
| `OverlapOperation` | LightOverlapOperation | ✅ | 광원 연산 방식 |
| `LightOrder` | int32 | ✅ | 렌더링 순서 (작을수록 먼저 렌더링) |

#### 타겟 레이어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `TargetAllSortingLayers` | boolean | ✅ | 모든 SortingLayer에 영향 |
| `TargetSortingLayers` | SyncList\<string\> | ✅ | 영향을 줄 SortingLayer 목록 |
| `IgnoreMapLayerCheck` | boolean | ✅ | Map Layer 자동 치환 비활성화 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (0개)

**모든 Methods는 Component에서 상속:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (0개)

없음

### 사용 패턴

#### Spot 광원 (손전등)
```lua
[server only]
void OnBeginPlay()
{
    local light = self.Entity.LightComponent
    
    light.Type = LightType.Spot
    light.Color = Color(1, 1, 0.8, 1)  -- 따뜻한 흰색
    light.Intensity = 1.5
    
    -- Spot 설정
    light.InnerRadius = 2.0
    light.OuterRadius = 5.0
    light.SpotInnerAngle = 30
    light.SpotOuterAngle = 60
    
    -- 부드러운 경계
    light.FalloffIntensity = 2.0
}
```

#### Freeform 광원 (커스텀 모양)
```lua
[server only]
void OnBeginPlay()
{
    local light = self.Entity.LightComponent
    
    light.Type = LightType.Freeform
    light.Color = Color(0, 1, 0, 1)  -- 녹색
    light.Intensity = 1.0
    
    -- 삼각형 모양
    light.FreeformPoints:Clear()
    light.FreeformPoints:Add(Vector2(0, 2))
    light.FreeformPoints:Add(Vector2(-1.5, -1))
    light.FreeformPoints:Add(Vector2(1.5, -1))
    
    light.FalloffDistance = 3.0
    light.FalloffIntensity = 1.5
}
```

#### Global 광원 (전역 조명)
```lua
[server only]
void OnBeginPlay()
{
    local light = self.Entity.LightComponent
    
    light.Type = LightType.Global
    light.Color = Color(1, 1, 1, 1)  -- 흰색
    light.Intensity = 0.5
    
    -- 모든 레이어에 영향
    light.TargetAllSortingLayers = true
}
```

#### Sprite 광원 (애니메이션 광원)
```lua
[server only]
void OnBeginPlay()
{
    local light = self.Entity.LightComponent
    
    light.Type = LightType.Sprite
    light.SpriteRUID = "fire_light_sprite_ruid"
    light.Color = Color(1, 0.5, 0, 1)  -- 주황색
    light.Intensity = 1.2
    light.PlayRate = 1.0  -- 재생 속도
}
```

#### 특정 레이어에만 영향
```lua
[server only]
void OnBeginPlay()
{
    local light = self.Entity.LightComponent
    
    light.Type = LightType.Spot
    light.Color = Color(1, 0, 0, 1)  -- 빨간색
    light.Intensity = 1.0
    
    -- 특정 레이어에만 영향
    light.TargetAllSortingLayers = false
    light.TargetSortingLayers:Clear()
    light.TargetSortingLayers:Add("Player")
    light.TargetSortingLayers:Add("Enemy")
}
```

#### 렌더링 순서 제어
```lua
[server only]
void OnBeginPlay()
{
    local backgroundLight = self.BackgroundLight.LightComponent
    local foregroundLight = self.ForegroundLight.LightComponent
    
    -- 배경 광원 먼저 렌더링
    backgroundLight.LightOrder = 0
    
    -- 전경 광원 나중에 렌더링 (위에 그려짐)
    foregroundLight.LightOrder = 10
}
```

---

## 🎯 Phase 8 핵심 패턴

### 1. 카메라 추적 설정

```lua
-- 빠른 추적 (액션 게임)
cam.DeadZone = Vector2(1.0, 0.5)
cam.SoftZone = Vector2(2.0, 1.5)
cam.Damping = Vector2(0.1, 0.1)  -- 빠른 반응

-- 느린 추적 (탐험 게임)
cam.DeadZone = Vector2(3.0, 2.0)
cam.SoftZone = Vector2(6.0, 4.0)
cam.Damping = Vector2(1.0, 1.0)  -- 느린 반응
```

### 2. 줌 효과

```lua
-- 점진적 줌 인
cam:SetZoomTo(150, 2.0)  -- 2초 동안 150%로

-- 점진적 줌 아웃
cam:SetZoomTo(75, 1.5)  -- 1.5초 동안 75%로

-- 즉시 줌
cam.ZoomRatio = 200  -- 즉시 200%
```

### 3. 카메라 효과

```lua
-- 약한 흔들림 (걷기)
cam:ShakeCamera(1.0, 0.5)

-- 중간 흔들림 (공격)
cam:ShakeCamera(3.0, 0.3)

-- 강한 흔들림 (폭발)
cam:ShakeCamera(10.0, 1.0)
```

### 4. 광원 타입 선택

```lua
-- Spot: 손전등, 스포트라이트
light.Type = LightType.Spot
light.InnerRadius = 2.0
light.OuterRadius = 5.0

-- Freeform: 커스텀 모양 (창문, 문)
light.Type = LightType.Freeform
light.FreeformPoints:Add(Vector2(0, 0))
light.FreeformPoints:Add(Vector2(2, 0))
light.FreeformPoints:Add(Vector2(2, 3))
light.FreeformPoints:Add(Vector2(0, 3))

-- Global: 전역 조명 (낮/밤)
light.Type = LightType.Global
light.Intensity = 0.8

-- Sprite: 애니메이션 광원 (횃불, 불)
light.Type = LightType.Sprite
light.SpriteRUID = "torch_light"
```

### 5. 광원 색상 & 강도

```lua
-- 따뜻한 조명 (실내)
light.Color = Color(1, 0.9, 0.7, 1)
light.Intensity = 1.0

-- 차가운 조명 (밤)
light.Color = Color(0.7, 0.8, 1, 1)
light.Intensity = 0.5

-- 위험 조명 (경고)
light.Color = Color(1, 0, 0, 1)
light.Intensity = 1.5
```

### 6. 카메라 영역 제한

```lua
-- 맵 발판 영역으로 제한
cam.ConfineCameraArea = true

-- 커스텀 영역 제한
cam.UseCustomBound = true
cam.LeftBottom = Vector2(-50, -30)
cam.RightTop = Vector2(50, 30)

-- 제한 없음
cam.ConfineCameraArea = false
cam.UseCustomBound = false
```

### 7. 동적 광원 효과

```lua
-- 깜빡이는 광원
[server only]
void OnUpdate(number delta)
{
    self.time = self.time + delta
    
    local light = self.Entity.LightComponent
    light.Intensity = 1.0 + math.sin(self.time * 5) * 0.3
}

-- 회전하는 광원
[server only]
void OnUpdate(number delta)
{
    self.angle = self.angle + delta * 90  -- 90도/초
    
    local transform = self.Entity.TransformComponent
    transform.Angle = self.angle
}
```

### 8. 특정 플레이어에게만 효과

```lua
-- 특정 플레이어에게만 카메라 흔들기
[server only]
void ShakeForPlayer(string userId)
{
    local cam = self.Entity.CameraComponent
    cam:ShakeCamera(5.0, 1.0, userId)
}

-- 특정 플레이어에게만 줌
[server only]
void ZoomForPlayer(string userId)
{
    local cam = self.Entity.CameraComponent
    cam:SetZoomTo(150, 2.0, userId)
}
```

---

## 🔗 관련 컴포넌트 & 타입

### 관련 서비스
- **CameraService**: 카메라 간 전환
- **TimerService**: 타이머 기반 효과

### 관련 컴포넌트
- **TransformComponent**: 광원 위치/회전 (LightComponent와 함께 사용)

### 관련 타입
- **Vector2**: 2D 벡터 (위치, 영역)
- **Color**: 색상 (광원 색상)
- **LightType**: Spot, Freeform, Global, Sprite
- **LightOverlapOperation**: 광원 연산 방식

---

## 💡 Best Practices

### 1. 카메라 추적 최적화
```lua
-- DeadZone: 타겟이 여기 있으면 카메라 정지
-- SoftZone: 타겟이 여기 들어오면 카메라 이동
-- Damping: 이동 속도 (작을수록 빠름)

-- 권장 비율: SoftZone = DeadZone * 2
cam.DeadZone = Vector2(2.0, 1.5)
cam.SoftZone = Vector2(4.0, 3.0)
```

### 2. 줌 범위 설정
```lua
-- 최소 30%, 최대 500%
cam.ZoomRatioMin = 50  -- 너무 작으면 화면 왜곡
cam.ZoomRatioMax = 200  -- 너무 크면 성능 저하
cam.ZoomRatio = 100  -- 기본 100%
```

### 3. 광원 성능 최적화
```lua
-- Freeform 점 개수 제한
light.FreeformPoints:Count() <= 100  -- 권장

-- 필요한 레이어에만 영향
light.TargetAllSortingLayers = false
light.TargetSortingLayers:Add("Player")

-- 렌더링 순서 최소화
light.LightOrder = 0  -- 필요한 경우에만 변경
```

### 4. 카메라 효과 사용 시기
```lua
-- 흔들기: 폭발, 충격, 지진
cam:ShakeCamera(intensity, duration)

-- 줌: 중요한 순간, 컷신
cam:SetZoomTo(percent, duration)

-- 회전: 특수 효과, 혼란 상태
cam.DutchAngle = angle
```

### 5. 광원 타입 선택 가이드
```lua
-- Spot: 방향성 조명 (손전등, 스포트라이트)
-- Freeform: 복잡한 모양 (창문, 문, 특수 효과)
-- Global: 전역 조명 (낮/밤, 환경 조명)
-- Sprite: 애니메이션 조명 (횃불, 불, 마법)
```

---

## 📋 다음 단계

Phase 8 완료! 다음은:
- **Phase 9**: Network & Data Components (3개) - NetworkComponent 등
- **Phase 10**: Trigger & Interaction Components (3개) - TriggerComponent 등

---

> **학습 완료**: 2026-02-08  
> **참고**: ScreenEffectComponent는 API 문서가 존재하지 않아 제외되었습니다.  
> **다음 목표**: Phase 9 - Network & Data Components 학습
