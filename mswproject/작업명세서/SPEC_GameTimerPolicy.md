# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 1. 개요

게임 내 시간 경과에 의존하는 모든 시스템이 `GameTimerComponent.ElapsedTime`을 시간 기준으로 참조하고, `LobbyFlowComponent.IsLobbyActive == true`일 때는 게임플레이 타이머가 동작하지 않도록 통일한다.

---

## 2. 정책 규칙

| 규칙 | 설명 |
|---|---|
| **R1. 시간 기준** | 게임플레이 경과 시간이 필요한 곳은 `GameTimerComponent.ElapsedTime` 참조 |
| **R2. IsLobby 가드** | 게임플레이 반복 타이머(SetTimerRepeat)의 콜백 최상단에 `if IsLobby then return` 가드 삽입 |
| **R3. 예외** | UI 갱신용 타이머, 로비 전용 로직, GameTimerComponent 자체는 가드 비대상 |

---

## 3. 컴포넌트별 적용 현황

### 🔴 IsLobby 가드 추가 필요 (게임플레이 타이머)

| 컴포넌트 | 타이머 종류 | 수정 내용 |
|---|---|---|
| `MonsterSpawnComponent` | `SpawnTick` (717행), `StateMonitorTimer` (610행) | 이미 `IsSafeZoneActiveServer()` 가드 존재 → **확인만** |
| `PenaltySystemComponent` | `MonitorTimerId` (69행) | 콜백 최상단에 IsLobby 가드 추가 |
| `TurretAIComponent` | `ThinkTimerId` (51행) | 콜백 최상단에 IsLobby 가드 추가 |
| `MonsterChaseComponent` | `ThinkTimerId` (56행) | 콜백 최상단에 IsLobby 가드 추가 |
| `ItemDropManagerComponent` | 자석 OnUpdate (Client) | 이미 필드 아이템 없으면 스킵 → **IsLobby 시 자석 중지 추가** |
| `FireSystemComponent` | `FireCooldownTimerId` (1052행) | 발사 자체가 로비 중 불가 → **확인만** |
| `ReloadComponent` | `ReloadTimerBySlot` (122행) | 재장전 자체가 로비 중 불가 → **확인만** |

### 🟢 가드 불필요 (UI / 메타 / 로비 전용)

| 컴포넌트 | 이유 |
|---|---|
| `HUDComponent` / `InGameHUDComponent` | UI 갱신 전용, 로비에서도 표시 필요 |
| `ShopUIComponent` | 상점 UI 전용 |
| `RankingUIComponent` | 결과 화면 전용 |
| `GameTimerComponent` | 타이머 자체, 자체 `IsRunning`/`IsPaused` 관리 |
| `InfiniteModeComponent` | 자체 `IsInfiniteActive` 가드 존재 |
| `LobbyFlowComponent` | 로비 전용 로직 |
| `TagManagerComponent` | 쿨다운/무적은 전투 중에만 발동 → 자체 가드 |
| `TagSkillComponent` | 스킬 버프 타이머, 전투 중에만 발동 |
| `Map01BootstrapComponent` | 초기 설정 타이머, 1회성 |
| `MovementComponent` | 애니메이션 갱신, 항상 필요 |
| `WeaponModelComponent` | 무기 모델 팔로우, 항상 필요 |
| `ProjectileComponent` | 투사체 바인드, 전투 중에만 존재 |
| `HPSystemComponent` | 무적 해제 타이머, 전투 중에만 발동 |

---

## 4. IsLobby 가드 삽입 패턴

각 대상 컴포넌트의 반복 타이머 콜백 최상단에 삽입:

```pseudocode
local lobbyFlow = self:ResolveComponentSafe(self.Entity, "LobbyFlowComponent", "IsLobbyActive")
if lobbyFlow ~= nil then
    local ok, isLobby = pcall(function() return lobbyFlow.IsLobbyActive end)
    if ok == true and isLobby == true then return end
end
```

> `MonsterSpawnComponent`는 이미 `IsSafeZoneActiveServer()`가 동일 로직 수행 중 → 패턴 동일 확인만

---

## 5. 기획서 참조

* PD 직접 지시 (2026-02-26)

## 6. 구현 방식

MCP 이용해서 직접 workspace에서 작업해줘야하는 방식

## 7. 주의/최적화 포인트

* **가드 위치**: 콜백 **최상단**에 삽입 → 로비 중 불필요한 연산 완전 차단
* **UI 타이머 제외**: UI 갱신은 로비에서도 동작해야 하므로 가드 적용 안 함
* **GameTimerComponent 보호**: 타이머 자체에 가드를 걸면 시간이 멈춰버리므로 절대 적용 안 함

---
