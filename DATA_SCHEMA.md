# 📊 데이터 시트 명세서 (Data Schema)
> **최종 업데이트**: 2026-02-13
> 이 문서는 프로젝트에서 사용하는 모든 데이터 시트의 구조, 위치, 연결 방식을 정의합니다.

---

## 📋 데이터 시트 목록

| # | 시트 이름 | 포맷 | 위치 | 모듈 | 상태 |
|---|----------|------|------|------|------|
| 1 | 히어로 스탯 | JSON | `data/heroes.json` | combat | 🔲 미생성 |
| 2 | 스킬 정의 | JSON | `data/skills.json` | combat | 🔲 미생성 |
| 3 | 몬스터 스탯 | JSON | `data/monsters.json` | combat | 🔲 미생성 |
| 4 | 아이템 목록 | JSON | `data/items.json` | data | 🔲 미생성 |
| 5 | 대화 스크립트 | JSON | `data/dialogs.json` | vn | 🔲 미생성 |
| 6 | 맵 설정 | JSON | `data/maps.json` | physics | 🔲 미생성 |
| 7 | UI 텍스트 (i18n) | JSON | `data/locale_ko.json` | ui | 🔲 미생성 |

> [!TIP]
> 시트가 실제로 생성되면 상태를 ✅로 변경하고, 아래 스키마를 실제 값으로 업데이트하세요.

---

## 🗂️ 스키마 상세

### 1. 히어로 스탯 (`data/heroes.json`)
```json
{
  "heroes": [
    {
      "id": "hero_001",
      "name": "검사",
      "class": "Warrior",
      "stats": {
        "hp": 1000,
        "mp": 200,
        "atk": 50,
        "def": 30,
        "spd": 10,
        "crit_rate": 0.15,
        "crit_dmg": 2.0
      },
      "skills": ["skill_slash", "skill_guard"],
      "model_id": "model_hero_001"
    }
  ]
}
```
| 필드 | 타입 | MSW 연결 | 설명 |
|------|------|----------|------|
| `id` | string | Entity Name | 고유 식별자 |
| `stats.hp` | number | `HitComponent.Health` | 체력 |
| `stats.atk` | number | `AttackComponent.CalcDamage()` | 공격력 (계산식 입력) |
| `stats.crit_rate` | number | `AttackComponent.CalcCritical()` | 크리티컬 확률 |
| `model_id` | string | `_SpawnService:SpawnByModelId()` | 스폰용 모델 ID |

---

### 2. 스킬 정의 (`data/skills.json`)
```json
{
  "skills": [
    {
      "id": "skill_slash",
      "name": "참격",
      "type": "active",
      "target": "single",
      "star_cost": 1,
      "damage_multiplier": 1.5,
      "hit_count": 1,
      "cooldown": 0,
      "area": { "width": 2, "height": 2, "offset_x": 1, "offset_y": 0 },
      "effects": []
    }
  ]
}
```
| 필드 | 타입 | MSW 연결 | 설명 |
|------|------|----------|------|
| `star_cost` | number | 전투 자원 시스템 | 스킬 사용 비용 (Star) |
| `damage_multiplier` | number | `CalcDamage()` | ATK × 배율 |
| `hit_count` | number | `GetDisplayHitCount()` | 다중 히트 수 |
| `area` | object | `Attack(size, offset)` | 공격 범위 |

---

### 3. 몬스터 스탯 (`data/monsters.json`)
```json
{
  "monsters": [
    {
      "id": "mob_slime",
      "name": "슬라임",
      "stats": { "hp": 100, "atk": 10, "def": 5, "spd": 3 },
      "drops": [
        { "item_id": "item_potion", "rate": 0.3 }
      ],
      "exp": 20,
      "model_id": "model_slime"
    }
  ]
}
```

---

### 4. 대화 스크립트 (`data/dialogs.json`)
```json
{
  "scenes": [
    {
      "scene_id": "prologue_01",
      "background": "bg_village",
      "bgm": "bgm_peaceful",
      "dialogs": [
        {
          "character": "Hero",
          "portrait": "hero_normal",
          "text": "여기가... 마을인가?",
          "action": "fade_in",
          "choices": null
        },
        {
          "character": "Elder",
          "portrait": "elder_smile",
          "text": "오, 용사여! 드디어 왔구나!",
          "action": null,
          "choices": [
            { "text": "여기가 어디죠?", "next": "prologue_02a" },
            { "text": "할 일이 뭐죠?", "next": "prologue_02b" }
          ]
        }
      ]
    }
  ]
}
```

---

## 🔗 데이터 시트 ↔ 코드 연결 가이드

### MSW Lua에서 JSON 로딩
```lua
-- DataStorage를 통한 JSON 데이터 로딩 패턴
[server only]
void LoadHeroData()
{
    local ds = _DataStorageService:GetGlobalDataStorage("gameData")
    local errorCode, jsonStr = ds:GetAndWait("heroes")
    if errorCode == 0 then
        -- JSON 파싱은 MSW의 내장 함수 활용
        self.HeroData = _HttpService:JSONDecode(jsonStr)
    end
}
```

### 웹(JS)에서 JSON 로딩
```javascript
async function loadHeroes() {
  const res = await fetch('./data/heroes.json');
  const data = await res.json();
  return data.heroes;
}
```

---

## 📝 시트 추가/수정 시 체크리스트

1. 이 문서의 **데이터 시트 목록** 테이블에 추가
2. **스키마 상세** 섹션에 구조 정의 작성
3. MSW 컴포넌트와의 연결 필드를 `MSW 연결` 컬럼에 명시
4. `PROJECT_STRUCTURE.md`의 해당 모듈에 데이터 변경 사항 반영

---
*이 명세서는 데이터의 '설계도'입니다. 실제 데이터 파일 생성 시 이 구조를 따르세요.*
