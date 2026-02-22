
# Code Documentation

## Phase 0-2 Modular Refactor
- **수정일:** `2026-02-18`
- **범위:** `GRUtilModule + Core 2종 + Combat 4종 (총 7개)`
- **비고:** `.mlua` 유지 + `.codeblock(Target mLua)` 동기화 대상

## GRUtilModule
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/GRUtilModule.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 유틸 API 제공 컴포넌트로 별도 Property 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `BootstrapUtil` | void | table | 공통 유틸 API 테이블 생성/반환 (`self._T.UtilApi` 캐시) |
| `OnBeginPlay` | void | void | 서버에서 유틸 등록 보장 |
| `OnMapEnter` | `enteredMap: Entity` | void | 클라이언트 맵 진입 시 유틸 재등록 |

## MovementComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `SpeedMultiplier` | number | 이동 속도 배율 (Sync) |
| `CanMove` | boolean | 이동 가능 여부 (Sync) |
| `FacingDirection` | integer | 8방향 바라보기 인덱스 (Sync) |
| `MoveSpeed` | number | 기본 이동 속도 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 입력 캐시 초기화 및 유틸 부트스트랩 |
| `OnBeginPlay` | void | void | 클라이언트 유틸 부트스트랩 |
| `HandleKeyDownEvent` | `event: KeyDownEvent` | void | 이동 키 입력 시작 시 의도 전송 |
| `HandleKeyUpEvent` | `event: KeyUpEvent` | void | 이동 키 해제 시 의도 전송 |
| `SubmitMoveInput` | `moveDirection: Vector2` | void | 서버 권위 입력 반영(소유자 검증 포함) |
| `OnUpdate` | `delta: number` | void | 서버 이동/방향/상태 업데이트 |
| `ApplyMovementServer` | `moveDirection: Vector2, speed: number, delta: number` | void | Rigidbody 우선 이동 적용 |
| `UpdateStateAnimation` | `moveDirection: Vector2` | void | MOVE/IDLE 상태 동기화 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## CameraFollowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CameraOffset` | Vector2 | 카메라 중심 오프셋 |
| `MapBoundsMin` | Vector2 | 카메라 경계 최소 좌표 |
| `MapBoundsMax` | Vector2 | 카메라 경계 최대 좌표 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 클라이언트 시작 시 카메라 세팅 적용 |
| `OnMapEnter` | `enteredMap: Entity` | void | 맵 진입 시 카메라 경계 재적용 |
| `ApplyCameraSettings` | void | void | 현재 카메라 컴포넌트에 Bound/Offset 적용 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## GoldComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/GoldComponent.mlua`
- **수정일:** `2026-02-19`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentGold` | integer | 현재 보유 골드 (Sync) |
| `InitialGold` | integer | 시작 시 지급 골드 |
| `MaxGold` | integer | 골드 최대 보유 한도 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 유틸 부트스트랩 초기화 |
| `OnBeginPlay` | void | void | 서버 권위 시작 골드 초기화 |
| `SpendGold` | `amount: integer` | boolean | 유효 금액/잔액 검증 후 골드 차감 |
| `AddGold` | `amount: integer` | void | 골드 획득 처리 및 최대치 클램프 |
| `CanAfford` | `amount: integer` | boolean | 현재 골드 기반 구매 가능 여부 판정 |
| `ResetGold` | void | void | 로비 복귀 시 시작 골드로 재설정 |
| `NormalizeAmount` | `amount: integer` | integer | 입력 금액 정규화(음수 방지) |
| `ClampGold` | `value: integer` | integer | 골드 값을 0~MaxGold 범위로 제한 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## HPSystemComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MaxHP` | integer | 최대 체력 (Sync) |
| `CurrentHP` | integer | 현재 체력 (Sync) |
| `IsInvincible` | boolean | 무적 상태 (Sync) |
| `IsDead` | boolean | 사망 상태 (Sync) |
| `DamageReduction` | integer | 고정 피해 감소량 |
| `InvincibleDuration` | number | 피격 후 무적 지속시간 |
| `CriticalHPRatio` | number | 위험 체력 비율 임계값 |
| `FallbackDamage` | integer | 외부 공격 정보 미탐지 시 기본 피해 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | HP/사망/무적 초기화 |
| `OnBeginPlay` | void | void | 초기 HP 상태 브로드캐스트 |
| `HandleTriggerEnterEvent` | `event: TriggerEnterEvent` | void | 충돌 기반 피해 진입점 |
| `ResolveIncomingDamage` | `sourceEntity: Entity` | integer | 투사체/몬스터 공격력 해석 |
| `ApplyDamage` | `rawDamage: integer` | void | 피해 적용 및 사망 판정 |
| `StartInvincibleWindow` | void | void | 무적 타이머 시작/갱신 |
| `Heal` | `amount: integer` | void | 회복 처리 |
| `ReviveToFullHP` | void | void | 부활 초기화 |
| `NotifyGameOver` | void | void | LobbyFlow/GameManager/타이머 순으로 종료 라우팅 |
| `UpdateHPFeedbackClient` | `currentHp, maxHp, isInvincible, isDead` | void | 클라이언트 전용 피드백 반영 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## ReloadComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentAmmo` | integer | 현재 탄약 (Sync) |
| `IsReloading` | boolean | 재장전 진행 상태 (Sync) |
| `CurrentWeaponSlot` | integer | 현재 무기 슬롯 (Sync) |
| `MaxAmmo` | integer | 최대 탄약 |
| `ReloadTime` | number | 재장전 소요 시간 |
| `FireRate` | number | 발사 간격 |
| `WeaponSlotCount` | integer | 지원 슬롯 수 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 슬롯별 탄약/쿨다운 테이블 초기화 |
| `OnBeginPlay` | void | void | 클라이언트 유틸 부트스트랩 |
| `HandleKeyDownEvent` | `event: KeyDownEvent` | void | R 입력 시 서버 재장전 요청 |
| `RequestReloadServer` | void | void | 서버 소유자 검증 후 재장전 시작 |
| `StartReloadForSlot` | `slot: integer` | void | 슬롯별 재장전 타이머 시작 |
| `CompleteReload` | `slot: integer` | void | 재장전 완료 시 탄약 보충 |
| `CancelCurrentReload` | void | void | 현재 슬롯 재장전 취소 |
| `SetCurrentWeaponSlot` | `slot: integer` | void | 슬롯 전환/탄약 복원 |
| `ConsumeAmmoOnFire` | void | boolean | 발사 시 탄약 소비 및 다음 발사 시각 갱신 |
| `IsFireReady` | void | boolean | 슬롯별 연사 가능 여부 판정 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## FireSystemComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsFireReady` | boolean | 발사 가능 상태 (Sync) |
| `CanAttack` | boolean | 공격 가능 상태 (Sync) |
| `FireCooldown` | number | 발사 쿨다운 |
| `MuzzleOffset` | Vector2 | 총구 오프셋 |
| `ProjectileModelId` | string | 모델 ID 기반 투사체 스폰 키 |
| `ProjectileTemplateEntity` | Entity | 템플릿 엔티티 기반 스폰 참조 |
| `BaseWeaponAttack` | integer | 기본 공격력 |
| `PassiveFlatAttack` | integer | 고정 보너스 공격력 |
| `BuffIncreasePercent` | number | 버프 퍼센트 증가 |
| `PassiveIncreasePercent` | number | 패시브 퍼센트 증가 |
| `ProjectileSpeed` | number | 투사체 속도 |
| `ProjectileRange` | number | 투사체 최대 사거리 |
| `ProjectileLifetime` | number | 투사체 생존 시간 |
| `ProjectileSpread` | number | 투사체 산포각 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 발사 쿨다운 상태 초기화 |
| `OnBeginPlay` | void | void | 클라이언트 유틸 부트스트랩 |
| `HandleScreenTouchEvent` | `event: ScreenTouchEvent` | void | 터치 입력을 발사 요청으로 변환 |
| `RequestFireServer` | `targetWorldPosition: Vector2` | void | 서버 소유자 검증 후 발사 시도 |
| `CanFireServer` | void | boolean | 탄약/재장전/쿨다운/스폰 조건 종합 판정 |
| `SpawnProjectileServer` | `direction: Vector2, shooterPosition: Vector2` | void | 투사체 생성 및 초기화 |
| `CalculateFinalDamage` | void | integer | 최종 공격력 공식 계산 |
| `StartFireCooldown` | void | void | 발사 쿨다운 타이머 시작 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## ProjectileComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Speed` | number | 투사체 속도 |
| `MaxRange` | number | 최대 이동 거리 |
| `Lifetime` | number | 최대 생존 시간 |
| `Damage` | integer | 충돌 피해량 |
| `Spread` | number | 발사 산포각 |
| `MoveDirection` | Vector2 | 현재 이동 방향 |
| `StartPosition` | Vector2 | 시작 위치 |
| `OwnerEntity` | Entity | 소유자 엔티티 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 수명/파괴 플래그 초기화 |
| `InitializeProjectile` | `direction: Vector2, spawnPosition: Vector2, ownerEntity: Entity` | void | 발사 스냅샷 초기화 |
| `ApplySpread` | `direction: Vector2` | Vector2 | 초기 산포각 반영 |
| `OnUpdate` | `delta: number` | void | 이동/거리/수명 서버 판정 |
| `HandleTriggerEnterEvent` | `event: TriggerEnterEvent` | void | 충돌 피해 적용 후 파괴 |
| `DestroySelf` | void | void | 중복 파괴 방지 포함 단일 파괴 경로 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## Phase 3 Meta Modular Refactor
- **수정일:** `2026-02-19`
- **범위:** `WeaponSwapComponent + ShopManagerComponent + TagManagerComponent + SpeedrunTimerComponent + RankingComponent`

## WeaponSwapComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **수정일:** `2026-02-19`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentWeaponSlot` | integer | 현재 무기 슬롯 (Sync) |
| `WeaponSlotCount` | integer | 총 슬롯 수 |
| `IsSwapMenuOpen` | boolean | 교체 메뉴 열림 상태 (Sync) |
| `Weapon1_Data` | table | 슬롯1 무기 데이터 |
| `Weapon2_Data` | table | 슬롯2 무기 데이터 |
| `Weapon3_Data` | table | 슬롯3 무기 데이터 |
| `Weapon4_Data` | table | 슬롯4 무기 데이터 |
| `PauseGameplayByFlag` | boolean | 메뉴 오픈 시 로직 일시정지 플래그 사용 여부 |
| `UseClientTimeScalePause` | boolean | 클라이언트 타임스케일 일시정지 사용 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RequestOpenSwapMenuServer` | void | void | F 입력 기반 무기 메뉴 오픈 요청 |
| `IsShopInteractionPreferredServer` | `requestUserId: string` | boolean | 상점 상호작용이 우선인 상황(상점 열림/상호작용 가능 거리) 판정 |
| `RequestCancelSwapMenuServer` | void | void | 메뉴 취소/닫기 요청 |
| `RequestConfirmSwapServer` | `selectedSlot: integer` | void | 슬롯 확정 요청 |
| `ConfirmSwapServer` | `selectedSlot: integer` | void | 슬롯 확정 후 무기 상태 스왑 |
| `CaptureRuntimeToSlot` | `slot: integer` | void | 현재 전투 상태를 슬롯 데이터로 백업 |
| `ApplySlotDataToCombat` | `slot: integer` | void | 슬롯 데이터 적용(재장전/발사 파라미터 동기화) |
| `ExportWeaponSwapState` | void | table | 태그 시스템용 전체 슬롯 상태 내보내기 |
| `ImportWeaponSwapState` | `state: table` | void | 태그 시스템에서 받은 슬롯 상태 복원 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## ShopManagerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **수정일:** `2026-02-19`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsShopOpen` | boolean | 상점 UI 열림 상태 (Sync) |
| `ActiveShopIndex` | integer | 현재 활성 상점 인덱스 (Sync, 1~4) |
| `InteractionRange` | number | 상점 상호작용 거리(px) |
| `ShopEntity1~4` | Entity | 동/서/남/북 상점 엔티티 참조 |
| `ShopDataTableName` | string | 상점 데이터 테이블명 (`ShopItemData`) |
| `HealPercent` | number | 회복 슬롯 HP 비율 |
| `HealPrice` | integer | 회복 슬롯 가격 |
| `AmmoPrice` | integer | 탄약 슬롯 가격 |
| `PassivePrice` | integer | 패시브 슬롯 가격 |
| `Slot1~3Type/Name/Description/Price/SoldOut` | string/integer/boolean | 클라이언트 UI 렌더링용 슬롯 Sync 필드 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RequestOpenShopServer` | void | void | F 입력 기반 상점 열기 서버 요청 |
| `CanOpenShopForOwnerServer` | `requestUserId: string` | boolean | 소유자/활성 상점/거리 기반 오픈 가능 여부 판정 |
| `RequestPurchaseServer` | `slotIndex: integer` | void | 슬롯 구매 서버 처리(골드 차감/효과 적용) |
| `RequestCloseShopServer` | void | void | ESC/닫기 기반 상점 종료 요청 |
| `OpenShopServer` | void | void | 상점 오픈 + 게임플레이 잠금 + 슬롯 구성 |
| `CloseAndRotateShopServer` | void | void | 상점 종료 + 방문 상점 비활성 + 랜덤 순환 |
| `ResetShopStateServer` | void | void | 로비 복귀 시 상점 상태 초기화 |
| `ResolveShopEntitiesServer` | void | void | 맵 엔티티 기반 상점 참조 자동 탐색 |
| `LoadShopDataServer` | void | void | `ShopItemData` 로드 및 행 캐시 |
| `ApplyPurchaseEffectServer` | `slotType: string, slotData: table` | void | 회복/탄약/패시브 구매 효과 분기 |
| `SetGameplayLockServer` | `locked: boolean` | void | 이동/공격/타이머 정지 및 스왑 UI 충돌 방지 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## TagManagerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentCharIndex` | integer | 현재 활성 캐릭터 인덱스 (Sync, 1/2) |
| `TagCooldown` | number | 태그 쿨다운 |
| `IsTagReady` | boolean | 태그 가능 상태 (Sync) |
| `InvincibleTime` | number | 태그 직후 무적 시간 |
| `IsTagLocked` | boolean | 태그 금지 상태 (Sync) |
| `DisableMoveDuringTag` | boolean | 태그 연출 중 이동 잠금 사용 여부 |
| `CancelReloadOnTag` | boolean | 태그 시 재장전 취소 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RequestTagServer` | void | void | Q 입력 기반 서버 태그 요청 |
| `CanTagServer` | void | boolean | 쿨다운/사망/잠금/무기메뉴 상태 검증 |
| `ExecuteTagSwapServer` | void | void | 캐릭터 상태 저장/복원 후 인덱스 스왑 |
| `CaptureCurrentCharacterState` | void | table | HP/무기/탄약 상태 스냅샷 생성 |
| `ApplyCharacterState` | `charIndex: integer` | void | 저장된 캐릭터 상태 복원 |
| `StartTagCooldownServer` | void | void | 태그 쿨다운 타이머 시작 |
| `ApplyInvincibleWindowServer` | void | void | 태그 무적 타이머 적용 |
| `TriggerEntrySkillServer` | `charIndex: integer` | void | 태그 엔트리 스킬 훅 호출 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## SpeedrunTimerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/SpeedrunTimerComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ElapsedTime` | number | 누적 시간(초, Sync) |
| `IsRunning` | boolean | 타이머 동작 여부(Sync) |
| `CurrentStageId` | integer | 현재 스테이지 ID |
| `BestTime` | number | 현재 스테이지 최고 기록(Sync) |
| `CountdownSeconds` | number | 런 시작 카운트다운 시간 |
| `TextUpdateInterval` | number | 타이머 텍스트 갱신 주기 |
| `TimerTextEntity` | Entity | 타이머 표시 텍스트 엔티티 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `StartRunWithCountdown` | void | void | 카운트다운 후 런 시작 |
| `StartRunNow` | void | void | 즉시 런 시작 |
| `CompleteRun` | void | void | 런 종료/신기록 판정/랭킹 전달 |
| `ResetRun` | void | void | 타이머 초기화 |
| `SetPauseSource` | `sourceKey: string, shouldPause: boolean` | void | 외부 시스템의 일시정지 소스 반영 |
| `IsPausedServer` | void | boolean | 태그/무기교체/로비 상태 포함 일시정지 판정 |
| `LoadBestTimeFromStorageServer` | void | void | 사용자 저장소에서 최고기록 로드 |
| `SaveBestTimeToStorageServer` | `bestTime: number` | void | 사용자 저장소에 최고기록 저장 |
| `UpdateTimerTextClient` | `elapsedTime: number, isRunning: boolean` | void | 클라이언트 타이머 텍스트 반영 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## RankingComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/RankingComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `TimeAttackBestTime` | number | 개인 타임어택 최고 기록 |
| `InfiniteModeBestKills` | integer | 개인 무한모드 최고 처치수 |
| `DisplayCount` | integer | 기본 표시 랭킹 수 |
| `MaxRankScanCount` | integer | 내 순위 검색 최대 스캔 수 |
| `MinimumValidClearTime` | number | 최소 유효 클리어 시간(치트 필터) |
| `MaximumValidClearTime` | number | 최대 유효 클리어 시간(치트 필터) |
| `MaximumValidKills` | integer | 최대 유효 처치수(치트 필터) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `SubmitTimeAttackRecordServer` | `elapsedTime: number` | boolean | 타임어택 신기록 검증/저장/업로드 |
| `SubmitInfiniteRecordServer` | `killCount: integer` | boolean | 무한모드 신기록 검증/저장/업로드 |
| `RequestRankingSnapshotServer` | `mode: integer` | void | Top/내 순위 스냅샷 요청 처리 |
| `RequestRankingDataServer` | `mode: integer, displayCount: integer` | void | 로비 호환용 랭킹 데이터 요청 래퍼 |
| `GetTopRanksServer` | `mode: integer, count: integer` | table | 모드별 상위 랭킹 조회 |
| `GetMyRankServer` | `mode: integer` | table | 모드별 내 순위 조회 |
| `LoadLocalBestRecordsServer` | void | void | 로컬 최고기록 로드 |
| `SaveLocalBestRecordServer` | `mode: integer, value: number` | void | 로컬 최고기록 저장 |
| `FormatScoreForDisplay` | `mode: integer, scoreValue: integer` | string | UI 표기용 포맷 변환 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## Phase 4 UI/Bootstrap Modular Refactor
- **수정일:** `2026-02-19`
- **범위:** `WeaponWheelUIComponent + RankingUIComponent + HUDComponent + ShopUIComponent + Map01BootstrapComponent + LobbyFlowComponent`

## WeaponWheelUIComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `WheelRoot` | Entity | 방사형 메뉴 루트 엔티티 |
| `WheelRootPath` | string | 메뉴 루트 탐색 경로 |
| `UseRootVisibleToggle` | boolean | 루트 Enable/Visible 제어 사용 여부 |
| `HighlightScale` | number | 하이라이트 슬롯 스케일 |
| `NormalScale` | number | 기본 슬롯 스케일 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ApplyWeaponWheelStateClient` | `visible: boolean, highlightedSlot: integer, currentSlot: integer` | void | 무기휠 표시/하이라이트/현재 슬롯 반영 |
| `OnTagChangedClient` | `charIndex: integer` | void | 태그 전환 시 휠 상태 리셋 |
| `ResolveWheelRootClient` | void | Entity | 휠 루트 엔티티 참조 해결 |
| `ApplySlotVisualClient` | `slotEntity: Entity, isHighlighted: boolean, isCurrent: boolean, wheelVisible: boolean` | void | 슬롯 강조 시각효과 적용 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## RankingUIComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentTab` | integer | 현재 랭킹 탭(1=타임어택, 2=무한모드) |
| `DisplayCount` | integer | 표시할 최대 랭킹 수 |
| `RankingTextEntity` | Entity | 상위 랭킹 텍스트 엔티티 |
| `MyRankTextEntity` | Entity | 내 순위 텍스트 엔티티 |
| `RankingTextPath` | string | 랭킹 텍스트 경로 |
| `MyRankTextPath` | string | 내 순위 텍스트 경로 |
| `RefreshInterval` | number | 자동 갱신 주기 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `SetCurrentTabClient` | `tab: integer` | void | 탭 변경 및 서버 스냅샷 요청 |
| `OpenTab` | `tab: integer` | void | 로비 기본 탭 오픈용 별칭 메서드 |
| `RequestRankingSnapshotClient` | void | void | RankingComponent에 스냅샷 요청 |
| `RefreshRankingUIClient` | void | void | 최신 스냅샷 텍스트 반영 |
| `RenderRankingTextClient` | `topRows: table` | void | Top N 랭킹 리스트 렌더링 |
| `RenderMyRankTextClient` | `myRow: table` | void | 내 순위 라인 렌더링 |
| `ApplyVisibilityClient` | `visible: boolean` | void | 로비/인게임 전환 시 랭킹 UI 표시 제어 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## HUDComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/HUDComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `HPTextEntity` | Entity | HP 텍스트 엔티티 |
| `AmmoTextEntity` | Entity | 탄약 텍스트 엔티티 |
| `CooldownTextEntity` | Entity | 쿨다운 텍스트 엔티티 |
| `WeaponTextEntity` | Entity | 현재 무기 텍스트 엔티티 |
| `HPTextPath` | string | HP 텍스트 경로 |
| `AmmoTextPath` | string | 탄약 텍스트 경로 |
| `CooldownTextPath` | string | 쿨다운 텍스트 경로 |
| `WeaponTextPath` | string | 무기 텍스트 경로 |
| `UpdateInterval` | number | HUD 갱신 주기 |
| `HideInLobby` | boolean | 로비에서 HUD 숨김 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RefreshHUDClient` | void | void | HP/탄약/쿨다운/무기 슬롯 표시 갱신 |
| `ApplyLobbyStateClient` | `isLobby: boolean` | void | 로비 상태에 따른 HUD 표시 정책 적용 |
| `SetHUDVisibilityClient` | `visible: boolean` | void | HUD 텍스트 일괄 가시성 제어 |
| `StartHUDLoopClient` | void | void | 주기적 HUD 갱신 루프 시작 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## ShopUIComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/ShopUIComponent.mlua`
- **수정일:** `2026-02-19`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ShopPanelRoot` | Entity | 상점 패널 루트 UI 엔티티 |
| `ShopPanelRootPath` | string | 상점 패널 루트 경로 |
| `DimOverlayEntity` | Entity | 배경 딤 오버레이 엔티티 |
| `DimOverlayPath` | string | 배경 딤 오버레이 경로 |
| `CloseButtonEntity` | Entity | 상점 닫기 버튼 엔티티 |
| `CloseButtonPath` | string | 상점 닫기 버튼 경로 |
| `Slot1Root` | Entity | 슬롯1 루트 엔티티 |
| `Slot2Root` | Entity | 슬롯2 루트 엔티티 |
| `Slot3Root` | Entity | 슬롯3 루트 엔티티 |
| `Slot1Path` | string | 슬롯1 루트 경로 |
| `Slot2Path` | string | 슬롯2 루트 경로 |
| `Slot3Path` | string | 슬롯3 루트 경로 |
| `GoldDisplayEntity` | Entity | 골드 텍스트 엔티티 |
| `GoldDisplayPath` | string | 골드 텍스트 경로 |
| `RefreshInterval` | number | UI 동기 감시 주기 |
| `CloseDebounceSeconds` | number | 닫기 버튼 디바운스 시간 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ResolveAndBindUIClient` | void | void | 경로 기반 UI 참조 해결 + 버튼 이벤트 바인딩 |
| `RefreshShopUIStateClient` | `forceRefresh: boolean` | void | `ShopManagerComponent` Sync 상태 변화 감지 및 UI 갱신 |
| `RenderSlotsClient` | `shopManager: Component, currentGold: integer` | void | 슬롯 텍스트/가격/상태 렌더링 |
| `OnSlotButtonClickedClient` | `slotIndex: integer, event: ButtonClickEvent` | void | 슬롯 구매 버튼 클릭 처리 및 서버 구매 요청 |
| `OnCloseButtonClickedClient` | `event: ButtonClickEvent` | void | 닫기 버튼 클릭 처리 및 서버 닫기 요청 |
| `RefreshGoldDisplayClient` | `currentGold: integer` | void | 현재 골드 텍스트 갱신 |
| `SetShopVisibleClient` | `visible: boolean` | void | 패널/딤 오버레이 표시 상태 일괄 제어 |
| `BuildSlotSignatureClient` | `shopManager: Component` | string | 슬롯 Sync 변경 여부 판정용 시그니처 생성 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## ShopUILayout(DefaultGroup)
- **파일명:** `ui/DefaultGroup.ui`
- **수정일:** `2026-02-19`

