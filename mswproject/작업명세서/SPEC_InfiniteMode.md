# 🟡 대기중
# SPEC_InfiniteMode — 무한 모드 & 점수 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `InfiniteModeComponent` |
| **Execution Space** | `[Server Only]` (점수 집계/모드 전환), `[Client Only]` (점수 UI/결과 화면) |
| **기획서 참조** | `기획서/1.핵심 시스템/[v.1.2] 무한 모드 랭킹 시스템.md`, `기획서/2.세부 시스템/[콘텐츠] v.1.1 랭킹 콘텐츠 기획.md` |
| **모듈화 레이어** | `Meta` |

> [!IMPORTANT]
> - 점수 단위는 **Kill Count가 아닌** `MonsterData.csv`의 `creep_score` 컬럼 값 누적
> - 기존 `RankingComponent`의 Infinite 파이프라인(Submit/Upload/GetTopRanks)은 **수정 없이 재사용** (단, `InfiniteModeBestKills` → 실질적으로 "점수" 의미)

---

## 2. 유저 플로우 요약

```
일반 모드 전투 시작
  ↓ 몬스터 처치마다 creep_score 누적 (일반 모드 점수)
  ↓
[사망 시] → 결과 화면: 일반 모드 점수만 표시 (랭킹 등재 X) → 로비
[최종 보스 클리어 시] → '재돌입 결의' 선택 UI
  ├─ [거부] → 일반 모드 점수 표시 후 종료 (랭킹 등재 X) → 로비
  └─ [수락] → 무한 모드 진입
                ↓ 점수 0에서 재시작 (기존 전투 상태 유지: 무기/패시브/체력)
                ↓ 타이머 → 점수판으로 전환
                ↓ 몬스터 처치마다 creep_score 누적 (무한 모드 점수)
                ↓
              [사망] → 결과 화면 (무한 모드 점수 + 최고 기록 비교)
                     → 신기록이면 랭킹 등재 (RankingComponent 경유)
                     → 로비 복귀 + 랭킹 창 오픈
```

---

## 3. Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsInfiniteActive` | `boolean` | `@Sync` | `false` | 무한 모드 진행 중 |
| `CurrentScore` | `integer` | `@Sync` | `0` | 현재 모드 누적 점수 (일반/무한 공용) |
| `SessionBestScore` | `integer` | `None` | `0` | 로컬 PB (결과 화면 비교용, RankingComponent에서 로드) |
| `ResultDelaySeconds` | `number` | `None` | `3.0` | 결과 화면 → 로비 복귀 딜레이 |

---

## 4. 사용 서비스

| 서비스 | 용도 |
|---|---|
| `_TimerService` | 결과 딜레이, UI 전환 |
| `_DataService` | `MonsterData` 테이블에서 `creep_score` 조회 |

> 저장/랭킹은 **기존 `RankingComponent`가 전담**.

---

## 5. 로직 흐름

### 5-1. 점수 집계 (일반 모드 + 무한 모드 공용)
- 몬스터 사망 시 서버에서 `OnMonsterKilledServer(monsterId)` 호출
- `MonsterData` 테이블에서 해당 몬스터의 `creep_score` 조회 → `CurrentScore += creep_score`
- `IsInfiniteActive`와 무관하게 항상 집계 (일반 모드에서도 점수 표시용)

```
OnMonsterKilledServer(monsterId):
  if IsDead then return  -- 사망 후 집계 중단
  score = MonsterData[monsterId].creep_score or 0
  CurrentScore += score   -- @Sync → 클라이언트 HUD 자동 갱신
```

### 5-2. 보스 클리어 → 재돌입 결의
- 최종 보스 사망 감지 시 `OnFinalBossClearedServer()` 호출
- 서버: 게임 시간 정지 + 클라이언트에 선택 UI 요청
- 클라이언트: '재돌입 결의' 팝업 표시 → 유저 선택 → 서버로 결과 전송

```
OnFinalBossClearedServer():
  게임 타임 정지 (MonsterSpawnComponent → 스폰 중지)
  ShowReentryDecisionClient()  -- 클라이언트에 팝업 표시 요청

OnReentryDecisionServer(accepted):
  if accepted == false then
    HandleNormalEndServer()  -- 일반 종료: 점수 표시만, 랭킹 X
    return
  EnterInfiniteModeServer()
```

