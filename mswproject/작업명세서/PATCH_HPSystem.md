# 🔵 진행중
# PATCH_HPSystem — PlayerbleData 초기값 연동

> 기존 `SPEC_HPSystem.md` (🟢 완료)에 대한 **패치 문서**

## 변경 요약

| 항목 | 기존 | 변경 |
|---|---|---|
| `MaxHP` 초기값 | `100` 고정 | `CharacterDataInitComponent`가 `PlayerbleData.player_hp` 주입 (A=100, B=90) |
| 캐릭터별 HP | 단일 관리 | 태그 시 `TagManagerComponent`가 개별 백업/복원 |

## 상세 변경

### HPSystemComponent 수정 사항

1. **초기값 주입**
   - `MaxHP`, `CurrentHP` 초기화를 자체적으로 하지 않음
   - `CharacterDataInitComponent.ApplyCharacterData`에서 `PlayerbleData.player_hp` 값 주입

2. **유지 항목**
   - 피격 판정, 무적, 사망 판정, UI 연출 → **모두 그대로**
   - `DamageReduction`, `IsInvincible`, `CriticalHPRatio`, `IsDead` → 그대로

## Codex 체크리스트

- [x] `MaxHP`/`CurrentHP` 초기화 하드코딩 제거
- [x] `CharacterDataInitComponent` 주입 수신 확인
- [x] `Code_Documentation.md` 업데이트

---

| **작성자** | Antigravity (TD) | **상태** | 🔵 진행중 |
|---|---|---|---|


