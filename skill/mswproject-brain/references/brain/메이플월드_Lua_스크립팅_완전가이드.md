# 메이플스토리 월드 Lua 스크립팅 완전 가이드

> 이 문서는 메이플스토리 월드의 Lua 스크립팅 문법과 MSW 전용 기능을 상세히 정리한 가이드입니다.

---

## 1. Lua 기본 정보

메이플스토리 월드는 **Lua 5.3**을 기본 스크립트 언어로 사용합니다.
- 공식 문서: [Lua 5.3 Manual](https://www.lua.org/manual/5.3/)
- 일부 기능은 Lua 5.3 표준과 **상이할 수 있음** (MSW 전용 수정)

### 1.1 Lua 언어 특징
- **절차적 프로그래밍** 지원
- **객체 지향 프로그래밍** 지원
- **함수형 프로그래밍** 지원
- 빠른 실행 속도와 이식성

---

## 2. 핵심 개념: self와 Entity

### 2.1 `self` 키워드

`self`는 **"이 컴포넌트 안에서"**라는 의미로, 스크립트가 부착된 **컴포넌트 자체**를 참조합니다.

#### 프로퍼티 접근 (마침표 `.` 사용)
```lua
-- 프로퍼티 읽기
log(self.testP)

-- 프로퍼티 변경
self.testP = self.testP + 100
```

#### 함수 호출 (콜론 `:` 사용)
```lua
-- 함수 호출 시에는 콜론(:) 사용
self:MyFunction()
self:Attack()
```

> **📌 중요**: 프로퍼티 접근은 `.`, 함수 호출은 `:`를 사용합니다!

---

### 2.2 `self.Entity` - 엔티티 접근

`self.Entity`를 통해 스크립트가 부착된 **엔티티 객체**에 접근합니다.

```lua
-- 엔티티의 다른 컴포넌트에 접근
local transform = self.Entity.TransformComponent
local sprite = self.Entity.SpriteRendererComponent

-- 위치 변경
self.Entity.TransformComponent.Position = Vector2(100, 200)

-- 엔티티 이름 가져오기
local name = self.Entity.Name
```

---

### 2.3 Component 접근 패턴

```lua
-- 현재 엔티티의 컴포넌트 접근
self.Entity.TransformComponent
self.Entity.MovementComponent
self.Entity.SpriteRendererComponent

-- 다른 엔티티의 컴포넌트 접근
local player = _EntityService:GetEntityByName("Player")
local playerPos = player.TransformComponent.Position
```

### 2.4 Entity 컴포넌트 관리 함수

| 함수 | 설명 |
|------|------|
| `Entity:GetComponent(typename)` | 특정 타입의 컴포넌트 반환 |
| `Entity:AddComponent(typename)` | 컴포넌트 추가 |
| `Entity:RemoveComponent(typename)` | 컴포넌트 제거 |
| `Entity:HasComponent(typename)` | 컴포넌트 존재 여부 확인 (boolean) |

```lua
-- 컴포넌트 존재 확인
local movement = self.Entity:GetComponent("MovementComponent")
if movement then
    movement.Speed = 200
end

-- 컴포넌트 동적 추가
self.Entity:AddComponent("ChatBalloonComponent")

-- 컴포넌트 제거
self.Entity:RemoveComponent("SpriteRendererComponent")
```

---

## 3. MSW 기본 이벤트 함수

스크립트 컴포넌트에서 자동으로 호출되는 기본 함수들입니다.

### 3.1 라이프사이클 이벤트 함수

| 함수 | 호출 시점 | 공간 | 설명 |
|------|----------|------|------|
| `OnInitialize()` | 스크립트 초기화 시 | Server/Client | 컴포넌트 생성 직후 1회 호출 |
| `OnBeginPlay()` | 게임 시작 시 | Server/Client | 모든 엔티티/컴포넌트 생성 후 1회 호출 |
| `OnUpdate(dt)` | 매 프레임 | Server/Client | 프레임마다 반복 호출 (dt: 델타타임) |
| `OnEndPlay()` | 게임 종료 시 | Server/Client | 엔티티 제거 시 1회 호출 |
| `OnDestroy()` | 엔티티 파괴 시 | Server/Client | OnEndPlay 이후 호출 |

### 3.2 맵 관련 이벤트 함수

| 함수 | 호출 시점 | 공간 | 설명 |
|------|----------|------|------|
| `OnMapEnter()` | 맵 진입 시 | Server/Client | 플레이어가 다른 맵으로 이동할 때 |
| `OnMapLeave()` | 맵 이탈 시 | Server/Client | 플레이어가 현재 맵을 떠날 때 |

> **📌 주의**: `OnInitialize`는 다른 컴포넌트가 아직 생성되지 않았을 수 있습니다. 다른 컴포넌트 참조는 `OnBeginPlay`에서 수행하세요!

### 3.1 기본 구조 예시

```lua
-- 초기화 함수 (게임 시작 전)
function OnInitialize()
    log("초기화 완료")
end

-- 게임 시작 함수
function OnBeginPlay()
    log("게임 시작!")
    self.hp = 100
end

-- 매 프레임 업데이트 (dt: 델타 타임)
function OnUpdate(dt)
    -- 매 프레임 실행되는 로직
    self.timer = self.timer + dt
end

-- 게임 종료 함수
function OnEndPlay()
    log("게임 종료")
end
```

---

## 4. wait() 함수 - 대기/지연

`wait()` 함수는 스크립트 실행을 **지정한 시간(초)만큼 일시 중단**합니다.

```lua
function OnBeginPlay()
    log("시작!")
    
    wait(1)  -- 1초 대기
    log("1초 후!")
    
    wait(2)  -- 2초 대기
    log("3초 후!")
end
```

### 4.1 반복문과 함께 사용

```lua
function OnBeginPlay()
    for i = 1, 5 do
        log("카운트: " .. i)
        wait(1)  -- 1초마다 출력
    end
    log("완료!")
end
```

> **📌 참고**: `wait()`는 Yield 함수로, 호출 시 스크립트 실행이 일시 중단됩니다.

---

## 5. 이벤트 핸들러

### 5.1 이벤트 시스템 구조

```
┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│  Dispatcher  │───▶│    Event    │───▶│   Handler    │
│   (발송자)    │    │   (이벤트)   │    │  (처리자)     │
└──────────────┘    └─────────────┘    └──────────────┘
```

### 5.2 이벤트 핸들러 연결

```lua
-- TriggerComponent 이벤트 연결
self.Entity.TriggerComponent.OnTriggerEnter:Connect(function(other)
    if other.PlayerComponent then
        log("플레이어가 영역에 진입!")
    end
end)

-- InputService 키 입력 이벤트
_InputService.KeyDownEvent:Connect(function(event)
    if event.key == KeyCode.Space then
        log("스페이스바 눌림!")
    end
end)
```

### 5.3 Entity Event Handler 사용

```lua
-- [EventSender] 어트리뷰트를 사용한 이벤트 핸들러
--@EventSender("InputService", "KeyDownEvent")
function OnKeyDown(event)
    if event.key == KeyCode.W then
        self:MoveUp()
    end
end
```

---

## 6. 프로퍼티와 서버/클라이언트 통신

### 6.1 Property 정의

Property는 컴포넌트의 멤버 변수로, 일반 Lua 변수와 달리 **타입이 고정**되며 외부에서 접근 가능합니다.

```lua
-- Property 타입 정의 (MyDesk에서 설정)
-- @Property(number) hp
-- @Property(string) playerName
-- @Property(boolean) isActive
```

### 6.2 프로퍼티 동기화 [Sync]

멀티플레이어 환경에서 변수 값을 클라이언트 간 **동기화**하려면 프로퍼티에 `[Sync]` 설정을 활성화해야 합니다.

```lua
-- 동기화되는 프로퍼티 (서버 → 클라이언트 자동 전파)
--@Sync
self.health = 100  -- 서버에서 변경하면 모든 클라이언트에 반영

-- 동기화되지 않는 프로퍼티
self.localScore = 0  -- 각 클라이언트에서만 유효
```

> **📌 동기화 방향**: 일반적으로 **서버 → 클라이언트** 방향으로 동기화됩니다.

### 6.3 서버/클라이언트 실행 공간

MSW에서는 스크립트가 **서버**와 **클라이언트** 두 환경에서 모두 실행될 수 있습니다.

| 환경 | 역할 |
|------|------|
| **Server** | 게임 로직 처리, 전체 상태 관리, 권위 있는 연산 |
| **Client** | 사용자 입력 처리, 렌더링, 로컬 UI |

```lua
-- 서버 전용 함수 (ServerOnly 배지)
--@Server
function SpawnEnemy()
    -- 서버에서만 실행됨
end

-- 클라이언트 전용 함수 (ClientOnly 배지)
--@Client
function ShowEffect()
    -- 클라이언트에서만 실행됨
end
```

### 6.4 HandleEvent 패턴

이벤트 핸들러를 정의하는 패턴입니다.

```lua
-- 핸들러 함수 정의
handler HandleEvent(KeyDownEvent event)
    if event.key == KeyCode.Space then
        self:Jump()
    end
end
```

### 6.5 서버/클라이언트 간 이벤트 통신

멀티플레이어 게임에서 서버와 클라이언트 간 이벤트를 주고받는 핵심 함수입니다.

| 함수 | 실행 위치 | 설명 |
|------|----------|------|
| `HandleEvent(event)` | All | 일반 이벤트 수신 |
| `HandleEventFromClient(event, userId)` | **Server** | 클라이언트가 보낸 이벤트 수신 |
| `HandleEventFromServer(event)` | **Client** | 서버가 보낸 이벤트 수신 |

```lua
-- 서버 코드: 클라이언트로부터 이벤트 수신
--@Server
function HandleEventFromClient(event, userId)
    if event.Type == "PlayerAttack" then
        log("유저 " .. userId .. "가 공격!")
        -- 모든 클라이언트에게 결과 전송
        self:SendEventToAllClients(event)
    end
end

-- 클라이언트 코드: 서버로부터 이벤트 수신
--@Client
function HandleEventFromServer(event)
    if event.Type == "EnemySpawned" then
        log("적 스폰됨: " .. event.EnemyName)
        self:ShowSpawnEffect(event.Position)
    end
end
```

> **📌 중요**: `HandleEventFromClient`의 `userId` 파라미터로 이벤트를 보낸 클라이언트를 식별할 수 있습니다!

---

## 7. 변수 선언과 스코프

### 7.1 지역 변수 (local)

```lua
local speed = 100       -- 지역 변수 (권장)
local name = "Player"   -- 문자열
local isActive = true   -- 불리언
local items = {}        -- 테이블
```

### 7.2 전역 변수

```lua
globalVar = 500  -- 전역 변수 (local 키워드 없음)
-- ⚠️ 전역 변수는 가급적 사용 자제
```

### 7.3 self 프로퍼티 (컴포넌트 범위)

```lua
self.hp = 100      -- 컴포넌트 프로퍼티 (다른 함수에서도 접근 가능)
self.score = 0
```

---

## 8. 조건문

```lua
-- if-then-else
if self.hp <= 0 then
    log("사망!")
elseif self.hp <= 30 then
    log("위험!")
else
    log("안전")
end

-- and, or, not 연산자
if isPlayer and isAlive then
    log("플레이어가 살아있음")
end

if not isDead or hasRevive then
    log("부활 가능")
end
```

---

## 9. 반복문

### 9.1 for 문

```lua
-- 숫자 반복
for i = 1, 10 do
    log(i)
end

-- 스텝 지정
for i = 10, 1, -1 do  -- 10부터 1까지 역순
    log(i)
end
```

### 9.2 while 문

```lua
local count = 0
while count < 5 do
    log(count)
    count = count + 1
end
```

### 9.3 테이블 순회

```lua
local items = {"sword", "shield", "potion"}

-- ipairs: 배열 순회 (1부터 순차적)
for index, item in ipairs(items) do
    log(index .. ": " .. item)
end

-- pairs: 전체 테이블 순회
local player = {name = "Hero", level = 10, hp = 100}
for key, value in pairs(player) do
    log(key .. " = " .. tostring(value))
end
```

---

## 10. 함수 정의

### 10.1 기본 함수

```lua
-- 함수 정의
function MyFunction()
    log("함수 호출됨")
end

-- 파라미터 있는 함수
function Attack(damage)
    self.hp = self.hp - damage
end

-- 반환값 있는 함수
function GetDistance(pos1, pos2)
    local dx = pos2.x - pos1.x
    local dy = pos2.y - pos1.y
    return math.sqrt(dx*dx + dy*dy)
end
```

### 10.2 지역 함수

```lua
local function HelperFunction()
    -- 이 스크립트 내에서만 사용 가능
end
```

---

## 11. 디버깅: log() 함수

MSW에서는 `print()` 대신 **`log()`** 함수를 사용합니다.

```lua
log("메시지 출력")
log("HP: " .. self.hp)
log("위치: " .. tostring(self.Entity.TransformComponent.Position))
```

### 11.1 로그 메시지 레벨

| 레벨 | 접두사 | 설명 |
|------|--------|------|
| Info | `LIA` | 정보성 메시지 |
| Warning | `LWA` | 문제가 있지만 동작함 |
| Error | `LEA` | 정상 동작 불가능 |

---

## 12. MSW 전용 전역 객체

| 객체 | 설명 |
|------|------|
| `self` | 현재 스크립트 컴포넌트 |
| `self.Entity` | 스크립트가 부착된 엔티티 |
| `_EntityService` | 엔티티 관리 서비스 |
| `_RoomService` | 룸 관리 서비스 |
| `_InputService` | 입력 서비스 |
| `_HttpService` | HTTP 요청 서비스 |
| `Vector2` | 2D 벡터 타입 |
| `Vector3` | 3D 벡터 타입 |
| `Color` | 색상 타입 |
| `log(msg)` | 로그 출력 함수 |
| `wait(sec)` | 대기 함수 |

---

## 13. 실전 예제

### 13.1 플레이어 이동

```lua
function OnBeginPlay()
    self.speed = 200
end

function OnUpdate(dt)
    local input = Vector2(0, 0)
    
    if _InputService:IsKeyPressed(KeyCode.W) then
        input.y = input.y + 1
    end
    if _InputService:IsKeyPressed(KeyCode.S) then
        input.y = input.y - 1
    end
    if _InputService:IsKeyPressed(KeyCode.A) then
        input.x = input.x - 1
    end
    if _InputService:IsKeyPressed(KeyCode.D) then
        input.x = input.x + 1
    end
    
    local pos = self.Entity.TransformComponent.Position
    pos = pos + input * self.speed * dt
    self.Entity.TransformComponent.Position = pos
end
```

### 13.2 충돌 감지

```lua
function OnBeginPlay()
    self.Entity.TriggerComponent.OnTriggerEnter:Connect(function(other)
        if other.TagComponent and other.TagComponent:HasTag("Enemy") then
            log("적과 충돌!")
            self:TakeDamage(10)
        end
    end)
end

function TakeDamage(amount)
    self.hp = self.hp - amount
    log("데미지 받음! 남은 HP: " .. self.hp)
    
    if self.hp <= 0 then
        self:Die()
    end
end

function Die()
    log("사망!")
    _EntityService:Destroy(self.Entity)
end
```

### 13.3 타이머 구현

```lua
function OnBeginPlay()
    self.timer = 0
    self.interval = 2  -- 2초마다 실행
end

function OnUpdate(dt)
    self.timer = self.timer + dt
    
    if self.timer >= self.interval then
        self.timer = 0
        self:OnInterval()
    end
end

function OnInterval()
    log("2초마다 실행!")
    -- 적 스폰, 아이템 생성 등
end
```

---

## 14. 참고 링크

- [API Reference 가이드라인](https://maplestoryworlds-creators.nexon.com/ko/apiReference/How-to-use-API-Reference)
- [Lua 공식 문서](https://maplestoryworlds-creators.nexon.com/ko/apiReference/Lua)
- [Lua 5.3 공식 매뉴얼](https://www.lua.org/manual/5.3/)

