## [MovementComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/MovementComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MoveSpeed` | number | 기본 이동 속도 |
| `SpeedMultiplier` | number | 버프/디버프 배율 (Sync) |
| `CanMove` | boolean | 이동 가능 여부 (Sync) |
| `FacingDirection` | integer | 현재 바라보는 8방향 인덱스 (Sync) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 입력 버퍼 초기화 |
| `HandleKeyDownEvent` | `KeyDownEvent event` | void | 이동 키 입력 시 서버로 최신 방향 전달 |
| `HandleKeyUpEvent` | `KeyUpEvent event` | void | 이동 키 해제 시 서버로 최신 방향 전달 |
| `OnUpdate` | `number delta` | void | 서버 권위 이동/방향/상태 갱신 |
| `IsMovementKey` | `KeyboardKey key` | `boolean` | WASD 이동 키 여부 판정 |
| `SubmitMoveInput` | `Vector2 moveDirection` | void | 클라이언트 입력을 서버에서 검증 후 반영 |
| `GetMoveInputClient` | void | `Vector2` | 클라이언트 키 조합을 방향 벡터로 계산 |
| `ClampInputDirection` | `Vector2 inputDirection` | `Vector2` | 방향 벡터 정규화 및 0 벡터 처리 |
| `ApplyMovementServer` | `Vector2 moveDirection`, `number speed`, `number delta` | void | Rigidbody 우선 이동 적용 |
| `UpdateFacingDirection` | `Vector2 moveDirection` | void | 이동 방향 기반 FacingDirection 동기화 |
| `ComputeFacingDirection` | `Vector2 direction` | `integer` | 8방향 인덱스 계산 |
| `UpdateStateAnimation` | `Vector2 moveDirection` | void | 이동/정지 상태를 MOVE/IDLE로 강제 전환 |
| `OnEndPlay` | void | void | 종료 시 이동 벡터 정리 |

## [CameraFollowComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CameraOffset` | Vector2 | 카메라 오프셋 |
| `MapBoundsMin` | Vector2 | 카메라 경계 최소 좌표 |
| `MapBoundsMax` | Vector2 | 카메라 경계 최대 좌표 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 입장 시 카메라 설정 적용 |
| `OnMapEnter` | void | void | 맵 재진입 시 카메라 설정 재적용 |
| `ApplyCameraSettings` | void | void | 카메라 오프셋/커스텀 경계 동기화 |

## [HPSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MaxHP` | integer | 최대 체력 (Sync) |
| `CurrentHP` | integer | 현재 체력 (Sync) |
| `DamageReduction` | integer | 피해 감소량 |
| `IsInvincible` | boolean | 무적 여부 (Sync) |
| `InvincibleDuration` | number | 무적 지속 시간(초) |
| `CriticalHPRatio` | number | 위기 HP 비율 기준 |
| `IsDead` | boolean | 사망 여부 (Sync) |
| `FallbackDamage` | integer | 소스 미확인 충돌의 기본 피해값 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 체력/무적 초기화 |
| `OnBeginPlay` | void | void | 초기 HP 상태 클라이언트 전달 |
| `HandleTriggerEnterEvent` | `TriggerEnterEvent event` | void | 서버 피격 트리거 수신 |
| `ResolveIncomingDamage` | `Entity sourceEntity` | `integer` | 피격 원본 엔티티에서 데미지 추출 |
| `ApplyDamage` | `integer rawDamage` | void | 피해 계산 및 HP 차감 |
| `StartInvincibleWindow` | void | void | 피격 후 무적 타이머 시작 |
| `Heal` | `integer amount` | void | 서버 회복 처리 (상한 적용) |
| `EvaluateDeath` | void | void | 사망 상태 확정 및 이동 차단 |
| `NotifyGameOver` | void | void | GameManager로 게임오버 전달 |
| `BroadcastHPState` | void | void | 서버 상태를 클라이언트 연출 함수로 전송 |
| `UpdateHPFeedbackClient` | `integer currentHp`, `integer maxHp`, `boolean isInvincible`, `boolean isDead` | void | 클라이언트 HP/무적/사망 연출 갱신 |
| `UpdateInvincibleBlink` | `boolean isInvincible` | void | 무적 점멸 시작/종료 분기 |
| `StartInvincibleBlink` | void | void | 클라이언트 점멸 타이머 시작 |
| `StopInvincibleBlink` | void | void | 클라이언트 점멸 타이머 정리 및 색상 복구 |
| `UpdateCriticalWarning` | `integer currentHp`, `integer maxHp` | void | 위기 상태 플래그 계산 |
| `HandleDeadUI` | void | void | 단발 게임오버 UI 트리거 |
| `OnEndPlay` | void | void | 서버 무적 타이머 정리 |

## [ReloadComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ReloadComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `MaxAmmo` | integer | 최대 탄약 수 |
| `CurrentAmmo` | integer | 현재 잔탄 (Sync) |
| `ReloadTime` | number | 재장전 소요 시간(초) |
| `IsReloading` | boolean | 재장전 여부 (Sync) |
| `FireRate` | number | 발사 간격(초) |
| `CurrentWeaponSlot` | integer | 현재 장착 무기 슬롯 (Sync) |
| `WeaponSlotCount` | integer | 슬롯 개수 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 슬롯별 탄약/쿨타임 버퍼 초기화 |
| `HandleKeyDownEvent` | `KeyDownEvent event` | void | R키 입력을 서버 재장전 요청으로 전달 |
| `RequestReloadServer` | void | void | 서버 권위 재장전 요청 검증 |
| `StartReloadForSlot` | `integer slot` | void | 슬롯 재장전 시작 |
| `CompleteReload` | `integer slot` | void | 슬롯 재장전 완료 및 탄약 충전 |
| `CancelReloadForSlot` | `integer slot` | void | 슬롯 재장전 취소 |
| `CancelCurrentReload` | void | void | 현재 슬롯 재장전 취소 진입점 |
| `SetCurrentWeaponSlot` | `integer slot` | void | 무기 슬롯 전환 및 탄약 상태 복원 |
| `ConsumeAmmoOnFire` | void | `boolean` | 발사 시 잔탄 차감/쿨타임 갱신 |
| `IsFireReady` | void | `boolean` | 현재 슬롯 발사 가능 여부 |
| `IsValidSlot` | `integer slot` | `boolean` | 슬롯 범위 유효성 검사 |
| `IsReloadingInSlot` | `integer slot` | `boolean` | 슬롯별 재장전 진행 여부 |
| `GetSlotAmmo` | `integer slot` | `integer` | 슬롯 탄약 조회 |
| `SetSlotAmmo` | `integer slot`, `integer ammo` | void | 슬롯 탄약 설정 |
| `OnEndPlay` | void | void | 슬롯별 재장전 타이머 정리 |

## [FireSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/FireSystemComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `FireCooldown` | number | 발사 쿨타임 |
| `IsFireReady` | boolean | 발사 가능 여부 (Sync) |
| `CanAttack` | boolean | 공격 가능 여부 (Sync) |
| `MuzzleOffset` | Vector2 | 총구 오프셋 |
| `ProjectileModelId` | string | 투사체 모델 ID |
| `BaseWeaponAttack` | integer | 무기 기본 공격력 |
| `PassiveFlatAttack` | integer | 패시브 고정 공격력 보너스 |
| `BuffIncreasePercent` | number | 버프 증가율(%) |
| `PassiveIncreasePercent` | number | 패시브 증가율(%) |
| `ProjectileSpeed` | number | 발사 투사체 속도 |
| `ProjectileRange` | number | 발사 투사체 최대 사거리 |
| `ProjectileLifetime` | number | 발사 투사체 최대 생존시간 |
| `ProjectileSpread` | number | 발사 투사체 확산각 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 발사 쿨타임 핸들 초기화 |
| `HandleScreenTouchEvent` | `ScreenTouchEvent event` | void | 좌클릭 입력을 발사 요청으로 전달 |
| `RequestFireServer` | `Vector2 targetWorldPosition` | void | 서버 발사 요청 검증 |
| `TryFireServer` | `Vector2 targetWorldPosition` | void | 발사 최종 실행(회전/스폰/쿨타임) |
| `CanFireServer` | void | `boolean` | 발사 가능 조건 검사 |
| `CalculateMuzzleWorldPosition` | `Vector2 direction`, `Vector2 shooterPosition` | `Vector2` | 총구 월드 좌표 계산 |
| `SpawnProjectileServer` | `Vector2 direction`, `Vector2 shooterPosition` | void | 투사체 스폰 및 발사 시점 스탯 주입 |
| `RotateShooter` | `Vector2 direction` | void | 서버에서 캐릭터 조준 회전 반영 |
| `CalculateFinalDamage` | void | `integer` | 기획서 데미지 공식 계산 |
| `StartFireCooldown` | void | void | 발사 쿨타임 시작/복원 |
| `GetFallbackDirection` | void | `Vector2` | 클릭 겹침 시 대체 진행 방향 반환 |
| `OnEndPlay` | void | void | 발사 쿨타임 타이머 정리 |

## [ProjectileComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ProjectileComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Speed` | number | 비행 속도 |
| `MaxRange` | number | 최대 사거리 |
| `Lifetime` | number | 최대 생존 시간 |
| `Damage` | integer | 데미지 |
| `Spread` | number | 발사 확산각 |
| `MoveDirection` | Vector2 | 진행 방향 |
| `StartPosition` | Vector2 | 발사 시작 좌표 |
| `OwnerEntity` | Entity | 발사자 엔티티 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 투사체 내부 상태 초기화 |
| `InitializeProjectile` | `Vector2 direction`, `Vector2 spawnPosition`, `Entity ownerEntity` | void | 발사 파라미터/초기 위치 설정 |
| `ApplySpread` | `Vector2 direction` | `Vector2` | 확산각 적용 방향 계산 |
| `OnUpdate` | `number delta` | void | 서버 이동/사거리/수명 처리 |
| `HandleTriggerEnterEvent` | `TriggerEnterEvent event` | void | 서버 충돌 데미지/소멸 처리 |
| `DestroySelf` | void | void | 중복 파괴 방지 포함 투사체 제거 |

## [WeaponSwapComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentWeaponSlot` | integer | 현재 무기 슬롯 (Sync) |
| `WeaponSlotCount` | integer | 무기 슬롯 개수 |
| `IsSwapMenuOpen` | boolean | 메뉴 오픈 상태 (Sync) |
| `Weapon1_Data` | table | 슬롯1 무기 데이터 |
| `Weapon2_Data` | table | 슬롯2 무기 데이터 |
| `Weapon3_Data` | table | 슬롯3 무기 데이터 |
| `Weapon4_Data` | table | 슬롯4 무기 데이터 |
| `HighlightedSlot` | integer | 메뉴 하이라이트 슬롯 (Sync) |
| `IsGameLogicPaused` | boolean | 메뉴 중 게임 로직 정지 플래그 (Sync) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 서버 슬롯 데이터 초기화 |
| `HandleKeyDownEvent` | `KeyDownEvent event` | void | F/ESC/WASD 입력 처리 |
| `HandleScreenTouchEvent` | `ScreenTouchEvent event` | void | 메뉴 중 좌클릭 확정 입력 처리 |
| `RequestOpenSwapMenuServer` | void | void | 메뉴 열기 서버 요청 |
| `RequestCancelSwapMenuServer` | void | void | 메뉴 취소 서버 요청 |
| `RequestHighlightSlotServer` | `integer slot` | void | 서버 하이라이트 슬롯 변경 |
| `RequestConfirmSwapServer` | `integer slot` | void | 서버 슬롯 확정 요청 |
| `CloseSwapMenu` | `boolean applySlot`, `integer slot` | void | 메뉴 종료/잠금해제 처리 |
| `ApplyWeaponSlot` | `integer slot` | void | 슬롯 교체 및 전투 컴포넌트 반영 |
| `EnsureSlotData` | `integer slot` | `table` | 슬롯 기본 데이터 보정 |
| `SaveCurrentSlotState` | `integer slot` | void | 현재 슬롯 상태 저장 |
| `LoadSlotDataToCombatComponents` | `table data`, `integer slot` | void | 슬롯 데이터 로드 |
| `SetCombatInputLocked` | `boolean isLocked` | void | 이동/공격 입력 잠금 |
| `UpdateSwapUIClient` | `boolean isOpen`, `integer highlightedSlot` | void | 클라이언트 방사형 메뉴 UI 갱신 |
| `IsRequestFromOwner` | void | `boolean` | 서버 요청 소유자 검증 |
| `CanOpenSwapMenu` | void | `boolean` | 메뉴 오픈 가능 여부 검사 |
| `MapKeyToSlot` | `KeyboardKey key` | `integer` | WASD 입력을 슬롯으로 매핑 |
| `IsValidSlot` | `integer slot` | `boolean` | 슬롯 유효성 검사 |
| `GetSlotData` | `integer slot` | `table` | 슬롯 데이터 조회 |
| `SetSlotData` | `integer slot`, `table data` | void | 슬롯 데이터 저장 |
| `OnEndPlay` | void | void | 종료 시 메뉴/잠금 상태 정리 |

## [WeaponWheelUIComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponWheelUIComponent.mlua`
- **수정일:** `2026-02-17`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsVisible` | boolean | 방사형 메뉴 표시 여부 (Sync) |
| `HighlightedSlot` | integer | 현재 하이라이트 슬롯 (Sync) |
| `WheelRoot` | Entity | 메뉴 루트 UI 엔티티 |
| `WheelRootPath` | string | Wheel UI entity path (`/ui/DefaultGroup/GRWeaponWheelRoot`) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `SetWheelVisible` | `boolean isVisible`, `integer highlightedSlot` | void | 메뉴 표시/하이라이트 상태 설정 |
| `ApplyWheelState` | void | void | WheelRoot Enable 상태 적용 |
| `OnBeginPlay` | void | void | 초기 UI 상태 동기화 |
| `ResolveWheelRootClient` | void | `Entity` | Resolve wheel root from UI path |

## [TagManagerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentCharIndex` | integer | 현재 활성 캐릭터 인덱스 (Sync) |
| `TagCooldown` | number | 태그 쿨타임(초) |
| `IsTagReady` | boolean | 태그 가능 여부 (Sync) |
| `InvincibleTime` | number | 태그 후 무적 시간(초) |
| `IsTagLocked` | boolean | 태그 잠금 상태 (Sync) |
| `Character1_Data` | table | 캐릭터1 상태 백업 |
| `Character2_Data` | table | 캐릭터2 상태 백업 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 태그 초기 상태/백업 데이터 초기화 |
| `HandleKeyDownEvent` | `KeyDownEvent event` | void | 태그 키 입력 처리 |
| `RequestTagServer` | void | void | 서버 태그 요청 검증 진입 |
| `ExecuteTagServer` | void | void | 태그 스왑 본 처리 |
| `CanTagServer` | void | `boolean` | 태그 가능 조건 검사 |
| `SaveCharacterState` | `integer charIndex` | void | 캐릭터 상태 백업 저장 |
| `CaptureCurrentCharacterState` | void | `table` | 현재 컴포넌트 상태 스냅샷 생성 |
| `LoadCharacterState` | `integer charIndex` | void | 백업 상태 복원 |
| `CancelCurrentReloadBeforeSwap` | void | void | 태그 전 재장전 취소 |
| `ApplyTagInvincibleWindow` | void | void | 태그 무적 적용/해제 |
| `StartTagCooldown` | void | void | 태그 쿨타임 시작/복원 |
| `TriggerEntrySkill` | `integer charIndex` | void | 캐릭터 엔트리 스킬 훅 |
| `IsRequestFromOwner` | void | `boolean` | 서버 요청 소유자 검증 |
| `CloneTable` | `table source` | `table` | 상태 테이블 깊은 복사 |
| `OnEndPlay` | void | void | 태그 타이머 정리 |

## [SpeedrunTimerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.mlua`
- **수정일:** `2026-02-17`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ElapsedTime` | number | 누적 경과 시간(초) (Sync) |
| `IsRunning` | boolean | 타이머 동작 여부 (Sync) |
| `CurrentStageId` | integer | 현재 스테이지 ID |
| `BestTime` | number | 스테이지 최고 기록 (Sync) |
| `DataStorageName` | string | 기록 저장소 이름 |
| `TimerTextEntity` | Entity | 타이머 텍스트 UI 엔티티 |
| `TimerTextPath` | string | Timer UI entity path (`/ui/DefaultGroup/GRTimerText`) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 타이머 상태/외부 일시정지 맵 초기화 |
| `OnBeginPlay` | void | void | 클라이언트 텍스트 루프 시작 |
| `OnUpdate` | `number delta` | void | 서버 경과 시간 누적 |
| `StartRun` | void | void | 런 시작 |
| `SetExternalPauseState` | `string reason`, `boolean paused` | void | 외부 일시정지 플래그 설정 |
| `IsExternallyPaused` | void | `boolean` | 외부 일시정지 여부 판정 |
| `CompleteRun` | void | void | 런 종료/기록 갱신/랭킹 전달 |
| `ResetRun` | void | void | 런 리셋 |
| `UpdateBestTimeAndSave` | void | void | 최고 기록 비교/저장 |
| `GetBestTimeStorageKey` | void | `string` | 스테이지별 저장 키 반환 |
| `SaveBestTimeToStorage` | void | void | 최고 기록 저장 |
| `LoadBestTimeFromStorage` | void | void | 최고 기록 로드 |
| `NotifyRankingSystem` | void | void | RankingComponent로 결과 전달 |
| `PlayNewRecordFeedbackClient` | void | void | 신기록 클라이언트 피드백 |
| `ResolveTimerTextEntityClient` | void | `Entity` | Resolve timer text from UI path |
| `FormatElapsedTime` | `number elapsed` | `string` | `MM:SS.ms` 포맷 변환 |
| `StopClientTimerTextLoop` | void | void | 클라이언트 텍스트 루프 종료 |
| `OnEndPlay` | void | void | 종료 시 텍스트 루프 정리 |

## [RankingComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingComponent.mlua`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `TimeAttackBestTime` | number | 타임어택 개인 최고 기록 |
| `InfiniteModeBestKills` | integer | 무한모드 개인 최고 처치수 |
| `MinimumValidTime` | number | 타임어택 최소 유효 시간(치트 필터) |
| `MaximumValidTime` | number | 타임어택 최대 유효 시간 |
| `MaximumValidKills` | integer | 무한모드 최대 유효 처치수 |
| `RankingStorageName` | string | 랭킹 저장소 이름 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `SubmitTimeAttackResult` | `number elapsedTime`, `integer stageId` | void | 타임어택 기록 제출/갱신 |
| `SubmitInfiniteModeResult` | `integer kills` | void | 무한모드 기록 제출/갱신 |
| `RequestRankingDataServer` | `integer mode`, `integer displayCount` | void | 서버 랭킹 조회 요청 처리 |
| `IsValidTimeAttackScore` | `number score` | `boolean` | 타임어택 유효성 검사 |
| `GetModeTag` | `integer mode` | `string` | 모드 태그 반환 |
| `SavePersonalBest` | `string modeTag`, `any scoreValue` | void | 개인 최고 기록 저장 |
| `UpsertRankingRecord` | `string modeTag`, `any scoreValue`, `integer stageId` | void | 랭킹 레코드 저장/갱신 |
| `LoadAndSortRecords` | `string modeTag` | `table` | 저장 레코드 로드 및 정렬 |
| `BuildTopEntries` | `integer mode`, `table sortedRecords`, `integer displayCount` | `table` | UI 표시용 상위 목록 생성 |
| `FindMyRank` | `integer mode`, `table sortedRecords` | `integer`, `string` | 내 순위/기록 계산 |
| `UpdateRankingDataClient` | `integer mode`, `table entries`, `integer myRank`, `string myValue` | void | 클라이언트 UI 갱신 전달 |
| `TrySubmitLeaderBoardService` | `string modeTag`, `any scoreValue` | void | LeaderBoardService 옵션 제출 |
| `FormatScore` | `integer mode`, `number score` | `string` | 모드별 점수 포맷 |
| `SerializeRecord` | `number score`, `string userName`, `number timestamp`, `integer stageId` | `string` | 랭킹 레코드 직렬화 |
| `DeserializeRecord` | `string serialized` | `number`, `string`, `number`, `integer` | 레코드 역직렬화 |
| `ExtractUserIdFromKey` | `string key` | `string` | 키에서 userId 추출 |
| `GetOwnerUserId` | void | `string` | 오너 userId 조회 |
| `GetOwnerDisplayName` | void | `string` | 오너 표시명 조회 |

## [RankingUIComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingUIComponent.mlua`
- **수정일:** `2026-02-17`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentTab` | integer | 현재 탭 (1=타임어택, 2=무한모드) |
| `DisplayCount` | integer | 최대 표시 순위 |
| `RankingTextEntity` | Entity | 상위 랭킹 텍스트 UI 엔티티 |
| `MyRankTextEntity` | Entity | 내 순위 텍스트 UI 엔티티 |
| `RankingTextPath` | string | Ranking list UI path (`/ui/DefaultGroup/GRRankingText`) |
| `MyRankTextPath` | string | My-rank UI path (`/ui/DefaultGroup/GRMyRankText`) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 초기 탭 데이터 로드 |
| `OpenTab` | `integer tab` | void | 탭 전환 및 서버 조회 |
| `ApplyRankingData` | `integer mode`, `table entries`, `integer myRank`, `string myValue` | void | 랭킹 데이터 UI 반영 |
| `BuildRankingText` | `integer mode`, `table entries` | `string` | 리스트 렌더 문자열 생성 |
| `BuildMyRankText` | `integer myRank`, `string myValue` | `string` | 내 순위 문자열 생성 |
| `ResolveUIEntitiesClient` | void | void | Resolve ranking text entities from UI paths |
| `ResolveTextEntityByPath` | `Entity currentEntity`, `string targetPath` | `Entity` | Shared resolver for UI text entities |

## [Map01BootstrapComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Map01BootstrapComponent.mlua`
- **수정일:** `2026-02-17`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `TargetMapName` | string | 자동 설정을 적용할 맵 이름 |
| `ProjectileTemplateName` | string | 발사 템플릿 엔티티 이름 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 맵 내 기존 유저를 즉시 설정 |
| `HandleUserEnterEvent` | `UserEnterEvent event` | void | 새로 입장한 유저 자동 설정 |
| `ConfigureCurrentMapUsers` | void | void | 현재 맵 유저 전체 순회 |
| `ConfigurePlayerIfInTargetMap` | `Entity playerEntity` | void | map01 유저 필터링 후 설정 진입 |
| `ConfigurePlayer` | `Entity playerEntity` | void | 전투/이동/UI 컴포넌트 자동 부착 및 초기값 주입 |
| `RebindRuntimeReferences` | `Entity playerEntity` | void | Rebind server-authoritative projectile template reference |
| `SeedWeaponSlots` | `Component weaponSwapComponent` | void | 4개 슬롯 기본 무기 데이터 주입 |
| `BuildWeaponData` | 무기 스펙 파라미터 | `table` | 슬롯 데이터 테이블 생성 |
| `FindMapEntityByName` | `string entityName` | `Entity` | 맵 하위 엔티티 탐색 |
| `AddOrGetComponent` | `Entity targetEntity`, `string typeName` | `Component` | 컴포넌트 중복 없이 조회/추가 |

