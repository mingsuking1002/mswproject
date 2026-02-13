# Antigravity Custom Rules
> **규칙 업데이트**: 2026-02-14

이 파일에 정의된 규칙은 이 프로젝트를 다루는 모든 Antigravity AI에게 **최우선**으로 적용됩니다.

## 1. 🌐 언어 및 커뮤니케이션 (Communication)
- **무조건 한국어 사용**: 코드 주석, 커밋 메시지, 대화 등 모든 아웃풋은 **한국어**로 작성한다. (단, 변수명이나 기술 용어는 원어 유지 가능)
- **친근하고 확실하게**: 사용자의 '바이브'를 존중하며, 불확실한 내용은 먼저 질문한다.

## 2. 🧠 기억 및 맥락 (Context & Memory)
- **"이전 대화 읽어/불러와" 요청 처리 규칙(필독)**:
  - 사용자가 "전 대화 읽어줘/불러와", "이전 대화", "대화 로그", "지난 대화" 등을 요청하면, 답변 전에 **반드시** `text/AI_CONTEXT_EXPORT*.md`를 먼저 찾고 읽는다. (기본: `text/AI_CONTEXT_EXPORT.md`)
  - `AI_CONTEXT_EXPORT*.md`가 여러 개면 `LastWriteTime`이 가장 최신인 파일을 우선한다.
  - `.pb` 같은 바이너리 대화 로그는 그대로는 내용을 확인할 수 없으므로, 가능한 경우 텍스트/마크다운으로 내보낸 `AI_CONTEXT_EXPORT`를 기준으로 판단한다. (없으면 `_scripts/export_context.ps1`로 생성 안내)
  - 답변에는 필요 시 "어떤 `AI_CONTEXT_EXPORT` 파일을 읽었는지"를 함께 명시한다.
- **세션 마무리**: 작업이 끝나면 항상 `/session_wrapup`을 제안하여 기억을 저장한다.

## 3. 🛠️ 프로젝트 구조 (Structure)
- **데이터 시트**: 데이터 구조 변경 시 `DATA_SCHEMA.md`를 반드시 먼저 확인하고 갱신한다.
- **모듈화**: `PROJECT_STRUCTURE.md`에 정의된 모듈 분류를 따르며, 무분별한 의존성 추가를 지양한다.
- **내보내기**: 모든 대화 맥락 내보내기 결과물은 `text/` 폴더에 저장한다.

## 4. 💻 코딩 스타일 (Coding Style)
- **MSW Lua**: 타입 명시(`string`, `number` 등)를 철저히 하고, 서버/클라이언트 실행 제어(`[server]`, `[client]`)를 명확히 한다.
- **Web (VN)**: Vanilla JS + CSS Glassmorphism 스타일을 지향한다.
