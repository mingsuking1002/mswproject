# MSW 핵심 Components 심화 가이드

> **Core Components Deep Dive** - 필수 컴포넌트 완전 정복

---

## 1. TransformComponent ⭐⭐⭐⭐⭐

> **용도**: 엔티티의 위치, 회전, 크기 제어
> **필수도**: ★★★★★ (모든 Entity 기본 컴포넌트)

### 1.1 Properties

#### 위치 (Position)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Position` | Vector3 | ✅ | 부모 기준 로컬 좌표 |
| `WorldPosition` | Vector3 | ❌ | 월드 기준 절대 좌표 |

```lua
-- 로컬 좌표 설정 (부모 기준)
self.Entity.TransformComponent.Position = Vector3(100, 200, 0)

-- 월드 좌표 설정 (절대 위치)
self.Entity.TransformComponent.WorldPosition = Vector3(500, 300, 0)
```

#### 회전 (Rotation)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Rotation` | Vector3 | ❌ | 오일러 각 (Euler Angles) |
| `QuaternionRotation` | Quaternion | ✅ | 쿼터니언 (동기화됨) |
| `Z rotation` | float | ❌ | Z축 회전 (2D) |
| `WorldRotation` | Vector3 | ❌ | 월드 기준 회전 |
| `WorldZRotation` | float | ❌ | 월드 Z축 회전 |

```lua
-- 2D 게임에서 회전 (Z축 사용)
transform.ZRotation = 45  -- 45도 회전

-- Rotation은 QuaternionRotation에 의해 동기화됨
-- 직접 제어는 Rotation 사용, 네트워크 전송은 Quaternion 사용
```

#### 크기 (Scale)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Scale` | Vector3 | ✅ | 크기 비율 (1 = 100%) |

```lua
-- 크기 2배로 확대
transform.Scale = Vector3(2, 2, 1)

-- X축만 뒤집기
transform.Scale = Vector3(-1, 1, 1)
```

### 1.2 Methods

#### Rotate(float angle)
```lua
-- angle만큼 반시계 방향 회전
transform:Rotate(90)  -- 90도 회전
```

#### Translate(float deltaX, float deltaY)
```lua
-- 상대 이동
transform:Translate(10, 0)  -- 오른쪽으로 10 이동
```

#### 좌표 변환 함수
| Method | 설명 |
|--------|------|
| `ToLocalPoint(Vector3 worldPoint)` | 월드 → 로컬 좌표 변환 (Scale 영향O) |
| `ToWorldPoint(Vector3 localPoint)` | 로컬 → 월드 좌표 변환 (Scale 영향O) |
| `ToLocalDirection(Vector3 worldDirection)` | 월드 → 로컬 방향 변환 (Scale 영향X) |
| `ToWorldDirection(Vector3 localDirection)` | 로컬 → 월드 방향 변환 (Scale 영향X) |

```lua
-- 월드 좌표를 로컬 좌표로 변환
local localPos = transform:ToLocalPoint(Vector3(100, 200, 0))

-- 캐릭터가 바라보는 방향의 월드 좌표
local forwardDir = transform:ToWorldDirection(Vector3(1, 0, 0))
```

#### FastVector3 반환
```lua
-- 성능 최적화 버전 (GC 부담 감소)
local fastPos = transform:PositionAsFastVector3()
local fastWorldPos = transform:WorldPositionAsFastVector3()
```

### 1.3 사용 패턴

#### 패턴 1: 회전 애니메이션
```lua
Property:
[None] number AngularSpeed = 360

Method:
[server only]
void OnUpdate(number delta)
{
    local transform = self.Entity.TransformComponent
    transform.ZRotation = transform.ZRotation + (self.AngularSpeed * delta)
}
```

#### 패턴 2: 자유낙하 시뮬레이션
```lua
Property:
[None] Vector2 Gravity = Vector2(0, -9.8)
[Sync] Vector2 CurrentVelocity = Vector2(0, 0)

Method:
[server only]
void OnUpdate(number delta)
{
    local transform = self.Entity.TransformComponent
    
    -- 속도 = 기존 속도 + 중력 * 시간
    self.CurrentVelocity = self.CurrentVelocity + (self.Gravity * delta)
    
    -- 이동 = 속도 * 시간
    local deltaX = self.CurrentVelocity.x * delta
    local deltaY = self.CurrentVelocity.y * delta
    
    transform:Translate(deltaX, deltaY)
}
```

---

## 2. SpriteRendererComponent ⭐⭐⭐⭐⭐

> **용도**: 스프라이트 이미지 및 애니메이션 렌더링
> **필수도**: ★★★★★ (가장 많이 사용)

### 2.1 Properties

#### 스프라이트 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SpriteRUID` | string | ✅ | 스프라이트/애니메이션 RUID |
| `Color` | Color | ✅ | 색상 오버레이 |
| `FlipX` | boolean | ✅ | X축 반전 |
| `FlipY` | boolean | ✅ | Y축 반전 |

```lua
-- 스프라이트 변경
sprite.SpriteRUID = "sprite://xxxxx"

-- 빨간색 오버레이
sprite.Color = Color(1, 0, 0, 1)

-- 좌우 반전 (캐릭터 방향 전환)
sprite.FlipX = true
```

#### 애니메이션 제어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `PlayRate` | float | ✅ | 재생 속도 (1 = 100%) |
| `StartFrameIndex` | int32 | ✅ | 시작 프레임 |
| `EndFrameIndex` | int32 | ✅ | 끝 프레임 |

```lua
-- 애니메이션 2배속 재생
sprite.PlayRate = 2.0

-- 특정 프레임 범위만 재생 (5~10번 프레임)
sprite.StartFrameIndex = 5
sprite.EndFrameIndex = 10
```

#### 렌더링 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `DrawMode` | SpriteDrawMode | ✅ | Simple/Sliced/Tiled |
| `TiledSize` | Vector2 | ✅ | Tiled/Sliced 시 크기 |
| `SortingLayer` | string | ✅ | 렌더링 레이어 |
| `OrderInLayer` | int32 | ✅ | 레이어 내 순서 (클수록 앞) |

```lua
-- 타일 모드로 배경 반복
sprite.DrawMode = SpriteDrawMode.Tiled
sprite.TiledSize = Vector2(1000, 500)

-- 렌더링 순서 설정
sprite.SortingLayer = "Character"
sprite.OrderInLayer = 100  -- 값이 클수록 앞에 보임
```

#### 머티리얼
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `MaterialID` | string | ✅ | 적용할 머티리얼 ID |

```lua
-- 머티리얼 적용
sprite.MaterialID = "material://xxxxx"
```

#### 맵 레이어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IgnoreMapLayerCheck` | boolean | ✅ | Map Layer 자동 치환 무시 |

### 2.2 Methods

#### ChangeMaterial(string materialId)
```lua
-- 머티리얼 교체
sprite:ChangeMaterial("material://new_material")
```

#### SetAlpha(float alpha)
```lua
-- 투명도 설정 (0.0 ~ 1.0)
sprite:SetAlpha(0.5)  -- 50% 투명

-- TweenLogic과 함께 사용하면 페이드 효과
local tweener = _TweenLogic:MakeNativeTween(
    1, 0, 3, EaseType.Linear,
    sprite, "SetAlpha"
)
tweener:Play()
```

### 2.3 Events

| Event | 발생 시점 |
|-------|----------|
| `SpriteAnimPlayerStartEvent` | 애니메이션 시작 |
| `SpriteAnimPlayerEndEvent` | 애니메이션 종료 |
| `SpriteAnimPlayerChangeFrameEvent` | 프레임 변경 |
| `SpriteAnimPlayerStartFrameEvent` | 첫 프레임 재생 |
| `SpriteAnimPlayerEndFrameEvent` | 마지막 프레임 재생 |
| `OrderInLayerChangedEvent` | OrderInLayer 변경 |
| `SortingLayerChangedEvent` | SortingLayer 변경 |

### 2.4 사용 패턴

#### 패턴 1: 조건부 스프라이트 변경
```lua
Property:
[Sync] number Meso = 0

Method:
[server only]
void OnBeginPlay()
{
    self.Meso = _UtilLogic:RandomIntegerRange(1, 1500)
    local sprite = self.Entity.SpriteRendererComponent
    
    if self.Meso < 50 then
        sprite.SpriteRUID = "sprite://meso_bronze"
    elseif self.Meso < 100 then
        sprite.SpriteRUID = "sprite://meso_silver"
    elseif self.Meso < 1000 then
        sprite.SpriteRUID = "sprite://meso_gold"
    else
        sprite.SpriteRUID = "sprite://meso_diamond"
    end
}
```

#### 패턴 2: 방향에 따른 FlipX
```lua
[server only]
void UpdateDirection(Vector2 velocity)
{
    local sprite = self.Entity.SpriteRendererComponent
    
    if velocity.x > 0 then
        sprite.FlipX = false  -- 오른쪽
    elseif velocity.x < 0 then
        sprite.FlipX = true   -- 왼쪽
    end
}
```

---

## 3. TextComponent ⭐⭐⭐⭐⭐

> **용도**: UI 텍스트 표시
> **필수도**: ★★★★★ (UI 필수)
> **권장**: UITransformComponent와 함께 사용

### 3.1 Properties

#### 텍스트 내용
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Text` | string | ❌ | 표시할 텍스트 |
| `IsLocalizationKey` | boolean | ❌ (MakerOnly) | LocaleDataSet Key 사용 여부 |
| `AllowAutomaticTranslation` | boolean | ❌ (MakerOnly) | 자동 번역 사용 |
| `EnableProfanityFilter` | boolean | ❌ (MakerOnly) | 금칙어 필터 사용 |
| `IsRichText` | boolean | ❌ | 리치 텍스트 사용 |

```lua
-- 일반 텍스트
text.Text = "Hello, World!"

-- 로컬라이제이션 사용
text.IsLocalizationKey = true
text.Text = "UI_GREETING"  -- Key로 사용

-- 리치 텍스트
text.IsRichText = true
text.Text = "<color=red>빨간색</color> <b>굵게</b>"
```

#### 폰트 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Font` | FontType | ❌ | 글꼴 종류 |
| `FontSize` | int32 | ❌ | 글꼴 크기 |
| `FontColor` | Color | ❌ | 텍스트 색상 |
| `Bold` | boolean | ❌ | 굵게 |
| `LineSpacing` | float | ❌ | 행간 너비 |

```lua
text.Font = FontType.Maplestory
text.FontSize = 24
text.FontColor = Color.white
text.Bold = true
text.LineSpacing = 1.2
```

#### 정렬 및 오버플로우
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Alignment` | TextAlignmentType | ❌ | 정렬 방식 |
| `Overflow` | OverflowType | ❌ | 영역 초과 처리 |
| `UseNBSP` | boolean | ❌ | 개행 방식 (문자/단어) |

```lua
text.Alignment = TextAlignmentType.UpperLeft
text.Overflow = OverflowType.Ellipsis  -- ... 표시
text.UseNBSP = false  -- 단어 단위 개행
```

#### 크기 조절
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SizeFit` | boolean | ❌ | 텍스트에 맞춰 크기 조정 |
| `BestFit` | boolean | ❌ | 영역에 맞춰 폰트 크기 조정 |
| `MinSize` | int32 | ❌ | 최소 폰트 크기 |
| `MaxSize` | int32 | ❌ | 최대 폰트 크기 |
| `ConstraintX` | float | ❌ | 최대 너비 제한 |
| `ConstraintY` | float | ❌ | 최대 높이 제한 |
| `UseConstraintX` | boolean | ❌ | 너비 제한 사용 |
| `UseConstraintY` | boolean | ❌ | 높이 제한 사용 |

```lua
-- 텍스트에 맞춰 크기 자동 조정
text.SizeFit = true
text.UseConstraintX = true
text.ConstraintX = 500  -- 최대 500px

-- 영역에 맞춰 폰트 크기 자동 조정
text.BestFit = true
text.MinSize = 10
text.MaxSize = 30
```

#### 외곽선 (Outline)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `UseOutLine` | boolean | ❌ | 외곽선 사용 |
| `OutlineWidth` | float | ❌ | 외곽선 두께 |
| `OutlineColor` | Color | ❌ | 외곽선 색상 |

```lua
text.UseOutLine = true
text.OutlineWidth = 2
text.OutlineColor = Color.black
```

#### 그림자 (Drop Shadow)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `DropShadow` | boolean | ❌ | 그림자 사용 |
| `DropShadowColor` | Color | ❌ | 그림자 색상 |
| `DropShadowDistance` | float | ❌ | 그림자 거리 |
| `DropShadowAngle` | float | ❌ | 그림자 각도 |

```lua
text.DropShadow = true
text.DropShadowColor = Color(0, 0, 0, 0.5)
text.DropShadowDistance = 2
text.DropShadowAngle = 45
```

#### 여백 (Padding)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Padding` | RectOffset | ❌ | 텍스트 영역 여백 |

#### 렌더링
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SortingLayer` | string | ✅ | 렌더링 레이어 |
| `OrderInLayer` | int32 | ✅ | 레이어 내 순서 |
| `OverrideSorting` | boolean | ✅ (ReadOnly) | Sorting 임의 설정 여부 |
| `IgnoreMapLayerCheck` | boolean | ✅ | MapLayer 자동 치환 무시 |

### 3.2 Methods

#### GetLocalizedText() [ClientOnly]
```lua
-- LocaleDataSet에서 번역 텍스트 가져오기
local localizedText = text:GetLocalizedText()
```

#### GetPreferredWidth(string preferredText) [ClientOnly, Yield]
```lua
-- 텍스트 영역의 너비 계산
local width = text:GetPreferredWidth("Hello")
```

#### GetPreferredHeight(string preferredText, float width) [ClientOnly, Yield]
```lua
-- 고정 너비에서 텍스트 영역의 높이 계산
local height = text:GetPreferredHeight("Long text...", 200)
```

### 3.3 Events

| Event | 발생 시점 |
|-------|----------|
| `OrderInLayerChangedEvent` | OrderInLayer 변경 |
| `SortingLayerChangedEvent` | SortingLayer 변경 |

### 3.4 사용 패턴

#### 패턴 1: 타이핑 효과 (한 글자씩 출력)
```lua
Property:
[None] number TimerID = 0
[None] number MessageLength = 0
[None] number MessageIdx = 0
[None] string RawMessage = ""

Method:
[client only]
void OnBeginPlay()
{
    local textComponent = self.Entity.TextComponent
    if not textComponent then return end
    
    textComponent.Bold = true
    textComponent.Alignment = TextAlignmentType.UpperLeft
    textComponent.FontColor = Color.white
    textComponent.UseOutLine = true
    textComponent.OutlineColor = Color.black
    textComponent.FontSize = 50
    
    self:ShowDialogueOverTime("안녕하세요. MSW에 오신 것을 환영합니다.", 0.1)
}

