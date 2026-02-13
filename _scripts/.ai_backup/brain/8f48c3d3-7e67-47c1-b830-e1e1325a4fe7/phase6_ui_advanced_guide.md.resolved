# Phase 6: UI Advanced Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 1개  
> **카테고리**: UI Advanced (Slider)

---

## 📊 Phase 6 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **SliderComponent** | 17 | 0 | 3 | 슬라이더 UI (값 범위 설정) |
| **총계** | **17** | **0** | **3** | - |

---

## 🎚️ UI Slider System 개요

MapleStory Worlds의 슬라이더 시스템은 **SliderComponent**를 통해 최소/최대 범위 내에서 값을 설정하고 시각화합니다.

### 핵심 메커니즘
1. **SliderComponent**: 값 범위 설정, 핸들 드래그, 시각적 표현
2. **Sl�라이더 이벤트**: 값 변경 시 SliderValueChangedEvent 발생

### 슬라이더 흐름
```
SliderComponent
    ↓ MinValue, MaxValue 설정
    ↓ UseIntegerValue (정수/실수)
    ↓ UseHandle (핸들 사용 여부)
    ↓ 사용자 드래그 또는 Value 변경
    ↓ SliderValueChangedEvent 발생
    ↓ UI 업데이트
```

---

## 1. SliderComponent

### 📝 개요
- **용도**: 최소/최대 범위 내에서 값을 설정하고 그래픽으로 표현
- **필수도**: ⭐⭐⭐⭐ (슬라이더 UI 필요 시)
- **핵심 기능**: 값 범위 설정, 핸들 커스터마이징, 정수/실수 모드

### Properties (17개)

#### 값 설정
| Property | Type | 설명 |
|----------|------|------|
| `Value` | float | 현재 값 |
| `MinValue` | float | 최솟값 |
| `MaxValue` | float | 최댓값 |
| `UseIntegerValue` | boolean | 정수로만 사용 여부 (true: 정수, false: 실수) |

#### 핸들 설정
| Property | Type | 설명 |
|----------|------|------|
| `UseHandle` | boolean | 핸들 사용 여부 |
| `HandleSize` | Vector2 | 핸들 크기 |
| `HandleColor` | Color | 핸들 색상 |
| `HandleImageRUID` | DataRef | 핸들 이미지 RUID |
| `HandleAreaPadding` | RectOffset | 핸들 이동 가능 영역의 여유 공간 |

#### Fill Rect (값 표시 영역)
| Property | Type | 설명 |
|----------|------|------|
| `FillRectColor` | Color | 값 표시 영역 색상 |
| `FillRectImageRUID` | DataRef | 값 표시 영역 이미지 RUID |
| `FillRectPadding` | RectOffset | 값 표시 영역의 여유 공간 |

#### 방향 & 레이어
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `Direction` | SliderDirection | - | 최솟값→최댓값 방향 (LeftToRight, RightToLeft, BottomToTop, TopToBottom) |
| `SortingLayer` | string | ✅ | 렌더링 레이어 |
| `OrderInLayer` | int32 | ✅ | 같은 레이어 내 우선순위 (클수록 앞) |
| `OverrideSorting` | boolean | ✅ ReadOnly | SortingLayer/OrderInLayer 임의 설정 여부 |
| `IgnoreMapLayerCheck` | boolean | ✅ | Map Layer 자동 치환 비활성화 |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (0개)

**모든 Methods는 Component에서 상속:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (3개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `SliderValueChangedEvent` | Slider 값이 변경되었을 때 | Client |
| `OrderInLayerChangedEvent` | OrderInLayer가 변경되었을 때 | Client |
| `SortingLayerChangedEvent` | SortingLayer가 변경되었을 때 | Client |

### 사용 패턴

#### 기본 슬라이더 (0~100)
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    -- 값 범위 설정
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 100
    slider.Value = 50
    
    -- 핸들 설정
    slider.UseHandle = true
    slider.HandleSize = Vector2(20, 20)
    slider.HandleColor = Color(1, 1, 1, 1)  -- 흰색
    
    -- Fill Rect 설정
    slider.FillRectColor = Color(0, 1, 0, 1)  -- 녹색
    slider.Direction = SliderDirection.LeftToRight
}
```

#### 슬라이더 값 표시
```lua
-- SliderComponent 예제 (API 문서에서)
[None]
Entity TextEntity = EntityPath
  
[client only]
void OnBeginPlay()
{
    local sliderComp = self.Entity.SliderComponent
    if not sliderComp then
        return
    end
    
    sliderComp.UseIntegerValue = true
    sliderComp.MaxValue = 100
    sliderComp.MinValue = 0
    sliderComp.Value = 0
    
    self:SetSliderText(sliderComp.Value)
}
  
void SetSliderText(number sliderValue)
{
    if not self.TextEntity then
        return
    end
  
    local textComp = self.TextEntity.TextComponent
    if not textComp then
        return
    end
  
    textComp.Text = string.format("%d", sliderValue)
}
  
[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    local Value = event.Value
    self:SetSliderText(Value)
}
```

---

## 🎯 Phase 6 핵심 패턴

### 1. 볼륨 조절 슬라이더
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    -- 볼륨 범위: 0.0 ~ 1.0
    slider.UseIntegerValue = false
    slider.MinValue = 0.0
    slider.MaxValue = 1.0
    slider.Value = 0.5
    
    slider.UseHandle = true
    slider.Direction = SliderDirection.LeftToRight
}

[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    local volume = event.Value
    
    -- 사운드 볼륨 적용
    local sound = _SoundService:GetBGMComponent()
    if sound then
        sound.Volume = volume
    end
}
```

### 2. 체력 바 (핸들 없음)
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    -- 체력 범위: 0 ~ 100
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 100
    slider.Value = 100
    
    -- 핸들 비활성화 (읽기 전용)
    slider.UseHandle = false
    
    -- 빨간색 체력 바
    slider.FillRectColor = Color(1, 0, 0, 1)
    slider.Direction = SliderDirection.LeftToRight
}

[server only]
void TakeDamage(number damage)
{
    local slider = self.Entity.SliderComponent
    slider.Value = math.max(0, slider.Value - damage)
}
```

### 3. 경험치 바
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 1000  -- 레벨업에 필요한 경험치
    slider.Value = 0
    
    slider.UseHandle = false
    slider.FillRectColor = Color(1, 1, 0, 1)  -- 노란색
    slider.Direction = SliderDirection.LeftToRight
}

[server only]
void GainExp(number exp)
{
    local slider = self.Entity.SliderComponent
    slider.Value = slider.Value + exp
    
    -- 레벨업 체크
    if slider.Value >= slider.MaxValue then
        self:LevelUp()
        slider.Value = 0  -- 경험치 초기화
    end
}
```

### 4. 밝기 조절 슬라이더
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    -- 밝기: 0% ~ 200%
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 200
    slider.Value = 100  -- 기본 100%
    
    slider.UseHandle = true
}

[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    local brightness = event.Value / 100  -- 0.0 ~ 2.0
    
    -- 화면 밝기 적용
    _CameraService:SetBrightness(brightness)
}
```

### 5. 수직 슬라이더
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 100
    slider.Value = 50
    
    -- 아래에서 위로
    slider.Direction = SliderDirection.BottomToTop
    slider.UseHandle = true
}
```

### 6. 커스텀 핸들 & Fill Rect
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    slider.UseIntegerValue = true
    slider.MinValue = 0
    slider.MaxValue = 100
    slider.Value = 50
    
    -- 커스텀 핸들 이미지
    slider.UseHandle = true
    slider.HandleImageRUID = "custom_handle_ruid"
    slider.HandleSize = Vector2(30, 30)
    
    -- 커스텀 Fill Rect 이미지
    slider.FillRectImageRUID = "custom_fill_ruid"
    
    -- 패딩 설정
    slider.HandleAreaPadding = RectOffset(10, 10, 5, 5)
    slider.FillRectPadding = RectOffset(5, 5, 5, 5)
}
```

### 7. 퍼센트 표시
```lua
[None]
Entity PercentTextEntity = EntityPath

[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    slider.UseIntegerValue = false
    slider.MinValue = 0
    slider.MaxValue = 1
    slider.Value = 0.5
    
    self:UpdatePercentText()
}

void UpdatePercentText()
{
    local slider = self.Entity.SliderComponent
    local percent = (slider.Value / slider.MaxValue) * 100
    
    local textComp = self.PercentTextEntity.TextComponent
    if textComp then
        textComp.Text = string.format("%.1f%%", percent)
    end
}

[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    self:UpdatePercentText()
}
```

### 8. 범위 제한 슬라이더
```lua
[client only]
void OnBeginPlay()
{
    local slider = self.Entity.SliderComponent
    
    -- 10 ~ 90 범위로 제한
    slider.UseIntegerValue = true
    slider.MinValue = 10
    slider.MaxValue = 90
    slider.Value = 50
    
    slider.UseHandle = true
}

[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    local value = event.Value
    
    -- 값 검증
    if value < 10 or value > 90 then
        log("Value out of range!")
    else
        log("Valid value: " .. value)
    end
}
```

---

## 🔗 관련 컴포넌트 & 타입

### 관련 컴포넌트
- **TextComponent**: 슬라이더 값 표시
- **ImageComponent**: 커스텀 슬라이더 배경

### 관련 타입
- **SliderDirection**: LeftToRight, RightToLeft, BottomToTop, TopToBottom
- **Vector2**: 핸들 크기
- **Color**: 색상 설정
- **RectOffset**: 패딩 설정 (left, right, top, bottom)

### 관련 이벤트
- **SliderValueChangedEvent**: 슬라이더 값 변경 시
  - `Value`: 변경된 값

---

## 💡 Best Practices

### 1. 정수 vs 실수
```lua
-- 정수 모드 (레벨, 개수 등)
slider.UseIntegerValue = true
slider.MinValue = 1
slider.MaxValue = 100

-- 실수 모드 (볼륨, 밝기 등)
slider.UseIntegerValue = false
slider.MinValue = 0.0
slider.MaxValue = 1.0
```

### 2. 핸들 사용 여부
```lua
-- 사용자 조작 가능 (설정 UI)
slider.UseHandle = true

-- 읽기 전용 (체력 바, 경험치 바)
slider.UseHandle = false
```

### 3. 방향 선택
```lua
-- 수평 슬라이더
slider.Direction = SliderDirection.LeftToRight  -- 일반적
slider.Direction = SliderDirection.RightToLeft  -- 특수 케이스

-- 수직 슬라이더
slider.Direction = SliderDirection.BottomToTop  -- 일반적
slider.Direction = SliderDirection.TopToBottom  -- 특수 케이스
```

### 4. 값 범위 설정
```lua
-- 항상 MinValue < MaxValue
slider.MinValue = 0
slider.MaxValue = 100

-- 초기값은 범위 내로
slider.Value = 50  -- MinValue <= Value <= MaxValue
```

### 5. 이벤트 처리
```lua
-- SliderValueChangedEvent는 Client에서 발생
[self]
HandleSliderValueChangedEvent(SliderValueChangedEvent event)
{
    local newValue = event.Value
    
    -- 값 변경 처리
    self:OnValueChanged(newValue)
}
```

---

## 📋 다음 단계

Phase 6 완료! 다음은:
- **Phase 7**: Physics Components (4개) - RigidbodyComponent, ColliderComponent 등
- **Phase 8**: Camera & Rendering Components (3개) - CameraComponent 등

---

> **학습 완료**: 2026-02-08  
> **참고**: ScrollViewComponent, ProgressBarComponent, ToggleComponent, DropdownComponent는 API 문서가 존재하지 않아 제외되었습니다.  
> **다음 목표**: Phase 7 - Physics Components 학습
