# 🔵 진행중
# SPEC_WeaponLevelUp — 무기 경험치 & 레벨업 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `WeaponLevelUpComponent` (신규) |
| **Execution Space** | `[Server Only]` 경험치 집계/레벨업 판정, `[Client Only]` 레벨업 UI/이펙트 |
| **기획서** | `[콘텐츠] v1.1 무기 콘텐츠 기획-1`, `[시스템] 무기 레벨업 시스템 V 1.0`, `[콘텐츠] v.2.0 무기 콘텐츠 기획-2` |
| **레이어** | `Meta` |
| **데이터 연동** | `PlayerbleData` → `WeaponData` → `WeaponLevelData` |

> [!IMPORTANT]
> - 1발사 = 1경험치 (타격 성공 무관, 발사/설치 기준)
> - 포탑류 = 설치 시 1경험치 (포탑 공격은 경험치 X)
> - 잉여 경험치 다음 레벨로 이월 (연속 레벨업 가능)
> - 태그 교체 시 경험치/레벨 보존 (세션 내 영구)

---

## 2. 유저 플로우

```
무기 발사/설치 → 해당 무기 경험치 +1
  ↓ 요구치 도달 시
레벨업 (최대 Lv.10) → 데미지 배율 상승 (WeaponLevelData 참조)
  ↓ 잉여 경험치 이월 → 연속 레벨업 가능
Lv.10 도달 → "MAX" 표시, 경험치 누적 중단
```

---

## 3. Properties (WeaponLevelUpComponent)

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `WeaponDataTableName` | `string` | `None` | `"WeaponData"` | 무기 데이터 테이블명 |
| `WeaponLevelDataTableName` | `string` | `None` | `"WeaponLevelData"` | 레벨별 배율 테이블명 |

> 슬롯/무기별 경험치·레벨은 `_T` 테이블로 관리 (8무기 독립):
> `_T.WeaponExp[weaponId]`, `_T.WeaponLevel[weaponId]`, `_T.WeaponMaxLevel[weaponId]`, `_T.WeaponRequiredExp[weaponId]`

---

## 4. 사용 서비스

| 서비스 | 용도 |
|---|---|
| `_DataService` | `PlayerbleData`, `WeaponData`, `WeaponLevelData` 로드 |

---

## 5. 로직 흐름

### 5-1. 초기화 (OnBeginPlay)
`PlayerbleData` 로드 → `player_atk` 캐싱 (데미지 배율의 기준값).
`WeaponData` 로드 → 무기별 `required_exp`, `start_level`, `max_level`, `dmg_raito` 캐싱.
`WeaponLevelData` 로드 → 무기별 레벨 배율 테이블 캐싱.
각 무기 `_T.WeaponLevel[id] = start_level`, `_T.WeaponExp[id] = 0`.

### 5-2. 경험치 획득
`FireSystemComponent.TryFireServer` 성공 시 → `AddWeaponExpServer(weaponId, 1)` 호출.
포탑: `SummonComponent` 설치 성공 시 → `AddWeaponExpServer(weaponId, 1)` 호출.

```
AddWeaponExpServer(weaponId, amount):
  level = _T.WeaponLevel[weaponId]
  if level >= maxLevel then return  -- MAX, 경험치 중단
  _T.WeaponExp[weaponId] += amount
  while _T.WeaponExp[weaponId] >= requiredExp and level < maxLevel:
    _T.WeaponExp[weaponId] -= requiredExp
    level += 1
    ApplyLevelUpServer(weaponId, level)  -- 연속 레벨업
  _T.WeaponLevel[weaponId] = level
```

### 5-3. 레벨업 적용
`WeaponLevelData`에서 해당 무기의 `level_N` 배율 조회 → `FireSystemComponent.BaseWeaponAttack` 갱신.

**데미지 공식**: `최종 공격력 = PlayerbleData.player_atk × WeaponLevelData[weaponId].level_N`
- 예: 활 Lv.5 = `100 × 1.4 = 140`
- 예: 저격탑 Lv.3 = `100 × 4.2 = 420`

```
ApplyLevelUpServer(weaponId, newLevel):
  dmgMultiplier = WeaponLevelData[weaponId]["level_" .. newLevel]
  FireSystemComponent.BaseWeaponAttack = _T.PlayerAtk * dmgMultiplier
  NotifyLevelUpClient(weaponId, newLevel)  -- UI 이펙트
```

### 5-4. 태그 교체 연동
`TagManagerComponent.CaptureCurrentCharacterState()` 시: 현재 캐릭터의 4무기 레벨/경험치도 캡처.
`TagManagerComponent.ApplyCharacterState()` 시: 대상 캐릭터의 4무기 레벨/경험치 복원 + 현재 슬롯 배율 적용.

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `FireSystemComponent` | 발사 성공 시 `AddWeaponExpServer` 호출, `BaseWeaponAttack` 갱신 |
| `WeaponSwapComponent` | 슬롯 전환 시 `weaponId` 제공 + 레벨 배율 적용 |
| `TagManagerComponent` | 태그 시 레벨/경험치 캡처/복원 |
| `ReloadComponent` | 잔탄 0 시 발사 실패 → 경험치 미획득 (기존 로직 유지) |

---

## 7. 데이터 테이블 구조

### WeaponData (경험치/레벨 관련 컬럼만)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | STRING | 무기 ID (bow, cannon...) |
| `fire_type` | ENUM | `projectile` / `summon` |
| `required_exp` | INT | 레벨업 요구 경험치 |
| `start_level` | INT | 시작 레벨 (1) |
| `max_level` | INT | 최대 레벨 (10) |
| `dmg_raito` | FLOAT | 기본 데미지 배율 |

### PlayerbleData (연동 컬럼)

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | STRING | 캐릭터 ID (player_a, player_b) |
| `player_atk` | INT | 기본 공격력 (100) — 모든 무기 데미지의 기준값 |
| `weaponslot1~4` | STRING | 슬롯별 무기 ID (bow, cannon...) |

### WeaponLevelData

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | STRING | 무기 ID |
| `level_1` ~ `level_10` | FLOAT | 각 레벨의 데미지 배율 |

---

## 8. Maker 배치

컴포넌트 부착: Player Entity → `script.WeaponLevelUpComponent` (Bootstrap 추가)

---

## 9. 주의/최적화

- 경험치 집계 서버 전용 (치트 방지)
- `required_exp`는 무기별 상이 (활 245, 미니건 15 등)
- 잉여 경험치 이월 로직에서 무한 루프 방지: `while` 안에 `level < maxLevel` 체크
- 포탑 발사는 경험치 X, 유저의 설치 행위만 +1

---

## 10. Codex 체크리스트

- [x] `WeaponLevelUpComponent` 신규
- [x] `FireSystemComponent` 수정: 발사 성공 시 경험치 호출
- [x] `WeaponSwapComponent` 수정: 슬롯 적용 시 WeaponLevelUp 연동
- [x] `TagManagerComponent` 수정: 캡처/복원에 레벨/경험치 추가
- [x] `Map01BootstrapComponent` 목록 추가
- [x] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🔵 진행중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |

