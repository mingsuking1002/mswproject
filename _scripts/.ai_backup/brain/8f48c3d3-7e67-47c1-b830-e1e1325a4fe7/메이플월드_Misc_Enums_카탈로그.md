# 메이플스토리 월드 Misc & Enums 타입 카탈로그

> 이 문서는 메이플스토리 월드의 고유 타입(Misc)과 열거형(Enums)을 정리한 카탈로그입니다.

---

# Part 1: Misc (고유 타입, 총 100개+)

## 1. Misc 개요

**Misc**는 메이플스토리 월드에서만 사용하는 **고유한 타입**을 의미합니다.
- 프로퍼티, 생성자, 함수를 가집니다
- 주로 좌표, 색상, 데이터 저장소, 물리 등 데이터 구조를 정의합니다

---

## 2. Misc 분류표

### 2.1 📐 벡터/색상/기본 타입 (12개)

| 타입 | 설명 |
|------|------|
| `Vector2` | 2D 벡터 (x, y) |
| `Vector2Int` | 2D 정수 벡터 |
| `Vector3` | 3D 벡터 (x, y, z) |
| `Vector4` | 4D 벡터 |
| `FastVector2` | 고속 2D 벡터 |
| `FastVector3` | 고속 3D 벡터 |
| `Quaternion` | 쿼터니언 (회전) |
| `Color` | RGBA 색상 |
| `FastColor` | 고속 색상 |
| `RectOffset` | 사각형 오프셋 |
| `DateTime` | 날짜/시간 |
| `TimeSpan` | 시간 간격 |

---

### 2.2 🏢 엔티티/컴포넌트 참조 (4개)

| 타입 | 설명 |
|------|------|
| `Entity` | 게임 오브젝트 |
| `EntityRef` | 엔티티 참조 |
| `ComponentRef` | 컴포넌트 참조 |
| `DataRef` | 데이터 참조 |

---

### 2.3 📦 데이터 저장소 (20개+)

| 타입 | 설명 |
|------|------|
| `DataStorage` | 기본 데이터 저장소 |
| `DataStorageItem` | 저장소 아이템 |
| `DataStorageItemPages` | 저장소 아이템 페이지 |
| `DataStorageKeyInfo` | 저장소 키 정보 |
| `DataStorageVersionInfo` | 저장소 버전 정보 |
| `DataStorageVersionPages` | 저장소 버전 페이지 |
| `CreatorDataStorage` | 크리에이터 데이터 저장소 |
| `GlobalDataStorage` | 글로벌 데이터 저장소 |
| `GlobalDataStoragePages` | 글로벌 저장소 페이지 |
| `SortableDataStorage` | 정렬 가능 저장소 |
| `SortableDataStorageItem` | 정렬 가능 아이템 |
| `SortableDataStorageItemPages` | 정렬 가능 아이템 페이지 |
| `SortableDataStoragePages` | 정렬 가능 저장소 페이지 |
| `UserDataStorage` | 유저 데이터 저장소 |
| `UserDataStoragePages` | 유저 저장소 페이지 |
| `UserDataRow` | 유저 데이터 행 |
| `UserDataSet` | 유저 데이터 세트 |

---

### 2.4 📋 컬렉션/자료구조 (8개)

| 타입 | 설명 |
|------|------|
| `List` | 리스트 |
| `ReadOnlyList` | 읽기 전용 리스트 |
| `Dictionary` | 딕셔너리 |
| `ReadOnlyDictionary` | 읽기 전용 딕셔너리 |
| `SyncList` | 동기화 리스트 |
| `SyncDictionary` | 동기화 딕셔너리 |
| `SharedVariableInfo` | 공유 변수 정보 |
| `SharedVariableKeyInfo` | 공유 변수 키 정보 |

---

### 2.5 ⚙️ 물리/충돌/조인트 (15개)

| 타입 | 설명 |
|------|------|
| `BoxShape` | 박스 형태 |
| `CircleShape` | 원형 형태 |
| `PolygonShape` | 다각형 형태 |
| `Shape` | 형태 기본 클래스 |
| `CollisionGroup` | 충돌 그룹 |
| `CollisionMapService` | 충돌 맵 서비스 |
| `CollisionSimulator` | 충돌 시뮬레이터 |
| `Foothold` | 발판 |
| `DistanceJoint` | 거리 조인트 |
| `RevoluteJoint` | 회전 조인트 |
| `PrismaticJoint` | 직선 조인트 |
| `PulleyJoint` | 도르래 조인트 |
| `WeldJoint` | 용접 조인트 |
| `WheelJoint` | 바퀴 조인트 |

