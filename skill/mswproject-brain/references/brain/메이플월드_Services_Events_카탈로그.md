# 메이플스토리 월드 Services & Events 카탈로그

> 이 문서는 메이플스토리 월드의 Services와 Events API를 정리한 카탈로그입니다.

---

# Part 1: Services (총 40개)

## 1. Services 개요

**Service**는 월드 제작에 필요한 **시스템 레벨 핵심 기능**을 제공합니다.
- 전역으로 접근 가능 (`_ServiceName` 형식)
- 프로퍼티와 함수를 가집니다
- 엔티티 관리, 룸 관리, 입력 처리 등 시스템 기능 담당
- 모든 Service는 기본 `Service` 클래스를 상속합니다

---

## 2. Services 분류표

### 2.1 🎯 엔티티/스폰 관련 (3개)

| Service | 설명 |
|---------|------|
| `EntityService` | 엔티티 탐색, 생성, 삭제, 유효성 검사 |
| `SpawnService` | 엔티티 스폰 관리 |
| `Service` | 서비스 기본 클래스 (추상) |

---

### 2.2 🚪 룸/맵/텔레포트 (5개)

| Service | 설명 |
|---------|------|
| `RoomService` | 인스턴스 룸 생성/이동 |
| `InstanceMapService` | 인스턴스 맵 관리 |
| `DynamicMapService` | 동적 맵 생성/관리 |
| `TeleportService` | 텔레포트 기능 |
| `WorldInstanceService` | 월드 인스턴스 간 통신 |

---

### 2.3 ⌨️ 입력/모바일 (5개)

| Service | 설명 |
|---------|------|
| `InputService` | 키보드/마우스/터치 입력 |
| `MobileAccelerometerService` | 모바일 가속도계 |
| `MobileGyroscopeService` | 모바일 자이로스코프 |
| `MobileVibratorService` | 모바일 진동 |
| `MobileShareService` | 모바일 공유 기능 |

---

### 2.4 📦 데이터/저장 (4개)

| Service | 설명 |
|---------|------|
| `DataService` | 데이터 관리 |
| `DataStorageService` | 영구 데이터 저장 |
| `LogService` | 로그 관리 |
| `LogStorageService` | 로그 저장 |

---

### 2.5 🌐 네트워크/통신 (3개)

| Service | 설명 |
|---------|------|
| `HttpService` | HTTP GET/POST 요청 |
| `RateLimitService` | 요청 속도 제한 |
| `ResourceService` | 리소스 관리 |

---

### 2.6 👤 유저/정책 (3개)

| Service | 설명 |
|---------|------|
| `UserService` | 유저 정보 관리 |
| `EntryService` | 입장 관리 |
| `PolicyService` | 정책 관리 |

---

### 2.7 🎨 시각/이펙트 (7개)

| Service | 설명 |
|---------|------|
| `CameraService` | 카메라 제어 |
| `EffectService` | 이펙트 생성/관리 |
| `ParticleService` | 파티클 관리 |
| `OverlayLightService` | 오버레이 조명 |
| `MaterialService` | 머티리얼 관리 |
| `ScreenTransitionService` | 화면 전환 효과 |
| `DamageSkinService` | 데미지 스킨 |

---

### 2.8 🔊 사운드 (1개)

| Service | 설명 |
|---------|------|
| `SoundService` | 사운드 재생/관리 |

---

### 2.9 📹 화면 캡처 (2개)

| Service | 설명 |
|---------|------|
| `ScreenshotService` | 스크린샷 캡처 |
| `ScreenRecordService` | 화면 녹화 |

---

### 2.10 🎮 게임 시스템 (5개)

| Service | 설명 |
|---------|------|
| `ItemService` | 아이템 관리 |
| `BadgeService` | 배지 관리 |
| `WorldShopService` | 월드 상점 |
| `TimerService` | 타이머 관리 |
| `CollisionService` | 충돌 관리 |

---

### 2.11 🛠️ 에디터/기타 (2개)

| Service | 설명 |
|---------|------|
| `EditorService` | 에디터 기능 |
| `LocalizationService` | 다국어 지원 |

---

## 3. 주요 Services 상세

### 3.1 _EntityService

```lua
-- 이름으로 엔티티 찾기
local player = _EntityService:GetEntityByName("Player")

-- 엔티티 파괴
_EntityService:Destroy(enemy)

-- 모델 ID로 스폰
local newEntity = _EntityService:SpawnByModelId("model_npc_01", Vector2(100, 100))
```

