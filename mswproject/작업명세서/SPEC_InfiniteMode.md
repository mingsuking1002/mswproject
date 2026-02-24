# 🔵 진행중
# SPEC_InfiniteMode — 점수 · 무한 모드 · 랭킹 통합 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **신규 컴포넌트** | `InfiniteModeComponent` (Meta 레이어) |
| **수정 컴포넌트** | `RankingComponent`, `RankingUIComponent`, `MonsterSpawnComponent`, `HPSystemComponent` |
| **Execution Space** | `[Server Only]` 점수 집계/모드 전환/제출, `[Client Only]` 점수 UI/결과 화면 |
| **기획서** | `[v.1.2] 무한 모드 랭킹 시스템.md`, `[콘텐츠] v.1.1 랭킹 콘텐츠 기획.md` |

> [!IMPORTANT]
> **타임어택(클리어 시간 랭킹)은 완전 삭제.** 모든 랭킹은 `creep_score` 누적 점수 기반.

---

## 2. 랭킹 모드 구조 (변경 후)

| Mode | 이름 | 점수 단위 | 정렬 | 스토리지 | 랭킹 등재 |
|---|---|---|---|---|---|
| **1** | 일반 모드 | `MonsterData.creep_score` 누적 | 내림차순 | `GR_NormalScore` | ✅ |
| **2** | 무한 모드 | `ModeMonsterData.creep_score` 누적 | 내림차순 | `GR_Infinite` 유지 | ✅ |

> 기존 `GR_TimeAttack` 스토리지 + `TimeAttackBestTime` Property + 시간 포맷 로직 → **전부 삭제**

---

## 3. 유저 플로우

```
일반 모드 시작
  ↓ 몬스터 처치마다 MonsterData.creep_score 누적
  ↓
[보스 클리어 전 사망] → 결과 화면 (점수 표시만, 랭킹 등재 ❌) → 로비
[보스 클리어] → '재돌입 결의' 팝업
  ├─ [거부] → 일반 모드 점수 결과 + 랭킹 등재 ✅ → 로비
  └─ [수락] → 무한 모드 진입
                점수 0 재시작 (전투 상태 유지)
                ModeMonsterData 기반 무한 웨이브
              [사망] → 결과 (무한 점수 + 최고 기록) + 랭킹 등재 ✅
                     → 로비 + 랭킹 창 오픈
```

> [!NOTE]
> 일반 모드 랭킹 등재 조건 = **보스 클리어 필수**. 점수 집계는 항상 하지만, 보스 클리어 전 사망 시 점수 표시만 하고 등재하지 않음.

---

## 4. InfiniteModeComponent (신규)

### Properties

