# 🟢 완료
# SPEC_DefaultGroupUILoadFix — DefaultGroup.ui 메이커 미노출 복구

## 0. 상태 이력

- `2026-02-26` `🟡 대기중` 접수
- `2026-02-26` `🔵 진행중` 분석/복구 시작
- `2026-02-26` `🟢 완료` JSON 정합 복구 + 문서 반영 완료

---

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `DefaultGroup` (UI Resource) |
| **대상 파일** | `ui/DefaultGroup.ui` |
| **Execution Space** | Maker UI Resource Loader (편집기 로딩 단계) |
| **기능 요약** | `DefaultGroup.ui` 파싱 실패로 메이커에서 UI 그룹이 보이지 않는 문제 복구 |
| **기획서/연관 문서** | `작업명세서/SPEC_LobbyUIFix.md`, `기획서/4.부록/Code_Documentation.md` |

---

## 2. 명세 체크(필수 항목 대조)

| 항목 | 반영 내용 |
|---|---|
| **Component Name** | `DefaultGroup` |
| **Execution Space** | Maker 리소스 로딩 시점 |
| **Properties** | 해당 없음 (UI 리소스 텍스트 데이터 수정) |
| **Services** | 해당 없음 |
| **Logic Architecture** | 해당 없음 (JSON 정합 복구 작업) |
| **주의사항** | JSON 문자열(`Text`)은 반드시 닫는 따옴표 포함 |

---

## 3. 원인 분석

`ui/DefaultGroup.ui` 내부 `TextComponent.Text` 2개 항목에서 문자열 종료 따옴표(`"`)가 누락되어 JSON 전체 파싱이 실패했다.

- `ui/DefaultGroup.ui:7941`
  - 기존: `"Text": "?뚯븘媛湲?,`
  - 복구: `"Text": "BACK",`
- `ui/DefaultGroup.ui:9223`
  - 기존: `"Text": "?됰꽕??,`
  - 복구: `"Text": "PLAYER",`

이 상태에서는 Maker가 `DefaultGroup.ui`를 유효 리소스로 읽지 못해 그룹이 편집기에서 표시되지 않는다.

---

## 4. 반영 파일

| 파일 | 변경 내용 |
|---|---|
| `ui/DefaultGroup.ui` | 깨진 텍스트 문자열 2건 복구, JSON 파싱 정상화 |
| `기획서/4.부록/Code_Documentation.md` | 본 핫픽스 문서화 |

---

## 5. 검증 결과

- [x] `ConvertFrom-Json` 파싱 성공
- [x] 엔티티 개수 확인: `71`
- [x] 비정상 `Text` 라인(닫는 따옴표 누락) 재검사 시 `0건`

