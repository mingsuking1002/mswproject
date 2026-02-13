# MapleStory Worlds - 핵심 Components 상세 가이드 (Part 2)

> **목적**: 나머지 6개 핵심 Components의 모든 Properties, Methods, Events 완벽 정리  
> **대상**: ButtonComponent, TextInputComponent, CameraComponent, MapComponent, TileMapComponent, PlayerComponent

---

## 1. ButtonComponent ⭐⭐⭐⭐⭐

> **용도**: UI 버튼 기능 제공
> **필수도**: ★★★★★ (UI 상호작용 필수)
> **핵심**: 버튼 클릭 감지, 상태별 비주얼 제어

### 1.1 Properties

#### 비주얼 전환
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Transition` | TransitionType | ❌ | 버튼 상태 전환 효과 (None/ColorTint/SpriteSwap/Animation) |
| `Colors` [HideFromInspector] | TransitionColorSet | ❌ | 상태별 색상 정의 (NormalColor, HighlightedColor, PressedColor, DisabledColor) |
| `ImageRUIDs` [HideFromInspector] | TransitionRUIDSet | ❌ | 상태별 이미지 RUID |

```lua
-- 색상 전환 효과
button.Transition = TransitionType.ColorTint
button.Colors.NormalColor = Color(1, 1, 1, 1)
button.Colors.PressedColor = Color(0.8, 0.8, 0.8, 1)

-- 이미지 전환 효과
button.Transition = TransitionType.SpriteSwap
button.ImageRUIDs.NormalImage = "normal_btn_ruid"
button.ImageRUIDs.PressedImage = "pressed_btn_ruid"
```

#### 키보드 바인딩
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `KeyCode` | KeyboardKey | ❌ | 버튼과 연결된 키보드 단축키 |

```lua
-- Space키로 버튼 누르기
button.KeyCode = KeyboardKey.Space
```

#### 렌더링 레이어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SortingLayer` [Sync] | string | ✅ | 렌더링 우선순위 레이어 |
| `OrderInLayer` [Sync] | int32 | ✅ | 같은 레이어 내 우선순위 (큰 값 = 앞에 보임) |
| `OverrideSorting` [Sync] [ReadOnly] | boolean | ✅ | 레이어 값을 임의 설정 가능 여부 |
| `IgnoreMapLayerCheck` [Sync] | boolean | ✅ | SortingLayer의 Map Layer 자동 치환 비활성화 |

### 1.2 Methods

상속받은 메서드만 제공 (`IsClient()`, `IsServer()`)

### 1.3 Events

| Event | 발생 시점 |
|-------|----------|
| `ButtonClickEvent` | 버튼 클릭 완료 시 |
| `ButtonPressedEvent` | 버튼이 눌린 상태가 됨 |
| `ButtonStateChangeEvent` | 버튼 상태 변경 시 (Normal→Highlighted→Pressed→Disabled) |
| `ButtonClickEditorEvent` | 버튼 클릭 (에디터 전용) |
| `ButtonStateChangeEditorEvent` | 버튼 상태 변경 (에디터 전용) |
| `OrderInLayerChangedEvent` | OrderInLayer 변경 시 |
| `SortingLayerChangedEvent` | SortingLayer 변경 시 |

### 1.4 사용 패턴

#### 패턴 1: 버튼 홀드 시 이미지/색상 변경
```lua
Property:
[None] boolean IsButtonDown = false
[None] number RedVal = 0
[None] number TimerID = 0
[None] string AlternateImageRUID = "pressed_image_ruid"
[None] string OriginalRUID = ""

Method:
[client only]
void OnBeginPlay()
{
    self.OriginalRUID = self.Entity.SpriteGUIRendererComponent.ImageRUID
}

void CancelHoldButton()
{
    _TimerService:ClearTimer(self.TimerID)
    self.Entity.SpriteGUIRendererComponent.ImageRUID = self.OriginalRUID
    self.IsButtonDown = false
    self.RedVal = 0
}

Event Handler:
[self]
HandleButtonPressedEvent(ButtonPressedEvent event)
{
    if self.IsButtonDown then
        self:CancelHoldButton()
    else
        self.Entity.SpriteGUIRendererComponent.ImageRUID = self.AlternateImageRUID
    end
    
    self.IsButtonDown = true
    
    local AddMoreRed = function()
        if self.RedVal <= 1 then
            self.RedVal = self.RedVal + 0.2
            self.Entity.ButtonComponent.Colors.PressedColor = Color(self.RedVal, 0, 0, 1)
        end
    end
    self.TimerID = _TimerService:SetTimerRepeat(AddMoreRed, 0.3)
}

[self]
HandleButtonClickEvent(ButtonClickEvent event)
{
    -- 클릭 완료 시 원래 상태로
    self:CancelHoldButton()
}

[self]
HandleButtonStateChangeEvent(ButtonStateChangeEvent event)
{
    if event.state == ButtonState.Released then
        self:CancelHoldButton()
    end
}
```

---

## 2. TextInputComponent ⭐⭐⭐⭐⭐

> **용도**: 문자열 입력 받기
> **필수도**: ★★★★★ (채팅, 검색, 이름 입력 등 필수)
> **핵심**: TextComponent와 함께 사용

### 2.1 Properties

#### 입력 제한
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `CharacterLimit` | int32 | ❌ | 입력 가능한 글자 수 제한 |
| `ContentType` | InputContentType | ❌ | 입력 타입 (Standard/IntegerNumber/DecimalNumber/Alphanumeric/Name/Email/Password/Pin) |
| `LineType` | InputLineType | ❌ | 개행 입력 방식 (SingleLine/MultiLineSubmit/MultiLineNewline) |

```lua
-- 비밀번호 입력 필드
textInput.CharacterLimit = 20
textInput.ContentType = InputContentType.Password
textInput.LineType = InputLineType.SingleLine

-- 정수만 입력 가능
textInput.ContentType = InputContentType.IntegerNumber
textInput.CharacterLimit = 10
```

#### 플레이스홀더
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `PlaceHolder` | string | ❌ | 비어있을 때 표시되는 기본 문구 |
| `PlaceHolderColor` | Color | ❌ | PlaceHolder 색상 |
| `IsLocalizationKey` [MakerOnly] | boolean | ❌ | true = PlaceHolder를 LocaleDataSet 키로 사용 |
| `AllowAutomaticTranslation` [MakerOnly] | boolean | ❌ | PlaceHolder 자동 번역 여부 |

```lua
-- 한국어 기본 문구
textInput.PlaceHolder = "이름을 입력하세요"
textInput.PlaceHolderColor = Color(0.7, 0.7, 0.7, 1)

-- 로컬라이제이션
textInput.IsLocalizationKey = true
textInput.PlaceHolder = "NAME_INPUT_KEY"
```

#### 입력 상태
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Text` [HideFromInspector] | string | ❌ | 입력한 내용 |
| `IsFocused` [ReadOnly] [HideFromInspector] | boolean | ❌ | 현재 포커싱 여부 |
| `AutoClear` | boolean | ❌ | 입력 완료 시 자동 초기화 여부 |

```lua
-- 입력값 가져오기
local userInput = textInput.Text

-- 포커스 확인
if textInput.IsFocused then
    print("사용자가 입력 중")
end

-- 제출 후 자동 초기화
textInput.AutoClear = true
```

#### 렌더링 레이어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `SortingLayer` [Sync] | string | ✅ | 렌더링 우선순위 레이어 |
| `OrderInLayer` [Sync] | int32 | ✅ | 같은 레이어 내 우선순위 |
| `OverrideSorting` [Sync] [ReadOnly] | boolean | ✅ | 레이어 값 임의 설정 가능 여부 |
| `IgnoreMapLayerCheck` [Sync] | boolean | ✅ | Map Layer 자동 치환 비활성화 |

### 2.2 Methods

| Method | 설명 |
|--------|------|
| `ActivateInputField()` | 입력 활성화 (포커스), 몇 프레임 후 IsFocused=true |
| `GetLocalizedPlaceHolder()` | 현재 언어의 PlaceHolder 텍스트 반환 |

```lua
-- 프로그래밍 방식으로 입력 활성화
textInput:ActivateInputField()