void ShowDialogueOverTime(string rawMessage, number interval)
{
    if interval <= 0 then interval = 0.1 end
    
    self.MessageIdx = 0
    self.RawMessage = rawMessage
    self.MessageLength = utf8.len(rawMessage)
    
    local UpdateMessage = function()
        if self.MessageIdx < self.MessageLength then
            self.MessageIdx = self.MessageIdx + 1
            local currentString = _UtilLogic:SubString(self.RawMessage, 1, self.MessageIdx)
            
            if not _UtilLogic:IsNilorEmptyString(currentString) then
                self.Entity.TextComponent.Text = currentString
            end
        else
            self.Entity.TextComponent.Text = ""
            self:RestartDialogue()
        end
    end
    
    self.TimerID = _TimerService:SetTimerRepeat(UpdateMessage, interval)
}

void CancelDialogue()
{
    _TimerService:ClearTimer(self.TimerID)
}

void RestartDialogue()
{
    self.MessageIdx = 0
}
```

#### 패턴 2: 동적 점수 표시
```lua
Property:
[Sync] number Score = 0

Method:
[client only]
void OnSyncProperty(string name, any value)
{
    if name == "Score" then
        self.Entity.TextComponent.Text = string.format("점수: %d", self.Score)
    end
}
```

---

## 4. Component 공통 패턴

### 4.1 상속받은 Properties (모든 Component)

| Property | Type | 설명 |
|----------|------|------|
| `Enable` [Sync] | boolean | 컴포넌트 활성화 여부 |
| `EnableInHierarchy` [ReadOnly] | boolean | 계층 구조상 활성화 여부 |
| `Entity` [ReadOnly] | Entity | 소유한 엔티티 |

### 4.2 상속받은 Methods (모든 Component)

| Method | 설명 |
|--------|------|
| `IsClient()` | 클라이언트 환경 여부 |
| `IsServer()` | 서버 환경 여부 |

```lua
-- 컴포넌트 비활성화
component.Enable = false

-- 실행 환경 확인
if component:IsServer() then
    -- 서버 전용 로직
end
```

---

## 5. 학습 체크리스트

### TransformComponent
- [x] Position vs WorldPosition 차이
- [x] Rotation (Euler) vs QuaternionRotation
- [x] Translate, Rotate 함수 사용법
- [x] 좌표 변환 함수 (ToLocal/ToWorld)
- [x] 자유낙하, 회전 애니메이션 구현

### SpriteRendererComponent
- [x] SpriteRUID로 스프라이트 변경
- [x] Color 오버레이, FlipX/Y 사용법
- [x] 애니메이션 제어 (PlayRate, StartFrame, EndFrame)
- [x] DrawMode (Simple/Sliced/Tiled)
- [x] SortingLayer, OrderInLayer 렌더링 순서
- [x] SetAlpha, ChangeMaterial 함수
- [x] 애니메이션 이벤트 처리

### TextComponent
- [x] Text, Font, FontSize, FontColor 설정
- [x] Alignment, Overflow, UseNBSP
- [x] SizeFit, BestFit 자동 크기 조절
- [x] UseOutLine, DropShadow 효과
- [x] IsLocalizationKey 로컬라이제이션
- [x] IsRichText 리치 텍스트
- [x] 타이핑 효과 구현

---

> **다음 학습**: UITransformComponent, RigidbodyComponent, TriggerComponent

---

## 4. UITransformComponent ⭐⭐⭐⭐⭐

> **용도**: UI 엔티티의 위치, 크기, 앵커 제어
> **필수도**: ★★★★★ (UI 필수, TextComponent와 함께 사용)
> **주의**: TransformComponent를 상속받으며 UI 전용 기능 추가

### 4.1 Properties

#### UI 앵커 시스템
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `AlignmentOption` | AlignmentType | ❌ | 앵커 참조 포인트 (UpperLeft, Center, StretchAll 등) |
| `anchoredPosition` | Vector2 | ❌ | 앵커 기준 UI 중심 위치 |
| `AnchorsMin` | Vector2 | ❌ | 왼쪽 하단 앵커 정규화 위치 (0~1) |
| `AnchorsMax` | Vector2 | ❌ | 오른쪽 상단 앵커 정규화 위치 (0~1) |

```lua
-- 화면 중앙에 UI 배치
uiTransform.AlignmentOption = AlignmentType.MiddleCenter
uiTransform.anchoredPosition = Vector2(0, 0)

-- 화면 전체를 채우는 UI (Stretch)
uiTransform.AlignmentOption = AlignmentType.StretchAll
uiTransform.OffsetMin = Vector2(0, 0)
uiTransform.OffsetMax = Vector2(0, 0)
```

#### UI 오프셋 및 크기
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `OffsetMin` | Vector2 | ❌ | 왼쪽 하단 앵커 기준 편차 |
| `OffsetMax` | Vector2 | ❌ | 오른쪽 상단 앵커 기준 편차 |
| `RectSize` | Vector2 | ❌ | UI 크기 (width, height) |

```lua
-- 화면 가장자리에서 10px씩 여백
uiTransform.OffsetMin = Vector2(10, 10)
uiTransform.OffsetMax = Vector2(-10, -10)

-- 고정 크기 UI (800x600)
uiTransform.RectSize = Vector2(800, 600)
```

#### UI 회전 및 크기 비율
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Pivot` | Vector2 | ❌ | 회전 중심점 정규화 위치 (0~1) |
| `UIRotation` | Vector3 | ❌ | UI 회전 (Euler Angles) |
| `UIScale` | Vector3 | ❌ | UI 상대 크기 비율 |

```lua
-- 중심 기준 회전
uiTransform.Pivot = Vector2(0.5, 0.5)
uiTransform.UIRotation = Vector3(0, 0, 45) -- Z축 45도

-- UI 크기 1.5배
uiTransform.UIScale = Vector3(1.5, 1.5, 1)
```

#### 플랫폼 및 모드
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `ActivePlatform` [ReadOnly] | PlatformType | ❌ | 활성화되는 플랫폼 (PC/Mobile) |
| `UIMode` [ReadOnly] | UIModeType | ❌ | 현재 UI 렌더링 모드 |

### 4.2 Methods

#### GetWorldCorners()
```lua
-- UI 4개 꼭지점의 월드 좌표 (좌하, 좌상, 우상, 우하 순)
local corners = uiTransform:GetWorldCorners()
local bottomLeft = corners[1]
local topLeft = corners[2]
local topRight = corners[3]
local bottomRight = corners[4]
```

### 4.3 Events

| Event | 발생 시점 |
|-------|----------|
| `UIModeTypeChangedEvent` | UIMode 변경 |

### 4.4 사용 패턴

#### 패턴 1: 크기 애니메이션 (호흡 효과)
```lua
Property:
[None] number offset = 0
[None] number dir = 1.0

Method:
[client only]
void OnUpdate(number delta)
{
    local offsetPerDelta = delta * 100.0 * self.dir
    self.offset = self.offset + offsetPerDelta
    
    if self.dir > 0 and self.offset >= 100 then
        self.dir = -1.0
    elseif self.dir < 0 and self.offset <= 0 then
        self.dir = 1.0
    end
    
    local uiTransform = self.Entity.UITransformComponent
    if uiTransform then
        if uiTransform.AlignmentOption ~= AlignmentType.StretchAll then
            uiTransform.AlignmentOption = AlignmentType.StretchAll
            uiTransform.anchoredPosition = Vector2.zero
        end
        
        uiTransform.OffsetMin = Vector2(self.offset, self.offset)
        uiTransform.OffsetMax = Vector2(-self.offset, -self.offset)
    end
}
```

#### 패턴 2: 화면 비율에 맞춘 UI 배치
```lua
-- 상단 중앙 (체력바)
uiTransform.AlignmentOption = AlignmentType.UpperCenter
uiTransform.anchoredPosition = Vector2(0, -50)

-- 하단 우측 (미니맵)
uiTransform.AlignmentOption = AlignmentType.LowerRight
uiTransform.anchoredPosition = Vector2(-100, 100)

-- 좌측 전체 (인벤토리)
uiTransform.AlignmentOption = AlignmentType.StretchLeft
uiTransform.OffsetMin = Vector2(0, 100)
uiTransform.OffsetMax = Vector2(0, -100)
```

---

## 5. RigidbodyComponent ⭐⭐⭐⭐⭐

> **용도**: 메이플 스타일 물리 이동 (플랫포머)
> **필수도**: ★★★★★ (캐릭터/NPC 이동 필수)
> **핵심**: 중력, 가감속, 점프, 발판 감지

### 5.1 Properties

#### 지상 이동 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `WalkSpeed` | float | ❌ | 지상 최대 이동 속도 |
| `WalkAcceleration` | float | ❌ | 가속도 (클수록 빠르게 가속) |
| `WalkDrag` | float | ❌ | 지형 마찰력 (0.5~2) |
| `WalkSlant` | float | ❌ | 경사 극복 능력 (0~1) |
| `WalkJump` | float | ❌ | 점프 높이 |

```lua
-- 빠른 캐릭터 설정
rigidbody.WalkSpeed = 500
rigidbody.WalkAcceleration = 3000
rigidbody.WalkDrag = 2.0  -- 빠르게 멈춤
rigidbody.WalkJump = 800  -- 높은 점프
```

#### 공중 이동 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `AirAccelerationX` | float | ❌ | 공중 이동 속도 보정 |
| `AirDecelerationX` | float | ❌ | 공중 입력 없을 때 감속 |
| `FallSpeedMaxX` | float | ❌ | 공중 X축 최대 속도 |
| `FallSpeedMaxY` | float | ❌ | 공중 Y축 최대 속도 (낙하) |
| `Gravity` | float | ❌ | 중력 (클수록 빠르게 낙하) |

```lua
-- 공중 제어력이 좋은 캐릭터
rigidbody.AirAccelerationX = 2000
rigidbody.AirDecelerationX = 1500
rigidbody.Gravity = 2000
rigidbody.FallSpeedMaxY = 1200
```

#### 점프 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `JumpBias` | float | ❌ | 점프 시작 높이 |
| `DownJumpSpeed` | float | ❌ | 아래 점프 시 위로 튀어오르는 속도 |

#### 이동 모드
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `KinematicMove` | boolean | ❌ | true = 탑다운 (상하좌우), false = 플랫포머 |
| `KinematicMoveAcceleration` | Vector2 | ❌ | 탑다운 모드 이동 속력 |
| `EnableKinematicMoveJump` | boolean | ❌ | 탑다운에서 점프 사용 여부 |

```lua
-- 탑다운 게임 설정
rigidbody.KinematicMove = true
rigidbody.KinematicMoveAcceleration = Vector2(500, 500)
rigidbody.EnableKinematicMoveJump = false
```

#### 이동 입력 및 상태
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `MoveVelocity` [HideFromInspector] | Vector2 | ❌ | 이동 입력값 (-1~1) |
| `RealMoveVelocity` [HideFromInspector] [ReadOnly] | Vector2 | ❌ | 실제 이동량 |

```lua
-- 이동 입력 (MovementComponent가 주로 제어)
rigidbody.MoveVelocity = Vector2(1, 0) -- 오른쪽

-- 실제 이동량 확인
local velocity = rigidbody.RealMoveVelocity
local speed = velocity.magnitude
```

#### 물리 속성
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Mass` | float | ❌ | 질량 (클수록 가감속 느림, >0) |

#### 지형 제한
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IgnoreMoveBoundary` | boolean | ❌ | true = 맵 영역 벗어날 수 있음 |
| `IsBlockVerticalLine` | boolean | ❌ | true = 세로 지형 무조건 막힘 |
| `IsolatedMove` | boolean | ❌ | true = 발판 끝에서 떨어지지 않음 |

```lua
-- NPC가 발판 밖으로 안 떨어지게
rigidbody.IsolatedMove = true

-- 벽 통과 방지
rigidbody.IsBlockVerticalLine = true
```

#### 레이어 및 사다리
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `LayerSettingType` [Sync] | AutomaticLayerOption | ✅ | Foothold/사다리와의 SortingLayer 관계 |
| `ApplyClimbableRotation` [Sync] | boolean | ✅ | true = 사다리 기울기에 캐릭터 회전 적용 |

### 5.2 Methods

#### 위치 설정
| Method | 설명 |
|--------|------|
| `SetPosition(Vector2 position)` | 로컬 좌표 설정 |
| `SetWorldPosition(Vector2 position)` | 월드 좌표 설정 |
| `PositionReset()` | 누적 위치 정보 초기화 |

```lua
-- 스폰 포인트로 이동
rigidbody:SetWorldPosition(Vector2(100, 200))
rigidbody:PositionReset() -- 물리 계산 초기화
```

#### 힘 적용
| Method | 설명 |
|--------|------|
| `SetForce(Vector2 forcePower)` | 힘 설정 (기존 힘 대체) |
| `AddForce(Vector2 forcePower)` | 힘 추가 (기존 힘에 더함) |
| `SetForceReserve(Vector2 forcePower)` | 프레임 종료 후 힘 적용 예약 |

```lua
-- 넉백 효과
rigidbody:AddForce(Vector2(-500, 300))

-- 점프 (SetForce로 순간 힘)
rigidbody:SetForce(Vector2(0, 2000))
```

#### 점프
| Method | 설명 |
|--------|------|
| `JustJump(Vector2 jumpRate)` | 대상 점프 (벡터 비율) |
| `DownJump()` | 아래 점프 수행 |

```lua
-- 일반 점프
rigidbody:JustJump(Vector2(1, 1))

-- 아래 점프 (지상에서만 동작)
if rigidbody:IsOnGround() then
    rigidbody:DownJump()
end
```

#### Attach 시스템
| Method | 설명 |
|--------|------|
| `AttachTo(string entityId, Vector3 offset)` | 다른 엔티티에 붙힘 (물리 비활성) |
| `Detach()` | Attach 해제 |

```lua
-- 이동 플랫폼에 붙기
rigidbody:AttachTo(platformEntity.Id, Vector3.zero)

-- 3초 후 떨어지기
wait(3)
rigidbody:Detach()
```

#### 발판 정보
| Method | 설명 |
|--------|------|
| `IsOnGround()` | 지형 위에 있는지 확인 |
| `GetCurrentFoothold()` | 현재 밟고 있는 Foothold 반환 |
| `GetCurrentFootholdPerpendicular()` | 밟고 있는 지형의 수직선 |
| `PredictFootholdEnd(float distance, boolean isForward)` | 발판 끝까지 거리 확인 |

```lua
-- 발판 끝 감지 (AI 제어)
local canMoveForward = rigidbody:PredictFootholdEnd(50, true)
if not canMoveForward then
    -- 방향 전환
    rigidbody.MoveVelocity = Vector2(-1, 0)
end

-- 경사면의 수직 벡터
local perpendicular = rigidbody:GetCurrentFootholdPerpendicular()
```

### 5.3 Events

| Event | 발생 시점 |
|-------|----------|
| `FootholdCollisionEvent` | 발판 충돌 |
| `FootholdEnterEvent` | 발판에 붙음 |
| `FootholdLeaveEvent` | 발판에서 떨어짐 |
| `RigidbodyAttachEvent` | AttachTo 실행 |
| `RigidbodyDetachEvent` | Detach 실행 |
| `RigidbodyClimbableAttachStartEvent` | 사다리/로프 타기 전 |
| `RigidbodyClimbableDetachEndEvent` | 사다리/로프 떨어진 후 |
| `RigidbodyKinematicMoveJumpEvent` | 탑다운 모드에서 점프/착지 |