---

### 2.6 💡 조명 (8개)

| 타입 | 설명 |
|------|------|
| `AttachedFreeformTypeOverlayLightInfo` | 자유형 오버레이 조명 |
| `AttachedGlobalTypeOverlayLightInfo` | 글로벌 오버레이 조명 |
| `AttachedSpotTypeOverlayLightInfo` | 스팟 오버레이 조명 |
| `AttachedSpriteTypeOverlayLightInfo` | 스프라이트 오버레이 조명 |
| `FreeformTypeOverlayLightInfo` | 자유형 조명 정보 |
| `GlobalTypeOverlayLightInfo` | 글로벌 조명 정보 |
| `SpotTypeOverlayLightInfo` | 스팟 조명 정보 |
| `SpriteTypeOverlayLightInfo` | 스프라이트 조명 정보 |

---

### 2.7 🏠 월드/룸/인스턴스 (8개)

| 타입 | 설명 |
|------|------|
| `Environment` | 환경 설정 |
| `InstanceRoom` | 인스턴스 룸 |
| `RoomSharedMemory` | 룸 공유 메모리 |
| `WorldInstanceInfo` | 월드 인스턴스 정보 |
| `WorldInstanceInfoPages` | 월드 인스턴스 페이지 |
| `WorldInstanceSharedMemory` | 월드 공유 메모리 |
| `WarpRecord` | 워프 기록 |

---

### 2.8 🛒 상점/아이템/배지 (10개)

| 타입 | 설명 |
|------|------|
| `Item` | 아이템 |
| `BadgeInfo` | 배지 정보 |
| `BadgeInfoPages` | 배지 페이지 |
| `WorldShopProduct` | 월드 상점 상품 |
| `WorldShopProductPages` | 상점 상품 페이지 |
| `WorldShopPurchaseInfo` | 상점 구매 정보 |
| `PurchaseLogPages` | 구매 로그 페이지 |
| `PolicyInfo` | 정책 정보 |

---

### 2.9 🎬 애니메이션/스프라이트 (5개)

| 타입 | 설명 |
|------|------|
| `AnimationClip` | 애니메이션 클립 |
| `SkeletonAnimationClip` | 스켈레톤 애니메이션 클립 |
| `Sprite` | 스프라이트 |
| `RawImage` | 원시 이미지 |
| `AvatarBodyActionElement` | 아바타 바디 액션 요소 |

---

### 2.10 🔤 정규식 (5개)

| 타입 | 설명 |
|------|------|
| `Regex` | 정규식 |
| `RegexMatch` | 정규식 매치 |
| `RegexGroup` | 정규식 그룹 |
| `RegexCapture` | 정규식 캡처 |

---

### 2.11 🌳 AI 행동트리 (6개)

| 타입 | 설명 |
|------|------|
| `BTNode` | 행동트리 노드 |
| `CompositeNode` | 복합 노드 |
| `SelectorNode` | 선택자 노드 |
| `SequenceNode` | 시퀀스 노드 |
| `ParallelNode` | 병렬 노드 |
| `RandomSelectorNode` | 랜덤 선택자 노드 |

---

### 2.12 📱 기타 유틸리티 (10개+)

| 타입 | 설명 |
|------|------|
| `User` | 유저 |
| `Translator` | 번역기 |
| `Tweener` | 트위너 |
| `ResourceObject` | 리소스 오브젝트 |
| `MicrophoneDevice` | 마이크 장치 |
| `LinePoint` | 라인 포인트 |
| `RectTileInfo` | 사각형 타일 정보 |
| `TextRendererSpacingOption` | 텍스트 간격 옵션 |
| `StateType` | 상태 타입 |
| `SharedVariableResult` | 공유 변수 결과 |

---

## 3. 주요 타입 상세

### 3.1 Vector2

```lua
local pos = Vector2(100, 200)
local distance = Vector2.Distance(pos1, pos2)
```

### 3.2 Color

```lua
local red = Color(1, 0, 0, 1)
self.Entity.SpriteRendererComponent.Color = red
```

### 3.3 DateTime / TimeSpan

```lua
local now = DateTime.Now
local duration = TimeSpan.FromSeconds(5)
```

---

# Part 2: Enums (열거형, 총 100개)

## 4. Enums 개요

