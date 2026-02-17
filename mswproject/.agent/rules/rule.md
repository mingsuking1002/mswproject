---
trigger: always_on
glob:
description: Project GR 코딩 작업에서 project-gr-codex-rules를 기본 규칙으로 항상 적용
---

Project GR 관련 코드 작업에서는 `$project-gr-codex-rules`를 기본 스킬로 간주하고 아래를 항상 준수한다.

1. 구현 전 `작업명세서/SPEC_*.md`를 먼저 확인하고 상태를 `🟡 대기중 -> 🔵 진행중 -> 🟢 완료`로 갱신한다.
2. 관련 `기획서/` 문서를 확인한 뒤 명세서 항목(Component Name, Execution Space, Properties, Services, Logic Architecture)을 대조한다.
3. MSW mlua 구현 시 서버 권위, 동기화(Sync/Event), 성능 최적화(OnUpdate 최소화/타이머 기반/풀링)를 우선한다.
4. 코드 변경 시 `기획서/4.부록/Code_Documentation.md`를 반드시 업데이트한다.
5. 최종 응답은 구현 완료 보고 형식과 전체 mlua 코드 블록을 포함한다.

스킬이 명시적으로 호출되지 않았더라도, Project GR 코드 요청이면 동일 규칙을 자동 적용한다.