### 5.4 사용 패턴

#### 패턴 1: AI 순찰 (발판 끝 감지)
```lua
Property:
[None] number Direction = 1

Method:
[server only]
void OnUpdate(number delta)
{
    local rigidbody = self.Entity.RigidbodyComponent
    
    -- 발판 끝 50px 이내면 방향 전환
    if not rigidbody:PredictFootholdEnd(50, self.Direction > 0) then
        self.Direction = -self.Direction
    end
    
    rigidbody.MoveVelocity = Vector2(self.Direction, 0)
}
```

#### 패턴 2: 넉백 효과
```lua
void ApplyKnockback(Vector2 attackDirection, number power)
{
    local rigidbody = self.Entity.RigidbodyComponent
    
    -- 공격 방향으로 튕겨냄
    local knockbackForce = attackDirection.normalized * power
    knockbackForce.y = power * 0.5  -- 위로도 약간 튕김
    
    rigidbody:AddForce(knockbackForce)
}
```

---

## 6. TriggerComponent ⭐⭐⭐⭐⭐

> **용도**: 충돌 영역 감지 (트리거, 아이템 획득, 상호작용)
> **필수도**: ★★★★★ (모든 상호작용의 기본)
> **중요**: CollisionGroup으로 충돌 대상 필터링

### 6.1 Properties

#### 충돌체 형태 (신규 시스템, IsLegacy=false)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `ColliderType` [Sync] | ColliderType | ✅ | Box/Circle/Polygon |
| `ColliderOffset` [Sync] | Vector2 | ✅ | 충돌체 중심점 위치 |
| `BoxSize` [Sync] | Vector2 | ✅ | 직사각형 너비/높이 |
| `CircleRadius` [Sync] | float | ✅ | 원형 반지름 |
| `PolygonPoints` [Sync] | SyncList\<Vector2\> | ✅ | 다각형 점들의 위치 |

```lua
-- 박스 충돌체
trigger.ColliderType = ColliderType.Box
trigger.ColliderOffset = Vector2(0, 0)
trigger.BoxSize = Vector2(100, 100)

-- 원형 충돌체
trigger.ColliderType = ColliderType.Circle
trigger.CircleRadius = 50

-- 다각형 충돌체
trigger.ColliderType = ColliderType.Polygon
trigger.PolygonPoints:Clear()
trigger.PolygonPoints:Add(Vector2(0, 0))
trigger.PolygonPoints:Add(Vector2(50, 0))
trigger.PolygonPoints:Add(Vector2(25, 50))
```

#### 충돌체 형태 (구 시스템, IsLegacy=true)
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `BoxOffset` [Sync] | Vector2 | ✅ | 구 시스템 충돌체 중심 (Deprecated) |

#### 충돌 그룹
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `CollisionGroup` [Sync] | CollisionGroup | ✅ | 충돌 그룹 설정 |

```lua
-- 플레이어만 감지하는 트리거
trigger.CollisionGroup = CollisionGroup.GetCollisionGroup("PlayerOnly")

-- 몬스터만 감지
trigger.CollisionGroup = CollisionGroup.GetCollisionGroup("MonsterOnly")
```

#### 충돌 최적화
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IsPassive` [Sync] | boolean | ✅ | true = 스스로 충돌 검사 안 함 (성능 개선) |

```lua
-- 아이템은 Passive (플레이어가 검사)
itemTrigger.IsPassive = true

-- 플레이어는 Active (주도적으로 검사)
playerTrigger.IsPassive = false
```

#### 시스템 정보
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IsLegacy` [ReadOnly] | boolean | ❌ | true = 구 시스템 (회전/크기 미적용) |

### 6.2 Methods

#### ScriptOverridable (이벤트 대신 함수 재정의)
| Method | 설명 |
|--------|------|
| `OnEnterTriggerBody(TriggerEnterEvent)` | 트리거 진입 |
| `OnStayTriggerBody(TriggerStayEvent)` | 트리거 내 머무름 (매 프레임) |
| `OnLeaveTriggerBody(TriggerLeaveEvent)` | 트리거 이탈 |

```lua
Method:
[server only]
void OnEnterTriggerBody(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    print(other.Name .. " 진입!")
}
```

### 6.3 Events

| Event | 발생 시점 |
|-------|----------|
| `TriggerEnterEvent` | 영역이 겹치는 순간 |
| `TriggerStayEvent` | 영역이 겹쳐 있는 동안 (매 프레임, 성능 주의!) |
| `TriggerLeaveEvent` | 영역이 떨어지는 순간 |

### 6.4 사용 패턴

