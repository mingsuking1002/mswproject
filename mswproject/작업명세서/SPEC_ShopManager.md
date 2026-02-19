# 🟡 대기중
# SPEC_ShopManager — 상점 관리 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `ShopManagerComponent` |
| **기능 요약** | 4방향 상점 순환, F키 상호작용, 구매 처리, 일시정지 제어 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 상점 및 UI 시스템 v1.0.md` |
| **모듈화 레이어** | `Meta` |

> [!IMPORTANT]
> **핵심 플로우**: 활성 상점 접근 → F키 → 일시정지 + UI 오픈 → 구매/닫기 → 현재 상점 비활성 → 나머지 3곳 중 무작위 1곳 활성 → 일시정지 해제

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 상점 초기화 (4곳 중 1곳 활성) | `[server only]` | 게임 시작 시 무작위 1곳 Enable |
| F키 입력 감지 | `[client only]` | KeyDownEvent 핸들링 |
| 상호작용 거리 검증 | `[server only]` | 플레이어-상점 거리 판정 |
| 상점 UI 오픈 요청 | `[server only]` | 거리 검증 통과 후 UI 오픈 이벤트 |
| 일시정지 플래그 제어 | `[server only]` | 일시정지 소스 등록/해제 |
| 구매 로직 (골드 차감, 효과 적용) | `[server only]` | 서버 권위 거래 처리 |
| 상점 순환 (비활성→활성) | `[server only]` | 방문 후 현재 비활성, 랜덤 활성 |
| UI 열기/닫기 연출 | `[client only]` | ShopUIComponent에 위임 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `IsShopOpen` | `boolean` | `@Sync` | `false` | 상점 UI 오픈 상태 |
| `ActiveShopIndex` | `integer` | `@Sync` | `0` | 현재 활성 상점 인덱스 (1~4, 0=미지정) |
| `InteractionRange` | `number` | `None` | `150` | 상호작용 거리 (px) |
| `ShopEntity1` | `Entity` | `None` | `nil` | 동(3시) 상점 엔티티 참조 |
| `ShopEntity2` | `Entity` | `None` | `nil` | 서(9시) 상점 엔티티 참조 |
| `ShopEntity3` | `Entity` | `None` | `nil` | 남(6시) 상점 엔티티 참조 |
| `ShopEntity4` | `Entity` | `None` | `nil` | 북(12시) 상점 엔티티 참조 |
| `ShopDataTableName` | `string` | `None` | `"ShopItemData"` | 상점 판매 목록 DataTable 이름 |
| `HealPercent` | `number` | `None` | `30` | 회복 슬롯 체력 회복 비율(%) |
| `HealPrice` | `integer` | `None` | `100` | 회복 아이템 가격 (임시) |
| `AmmoPrice` | `integer` | `None` | `50` | 탄약 아이템 가격 (임시) |
| `PassivePrice` | `integer` | `None` | `200` | 패시브 스킬 가격 (임시) |

> [!NOTE]
> 가격 수치는 임시값입니다. DataTable(`ShopItemData`)에서 관리하며, 밸런스 조정 시 테이블만 수정합니다.

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_DataService` | `GetTable("ShopItemData")` — 상점 아이템 데이터 로드 |
| `_TimerService` | 상점 순환 딜레이 (필요 시) |
| `Entity.SetEnable()` | 상점 엔티티 활성/비활성 제어 |
| `Entity.TransformComponent.WorldPosition` | 거리 계산용 위치 조회 |
| `TriggerEnterEvent` / `TriggerLeaveEvent` | 상점 근접 감지 (대안: 거리 계산) |

---

## 5. 로직 흐름

### 5-1. 초기화 (OnBeginPlay)

```
OnBeginPlay [server only]:
  1. 4개 상점 엔티티 참조 획득 (Property 또는 맵 검색)
  2. 모든 상점 Entity.Enable = false
  3. 무작위 1곳 선택 → ActiveShopIndex 설정
  4. 선택된 상점 Entity.Enable = true
  5. DataTable 로드: _DataService:GetTable(ShopDataTableName)
     → self._T.ShopData에 캐싱
```

### 5-2. F키 상호작용 요청

```
HandleKeyDownEvent [client only]:
  1. event.key ~= KeyboardKey.F → return
  2. IsShopOpen == true → return (이미 열려있음)
  3. RequestOpenShopServer() 호출 (서버 RPC)

RequestOpenShopServer [server only]:
  1. 소유자 검증 (OwnerId 체크)
  2. ActiveShopIndex == 0 → return
  3. 활성 상점 엔티티의 WorldPosition 조회
  4. 플레이어 엔티티의 WorldPosition 조회
  5. 거리 = (플레이어 위치 - 상점 위치).magnitude
  6. 거리 > InteractionRange → return (범위 밖)
  7. OpenShop() 호출
```

### 5-3. 상점 오픈

```
OpenShop [server only]:
  1. IsShopOpen = true
  2. 일시정지 플래그 등록:
     → MovementComponent.CanMove = false
     → SpeedrunTimerComponent:SetPauseSource("shop", true)
     → FireSystemComponent.CanAttack = false  (공격 차단)
  3. 판매 슬롯 데이터 구성:
     → 슬롯1: { type="heal", name="체력 회복", desc="HP 30% 회복", price=HealPrice }
     → 슬롯2: { type="ammo", name="탄약 보충", desc="전 무기 탄약 1세트", price=AmmoPrice }
     → 슬롯3: 패시브 풀에서 랜덤 1종 선택 (미구현 시 placeholder)
        → 모든 패시브 습득 완료 → type="soldout"
  4. self._T.CurrentSlots = { slot1, slot2, slot3 }
  ※ 클라이언트에서 IsShopOpen Sync 변화 감지 → ShopUIComponent가 UI 렌더링
```

### 5-4. 구매 처리

```
RequestPurchaseServer(slotIndex) [server only]:
  1. IsShopOpen == false → return
  2. slotIndex 범위 검증 (1~3)
  3. 해당 슬롯 데이터 조회: slotData = self._T.CurrentSlots[slotIndex]
  4. slotData.type == "soldout" → return
  5. GoldComponent:CanAfford(slotData.price) == false → return
  6. GoldComponent:SpendGold(slotData.price)
  7. 효과 적용:
     → "heal": HPSystemComponent:Heal(MaxHP * HealPercent / 100)
     → "ammo": ReloadComponent → 전 슬롯 CurrentAmmo = MaxAmmo
     → "passive": (1차 미구현, 로그만 출력)
  8. 구매 완료 피드백 (슬롯 비활성화)
```

### 5-5. 상점 닫기 및 순환

```
RequestCloseShopServer [server only]:
  1. IsShopOpen == false → return
  2. IsShopOpen = false
  3. 현재 활성 상점 비활성화:
     → ShopEntity[ActiveShopIndex].Enable = false
  4. 후보 리스트 = {1,2,3,4} - {ActiveShopIndex} (3곳)
  5. 무작위 1곳 선택 → newIndex
  6. ActiveShopIndex = newIndex
  7. ShopEntity[newIndex].Enable = true
  8. 일시정지 해제:
     → MovementComponent.CanMove = true
     → SpeedrunTimerComponent:SetPauseSource("shop", false)
     → FireSystemComponent.CanAttack = true
```

### 5-6. ESC 닫기 (클라이언트)

```
HandleKeyDownEvent [client only]:
  1. event.key == KeyboardKey.Escape AND IsShopOpen == true
  2. RequestCloseShopServer() 호출
```

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| 해당 없음 | — | — | — | — | UI는 ShopUIComponent 명세서 참조 |

### 6-2. 맵 엔티티 (`Map01.map`)

| 작업 | 엔티티 경로 | 컴포넌트 | 속성 | 비고 |
|---|---|---|---|---|
| `추가` | `/maps/Map01/Shop_East` | `SpriteRendererComponent`, `TriggerComponent` | Position: 맵 동쪽(3시) 끝 중앙, Enable: false | 동쪽 상점 |
| `추가` | `/maps/Map01/Shop_West` | `SpriteRendererComponent`, `TriggerComponent` | Position: 맵 서쪽(9시) 끝 중앙, Enable: false | 서쪽 상점 |
| `추가` | `/maps/Map01/Shop_South` | `SpriteRendererComponent`, `TriggerComponent` | Position: 맵 남쪽(6시) 끝 중앙, Enable: false | 남쪽 상점 |
| `추가` | `/maps/Map01/Shop_North` | `SpriteRendererComponent`, `TriggerComponent` | Position: 맵 북쪽(12시) 끝 중앙, Enable: false | 북쪽 상점 |

> [!IMPORTANT]
> **상점 엔티티 설정 상세:**
> - `TriggerComponent`: ColliderType = Circle, CircleRadius = 150(px), IsPassive = true
> - `SpriteRendererComponent`: 상점 스프라이트 RUID (임시 플레이스홀더 사용)
> - `Enable`: false (초기 비활성, 서버에서 1곳만 Enable)
> - 충돌체(RigidbodyComponent) 없음 — 기획서에 따라 플레이어와 겹침 허용