### 5-3. 무한 모드 진입
```
EnterInfiniteModeServer():
  IsInfiniteActive = true
  CurrentScore = 0  -- 점수 초기화 (기존 전투 상태는 유지)
  SessionBestScore = RankingComponent.InfiniteModeBestKills
  타이머 → 점수판 전환 (SpeedrunTimerComponent 정지)
  MonsterSpawnComponent → 무한 웨이브 시작 (보스 없이 일반/엘리트 무한 스폰)
```

### 5-4. 사망 → 결과 → 제출
```
HandleInfiniteDeathServer():
  IsInfiniteActive = false
  MonsterSpawnComponent → 스폰 중지
  isNewRecord = RankingComponent:SubmitInfiniteRecordServer(CurrentScore)
  ShowInfiniteResultClient(CurrentScore, SessionBestScore, isNewRecord)
  딜레이 후 → LobbyFlowComponent:HandleRunCompletedServer(false) → 로비

HandleNormalEndServer():
  ShowNormalResultClient(CurrentScore)  -- 일반 모드 점수만 표시
  딜레이 후 → LobbyFlowComponent:HandleRunCompletedServer(isClear)
```

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `RankingComponent` | `SubmitInfiniteRecordServer(score)` 호출, `InfiniteModeBestKills` 읽기 |
| `MonsterSpawnComponent` | 몬스터 사망 시 `OnMonsterKilledServer(monsterId)` 콜백 수신, 스폰 제어 |
| `HPSystemComponent` | 사망 시 `NotifyGameOver` → 무한 모드 여부 분기 |
| `SpeedrunTimerComponent` | 무한 모드 진입 시 타이머 정지 → 점수판 전환 |
| `LobbyFlowComponent` | 결과 후 `HandleRunCompletedServer(false)` 로비 복귀 |

---

## 7. Maker 배치

### 7-1. UI 엔티티

| 엔티티명 | 컴포넌트 | 초기 상태 | 용도 |
|---|---|---|---|
| `GRScoreText` | `TextComponent` | `enable: false` | 실시간 점수 표시 (타이머 위치 대체) |
| `GRInfiniteResultPanel` | `TextComponent` | `enable: false` | 무한 모드 결과 화면 |
| `GRReentryPopup` | `TextComponent`, `ButtonComponent` | `enable: false` | 재돌입 결의 선택 팝업 |

### 7-2. 컴포넌트 부착

| 엔티티 | 컴포넌트 | 비고 |
|---|---|---|
| Player Entity (Bootstrap) | `script.InfiniteModeComponent` | `Map01BootstrapComponent` 목록에 추가 |

---

## 8. 주의/최적화

- `CurrentScore`는 `@Sync` → 클라이언트 HUD 실시간 반영
- 사망 판정 즉시 점수 집계 중단 (동귀어진 방지)
- 점수 집계는 서버 전용 (치트 방지)
- `creep_score` 미정 데이터: CSV에서 조회 실패 시 `0` fallback
- 재돌입 결의 팝업 중 네트워크 단절 → 일반 종료로 처리

---

## 9. 선결 과제

| 과제 | 현재 상태 | 필요 작업 |
|---|---|---|
| 몬스터 사망 시 `creep_score` 전달 경로 | 미구현 | 몬스터 Destroy 시 `InfiniteModeComponent.OnMonsterKilledServer(monsterId)` 통지 |
| 최종 보스 사망 감지 | 미구현 | `MonsterSpawnComponent`에서 보스 처치 이벤트 발행 |
| `HPSystemComponent` 무한 모드 분기 | 미구현 | `NotifyGameOver`에서 `IsInfiniteActive` 여부 확인 → 분기 |

---

## 10. Codex 구현 체크리스트

- [ ] `@Component`, `Meta` 레이어
- [ ] `self._T.GRUtil` 사용
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil`/`isvalid` 방어 + `pcall` 보호
- [ ] `MonsterData` 테이블에서 `creep_score` 조회 로직
- [ ] 재돌입 결의 팝업 UI 로직
- [ ] `MonsterSpawnComponent` 수정: 보스 사망 감지 + Kill 콜백
- [ ] `HPSystemComponent` 수정: 무한 모드 사망 분기
- [ ] `Map01BootstrapComponent` 목록에 추가
- [ ] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🟡 대기중 |