### 3.2 _RoomService

```lua
-- 인스턴스 룸 생성 및 이동
local roomId = _RoomService:CreateInstanceRoom("dungeon_map")
_RoomService:MoveUsersToInstanceRoom({player}, roomId, "dungeon_map")
```

### 3.3 _InputService

```lua
-- 키 입력 이벤트
_InputService.KeyDownEvent:Connect(function(event)
    if event.key == KeyCode.Space then
        self:Jump()
    end
end)
```

### 3.4 _HttpService

```lua
-- HTTP 요청 (Yield 발생)
local response = _HttpService:GetAsync("https://api.example.com/data")
```

---

## 4. Service 접근 방법

```lua
-- 언더스코어(_)로 시작하는 전역 변수로 접근
local entity = _EntityService:GetEntityByName("Player")
local room = _RoomService:CreateInstanceRoom("map01")
local sound = _SoundService:Play("bgm_01")
```

---


# Part 2: Events (총 170개)

## 4. Events 개요

**Event**는 월드 내에서 발생하는 다양한 **사건/상호작용**을 나타냅니다.
- 이벤트는 **데이터**를 가지며, 발생 위치 정보를 제공
- **Agent(Listener)**가 이벤트를 수신하여 처리
- **Dispatcher**가 이벤트를 발송

---

## 5. Events 분류표

### 5.1 👤 유저 관련 (5개)

| Event | 설명 |
|-------|------|
| `UserEnterEvent` | 유저 입장 |
| `UserLeaveEvent` | 유저 퇴장 |
| `UserDisconnectEvent` | 유저 연결 해제 |
| `UserReconnectEvent` | 유저 재접속 |
| `UserKickEvent` | 유저 강제 퇴장 |

---

### 5.2 💥 충돌/트리거 (9개)

| Event | 설명 |
|-------|------|
| `TriggerEnterEvent` | 트리거 영역 진입 |
| `TriggerStayEvent` | 트리거 영역 유지 |
| `TriggerLeaveEvent` | 트리거 영역 이탈 |
| `PhysicsContactBeginEvent` | 물리 충돌 시작 |
| `PhysicsContactEndEvent` | 물리 충돌 종료 |
| `FootholdCollisionEvent` | 발판 충돌 |
| `FootholdEnterEvent` | 발판 진입 |
| `FootholdLeaveEvent` | 발판 이탈 |
| `RectTileCollisionBeginEvent` | 타일 충돌 시작 |

---

### 5.3 ⌨️ 입력 이벤트 (16개)

| Event | 설명 |
|-------|------|
| `KeyDownEvent` | 키 누름 |
| `KeyUpEvent` | 키 뗌 |
| `KeyHoldEvent` | 키 홀드 |
| `KeyReleaseEvent` | 키 릴리즈 |
| `MouseMoveEvent` | 마우스 이동 |
| `MouseScrollEvent` | 마우스 스크롤 |
| `TouchEvent` | 터치 |
| `TouchHoldEvent` | 터치 홀드 |
| `TouchReleaseEvent` | 터치 릴리즈 |
| `ScreenTouchEvent` | 화면 터치 |
| `ScreenTouchHoldEvent` | 화면 터치 홀드 |
| `ScreenTouchReleaseEvent` | 화면 터치 릴리즈 |
| `PinchInOutEvent` | 핀치 줌 |
| `TouchEditorEvent` | 에디터 터치 |
| `ScreenTouchEditorEvent` | 에디터 화면 터치 |
| `ScreenTouchHoldEditorEvent` | 에디터 화면 터치 홀드 |

---

### 5.4 🎯 Entity 생명주기 (35개+)

| Event | 설명 |
|-------|------|
| `EntityCreateEvent` | 엔티티 생성 |
| `EntityDestroyEvent` | 엔티티 파괴 |
| `EntityBeginPlayEvent` | 엔티티 시작 |
| `EntityEndPlayEvent` | 엔티티 종료 |
| `EntityConstructEvent` | 엔티티 구성 |
| `EntityFinishedConstructEvent` | 엔티티 구성 완료 |
| `EntityMapChangedEvent` | 엔티티 맵 변경 |
| `EntityWorldChangedEvent` | 엔티티 월드 변경 |
| `EntityChangedParentEvent` | 부모 변경 |
| `EntityAddChildrenEvent` | 자식 추가 |
| `EntityRemoveChildrenEvent` | 자식 제거 |
| `EntityEnabledInHierarchyChangedEvent` | 활성화 변경 |
| `EntityVisibleInHierarchyChangedEvent` | 가시성 변경 |
| `ComponentEnabledInHierarchyChangedEvent` | 컴포넌트 활성화 변경 |

