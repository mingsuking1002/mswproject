# 🟢 완료
# SPEC_FireSystem — 탑뷰 타겟팅 발사 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `FireSystemComponent`, `ProjectileComponent` |
| **기능 요약** | 마우스 클릭 좌표 → 월드 변환 → 캐릭터 회전 → 투사체 생성/발사 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 탑뷰 타겟팅 발사 시스템.md` |

### 핵심 동작
- 좌클릭 시 마우스 스크린 좌표를 월드 좌표로 변환
- 캐릭터가 해당 방향으로 **즉시 회전** 후 투사체 발사
- 투사체: 적 적중 → 데미지, 지형 충돌 → 소멸, 사거리 초과 → 자동 소멸

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 좌클릭 입력 | `[client only]` | `_InputService` → `ScreenTouchEvent` |
| 스크린→월드 좌표 변환 | `[client only]` | `_UILogic:ScreenToWorldPosition()` |
| 발사 요청 | Client → Server | `@EventSender`로 발사 방향/좌표 전달 |
| 발사 조건 검증 | `[server only]` | 잔탄, 쿨타임, 상태이상 체크 |
| 투사체 생성 | `[server only]` | 엔티티 생성 + 속도 부여 |
| 투사체 충돌 판정 | `[server only]` | TriggerEnter → 데미지 적용 → 소멸 |
| 이펙트/사운드 | `[client only]` | 총구 화염, 발사음, 피격 이펙트 |

---

## 3. Properties

### FireSystemComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `FireCooldown` | `number` | `None` | `0.5` | 발사 쿨타임 (연사 속도) — 무기별 다름 |
| `IsFireReady` | `boolean` | `Sync` | `true` | 발사 가능 여부 |
| `CanAttack` | `boolean` | `Sync` | `true` | 공격 가능 상태 (스턴/사망/상점 시 false) |
| `MuzzleOffset` | `Vector2` | `None` | `(0.5, 0.2)` | 총구 위치 보정 (캐릭터 중심 기준) |
| `ProjectileModelId` | `string` | `None` | `""` | 투사체 엔티티 모델 ID (RUID) |

### ProjectileComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `Speed` | `number` | `None` | `20.0` | 투사체 비행 속도 |
| `MaxRange` | `number` | `None` | `15.0` | 최대 사거리 |
| `Lifetime` | `number` | `None` | `2.0` | 최대 생존 시간 (안전장치) |
| `Damage` | `integer` | `None` | `10` | 기본 데미지 (발사 시점 무기 스탯 복사) |
| `Spread` | `number` | `None` | `0` | 탄 퍼짐 각도 (기본총 0, 산탄총 15~30) |

---

## 4. 데미지 공식 (기획서 확정)

### 플레이어 → 몬스터

```
최종 데미지 = (무기 기본 공격력 + 캐릭터 패시브 추가 공격력)
              × (100% + 버프 증가 퍼센트%)
              × (100% + 캐릭터 패시브 증가 퍼센트%)
```

### 몬스터 → 플레이어

```
입는 데미지 = 몬스터 기본 공격력 - 피격 데미지 감소량
최종 체력 = 피격 전 HP - 입는 데미지
```

> ⚠️ 위 공식은 기획서 원본이므로 그대로 구현. 코드화는 Codex 판단.

---

## 5. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | 좌클릭 감지 (`ScreenTouchEvent`) |
| `_UILogic` | `ScreenToWorldPosition()` — 좌표 변환 |
| `_TimerService` | 발사 쿨타임 타이머 |
| `_EntityService` | 투사체 엔티티 동적 생성 |
| `TriggerComponent` | 투사체 충돌 감지 |
| `_SoundService` | 발사음, 빈 탄창 소리 |
| `_EffectService` | 총구 화염, 피격 이펙트 |

---

## 6. 로직 흐름

### 6-1. 발사 요청 (클라이언트)
1. 좌클릭 감지 → 스크린 좌표를 월드 좌표로 변환
2. `CanAttack == false` 또는 `IsFireReady == false` → 무시
3. 잔탄 0 → 빈 탄창 소리 재생 + "재장전 필요" UI 표시 → 발사 안 함
4. 서버에 발사 요청 (목표 월드 좌표 전달)

### 6-2. 발사 실행 (서버)
1. 조건 재검증 (쿨타임, 잔탄, 상태)
2. 캐릭터 → 목표 방향 벡터 계산, 캐릭터 회전
3. 총구 위치(MuzzleOffset 적용)에서 투사체 엔티티 생성
4. 투사체에 방향/속도/데미지(발사 시점 값) 부여
5. 잔탄 1 차감
6. `IsFireReady = false` → `_TimerService`로 `FireCooldown` 후 복원

### 6-3. 투사체 진행 (서버)
- 매 프레임 이동 (또는 물리 Velocity)
- **적 충돌:** 데미지 공식 적용 → 피격 이펙트 → 투사체 소멸
- **지형 충돌:** 즉시 소멸
- **사거리/시간 초과:** 자동 소멸

### 6-4. 중요: 무기 교체 중 투사체
- 이미 발사된 투사체는 **발사 시점의 무기 데미지를 유지** (교체 후 데미지로 변경하지 않음)

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `ReloadComponent` | 잔탄 참조 | 잔탄 0이면 발사 차단, 재장전 중 발사 불가 |
| `WeaponSwapComponent` | 무기 데이터 참조 | 현재 무기의 쿨타임/데미지/투사체 ID |
| `MovementComponent` | `FacingDirection` | 발사 방향으로 캐릭터 회전 동기화 |
| `HPSystemComponent` | 데미지 전달 | 적→플레이어 피격 시 HP 차감 호출 |

---

## 8. 주의 사항

- [ ] 클릭 위치가 캐릭터와 겹칠 경우 → 현재 방향 유지로 발사
- [ ] 투사체 풀링 고려 (대량 발사 시 성능)
- [ ] 쿨타임 중 재클릭 → 입력 완전 무시
- [ ] 탄 퍼짐(Spread)은 기본무기 0도, 특수무기용 확장 포인트

---

## 9. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil` 체크, `isValid` 방어 코드
- [ ] 기존 스크립트 연동 확인
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
