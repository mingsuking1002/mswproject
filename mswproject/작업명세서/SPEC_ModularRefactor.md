# 🔵 진행중
# SPEC_ModularRefactor — 전체 스크립트 모듈화 리팩토링

## 1. 개요

| 항목 | 내용 |
|---|---|
| **목적** | 14개 단일 폴더 컴포넌트 → 5레이어 도메인 모듈 구조로 재구성 |
| **선행 조건** | 사용자가 기존 14개 `.codeblock` 전부 삭제 완료 |
| **참조** | 기존 개별 SPEC들(SPEC_Movement~SPEC_WeaponSwap) + Code_Documentation.md |

---

## 2. 삭제 완료 확인 리스트 (사용자 작업)

아래 14개가 Maker에서 삭제되었음을 전제로 진행:

| # | 컴포넌트 |
|---|---|
| 1 | `MovementComponent` |
| 2 | `CameraFollowComponent` |
| 3 | `HPSystemComponent` |
| 4 | `ReloadComponent` |
| 5 | `FireSystemComponent` |
| 6 | `ProjectileComponent` |
| 7 | `WeaponSwapComponent` |
| 8 | `WeaponWheelUIComponent` |
| 9 | `TagManagerComponent` |
| 10 | `SpeedrunTimerComponent` |
| 11 | `RankingComponent` |
| 12 | `RankingUIComponent` |
| 13 | `LobbyFlowComponent` |
| 14 | `Map01BootstrapComponent` |

---

## 3. 새 폴더 구조

```
ProjectGR/
├── Core/                       ← 전투 무관 기반
│   ├── GRUtilModule            ← 🆕 글로벌 유틸리티
│   ├── MovementComponent
│   └── CameraFollowComponent
│
├── Combat/                     ← 전투 도메인
│   ├── HPSystemComponent
│   ├── FireSystemComponent
│   ├── ProjectileComponent
│   └── ReloadComponent
│
├── Meta/                       ← 메타 시스템
│   ├── WeaponSwapComponent
│   ├── TagManagerComponent
│   ├── SpeedrunTimerComponent
│   └── RankingComponent
│
├── UI/                         ← 순수 표시 (로직 금지)
│   ├── WeaponWheelUIComponent
│   ├── RankingUIComponent
│   └── HUDComponent            ← 🆕 HP바/잔탄/쿨타임 통합
│
└── Bootstrap/                  ← 초기화/오케스트레이션
    ├── Map01BootstrapComponent
    └── LobbyFlowComponent
```

> **Maker 폴더 미지원 시**: `Core/GRUtilModule` → `GRUtilModule` (prefix 없이 flat), 물리 폴더 대신 논리 구분으로 대체

---

## 4. GRUtilModule (Phase 0 — 최우선 구현)

### 4-1. 역할
6개 컴포넌트에서 복사되었던 공통 유틸리티를 `_GRUtil` 글로벌 테이블 1곳에 통합

### 4-2. 추출 대상 함수

| 함수 | 시그니처 | 이전 중복 수 |
|---|---|---|
| `ResolveComponent` | `(entity, scriptName, markerField) → Component` | 6 |
| `ResolveMovement` | `(entity) → Component` | 4 |
| `TrySetCanMove` | `(entity, canMove) → boolean` | 4 |
| `CanWriteField` | `(comp, fieldName) → boolean` | 5 |
| `HasMember` | `(comp, memberName) → boolean` | 2 |
| `IsOwner` | `(entity, senderUserId) → boolean` | 3 |
| `TrySetField` | `(comp, fieldName, value) → boolean` | 2 |
| `FindOrAddComponent` | `(entity, typeName) → Component` | 2 |

### 4-3. 구현 패턴

