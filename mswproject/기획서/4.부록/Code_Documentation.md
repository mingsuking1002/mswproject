
# Code Documentation

## Phase 0-2 Modular Refactor
- **수정일:** `2026-02-18`
- **범위:** `GRUtilModule + Core 2종 + Combat 4종 (총 7개)`
- **비고:** `.mlua` 유지 + `.codeblock(Target mLua)` 동기화 대상

## GRUtilModule
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/GRUtilModule.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `-` | `-` | 유틸 함수 전역 등록 컴포넌트로 별도 Property 없음 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `BootstrapUtil` | void | void | `_GRUtil` 테이블 생성 및 공통 유틸 함수 등록 |
| `OnBeginPlay` | void | void | 서버에서 유틸 등록 보장 |
| `OnMapEnter` | `enteredMap: Entity` | void | 클라이언트 맵 진입 시 유틸 재등록 |

## MovementComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/MovementComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## CameraFollowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## HPSystemComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## ReloadComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ReloadComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## FireSystemComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/FireSystemComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## ProjectileComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ProjectileComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## Phase 3 Meta Modular Refactor
- **수정일:** `2026-02-18`
- **범위:** `WeaponSwapComponent + TagManagerComponent + SpeedrunTimerComponent + RankingComponent`

## WeaponSwapComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.mlua`
- **수정일:** `2026-02-18`

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
| `RequestCancelSwapMenuServer` | void | void | 메뉴 취소/닫기 요청 |
| `RequestConfirmSwapServer` | `selectedSlot: integer` | void | 슬롯 확정 요청 |
| `ConfirmSwapServer` | `selectedSlot: integer` | void | 슬롯 확정 후 무기 상태 스왑 |
| `CaptureRuntimeToSlot` | `slot: integer` | void | 현재 전투 상태를 슬롯 데이터로 백업 |
| `ApplySlotDataToCombat` | `slot: integer` | void | 슬롯 데이터 적용(재장전/발사 파라미터 동기화) |
| `ExportWeaponSwapState` | void | table | 태그 시스템용 전체 슬롯 상태 내보내기 |
| `ImportWeaponSwapState` | `state: table` | void | 태그 시스템에서 받은 슬롯 상태 복원 |
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## TagManagerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## SpeedrunTimerComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## RankingComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingComponent.mlua`
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
| `GetTopRanksServer` | `mode: integer, count: integer` | table | 모드별 상위 랭킹 조회 |
| `GetMyRankServer` | `mode: integer` | table | 모드별 내 순위 조회 |
| `LoadLocalBestRecordsServer` | void | void | 로컬 최고기록 로드 |
| `SaveLocalBestRecordServer` | `mode: integer, value: number` | void | 로컬 최고기록 저장 |
| `FormatScoreForDisplay` | `mode: integer, scoreValue: integer` | string | UI 표기용 포맷 변환 |
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## Phase 4 UI/Bootstrap Modular Refactor
- **수정일:** `2026-02-18`
- **범위:** `WeaponWheelUIComponent + RankingUIComponent + HUDComponent + Map01BootstrapComponent + LobbyFlowComponent`

## WeaponWheelUIComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponWheelUIComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## RankingUIComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingUIComponent.mlua`
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
| `RequestRankingSnapshotClient` | void | void | RankingComponent에 스냅샷 요청 |
| `RefreshRankingUIClient` | void | void | 최신 스냅샷 텍스트 반영 |
| `RenderRankingTextClient` | `topRows: table` | void | Top N 랭킹 리스트 렌더링 |
| `RenderMyRankTextClient` | `myRow: table` | void | 내 순위 라인 렌더링 |
| `ApplyVisibilityClient` | `visible: boolean` | void | 로비/인게임 전환 시 랭킹 UI 표시 제어 |
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## HUDComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/HUDComponent.mlua`
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
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## Map01BootstrapComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Map01BootstrapComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ConfigureOnBeginPlay` | boolean | 시작 시 기존 사용자 설정 수행 여부 |
| `ConfigureOnUserEnter` | boolean | 유저 입장 이벤트 기반 설정 여부 |
| `AutoAttachMissingComponents` | boolean | 누락 컴포넌트 자동 부착 여부 |
| `EnableLobbyMapSplit` | boolean | lobby/map01 분리 이동 사용 여부 |
| `LobbyMapName` | string | 로비 맵 이름 |
| `InGameMapName` | string | 인게임 맵 이름 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `HandleUserEnterEvent` | `event: UserEnterEvent` | void | 신규 유저 입장 시 플레이어 설정 |
| `ConfigurePlayerByUserIdServer` | `userId: string` | void | userId 기반 플레이어 엔티티 설정 |
| `ConfigurePlayer` | `playerEntity: Entity` | void | 필수 컴포넌트 부착 및 LobbyFlow 설정 |
| `AttachRequiredComponentsServer` | `playerEntity: Entity` | void | Phase 0~4 필수 컴포넌트 자동 부착 |
| `FindOrAddComponentSafe` | `targetEntity: Entity, typeName: string` | Component | 조회/추가 안전 래퍼 |
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |

## LobbyFlowComponent
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/LobbyFlowComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsLobbyActive` | boolean | 현재 로비 상태 여부(Sync) |
| `EnableLobbyFlow` | boolean | 로비 플로우 사용 여부 |
| `UseMapSplit` | boolean | lobby/map01 분리 맵 이동 여부 |
| `LobbyMapName` | string | 로비 맵 이름 |
| `InGameMapName` | string | 인게임 맵 이름 |
| `HideRankingDuringGameplay` | boolean | 인게임에서 랭킹 텍스트 숨김 |
| `HideTimerDuringLobby` | boolean | 로비에서 타이머 텍스트 숨김 |
| `HideCombatHUDInLobby` | boolean | 로비에서 전투 HUD 숨김 |
| `ReturnToLobbyOnRunComplete` | boolean | 런 종료 후 로비 복귀 여부 |
| `EnableKeyboardStartFallback` | boolean | 키보드 시작 폴백 허용 여부 |
| `StartButtonPath` | string | 시작 버튼 경로 |
| `RankingTextPath` | string | 랭킹 텍스트 경로 |
| `MyRankTextPath` | string | 내 순위 텍스트 경로 |
| `TimerTextPath` | string | 타이머 텍스트 경로 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `RequestStartGameServer` | void | void | 시작 요청 서버 처리(로비->인게임) |
| `SetLobbyStateServer` | `isLobby: boolean` | void | 로비 상태 전환 및 연동 컴포넌트 정책 적용 |
| `ApplyLobbyUIClient` | `isLobby: boolean` | void | 시작/랭킹/타이머/HUD 가시성 클라이언트 반영 |
| `MoveOwnerToInGameMapIfNeeded` | void | boolean | 인게임 맵 이동 요청 |
| `MoveOwnerToLobbyMapIfNeeded` | void | boolean | 로비 맵 이동 요청 |
| `HandleRunCompletedServer` | `isClear: boolean` | void | 런 종료 처리 및 로비 복귀 |
| `HandleStageFailedServer` | void | void | 실패 종료 래퍼 |
| `StartRunTimerServer` | void | void | 스피드런 타이머 시작 요청 |
| `CompleteRunTimerServer` | void | void | 스피드런 타이머 종료 요청 |
| `EnsureGRUtil` | void | void | `_GRUtil` 자동 부팅 폴백 |
