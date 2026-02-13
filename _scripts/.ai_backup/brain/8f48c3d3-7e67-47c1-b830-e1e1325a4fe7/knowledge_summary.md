# MapleStory Worlds 학습 지식 총정리

> **작성일**: 2026-02-08  
> **학습 기간**: 2026-02-05 ~ 2026-02-08 (3일)  
> **총 문서**: 17개 아티팩트 (한글 8개 + 영문 9개)  
> **총 분량**: 약 10,000줄 이상

---

## 📚 학습 문서 목록 (17개)

### 1. 계획 및 추적 문서 (3개)

#### [`task.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/task.md)
- **용도**: 전체 학습 진행 상황 추적
- **내용**: API Reference 시스템 학습, Components 카탈로그, 핵심 12개 Components 완료

#### [`learning_plan.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/learning_plan.md)
- **용도**: 초기 학습 계획 수립
- **내용**: 3단계 학습 로드맵 (기초 → 심화 → 실전)

#### [`api_learning_plan.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/api_learning_plan.md)
- **용도**: API Reference 학습 전략
- **내용**: Components 우선순위 분류, 학습 순서 및 방법론

---

### 2. 기초 지식 문서 (5개)

#### [`msw_knowledge_base.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/msw_knowledge_base.md)
- **용도**: MapleStory Worlds 기초 지식
- **주요 내용**:
  - Entity-Component 시스템
  - Lua 5.2 기반 스크립팅
  - Client-Server 아키텍처
  - RUID 리소스 시스템
  - 2D 플랫포머 좌표계

#### [`메이플월드_API_Reference_완전가이드.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_API_Reference_완전가이드.md)
- **용도**: API Reference 사용법 가이드
- **내용**: 8개 카테고리, 배지 시스템 (17개), 로그 메시지

#### [`메이플월드_API_학습.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_API_학습.md)
- **용도**: API 학습 기본 개념
- **내용**: Lua 5.3, API 구조, 배지 의미, 로그 시스템

#### [`메이플월드_Lua_스크립팅_완전가이드.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Lua_스크립팅_완전가이드.md) (584줄)
- **용도**: Lua 스크립팅 완전 가이드
- **주요 내용**:
  - self와 Entity 개념
  - 라이프사이클 이벤트 (OnBeginPlay, OnUpdate 등)
  - wait() 함수, 이벤트 핸들러
  - Property 동기화 [Sync]
  - Server/Client 통신
  - 변수, 조건문, 반복문, 함수
  - 실전 예제 (이동, 충돌, 타이머)

#### [`메이플월드_Logics_Lua_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Logics_Lua_카탈로그.md) (496줄)
- **용도**: Logics 및 Lua 표준 라이브러리
- **주요 내용**:
  - **Logics 8개**: TweenLogic, UILogic, ScreenMessageLogic, UtilLogic 등
  - **Lua 라이브러리 7개**:
    - global (wait, isvalid, log, pcall, pairs, ipairs 등)
    - math (pi, abs, sqrt, sin, cos, random, clamp, sign 등)
    - string (len, upper, lower, find, gsub, format 등)
    - table (insert, remove, sort, concat, keys, values, create 등)
    - os (time, date, difftime, clock)
    - profiler (beginscope, endscope)
    - utf8 (len, char, codepoint, codes - 한글 처리)

---

### 3. Components 카탈로그 (3개)

#### [`components_catalog.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/components_catalog.md)
- **용도**: 전체 Components 분류 카탈로그
- **통계**: 100개 이상 컴포넌트
- **12개 카테고리**: AI, Avatar, Rendering, UI, Physics, Joints, Map, Player, Interaction, Damage, Sound, System

#### [`메이플월드_Components_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Components_카탈로그.md) (278줄)
- **용도**: Components 한글 카탈로그
- **내용**: 105개 Components를 12개 카테고리로 분류

#### [`메이플월드_완전_API_레퍼런스.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_완전_API_레퍼런스.md) (6,802줄!)
- **용도**: 모든 API 종합 레퍼런스
- **내용**:
  - Part 0: API 형식 가이드 (배지 17개)
  - Part 1: Components (100개+) 상세 설명
  - Part 2: Services (40개) 상세 설명

---

### 4. 상세 가이드 문서 (2개)

#### [`core_components_guide.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/core_components_guide.md) (1,233줄)
**필수 6개 Components 완벽 가이드**

1. **TransformComponent**: 8 properties, 8 methods (위치/회전/크기)
2. **SpriteRendererComponent**: 14 properties, 2 methods, 7 events (스프라이트/애니메이션)
3. **TextComponent**: 30+ properties, 3 methods, 2 events (UI 텍스트)
4. **UITransformComponent**: 10 properties, 1 method, 1 event (UI 앵커/레이아웃)
5. **RigidbodyComponent**: 22 properties, 13 methods, 9 events (메이플 스타일 물리)
6. **TriggerComponent**: 9 properties, 3 methods, 3 events (충돌 감지)

#### [`additional_components_guide.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/additional_components_guide.md) (967줄)
**핵심 6개 Components 완벽 가이드**

1. **ButtonComponent**: 8 properties, 7 events (UI 버튼)
2. **TextInputComponent**: 14 properties, 2 methods, 8 events (텍스트 입력)
3. **CameraComponent**: 16 properties, 4 methods (카메라 제어)
4. **MapComponent**: 13 properties, 1 method (맵 물리 설정)
5. **TileMapComponent**: 14 properties, 1 event (타일맵/발판)
6. **PlayerComponent**: 9 properties, 8 methods (플레이어 관리)

---

### 5. Services, Events, Enums 카탈로그 (3개)

#### [`메이플월드_Services_Events_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Services_Events_카탈로그.md) (469줄)
- **Services 40개**:
  - 엔티티/스폰 (3개): EntityService, SpawnService
  - 룸/맵 (5개): RoomService, InstanceMapService, DynamicMapService, TeleportService
  - 입력/모바일 (5개): InputService, MobileAccelerometerService 등
  - 데이터/저장 (4개): DataService, DataStorageService, LogService
  - 네트워크 (3개): HttpService, RateLimitService, ResourceService
  - 유저/정책 (3개): UserService, EntryService, PolicyService
  - 시각/이펙트 (7개): CameraService, EffectService, ParticleService 등
  - 사운드 (1개): SoundService
  - 화면 캡처 (2개): ScreenshotService, ScreenRecordService
  - 게임 시스템 (5개): ItemService, BadgeService, TimerService 등
  - 에디터/기타 (2개): EditorService, LocalizationService

- **Events 170개**:
  - 유저 (5개): UserEnter, UserLeave, UserDisconnect 등
  - 충돌/트리거 (9개): TriggerEnter, TriggerStay, TriggerLeave 등
  - 입력 (16개): KeyDown, KeyUp, MouseMove, Touch 등
  - Entity 생명주기 (35개+): EntityCreate, EntityDestroy 등
  - 전투/상호작용 (10개): Attack, Hit, Dead, Revive 등
  - 애니메이션/상태 (25개): StateChange, SpriteAnimStart 등
  - UI (20개): ButtonClick, SliderValueChanged, TextInputSubmit 등
  - 카메라/시각 (8개): CameraSwitch, FadeIn, FadeOut 등
  - 사운드/미디어 (5개): SoundPlayStateChanged 등
  - 인벤토리 (6개): InventoryItemAdded 등
  - 룸/월드 (8개): RoomBegin, RoomEnd 등
  - 물리/이동 (15개): RigidbodyAttach, FootholdEnter 등
  - 채팅 (2개): Chat, ChatBalloon
  - 시스템/기타 (10개+)

#### [`메이플월드_Misc_Enums_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Misc_Enums_카탈로그.md) (477줄)
- **Misc 타입 100개+**:
  - 벡터/색상 (12개): Vector2, Vector3, Color, Quaternion 등
  - 엔티티/컴포넌트 참조 (4개): Entity, EntityRef, ComponentRef, DataRef
  - 데이터 저장소 (20개+): DataStorage, UserDataStorage, GlobalDataStorage 등
  - 컬렉션 (8개): List, Dictionary, SyncList, SyncDictionary 등
  - 물리/충돌 (15개): BoxShape, CircleShape, CollisionGroup, Foothold 등
  - 조명 (8개): OverlayLightInfo 등
  - 월드/룸 (8개): Environment, InstanceRoom, WorldInstanceInfo 등
  - 상점/아이템 (10개): Item, BadgeInfo, WorldShopProduct 등
  - 애니메이션 (5개): AnimationClip, Sprite 등
  - 정규식 (5개): Regex, RegexMatch 등
  - AI 행동트리 (6개): BTNode, SelectorNode, SequenceNode 등
  - 기타 유틸리티 (10개+): User, Translator, Tweener 등