**Enums**는 서로 연결된 **상수 값의 집합**입니다.
- 특정 상태나 옵션을 명확하게 표현
- 코드 가독성 향상

---

## 5. Enums 분류표

### 5.1 ⌨️ 입력 관련 (5개)

| Enum | 설명 |
|------|------|
| `KeyboardKey` | 키보드 키 코드 |
| `CursorLockMode` | 커서 잠금 모드 |
| `InputContentType` | 입력 콘텐츠 타입 |
| `InputLineType` | 입력 라인 타입 |
| `DragMode` | 드래그 모드 |

---

### 5.2 ⚙️ 물리/충돌 (5개)

| Enum | 설명 |
|------|------|
| `BodyType` | 물리 바디 타입 (Static, Dynamic, Kinematic) |
| `ColliderType` | 충돌체 타입 (Box, Circle, Polygon) |
| `PhysicsCollisionDetectionMode` | 물리 충돌 감지 모드 |
| `PhysicsSleepingMode` | 물리 슬리핑 모드 |
| `RigidbodyMovementOptionType` | 리지드바디 이동 옵션 |

---

### 5.3 🎨 UI/레이아웃 (25개+)

| Enum | 설명 |
|------|------|
| `AlignmentType` | 정렬 타입 |
| `TextAlignmentType` | 텍스트 정렬 (9방향) |
| `TextHorizontalAlignmentOption` | 텍스트 수평 정렬 |
| `TextVerticalAlignmentOption` | 텍스트 수직 정렬 |
| `TextOverflowMode` | 텍스트 오버플로우 모드 |
| `FontStyleType` | 폰트 스타일 |
| `FontType` | 폰트 타입 |
| `ChildAlignmentType` | 자식 정렬 타입 |
| `GridLayoutAxis` | 그리드 레이아웃 축 |
| `GridLayoutConstraint` | 그리드 레이아웃 제약 |
| `GridLayoutCorner` | 그리드 레이아웃 코너 |
| `GridViewFixedType` | 그리드뷰 고정 타입 |
| `LayoutGroupType` | 레이아웃 그룹 타입 |
| `FillMethodType` | 채우기 방법 |
| `ImageType` | 이미지 타입 |
| `MaskShape` | 마스크 형태 |
| `OverflowType` | 오버플로우 타입 |
| `ScrollBarVisibility` | 스크롤바 가시성 |
| `HorizontalScrollBarDirection` | 수평 스크롤바 방향 |
| `VerticalScrollBarDirection` | 수직 스크롤바 방향 |
| `SliderDirection` | 슬라이더 방향 |
| `ButtonState` | 버튼 상태 |
| `UIGroupType` | UI 그룹 타입 |
| `UIModeType` | UI 모드 타입 |
| `UITransformAxis` | UI 트랜스폼 축 |

---

### 5.4 🎬 애니메이션/트윈 (12개)

| Enum | 설명 |
|------|------|
| `EaseType` | 이징 타입 |
| `TweenState` | 트윈 상태 |
| `TweenLoopType` | 트윈 루프 타입 |
| `TweenSyncType` | 트윈 동기화 타입 |
| `TweenLinearStopType` | 트윈 직선 정지 타입 |
| `SpriteAnimClipPlayType` | 스프라이트 애니메이션 재생 타입 |
| `SpriteAnimPlayerState` | 스프라이트 애니메이션 플레이어 상태 |
| `SpriteDrawMode` | 스프라이트 그리기 모드 |
| `MaterialAnimationClipFilterMode` | 머티리얼 애니메이션 필터 모드 |
| `MaterialAnimationClipWrapMode` | 머티리얼 애니메이션 래핑 모드 |
| `TransitionType` | 전환 타입 |
| `InterpolationType` | 보간 타입 |

---

### 5.5 🎭 아바타/캐릭터 (5개)

| Enum | 설명 |
|------|------|
| `MapleAvatarBodyActionState` | 아바타 몸 액션 상태 (Stand, Walk, Attack 등) |
| `MapleAvatarFaceActionState` | 아바타 표정 상태 |
| `MapleAvatarItemCategory` | 아바타 아이템 카테고리 |
| `MapleAvatarWeaponPoseType` | 아바타 무기 포즈 타입 |
| `EmotionalType` | 감정 타입 |

---

### 5.6 💡 조명/시각 (6개)

