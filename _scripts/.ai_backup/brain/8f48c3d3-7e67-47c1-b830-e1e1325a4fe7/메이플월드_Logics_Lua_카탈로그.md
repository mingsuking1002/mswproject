# 메이플스토리 월드 Logics & Lua API 카탈로그

> 이 문서는 메이플스토리 월드의 Logics와 Lua 표준 라이브러리 API를 정리한 카탈로그입니다.

---

# Part 1: Logics (총 8개)

## 1. Logics 개요

**Logics**는 월드 제작에 필요한 **게임 로직 관련 기능**을 제공합니다.
- 트윈 애니메이션, UI 처리, 유틸리티 함수 등 포함
- 프로퍼티와 함수를 가집니다
- 모든 Logic은 기본 `Logic` 클래스를 상속합니다

---

## 2. Logics 분류표

| Logic | 설명 |
|-------|------|
| `Logic` | 로직 기본 클래스 (추상) |
| `DefaultUserEnterLeaveLogic` | 기본 유저 입장/퇴장 로직 |
| `MaplePreferencesLogic` | 메이플 환경설정 로직 |
| `MODTweenLogic` | MOD 트윈 애니메이션 로직 |
| `ScreenMessageLogic` | 화면 메시지 표시 로직 |
| `TweenLogic` | 트윈 애니메이션 로직 |
| `UILogic` | UI 처리 로직 |
| `UtilLogic` | 유틸리티 함수 모음 |

---

## 3. 주요 Logics 상세

### 3.1 TweenLogic / MODTweenLogic

트윈(Tween) 애니메이션을 생성하고 제어합니다.

```lua
-- 위치 트윈 예시
local tween = _TweenLogic:MoveTo(entity, targetPos, duration)
tween:Play()

-- 회전 트윈
_TweenLogic:RotateTo(entity, 360, 2.0)
```

---

### 3.2 UILogic

UI 요소 표시/숨김 및 제어 로직입니다.

```lua
-- UI 표시/숨김
_UILogic:Show(uiEntity)
_UILogic:Hide(uiEntity)
```

---

### 3.3 ScreenMessageLogic

화면에 메시지를 표시합니다.

```lua
-- 화면 메시지 표시
_ScreenMessageLogic:Show("레벨 업!")
```

---

### 3.4 UtilLogic

다양한 유틸리티 함수를 제공합니다.

```lua
-- 유틸리티 함수 예시
local distance = _UtilLogic:GetDistance(pos1, pos2)
```

---

### 3.5 DefaultUserEnterLeaveLogic

유저 입장/퇴장 시 기본 동작을 정의합니다.

---

### 3.6 MaplePreferencesLogic

게임 설정(소리, 그래픽 등)을 관리합니다.

---

# Part 2: Lua 표준 라이브러리 (7개)

> 메이플스토리 월드는 **Lua 5.3**을 스크립팅 언어로 사용합니다.
> 아래 라이브러리는 공식 API Reference에서 추출한 정확한 내용입니다.

---

## 4. global (전역 함수)

스크립트 전역에서 사용 가능한 기본 함수들입니다.

### 4.1 🔧 에러 처리

| 함수 | 설명 |
|------|------|
| `assert(v, message="assertion failed!")` | v가 false/nil이면 error 호출, 아니면 인수 반환 |
| `error(message, level=1)` | 함수 종료하고 에러 메시지 반환 |
| `pcall(f, args...)` | 보호 모드로 함수 호출 (에러 발생해도 전달 안됨) |
| `xpcall(f, msgh, args...)` | pcall + 메시지 핸들러 설정 가능 |

### 4.2 🔄 반복/순회

| 함수 | 설명 |
|------|------|
| `pairs(t)` | 테이블 전체 키-값 순회 |
| `ipairs(t)` | 배열 부분 순차 순회 (1부터) |
| `next(table, index=nil)` | 테이블의 다음 키와 요소 반환 |

### 4.3 🔀 타입 변환

| 함수 | 설명 |
|------|------|
| `type(v)` | v의 타입을 문자열로 반환 |
| `tostring(v)` | v를 문자열로 변환 |
| `tonumber(e, base=10)` | e를 숫자로 변환 (진법 지정 가능) |

### 4.4 ⚙️ 메타테이블

| 함수 | 설명 |
|------|------|
| `getmetatable(object)` | 객체의 메타테이블 반환 |
| `setmetatable(table, metatable)` | 테이블의 메타테이블 설정 |
| `rawget(table, index)` | __index 없이 값 가져오기 |
| `rawset(table, index, value)` | __newindex 없이 값 설정 |
| `rawequal(v1, v2)` | __eq 없이 동등 비교 |
| `rawlen(v)` | __len 없이 길이 반환 |

### 4.5 🎮 메이플월드 전용 전역 함수

| 함수 | 설명 |
|------|------|
| `wait(seconds)` | seconds 동안 스크립트 실행 중단 |
| `isvalid(object)` | 객체 유효성 확인 (nil, Entity/Component 삭제 여부) |
| `log(args...)` | **정보 로그 출력 (권장)** |
| `log_warning(args...)` | 경고 로그 출력 |
| `log_error(args...)` | 오류 로그 출력 |
| `enum(table)` | 테이블의 키-값 교환 후 반환 |

> **⚠️ 주의**: `print()` 대신 **`log()`** 함수를 사용하세요!

### 4.6 기타

| 함수 | 설명 |
|------|------|
| `select(index, args...)` | index번째 이후 인수들 반환 (index="#"이면 개수) |
| `collectgarbage(opt="collect", arg=nil)` | Garbage Collector 인터페이스 |

```lua
-- 예제: 안전한 함수 호출
local success, result = pcall(function()
    return dangerousFunction()
end)

if success then
    log("결과: " .. tostring(result))
else
    log_error("에러 발생: " .. result)
end

-- 메이플월드 전용: 대기
wait(2)  -- 2초 대기

-- 유효성 검사
if isvalid(self.Entity) then
    log("엔티티가 유효합니다")
end
```

---

## 5. math 라이브러리

수학 연산을 위한 라이브러리입니다.

### 5.1 📊 속성 (Properties)

| 속성 | 타입 | 설명 |
|------|------|------|
| `math.pi` | number | π 값 (3.14159...) |
| `math.huge` | number | 가장 큰 실수 값 |
| `math.mininteger` | integer | 가장 작은 정수 |
| `math.maxinteger` | integer | 가장 큰 정수 |

### 5.2 🔢 기본 연산

| 함수 | 설명 |
|------|------|
| `math.abs(x)` | 절대값 |
| `math.ceil(x)` | 올림 (x보다 크거나 같은 가장 작은 정수) |
| `math.floor(x)` | 내림 (x보다 작거나 같은 가장 큰 정수) |
| `math.sqrt(x)` | 제곱근 |
| `math.exp(x)` | e^x (e = 2.71828...) |
| `math.log(x, base=e)` | 로그 (기본 자연로그) |
| `math.log10(x)` | 상용로그 (밑=10) |
| `math.pow(x, y)` | x^y 거듭제곱 |
| `math.fmod(x, y)` | 나머지 연산 |
| `math.modf(x)` | 정수부와 소수부 분리 반환 |

### 5.3 📐 삼각함수

| 함수 | 설명 |
|------|------|
| `math.sin(x)` | 사인 (라디안) |
| `math.cos(x)` | 코사인 (라디안) |
| `math.tan(x)` | 탄젠트 (라디안) |
| `math.asin(x)` | 아크사인 |
| `math.acos(x)` | 아크코사인 |
| `math.atan(y, x=1)` | 아크탄젠트 (사분면 판정 포함) |
| `math.sinh(x)` | 쌍곡선 사인 |
| `math.cosh(x)` | 쌍곡선 코사인 |
| `math.tanh(x)` | 쌍곡선 탄젠트 |
| `math.deg(x)` | 라디안 → 도 변환 |
| `math.rad(x)` | 도 → 라디안 변환 |

### 5.4 🎲 난수

| 함수 | 설명 |
|------|------|
| `math.random()` | [0, 1) 범위 난수 실수 |
| `math.random(n)` | [1, n] 범위 난수 정수 |
| `math.random(m, n)` | [m, n] 범위 난수 정수 |
| `math.randomseed(x)` | 난수 시드 설정 (같은 시드 = 같은 수열) |

### 5.5 📏 비교/범위

| 함수 | 설명 |
|------|------|
| `math.min(x, args...)` | 가장 작은 값 반환 |
| `math.max(x, args...)` | 가장 큰 값 반환 |
| `math.clamp(value, min, max)` | **[min, max] 범위로 값 제한** |
| `math.sign(value)` | **값의 부호 반환 (-1, 0, 1)** |
| `math.almostequal(x, y)` | **두 실수가 거의 같은지 확인** |
| `math.ult(m, n)` | 부호 없는 정수 비교 (m < n) |
| `math.tointeger(x)` | 정수로 변환 (불가능하면 nil) |
| `math.type(x)` | "integer", "float", 또는 nil 반환 |

### 5.6 🔬 고급 수학

| 함수 | 설명 |
|------|------|
| `math.frexp(x)` | x = m*2^e에서 m, e 반환 |
| `math.ldexp(x, e)` | x*2^e 반환 |

```lua
-- 예제: 범위 제한 (메이플월드 확장)
local hp = math.clamp(currentHP, 0, maxHP)

-- 부호 확인
local direction = math.sign(velocity.x)  -- -1, 0, 1

-- 실수 비교 (부동소수점 오차 고려)
if math.almostequal(a, b) then
    log("a와 b는 거의 같습니다")
end

-- 난수
local damage = math.random(10, 50)
```

---

## 6. string 라이브러리

문자열 처리 함수들입니다.

> **⚠️ 주의**: 인덱스와 길이는 **byte 단위**입니다. 한글 등 다국어 사용 시 utf8 라이브러리를 권장합니다.

### 6.1 📝 기본 함수

| 함수 | 설명 |
|------|------|
| `string.len(s)` / `s:len()` | 문자열 길이 (byte) |
| `string.upper(s)` / `s:upper()` | 대문자 변환 |
| `string.lower(s)` / `s:lower()` | 소문자 변환 |
| `string.reverse(s)` / `s:reverse()` | 문자열 뒤집기 |
| `string.sub(s, i, j=-1)` | i~j 부분 문자열 |
| `string.rep(s, n, sep="")` | s를 n번 반복 (sep로 구분) |

### 6.2 🔍 패턴 검색

| 함수 | 설명 |
|------|------|
| `string.find(s, pattern, init=1, plain=false)` | 첫 일치 위치 (시작, 끝 인덱스) 반환 |
| `string.match(s, pattern, init=1)` | 첫 일치 부분 문자열 반환 |
| `string.gmatch(s, pattern)` | 모든 일치를 순회하는 반복자 반환 |
| `string.gsub(s, pattern, repl, n)` | 패턴 치환 (치환된 문자열, 횟수 반환) |

### 6.3 🔧 포맷/변환

| 함수 | 설명 |
|------|------|
| `string.format(fmt, args...)` | 포맷 문자열 생성 |
| `string.byte(s, i=1, j=i)` | 문자 → 숫자 코드 |
| `string.char(args...)` | 숫자 코드 → 문자열 |
| `string.pack(fmt, args...)` | 바이너리 문자열 생성 |
| `string.unpack(fmt, s, pos=1)` | 바이너리 문자열 해석 |
| `string.packsize(fmt)` | pack 결과 크기 반환 |

### 6.4 🔄 비교

| 함수 | 설명 |
|------|------|
| `string.compare(s1, s2)` / `s:compare(s2)` | 비교 (0: 같음, <0: s1<s2, >0: s1>s2) |
| `string.equals(s1, s2)` / `s:equals(s2)` | 동일 여부 확인 |

```lua
-- 예제: 포맷팅
local msg = string.format("[%s] HP: %d/%d", playerName, currentHP, maxHP)

-- 패턴 치환
local clean = string.gsub(rawText, "%s+", " ")  -- 연속 공백을 단일 공백으로

-- 반복자 사용
for word in string.gmatch(sentence, "%w+") do
    log(word)
end
```

---

## 7. table 라이브러리

테이블(배열/딕셔너리) 조작 함수들입니다.

### 7.1 📋 기본 조작

| 함수 | 설명 |
|------|------|
| `table.insert(t, value)` | 테이블 끝에 값 추가 |
| `table.insert(t, pos, value)` | pos 위치에 값 삽입 |
| `table.remove(t, pos=#t)` | 값 제거 후 반환 |
| `table.sort(t, comp?)` | 테이블 정렬 (comp: 비교 함수) |
| `table.concat(t, sep="", i=1, j=#t)` | 요소들을 문자열로 결합 |
| `table.move(a1, f, e, t, a2=a1)` | a1[f..e] → a2[t..]로 이동 |

### 7.2 🔄 Pack/Unpack

| 함수 | 설명 |
|------|------|
| `table.pack(args...)` | 인수들을 테이블로 묶음 (n 필드 포함) |
| `table.unpack(t, i=1, j=#t)` | 테이블 요소들을 개별 값으로 반환 |

### 7.3 🎮 메이플월드 확장

| 함수 | 설명 |
|------|------|
| `table.keys(t)` | **테이블의 모든 키 목록 반환** |
| `table.values(t)` | **테이블의 모든 값 목록 반환** |
| `table.clear(t)` | **테이블 내용 전체 삭제 (nil 설정)** |
| `table.initialize(t1, t2)` | **t1을 t2의 요소로 초기화** |
| `table.create(size, value=nil)` | **지정 크기의 배열 생성 (값 초기화)** |

```lua
-- 기본 사용
local items = {"sword", "shield", "potion"}
table.insert(items, "bow")
table.remove(items, 2)  -- shield 제거

-- 정렬 (내림차순)
table.sort(items, function(a, b) return a > b end)

-- 메이플월드 확장
local keys = table.keys(playerData)
local values = table.values(playerData)

-- 빠른 배열 생성
local grid = table.create(100, 0)  -- 100개의 0으로 초기화
```

---

## 8. os 라이브러리

시스템 시간 관련 함수입니다.

| 함수 | 설명 |
|------|------|
| `os.time()` | 현재 시각 (정수) 반환 |
| `os.time(table)` | 테이블로 지정한 시간 반환 (year, month, day 필수) |
| `os.date(format?, time?)` | 날짜/시간을 문자열 또는 테이블로 반환 |
| `os.difftime(t2, t1)` | 두 시간의 차이 (초 단위) |
| `os.clock()` | 프로그램이 사용한 CPU 시간 (초, 근사값) |

```lua
-- 현재 시간
local now = os.time()

-- 포맷팅
local dateStr = os.date("%Y-%m-%d %H:%M:%S")
log("현재 시각: " .. dateStr)

-- 시간 차이 계산
local startTime = os.time()
-- ... 작업 수행 ...
local elapsed = os.difftime(os.time(), startTime)
log("소요 시간: " .. elapsed .. "초")
```

---

## 9. profiler 라이브러리

성능 프로파일링을 위한 라이브러리입니다.

| 함수 | 설명 |
|------|------|
| `profiler.beginscope(name)` | 사용자 지정 범위로 프로파일링 시작 |
| `profiler.endscope()` | 프로파일링 샘플 종료 |

```lua
-- 성능 측정
profiler.beginscope("HeavyCalculation")
-- 무거운 연산 수행
for i = 1, 10000 do
    -- ...
end
profiler.endscope()
```

---

## 10. utf8 라이브러리

UTF-8 문자열 처리를 위한 라이브러리입니다. 한글 등 다국어 처리에 필수!

### 10.1 속성

| 속성 | 설명 |
|------|------|
| `utf8.charpattern` | UTF-8 문자 하나에 매칭되는 패턴 |

### 10.2 함수

| 함수 | 설명 |
|------|------|
| `utf8.len(s, i=1, j=-1)` | UTF-8 문자 개수 반환 (무효하면 false + 위치) |
| `utf8.char(args...)` | 코드 포인트 → UTF-8 문자열 |
| `utf8.codepoint(s, i=1, j=i)` | UTF-8 문자 → 코드 포인트 반환 |
| `utf8.codes(s)` | 모든 문자 순회용 반복자 (위치, 코드포인트) |
| `utf8.offset(s, n, i=1)` | n번째 문자의 바이트 위치 반환 |

```lua
-- 한글 문자열 길이
local text = "안녕하세요"
log(string.len(text))  -- 15 (바이트)
log(utf8.len(text))    -- 5 (문자)

-- 각 문자 순회
for pos, code in utf8.codes(text) do
    log(string.format("위치: %d, 코드: %d, 문자: %s", 
        pos, code, utf8.char(code)))
end
```

---

## 11. 메이플월드 전용 전역 객체

| 전역 객체 | 설명 |
|----------|------|
| `self` | 현재 스크립트 인스턴스 |
| `self.Entity` | 현재 엔티티 객체 |
| `Vector2(x, y)` | 2D 벡터 생성자 |
| `Vector3(x, y, z)` | 3D 벡터 생성자 |
| `Color(r, g, b, a)` | 색상 생성자 |

---

## 12. 참고 링크

- [Lua 공식 API](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua)
- [global](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/global)
- [math](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/math)
- [string](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/string)
- [table](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/table)
- [os](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/os)
- [profiler](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/profiler)
- [utf8](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua/utf8)
- [Logics 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Logics)