### Entities
| 경로 | 역할 |
|---|---|
| `/ui/DefaultGroup/ShopDimOverlay` | 상점 오픈 시 배경 딤 오버레이 |
| `/ui/DefaultGroup/ShopPanel` | 상점 패널 루트 |
| `/ui/DefaultGroup/ShopPanel/TitleText` | 상점 제목 텍스트 |
| `/ui/DefaultGroup/ShopPanel/GoldText` | 현재 골드 표시 텍스트 |
| `/ui/DefaultGroup/ShopPanel/CloseButton` | 상점 닫기 버튼 |
| `/ui/DefaultGroup/ShopPanel/Slot1~Slot3` | 상점 3슬롯 카드 루트 |
| `/ui/DefaultGroup/ShopPanel/Slot*/Icon` | 슬롯 아이콘 렌더러 |
| `/ui/DefaultGroup/ShopPanel/Slot*/ItemName` | 슬롯 아이템명 텍스트 |
| `/ui/DefaultGroup/ShopPanel/Slot*/Description` | 슬롯 설명 텍스트 |
| `/ui/DefaultGroup/ShopPanel/Slot*/PriceButton` | 슬롯 구매 버튼(가격 텍스트 포함) |

## Map01BootstrapComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **수정일:** `2026-02-20`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ConfigureOnBeginPlay` | boolean | 시작 시 기존 사용자 설정 수행 여부 |
| `ConfigureOnUserEnter` | boolean | 유저 입장 이벤트 기반 설정 여부 |
| `AutoAttachMissingComponents` | boolean | 누락 컴포넌트 자동 부착 여부 |
| `EnableLobbyMapSplit` | boolean | `games` 기준 맵 분리 이동 사용 여부 (`false`면 UI 상태 전환만 수행) |
| `LobbyMapName` | string | 로비 맵 이름 |
| `InGameMapName` | string | 인게임 맵 이름 |
| `AutoOpenRankingOnLobby` | boolean | 로비 진입 시 랭킹 자동 오픈 여부 |
| `LobbyRankingTab` | integer | 로비 기본 랭킹 탭 |
| `LobbyUIRootPath` | string | 로비 UI 루트 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `HandleUserEnterEvent` | `event: UserEnterEvent` | void | 신규 유저 입장 시 플레이어 설정 |
| `ConfigurePlayerByUserIdServer` | `userId: string` | void | userId 기반 플레이어 엔티티 설정 |
| `ConfigurePlayer` | `playerEntity: Entity` | void | 필수 컴포넌트 부착 및 LobbyFlow 설정 |
| `AttachRequiredComponentsServer` | `playerEntity: Entity` | void | Phase 0~4 필수 컴포넌트 자동 부착 (`GoldComponent`, `ShopManagerComponent`, `ShopUIComponent`, `MonsterSpawnComponent` 포함) |
| `FindOrAddComponentSafe` | `targetEntity: Entity, typeName: string` | Component | 조회/추가 안전 래퍼 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## MonsterSpawnComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **수정일:** `2026-02-20`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `SpawnConfigTableName` | string | 스폰 설정 DataTable 이름 (`SpawnConfig`) |
| `MonsterDataTableName` | string | 웨이브+드랍 통합 DataTable 이름 (`MonsterData`) |
| `SpawnWaveTableName` | string | 구버전 호환용 별칭 테이블명(비어있지 않으면 fallback 사용) |
| `IsSpawnActive` | boolean | 서버 스폰 루프 활성 상태(Sync) |
| `IsBossPhase` | boolean | 보스 페이즈 상태(Sync) |
| `MonsterParentEntity` | Entity | 스폰 몬스터 부모 엔티티 |
| `MonsterContainerName` | string | 맵에서 부모 엔티티를 찾을 이름 |
| `StateMonitorInterval` | number | 로비/상점 상태 기반 스폰 가능 여부 재평가 주기 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `LoadSpawnDataFromTable` | void | boolean | `SpawnConfig`/`MonsterData` 로드 및 준비 상태 갱신 |
| `LoadMonsterDataFromTable` | void | boolean | 몬스터 통합 테이블 로드 |
| `ResolveSpawnCandidates` | `stage: integer, elapsedSec: number` | table | 현재 시점 스폰 후보(일반/보스) 분리 |
| `BuildSpawnMetaFromRow` | `row: UserDataRow` | table | 드랍/보상 후속 연동용 메타 데이터 구성 |
| `ApplyMonsterVisualIfAvailable` | `targetEntity: Entity, row: UserDataRow` | void | `sprite_ruid`가 있으면 SpriteRenderer 외형만 안전 교체 |
| `ApplyMonsterStatsIfAvailable` | `targetEntity: Entity, row: UserDataRow` | void | 스탯 컴포넌트 존재 시 안전 적용(미정 명세 훅) |
| `GetSpawnMetaByEntity` | `targetEntity: Entity` | table | 엔티티 기준 스폰 메타 조회 API |
| `RefreshSpawnStateServer` | void | void | 로비/상점/보스/데이터 상태를 반영해 스폰 시작/정지 |
| `SpawnTick` | void | void | 타이머 틱에서 스폰 제한/좌표/재시도/보스 판정 처리 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## LobbyFlowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **수정일:** `2026-02-19`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsLobbyActive` | boolean | 현재 로비 상태 여부(Sync) |
| `UseMapSplit` | boolean | `games` 기준 분리 맵 이동 사용 여부 (`false`면 시작 시 UI 비활성만 수행) |
| `LobbyMapName` | string | 로비 맵 이름 |
| `InGameMapName` | string | 인게임 맵 이름 |
| `AutoOpenRankingOnLobby` | boolean | 로비 진입 시 랭킹 자동 오픈 여부 |
| `LobbyRankingTab` | integer | 로비 기본 랭킹 탭 (1=타임어택) |
| `StartButtonPath` | string | 시작 버튼 경로 |
| `RankingTextPath` | string | 랭킹 텍스트 경로 |
| `MyRankTextPath` | string | 내 순위 텍스트 경로 |
| `UIRootPath` | string | 로비 UI 루트 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnStartButtonClickedClient` | `event: ButtonClickEvent` | void | 버튼 클릭 디바운스 후 시작 요청 |
| `RequestStartGameServer` | `requestUserId: string` | void | 시작 요청 서버 처리(소유자 검증 후 UI 상태 전환, 필요 시 맵 이동) |
| `SetLobbyStateServer` | `isLobby: boolean` | void | 로비 상태 전환 및 연동 컴포넌트 정책 적용 |
| `ApplyLobbyUIClient` | `isLobby: boolean` | void | 시작/랭킹 UI 가시성 클라이언트 반영 |
| `RequestOpenLobbyRankingClient` | void | void | 로비 진입 시 랭킹 탭 오픈/데이터 요청 |
| `MoveOwnerToInGameMapIfNeeded` | void | boolean | 인게임 맵 이동 요청 |
| `MoveOwnerToLobbyMapIfNeeded` | void | boolean | 로비 맵 이동 요청 |
| `HandleRunCompletedServer` | `isClear: boolean` | void | 런 종료 처리 및 로비 복귀 |
| `TryResetGoldForOwnerServer` | void | void | 런 종료 시 `GoldComponent.ResetGold()` 안전 호출 |
| `TryResetShopForOwnerServer` | void | void | 런 종료 시 `ShopManagerComponent.ResetShopStateServer()` 안전 호출 |
| `HandleStageFailedServer` | void | void | 실패 종료 래퍼 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |


