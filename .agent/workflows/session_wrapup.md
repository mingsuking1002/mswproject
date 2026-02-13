---
description: 코딩 세션 마무리 시 실행하는 체크리스트 (바이브 코딩 결과 보존)
---

# 🏁 세션 마무리 워크플로우

코딩 세션이 끝날 때마다 이 워크플로우를 실행하여 작업 내용이 안전하게 보존되도록 합니다.

## 1단계: 오늘의 작업 요약 저장
AI에게 다음과 같이 요청하세요:
> "오늘 작업한 내용을 brain_summary.md에 요약해줘"

이렇게 하면 오늘의 바이브 코딩 결과가 Brain에 기록되어, 다음 세션이나 다른 AI가 즉시 이어받을 수 있습니다.

## 2단계: 데이터 시트 갱신 확인
오늘 추가하거나 수정한 데이터가 있다면:
- `DATA_SCHEMA.md`에 변경 사항이 반영되었는지 확인
- 새 데이터 시트가 있으면 스키마를 추가

## 3단계: 프로젝트 구조 갱신 확인
오늘 새 모듈이나 폴더를 만들었다면:
- `PROJECT_STRUCTURE.md`의 폴더 구조와 모듈 테이블을 업데이트

## 4단계: AI 맥락 내보내기
// turbo
```powershell
.\_scripts\export_context.ps1
```
최신 맥락을 `AI_CONTEXT_EXPORT.md`로 추출합니다.

## 5단계: Git 동기화 및 커밋
// turbo
```powershell
.\_scripts\sync_ai.ps1
```
AI 기억을 리포지토리에 백업합니다.

그 후 변경 사항을 커밋하세요:
```powershell
git add -A
git commit -m "session: [오늘 작업 한 줄 요약]"
```
