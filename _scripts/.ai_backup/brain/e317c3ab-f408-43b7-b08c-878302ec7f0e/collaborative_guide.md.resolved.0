# 메이플스토리 월드 공동작업 환경 구축 가이드

이 문서는 메이플스토리 월드(MapleStory World) 개발 시 VS Code를 활용하여 효율적인 공동작업 환경을 구축하기 위한 체크리스트와 상세 가이드입니다. 제공된 정보와 공식 문서를 기반으로 작성되었습니다.

## 1. 환경 구축 체크리스트 (Checklist)

작업을 시작하기 전 다음 항목들을 확인하세요.

- [ ] **소프트웨어 설치**
    - [ ] [Visual Studio Code](https://code.visualstudio.com/) 최신 버전 설치
    - [ ] 메이플스토리 월드(Maker) 최신 버전 확인
- [ ] **VS Code 설정**
    - [ ] VS Code 확장 프로그램: `mLua` (by MapleStoryWorlds) 설치 및 활성화
- [ ] **메이플스토리 월드 프로젝트 설정**
    - [ ] Maker에서 `LocalWorkspace` 기능 활성화 (`Workspace` > `WorldConfig`)
    - [ ] Maker에서 `UseExtendedScriptFormat` 활성화
    - [ ] VS Code 연동 설정 완료 (`File` > `Setting` > `Create` > `VSCode`)
- [ ] **협업 규칙 확인**
    - [ ] 외부 에디터에서는 **스크립트(mLua)**와 **데이터(CSV)** 파일만 수정하기 (이외 파일 수정 시 동기화 오류 위험)
    - [ ] 공동 작업 시 그룹 리더(장)만 원격 워크스페이스 동기화(Sync to Remote) 수행

---

## 2. 상세 가이드 (Step-by-Step Guide)

### 2.1 VS Code 및 확장 프로그램 설치
VS Code에서 메이플스토리 월드 스크립트(Lua)를 편리하게 작성하기 위해 전용 확장 프로그램을 설치해야 합니다.

1.  **VS Code 실행**
2.  좌측 **Extensions (확장)** 탭 클릭 (단축키: `Ctrl+Shift+X`)
3.  검색창에 `mLua` 입력
4.  **mLua (Publisher: MapleStoryWorlds)** 선택 및 설치
5.  설치 완료 후 자동으로 활성화됩니다.
    *   *기능: 문법 강조, 자동 완성, 오류 진단, 글로벌 변수 선언 지원 등*

### 2.2 로컬 워크스페이스(Local Workspace) 연동
메이플스토리 월드 Maker의 데이터를 로컬 폴더로 내보내어 VS Code에서 편집할 수 있도록 설정합니다.

1.  **Local Workspace 활성화**
    *   Maker 실행 > 상단 메뉴 `Workspace` > `WorldConfig` > `LocalWorkspace` 체크
    *   저장할 로컬 폴더 경로를 지정합니다.
2.  **ExtendedScriptFormat 사용 설정**
    *   `Workspace` > `WorldConfig` > `UseExtendedScriptFormat` 체크
    *   *이 옵션을 켜야 외부 에디터에서 편집하기 쉬운 포맷으로 스크립트가 저장됩니다.*
3.  **VS Code 자동 연동 (Windows 전용)**
    *   Maker 상단 메뉴 `File` > `Setting` > `Create` > `VSCode` 클릭
    *   이 기능을 사용하면 `.vscode`, `launch.json` 등 필요한 설정 파일이 자동으로 생성되며 VS Code가 해당 폴더로 열립니다.
    *   *자동 연동이 안 될 경우:* VS Code에서 `File` > `Open Folder`를 선택하여 Local Workspace로 지정한 폴더를 직접 엽니다.

### 2.3 스크립트 작성 및 수정
VS Code에서 코드를 작성할 때 다음 사항을 유의하세요.

*   **글로벌 변수:** mLua 확장은 글로벌 변수 선언을 지원하며, Maker의 기본 에디터와 달리 불필요한 경고를 표시하지 않습니다.
*   **수정 가능 파일:** `.lua` (스크립트) 및 `.csv` (데이터셋) 파일 위주로 수정하는 것을 권장합니다.
*   **주의:** 맵 엔티티, 컴포넌트 구조 등 복잡한 데이터 파일은 Maker에서 직접 수정하는 것이 안전합니다.
*   **디버깅:** 현재 VS Code 내 디버깅 기능은 지원하지 않습니다 (추후 지원 예정). 테스트는 Maker와 동기화 후 Maker 내에서 진행하세요.

### 2.4 동기화 (Synchronization)
VS Code에서 수정한 내용을 Maker에 반영하거나, Maker의 변경 사항을 로컬로 가져오는 방법입니다.

#### 로컬 수정 사항 → Maker로 불러오기
VS Code에서 저장(`Ctrl+S`) 후 Maker로 돌아와 다음 중 하나를 수행합니다:
1.  **Refresh (새로고침):** Workspace나 Hierarchy 패널 우클릭 > `Refresh`
    *   변경된 파일만 빠르게 갱신합니다.
2.  **Reimport (재임포트):** 특정 스크립트나 데이터셋 우클릭 > `Reimport`
3.  **ReimportAll (전체 재임포트):** Workspace 패널 우클릭 > `ReimportAll`
    *   모든 파일을 다시 로드합니다. 충돌이나 로드 오류 발생 시 유용합니다.

#### Maker → 원격 서버(Remote) 동기화
*   **Sync to Remote Workspace:** `File` > `Sync to Remote Workspace`
    *   로컬에서의 작업 내용을 최종적으로 팀원들과 공유되는 서버에 업로드합니다.
    *   **중요:** 이 작업은 **그룹 리더(Master)**만 수행 가능합니다. 팀원들은 작업 전 항상 최신 버전을 받아야 충돌을 방지할 수 있습니다.

### 2.5 공동 제작 팁
*   **형상 관리:** Git 등을 사용할 경우 `.vscode` 설정 파일이나 백업(backup) 폴더는 `.gitignore`에 포함하여 불필요한 파일 공유를 막는 것이 좋습니다.
*   **소통:** 리모트 동기화(Sync) 전에는 팀원들에게 알리고, 작업이 겹치지 않도록 파트를 명확히 나누는 것이 중요합니다.
