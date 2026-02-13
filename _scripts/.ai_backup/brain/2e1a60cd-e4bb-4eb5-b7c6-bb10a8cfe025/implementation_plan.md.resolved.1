# 구현 계획 - AI Brain & 프로젝트 통합 Git 관리

이 계획은 사용자의 프로젝트 코드("바이브 코딩 스크립트")와 AI의 기억(Brain, Knowledge, Rules)을 하나의 Git 리포지토리에서 관리하기 위한 워크플로우를 설정합니다.

## 목표 설명
프로젝트 루트(`c:/Users/ksh00/Desktop/메랜 코딩용`)에 PowerShell 스크립트 세트를 생성하여 다음을 수행합니다:
1.  **백업 (Sync to Repo)**: 시스템 폴더(`Thinking`)에 있는 AI의 기억(`brain`, `knowledge`)을 프로젝트 폴더 내 백업 디렉토리로 복사합니다.
2.  **복원 (Restore from Repo)**: 새 기기나 초기화된 환경에서, 프로젝트 폴더의 백업 내용을 시스템 폴더로 복원합니다.
3.  **규칙 관리**: 프로젝트 루트에 있는 `custom_rules.md`를 수정하면, AI가 참조하는 시스템 폴더로 자동 동기화되도록 합니다.

## 사용자 검토 필요
> [!IMPORTANT]
> 이 설정은 `_scripts` 폴더 내의 PowerShell 스크립트(`sync_ai.ps1`, `restore_ai.ps1`)를 실행하여 시스템과 Git 리포지토리 간의 상태를 동기화합니다. Git에 커밋하기 전에는 반드시 `sync_ai.ps1`을 실행하여 최신 AI 기억을 백업해야 합니다.

## 변경 사항 제안

### 프로젝트 루트: `c:/Users/ksh00/Desktop/메랜 코딩용`

#### [NEW] `_scripts/sync_ai.ps1` (백업용)
- `C:\Users\ksh00\.gemini\antigravity\brain` -> `./.ai_backup/brain` 복사
- `C:\Users\ksh00\.gemini\antigravity\knowledge` -> `./.ai_backup/knowledge` 복사
- `./custom_rules.md` -> `C:\Users\ksh00\.gemini\antigravity\brain\custom_rules.md` 복사 (규칙 업데이트)

#### [NEW] `_scripts/restore_ai.ps1` (복원용)
- `./.ai_backup/brain` -> `C:\Users\ksh00\.gemini\antigravity\brain` 복사
- `./.ai_backup/knowledge` -> `C:\Users\ksh00\.gemini\antigravity\knowledge` 복사

#### [NEW] `custom_rules.md`
- 사용자가 정의할 커스텀 룰 파일. 리포지토리 루트에서 직접 편집합니다.

#### [NEW] `.gitignore`
- 시스템 파일 등 불필요한 파일은 무시하고, `.ai_backup` 폴더는 포함하도록 설정.

#### [NEW] `README.md`
- 동기화 스크립트 사용법 및 Git 워크플로우 문서화.

## 검증 계획

### 수동 검증
1.  **동기화 실행**: `_scripts/sync_ai.ps1`을 실행하고 `.ai_backup` 폴더가 생성되며, `custom_rules.md`가 시스템 폴더로 복사되는지 확인.
2.  **복원 실행**: (테스트) 백업 폴더에 임의의 파일을 만들고 `restore_ai.ps1` 실행 후 시스템 폴더에 해당 파일이 나타나는지 확인.
3.  **Git 상태 확인**: `git status`를 통해 백업된 파일들이 커밋 대기 상태가 되는지 확인.
