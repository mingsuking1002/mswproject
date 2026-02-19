# 🟢 완료
# SPEC_ShopUI — 상점 UI 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `ShopUIComponent` |
| **기능 요약** | 상점 팝업 UI 렌더링, 슬롯 버튼 관리, 구매 피드백, 닫기 처리 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 상점 및 UI 시스템 v1.0.md` |
| **모듈화 레이어** | `UI` |

> [!NOTE]
> **레퍼런스**: 탕탕특공대(Survivor.io) 스킬 선택 팝업 UI 참고. 3슬롯 카드 형식 + 닫기 버튼 구성.

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| UI 엔티티 참조 해결 | `[client only]` | Path 기반 UI 엔티티 탐색 |
| 상점 UI 표시/숨김 | `[client only]` | ShopManagerComponent.IsShopOpen Sync 감지 |
| 슬롯 데이터 렌더링 | `[client only]` | 텍스트/아이콘/가격 표시 |
| 구매 버튼 클릭 핸들링 | `[client only]` | ButtonClickEvent → 서버 구매 요청 |
| 닫기 버튼/ESC 핸들링 | `[client only]` | ButtonClickEvent → 서버 닫기 요청 |
| 구매 피드백 (슬롯 비활성화, 잔액 갱신) | `[client only]` | Sync Property 변화 감지 → UI 갱신 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `ShopPanelRoot` | `Entity` | `None` | `nil` | 상점 패널 루트 UI 엔티티 |
| `ShopPanelRootPath` | `string` | `None` | `""` | 상점 패널 루트 경로 (탐색용) |
| `DimOverlayEntity` | `Entity` | `None` | `nil` | 배경 어둡게 처리 오버레이 |
| `DimOverlayPath` | `string` | `None` | `""` | 딤 오버레이 경로 |
| `CloseButtonEntity` | `Entity` | `None` | `nil` | 닫기 버튼 엔티티 |
| `CloseButtonPath` | `string` | `None` | `""` | 닫기 버튼 경로 |
| `Slot1Root` | `Entity` | `None` | `nil` | 슬롯1 루트 엔티티 |
| `Slot2Root` | `Entity` | `None` | `nil` | 슬롯2 루트 엔티티 |
| `Slot3Root` | `Entity` | `None` | `nil` | 슬롯3 루트 엔티티 |
| `GoldDisplayEntity` | `Entity` | `None` | `nil` | 현재 골드 표시 텍스트 엔티티 |
| `GoldDisplayPath` | `string` | `None` | `""` | 골드 표시 경로 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `TextComponent` | 아이템 이름, 설명, 가격, 골드 표시 |
| `SpriteGUIRendererComponent` | 아이콘 이미지 표시 |
| `ButtonComponent` | 슬롯 구매 버튼, 닫기 버튼 |
| `ButtonClickEvent` | 버튼 클릭 이벤트 핸들링 |
| `Entity.Enable` / `Entity.SetEnable()` | UI 패널 표시/숨김 |

---

## 5. 로직 흐름

### 5-1. 초기화 (OnBeginPlay)

```
OnBeginPlay [client only]:
  1. Path 기반 UI 엔티티 참조 해결:
     → ShopPanelRoot = ResolveEntity(ShopPanelRootPath)
     → DimOverlayEntity = ResolveEntity(DimOverlayPath)
     → CloseButtonEntity = ResolveEntity(CloseButtonPath)
     → Slot1~3Root = ShopPanelRoot 내부 자식 검색
     → GoldDisplayEntity = ResolveEntity(GoldDisplayPath)
  2. 모든 UI를 초기 숨김: ShopPanelRoot.Enable = false
  3. 닫기 버튼 이벤트 연결:
     → CloseButtonEntity:ConnectEvent(ButtonClickEvent, OnCloseButtonClicked)
  4. 각 슬롯 버튼 이벤트 연결:
     → Slot1~3의 ButtonComponent에 ConnectEvent
  5. 슬롯 내부 엔티티 캐싱:
     → 각 SlotRoot 하위의 TextComponent들 (ItemName, Description, Price)
     → SpriteGUIRendererComponent (아이콘)
```

### 5-2. 상점 UI 열기 (Sync 감지)

```
OnSyncProperty [client only]:
  ShopManagerComponent.IsShopOpen 변화 감지:
  
  if IsShopOpen == true:
    1. DimOverlayEntity.Enable = true (배경 어둡게)
    2. ShopPanelRoot.Enable = true
    3. RenderSlots() 호출
    4. RefreshGoldDisplay() 호출
  
  if IsShopOpen == false:
    1. ShopPanelRoot.Enable = false
    2. DimOverlayEntity.Enable = false
```

### 5-3. 슬롯 렌더링 (RenderSlots)

```
RenderSlots [client only]:
  for i = 1 to 3:
    1. ShopManagerComponent에서 슬롯 데이터 조회
       (self._T.CurrentSlots 접근 또는 Sync Property)
    2. 슬롯 타입 판별:
       → "heal": 아이콘 + "체력 회복" + "HP 30% 회복" + "100G"
       → "ammo": 아이콘 + "탄약 보충" + "전 무기 탄약 1세트" + "50G"
       → "passive": 아이콘 + 패시브 이름 + 설명 + "200G"
       → "soldout": "품절" 표시, 버튼 비활성
    3. 골드 부족 시:
       → 가격 텍스트 빨간색, 버튼 비활성 (ButtonComponent.Enable = false)
    4. 골드 충분 시:
       → 가격 텍스트 기본색, 버튼 활성
```

### 5-4. 구매 버튼 클릭

```
OnSlotButtonClicked(slotIndex) [client only]:
  1. ShopManagerComponent.RequestPurchaseServer(slotIndex) 호출
  2. UI 즉시 반영 (옵티미스틱):
     → 해당 슬롯 버튼 비활성 + "구매 완료" 텍스트
     → RefreshGoldDisplay() 호출 (Sync 반영 후)
```

### 5-5. 닫기 버튼 클릭

```
OnCloseButtonClicked [client only]:
  1. ShopManagerComponent.RequestCloseShopServer() 호출
  ※ UI 숨김은 IsShopOpen Sync 변화 시 자동 처리 (5-2)
```

### 5-6. 골드 표시 갱신

```
RefreshGoldDisplay [client only]:
  1. GoldComponent = self.Entity.GoldComponent
  2. GoldDisplayEntity.TextComponent.Text = tostring(GoldComponent.CurrentGold) .. "G"
```

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| `추가` | `ShopDimOverlay` | `SpriteGUIRendererComponent` | `enable: false` | 전체 화면, 반투명 검정 | 배경 어둡게 오버레이 |
| `추가` | `ShopPanel` | — (컨테이너) | `enable: false` | 화면 중앙, 적절한 크기 | 상점 패널 루트 |
| `추가` | `ShopPanel/TitleText` | `TextComponent` | `enable: true` | 패널 상단 중앙 | "상점" 제목 텍스트 |
| `추가` | `ShopPanel/GoldText` | `TextComponent` | `enable: true` | 패널 상단 우측 | "500G" 현재 골드 표시 |
| `추가` | `ShopPanel/Slot1` | — (컨테이너) | `enable: true` | 패널 내 좌측 | 슬롯1 카드 루트 |
| `추가` | `ShopPanel/Slot1/Icon` | `SpriteGUIRendererComponent` | `enable: true` | 카드 상단 중앙 | 아이템 아이콘 |
| `추가` | `ShopPanel/Slot1/ItemName` | `TextComponent` | `enable: true` | 아이콘 하단 | "체력 회복" |
| `추가` | `ShopPanel/Slot1/Description` | `TextComponent` | `enable: true` | 이름 하단 | "HP 30% 회복" |
| `추가` | `ShopPanel/Slot1/PriceButton` | `ButtonComponent`, `SpriteGUIRendererComponent`, `TextComponent` | `enable: true` | 카드 하단 | "100G" 구매 버튼 |
| `추가` | `ShopPanel/Slot2` | (Slot1과 동일 구조) | `enable: true` | 패널 내 중앙 | 슬롯2 카드 |
| `추가` | `ShopPanel/Slot2/Icon` | `SpriteGUIRendererComponent` | `enable: true` | 카드 상단 중앙 | 탄약 아이콘 |
| `추가` | `ShopPanel/Slot2/ItemName` | `TextComponent` | `enable: true` | — | "탄약 보충" |
| `추가` | `ShopPanel/Slot2/Description` | `TextComponent` | `enable: true` | — | "전 무기 탄약 1세트" |
| `추가` | `ShopPanel/Slot2/PriceButton` | `ButtonComponent`, `SpriteGUIRendererComponent`, `TextComponent` | `enable: true` | — | "50G" |
| `추가` | `ShopPanel/Slot3` | (Slot1과 동일 구조) | `enable: true` | 패널 내 우측 | 슬롯3 카드 (패시브) |
| `추가` | `ShopPanel/Slot3/Icon` | `SpriteGUIRendererComponent` | `enable: true` | — | 패시브 아이콘 |
| `추가` | `ShopPanel/Slot3/ItemName` | `TextComponent` | `enable: true` | — | "패시브 스킬" |
| `추가` | `ShopPanel/Slot3/Description` | `TextComponent` | `enable: true` | — | 설명 |
| `추가` | `ShopPanel/Slot3/PriceButton` | `ButtonComponent`, `SpriteGUIRendererComponent`, `TextComponent` | `enable: true` | — | "200G" |
| `추가` | `ShopPanel/CloseButton` | `ButtonComponent`, `SpriteGUIRendererComponent`, `TextComponent` | `enable: true` | 패널 하단 중앙 또는 우상단 X | "닫기" 버튼 |

> [!IMPORTANT]
> **UI 레이아웃 참고**: 탕탕특공대 스킬 선택 팝업과 유사하게, 3개 카드가 가로로 나열된 형태. 각 카드에 아이콘, 이름, 설명, 가격 버튼 포함.

### 6-2. 맵 엔티티

| 작업 | 엔티티 경로 | 컴포넌트 | 속성 | 비고 |
|---|---|---|---|---|
| 해당 없음 | — | — | — | 맵 엔티티는 ShopManager 명세서 참조 |

### 6-3. 글로벌/모델 (`DefaultPlayer.model`)

| 작업 | 대상 파일 | 변경 내용 | 비고 |
|---|---|---|---|
| `수정` | `DefaultPlayer.model` | `ShopUIComponent` 부착 | Bootstrap에서 자동 부착 |

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| `DefaultPlayer` | `script.ShopUIComponent` | `ShopPanelRootPath`, `DimOverlayPath`, `CloseButtonPath`, `GoldDisplayPath` 설정 | Path 기반 UI 참조 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `ShopManagerComponent` | `Meta` | `IsShopOpen` Sync 감지 → UI 제어, `RequestPurchaseServer()` / `RequestCloseShopServer()` 호출 |
| `GoldComponent` | `Core` | `CurrentGold` Sync 읽기 → 골드 표시 및 버튼 활성화 판정 |
| `Map01BootstrapComponent` | `Bootstrap` | 컴포넌트 자동 부착 대상 추가 |

---

## 8. 주의/최적화 포인트

- **UI는 클라이언트 전용**: 모든 UI 로직은 `[client only]`. 서버에서 UI 엔티티 접근 금지.
- **Sync 기반 갱신**: `IsShopOpen`, `CurrentGold` 등 Sync Property 변화 시에만 UI 갱신. 매 프레임 갱신 금지.
- **닫기 버튼 디바운스**: 빠른 연타 방지용 플래그 (`self._T.IsClosing`) 사용.
- **패시브 슬롯 품절 처리**: 1차에서는 항상 표시하되, 구매 시 "미구현" 로그만 출력. 모든 패시브 습득 판정 로직은 추후 구현.
- **SortingLayer/OrderInLayer**: ShopDimOverlay와 ShopPanel은 HUD보다 높은 레이어에 배치하여 항상 최상단에 표시.

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `UI` 레이어
- [x] `_GRUtil` 사용 (중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리 (UI는 전부 client only)
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 반영 완료** — `ui/DefaultGroup.ui`에 Shop UI 엔티티 20개를 생성/배치
- [x] `Map01BootstrapComponent.AttachRequiredComponentsServer`에 `ShopUIComponent` 추가
- [x] Path 기반 UI 참조 Property 설정
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 10. Maker 배치 결과

- [x] `DefaultGroup.ui`에 `ShopDimOverlay`, `ShopPanel`, `Slot1~3`, `CloseButton`, `GoldText` 엔티티 생성 및 컴포넌트/레이아웃 설정 완료
- [x] `ShopUIComponent` 기본 경로와 UI 엔티티 경로 정합성 검증 완료

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-19 |
| **상태** | 🟢 완료 |