-- 현재 언어의 PlaceHolder 가져오기
local placeholder = textInput:GetLocalizedPlaceHolder()
```

### 2.3 Events

| Event | 발생 시점 |
|-------|----------|
| `TextInputValueChangeEvent` | 입력값 변경 시 (매 글자마다) |
| `TextInputEndEditEvent` | 입력 완료 (포커스 잃음) |
| `TextInputSubmitEvent` | Enter 키 입력 시 |
| `TextInputValueChangeEditorEvent` | 입력값 변경 (에디터 전용) |
| `TextInputEndEditEditorEvent` | 입력 완료 (에디터 전용) |
| `TextInputSubmitEditorEvent` | Enter 입력 (에디터 전용) |
| `OrderInLayerChangedEvent` | OrderInLayer 변경 |
| `SortingLayerChangedEvent` | SortingLayer 변경 |

### 2.4 사용 패턴

#### 패턴 1: 로그인 폼
```lua
Property:
[None] string UserId = ""
[None] string Password = ""
[None] TextInputComponent IdInput = EntityPath
[None] TextInputComponent PasswordInput = EntityPath

Method:
[client only]
void OnBeginPlay()
{
    self.IdInput.Text = ""
    self.IdInput.PlaceHolder = "아이디"
    
    self.PasswordInput.Text = ""
    self.PasswordInput.PlaceHolder = "비밀번호"
    self.PasswordInput.ContentType = InputContentType.Password
}

Event Handler:
[entity: self.IdInput]
HandleTextInputEndEditEvent(TextInputEndEditEvent event)
{
    self.UserId = event.text
    log("입력된 아이디: " .. self.UserId)
}

[entity: self.PasswordInput]
HandleTextInputEndEditEvent2(TextInputEndEditEvent event)
{
    self.Password = event.text
    log("입력된 비밀번호: " .. self.Password)
}
```

#### 패턴 2: 실시간 검증
```lua
Event Handler:
[self]
HandleTextInputValueChangeEvent(TextInputValueChangeEvent event)
{
    local text = event.text
    
    -- 길이 체크
    if string.len(text) < 3 then
        self.Entity.TextComponent.FontColor = Color.red
        self.Entity.TextComponent.Text = "최소 3글자 이상 입력하세요"
    else
        self.Entity.TextComponent.FontColor = Color.green
        self.Entity.TextComponent.Text = ""
    end
}
```

---

## 3. CameraComponent ⭐⭐⭐⭐⭐

> **용도**: 카메라 제어
> **필수도**: ★★★★★ (화면 연출 필수)
> **핵심**: Cinemachine-style DeadZone/SoftZone, Zoom, Shake

### 3.1 Properties

#### 카메라 영역
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `DeadZone` | Vector2 | ❌ | 카메라가 타겟을 유지하는 프레임 영역 (정규화 0~1) |
| `SoftZone` | Vector2 | ❌ | 타겟이 들어오면 카메라가 DeadZone으로 되돌리는 영역 (정규화 0~1) |
| `Damping` | Vector2 | ❌ | SoftZone 진입 시 카메라 반응 속도 (작을수록 빠름) |

```lua
-- 카메라 추적 설정
camera.DeadZone = Vector2(0.1, 0.1)  -- 중앙 10% 영역
camera.SoftZone = Vector2(0.3, 0.3)  -- 중앙 30% 영역
camera.Damping = Vector2(0.5, 0.5)   -- 보통 반응 속도
```

#### 카메라 오프셋
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `CameraOffset` | Vector2 | ❌ | 카메라 위치 오프셋 (월드 좌표) |
| `ScreenOffset` | Vector2 | ❌ | 타겟 기준 스크린 비율 (0~1, 0.5=중앙) |

```lua
-- 카메라를 위로 100px 이동
camera.CameraOffset = Vector2(0, 100)

-- 타겟을 화면 왼쪽에 배치
camera.ScreenOffset = Vector2(0.3, 0.5)
```

#### 카메라 경계
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `UseCustomBound` [Sync] | boolean | ✅ | true = LeftBottom/RightTop 사용, false = 맵 영역 사용 |
| `LeftBottom` [Sync] | Vector2 | ✅ | 카메라 제한 영역 좌하단 |
| `RightTop` [Sync] | Vector2 | ✅ | 카메라 제한 영역 우상단 |
| `ConfineCameraArea` | boolean | ❌ | true = 카메라 범위를 맵 발판 영역으로 제한 |

```lua
-- 커스텀 카메라 경계
camera.UseCustomBound = true
camera.LeftBottom = Vector2(-1000, -500)
camera.RightTop = Vector2(1000, 500)

