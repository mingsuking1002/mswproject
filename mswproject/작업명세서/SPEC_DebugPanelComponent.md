# 🟢 완료

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 | 비고 |
|---|---|---|
| 2026-03-03 | 🟡 대기중 |
| 2026-03-03 | 🔵 진행중 | `DebugPanelComponent` 신규 구현 시작 |
| 2026-03-03 | 🟢 완료 | `.mlua/.codeblock` 신규 생성 및 Code_Documentation 갱신 완료 |
| 2026-03-03 | 🟡 대기중 | 디버그 패널 UI 엔티티 자동 생성 요청 |
| 2026-03-03 | 🔵 진행중 | `ui/DefaultGroup.ui` DebugPanel/버튼 2종 추가 및 자동 경로 해석 반영 시작 |
| 2026-03-03 | 🟢 완료 | UI 패널 생성 + Bootstrap 자동 부착 + `.codeblock` 동기화 완료 |

---

* **Component Name:** `DebugPanelComponent`
* **Execution Space:** `[둘 다]` — 버튼 UI는 Client, 실제 처리는 Server
* **Properties:**
  - `(Entity) DebugPanelEntity = nil  // 디버그 패널 루트 Entity(Maker 배치)`
  - `(string) DebugPanelPath = "/ui/DefaultGroup/DebugPanel"`
  - `(Entity) BtnAddTimeEntity = nil  // "시간 +5분" 버튼 Entity`
  - `(string) BtnAddTimePath = "/ui/DefaultGroup/DebugPanel/BtnAddTime"`
  - `(Entity) BtnWeaponLevelEntity = nil  // "무기 레벨+1" 버튼 Entity`
  - `(string) BtnWeaponLevelPath = "/ui/DefaultGroup/DebugPanel/BtnWeaponLevel"`
  - `(boolean) EnableDebugLogs = true`
  - `(boolean) IsPanelEnabled = true`

* **Required MSW Services:**
  - `_InputService` (UI 버튼 핸들러 등록)

* **연동 컴포넌트:**
  - `GameTimerComponent` — `ElapsedTime += 300` 으로 5분 증가
  - `WeaponLevelUpComponent` — `ResolveCurrentWeaponIdServer()`, `EnsureWeaponProgressByIdServer()`, progress.Level 증가 후 `ApplyWeaponPowerToFireServer`, `RefreshCurrentWeaponProgressSyncServer`, `RequestReapplyCurrentWeaponServer`
  - `Map01BootstrapComponent` — `AttachRequiredComponentsServer()` required 목록에 `DebugPanelComponent` 포함

* **Logic Architecture:**

  - **초기화 (`OnBeginPlay` Client):**
    1. `BtnAddTimeEntity`, `BtnWeaponLevelEntity`에 ButtonClickEvent 핸들러 등록
    2. 패널 기본 가시성 설정 (항상 보임 또는 토글)

  - **"시간 +5분" (`RequestAddTimeServer` — Server Only):**
    ```
    timer = ResolveComponentSafe(self.Entity, "GameTimerComponent", "ElapsedTime")
    timer.ElapsedTime += 300
    log("[DebugPanel] Time +5min, now=", timer.ElapsedTime)
    ```
    > 시간 증가에 따라 MonsterSpawnComponent가 자동으로 해당 시간대의 몬스터/보스 스폰 로직을 실행

  - **"무기 레벨+1" (`RequestWeaponLevelUpServer` — Server Only):**
    ```
    local wlu = ResolveComponentSafe(self.Entity, "WeaponLevelUpComponent", "CurrentWeaponLevel")
    local weaponId = wlu:ResolveCurrentWeaponIdServer()
    local progress = wlu:EnsureWeaponProgressByIdServer(weaponId)
    if progress.Level < progress.MaxLevel then
        progress.Level += 1
        wlu:ApplyWeaponPowerToFireServer(weaponId)
        wlu:RefreshCurrentWeaponProgressSyncServer(weaponId)
        wlu:RequestReapplyCurrentWeaponServer(weaponId, progress.Level)
    end
    ```

* **기획서 참조:** 개발 전용 디버그 도구 (기획서 해당 없음)

* **구현 방식:** mcp 이용해서 직접 workspace에서 작업

* **주의/최적화 포인트:**
  - 릴리즈 빌드에서는 패널 비활성화 필요 (Property 또는 Entity.Enable = false)
  - 시간 +5분 시 MonsterSpawnComponent가 ElapsedTime 기반으로 스폰하므로 몬스터/보스 등장 가능 (의도된 동작)
  - Maker에서 UI 버튼 2개 + 패널 Entity 배치 필요 (TextComponent로 라벨)
