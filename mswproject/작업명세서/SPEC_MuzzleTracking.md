# 🟡 대기중

---
**[Codex용 작업 명세서]**

* **Component Name:** `WeaponModelComponent` 수정 (총구 위치 마우스 추적 보정)
* **Execution Space:** `[Server Only]` 및 `[공용 method]`
* **Properties:**
  - 변경 없음
* **Required MSW Services:**
  - 해당 없음
* **연동 컴포넌트:**
  - `FireSystemComponent`: `ResolveMuzzlePositionServer` → `GetMuzzlePosition` 호출부

---

## § 문제

`GetMuzzlePosition()`이 **서버 측 holder의 ZRotation**으로 forward 벡터를 계산.
그런데 핸들 회전은 `ApplyHolderRotationClient`(@ClientOnly)에서만 수행.
→ **서버의 ZRotation은 항상 0(초기값)** → 총구가 항상 오른쪽 고정 → 마우스를 안 따라감.

## § 해결

`GetMuzzlePosition`에 **optional 파라미터 `targetWorldPos`** 를 추가.
targetWorldPos가 넘어오면 holder ZRotation 대신 **(targetWorldPos - pivotPos) 방향**으로 forward를 재계산.

### 의사코드

```
method Vector2 GetMuzzlePosition(Vector2 targetWorldPos)
    -- pivotPos = 회전축 위치 (기존 로직 유지)
    
    if targetWorldPos ~= nil then
        -- 서버에서 호출 시: 마우스 좌표 기반 forward
        local direction = (targetWorldPos - pivotPos)
        if direction:SqrMagnitude() > 0 then
            forward = direction:Normalize()
        end
    else
        -- 클라이언트/기존: holder ZRotation 기반 forward (기존 로직 유지)
    end
    
    -- 이후 muzzlePos = pivotPos + forward * distance (기존 동일)
```

### 호출부 수정 (`FireSystemComponent`)

`ResolveMuzzlePositionServer`에서:
```
-- 기존:  weaponModel:GetMuzzlePosition()
-- 수정:  weaponModel:GetMuzzlePosition(targetWorldPosition)
```

`TryFireServer`에서 `ResolveMuzzlePositionServer`에 targetWorldPosition 파라미터 전달.

---

* **기획서 참조:** 핸들/무기 시스템 구조도
* **구현 방식:** mcp 이용해서 직접 workspace 에서 작업해줘야하는 방식
* **주의/최적화 포인트:**
  - `GetAimDirection`도 내부에서 `GetMuzzlePosition()`을 호출하므로 같이 수정 필요.
  - 기존 `GetMuzzlePosition()` 파라미터 없이 호출하는 곳(클라이언트)은 기존 동작 유지됨(nil 전달 시 ZRotation 사용).