| Property | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsInfiniteActive` | `boolean` | `@Sync` | `false` | 무한 모드 진행 중 |
| `CurrentScore` | `integer` | `@Sync` | `0` | 현재 누적 점수 |
| `SessionBestScore` | `integer` | `None` | `0` | 로컬 PB (결과 비교용) |
| `ResultDelaySeconds` | `number` | `None` | `3.0` | 결과→로비 딜레이 |
| `ModeMonsterDataTableName` | `string` | `None` | `"ModeMonsterData"` | 무한 몬스터 테이블 |

### 로직

- **점수 집계**: `OnMonsterKilledServer(monsterId)` → `creep_score` 조회 → `CurrentScore += score`
- **재돌입 결의**: 보스 사망 → 스폰 정지 → 팝업 → 유저 선택 → 서버 전달
- **무한 진입**: `CurrentScore = 0`, 전투 상태 유지, ModeMonsterData 웨이브 시작
- **사망 처리**:
  - 일반 모드: `RankingComponent.SubmitNormalRecordServer(CurrentScore)` → 결과 → 로비
  - 무한 모드: `RankingComponent.SubmitInfiniteRecordServer(CurrentScore)` → 결과 → 로비

---

## 5. RankingComponent 변경사항

### 삭제 항목

| 항목 | 삭제 대상 |
|---|---|
| Property | `TimeAttackBestTime`, `MinimumValidClearTime`, `MaximumValidClearTime`, `TimeAttackStorageName`, `TimeAttackLocalKey` |
| Method | `SubmitTimeAttackRecordServer`, `UploadTimeAttackRecordServer`, `IsValidTimeAttackRecord` |
| Logic | `FormatScoreForDisplay`의 시간 포맷 분기 (Mode 1 → `%02d:%02d.%02d`) |
| Storage | `GR_TimeAttack` SortableDataStorage |

### 추가/변경 항목

| 항목 | 변경 |
|---|---|
| Property `InfiniteModeBestKills` | → `InfiniteBestScore` 리네임 |
| Property `MaximumValidKills` | → `MaximumValidScore` 리네임 |
| 신규 Property | `NormalBestScore` (integer, None, 0) — 일반 모드 최고 점수 |
| 신규 Property | `NormalStorageName` = `"GR_NormalScore"` |
| 신규 Property | `NormalLocalKey` = `"Ranking_NormalBest"` |
| 신규 Method | `SubmitNormalRecordServer(integer score)` — 일반 모드 점수 제출 |
| 신규 Method | `UploadNormalRecordServer(integer score)` |
| `GetSortableStorageByMode` | Mode 1 → `GR_NormalScore` (내림차순), Mode 2 → `GR_Infinite` (내림차순) |
| `FormatScoreForDisplay` | Mode 구분 없이 모두 `tostring(score)` (시간 포맷 삭제) |
| `NormalizeMode` | 변경 없음 (1=일반, 2=무한) |
| `LoadLocalBestRecordsServer` | TimeAttack 로드 → Normal 로드로 교체 |

### 정렬 방향 통일

기존: Mode 1 `Ascending`, Mode 2 `Descending`
변경 후: **양쪽 모두 `Descending`** (높은 점수가 1등)

---

## 6. RankingUIComponent 변경사항

| 항목 | 변경 |
|---|---|
| 탭 라벨 | "타임어택" → **"일반 모드"** |
| 탭 라벨 | "무한모드" → **"무한 모드"** (기존 유지) |
| `CurrentTab = 1` | 1 = 일반 모드, 2 = 무한 모드 |
| 점수 표시 포맷 | 시간 표기 제거, 모두 정수 점수 표시 |

---

## 7. ModeMonsterData 테이블

| 컬럼 | 타입 | 설명 |
|---|---|---|
| `id` | STRING | 몬스터 ID |
| `mon_type` | ENUM | `mode_normal`, `mode_elite` |
| `mode_mon_hp` / `mode_mon_hp_up` | FLOAT | 기본 HP / **분당** 증가 |
| `mon_atk` / `mode_mon_atk_up` | FLOAT | 공격력 / 분당 증가 |
| `mon_spd` / `mon_spd_up` | FLOAT | 속도 / 분당 증가 |
| `creep_score` | INT | 처치 시 획득 점수 |

현재 데이터: 일반 1종(10점), 엘리트 2종(500점)

---

## 8. Maker 배치 (UI 틀만, 이미지는 PD 추가)

| 엔티티 | 컴포넌트 | 초기 | 용도 |
|---|---|---|---|
| `GRScoreText` | `TextComponent` | `enable: false` | 실시간 점수 (우상단) |
| `GRResultPanel` | `TextComponent` | `enable: false` | 결과 화면 틀 |
| `GRReentryPopup` | `TextComponent`, `ButtonComponent` ×2 | `enable: false` | 재돌입 결의 팝업 |

컴포넌트 부착: Player Entity → `script.InfiniteModeComponent` (Bootstrap 추가)

---

## 9. 연동 컴포넌트

| 컴포넌트 | 연동 |
|---|---|
| `RankingComponent` | `SubmitNormalRecordServer(score)`, `SubmitInfiniteRecordServer(score)` |
| `MonsterSpawnComponent` | 몬스터 사망 콜백, ModeMonsterData 전환, 스폰 제어 |
| `HPSystemComponent` | 사망 시 모드 분기 |
| `GameTimerComponent` | 무한 진입 후 시간 기준 컨텍스트 유지(스폰/상태 연동) |
| `LobbyFlowComponent` | 결과 후 로비 복귀 |

---

## 10. 선결 과제

| 과제 | 작업 |
|---|---|
| 몬스터 사망 → creep_score 전달 | Destroy 시 `OnMonsterKilledServer(monsterId)` 통지 |
| 보스 사망 감지 | `MonsterSpawnComponent`에서 보스 처치 이벤트 |
| HP 시스템 분기 | `NotifyGameOver`에서 `IsInfiniteActive` 분기 |
| ModeMonsterData.csv | `ProjectGR/Data/`에 배치 + `_DataService` 등록 |

---

## 11. Codex 체크리스트

- [x] `InfiniteModeComponent` 신규
- [x] `RankingComponent`: TimeAttack 삭제 + Normal 추가 + 리네임 (§5)
- [x] `RankingUIComponent`: 탭 라벨 + 포맷 변경 (§6)
- [x] `MonsterSpawnComponent`: 보스 감지 + Kill 콜백 + ModeMonsterData 전환
- [x] `HPSystemComponent`: 무한 모드 사망 분기
- [x] UI 틀 제작 (GRResultPanel, GRReentryPopup, GRScoreText)
- [x] `Map01BootstrapComponent` 목록 추가
- [x] `Code_Documentation.md` 업데이트
- [ ] 완료 후 `🟢 완료`

---

| **작성자** | Antigravity (TD) | **상태** | 🔵 진행중 |
|---|---|---|---|
| **담당자** | Codex | **작성일** | 2026-02-24 |
