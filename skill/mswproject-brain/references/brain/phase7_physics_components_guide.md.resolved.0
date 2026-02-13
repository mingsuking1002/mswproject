# Phase 7: Physics Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 3개  
> **카테고리**: Physics (Movement & Collision)

---

## 📊 Phase 7 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **RigidbodyComponent** | 25 | 14 | 9 | 메이플 이동 (중력, 가감속) |
| **KinematicbodyComponent** | 12 | 7 | 5 | 탑다운 이동 (RectTile) |
| **SideviewbodyComponent** | 6 | 4 | 4 | 횡스크롤 이동 (SideViewRectTile) |
| **총계** | **43** | **25** | **18** | - |

---

## 🎮 Physics System 개요

MapleStory Worlds의 물리 시스템은 **3가지 이동 방식**을 제공합니다:

### 핵심 메커니즘
1. **RigidbodyComponent**: 메이플스토리 스타일 이동 (중력, 가감속, 발판)
2. **KinematicbodyComponent**: 탑다운 방식 이동 (상하좌우, RectTile 충돌)
3. **SideviewbodyComponent**: 횡스크롤 방식 이동 (좌우+점프, SideViewRectTile 충돌)

### 이동 방식 비교

| 특징 | Rigidbody | Kinematicbody | Sideviewbody |
|------|-----------|---------------|--------------|
| **중력** | ✅ | ❌ | ✅ |
| **가감속** | ✅ | ❌ | ❌ |
| **점프** | ✅ | ✅ | ✅ |
| **이동 방향** | 좌우 | 상하좌우 | 좌우 |
| **타일맵** | Foothold | RectTile | SideViewRectTile |
| **용도** | 플랫포머 | 탑다운 RPG | 횡스크롤 |

---

## 1. RigidbodyComponent

### 📝 개요
- **용도**: 메이플스토리 움직임 적용 (중력, 가감속, 발판)
- **필수도**: ⭐⭐⭐⭐⭐ (플랫포머 게임 필수)
- **핵심 기능**: 중력, 점프, 발판 충돌, 힘 적용, Attach/Detach

### Properties (25개)

#### 지형 이동 (Walk)
| Property | Type | 설명 |
|----------|------|------|
| `WalkSpeed` | float | 지형 이동 시 최대 속도 |
| `WalkAcceleration` | float | 지형 이동 시 가감속 (클수록 빠르게 최대 속도 도달) |
| `WalkDrag` | float | 미끄러짐 저항 (클수록 빠르게 멈춤, 0.5~2 범위) |
| `WalkSlant` | float | 경사 넘기 능력 (0~1, 클수록 급경사 가능) |
| `WalkJump` | float | 점프 높이 (클수록 높게 뜀) |

#### 공중 이동 (Air)
| Property | Type | 설명 |
|----------|------|------|
| `AirAccelerationX` | float | 공중 X축 가속도 (클수록 공중 이동 빠름) |
| `AirDecelerationX` | float | 공중 X축 감속도 (입력 없을 때 멈추는 속도) |
| `FallSpeedMaxX` | float | 공중 X축 최대 속도 제한 |
| `FallSpeedMaxY` | float | 공중 Y축 최대 속도 제한 |
| `Gravity` | float | 중력값 (클수록 빠르게 떨어짐) |

#### 점프
| Property | Type | 설명 |
|----------|------|------|
| `JumpBias` | float | 점프 시 초기 공중 높이 |
| `DownJumpSpeed` | float | 아래 점프 시 위로 튀는 속도 |

#### Kinematic Move (탑다운 모드)
| Property | Type | 설명 |
|----------|------|------|
| `KinematicMove` | boolean | true: 탑다운 상하좌우 이동 |
| `KinematicMoveAcceleration` | Vector2 | 탑다운 모드 이동 속력 |
| `EnableKinematicMoveJump` | boolean | 탑다운 모드에서 점프 사용 여부 |

