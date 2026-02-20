# 📋 Project GR — 로드맵 및 체크리스트

> **문서 목적**: GR 전체 주요 플로우 차트를 기준으로, 기획서·SPEC 현황을 매핑하고 개발 단계별 진행 상황을 추적합니다.

---

## 1. 플로우 차트 ↔ 개발 현황 매핑

아래 표는 **플로우 차트의 각 노드**를 기획서·SPEC과 대응시킨 것입니다.

| # | 플로우 노드 | 기획서 | SPEC | SPEC 상태 | 비고 |
|---|-----------|-------|------|----------|------|
| 1 | **게임 진입** | — | `SPEC_EngineSetup` | 🟢 완료 | Bootstrap, 월드 인스턴스 초기화 |
| 2 | **메인 화면** | — | `SPEC_Lobby` | 🟢 완료 | 로비 UI, DefaultPlayer 설정 |
| 3 | **랭킹 확인** | 랭킹 시스템 기획 | `SPEC_RankingSystem` | 🟢 완료 | 랭킹 화면 → 메인 복귀 |
| 4 | **랭킹 화면** | 랭킹 시스템 기획 | `SPEC_RankingSystem` | 🟢 완료 | — |
| 5 | **랭킹 기록** | 랭킹 시스템 기획 | `SPEC_RankingSystem` | 🟢 완료 | 게임 결과 → 랭킹 등록 |
| 6 | **게임 시작** | — | `SPEC_Lobby` | 🟢 완료 | 로비 → 인게임 전환 |
| 7 | **인게임 UI/HUD 진입** | — | `SPEC_LobbyUIFix` | 🟢 완료 | UI 레이아웃, HUD |
| 8 | **캐릭터 A ↔ B 선택** | 캐릭터 태그 시스템 | `SPEC_TagSystem` | 🟢 완료 | 2인 파티, Enable/스왑 |
| 9 | **기본 조작 탐색** | 기본 이동 기획 v1.2 | `SPEC_Movement` | 🟢 완료 | 탑뷰 이동 |
| 10 | **다른 몬스터 조우** | 몬스터 등장 시스템 v1.1 | `SPEC_MonsterSpawn` | 🟢 완료 | 도넛 영역 스폰, 시간 기반 웨이브 |
| 11 | **태그 시스템 발동** | 캐릭터 태그 시스템 | `SPEC_TagSystem` | 🟢 완료 | 태그 스킬 / 쿨타임 |
| 12 | **태그 스킬 발동** | 캐릭터 태그 시스템 | `SPEC_TagSystem` | 🟢 완료 | — |
| 13 | **무기 교체 (F키)** | 무기 교체 기획 | `SPEC_WeaponSwap` | 🟢 완료 | 시간 정지, UI 팝업 |
| 14 | **무기 종류 탐색** | 탑뷰 타겟팅 발사 시스템 | `SPEC_FireSystem` | 🟢 완료 | 마우스 에임, 발사 |
| 15 | **전투 순환** | 체력 시스템, 발사 시스템 | `SPEC_HPSystem`, `SPEC_FireSystem` | 🟢 완료 | HP, 데미지 |
| 16 | **재장전** | 잔탄 관리 및 재장전 시스템 | `SPEC_ReloadSystem` | 🟢 완료 | — |
| 17 | **피격 시 무기 경험치 획득** | (무기 성장 — 기획서 §5) | ❌ 미작성 | — | **향후 SPEC 필요** |
| 18 | **레벨 업 시스템** | (캐릭터 성장 — 기획서 §5) | ❌ 미작성 | — | **향후 SPEC 필요** |
| 19 | **무기 성장 시 UI 표현** | — | ❌ 미작성 | — | **향후 SPEC 필요** |
| 20 | **결정석** | — | ❌ 미작성 | — | **향후 기획·SPEC 필요** |
| 21 | **상점** | 상점 및 UI 시스템 v1.0 | `SPEC_ShopManager`, `SPEC_ShopUI` | 🟢 완료 | 시간 정지, 아이템 구매 |
| 22 | **골드 경제** | — | `SPEC_GoldSystem` | 🟢 완료 | 몬스터 드랍 → 골드 획득 |
| 23 | **드랍 아이템** | (몬스터 등장 시스템 v1.1) | ❌ 미작성 | — | MonsterData에 메타만 존재, **드랍 로직 SPEC 필요** |
| 24 | **몬스터 처치 보상 획득 추가** | — | ❌ 미작성 | — | 경험치/골드/아이템 분배 |
| 25 | **진행 및 웨이브 수집자 획득** | — | ❌ 미작성 | — | 웨이브 진행 추적 |
| 26 | **플레이어 무기 성장 및 전체 세팅 중지** | (무기 성장 — 기획서 §5) | ❌ 미작성 | — | 시간 정지 + 무기 선택 |
| 27 | **유저 성장 전략 수립** | — | — | — | 플레이어 선택 (비 코드) |
| 28 | **보스 전투** | 몬스터 등장 시스템 v1.1 | `SPEC_MonsterSpawn` | 🟢 완료 | BossStartTime, 보스 스폰 |
| 29 | **중간 보스 격파** | — | ❌ 미작성 | — | 중간 보스 보상, 스테이지 전환 |
| 30 | **스테이지 전환** | — | ❌ 미작성 | — | 맵 이동 / 난이도 상승 |
| 31 | **스피드런 타이머** | 스피드런 타이머 시스템 | `SPEC_SpeedrunTimer` | 🟢 완료 | 경과 시간, 스테이지 관리 |
| 32 | **최종 보스 격파** | — | ❌ 미작성 | — | 클리어 조건, 엔딩 |
| 33 | **게임 오버** | 체력 시스템 기획 | `SPEC_HPSystem` | 🟢 완료 | HP → 0 시 게임오버 |
| 34 | **모듈 리팩터링** | — | `SPEC_ModularRefactor` | 🟢 완료 | GRUtilModule, 코드 구조화 |
| 35 | **기석 사이클 종료 (게임 오버)** | — | — | — | 결과 화면 → 재도전/메인 |
| 36 | **결과 / 재도전** | — | ❌ 미작성 | — | 결과 화면, 재도전 루프 |

---

## 2. 개발 단계 (Phase) 정의

### Phase 0 — 엔진 셋업 & 기초 인프라 ✅ 완료
- [x] `SPEC_EngineSetup` — Bootstrap, DefaultPlayer, 월드 인스턴스
- [x] `SPEC_ModularRefactor` — GRUtilModule, 코드 구조화
- [x] `SPEC_Lobby` — 로비 플로우, 게임 시작
- [x] `SPEC_LobbyUIFix` — UI 레이아웃 수정

### Phase 1 — 핵심 전투 루프 ✅ 완료
- [x] `SPEC_Movement` — 탑뷰 이동
- [x] `SPEC_FireSystem` — 타겟팅, 발사
- [x] `SPEC_ReloadSystem` — 잔탄 관리, 재장전
- [x] `SPEC_HPSystem` — 체력, 게임오버
- [x] `SPEC_TagSystem` — 2인 태그, 교체 스킬
- [x] `SPEC_WeaponSwap` — 무기 교체, 시간 정지

### Phase 2 — 경제 & 상점 ✅ 완료
- [x] `SPEC_GoldSystem` — 골드 획득·소비
- [x] `SPEC_ShopManager` — 상점 로직
- [x] `SPEC_ShopUI` — 상점 UI

### Phase 3 — 몬스터 & 스테이지 ✅ 완료
- [x] `SPEC_MonsterSpawn` — 몬스터 스폰, 시간 웨이브, 보스
- [x] `SPEC_SpeedrunTimer` — 경과 시간, 스테이지 관리
- [x] `SPEC_RankingSystem` — 랭킹 등록·조회

### Phase 4 — 성장 & 보상 시스템 🔲 미착수
- [ ] `SPEC_WeaponGrowth` — 무기 경험치, 무기 레벨업, 성장 UI
- [ ] `SPEC_CharacterGrowth` — 플레이어 레벨, 공유 경험치, 레벨업 효과
- [ ] `SPEC_DropSystem` — 몬스터 드랍 분배, 아이템 획득

### Phase 5 — 스테이지 진행 & 보스 🔲 미착수
- [ ] `SPEC_StageProgression` — 스테이지 전환, 난이도 상승
- [ ] `SPEC_BossEncounter` — 중간 보스, 최종 보스 연출, 클리어 조건

### Phase 6 — 결과 & 재도전 🔲 미착수
- [ ] `SPEC_GameResult` — 결과 화면, 통계 표시
- [ ] `SPEC_ReplayLoop` — 재도전 루프, 메인 화면 복귀

### Phase 7 — 결정석 시스템 🔲 미착수 (기획 미확정)
- [ ] 기획서 작성 필요
- [ ] `SPEC_CrystalSystem` — 결정석 획득·사용

### Phase 8 — 폴리싱 & 최적화 🔲 미착수
- [ ] 패시브 스킬 시스템
- [ ] 이펙트 / 사운드 연출 강화
- [ ] 대규모 몬스터 풀링 최적화
- [ ] NavMesh 기반 스폰 좌표 검증
- [ ] UI/UX 개선 (튜토리얼 포함)

---

## 3. SPEC 상태 요약 대시보드

| 상태 | 개수 | SPEC 목록 |
|------|-----|----------|
| 🟢 완료 | 16 | EngineSetup, Movement, HPSystem, FireSystem, TagSystem, WeaponSwap, MonsterSpawn, SpeedrunTimer, ShopManager, ShopUI, Lobby, LobbyUIFix, GoldSystem, ReloadSystem, RankingSystem, ModularRefactor |
| 🟡 대기중 | 0 | — |
| 🔵 진행중 | 0 | — |
| 🔴 수정요청 | 0 | — |
| ❌ 미작성 | 7+ | WeaponGrowth, CharacterGrowth, DropSystem, StageProgression, BossEncounter, GameResult, ReplayLoop, CrystalSystem 등 |

---

## 4. 다음 작업 우선순위 (권장)

> [!IMPORTANT]
> Phase 4(성장 & 보상)는 플로우 차트에서 **전투 순환 → 보상 → 성장 → 재전투**의 핵심 루프를 완성하는 단계이므로 최우선 착수를 권장합니다.

1. **`SPEC_WeaponGrowth`** — 무기 경험치 시스템 (기획서 §5 "무기 성장" 기반)
2. **`SPEC_CharacterGrowth`** — 플레이어 레벨 시스템 (기획서 §5 "캐릭터 성장" 기반)
3. **`SPEC_DropSystem`** — 몬스터 드랍 로직 (MonsterData 메타 활용)
4. **`SPEC_StageProgression`** — 스테이지 전환 (기획서 중심 플로우 "조우→전투→성장→보상→스테이지 이동")
5. **`SPEC_BossEncounter`** — 보스 연출 (MonsterSpawn 보스 위에 연출·보상 레이어)
6. **`SPEC_GameResult`** / **`SPEC_ReplayLoop`** — 결과 화면 및 재도전

---

## 5. 기획서 ↔ SPEC 대응 갭 분석

| 기획서 | 대응 SPEC | 갭 |
|-------|----------|-----|
| 기본 이동 기획 v1.2 | `SPEC_Movement` | ✅ 없음 |
| 체력(HP) 및 게임오버 시스템 | `SPEC_HPSystem` | ✅ 없음 |
| 탑뷰 타겟팅 발사 시스템 | `SPEC_FireSystem` | ✅ 없음 |
| 캐릭터 태그 시스템 | `SPEC_TagSystem` | ✅ 없음 |
| 무기 교체 기획 | `SPEC_WeaponSwap` | ✅ 없음 |
| 몬스터 등장 시스템 v1.1 | `SPEC_MonsterSpawn` | ⚠️ 드랍 로직 미구현 |
| 스피드런 타이머 시스템 | `SPEC_SpeedrunTimer` | ✅ 없음 |
| 상점 및 UI 시스템 v1.0 | `SPEC_ShopManager` + `SPEC_ShopUI` | ✅ 없음 |
| 잔탄 관리 및 재장전 시스템 | `SPEC_ReloadSystem` | ✅ 없음 |
| 랭킹 시스템 기획 | `SPEC_RankingSystem` | ✅ 없음 |
| **무기 성장 (기획서 §5)** | — | ❌ SPEC 없음 |
| **캐릭터 성장 (기획서 §5)** | — | ❌ SPEC 없음 |
| **결정석 (플로우 차트)** | — | ❌ 기획서·SPEC 없음 |
| **결과 / 재도전 (플로우 차트)** | — | ❌ SPEC 없음 |

---

*최종 업데이트: 2026-02-19*
