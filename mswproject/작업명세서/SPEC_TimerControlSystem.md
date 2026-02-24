# 🔵 진행중
# SPEC_TimerControlSystem — v1.2 메인 및 하위 타이머 제어 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `GameTimerComponent` (메인) |
| **삭제 대상** | `SpeedrunTimerComponent` (기존, 완전 삭제) |
| **Execution Space** | `[Server Only]` (타이머 틱/제어), `[Client Only]` (UI 표시) |
| **기획서 참조** | `기획서/1.핵심 시스템/[v.1.2] 메인 및 하위 타이머 제어 시스템.md` |
| **모듈화 레이어** | `Meta` |
| **변경 범위** | 신규 1개 + 삭제 1개 + 외부 수정 6개 |

---

## 2. 기존 시스템과의 차이점 (왜 교체하는가)

| 항목 | 기존 `SpeedrunTimerComponent` | 신규 `GameTimerComponent` |
|---|---|---|
| 타이머 구조 | 단일 `ElapsedTime` 스톱워치 | 3계층: GameTimer(메인) → SpawnTimer + CallTimer(하위) |
| 일시정지 | `PauseSources` 딕셔너리 | `IsPaused` 단일 Sync 플래그 + 예외 목록 |
| 하위 타이머 | 없음 (각 컴포넌트 자체 `_TimerService`) | 메인 정지 → 하위 자동 정지/재개 |
| 스테이지 | `CurrentStageId` 단일 정수 | (유지) `CurrentStageId` |
| 기록 저장 | `BestTime` + `_DataStorageService` | **삭제** — 기록/랭킹은 별도 시스템으로 분리 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `ElapsedTime` | `number` | `@Sync` | `0.0` | 메인 타이머 경과 시간 (초) |
| `IsRunning` | `boolean` | `@Sync` | `false` | 타이머 작동 중 여부 |
| `IsPaused` | `boolean` | `@Sync` | `false` | 메인 일시정지 상태 |
| `CurrentStageId` | `integer` | - | `1` | 현재 스테이지 ID |
| `CountdownSeconds` | `number` | - | `3.0` | 게임 시작 카운트다운 |
| `TextUpdateInterval` | `number` | - | `0.05` | UI 텍스트 갱신 주기 |
| `EnableDebugLogs` | `boolean` | - | `true` | 디버그 로그 |
| `TimerTextEntity` | `Entity` | - | `nil` | 타이머 텍스트 UI |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_TimerService` | 카운트다운, 텍스트 갱신 루프 |
| `TextComponent` | 타이머 UI 텍스트 표시 |

---

## 5. 로직 흐름

### 5-1. 초기화 (`OnInitialize` — Server)
- `ElapsedTime = 0`, `IsRunning = false`, `IsPaused = false`
- `_T.CountdownTimerId = 0`, `_T.ClientTextTimerId = 0`

### 5-2. 메인 타이머 틱 (`OnUpdate` — Server)
```
if IsRunning == false then return end
if IsPaused == true then return end
ElapsedTime += delta
```

### 5-3. 일시정지 API (`PauseGame` / `ResumeGame` — Server)
- `PauseGame()`: `IsPaused = true` → **하위 타이머 정지 이벤트 발행**
- `ResumeGame()`: `IsPaused = false` → **하위 타이머 재개 이벤트 발행**
- 예외 처리: 상점/대화 중에도 메인 타이머 정지

### 5-4. 하위 타이머 제어 방식
기획서의 핵심: "메인 타이머가 멈추면 → 하위 타이머도 멈춘다"
- **SpawnTimer** (MonsterSpawnComponent): 메인 정지 시 `StopSpawning()`, 재개 시 `StartSpawning()`
- **CallTimer** (재장전/태그 쿨타임 등): 메인 정지 시 `_TimerService:ClearTimer` → 재개 시 잔여 시간으로 재등록
- 구현 방식: `GameTimerComponent`가 **직접** 하위 컴포넌트의 pause/resume 메서드를 호출
  (기존 `PauseSources` 딕셔너리 패턴 삭제)

### 5-5. 게임 시작/종료
- `StartRunWithCountdown()` → 카운트다운 → `StartRunNow()` (기존과 동일 인터페이스 유지)
- `CompleteRun()` → `IsRunning = false` (기록 저장/랭킹 제출은 별도 시스템 담당)

> ⚠️ 기존 `SpeedrunTimerComponent`의 `BestTime`, `LoadBestTimeFromStorageServer`, `EvaluateBestTimeServer`, `NotifyRankingServer` 등 기록/랭킹 관련 로직은 **모두 삭제**. 향후 무한 모드 랭킹 시스템에서 별도 컴포넌트로 구현 예정.

### 5-6. UI 표시 (`Client`)
- `StartClientTimerTextLoop()` → `_TimerService:SetTimerRepeat`로 텍스트 갱신
- `FormatElapsedTime()` → `MM:SS.ms` 포맷 (기존 로직 재사용)

---

## 6. 외부 컴포넌트 연동 코드 수정 (★ 핵심 ★)

> 기존 `SpeedrunTimerComponent` 참조를 모두 `GameTimerComponent`로 변경하고,
> `SetPauseSource()` 호출을 `PauseGame()`/`ResumeGame()` 호출로 교체.

---

### 6-1. `WeaponSwapComponent.mlua` (L455~466)

**변경 사유**: 무기교체 메뉴 열기/닫기 시 타이머 정지/재개

```diff
 -- Gameplay lock toggles movement, attack, and timer pause in one place for open/close consistency.
 @ExecSpace("ServerOnly")
 method void SetGameplayLockServer(boolean locked)
     self:SetCanMoveSafely(not locked)
     self:SetCanAttackSafely(not locked)