#### 물리 설정
| Property | Type | 설명 |
|----------|------|------|
| `Mass` | float | 질량 (클수록 가감속 느림, 외부 요인 반응 낮음, >0) |
| `MoveVelocity` | Vector2 | 이동 입력값 (MovementComponent가 제어) |
| `RealMoveVelocity` | Vector2 | 직전 이동량 (읽기 전용) |

#### 특수 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `ApplyClimbableRotation` | boolean | ✅ | true: 사다리 회전/기울기 따름 |
| `IgnoreMoveBoundary` | boolean | - | true: 맵 영역 벗어남 가능 |
| `IsBlockVerticalLine` | boolean | - | true: 세로 지형 무조건 막힘 (벽) |
| `IsolatedMove` | boolean | - | true: 발판 끝에서 떨어지지 않음 |
| `LayerSettingType` | AutomaticLayerOption | ✅ | Rigidbody와 foothold/사다리/로프의 SortingLayer 관계 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (14개)

#### 힘 제어
| Method | 설명 |
|--------|------|
| `AddForce(Vector2 forcePower)` | 힘 추가 (기존 힘에 더함) |
| `SetForce(Vector2 forcePower)` | 힘 설정 (기존 힘 대체) |
| `SetForceReserve(Vector2 forcePower)` | 현재 프레임 이동 후 힘 대체 |

#### 위치 제어
| Method | 설명 |
|--------|------|
| `SetPosition(Vector2 position)` | 로컬 좌표 기준 위치 설정 |
| `SetWorldPosition(Vector2 position)` | 월드 좌표 기준 위치 설정 |
| `PositionReset()` | 누적 위치 계산 삭제, 현재 위치 기반 재계산 |

#### 점프
| Method | 설명 |
|--------|------|
| `JustJump(Vector2 jumpRate)` | 대상 점프 |
| `DownJump()` | 아래 점프 (지형 위에서만 유효) |

#### Attach/Detach
| Method | 설명 |
|--------|------|
| `AttachTo(string entityId, Vector3 offset)` | 다른 엔티티에 붙임 (물리 동작 중지) |
| `Detach()` | Attach 상태 해제 |

#### 발판 정보
| Method | 설명 |
|--------|------|
| `GetCurrentFoothold()` | 현재 밟고 있는 Foothold 반환 |
| `GetCurrentFootholdPerpendicular()` | 밟고 있는 지형의 수직선 반환 |
| `IsOnGround()` | 지형 위에 서 있는지 확인 |
| `PredictFootholdEnd(float distance, boolean isForward)` | 발판 끝까지 distance만큼 이동 가능한지 확인 |

**Deprecated:**
- `SetUseCustomMove(boolean isUse)` → `Enable` 프로퍼티 사용

### Events (9개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `FootholdCollisionEvent` | 발판 충돌 시 | Server, Client |
| `FootholdEnterEvent` | 발판에 붙었을 때 | Server, Client |
| `FootholdLeaveEvent` | 발판에서 떨어졌을 때 | Server, Client |
| `RigidbodyAttachEvent` | AttachTo로 엔티티에 붙었을 때 | Server/Client |
| `RigidbodyDetachEvent` | Detach로 Attach 해제 시 | Server/Client |
| `RigidbodyClimbableAttachStartEvent` | 사다리/로프 타기 전 | Server, Client |
| `RigidbodyClimbableDetachEndEvent` | 사다리/로프에서 떨어진 후 | Server, Client |
| `RigidbodyKinematicMoveJumpEvent` | KinematicMove=true일 때 점프/착지 | Server, Client |

### 사용 패턴

#### 기본 플랫포머 설정
```lua
[server only]
void OnBeginPlay()
{
    local rb = self.Entity.RigidbodyComponent
    
    -- 지형 이동
    rb.WalkSpeed = 5.0
    rb.WalkAcceleration = 10.0
    rb.WalkDrag = 1.0
    rb.WalkSlant = 0.5
    
    -- 점프
    rb.WalkJump = 10.0
    rb.Gravity = 20.0
    
    -- 공중 이동
    rb.AirAccelerationX = 5.0
    rb.AirDecelerationX = 2.0
    rb.FallSpeedMaxY = 15.0
    
    -- 질량
    rb.Mass = 1.0
}
```

