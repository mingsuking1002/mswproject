# 메이플스토리 월드 엔진 마스터 가이드 v5.0

> **The Bible of MSW** - 메이플스토리 월드 엔진의 모든 것을 집대성한 기술 백서입니다.
> **Last Updated**: 2026-02-06 | **Sources**: 62+ official documentation | **Coverage**: API, Guides, Patterns

---

## 1. 핵심 아키텍처

### 1.1 Entity-Component-Property (ECP) 모델
MSW의 모든 객체는 **Entity → Component → Property** 구조를 따릅니다.

| 개념 | 설명 | 비유 |
|------|------|------|
| **Entity** | 게임 내 존재하는 모든 객체 (눈에 보이는 것 + 로직) | 피자 한 판 |
| **Component** | Entity의 기능을 결정하는 모듈 | 토마토, 도우, 치즈 |
| **Property** | Component의 세부 설정값 | 치즈의 "양", "종류" |

```lua
-- Entity 접근
local myEntity = self.Entity
-- Component 접근
local transform = myEntity.TransformComponent
-- Property 접근
local position = transform.Position
```

### 1.2 Workspace 구조
| 폴더 | 설명 |
|------|------|
| `DefaultPlayer` | 플레이어 아바타 템플릿. NativeModel의 Player 참조 |
| `BaseEnvironment` | 변경 불가한 네이티브 스크립트/모델 |
| `NativeScripts` | Component, Service, Logic, Event, Misc |
| `NativeModel` | 복제/확장 가능한 기본 모델들 |
| `MyDesk` | 크리에이터 작업 영역. 모든 커스텀 리소스 저장 |

### 1.3 Hierarchy 구조 (계층)
```
World
├── common    (전역 룰, 게임 시스템)
├── maps      (맵별 엔티티)
│   └── map01, map02...
└── ui        (UI 엔티티)
    ├── DefaultGroup
    ├── PopupGroup
    └── ToastGroup
```

> **핵심**: 부모 Transform 변경 시 자식도 영향받음 (단방향: 부모→자식)

---

## 2. 서버-클라이언트 아키텍처

### 2.1 실행 공간 (Execution Space)
| 실행 제어 | 서버에서 호출 시 | 클라이언트에서 호출 시 |
|-----------|------------------|------------------------|
| `없음` | 서버에서 실행 | 클라이언트에서 실행 |
| `[client]` | 클라이언트로 전송 후 실행 | 클라이언트에서 실행 |
| `[client only]` | **무시됨** | 클라이언트에서 실행 |
| `[server]` | 서버에서 실행 | 서버로 전송 후 실행 |
| `[server only]` | 서버에서 실행 | **무시됨** |
| `[multicast]` | 서버 실행 후 모든 클라이언트로 전송 | **무시됨** |

### 2.2 특정 클라이언트에만 응답 보내기
```lua
[server only]
void HandleRequest(string userId)
{
    -- 처리 로직...
    self:ResponseToClient(result, userId)  -- 마지막 매개변수가 userId
}

[client]
void ResponseToClient(string result)
{
    -- 요청한 클라이언트만 이 함수를 실행
}
```

### 2.3 프로퍼티 동기화 (Sync)
- **방향**: 서버 → 클라이언트 (단방향)
- **설정**: `[Sync]` 또는 `[None]`
- **OnSyncProperty**: 동기화 완료 시점에 클라이언트에서 호출

```lua
Property:
[Sync]
number HP = 100

Method:
[Client Only]
void OnSyncProperty(string name, any value)
{
    if name == "HP" then
        -- HP UI 업데이트
    end
}
```

| 타입 | 동기화 가능 |
|------|-------------|
| string, number, integer, boolean | ✅ |
| Vector2, Vector3, Vector4, Color | ✅ |
| Entity, Component, EntityRef, ComponentRef | ✅ |
| SyncTable<v>, SyncTable<k,v> | ✅ |
| table, any | ❌ |

---

## 3. 생명주기 (Lifecycle)