---

### 5.5 ⚔️ 전투/상호작용 (10개)

| Event | 설명 |
|-------|------|
| `AttackEvent` | 공격 |
| `HitEvent` | 피격 |
| `DeadEvent` | 사망 |
| `ReviveEvent` | 부활 |
| `InteractionEvent` | 상호작용 |
| `InteractionEnterEvent` | 상호작용 진입 |
| `InteractionLeaveEvent` | 상호작용 이탈 |
| `PlayerActionEvent` | 플레이어 액션 |
| `PortalUseEvent` | 포탈 사용 |
| `MonsterActionStateEvent` | 몬스터 액션 상태 |

---

### 5.6 🎬 애니메이션/상태 (25개)

| Event | 설명 |
|-------|------|
| `ActionStateChangedEvent` | 액션 상태 변경 |
| `StateChangeEvent` | 상태 변경 |
| `BodyActionStateChangeEvent` | 몸 액션 상태 변경 |
| `BodyActionTypeChangeEvent` | 몸 액션 타입 변경 |
| `FaceActionStateChangeEvent` | 표정 액션 상태 변경 |
| `AnimationClipEvent` | 애니메이션 클립 |
| `SpriteAnimPlayerStartEvent` | 스프라이트 애니메이션 시작 |
| `SpriteAnimPlayerEndEvent` | 스프라이트 애니메이션 종료 |
| `SpriteAnimPlayerChangeFrameEvent` | 스프라이트 프레임 변경 |
| `SpriteAnimPlayerEndFrameEvent` | 스프라이트 마지막 프레임 |
| `SpriteAnimPlayerStartFrameEvent` | 스프라이트 첫 프레임 |
| `SpriteGUIAnimPlayerStartEvent` | GUI 애니메이션 시작 |
| `SpriteGUIAnimPlayerEndEvent` | GUI 애니메이션 종료 |
| `SpriteGUIAnimPlayerChangeFrameEvent` | GUI 프레임 변경 |
| `SkeletonAnimationStartEvent` | 스켈레톤 애니메이션 시작 |
| `SkeletonAnimationEndEvent` | 스켈레톤 애니메이션 종료 |
| `SkeletonAnimationCompleteEvent` | 스켈레톤 애니메이션 완료 |
| `SkeletonAnimationTimelineEvent` | 스켈레톤 타임라인 |

---

### 5.7 🎨 UI 이벤트 (20개)

| Event | 설명 |
|-------|------|
| `ButtonClickEvent` | 버튼 클릭 |
| `ButtonPressedEvent` | 버튼 누름 |
| `ButtonStateChangeEvent` | 버튼 상태 변경 |
| `SliderValueChangedEvent` | 슬라이더 값 변경 |
| `TextInputValueChangeEvent` | 텍스트 입력 값 변경 |
| `TextInputSubmitEvent` | 텍스트 제출 |
| `TextInputEndEditEvent` | 텍스트 편집 종료 |
| `ScrollPositionChangedEvent` | 스크롤 위치 변경 |
| `UITouchDownEvent` | UI 터치 다운 |
| `UITouchUpEvent` | UI 터치 업 |
| `UITouchEnterEvent` | UI 터치 진입 |
| `UITouchExitEvent` | UI 터치 이탈 |
| `UITouchDragEvent` | UI 드래그 |
| `UITouchBeginDragEvent` | UI 드래그 시작 |
| `UITouchEndDragEvent` | UI 드래그 종료 |
| `UIModeTypeChangedEvent` | UI 모드 변경 |

---

### 5.8 📹 카메라/시각 (8개)

| Event | 설명 |
|-------|------|
| `CameraSwitchEvent` | 카메라 전환 |
| `CameraZoomEndEvent` | 카메라 줌 종료 |
| `ChangedLookAtEvent` | 시선 변경 |
| `FadeInStartEvent` | 페이드 인 시작 |
| `FadeInEndEvent` | 페이드 인 종료 |
| `FadeOutStartEvent` | 페이드 아웃 시작 |
| `FadeOutEndEvent` | 페이드 아웃 종료 |
| `OrderInLayerChangedEvent` | 레이어 순서 변경 |

