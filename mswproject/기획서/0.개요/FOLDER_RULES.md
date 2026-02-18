# 📁 Project GR — 폴더 구조 규칙

## 전체 구조 (현업 기준)

```
mswproject/
│
├── 📄 기획서/                          ← 기획 문서 전용 (비개발자도 열람)
│   ├── 0.개요/                         ← 프로젝트 메인 기획서
│   │   ├── projectGR_main_proposal.md
│   │   └── FOLDER_RULES.md            ← (이 문서)
│   ├── 1.핵심 시스템/                   ← 8대 핵심 시스템 기획서
│   │   ├── [시스템] 기본 이동 기획 v.1.2.md
│   │   ├── [시스템] 체력(HP) 및 게임오버 시스템.md
│   │   ├── [시스템] 탑뷰 타겟팅 발사 시스템.md
│   │   └── ...
│   ├── 2.세부 시스템/                   ← 핵심이 아닌 보조 시스템
│   │   ├── [시스템] 상점 시스템.md      (예시)
│   │   ├── [시스템] 인벤토리.md         (예시)
│   │   └── ...
│   ├── 3.데이터 및 기술/                ← 데이터 설계 문서 (CSV 스키마 정의)
│   │   ├── [데이터] 무기 테이블 설계.md  (예시)
│   │   ├── [데이터] 몬스터 테이블 설계.md(예시)
│   │   └── [기술] 동기화 방식 정리.md   (예시)
│   ├── 4.부록/                         ← 코드 문서, 참고 자료
│   │   └── Code_Documentation.md
│   └── TEMPLATE_기획서양식.md
│
├── 📋 작업명세서/                       ← 구현 지침서 (AI/개발자용)
│   ├── SPEC_EngineSetup.md             ← 0번: 환경 구축
│   ├── SPEC_Movement.md                ← 시스템별 구현 명세
│   ├── SPEC_HPSystem.md
│   ├── SPEC_FireSystem.md
│   ├── ...
│   ├── TEMPLATE.md
│   └── README.md
│
├── 🎮 RootDesk/MyDesk/ProjectGR/       ← 코드 (mlua 스크립트)
│   ├── Components/                     ← 시스템 컴포넌트 코드
│   │   ├── Core/                       ← 기반 시스템 + 공통 유틸
│   │   ├── Combat/                     ← 전투 도메인
│   │   ├── Meta/                       ← 메타/세션 도메인
│   │   ├── UI/                         ← 표시 전용 컴포넌트
│   │   └── Bootstrap/                  ← 초기화/오케스트레이션
│   └── Common/                         ← 공용 유틸리티 스크립트(레거시/선택)
│
├── 📊 Data/                            ← 데이터 시트 (CSV) — MSW Maker 관리
│   ├── WeaponTable.csv                 (예시)
│   ├── MonsterTable.csv                (예시)
│   ├── StageTable.csv                  (예시)
│   └── ItemTable.csv                   (예시)
│
├── 🌍 Global/                          ← MSW 엔진 글로벌 설정
│   ├── DefaultPlayer.model
│   ├── CollisionGroupSet.collisiongroupset
│   ├── WorldConfig.config
│   └── common.gamelogic
│
├── 🗺️ map/                             ← 맵 데이터
│   └── map01.map
│
└── 🖼️ ui/                              ← UI 레이아웃
    ├── DefaultGroup.ui
    ├── PopupGroup.ui
    └── ToastGroup.ui
```

---

## 핵심 분리 원칙

| 구분 | 폴더 | 내용물 | 관리 주체 |
|---|---|---|---|
| **기획** | `기획서/` | 시스템 설계, 밸런스 의도, 컨셉 | 기획자 (사용자) |
| **명세** | `작업명세서/` | 구현 지침 (SPEC), 코드 작성 전 참고 | TD (Antigravity) |
| **코드** | `Components/<Domain>/` | mlua 스크립트 (실제 로직) | 개발 (Codex) |
| **데이터** | `Data/` | CSV 테이블 (밸런스 수치) | 기획자 + 개발 |
| **엔진** | `Global/`, `map/`, `ui/` | MSW Maker 자동 관리 파일 | Maker + 개발 |

---

## 1. 기획서 (`기획서/`) 규칙

### 네이밍
- **시스템 기획**: `[시스템] OOO.md`
- **데이터 설계**: `[데이터] OOO 테이블 설계.md`
- **기술 문서**: `[기술] OOO.md`
- **UI 기획**: `[UI] OOO.md`

### 폴더 배치 기준
| 번호 | 폴더 | 기준 |
|---|---|---|
| 0 | `0.개요/` | 프로젝트 전체 기획, 폴더 규칙 등 메타 문서 |
| 1 | `1.핵심 시스템/` | 게임의 뼈대가 되는 시스템 (이동, HP, 발사, 재장전, 무기교체, 태그, 타이머, 랭킹) |
| 2 | `2.세부 시스템/` | 핵심 위에 얹는 서브 시스템 (상점, 인벤토리, 패시브, 레벨업 등) |
| 3 | `3.데이터 및 기술/` | **데이터 테이블 스키마 설계** + 기술적 의사결정 기록 |
| 4 | `4.부록/` | 코드 문서, API 레퍼런스, 참고 자료 |

