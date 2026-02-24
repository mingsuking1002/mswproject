# 🔵 진행중
# SPEC_PenaltySystem — 패널티 시스템 v1.0

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `PenaltySystemComponent` |
| **Execution Space** | `[Server Only]` (판정/피해), `[Client Only]` (경고 UI) |
| **기획서 참조** | `기획서/2.세부 시스템/[시스템] 패널티 시스템 v1.0.md` |
| **모듈화 레이어** | `Combat` |
| **기능 요약** | 필드 몬스터 60마리 이상 시 경고, 70마리 도달 시 일반 몬스터 30마리 즉시 비활성화 + 플레이어 최대 HP 70% 고정 피해 |

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 몬스터 수 감시 | `[server only]` | `_TimerService:SetTimerRepeat`로 주기적 체크 |
| 패널티 발동 판정 | `[server only]` | 70마리 도달 시 즉시 트리거 |
| 몬스터 강제 비활성화 | `[server only]` | 일반 몬스터 30마리 랜덤 선택 → `_EntityService:Destroy` |
| 플레이어 피해 적용 | `[server only]` | 무적 무시, MaxHP × 0.7 고정 피해 |
| 경고 UI 표시/제거 | `[client only]` | 서버 → 클라이언트 RPC로 상태 전달 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `WarningThreshold` | `integer` | `None` | `60` | 경고 UI 출력 기준 몬스터 수 |
| `PenaltyThreshold` | `integer` | `None` | `70` | 패널티 발동 기준 몬스터 수 |
| `CullCount` | `integer` | `None` | `30` | 강제 비활성화 몬스터 수 |
| `PenaltyDamageRatio` | `number` | `None` | `0.7` | 최대 HP 대비 고정 피해 비율 |
| `MonitorInterval` | `number` | `None` | `0.5` | 몬스터 수 감시 주기(초) |
| `IsWarningActive` | `boolean` | `Sync` | `false` | 경고 상태 여부 (클라이언트 UI 바인딩) |

---

## 4. Required MSW Services

- `_TimerService` — 주기적 몬스터 수 감시 타이머
- `_EntityService` — 몬스터 엔티티 Destroy

---

## 5. 로직 흐름

### 5-1. 초기화 (`OnBeginPlay`)
1. `_TimerService:SetTimerRepeat`으로 `MonitorInterval` 주기 감시 시작
2. `MonsterSpawnComponent` 참조 캐시

### 5-2. 감시 루프 (`CheckMonsterCount`)
```
count = MonsterSpawnComponent:GetSpawnedMonsterCount()
if count >= PenaltyThreshold then
    ExecutePenalty()
elseif count >= WarningThreshold then
    IsWarningActive = true  -- 경고 진입
else
    IsWarningActive = false -- 경고 해제
end
```
- 재발동 정책: 임계치 돌파당 1회 발동 후, `count < WarningThreshold` 구간에 재진입하면 다음 발동을 재무장

### 5-3. 패널티 실행 (`ExecutePenalty`) [Server Only]
1. **몬스터 비활성화**: `MonsterSpawnComponent._T.SpawnedMonsters`에서 일반 몬스터(`mon_type ≠ "boss"`, `mon_type ≠ "elite"`)만 필터 → 랜덤 셔플 → 최대 `CullCount`마리 선택  
2. 선택된 몬스터: 사망 애니메이션 생략, 보상 테이블 미호출, 처치 점수 미집계 → `_EntityService:Destroy` 즉시 제거  
3. `MonsterSpawnComponent:PruneSpawnedMonsters()` 호출하여 내부 캐시 정리  
4. **플레이어 피해**: `HPSystemComponent:ApplyPenaltyDamage(damage)` 호출  
   - `damage = math.floor(MaxHP * PenaltyDamageRatio)`  
   - **모든 무적 판정 무시** (기획 §6 예외)  
5. 경고 UI 해제: `IsWarningActive = false`

### 5-4. 패널티 피해 적용 방식

> [!IMPORTANT]
> 기존 `HPSystemComponent.ApplyDamage()`는 `IsInvincible == true`이면 피해를 무시합니다.
> 패널티 피해는 **무적을 관통**해야 하므로, `HPSystemComponent`에 새 메서드가 필요합니다.

**HPSystemComponent에 추가할 메서드:**

```
[Server Only] method void ApplyPenaltyDamage(integer rawDamage)
    -- 무적/DamageReduction 무시, 사망 판정 포함
    if self.IsDead == true then return end
    self.CurrentHP = math.max(self.CurrentHP - rawDamage, 0)
    self:EvaluateDeath()
    self:BroadcastHPState()
end
```

- `IsInvincible` 체크 없음, `DamageReduction` 적용 없음
- HP가 0 이하면 즉사 판정 (기획 §6: 음수 방지, 정확히 0으로 고정)

---

## 6. DataTable 설계

해당 없음 — 모든 수치는 Property 기반 (CSV 불필요)

---

## 7. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `MonsterSpawnComponent` | `GetSpawnedMonsterCount()` — 현재 필드 몬스터 수 조회 |
| `MonsterSpawnComponent` | `_T.SpawnedMonsters` / `_T.SpawnMetaByEntity` — 비활성화 대상 선택 시 meta 참조 |
| `MonsterSpawnComponent` | `PruneSpawnedMonsters()` — 비활성화 후 캐시 정리 |
| `HPSystemComponent` | `ApplyPenaltyDamage(damage)` — 무적 관통 고정 피해 (신규 메서드) |
| `HPSystemComponent` | `MaxHP` — 피해량 계산 기준 |
| `Map01BootstrapComponent` | 자동 부착 목록에 `PenaltySystemComponent` 추가 |
| `GRUtilModule` | 안전한 컴포넌트 조회 유틸 |

---

## 8. 경고 UI 연출 (Client Only)

| 요소 | 내용 |
|---|---|
| 중앙 상단 | 붉은 해골 아이콘 + `"WARNING: Monster Count Critical! {count}/{PenaltyThreshold}"` |
| 캐릭터 옆 | `"Too many enemies! Reduce their numbers!"` 말풍선 |
| 비활성화 시 | 사망 애니메이션 생략, 즉시 화면에서 제거 |
| SFX | 미정 |

> UI 엔티티 배치/경로는 Maker 수동 배치 후 Property로 참조

---

## 9. 주의/최적화 포인트

1. **감시 루프**: `_TimerService` 기반 0.5초 주기. OnUpdate 사용 금지
2. **비활성화 시 보상 차단**: `Destroy` 전 드랍/골드/킬카운트 로직 우회 확인 필요 — 현재 보상 시스템 미구현이므로 Phase 1에서는 단순 Destroy로 충분
3. **동기화**: `IsWarningActive`만 Sync — 클라이언트는 이 플래그 변화를 감지하여 UI 토글
4. **보스/엘리트 보호**: 비활성화 대상 필터에서 `boss`, `elite` 제외 필수

---

## 10. 구현 체크리스트

- [x] `PenaltySystemComponent.mlua` 신규 추가
- [x] `PenaltySystemComponent.codeblock(Target mLua)` 신규 추가
- [x] `HPSystemComponent.mlua`에 `ApplyPenaltyDamage()` 메서드 추가
- [x] `Map01BootstrapComponent` 자동 부착 목록에 `PenaltySystemComponent` 추가
- [ ] 경고 UI 엔티티 Maker 배치 + Property 경로 연결
- [x] `기획서/4.부록/Code_Documentation.md` 갱신

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🔵 진행중 |