-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "IsRunning")
-    if timerComponent ~= nil and timerComponent.SetPauseSource ~= nil and self.PauseGameplayByFlag == true then
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
+    if timerComponent ~= nil and self.PauseGameplayByFlag == true then
         pcall(function()
-            timerComponent:SetPauseSource("WeaponSwap", locked)
+            if locked == true then
+                timerComponent:PauseGame()
+            else
+                timerComponent:ResumeGame()
+            end
         end)
     end
```

---

### 6-2. `ShopManagerComponent.mlua` (L893~927)

**변경 사유**: 상점 시 타이머 정지/재개 — 2곳 수정

```diff
 -- (L896~902) UseGameplayLockDuringShop == false 분기
-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "IsRunning")
-    if timerComponent ~= nil and timerComponent.SetPauseSource ~= nil then
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
+    if timerComponent ~= nil then
         pcall(function()
-            timerComponent:SetPauseSource("shop", false)
+            timerComponent:ResumeGame()
         end)
     end

 -- (L917~922) UseGameplayLockDuringShop == true 분기
-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "IsRunning")
-    if timerComponent ~= nil and timerComponent.SetPauseSource ~= nil then
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
+    if timerComponent ~= nil then
         pcall(function()
-            timerComponent:SetPauseSource("shop", locked)
+            if locked == true then
+                timerComponent:PauseGame()
+            else
+                timerComponent:ResumeGame()
+            end
         end)
     end
```

---

### 6-3. `MonsterSpawnComponent.mlua` (L621~648)

**변경 사유**: 스폰 웨이브 결정용 `ElapsedTime`/`CurrentStageId` 읽기 — 참조 이름만 변경

```diff
 method table ResolveCurrentSpawnContext()
     local context = {}
     context.Stage = 1
     context.ElapsedSec = 0

-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "ElapsedTime")
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "ElapsedTime")
     if timerComponent == nil then
         return context
     end
```
> `CurrentStageId`, `ElapsedTime` Property 이름이 동일하므로 참조만 교체.
> 추가로, `GameTimerComponent.IsPaused == true`일 때 `MonsterSpawnComponent`의 `CanSpawnNowServer()`에서 스폰을 차단하는 조건 추가 필요:

```diff
 method boolean CanSpawnNowServer()
     -- ... 기존 조건들 ...
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsPaused")
+    if timerComponent ~= nil then
+        local pauseOk, isPaused = pcall(function()
+            return timerComponent.IsPaused
+        end)
+        if pauseOk == true and isPaused == true then
+            self:TraceSpawnGateServer(false, "GameTimerPaused")
+            return false
+        end
+    end
     self:TraceSpawnGateServer(true, "Ready")
     return true
 end
```

---

### 6-4. `HPSystemComponent.mlua` (L228~232)

**변경 사유**: 사망 시 game-over fallback — `CompleteRun()` 호출 참조 변경

```diff
-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "ElapsedTime")
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "ElapsedTime")
     if timerComponent ~= nil and timerComponent.CompleteRun ~= nil then
         timerComponent:CompleteRun()
     end
```

---

### 6-5. `Map01BootstrapComponent.mlua` (L135)

**변경 사유**: 부트스트랩 필수 컴포넌트 목록 변경

```diff
-            "SpeedrunTimerComponent",
+            "GameTimerComponent",
```

---

### 6-6. `LobbyFlowComponent.mlua` (L155~188)

**변경 사유**: 게임 시작 시 타이머 시작 — 참조 이름 교체

```diff
 method void TryStartRunTimerServer()
-    local timerComponent = self:ResolveComponentSafe(self.Entity, "SpeedrunTimerComponent", "IsRunning")
+    local timerComponent = self:ResolveComponentSafe(self.Entity, "GameTimerComponent", "IsRunning")
     if timerComponent == nil then
         if self.EnableDebugLogs == true then
-            log_warning("[LobbyFlow][DEBUG] Timer start skipped: SpeedrunTimerComponent missing.")
+            log_warning("[LobbyFlow][DEBUG] Timer start skipped: GameTimerComponent missing.")
         end
         return
     end
```

---

## 7. 삭제 대상

### 7-1. 파일 삭제

| 파일 | 사유 |
|---|---|
| `Components/Meta/SpeedrunTimerComponent.mlua` | `GameTimerComponent`로 완전 대체 |
| `Components/Meta/SpeedrunTimerComponent.codeblock` | 코드블록 메타파일 |

### 7-2. SPEC 상태 변경

| 파일 | 변경 |
|---|---|
| `작업명세서/SPEC_SpeedrunTimer.md` | 상단 `🟢 완료` → `🔴 폐기 (GameTimerComponent로 대체됨)` |

---

## 8. 무한 모드 랭킹 시스템 고려사항 (향후 별도 SPEC)

> `[v.1.2] 무한 모드 랭킹 시스템.md` 분석 결과, 랭킹/기록 관련 기능은 `GameTimerComponent`에 포함하지 않고 **별도 SPEC**으로 분리합니다.

- 기존 `SpeedrunTimerComponent`의 `BestTime` 저장/로드 (`_DataStorageService`) → **완전 삭제**
- 랭킹 시스템은 별도 `RankingComponent` 또는 유사 컴포넌트로 구현 예정
- `GameTimerComponent`는 순수하게 **시간 제어/분배** 역할만 담당

---

## 9. 주의/최적화 포인트

- 메인 타이머는 `OnUpdate`에서 `ElapsedTime += delta` (기존과 동일 — 서버 권위)
- `PauseGame()`/`ResumeGame()` 호출 시 하위 컴포넌트 순회 — 반드시 `pcall` 보호
- `PauseSources` 딕셔너리 패턴 완전 삭제 — `IsPaused` 단일 플래그로 단순화
- 기존 `IsPausedServer()` 내 `WeaponSwapComponent.IsSwapMenuOpen` 폴링 삭제 → 호출자가 명시적으로 `PauseGame()` 호출

---

## 10. Codex 구현 체크리스트

- [x] `GameTimerComponent.mlua` 신규 작성 (Meta 레이어)
- [x] `SpeedrunTimerComponent.mlua` + `.codeblock` 삭제
- [x] `SPEC_SpeedrunTimer.md` → `🔴 폐기` 상태 변경
- [x] `WeaponSwapComponent.mlua` 수정 (§6-1)
- [x] `ShopManagerComponent.mlua` 수정 (§6-2)
- [x] `MonsterSpawnComponent.mlua` 수정 (§6-3)
- [x] `HPSystemComponent.mlua` 수정 (§6-4)
- [x] `Map01BootstrapComponent.mlua` 수정 (§6-5)
- [x] `LobbyFlowComponent.mlua` 수정 (§6-6)
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🔵 진행중 |
