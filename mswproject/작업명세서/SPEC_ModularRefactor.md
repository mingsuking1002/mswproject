# 🟢 완료
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
└── Components/
    ├── Core/                   ← 전투 무관 기반
    │   ├── GRUtilModule        ← 🆕 글로벌 유틸리티
    │   ├── MovementComponent
    │   └── CameraFollowComponent
    │
    ├── Combat/                 ← 전투 도메인
    │   ├── HPSystemComponent
    │   ├── FireSystemComponent
    │   ├── ProjectileComponent
    │   └── ReloadComponent
    │
    ├── Meta/                   ← 메타 시스템
    │   ├── WeaponSwapComponent
    │   ├── TagManagerComponent
    │   ├── SpeedrunTimerComponent
    │   └── RankingComponent
    │
    ├── UI/                     ← 순수 표시 (로직 금지)
    │   ├── WeaponWheelUIComponent
    │   ├── RankingUIComponent
    │   └── HUDComponent        ← 🆕 HP바/잔탄/쿨타임 통합
    │
    └── Bootstrap/              ← 초기화/오케스트레이션
        ├── Map01BootstrapComponent
        └── LobbyFlowComponent
```

> **Maker 폴더 미지원 시**: `Components/Core/GRUtilModule` → `Components/GRUtilModule` (prefix 없이 flat), 물리 폴더 대신 논리 구분으로 대체

---

## 4. GRUtilModule (Phase 0 — 최우선 구현)

### 4-1. 역할
중복 유틸 함수를 `GRUtilModule`에 통합하고,  
`BootstrapUtil() -> table` 반환값을 각 컴포넌트 `self._T.GRUtil`에 캐시해 사용한다.

### 4-2. 추출 대상 함수

| 함수 | 시그니처 | 이전 중복 수 |
|---|---|---|
| `ResolveComponent` | `(entity, scriptName, markerField) → Component` | 6 |
| `ResolveMovement` | `(entity) → Component` | 4 |
| `TrySetCanMove` | `(entity, canMove) → boolean` | 4 |
| `CanWriteField` | `(comp, fieldName) → boolean` | 5 |
| `HasMember` | `(comp, memberName) → boolean` | 2 |
| `IsOwner` | `(entity, requestUserId) → boolean` | 3 |
| `TrySetField` | `(comp, fieldName, value) → boolean` | 2 |
| `FindOrAddComponent` | `(entity, typeName) → Component` | 2 |

### 4-3. 구현 패턴

```lua
@Component
script GRUtilModule extends Component

    method table BootstrapUtil()
        if self._T.UtilApi ~= nil then
            return self._T.UtilApi
        end

        local utilApi = {}
        utilApi.ResolveComponent = function(entity, scriptName, markerField)
            return self:ResolveComponent(entity, scriptName, markerField)
        end
        utilApi.ResolveMovement = function(entity)
            return self:ResolveMovement(entity)
        end
        utilApi.TrySetCanMove = function(entity, canMove)
            return self:TrySetCanMove(entity, canMove)
        end
        utilApi.CanWriteField = function(component, fieldName)
            return self:CanWriteField(component, fieldName)
        end
        utilApi.HasMember = function(component, memberName)
            return self:HasMember(component, memberName)
        end
        utilApi.IsOwner = function(entity, requestUserId)
            return self:IsOwner(entity, requestUserId)
        end
        utilApi.TrySetField = function(component, fieldName, value)
            return self:TrySetField(component, fieldName, value)
        end
        utilApi.FindOrAddComponent = function(entity, typeName)
            return self:FindOrAddComponent(entity, typeName)
        end

        self._T.UtilApi = utilApi
        return self._T.UtilApi
    end
end
```

### 4-4. PoC 테스트 방법
1. Maker에서 `GRUtilModule.codeblock` 적용 후 플레이
2. 각 컴포넌트 `EnsureGRUtil()`에서 `utilComponent:BootstrapUtil()` 호출
3. `self._T.GRUtil ~= nil` 및 `self._T.GRUtil.ResolveComponent ~= nil` 확인
4. `self._T.GRUtil.ResolveComponent(...)` 호출 결과가 nil이 아닌지 확인

> 폴백 정책: `self._T.GRUtil` 확보 실패 시, 컴포넌트 내부 `ResolveComponentSafe` + `pcall` 경로로 안전 동작 유지

---

## 5. 각 컴포넌트 재구현 규칙

### 5-1. 중복 코드 제거

모든 컴포넌트에서 아래 함수들을 **삭제**하고  
`self._T.GRUtil` 경유 호출(없으면 `ResolveComponentSafe` 폴백)로 대체:

| 삭제 대상 (self 메서드) | 대체 호출 |
|---|---|
| `self:ResolveProjectComponent(name, marker)` | `self._T.GRUtil.ResolveComponent(self.Entity, name, marker)` |
| `self:ResolveProjectMovementComponent()` | `self._T.GRUtil.ResolveMovement(self.Entity)` |
| `self:TrySetMovementCanMove(val)` | `self._T.GRUtil.TrySetCanMove(self.Entity, val)` |
| `self:CanWriteComponentField(comp, field)` | `self._T.GRUtil.CanWriteField(comp, field)` |
| `self:HasComponentMember(comp, member)` | `self._T.GRUtil.HasMember(comp, member)` |
| `self:IsRequestFromOwner()` | `self._T.GRUtil.IsOwner(self.Entity, requestUserId)` |

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

-- ④ 모든 외부 참조는 self._T.GRUtil 경유
    -- ✅ Good
    local comp = self._T.GRUtil.ResolveComponent(self.Entity, "HPSystemComponent", "CurrentHP")
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

- [x] Phase 0: `GRUtilModule` 신규 구현 및 `BootstrapUtil() -> self._T.GRUtil` 경로 확정
- [x] Phase 1: `MovementComponent`, `CameraFollowComponent` 신규 구현
- [x] Phase 2: `HPSystemComponent`, `FireSystemComponent`, `ProjectileComponent`, `ReloadComponent` 신규 구현
- [x] Phase 3: `WeaponSwapComponent`, `TagManagerComponent`, `SpeedrunTimerComponent`, `RankingComponent` 신규 구현
- [x] Phase 4: `WeaponWheelUIComponent`, `RankingUIComponent`, `HUDComponent`, `Map01BootstrapComponent`, `LobbyFlowComponent` 신규 구현
- [x] 전체 Phase 완료 후 상태 `🟢 완료` 전환

---

## 7. Phase 완료 시 갱신 대상

- [x] `기획서/0.개요/FOLDER_RULES.md` — 코드 구조 섹션 업데이트
- [x] `기획서/4.부록/Code_Documentation.md` — 전체 재작성
- [x] 본 SPEC 상태 `🟢 완료`로 변경

---

## 8. 명세-코드 정합 매트릭스 (Phase 0~4)

| 컴포넌트 | Execution Space 기준 | 핵심 Property 반영 | 핵심 메서드 반영 | 결과 |
|---|---|---|---|---|
| `GRUtilModule` | Server/Client bootstrap 분리 | 없음(유틸 제공 전용) | `BootstrapUtil` + 8개 유틸 API | ✅ |
| `MovementComponent` | 입력(Client) / 이동(Server) | `CanMove`, `SpeedMultiplier`, `FacingDirection` | `SubmitMoveInput`, `ApplyMovementServer` | ✅ |
| `CameraFollowComponent` | Client 전용 | 카메라 경계/오프셋 | `ApplyCameraSettings` | ✅ |
| `HPSystemComponent` | 판정(Server) / 피드백(Client) | `CurrentHP`, `IsDead`, `IsInvincible` | `ApplyDamage`, `ReviveToFullHP` | ✅ |
| `ReloadComponent` | 입력(Client) / 처리(Server) | `CurrentAmmo`, `IsReloading` | `RequestReloadServer`, `CompleteReload` | ✅ |
| `FireSystemComponent` | 입력(Client) / 발사(Server) | `CanAttack`, `IsFireReady`, 투사체 설정값 | `RequestFireServer`, `SpawnProjectileServer` | ✅ |
| `ProjectileComponent` | Server 전용 이동/충돌 | `Speed`, `Damage`, `Lifetime` | `InitializeProjectile`, `HandleTriggerEnterEvent` | ✅ |
| `WeaponSwapComponent` | 입력(Client) / 상태 스왑(Server) | `CurrentWeaponSlot`, `IsSwapMenuOpen` | `RequestConfirmSwapServer`, `ApplySlotDataToCombat` | ✅ |
| `TagManagerComponent` | 입력(Client) / 태그(Server) | `CurrentCharIndex`, `IsTagReady` | `RequestTagServer`, `ExecuteTagSwapServer` | ✅ |
| `SpeedrunTimerComponent` | 서버 시간 권위 + 클라이언트 표시 | `ElapsedTime`, `IsRunning`, `BestTime` | `StartRunNow`, `CompleteRun` | ✅ |
| `RankingComponent` | Server 조회/저장 + Client 스냅샷 수신 | 모드별 PB/표시 개수 | `RequestRankingSnapshotServer`, `GetMyRankServer` | ✅ |
| `WeaponWheelUIComponent` | Client 전용 | 휠 루트/시각 파라미터 | `ApplyWeaponWheelStateClient` | ✅ |
| `RankingUIComponent` | Client 전용 | 탭/표시 개수/텍스트 경로 | `SetCurrentTabClient`, `RefreshRankingUIClient` | ✅ |
| `HUDComponent` | Client 전용 | HUD 경로/갱신 주기 | `RefreshHUDClient`, `ApplyLobbyStateClient` | ✅ |
| `Map01BootstrapComponent` | Server 전용 부팅/부착 | 맵 분리 옵션/맵명/로비 옵션 | `ConfigurePlayer`, `AttachRequiredComponentsServer` | ✅ |
| `LobbyFlowComponent` | UI(Client) + 상태전환(Server) | `IsLobbyActive`, `UseMapSplit`, 맵명 | `RequestStartGameServer`, `ApplyLobbyUIClient` | ✅ |

검증 메모:
- 기본 맵 정책은 `games`로 정규화 (`LobbyMapName/InGameMapName = games`).
- `UseMapSplit=false` 시 `GRStartButton` 동작은 UI 비활성/상태 전환이 정상 동작.
- `self._T.GRUtil` 글로벌 직접 의존 문구 제거, `self._T.GRUtil` 표준으로 통일.
- 리소스 회귀 경계: `ui/`, `Global/DefaultPlayer.model` 변경 없음.

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

