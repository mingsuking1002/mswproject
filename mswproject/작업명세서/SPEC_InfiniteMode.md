# 🟡 대기중
# SPEC_InfiniteMode — 무한 모드 랭킹 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `InfiniteModeComponent` |
| **Execution Space** | `[Server Only]` (모드 진행/Kill 집계/제출), `[Client Only]` (결과 UI) |
| **기획서 참조** | `기획서/1.핵심 시스템/[v.1.2] 무한 모드 랭킹 시스템.md` |
| **모듈화 레이어** | `Meta` |
| **역할** | 무한 모드 진입 → 무한 웨이브 → Kill 집계 → 사망 → 결과 표시 → 랭킹 제출 → 로비 복귀 **오케스트레이터** |

> [!IMPORTANT]
> 기존 `RankingComponent`의 Infinite 파이프라인(Submit/Upload/GetTopRanks)은 **그대로 유지**. 이 SPEC은 무한 모드 플로우를 제어하는 새 컴포넌트를 추가한다.

---

## 2. 기존 시스템과의 관계

| 기존 컴포넌트 | 상태 | 이 SPEC에서의 역할 |
|---|---|---|
| `RankingComponent` | 🟢 구현 완료 | `SubmitInfiniteRecordServer(killCount)` 호출 대상 |
| `MonsterSpawnComponent` | 🟢 구현 완료 | 무한 모드 시 `IsSpawnEnabled` 유지 + 보스 억제 |
| `HPSystemComponent` | 🟢 구현 완료 | 사망 이벤트 발신처 |
| `LobbyFlowComponent` | 🟢 구현 완료 | 사망 후 로비 복귀 (`HandleRunCompletedServer`) |
| `GameTimerComponent` | 🟡 대기중 | 무한 모드 진입 시 타이머 정지 (SPEC_TimerControlSystem) |

---

## 3. Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsInfiniteActive` | `boolean` | `@Sync` | `false` | 무한 모드 진행 중 여부 |
| `TotalKillCount` | `integer` | `@Sync` | `0` | 누적 처치 수 (= 점수) |
| `SessionBestKills` | `integer` | `None` | `0` | 현재 세션 로컬 최고 기록 (UI 비교용) |

---

## 4. 사용 서비스 & API

| 서비스 | 용도 |
|---|---|
| `_TimerService` | 결과 화면 표시 딜레이 |

> `_DataStorageService` / `SortableDataStorage` 저장은 **기존 `RankingComponent`가 전담**. 이 컴포넌트는 호출만 한다.

---

## 5. 로직 흐름

### 5-1. 무한 모드 진입 조건
- 기획서: "최종 보스 처치 후, 무한 스테이지로 자동 진입"
- **트리거**: `MonsterSpawnComponent`에서 최종 보스 사망 시 이벤트 발행 → `InfiniteModeComponent.EnterInfiniteModeServer()` 호출
- 현재 구현 gap: 보스 사망 이벤트 발행 로직이 `MonsterSpawnComponent`에 미구현 → Codex가 보스 사망 감지 훅을 추가해야 함

```
EnterInfiniteModeServer():
  IsInfiniteActive = true
  TotalKillCount = 0
  SessionBestKills = RankingComponent.InfiniteModeBestKills  -- 로컬 PB 캐싱
  GameTimerComponent → StopTimer / IsPaused = true  -- 타이머 정지
  MonsterSpawnComponent → 보스 스폰 억제, 일반 몬스터 무한 스폰 유지
```

### 5-2. Kill Count 집계
- 몬스터 사망 시마다 서버에서 `TotalKillCount += 1`
- **트리거**: 몬스터 엔티티의 HP 0 → Destroy 시점에서 호출
- 현재 구현 gap: 몬스터 사망 콜백이 `InfiniteModeComponent`로 전달되는 경로 필요
- **방안**: `MonsterSpawnComponent`의 몬스터 Destroy 감지 로직에서 `InfiniteModeComponent.OnMonsterKilledServer()` 호출

```
OnMonsterKilledServer():
  if IsInfiniteActive == false then return
  TotalKillCount += 1
```

