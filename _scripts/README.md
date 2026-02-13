# AI Sync System Guide

이 프로젝트는 **Antigravity AI의 기억(Brain)**과 **사용자 코드**를 함께 Git으로 관리하는 시스템이 구축되어 있습니다.
이 시스템은 모든 AI 데이터를 텍스트 파일(Markdown)로 저장하므로, **GitHub Copilot, Cursor 등 다른 'Codex' AI 도구와도 완벽하게 연동**됩니다.

## 폴더 구조
- `_scripts/`: 동기화 스크립트 모음
- `.ai_backup/`: AI의 기억과 지식이 백업되는 곳 (Git에 포함됨)
- `custom_rules.md`: 사용자가 편집하는 AI 규칙 파일

## 사용 방법

### 1. 작업 전/후 (백업)
작업을 마치고 Git에 커밋하기 전에 반드시 아래 스크립트를 실행하세요.
```powershell
./_scripts/sync_ai.ps1
```
이 스크립트는:
1.  현재 AI의 기억을 `.ai_backup` 폴더로 복사합니다.
2.  `custom_rules.md`의 내용을 AI에게 적용합니다.

### 2. 새 기기에서 시작할 때 (복원)
새로운 PC에서 이 저장소를 Clone한 후, 처음 한 번 실행하세요.
```powershell
./_scripts/restore_ai.ps1
```
이 스크립트는 저장소에 있는 기억을 로컬 AI 시스템으로 복원합니다.

### 3. Brain을 Codex Skill로 변환하기
레포에 백업된 brain 문서를 Codex Skill 폴더(`skill/<skill-name>/`)로 변환하려면:
```powershell
./_scripts/brain_to_skill.ps1 -Force
```
Codex 전역 스킬 폴더(`%USERPROFILE%\.codex\skills`)로도 복사하려면:
```powershell
./_scripts/brain_to_skill.ps1 -InstallToCodex -Force
```

### 4. Codex Skill 백업/복원(다른 PC에서 그대로 사용)
레포의 `skill/` 폴더를 Git으로 동기화해두면, 다른 PC에서도 스킬을 바로 설치해서 사용할 수 있습니다.

#### 4-1) 복원(레포 → 내 PC Codex)
```powershell
./_scripts/restore_codex_skills.ps1 -Force
```

#### 4-2) 백업(내 PC Codex → 레포)
```powershell
./_scripts/sync_codex_skills.ps1 -Force
```

## Codex / Copilot 연동
`.ai_backup` 폴더 안에는 AI가 생성한 모든 문서와 기억이 Markdown 형태로 들어 있습니다.
VS Code나 Cursor에서 **폴더 전체를 열어두면**, Copilot이나 AI가 이 파일들을 읽고 프로젝트의 문맥(Context)을 이해하는 데 도움을 줍니다.
