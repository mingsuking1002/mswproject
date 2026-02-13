# 🌉 AI Knowledge Bridge: Master Technical Blueprint
> **최종 정교화 업데이트**: 2026-02-13
> **대상**: 이 프로젝트를 이어받아 즉시 개발을 수행해야 하는 모든 AI 어시스턴트

이 문서는 단순한 요약을 넘어, 다른 AI가 프로젝트의 **코드 아키텍처, 데이터 흐름, 그리고 기술적 결정 사항**을 즉시 파악하고 코드를 짤 수 있도록 설계되었습니다.

---

## 🏗️ 1. Core Architecture (핵심 아키텍처)

### 1.1 MSW Entity-Component-Property (ECP)
- 모든 객체는 `Entity`이며, 기능은 `Component`로 분리됩니다.
- **통신 규칙**: 서버와 클라이언트 간의 데이터 동기화는 `[Sync]` 프로퍼티를 통해 자동으로 이루어지며, 로직 실행은 `[server]`, `[client]`, `[multicast]` 등을 통해 제어됩니다.

| 실행 제어 제약 | 설명 |
| :--- | :--- |
| `[server]` | 서버에서 실행 (클라이언트에서 호출 시 RPC 발생) |
| `[client]` | 클라이언트에서 실행 |
| `[multicast]` | 서버 실행 후 모든 클라이언트에 복제 실행 |
| `[Sync]` | 서버에서 값 변경 시 클라이언트에 자동 동기화 |

### 1.2 Lifecycle (생명주기)
- `OnInitialize` -> `OnBeginPlay` -> `OnUpdate` (매 프레임) -> `OnEndPlay`
- **주의**: `OnBeginPlay` 시점에 다른 엔티티와의 참조가 보장됩니다.

---

## ⚔️ 2. Combat System Deep-Dive (전투 시스템 상세)

### 2.1 Attack-Hit Interaction
전투는 `AttackComponent`와 `HitComponent`의 상호작용으로 발생합니다.
```lua
-- 공격 실행 예시
[server only]
void Attack() {
    local size = Vector2(2, 2)
    local offset = Vector2(1, 0)
    -- CollisionGroups.Monster 그룹을 대상으로 공격
    self:Attack(size, offset, "NormalSkill", CollisionGroups.Monster)
}
```
- **CalcDamage**: `AttackComponent`를 확장하여 대미지 계산식을 재정의합니다.
- **IsHitTarget**: `HitComponent`에서 무적 상태나 PVP 모드에 따라 피격 여부를 결정합니다.

---

## 📱 3. Visual Novel Web Engine (웹 엔진 전환)

### 3.1 아키텍처 설계
- **Core**: MSW Lua 로직을 JS 클래스로 이식.
- **UI**: CSS Glassmorphism 및 CSS Variables 기반 테마 시스템.
- **Data**: JSON 기반 대화 스크립트 구조화.
```json
{
  "scene_id": "prologue",
  "dialogs": [
    {"character": "Hero", "text": "안녕?", "action": "fade_in"}
  ]
}
```

---

## 💾 4. DevOps & Continuity (지속성 관리)

### 4.1 AI Memory Sync (`_scripts/sync_ai.ps1`)
- AI의 `brain`, `knowledge`, `conversations` 데이터를 Git 리포지토리의 `.ai_backup`으로 백업합니다.
- `custom_rules.md`를 수정하면 모든 브레인 세션에 즉시 반영되는 동기화 로직을 포함합니다.

### 4.2 Context Export (`_scripts/export_context.ps1`)
- 현재 세션의 `task.md`, `implementation_plan.md`를 자동으로 수집하여 `AI_CONTEXT_EXPORT.md`를 생성합니다.

---

## 🤖 5. Next AI Collaboration Guide (AI 가이드북)

이 섹션을 읽는 AI는 다음 지침을 엄수하십시오:
1. **맥락 우선**: `AI_CONTEXT_EXPORT.md`가 존재한다면 가장 최근에 하던 작업을 최우선으로 이어받으세요.
2. **기술 스택**: 코드는 MSW Lua 5.1 기반이며, 웹 전환 시에는 Vanilla CSS/JS를 사용합니다.
3. **규칙 준수**: `custom_rules.md`에 정의된 한국어 답변 및 스타일 가이드를 따르세요.
4. **상세 정보**: 더 자세한 기술 사양이 필요하면 `brain/8f48c3d3-7e67-47c1-b830-e1e1325a4fe7/msw_knowledge_base.md`를 참고하세요.

---
*이 문서는 Antigravity v2.0에 의해 '세세하게' 재구성되었습니다.*