### 3.1 이벤트 함수 호출 순서
```
OnInitialize  →  OnBeginPlay  →  OnUpdate (매 프레임)  →  OnEndPlay  →  OnDestroy
                                      ↓
                              OnMapEnter / OnMapLeave (맵 이동 시)
```

| 함수 | 호출 시점 | 주의사항 |
|------|-----------|----------|
| `OnInitialize` | 엔티티/컴포넌트 생성 직후 | 다른 엔티티 참조 시 nil 가능 |
| `OnBeginPlay` | 모든 엔티티 생성 완료 후 | 다른 엔티티 참조 보장됨 |
| `OnUpdate(delta)` | 매 프레임 | Wait() 사용 금지! |
| `OnMapEnter(map)` | 맵 진입/생성 시 | 맵 이동마다 호출 |
| `OnMapLeave(map)` | 맵 퇴장/제거 시 | - |
| `OnEndPlay` | 제거 시작 | 엔티티 아직 유효 |
| `OnDestroy` | 제거 완료 | 이후 엔티티 무효 |
| `OnSyncProperty` | 프로퍼티 동기화 완료 시 | Client Only |

### 3.2 초기화 순서 주의
```lua
-- ComponentA
[server only]
void OnInitialize() { self.Value = "Ready" }

-- ComponentB (다른 컴포넌트)
[Server Only]
void OnBeginPlay()
{
    local a = self.Entity.ComponentA
    log(a.Value)  -- ✅ "Ready" 보장됨 (OnInitialize는 OnBeginPlay 전에 완료)
}
```

---

## 4. 프로퍼티 시스템

### 4.1 프로퍼티 타입
| 타입 | 설명 | 동기화 |
|------|------|--------|
| `string` | 문자열 | ✅ |
| `number` | 64비트 실수 | ✅ |
| `integer` | 64비트 정수 | ✅ |
| `boolean` | true/false | ✅ |
| `table` | Lua 테이블 (참조형) | ❌ |
| `SyncTable<v>` | 동기화 가능 배열 | ✅ |
| `SyncTable<k,v>` | 동기화 가능 딕셔너리 | ✅ |
| `Vector2/3/4` | 벡터 (참조형) | ✅ |
| `Entity` | 엔티티 참조 (맵 이동 시 끊김) | ✅ |
| `EntityRef` | 엔티티 키 참조 (맵 이동 후 복구) | ✅ |
| `Component` / `ComponentRef` | 컴포넌트 참조 | ✅ |
| `any` | 모든 타입 (동기화 불가) | ❌ |

### 4.2 _T 프로퍼티 (임시 저장소)
동기화 없이 컴포넌트 내부에서 값을 유지해야 할 때 사용:
```lua
void OnUpdate(delta)
{
    if self._T.timer == nil then self._T.timer = 0 end
    self._T.timer = self._T.timer + delta
    if self._T.timer >= 3 then
        self._T.timer = 0
        log("3초 경과!")
    end
}
```

---

## 5. 모델 시스템

### 5.1 모델이란?
**모델** = 엔티티의 컴포넌트 + 프로퍼티 정보를 저장한 **틀(도장)**

### 5.2 모델화 (Create Model From Entity)
1. Scene에서 엔티티 완성
2. 우클릭 → **Create Model From Entity**
3. MyDesk에 모델 생성됨
4. 이후 해당 모델로 무한 복제 가능

### 5.3 모델 활용
```lua
-- 코드로 모델 스폰
local entity = _SpawnService:SpawnByModelId("model_12345", spawnPosition, self.Entity)
```

---

## 6. 맵 레이어 시스템

### 6.1 레이어 우선순위
1. **Map Layer** (SpriteRendererComponent.SortingLayer)
2. **OrderInLayer** 프로퍼티
3. **Position.Z** 값

### 6.2 기본 OrderInLayer 값
| OrderInLayer | 대상 |
|--------------|------|
| 0 | 오브젝트 |
| 1 | 타일 |
| 2 | 몬스터, NPC, 발판, 사다리, 포탈, 트랩, 아이템 |
| 3 | 타 플레이어 아바타 |
| 4 | 내 아바타 |