#### 힘 적용 (넉백)
```lua
[server only]
void ApplyKnockback(Vector2 direction, float power)
{
    local rb = self.Entity.RigidbodyComponent
    local force = direction * power
    rb:AddForce(force)
}
```

#### Attach/Detach (이동 플랫폼)
```lua
-- AttachTo 예제 (API 문서에서)
[Sync]
number time = 0
[Sync]
boolean isAttached = false

[client]
void AttachTo(string entityId)
{
    self.Entity.RigidbodyComponent:AttachTo(entityId, Vector3.zero)
    self.isAttached = true
}

[client only]
void OnUpdate(number delta)
{
    if self.isAttached == false then
        return
    end
    
    self.time = self.time + delta
    
    if self.time >= 3.0 then
        self.Entity.RigidbodyComponent:Detach()
        self.time = 0
        self.isAttached = false
    end
}

[self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local TriggerBodyEntity = event.TriggerBodyEntity
    if TriggerBodyEntity.Name == "MovingPlatform" then
        self:AttachTo(TriggerBodyEntity.Id)
    end
}
```

#### 발판 끝 예측
```lua
-- PredictFootholdEnd 예제 (API 문서에서)
[client only]
void OnUpdate(number delta)
{
    local entity = _EntityService:GetEntityByPath(EntityPath)
    
    -- 오른쪽으로 10만큼 이동 가능한지 확인
    if self.Entity.RigidbodyComponent:PredictFootholdEnd(10, true) then
        entity.Enable = true  -- 이동 가능
    else
        entity.Enable = false  -- 발판 끝 가까움
    end
}
```

---

## 2. KinematicbodyComponent

### 📝 개요
- **용도**: 탑다운 방식 상하좌우 이동, 점프, RectTile 충돌
- **필수도**: ⭐⭐⭐⭐ (탑다운 게임 필수)
- **핵심 기능**: 상하좌우 이동, 점프, RectTile 충돌, 그림자

### Properties (12개)

#### 이동 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SpeedFactor` | Vector2 | ✅ | X/Y축 속력 가중치 (클수록 빠름) |
| `MoveVelocity` | Vector2 | - | 이동 속도 (SpeedFactor 곱한 값이 최종 속도) |

#### 점프 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `EnableJump` | boolean | ✅ | 점프 기능 사용 여부 |
| `JumpSpeed` | float | ✅ | 점프 속력 (클수록 높이 점프) |
| `JumpDrag` | float | ✅ | 점프 속력 감소량 (클수록 빨리 떨어짐) |

#### 그림자 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `EnableShadow` | boolean | ✅ | 그림자 사용 여부 |
| `ShadowColor` | Color | ✅ | 그림자 색상 |
| `ShadowOffset` | Vector2 | ✅ | 그림자 위치 |
| `ShadowSize` | Vector2 | ✅ | 그림자 크기 |
| `ShadowScalingRatio` | float | ✅ | 그림자 크기 변화율 (점프 높이에 따라) |

#### 특수 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `EnableTileCollision` | boolean | ✅ | RectTileMap 충돌 기능 사용 여부 |
| `ApplyClimbableRotation` | boolean | ✅ | true: 사다리 회전/기울기 따름 |

**Deprecated:**
- `Acceleration` → `SpeedFactor` 사용

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (7개)

| Method | 설명 |
|--------|------|
| `GetGroundPosition()` | 로컬 좌표 기준 바닥 위치 반환 |
| `GetWorldGroundPosition()` | 월드 좌표 기준 바닥 위치 반환 |
| `IsOnGround()` | 지면에 닿아 있는지 확인 (점프 중 false) |
| `SetPosition(Vector2 position)` | 로컬 좌표 기준 위치 설정 |
| `SetWorldPosition(Vector2 position)` | 월드 좌표 기준 위치 설정 |
| `OnEnterRectTile(RectTileEnterEvent enterEvent)` | RectTileEnterEvent 발생 시 호출 (재정의 가능) |
| `OnLeaveRectTile(RectTileLeaveEvent leaveEvent)` | RectTileLeaveEvent 발생 시 호출 (재정의 가능) |