- **Enums 100개**:
  - 입력 (5개): KeyboardKey, InputContentType, InputLineType 등
  - 물리/충돌 (5개): BodyType, ColliderType 등
  - UI/레이아웃 (25개+): AlignmentType, TextAlignmentType, ButtonState 등
  - 애니메이션/트윈 (12개): EaseType, TweenState, SpriteDrawMode 등
  - 아바타/캐릭터 (5개): MapleAvatarBodyActionState, EmotionalType 등
  - 조명/시각 (6개): LightType, LitMode 등
  - 카메라 (2개): CameraBlendType, AxisType
  - 사운드 (1개): SoundPlayState
  - 파티클 (8개): AreaParticleType, BasicParticleType 등
  - 맵/월드 (8개): TileMapMode, ClimbableType 등
  - 상점/배지 (5개): BadgeGrade, BadgeStatus 등
  - 네트워크/시스템 (12개): AccountRegion, HttpContentType 등
  - 기타 (10개+): BehaviourTreeStatus, RegexOption 등

---

### 6. 총정리 문서 (1개)

#### [`knowledge_summary.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/knowledge_summary.md)
- **용도**: 전체 학습 내용 요약
- **내용**: 이 문서!

---

## 📊 학습 통계

### Components 학습 현황
| 카테고리 | 학습 완료 | 총 개수 | 완료율 |
|---------|----------|---------|--------|
| **필수** | 6개 | 6개 | 100% ✅ |
| **핵심** | 6개 | 6개 | 100% ✅ |
| **중요** | 0개 | ~20개 | 0% |
| **선택** | 0개 | ~70개 | 0% |

### 문서 통계
- **총 Properties**: 160개 (Components 12개 기준)
- **총 Methods**: 36개
- **총 Events**: 36개
- **코드 예제**: 30개 이상
- **사용 패턴**: 25개 이상
- **총 문서 분량**: 약 10,000줄

### API 카탈로그 통계
- **Components**: 100개 이상
- **Services**: 40개
- **Events**: 170개
- **Misc 타입**: 100개 이상
- **Enums**: 100개
- **Logics**: 8개
- **Lua 라이브러리**: 7개

---

## 🎯 핵심 개념 정리

### 1. Entity-Component 시스템
```lua
-- Entity는 컨테이너, Component가 기능 제공
local entity = _EntityService:CreateEntity("MyEntity")
entity.TransformComponent.Position = Vector3(100, 200, 0)
entity.SpriteRendererComponent.SpriteRUID = "sprite_ruid"
```

### 2. Client-Server 아키텍처
```lua
-- [server only] - 서버에서만 실행
-- [client only] - 클라이언트에서만 실행
-- [Sync] - 서버→클라이언트 자동 동기화
```

### 3. 좌표계
- **로컬 좌표**: 부모 기준 상대 위치
- **월드 좌표**: 맵 기준 절대 위치
- **UI 좌표**: 앵커 기준 정규화 (0~1)

### 4. 이벤트 시스템
```lua
Event Handler:
[self]
HandleTriggerEnterEvent(TriggerEnterEvent event)
{
    local other = event.TriggerBodyEntity
    -- 충돌 처리
}
```

### 5. 물리 시스템
- **플랫포머 모드**: KinematicMove = false (메이플 스타일)
- **탑다운 모드**: KinematicMove = true (상하좌우)
- **발판 시스템**: Foothold 자동 생성 및 감지

---

## 🔧 실전 패턴

### UI 시스템
```lua
-- Button + TextInput + Text 조합
-- 로그인 폼, 채팅, 검색 등
```

### 카메라 연출
```lua
-- DeadZone/SoftZone으로 부드러운 추적
-- SetZoomTo로 줌 인/아웃
-- ShakeCamera로 진동 효과
```

### 플레이어 관리
```lua
-- Hp/MaxHp로 체력 관리
-- RespawnPosition으로 체크포인트
-- MoveToMapPosition으로 맵 이동
```

### 물리 제어
```lua
-- MapComponent로 맵 전역 물리 보정
-- RigidbodyComponent로 개별 엔티티 제어
-- TriggerComponent로 상호작용
```

---

## 📖 학습 체크리스트

### 완료된 학습 ✅
- [x] API Reference 시스템 이해
- [x] Components 전체 카탈로그 작성 (100개+)
- [x] 필수 6개 Components 마스터
- [x] 핵심 6개 Components 마스터
- [x] Entity-Component 시스템 이해
- [x] Client-Server 아키텍처 이해
- [x] 좌표계 및 변환 이해
- [x] 이벤트 시스템 이해
- [x] 물리 시스템 (플랫포머/탑다운) 이해
- [x] Lua 스크립팅 기초 (self, Entity, wait, 이벤트)
- [x] Services 카탈로그 (40개)
- [x] Events 카탈로그 (170개)
- [x] Misc/Enums 카탈로그 (200개+)
- [x] Lua 표준 라이브러리 (7개)

### 다음 학습 목표 📝
- [ ] Services 상세 학습 (EntityService, RoomService, InputService 등)
- [ ] 중요 Components 20개 학습
- [ ] 실전 프로젝트 구현 (미니 게임)
- [ ] 고급 패턴 (AI, 멀티플레이어, 데이터 저장)

---

## 🚀 활용 가능한 기능

### 현재 구현 가능한 시스템
1. **캐릭터 이동 시스템** (Rigidbody + Movement)
2. **UI 시스템** (Button + TextInput + Text + UITransform)
3. **카메라 시스템** (Camera + DeadZone/SoftZone)
4. **충돌 감지** (Trigger + CollisionGroup)
5. **체력/리스폰 시스템** (Player + Hp/Respawn)
6. **맵 이동 시스템** (Player.MoveToMapPosition)
7. **애니메이션 시스템** (SpriteRenderer + 이벤트)
8. **타일맵 시스템** (TileMap + Foothold)
9. **입력 처리** (InputService + KeyDown/Touch)
10. **데이터 저장** (DataStorageService)
11. **HTTP 통신** (HttpService)
12. **사운드 재생** (SoundService)

### 실전 예제
- ✅ 로그인 폼
- ✅ 체크포인트 시스템
- ✅ 포탈 시스템
- ✅ AI 순찰 (발판 끝 감지)
- ✅ 넉백 효과
- ✅ 아이템 획득
- ✅ 체력 회복 공간
- ✅ 카메라 연출 (보스 등장)
- ✅ 타이핑 효과
- ✅ 페이드 효과
- ✅ 플레이어 이동 (WASD)
- ✅ 충돌 감지 및 데미지
- ✅ 타이머 구현

---

## 📚 참고 자료

### 공식 문서
- [MapleStory Worlds Creator Center](https://maplestoryworlds-creators.nexon.com/ko)
- [API Reference](https://maplestoryworlds-creators.nexon.com/ko/apiReference)
- [Lua 5.3 Manual](https://www.lua.org/manual/5.3/)

### 학습 문서 (Brain - 17개)

**계획/추적 (3개)**:
1. [`task.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/task.md)
2. [`learning_plan.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/learning_plan.md)
3. [`api_learning_plan.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/api_learning_plan.md)

**기초 지식 (5개)**:
4. [`msw_knowledge_base.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/msw_knowledge_base.md)
5. [`메이플월드_API_Reference_완전가이드.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_API_Reference_완전가이드.md)
6. [`메이플월드_API_학습.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_API_학습.md)
7. [`메이플월드_Lua_스크립팅_완전가이드.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Lua_스크립팅_완전가이드.md)
8. [`메이플월드_Logics_Lua_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Logics_Lua_카탈로그.md)

**Components 카탈로그 (3개)**:
9. [`components_catalog.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/components_catalog.md)
10. [`메이플월드_Components_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Components_카탈로그.md)
11. [`메이플월드_완전_API_레퍼런스.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_완전_API_레퍼런스.md) (6,802줄)

**상세 가이드 (2개)**:
12. [`core_components_guide.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/core_components_guide.md) (1,233줄)
13. [`additional_components_guide.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/additional_components_guide.md) (967줄)

**Services/Events/Enums (3개)**:
14. [`메이플월드_Services_Events_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Services_Events_카탈로그.md) (469줄)
15. [`메이플월드_Misc_Enums_카탈로그.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/메이플월드_Misc_Enums_카탈로그.md) (477줄)

**총정리 (1개)**:
16. [`knowledge_summary.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/knowledge_summary.md) (이 문서)

**기타 (1개)**:
17. [`implementation_plan.md`](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/implementation_plan.md)

---

> **마지막 업데이트**: 2026-02-08  
> **총 학습 문서**: 17개 (약 10,000줄)  
> **다음 목표**: Services 상세 학습 및 실전 프로젝트 구현