```lua
@Component
script GRUtilModule extends Component

    @ExecSpace("ServerOnly")
    method void OnBeginPlay()
        if _GRUtil ~= nil then
            return  -- 이미 등록됨
        end
        _GRUtil = {}

        ---------------------------------------------------
        -- script.XXX / XXX 양방향 탐색으로 컴포넌트 참조
        ---------------------------------------------------
        _GRUtil.ResolveComponent = function(entity, scriptName, markerField)
            if entity == nil or isvalid(entity) == false then return nil end
            local comp = entity:GetComponent("script." .. scriptName)
            if comp == nil then
                comp = entity:GetComponent(scriptName)
            end
            if comp ~= nil and markerField ~= nil and markerField ~= "" then
                local ok, _ = pcall(function() return comp[markerField] end)
                if not ok then return nil end
            end
            return comp
        end

        ---------------------------------------------------
        -- CanMove 필드를 가진 이동 컴포넌트 탐색
        ---------------------------------------------------
        _GRUtil.ResolveMovement = function(entity)
            local comp = _GRUtil.ResolveComponent(entity, "MovementComponent", "CanMove")
            if comp == nil then
                comp = entity:GetComponent("MovementComponent")
            end
            return comp
        end

        ---------------------------------------------------
        -- pcall 보호 CanMove 대입
        ---------------------------------------------------
        _GRUtil.TrySetCanMove = function(entity, canMove)
            local comp = _GRUtil.ResolveMovement(entity)
            if comp == nil then return false end
            local ok, _ = pcall(function() comp.CanMove = canMove end)
            return ok
        end

        ---------------------------------------------------
        -- read+write probe 필드 검증
        ---------------------------------------------------
        _GRUtil.CanWriteField = function(comp, fieldName)
            if comp == nil then return false end
            local ok, val = pcall(function() return comp[fieldName] end)
            if not ok then return false end
            local ok2, _ = pcall(function() comp[fieldName] = val end)
            return ok2
        end

        ---------------------------------------------------
        -- nil 필드 / 미존재 필드 구분
        ---------------------------------------------------
        _GRUtil.HasMember = function(comp, memberName)
            if comp == nil then return false end
            local ok, _ = pcall(function() return comp[memberName] end)
            return ok
        end

        ---------------------------------------------------
        -- 요청 소유자 검증
        ---------------------------------------------------
        _GRUtil.IsOwner = function(entity)
            if entity == nil or isvalid(entity) == false then return false end
            if entity.PlayerController == nil then return true end
            local currentUser = _UserService.LocalPlayer
            if currentUser == nil then return false end
            return entity == currentUser.Entity
        end

        ---------------------------------------------------
        -- 안전 필드 대입
        ---------------------------------------------------
        _GRUtil.TrySetField = function(comp, fieldName, value)
            if comp == nil then return false end
            local ok, _ = pcall(function() comp[fieldName] = value end)
            return ok
        end

        ---------------------------------------------------
        -- 컴포넌트 중복 없이 조회/추가
        ---------------------------------------------------
        _GRUtil.FindOrAddComponent = function(entity, typeName)
            if entity == nil or isvalid(entity) == false then return nil end
            local comp = entity:GetComponent(typeName)
            if comp == nil then
                comp = entity:AddComponent(typeName)
            end
            return comp
        end

        log("[GRUtilModule] _GRUtil registered.")
    end
end
```

### 4-4. PoC 테스트 방법
1. Maker에서 `GRUtilModule.codeblock` 생성
2. `Map01Bootstrap` 또는 맵 엔티티에 부착
3. 플레이 → 콘솔에 `[GRUtilModule] _GRUtil registered.` 확인
4. 다른 컴포넌트에서 `_GRUtil.ResolveComponent(...)` 호출 → nil이 아닌 값 반환 확인

> ⚠️ PoC 실패 시(글로벌 테이블 미지원) → 각 컴포넌트 `OnBeginPlay`에서 `Map01BootstrapComponent`를 통해 유틸 테이블 주입받는 방식으로 전환

---

## 5. 각 컴포넌트 재구현 규칙

### 5-1. 중복 코드 제거

모든 컴포넌트에서 아래 함수들을 **삭제**하고 `_GRUtil.함수명()` 호출로 대체:

| 삭제 대상 (self 메서드) | 대체 호출 |
|---|---|
| `self:ResolveProjectComponent(name, marker)` | `_GRUtil.ResolveComponent(self.Entity, name, marker)` |
| `self:ResolveProjectMovementComponent()` | `_GRUtil.ResolveMovement(self.Entity)` |
| `self:TrySetMovementCanMove(val)` | `_GRUtil.TrySetCanMove(self.Entity, val)` |
| `self:CanWriteComponentField(comp, field)` | `_GRUtil.CanWriteField(comp, field)` |
| `self:HasComponentMember(comp, member)` | `_GRUtil.HasMember(comp, member)` |
| `self:IsRequestFromOwner()` | `_GRUtil.IsOwner(self.Entity)` |

### 5-2. 레이어 참조 규칙

```
Core  ← 외부 참조 금지 (자기 완결)
Combat ← Core만 가능
Meta   ← Core + Combat 가능
UI     ← 데이터 수신만 (로직 금지)
Bootstrap ← 전체 가능
```

### 5-3. 기존 SPEC 참조 매핑