> ⚠️ 3 이상 값 사용 시 아바타가 가려질 수 있음

### 6.3 플레이어와 레이어
- 플레이어는 **밟고 있는 발판의 레이어**에 귀속됨
- 맵 이동/점프 시 레이어가 동적으로 변경됨

---

## 7. DataStorage 심화

### 7.1 DataStorage 종류
| 종류 | 범위 | 값 타입 | 특징 |
|------|------|---------|------|
| `GlobalDataStorage` | 월드 전용 | string | 이름으로 여러 개 생성 가능 |
| `UserDataStorage` | 유저별 | string | userId로 접근 |
| `CreatorDataStorage` | 크리에이터 전체 | string | 월드 간 공유 가능 |
| `SortableDataStorage` | 월드 전용 | integer | 정렬/증가 함수 지원 |

### 7.2 기본 사용법
```lua
[server only]
void SaveData()
{
    local ds = _DataStorageService:GetGlobalDataStorage("myData")
    ds:SetAndWait("key", "value")
}

void LoadData()
{
    local ds = _DataStorageService:GetGlobalDataStorage("myData")
    local errorCode, value = ds:GetAndWait("key")
}
```

### 7.3 Batch 처리 (성능 최적화)
```lua
local ds = _DataStorageService:GetGlobalDataStorage("batch")
local keyValues = {
    ["stat_hp"] = "100",
    ["stat_mp"] = "50",
    ["stat_level"] = "10"
}
local errorCode, successKeys = ds:BatchSetAndWait(keyValues)
```

### 7.4 ErrorCode
| Code | 이름 | 설명 |
|------|------|------|
| 0 | Ok | 성공 |
| 1000004 | TimedOut | 시간 초과 |
| 1000005 | ResourceExhausted | 호출 한도 초과 |
| 1000006 | PartialFailure | 일부 실패 |

### 7.5 Version & Tag
```lua
local keyInfo = DataStorageKeyInfo()
keyInfo.Key = "playerData"
keyInfo.Version = "v2"
keyInfo.Tag = "character"
ds:SetByInfoAndWait(keyInfo, jsonData)
```

---

## 8. 월드 인스턴스

### 8.1 개념
- **월드 인스턴스** = 메이커에서 만든 월드의 실제 실행 객체
- 최대 플레이어 수 도달 시 새 인스턴스 생성
- 모든 유저 퇴장 시 인스턴스 파괴

### 8.2 은퇴 준비 (Retirement)
- 일정 시간 경과 후 새 유저 입장 차단
- 기존 유저만으로 운영 후 자연 파괴

### 8.3 인스턴스 간 통신
```lua
-- RoomService, WorldInstanceService 활용
_RoomService:...
_WorldInstanceService:...
```

---

## 9. 최적화 패턴

### 9.1 FastVector3 (Effective MSW)
엔진 Vector3 호출 비용을 제거한 순수 Lua 테이블:
```lua
local FastVector3 = {x = 0, y = 0, z = 0}
function FastVector3.new(x, y, z)
    return {x = x or 0, y = y or 0, z = z or 0}
end
```
> 탄막 게임 등 수천 번 반복 연산 시 사용

### 9.2 DataStorage 절약
- **JSON 직렬화**: 여러 값을 하나로 묶어 저장
- **Batch 처리**: `BatchSetAndWait()` 사용
- **퇴장 시 저장**: `OnMapLeave` 또는 `UserLeave` 이벤트 활용

### 9.3 네트워크 최적화
- `OnUpdate`에서 RPC 호출 금지
- `ResponseToClient(userId)`로 특정 클라이언트만 응답
- 프로퍼티 동기화 최소화 (`[None]` 활용)

---

## 10. 스크립트 작성

### 10.1 함수 선언
```lua
void MyFunction(string param1, number param2)
{
    -- 코드 작성
    return result
}
```

### 10.2 다른 컴포넌트 접근
```lua
-- 같은 엔티티의 다른 컴포넌트
local otherComp = self.Entity.OtherComponent

-- 다른 엔티티의 컴포넌트
local entity = _EntityService:GetEntityByPath("/maps/map01/npc")
local comp = entity.MyComponent
```

### 10.3 Service 호출
```lua
local users = _UserService.UserEntities
local entity = _EntityService:GetEntityByPath("/maps/map01")
local ds = _DataStorageService:GetGlobalDataStorage("name")
```

---

## 11. Lua 기초 (MSW 특화)

### 11.1 변수
```lua
local a = 10           -- 지역 변수 (권장)
self.PropName = "val"  -- Property (동기화 가능)
self._T.temp = 0       -- 임시 저장소 (동기화 불가)
```

### 11.2 테이블
```lua
-- 배열 (인덱스 1부터 시작!)
local arr = {"A", "B", "C"}
log(arr[1])  -- "A"

-- 딕셔너리
local dict = {name = "Tom", age = 20}
log(dict.name)  -- "Tom"
```

### 11.3 반복문
```lua
-- 배열 순회
for i, v in ipairs(array) do ... end

-- 딕셔너리 순회
for k, v in pairs(dict) do ... end
```

### 11.4 문자열 연결
```lua
local msg = "Hello " .. "World"  -- ".." 연산자 사용
```

---

## 12. 트러블슈팅

### 12.1 중복 컴포넌트 오류
- **원인**: 부모/자식 모델에 같은 컴포넌트 존재 (`Ambiguous Call`)
- **해결**: 콘솔 로그 확인 → 중복 컴포넌트 제거

### 12.2 API Reference 배지 해석
| 배지 | 의미 |
|------|------|
| `Sync` | 서버→클라이언트 자동 동기화 (트래픽 주의) |
| `Yield` | 비동기 대기 가능 (스크립트 멈춤) |
| `Static` | `.`으로 호출 (`:` 아님) |
| `ServerOnly` | 서버에서만 실행 가능 |
| `ClientOnly` | 클라이언트에서만 실행 가능 |

### 12.3 로그 접두사
| 접두사 | 의미 |
|--------|------|
| `LIA` | Info - 단순 정보 |
| `LWA` | Warning - 권장하지 않는 사용법 |
| `LEA` | Error - 치명적 오류, 실행 불가 |

---

## 13. 참고 문서 링크

| 주제 | postId |
|------|--------|
| Entity, Component, Property | 54 |
| 모델 | 55 |
| 프로퍼티 | 205 |
| 프로퍼티 동기화 | 208 |
| 실행 제어 | 210 |
| 함수 | 172 |
| 기본 이벤트 함수 | 163 |
| DataStorage 활용 | 692 |
| 월드 인스턴스 | 984 |
| 맵 레이어 | 53 |
| Lua 기초 | 822 |
| Effective MSW 1 | 559 |
| Effective MSW 2 | 560 |

---

> **문서 버전**: v5.0 (2026-02-06)
> **최종 업데이트**: 62+ 문서 통합 완료

---

## 14. UI 컴포넌트 시스템

### 14.1 TextInputComponent (postId=360)
문자열 입력을 받아 TextComponent에 전달하는 컴포넌트

```lua
Property:
[None] string Text           -- 입력된 내용
[None] string PlaceHolder    -- 기본 문구
[None] int CharacterLimit     -- 최대 글자 수
[None] InputContentType ContentType  -- 입력 타입
[None] boolean AutoClear      -- 완료 시 자동 초기화

Method:
void ActivateInputField()    -- 입력 활성화
string GetLocalizedPlaceHolder()  -- 로컬라이제이션 적용 텍스트
```

**주요 이벤트**:
- `TextInputEndEditEvent`: 값 변경 완료
- `TextInputSubmitEvent`: Enter 키 입력
- `TextInputValueChangeEvent`: 값 변경 중