### "3.데이터 및 기술/" 활용법
이 폴더는 **CSV의 스키마(컬럼 정의)를 기획하는 문서**를 넣는 곳입니다.
실제 CSV 파일은 `Data/`에 들어갑니다.

```
3.데이터 및 기술/
├── [데이터] 무기 테이블 설계.md     ← "어떤 컬럼이 필요한가" 정의
├── [데이터] 몬스터 테이블 설계.md
├── [데이터] 스테이지 테이블 설계.md
├── [기술] 서버-클라이언트 동기화 방식.md
└── [기술] 충돌 그룹 설계.md
```

---

## 2. 데이터 시트 (`Data/`) 규칙

### 원칙
- **기획서에서 설계** → **Data/ 에서 CSV로 구현** → **코드에서 참조**
- CSV는 MSW Maker에서 직접 관리
- 코드(mlua)에서 `_DataService` 등으로 런타임 로딩

### 네이밍 규칙
```
{카테고리}{대상}Table.csv
```

### 예시 CSV 목록

| CSV 파일명 | 내용 | 관련 SPEC |
|---|---|---|
| `WeaponTable.csv` | 무기 4종 스탯 (데미지, 연사속도, 탄약수, 재장전시간, 스프레드) | SPEC_FireSystem, SPEC_ReloadSystem |
| `MonsterTable.csv` | 몬스터 종류별 HP, 공격력, 이동속도, 드롭 | (추후) |
| `StageTable.csv` | 스테이지별 난이도, 몬스터 구성, 클리어 조건 | SPEC_SpeedrunTimer |
| `CharacterTable.csv` | 캐릭터 A/B 기본 스탯, 아바타 RUID, 태그 스킬 ID | SPEC_TagSystem |
| `PassiveTable.csv` | 패시브 스킬 목록, 효과, 스택 방식 | (추후) |

### WeaponTable.csv 예시 구조
```csv
WeaponId,WeaponName,Damage,FireRate,MaxAmmo,ReloadTime,Spread,ProjectileSpeed,ProjectileModelId
1,기본권총,10,0.5,30,1.5,0,20,
2,산탄총,8,1.0,8,2.0,15,15,
3,저격소총,50,2.0,5,3.0,0,30,
4,기관총,5,0.1,100,4.0,5,25,
```

---

## 3. 코드 (`Components/`) 규칙

### 네이밍
```
{시스템명}Component.mlua
```
- 예외: 공용 유틸은 `Module` 접미사 사용 가능 (`GRUtilModule.mlua`)

### 폴더 구조
```
ProjectGR/
├── Components/                      ← 시스템 컴포넌트 루트
│   ├── Core/                        ← 전투 무관 기반
│   │   ├── GRUtilModule.mlua
│   │   ├── MovementComponent.mlua
│   │   └── CameraFollowComponent.mlua
│   ├── Combat/                      ← 전투 도메인
│   │   ├── HPSystemComponent.mlua
│   │   ├── FireSystemComponent.mlua
│   │   ├── ProjectileComponent.mlua
│   │   └── ReloadComponent.mlua
│   ├── Meta/                        ← 메타 시스템
│   │   ├── WeaponSwapComponent.mlua
│   │   ├── TagManagerComponent.mlua
│   │   ├── SpeedrunTimerComponent.mlua
│   │   └── RankingComponent.mlua
│   ├── UI/                          ← 순수 UI 표시 계층
│   │   ├── WeaponWheelUIComponent.mlua
│   │   ├── RankingUIComponent.mlua
│   │   └── HUDComponent.mlua
│   └── Bootstrap/                   ← 맵/로비 초기화
│       ├── Map01BootstrapComponent.mlua
│       └── LobbyFlowComponent.mlua
└── Common/                          ← 공용 유틸리티 (레거시/선택)
```

---

## 4. 문서 간 흐름 (파이프라인)

```
기획서 (WHY/WHAT)
  ↓
작업명세서 (WHAT → HOW 연결)
  ↓
코드 (HOW)  +  데이터 시트 (수치)
```

| 단계 | 산출물 | 예시 |
|---|---|---|
| 기획 | `기획서/1.핵심 시스템/[시스템] 무기 교체.md` | "F키로 시간정지, 4슬롯 방사형 메뉴" |
| 데이터 설계 | `기획서/3.데이터 및 기술/[데이터] 무기 테이블 설계.md` | "컬럼: ID, 이름, 데미지, 연사속도..." |
| 명세 | `작업명세서/SPEC_WeaponSwap.md` | "Property, Execution Space, 로직 흐름" |
| 데이터 | `Data/WeaponTable.csv` | 실제 수치 입력 |
| 코드 | `Components/Meta/WeaponSwapComponent.mlua` | mlua 구현 |
| 기록 | `기획서/4.부록/Code_Documentation.md` | 코드 변경 이력 |

---

## 5. 요약: 뭘 어디에?

| 이것은... | 여기에 넣는다 |
|---|---|
| "왜 이 시스템이 필요한가" | `기획서/1~2.시스템/` |
| "테이블에 어떤 컬럼이 필요한가" | `기획서/3.데이터 및 기술/` |
| "코드를 어떻게 짜야 하는가" | `작업명세서/SPEC_*.md` |
| "실제 밸런스 수치" | `Data/*.csv` |
| "실제 로직 코드" | `Components/*/*.mlua` |
| "이 코드가 뭐하는 건지 기록" | `기획서/4.부록/Code_Documentation.md` |