### Events (5개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `KinematicbodyJumpEvent` | 점프 상태 변경 시 | Server, Client |
| `RectTileCollisionBeginEvent` | 충돌 가능한 타일 접촉 시 | Server, Client |
| `RectTileCollisionEndEvent` | 충돌 타일에서 벗어날 때 | Server, Client |
| `RectTileEnterEvent` | 특정 사각형 타일 진입 시 | Server, Client |
| `RectTileLeaveEvent` | 특정 사각형 타일 벗어날 때 | Server, Client |

### 사용 패턴

#### 기본 탑다운 설정
```lua
[server only]
void OnBeginPlay()
{
    local kb = self.Entity.KinematicbodyComponent
    
    -- 이동 속도
    kb.SpeedFactor = Vector2(5.0, 5.0)
    
    -- 점프 설정
    kb.EnableJump = true
    kb.JumpSpeed = 10.0
    kb.JumpDrag = 5.0
    
    -- 그림자
    kb.EnableShadow = true
    kb.ShadowColor = Color(0, 0, 0, 0.5)
    kb.ShadowSize = Vector2(1.0, 0.5)
    
    -- 타일 충돌
    kb.EnableTileCollision = true
}
```

#### 점프로 타일 뛰어넘기
```lua
-- API 문서 예제
[client only]
void OnUpdate()
{
    if _UserService.LocalPlayer ~= self.Entity then
        return
    end
    
    local kinematicbody = self.Entity.KinematicbodyComponent
    
    local isOnGround = kinematicbody:IsOnGround()
    kinematicbody.EnableTileCollision = isOnGround
    -- 점프 중에는 타일 충돌 비활성화 → 타일 뛰어넘기
}
```

---

## 3. SideviewbodyComponent

### 📝 개요
- **용도**: 횡스크롤 방식 이동 및 점프, SideViewRectTile 충돌
- **필수도**: ⭐⭐⭐⭐ (횡스크롤 게임 필수)
- **핵심 기능**: 좌우 이동, 점프, 아래 점프, SideViewRectTile 충돌

### Properties (6개)

| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `MoveVelocity` | Vector2 | - | 이동 속도 (MovementComponent가 제어) |
| `JumpSpeed` | float | ✅ | 점프 속력 (클수록 높이 점프) |
| `JumpDrag` | float | ✅ | 점프 속력 감소량 (클수록 빨리 떨어짐) |
| `EnableDownJump` | boolean | ✅ | 아래 점프 기능 켜기/끄기 |
| `DownJumpSpeed` | float | ✅ | 아래 점프 시 위로 튀는 속력 |
| `ApplyClimbableRotation` | boolean | ✅ | true: 사다리 회전/기울기 따름 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (4개)

| Method | 설명 |
|--------|------|
| `GetUnderfootTile()` | 현재 밟고 있는 타일 정보 반환 (RectTileInfo, 없으면 nil) |
| `IsOnGround()` | 지면에 닿아 있는지 확인 |
| `SetPosition(Vector2 position)` | 로컬 좌표 기준 위치 설정 |
| `SetWorldPosition(Vector2 position)` | 월드 좌표 기준 위치 설정 |

### Events (4개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `RectTileCollisionBeginEvent` | 충돌 가능한 타일 접촉 시 | Server, Client |
| `RectTileCollisionEndEvent` | 충돌 타일에서 벗어날 때 | Server, Client |
| `RectTileEnterEvent` | 특정 사각형 타일 진입 시 | Server, Client |
| `RectTileLeaveEvent` | 특정 사각형 타일 벗어날 때 | Server, Client |

