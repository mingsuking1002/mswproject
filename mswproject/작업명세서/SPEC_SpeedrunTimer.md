# 🟢 완료
# SPEC_SpeedrunTimer — 스피드런 타이머 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `SpeedrunTimerComponent` |
| **기능 요약** | 스테이지 클리어 시간 정밀 측정, 최고 기록 저장, 신기록 연출 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 스피드런 타이머 시스템.md` |
| **모듈화 레이어** | `Meta` |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 타이머 시작/정지 제어 | `[server only]` | 게임 이벤트 기반 |
| 시간 누적 | `[server only]` | 서버 기준 시간 (치트 방지) |
| UI 표시 (`MM:SS.ms`) | `[client only]` | Sync된 시간값 → 텍스트 변환 |
| 기록 저장/로드 | `[server only]` | `_DataStorageService` |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `ElapsedTime` | `number` | `Sync` | `0.0` | 경과 시간 (초) |
| `IsRunning` | `boolean` | `Sync` | `false` | 타이머 작동 중 여부 |
| `CurrentStageId` | `integer` | `None` | `1` | 현재 스테이지 ID |
| `BestTime` | `number` | `Sync` | `-1` | 최고 기록 (-1 = 없음) |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_DataStorageService` | 스테이지별 최고 기록 저장/로드 |
| `TextComponent` | 타이머 UI 텍스트 표시 |

---

## 5. 로직 흐름

### 5-1. 타이머 시작
카운트다운 종료 → IsRunning = true, ElapsedTime = 0 → OnUpdate에서 누적

### 5-2. 일시정지
ESC/상점/무기교체 → IsRunning = false → 닫히면 복귀

### 5-3. 타이머 정지 (클리어)
보스 처치 → IsRunning = false → ElapsedTime이 최종 기록

### 5-4. 기록 비교/저장
신기록이면 `Stage_{N}_BestTime` 키로 저장

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| `확인/추가` | `GRTimerText` | `UITransformComponent`, `TextComponent` | `enable: false` | 화면 상단 중앙 | 타이머 텍스트 — 인게임에서만 표시 |

### 6-2. 맵 엔티티

해당 없음

### 6-3. 글로벌/모델

해당 없음

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| Player Entity (Bootstrap 자동) | `script.SpeedrunTimerComponent` | 기본값 | 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `WeaponSwapComponent` | Meta | `IsSwapMenuOpen` 감지 → 타이머 정지 |
| `RankingComponent` | Meta | `ElapsedTime` 전달 → 랭킹 기록 전송 |
| `HUDComponent` | UI | 타이머 텍스트 렌더링 |

---

## 8. 주의/최적화 포인트

- 시간은 Float, 표시만 `MM:SS.ms` 변환
- OnUpdate에서 시간 누적하되 서버 기준
- 상점/메뉴 중 시간 정지 — 순수 플레이 시간만

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Meta` 레이어
- [x] `self._T.GRUtil` 사용 (BootstrapUtil 경유, 중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 항목을 백로그로 분리**
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 수동 백로그

- [ ] `GRTimerText` 표시/숨김과 카운트다운-런타임 갱신을 Maker Play에서 최종 확인

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

