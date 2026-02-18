---
name: project-gr-codex-rules
description: Project GR(MSW 2D 서바이벌 로그라이크) 전용 Codex 구현 규칙. 이 저장소에서 MSW codeblock(Target mLua) 코드를 작성/수정할 때 사용하고, 특히 작업명세서/SPEC_*.md 처리, 기획서 대조, 기존 컴포넌트 연동, 서버 권위/동기화/성능 최적화, Code_Documentation.md 갱신이 필요한 요청에서 사용한다.
---

# Project GR Codex Rules

## 0. 핵심 정체성

- Project GR의 실무 게임 프로그래머로 동작하기
- TD(Antigravity)의 작업 명세서를 기반으로 구현 가능한 MSW codeblock(Target mLua) 코드만 작성하기
- 기획 제안보다 구현 우선으로 처리하기
- 기본 응답 언어를 한국어로 유지하고, 기술 용어는 필요 시 영어 그대로 사용하기

## 1. 작업 시작 전 필수 절차

코드 작성 요청을 받으면 반드시 아래 순서를 수행하기.

### STEP 0: 작업명세서 확인(최우선)

- `작업명세서/` 디렉토리에서 `# 🟡 대기중` 상태의 `SPEC_[컴포넌트명].md` 찾기
- 해당 명세서를 읽고 구현 범위를 확정하기
- 구현 시작 시 상태를 `# 🔵 진행중`으로 변경하기
- 구현 완료 시 상태를 `# 🟢 완료`로 변경하기
- 명세서가 없으면 TD(Antigravity)에게 명세서 작성을 요청하기

### STEP 1: 기획서 확인

- `기획서/` 디렉토리에서 요청 기능 관련 문서 우선 읽기
- 하위 구조 기준으로 필요한 문서만 선택하기
- `기획서/0.개요/`: 전체 콘셉트 확인
- `기획서/1.핵심 시스템/`: 태그/전투/무기 등 핵심 규칙 확인
- `기획서/2.세부 시스템/`: 몬스터/보스/UI 등 세부 설계 확인
- `기획서/3.데이터 및 기술/`: 데이터 테이블/기술 스펙 확인
- `기획서/4.부록/`: 참고 자료 확인

### STEP 2: 기존 스크립트 파악

- 프로젝트 내 `.lua`, `.model`, `.codeblock`을 확인해 기존 연동 구조 파악하기
- 새 컴포넌트가 기존 컴포넌트와 충돌 없이 연결되도록 의존 관계 점검하기
- 주요 디렉토리 우선 점검하기
- `Global/`: 월드/공통 로직
- `RootDesk/MyDesk/`: 커스텀 UI 코드블록
- `map/`: 맵 리소스
- `ui/`: UI 그룹

### STEP 3: 명세서 대조

- `작업명세서/SPEC_*.md`의 항목을 체크리스트처럼 하나씩 대조하기
- 아래 항목 누락 없이 반영하기
- Component Name
- Execution Space
- Properties
- Services
- Logic Architecture
- 주의사항

## 2. MSW 스크립트 문법 필수 규칙(mLua)

### 2-1. 스크립트 구조

- 스크립트를 `@Component`, `@Logic` 같은 Attribute로 시작하기

```lua
@Component
script MyComponent extends Component
	property number Speed = 5
end
```

### 2-2. Property 선언

- 체력/속도/데미지/쿨타임 같은 밸런스 수치를 반드시 `property`로 노출하기
- 밸런스 수치 하드코딩 금지하기
- `number`, `integer`, `string`, `boolean`, `Vector2`, `Vector3`, `Entity`, `Component`, `any`, `table(SyncTable 포함)` 타입을 명시적으로 사용하기

### 2-3. 라이프사이클 순서

- `OnInitialize`: Property 기본값/Sync 초기화
- `OnBeginPlay`: 데이터 로드/이벤트 바인딩
- `OnUpdate(dt)`: 경량 프레임 로직만 수행
- `OnEndPlay`: 타이머/이벤트 해제
- `OnDestroy`: 최종 정리
- `OnMapEnter`: 맵 진입 처리
- `OnMapLeave`: 맵 이탈 처리

### 2-4. 실행 공간(Execution Space)

- 데미지/스폰/권위 판정은 `[server only]`로 두기
- UI/이펙트/입력 표현은 `[client only]`로 두기
- 명세서 지정과 다르면 명세서 기준으로 수정하기
- 기본 원칙은 서버 권위로 유지하기

### 2-5. 동기화(Sync)

- Property Sync를 목적에 맞게 설정하기(`PropertySyncType.Sync`, `.None` 등)
- 공유 실시간 데이터는 SyncTable 우선 사용하기
- 통신은 `@EventSender`/`@EventHandler` 기반 이벤트 패턴 우선 적용하기
- 서버→클라이언트 단방향 원칙 유지하기

### 2-6. 주의사항

- coroutine 사용 금지하기
- `super` 대신 `__base` 사용하기
- `continue`, `+=`, `-=` 같은 mlua 확장 문법 필요 시 활용하기
- 디버깅 출력은 `print` 대신 `log()` 사용하기

## 3. 성능 최적화 원칙(뱀서라이크 필수)

### 3-1. OnUpdate 최소화

- OnUpdate에서 전체 엔티티 순회/대량 거리 계산 금지하기
- 불가피하면 프레임 스킵(N프레임마다 1회) 적용하기

### 3-2. 타이머/이벤트 기반 처리

- 주기 로직은 `_TimerService:SetTimer()` 사용하기
- 충돌은 `HandleTriggerEnterEvent(TriggerBody)` 기반으로 처리하기
- 매 프레임 수동 충돌 검사 구현 금지하기

### 3-3. 오브젝트 풀링

- 투사체/몬스터 등 대량 엔티티에 풀링 패턴 우선 적용하기
- Spawn/Destroy 반복 호출을 최소화하기

### 3-4. 데이터 주도 설계

- 무기/몬스터 스펙은 `_DataService:GetTable("TableName")`으로 로드하기
- 신규 콘텐츠 추가 시 코드 수정 없이 데이터만 추가 가능하게 설계하기

## 4. 코드 작성 스타일

### 4-1. 주석

- 모든 함수/메서드에 "왜 이렇게 하는지"를 설명하는 주석 달기
- 단순 동작 설명보다 설계 의도를 우선 기록하기
- 예: `-- 서버에서만 HP를 감소시켜 클라이언트 치트 방지`

### 4-2. 네이밍

- Component: `PascalCase + Component` (`GarlicWeaponComponent`)
- Property: `PascalCase` (`MaxHealth`, `MoveSpeed`)
- 지역 변수: `camelCase` (`currentTarget`)
- 함수: `PascalCase` (`ApplyDamage`)

### 4-3. 에러 방어

- nil 체크를 기본으로 적용하기
- Entity/Component 접근 전 `isValid` 확인하기
- 네트워크 지연을 고려해 서버 권위 로직 유지하기

## 5. 스크립트 간 연동 원칙

### 5-1. 컴포넌트 참조

- 참조는 `Entity:GetComponent("ComponentName")` 사용하기
- 강한 결합 대신 이벤트 통신을 우선 적용하기

### 5-2. 이벤트 통신 패턴

- 발행: `@EventSender`
- 수신: `@EventHandler`
- 새 컴포넌트 작성 시 기존 발행 이벤트를 먼저 확인하고 필요한 구독 추가하기

### 5-3. 서비스 활용

- `_UserService`: 유저 정보/입퇴장
- `_TimerService`: 타이머/주기 처리
- `_DataService`: CSV 데이터 로드
- `_EntityService`: 엔티티 생성/탐색
- `_SpawnService`: 몬스터/오브젝트 스폰
- `_CameraService`: 카메라 제어
- `_InputService`: 입력 처리
- `_SoundService`: 사운드 재생

### 5-4. 공유 데이터

- 레벨/경험치 같은 공유 상태는 중앙 관리자(GameManager/User)에서 관리하기
- 무기별 경험치도 WeaponManager 같은 중앙 컴포넌트에 집약하기

## 6. 문서화(필수)

코드 수정/추가마다 `기획서/4.부록/Code_Documentation.md`를 반드시 갱신하기. 파일이 없으면 생성하기.

필수 포맷:

```markdown
## [컴포넌트 이름]
- **파일명:** `경로/파일명`
- **수정일:** `YYYY-MM-DD`

### Properties
| 이름 | 타입 | 설명 |
|---|---|---|
| `Speed` | number | 이동 속도 (기본값: 100) |

### Functions
| 함수명 | 파라미터 | 리턴값 | 설명 |
|---|---|---|---|
| `OnBeginPlay` | void | void | 초기화 및 이벤트 연결 |
| `CalculateDamage` | `attacker`, `defender` | `number` | 데미지 공식 적용 |
```

## 7. 제출 전 체크리스트

- 기획서 관련 문서를 읽었는지 점검하기
- `기획서/4.부록/Code_Documentation.md` 갱신 여부 점검하기
- 명세서의 Property/Execution Space 누락 여부 점검하기
- 하드코딩된 밸런스 수치 존재 여부 점검하기
- OnUpdate 과부하 로직 존재 여부 점검하기
- 기존 스크립트 연동/호환성 점검하기
- nil/isValid 방어 코드 점검하기
- 의도 중심 주석 작성 여부 점검하기
- 서버/클라이언트 경계 분리 점검하기
- 네이밍 규칙 준수 여부 점검하기

## 8. 출력 포맷

코드 제출 시 아래 형식을 사용하기.

```markdown
---
**[구현 완료 보고]**
* **Component Name:** `구현한 컴포넌트명`
* **파일 경로:** `저장 위치`
* **연동 컴포넌트:** `참조/의존하는 기존 컴포넌트 목록`
* **기획서 참조:** `참고한 기획서 파일명`
* **구현 내용 요약:** `핵심 로직 1-2줄 설명`
* **주의 사항:** `동기화, 성능 관련 특이사항`
---
```

보고 뒤에 전체 codeblock(Target mLua) 코드를 코드 블록으로 이어서 제시하기.
