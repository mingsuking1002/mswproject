# ⚪ 예시 (구현 대기 아님 — Codex는 이 파일을 무시할 것)
# [예시] 작업 명세서: SPEC_TagSystem

> **이 파일은 작업명세서의 작성 예시입니다.**
> 실제 구현 요청 시 파일명을 `SPEC_*.md`로 변경하고, 상태를 `🟡 대기중`으로 바꾸세요.

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `TagManagerComponent` |
| **파일 저장 위치** | `Global/common.gamelogic` 또는 새 `.codeblock` 생성 |
| **기능 요약** | 2인 캐릭터 실시간 교체 (태그 시스템) |
| **기획서 참조** | `기획서/0.개요/projectGR_main_proposal.md` §5. 태그 시스템 |

### 핵심 동작
- 플레이어가 **F키**를 누르면 현재 캐릭터(A↔B)가 **스왑**됨.
- 교체 시 **태그 스킬**(등장 스킬) 발동 + **쿨타임** 적용.
- 실제 MSW Entity는 1개만 유지하고, **외형(RUID)과 데이터만 교체**.

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| F키 입력 감지 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 서버에 태그 요청 | Client → Server | `@EventSender` 로 서버에 이벤트 전달 |
| 태그 로직 처리 | `[server only]` | 쿨타임 검증, 인덱스 변경, 스킬 발동 |
| UI/외형 갱신 | `[client only]` | Sync된 Property 변경 감지 → HUD 업데이트 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentCharIndex` | `integer` | `Sync` | `1` | 현재 활성 캐릭터 (1=A, 2=B) |
| `TagCooldown` | `number` | `None` | `10.0` | 태그 쿨타임 (초) — 밸런스 조절용 |
| `IsTagReady` | `boolean` | `Sync` | `true` | 태그 가능 여부 (쿨타임 반영) |
| `CharA_HP` | `number` | `Sync` | `100` | 캐릭터 A 체력 |
| `CharB_HP` | `number` | `Sync` | `100` | 캐릭터 B 체력 |
| `InvincibleTime` | `number` | `None` | `0.5` | 태그 직후 무적 시간 (초) |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | F키 입력 감지 (`KeyDownEvent`) |
| `_TimerService` | 쿨타임 타이머 (`SetTimer`) |
| `_UserService` | 유저별 데이터 관리 |
| `AvatarRendererComponent` | 캐릭터 외형(RUID) 변경 |
| `@EventSender` / `@EventHandler` | Client→Server 통신 |

---

## 5. 로직 흐름 (코드 작성하지 않음 — Codex가 구현)

### 5-1. 초기화
- 유저 접속 시 캐릭터 A/B 데이터 로드
- 기본 캐릭터(A)로 외형 세팅, `IsTagReady = true`

### 5-2. 입력 → 태그 요청
- 클라이언트에서 F키 `KeyDownEvent` 감지
- `IsTagReady` 확인 → 불가 시 UI 피드백
- 가능하면 `@EventSender`로 서버에 태그 요청

### 5-3. 서버 처리
1. 쿨타임 재검증 (클라이언트 우회 방지)
2. 교체 대상 캐릭터 생존 여부 확인
3. `CurrentCharIndex` 스왑 (1↔2)
4. 외형(RUID) 변경
5. 태그 스킬 발동
6. `IsTagReady = false` → `_TimerService`로 쿨타임 후 복원

### 5-4. 동기화
- `CurrentCharIndex` Sync → 클라이언트에서 `OnSyncProperty`로 감지
- HUD/외형 갱신은 클라이언트에서 처리

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `WeaponManagerComponent` | 이벤트 구독 | 태그 시 무기 세트도 교체 |
| `PlayerHUDComponent` | Sync 감지 | HP/캐릭터 아이콘 갱신 |
| `GameManagerComponent` | 참조 | 양쪽 사망 시 게임 오버 |

---

## 7. 주의 사항

- [ ] **HP 공유 여부:** 기획 확인 필요 (개별 vs 통합)
- [ ] **사망 처리:** 한쪽 사망 시 태그 불가, 양쪽 사망 시 게임 오버
- [ ] **무적 시간:** 태그 직후 `InvincibleTime` 동안 무적
- [ ] **쿨타임 UI:** 진행률을 HUD에 표시
- [ ] **coroutine 금지:** `_TimerService` 사용

---

## 8. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil` 체크, `isValid` 방어 코드
- [ ] 기존 스크립트 연동 확인
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex (실무 프로그래머) |
| **작성일** | 2026-02-17 |
| **상태** | ⚪ 예시 |
| **상태 흐름** | `🟡 대기중` → `🔵 진행중` → `🟢 완료` |