-- 맵 발판 영역으로 제한
camera.ConfineCameraArea = true
```

#### 줌
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IsAllowZoomInOut` | boolean | ❌ | 줌 기능 사용 여부 |
| `ZoomRatio` | float | ❌ | 줌 비율 (백분율, 30~500) |
| `ZoomRatioMin` | float | ❌ | 줌 최소값 (≥30) |
| `ZoomRatioMax` | float | ❌ | 줌 최대값 (≤500) |

```lua
-- 줌 활성화
camera.IsAllowZoomInOut = true
camera.ZoomRatio = 100  -- 기본 크기
camera.ZoomRatioMin = 50
camera.ZoomRatioMax = 200
```

#### 기타
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `DutchAngle` | float | ❌ | 카메라 회전 값 (Z축 기울기) |
| `MaterialId` [Sync] | string | ✅ | 렌더러에 적용할 머티리얼 ID |

```lua
-- 카메라 회전 효과
camera.DutchAngle = 15  -- 15도 기울이기

-- 흑백 필터
camera.MaterialId = "grayscale_material"
```

### 3.2 Methods

| Method | 설명 |
|--------|------|
| `GetBound()` | (LeftBottom, RightTop) 반환 |
| `SetZoomTo(percent, duration, targetUserId)` [Client] | duration 초 동안 percent로 줌 |
| `ShakeCamera(intensity, duration, targetUserId)` [Client] | duration 초 동안 intensity 강도로 진동 |
| `ChangeMaterial(materialId)` | 머티리얼 교체 |

```lua
-- 카메라 경계 확인
local leftBottom, rightTop = camera:GetBound()

-- 4초 뒤 카메라 2배 확대 (2초 동안)
wait(4)
camera:SetZoomTo(200, 2)

-- 폭발 효과 (0.5초 진동)
camera:ShakeCamera(10, 0.5)

-- 세피아 필터 적용
camera:ChangeMaterial("sepia_material")
```

### 3.3 사용 패턴

#### 패턴 1: 보스 등장 연출
```lua
Method:
[server only]
void BossEntranceSequence()
{
    local camera = self.Entity.CameraComponent
    
    -- 1. 보스 위치로 카메라 이동
    camera.CameraOffset = Vector2(0, 300)
    
    -- 2. 줌 인
    camera:SetZoomTo(150, 2)
    
    -- 3. 진동 효과
    wait(2)
    camera:ShakeCamera(20, 1)
    
    -- 4. 원래 설정으로 복구
    wait(1)
    camera.CameraOffset = Vector2.zero
    camera:SetZoomTo(100, 2)
}
```

---

## 4. MapComponent ⭐⭐⭐⭐

> **용도**: 맵 전역 물리 설정
> **필수도**: ★★★★ (맵마다 물리 조정 필요)
> **핵심**: RigidbodyComponent의 Factor 값 보정

### 4.1 Properties

#### 이동 속도 보정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `WalkAccelerationFactor` | float | ❌ | 지상 가속도 배수 (최대 속도는 Rigidbody.WalkSpeed) |
| `WalkDrag` | float | ❌ | 지형 마찰력 (작을수록 미끄러짐) |
| `AirAccelerationXFactor` | float | ❌ | 공중 X축 속도 배수 |
| `AirDecelerationXFactor` | float | ❌ | 공중 X축 감속 배수 |

```lua
-- 얼음 맵 (미끄러움)
map.WalkDrag = 0.5
map.WalkAccelerationFactor = 0.7

-- 일반 맵
map.WalkDrag = 2.0
map.WalkAccelerationFactor = 1.0
```

#### 공중 이동 보정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `FallSpeedMaxXFactor` | float | ❌ | 공중 X축 최대 속도 배수 |
| `FallSpeedMaxYFactor` | float | ❌ | 공중 Y축 최대 속도 배수 (낙하) |
| `Gravity` | float | ❌ | 중력 배수 |

```lua
-- 달 맵 (낮은 중력)
map.Gravity = 0.5
map.FallSpeedMaxYFactor = 0.7

-- 지구 맵
map.Gravity = 1.0
map.FallSpeedMaxYFactor = 1.0
```

#### 맵 영역
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `UseCustomBound` [Sync] | boolean | ✅ | true = LeftBottom/RightTop 사용, false = 자동 생성 |
| `LeftBottom` [Sync] | Vector2 | ✅ | 맵 영역 좌하단 |
| `RightTop` [Sync] | Vector2 | ✅ | 맵 영역 우상단 |

```lua
-- 커스텀 맵 경계
map.UseCustomBound = true
map.LeftBottom = Vector2(-2000, -1000)
map.RightTop = Vector2(2000, 1000)
```

#### 맵 타입
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IsInstanceMap` | boolean | ❌ | true = 인스턴스 맵 (플레이어별 독립) |
| `IsDynamicMap` [ReadOnly] [HideFromInspector] | boolean | ❌ | true = 동적 생성 맵 |
| `TileMapMode` [ReadOnly] | TileMapMode | ❌ | 타일맵 모드 (None/UnityTile/MapleTile) |

### 4.2 Methods

| Method | 설명 |
|--------|------|
| `GetBound()` | (LeftBottom, RightTop) 반환 |

```lua
-- 맵 경계 확인
local leftBottom, rightTop = map:GetBound()
print("맵 크기: " .. (rightTop.x - leftBottom.x))
```

---

## 5. TileMapComponent ⭐⭐⭐⭐

> **용도**: 메이플 스타일 타일맵 렌더링 및 발판
> **필수도**: ★★★★ (메이플 스타일 맵 필수)
> **핵심**: CreateFoothold 활성화하여 발판 자동 생성

### 5.1 Properties

#### 발판 생성
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `CreateFoothold` [MakerOnly] | boolean | ❌ | true = 발판 생성, false = 비활성화 |
| `IncludeFinishFoothold` [MakerOnly] | boolean | ❌ | 발판 굽은 끝 부분 포함 여부 |
| `IsBlockVerticalLine` | boolean | ❌ | true = 세로 발판에 막힘 |

```lua
-- 발판 활성화
tilemap.CreateFoothold = true
tilemap.IncludeFinishFoothold = true
tilemap.IsBlockVerticalLine = true
```

#### 발판 속성
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `FootholdDrag` [ReadOnly] | float | ❌ | 발판 위 엔티티 마찰력 (클수록 빠르게 감속) |
| `FootholdForce` [ReadOnly] | float | ❌ | 발판 위 엔티티에 가해지는 힘 (양수=오른쪽, 음수=왼쪽) |
| `FootholdWalkSpeedFactor` [ReadOnly] | float | ❌ | 발판 위 이동 속도 계수 |

```lua
-- 컨베이어 벨트
tilemap.FootholdForce = 300  -- 오른쪽으로 밀림

-- 진흙 지형
tilemap.FootholdDrag = 5.0
tilemap.FootholdWalkSpeedFactor = 0.5
```

#### 렌더링
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Color` [Sync] | Color | ✅ | 타일맵 색상 |
| `TileSetRUID` | DataRef | ❌ | 사용할 타일셋 RUID |
| `SortingLayer` [ReadOnly] | string | ❌ | 렌더링 우선순위 레이어 |
| `OrderInLayer` [Sync] | int32 | ✅ | 같은 레이어 내 우선순위 |

```lua
-- 야간 효과 (어둡게)
tilemap.Color = Color(0.3, 0.3, 0.5, 1)

-- 타일셋 변경
tilemap.TileSetRUID = DataRef("new_tileset_ruid")
```

#### 기타
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `IsOddGridPosition` | boolean | ❌ | true = 그리드 기준점과 어긋나게 배치 |
| `PhysicsInteractable` [ReadOnly] | boolean | ❌ | true = PhysicRigidbody와 충돌 가능 |
| `IgnoreMapLayerCheck` | boolean | ❌ | Map Layer 자동 치환 비활성화 |
| `TileMapVersion` [ReadOnly] [HideFromInspector] | TileMapVersion | ❌ | 타일맵 생성 규칙 버전 |

### 5.2 Events

| Event | 발생 시점 |
|-------|----------|
| `OrderInLayerChangedEvent` | OrderInLayer 변경 시 |

### 5.3 사용 패턴

#### 패턴 1: 트리거로 타일맵 색상 변경
```lua
Method:
void SetColor(Color color)
{
    local tileMap = _EntityService:GetEntityByPath("/maps/map01/TileMap")
    tileMap.TileMapComponent.Color = color
}

Event Handler:
[self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    if event.TriggerBodyEntity.Name == "ColorTrigger" then
        self:SetColor(Color.red)
    end
}

[self]
HandleTriggerLeaveEvent(TriggerLeaveEvent event)
{
    self:SetColor(Color.white)
}
```

---

## 6. PlayerComponent ⭐⭐⭐⭐⭐

> **용도**: 플레이어 관리 및 제어
> **필수도**: ★★★★★ (플레이어 엔티티 필수)
> **핵심**: Hp, Respawn, MoveTo 함수

### 6.1 Properties

#### 체력
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Hp` [Sync] [HideFromInspector] | integer | ✅ | 현재 체력 |
| `MaxHp` [Sync] | integer | ✅ | 최대 체력 |

```lua
-- 체력 설정
player.MaxHp = 1000
player.Hp = 1000

-- 데미지 입히기
player.Hp = player.Hp - 100
if player.Hp <= 0 then
    player:ProcessDead()
end
```

#### 리스폰
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `RespawnDuration` [Sync] | float | ✅ | 죽은 후 리스폰까지 시간 (초) |
| `RespawnPosition` [Sync] [HideFromInspector] | Vector3 | ✅ | 리스폰 위치 (우선순위 1) |
| `RespawnTime` [Sync] [HideFromInspector] | number | ✅ | 리스폰 예정 시간 |

```lua
-- 리스폰 시간 설정
player.RespawnDuration = 5.0  -- 5초 후 리스폰

-- 체크포인트 설정
player.RespawnPosition = checkpointTransform.Position
```

#### 플레이어 정보
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `UserId` [Sync] [ReadOnly] [HideFromInspector] | string | ✅ | 플레이어 고유 식별자 (Client 함수 targetUserId에 사용) |
| `Nickname` [Sync] [HideFromInspector] | string | ✅ | 플레이어 닉네임 |
| `ProfileCode` [Sync] [ReadOnly] [HideFromInspector] | string | ✅ | 플레이어 프로필 코드 |

```lua
-- 플레이어 확인
print("플레이어: " .. player.Nickname)
print("UserId: " .. player.UserId)
```

#### PVP
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `PVPMode` [Sync] | boolean | ✅ | true = 플레이어끼리 공격 가능 |

```lua
-- PVP 활성화
player.PVPMode = true
```

### 6.2 Methods

#### 이동
| Method | 설명 |
|--------|------|
| `MoveToEntity(entityID)` [Server] [ScriptOverridable] | entityID 위치로 이동, 다른 맵이면 맵 이동 |
| `MoveToEntityByPath(worldPath)` [Server] [ScriptOverridable] | worldPath 엔티티 위치로 이동, 다른 맵이면 맵 이동 |
| `MoveToMapPosition(mapID, targetPosition)` [Server] [ScriptOverridable] | 특정 맵의 특정 위치로 이동 |
| `SetPosition(position)` | 로컬 좌표 설정 |
| `SetWorldPosition(worldPosition)` | 월드 좌표 설정 |

```lua
-- 다른 엔티티로 워프
player:MoveToEntity(portalEntity.Id)

-- 경로로 이동
player:MoveToEntityByPath("/maps/map02/SpawnPoint")

-- 특정 맵의 좌표로 이동
player:MoveToMapPosition("map02_id", Vector2(100, 200))

-- 현재 맵에서 위치 이동
player:SetWorldPosition(Vector3(500, 300, 0))
```

#### 생사
| Method | 설명 |
|--------|------|
| `IsDead()` | true = 플레이어가 죽은 상태 |
| `ProcessDead(targetUserId)` [Client] | 플레이어를 죽게 함 |
| `ProcessRevive(targetUserId)` [Client] | 플레이어를 부활시킴 |
| `Respawn()` [ScriptOverridable] | 리스폰 수행 (RespawnPosition → SpawnLocation → 맵 진입 시점) |

```lua
-- 즉시 죽이기
player:ProcessDead()

-- 죽었는지 확인
if player:IsDead() then
    print("플레이어가 죽었습니다")
end

-- 부활
player:ProcessRevive()

-- 리스폰
player:Respawn()
```

### 6.3 사용 패턴

#### 패턴 1: 체크포인트 시스템
```lua
Event Handler:
[server only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local trigger = event.TriggerBodyEntity
    local player = self.Entity.PlayerComponent
    
    if trigger.Name == "CheckPoint" then
        -- 리스폰 위치 저장
        player.RespawnPosition = trigger.TransformComponent.Position
        log("체크포인트 저장!")
    elseif trigger.Name == "DeathZone" then
        -- 즉시 죽이기
        player:ProcessDead()
    end
}
```

#### 패턴 2: 포탈 시스템
```lua
Event Handler:
[server only] [self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local trigger = event.TriggerBodyEntity
    local player = self.Entity.PlayerComponent
    
    if trigger.Name == "PortalToMap02" then
        -- 다음 맵으로 이동
        player:MoveToEntityByPath("/maps/map02/SpawnPoint")
    end
}
```

---

## 7. 컴포넌트 통합 패턴

### 7.1 UI 입력 시스템
```lua
-- ButtonComponent + TextInputComponent + TextComponent
Property:
[None] TextInputComponent IdInput = EntityPath
[None] TextInputComponent PwInput = EntityPath
[None] ButtonComponent LoginButton = EntityPath
[None] TextComponent StatusText = EntityPath

Event Handler:
[entity: self.LoginButton]
HandleButtonClickEvent(ButtonClickEvent event)
{
    local id = self.IdInput.Text
    local pw = self.PwInput.Text
    
    if id ~= "" and pw ~= "" then
        self.StatusText.Text = "로그인 중..."
        self.StatusText.FontColor = Color.green
        -- 서버에 로그인 요청
    else
        self.StatusText.Text = "아이디와 비밀번호를 입력하세요"
        self.StatusText.FontColor = Color.red
    end
}
```

### 7.2 카메라 + 플레이어 연출
```lua
-- CameraComponent + PlayerComponent
Method:
[server only]
void LevelClearSequence()
{
    local camera = self.PlayerCamera.CameraComponent
    local player = self.Entity.PlayerComponent
    
    -- 1. 플레이어 무적
    player.PVPMode = false
    
    -- 2. 줌 인
    camera:SetZoomTo(200, 2)
    
    -- 3. 진동
    wait(2)
    camera:ShakeCamera(15, 0.5)
    
    -- 4. 다음 스테이지로 이동
    wait(1)
    player:MoveToMapPosition("stage02", Vector2(0, 0))
}
```

---

## 8. 학습 체크리스트

### ButtonComponent
- [x] Transition (ColorTint/SpriteSwap) 설정
- [x] KeyCode로 키보드 바인딩
- [x] ButtonClickEvent, ButtonPressedEvent, ButtonStateChangeEvent
- [x] 홀드 상태에서 비주얼 변경 구현

### TextInputComponent
- [x] CharacterLimit, ContentType, LineType 설정
- [x] PlaceHolder 및 로컬라이제이션
- [x] ActivateInputField로 포커스 제어
- [x] TextInputValueChangeEvent (실시간) vs TextInputSubmitEvent (Enter)
- [x] 로그인 폼 구현

### CameraComponent
- [x] DeadZone, SoftZone, Damping 이해
- [x] CameraOffset vs ScreenOffset
- [x] UseCustomBound로 카메라 경계 설정
- [x] SetZoomTo, ShakeCamera 연출
- [x] ConfineCameraArea로 맵 제한

### MapComponent
- [x] WalkAccelerationFactor, WalkDrag로 물리 보정
- [x] Gravity, AirAccelerationXFactor 공중 제어
- [x] UseCustomBound로 맵 경계 설정
- [x] IsInstanceMap 이해

### TileMapComponent
- [x] CreateFoothold로 발판 생성
- [x] FootholdDrag, FootholdForce, FootholdWalkSpeedFactor
- [x] Color로 타일맵 색상 변경
- [x] TileSetRUID로 타일셋 교체

### PlayerComponent
- [x] Hp, MaxHp 체력 관리
- [x] RespawnDuration, RespawnPosition 리스폰 제어
- [x] MoveToEntity, MoveToMapPosition 이동
- [x] ProcessDead, ProcessRevive, Respawn 생사 제어
- [x] UserId 프로퍼티로 특정 플레이어 대상 함수 호출
- [x] PVPMode 이해

---

> **완료**: 6개 핵심 Components 마스터!  
> **총 12개 핵심 컴포넌트 학습 완료**  
> **다음**: Services, Enums, Events 추가 학습