#### 패턴 1: 체력 회복 공간
```lua
Property:
[Sync] boolean IsGettingHealed = false
[Sync] number Hp = 1000

Method:
[server only]
void OnUpdate(number delta)
{
    if self.IsGettingHealed then
        local player = self.Entity.PlayerComponent
        self.Hp = self.Hp + (10.0 * delta)
        player.Hp = math.floor(self.Hp)
    end
}

Event Handler:
[server only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    if other.Name == "HealZone" then
        self.IsGettingHealed = true
    end
}

[server only] [self]
HandleTriggerLeaveEvent(TriggerLeaveEvent event)
{
    local other = event.TriggerBodyEntity
    if other.Name == "HealZone" then
        self.IsGettingHealed = false
    end
}
```

#### 패턴 2: 아이템 획득
```lua
Property:
[Sync] string ItemType = "Coin"
[Sync] number ItemValue = 10

Event Handler:
[server only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    local player = other.PlayerComponent
    
    if player then
        -- 플레이어가 아이템에 닿음
        if self.ItemType == "Coin" then
            player.Gold = player.Gold + self.ItemValue
        elseif self.ItemType == "Potion" then
            player.Hp = player.Hp + self.ItemValue
        end
        
        -- 아이템 제거
        self.Entity:Destroy()
    end
}
```

#### 패턴 3: 출입 카운터
```lua
Property:
[Sync] number PlayersInside = 0

Event Handler:
[server only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    if other.PlayerComponent then
        self.PlayersInside = self.PlayersInside + 1
        print("입장: " .. self.PlayersInside .. "명")
    end
}

[server only] [self]
HandleTriggerLeaveEvent(TriggerLeaveEvent event)
{
    local other = event.TriggerBodyEntity
    if other.PlayerComponent then
        self.PlayersInside = self.PlayersInside - 1
        print("퇴장: " .. self.PlayersInside .. "명")
    end
}
```

---

## 7. Component 공통 패턴

### 7.1 상속받은 Properties (모든 Component)

| Property | Type | 설명 |
|----------|------|------|
| `Enable` [Sync] | boolean | 컴포넌트 활성화 여부 |
| `EnableInHierarchy` [ReadOnly] | boolean | 계층 구조상 활성화 여부 |
| `Entity` [ReadOnly] | Entity | 소유한 엔티티 |

### 7.2 상속받은 Methods (모든 Component)

| Method | 설명 |
|--------|------|
| `IsClient()` | 클라이언트 환경 여부 |
| `IsServer()` | 서버 환경 여부 |

```lua
-- 컴포넌트 비활성화
component.Enable = false

-- 실행 환경 확인
if component:IsServer() then
    -- 서버 전용 로직
end
```

---

## 8. 학습 체크리스트

### TransformComponent
- [x] Position vs WorldPosition 차이
- [x] Rotation (Euler) vs QuaternionRotation
- [x] Translate, Rotate 함수 사용법
- [x] 좌표 변환 함수 (ToLocal/ToWorld)
- [x] 자유낙하, 회전 애니메이션 구현

### SpriteRendererComponent
- [x] SpriteRUID로 스프라이트 변경
- [x] Color 오버레이, FlipX/Y 사용법
- [x] 애니메이션 제어 (PlayRate, StartFrame, EndFrame)
- [x] DrawMode (Simple/Sliced/Tiled)
- [x] SortingLayer, OrderInLayer 렌더링 순서
- [x] SetAlpha, ChangeMaterial 함수
- [x] 애니메이션 이벤트 처리

### TextComponent
- [x] Text, Font, FontSize, FontColor 설정
- [x] Alignment, Overflow, UseNBSP
- [x] SizeFit, BestFit 자동 크기 조절
- [x] UseOutLine, DropShadow 효과
- [x] IsLocalizationKey 로컬라이제이션
- [x] IsRichText 리치 텍스트
- [x] 타이핑 효과 구현

### UITransformComponent
- [x] AlignmentOption, anchoredPosition 앵커 시스템
- [x] AnchorsMin/Max, OffsetMin/Max 이해
- [x] RectSize, Pivot, UIScale
- [x] UIRotation과 Transform의 Rotation 차이
- [x] GetWorldCorners로 UI 영역 계산
- [x] StretchAll로 화면 크기 대응

### RigidbodyComponent
- [x] WalkSpeed, WalkAcceleration, WalkJump 지상 이동
- [x] AirAccelerationX, Gravity 공중 제어
- [x] KinematicMove 탑다운 vs 플랫포머
- [x] SetForce, AddForce 힘 적용
- [x] JustJump, DownJump 점프 제어
- [x] AttachTo/Detach 시스템
- [x] IsOnGround, GetCurrentFoothold 발판 감지
- [x] PredictFootholdEnd로 AI 제어
- [x] MoveVelocity vs RealMoveVelocity

### TriggerComponent
- [x] ColliderType (Box/Circle/Polygon)
- [x] ColliderOffset, BoxSize, CircleRadius
- [x] CollisionGroup으로 충돌 필터링
- [x] IsPassive 성능 최적화
- [x] TriggerEnter/Stay/Leave 이벤트
- [x] OnEnterTriggerBody 함수 재정의
- [x] IsLegacy 신구 시스템 차이

---

> **완료**: 6개 필수 Components 마스터!  
> **다음 학습**: ButtonComponent, TextInputComponent, CameraComponent, MapComponent, TileMapComponent, PlayerComponent

