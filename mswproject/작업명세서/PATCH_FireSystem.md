# 🔵 진행중
# PATCH_FireSystem — 무기 모델 회전 위임 + Muzzle 변경

> 기존 `SPEC_FireSystem.md` (🟢 완료)에 대한 **패치 문서**

## 변경 요약

| 항목 | 기존 | 변경 |
|---|---|---|
| 캐릭터 회전 | `FireSystemComponent`가 발사 방향으로 캐릭터 회전 | 회전 제거 → `WeaponModelComponent`에 위임 |
| Muzzle 위치 | `MuzzleOffset` Property (캐릭터 기준 오프셋) | `WeaponModelComponent.GetMuzzlePosition()` 호출 |
| 발사 방향 | 클릭 위치 - 캐릭터 위치 | 클릭 위치 - Muzzle 위치 (무기 끝 기준) |
| `BasePlayerAtk` | 없음 (하드코딩) | `CharacterDataInitComponent`가 `PlayerbleData.player_atk` 주입 |

## 상세 변경

### FireSystemComponent 수정 사항

1. **캐릭터 회전 로직 제거**
   - `MovementComponent.FacingDirection` 참조 제거

2. **MuzzleOffset → GetMuzzlePosition()**
   ```
   -- 기존
   muzzlePos = playerPos + MuzzleOffset
   -- 변경
   muzzlePos = WeaponModelComponent:GetMuzzlePosition()
   ```

3. **발사 방향 = 무기 회전 방향**
   ```
   direction = WeaponModelComponent:GetAimDirection()
   ```

4. **유지 항목**
   - `CanFireServer()`, `StartFireCooldown()`, `CalculateFinalDamage()` → 그대로
   - `IsFireReady`, `CanAttack`, `FireCooldown` → 그대로
   - 투사체 생성/충돌/데미지 → 그대로

## Codex 체크리스트

- [x] 캐릭터 회전 로직 제거
- [x] MuzzleOffset → `WeaponModelComponent.GetMuzzlePosition()` 교체
- [x] 발사 방향 → `WeaponModelComponent.GetAimDirection()` 교체
- [x] `Code_Documentation.md` 업데이트

---

| **작성자** | Antigravity (TD) | **상태** | 🔵 진행중 |
|---|---|---|---|


