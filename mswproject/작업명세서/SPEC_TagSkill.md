# 🟡 대기중
# SPEC_TagSkill — 태그 스킬(Entry Skill) 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `TagSkillComponent` (신규) |
| **Execution Space** | `[Server Only]` 버프 적용, `[Client Only]` 컷씬/이펙트/사운드 |
| **레이어** | `Combat` |
| **기획서** | 캐릭터 A/B 콘셉트 §4.4, SkillData |

---

## 2. 스킬 정의 (SkillData 참조)

| ID | 캐릭터 | 효과 | 지속 | 쿨타임 |
|---|---|---|---|---|
| `tag_skill_char_a_01` | A (베루아) | 이동속도 +60% | 3초 | 태그 쿨타임과 공유 |
| `tag_skill_char_b_01` | B (카르테) | 공격력 +60% | 6초 | 16초 |

---

## 3. Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsSkillActive` | `boolean` | `Sync` | `false` | 스킬 버프 활성 여부 |
| `SkillBuffMultiplier` | `number` | `Sync` | `1.0` | 현재 버프 배율 (1.0 = 버프 없음) |
| `SkillBuffType` | `string` | `None` | `""` | `"movespeed"` or `"attack"` |

---

## 4. 로직 흐름

### 4-1. 태그 시 스킬 발동 [Server Only]
`TagManagerComponent` 태그 완료 → `ActivateTagSkill(charId)` 호출.

```
ActivateTagSkill(charId):
  skillId = PlayerbleData[charId].tag_skill
  skillRow = SkillData[skillId]
  SkillBuffType = skillRow.buff_type  -- "movespeed" or "attack"
  SkillBuffMultiplier = 1.0 + skillRow.buff_value  -- 1.6
  IsSkillActive = true
  ApplyBuff()
  _TimerService:SetTimer(duration, RemoveBuff)
```

### 4-2. 버프 적용/해제

```
ApplyBuff():
  if SkillBuffType == "movespeed" then
    MovementComponent.SpeedMultiplier *= SkillBuffMultiplier
  elseif SkillBuffType == "attack" then
    FireSystemComponent.BuffIncreasePercent += (SkillBuffMultiplier - 1.0)
  end

RemoveBuff():
  -- 역산 복원
  IsSkillActive = false
  SkillBuffMultiplier = 1.0
```

### 4-3. B 예외: 공격력 버프
버프 사용 후 발사한 투사체에만 적용. 기존 날아가는 투사체는 미적용.
→ `FireSystemComponent`가 발사 시점의 `BuffIncreasePercent`를 투사체에 스냅샷 (기존 구현 유지).

### 4-4. 컷씬 연출 [Client Only]

```
PlaySkillCutscene(charId):
  1. 화면 좌측에 초상화 + 스킬 이름 UI 표시
  2. 1초 후 왼쪽 이동 → 페이드아웃
  3. 캐릭터 중심 이펙트(십자형) 재생 (시전 시간 동안 유지)
  4. SFX 1회 재생
```

---

## 5. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `TagManagerComponent` | 태그 완료 시 `ActivateTagSkill` 호출 |
| `MovementComponent` | `SpeedMultiplier` 변경 (A 스킬) |
| `FireSystemComponent` | `BuffIncreasePercent` 변경 (B 스킬) |
| `CharacterDataInitComponent` | `PlayerbleData.tag_skill` 제공 |

---

## 6. Maker 배치

| 엔티티 | 작업 |
|---|---|
| Player Entity | `script.TagSkillComponent` 부착 |
| UI (`DefaultGroup.ui`) | `GRSkillCutscene` 패널 (초상화+스킬명 표시 틀) |

---

## 7. 주의/최적화

- B 스킬 쿨타임(16초)은 태그 쿨타임(3초)과 **별도** → 스킬 자체 쿨타임 관리
- 태그 교체로 캐릭터가 바뀌어도 이전 캐릭터의 버프 타이머 정리 필요
- 컷씬 UI는 이미지 없이 **틀만** (PD가 이미지 추가)

---

## 8. Codex 체크리스트

- [ ] `TagSkillComponent` 신규 작성
- [ ] `SkillData` CSV 연동
- [ ] 스킬 컷씬 UI 틀 제작
- [ ] `Map01BootstrapComponent` 목록 추가
- [ ] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🟡 대기중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |
