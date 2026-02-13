# MapleStory Worlds 전체 Components 마스터 플랜

> **목표**: 100개 이상의 모든 Components를 완벽히 학습하여 베테랑 개발자급 가이드 제공  
> **현재 진행**: 12개 완료 / 100개+ 전체  
> **예상 소요**: 약 20-30시간

---

## 📊 학습 현황

### ✅ 완료 (12개)
- Transform, SpriteRenderer, Text, UITransform, Rigidbody, Trigger
- Button, TextInput, Camera, Map, TileMap, Player

### 📝 남은 Components (90개+)

---

## 🎯 학습 우선순위 및 순서

### Phase 1: 플레이어/캐릭터 시스템 (20개)
**우선순위**: ⭐⭐⭐⭐⭐

#### 1.1 Player/Movement (완료 2개 + 추가 2개)
- [x] PlayerComponent
- [ ] PlayerControllerComponent - 플레이어 입력 제어
- [ ] MovementComponent - 이동 기능
- [ ] ChatComponent - 채팅 기능

#### 1.2 Avatar 시스템 (8개)
- [ ] AvatarRendererComponent - 아바타 렌더링
- [ ] AvatarGUIRendererComponent - GUI 아바타
- [ ] AvatarBodyActionSelectorComponent - 몸 동작 선택
- [ ] AvatarFaceActionSelectorComponent - 표정 선택
- [ ] AvatarStateAnimationComponent - 상태 애니메이션
- [ ] CostumeManagerComponent - 코스튬 관리
- [ ] NameTagComponent - 이름표
- [ ] ChatBalloonComponent - 채팅 말풍선

#### 1.3 AI 시스템 (3개)
- [ ] AIComponent - AI 기본 (행동 트리)
- [ ] AIChaseComponent - 추적 AI
- [ ] AIWanderComponent - 배회 AI

---

### Phase 2: 전투/상호작용 시스템 (6개)
**우선순위**: ⭐⭐⭐⭐⭐

- [ ] AttackComponent - 공격 기능
- [ ] HitComponent - 피격 처리
- [ ] DamageSkinComponent - 데미지 표시
- [ ] DamageSkinSettingComponent - 데미지 설정
- [ ] DamageSkinSpawnerComponent - 데미지 생성
- [ ] HitEffectSpawnerComponent - 피격 이펙트
- [ ] InteractionComponent - 상호작용

---

### Phase 3: 애니메이션/상태 시스템 (7개)
**우선순위**: ⭐⭐⭐⭐

- [ ] StateComponent - 상태 관리
- [ ] StateAnimationComponent - 상태 기반 애니메이션
- [ ] StateStringToAvatarActionComponent - 상태→아바타 동작
- [ ] StateStringToMonsterActionComponent - 상태→몬스터 동작
- [ ] TweenBaseComponent - 트윈 기본
- [ ] TweenCircularComponent - 원형 트윈
- [ ] TweenFloatingComponent - 부유 트윈
- [ ] TweenLineComponent - 직선 트윈

---

### Phase 4: 물리/충돌 시스템 (13개)
**우선순위**: ⭐⭐⭐⭐

#### 4.1 Physics (완료 1개 + 추가 4개)
- [x] RigidbodyComponent
- [ ] PhysicsRigidbodyComponent - 물리 리지드바디
- [ ] PhysicsColliderComponent - 물리 충돌체
- [ ] PhysicsSimulatorComponent - 물리 시뮬레이터
- [ ] KinematicbodyComponent - 키네마틱 바디
- [ ] SideviewbodyComponent - 사이드뷰 바디

#### 4.2 Joints (6개)
- [ ] DistanceJointComponent - 거리 조인트
- [ ] RevoluteJointComponent - 회전 조인트
- [ ] PrismaticJointComponent - 직선 조인트
- [ ] PulleyJointComponent - 도르래 조인트
- [ ] WeldJointComponent - 용접 조인트
- [ ] WheelJointComponent - 바퀴 조인트

#### 4.3 Foothold (완료 1개 + 추가 1개)
- [x] TriggerComponent
- [ ] FootholdComponent - 발판
- [ ] CustomFootholdComponent - 커스텀 발판

---

### Phase 5: 맵/타일 시스템 (9개)
**우선순위**: ⭐⭐⭐⭐

- [x] MapComponent
- [x] TileMapComponent
- [ ] MapLayerComponent - 맵 레이어
- [ ] RectTileMapComponent - 사각형 타일맵
- [ ] ClimbableComponent - 등반 가능 오브젝트
- [ ] ClimbableSpriteRendererComponent - 등반 스프라이트
- [ ] PortalComponent - 포탈
- [ ] SpawnLocationComponent - 스폰 위치
- [ ] WorldComponent - 월드
- [ ] GridComponent - 그리드

---

### Phase 6: UI 시스템 (12개)
**우선순위**: ⭐⭐⭐⭐

- [x] ButtonComponent
- [x] TextComponent
- [x] TextInputComponent
- [x] UITransformComponent
- [ ] UIGroupComponent - UI 그룹
- [ ] SliderComponent - 슬라이더
- [ ] GridViewComponent - 그리드 뷰
- [ ] ScrollLayoutGroupComponent - 스크롤 레이아웃
- [ ] CanvasGroupComponent - 캔버스 그룹
- [ ] JoystickComponent - 조이스틱
- [ ] TouchReceiveComponent - 터치 수신
- [ ] UITouchReceiveComponent - UI 터치 수신
- [ ] TextGUIRendererInputComponent - GUI 텍스트 입력

---

### Phase 7: 렌더링 시스템 (18개)
**우선순위**: ⭐⭐⭐

#### 7.1 기본 렌더링 (완료 2개 + 추가 4개)
- [x] SpriteRendererComponent
- [x] CameraComponent
- [ ] SpriteGUIRendererComponent - GUI 스프라이트
- [ ] ImageComponent - 이미지
- [ ] BackgroundComponent - 배경
- [ ] MaskComponent - 마스크

#### 7.2 Skeleton (2개)
- [ ] SkeletonRendererComponent - 스켈레톤 렌더링
- [ ] SkeletonGUIRendererComponent - GUI 스켈레톤

#### 7.3 Pixel (2개)
- [ ] PixelRendererComponent - 픽셀 렌더링
- [ ] PixelGUIRendererComponent - GUI 픽셀

#### 7.4 Line (2개)
- [ ] LineRendererComponent - 라인 렌더링
- [ ] LineGUIRendererComponent - GUI 라인

#### 7.5 Polygon (2개)
- [ ] PolygonRendererComponent - 다각형 렌더링
- [ ] PolygonGUIRendererComponent - GUI 다각형

#### 7.6 Text Renderer (2개)
- [ ] TextRendererComponent - 텍스트 렌더링
- [ ] TextGUIRendererComponent - GUI 텍스트

#### 7.7 RawImage (2개)
- [ ] RawImageRendererComponent - Raw 이미지
- [ ] RawImageGUIRendererComponent - GUI Raw 이미지

#### 7.8 Light (2개)
- [ ] OverlayLightComponent - 오버레이 조명
- [ ] LightComponent - 일반 조명

---

### Phase 8: 파티클/이펙트 시스템 (10개)
**우선순위**: ⭐⭐⭐

#### 8.1 World Particles (4개)
- [ ] BaseParticleComponent - 파티클 기본 (추상)
- [ ] BasicParticleComponent - 기본 파티클
- [ ] AreaParticleComponent - 영역 파티클
- [ ] SpriteParticleComponent - 스프라이트 파티클

#### 8.2 UI Particles (4개)
- [ ] UIBaseParticleComponent - UI 파티클 기본
- [ ] UIBasicParticleComponent - UI 기본 파티클
- [ ] UIAreaParticleComponent - UI 영역 파티클
- [ ] UISpriteParticleComponent - UI 스프라이트 파티클

---

### Phase 9: 사운드/멀티미디어 (6개)
**우선순위**: ⭐⭐⭐

- [ ] SoundComponent - 사운드 재생
- [ ] YoutubePlayerCommonComponent - YouTube 공통
- [ ] YoutubePlayerGUIComponent - YouTube GUI
- [ ] YoutubePlayerWorldComponent - YouTube 월드
- [ ] WebViewComponent - 웹뷰
- [ ] WebSpriteComponent - 웹 스프라이트

---

### Phase 10: 유틸리티 (4개)
**우선순위**: ⭐⭐

- [ ] TagComponent - 태그 부여
- [ ] InventoryComponent - 인벤토리 관리
- [ ] DirectionSynchronizerComponent - 방향 동기화

---

## 📋 학습 방법론

### 각 Component 학습 시 포함할 내용:

1. **개요**
   - 용도 및 필수도
   - 핵심 기능 요약

2. **Properties**
   - 모든 프로퍼티 목록
   - 타입, Sync 여부, 설명
   - 중요 프로퍼티 강조

3. **Methods**
   - 모든 메서드 목록
   - 파라미터, 리턴 타입
   - Server/Client 구분

4. **Events**
   - 모든 이벤트 목록
   - 발생 조건, Space 정보

5. **사용 패턴**
   - 실전 예제 코드
   - 일반적인 사용 사례
   - 주의사항 및 팁

6. **통합 패턴**
   - 다른 Components와의 조합
   - 시스템 구축 예제

---

## 🎯 예상 일정

- **Phase 1-2** (플레이어/전투): 2-3일
- **Phase 3-4** (애니메이션/물리): 2-3일
- **Phase 5-6** (맵/UI): 2-3일
- **Phase 7-8** (렌더링/파티클): 2-3일
- **Phase 9-10** (사운드/유틸): 1-2일

**총 예상**: 9-14일

---

## 📚 참고 자료

- [Components 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Components)
- 기존 학습 문서: `core_components_guide.md`, `additional_components_guide.md`
