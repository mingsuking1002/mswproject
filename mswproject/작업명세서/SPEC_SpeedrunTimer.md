# 🟢 완료
# SPEC_SpeedrunTimer — 스피드런 타이머 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `SpeedrunTimerComponent` |
| **기능 요약** | 스테이지 클리어 시간 정밀 측정, 최고 기록 저장, 신기록 연출 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 스피드런 타이머 시스템.md` |

### 핵심 동작
- 스테이지 시작 카운트다운 후 타이머 자동 시작
- 화면 상단에 `MM:SS.ms` 실시간 표시
- 보스 처치 또는 목표 달성 시 타이머 정지
- 신기록 시 연출 + 기록 저장

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 타이머 시작/정지 제어 | `[server only]` | 게임 이벤트 기반 |
| 시간 누적 | `[server only]` | 서버 기준 시간 (치트 방지) |
| UI 표시 (`MM:SS.ms`) | `[client only]` | Sync된 시간값 → 텍스트 변환 |
| 기록 저장/로드 | `[server only]` | `_DataStorageService` 또는 로컬 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `ElapsedTime` | `number` | `Sync` | `0.0` | 경과 시간 (Float, 초 단위) |
| `IsRunning` | `boolean` | `Sync` | `false` | 타이머 작동 중 여부 |
| `CurrentStageId` | `integer` | `None` | `1` | 현재 스테이지 ID (1~5) |
| `BestTime` | `number` | `Sync` | `-1` | 현재 스테이지 최고 기록 (-1 = 기록 없음) |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_DataStorageService` | 스테이지별 최고 기록 저장/로드 (키: `Stage_{N}_BestTime`) |
| `TextComponent` | 타이머 UI 텍스트 표시 |

---

## 5. 로직 흐름

### 5-1. 타이머 시작
1. 스테이지 로딩 완료 → 카운트다운 연출 ("Ready... Go!")
2. 카운트다운 종료 이벤트 수신 → `IsRunning = true`, `ElapsedTime = 0.0`
3. OnUpdate에서 `ElapsedTime += delta` (IsRunning == true일 때만)

### 5-2. 일시정지 처리
- 다음 상황에서 `IsRunning = false` (시간 멈춤):
  - ESC 메뉴 열림
  - 상점(Shop) 이용 중
  - 무기 교체 팝업 (F키) 열림 중
- 해당 UI 닫힘 → `IsRunning = true` 복귀

### 5-3. 타이머 정지 (클리어)
1. 보스 처치 또는 목표 달성 이벤트 수신
2. `IsRunning = false` — 타이머 즉시 정지
3. `ElapsedTime`이 최종 기록

### 5-4. 기록 비교/저장
1. `BestTime == -1` (최초 클리어) → 무조건 저장
2. `ElapsedTime < BestTime` (신기록) → 기록 갱신 + "New Record!" 연출
3. 저장 키: `Stage_{CurrentStageId}_BestTime` → `_DataStorageService`에 Float 저장

### 5-5. 클라이언트 UI
- `ElapsedTime` Sync → 매 프레임 `MM:SS.ms` 포맷으로 변환하여 TextComponent에 표시
- 위치: 화면 중앙 상단 (Top-Center) 고정
- 신기록 달성 시: 특수 연출 (색상 변경, 사운드)

### 5-6. 재시작 (Retry)
- 사망 후 재시작 시 `ElapsedTime = 0.0`, `IsRunning` 카운트다운 대기 상태로 초기화

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `WeaponSwapComponent` | `IsSwapMenuOpen` 감지 | 무기 교체 중 타이머 정지 |
| `GameManagerComponent` | 클리어/사망 이벤트 | 타이머 정지 트리거, 재시작 트리거 |
| `RankingComponent` | `ElapsedTime` 전달 | 클리어 시 랭킹 시스템에 기록 전송 |
| `HUDComponent` | UI 표시 | 타이머 텍스트 렌더링 |

---

## 7. 주의 사항

- [ ] 시간은 **Float(실수)** — 기획서 확정, 표시만 `MM:SS.ms` 변환
- [ ] OnUpdate에서 시간 누적하되, 서버 기준 (클라이언트 조작 방지)
- [ ] 상점/메뉴 중 시간 정지 — 순수 플레이 시간만 측정
- [ ] 저장 키 네이밍: `Stage_{N}_BestTime` (기획서 확정)

---

## 8. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil` 체크, `isValid` 방어 코드
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
