# 🟢 완료
# SPEC_GoldSystem — 재화(골드) 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `GoldComponent` |
| **기능 요약** | 플레이어 골드 보유량 관리, 소비/획득 API 제공 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 상점 및 UI 시스템 v1.0.md` |
| **모듈화 레이어** | `Core` |

> [!IMPORTANT]
> 1차 구현에서는 **초기 골드 지급만** 구현합니다. 몬스터 처치 시 골드 획득은 추후 몬스터 시스템 연동 시 확장합니다.

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 골드 초기화 | `[server only]` | 초기 골드량 세팅 |
| 골드 소비(차감) | `[server only]` | 상점 구매 시 서버 검증 후 차감 |
| 골드 획득(추가) | `[server only]` | 외부 시스템에서 호출 (추후 몬스터 연동) |
| HUD 동기화 | `@Sync Property` | CurrentGold Sync로 클라이언트 자동 반영 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentGold` | `integer` | `@Sync` | `500` | 현재 보유 골드 (임시 초기값) |
| `InitialGold` | `integer` | `None` | `500` | 게임 시작 시 지급 골드 |
| `MaxGold` | `integer` | `None` | `99999` | 골드 상한선 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| 해당 없음 | 자체 Property만 사용, 외부 서비스 불필요 |

---

## 5. 로직 흐름

### 5-1. 초기화

```
OnBeginPlay (server only):
  1. CurrentGold = InitialGold
  2. 초기화 완료 로그
```

### 5-2. 골드 소비 (SpendGold)

```
SpendGold(amount) [server only]:
  1. amount <= 0 → return false (무효)
  2. CurrentGold < amount → return false (잔액 부족)
  3. CurrentGold -= amount
  4. return true
```

### 5-3. 골드 획득 (AddGold)

```
AddGold(amount) [server only]:
  1. amount <= 0 → return
  2. CurrentGold = math.min(CurrentGold + amount, MaxGold)
```

### 5-4. 잔액 조회 (CanAfford)

```
CanAfford(amount) [server/client]:
  1. return CurrentGold >= amount
```

### 5-5. 골드 리셋 (ResetGold)

```
ResetGold() [server only]:
  1. CurrentGold = InitialGold
  ※ 로비 복귀 시 LobbyFlowComponent에서 호출
```

---

## 6. Maker 배치 (Codex MCP 실행) ⚠️ 필수 검토

### 6-1. UI 엔티티 (`DefaultGroup.ui`)

| 작업 | 엔티티 | 컴포넌트 | 초기 상태 | 위치/크기 | 비고 |
|---|---|---|---|---|---|
| 해당 없음 | — | — | — | — | 골드 표시는 HUDComponent에서 담당 |

### 6-2. 맵 엔티티

| 작업 | 엔티티 경로 | 컴포넌트 | 속성 | 비고 |
|---|---|---|---|---|
| 해당 없음 | — | — | — | DefaultPlayer 모델에 부착 |

### 6-3. 글로벌/모델 (`DefaultPlayer.model`)

| 작업 | 대상 파일 | 변경 내용 | 비고 |
|---|---|---|---|
| `수정` | `DefaultPlayer.model` | `GoldComponent` 부착 | Bootstrap에서 자동 부착 대상에 추가 |

### 6-4. 컴포넌트 부착 관계

| 엔티티 경로 | 부착할 컴포넌트 | 설정할 Property | 비고 |
|---|---|---|---|
| `DefaultPlayer` | `script.GoldComponent` | `InitialGold=500` | Map01BootstrapComponent에서 자동 부착 |

---

## 7. 연동 컴포넌트

| 컴포넌트 | 레이어 | 연동 방식 |
|---|---|---|
| `ShopManagerComponent` | `Meta` | `SpendGold()` 호출하여 구매 처리 |
| `HUDComponent` | `UI` | `CurrentGold` Sync 값을 읽어 HUD에 표시 |
| `LobbyFlowComponent` | `Bootstrap` | 로비 복귀 시 `ResetGold()` 호출 |
| `Map01BootstrapComponent` | `Bootstrap` | `AttachRequiredComponentsServer`에 GoldComponent 추가 |

---

## 8. 주의/최적화 포인트

- **서버 권위 필수**: 골드 변경은 반드시 `[server only]`에서 처리. 클라이언트에서 직접 수정 불가.
- **Sync Property**: `CurrentGold`가 Sync이므로 클라이언트는 읽기만 가능.
- **확장 포인트**: 추후 몬스터 처치 시 `AddGold()` 호출 경로 추가 예정.

---

## 9. Codex 구현 체크리스트

- [x] `@Component` 어트리뷰트, `Core` 레이어
- [x] `_GRUtil` 사용 (중복 유틸 금지)
- [x] `[server only]` / `[client only]` 분리
- [x] `nil`/`isvalid` 방어 + `pcall` 보호
- [x] **Maker 배치 (§6) 완료** — DefaultPlayer 모델에 컴포넌트 부착
- [x] `Map01BootstrapComponent.AttachRequiredComponentsServer`에 `GoldComponent` 추가
- [x] `기획서/4.부록/Code_Documentation.md` 업데이트
- [x] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-19 |
| **상태** | 🟢 완료 |