### 14.2 ButtonComponent 이벤트
- `ButtonClickEvent`: 버튼 클릭 (서버/클라이언트)
- `ButtonClickEditorEvent`: 에디터에서 버튼 클릭
- `ButtonStateChangeEvent`: 버튼 상태 변경

---

## 15. 인스턴스 룸 시스템 (Instance Room)

### 15.1 개념 구조
```
World Instance
├── Static Room (정적 룸)
│   └── Static Maps (정적 맵들)
└── Instance Rooms (인스턴스 룸들)
    └── Instance Maps (인스턴스 맵들)
```

### 15.2 특징
| 구분 | 정적 룸/맵 | 인스턴스 룸/맵 |
|------|-----------|----------------|
| **생성 시점** | 월드 시작 시 자동 생성 | 런타임에 동적 생성 |
| **이동** | 자유롭게 이동 가능 | RoomService 통해서만 |
| **데이터 접근** | 공유 불가 | DataStorage는 공유 |
| **식별** | 이름으로 | Key로 구분 |

### 15.3 RoomService API (postId=540)
```lua
-- 인스턴스 룸 생성/가져오기
local room = _RoomService:GetOrCreateInstanceRoom(key)

-- 유저를 인스턴스 룸으로 이동
_RoomService:MoveUsersToInstanceRoom(instanceKey, userNames)

-- 유저를 정적 룸으로 복귀
_RoomService:MoveUsersToStaticRoom(userNames, mapName)
```

**주의사항**:
- MapComponent의 `InstanceMap = true` 설정 필요
- 인스턴스 룸 간 직접 이동 불가 (정적 룸 경유)
- Service/Logic은 공간마다 별도 존재

---

## 16. 물리 시스템 (Physics)

### 16.1 BodyType (postId=850)
| 타입 | 질량 | 움직임 | 충돌 대상 |
|------|------|--------|-----------|
| `Static` | 무한대 | 물리로 안움직임 | Dynamic만 |
| `Kinematic` | 무한대 | 속도로 움직임 | Dynamic |
| `Dynamic` | 유한 | 물리 엔진 제어 | 모든 타입 |

### 16.2 PrismaticJoint (postId=800)
두 Entity를 특정 축을 따라서만 상대적 이동하도록 연결

```lua
Property:
Vector2 LocalAnchorA/B        -- 앵커 위치
Vector2 LocalAxis             -- 제한 축
float LowerTranslation        -- 최소 이동 범위
float UpperTranslation        -- 최대 이동 범위
boolean MotorEnable           -- 모터 기능
float MotorSpeed              -- 목표 속도
float MaxMotorForce           -- 최대 힘
EntityRef TargetEntityRef     -- 연결할 Entity
```

### 16.3 PhysicsColliderComponent (postId=775)
물리 충돌 감지 컴포넌트
- TriggerComponent와 함께 사용
- `TriggerEnterEvent`, `TriggerExitEvent` 발생
- Rigidbody와 연계하여 물리 반응

---

## 17. 메이플 이동 시스템 (postId=750)

### 17.1 RigidbodyComponent 이동 특성
```
발판 위 이동:
- 현재 밟은 발판의 이동 규칙 적용
- 발판 벗어나면 관계 해제
- 중력 영향으로 하강
- 올라갈 때는 발판 통과 가능
```

### 17.2 LayerSettingType
```lua
All          -- 메이플 방식: 발판/사다리 SortingLayer 따름
Climbable    -- 마지막 탄 사다리 Layer 유지
None         -- 크리에이터 설정값 유지
```

### 17.3 수직선 지형 제어
```lua
-- RigidbodyComponent
IsBlockVerticalLine = true   -- 모든 수직선 막기

-- TileMapComponent (특정 레이어만)
IsBlockVerticalLine = true   -- 해당 레이어만 수직선 막기
```

### 17.4 타일맵 모드 (TileMapMode, postId=900)
| 모드 | 시점 | 용도 |
|------|------|------|
| `MapleTile` | 횡스크롤 | 메이플스토리식 |
| `RectTile` | 탑다운 | 평면 격자 |
| `SideViewRectTile` | 횡스크롤 | 격자 플랫포머 |

---

## 18. TweenLogic - 애니메이션 시스템 (postId=700)

### 18.1 핵심 함수
```lua
-- 간단한 이동
_TweenLogic:MoveTo(entity, destination, duration, easeType)
_TweenLogic:MoveOffset(entity, offset, duration, easeType)

-- 회전
_TweenLogic:RotateTo(entity, angle, duration, easeType)

-- 스케일
_TweenLogic:ScaleTo(entity, targetScale, duration, easeType)

-- 커스텀 Tween
local tweener = _TweenLogic:MakeTween(
    startValue, endValue, duration, easeType,
    function(value) self.Entity.TransformComponent.Position = value end
)
tweener:Play()

-- 네이티브 컴포넌트 최적화 (성능 우수)
local tweener = _TweenLogic:MakeNativeTween(
    1, 0, 3, EaseType.Linear,
    self.Entity.SpriteRendererComponent, "SetAlpha"
)
```

### 18.2 TweenFloatingComponent (postId=380)
Entity가 위아래로 왕복 이동

```lua
Property:
float Amplitude        -- 최저~최고점 거리
float OneCycleTime     -- 주기 시간 (초)
EaseType TweenType     -- 움직임 효과
```

---

## 19. 머티리얼 시스템 (Material)

### 19.1 MaterialService (postId=950)
런타임 머티리얼 제어

```lua
-- 머티리얼 프로퍼티 변경
local properties = {["PixelateSize"] = 32}
_MaterialService:ChangeMaterialProperty("material://Entry ID", properties)

-- SpriteRendererComponent에서 변경
self.Entity.SpriteRendererComponent:ChangeMaterial("material://Entry ID")
```

### 19.2 활용 패턴
```lua
-- 거리에 따른 블러 효과
[client only]
void OnUpdate(number delta)
{
    local dist = Vector2.Distance(playerPos, selfPos)
    local changeValue = {["PixelateSize"] = dist * 16 + 16}
    _MaterialService:ChangeMaterialProperty(materialId, changeValue)
}
```

---

## 20. Effective 패턴 및 주의사항 (postId=560)

### 20.1 실행 제어 제약사항
**전송 불가능한 매개변수 타입**:
- `any` 타입 (전송 형태 불명확)
- 함수 타입
- `Failed to convert argument` 오류 → 타입 변경 필요

### 20.2 OnBeginPlay 함수 주의사항
```lua
-- ❌ 잘못된 사용: 서버 OnBeginPlay에서 클라이언트 함수 호출
[server only]
void OnBeginPlay() {
    self:SendToClient()  -- 클라이언트가 아직 접속 전!
}

-- ✅ 올바른 사용: 클라이언트가 서버에 준비 완료 신호
[client only]
void OnBeginPlay() {
    self:NotifyServerReady()  -- 서버에 알림
}

[server]
void NotifyServerReady() {
    -- 이제 데이터 전송 가능
}
```

### 20.3 Localized Entity 제약
**UI Entity는 서버 실행 제어 함수 사용 불가**:
- UI는 각 클라이언트에만 존재 (서버에 없음)
- World Entity를 경유하여 서버와 통신

### 20.4 LocalPlayer 처리
```lua
-- ❌ 잘못된 사용
[service: InputService]
HandleKeyDownEvent(KeyDownEvent event) {
    self:UseSkill()  -- 모든 플레이어가 스킬 사용!
}

-- ✅ 올바른 사용
[service: InputService]
HandleKeyDownEvent(KeyDownEvent event) {
    if self.Entity ~= _UserService.LocalPlayer then
        return  -- 내 캐릭터만 처리
    end
    self:UseSkill()
}
```

---

## 21. 추가 컴포넌트 및 API

### 21.1 SpawnLocationComponent (postId=370)
SpawnLocation Model 전용 컴포넌트

### 21.2 Translator (postId=460)
LocaleDataSet 번역 조회 시스템
```lua
Property:
string LocaleId  -- 언어 코드 (readonly)

Method:
string GetText(string key)  -- 번역 텍스트 가져오기
string GetTextFormat(string key, any... args)  -- 포맷 적용
```