### 5-3. 사망 → 결과 → 제출 → 로비 복귀
기획서 플로우: 플레이어 사망 → 결과 화면(처치 수 + 최고 기록 비교) → 자동 랭킹 제출 → 로비 복귀

```
HandleInfiniteDeathServer():
  IsInfiniteActive = false
  MonsterSpawnComponent → 스폰 중지
  RankingComponent:SubmitInfiniteRecordServer(TotalKillCount)  -- PB 갱신 + 서버 업로드
  ShowInfiniteResultClient(TotalKillCount, SessionBestKills, isNewRecord)
  _TimerService:SetTimerOnce(→ LobbyFlowComponent:HandleRunCompletedServer(false), 결과화면딜레이)
```

### 5-4. 결과 화면 (Client)
- 표시 항목: 이번 처치 수, 로컬 최고 기록, 신기록 여부
- 기획서 이미지 참조: "무한 모드 결과 화면 목업"
- 결과 UI 엔티티: `GRInfiniteResultText` (TextComponent)

---

## 6. 연동 컴포넌트

| 컴포넌트 | 호출 방향 | 함수/필드 |
|---|---|---|
| `RankingComponent` | → 호출 | `SubmitInfiniteRecordServer(killCount)`, `InfiniteModeBestKills` 읽기 |
| `MonsterSpawnComponent` | ← 콜백 수신 | 몬스터 사망 시 `OnMonsterKilledServer()` 호출 |
| `MonsterSpawnComponent` | → 호출 | 보스 스폰 억제 플래그 설정 |
| `HPSystemComponent` | ← 이벤트 | 플레이어 사망 → `NotifyGameOver` 체인에서 도달 |
| `GameTimerComponent` | → 호출 | 무한 모드 진입 시 타이머 정지 |
| `LobbyFlowComponent` | → 호출 | 결과 표시 후 `HandleRunCompletedServer(false)` |

---

## 7. Maker 배치

### 7-1. UI 엔티티 (`DefaultGroup.ui`)

| 엔티티명 | 컴포넌트 | 초기 상태 | 비고 |
|---|---|---|---|
| `GRInfiniteResultText` | `TextComponent` | `enable: false` | 결과 화면 텍스트 |

### 7-2. 컴포넌트 부착

| 엔티티 | 컴포넌트 | 비고 |
|---|---|---|
| Player Entity (Bootstrap 자동) | `script.InfiniteModeComponent` | `Map01BootstrapComponent` 목록에 추가 |

---

## 8. 주의/최적화 포인트

- `TotalKillCount`는 `@Sync` — 클라이언트 HUD에 실시간 표시 가능
- 몬스터 사망 콜백은 **서버에서만** 집계 (치트 방지)
- 결과 화면 → 로비 복귀 사이 딜레이(약 3~5초)로 결과 확인 시간 확보
- `MonsterSpawnComponent` 변경 최소화: 보스 억제 플래그 1개 + 사망 콜백 1개만 추가

---

## 9. 선결 과제 (이 SPEC의 전제)

| 과제 | 현재 상태 | 필요 작업 |
|---|---|---|
| 최종 보스 사망 감지 | 미구현 | `MonsterSpawnComponent`에 보스 사망 이벤트 추가 |
| 몬스터 사망 콜백 | 미구현 | 몬스터 Destroy 시 `InfiniteModeComponent` 통지 |
| `HPSystemComponent` 게임오버 분기 | 부분 구현 | 무한 모드 여부에 따라 `InfiniteModeComponent.HandleInfiniteDeathServer()` 호출 경로 추가 |

---

## 10. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트, `Meta` 레이어
- [ ] `self._T.GRUtil` 사용 (BootstrapUtil 경유)
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil`/`isvalid` 방어 + `pcall` 보호
- [ ] `MonsterSpawnComponent` 수정: 보스 사망 감지 + Kill 콜백
- [ ] `HPSystemComponent` 수정: 무한 모드 사망 분기
- [ ] `Map01BootstrapComponent` 컴포넌트 목록에 `InfiniteModeComponent` 추가
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🟡 대기중 |
