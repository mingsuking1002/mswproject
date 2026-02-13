# 구현 계획: 스탯 저장 및 초기화 NPC (Mastery Proof)

이 프로젝트는 단순한 NPC 구현이 아닙니다. 우리가 학습한 **"MSW 엔진 마스터리"를 증명하는 기술적 시연(Tech Demo)**입니다.

## 1. 목표 (Goal)
*   **기능**: NPC와 대화하여 플레이어의 스탯(STR, DEX 등)을 올리고, 이를 서버 영구 저장소(DataStorage)에 안전하게 저장/초기화한다.
*   **기술적 목표**:
    1.  **최적화**: `DataStorage` 사용 시 **JSON 직렬화**를 통해 Credit 소모 최소화.
    2.  **네트워크**: `TargetUserSync` 패턴으로 불필요한 패킷 브로드캐스팅 방지.
    3.  **UI 연동**: 서버(NPC) -> 클라이언트(UI) 호출 시 안전한 실행 제어 (`CommandService` 활용).
    4.  **안정성**: 유저 퇴장 시 (`UserLeaveEvent`) 데이터 유실 방지 로직.

## 2. 사용자 리뷰 필요 사항 (User Review Required)
> [!IMPORTANT]
> **DataStorage 키 설계**:
> `UserDataStorage`를 사용할 예정입니다. 테스트를 위해 실제 저장이 이루어지므로, 기존에 동일한 로직을 테스트한 적이 있다면 키 충돌에 주의해야 합니다. (Key: `StatData_v1`)

## 3. 변경 사항 (Proposed Changes)

### Common (Model)
#### [NEW] [NpcStatManager](file:///model/NpcStatManager)
*   NPC 모델에 부착될 핵심 스크립트.
*   `ClientOnly`와 `ServerOnly` 로직을 명확히 분리.
*   **[Server]** `OnInteract()`: 플레이어와의 상호작용 시작.
*   **[Client]** `ShowDialog()`: UI 팝업 출력.

### UI System
#### [NEW] [UI_StatManager](file:///ui/UI_StatManager)
*   스탯 찍기/초기화 버튼이 있는 UI.
*   `DefaultGroup` 하위에 생성.
#### [NEW] [StatUIScript](file:///script/StatUIScript)
*   UI 버튼 이벤트 핸들링.
*   서버로 요청 시 `_UserService.LocalPlayer` 체크 필수 (보안).

### Server Logic (Data)
#### [NEW] [StatDataHandler](file:///logic/StatDataHandler)
*   **DataStorage 전담 로직**.
*   `UserEnterEvent`: 데이터 로드 (BatchGetAsync 권장).
*   `UserLeaveEvent`: 데이터 저장 (JSON 직렬화).
*   `SaveStat(userId, statTable)`: 외부에서 호출 가능한 저장 인터페이스.

## 4. 검증 계획 (Verification Plan)

### Automated Tests (Scenario)
1.  **저장 효율성 테스트**: 스탯을 100번 변경해도 `Save` 호출은 '퇴장 시' 또는 '중요 체크포인트'에서만 1번 일어나는지 로그 확인.
2.  **동기화 테스트**: 클라이언트 A가 NPC와 대화 중일 때, 클라이언트 B에게 불필요한 패킷이나 UI가 뜨지 않는지 (`TargetUserSync` 검증).

### Manual Verification
1.  Play 모드 진입.
2.  NPC에게 말 걸기 -> UI 오픈.
3.  STR 증가 -> 클라이언트 즉시 반영 확인.
4.  게임 종료 후 재접속 -> STR 수치 유지 확인 (DataStorage 동작).
