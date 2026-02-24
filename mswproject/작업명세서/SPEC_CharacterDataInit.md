# 🟡 대기중
# SPEC_CharacterDataInit — PlayerbleData 기반 캐릭터 초기화

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `CharacterDataInitComponent` (신규) |
| **Execution Space** | `[Server Only]` 데이터 로드/주입 |
| **레이어** | `Bootstrap` |
| **기획서** | 캐릭터 A/B 콘셉트, PlayerbleData |

---

## 2. Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentCharacterId` | `string` | `Sync` | `"player_a"` | 현재 활성 캐릭터 ID |

> `_T` 테이블: `_T.CharData[player_a]`, `_T.CharData[player_b]` — PlayerbleData 행 캐싱

---

## 3. 사용 서비스

| 서비스 | 용도 |
|---|---|
| `_DataService` | `PlayerbleData` 로드 |

---

## 4. 로직 흐름

### 4-1. 초기화 (OnBeginPlay)
`PlayerbleData` 로드 → `player_a`, `player_b` 두 행 캐싱.
`ApplyCharacterData("player_a")` 호출 → 초기 캐릭터 적용.

### 4-2. ApplyCharacterData(charId) [Server Only]

```
row = _T.CharData[charId]
HPSystemComponent.MaxHP = row.player_hp
HPSystemComponent.CurrentHP = 태그시 보존값 or row.player_hp
MovementComponent.MoveSpeed = row.movespeed
FireSystemComponent.BasePlayerAtk = row.player_atk
WeaponSwapComponent:InitSlotsFromPlayerbleData(charId, row)
WeaponModelComponent:SwapModel(현재슬롯의 WeaponData.id)
CurrentCharacterId = charId
```

### 4-3. 태그 연동
`TagManagerComponent`가 태그 시 → `ApplyCharacterData(대상ID)` 호출.
기존 캐릭터 데이터(HP/탄창 등)는 `TagManagerComponent`가 별도 백업.

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `HPSystemComponent` | `MaxHP`, `CurrentHP` 주입 |
| `MovementComponent` | `MoveSpeed` 주입 |
| `FireSystemComponent` | `BasePlayerAtk` 주입 |
| `WeaponSwapComponent` | 슬롯 초기화 (`weaponslot1~4`) |
| `WeaponModelComponent` | 무기 모델 교체 |
| `TagManagerComponent` | 태그 시 `ApplyCharacterData` 호출 |

---

## 6. Maker 배치

Player Entity → `script.CharacterDataInitComponent` (Bootstrap 자동 부착)

---

## 7. Codex 체크리스트

- [ ] `CharacterDataInitComponent` 신규 작성
- [ ] `Map01BootstrapComponent` 목록 추가
- [ ] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🟡 대기중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |
