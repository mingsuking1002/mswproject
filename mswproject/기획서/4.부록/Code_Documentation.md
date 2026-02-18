## [MovementComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/MovementComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.codeblock`
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
| `OnMapEnter` | `Entity enteredMap` | void | 맵 재진입 시 카메라 설정 재적용 |
| `ApplyCameraSettings` | void | void | 카메라 오프셋/커스텀 경계 동기화 |

## [HPSystemComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.codeblock`
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
| `ReviveToFullHP` | void | void | 다음 런 시작을 위한 HP/사망 상태 전체 복구 |
| `EvaluateDeath` | void | void | 사망 상태 확정 및 이동 차단 |
| `ResolveProjectMovementComponent` | void | `Component` | script 우선으로 CanMove 필드를 가진 이동 컴포넌트 탐색 |
| `TrySetMovementCanMove` | `boolean canMove` | `boolean` | CanMove 대입을 pcall로 보호해 런타임 예외 차단 |
| `CanWriteComponentField` | `any targetComponent`, `string fieldName` | `boolean` | 읽기+동일값 재대입 probe로 필드 쓰기 가능 여부 판정 |
| `NotifyGameOver` | void | void | LobbyFlow/GameManager 폴백 체인으로 게임오버 결과 처리 |
| `BroadcastHPState` | void | void | 서버 상태를 클라이언트 연출 함수로 전송 |
| `UpdateHPFeedbackClient` | `integer currentHp`, `integer maxHp`, `boolean isInvincible`, `boolean isDead` | void | 클라이언트 HP/무적/사망 연출 갱신 |
| `UpdateInvincibleBlink` | `boolean isInvincible` | void | 무적 점멸 시작/종료 분기 |
| `StartInvincibleBlink` | void | void | 클라이언트 점멸 타이머 시작 |
| `StopInvincibleBlink` | void | void | 클라이언트 점멸 타이머 정리 및 색상 복구 |
| `UpdateCriticalWarning` | `integer currentHp`, `integer maxHp` | void | 위기 상태 플래그 계산 |
| `HandleDeadUI` | void | void | 단발 게임오버 UI 트리거 |
| `OnEndPlay` | void | void | 서버 무적 타이머 정리 |

## [ReloadComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ReloadComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/FireSystemComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/ProjectileComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.codeblock`
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
| `AllowSwapMenu` | boolean | 메뉴 오픈 허용 여부 (로비 게이트 연동) |

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
| `ResolveProjectMovementComponent` | void | `Component` | script 우선으로 CanMove 필드를 가진 이동 컴포넌트 탐색 |
| `TrySetMovementCanMove` | `boolean canMove` | `boolean` | CanMove 대입을 pcall로 보호해 런타임 예외 차단 |
| `CanWriteComponentField` | `any targetComponent`, `string fieldName` | `boolean` | 읽기+동일값 재대입 probe로 필드 쓰기 가능 여부 판정 |
| `UpdateSwapUIClient` | `boolean isOpen`, `integer highlightedSlot` | void | 클라이언트 방사형 메뉴 UI 갱신 |
| `IsRequestFromOwner` | void | `boolean` | 서버 요청 소유자 검증 |
| `CanOpenSwapMenu` | void | `boolean` | 메뉴 오픈 가능 여부 검사 (AllowSwapMenu 포함) |
| `MapKeyToSlot` | `KeyboardKey key` | `integer` | WASD 입력을 슬롯으로 매핑 |
| `IsValidSlot` | `integer slot` | `boolean` | 슬롯 유효성 검사 |
| `GetSlotData` | `integer slot` | `table` | 슬롯 데이터 조회 |
| `SetSlotData` | `integer slot`, `table data` | void | 슬롯 데이터 저장 |
| `OnEndPlay` | void | void | 종료 시 메뉴/잠금 상태 정리 |

## [WeaponWheelUIComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/WeaponWheelUIComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.codeblock`
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
| `EnableCharacterVisualSwap` | boolean | 태그 시 캐릭터 외형 색상/알파 스왑 적용 여부 |
| `Character1VisualColor` | Color | 캐릭터1 외형 기준 색상 |
| `Character2VisualColor` | Color | 캐릭터2 외형 기준 색상 |
| `Character1VisualAlpha` | number | 캐릭터1 외형 알파 |
| `Character2VisualAlpha` | number | 캐릭터2 외형 알파 |
| `EnableEntrySkill` | boolean | 태그 직후 엔트리 스킬 활성화 여부 |
| `EntrySkillTargetCollisionGroupName` | string | 엔트리 스킬 탐색 대상 충돌 그룹 이름 |
| `EntrySkillTargetHPComponentName` | string | 엔트리 스킬 데미지 적용 대상 HP 컴포넌트명 |
| `Character1EntrySkillDamage` | integer | 캐릭터1 엔트리 스킬 데미지 |
| `Character2EntrySkillDamage` | integer | 캐릭터2 엔트리 스킬 데미지 |
| `Character1EntrySkillRadius` | number | 캐릭터1 엔트리 스킬 반경 |
| `Character2EntrySkillRadius` | number | 캐릭터2 엔트리 스킬 반경 |
| `EntrySkillMaxTargets` | integer | 엔트리 스킬 최대 타격 대상 수 |
| `EntrySkillFlashDuration` | number | 엔트리 스킬 플래시 연출 지속 시간 |
| `Character1EntrySkillFlashColor` | Color | 캐릭터1 엔트리 스킬 플래시 색상 |
| `Character2EntrySkillFlashColor` | Color | 캐릭터2 엔트리 스킬 플래시 색상 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 태그 초기 상태/백업 데이터 초기화 |
| `OnBeginPlay` | void | void | 클라이언트 시작 시 현재 캐릭터 외형 적용 |
| `OnSyncProperty` | `string propertyName`, `any value` | void | CurrentCharIndex 동기화 시 외형 재적용 |
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
| `TriggerEntrySkill` | `integer charIndex` | void | 엔트리 스킬 서버 판정 실행 |
| `ApplyCharacterVisualClient` | `integer charIndex` | void | 캐릭터별 외형 색상/알파 적용 |
| `ApplyEntrySkillDamageServer` | `integer damage`, `number radius` | `integer` | 충돌 시뮬레이터 기반 범위 데미지 적용 |
| `PlayEntrySkillFlashClient` | `integer charIndex` | void | 엔트리 스킬 플래시 연출 |
| `GetCharacterVisualColor` | `integer charIndex` | `Color` | 캐릭터별 외형 색상 반환 |
| `GetCharacterVisualAlpha` | `integer charIndex` | `number` | 캐릭터별 외형 알파 반환 |
| `GetEntrySkillDamage` | `integer charIndex` | `integer` | 캐릭터별 엔트리 스킬 데미지 반환 |
| `GetEntrySkillRadius` | `integer charIndex` | `number` | 캐릭터별 엔트리 스킬 반경 반환 |
| `GetEntrySkillFlashColor` | `integer charIndex` | `Color` | 캐릭터별 플래시 색상 반환 |
| `IsRequestFromOwner` | void | `boolean` | 서버 요청 소유자 검증 |
| `CloneTable` | `table source` | `table` | 상태 테이블 깊은 복사 |
| `OnEndPlay` | void | void | 태그 타이머 정리 |

## [SpeedrunTimerComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.codeblock`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `ElapsedTime` | number | 누적 경과 시간(초) (Sync) |
| `IsRunning` | boolean | 타이머 동작 여부 (Sync) |
| `IsCountdownRunning` | boolean | 시작 카운트다운 진행 여부 (Sync) |
| `CountdownRemaining` | integer | 시작 카운트다운 남은 초 (Sync) |
| `CurrentStageId` | integer | 현재 스테이지 ID |
| `BestTime` | number | 스테이지 최고 기록 (Sync) |
| `DataStorageName` | string | 기록 저장소 이름 |
| `TimerTextEntity` | Entity | 타이머 텍스트 UI 엔티티 |
| `TimerTextPath` | string | Timer UI entity path (`/ui/DefaultGroup/GRTimerText`) |
| `TimerTextFallbackPath` | string | 타이머 텍스트 UI fallback path (`/maps/map01/GRTimerText`) |
| `EnableStartCountdown` | boolean | 런 시작 전 카운트다운 사용 여부 |
| `StartCountdownSeconds` | integer | 시작 카운트다운 길이(초) |
| `LockCombatDuringCountdown` | boolean | 카운트다운 중 이동/공격 잠금 여부 |
| `CountdownPauseReason` | string | 외부 pause 맵에서 사용하는 카운트다운 사유 키 |
| `CountdownReadyPrefix` | string | 카운트다운 표시 접두 문자열 |
| `CountdownGoText` | string | 카운트다운 종료 표시 문자열 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 타이머 상태/외부 일시정지 맵 초기화 |
| `OnBeginPlay` | void | void | 클라이언트 텍스트 루프 시작 |
| `OnUpdate` | `number delta` | void | 서버 경과 시간 누적 |
| `StartRun` | void | void | 카운트다운 없이 즉시 런 시작 |
| `StartRunWithCountdown` | void | void | 서버 권위 카운트다운 후 런 시작 |
| `CancelCountdown` | void | void | 카운트다운 타이머/잠금 상태 정리 |
| `ApplyCountdownCombatLockServer` | `boolean isLocked` | void | 카운트다운 중 이동/공격 잠금 제어 |
| `ResolveProjectMovementComponent` | void | `Component` | script 우선으로 CanMove 필드를 가진 이동 컴포넌트 탐색 |
| `TrySetMovementCanMove` | `boolean canMove` | `boolean` | CanMove 대입을 pcall로 보호해 런타임 예외 차단 |
| `CanWriteComponentField` | `any targetComponent`, `string fieldName` | `boolean` | 읽기+동일값 재대입 probe로 필드 쓰기 가능 여부 판정 |
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
| `PlayCountdownFeedbackClient` | `integer remaining` | void | 카운트다운 단계별 클라이언트 피드백 |
| `PlayCountdownGoFeedbackClient` | void | void | 카운트다운 종료 클라이언트 피드백 |
| `OnSyncProperty` | `string propertyName`, `any value` | void | 타이머 Sync 수신 시 UI 텍스트 즉시 갱신 |
| `RefreshTimerTextClient` | void | void | 현재 상태(카운트다운/시간)에 맞춰 타이머 텍스트 강제 갱신 |
| `ResolveTimerTextEntityClient` | void | `Entity` | Resolve timer text from UI path |
| `TrySetTimerTextVisibleClient` | `boolean visible` | void | 카운트다운/런 중 타이머 텍스트 표시를 강제 |
| `BuildCountdownText` | `integer remaining` | `string` | 카운트다운 HUD 표시 문자열 생성 |
| `FormatElapsedTime` | `number elapsed` | `string` | `MM:SS.ms` 포맷 변환 |
| `StopClientTimerTextLoop` | void | void | 클라이언트 텍스트 루프 종료 |
| `OnEndPlay` | void | void | 종료 시 텍스트 루프 정리 |
| `OnDestroy` | void | void | 서버 카운트다운 타이머 정리 |

## [RankingComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingComponent.codeblock`
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
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/RankingUIComponent.codeblock`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `CurrentTab` | integer | 현재 탭 (1=타임어택, 2=무한모드) |
| `DisplayCount` | integer | 최대 표시 순위 |
| `RankingTextEntity` | Entity | 상위 랭킹 텍스트 UI 엔티티 |
| `MyRankTextEntity` | Entity | 내 순위 텍스트 UI 엔티티 |
| `RankingTextPath` | string | Ranking list UI path (`/ui/DefaultGroup/GRRankingText`) |
| `MyRankTextPath` | string | My-rank UI path (`/ui/DefaultGroup/GRMyRankText`) |
| `RankingTextFallbackPath` | string | map fallback path (`/maps/map01/GRRankingText`) |
| `MyRankTextFallbackPath` | string | map fallback path (`/maps/map01/GRMyRankText`) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 초기 탭 데이터 로드 |
| `OpenTab` | `integer tab` | void | 탭 전환 및 서버 조회 |
| `ApplyRankingData` | `integer mode`, `table entries`, `integer myRank`, `string myValue` | void | 랭킹 데이터 UI 반영 |
| `BuildRankingText` | `integer mode`, `table entries` | `string` | 리스트 렌더 문자열 생성 |
| `BuildMyRankText` | `integer myRank`, `string myValue` | `string` | 내 순위 문자열 생성 |
| `ResolveUIEntitiesClient` | void | void | Resolve ranking text entities from UI paths |
| `SetRankingVisibleClient` | `boolean visible` | void | 로비/인게임 상태에 맞춰 랭킹 텍스트 가시성 강제 토글 |
| `ApplyEntityVisibleStateClient` | `Entity targetEntity`, `boolean visible` | void | Entity/UI component별 Enable/Visible 안전 적용 |
| `ResolveTextEntityWithFallback` | `Entity currentEntity`, `string primaryPath`, `string fallbackPath` | `Entity` | UI 경로 우선, 실패 시 map 경로 폴백 |
| `ResolveTextEntityByPath` | `Entity currentEntity`, `string targetPath` | `Entity` | Shared resolver for UI text entities |

## [LobbyFlowComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/LobbyFlowComponent.codeblock`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `IsLobbyActive` | boolean | 현재 로비 상태 여부 (Sync) |
| `EnableLobbyFlow` | boolean | 랭킹-시작 버튼 게이트 기능 사용 여부 |
| `UseMapSplit` | boolean | 로비/인게임 맵 분리 사용 여부 |
| `LobbyMapName` | string | 로비 맵 이름 |
| `InGameMapName` | string | 인게임 맵 이름 |
| `LobbySpawnPosition` | Vector2 | 로비 맵 복귀 위치 |
| `InGameSpawnPosition` | Vector2 | 인게임 진입 위치 |
| `AutoOpenRankingOnLobby` | boolean | 로비 진입 시 랭킹 자동 조회 여부 |
| `LobbyRankingTab` | integer | 로비에서 열 랭킹 탭 (1=TimeAttack, 2=Infinite) |
| `AutoStartTimerWhenGameStart` | boolean | 시작 버튼 이후 타이머 자동 시작 여부 |
| `ResetTimerWhenLobbyActive` | boolean | 로비 상태 복귀 시 타이머 리셋 여부 |
| `ReturnToLobbyOnRunComplete` | boolean | 런 결과 확정 후 로비 복귀 여부 |
| `HideRankingDuringGameplay` | boolean | 인게임에서 랭킹 UI 숨김 여부 |
| `HideTimerDuringLobby` | boolean | 로비에서 타이머 UI 숨김 여부 |
| `HideCombatHUDInLobby` | boolean | 로비에서 조작 HUD 숨김 여부 |
| `LockPlayerControllerInLobby` | boolean | 로비 상태에서 기본 PlayerController 비활성화 여부 |
| `LockTagInLobby` | boolean | 로비 상태에서 태그 입력 잠금 여부 |
| `HidePlayerVisualInLobby` | boolean | 로비 상태에서 플레이어 렌더 숨김 여부 |
| `HideMapLayerInLobby` | boolean | 로비 상태에서 맵 레이어 숨김 여부 |
| `MapLayerEntityName` | string | 가시성 제어 대상 맵 레이어 이름 |
| `StartButtonPath` | string | 시작 버튼 UI 경로 |
| `StartButtonFallbackPath` | string | 시작 버튼 map fallback 경로 (`/maps/map01/GRStartButton`) |
| `RankingTextPath` | string | 랭킹 텍스트 UI 경로 |
| `MyRankTextPath` | string | 내 순위 텍스트 UI 경로 |
| `RankingTextFallbackPath` | string | map fallback 랭킹 텍스트 경로 (`/maps/map01/GRRankingText`) |
| `MyRankTextFallbackPath` | string | map fallback 내 순위 텍스트 경로 (`/maps/map01/GRMyRankText`) |
| `TimerTextPath` | string | 타이머 텍스트 UI 경로 |
| `UIRootPath` | string | UI 그룹 루트 경로 (`/ui/DefaultGroup`) |
| `AttackButtonPath` | string | 공격 버튼 UI 경로 |
| `JumpButtonPath` | string | 점프 버튼 UI 경로 |
| `JoystickPath` | string | 조이스틱 UI 경로 |
| `ClientUiPollInterval` | number | 클라이언트 UI 동기화 폴링 주기 |
| `StartButtonBindRetryInterval` | number | 시작 버튼 바인딩 재시도 간격 |
| `StartButtonBindRetryMaxAttempts` | integer | 시작 버튼 바인딩 최대 재시도 횟수 |
| `UseButtonPressedFallback` | boolean | 클릭 이벤트 미수신 시 Pressed 이벤트 폴백 사용 여부 |
| `EnableKeyboardStartFallback` | boolean | Enter/Space 키 시작 폴백 사용 여부 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnInitialize` | void | void | 초기 로비 상태 설정 |
| `OnBeginPlay` | void | void | 초기 서버/클라이언트 상태 적용 |
| `OnMapEnter` | `Entity enteredMap` | void | 맵 분리 시 현재 맵명 기준으로 로비/인게임 상태 자동 동기화 |
| `OnUpdate` | `number delta` | void | 클라이언트 UI 상태 폴링 및 바인딩 복구 (MapSplit 맵명 기반 상태를 주기적으로 강제 적용) |
| `RequestStartGameServer` | void | void | 시작 버튼 서버 요청 처리 (맵 분리 시 즉시 인게임 상태 전환) |
| `HandleRunCompletedServer` | `boolean isClear` | void | 결과 확정 시 타이머 종료/로비 복귀 처리 |
| `HandleStageClearServer` | void | void | 클리어 결과 진입점 |
| `HandleStageFailedServer` | void | void | 실패 결과 진입점 |
| `HandleLobbyStartKeyDownEvent` | `KeyDownEvent event` | void | Enter/Space 키로 시작 요청 처리 |
| `OnStartButtonClickedClient` | `any event` | void | 시작 버튼 클릭/프레스 입력 처리 |
| `ApplyInitialServerState` | void | void | 초기 상태 분기(로비/인게임) |
| `SetLobbyStateServer` | `boolean isLobby` | void | 이동/공격/태그/HP/타이머 상태 전환 및 시작 카운트다운 연결 |
| `ResolveProjectMovementComponent` | void | `Component` | script 우선으로 CanMove 필드를 가진 이동 컴포넌트 탐색 |
| `TrySetMovementCanMove` | `boolean canMove` | `boolean` | CanMove 대입을 pcall로 보호해 런타임 예외 차단 |
| `CanWriteComponentField` | `any targetComponent`, `string fieldName` | `boolean` | 읽기+동일값 재대입 probe로 필드 쓰기 가능 여부 판정 |
| `ApplyLobbyControlLockServer` | `boolean isLobby` | void | 로비 상태에서 PlayerController/NativeMovement 강제 잠금 |
| `ApplyLobbyVisualMaskClient` | `boolean isLobby` | void | 로비 상태 시 플레이어/맵 시각 요소 마스킹 |
| `SetPlayerVisualVisibleClient` | `boolean visible` | void | 플레이어 렌더 알파 토글 |
| `SetCurrentMapLayerVisibleClient` | `boolean visible` | void | 현재 맵 레이어 가시성 토글 |
| `MoveOwnerToInGameMapIfNeeded` | void | `boolean` | 맵 분리 모드에서 인게임 맵 이동 요청 성공 여부 반환 |
| `MoveOwnerToLobbyMapIfNeeded` | void | `boolean` | 결과 확정 후 split-scene 로비 맵 이동 요청 성공 여부 반환 |
| `ApplyLobbyUIClient` | `boolean isLobby` | void | 로비/인게임 UI 가시성 전환 |
| `ResolveEffectiveLobbyStateClient` | void | `boolean` | MapSplit 시 현재 맵 이름 기준으로 로비 상태를 보정(불명확 시 인게임 기본값) |
| `BindStartButtonClient` | void | `boolean` | 시작 버튼 클릭/프레스 이벤트 바인딩 |
| `ScheduleStartButtonBindRetryClient` | void | void | UI 지연 로딩 시 바인딩 재시도 타이머 시작 |
| `SetEntityEnableByPath` | `string entityPath`, `boolean enabled` | void | 경로 기반 UI 활성 상태 변경 |
| `SetEntityEnableByPathIfExists` | `string entityPath`, `boolean enabled` | void | 폴백 경로를 경고 없이 가시성 적용 |
| `SetEntityEnableByNameUnderUIRoot` | `string childName`, `boolean enabled` | void | UI 루트 하위 이름 탐색 폴백으로 가시성 적용 |
| `SetEntityEnableByNameInCurrentMap` | `string childName`, `boolean enabled` | void | 현재 맵 하위 이름 탐색 폴백으로 가시성 적용 |
| `ForceApplyLobbyNamedEntitiesInCurrentMapClient` | `boolean isLobby`, `boolean rankingVisible`, `boolean timerVisible` | void | `GRStartButton/GRRankingText/GRMyRankText/GRTimerText` 이름 기반 강제 토글 |
| `ApplyEntityEnableStateClient` | `Entity targetEntity`, `boolean enabled` | void | UI 엔티티 Enable/Visible 적용 공통 처리 (`TextRenderer/CanvasGroup` 포함) |
| `TrySetComponentEnable` | `any targetComponent`, `boolean enabled` | void | UI 컴포넌트별 Enable 안전 적용 |
| `TrySetEntityVisualAlpha` | `Entity targetEntity`, `boolean enabled` | void | Enable 적용 후에도 남는 UI 잔상을 알파로 강제 숨김 |
| `ResolveEntityByPath` | `string entityPath` | `Entity` | 경로 기반 엔티티 조회 |
| `NormalizeMapName` | `string mapName` | `string` | `/maps/map01`/`map01` 형태를 동일 비교용 키로 정규화 |
| `IsMapNameMatched` | `string currentMapName`, `string targetMapName` | `boolean` | split-scene 맵명 비교 표준화 |
| `IsRequestFromOwner` | void | `boolean` | 요청 소유자 검증 |
| `OnEndPlay` | void | void | 클릭 이벤트 해제 |

## [Map01BootstrapComponent]
- **파일명:** `RootDesk/MyDesk/ProjectGR/Components/Map01BootstrapComponent.codeblock`
- **수정일:** `2026-02-18`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `TargetMapName` | string | 자동 설정을 적용할 맵 이름 |
| `ProjectileTemplateName` | string | 발사 템플릿 엔티티 이름 |
| `EnableLobbyMapSplit` | boolean | 로비/인게임 맵 분리 설정 주입 여부 |
| `LobbyMapName` | string | 분리 모드 로비 맵 이름 |
| `LobbySpawnPosition` | Vector2 | 분리 모드 로비 맵 이동 목표 좌표 |
| `InGameMapName` | string | 분리 모드 인게임 맵 이름 |
| `InGameSpawnPosition` | Vector2 | 인게임 맵 이동 목표 좌표 |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 맵 내 기존 유저를 즉시 설정 |
| `HandleUserEnterEvent` | `UserEnterEvent event` | void | 새로 입장한 유저 자동 설정 |
| `ConfigureCurrentMapUsers` | void | void | 현재 맵 유저 전체 순회 |
| `ConfigurePlayerIfInTargetMap` | `Entity playerEntity` | void | TargetMapName 일치 유저 필터링 후 설정 진입 |
| `ConfigurePlayer` | `Entity playerEntity` | void | 커스텀 컴포넌트 우선 탐색 후 안전 필드 대입으로 플레이어 초기화 |
| `RebindRuntimeReferences` | `Entity playerEntity` | void | Rebind server-authoritative projectile template reference |
| `SeedWeaponSlots` | `Component weaponSwapComponent` | void | 4개 슬롯 기본 무기 데이터 주입 |
| `BuildWeaponData` | 무기 스펙 파라미터 | `table` | 슬롯 데이터 테이블 생성 |
| `FindMapEntityByName` | `string entityName` | `Entity` | 맵 하위 엔티티 탐색 |
| `AddOrGetComponent` | `Entity targetEntity`, `string typeName` | `Component` | 컴포넌트 중복 없이 조회/추가 |
| `FindProjectComponent` | `Entity targetEntity`, `string scriptName`, `string markerField` | `Component` | script-prefix/plain-name fallback으로 커스텀 컴포넌트 탐색 |
| `GetOrAddProjectComponent` | `Entity targetEntity`, `string scriptName`, `string markerField` | `Component` | script-prefixed 우선 추가 후 마커 검증 및 충돌 경고 로그 출력 |
| `HasComponentMember` | `any targetComponent`, `string memberName` | `boolean` | 읽기+동일값 재대입 probe로 nil 필드/미존재 필드를 구분 |
| `TrySetComponentField` | `any targetComponent`, `string fieldName`, `any value` | `boolean` | 존재 필드만 안전하게 대입(런타임 예외 차단) |



