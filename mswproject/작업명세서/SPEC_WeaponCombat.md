# 🟡 대기중
# SPEC_WeaponCombat — 무기 발사 · 공격 타입 · 데이터 테이블 연동

## 1. 개요

| 항목 | 내용 |
|---|---|
| **수정 컴포넌트** | `FireSystemComponent` (Combat), `WeaponSwapComponent` (Meta) |
| **신규 의존** | `WeaponData`, `ProjectileData`, `SummonData` CSV 테이블 |
| **Execution Space** | `[Server Only]` 발사/소환/데미지, `[Client Only]` 이펙트/사운드 |
| **기획서** | `[콘텐츠] v1.1 무기 콘텐츠 기획-1`, `[콘텐츠] v.2.0 무기 콘텐츠 기획-2` |

> [!IMPORTANT]
> 현재 `FireSystemComponent`는 **projectile(단일)** 발사만 구현. 이 SPEC은 4가지 공격 타입 분기와 데이터 테이블 연동을 추가한다.

---

## 2. 공격 타입 분류

| fire_type (WeaponData) | projectile_type (ProjectileData) | 동작 | 해당 무기 |
|---|---|---|---|
| `projectile` | `single_projectile` | 직선 투사체, 단일 타격 | 활, 권총 |
| `projectile` | `area_projectile` | 투사체 비행 → 접촉 시 광역 폭발 | 캐논, 파이어볼 |
| `projectile` | `smite` | 투사체 없이 타겟 위치 즉발 타격 | 데스페라도, 궁니르 |
| `summon` | (SummonData 참조) | 맵에 포탑 설치 → 자동 공격 | 미니건, 저격탑 |

---

## 3. FireSystemComponent 변경

### 3-1. 기존 유지 항목
- `IsFireReady`, `CanAttack`, `FireCooldown`, `MuzzleOffset` → 유지
- `CanFireServer()`, `StartFireCooldown()` → 유지
- 데미지 계산: `CalculateFinalDamage()` → 유지 (레벨업 배율은 `WeaponLevelUpComponent`가 `BaseWeaponAttack` 갱신)

### 3-2. 추가/변경 항목

| 항목 | 변경 |
|---|---|
| 신규 Property `CurrentFireType` | `string`, `@Sync`, `"projectile"` — 현재 무기의 `fire_type` |
| 신규 Property `CurrentProjectileType` | `string`, `None`, `"single_projectile"` — 투사체 세부 타입 |
| 신규 Property `SplashSize` | `number`, `None`, `0` — 광역 피해 반경 |
| `TryFireServer` 변경 | `fire_type`에 따라 분기: projectile → `FireProjectileServer()`, summon → `SummonTurretServer()` |
| `SpawnProjectileServer` 변경 | `projectile_type`에 따라: single → 기존, area → 폭발 콜리전 추가, smite → 즉발 데미지 |
| 신규 Method | `SummonTurretServer()` — SummonData 기반 포탑 엔티티 생성 |

### 3-3. 발사 분기 (pseudocode)

```
TryFireServer(target):
  if CanFireServer() == false then return
  ConsumeAmmo()  -- ReloadComponent 연동
  if CurrentFireType == "summon" then
    SummonTurretServer(target)
  elseif CurrentProjectileType == "smite" then
    SmiteAttackServer(target)  -- 즉발 데미지
  else
    SpawnProjectileServer(direction)  -- single/area 공통, ProjectileComponent가 타입 분기
  end
  WeaponLevelUpComponent:AddWeaponExpServer(weaponId, 1)  -- 경험치
  StartFireCooldown()
```

---

## 4. 투사체 타입별 동작

### single_projectile (활, 권총)
기존 구현 유지. 직선 비행 → 몬스터 접촉 시 단일 데미지 → 소멸.

### area_projectile (캐논, 파이어볼)
투사체 비행 → 몬스터/오브젝트/사거리 끝 도달 시 폭발.
폭발: `splash_size` 반경 내 모든 몬스터에 데미지. 폭발 이펙트 출력.

### smite (데스페라도, 궁니르)
투사체 생성 없음. 타겟 위치에 즉발 데미지.
- 데스페라도: 전방 면 범위 즉발 (`splash_size` = 9)
- 궁니르: 타겟 위치 지정 단일 타격 (낙뢰 연출)

---

## 5. 포탑 시스템 (fire_type = "summon")

### SummonData 참조

| 컬럼 | 설명 |
|---|---|
| `fire_rate` | 포탑 발사 간격 (미니건 0.25s, 저격 1s) |
| `duration` | 포탑 지속 시간 (미니건 8s, 저격 15s) |
| `cooldown` | 재설치 쿨다운 (미니건 6s, 저격 10s) |
| `projectile_id` | 포탑이 발사하는 투사체 ID |