| 컴포넌트 | 기존 SPEC | 레이어 |
|---|---|---|
| `MovementComponent` | `SPEC_Movement.md` | Core |
| `CameraFollowComponent` | `SPEC_Movement.md` (카메라 섹션) | Core |
| `HPSystemComponent` | `SPEC_HPSystem.md` | Combat |
| `FireSystemComponent` | `SPEC_FireSystem.md` | Combat |
| `ProjectileComponent` | `SPEC_FireSystem.md` (투사체 섹션) | Combat |
| `ReloadComponent` | `SPEC_ReloadSystem.md` | Combat |
| `WeaponSwapComponent` | `SPEC_WeaponSwap.md` | Meta |
| `TagManagerComponent` | `SPEC_TagSystem.md` | Meta |
| `SpeedrunTimerComponent` | `SPEC_SpeedrunTimer.md` | Meta |
| `RankingComponent` | `SPEC_RankingSystem.md` | Meta |
| `WeaponWheelUIComponent` | `SPEC_WeaponSwap.md` (UI 섹션) | UI |
| `RankingUIComponent` | `SPEC_RankingSystem.md` (UI 섹션) | UI |
| `HUDComponent` | 신규 (HP바+잔탄+쿨타임 표시) | UI |
| `Map01BootstrapComponent` | `SPEC_EngineSetup.md` | Bootstrap |
| `LobbyFlowComponent` | `SPEC_LobbyUIFix.md` | Bootstrap |

### 5-4. 코딩 컨벤션

```lua
-- ① @Component 어트리뷰트 필수
@Component
script XxxComponent extends Component

-- ② Property 순서: Sync → Config → Internal
    @Sync
    property boolean IsActive = false        -- Sync 먼저
    property number Speed = 200              -- Config 다음
    property Entity _cached = nil            -- Internal 마지막 (언더스코어 prefix)

-- ③ ExecSpace 명시
    @ExecSpace("ServerOnly")
    method void ServerMethod() ... end

    @ExecSpace("ClientOnly") 
    method void ClientMethod() ... end

-- ④ 모든 외부 참조는 _GRUtil 경유
    -- ✅ Good
    local comp = _GRUtil.ResolveComponent(self.Entity, "HPSystemComponent", "CurrentHP")
    -- ❌ Bad (직접 탐색)
    local comp = self.Entity:GetComponent("script.HPSystemComponent")

-- ⑤ nil/isvalid 방어 필수
    if entity ~= nil and isvalid(entity) == true then ... end

-- ⑥ pcall 보호
    pcall(function() entity.Enable = true end)
```

---

## 6. Phase별 구현 순서

| Phase | 대상 | 의존성 | SPEC 참조 |
|---|---|---|---|
| **0** | `GRUtilModule` | 없음 | 본 문서 §4 |
| **1** | `MovementComponent`, `CameraFollowComponent` | Phase 0 | SPEC_Movement |
| **2** | `HPSystemComponent`, `FireSystemComponent`, `ProjectileComponent`, `ReloadComponent` | Phase 0~1 | SPEC_HPSystem, SPEC_FireSystem, SPEC_ReloadSystem |
| **3** | `WeaponSwapComponent`, `TagManagerComponent`, `SpeedrunTimerComponent`, `RankingComponent` | Phase 0~2 | SPEC_WeaponSwap, SPEC_TagSystem, SPEC_SpeedrunTimer, SPEC_RankingSystem |
| **4** | `WeaponWheelUIComponent`, `RankingUIComponent`, `HUDComponent`, `Map01BootstrapComponent`, `LobbyFlowComponent` | Phase 0~3 | SPEC_WeaponSwap(UI), SPEC_RankingSystem(UI), SPEC_LobbyUIFix |

> 각 Phase를 순서대로 실행. Phase N 완료 후 Phase N+1 시작.

### 6-1. 진행 체크 (2026-02-18)

- [x] Phase 0: `GRUtilModule` 신규 구현 및 `_GRUtil` 등록
- [x] Phase 1: `MovementComponent`, `CameraFollowComponent` 신규 구현
- [x] Phase 2: `HPSystemComponent`, `FireSystemComponent`, `ProjectileComponent`, `ReloadComponent` 신규 구현
- [x] Phase 3: `WeaponSwapComponent`, `TagManagerComponent`, `SpeedrunTimerComponent`, `RankingComponent` 신규 구현
- [x] Phase 4: `WeaponWheelUIComponent`, `RankingUIComponent`, `HUDComponent`, `Map01BootstrapComponent`, `LobbyFlowComponent` 신규 구현
- [ ] 전체 Phase 완료 후 상태 `🟢 완료` 전환

---

## 7. Phase 완료 시 갱신 대상

- [ ] `기획서/0.개요/FOLDER_RULES.md` — 코드 구조 섹션 업데이트
- [x] `기획서/4.부록/Code_Documentation.md` — 전체 재작성
- [ ] 본 SPEC 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🔵 진행중 |
