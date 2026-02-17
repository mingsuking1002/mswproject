# 작업명세서 (Task Specifications)

이 폴더는 **Antigravity(TD)**가 작성한 기술 명세서를 보관하는 곳입니다.
**Codex(프로그래머)**는 이 폴더의 `.md` 파일을 읽고 구현합니다.

## 워크플로우
```
PD(사용자) → Antigravity(TD) → 작업명세서/*.md → Codex(프로그래머) → 코드
```

## 파일 네이밍 규칙
`SPEC_[컴포넌트명].md`
예: `SPEC_GarlicWeaponComponent.md`

## 상태 표시
각 명세서 상단에 상태를 표시합니다:
- `🟡 대기중` — Antigravity가 작성 완료, Codex 구현 대기
- `🔵 진행중` — Codex가 구현 중
- `🟢 완료` — 구현 완료, 리뷰 대기
- `🔴 수정요청` — 리뷰 후 수정 필요
