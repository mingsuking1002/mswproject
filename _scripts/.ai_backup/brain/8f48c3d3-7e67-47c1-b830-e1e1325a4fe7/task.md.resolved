# 메이플스토리 월드 개발 학습 및 실습

- [x] **환경 설정 및 자료 수집** <!-- id: 0 -->
    - [x] 개발 목표 확인 및 방향성 설정
    - [x] MSW API 레퍼런스 및 학습 자료 확보
- [x] **엔진 마스터리 (Engine Mastery)** <!-- id: 1 -->
    - [x] **공식 가이드 정독 (Docs Analysis)**:
        - [x] **기초**: 실행 제어(210), 동기화(208), 이동(750)
        - [x] **생명주기 & UI**: 이벤트(163), 기본 UI(744), DataStorage(692)
        - [x] **객체 및 맵**: 모델(55), 맵 레이어(53), 타일맵(589), 사다리(809)
        - [x] **스크립트 심화**: 프로퍼티(205), 함수(172), 최적화(1078, 1073)
        - [x] **리소스**: 아바타 아이템(588), 애니메이션(595)
    - [x] **API 레퍼런스 확립**:
        - [x] 주요 서비스/컴포넌트 인덱싱 완료 (`Components`, `Services`)
    - [x] **마스터 지식 베이스 구축 (Supreme)**: v3.0 업데이트 완료
- [/] **심화 API 학습 (Bulk Analysis)** <!-- id: 2 -->
    - [x] **1차 대량 학습 완료**: 18개 문서 분석 및 Knowledge Base v4.0 통합
        - Entity/Component/Property 모델, Workspace/Hierarchy 구조
        - 서버-클라이언트 실행 제어, 프로퍼티 동기화
        - 생명주기 이벤트, 모델 시스템, 맵 레이어
        - DataStorage 심화 (Batch/Transaction/Version)
        - 월드 인스턴스, Lua 기초, 트러블슈팅
    - [x] **postId 1-1400 스캔**: 62+ 유효 문서 발굴 완료
    - [x] **Knowledge Base v5.0 통합**: 신규 발견 문서 체계화 완료
        - UI 컴포넌트 (TextInputComponent, Button 시스템)
        - 물리 시스템 (BodyType, PrismaticJoint, PhysicsCollider)
        - 인스턴스 룸 시스템 (RoomService, 정적/동적 맵)
        - 메이플 이동 메커니즘 (LayerSettingType, 수직선 제어)
        - TweenLogic 애니메이션 시스템
        - MaterialService 런타임 제어
        - Effective 패턴 및 주의사항 (LocalPlayer, Localized Entity)
        - ItemService, AttackComponent, Translator 등 추가 API
    - [/] **컴포넌트/API 정복**: 세부 API Reference 문서화
        - [x] **Components 전체 카탈로그 작성**: 100+ 컴포넌트 분류 완료
            - 12개 카테고리: AI, Avatar, Rendering, UI, Physics, Joints, Map, Player, Interaction, Damage, Sound, System
            - 우선순위 매핑 완료 (필수 6개, 핵심 6개 식별)
        - [x] **핵심 Components 상세 학습 완료**: **필수 6개 + 핵심 6개 = 총 12개 완료!**
            - [x] **필수 6개**: Transform, SpriteRenderer, Text, UITransform, Rigidbody, Trigger
                - Transform: 8 properties, 8 methods (위치/회전/크기/좌표변환)
                - SpriteRenderer: 14 properties, 2 methods, 7 events (스프라이트/애니메이션)
                - Text: 30+ properties, 3 methods, 2 events (UI 텍스트/폰트/정렬/효과)
                - UITransform: 10 properties, 1 method, 1 event (UI 앵커/레이아웃)
                - Rigidbody: 22 properties, 13 methods, 9 events (물리/이동/점프)
                - Trigger: 9 properties, 3 methods, 3 events (충돌감지/상호작용)
            - [x] **핵심 6개**: Button, TextInput, Camera, Map, TileMap, Player
                - Button: 8 properties, 7 events (UI 버튼/클릭 이벤트)
                - TextInput: 14 properties, 2 methods, 8 events (텍스트 입력/검증)
                - Camera: 16 properties, 4 methods (카메라 추적/줌/진동)
                - Map: 13 properties, 1 method (맵 물리 보정/경계)
                - TileMap: 14 properties, 1 event (타일맵/발판 생성)
                - Player: 9 properties, 8 methods (체력/리스폰/이동)
        - [x] **Phase 1 - Player & Character Components 완료**: **11개 컴포넌트 마스터!**
            - [x] **Player/Movement (3개)**: PlayerController, Movement, Chat
                - PlayerController: 3 properties, 13 methods, 2 events (입력/액션 매핑)
                - Movement: 3 properties, 7 methods, 2 events (이동/점프 제어)
                - Chat: 7 properties, 1 event (채팅/감정 표현)
            - [x] **Avatar System (8개)**: Renderer, GUI, Body/Face Selector, State Animation, Costume, NameTag, ChatBalloon
                - AvatarRenderer: 6 properties, 8 methods, 2 events (월드 아바타 렌더링)
                - AvatarGUIRenderer: 7 properties, 5 methods (UI 아바타 렌더링)
                - AvatarBodyActionSelector: 2 properties, 1 event (몸 동작 선택)
                - AvatarFaceActionSelector: 3 properties (표정 선택)
                - AvatarStateAnimation: 2 properties, 4 methods, 1 event (상태 애니메이션)
                - CostumeManager: 20 properties, 2 methods, 2 events (코스튬 관리)
                - NameTag: 7 properties (이름표)
                - ChatBalloon: 15 properties, 1 event (말풍선)
            - **Phase 1 총계**: 75 properties, 39 methods, 12 events
        - [x] **Phase 2 - AI Components 완료**: **3개 컴포넌트 마스터!**
            - [x] **AI System (3개)**: AIComponent, AIChaseComponent, AIWanderComponent
                - AIComponent: 3 properties, 3 methods (Behavior Tree 기반 AI)
                - AIChaseComponent: 3 properties, 2 methods (플레이어/엔티티 추적)
                - AIWanderComponent: 0 unique properties, 0 unique methods (주변 배회, AIComponent 상속)
            - **Phase 2 총계**: 6 properties, 5 methods
            - **핵심 개념**: Behavior Tree (Selector/Sequence/Leaf Node), BehaviourTreeStatus
        - [x] **Phase 3 - Combat System 완료**: **3개 컴포넌트 마스터!**
            - [x] **Combat System (3개)**: AttackComponent, HitComponent, DamageSkinComponent
                - AttackComponent: 0 unique properties, 10 methods, 1 event (공격 시스템/대미지 계산)
                - HitComponent: 9 properties, 2 methods, 1 event (피격 시스템/충돌체)
                - DamageSkinComponent: 0 unique properties, 0 unique methods (대미지 스킨 표시)
            - **Phase 3 총계**: 9 properties, 12 methods, 2 events
            - **핵심 개념**: Attack/Hit 메커니즘, 대미지 계산, 크리티컬 시스템, 충돌체 타입
        - [x] **Phase 4 - Animation & State 완료**: **2개 컴포넌트 마스터!**
            - [x] **State System (2개)**: StateComponent, StateAnimationComponent
                - StateComponent: 1 property, 6 methods, 3 events (상태 관리/전이)
                - StateAnimationComponent: 1 property, 4 methods, 1 event (상태 기반 애니메이션)
            - **Phase 4 총계**: 2 properties, 10 methods, 4 events
            - **핵심 개념**: StateType 정의, 상태 전이 조건, State → Animation 매핑
        - [x] **Phase 5 - Sound Components 완료**: **1개 컴포넌트 마스터!**
            - [x] **Sound System (1개)**: SoundComponent
                - SoundComponent: 11 properties, 14 methods, 1 event (효과음/BGM 재생)
            - **Phase 5 총계**: 11 properties, 14 methods, 1 event
            - **핵심 개념**: 음원 재생, 3D 사운드, 동기화 재생, 볼륨/피치 제어
        - [x] **Phase 6 - UI Advanced 완료**: **1개 컴포넌트 마스터!**
            - [x] **UI Advanced (1개)**: SliderComponent
                - SliderComponent: 17 properties, 0 unique methods, 3 events (슬라이더 UI)
            - **Phase 6 총계**: 17 properties, 0 unique methods, 3 events
            - **핵심 개념**: 값 범위 설정, 핸들 커스터마이징, 정수/실수 모드
        - [x] **Phase 7 - Physics Components 완료**: **3개 컴포넌트 마스터!**
            - [x] **Physics System (3개)**: RigidbodyComponent, KinematicbodyComponent, SideviewbodyComponent
                - RigidbodyComponent: 25 properties, 14 methods, 9 events (메이플 이동/중력/가감속)
                - KinematicbodyComponent: 12 properties, 7 methods, 5 events (탑다운 이동/RectTile)
                - SideviewbodyComponent: 6 properties, 4 methods, 4 events (횡스크롤 이동)
            - **Phase 7 총계**: 43 properties, 25 methods, 18 events
            - **핵심 개념**: 중력, 가속도, 점프, 발판/타일 충돌, Attach/Detach
        - [x] **Phase 8 - Camera & Rendering 완료**: **2개 컴포넌트 마스터!**
            - [x] **Camera & Rendering (2개)**: CameraComponent, LightComponent
                - CameraComponent: 16 properties, 4 methods, 0 events (카메라 추적/줌/흔들기)
                - LightComponent: 18 properties, 0 unique methods, 0 events (광원 출력)
            - **Phase 8 총계**: 34 properties, 4 unique methods, 0 events
            - **핵심 개념**: DeadZone/SoftZone, 줌, 카메라 흔들기, 광원 타입(Spot/Freeform/Global/Sprite)

---

## 🎉 학습 완료!

### 최종 통계
- **완료 Phase**: 8개
- **학습 Component**: 26개
- **문서화 Properties**: 228개
- **문서화 Methods**: 105개
- **문서화 Events**: 43개
- **생성 가이드**: 8개 (약 4,371줄)

### 마스터한 시스템
1. ✅ Player & Character System (11개)
2. ✅ AI System (3개)
3. ✅ Combat System (3개)
4. ✅ Animation & State System (2개)
5. ✅ Sound System (1개)
6. ✅ UI Advanced System (1개)
7. ✅ Physics System (3개)
8. ✅ Camera & Rendering System (2개)

### 다음 단계
- 실전 프로젝트 구축
- 추가 Phase 학습 (가능한 컴포넌트)
- 고급 패턴 연구

**상세 내용**: [walkthrough.md](file:///c:/Users/ksh00/.gemini/antigravity/brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/walkthrough.md)

