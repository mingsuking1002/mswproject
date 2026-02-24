# 🟡 대기중
# SPEC_InfiniteMode — 무한 모드 & 점수 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `InfiniteModeComponent` (신규) |
| **Execution Space** | `[Server Only]` (점수 집계/모드 전환), `[Client Only]` (점수 UI/결과 화면) |
| **기획서 참조** | `기획서/1.핵심 시스템/[v.1.2] 무한 모드 랭킹 시스템.md`, `기획서/2.세부 시스템/[콘텐츠] v.1.1 랭킹 콘텐츠 기획.md` |
| **모듈화 레이어** | `Meta` |

> [!IMPORTANT]
> - 점수 = `MonsterData.csv` / `ModeMonsterData.csv`의 `creep_score` 컬럼 누적 (Kill Count 아님)
> - 기존 `RankingComponent` Infinite 파이프라인은 재사용하되, **리네임 필수** (§A 참조)

---

## 2. 유저 플로우

```
일반 모드 전투 시작
  ↓ 몬스터 처치마다 creep_score 누적 (= 일반 모드 점수)
  ↓
[사망 시] → 결과 화면: 일반 모드 점수 표시 (랭킹 등재 X) → 로비
[최종 보스 클리어 시] → '재돌입 결의' 팝업
  ├─ [거부] → 일반 모드 점수만 표시, 종료 → 로비
  └─ [수락] → 무한 모드 진입
                ↓ 점수 0 재시작 (전투 상태 유지: 무기/패시브/체력/잔탄)
                ↓ 타이머 → 점수판 전환
                ↓ ModeMonsterData 기반 무한 웨이브 (분당 스탯 증가)
                ↓ 몬스터 처치마다 creep_score 누적
              [사망] → 결과 화면 (무한 모드 점수 + 최고 기록 비교)
                     → 신기록이면 랭킹 등재
                     → 로비 + 랭킹 창 오픈
```

---

## 3. Properties (InfiniteModeComponent)

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsInfiniteActive` | `boolean` | `@Sync` | `false` | 무한 모드 진행 중 |
| `CurrentScore` | `integer` | `@Sync` | `0` | 현재 누적 점수 (일반/무한 공용) |
| `SessionBestScore` | `integer` | `None` | `0` | 로컬 PB (결과 비교용) |
| `ResultDelaySeconds` | `number` | `None` | `3.0` | 결과→로비 딜레이 |
| `ModeMonsterDataTableName` | `string` | `None` | `"ModeMonsterData"` | 무한 모드 몬스터 테이블명 |

---

## 4. 사용 서비스

| 서비스 | 용도 |
|---|---|
| `_TimerService` | 결과 딜레이 |
| `_DataService` | `MonsterData` / `ModeMonsterData` 테이블 creep_score 조회 |

---

## 5. 로직 흐름

### 5-1. 점수 집계 (공용)
몬스터 사망 시 서버에서 `OnMonsterKilledServer(monsterId)` 호출. `creep_score` 조회 → `CurrentScore += score`. 사망(IsDead) 후 집계 즉시 중단.

### 5-2. 보스 클리어 → 재돌입 결의
보스 사망 감지 → 스폰 정지 → 클라이언트에 팝업 표시 → 유저 선택 → 서버 전달.
네트워크 단절/타임아웃 시 → 일반 종료(거부)로 처리.

### 5-3. 무한 모드 진입
`IsInfiniteActive = true`, `CurrentScore = 0`, `SessionBestScore = RankingComponent.InfiniteBestScore`.
タイマー 정지 → 점수판 전환. `ModeMonsterData` 기반 무한 웨이브 시작.

### 5-4. 사망 → 결과 → 제출
무한 모드: `RankingComponent.SubmitInfiniteRecordServer(CurrentScore)` → 결과 화면 → 딜레이 → 로비.
일반 모드: 점수만 표시 → 로비.

---

## 6. ModeMonsterData 테이블 구조

| 컬럼 | 자료형 | 설명 |
|---|---|---|
| `id` | STRING | 몬스터 ID |
| `mon_type` | ENUM | `mode_normal`, `mode_elite` |
| `mode_mon_hp` | FLOAT | 기본 HP |
| `mode_mon_hp_up` | FLOAT | **분당** HP 증가량 |
| `mon_atk` | FLOAT | 기본 공격력 |
| `mode_mon_atk_up` | FLOAT | **분당** 공격력 증가량 |
| `mon_spd` / `mon_spd_up` | FLOAT | 속도 / 분당 증가 |
| `creep_score` | INT | 처치 시 획득 점수 |

> 현재 데이터: 일반 1종(10점), 엘리트 2종(500점). 분당 스탯 증가로 후반 난이도 기하급수 상승.

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `RankingComponent` | `SubmitInfiniteRecordServer(score)`, `InfiniteBestScore` 읽기 |
| `MonsterSpawnComponent` | 몬스터 사망 콜백, 무한 웨이브 전환(ModeMonsterData), 스폰 제어 |
| `HPSystemComponent` | 사망 시 무한 모드 분기 |
| `SpeedrunTimerComponent` | 무한 모드 진입 시 정지 → 점수판 전환 |
| `LobbyFlowComponent` | 결과 후 로비 복귀 |

---

## 8. Maker 배치 (UI 틀만 — 이미지는 PD가 추가)

| 엔티티명 | 컴포넌트 | 초기 | 용도 |
|---|---|---|---|
| `GRScoreText` | `TextComponent` | `enable: false` | 실시간 점수 (우상단) |
| `GRResultPanel` | `TextComponent` | `enable: false` | 결과 화면 (일반/무한 공용 틀) |
| `GRReentryPopup` | `TextComponent`, `ButtonComponent` ×2 | `enable: false` | 재돌입 결의 팝업 (수락/거부 버튼) |

컴포넌트 부착: Player Entity → `script.InfiniteModeComponent` (Bootstrap 목록 추가)

---

## 9. 주의/최적화

- `CurrentScore`는 `@Sync` → 클라이언트 UI 실시간 반영
- 사망 즉시 집계 중단 (동귀어진 방지)
- 서버 전용 집계 (치트 방지)
- `creep_score` 조회 실패 시 `0` fallback

---

## A. RankingComponent 리네임 (함께 작업)

**목적**: "Kills" → "Score"로 의미 정확성 확보

| 대상 | Before | After |
|---|---|---|
| Property | `InfiniteModeBestKills` | `InfiniteBestScore` |
| 파라미터 | `killCount` (SubmitInfiniteRecordServer) | `score` |
| 검증 함수 | `IsValidInfiniteRecord(killCount)` | `IsValidInfiniteRecord(score)` |
| Property | `MaximumValidKills` | `MaximumValidScore` |
| 스토리지 키 | `Ranking_InfiniteBest` | 변경 없음 (호환성) |
| 스토리지명 | `GR_Infinite` | 변경 없음 |

> 영향 파일: `RankingComponent.mlua`, `.codeblock`, `SPEC_RankingSystem.md`, `Code_Documentation.md`

---

## B. 선결 과제

| 과제 | 상태 | 작업 |
|---|---|---|
| 몬스터 사망 → creep_score 전달 | 미구현 | Destroy 시 `InfiniteModeComponent.OnMonsterKilledServer(monsterId)` 통지 |
| 최종 보스 사망 감지 | 미구현 | `MonsterSpawnComponent`에서 보스 처치 이벤트 |
| HP 시스템 무한 모드 분기 | 미구현 | `NotifyGameOver`에서 `IsInfiniteActive` 분기 |
| `ModeMonsterData.csv` → Maker 데이터서비스 등록 | 미완료 | CSV를 `ProjectGR/Data/` 경로에 배치 + `_DataService` 등록 |

---

## C. Codex 체크리스트

- [ ] `InfiniteModeComponent` 신규 (`@Component`, `Meta`)
- [ ] `RankingComponent` 리네임 (§A)
- [ ] `MonsterSpawnComponent` 수정: 보스 사망 감지 + Kill 콜백 + ModeMonsterData 전환
- [ ] `HPSystemComponent` 수정: 무한 모드 사망 분기
- [ ] 결과 UI 틀 제작 (GRResultPanel, GRReentryPopup, GRScoreText)
- [ ] `Map01BootstrapComponent` 목록 추가
- [ ] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🟡 대기중 |
