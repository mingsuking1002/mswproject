# 🟢 완료

---

**[Codex용 작업 명세서]**

## 1. 개요

인게임 HUD(Heads-Up Display) 시스템을 기획서 레이아웃에 맞춰 전면 재구성한다.
기존 `HUDComponent`는 **텍스트 기반 단순 HUD**로, 실제 게임에 필요한 시각적 요소(바, 아이콘, 게이지 등)가 부재하다.
PD가 제공한 **인게임 UI 레이아웃 이미지**를 기준으로, 각 영역별 UI 요소를 정의하고 구현 방향을 설계한다.

---

## 2. UI 영역 정의 (실제 레이아웃 기준)

### 2-1. 좌측 상단 영역 — 재화/상점 HUD

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **상점 아이콘 (SHOP)** | 상점 진입 버튼 또는 방향 지시 스프라이트 | ShopManager |
| **보유 골드** | `[골드 아이콘] 숫자` 포맷으로 현재 골드 표시 | GoldComponent |

### 2-2. 중앙 상단 영역 — 타이머 HUD

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **타이머 텍스트** | 메인 타이머 경과 시간 표시 (HH:MM:SS 또는 MM:SS). 배경 패널 위에 중앙 정렬 | GameTimerComponent |

### 2-3. 우측 상단 영역 — 대기 캐릭터 상태

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **대기 캐릭터 초상화** | 현재 대기 중인(태그되지 않은) 캐릭터 이미지 + "WAITING" 텍스트 | TagManagerComponent |
| **태그 쿨타임 게이지** | 초상화 옆 세로형 게이지. **(2패널 방식)** 배경 회색 / 전경 주황색 | TagManagerComponent |
| **태그스킬 아이콘** | 단축키(Q/E 등) 안내와 함께 스킬 아이콘 패널 배치 | TagSkill |

### 2-4. 화면 중앙 (플레이어 기준) — 인게임 액션 UI

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **진행률 게이지** | 장전 중 등 특정 액션 시 캐릭터 하단에 임시로 나타나는 가로 게이지. **(2패널 방식)** | ReloadComponent |

### 2-5. 하단 영역 — 전투 상태 (HP, 탄약, 경험치)

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **체력(HP) 바** | 하단 중앙에 위치. **(2패널 방식)** 주황색 바 (크기 동적 조절) | HPSystemComponent |
| **경험치 바** | 하단 중앙, 체력 바 바로 아래 위치. **(2패널 방식)** 하늘색 바 | WeaponLevelUp |
| **보유 탄환 / 탄창** | 체력/경험치 바 우측에 탄약 아이콘과 함게 숫자 표시 | ReloadComponent |

### 2-6. 우측 하단 영역 — 무기 상태

| 요소 | 설명 | 연동 시스템 |
|------|------|------------|
| **현재 무기 아이콘** | 현재 장착 중인 무기 이미지 표시 | WeaponSwapComponent |
| **LV (무기 레벨)** | 아이콘 하단에 무기 레벨 숫자 표시 | WeaponLevelUp |
| **무기 교체 힌트** | 방향키/마우스 아이콘 등 무기 교체 패널 진입 단축키 안내 시각화 | WeaponSwapComponent |

---

## 3. 컴포넌트 설계

### Component Name: `InGameHUDComponent`

- **Execution Space:** `[Client Only]`

### Properties

| 타입 | 변수명 | 기본값 | 설명 |
|------|--------|--------|------|
| string | TimerTextPath | "" | 타이머 텍스트 렌더러 경로 |
| string | GoldTextPath | "" | 골드 텍스트 렌더러 경로 |
| string | HP_ForegroundPath | "" | 현재 체력 전경 패널 (스케일 조절용) |
| string | EXP_ForegroundPath | "" | 무기 경험치 전경 패널 (스케일 조절용) |
| string | AmmoTextPath | "" | 잔탄 수 표시 텍스트 경로 |
| string | WeaponIconPath | "" | 무기 이미지 스프라이트 경로 |
| string | WeaponLevelTextPath | "" | 무기 레벨 텍스트 경로 |
| string | TagCooldown_ForegroundPath| "" | 태그 쿨타임 전경 패널 (세로 스케일 조절용) |
| string | StandbyPortraitPath | "" | 대기 캐릭터 이미지 스프라이트 경로 |
| string | ReloadGaugePath | "" | 재장전 중앙 게이지 전경 패널 경로 |
| number | MaxGaugeWidth | 100 | 가로 게이지 패널의 최대 픽셀 너비 보관 (초기화 시 자동 설정) |
| number | MaxVerticalGaugeHeight| 100 | 세로 쿨타임 게이지의 최대 픽셀 높이 보관 |

### Required MSW Services
- `_TimerService`
- `_EntityService`

### 연동 컴포넌트 호출 리스트 (Ref)
- `HPSystemComponent`
- `ReloadComponent` (탄약, 재장전 상태)
- `WeaponSwapComponent`
- `TagManagerComponent` (쿨타임)
- `GoldComponent`
- `WeaponLevelUpComponent`
- `GameTimerComponent`

---

## 4. Logic Architecture (논리 구조)

### 게이지 2패널 구현 방식 (핵심 패턴)
모든 게이지(HP, EXP, 쿨타임, 재장전)는 배경 패널(`Back`) 안에 전경 패널(`Fore`)을 배치하여 구현. `UITransformComponent`를 사용해 크기를 조절한다.

```lua
-- 가로 게이지 갱신 로직 샘플
local ratio = math.min(1.0, math.max(0.0, current_val / max_val))
local uiTransform = ExpForeEntity.UITransformComponent
if isvalid(uiTransform) then
    uiTransform.SetScale(Vector2(ratio, 1)) -- x스케일 비율 적용
end
```

### 초기화 (`OnBeginPlay`)
1. Path를 이용해 모든 UI 요소 Entity 탐색 후 캐싱
2. 각 전경 게이지 패널의 기본 너비/높이를 캐싱 (100% 기준)
3. `_TimerService:SetTimerRepeat(self.RefreshHUD, 0.1, 0)` 로 갱신 시작

### 핵심 로직 (`RefreshHUD`)
- 0.1초 틱마다 실행.
- HP 시스템의 `HP`, `MaxHP`를 읽어 체력 게이지 스케일 조절
- WeaponLevelUp의 `EXP`, `MaxEXP`를 읽어 경험치 게이지 조절
- Tag 쿨타임 비율 계산해 세로 게이지 Y-Scale 조절
- Timer 시간을 mm:ss 포맷으로 변환해 반영

---

## 5. 구현 방식

Maker의 `MyDesk > ProjectGR > Components > UI` 하위에 저장된 `InGameHUDComponent.mlua`를 작성/수정.
UI 씬 배치는 Codex가 코드를 작성한 이후 PD 또는 TD가 Maker UI Editor에서 앵커(Anchors)와 오프셋을 맞추어 수동 배치한다. Codex는 동작용 스크립트만 구축한다.

---

## 6. 주의/최적화 포인트

- **게이지 0 처리**: 비율이 0 이하일 경우 시각적 버그 방지를 위해 예외 처리(`math.max(0, ratio)`).
- **Scale 기준점**: `UITransformComponent` 스케일을 조절할 때, 기준점(Pivot)이 좌측(또는 하단)인지 확인 (UI 배치는 Maker에서 처리하므로 스크립트는 항상 0.0~1.0 비율만 넣어줌).
- **방어 코드 일괄**: 각 Property 호출 시 연동 Entity나 System이 `nil`일 경우 OnUpdate가 죽지 않도록 방어 코드 추가.
---
