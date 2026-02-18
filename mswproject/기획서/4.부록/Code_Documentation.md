
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