### 21.3 DefaultUserEnterLeaveLogic (postId=650)
유저 입장/퇴장 관련 기능

```lua
Property:
string PlayerUri   -- 플레이어 Model ID
string StartPoint  -- 시작 맵 이름
```

### 21.4 ItemService (postId=310)
```lua
void ChangeOwner(Item item, InventoryComponent owner)
Item CreateItem(string itemId, number count)
Item GetItemByGUID(string guid)
table GetMODItemsByOwner(InventoryComponent owner)
void RemoveItem(Item item)
```

### 21.5 AttackComponent (postId=340)
```lua
Method:
void Attack(Entity target)
void AttackFast(Entity target)
number CalcDamage(Entity attacker, Entity target)
boolean IsAttackTarget(Entity entity)

Event:
AttackEvent  -- 공격 발생 시
```

### 21.6 기타 Enum 및 타입
- `KeyboardKey` (postId=875): 키보드 입력 키 열거형
- `PolygonShape` (postId=925): 다각형 충돌 형태
- `SoundPlayState` (postId=1125): Stop, Play, Pause
- `ReadOnlyDictionary<K,V>` (postId=1025): 읽기 전용 해시 테이블

---

## 22. 참고 문서 링크 (확장)

### 22.1 아키텍처 및 기초
| 주제 | postId |
|------|--------|
| Entity, Component, Property | 54 |
| 모델 | 55 |
| Workspace 구조 | 162 |
| Hierarchy 구조 | 162 |

### 22.2 서버-클라이언트
| 주제 | postId |
|------|--------|
| 실행 제어 | 210 |
| 프로퍼티 동기화 | 208 |
| Effective MSW 1 | 559 |
| Effective MSW 2 | 560 |

### 22.3 컴포넌트 시스템
| 주제 | postId |
|------|--------|
| TextInputComponent | 360 |
| TweenFloatingComponent | 380 |
| SpawnLocationComponent | 370 |
| AttackComponent | 340 |
| PhysicsColliderComponent | 775 |
| RigidbodyComponent | 378 |
| TileMapComponent | 379 |

### 22.4 서비스 및 로직
| 주제 | postId |
|------|--------|
| ItemService | 310 |
| RoomService | 540 |
| TweenLogic | 700 |
| MaterialService | 950 |
| Translator | 460 |
| DefaultUserEnterLeaveLogic | 650 |
| UserService 가이드 | 60 |

### 22.5 물리 및 이동
| 주제 | postId |
|------|--------|
| PrismaticJoint | 800 |
| BodyType | 850 |
| TileMapMode | 900 |
| 메이플 이동 개념 | 750 |
| 사다리와 로프 | 809 |

### 22.6 이벤트
| 주제 | postId |
|------|--------|
| 기본 이벤트 함수 | 163 |
| ButtonClickEditorEvent | 420 |
| ScreenTouchEvent | 410 |
| TriggerEnterEvent | 430 |
| KeyDownEvent | 440 |

### 22.7 리소스 및 시스템
| 주제 | postId |
|------|--------|
| 아바타 아이템 등록 | 590 |
| 머티리얼 응용 | 950 |
| 리치 텍스트 | 1275 |
| DataStorage 활용 | 692 |
| 월드 인스턴스 | 984 |
| 인스턴스 맵 만들기 | 540 |

### 22.8 가이드 및 튜토리얼
| 주제 | postId |
|------|--------|
| 엔티티 생성/삭제/유효성 | 290 |
| 포탈 만들기 | 90 |
| UI 에디터 | 120 |
| 컴포넌트 활용 II | 575 |
| Lua 기초 | 822 |
| 플래피 피쉬 리메이크 | 1100 |
| 그룹 생성 및 멤버 관리 | 1325 |

---

> **총 참고 문서**: 62+ 개
> **커버리지**: API Reference, System Guides, Patterns, Best Practices
