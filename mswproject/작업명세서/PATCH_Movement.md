# 🟡 대기중
# PATCH_Movement — 캐릭터 방향 판단 변경

> 기존 `SPEC_Movement.md` (🟢 완료)에 대한 **패치 문서**

## 변경 요약

| 항목 | 기존 | 변경 |
|---|---|---|
| 캐릭터 방향 | 이동 방향 기준 8방향 (`FacingDirection` 1~8) | 마우스 위치 기준 좌/우 2방향 |
| 방향 제어 주체 | `MovementComponent` | `WeaponModelComponent` (§4-3) |
| `MoveSpeed` 초기값 | `1.0` 하드코딩 | `CharacterDataInitComponent`가 `PlayerbleData.movespeed` 주입 |

## 상세 변경

### MovementComponent 수정 사항

1. **`FacingDirection` Property 제거** (또는 미사용)
   - 좌우 반전은 `WeaponModelComponent`가 마우스 기준으로 처리
   - 이동 방향과 바라보는 방향이 독립됨

2. **이동 로직 유지**
   - WASD 8방향 이동, 대각 정규화, 벽 슬라이드 → **그대로 유지**
   - `CanMove`, `SpeedMultiplier` → **그대로 유지**

3. **스프라이트 교체 제거**
   - 기존: 이동 방향 기반 스프라이트 교체
   - 변경: 좌우 반전만 (`WeaponModelComponent`가 `Player.ScaleX` 제어)

## Codex 체크리스트

- [ ] `FacingDirection` 기반 스프라이트 교체 로직 제거
- [ ] `MoveSpeed` 초기값 로직 제거 (CharacterDataInit이 주입)
- [ ] `Code_Documentation.md` 업데이트

---

| **작성자** | Antigravity (TD) | **상태** | 🟡 대기중 |
|---|---|---|---|