### SummonTurretServer 로직

```
SummonTurretServer(targetPosition):
  SummonData 조회 → 포탑 엔티티 생성 (무적 오브젝트)
  포탑에 TurretAIComponent 부착 → 자동 타겟팅 + 발사
  duration 후 자동 Destroy
  설치 시 WeaponLevelUpComponent:AddWeaponExpServer(weaponId, 1)
```

> 포탑의 데미지도 무기 레벨 배율 적용 (설치 시점의 레벨 스냅샷)

---

## 6. WeaponSwapComponent 변경

슬롯 전환 시 `fire_type`, `projectile_type`, `splash_size` 등을 `WeaponData`/`ProjectileData`에서 로드하여 `FireSystemComponent`에 적용.

### NormalizeSlotData 확장

기존 필드에 추가:
| 필드 | 타입 | 설명 |
|---|---|---|
| `WeaponId` | `string` | 무기 테이블 ID (bow, cannon...) |
| `FireType` | `string` | `projectile` / `summon` |
| `ProjectileType` | `string` | `single_projectile` / `area_projectile` / `smite` |
| `ProjectileId` | `string` | 투사체 ID (ProjectileData 키) |
| `SummonId` | `string` | 포탑 ID (SummonData 키) |
| `SplashSize` | `number` | 광역 반경 |

### ApplySlotDataToCombat 확장

```
FireSystemComponent.CurrentFireType = data.FireType
FireSystemComponent.CurrentProjectileType = data.ProjectileType
FireSystemComponent.SplashSize = data.SplashSize
FireSystemComponent.FireCooldown = data.FireCooldown  -- WeaponData.fire_rate
```

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `FireSystemComponent` | 공격 타입 분기 추가 (§3) |
| `WeaponSwapComponent` | 슬롯 데이터에 fire_type/projectile_type 추가 (§6) |
| `WeaponLevelUpComponent` | 발사/설치 성공 시 경험치 호출 (SPEC_WeaponLevelUp) |
| `ReloadComponent` | 잔탄 소모 → 0이면 발사 차단 (기존 유지) |
| `TagManagerComponent` | 태그 시 슬롯 데이터 캡처/복원 (기존 로직 + 신규 필드) |

---

## 8. 데이터 테이블 요약

### WeaponData 핵심 컬럼

| 컬럼 | 설명 |
|---|---|
| `fire_type` | `projectile` / `summon` |
| `projectile_id` | 투사체 ID → ProjectileData 키 |
| `summon_id` | 포탑 ID → SummonData 키 |
| `fire_rate` | 발사 딜레이 (초) |
| `reload_time` | 장전 시간 (초) |
| `max_basic_resource` | 최대 탄약 |

### ProjectileData 핵심 컬럼

| 컬럼 | 설명 |
|---|---|
| `projectile_type` | `single_projectile` / `area_projectile` / `smite` |
| `projectile_atk` | 데미지 공식 (e.g. `player_atk*bow`) |
| `bulletspeed` | 탄속 |
| `splash_size` | 광역 반경 (없으면 0) |

### SummonData 핵심 컬럼

| 컬럼 | 설명 |
|---|---|
| `fire_rate` | 포탑 발사 간격 |
| `duration` | 포탑 지속 시간 |
| `cooldown` | 재설치 쿨다운 |
| `projectile_id` | 포탑 투사체 (minigun_bullet, sniper_bullet) |

---

## 9. 주의/최적화

- 투사체 스폰은 오브젝트 풀링 적용 (대량 발사 무기: 활 0.4s, 미니건 0.25s)
- smite 타입은 투사체 미생성 → 서버 부하 최소
- 포탑은 **무적 오브젝트** (몬스터 공격 불가)
- `projectile_atk` 공식 (`player_atk*weapon_ratio`)은 서버에서 파싱하여 적용
- 포탑 설치 불가 지역: 맵 밖 → 설치 불가 UI 표시 + 무시 처리 (미정, 추후 기획 확인)

---

## 10. Codex 체크리스트

- [ ] `FireSystemComponent` 수정: 공격 타입 분기 (§3)
- [ ] 투사체 타입별 동작 구현 (single/area/smite) (§4)
- [ ] `SummonTurretServer` 포탑 시스템 구현 (§5)
- [ ] `WeaponSwapComponent` 슬롯 데이터 확장 (§6)
- [ ] 데이터 테이블 연동 (`_DataService`) (§8)
- [ ] 오브젝트 풀링 적용
- [ ] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🟡 대기중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |
