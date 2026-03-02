# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 |
|---|---|
| 2026-03-03 | 🟡 대기중 |

---

## 1. 개요

보스가 몬스터를 소환하지 않는 버그 수정. 2개 함수 누락이 원인.

**에러 로그:**
```
[LEA-2011] AttemptToCall : 'FindOrAddComponentSafe'을 호출할 수 없습니다. 'FindOrAddComponentSafe'은 nil입니다.
MonsterSpawnComponent.SpawnMonsterByRow
```

---

## 2. 수정 대상

### [MODIFY] MonsterSpawnComponent.mlua (`Components/Combat/`)

**Execution Space:** [Server Only]

#### 추가 함수 ①: `FindOrAddComponentSafe`
- `Map01BootstrapComponent.mlua` L964~L1004의 동일 함수를 **그대로 복사**
- 위치: `end` 직전, `ResolveComponentSafe` 함수 바로 위

```lua
method Component FindOrAddComponentSafe(Entity targetEntity, string typeName)
    if targetEntity == nil or isvalid(targetEntity) == false then
        return nil
    end

    local existing = self:ResolveComponentSafe(targetEntity, typeName, nil)
    if existing ~= nil then
        return existing
    end

    local prefixedName = typeName
    local plainName = typeName
    if string.sub(typeName, 1, 7) == "script." then
        plainName = string.sub(typeName, 8)
    else
        prefixedName = "script." .. typeName
    end

    local added = nil
    local addOk1, addResult1 = pcall(function()
        return targetEntity:AddComponent(prefixedName)
    end)
    if addOk1 == true then
        added = addResult1
    end

    if added == nil then
        local addOk2, addResult2 = pcall(function()
            return targetEntity:AddComponent(plainName)
        end)
        if addOk2 == true then
            added = addResult2
        end
    end

    return added
end
```

#### 추가 함수 ②: `GetMonsterRowByIdServer`
- `BossAIComponent.AttackTickServer`(L82)에서 호출하지만 현재 미정의
- `self._T.MonsterRows`를 순회하여 `id` 일치하는 row 반환

```lua
@ExecSpace("ServerOnly")
method UserDataRow GetMonsterRowByIdServer(string monsterId)
    if monsterId == nil or monsterId == "" then
        return nil
    end
    if self._T.MonsterRows == nil then
        return nil
    end

    for _, row in pairs(self._T.MonsterRows) do
        if row == nil then
            continue
        end
        local rowId = self:GetRowString(row, "id", "")
        if rowId == monsterId then
            return row
        end
    end
    return nil
end
```

---

## 3. 연동 컴포넌트

| 컴포넌트 | 호출 함수 |
|---|---|
| BossAIComponent L82 | `spawnComponent:GetMonsterRowByIdServer(self.SummonMonsterId)` |
| MonsterSpawnComponent L1596 | `self:FindOrAddComponentSafe(spawnedEntity, "BossAIComponent")` |

---

## 4. 구현 방식

mcp 이용해서 직접 workspace에서 작업

---

## 5. 주의/최적화 포인트

- `FindOrAddComponentSafe`는 `Map01BootstrapComponent`와 **동일 시그니처/로직** 유지
- `GetMonsterRowByIdServer`는 선형 탐색이지만 보스 소환 시 1회만 호출되므로 성능 무관
- `.codeblock` 파일도 반드시 동기화
