# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 |
|---|---|
| 2026-03-03 | 🟡 대기중 |

---

## 1. 개요

Maker 린트 에러 4건 일괄 수정. 동작 영향 최소, Publish 차단 방지 목적.

---

## 2. 수정 사항

### ① [MODIFY] MovementComponent.mlua (`Components/Core/`)
**에러:** `LEA-1121` — `TryChangeStateSafely` 인수 부족 (L647, L657)

**수정:** `UpdateStateAnimation` 함수 내 2곳, 3번째 인수 `false` 추가

```diff
-- L647
- self:TryChangeStateSafely(stateComponent, deadState)
+ self:TryChangeStateSafely(stateComponent, deadState, false)

-- L657
- self:TryChangeStateSafely(stateComponent, targetState)
+ self:TryChangeStateSafely(stateComponent, targetState, false)
```

**추가 확인:** `TryChangeStateSafely`(L911) 시그니처가 `.codeblock`에서 4번째 매개변수 `targetUserId`를 포함하는 경우, `.mlua`의 시그니처도 동일하게 맞추거나, 불필요한 4번째 매개변수를 `.codeblock`에서 제거.

---

### ② [MODIFY] TagSkillComponent.mlua (`Components/Combat/`)
**에러:** `LEA-1120` — 반환타입 `table` 선언이나 실제 `string, number` 반환 (L233)

**수정:** 시그니처 반환타입 변경

```diff
-- L233
- method table ResolveBuffTypeAndValueServer(string skillId, table skillRow)
+ method any ResolveBuffTypeAndValueServer(string skillId, table skillRow)
```

---

### ③ [MODIFY] WeaponModelComponent.mlua (`Components/Core/`)
**에러:** `LEA-1121` — `LogSwapWarning` 5개 매개변수 중 4개만 전달 (L1184)

**수정:** 5번째 인수 추가

```diff
-- L1184
- self:LogSwapWarning("EnsureWeaponHolderChildServer failed. primary=", primaryModelId, ", fallback=", fallbackModelId)
+ self:LogSwapWarning("EnsureWeaponHolderChildServer failed. primary=", primaryModelId, ", fallback=", fallbackModelId, "")
```

---

### ④ [MODIFY] LobbyFlowComponent.mlua (`Components/Bootstrap/`)
**에러:** `LEA-4003` — 매개변수명 `targetUserId` 예약어 충돌 (L145)

**수정:** 매개변수명 변경 + 함수 내부 참조 전체 리네임

```diff
-- L145 시그니처
- method void BeginInGameStateServer(string targetUserId)
+ method void BeginInGameStateServer(string inGameUserId)
```

함수 내부 `targetUserId` → `inGameUserId` 일괄 변경 대상:
- L147, L156, L162, L164, L168 (함수 내부 참조)
- L134~140 (호출부의 로컬 변수명도 통일 권장)

---

## 3. 구현 방식

mcp 이용해서 직접 workspace에서 작업. `.codeblock` 파일도 반드시 동기화.

---

## 4. 주의 포인트

- 모든 수정은 **시그니처/호출부만 변경**, 로직 변경 없음
- `.mlua` 수정 후 반드시 `.codeblock` 동기화 확인
- 수정 후 Maker에서 린트 재검사하여 경고 해소 확인