### 사용 패턴

#### 기본 횡스크롤 설정
```lua
[server only]
void OnBeginPlay()
{
    local sb = self.Entity.SideviewbodyComponent
    
    -- 점프 설정
    sb.JumpSpeed = 10.0
    sb.JumpDrag = 5.0
    
    -- 아래 점프
    sb.EnableDownJump = true
    sb.DownJumpSpeed = 5.0
    
    -- 사다리
    sb.ApplyClimbableRotation = true
}
```

#### 벽 타일 감지
```lua
-- GetWallTile 예제 (API 문서에서)
[None]
table WallTile = {}

[client only]
table GetWallTile()
{
    return self.WallTile
}

[client only] [self]
HandleRectTileCollisionBeginEvent(RectTileCollisionBeginEvent event)
{
    local Normal = event.Normal
    local TileInfo = event.TileInfo
    local TilePosition = event.TilePosition
    local TileMap = event.TileMap
    
    -- 좌우 벽 감지
    if Normal == Vector2.left or Normal == Vector2.right then
        self.WallTile = {
            info = TileInfo,
            position = TilePosition:Clone(),
            normal = Normal:Clone(),
            tilemap = TileMap
        }
    end
}

[client only] [self]
HandleRectTileCollisionEndEvent(RectTileCollisionEndEvent event)
{
    local TilePosition = event.TilePosition
    local currWallTile = self.WallTile
    
    if currWallTile ~= nil and currWallTile.position == TilePosition then
        self.WallTile = nil
    end
}
```

---

## 🎯 Phase 7 핵심 패턴

### 1. 이동 방식 선택

```lua
-- 플랫포머 (메이플스토리 스타일)
self.Entity:AddComponent(ComponentType.RigidbodyComponent)
self.Entity:AddComponent(ComponentType.MovementComponent)

-- 탑다운 RPG
self.Entity:AddComponent(ComponentType.KinematicbodyComponent)
self.Entity:AddComponent(ComponentType.MovementComponent)

-- 횡스크롤
self.Entity:AddComponent(ComponentType.SideviewbodyComponent)
self.Entity:AddComponent(ComponentType.MovementComponent)
```

### 2. 중력 vs 비중력

```lua
-- 중력 O: Rigidbody, Sideviewbody
rb.Gravity = 20.0

-- 중력 X: Kinematicbody
kb.SpeedFactor = Vector2(5.0, 5.0)  -- Y축도 자유롭게 이동
```

### 3. 타일 충돌 처리

```lua
-- RectTile 충돌 (Kinematicbody, Sideviewbody)
[self]
HandleRectTileCollisionBeginEvent(RectTileCollisionBeginEvent event)
{
    local TileInfo = event.TileInfo
    local TilePosition = event.TilePosition
    local Normal = event.Normal
    
    log("Collided with tile at: " .. tostring(TilePosition))
    log("Normal: " .. tostring(Normal))
}

-- Foothold 충돌 (Rigidbody)
[self]
HandleFootholdEnterEvent(FootholdEnterEvent event)
{
    local Foothold = event.Foothold
    log("Entered foothold: " .. Foothold.Name)
}
```

### 4. 점프 구현

```lua
-- Rigidbody 점프
[server only]
void Jump()
{
    local rb = self.Entity.RigidbodyComponent
    if rb:IsOnGround() then
        rb:JustJump(Vector2(0, 1))
    end
}

-- Kinematicbody/Sideviewbody 점프
-- MovementComponent:Jump() 사용
[server only]
void Jump()
{
    local movement = self.Entity.MovementComponent
    movement:Jump()
}
```

### 5. 힘 기반 이동 (Rigidbody만)

```lua
-- 대시
[server only]
void Dash(Vector2 direction)
{
    local rb = self.Entity.RigidbodyComponent
    rb:AddForce(direction * 20.0)
}

-- 넉백
[server only]
void Knockback(Vector2 direction, float power)
{
    local rb = self.Entity.RigidbodyComponent
    rb:SetForce(direction * power)
}
```