---

### 5.9 🔊 사운드/미디어 (5개)

| Event | 설명 |
|-------|------|
| `SoundPlayStateChangedEvent` | 사운드 재생 상태 변경 |
| `WebLoadCompleteEvent` | 웹 로드 완료 |
| `WebLoadFailEvent` | 웹 로드 실패 |
| `WebViewClickedEvent` | 웹뷰 클릭 |
| `WebViewPopupEvent` | 웹뷰 팝업 |

---

### 5.10 📦 인벤토리 (6개)

| Event | 설명 |
|-------|------|
| `InventoryItemAddedEvent` | 아이템 추가 |
| `InventoryItemRemovedEvent` | 아이템 제거 |
| `InventoryItemModifiedEvent` | 아이템 수정 |
| `InventoryItemInitEvent` | 아이템 초기화 |
| `InventoryItemEvent` | 아이템 이벤트 |
| `InitMapleCostumeEvent` | 메이플 코스튬 초기화 |

---

### 5.11 🏠 룸/월드 (8개)

| Event | 설명 |
|-------|------|
| `RoomBeginEvent` | 룸 시작 |
| `RoomEndEvent` | 룸 종료 |
| `EnterPlayEvent` | 플레이 진입 |
| `EnterEditorEvent` | 에디터 진입 |
| `WorldLoadEditorEvent` | 월드 에디터 로드 |
| `WorldInstanceExcludedEvent` | 월드 인스턴스 제외 |
| `ExitPopupOpenedEvent` | 종료 팝업 열림 |
| `ExitPopupClosedEvent` | 종료 팝업 닫힘 |

---

### 5.12 🎮 물리/이동 (15개)

| Event | 설명 |
|-------|------|
| `ChangedMovementInputEvent` | 이동 입력 변경 |
| `ClimbPauseEvent` | 등반 일시정지 |
| `KinematicbodyJumpEvent` | 키네마틱 점프 |
| `RigidbodyEvent` | 리지드바디 이벤트 |
| `RigidbodyAttachEvent` | 리지드바디 부착 |
| `RigidbodyDetachEvent` | 리지드바디 분리 |
| `RigidbodyClimbableAttachStartEvent` | 등반 시작 |
| `RigidbodyClimbableDetachEndEvent` | 등반 종료 |
| `RigidbodyKinematicMoveJumpEvent` | 키네마틱 이동 점프 |
| `RigidbodyQuartviewJumpEvent` | 쿼터뷰 점프 |
| `ParticleEmitStartEvent` | 파티클 방출 시작 |
| `ParticleEmitEndEvent` | 파티클 방출 종료 |
| `ParticleLoopEvent` | 파티클 루프 |

---

### 5.13 💬 채팅 (2개)

| Event | 설명 |
|-------|------|
| `ChatEvent` | 채팅 |
| `ChatBalloonEvent` | 채팅 말풍선 |

---

### 5.14 ⚙️ 시스템/기타 (10개+)

| Event | 설명 |
|-------|------|
| `EventType` | 이벤트 타입 (기본) |
| `EntityEventType` | 엔티티 이벤트 타입 |
| `ServerFunctionRateLimitEvent` | 서버 함수 속도 제한 |
| `TotalServerFunctionRateLimitEvent` | 전체 서버 함수 속도 제한 |
| `ResourceUploadEvent` | 리소스 업로드 |
| `SortingLayerChangedEvent` | 정렬 레이어 변경 |
| `GizmoColliderChangedEvent` | 기즈모 충돌체 변경 |
| `MenuPopupOpenedEvent` | 메뉴 팝업 열림 |
| `MenuPopupClosedEvent` | 메뉴 팝업 닫힘 |

---

## 6. 이벤트 핸들링 패턴

### 6.1 Component 이벤트 연결
```lua
self.Entity.TriggerComponent.OnTriggerEnter:Connect(function(other)
    log("엔티티 진입: " .. other.Name)
end)
```

### 6.2 Service 이벤트 핸들러
```lua
_InputService.KeyDownEvent:Connect(function(event)
    if event.key == KeyCode.Space then
        self:Jump()
    end
end)
```

---

## 7. 참고 링크

- [Events 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Events)
- [Services 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Services)


