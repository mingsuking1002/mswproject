# 🟢 완료
# SPEC_EngineSetup — 엔진 사전 세팅 지침서

## 1. 개요

| 항목 | 내용 |
|---|---|
| **작업 순서** | **0번** — 시스템 SPEC 구현 전/중 병행 |
| **작업 목적** | 코드 런타임이 정상 동작하도록 기본 맵/모델/충돌/서비스 전제를 고정 |
| **작업 유형** | Codex(파일 정합) + 사용자(Maker GUI 검증) |
| **기획서 참조** | `기획서/` 전체 및 `작업명세서/SPEC_*.md` |
| **현재 기준 맵** | `map/games.map` (단일 canonical 맵) |

---

## 2. 현재 정합 확인 결과 (Codex 자동 확인)

| 항목 | 결과 | 근거 |
|---|---|---|
| `DefaultPlayer.model` 필수 컴포넌트 | ✅ | `Movement/Camera/HP/Fire/Reload/WeaponSwap/Tag/Speedrun/Ranking/LobbyFlow` 존재 확인 |
| `games.map` 투사체 템플릿 | ✅ | `/maps/games/GRProjectileTemplate` + `Transform/Projectile/Trigger` 확인 |
| `CollisionGroupSet` 그룹 | ✅ | `Player/Enemy/PlayerProjectile/EnemyProjectile/Terrain` 확인 |
| 코드-문서 정책 | ✅ | `self._T.GRUtil`, `games`, `UseMapSplit=false` 정책 반영 |

---

## 3. 작업 분류

| 구분 | 작업 | 담당 |
|---|---|---|
| 🤖 | 모델/맵/충돌 설정 파일 정합 유지 | Codex |
| 🤖 | SPEC 상태/체크리스트/백로그 정렬 | Codex |
| 👤 | 리소스 임포트(RUID), 맵 배치, 서비스 활성화 | 사용자(Maker GUI) |
| 👤 | 실제 플레이 검증 | 사용자(Maker Play) |

---

## 4. Codex 완료 체크리스트

- [x] `DefaultPlayer.model` 필수 컴포넌트 구성 확인
- [x] `games.map`의 `GRProjectileTemplate` 엔티티 구성 확인
- [x] `CollisionGroupSet` 핵심 그룹/매트릭스 항목 존재 확인
- [x] `작업명세서/SPEC_*.md` 상태 규칙(`🟢` + 백로그 분리) 정렬
- [x] `기획서/4.부록/Code_Documentation.md`와 정책 정합 유지

---

## 5. Maker 수동 백로그

- [ ] 총알 스프라이트/이펙트/사운드 리소스 임포트 및 Property RUID 연결
- [ ] `DefaultPlayer` 물리 설정 확인 (`GravityScale=0`, 회전 고정)
- [ ] 지형/벽 충돌체 배치(`Terrain` 그룹) 및 슬라이드 체감 확인
- [ ] `_LeaderBoardService`, `_DataStorageService` 활성화 상태 확인
- [ ] `games.map` Play에서 이동/발사/충돌/랭킹 시나리오 점검

---

## 6. 권장 검증 시나리오 (Maker)

1. `games.map` Play 진입 후 WASD 이동 및 카메라 추적 확인
2. 좌클릭 발사 시 투사체 생성/충돌/소멸 확인
3. `GRStartButton` 클릭 후 로비 UI 숨김 및 타이머/전투 UI 전환 확인
4. 런 종료 후 로비 UI 재표시 및 랭킹 갱신 확인

---

## 7. 주의 사항

- Maker가 열린 상태에서 파일 편집 시 충돌이 날 수 있으므로 파일 변경 전후 워크스페이스 새로고침을 권장한다.
- `UseMapSplit=false`가 기본 동작이며, 맵 미이동 상태 전환은 정상 케이스다.
- 수동 검증 항목은 본 SPEC의 완료 상태와 분리해 백로그로 관리한다.

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex + 사용자(Maker 수동) |
| **작성일** | 2026-02-18 |
| **상태** | 🟢 완료 |