### 6. 발판/타일 정보 확인

```lua
-- Rigidbody: 현재 발판
[server only]
void CheckFoothold()
{
    local rb = self.Entity.RigidbodyComponent
    local foothold = rb:GetCurrentFoothold()
    
    if foothold then
        log("On foothold: " .. foothold.Name)
    end
}

-- Sideviewbody: 현재 타일
[server only]
void CheckTile()
{
    local sb = self.Entity.SideviewbodyComponent
    local tileInfo = sb:GetUnderfootTile()
    
    if tileInfo then
        log("On tile: " .. tostring(tileInfo.Position))
    end
}
```

### 7. 탑다운 모드 (Rigidbody)

```lua
-- Rigidbody를 탑다운처럼 사용
[server only]
void OnBeginPlay()
{
    local rb = self.Entity.RigidbodyComponent
    
    rb.KinematicMove = true
    rb.KinematicMoveAcceleration = Vector2(5.0, 5.0)
    rb.EnableKinematicMoveJump = true
}
```

---

## 🔗 관련 컴포넌트 & 타입

### 관련 컴포넌트
- **MovementComponent**: 이동 제어 (Jump, MoveToDirection, Stop)
- **TriggerComponent**: 충돌 감지
- **ColliderComponent**: 충돌체 (404 에러로 문서 없음)

### 관련 타입
- **Vector2**: 2D 벡터 (위치, 속도, 힘)
- **Vector3**: 3D 벡터 (Attach offset)
- **Foothold**: 발판 정보
- **RectTileInfo**: 사각형 타일 정보
- **AutomaticLayerOption**: 레이어 설정 옵션

### 관련 이벤트
- **FootholdCollisionEvent**, **FootholdEnterEvent**, **FootholdLeaveEvent**
- **RectTileCollisionBeginEvent**, **RectTileCollisionEndEvent**
- **RectTileEnterEvent**, **RectTileLeaveEvent**
- **RigidbodyAttachEvent**, **RigidbodyDetachEvent**
- **KinematicbodyJumpEvent**

---

## 💡 Best Practices

### 1. 이동 방식 선택 기준
```lua
-- 플랫포머 (점프, 발판, 중력)
→ RigidbodyComponent

-- 탑다운 RPG (상하좌우, 타일)
→ KinematicbodyComponent

-- 횡스크롤 (좌우, 점프, 타일)
→ SideviewbodyComponent
```

### 2. 물리 파라미터 조정
```lua
-- 빠른 캐릭터
rb.WalkSpeed = 10.0
rb.WalkAcceleration = 20.0

-- 무거운 캐릭터
rb.Mass = 5.0
rb.WalkAcceleration = 5.0

-- 높이 점프
rb.WalkJump = 15.0
rb.Gravity = 15.0
```

### 3. 타일 충돌 최적화
```lua
-- 필요할 때만 충돌 활성화
kb.EnableTileCollision = true

-- 점프 중 타일 통과
if kb:IsOnGround() then
    kb.EnableTileCollision = true
else
    kb.EnableTileCollision = false
end
```

### 4. Attach 활용
```lua
-- 이동 플랫폼
rb:AttachTo(platformId, Vector3.zero)

-- 일정 시간 후 Detach
wait(3.0)
rb:Detach()
```

### 5. 발판 끝 감지
```lua
-- 발판 끝 10 거리 전에 경고
if not rb:PredictFootholdEnd(10, true) then
    log("Warning: Edge ahead!")
end
```

---

## 📋 다음 단계

Phase 7 완료! 다음은:
- **Phase 8**: Camera & Rendering Components (3개) - CameraComponent 등
- **Phase 9**: Network & Data Components (3개) - NetworkComponent 등

---

> **학습 완료**: 2026-02-08  
> **참고**: ColliderComponent는 API 문서가 존재하지 않아 제외되었습니다.  
> **다음 목표**: Phase 8 - Camera & Rendering Components 학습