### 6-3. 글로벌/모델 (`DefaultPlayer.model`)

| 작업 | 대상 파일 | 변경 내용 | 비고 |
|---|---|---|---|
| `수정` | `DefaultPlayer.model` | `ShopManagerComponent` 부착 | Bootstrap에서 자동 부착 |

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| `DefaultPlayer` | `script.ShopManagerComponent` | `ShopEntity1~4` = 맵 상점 엔티티 참조 | Bootstrap에서 자동 부착 및 Entity 참조 세팅 |

> [!NOTE]
> 상점 엔티티가 맵에 배치되므로, Bootstrap에서 `Entity:GetChildByName()` 등으로 맵 내 상점 엔티티를 검색하여 Property에 할당해야 합니다.

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `GoldComponent` | `Core` | `SpendGold()`, `CanAfford()` 호출 |
| `HPSystemComponent` | `Combat` | `Heal()` 호출 (회복 슬롯) |
| `ReloadComponent` | `Combat` | 탄약 보충 시 `CurrentAmmo = MaxAmmo` 직접 설정 |
| `FireSystemComponent` | `Combat` | 일시정지 시 `CanAttack = false` 제어 |
| `MovementComponent` | `Core` | 일시정지 시 `CanMove = false` 제어 |
| `SpeedrunTimerComponent` | `Meta` | `SetPauseSource("shop", bool)` 호출 |
| `ShopUIComponent` | `UI` | `IsShopOpen` Sync 변화 감지 → UI 렌더링 |
| `Map01BootstrapComponent` | `Bootstrap` | 컴포넌트 자동 부착 및 상점 엔티티 참조 세팅 |
| `LobbyFlowComponent` | `Bootstrap` | 로비 복귀 시 상점 상태 리셋 |
| `WeaponSwapComponent` | `Meta` | 상점 열림 시 무기 교체 메뉴 비활성 (IsShopOpen 참조) |

---

## 8. 주의/최적화 포인트

- **거리 판정은 서버에서만**: 클라이언트에서 F키 누름 → 서버에서 거리 검증. 클라이언트 조작 방지.
- **일시정지는 플래그 기반**: MSW에 네이티브 TimeScale이 없으므로, Movement/Fire/Timer 각각 플래그로 정지. `WeaponSwapComponent.PauseGameplayByFlag` 패턴과 동일.
- **상점 Entity는 TriggerComponent 불필요 (대안)**: 거리 계산만으로 상호작용 판정 가능. TriggerComponent 사용 시 IsPassive=true 필수(상점 자체가 충돌 검사하지 않도록).
- **DataTable 기반 수치**: 가격/회복량 등 밸런스 수치는 모두 DataTable에서 로드. 하드코딩 금지.
- **상점 순환 시 Enable/Disable**: `Entity:SetEnable(false, false, true)` 사용하여 동기화.

---

## 9. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트, `Meta` 레이어
- [ ] `_GRUtil` 사용 (중복 유틸 금지)
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil`/`isvalid` 방어 + `pcall` 보호
- [ ] **Maker 배치 (§6) 완료** — 맵에 상점 엔티티 4개 추가, DefaultPlayer에 컴포넌트 부착
- [ ] DataTable `ShopItemData` 설계 및 생성
- [ ] `Map01BootstrapComponent.AttachRequiredComponentsServer`에 `ShopManagerComponent` 추가
- [ ] 상점 엔티티 참조 세팅 로직 추가 (Bootstrap에서 맵 검색)
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 10. DataTable 설계: `ShopItemData`

| Column | Type | 설명 | 예시 |
|---|---|---|---|
| `SlotType` | string | 슬롯 타입 ("heal" / "ammo" / "passive") | "heal" |
| `ItemName` | string | 표시 이름 | "체력 회복" |
| `Description` | string | 설명 텍스트 | "최대 HP의 30% 회복" |
| `Price` | integer | 가격 | 100 |
| `EffectValue` | number | 효과 수치 (회복%/탄약세트 등) | 30 |
| `IconRUID` | string | 아이콘 스프라이트 RUID | "" (임시 비워둠) |

> 초기 데이터 (3행):

| SlotType | ItemName | Description | Price | EffectValue | IconRUID |
|---|---|---|---|---|---|
| heal | 체력 회복 | 최대 HP의 30% 회복 | 100 | 30 | (임시) |
| ammo | 탄약 보충 | 전 무기 탄약 1세트 충전 | 50 | 1 | (임시) |
| passive | 패시브 스킬 | 랜덤 패시브 스킬 1종 획득 | 200 | 0 | (임시) |

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-19 |
| **상태** | 🟡 대기중 |
