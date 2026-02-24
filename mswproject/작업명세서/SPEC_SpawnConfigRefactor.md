# 🔵 진행중
# SPEC_SpawnConfigRefactor — SpawnConfig 변경 계획

## 1. 개요

| 항목 | 내용 |
|---|---|
| **변경 대상** | `SpawnConfig.csv`, `MonsterSpawnComponent`, `SPEC_MonsterSpawn.md` |
| **변경 사유** | 패널티 시스템 도입으로 필드 몬스터 수 상한이 SpawnConfig가 아닌 PenaltySystemComponent에서 관리됨 |
| **기획서 참조** | `기획서/2.세부 시스템/[시스템] 패널티 시스템 v1.0.md` |

---

## 2. 삭제 대상

### 2-1. SpawnConfig.csv 컬럼 삭제

| 삭제 컬럼 | 기존 값 | 삭제 사유 |
|---|---|---|
| `MaxFieldMonsters` | `30` | 필드 최대 몬스터 수 제한을 패널티 시스템(70마리 임계)으로 대체. 스폰 시 상한 체크 자체를 제거하여 몬스터가 자유롭게 축적되도록 함 |
| `MaxRetryCount` | `10` | 유효 좌표 못 찾을 때 재시도 횟수 제한이 실질적으로 불필요. 도넛 좌표 생성은 항상 유효 범위 내이므로 실패 자체가 극히 드�묾. 무한 재시도 대신 단일 시도로 변경 |

**변경 후 SpawnConfig.csv:**
```csv
InnerRadius,OuterRadius,SpawnInterval,SpawnPerTick
500,800,5,3
```

---

## 3. MonsterSpawnComponent 코드 변경

### 3-1. `LoadSpawnConfigFromTable()` 변경

**삭제:**
```diff
- local maxFieldMonsters = self:GetRowInteger(row, "MaxFieldMonsters", -1)
- local maxRetryCount = self:GetRowInteger(row, "MaxRetryCount", -1)
- if ... or maxFieldMonsters <= 0 or maxRetryCount <= 0 then
+ if innerRadius < 0 or outerRadius < 0 or spawnInterval <= 0 or spawnPerTick <= 0 then
```

**config 테이블에서 제거:**
```diff
- config.MaxFieldMonsters = maxFieldMonsters
- config.MaxRetryCount = maxRetryCount
```

### 3-2. `SpawnTick()` 변경

**MaxFieldMonsters 상한 체크 제거 (2곳):**
```diff
- if self:GetSpawnedMonsterCount() >= config.MaxFieldMonsters then
-     return
- end
  -- (스폰 진행, 상한 체크 없음)
```

```diff
  for i = 1, config.SpawnPerTick do
      self:PruneSpawnedMonsters()
-     if self:GetSpawnedMonsterCount() >= config.MaxFieldMonsters then
-         break
-     end
```

**MaxRetryCount 재시도 루프 제거:**
```diff
- for retry = 1, config.MaxRetryCount do
      local spawnPosition = self:CalcDonutPosition()
-     if self:IsValidSpawnPosition(spawnPosition) == false then
-         continue
-     end
      local spawned = self:SpawnMonsterByRow(selectedRow, spawnPosition, false)
-     if spawned ~= nil and isvalid(spawned) == true then
-         break
-     end
- end
+ -- 단일 시도: 좌표 생성 → 유효성 검증 → 스폰
+ local spawnPosition = self:CalcDonutPosition()
+ if spawnPosition ~= nil and self:IsValidSpawnPosition(spawnPosition) == true then
+     self:SpawnMonsterByRow(selectedRow, spawnPosition, false)
+ end
```

---

## 4. SPEC_MonsterSpawn.md 수정 사항

| 섹션 | 변경 내용 |
|---|---|
| §5-3 SpawnTick | `MaxFieldMonsters`/`MaxRetryCount` 제약 언급 삭제 |
| §6-1 SpawnConfig | `MaxFieldMonsters`, `MaxRetryCount` 행 삭제 |
| §7 미정 영역 | 패널티 시스템과의 연동 언급 추가 |

---

## 5. 영향 범위 요약

| 파일 | 변경 유형 |
|---|---|
| `Data/SpawnConfig.csv` | 컬럼 2개 삭제 |
| `RootDesk/MyDesk/ProjectGR/Data/SpawnConfig.csv` | 동일 |
| `RootDesk/MyDesk/ProjectGR/Data/SpawnConfig.userdataset` | Maker에서 재import 필요 |
| `MonsterSpawnComponent.mlua` | 코드 4곳 수정 |
| `MonsterSpawnComponent.codeblock` | 동기화 |
| `SPEC_MonsterSpawn.md` | 문서 3개 섹션 수정 |
| `Code_Documentation.md` | MonsterSpawnComponent 섹션 갱신 |

---

## 6. 구현 체크리스트

- [x] `Data/SpawnConfig.csv` 컬럼 삭제
- [x] `RootDesk/MyDesk/ProjectGR/Data/SpawnConfig.csv` 동기화
- [x] `MonsterSpawnComponent.mlua` 코드 수정 (§3 참조)
- [x] `MonsterSpawnComponent.codeblock` 동기화
- [x] `SPEC_MonsterSpawn.md` 문서 업데이트
- [x] `Code_Documentation.md` 갱신
- [ ] Maker에서 SpawnConfig DataTable 재import

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-24 |
| **상태** | 🔵 진행중 |
