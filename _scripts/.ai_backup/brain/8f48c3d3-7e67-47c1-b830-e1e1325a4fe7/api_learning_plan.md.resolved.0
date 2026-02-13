# MSW API Reference 정복 계획

> **목표**: 메이플스토리 월드 API Reference 체계적 학습 및 Knowledge Base 확장

---

## 📚 API Reference 구조 이해 (완료)

### API 카테고리 분류
| 카테고리 | 설명 | URL |
|---------|------|-----|
| **Components** | 엔티티에 추가하는 기능 단위 | `/apiReference/Components` |
| **Events** | API에서 발생하는 이벤트 | `/apiReference/Events` |
| **Services** | 시스템 제작 핵심 기능 | `/apiReference/Services` |
| **Logics** | 게임 로직 | `/apiReference/Logics` |
| **Misc** | MSW 고유 타입 | `/apiReference/Misc` |
| **Enums** | 연결된 값의 집합 | `/apiReference/Enums` |
| **Lua** | Lua 5.3 기반 스크립팅 | `/apiReference/Lua` |
| **LogMessages** | 로그 메시지 (LIA/LWA/LEA) | `/apiReference/LogMessages` |

### 배지 시스템 이해 (완료)

#### 동기화 정보
- **Sync**: 서버→클라이언트 동기화

#### 실행 공간 제어
- **ReadOnly**: 읽기 전용, 덮어쓰기 불가
- **ControlOnly**: 조작 권한 환경 전용
- **MakerOnly**: 메이커 전용
- **ReleaseOnly**: 출시 월드 전용
- **ServerOnly**: 서버 전용 함수
- **ClientOnly**: 클라이언트 전용 함수
- **Server**: 서버 실행 (클라이언트→서버 요청)
- **Client**: 클라이언트 실행 (서버→클라이언트 전달)

#### 프로퍼티 관련
- **HideFromInspector**: 프로퍼티 창 비노출 (스크립트 접근 가능)

#### 함수 관련
- **Yield**: 스크립트 실행 중단
- **Static**: 전역 접근 가능 (`.` 호출)

#### 스크립트 관련
- **ScriptOverridable**: 재정의 가능

#### 타입 관련
- **Abstract**: Component 생성 불가 추상 API

#### API 상태
- **Deprecated**: 더 이상 사용 안 함
- **Preview**: 선공개 API (변경 가능)

#### Event 공간
- **Space: Server**: 서버에서 발생
- **Space: Client**: 클라이언트에서 발생
- **Space: Editor**: 에디터에서 발생
- **Space: All**: 서버+클라이언트에서 발생

### 매개변수 표기법
- **기본**: `type paramName`
- **생략 가능**: `type paramName=nil`
- **가변**: `any... args`

---

## 🎯 학습 전략

### Phase 1: Components 정복 (최우선)
**이유**: 가장 많이 사용하며 Knowledge Base에서 이미 일부 커버

**학습 순서**:
1. **핵심 시각 컴포넌트**
   - SpriteRendererComponent
   - TextComponent
   - ImageComponent
   - CameraComponent

2. **Transform 및 물리**
   - TransformComponent ✓ (이미 학습됨)
   - RigidbodyComponent ✓
   - PhysicsColliderComponent ✓
   - TriggerComponent

3. **UI 컴포넌트**
   - TextInputComponent ✓
   - ButtonComponent
   - ScrollViewComponent
   - SliderComponent

4. **게임 로직 컴포넌트**
   - InventoryComponent
   - ItemComponent
   - AttackComponent ✓
   - HealthComponent
   - StateComponent

5. **아바타 및 애니메이션**
   - AvatarRendererComponent
   - SpriteAnimPlayerComponent
   - StateAnimationComponent
   - TweenFloatingComponent ✓

6. **맵 및 타일**
   - TileMapComponent ✓
   - MapComponent
   - SpawnLocationComponent ✓
   - PortalComponent

### Phase 2: Services 마스터
**이유**: 시스템 레벨 기능, 게임 로직의 중추

**학습 순서**:
1. **핵심 서비스**
   - UserService ✓ (가이드 완료)
   - EntityService
   - ItemService ✓
   - DataStorageService ✓

2. **맵 및 인스턴스**
   - RoomService ✓
   - MapService
   - InstanceMapService

3. **UI 및 렌더링**
   - MaterialService ✓
   - GuiService
   - CameraService

4. **입력 및 사운드**
   - InputService
   - SoundService
   - PhysicsService

### Phase 3: Events 이해
**이유**: 게임 로직 연결의 핵심

**학습 순서**:
1. **생명주기 이벤트**
   - OnBeginPlay ✓
   - OnUpdate
   - OnDestroy

2. **사용자 입력 이벤트**
   - KeyDownEvent ✓
   - KeyUpEvent
   - ScreenTouchEvent ✓
   - ButtonClickEvent ✓

3. **물리 이벤트**
   - TriggerEnterEvent ✓
   - TriggerExitEvent
   - CollisionEvent

4. **엔티티 이벤트**
   - EntityPostTransformInitEvent ✓
   - EntityPreApplyChangedPropertiesEvent ✓
   - EntityDestroyedEvent

### Phase 4: Logics & Misc
**학습 순서**:
1. **Logics**
   - TweenLogic ✓
   - UtilLogic
   - UILogic
   - DefaultUserEnterLeaveLogic ✓

2. **Misc 타입**
   - Vector2, Vector3 ✓
   - Entity ✓
   - Component ✓
   - Tweener
   - ReadOnlyDictionary ✓

### Phase 5: Enums & 고급 주제
1. **Enums**
   - BodyType ✓
   - TileMapMode ✓
   - EaseType
   - InputContentType
   - KeyboardKey ✓
   - SoundPlayState ✓

---

## 📊 현재 진행 상황

### ✅ 이미 학습 완료 (Knowledge Base v5.0)
- **Components**: TextInputComponent, TweenFloatingComponent, SpawnLocationComponent, AttackComponent, PhysicsColliderComponent, RigidbodyComponent, TileMapComponent
- **Services**: ItemService, RoomService, MaterialService, UserService (가이드)
- **Logics**: TweenLogic, DefaultUserEnterLeaveLogic, Translator
- **Events**: ButtonClickEvent, TriggerEnterEvent, KeyDownEvent, ScreenTouchEvent, EntityPostTransformInitEvent
- **Misc**: Entity, Vector2/3, ReadOnlyDictionary
- **Enums**: BodyType, TileMapMode, KeyboardKey, SoundPlayState

### 🎯 다음 학습 목표
1. **SpriteRendererComponent** - 가장 기본적인 렌더링 컴포넌트
2. **TextComponent** - UI 텍스트 표시
3. **TransformComponent** - 위치/회전/크기 (핵심!)
4. **EntityService** - Entity 생성/삭제/관리
5. **UserService** - 플레이어 관리 (API 상세)

---

## 🔄 학습 방법론

### 각 API 학습 시 체크리스트
- [ ] API 개요 및 용도 파악
- [ ] Properties 전수 조사 (타입, Sync, ReadOnly 등)
- [ ] Methods 전수 조사 (매개변수, 리턴 타입, 배지)
- [ ] Events 확인 (발생 조건, Space)
- [ ] Examples 분석 및 패턴 추출
- [ ] Knowledge Base에 핵심 정보 통합
- [ ] 기존 학습한 API와 연관성 파악

### Knowledge Base 통합 원칙
1. **간결성**: 핵심 정보만 추출
2. **실용성**: 실제 사용 패턴 예시 포함
3. **연계성**: 관련 API 참조 명시
4. **완전성**: 중요 Property/Method 빠짐없이

---

## 📅 학습 일정 (예상)

| Phase | 예상 시간 | 우선순위 |
|-------|----------|----------|
| Components (핵심 15개) | 2-3시간 | ⭐⭐⭐⭐⭐ |
| Services (핵심 10개) | 1-2시간 | ⭐⭐⭐⭐ |
| Events (핵심 15개) | 1시간 | ⭐⭐⭐ |
| Logics & Misc | 30분 | ⭐⭐ |
| Enums | 30분 | ⭐ |

---

> **총 예상 학습 시간**: 5-7시간
> **목표**: Knowledge Base v6.0 - 완전한 API Reference 통합
