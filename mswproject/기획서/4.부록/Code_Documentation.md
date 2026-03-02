
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
| `UpdateStateAnimation` | `moveDirection: Vector2` | void | `IsDead` 우선으로 `DEAD` 유지, 생존 시 MOVE/IDLE 상태 동기화 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## CameraFollowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.mlua`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CameraOffset` | Vector2 | 카메라 중심 오프셋 (`0,0` 기본 유지) |
| `ForceHardLockFollow` | boolean | DeadZone/SoftZone/Damping 0 강제 적용 여부 |
| `CameraApplyRetryInterval` | number | 카메라 적용 재시도 간격(초) |
| `CameraApplyRetryMaxCount` | integer | 카메라 적용 최대 재시도 횟수 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 클라이언트 시작 시 카메라 세팅 적용 |
| `OnMapEnter` | `enteredMap: Entity` | void | 맵 진입 시 카메라 세팅 재적용 |
| `StartCameraApplyRetryClient` | void | void | 카메라 컴포넌트 준비 지연 시 재시도 타이머 시작 |
| `StopCameraApplyRetryClient` | void | void | 카메라 재시도 타이머 정리 |
| `ApplyCameraSettings` | void | boolean | 카메라 경계 제한 해제(`UseCustomBound=false`) + `CameraOffset=(0,0)` 중심 추적 적용 |
| `OnEndPlay` | void | void | 맵 종료 시 카메라 재시도 타이머 정리 |
| `OnDestroy` | void | void | 컴포넌트 제거 시 카메라 재시도 타이머 정리 |

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
- **수정일:** `2026-02-25`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MaxHP` | integer | 최대 체력 (Sync) |
| `CurrentHP` | integer | 현재 체력 (Sync) |
| `IsInvincible` | boolean | 태그 무적 게이트용 상태 플래그 (Sync) |
| `IsDead` | boolean | 사망 상태 (Sync) |
| `CriticalHPRatio` | number | 위험 체력 비율 임계값 |
| `FallbackDamage` | integer | 외부 공격 정보 미탐지 시 기본 피해 |
| `HitInvincibleDuration` | number | 피격 후 무적 시간(초, 기본 1.0) |
| `EnableInvincibleBlink` | boolean | 무적 상태 시 깜빡임 효과 사용 여부 |
| `InvincibleBlinkInterval` | number | 깜빡임 토글 간격(초) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | HP/사망/무적 초기화 |
| `OnBeginPlay` | void | void | 초기 HP 상태 브로드캐스트 |
| `HandleTriggerEnterEvent` | `event: TriggerEnterEvent` | void | 충돌 기반 피해 진입점 |
| `ResolveIncomingDamage` | `sourceEntity: Entity` | integer | 투사체/몬스터 공격력 해석 + 자기 충돌/아군 투사체 차단 |
| `ShouldIgnoreProjectileDamage` | `sourceEntity: Entity, projectileComponent: Component` | boolean | 플레이어는 몬스터 소유 투사체만 허용하도록 팀 기반 판정 |
| `ResolveCombatTeam` | `targetEntity: Entity` | string | `player/monster/unknown` 전투팀 분류 |
| `ApplyDamage` | `rawDamage: integer` | void | `IsInvincible`일 때 무시, 피해 적용 후 생존 시 피격 무적 윈도우 시작 |
| `ApplyPenaltyDamage` | `rawDamage: integer` | void | 패널티 피해 적용 (동일 직접 차감 경로) |
| `SetInvincibleWindowServer` | `duration: number` | void | 무적 종료 시각 기반으로 무적 윈도우를 설정/연장 |
| `ClearInvincibleWindowServer` | void | void | 무적 타이머/상태를 즉시 초기화 |
| `OnUpdate` | `delta: number` | void | 클라이언트에서 무적 깜빡임 상태 업데이트 |
| `ApplyBlinkVisibilityClient` | `visible: boolean` | void | Sprite/Avatar 렌더러 가시성 토글 |
| `Heal` | `amount: integer` | void | 회복 처리 |
| `ReviveToFullHP` | void | void | 부활 초기화 |
| `NotifyGameOver` | void | void | LobbyFlow/GameManager/타이머 순으로 종료 라우팅 |
| `UpdateHPFeedbackClient` | `currentHp, maxHp, isDead` | void | 클라이언트 전용 피드백 반영 |
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
- **수정일:** `2026-02-26`

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
| `SmiteAttackServer` | `targetWorldPosition: Vector2` | boolean | smite 타격 좌표를 무기별 정책으로 해석한 뒤 이펙트/데미지 적용 |
| `ResolveSmiteTargetPosition` | `targetWorldPosition: Vector2` | Vector2 | 현재 무기의 smite 타겟 모드에 따라 최종 타격 좌표 반환 |
| `IsPlayerPositionSmite` | `weaponId: string` | boolean | 무기 ID 기준 self-타겟 smite 여부 판정 |
| `GetSmiteTargetModeFromWeaponData` | `weaponId: string` | string | smite 좌표 모드 반환 (`self`/`cursor`) |
| `CalculateFinalDamage` | void | integer | 최종 공격력 공식 계산 |
| `StartFireCooldown` | void | void | 발사 쿨다운 타이머 시작 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

### Notes
- `SPEC_SmiteRework` 1단계는 사용자 지시에 따라 임시 하드코딩 적용:
- `weaponId == "deathperado"`는 `self`, 그 외는 `cursor` 처리.
- 차기 단계에서 `WeaponData.smite_target_mode` 컬럼 기반으로 전환 예정.

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
- **수정일:** `2026-02-24`

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
| `UseGameplayLockDuringShop` | boolean | 상점 오픈 중 이동/공격/타이머 잠금 사용 여부 (`false` 기본) |
| `EnableDebugLogs` | boolean | 상점 오픈/클로즈/잠금 경로 디버그 로그 출력 여부 |
| `Slot1~3Type/Name/Description/Price/SoldOut` | string/integer/boolean | 클라이언트 UI 렌더링용 슬롯 Sync 필드 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RequestOpenShopServer` | void | void | F 입력 기반 상점 열기 서버 요청 |
| `CanOpenShopForOwnerServer` | `requestUserId: string` | boolean | 소유자/활성 상점/거리 기반 오픈 가능 여부 판정 |
| `RequestPurchaseServer` | `slotIndex: integer` | void | 슬롯 구매 서버 처리(골드 차감/효과 적용) |
| `RequestCloseShopServer` | void | void | ESC/닫기 기반 상점 종료 요청 |
| `OpenShopServer` | void | void | 상점 오픈 + 슬롯 구성(잠금은 `UseGameplayLockDuringShop` 설정에 따름) |
| `CloseAndRotateShopServer` | void | void | 상점 종료 + 방문 상점 비활성 + 랜덤 순환 |
| `ResetShopStateServer` | void | void | 로비 복귀 시 상점 상태 초기화 |
| `ResolveShopEntitiesServer` | void | void | 맵 엔티티 기반 상점 참조 자동 탐색 |
| `LoadShopDataServer` | void | void | `ShopItemData` 로드 및 행 캐시 |
| `ApplyPurchaseEffectServer` | `slotType: string, slotData: table` | void | 회복/탄약/패시브 구매 효과 분기 |
| `SetGameplayLockServer` | `locked: boolean` | void | 기본은 잠금 스킵(상점 안전지대 제거), 필요 시 이동/공격/타이머 잠금 적용 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## TagManagerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **수정일:** `2026-02-24`

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
| `ApplyInvincibleWindowServer` | void | void | `HPSystem.SetInvincibleWindowServer` 우선 호출(미지원 시 기존 타이머 fallback) |
| `TriggerEntrySkillServer` | `charIndex: integer` | void | 태그 엔트리 스킬 훅 호출 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## SpeedrunTimerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/SpeedrunTimerComponent.mlua`
- **수정일:** `2026-02-24`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ElapsedTime` | number | 누적 시간(초, Sync) |
| `IsRunning` | boolean | 타이머 동작 여부(Sync) |
| `CurrentStageId` | integer | 현재 스테이지 ID |
| `BestTime` | number | 현재 스테이지 최고 기록(Sync) |
| `CountdownSeconds` | number | 런 시작 카운트다운 시간 |
| `TextUpdateInterval` | number | 타이머 텍스트 갱신 주기 |
| `EnableDebugLogs` | boolean | 시작/일시정지/틱 상태 디버그 로그 출력 여부 |
| `DebugTickLogInterval` | number | 서버 타이머 틱 로그 출력 간격(초) |
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
| `TracePauseReasonServer` | `paused: boolean, reason: string` | void | 일시정지 원인 변경 시점 디버그 로깅 |
| `TraceTickServer` | `stateLabel: string` | void | 서버 타이머 런/정지 상태 주기 로그 출력 |
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
- **수정일:** `2026-02-24`

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
| `AttachRequiredComponentsServer` | `playerEntity: Entity` | void | Phase 0~4 필수 컴포넌트 자동 부착 (`GoldComponent`, `ShopManagerComponent`, `ShopUIComponent`, `MonsterSpawnComponent`, `PenaltySystemComponent` 포함) |
| `FindOrAddComponentSafe` | `targetEntity: Entity, typeName: string` | Component | 조회/추가 안전 래퍼 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## MonsterSpawnComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **수정일:** `2026-02-24`

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
| `StateMonitorInterval` | number | 스폰 게이트 상태 재평가 주기 |
| `EnableDebugLogs` | boolean | 스폰 게이트/틱/타이머 디버그 로그 출력 여부 |
| `DebugLogThrottleSeconds` | number | 게이트 상태 로그 최소 출력 간격 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `LoadSpawnDataFromTable` | void | boolean | `SpawnConfig`/`MonsterData` 로드 및 준비 상태 갱신 |
| `LoadMonsterDataFromTable` | void | boolean | 몬스터 통합 테이블 로드 |
| `BuildOptionalMonsterColumnsCache` | `rows: table` | void | optional `collider_*` column cache build |
| `HasOptionalMonsterColumn` | `columnName: string` | boolean | optional column existence check with cached probe |
| `ResolveSpawnCandidates` | `stage: integer, elapsedSec: number` | table | 현재 시점 스폰 후보(일반/보스) 분리 |
| `BuildSpawnMetaFromRow` | `row: UserDataRow` | table | 드랍/보상 + 콜라이더(`collider_*`) 후속 연동용 메타 데이터 구성 |
| `ApplyMonsterVisualIfAvailable` | `targetEntity: Entity, row: UserDataRow` | void | `sprite_ruid`가 있으면 SpriteRenderer 외형만 안전 교체 |
| `ApplyMonsterColliderIfAvailable` | `targetEntity: Entity, row: UserDataRow` | void | `collider_w/h/offset` 데이터가 있으면 Trigger/Hit/PhysicsCollider 크기/오프셋 반영 |
| `DisablePhysicsColliderIfMapHasNoSimulator` | `targetEntity: Entity` | void | disables PhysicsCollider when map has no PhysicsSimulator |
| `HasPhysicsSimulatorInCurrentMap` | void | boolean | checks map-level PhysicsSimulatorComponent availability |
| `ApplyMonsterStatsIfAvailable` | `targetEntity: Entity, row: UserDataRow` | void | 스탯 컴포넌트 존재 시 안전 적용(미정 명세 훅) |
| `GetSpawnMetaByEntity` | `targetEntity: Entity` | table | 엔티티 기준 스폰 메타 조회 API |
| `RefreshSpawnStateServer` | void | void | 로비/보스/데이터 상태를 반영해 스폰 시작/정지 |
| `SpawnTick` | void | void | 타이머 틱에서 좌표 검증 1회 기반 스폰/보스 판정 처리 (필드 상한 없음) |
| `TraceSpawnGateServer` | `canSpawn: boolean, reason: string` | void | 스폰 가능/불가 전이 및 원인 디버그 로그 출력(스로틀 적용) |
| `IsShopOpenServer` | void | boolean | 상점 열림 상태 조회(디버그 컨텍스트용, 스폰 차단에는 미사용) |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## PenaltySystemComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/PenaltySystemComponent.mlua`
- **수정일:** `2026-02-24`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `WarningThreshold` | integer | 경고 UI 활성 임계 몬스터 수 |
| `PenaltyThreshold` | integer | 패널티 발동 임계 몬스터 수 |
| `CullCount` | integer | 패널티 시 강제 비활성화할 일반 몬스터 수 |
| `PenaltyDamageRatio` | number | 플레이어 MaxHP 대비 패널티 피해 비율 |
| `MonitorInterval` | number | 몬스터 수 감시 타이머 주기 |
| `IsWarningActive` | boolean | 경고 UI 활성 상태(Sync) |
| `WarningIconPath` | string | 경고 아이콘 엔티티 경로 |
| `WarningTextPath` | string | 경고 텍스트 엔티티 경로 |
| `WarningBubblePath` | string | 캐릭터 주변 경고 말풍선 엔티티 경로 |
| `WarningBubbleTextPath` | string | 경고 말풍선 텍스트 엔티티 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `CheckMonsterCountServer` | void | void | 임계치 비교 및 경고/패널티 상태 전환 |
| `ExecutePenaltyServer` | `monsterSpawn: Component, currentCount: integer` | void | 일반 몬스터 비활성화 + 플레이어 패널티 피해 실행 |
| `CullNormalMonstersServer` | `monsterSpawn: Component` | integer | 보스/엘리트 제외 랜덤 일반 몬스터 제거 |
| `ApplyPenaltyDamageServer` | void | void | `HPSystemComponent.ApplyPenaltyDamage()` 호출 |
| `SetWarningStateServer` | `isActive: boolean, currentCount: integer` | void | Sync 상태 갱신 및 클라이언트 UI 반영 |
| `ApplyWarningUIClient` | `isActive, currentCount, penaltyThreshold` | void | 경고 UI 토글 및 문구 갱신 |
| `EnsureGRUtil` | void | void | `BootstrapUtil()` 결과를 `self._T.GRUtil`에 캐시하고 폴백 경로 유지 |

## LobbyFlowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **수정일:** `2026-02-24`

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
| `EnableDebugLogs` | boolean | 시작/전환/타이머 연동 디버그 로그 출력 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnStartButtonClickedClient` | `event: ButtonClickEvent` | void | 버튼 클릭 디바운스 후 시작 요청 |
| `RequestStartGameServer` | `requestUserId: string` | void | 시작 요청 서버 처리(소유자 검증 후 UI 상태 전환, 필요 시 맵 이동) |
| `BeginInGameStateServer` | `targetUserId: string` | void | 인게임 상태 전환 우선 적용 후 맵 이동 시도 |
| `TryStartRunTimerServer` | void | void | `SpeedrunTimerComponent` 존재 시 런 타이머 안전 시작 |
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

## 2026-02-24 Monster Chase Update

### MonsterChaseComponent
- **File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.codeblock`
- **Purpose** Server-authoritative nearest-player chase for spawned monsters.

#### Properties
| Name | Type | Description |
|---|---|---|
| `ThinkInterval` | number | Chase think timer interval (default `0.1`) |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `ThinkChaseServer` | void | void | Select nearest player in current map and apply movement direction |
| `FindNearestPlayerOnCurrentMapServer` | void | Entity | Resolve nearest valid player entity in same map |
| `PushDirectionToMovementServer` | `movementComponent: any, direction: Vector2` | void | Uses `SetMoveDirectionServer()` with fallback path |

### MovementComponent (Updated)
- **File** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.codeblock`
- **Updated At** `2026-02-24`

#### Added API
| Name | Type | Description |
|---|---|---|
| `UsePlayerInput` | boolean (`@Sync`) | Enables/disables client WASD input path (`false` for monsters) |
| `SetMoveDirectionServer` | method | Server-only direct direction setter for AI-driven movement |

### MonsterSpawnComponent (Updated)
- **File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated At** `2026-02-24`

#### Integration Changes
| Function | Change |
|---|---|
| `SpawnMonsterByRow` | Calls `AttachMonsterChaseIfNeeded(spawnedEntity)` after spawn success |
| `ApplyMonsterStatsIfAvailable` | Sets `movement.UsePlayerInput = false` and keeps `MoveSpeed = mon_spd` mapping |
| `AttachMonsterChaseIfNeeded` | New helper to idempotently add `MonsterChaseComponent` |

## 2026-02-24 Monster Contact Combat Update

### MonsterChaseComponent (Updated)
- **File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.codeblock`
- **Updated At** `2026-02-24`

#### Added Properties
| Name | Type | Description |
|---|---|---|
| `ContactDamage` | integer | Overlap contact damage base value (default `1`) |

#### Added/Changed Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `HandleTriggerEnterEvent` | `event: TriggerEnterEvent` | void | Cache overlap player target |
| `HandleTriggerLeaveEvent` | `event: TriggerLeaveEvent` | void | Clear overlap target on exit |
| `UpdateFacingFlipServer` | `targetEntity: Entity` | void | Set `SpriteRenderer.FlipX` by relative X position |
| `ApplyContactDamageServer` | `targetEntity: Entity` | void | Apply contact damage every chase tick while overlapping |
| `ThinkChaseServer` | void | void | Stop chase movement during overlap, resume chase after leave |

### MonsterSpawnComponent (Updated)
- **File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated At** `2026-02-24`

#### Integration Changes
| Function | Change |
|---|---|
| `SpawnMonsterByRow` | Calls `EnsureMonsterTriggerComponent(spawnedEntity)` after spawn success |
| `EnsureMonsterTriggerComponent` | Adds `TriggerComponent` if missing, sets `IsPassive=false`, copies collider size/offset when available |
| `ApplyMonsterStatsIfAvailable` | Injects `MonsterChaseComponent.ContactDamage = mon_atk` |

### Map01BootstrapComponent (Updated)
- **File** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated At** `2026-02-24`

| Function | Change |
|---|---|
| `ConfigurePlayer` | 플레이어 이동/로비/상점/캐릭터 초기화 경로를 일괄 구성 |

## 2026-02-24 Timer/Infinite Release Update
- **수정일:** `2026-02-24`
- **범위:** `GameTimerComponent 신규`, `InfiniteModeComponent 신규`, `Ranking/Spawn/HP/Bootstrap 연동 갱신`

### GameTimerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/GameTimerComponent.mlua`
- **동기화 파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/GameTimerComponent.codeblock`

#### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ElapsedTime` | number | 게임 경과 시간(초, Sync) |
| `IsRunning` | boolean | 타이머 실행 상태(Sync) |
| `IsPaused` | boolean | 타이머 일시정지 상태(Sync) |
| `CurrentStageId` | integer | 현재 스테이지 ID |
| `CountdownSeconds` | number | 시작 카운트다운 |

#### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `StartRunWithCountdown` | void | void | 카운트다운 후 런 시작 |
| `StartRunNow` | void | void | 즉시 런 시작 |
| `PauseGame` | void | void | 서버 권위 일시정지 |
| `ResumeGame` | void | void | 서버 권위 재개 |
| `CompleteRun` | void | void | 런 종료 (타이머 역할만 수행) |

### InfiniteModeComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.mlua`
- **동기화 파일:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.codeblock`

#### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsInfiniteActive` | boolean | 무한모드 활성 상태(Sync) |
| `CurrentScore` | integer | 현재 누적 점수(Sync) |
| `SessionBestScore` | integer | 세션 내 최고 점수 |
| `ModeMonsterDataTableName` | string | 무한모드 몬스터 데이터 테이블명 |
| `ResultDelaySeconds` | number | 결과 표시 후 로비 복귀 지연 |

#### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ResetForNewRunServer` | void | void | 런 시작 시 점수/모드 상태 초기화 |
| `OnMonsterKilledServer` | `monsterId, scoreOverride` | void | 처치 점수 누적 |
| `OnBossKilledServer` | `bossId` | void | 보스 클리어 팝업 트리거 |
| `RequestReentryDecisionServer` | `acceptInfinite` | void | 재돌입 수락/거부 처리 |
| `HandlePlayerDeathServer` | void | boolean | 일반/무한 사망 분기 + 랭킹 제출 |
| `EnterInfiniteModeServer` | void | void | ModeMonsterData 전환 + 점수 리셋 |
| `GetInfiniteElapsedSecondsServer` | void | number | 무한모드 경과 시간 반환 |

### RankingComponent (Updated)
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/RankingComponent.mlua`
- **변경 핵심:** TimeAttack 제거, 일반/무한 점수 2트랙 내림차순 정렬 통합

#### Added/Changed API
| 항목 | 변경 |
|---|---|
| Property | `NormalBestScore`, `InfiniteBestScore`, `NormalStorageName`, `NormalLocalKey`, `MaximumValidScore` |
| Method | `SubmitNormalRecordServer(score)` 추가 |
| Method | `SubmitInfiniteRecordServer(score)` 의미를 점수 기준으로 정리 |
| Logic | `GetTopRanksServer`/`GetMyRankServer` 모두 `SortDirection.Descending` |
| Logic | `FormatScoreForDisplay` 시간 포맷 제거, 정수 점수 문자열 통일 |

### RankingUIComponent (Updated)
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.mlua`
- **변경 핵심:** 탭 헤더를 점수 모드 기준으로 변경

| 함수명 | 변경 |
|---|---|
| `RenderRankingTextClient` | 탭 1 헤더를 `일반 모드`, 탭 2를 `무한 모드`로 표시 |

### MonsterSpawnComponent (Updated)
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **변경 핵심:** GameTimer 연동 + InfiniteMode 연동 + 처치 점수 콜백

#### Added/Changed Points
| 함수/항목 | 변경 |
|---|---|
| Property | `ModeMonsterDataTableName` 추가 |
| `CanSpawnNowServer` | `GameTimerComponent.IsPaused`일 때 스폰 차단 |
| `ResolveCurrentSpawnContext` | 무한모드 활성 시 `GetInfiniteElapsedSecondsServer()` 기준 컨텍스트 사용 |
| `ResolveMonsterDataTableName` | 무한모드 시 `ModeMonsterData` 선택 |
| `ActivateInfiniteModeServer` | 일반/무한 데이터 소스 전환 API 추가 |
| `BuildSpawnMetaFromRow` | `CreepScore` 메타 필드 추가 |
| `PruneSpawnedMonsters` | 제거 엔티티를 `InfiniteModeComponent.OnMonsterKilledServer`/`OnBossKilledServer`로 통지 |
| `ApplyMonsterStatsIfAvailable` | mode_* 컬럼 기반 분당 스탯 스케일링 반영 |

### HPSystemComponent (Updated)
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`

| 함수명 | 변경 |
|---|---|
| `NotifyGameOver` | `InfiniteModeComponent.HandlePlayerDeathServer()` 우선 호출로 결과/랭킹 분기 일원화 |
| `NotifyGameOver` fallback | 타이머 참조를 `GameTimerComponent`로 교체 |

### LobbyFlowComponent / Bootstrap / Shop / WeaponSwap (Updated)
- **파일명:**
`RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
`RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
`RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
`RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`

| 컴포넌트 | 변경 |
|---|---|
| `LobbyFlowComponent` | 런 시작 시 `InfiniteModeComponent.ResetForNewRunServer()` 호출 + `GameTimerComponent` 시작 참조 |
| `Map01BootstrapComponent` | 필수 부착 목록을 `GameTimerComponent` + `InfiniteModeComponent` 기준으로 갱신 |
| `ShopManagerComponent` | 상점 잠금 시 `PauseGame()` / 해제 시 `ResumeGame()` 사용 |
| `WeaponSwapComponent` | 무기교체 잠금 시 `PauseGame()` / 해제 시 `ResumeGame()` 사용 |

### DefaultGroup UI (Infinite/Ranking Placement)
- **파일명:** `ui/DefaultGroup.ui`
- **수정일:** `2026-02-24`

#### Added Entities
| 경로 | 초기 상태 | 용도 |
|---|---|---|
| `/ui/DefaultGroup/GRScoreText` | `enable: false`, `visible: false` | 실시간 점수 표시 |
| `/ui/DefaultGroup/GRResultPanel` | `enable: false`, `visible: false` | 결과 패널 텍스트 표시 |
| `/ui/DefaultGroup/GRReentryPopup` | `enable: false`, `visible: false` | 보스 클리어 후 재돌입 선택 팝업 |
| `/ui/DefaultGroup/GRReentryPopup/AcceptButton` | `enable: true`, `visible: true` | 무한 모드 진입 수락 버튼 |
| `/ui/DefaultGroup/GRReentryPopup/DeclineButton` | `enable: true`, `visible: true` | 무한 모드 거부 버튼 |

#### Layout Note
- 기존 랭킹 UI (`GRRankingText`, `GRMyRankText`)의 좌표/크기/표시순서는 유지하고, 신규 엔티티만 추가 배치.

## 2026-02-24 Lobby Ranking Overlay UI Update

### RankingUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.codeblock`
- **Updated:** `2026-02-24`

#### Added Properties
- `LobbyPanelPath`, `RankingPanelPath`
- `RankingOpenButtonPath`, `RankingBackButtonPath`
- `NormalTabButtonPath`, `InfiniteTabButtonPath`
- `RankingGridPath`, `RankingRowTemplatePath`
- `FirstRankIconRuid`, `SecondRankIconRuid`, `ThirdRankIconRuid`
- `DatePlaceholderText`
- `EnableTransitionAnimation`, `TransitionDuration`

#### Added/Changed Functions
- `ApplyLobbyStateClient(boolean isLobby)`
- `OpenRankingPanelClient(integer tab)`
- `CloseRankingPanelClient()`
- `BindPanelButtonsClient()` and button callbacks
- `PrepareRankingGridClient()` / `RefreshRankingGridClient()`
- `OnRankingRowRefreshClient()` / `OnRankingRowClearClient()`
- `ApplyRankingRowDataClient()`

#### Behavior
- Lobby now supports overlay flow: `LobbyPanel <-> RankingPanel`.
- Ranking grid rendering uses cached `RankingComponent._T.LastTopRanks` data.
- Rank 1~3 supports icon RUID injection via properties.
- Date column currently renders placeholder text (`-` by default).

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-24`

#### Changed Function
- `ApplyLobbyUIClient(boolean isLobby)` now delegates ranking panel visibility to:
- `RankingUIComponent.ApplyLobbyStateClient(isLobby)` first
- fallback to `ApplyVisibilityClient(isLobby)` when new API is absent

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-24`

#### Changed Default
- `AutoOpenRankingOnLobby = false`
- Lobby now defaults to the base lobby panel and opens ranking only by UI action.

### DefaultGroup UI Paths (Applied)
- `/ui/DefaultGroup/GRLobbyPanel`
- `/ui/DefaultGroup/GRLobbyPanel/GRRankingOpenButton`
- `/ui/DefaultGroup/GRRankingPanel`
- `/ui/DefaultGroup/GRRankingPanel/GRBackButton`
- `/ui/DefaultGroup/GRRankingPanel/GRTabNormalButton`
- `/ui/DefaultGroup/GRRankingPanel/GRTabInfiniteButton`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingGrid`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/RankIcon`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/RankNumberText`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/NicknameText`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/ScoreText`
- `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/DateText`

### 2026-02-24 Lobby First Screen Hotfix
- `LobbyFlowComponent.AutoOpenRankingOnLobby` 기본값을 `false`로 고정.
- `LobbyFlowComponent.OnInitialize()`에서 `self.AutoOpenRankingOnLobby = false`를 강제 적용해, 에디터 저장값이 남아 있어도 로비 최초 진입 시 랭킹 자동 오픈이 발생하지 않도록 수정.

## 2026-02-24 Character System Refactor (A/B Immediate Swap)

### CharacterDataInitComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.codeblock`
- **Updated:** `2026-02-24`

#### Properties
| Name | Type | Description |
|---|---|---|
| `CurrentCharacterId` | string (Sync) | 현재 활성 캐릭터 ID (`player_a`/`player_b`) |
| `CharacterTableName` | string | 캐릭터 데이터 테이블명 (`PlayerbleData`) |
| `CharacterAId`, `CharacterBId` | string | A/B 캐릭터 식별자 |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `InitializeCharacterDataServer` | void | void | `PlayerbleData` 전 행 캐시 |
| `GetCharacterDataRowServer` | `charId: string` | table | 캐시된 캐릭터 행 조회 |
| `ApplyCharacterDataServer` | `charId: string, isInitialApply: boolean` | boolean | HP/이속/기본공격/무기슬롯/무기모델 + 애니메이션 액션시트 적용 |
| `ApplyAvatarActionSheetsFromRowServer` | `row: table` | void | `idle_ruid/walk_ruid/dead_ruid`를 상태 키(`IDLE/MOVE/DEAD`)에 매핑 |
| `ResolveAnimationStateKeysServer` | void | table | `MovementComponent`의 `Idle/Move/DeadStateName`을 기준으로 상태 키 결정 |
| `ApplyActionSheetByStateServer` | `avatarAnimation: Component, stateKey: string, ruid: string, columnName: string` | void | 상태별 RUID를 `SetActionSheet`로 안전 적용 (빈 값은 skip) |
| `ApplyCharacterDataServer` HP 규칙 | - | - | `isInitialApply`는 최초 1회만 풀HP 적용, 이후 재호출은 현재 HP 보존(최대 HP로 clamp) |

### WeaponModelComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock`
- **Updated:** `2026-02-24`

#### Properties
| Name | Type | Description |
|---|---|---|
| `CurrentWeaponId` | string (Sync) | 현재 무기 ID |
| `WeaponHolderEntityRef` | Entity | WeaponHolder 엔티티 캐시 |
| `WeaponHolderName` | string | WeaponHolder 탐색 이름 |
| `WeaponDataTableName` | string | 무기 데이터 테이블명 |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `SwapModel` | `weaponId: string` | void | 무기 스프라이트 교체 |
| `GetMuzzlePosition` | void | Vector2 | 총구 월드 좌표 반환 |
| `GetAimDirection` | `targetWorldPos: Vector2` | Vector2 | 목표 기준 발사 방향 계산 |
| `ApplyHolderRotationClient` | `holder: Entity, targetWorld: Vector2` | void | WeaponHolder 회전 |
| `ApplyPlayerFlipClient` | `cursorScreen: Vector2` | void | 화면 좌우 기준 플레이어 반전 |

### TagSkillComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TagSkillComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TagSkillComponent.codeblock`
- **Updated:** `2026-02-24`

#### Properties
| Name | Type | Description |
|---|---|---|
| `IsSkillActive` | boolean (Sync) | 태그 스킬 활성 여부 |
| `SkillBuffMultiplier` | number (Sync) | 현재 버프 배율 |
| `SkillBuffType` | string | 버프 종류 (`movespeed`/`attack`) |
| `CharacterTableName`, `SkillDataTableName` | string | 캐릭터/스킬 데이터 테이블명 |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `ActivateTagSkillServer` | `charId: string` | void | `PlayerbleData.tag_skill` 기반 스킬 발동(누락/오타는 엄격 차단) |
| `RemoveBuffServer` | void | void | 적용된 이동/공격 버프 복원 |
| `ResolveSkillIdByCharacterServer` | `charId: string` | string | `PlayerbleData[charId].tag_skill` 조회 |
| `ResolveBuffTypeAndValueServer` | `skillId: string, skillRow: table` | `string, number` | `SkillData.plus_speed/plus_dmg` 단일 유효값으로 버프 타입/값 결정 |
| `PlaySkillCutsceneClient` | `charId: string, skillId: string` | void | 컷씬 패널 노출/자동 숨김 |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-24`

#### Integration Changes
| Function | Change |
|---|---|
| `AttachRequiredComponentsServer` | `CharacterDataInitComponent`, `WeaponModelComponent`, `TagSkillComponent` 자동 부착 추가 |
| `ConfigurePlayer` | `CharacterDataInitComponent` 초기 데이터 적용 호출 추가 |
| `ConfigurePlayer` | `ForcePlayerTransformMovement=true`일 때 `MovementComponent.UsePhysicsMovement=false` 강제 |
| `EnforceWeaponHolderNoCollisionServer` | WeaponHolder 하위 충돌 컴포넌트 비활성화 강제 |
| `StartPeriodicConfigureTimerServer` | 유저 엔티티 지연 생성 시 컴포넌트 누락 복구를 위한 주기 재구성 루프 추가 |

### MovementComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.codeblock`
- **Updated:** `2026-02-24`

#### Interface Changes
| Name | Type | Description |
|---|---|---|
| `UsePlayerInput` | boolean (Sync) | 플레이어 입력 경로 사용 여부 |
| `IdleStateName` | string | 정지 상태 전환 키 (기본값: `IDLE`) |
| `MoveStateName` | string | 이동 상태 전환 키 (기본값: `MOVE`) |
| `DeadStateName` | string | 사망 상태 전환 키 (기본값: `DEAD`) |
| `AutoRegisterStates` | boolean | 상태 키 미등록 시 `AddState` 자동 시도 |
| `DisableNativeJumpAction` | boolean | 클라이언트에서 Space 기본 점프 액션 제거 여부 |
| `UsePhysicsMovement` | boolean | true면 `Rigidbody.MoveVelocity` 우선, false면 `Transform.Translate`만 사용 |
| `SetMoveDirectionServer` | method | 서버 주도 이동 벡터 주입 API (AI/몬스터 추격용) |
| `EnsureAnimationStatesRegistered` | method | 시작 시 상태 키 등록 시도 |
| `TryChangeStateSafely` | method | `ChangeState` 예외를 안전 처리하고 재시도 |
| `UpdateStateAnimation` | method | `HPSystemComponent.IsDead`가 true면 `DEAD` 상태를 우선 강제하고, 아니면 `IDLE/MOVE` 유지 |
| `DisableNativeJumpActionClient` | method | `PlayerControllerComponent`의 Space 입력 바인딩 제거 |
| Removed | property/function | `FacingDirection` 동기화/계산 경로 제거 |

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-24`

#### Changes
| Item | Detail |
|---|---|
| Baseline | 기본 HP 값을 `1/1`로 축소해 외부 주입(`CharacterDataInit`) 우선 구조로 정리 |
| Runtime | 피격 무적 `HitInvincibleDuration(기본 1.0초)` 추가, 태그 무적과 종료시각 기준으로 병합 |
| Visual | `IsInvincible` 동안 플레이어 렌더러 깜빡임(클라이언트 전용) 추가 |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-24`

#### Interface Changes
| Name | Type | Description |
|---|---|---|
| `BasePlayerAtk` | integer | 캐릭터 기본 공격력 주입값 |
| Removed | property/function | `MuzzleOffset`, `RotateShooter` 제거 |

#### Behavior Changes
| Function | Change |
|---|---|
| `TryFireServer` | `WeaponModelComponent.GetMuzzlePosition()` + `GetAimDirection()` 기반 발사 |
| `CalculateFinalDamage` | `BasePlayerAtk + BaseWeaponAttack + PassiveFlatAttack` 공식 적용 |
| `GetFallbackDirection` | WeaponHolder 전방 벡터 폴백 경로 추가 |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-24`

#### Added API
| Function | Parameters | Returns | Description |
|---|---|---|---|
| `InitSlotsFromPlayerbleData` | `charId: string, row: table` | void | PlayerbleData 기반 슬롯 초기화 |
| `ApplyWeaponRowToSlotDataServer` | `data: table, weaponId: string` | void | WeaponData 기반 슬롯 파라미터 주입 |
| `GetWeaponRowByIdServer` | `weaponId: string` | table | WeaponData 캐시 조회 |

#### Integration Changes
| Function | Change |
|---|---|
| `ApplySlotDataToCombat` | 슬롯 적용 직후 `WeaponModelComponent:SwapModel()` 동기화 |

### TagManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **Updated:** `2026-02-24`

#### Integration Changes
| Function | Change |
|---|---|
| `ExecuteTagSwapServer` | 태그 시 `CharacterDataInitComponent.ApplyCharacterDataServer()` 호출 후 스냅샷 복원 |
| `ExecuteTagSwapServer` | 태그 완료 후 `TagSkillComponent.ActivateTagSkillServer()` 호출 |
| `ApplyCharacterState` | 복원 HP를 `MaxHP` 기준으로 클램프하고 HP 브로드캐스트 갱신 |

## 2026-02-24 HP Direct Damage Update

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-24`

#### Removed/Changed
| Item | Change |
|---|---|
| `DamageReduction` | 제거 |
| `InvincibleDuration` | 제거 |
| `StartInvincibleWindow` | 제거 |
| `ApplyDamage` | 태그 무적(`IsInvincible`)은 유지, 피해감산/무적시간은 제거한 직접 피해 차감으로 단순화 |
| `UpdateHPFeedbackClient` | 시그니처를 `(currentHp, maxHp, isDead)`로 단순화 |

### Integration Adjustments
| Component | Change |
|---|---|
| `Map01BootstrapComponent` | `PlayerInvincibleDuration` 프로퍼티 및 HP 무적시간 주입 제거 |
| `MonsterChaseComponent` | 접촉 피해 전 HP 무적시간 override 제거 |
| `MonsterSpawnComponent` | `ContactInvincibleDurationDefault` 주입 제거 |

## 2026-02-24 HP I-Frame + Blink Hotfix

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-24`

#### Added
| Item | Detail |
|---|---|
| `HitInvincibleDuration` | 피격 후 무적시간(기본 1.0초) |
| `SetInvincibleWindowServer(duration)` | 종료 시각 기반 무적 윈도우 설정/연장 |
| `EnableInvincibleBlink`, `InvincibleBlinkInterval` | 무적 중 깜빡임 렌더 효과 제어 |
| `UpdateInvincibleBlinkClient` | `IsInvincible` Sync 기반 클라이언트 깜빡임 루프 |

### CharacterDataInitComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.codeblock`
- **Updated:** `2026-02-24`

#### Fixed
| Item | Detail |
|---|---|
| 주기 Configure 시 HP 풀회복 이슈 | `ApplyCharacterDataServer(isInitialApply)`를 최초 1회만 초기 HP 적용하도록 변경, 이후 재호출은 현재 HP 보존 + MaxHP clamp |

## 2026-02-24 Weapon Core Loop v1 (Chunk 1-3)

### WeaponLevelUpComponent (New)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock
- **Updated:** 2026-02-24

#### Properties
| Name | Type | Description |
|---|---|---|
| WeaponDataTableName | string | 무기 메타 데이터 테이블명 |
| WeaponLevelDataTableName | string | 레벨 배율 테이블명 |
| DefaultRequiredExp | integer | 요구 경험치 기본값 |
| DefaultStartLevel | integer | 시작 레벨 기본값 |
| DefaultMaxLevel | integer | 최대 레벨 기본값 |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| InitializeWeaponProgressServer | void | void | WeaponData/WeaponLevelData 캐시 및 무기별 진행도 초기화 |
| AddWeaponExpServer | weaponId, amount | void | 발사/설치 성공 시 경험치 누적 및 연속 레벨업 처리 |
| ApplyWeaponPowerToFireServer | weaponId | integer | player_atk * level_N을 FireSystem.BaseWeaponAttack에 적용 |
| ExportWeaponProgressState | void | table | 태그 저장용 무기 진행도 스냅샷 반환 |
| ImportWeaponProgressState | state | void | 태그 복원 시 무기 진행도 복원 + 현재 무기 공격력 재적용 |

### TurretAIComponent (New)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.codeblock
- **Updated:** 2026-02-24

#### Properties
| Name | Type | Description |
|---|---|---|
| ThinkInterval | number | 서버 추적/사격 틱 간격 |
| TargetSearchRadius | number | 타겟 탐색 반경(0이면 무제한) |
| EnableDebugLogs | boolean | 디버그 로그 출력 여부 |

#### Functions
| Function | Parameters | Returns | Description |
|---|---|---|---|
| InitializeTurretServer | 	urretRuntimeConfig | void | 소환 런타임 설정(탄속/피해/지속시간) 주입 및 타이머 시작 |
| TickTurretServer | void | void | 최근접 몬스터 타겟 획득 후 사격 판정 |
| FireAtTargetServer | 	arget | boolean | projectile/smite 타입 분기 사격 |
| SpawnTurretProjectileServer | direction, spawnPosition2D | boolean | 포탑 투사체 생성 및 ProjectileComponent 초기화 |
| DestroyTurretServer | void | void | 지속시간 만료/종료 시 포탑 안전 파괴 |

### FireSystemComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock
- **Updated:** 2026-02-24

#### Added/Changed
| Item | Detail |
|---|---|
| FireType 분기 | TryFireByTypeServer 추가 (projectile/area/smite/summon) |
| Summon 연동 | SummonTurretServer에서 TurretAIComponent 런타임 주입 |
| Smite | 투사체 없이 즉발 피해 (SmiteAttackServer) |
| Projectile 확장 | SpawnProjectileServer가 성공 여부(boolean) 반환 |
| Weapon EXP | 발사/소환 성공 시 WeaponLevelUpComponent:AddWeaponExpServer 호출 |
| Damage 계산 | BaseWeaponAttack 우선, 미설정 시 BasePlayerAtk 폴백 |

### ProjectileComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock
- **Updated:** 2026-02-24

#### Added/Changed
| Item | Detail |
|---|---|
| ProjectileType | single/area 분기 처리 |
| SplashSize | area 폭발 반경 |
| ExplosionTriggered | 중복 폭발 방지 플래그 |
| ExplodeServer | area 투사체 반경 피해 처리 |

### WeaponSwapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock
- **Updated:** 2026-02-24

#### Added/Changed
| Item | Detail |
|---|---|
| 데이터 소스 확장 | ProjectileDataTableName, SummonDataTableName 추가 |
| 슬롯 스키마 확장 | FireType, ProjectileType, ProjectileId, SummonId, SplashSize, SummonCooldown, SummonDuration, SummonFireRate, SummonProjectileId, TurretModelId |
| 테이블 캐시 | Projectile/Summon 행 캐시 로딩 추가 |
| 전투 적용 연동 | ApplySlotDataToCombat에서 FireSystem 신규 필드 주입 |
| 레벨업 연동 | 슬롯 적용 직후 WeaponLevelUp.ApplyWeaponPowerToFireServer 호출 |

### TagManagerComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock
- **Updated:** 2026-02-24

#### Added/Changed
| Item | Detail |
|---|---|
| 상태 캡처 | CaptureCurrentCharacterState에 WeaponLevelProgressState 포함 |
| 상태 복원 | ApplyCharacterState에서 ImportWeaponProgressState 호출 |
| 공격력 재적용 | 복원 후 ApplyWeaponPowerToFireServer("") 재실행 |

### Map01BootstrapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock
- **Updated:** 2026-02-24

#### Added/Changed
| Item | Detail |
|---|---|
| 필수 부착 목록 | WeaponLevelUpComponent 자동 부착 추가 |

## 2026-02-25 Bootstrap Auto-Attach Hotfix

### Map01BootstrapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Native player auto-attach | Added PlayerComponent, PlayerControllerComponent, StateComponent, SpriteRendererComponent, AvatarStateAnimationComponent, TriggerComponent, PhysicsColliderComponent to required attach list. |
| Runtime stability | Prevents missing-base-component cases on custom player models (input/state animation not updating). |

## 2026-02-25 WeaponHolder Binding Hotfix

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Direct holder binding | Added WeaponHolderEntityPath and path-first resolution. |
| Fallback chain | Holder resolve order: WeaponHolderEntityRef -> WeaponHolderEntityPath -> child name(WeaponHolder). |

### Map01BootstrapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Collision-disable target resolve | EnforceWeaponHolderNoCollisionServer now resolves holder via WeaponModelComponent reference/path first, then child-name fallback. |

## 2026-02-25 WeaponHolder Follow Sync Hotfix

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Detached holder follow | Added server/client position sync for non-child WeaponHolder. |
| New properties | FollowDetachedWeaponHolder, DetachedWeaponHolderOffset, DetachedHolderFollowInterval. |
| Resolve order | WeaponHolderEntityRef -> WeaponHolderEntityPath -> child-name fallback. |

## 2026-02-25 Weapon Sprite Swap Reliability Hotfix

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Weapon ID normalization | Trim + case-insensitive lookup for `WeaponData.id` on swap. |
| Cache refresh on miss | If row lookup fails once, force reload `WeaponData` cache and retry. |
| sprite_ruid fallback | Reads `sprite_ruid` first, then alias columns (`spriteRuid`, `sprite`). |
| Diagnostic logs | Added swap-fail/success logs to identify holder/row/column issues quickly. |

## 2026-02-25 Weapon Model Visual + Muzzle Offset Hotfix

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Model-first visual swap | `weapon_model` (and aliases) is used first; if missing, fallback to `sprite_ruid`. |
| Weapon visual lifecycle | Previous weapon visual entity is destroyed before spawning next one to avoid stacking. |
| Holder sprite policy | Added option to hide holder sprite while model visual is active. |
| Per-weapon muzzle config | Reads optional `muzzle_distance`, `muzzle_offset_x/y` (aliases `muzzle_x/y`) from `WeaponData`. |
| Fire origin integration | `GetMuzzlePosition()` now applies weapon-specific distance/offset at runtime. |

## 2026-02-25 Weapon Visual Scale/Offset Data Hook

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| New WeaponData columns | Added runtime parsing for `weapon_scale_x`, `weapon_scale_y`, `weapon_offset_x`, `weapon_offset_y` (aliases `scale_x/y`, `offset_x/y`). |
| Holder transform apply | On weapon swap, holder transform scale/offset is updated from data before visual swap. |
| Detached holder support | For detached holder mode, weapon offset is combined into world-follow offset every sync tick. |
| Defaults | Added defaults `DefaultWeaponScaleX/Y`, `DefaultWeaponOffsetX/Y` and runtime caches for stable fallback. |

## 2026-02-25 Weapon Rotation Offset Data Hook

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| New WeaponData column | Added runtime parsing for `weapon_rotation_offset` (aliases `rotation_offset`, `angle_offset`). |
| Aim rotation integrate | Holder aim angle now applies per-weapon rotation offset (degree) before writing `ZRotation`. |
| Defaults | Added `DefaultWeaponRotationOffset` and per-weapon runtime cache for fallback safety. |

## 2026-02-25 Missing Column Log Suppression (WeaponModel)

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Alias fallback gate | `EnableAliasColumnFallback=false` by default, so legacy alias columns are not queried unless explicitly enabled. |
| Optional rotation column gate | `UseWeaponRotationOffsetColumn=false` by default, preventing `weapon_rotation_offset` missing-column logs when schema is not updated yet. |
| Runtime impact | Prevents `LEA-3011 NotFound` spam from optional/legacy column probes in WeaponModel swap path. |

## 2026-02-25 Sprite-Only Mode Guards (Weapon/Projectile)

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Sprite-only default | `PreferWeaponModelVisual=false` and `UseWeaponModelColumn=false` by default. |
| Muzzle column gate | `UseWeaponMuzzleColumns=false` default; missing `muzzle_*` columns no longer produce NotFound logs. |

### WeaponSwapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Projectile model gate | `EnableProjectileModelLookup=false` default to suppress missing `projectile_model*` column probes. |

## 2026-02-25 WeaponModel-Only Disable Adjustment

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Scope correction | Kept only `weapon_model` path disabled (`PreferWeaponModelVisual=false`, `UseWeaponModelColumn=false`). |
| Muzzle column restore | Re-enabled `muzzle_distance`, `muzzle_offset_x`, `muzzle_offset_y` read path in `ApplyMuzzleConfigByRowServer()`. |
| Runtime default | `UseWeaponMuzzleColumns=true` default so WeaponData muzzle columns are used immediately. |

### WeaponSwapComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Projectile model restore | Re-enabled `projectile_model` read path in `GetProjectileModelIdFromProjectileRow()`. |
| Runtime default | `EnableProjectileModelLookup=true` default. |
| Log safety | Alias probes are skipped intentionally; only primary `projectile_model` is queried to reduce missing-column log noise. |

## 2026-02-25 Weapon Draw Order Over Player

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| New properties | `MatchOwnerSortingLayer`, `WeaponOrderOffset`, `FallbackWeaponOrderInLayer` 추가. |
| Draw-order apply | `SwapModel()` 완료 시 `ApplyWeaponDrawOrderServer()` 호출로 무기 스프라이트 `OrderInLayer`를 플레이어보다 높게 강제. |
| Layer match | 옵션 활성 시 플레이어 `SortingLayer`를 무기에도 동일 적용. |

## 2026-02-25 Detached WeaponHolder Follow Smoothing

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Follow interval | `DetachedHolderFollowInterval` 기본값을 `0.02`로 조정해 서버 추종 빈도 상향. |
| Client smoothing | `EnableClientDetachedFollowSmoothing`, `ClientDetachedFollowSmoothingSpeed` 프로퍼티 추가. |
| Follow path | `OnUpdate()`에서 `SyncDetachedHolderPositionClient(holder, delta)`를 사용해 클라이언트 보간 추종 적용. |

## 2026-02-25 WeaponData Transform Column Integration

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Unified schema flag | `UseUnifiedWeaponTransformColumns=true` 기본값 추가. |
| Scale integration | `weapon_scale` 단일 컬럼으로 `weapon_scale_x/y`를 통합 처리. |
| Muzzle integration | `muzzle_forward_offset`, `muzzle_side_offset` 컬럼으로 기존 `muzzle_distance`, `muzzle_offset_x/y` 경로를 통합 처리. |
| Base offset policy | 통합 모드에서는 `muzzle_base_offset_x/y`를 테이블에서 읽지 않고 기본값(프로퍼티)만 사용. |
| Legacy compatibility | 필요 시 `UseUnifiedWeaponTransformColumns=false`로 기존 분리 컬럼 읽기 경로 사용 가능. |

## 2026-02-25 Left-Side Aim Inversion Reinforcement

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| FlipY policy | `CorrectWeaponSpriteYFlipOnLeft` default changed to `false` and automatic left-side `FlipY` compensation disabled. |
| Mirror rotation compensation | Added `CompensateLeftMirrorRotationWithoutHolderNegScale=true`; applies `angle = 180 - angle` normalization only when holder is owner-child (not detached holder). |
| Goal | Keep weapon visual up/down direction consistent on left-side aiming while preserving muzzle/fire logic path. |

## 2026-02-25 WeaponHolder Left Mirror Restore

### WeaponModelComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Holder local scale sign | `ApplyHolderCounterFlipScaleClient()` now applies `scale.x = -abs(x)` when owner faces left (`owner scale.x < 0`). |
| Intent | Restores requested left-facing local mirror behavior for WeaponHolder. |

## 2026-02-25 Projectile Target Filter + Monster HP Split

### ProjectileComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Monster target helper | Added `IsMonsterEntity(target)` with priority: `HPSystem.IsMonster` -> `PlayerComponent` exclusion -> `MonsterChaseComponent` fallback. |
| Single-hit filter | `HandleTriggerEnterEvent` now ignores non-monster HP entities and keeps projectile alive (penetration). |
| Area filter | `IsDamageTargetCandidate` now excludes non-monster entities before HP/dead checks. |
| Intent | Prevent friendly/player damage while preserving existing wall/obstacle destroy flow. |

### HPSystemComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| New property | Added `IsMonster` (boolean, default `false`) for monster/player damage-rule split. |
| Invincible gate split | `ApplyDamage` now applies i-frame block only when `IsMonster ~= true`. |
| Invincible window split | `SetInvincibleWindowServer` hit-window call is now player-only (`IsMonster ~= true`). |
| Intent | Keep player hit feedback/i-frame, allow monster multi-hit acceptance in dense projectile overlaps. |

### MonsterSpawnComponent (Updated)
- **File:** RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua
- **Sync File:** RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock
- **Updated:** 2026-02-25

#### Added/Changed
| Item | Detail |
|---|---|
| Spawn-time monster flag | `SpawnMonsterByRow` now sets `spawned HPSystem.IsMonster = true` immediately after spawn. |
| Boss/common coverage | Same spawn path applies to both normal monsters and boss rows. |
| Intent | Guarantee combat-side monster identification regardless of row schema or model composition. |

## 2026-02-25 Combat+Growth Data Table Alignment (Backward Compatible)

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Required WeaponData contract checks | Added one-time warnings for `fire_type`, `projectile_id`, `summon_id`, `fire_rate`, `reload_time`, `max_basic_resource`, `dmg_raito`, `start_level`, `max_level`, `required_exp`. |
| Backward-compatible damage ratio | Keeps `dmg_raito` as primary and accepts `dmg_ratio` only as optional alias fallback. |
| Summon binding priority | Fixed explicit load order for `SummonData.projectile_id/fire_rate/duration/cooldown/turret_model` and projection to runtime slot snapshot. |
| Projectile model diagnostics | Missing `projectile_model` now logs once with `weaponId` and `projectileId`. |
| CSV empty token normalization | `GetRowString` now treats `""`, `"-"`, `"null"`, `"nil"` as empty values before fallback. |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| WeaponSwap snapshot trust | Fire path remains table-independent and consumes only live snapshot values from WeaponSwap/slot apply. |
| Detailed fire-block diagnostics | Added context-rich warnings including `CurrentWeaponId`, `CurrentProjectileId`, `CurrentSummonId`, `CurrentFireType`, `CurrentProjectileType`. |
| Type normalization guards | Added normalization for `CurrentFireType`/`CurrentProjectileType` and invalid type fallback logs. |
| Area projectile guard | `area_projectile` with invalid splash radius is downgraded to `single_projectile` with warning. |

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| WeaponData contract checks | Added one-time missing checks for `start_level`, `max_level`, `required_exp`. |
| WeaponLevelData contract checks | Validates `level_1..level_10`; if missing, logs once and preserves fallback (`level_1` then `1.0`). |
| Reapply timing hardening | Added map-enter reapply path to enforce `ApplyWeaponPowerToFireServer` consistency after init/swap/tag transitions. |
| CSV empty token normalization | `GetRowString` now handles `""`, `"-"`, `"null"`, `"nil"` as empty values. |

### CharacterDataInitComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/CharacterDataInitComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| PlayerbleData contract checks | Added one-time checks for `player_hp`, `player_atk`, `movespeed`, `weaponslot1~4`, `tag_skill`. |
| Init sequence stabilization | After slot initialization from PlayerbleData, force weapon power reapply through `WeaponLevelUpComponent`. |
| Current slot compatibility | Keeps existing policy: empty `current_weaponslot` does not overwrite runtime slot. |
| CSV empty token normalization | `GetRowString` now handles placeholder-empty tokens consistently. |

### TagSkillComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TagSkillComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TagSkillComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Character-skill contract checks | Added one-time warning when `PlayerbleData.tag_skill` is missing for current character row. |
| Skill buff exclusivity guard | Explicitly validates mutual exclusivity of `plus_speed` vs `plus_dmg` and logs invalid dual/none rows once. |
| Cooldown traceability | Cooldown-block logs include remaining time for easier runtime verification (`tag_skill_a/b` separation). |
| CSV empty token normalization | `GetRowString` now treats empty placeholders as fallback. |

### WeaponModelComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Unified table parsing compatibility | Hardened row string extraction to normalize placeholder-empty tokens without changing existing transform/muzzle flow. |
| Missing-column noise control | Preserves fallback behavior while avoiding repeated invalid value propagation from placeholder tokens. |

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| SpawnConfig contract checks | Added required-column validation for `InnerRadius`, `OuterRadius`, `SpawnInterval`, `SpawnPerTick` with one-time warnings. |
| Monster table contract checks | Added required-column validation for `MonsterData`/`ModeMonsterData` with mode-compatible `model_type` fallback handling. |
| Mode speed-up compatibility | `ResolveMonsterStatValues` accepts `mon_spd_up` primary and `mode_mon_spd_up` alias fallback. |
| Monster identity continuity | Keeps spawn-time `HPSystem.IsMonster=true` application and validates runtime linkage for projectile target filtering. |
| CSV empty token normalization | `GetRowString` now handles placeholder-empty tokens consistently. |
## 2026-02-25 Placed Entity DataSet Auto-Binding

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Static monster auto-bind pass | Added delayed one-shot scan for map-placed monsters (`AutoBindPlacedMonsterEntities`). |
| Candidate guard | Excludes player entities and already spawned/runtime-tracked entities; binds explicit/monster-signature entities only. |
| Row resolution priority | `HPSystem.MonsterDataId` -> entity name as row id -> default earliest non-mode normal row fallback. |
| Reuse of spawn pipeline | Reuses chase/trigger/collider/stat application path so placed monsters and spawned monsters share data-driven behavior. |

### ProjectileComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| New binding fields | Added `ProjectileDataTableName`, `ProjectileDataId`, `EnablePlacedProjectileDataBinding`. |
| Static projectile auto-bind | Added delayed one-shot bind for map-placed projectiles using explicit id or normalized entity name fallback. |
| Runtime safety guard | Fired projectiles are skipped (`IsInitialized` / `OwnerEntity` guard) so launch snapshot values are preserved. |
| Applied columns | Binds `projectile_type`, `bulletspeed`, `splash_size` from `ProjectileData`. |

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Optional row-id property | Added `MonsterDataId` (string) for precise static monster table row binding. |
| Backward compatibility | Empty default keeps existing runtime behavior unchanged unless explicit id is provided. |

## [FireSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **수정일:** `2026-02-25`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 이번 수정에서 Property 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `TryFireServer` | `targetWorldPosition: Vector2` | void | 서버 발사 시작 시 총구 계산에 타깃 월드 좌표를 전달 |
| `ResolveMuzzlePositionServer` | `targetWorldPosition: Vector2` | `Vector2` | `WeaponModelComponent:GetMuzzlePosition(targetWorldPosition)` 호출로 서버 조준 정합성 보정 |

## [WeaponModelComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Core/WeaponModelComponent.mlua`
- **수정일:** `2026-02-25`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 이번 수정에서 Property 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `GetMuzzlePosition` | `targetWorldPos: Vector2` | `Vector2` | optional 타깃 좌표가 있으면 서버에서 holder 회전값 대신 `(target - pivot)` 방향으로 총구 계산 |
| `GetAimDirection` | `targetWorldPos: Vector2` | `Vector2` | 보정된 `GetMuzzlePosition(targetWorldPos)`를 기준으로 발사 방향 계산 |

## [ProjectileComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **수정일:** `2026-02-25`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 이번 수정에서 Property 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnUpdate` | `delta: number` | void | `Rigidbody.MoveVelocity` 의존을 제거하고, Rigidbody가 있을 때 `SetWorldPosition` 기반으로 이동시켜 화살 정지 문제를 방지 |

## 2026-02-25 Projectile Player-Hit Guard Hardening

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Root cause | Projectile-side monster filter alone was insufficient because receiver-side `HPSystemComponent.ResolveIncomingDamage()` still accepted projectile collisions. |
| Friendly-fire guard | Added `ShouldIgnoreProjectileDamage()` in receiver path to reject self/team projectile damage before damage resolve. |
| Team resolution | Added `ResolveCombatTeam()` using `PlayerComponent`/`HPSystem.IsMonster`/`MonsterChaseComponent` fallback. |
| Player safety policy | Player now accepts projectile damage only when owner team is resolved as `monster`; `player/unknown` owner projectiles are ignored. |

## 2026-02-25 Monster Death Effect + Fade-Out

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| New death-fade properties | Added `MonsterDeathEffectLeadTime`, `MonsterDeathFadeDuration`, `MonsterDeathFadeTick`. |
| Death sequence monitor | `StartStateMonitorTimer` now runs `ProcessMonsterDeathSequenceServer()` to detect dead monsters continuously. |
| One-shot death effect | On death start, resolves `death_effect_ruid` (`SpawnMeta` 우선, `MonsterData` fallback) and applies it once to `SpriteRenderer`. |
| Dead-contact shutdown | `PrepareDeadMonsterForFadeServer()` disables trigger/contact damage and chase/movement immediately. |
| Fade + destroy | Alpha fade via `SpriteRenderer.Color` after lead time, then `_EntityService:Destroy(monsterEntity)` when fade completes. |
| Runtime cleanup | Added runtime timer prune/clear paths for `OnEndPlay`/`OnDestroy` safety. |

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Monster death route split | `EvaluateDeath()` now returns early when `IsMonster == true` after dead-state finalization, so player game-over flow is not fired by monster death. |
| Intent | Monsters use visual fade-out lifecycle while only player death triggers run-fail/game-over orchestration. |

## 2026-02-25 Projectile Collision Reliability + Immediate Monster Death + Monster HP Bar

### ProjectileComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Physics bootstrap | Added `ConfigureProjectilePhysicsServer()` to force `PhysicsRigidbody` (`Dynamic`, `Continuous`, `NeverSleep`) and enable contact events. |
| Movement path | `OnUpdate()` now drives physics projectiles with `SetLinearVelocity` first, reducing high-speed arrow tile pass-through. |
| Contact fallback | `HandlePhysicsContactBeginEvent()` now treats `ContactedBodyEntity=nil` as environment hit and destroys/explodes projectile immediately. |
| Parent-chain target resolve | Added `ResolveMonsterDamageTargetEntity()` so child collider hits resolve to parent monster `HPSystem`. |
| Self-hit guard hardening | Added `IsSameOrChildOfEntity()` to ignore owner root/child overlap on spawn frame. |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Spawned projectile physics defaults | Projectile `PhysicsRigidbody` now explicitly sets `BodyType.Dynamic`, `CollisionDetectionMode.Continuous`, `SleepingMode.NeverSleep`. |
| Physics ownership | Added `SetServerAsPhysicsOwner()` for stable server-side contact event handling. |
| Collision-group sync | Physics collider collision group now mirrors trigger collision group when available. |

### TurretAIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Turret projectile physics defaults | Same dynamic/continuous/neversleep rigidbody profile applied to turret-fired projectiles. |
| Physics ownership | Added `SetServerAsPhysicsOwner()` for consistent server contact callbacks. |
| Collision-group sync | Physics collider collision group aligns with trigger collision group. |

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Immediate monster death trigger | `EvaluateDeath()` now calls `NotifyMonsterDeathSequenceServer()` when `IsMonster == true`, avoiding monitor-interval delay. |
| Spawn resolver | Added `ResolveMonsterSpawnComponentForDeathServer()` fallback scan to locate `MonsterSpawnComponent` in same map context. |

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Death timing | `MonsterDeathEffectLeadTime` default changed to `0` for immediate dead-state transition. |
| Monster HP bar | Added NameTag-based HP bar runtime (`EnableMonsterHPBar`, segment/offset/font options) with periodic update and spawn/bind-time setup. |
| Death + HP bar integration | `BeginMonsterDeathSequenceServer()` now hides HP bar immediately when death sequence starts. |
| Lifecycle cleanup | Added HP bar runtime clear/prune paths in `OnEndPlay`/`OnDestroy`. |

## 2026-02-25 Monster Overlap No-Stop / No-Friendly-Damage

### MonsterChaseComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterChaseComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Contact-target hard filter | `IsPotentialPlayerTargetServer()` now accepts only real user entities and explicitly excludes `HPSystem.IsMonster == true` targets. |
| User resolver | Added `IsUserEntityServer()` helper to validate overlap target against `_UserService.UserEntities`. |
| Effect | Monster-vs-monster overlap no longer enters `ContactTargetPlayer` path, so monsters do not stop each other on contact. |

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Monster-attack filter | Added `ShouldIgnoreMonsterAttackDamage()` in `ResolveIncomingDamage()` monster-attack branch. |
| Team rule | Same-team contact/attack damage is ignored (`monster -> monster` blocked). |
| Effect | Monster overlap/접촉 상황에서 상호 데미지가 누적되지 않음. |

## 2026-02-25 Monster HP Bar Size Downscale (Model Ratio)

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| HP bar X scale by model | Added `MonsterHPBarModelScaleXMultiplier` and applied model `TransformComponent.Scale.x` to segment count in `ResolveMonsterHPBarLayoutServer()`. |
| HP bar Y scale by ratio | Added `MonsterHPBarModelScaleYMultiplier` and applied `(scale.y / scale.x)` ratio to computed font size for vertical shrink. |
| Clamp controls | Added `MonsterHPBarMinSegments`, `MonsterHPBarMinFontSize` to prevent unreadable tiny bars. |
| Font default downscale | `MonsterHPBarFontSize` default lowered `10 -> 7`, `MonsterHPBarMinFontSize` default lowered `4 -> 2`. |
| Compact label mode | `MonsterHPBarShowNumeric` default changed to `true`; label now renders `current/max` only for clip-safe readability. |
| Runtime apply path | `UpdateMonsterHPBarByEntityServer()` now uses per-entity layout (`Segments`, `FontSize`) before writing `NameTagComponent`. |

## 2026-02-25 Ammo Integration + Damage Formula Fix

### ReloadComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Slot max-ammo cache | Added `_T.MaxAmmoBySlot` and initialized per slot in `OnInitialize`. |
| New API | Added `SetSlotMaxAmmo(slot, maxAmmo)` (server) and clamps slot ammo with current max. |
| Slot-aware clamp/reload | `StartReloadForSlot`, `CompleteReload`, `GetSlotAmmo`, `SetSlotAmmo` now use slot max ammo instead of global-only `MaxAmmo`. |
| Swap max sync | `SetCurrentWeaponSlot` now applies target slot max to `MaxAmmo` and clamps restored ammo. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Slot schema extension | Added `MaxAmmo` normalization field in `NormalizeSlotData()` with numeric clamp. |
| WeaponData max-ammo parse | `ApplyWeaponRowToSlotDataServer` now stores `max_basic_resource` into `data.MaxAmmo` and seeds slot ammo on row apply. |
| Runtime snapshot | `CaptureRuntimeToSlot()` now captures `ReloadComponent._T.MaxAmmoBySlot[slot]` into slot data. |
| Combat apply bridge | `ApplySlotDataToCombat()` now calls `reloadComponent:SetSlotMaxAmmo(finalSlot, data.MaxAmmo)` before slot ammo apply. |

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Final attack formula fix | `ApplyWeaponPowerToFireServer` now computes `BasePlayerAtk * DamageRatio(dmg_raito) * LevelMultiplier`. |
| Weapon config ratio cache | `LoadWeaponConfigRowsServer` now parses and caches `DamageRatio` from `dmg_raito` with `dmg_ratio` fallback. |
| Default safety | `EnsureWeaponProgressByIdServer` default config now includes `DamageRatio = 1.0`. |

## 2026-02-25 Damage Formula Runtime Enforcement

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Fire-time formula sync | Added `SyncWeaponAttackBeforeFireServer()` and call at start of `TryFireServer()`. |
| Stale attack guard | Every fire attempt now re-applies `WeaponLevelUpComponent.ApplyWeaponPowerToFireServer(CurrentWeaponId)` before damage calculation. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Swap overwrite guard | `ApplySlotDataToCombat()` now skips direct `BaseWeaponAttack = data.Damage` overwrite when `WeaponLevelUpComponent` is available. |
| Formula priority | Keeps level-based final attack formula as authoritative path after swap apply. |

## 2026-02-25 dmg_ratio NotFound 제거 + 데미지 공식 강제 경로

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Alias 제거 | `dmg_ratio` alias 조회 제거, `dmg_raito`만 사용하도록 정리. |
| NotFound 방지 | 존재하지 않는 `dmg_ratio` 열 접근으로 발생하던 `[LEA-3011] NotFound` 로그 경로 제거. |

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Alias 제거 | Weapon config load에서 `dmg_ratio` fallback 제거, `dmg_raito` 실패 시 `1.0` 기본값 사용. |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| FinalDamage 강제 동기화 | `CalculateFinalDamage()` 시작 시 `ResolveWeaponAttackFromLevelServer()` 호출로 레벨 기반 공격력 우선 적용. |
| Stale 값 차단 | 발사 직전 동기화 + 최종 데미지 계산 시 재동기화의 이중 경로로 스냅샷 잔존 문제 차단. |

## 2026-02-25 dmg_ratio Alias 복원 + 계산식 강제 적용

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Alias fallback 복원 | `EnableDamageRatioAliasFallback=true`에서 `dmg_raito` 실패 시 `dmg_ratio` fallback 다시 사용. |

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Alias fallback 복원 | `EnableDamageRatioAliasFallback=true`에서 `LoadWeaponConfigRowsServer`가 `dmg_ratio` fallback 허용. |
| 적용 로그 추가 | `EnableDebugLogs=true`일 때 `baseAtk/dmgRatio/levelMul/finalAttack` 계산 로그 출력. |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| 계산식 강제 경로 | `CalculateFinalDamage()`가 `ResolveWeaponAttackFromLevelServer()`를 우선 호출해 레벨 공식 공격력을 최우선 적용. |

## 2026-02-25 Smite One-Shot Visual Spawn (No Projectile Hitbox)

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Smite visual options | Added `EnableSmiteVisualSpawn` and `SmiteVisualLifetime` properties. |
| One-shot visual path | `SmiteAttackServer()` now triggers `SpawnSmiteVisualServer(targetWorldPosition)` and keeps smite as non-projectile damage logic. |
| No gameplay collision/damage from visual | `PrepareSmiteVisualEntityServer()` disables `ProjectileComponent`, `TriggerComponent`, and physics collider/body on spawned visual entity. |
| Lifecycle cleanup | Added `ClearSmiteVisualRuntimeServer()` and `ClearAllSmiteVisualRuntimeServer()`; called from both `OnEndPlay()` and `OnDestroy()`. |

## 2026-02-25 Tag B Weapon Swap Override Fix

### TagManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Root cause fix | Removed initial `CharacterStates[2]` clone from character A snapshot. |
| Behavior change | Character B now starts with empty snapshot (`nil`), so first tag-to-B keeps `PlayerbleData(player_b)` weapon slots instead of being overwritten by A state. |
| Stability | Subsequent tags still preserve per-character runtime state via existing `StoreCharacterState()`/`ApplyCharacterState()` flow. |

## 2026-02-25 Smite Timing Control (Visual Lifetime + Damage Delay)

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Damage hit timing property | Added `SmiteDamageDelay` property to control when smite damage is applied after cast. |
| Timing split | `SmiteVisualLifetime` controls only visual lifespan, while `SmiteDamageDelay` controls damage timing independently. |
| Delayed damage scheduler | Added `ScheduleSmiteDamageServer()` and `ApplySmiteDamageAtPositionServer()` so instant/delayed paths share same hit logic. |
| Cleanup safety | Added `ClearAllSmiteDamageTimerServer()` and called it from `OnEndPlay()`/`OnDestroy()` to prevent orphan timer callbacks. |

## 2026-02-25 Per-Smite Timing From ProjectileData

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Slot state fields | Added slot runtime fields `SmiteDamageDelay`, `SmiteVisualLifetime` in `NormalizeSlotData()`. |
| ProjectileData binding | `ApplyWeaponRowToSlotDataServer()` now reads `smite_damage_delay`, `smite_visual_lifetime` from projectile rows and applies per-weapon timing. |
| Fire bridge | `ApplySlotDataToCombat()` writes slot timing values into `FireSystemComponent.SmiteDamageDelay/SmiteVisualLifetime`. |
| Tag/Swap persistence | `CaptureRuntimeToSlot()` now captures smite timing from `FireSystemComponent`, preserving per-character/per-slot state after tag/swap. |

### ProjectileData (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/ProjectileData.csv`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| New columns | Added `smite_damage_delay`, `smite_visual_lifetime` columns for per-smite timing control. |
| Initial values | `deathperado_pt`, `gungnir_pt` set to `0`, `0.35` to preserve current behavior baseline. |

## 2026-02-25 DropSystem Implementation (SPEC_DropSystem)

### ItemDropManagerComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| New drop runtime component | Added `ItemDropManagerComponent` for server-authoritative drop/pickup flow and client-side magnet visuals. |
| Data cache load | `OnBeginPlay()` now loads `DropData` + `ItemData` into `_T.DropCache` and `_T.ItemCache`. |
| Drop execution API | Added `ExecuteDropServer(deathPosition, dropId)` with slot(1~3) rate checks and empty-slot skip. |
| Gold amount interpretation | Gold (`itemId=="gold"` or `effect_type=="None"`) uses `spawnCount=1`, `payloadAmount=drop_amount`. |
| Field spawn policy | Spawns by `_SpawnService:SpawnByModelId(FieldItemModelId, "FieldItem", ...)` and enforces `MaxFieldItems` FIFO eviction. |
| Gameplay collision off | Disables projectile/trigger/physics components on spawned field items to prevent combat interaction. |
| Magnet/pickup loop | `OnUpdate(dt)` handles airborne scatter interpolation, grounded magnet movement, and pickup request dispatch. |
| Pickup authority | Added `RequestPickupServer(itemEntity, itemId)` with owner validation + runtime validity checks. |
| Pickup effects | `heal_hp -> HPSystemComponent:Heal`, `a_mag/b_mag -> ReloadComponent` all slots full refill, gold -> `GoldComponent:AddGold(payloadAmount)`. |
| Cleanup path | Added `ClearAllFieldItemsServer()` and safety cleanup in `OnEndPlay()` / `OnDestroy()`. |

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Death drop hook | `BeginMonsterDeathSequenceServer()` now resolves `ItemDropManagerComponent` and calls `ExecuteDropServer()` right after `PrepareDeadMonsterForFadeServer()`. |
| Drop metadata usage | Uses `SpawnMeta.DropId` (from `BuildSpawnMetaFromRow`) to execute per-monster drop table. |

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Run-end field cleanup | Added `TryClearFieldItemsForOwnerServer()` and call at start of `HandleRunCompletedServer()`. |
| Drop manager bridge | Uses `ItemDropManagerComponent.ClearAllFieldItemsServer()` when component is available. |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Required component list | Added `ItemDropManagerComponent` into `AttachRequiredComponentsServer()` required components. |

### Codeblock Sync Integrity

#### Added/Changed
| Item | Detail |
|---|---|
| Target serialization fix | Corrected `ContentProto.Json.Target` to plain string for DropSystem-related codeblocks (`MonsterSpawnComponent`, `LobbyFlowComponent`, `Map01BootstrapComponent`, `ItemDropManagerComponent`). |
| Source parity | Verified each related `.codeblock` target matches paired `.mlua` source exactly. |

## 2026-02-25 InGameHUD Implementation (SPEC_InGameHUD)

### InGameHUDComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| New in-game HUD runtime | Added `InGameHUDComponent` for client-only unified HUD rendering (timer/gold/hp/exp/ammo/reload/tag/weapon). |
| Gauge rendering | Horizontal/vertical gauge scale helpers added with 0~1 clamp and `UITransformComponent.UIScale` application. |
| Lobby visibility policy | Uses `LobbyFlowComponent.IsLobbyActive` to hide HUD in lobby. |
| Fallback-safe rendering | Path resolve + `nil/isvalid/pcall` guards for every UI field update. |
| Icon data cache | Added optional client-side `PlayerbleData` + `SkillData` cache to map standby character tag-skill icon. |
| Legacy UI fallback | When `/ui/DefaultGroup/GRInGameHUD` is missing, auto-falls back to legacy text HUD paths (`GRTimerText`, `GRHPText`, `GRAmmoText`, `GRCooldownText`, `GRWeaponText`). |
| Legacy 2-panel bars | Added legacy panel gauge fallback paths (`/ui/DefaultGroup/GRHUD_HPBack/Fore`, `/ui/DefaultGroup/GRHUD_EXPBack/Fore`) and runtime scale binding for HP/Ammo. (`GRHUD_EXPBack` is reused as ammo bar) |

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Legacy HP bar panels | Added `/ui/DefaultGroup/GRHUD_HPBack` and child `/Fore` as 2-panel HP gauge fallback. |
| Legacy EXP bar panels | Added `/ui/DefaultGroup/GRHUD_EXPBack` and child `/Fore` as 2-panel EXP gauge fallback. |

### ReloadComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Reload sync window | Added `CurrentReloadStartAt`, `CurrentReloadEndAt` sync properties for HUD progress gauge. |
| Current max ammo sync | Changed `MaxAmmo` to `@Sync` so HUD/legacy bars display weapon-specific max ammo from `WeaponData.max_basic_resource` in real time. |
| Consistent lifecycle writes | Start/complete/cancel/slot-switch/endplay paths now keep reload window sync values coherent. |
| Time helper | Added `GetServerNowSeconds()` to keep sync timestamps resilient when elapsed-seconds read fails. |

### TagManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Tag cooldown sync | Added `TagCooldownEndAt` sync property for client HUD cooldown gauge ratio calculation. |
| Cooldown lifecycle writes | `StartTagCooldownServer()` writes end timestamp, timer completion/endplay clears it to `0`. |
| Time helper | Added `GetServerNowSeconds()` for timestamp creation. |

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Current-weapon sync fields | Added `CurrentWeaponLevel`, `CurrentWeaponExp`, `CurrentWeaponRequiredExp` sync properties. |
| Sync refresh API | Added `RefreshCurrentWeaponProgressSyncServer(string weaponId)` for HUD snapshot refresh. |
| Refresh integration | On begin/map enter/add-exp/import/apply-attack paths now refresh current weapon progress sync values. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Weapon HUD sync fields | Added `CurrentWeaponSpriteRuid`, `CurrentWeaponName` sync properties. |
| Visual sync API | Added `SyncCurrentWeaponVisualFromRowServer(string weaponId)` reading `WeaponData.name/sprite_ruid`. |
| Swap apply bridge | `ApplySlotDataToCombat()` now updates weapon HUD sync fields when slot data is applied. |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-25`

#### Added/Changed
| Item | Detail |
|---|---|
| Required component list | Replaced legacy `HUDComponent` auto-attach with `InGameHUDComponent` to avoid duplicated in-game HUD display. |

## 2026-02-26 Character-Follow Reload Bar

### InGameHUDComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Character-follow reload UI | Added `CharacterReloadBarBack/Fore` entity/path properties and runtime references. |
| Show only while reloading | Reload bar now appears only during active reload window and hides immediately after reload end time. |
| Left-to-right fill | Fore panel pivot/offset setup added so 0% shows background only, 50% shows left half fill, and full fill reaches 100%. |
| 100% hold then hide | Added `CharacterReloadBarCompleteHoldTime` (default `0.12s`) so full bar is visible briefly at completion before hiding. |
| Under-player tracking | Added world-to-screen-to-UI projection (`_UILogic:WorldToScreenPosition` + `ScreenToUIPosition`) and Y-offset follow under local character. |
| Legacy/new HUD parity | Character reload bar refresh is called from both legacy text HUD flow and new HUD flow. |
| Lobby visibility integration | Added reload bar entities to both `SetHUDVisibilityClient` and `SetLegacyHUDVisibilityClient`. |

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| New panel entities | Added `/ui/DefaultGroup/GRReloadFollowBack` and child `/Fore` as runtime reload bar panel pair. |
| Fill-ready transform | Fore panel default pivot set to left (`x=0`) and left-anchored local offset for scale-based fill. |

## 2026-02-26 Right-Bottom Weapon HUD Expansion (8 Icons + Swap Icon + LV)

### InGameHUDComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Right-bottom HUD paths | Added `WeaponRightBottomRootPath`, `WeaponSwapIconPath`, and moved default `WeaponLevelTextPath` to `/ui/DefaultGroup/GRWeaponRightBottomHUD/weapon_level_text`. |
| Icon panel render | Added `RefreshWeaponRightBottomClient()` to show only current `<weapon_id>_icon` panel and hide the other 7 panels. |
| ID resolve policy | Added `ResolveCurrentWeaponIdForHUDClient()` with priority `CurrentWeaponId` sync -> `CurrentWeaponName + WeaponData(name->id)` fallback -> `FireSystem.CurrentWeaponId` fallback. |
| WeaponData cache | Added `LoadWeaponNameToIdCacheClient()` for robust name-to-id fallback lookup. |
| Lobby visibility | Added right-bottom HUD visibility bridge to both `SetHUDVisibilityClient` and `SetLegacyHUDVisibilityClient`. |
| Legacy compatibility | Even when `GRInGameHUD` root is missing, right-bottom weapon HUD updates continue in legacy mode. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Current weapon id sync | Added `@Sync property string CurrentWeaponId = ""`. |
| Sync write point | `SyncCurrentWeaponVisualFromRowServer()` now writes `CurrentWeaponId` together with `CurrentWeaponName` and `CurrentWeaponSpriteRuid`. |

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Right-bottom root | Added `/ui/DefaultGroup/GRWeaponRightBottomHUD`. |
| 8 weapon icon panels | Added `bow_icon`, `cannon_icon`, `turret_minigun_icon`, `deathperado_icon`, `gun_icon`, `fireball_icon`, `turret_sniper_icon`, `gungnir_icon`. |
| Swap icon panel | Added `/ui/DefaultGroup/GRWeaponRightBottomHUD/weapon_swap_icon` (visual-only panel). |
| Level text panel | Added `/ui/DefaultGroup/GRWeaponRightBottomHUD/weapon_level_text` with default text `LV1`. |
| Placement preset | Current icon `(770,-430)`, swap icon `(912,-430)`, level text `(824,-492)`, icon size `96x96`. |

## 2026-02-26 DefaultGroup UI JSON Parse Hotfix

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Maker load blocker fix | Repaired two broken `Text` string literals that were missing closing quotes, which invalidated entire JSON payload. |
| Back button label safety | `/ui/DefaultGroup/GRRankingPanel/GRBackButton` text corrected to `BACK`. |
| Ranking row template safety | `/ui/DefaultGroup/GRRankingPanel/GRRankingRowTemplate/NicknameText` text corrected to `PLAYER`. |
| Validation | `ConvertFrom-Json` parse succeeds after patch (`Entities=71`). |

## 2026-02-26 Main UI Group Split (DefaultGroup InGame-Only)

### UI Resources (Updated)
- **Files:** `ui/DefaultGroup.ui`, `ui/MainGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| New group | Added `ui/MainGroup.ui` with root `/ui/MainGroup`. |
| Moved from Default to Main | `GRStartButton`, `GRLobbyPanel*`, `GRRankingPanel*`, `GRResultPanel`, `GRReentryPopup*` moved to `/ui/MainGroup/*`. |
| Legacy summary text restore | Added `/ui/MainGroup/GRRankingText`, `/ui/MainGroup/GRMyRankText` for legacy path compatibility. |
| DefaultGroup role narrowed | `DefaultGroup` now keeps in-game HUD/combat UI roots only (`GRInGameHUD/legacy HUD/GRScoreText/WeaponWheel/Shop/...`). |

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Main defaults | `StartButtonPath`, `RankingTextPath`, `MyRankTextPath`, `UIRootPath` defaulted to `/ui/MainGroup/*`. |
| Fallback root | Added `UIRootFallbackPath = "/ui/DefaultGroup"`. |
| Resolver chain | `ResolveUIEntity` now resolves in order: exact path -> main root leaf -> fallback root leaf. |

### RankingUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/RankingUIComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Main defaults | Ranking/Lobby panel paths defaulted to `/ui/MainGroup/*`. |
| Root properties | Added `UIRootPath`, `UIRootFallbackPath`. |
| Legacy text fallback | `RankingTextFallbackPath`, `MyRankTextFallbackPath` defaulted to `/ui/DefaultGroup/*`. |
| Hardcoded root 제거 | `"/ui/DefaultGroup"` 하드코드를 제거하고 root property 기반 탐색으로 변경. |

### InfiniteModeComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Path split policy | `ResultPanelPath`, `ReentryPopupPath`, `Reentry*ButtonPath`는 `/ui/MainGroup/*` 유지, `ScoreTextPath`는 `/ui/DefaultGroup/GRScoreText`로 설정. |
| Root fallback | Added `UIRootPath`, `UIRootFallbackPath` and root-based fallback in `ResolveUIEntity`. |

### Map01BootstrapComponent + games.map (Updated)
- **Files:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`, `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Bootstrap default | `LobbyUIRootPath` default changed to `/ui/MainGroup`. |
| Map override | `/maps/games/LobbyBootstrap` override updated to `/ui/MainGroup`. |

## 2026-02-26 InGame HUD Cleanup (Top-Left Removal + Bottom Bar Numeric Text)

### InGameHUDComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Top-left text HUD forced hidden | Added `HideDeprecatedTopLeftLegacyTextsClient()` and applied it during refresh/legacy visibility to keep `GRHPText`, `GRAmmoText`, `GRCooldownText`, `GRWeaponText` non-visible. |
| Bottom HP text binding | Added `LegacyHPBarValueTextEntity/Path` and changed HP label output to `체력 : current/max`. |
| Bottom ammo text binding | Added `LegacyAmmoBarValueTextEntity/Path` and changed ammo label output to `탄창 current/max`. |
| Legacy visibility policy | `SetLegacyHUDVisibilityClient()` now controls bottom bars + new bar texts, not deprecated top-left text widgets. |

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| HP bar value text | Added `/ui/DefaultGroup/GRHUD_HPBack/HPValueText` (bar 내부 중앙 텍스트). |
| Ammo bar value text | Added `/ui/DefaultGroup/GRHUD_EXPBack/AmmoValueText` (bar 내부 중앙 텍스트). |
| Ammo bar thickness | Increased `/ui/DefaultGroup/GRHUD_EXPBack` and `/Fore` height for better numeric readability. |

## 2026-02-26 HUD/Score Visibility Stabilization Hotfix

### InGameHUDComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Value text hard visibility | During legacy HUD refresh, `HPValueText`/`AmmoValueText` are explicitly re-enabled so external visibility toggles do not keep them hidden in-game. |
| Gameplay fallback 강화 | `IsGameplayRunningClient()` now additionally checks `MonsterSpawnComponent.IsSpawnActive` and `FireSystemComponent.CanAttack` to avoid stale lobby-state hiding. |

### InfiniteModeComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InfiniteModeComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Score UI refresh loop | Added lightweight client timer (`ScoreUIRefreshInterval`, default `0.2s`) to continuously correct `GRScoreText` visibility. |
| Lobby fallback 강화 | `IsLobbyActiveForScoreClient()` now delegates to `IsGameplayRunningForScoreClient()` with timer/spawn/movement/attack checks. |
| Timer cleanup | Added `ScoreUIRefreshTimerId` cleanup in `OnEndPlay`. |

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Main UI recovery | Restored `ResolveEffectiveLobbyStateClient()` to sync-authoritative `IsLobbyActive` so lobby `MainGroup` widgets are not hidden by client-side false positives. |
| Heuristic rollback | Removed `IsGameplayRunningClient()` fallback path from `LobbyFlowComponent` because it could classify lobby as in-game in edge states. |

## 2026-02-26 HP/Ammo Value Text Render Visibility Fix

### InGameHUDComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Value text hard-force write | Added `SetValueTextByPathClient()` to force `Entity.Enable/Visible=true` and `TextComponent.Enable=true` while applying HP/Ammo text values. |
| Legacy label path update point | `RefreshLegacyHPTextClient()` and `RefreshLegacyAmmoAndCooldownTextClient()` now use value-text dedicated writer for `HPValueText` / `AmmoValueText`. |

### DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| HP text draw priority | `/ui/DefaultGroup/GRHUD_HPBack/HPValueText` display order raised to `14`, `TextComponent.OverrideSorting=true`. |
| Ammo text draw priority | `/ui/DefaultGroup/GRHUD_EXPBack/AmmoValueText` display order raised to `15`, `TextComponent.OverrideSorting=true`. |

## 2026-02-26 PopuiGroup Weapon Wheel Split (DefaultGroup 분리)

### UI Resources (Updated)
- **Files:** `ui/DefaultGroup.ui`, `ui/PopuiGroup.ui`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Wheel root migration | Removed `/ui/DefaultGroup/GRWeaponWheelRoot*` from `DefaultGroup`. |
| New UI group | Added `ui/PopuiGroup.ui` with `/ui/PopuiGroup` (`GroupOrder=4`). |
| Pop wheel structure | Added `/ui/PopuiGroup/GRWeaponWheelRoot`, `GRWeaponWheelDim`, 슬롯 `Slot1~4`, 중앙 `Center*` 노드. |
| Wheel background sprite | Applied fixed wheel background `DataId=499c70eab41cfeb418a3ad9f87fd0285`. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Slot UI Sync fields | Added synced per-slot UI snapshot fields (`Slot{1..4}WeaponId/Name/SpriteRuid/Level/Exp/RequiredExp`). |
| Sync snapshot methods | Added `RefreshWheelSlotUISyncServer()`, `ApplyWheelSlotSyncBySlotServer()`. |
| Refresh trigger points | Snapshot refresh is called from `OnInitialize`, `InitSlotsFromPlayerbleData`, `OpenSwapMenuServer`, `ApplySlotDataToCombat`, `ImportWeaponSwapState`. |
| Level/Exp source | Integrates `WeaponLevelUpComponent:ExportWeaponProgressState()` to fill slot level/exp/required-exp. |

### WeaponWheelUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Root path cutover | `WheelRootPath` default changed to `/ui/PopuiGroup/GRWeaponWheelRoot`, `WheelDimPath` added. |
| Slot render pipeline | Added slot snapshot read/apply methods for name/icon/`LV` text/exp gauge (`Slot1~4`). |
| Center render pipeline | Added center render for weapon명/LV/exp and portrait fallback chain. |
| Portrait fallback | `CharacterDataInitComponent.CurrentIdleRuid` 우선, 미존재 시 `WeaponSwapComponent.CurrentWeaponSpriteRuid` 사용. |
| Legacy hardcode cleanup | Removed direct dependency on `"/ui/DefaultGroup/GRWeaponWheelRoot"`. |

## 2026-02-26 Weapon Wheel UI Click-to-Swap Support

### WeaponWheelUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Click swap option | Added `EnableSlotClickSwap` and `SlotClickDebounce` properties for UI click confirm control. |
| Slot button binding | Added runtime button wiring for `Slot1~4` (`EnsureSlotButtonsBoundClient`, `BindSlotButtonClient`, `UnbindSlotButtonClient`, `ClearSlotButtonsClient`). |
| Click confirm flow | Added `OnSlotClickedClient()` so wheel-open slot click sends authoritative `RequestConfirmSwapServer(targetSlot)`. |
| Lifecycle safety | Binding is ensured on `OnBeginPlay`/`OnMapEnter`/state apply, and cleaned up in `OnEndPlay` to prevent stale handlers. |
| Codeblock sync | `.codeblock(Target mLua)` updated to exact source parity with `.mlua`. |

## 2026-02-26 Weapon Wheel Input Policy Update (Icon Click Select + Space Confirm)

### WeaponWheelUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/WeaponWheelUIComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Click target scope | Slot root click binding replaced with `WeaponIcon` click target binding (`GetSlotClickTargetEntityClient`). |
| Click behavior | `OnSlotClickedClient()` now updates highlighted/pending slot only via `NotifySwapMenuClient(true, targetSlot, currentSlot)` and does not request confirm. |
| Confirm path separation | Mouse click is selection-only; final swap confirm path remains keyboard-driven (`Space`). |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Confirm input policy | `HandleKeyDownEvent()` confirm condition changed from `Mouse0 or Space` to `Space` only. |
| UX alignment | Wheel icon click selects slot, and `Space` confirms selected slot for consistent two-step selection/confirm flow. |

## 2026-02-26 games Map 48x48 RectTile Field Build

### GamesRectTileMapBuilderComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Server build flow | On begin play, resolves target RectTileMap and rebuilds deterministic tile field. |
| Grid/tile defaults | Applies `GridPixelSize=48`, `TileSetRuid=tileset://4e5436fa-e939-4c4d-9dfc-c441842dfe1e`, and enable/order defaults. |
| Fill size | Fills `(0,0) -> (47,47)` for exact `48 x 48` tile count. |
| Fill fallback | Tries tile name `Henesys_soil_1` first, then index `1` fallback if name fill fails. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Root bootstrap attach | Added `script.GamesRectTileMapBuilderComponent` to `/maps/games` root components. |
| RectTile entity | Added `/maps/games/MapleMapLayer/GRBaseRectTileMap` with `MOD.Core.RectTileMapComponent`. |
| RectTile defaults | Set `GridSize=(48,48)` and tileset `tileset://4e5436fa-e939-4c4d-9dfc-c441842dfe1e`. |

## 2026-02-26 games TileSet Global Switch + Center Spawn

### games_base.tileset (New)
- **File:** `RootDesk/MyDesk/games_base.tileset`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Global tileset resource | Added single-tile tileset resource for games map field rendering. |
| Tile image source | Uses image id `c2e42c0bf3754e73979553c8d0f32ac1` as the single tile entry (`BaseTile`). |
| TileSet id | `tileset://1a9d9bb4-4d5e-4f39-90d0-5c8ec2c3d26b`. |

### GamesRectTileMapBuilderComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/GamesRectTileMapBuilderComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| TileSet reference switch | Default `TileSetRuid` changed to `tileset://1a9d9bb4-4d5e-4f39-90d0-5c8ec2c3d26b`. |
| Fill tile key | Default `FillTileName` changed to `BaseTile` (single-tile set). |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Center spawn properties | Added `SpawnAtRectTileCenterOnConfigure`, `CenterSpawnRectTilePath`, `CenterSpawnTileCountX/Y`, `ApplyCenterSpawnOncePerUser`. |
| Center spawn logic | Added `ApplyCenterSpawnServer()` to place player at tile-field center using `RectTileMapComponent:ToWorldPosition()` midpoint. |
| One-time guard | Added per-user once guard (`_T.CenterSpawnAppliedByUser`) to avoid repeated recentering by periodic configure. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Builder override | Updated root builder override to new tileset id + `FillTileName=BaseTile`. |
| RectTile override | Updated `/maps/games/MapleMapLayer/GRBaseRectTileMap` `TileSetRUID` to new tileset id. |
| Bootstrap override | Added center spawn override values on `LobbyBootstrap.script.Map01BootstrapComponent`. |

## 2026-02-26 In-Game Lag Hotfix (Bootstrap Configure Loop)

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Periodic reconfigure scope | Added `PeriodicConfigureOnlyForUnconfiguredUsers` to skip full `ConfigurePlayer()` for already-configured user entities. |
| Warmup auto-stop | Added `StopPeriodicConfigureAfterWarmup` + `PeriodicConfigureWarmupTicks` so periodic timer stops after initial stabilization. |
| Configure cache | Added `_T.ConfiguredEntityByUserId`, `MarkUserConfiguredServer()`, `IsUserConfigureCurrentServer()` to track user-entity configure state. |
| User lifecycle reset | Added `HandleUserLeaveEvent` and `ResetUserConfigureStateServer()` so rejoin/recreate path can reconfigure once safely. |
| Source sync | `.codeblock(Target mLua)` synchronized to patched `.mlua`. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Tile rebuild clear pass | Changed `LobbyBootstrap.script.GamesRectTileMapBuilderComponent.ClearBeforeFill` to `false` to reduce initial map-load hitch while keeping full-field `BoxFill` behavior. |

## 2026-02-26 Temporary TileMap Load Disable

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Tile builder off | `script.GamesRectTileMapBuilderComponent.Enable=false`, `RebuildOnBeginPlay=false`. |
| Center spawn off | `script.Map01BootstrapComponent.SpawnAtRectTileCenterOnConfigure=false`. |
| Tile entity off | `/maps/games/MapleMapLayer/GRBaseRectTileMap` entity `enable/visible=false`, `RectTileMapComponent.Enable=false`. |

## 2026-02-26 Safe TileMap Visual Re-Enable (No Kinematicbody)

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Builder remains off | Kept `script.GamesRectTileMapBuilderComponent.Enable=false`, `RebuildOnBeginPlay=false` to prevent runtime overwrite/rebuild hitch. |
| Visual tilemap on | Re-enabled `/maps/games/MapleMapLayer/GRBaseRectTileMap` entity and `RectTileMapComponent.Enable=true`. |
| Layer safety preset | Applied `IgnoreMapLayerCheck=false`, `OrderInLayer=-1000`, `SortingLayer=Default` to keep floor tiles behind player/monster/projectile sprites. |
| Collision policy | Kept `PhysicsInteractable=false` (no Kinematicbody dependency, no tilemap collision blocking). |

### games_base.tileset (Updated)
- **File:** `RootDesk/MyDesk/games_base.tileset`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Image RUID input point | Tile image is controlled by `ContentProto.Json.datas[0].Id`; currently `c2e42c0bf3754e73979553c8d0f32ac1`. |

## 2026-02-26 TileMap Occlusion Emergency Fix (MapLayer Sort)

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Map layer sort priority | Changed `/maps/games/MapleMapLayer` `MapLayerComponent.LayerSortOrder` from `0` to `-100` so floor tilemap renders behind gameplay entities. |
| Combined safety | Kept tilemap `OrderInLayer=-1000`, `PhysicsInteractable=false`, `IgnoreMapLayerCheck=false` for non-blocking floor rendering. |

## 2026-02-26 Alternative 1 Migration (No TileMap + Single Backdrop Sprite)

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| TileMap full disable | Kept `GamesRectTileMapBuilderComponent` disabled and disabled `/maps/games/MapleMapLayer/GRBaseRectTileMap` entity + `RectTileMapComponent.Enable=false`. |
| Backdrop sprite entity | Added `/maps/games/MapleMapLayer/GRWorldBackdrop` with `MOD.Core.SpriteRendererComponent`. |
| Image RUID apply | Set `GRWorldBackdrop.SpriteRendererComponent.SpriteRUID = c2e42c0bf3754e73979553c8d0f32ac1`. |
| Requested backdrop size | Set `GRWorldBackdrop.TransformComponent.Scale = (2034, 2034, 1)`. |
| Render priority | Set backdrop `OrderInLayer = -2000` so gameplay actors render in front. |

## 2026-02-26 Player Backdrop Bounds Clamp (No Out-of-Bounds Movement)

### MovementComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| World bounds properties | Added `UseWorldBoundsClamp`, `WorldBoundsMinX/MaxX`, `WorldBoundsMinY/MaxY`, `WorldBoundsPadding`. |
| Clamp method | Added `ApplyWorldBoundsClampServer(transform)` to clamp world position on server authority. |
| Movement integration | Clamp is applied after both transform translate path and rigidbody velocity path. |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Backdrop clamp config | Added `ClampPlayerWithinBackdropBounds`, `BackdropCenterX/Y`, `BackdropSizeX/Y`, `BackdropBoundPadding`. |
| Configure injection | `ConfigurePlayer()` now computes backdrop bounds and injects movement clamp values into `MovementComponent`. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Explicit clamp override | Added `Map01BootstrapComponent` override values for transform movement + backdrop clamp bounds (initial: `2034 x 2034`, padding `24`; later corrected to `20.34 x 20.34`, padding `0.25`). |

## 2026-02-26 GRWorldBackdrop Authoritative Area Integration

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Backdrop auto-bounds | Added `UseBackdropEntityAutoBounds`, `BackdropEntityPath`, `BackdropBoundsRefreshInterval` and runtime resolver methods to derive bounds from `/maps/games/MapleMapLayer/GRWorldBackdrop`. |
| Sprite-size 기반 계산 | Added `ResolveBackdropSizeFromSpriteServer()` using `Sprite.Width/Height/PixelPerUnit` and backdrop `Transform.Scale` to compute world-space width/height. |
| Configure injection order | `ConfigurePlayer()` now refreshes backdrop bounds before injecting movement clamp values. |
| Player spawn fallback | Added `SpawnAtBackdropCenterOnConfigure` + `ApplyBackdropCenterSpawnServer()` so player spawns inside backdrop even when tile-center spawn is disabled. |
| MonsterSpawn handoff | `ConfigurePlayer()` now writes backdrop restriction/bootstrap path to attached `MonsterSpawnComponent` for consistent area rules. |

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Backdrop bounds cache | Added `RestrictMonstersToBackdrop`, `BackdropBootstrapPath`, `BackdropBoundsRefreshInterval` and cache resolver methods (`RefreshBackdropBoundsCacheServer`, `ResolveBackdropBoundsFromBootstrapServer`). |
| Spawn-area enforcement | `IsValidSpawnPosition()` now requires spawn point to be inside resolved backdrop bounds. |
| Boss spawn restriction | Added `ResolveBossSpawnPositionServer()` and applied it to boss spawn path so boss also spawns within backdrop area. |
| Monster movement clamp | Added `ApplyMonsterBackdropClampToMovementServer()` and applied to spawned/placed monsters through `ApplyMonsterStatsIfAvailable()`. |

## 2026-02-26 Backdrop Clamp Reliability Fix (Scale 4.8 Alignment)

### MovementComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Bootstrap fallback resolver | Added `EnsureWorldBoundsBootstrapServer()` and `TryApplyWorldBoundsFromBootstrapServer()` to fetch clamp config from `/maps/games/LobbyBootstrap` when runtime configure timing is missed. |
| Retry strategy | Added per-player retry gate (`_T.WorldBoundsBootstrapResolved`, `_T.WorldBoundsResolveRetryAt`) and periodic retry in `OnUpdate` until applied. |
| Safety behavior | If clamp is disabled in bootstrap, `UseWorldBoundsClamp=false` is applied explicitly to avoid stale settings. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Unit alignment fix | `Map01BootstrapComponent.BackdropSizeX/Y` override corrected to `20.34` (not `2034`) to match current `GRWorldBackdrop` transform scale `4.8`. |
| Padding retune | `BackdropBoundPadding` changed to `0.25` for a light inner margin without over-shrinking valid move area. |

## 2026-02-26 GRWorldBackdrop Bounds Stabilization Pass

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| MonsterSpawn immediate bounds refresh | `ConfigurePlayer()` now calls `MonsterSpawnComponent:RefreshBackdropBoundsCacheServer(true)` right after backdrop policy injection, reducing first-tick spawn race. |

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Bootstrap bounds refresh hook | `ResolveBackdropBoundsFromBootstrapServer()` now prefers `Map01BootstrapComponent:RefreshBackdropBoundsFromEntityServer(false)` before reading center/size, reducing stale backdrop bounds reads. |

### games.map (Updated)
- **File:** `map/games.map`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Explicit backdrop auto-bounds overrides | Added `UseBackdropEntityAutoBounds=true`, `BackdropEntityPath=/maps/games/MapleMapLayer/GRWorldBackdrop`, `BackdropBoundsRefreshInterval=1.0`, `SpawnAtBackdropCenterOnConfigure=true` on `LobbyBootstrap.script.Map01BootstrapComponent`. |

## 2026-02-26 Smite Trigger-Contact Damage Gate

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Smite hit rule | `SmiteAttackServer()` no longer applies direct positional damage; damage path is now trigger-contact only via spawned smite hit projectile. |
| New spawn method | Added `SpawnSmiteHitProjectileServer(targetWorldPosition, damage, radius)` to spawn stationary trigger hit-tile with `ProjectileComponent`. |
| Delay semantics | `ScheduleSmiteDamageServer()` now delays hit-projectile spawn timing (not direct delayed damage). |
| Compatibility bridge | `ApplySmiteDamageAtPositionServer()` now delegates to hit-projectile spawn to preserve call-site compatibility. |
| Fire config validation | `CanFireServer()` now requires smite to also have `ProjectileModelId` or `GRProjectileTemplate`, same as other projectile fire types. |

### Runtime Behavior Note
| Scenario | Result |
|---|---|
| Smite cast without trigger contact | No damage is applied. |
| Trigger enter/stay with monster | Damage is applied by `ProjectileComponent` server-side impact path. |
| Smite with splash (`SplashSize > 0`) | Spawned hit-tile uses `area_projectile`, and splash damage executes after trigger-based impact. |

## 2026-02-26 Smite Projectile-ID Behavior Hotfix (`gungnir_pt`, `deathperado_pt`)

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Projectile-ID branch | `SpawnSmiteHitProjectileServer()` now branches by `CurrentProjectileId` and explicitly handles `deathperado_pt`. |
| Gungnir visual duplicate fix | Added `PrepareSmiteHitProjectileEntityServer()` to disable renderers on smite hit projectile so gameplay hit-tile is invisible and cast visual is not duplicated. |
| Deathperado damage mode | `deathperado_pt` now uses trigger-zone single-projectile multi-hit mode (not global area explode). |

### ProjectileComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Impact/lifecycle control flags | Added `AreaExplodeOnLifetimeEnd`, `AreaExplodeOnRangeEnd`, `AreaExplodeOnEmptyPhysicsContact`, `DestroyOnImpact`, `HitOncePerTarget`. |
| Target dedupe | Added processed-target tracking (`HasProcessedTarget`, `MarkProcessedTarget`) so zone-hit projectiles can damage each monster once. |
| Non-destroy mode | `DestroyOnImpact=false` allows short-lived trigger zones to keep checking overlaps without disappearing on first contact. |

## 2026-02-26 Monster Hit Cooldown Guard (0.01s) for Double-Damage Suppression

### HPSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.codeblock`
- **Updated:** `2026-02-26`

#### Added/Changed
| Item | Detail |
|---|---|
| Monster-only cooldown props | Added `EnableMonsterHitCooldown` (default `true`) and `MonsterHitCooldownDuration` (default `0.01`). |
| Damage gate | `ApplyDamage()` now checks `IsMonsterHitCooldownActiveServer()` before processing monster damage. |
| Cooldown apply | On successful non-lethal monster hit, `ApplyMonsterHitCooldownServer()` writes server-time block window. |
| Scope policy | Player invincibility (`IsInvincible`, `HitInvincibleDuration`) path is unchanged; cooldown applies only to monsters. |

## 2026-02-26 Project GR 7-SPEC Batch (Timer/Elite/Round/Boss/DeathReset/MagPotion/Passive)

## [RoundTransitionComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/RoundTransitionComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Stage2BackgroundRuid` | string | 2스테이지 전환 시 적용할 배경 RUID |
| `PortalInteractRadius` | number | F키 포탈 상호작용 거리 |
| `LoadingPanelPath` | string | 전환 중 표시되는 로딩 패널 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `SpawnPortalAtPositionServer` | `deathPos: Vector3` | void | 보스 사망 위치에 포탈 생성(또는 위치-only 상호작용 저장) |
| `RequestStageTransitionServer` | void | void | F키 입력 기반 서버 권위 전환 요청 처리 |
| `ExecuteStageTransitionServer` | void | void | Stage2 전환, 배경 변경, 스폰 재개, 로딩 UI 토글 |

## [BossAIComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/BossAIComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `AttackInterval` | number | 보스 소환 패턴 주기 |
| `SummonMonsterId` | string | 보스가 소환할 몬스터 ID |
| `SpeedBoostMultiplier` | number | 소환 직후 몬스터 가속 배율 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `StartAttackLoopServer` | void | void | 반복 패턴 타이머 시작 |
| `AttackTickServer` | void | void | 몬스터 소환 + 감속 반경 체크 수행 |
| `CheckSlowdownServer` | `playerEntity: Entity` | void | 플레이어 근접 시 가속 해제 |

## [InventoryComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/InventoryComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MagazineA` | integer(Sync) | 캐릭터 A 탄창 보유량 |
| `MagazineB` | integer(Sync) | 캐릭터 B 탄창 보유량 |
| `PotionCount` | integer(Sync) | 포션 보유량 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ConsumeMagazineServer` | `charId: string` | `boolean` | 재장전 시작 시 탄창 1개 소모/실패 반환 |
| `AddMagazineServer` | `charId: string`, `amount: integer` | void | 탄창 아이템 누적 반영 |
| `RequestUsePotionServer` | void | void | E키 요청 기반 포션 사용 및 HP 회복 |

## [PassiveSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/PassiveSystemComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `PassiveDataTableName` | string | 패시브 데이터 테이블명 |
| `AcquiredPassiveCount` | integer(Sync) | 획득 패시브 수량 |
| `MaxPassiveSlots` | integer | 최대 패시브 슬롯 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `GetNextPassiveCandidateServer` | void | `table` | 상점 슬롯에 표시할 다음 후보 패시브 반환 |
| `ApplyRandomPassiveServer` | `gradeHint: string`, `passiveIdHint: string` | `boolean` | 구매된 패시브 실제 적용 |
| `ResetPassivesServer` | void | void | 런 종료 시 패시브/누적 스탯 초기화 |

## [MonsterSpawnComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `_T.EliteSpawnedSet` | table | 엘리트 1회 스폰 보장 집합 |
| `_T.StageStartElapsedTime` | number | 스테이지 기준 스폰 시간 오프셋 |
| `IsBossPhase` | boolean(Sync) | 보스 페이즈 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `IsEliteRow` | `row: UserDataRow` | `boolean` | 엘리트 행 판별 |
| `CheckEliteSpawnsServer` | void | void | monitor tick에서 엘리트 시간/1회 스폰 처리 |
| `OnBossDefeatedServer` | `deathPos: Vector3` | void | Stage별 보스 처치 분기(상점/포탈/Infinite popup) |

## [LobbyFlowComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsLobbyActive` | boolean(Sync) | 로비/게임플레이 상태 플래그 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `TryResetInventoryServer` | void | void | 런 종료 시 인벤토리 초기화 |
| `TryResetPassivesServer` | void | void | 런 종료 시 패시브 초기화 |
| `TryResumeMonsterSpawnServer` | void | void | 런 시작 후 스폰 재개 |

## [HPSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/HPSystemComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsDead` | boolean(Sync) | 사망 상태 동기화 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `EvaluateDeath` | void | void | 사망 시 이동/공격 잠금 및 타이머 Pause 처리 |

## [ReloadComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentAmmo` | integer(Sync) | 현재 장전 탄약 |
| `IsReloading` | boolean(Sync) | 재장전 진행 상태 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `StartReloadForSlot` | `slot: integer` | void | 재장전 시작 시 `InventoryComponent` 탄창 소모 게이트 적용 |

## [ItemDropManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MagnetRadius` | number | 아이템 자석 반경 |
| `PickupRadius` | number | 자동 픽업 반경 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnUpdate` | `dt: number` | void | 로비 중 자석/픽업 요청 중지, 에어본 보간은 유지 |
| `ApplyItemPickupEffectServer` | `runtime: table` | void | `a_mag/b_mag/heal_hp`를 인벤토리 누적으로 반영 |

## [ShopManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `PassivePrice` | integer | 패시브 기본 가격 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OpenBossRewardShopServer` | void | void | 보스 보상 상점 오픈 래퍼 |
| `ResolveCurrentCharIdServer` | void | `string` | 탄창 구매 대상 캐릭터 결정 |
| `BuildSlotDataServer` | `slotType: string` | `table` | 패시브 후보 선반영 슬롯 생성 |

## [FireSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `PassiveFlatAttack` | integer(Sync) | 패시브 고정 공격력 보정 |
| `PassiveIncreasePercent` | number(Sync) | 패시브 공격력 퍼센트 보정 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ApplyBossDamageModifierServer` | `baseDamage: integer`, `targetEntity: Entity` | `integer` | 궁니르 보스 반감(0.5) 적용 |
| `NotifyPassiveProjectileFiredServer` | void | void | 발사 성공 시 PassiveSystem 카운트 훅 호출 |

## [ProjectileComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Damage` | integer | 투사체 기본 피해 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ResolveDamageAgainstTargetServer` | `targetEntity: Entity`, `baseDamage: integer` | `integer` | 타격 직전 FireSystem 보스 반감 보정 적용 |

## [TagManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `_T.CharacterStateByIndex` | table | 캐릭터별 상태 스냅샷 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `CaptureCurrentCharacterState` | void | `table` | `state.MagazineCount` 포함 런타임 상태 캡처 |
| `ApplyCharacterState` | `state: table` | void | 태그 스왑 시 캐릭터별 탄창 복원 |

## [InGameHUDComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `PotionTextPath` | string | 포션 텍스트 UI 경로 |
| `MagazineTextPath` | string | 탄창 텍스트 UI 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RefreshInventoryTextsClient` | void | void | `포션 xN`, `탄창 xN` 표시 갱신 |

## [Map01BootstrapComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **수정일:** `2026-02-26`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `AutoAttachMissingComponents` | boolean | 플레이어 필수 컴포넌트 자동 부착 활성화 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `AttachRequiredComponentsServer` | `playerEntity: Entity` | void | `InventoryComponent`, `PassiveSystemComponent`, `RoundTransitionComponent` 부착 포함 |

## 2026-02-26 Boss Fixed Spawn Minute (14m per round)

### MonsterSpawnComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/MonsterSpawnComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Boss spawn timing policy | `GetSpawnMinuteFromRow()` now returns fixed `14` for boss rows (`mon_type=boss`), so each round boss spawn is locked to 14 minutes regardless of CSV `spawn_time`. |

## 2026-02-26 PassiveData Schema Normalization

### PassiveData.csv (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/PassiveData.csv`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Added columns | `price`, `player_b_stat` |
| Removed columns | `player_a_stat-copy6`, `-copy8`, `-copy9`, `-copy10`, `-copy11`, `-copy12` |
| Data cleanup | Removed trailing schema description rows and kept only runtime data rows (`pass_*`). |
| Canonical header | `id,name,grade,description,is_stackable,price,player_a_stat,player_b_stat,pass_value` |

### PassiveSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/PassiveSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/PassiveSystemComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Target stat resolution | `ResolveTargetStatForCurrentCharacter()` now reads canonical columns only: `player_a_stat` / `player_b_stat`.
| Legacy fallback removal | Removed fallback usage of `target_stat` and `player_a_stat-copy6`. |

## 2026-02-26 Shop/Inventory Hotfix

### ShopManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Slot type normalize | `heal`/`potion`을 `potion`으로 정규화하고 슬롯1 기본 타입을 `potion`으로 고정. |
| CSV column compatibility | `SlotType/ItemName/Description/Price/EffectValue` + `slot_type/name/description/price/effect_value` 동시 지원. |
| Potion purchase behavior | 포션 구매 시 즉시 회복 대신 `InventoryComponent:AddPotionServer()`로 보유량 증가. |
| Ammo purchase behavior | 탄약 구매는 `InventoryComponent:AddMagazineServer()`로 현재 캐릭터 탄창 보유량 증가 유지. |

### ReloadComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Reload gate hardening | `InventoryComponent` 또는 `ConsumeMagazineServer`가 없으면 재장전 시작을 차단(fail-closed)하도록 수정. |
| Magazine consume path | 재장전 시작 시점에만 탄창 1개 소모 계약 유지. |

### ItemData.csv (Reference)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/ItemData.csv`
- **Updated:** `2026-02-26` (검토)

| Item | Detail |
|---|---|
| Runtime-required columns | `item_id`, `effect_type`, `effect_value_1` |
| Current potion bind | `effect_type=heal_hp` 행의 `effect_value_1` 값을 `InventoryComponent.PotionHealAmount`로 로드 후 E키 사용 시 회복량으로 적용. |
| Schema change | 이번 핫픽스에서 `ItemData.csv` 컬럼 추가/삭제 없음. |

## 2026-02-26 GameStart/Inventory Acquire Hotfix

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| GRBG hide timing | `OnStartButtonClickedClient`에서 서버 Sync 대기 전에 `ApplyLobbyUIClient(false)`를 즉시 호출해 `GRBG` 잔상 노출을 제거. |

### ShopManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Ammo purchase payload | 탄창 구매 시 현재 캐릭터 1종이 아니라 `A/B` 양쪽 탄창을 모두 `amount`만큼 지급하도록 변경. |
| Inventory fail-safe | `ResolveOrAttachInventoryComponentServer`를 추가해 인벤토리 누락 시 구매 보상이 유실되지 않도록 보강. |

### ItemDropManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Item alias pickup | 드랍 적용 시 `effect_type`뿐 아니라 `item_id` 별칭(`potion_hp`, `mag_a`, `mag_b`)도 인식하도록 보강. |
| Inventory fail-safe | 드랍 획득 시 인벤토리가 없으면 즉시 부착 후 포션/탄창 누적을 수행. |

### ReloadComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Reload inventory resolve | 재장전 시작 시 `ResolveOrAttachInventoryComponentServer`로 인벤토리 누락 상태를 복구 후 탄창 소모 게이트를 수행. |

## 2026-02-26 Shop Maximum Purchase Limit

### ShopManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Maximum column binding | `ShopItemData.maximum`(또는 `Maximum`)을 슬롯별 최대 구매 횟수로 적용. |
| Runtime counters | 슬롯 데이터에 `MaxPurchaseCount`, `PurchasedCount`를 저장하고 구매 시 누적. |
| Sold-out condition | `PurchasedCount >= MaxPurchaseCount` 시 해당 슬롯을 `품절` 처리. |
| Scope | 구매 횟수 카운트는 상점 오픈 시 `BuildCurrentSlotsServer()`에서 재생성되어 샵 오픈 단위로 초기화. |

## 2026-02-26 Tag HP Swap Consistency Hotfix

### TagManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Initial state seeding | `BuildInitialCharacterStateByIndexServer()`를 추가해 대상 캐릭터 상태가 비어 있을 때 현재 활성 캐릭터 HP를 복사하지 않고 대상 캐릭터 기본 HP로 초기화. |
| Base HP resolver | `ResolveCharacterBaseHPServer()`를 추가해 `CharacterDataInitComponent`의 `player_hp`를 우선 사용, 실패 시 현재 `HPSystem.MaxHP`로 폴백. |
| Snapshot schema extension | `CaptureCurrentCharacterState()`에 `state.MaxHP` 캡처를 추가해 스왑 복원 시 HP/MaxHP 정합성 보강. |
| Restore hardening | `ApplyCharacterState()`에서 상태 누락 시 초기 상태를 생성하고 `MaxHP` 먼저 반영 후 `CurrentHP`를 적용하도록 변경. |

## 2026-02-26 Shop Table Source (userdataset)

### ShopManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.codeblock`
- **Updated:** `2026-02-26`

| Item | Detail |
|---|---|
| Shop table source | `ShopDataTableName` 기본값을 `ShopItemData.userdataset`으로 변경하여 `.userdataset` 테이블을 직접 로드하도록 조정. |

## 2026-02-27 Start Button A/B Reset + Origin Position Reset

### LobbyFlowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Run-start reset switches | Added `ResetABDataOnRunStart`, `ResetPositionOnRunStart`, `RunStartPositionX`, `RunStartPositionY` properties. |
| Start-button reset hook | `BeginInGameStateServer()` now calls `PrepareRunStartStateServer()` before gameplay start. |
| A/B data reset path | Added `TryResetTagStateForRunStartServer()` + existing `TryResetInventoryServer()`/`TryResetPassivesServer()` chaining on run start. |
| Position reset path | Added `TryResetRunStartPositionServer()` to force player world position to configured origin (`0.0`, `0.0` default). |

### TagManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Run-start API | Added `ResetForNewRunServer()` to clear tag timers/cooldown, normalize active character to A, and rebuild A/B character snapshots. |
| Client sync | `ResetForNewRunServer()` now calls `NotifyTagChangedClient(1)` so run start UI follows reset index immediately. |

## 2026-02-27 Projectile Monster Hit Effect/Sound (ProjectileData.userdataset)

### ProjectileComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ProjectileComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| New properties | Added hit feedback properties: `EnableMonsterHitEffect`, `HitEffectModelId`, `HitEffectLifetime`, `EnableMonsterHitSound`, `HitSoundRuid`, `HitSoundVolume`. |
| Runtime row bind | Added `TryBindRuntimeProjectileDataServer()` so spawned projectiles also bind row data by `ProjectileDataId`. |
| Data-driven columns | Added row binding for `hit_effect_model`, `hit_effect_lifetime`, `hit_sound_ruid`, `hit_sound_volume` via `ApplyHitEffectRowBindingServer()`. |
| Hit effect spawn | On valid monster damage in single/area flow, `TrySpawnMonsterHitEffectServer()` spawns short-lived visual effect entity and auto-destroys it after lifetime. |
| Hit sound playback | Added `TryPlayMonsterHitSoundAtServer()` to play impact sound to clients using `_SoundService` at hit position. |
| Splash sound policy | In `ExplodeServer()`, splash hit sound now plays only once per explosion even when multiple monsters are damaged. |
| Safety guards | Spawn path uses nil/isvalid checks and disables collision/damage-related components on effect entity (`PrepareVisualOnlyHitEffectEntityServer`). |

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| ProjectileData id normalization | Added `NormalizeProjectileDataIdToken()` for safe/consistent id tokens. |
| Projectile spawn binding | `SpawnProjectileServer()` now snapshots `ProjectileDataTableName` + `ProjectileDataId` into spawned `ProjectileComponent`. |
| Smite hit projectile binding | `SpawnSmiteHitProjectileServer()` also passes `ProjectileDataTableName` + `ProjectileDataId` to hit projectile entity. |
| Summon runtime id cleanup | `SummonTurretServer()` now normalizes `runtime.ProjectileId` before passing to turret AI. |

### TurretAIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/TurretAIComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Turret projectile binding | `SpawnTurretProjectileServer()` now writes `ProjectileDataTableName` + `ProjectileDataId` to spawned projectile. |
| Id normalization helper | Added `NormalizeProjectileDataIdToken()` for turret runtime config ids. |

### ProjectileData.csv (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/ProjectileData.csv`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| New columns | Added `hit_effect_model`, `hit_effect_lifetime`, `hit_sound_ruid`, `hit_sound_volume` header columns for `ProjectileData.userdataset` schema alignment. |
| Existing rows | Existing projectile rows were migrated with empty defaults so behavior stays unchanged until effect values are filled in sheet. |

## 2026-02-27 Weapon/Summon Cooldown Split

### FireSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/FireSystemComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Cooldown state map | Added `_T.CooldownStateByKey` / `_T.CurrentCooldownKey` runtime state to track cooldown independently per `weaponId + fireType + summonId` key. |
| Fire gate sync | `CanFireServer()` now calls `SyncCooldownStateForCurrentWeaponServer()` before readiness check, preventing summon cooldown from blocking unrelated weapon keys after swap/tag. |
| Per-key timer start | `StartFireCooldown()` now writes cooldown to keyed state and starts keyed timer; callback restores only that key state. |
| Summon cooldown path | Removed direct mutation `self.FireCooldown = self.CurrentSummonCooldown` from `SummonTurretServer()` and resolved summon cooldown in `ResolveCurrentCooldownDurationServer()`. |
| Cleanup API | Added `ClearAllFireCooldownTimerServer()` and wired `OnEndPlay`/`OnDestroy` to clear all keyed timers safely. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Swap-time cooldown restore | `ApplySlotDataToCombat()` now calls `FireSystemComponent:SyncCooldownStateForCurrentWeaponServer()` after slot fire fields are applied so active slot immediately reflects its own cooldown key state. |

## 2026-02-27 Weapon Level Override Data Integration

### WeaponLevelUpComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponLevelUpComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Override table contract | Added `WeaponLevelOverrideTableName = "WeaponLevelOverrideData"` and runtime cache `_T.OverrideByWeaponLevel`, `_T.IsOverrideLoaded`. |
| Override loader | Added `LoadWeaponLevelOverrideRowsServer()` with `(weapon_id|level)` key cache, `enabled == 1` filter, duplicate-key warning with first-row-wins policy. |
| Override resolver/merge | Added `GetOverrideForWeaponLevel()` and `MergeOverrideIntoSlotData()` to patch `fire_rate`, `reload_time`, `max_basic_resource`, `dmg_raito`, `projectile_id`, `summon_id`, `sprite_ruid` with null/blank fallback semantics. |
| Summon fire-rate policy | `MergeOverrideIntoSlotData()` ignores `fire_rate` override when current slot `FireType` is `summon`, preserving SummonData cooldown-driven flow. |
| Damage ratio override | `ApplyWeaponPowerToFireServer()` now prioritizes override `dmg_raito` when present for current `(weapon, level)` tuple. |
| Level-up reinjection trigger | `AddWeaponExpServer()` now calls `RequestReapplyCurrentWeaponServer()` only when `didLevelUp == true` and the leveled weapon is currently equipped. |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Reapply API | Added `ReapplyCurrentWeaponByLevelServer(weaponId, level)` to rebuild current slot from WeaponData base + level override and atomically reinject combat values. |
| Preserve apply API | Added `ApplySlotDataToCombatPreservingReload(slot, wasReloading, savedReloadEndTime)` that updates combat parameters without calling reload cancel/swap-model flow. |
| Reload preservation | Level-up reinjection keeps active reload timer and reload end-time; ammo is clamped by new `MaxAmmo` only. |
| Cooldown preservation | Reinjection updates configured cooldown value in keyed cooldown state while preserving running timer id/end state. |
| Derived parser reuse | Extracted projectile/summon derived parsing into `ApplyProjectileAndSummonDerivedDataServer()` and reused from both base apply and override requery path. |
| Runtime slot fields | Extended normalized slot payload with `DamageRatioOverride` and `NeedsProjectileRequery` to support override patching and requery signaling. |
| Level sprite override | Added `ResolveSpriteRuidWithOverrideServer()` + `ResolveWeaponLevelForVisualServer()` so `CurrentWeaponSpriteRuid` and wheel slot sprite both reflect `WeaponLevelOverrideData.sprite_ruid` when set. |

### WeaponLevelOverrideData.csv (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/WeaponLevelOverrideData.csv`
- **Updated:** `2026-02-27`

| Item | Detail |
|---|---|
| Schema | Added columns: `id, weapon_id, level, enabled, fire_rate, reload_time, max_basic_resource, dmg_raito, projectile_id, summon_id, sprite_ruid`. |
| Sample rows | Added `bow_2`, `bow_5` sample rows for level-based fire/reload/ammo override behavior validation. |
| Dataset scope | `WeaponLevelOverrideData.userdataset` creation is intentionally excluded in this change-set (Maker-side setup pending). |

## 2026-02-28 Passive Drop Item 3-Choice UI

### ItemData.csv (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/ItemData.csv`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Passive drop item rows | Added `passive_common_drop`, `passive_unique_drop`. |
| Effect type contract | Added `effect_type` values: `passive_common`, `passive_unique`. |
| Icon policy | Reused existing in-game icon RUID (`dcb2f57cb344471aaefde6dc089032b6`) for immediate visibility. |

### DropData.csv (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Data/DropData.csv`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Elite drop table | `elite_drop01.drop_item_3 = passive_common_drop`, `rate = 1`, `amount = 1`. |
| Boss drop table | `boss_drop01.drop_item_3 = passive_unique_drop`, `rate = 1`, `amount = 1`. |
| Existing rewards | 기존 potion/gold 슬롯(`drop_item_1`, `drop_item_2`)은 유지. |

### ItemDropManagerComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Pickup effect branch | `ApplyItemPickupEffectServer()`에 `passive_common`, `passive_unique` 분기를 potion/mag/gold보다 먼저 추가. |
| Passive open request | `PassiveSystemComponent:RequestPassiveSelectionFromDropServer("common"|"unique")` 호출 후 즉시 `return` 처리. |

### PassiveSystemComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/PassiveSystemComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/PassiveSystemComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| New sync property | `IsPassiveSelectionOpen`(Sync) 추가. |
| New server APIs | `RequestPassiveSelectionFromDropServer`, `BuildPassiveCandidatesServer`, `RequestSelectPassiveFromDropServer` 추가. |
| Runtime state machine | `_T.SelectionToken`, `_T.PendingSelection`, `_T.SelectionQueue`, `_T.LockSnapshot` 기반 드롭 선택 상태/큐 관리 추가. |
| Candidate rule | 비복원 랜덤 추출로 중복 없는 최대 3후보 구성. |
| Validation | 토큰 불일치/후보 외 passive id 요청 무시. |
| Queue processing | 선택창 오픈 중 추가 드롭은 큐 적재, 선택 완료 후 다음 요청 순차 오픈. |
| Gameplay lock | 선택창 오픈 시 이동/공격/태그 잠금 + 무기교체창 강제 종료 + 타이머 필요 시 `PauseGame()`, 종료 시 스냅샷 복원. |
| UI bridge | `PassiveSelectionUIComponent`의 `OpenPassiveSelectionClient`/`ClosePassiveSelectionClient` 호출 추가. |

### PassiveSelectionUIComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| UI role | 패시브 3선택 팝업 표시, 옵션 렌더링, 버튼 이벤트 바인딩, 서버 선택 요청 전달 담당. |
| Public client RPC | `OpenPassiveSelectionClient(candidates, token, grade)`, `ClosePassiveSelectionClient()` 구현. |
| Input path | `OnOptionClickedClient(index, event)`에서 `PassiveSystemComponent:RequestSelectPassiveFromDropServer(passiveId, token)` 호출. |
| Slot fallback | 후보가 3개 미만인 경우 빈 슬롯을 비활성 상태로 렌더링. |
| Map-safe binding | `OnBeginPlay`, `OnMapEnter`에서 경로 재해결 + 버튼 재바인딩 수행. |

### ui/DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| New overlay/panel | Added `/ui/DefaultGroup/PassiveDimOverlay`, `/ui/DefaultGroup/PassivePanel` (기본 hidden). |
| Panel hierarchy | Added `TitleText`, `Option1~3`, 각 옵션의 `NameText`/`DescriptionText` 자식 텍스트. |
| Render order | 패시브 팝업 `displayOrder`를 ShopPanel(8)보다 높은 18/19로 설정. |
| Interaction policy | 닫기 버튼 없이 옵션 버튼 3개만 제공(1개 선택 강제 흐름). |

### WeaponSwapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Meta/WeaponSwapComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Swap gate extension | `IsSwapAvailableServer()`에 `PassiveSystemComponent.IsPassiveSelectionOpen` 체크 추가. |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Required component list | `AttachRequiredComponentsServer()` required 목록에 `PassiveSelectionUIComponent` 추가. |

## 2026-02-28 Passive Selection Click Fix

### PassiveSelectionUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.codeblock`
- **Updated:** `2026-02-28`

| Item | Detail |
|---|---|
| Option callback index capture | `BindOptionButtonsClient()` now captures `optionIndex` per iteration before creating click callback, preventing all option callbacks from sharing an invalid loop index. |
| Stale-panel close guard | Added client `OnUpdate(delta)` sync guard that auto-closes panel when `PassiveSystemComponent.IsPassiveSelectionOpen == false`, covering missed close RPC cases. |

## 2026-03-02 Passive Selection Runtime Path Hotfix

### PassiveSelectionUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.codeblock`
- **Updated:** `2026-03-02`

| Item | Detail |
|---|---|
| Runtime parity fix | Applied the same click/close logic to `.mlua` as `.codeblock` so runtime script path cannot diverge. |
| Option callback capture | Fixed loop-index closure by capturing `optionIndex` before binding each button callback. |
| Close fallback | Added `OnUpdate(delta)` sync guard to close panel locally when server `IsPassiveSelectionOpen` is already false. |

## 2026-03-02 Passive Selection Clickable State Fix

### PassiveSelectionUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.codeblock`
- **Updated:** `2026-03-02`

| Item | Detail |
|---|---|
| Open/render order fix | In `OpenPassiveSelectionClient()`, changed call order to `SetSelectionVisibleClient(true)` then `RenderOptionsClient()` so `_T.IsOpen` is true before clickability is computed. |
| Symptom resolved | Prevents valid options from being marked non-clickable (`Click ignored: option not clickable`) immediately after panel open. |

## 2026-03-03 Camera First-Stop Bounds Split

### CameraFollowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Camera offset policy | Keeps `CameraOffset=(0,0)` baseline so camera stays character-centered in normal movement. |
| First-stop bounds split | Added `EnableCameraFirstStop` + `CameraFirstStopInsetX/Y` to clamp camera inside player move bounds, so camera stops first while player can still move in edge band. |
| Bootstrap bound source | Added `UseBootstrapBounds` + `BootstrapEntityPath` and runtime resolver to read `Map01BootstrapComponent` backdrop bounds on client. |
| Hard lock follow | When `ForceHardLockFollow=true`, applies `DeadZone/SoftZone/Damping=0` and `ScreenOffset=(0.5,0.5)` for fixed-center feel. |
| Camera readiness retry | Added timer-based retry (`CameraApplyRetryInterval`, `CameraApplyRetryMaxCount`) to handle delayed camera component initialization on begin/map-enter. |

## 2026-03-03 Camera Tile-Bounds Clamp Alignment

### CameraFollowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Tile bounds priority | Added `UseRectTileBoundsFromBootstrap` and `ResolveRectTileBoundsFromBootstrapClient()` so camera clamp uses bootstrap RectTileMap bounds first. |
| Boundary source | Reads `CenterSpawnRectTilePath`, `CenterSpawnTileCountX`, `CenterSpawnTileCountY` from `Map01BootstrapComponent`, then converts tile index bounds to world-space bounds. |
| Edge expansion | Expands sampled tile-center min/max by half tile step (`ToWorldPosition` delta) to align camera stop with tile edge boundary. |
| Fallback path | If tile bounds cannot be resolved, keeps existing backdrop-bound calculation as fallback. |
| Default behavior change | `EnableCameraFirstStop=false`, `CameraFirstStopInsetX/Y=0` defaults so camera stops on map tile boundary by default. |

## 2026-03-03 Movement Tile-Bounds Clamp Alignment

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Shared tile-bounds resolver | Added `ResolveCenterSpawnRectBoundsServer()` to convert `CenterSpawnRectTilePath` + `CenterSpawnTileCountX/Y` into world-space min/max bounds. |
| Movement clamp source change | `ConfigurePlayer()` now injects `MovementComponent.WorldBoundsMin/Max` from RectTile bounds first, and falls back to backdrop bounds only when tile resolve fails. |
| Padding policy | When RectTile bounds are used, `WorldBoundsPadding=0` is applied so movement boundary matches tile edge without early stop. |
| Spawn center consistency | `ApplyCenterSpawnServer()` now reuses the shared tile-bounds resolver to keep spawn-center and movement-clamp center aligned. |

### MovementComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/MovementComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Bootstrap fallback alignment | `TryApplyWorldBoundsFromBootstrapServer()` now tries `Map01BootstrapComponent.ResolveCenterSpawnRectBoundsServer()` first. |
| Boundary priority | Applies RectTile bounds as first priority and keeps existing backdrop bounds as fallback when tile bounds are unavailable. |
| Padding consistency | Forces `WorldBoundsPadding=0` on RectTile-bound path so runtime fallback cannot reintroduce inward inset. |

## 2026-03-03 Camera Clamp Removal (Character-Centered 0,0 Only)

### CameraFollowComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Core/CameraFollowComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Clamp removal | Removed bootstrap/tile/first-stop 기반 카메라 경계 계산 경로를 삭제하고 `UseCustomBound=false`로 고정. |
| Follow policy | 카메라는 항상 캐릭터 중심 추적만 수행하며 `CameraOffset=(0,0)`를 매 적용 시점에 강제 유지. |
| Hard-lock keep | `ForceHardLockFollow=true`일 때 `DeadZone/SoftZone/Damping=0`, `ScreenOffset=(0.5,0.5)` 유지. |
| Retry keep | 카메라 생성 타이밍 레이스 대응을 위해 `StartCameraApplyRetryClient`/`StopCameraApplyRetryClient` 유지. |

## 2026-03-03 Debug Panel Tooling

### DebugPanelComponent (New)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/DebugPanelComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/DebugPanelComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| UI click bridge | Client 버튼 클릭(`시간+5분`, `무기레벨+1`)을 서버 RPC(`RequestAddTimeServer`, `RequestWeaponLevelUpServer`)로 전달. |
| Timer debug action | `GameTimerComponent.ElapsedTime += 300`으로 5분 점프를 서버 권위로 적용해 스폰 타이밍 테스트를 즉시 수행. |
| Weapon debug action | `WeaponLevelUpComponent` 진행도(`progress.Level`)를 +1하고 화력/동기화/현재무기 재적용 파이프라인을 호출. |

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `DebugPanelEntity` | Entity | 디버그 패널 루트 엔티티 참조 |
| `BtnAddTimeEntity` | Entity | `시간 +5분` 버튼 엔티티 참조 |
| `BtnWeaponLevelEntity` | Entity | `무기 레벨+1` 버튼 엔티티 참조 |
| `EnableDebugLogs` | boolean | 디버그 패널 로그 출력 여부 |
| `IsPanelEnabled` | boolean | 디버그 패널 노출/동작 활성화 스위치(릴리즈 비활성화용) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 클라이언트 런타임 캐시 초기화, 버튼 바인딩, 패널 가시성 적용 |
| `OnMapEnter` | `enteredMap: Entity` | void | 맵 전환 시 버튼 재바인딩/가시성 재적용 |
| `RequestAddTimeServer` | void | void | 서버에서 `GameTimerComponent.ElapsedTime`을 300초 증가 |
| `RequestWeaponLevelUpServer` | void | void | 서버에서 현재 무기 진행도를 +1 처리 후 화력/Sync/재장착 적용 |

## 2026-03-03 Debug Panel UI Auto-Wiring

### DebugPanelComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/DebugPanelComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/DebugPanelComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Path fallback | Added `DebugPanelPath`, `BtnAddTimePath`, `BtnWeaponLevelPath` and path resolver so component auto-finds panel/buttons without manual entity reference wiring. |
| Release toggle | Added `IsPanelEnabled` guard to hide panel and block debug RPC calls in non-debug runs. |
| Runtime robustness | `ResolvePanelEntitiesClient()` now resolves panel root first, then path lookup, then child-name fallback order. |

### Map01BootstrapComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/Map01BootstrapComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Required component list | Added `DebugPanelComponent` to `AttachRequiredComponentsServer()` required list so player entity auto-attaches debug panel logic. |

### ui/DefaultGroup.ui (Updated)
- **File:** `ui/DefaultGroup.ui`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| New panel root | Added `/ui/DefaultGroup/DebugPanel` sprite panel for debug controls. |
| New debug buttons | Added `/ui/DefaultGroup/DebugPanel/BtnAddTime`, `/ui/DefaultGroup/DebugPanel/BtnWeaponLevel` with `ButtonComponent` + label text. |
| Wiring contract | Entity names/paths are aligned with `DebugPanelComponent` fallback keys so runtime auto-binding works immediately. |

## 2026-03-03 Passive Selection Sync Race Guard Fix

### PassiveSelectionUIComponent (Updated)
- **File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`
- **Sync File:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.codeblock`
- **Updated:** `2026-03-03`

| Item | Detail |
|---|---|
| Runtime grace timer field | Added `_T.OpenSyncGraceTimer` init in `InitializeRuntimeClient()` to keep client-local sync defer state deterministic. |
| Open-time grace arm | `OpenPassiveSelectionClient()` now sets `OpenSyncGraceTimer = 1.5` right after option render so open RPC and sync arrival can be decoupled safely. |
| Sync guard defer | `OnUpdate(delta)` now skips stale-close sync guard while grace time remains, preventing immediate false close caused by delayed `IsPassiveSelectionOpen` sync. |

### Runtime Fields
| 이름 | 타입 | 설명 |
|---|---|---|
| `self._T.OpenSyncGraceTimer` | number | 패널 오픈 직후 sync 지연 구간 동안 자동 닫힘 가드를 잠시 유예하는 클라이언트 런타임 타이머(초). |

### Functions (Updated)
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `InitializeRuntimeClient` | void | void | `_T.OpenSyncGraceTimer`를 `0.0`으로 초기화해 맵 전환/재오픈 시 grace 상태를 예측 가능하게 유지. |
| `OpenPassiveSelectionClient` | `candidates: table, token: integer, grade: string` | void | UI 오픈 렌더 직후 `OpenSyncGraceTimer=1.5`를 설정해 sync 도착 지연으로 인한 즉시 닫힘을 방지. |
| `OnUpdate` | `delta: number` | void | 패널 오픈 상태에서 grace 타이머가 남아 있으면 sync guard를 건너뛰고 타이머를 감소시켜 레이스 컨디션 구간을 흡수. |

## 2026-03-03 Unified Mana System

## [GRInventoryComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/GRInventoryComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/GRInventoryComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Mana` | integer (`@Sync`) | 기존 `MagazineA/B`를 대체하는 통합 마나 보유량 |
| `MaxMana` | integer | 통합 마나 최대치 (기존 `MaxMagazine` 대체) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ConsumeMagazineServer` | `charId: string` | `boolean` | `charId`를 무시하고 `Mana`를 1 소모, 부족 시 `ShowNoAmmoMessageClient()` 호출 |
| `AddMagazineServer` | `charId: string, amount: integer` | `void` | `charId`를 무시하고 `Mana = min(MaxMana, Mana + amount)` 적용 |
| `GetCurrentCharMagazine` | void | `integer` | 현재 캐릭터 분기 없이 통합 `Mana` 반환 |
| `SetCurrentCharMagazine` | `amount: integer` | `void` | 현재 캐릭터 분기 없이 통합 `Mana` 설정 |
| `ResetInventoryServer` | void | `void` | 런 초기화 시 `Mana`, `PotionCount`를 0으로 리셋 |
| `ShowNoAmmoMessageClient` | void | `void` | 부족 메시지를 `"마나가 부족합니다"`로 변경 |

## [ReloadComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ReloadComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 프로퍼티 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `StartReloadForSlot` | `slot: integer` | `void` | 인벤토리 탐색 마커를 `MagazineA`에서 `Mana`로 변경해 통합 마나 재장전 게이트와 연결 |

## [InGameHUDComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/UI/InGameHUDComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ManaTextEntity` | Entity | 통합 마나 텍스트 엔티티 캐시 (`MagazineTextEntity` 리네임) |
| `ManaTextPath` | string | 통합 마나 텍스트 경로 (`MagazineTextPath` 리네임, 기본 경로 유지) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnSyncProperty` | `propertyName: string, value: any` | `void` | `Mana`/`PotionCount` 동기화 변경 시 인벤토리 텍스트 즉시 갱신 |
| `RefreshLegacyAmmoAndCooldownTextClient` | void | `void` | 레거시 탄약 라벨을 `"마나 {현재}/{최대}"` 형식으로 변경 |
| `RefreshInventoryTextsClient` | void | `void` | `"탄창 xN"`을 `"마나 xN"`으로 변경하고 `ManaText*` 경로 사용 |
| `ResolveUIEntitiesClient` | void | `void` | `ManaTextEntity`와 `ManaTextPath` 기반 UI 캐시 갱신 |

## [ShopManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/ShopManagerComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 프로퍼티 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `BuildSlotDataServer` | `slotType: string` | `table` | 탄창 슬롯 기본 문구를 `"마나 보충"`, `"마나 1개 획득"`으로 변경 |
| `ApplyAmmoPurchaseServer` | `effectValue: number` | `void` | 구매 시 `AddMagazineServer("", amount)` 1회 호출로 통합 마나만 증가 |

## [ItemDropManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Combat/ItemDropManagerComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 프로퍼티 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `ApplyItemPickupEffectServer` | `runtime: table` | `void` | `a_mag`/`b_mag` 분기를 `mana` 통합 분기로 교체하고 `AddMagazineServer("", amount)` 호출 |

## [TagManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Meta/TagManagerComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 프로퍼티 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `CaptureCurrentCharacterState` | void | `table` | 캐릭터별 탄창 스냅샷(`MagazineCount`) 저장 로직 제거 |
| `ApplyCharacterState` | `charIndex: integer` | `void` | 태그 스왑 시 캐릭터별 `MagazineA/B` 복원 로직 제거 |

## [LobbyFlowComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.mlua`
- **Sync 파일명:** `RootDesk/MyDesk/ProjectGR/Components/Bootstrap/LobbyFlowComponent.codeblock`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 프로퍼티 변경 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `TryResetInventoryServer` | void | `void` | 인벤토리 탐색 마커를 `MagazineA`에서 `Mana`로 전환해 런 시작 시 통합 마나 리셋 유지 |

## [ItemData.csv]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Data/ItemData.csv`
- **수정일:** `2026-03-03`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `effect_type` | string | `mag_a`, `mag_b` 행의 `effect_type`을 `mana`로 통합 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `-` | `-` | 데이터 파일이므로 함수 없음 |
