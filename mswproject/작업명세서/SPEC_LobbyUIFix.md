# 🟢 완료
# SPEC_LobbyUIFix — 로비↔인게임 UI 상태 동기화 안정화

## 1. 개요

| 항목 | 내용 |
|---|---|
| **대상 컴포넌트** | `LobbyFlowComponent`, `SpeedrunTimerComponent`, `RankingUIComponent` |
| **기능 요약** | 로비 UI 잔류/중복 표시 이슈를 정리하고, `games` 단일맵 기준 UI 상태 전환을 안정화 |
| **기획서 참조** | TD 버그 수정 지침서 (`implementation_plan`) |
| **운영 기본값** | `UseMapSplit=false` (상태 전환 중심), 필요 시 맵 분리 옵션 사용 |

---

## 2. 최종 엔티티 기준 (정합 완료)

| 엔티티 이름 | `/ui/DefaultGroup/` | `/maps/games/` | 비고 |
|---|:---:|:---:|---|
| `GRStartButton` | ✅ | ❌ | 시작 버튼 |
| `GRRankingText` | ✅ | ❌ | 랭킹 요약 텍스트 |
| `GRMyRankText` | ✅ | ❌ | 내 순위 텍스트 |
| `GRTimerText` | ✅ | ❌ | 인게임 타이머 텍스트 |
| `GRWeaponWheelRoot` | ✅ | ❌ | 무기휠 UI 루트 |

---

## 3. 확정 정책

| 항목 | 정책 |
|---|---|
| UI Source of Truth | `/ui/DefaultGroup` 단일화 |
| 시작 입력 | 버튼 클릭만 허용 (키보드 폴백 없음) |
| 로비 판정 기준 | 맵명보다 `IsLobbyActive` Sync 우선 |
| 단일맵 운영 | `UseMapSplit=false`면 맵 미이동이 정상 |
| 옵션 모드 | `UseMapSplit=true`일 때만 RoomService 이동 시도 |

---

## 4. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 로비 상태 전환 | `[server only]` | `SetLobbyStateServer`에서 권위 상태 변경 |
| UI 가시성 제어 | `[client only]` | `ApplyLobbyUIClient`에서 Start/Ranking/MyRank 처리 |
| 맵 이동 시도 | `[server only]` | `UseMapSplit=true` 조건에서만 수행 |
| 맵 진입 재동기화 | `[client only]` | `OnMapEnter`에서 즉시 UI 재적용 |
| 타이머 표시 제어 | `[client only]` | 로비 상태면 타이머 숨김 유지 |

---

## 5. 반영 완료 내역

### 5-1. LobbyFlowComponent

- `UseMapSplit=false`, `LobbyMapName="games"`, `InGameMapName="games"` 기본값 유지
- 시작 버튼 클릭 이벤트를 유일한 시작 입력 경로로 유지
- `OnSyncProperty("IsLobbyActive")`와 `OnMapEnter`에서 UI를 중복 안전 적용
- `self._T.GRUtil` 경유로 이동/공격 잠금 제어

### 5-2. SpeedrunTimerComponent

- 타이머 텍스트는 `/ui/DefaultGroup/GRTimerText` 기준으로만 탐색
- 로비 상태(`IsLobbyActive=true`)에서는 타이머 텍스트 노출 차단

### 5-3. RankingUIComponent

- 랭킹 텍스트 경로를 UI 루트 기준으로 유지
- 로비/인게임 전환은 `ApplyVisibilityClient` 경로로만 처리

### 5-4. 리소스 정합

- `games.map`에 남아 있던 중복 UI 엔티티 제거
- UI 엔티티는 `DefaultGroup.ui` 단일 경로로 정리

---

## 6. 전체 플로우 (단일맵 기준)

### 6-1. 초기 진입

```
Player 접속
→ Map01BootstrapComponent.ConfigurePlayer
→ LobbyFlowComponent(IsLobbyActive=true) 초기화
→ ApplyLobbyUIClient(true)
```

### 6-2. GAME START

```
Client: GRStartButton 클릭
→ RequestStartGameServer()
Server: SetLobbyStateServer(false)
→ IsLobbyActive=false Sync
→ UseMapSplit=false 이므로 맵 이동 생략
Client: ApplyLobbyUIClient(false)
```

### 6-3. 런 종료/복귀

```
Server: HandleRunCompletedServer()
→ SetLobbyStateServer(true)
→ UseMapSplit=false 이므로 맵 이동 생략
Client: OnSyncProperty("IsLobbyActive", true)
→ ApplyLobbyUIClient(true)
```

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `Map01BootstrapComponent` | 초기 속성 주입 | LobbyFlow 기본값/자동 부착 제어 |
| `SpeedrunTimerComponent` | 런 시작/정지 | 로비 상태에서는 텍스트 비노출 |
| `RankingUIComponent` | 랭킹 표시 | LobbyFlow가 가시성만 제어 |
| `HPSystemComponent` | 런 종료 신호 | 사망 시 로비 복귀 경로 호출 |
| `MovementComponent` | 이동 잠금 | 로비에서 `CanMove=false` |
| `FireSystemComponent` | 공격 잠금 | 로비에서 `CanAttack=false` |

---

## 8. 주의/최적화 포인트

- UI 가시성 제어 책임은 `LobbyFlowComponent`에 집중한다.
- `OnMapEnter` 보정은 Sync 지연 구간의 잔상 방지용이며 제거하지 않는다.
- UI 제어 경로는 `pcall` 방어를 유지해 미로딩 시점을 흡수한다.
- 단일맵 운영에서는 `games→games` 이동 호출을 강제하지 않는다.

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 시작 + Execution Space 분리 유지
- [x] 키보드 시작 폴백 제거, 버튼 클릭 경로 단일화
- [x] `DefaultGroup.ui` 단일 UI 경로 정합 반영
- [x] `OnSyncProperty` + `OnMapEnter` 이중 UI 보정 반영
- [x] 타이머/랭킹 UI의 로비 상태 가시성 제어 반영
- [x] `nil`/`isvalid`/`pcall` 방어 유지
- [x] `.mlua` ↔ `.codeblock` 동기화 유지
- [x] 상태 `🟢 완료` 유지

---

## 10. Maker 수동 백로그

- [ ] `games.map` Play 기준으로 로비 진입 시 Start/Ranking 표시 확인
- [ ] `GRStartButton` 클릭 후 로비 UI 비활성 + 타이머 표시 전환 확인
- [ ] 런 종료 후 로비 UI 재표시와 중복 바인딩 미발생 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |
| **근거** | TD 버그 리뷰 + 워크스페이스 실제 배치 (`games`, `DefaultGroup`) |

