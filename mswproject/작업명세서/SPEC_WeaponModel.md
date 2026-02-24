# 🔵 진행중
# SPEC_WeaponModel — 무기 모델 프리팹 부착 & 회전

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `WeaponModelComponent` (신규) |
| **Execution Space** | `[Client Only]` 회전/반전 연출, `[Server Only]` 모델 교체 |
| **레이어** | `Core` |
| **기획서** | 탑뷰 타겟팅 발사 시스템 §2-0 |

> [!IMPORTANT]
> 플레이어는 이동만, 공격/회전은 무기가 담당. 무기 모델이 Player Entity 하위 자식 엔티티로 부착.

---

## 2. 구조

```
Player Entity
  └─ WeaponHolder (자식 엔티티, 총구 피벗)
       └─ WeaponModel (MSW model 기능)
```

- `WeaponHolder`: 손잡이 기준점, 회전 피벗
- `WeaponModel`: `WeaponData.weapon_model` + `sprite_ruid`로 렌더

---

## 3. Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentWeaponId` | `string` | `Sync` | `""` | 현재 장착 무기 ID |
| `WeaponHolderEntityRef` | `Entity` | `None` | `nil` | WeaponHolder 자식 엔티티 참조 |
| `FlipThreshold` | `number` | `None` | `0` | 좌우 반전 기준 (화면 중앙 X) |

---

## 4. 로직 흐름

### 4-1. 무기 모델 교체 [Server Only]
`SwapModel(weaponId)` — `WeaponData[weaponId].sprite_ruid`로 모델 교체.
`WeaponSwapComponent` 슬롯 전환 시 호출.

### 4-2. 마우스 방향 회전 [Client Only] (OnUpdate)

```
mouseWorldPos = _UILogic:ScreenToWorldPosition(mouseScreenPos)
dir = mouseWorldPos - WeaponHolder.Position
angle = atan2(dir.y, dir.x)
WeaponHolder.Rotation = angle
```

### 4-3. 캐릭터 좌우 반전 [Client Only]

```
if mouseScreenPos.x < 화면중앙 then
  Player.ScaleX = -1  -- 좌측 바라보기
else
  Player.ScaleX = 1   -- 우측 바라보기
end
```

> 기존 `MovementComponent.FacingDirection` 8방향 → 좌우반전으로 대체

### 4-4. Muzzle 위치 제공 [Client/Server]
`GetMuzzlePosition()` — WeaponHolder의 끝 좌표 반환. `FireSystemComponent`가 투사체 생성 시 사용.

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `FireSystemComponent` | `GetMuzzlePosition()` + 발사 방향 = 무기 회전 방향 |
| `WeaponSwapComponent` | 슬롯 전환 시 `SwapModel(weaponId)` 호출 |
| `MovementComponent` | 좌우 반전 로직 이관 (FacingDirection 제거) |
| `CharacterDataInitComponent` | 초기 무기 모델 설정 |

---

## 6. Maker 배치

| 엔티티 | 작업 |
|---|---|
| Player Entity 하위 `WeaponHolder` | 자식 엔티티 생성 (피벗 위치 조정) |
| Player Entity | `script.WeaponModelComponent` 부착 |

---

## 7. 주의/최적화

- OnUpdate 회전은 클라이언트 전용 (서버 부하 X)
- 무기 교체 시 스프라이트만 교체 (엔티티 재생성 X)
- 좌우 반전 시 무기도 Y축 반전 처리

---

## 8. Codex 체크리스트

- [x] `WeaponModelComponent` 신규 작성
- [ ] `WeaponHolder` 자식 엔티티 구조 정의
- [x] `Map01BootstrapComponent` 목록 추가
- [x] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🔵 진행중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |


