# 🟢 완료
# SPEC_RankingSystem — 랭킹(리더보드) 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `RankingComponent`, `RankingUIComponent` |
| **기능 요약** | 타임어택/무한모드 이중 리더보드, 서버 저장, Top 100 + 내 순위 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 랭킹 시스템 기획.md` |
| **모듈화 레이어** | `Meta` (Ranking) / `UI` (RankingUI) |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 기록 비교 (신기록 체크) | `[server only]` | 결과 화면 시점 |
| 서버에 점수 전송 | `[server only]` | `_LeaderBoardService` |
| 랭킹 데이터 요청 | `[client]` → `[server]` | 랭킹 창 오픈 시 |
| 랭킹 UI 표시 | `[client only]` | 리스트 렌더링 |

---

## 3. Properties

### RankingComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `TimeAttackBestTime` | `number` | `None` | `-1` | 타임어택 최고 기록 |
| `InfiniteModeBestKills` | `integer` | `None` | `0` | 무한모드 최고 처치수 |

### RankingUIComponent

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentTab` | `integer` | `None` | `1` | 현재 탭 (1=타임어택) |
| `DisplayCount` | `integer` | `None` | `100` | 표시할 최대 순위 수 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_LeaderBoardService` | 점수 등록/조회 |
| `_DataStorageService` | 로컬 개인 최고 기록 |
| `_UserService` | 유저 닉네임 조회 |

---

## 5. 로직 흐름

### 5-1. 기록 제출
클리어 → 개인 최고 비교 → 신기록이면 LeaderBoard 전송 + 로컬 갱신

### 5-2. 랭킹 조회
창 오픈 → Top 100 + 내 순위 요청 → 클라이언트 렌더링

### 5-3. UI 구조
탭(타임어택/무한모드) + 리스트(순위, 닉네임, 기록, 갱신일) + 내 순위(하단 고정)

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| `확인` | `GRRankingText` | `UITransformComponent`, `TextComponent` | `enable: true` | 로비 화면 | 랭킹 요약 텍스트 |
| `확인` | `GRMyRankText` | `UITransformComponent`, `TextComponent` | `enable: true` | 로비 화면 | 내 순위 표시 |

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.RankingComponent` | 기본값 | 자동 부착 |
| Player Entity (Bootstrap 자동) | `script.RankingUIComponent` | `DisplayCount=100` | 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `SpeedrunTimerComponent` | Meta | `ElapsedTime` 수신 → 타임어택 기록 |
| `LobbyFlowComponent` | Bootstrap | 로비 진입 시 랭킹 자동 조회 |
| `HUDComponent` | UI | 랭킹 팝업 열기/닫기 |

---

## 8. 주의/최적화 포인트

- 게임 플레이 중에는 서버 저장 안 함 — 결과 화면에서만
- 동점자 처리: 먼저 달성한 유저 우선 (서버 타임스탬프)
- MSW `_LeaderBoardService` API 확인 필요

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Meta`/`UI` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] `GRRankingText`/`GRMyRankText` 표시와 랭킹 스냅샷 갱신을 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

