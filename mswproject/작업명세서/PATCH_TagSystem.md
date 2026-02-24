# 🟡 대기중
# PATCH_TagSystem — PlayerbleData 연동 + 태그 스킬 호출

> 기존 `SPEC_TagSystem.md` (🟢 완료)에 대한 **패치 문서**

## 변경 요약

| 항목 | 기존 | 변경 |
|---|---|---|
| 데이터 스왑 | 내부 변수 백업/복원 | `CharacterDataInitComponent.ApplyCharacterData(charId)` 호출 |
| 외형 변경 | `AvatarRendererComponent` | `CharacterDataInitComponent`가 스프라이트 교체 |
| 태그 스킬 | 미정의 | 태그 완료 후 `TagSkillComponent.ActivateTagSkill(charId)` 호출 |
| 장전 쿨타임 | 명시 없음 | **공유(백그라운드)** 명시 — 비활성 캐릭터 장전 타이머 계속 진행 |

## 상세 변경

### TagManagerComponent 수정 사항

1. **태그 실행 흐름 변경**
   ```
   ExecuteTag [Server Only]:
     현재 캐릭터 데이터 백업 (HP, 탄창4슬롯, 장전상태)
     대상 charId = (CurrentCharIndex == 1) ? "player_b" : "player_a"
     CharacterDataInitComponent:ApplyCharacterData(대상charId)
     백업된 HP/탄창 복원
     무적 적용
     쿨타임 시작
     TagSkillComponent:ActivateTagSkill(대상charId)  ← 추가
   ```

2. **장전 쿨타임 공유**
   - 비활성 캐릭터의 `ReloadComponent` 타이머는 백그라운드에서 계속 진행
   - 태그 복귀 시 남은 쿨타임이 0이면 즉시 사격 가능

3. **유지 항목**
   - `TagCooldown`, `IsTagReady`, `InvincibleTime`, `IsTagLocked` → 그대로
   - 사망 시 자동 태그 없음 → 그대로
   - 위치/각도 계승 → 그대로

## Codex 체크리스트

- [ ] `CharacterDataInitComponent.ApplyCharacterData` 연동
- [ ] `TagSkillComponent.ActivateTagSkill` 호출 추가
- [ ] 장전 쿨타임 백그라운드 진행 보장
- [ ] `Code_Documentation.md` 업데이트

---

| **작성자** | Antigravity (TD) | **상태** | 🟡 대기중 |
|---|---|---|---|
