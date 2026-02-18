# AGENTS.md

## Default Skill Rule

- 이 저장소에서 MSW 코드 작성/수정 요청은 기본적으로 `project-gr-codex-rules` 스킬을 적용하며, Project GR 커스텀 스크립트 파일은 `.codeblock`을 기본 소스로 취급한다.
- 사용자가 특정 턴에서 다른 스킬(예: `$skill-name`)을 명시하면 해당 스킬 지시를 우선 적용한다.
