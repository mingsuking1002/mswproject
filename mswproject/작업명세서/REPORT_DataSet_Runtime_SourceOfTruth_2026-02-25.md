# Project GR DataSet 연동 기준 보고서 (2026-02-25)

## 1. 결론
- 인게임 런타임 데이터 소스는 `RootDesk/MyDesk/ProjectGR/Data/*.userdataset`에 등록된 DataSet(구글 스프레드시트 `syncDataSetWebUrl`)이다.
- `Data/v.2.0 GRDataTable - *.csv` 및 `Data/v.2.0 GRDataTable - PlayerbleData.csv`는 참고/검토용 자료로 취급한다.
- 코드 연동 검증 기준은 파일명이 아니라 테이블명(`WeaponData`, `PlayerbleData`, `ProjectileData`, `MonsterData` 등) 계약이다.

## 2. 런타임 로딩 구조
- 전투/성장 컴포넌트는 `_DataService:GetTable("<TableName>")`로 테이블을 조회한다.
- 각 테이블의 실제 데이터 원본 URL은 해당 `.userdataset`의 `ContentProto.Json.syncDataSetWebUrl`로 연결된다.
- 즉, 런타임 반영은 `userdataset 연결 상태 + 시트 publish 상태`에 의해 결정된다.

## 3. 테이블-컴포넌트 연동 맵 (핵심)
| TableName | 대표 userdataset | 주요 소비 컴포넌트 |
|---|---|---|
| `WeaponData` | `RootDesk/MyDesk/ProjectGR/Data/WeaponData.userdataset` | `WeaponSwapComponent`, `WeaponLevelUpComponent`, `WeaponModelComponent` |
| `WeaponLevelData` | `RootDesk/MyDesk/ProjectGR/Data/WeaponLevelData.userdataset` | `WeaponLevelUpComponent` |
| `PlayerbleData` | `RootDesk/MyDesk/ProjectGR/Data/PlayerbleData.userdataset` | `CharacterDataInitComponent`, `TagSkillComponent` |
| `ProjectileData` | `RootDesk/MyDesk/ProjectGR/Data/ProjectileData.userdataset` | `WeaponSwapComponent`, `FireSystemComponent`, `ProjectileComponent(배치 자동바인딩)` |
| `SummonData` | `RootDesk/MyDesk/ProjectGR/Data/SummonData.userdataset` | `WeaponSwapComponent`, `FireSystemComponent` |
| `MonsterData` | `RootDesk/MyDesk/ProjectGR/Data/MonsterData.userdataset` | `MonsterSpawnComponent(스폰/배치 자동바인딩)` |
| `ModeMonsterData` | `RootDesk/MyDesk/ProjectGR/Data/ModeMonsterData.userdataset` | `MonsterSpawnComponent(무한모드)` |
| `SpawnConfig` | `RootDesk/MyDesk/ProjectGR/Data/SpawnConfig.userdataset` | `MonsterSpawnComponent` |
| `SkillData` | `RootDesk/MyDesk/ProjectGR/Data/SkillData.userdataset` | `TagSkillComponent` |

## 4. 자동바인딩 적용 상태 (현재 코드 기준)
### 4.1 몬스터 배치 엔티티
- `MonsterSpawnComponent`가 맵의 배치 몬스터를 스캔해서 `MonsterData` 행과 자동 매칭한다.
- 우선순위:
1. `HPSystemComponent.MonsterDataId`
2. 엔티티 이름을 row id로 해석
3. 기본 fallback 행
- 결과: 배치 몬스터도 스폰 몬스터와 동일한 스탯/트리거/추적 세팅을 적용받는다.

### 4.2 발사체 배치 엔티티
- `ProjectileComponent`가 배치된 projectile 엔티티를 `ProjectileData`와 자동 바인딩한다.
- 우선순위:
1. `ProjectileComponent.ProjectileDataId`
2. 엔티티 이름 정규화 fallback
- 결과: 속도/타입/스플래시 등 핵심 전투값을 테이블에서 주입 가능하다.

## 5. 운영 규칙
- `Data/v.2.0 ...csv` 수정은 문서/검토 용도이며, 그것만으로 런타임 값은 바뀌지 않는다.
- 런타임 반영이 필요하면 구글 시트 원본을 수정하고 DataSet publish/sync 상태를 확인한다.
- 코드에서는 하위호환 파싱(`"", "-", "null", "nil"`)을 유지하여 시트 공백/표기 변형에 대응한다.

## 6. 점검 체크리스트
- [ ] Maker에서 해당 DataSet(`*.userdataset`)이 정상 연결/동기화 상태인가
- [ ] 시트 수정 후 publish URL이 유효하고 최신값이 반영되는가
- [ ] 컴포넌트 TableName 프로퍼티가 표준 이름과 일치하는가
- [ ] 배치 몬스터 `MonsterDataId`, 배치 발사체 `ProjectileDataId`가 의도대로 지정되었는가
- [ ] 런타임 로그에서 테이블 로드 실패/필수 컬럼 누락 경고가 없는가

## 7. 참고
- 본 문서는 “참고용 CSV와 런타임 DataSet”의 역할을 분리해 팀 내 혼선을 줄이기 위한 기준 문서다.
- 추후 테이블 스키마 변경 시, `userdataset` 이름 계약과 컴포넌트 파싱 규칙을 먼저 동기화해야 한다.
