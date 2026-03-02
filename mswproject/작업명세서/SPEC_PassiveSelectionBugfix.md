# 🟢 완료

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 | 비고 |
|---|---|---|
| 2026-03-03 | 🟡 대기중 | 패시브 드롭 선택 UI 즉시 닫힘 + Pause 고착 버그 수정 |
| 2026-03-03 | 🔵 진행중 | `OpenSyncGraceTimer` 기반 클라이언트 grace guard 구현 시작 |
| 2026-03-03 | 🟢 완료 | `.mlua/.codeblock` 동기화 및 Code_Documentation 갱신 완료 |

---

## 1. 개요

몬스터 드롭 패시브 아이템 획득 시, 3선택지 UI가 열리자마자 즉시 닫히고 게임이 무기한 정지(Pause)되는 버그를 수정한다. 원인은 `@ExecSpace("Client")` RPC와 `@Sync` Property 간의 **레이스 컨디션**(동기화 지연)으로, 아래 수정으로 해결한다.

---

## 2. 컴포넌트 정의

* **Component Name:** `PassiveSelectionUIComponent`
* **Execution Space:** `[Client Only]` (UI 렌더/입력 처리)
* **파일 경로:** `RootDesk/MyDesk/ProjectGR/Components/UI/PassiveSelectionUIComponent.mlua`

---

## 3. 버그 원인 (레이스 컨디션)

```
Server: IsPassiveSelectionOpen = true (@Sync, 수십ms 지연)
Server: OpenPassiveSelectionClient() RPC → 즉시 도착
Client: RPC 수신 → UI Open, _T.IsOpen = true
Client: 다음 프레임 OnUpdate → @Sync 미도달 → IsPassiveSelectionOpen == false
Client: "서버 닫힘" 오판 → ClosePassiveSelectionClient() → UI 닫힘
Server: 여전히 Lock 상태 → 영구 Pause
```

---

## 4. 수정 사항 (3곳)

### 4-1. `InitializeRuntimeClient` — grace timer 필드 초기화 추가

기존 `_T` 필드 초기화 블록 끝에 추가:

```lua
if self._T.OpenSyncGraceTimer == nil then
    self._T.OpenSyncGraceTimer = 0.0
end
```

### 4-2. `OpenPassiveSelectionClient` — UI 오픈 시 grace timer 세팅

`self:RenderOptionsClient()` 호출 직후(함수 끝부분)에 추가:

```lua
self._T.OpenSyncGraceTimer = 1.5
```

### 4-3. `OnUpdate` — grace period 중 sync guard 스킵

`if self._T.IsOpen ~= true then return end` 직후, 기존 sync guard 로직 직전에 삽입:

```lua
if self._T.OpenSyncGraceTimer ~= nil and self._T.OpenSyncGraceTimer > 0 then
    self._T.OpenSyncGraceTimer = self._T.OpenSyncGraceTimer - delta
    return
end
```

---

## 5. Required MSW Services

* 해당 없음 (기존 서비스 변경 없음)

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| `PassiveSystemComponent` | 서버에서 `OpenPassiveSelectionClient` RPC 호출 (변경 없음) |
| `ItemDropManagerComponent` | 드롭 획득 시 `RequestPassiveSelectionFromDropServer` 호출 (변경 없음) |

---

## 7. Logic Architecture

### 수정 후 전체 흐름

1. **드롭 획득** → `ItemDropManagerComponent.ApplyItemPickupEffectServer` → `PassiveSystemComponent.RequestPassiveSelectionFromDropServer`
2. **서버 오픈** → 후보 3개 생성, Token 발급, Lock 적용(이동/공격/타이머 정지), `IsPassiveSelectionOpen = true`
3. **클라이언트 오픈** → `OpenPassiveSelectionClient` RPC 수신 → UI 표시 + **`OpenSyncGraceTimer = 1.5`** 세팅
4. **OnUpdate grace** → 1.5초간 sync guard 완전 스킵 → 자동 닫힘 방지
5. **클릭 선택** → `RequestSelectPassiveFromDropServer(passiveId, token)` RPC
6. **서버 적용** → `ApplyRandomPassiveServer` → 스탯 반영
7. **게임 재개** → `ClosePassiveSelectionServer(true, true)` → `ApplyPassiveSelectionLockServer(false)` → Lock 해제

---

## 8. 기획서 참조

* `기획서/2.세부 시스템/v.2.0 패시브 통합 (구현 양식 버전) - 통합1.jpg`
* `기획서/2.세부 시스템/v.2.0 패시브 통합 (구현 양식 버전) - 통합2.jpg`
* `기획서/1.핵심 시스템/[시스템] 아이템 드랍 및 획득 시스템 v 1.0.md`

---

## 9. 구현 방식

workspace에서 직접 `PassiveSelectionUIComponent.mlua` 수정 후 codeblock 동기화

---

## 10. 주의/최적화 포인트

* **1.5초 유예**: Sync Property 도달에 충분한 시간. 이후에는 기존 guard가 정상 작동하여 stale 상태 방어
* **서버 로직 변경 없음**: 서버 권위 유지, 클라이언트 방어 코드만 보강
* **codeblock 동기화 필수**: `.mlua` 수정 후 반드시 `.codeblock` 파일도 갱신