| Enum | 설명 |
|------|------|
| `LightType` | 조명 타입 |
| `LitMode` | 라이트 모드 |
| `LightOverlapOperation` | 조명 오버랩 연산 |
| `GradientModes` | 그라디언트 모드 |
| `BackgroundType` | 배경 타입 |
| `AutomaticLayerOption` | 자동 레이어 옵션 |

---

### 5.7 📹 카메라 (2개)

| Enum | 설명 |
|------|------|
| `CameraBlendType` | 카메라 블렌드 타입 |
| `AxisType` | 축 타입 |

---

### 5.8 🔊 사운드 (1개)

| Enum | 설명 |
|------|------|
| `SoundPlayState` | 사운드 재생 상태 |

---

### 5.9 ✨ 파티클 (8개)

| Enum | 설명 |
|------|------|
| `AreaParticleType` | 영역 파티클 타입 |
| `BasicParticleType` | 기본 파티클 타입 |
| `SpriteParticleType` | 스프라이트 파티클 타입 |
| `UIAreaParticleType` | UI 영역 파티클 타입 |
| `UIBasicParticleType` | UI 기본 파티클 타입 |
| `UISpriteParticleType` | UI 스프라이트 파티클 타입 |

---

### 5.10 🏠 맵/월드 (8개)

| Enum | 설명 |
|------|------|
| `TileMapMode` | 타일맵 모드 |
| `ClimbableType` | 등반 가능 타입 |
| `CoordinateType` | 좌표 타입 |
| `Division` | 분할 |
| `DynamicMapResultCode` | 동적 맵 결과 코드 |
| `InteractType` | 상호작용 타입 |
| `PreserveSpriteType` | 스프라이트 보존 타입 |
| `DayOfWeekType` | 요일 타입 |

---

### 5.11 🛒 상점/배지 (5개)

| Enum | 설명 |
|------|------|
| `BadgeGrade` | 배지 등급 |
| `BadgeStatus` | 배지 상태 |
| `WorldShopProductStatus` | 월드 상점 상품 상태 |
| `WorldShopProductType` | 월드 상점 상품 타입 |

---

### 5.12 🌐 네트워크/시스템 (12개)

| Enum | 설명 |
|------|------|
| `AccountRegion` | 계정 지역 |
| `AccountTrustLevel` | 계정 신뢰 레벨 |
| `HttpContentType` | HTTP 콘텐츠 타입 |
| `KickReason` | 강퇴 사유 |
| `NexonOtpStateType` | 넥슨 OTP 상태 |
| `PlatformType` | 플랫폼 타입 |
| `PreloadResultStatus` | 프리로드 결과 상태 |
| `ResourceType` | 리소스 타입 |
| `ResourceUploadError` | 리소스 업로드 에러 |
| `ScreenRecordMode` | 화면 녹화 모드 |
| `ScreenRecordStartResult` | 화면 녹화 시작 결과 |
| `ScreenshotError` | 스크린샷 에러 |

---

### 5.13 🔧 기타 (10개+)

| Enum | 설명 |
|------|------|
| `BehaviourTreeStatus` | 행동트리 상태 |
| `DamageSkinTextType` | 데미지 스킨 텍스트 타입 |
| `DamageSkinTweenType` | 데미지 스킨 트윈 타입 |
| `HitFeedbackAction` | 피격 피드백 액션 |
| `RegexOption` | 정규식 옵션 |
| `SendEventRequestResultCode` | 이벤트 전송 결과 코드 |
| `SharedMemoryResultCode` | 공유 메모리 결과 코드 |
| `SortDirection` | 정렬 방향 |
| `UpdateAuthorityType` | 업데이트 권한 타입 |

---

## 6. 주요 Enum 상세

### 6.1 KeyboardKey

```lua
if event.key == KeyboardKey.Space then
    self:Jump()
elseif event.key == KeyboardKey.W then
    self:MoveUp()
end
```

### 6.2 BodyType

| 값 | 설명 |
|----|------|
| `Static` | 움직이지 않음 |
| `Dynamic` | 물리 엔진 제어 |
| `Kinematic` | 스크립트 제어 |

### 6.3 MapleAvatarBodyActionState

| 값 | 설명 |
|----|------|
| `Stand` | 서있기 |
| `Walk` | 걷기 |
| `Attack` | 공격 |
| `Jump` | 점프 |
| `Fall` | 낙하 |
| `Sit` | 앉기 |
| `Dead` | 사망 |

---

## 7. 참고 링크

- [Enums 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Enums)
- [Misc 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Misc)


- [Misc 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Misc)
- [Enums 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Enums)

