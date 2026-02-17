# 🟢 완료
# SPEC_TagSystem — 캐릭터 태그(교체) 시스템

## 1. 개요

| 항목 | 내용 |
|---|---|
| **Component Name** | `TagManagerComponent` |
| **기능 요약** | 2인 캐릭터 실시간 교체, 개별 HP/탄창, 태그 스킬 발동 |
| **기획서 참조** | `기획서/1.핵심 시스템/[시스템] 캐릭터 태그(교체) 시스템.md` |

### 핵심 동작
- 태그 버튼 입력 → 조건 체크 → 현재 캐릭터 퇴장 → 대기 캐릭터 등장
- 등장 시 **태그 스킬(Entry Skill)** 자동 발동
- 교체 프레임 동안 **무적 판정**
- HP, 탄창, 무기 상태는 캐릭터별 **개별 관리** (공유하지 않음)

---

## 2. Execution Space

| 처리 단계 | 실행 공간 | 설명 |
|---|---|---|
| 태그 키 입력 | `[client only]` | `_InputService` → `KeyDownEvent` |
| 서버에 태그 요청 | Client → Server | `@EventSender` |
| 태그 로직 (검증/스왑) | `[server only]` | 쿨타임, 상태, 금지구역 검증 후 교체 |
| 외형/HUD 갱신 | `[client only]` | Sync 감지 → UI/스프라이트 교체 |

---

## 3. Properties

| Property Name | Type | Sync | Default | 설명 |
|---|---|---|---|---|
| `CurrentCharIndex` | `integer` | `Sync` | `1` | 현재 활성 캐릭터 (1=A, 2=B) |
| `TagCooldown` | `number` | `None` | `3.0` | 태그 쿨타임 (초) |
| `IsTagReady` | `boolean` | `Sync` | `true` | 태그 가능 여부 |
| `InvincibleTime` | `number` | `None` | `0.5` | 교체 무적 시간 (초) |
| `IsTagLocked` | `boolean` | `Sync` | `false` | 태그 금지 상태 (상점, 컷신 등) |

### 캐릭터별 개별 데이터 (서버 관리)
| 데이터 | 설명 |
|---|---|
| 캐릭터 A: HP, 잔탄(4슬롯), 장착무기, 장전상태 | 대기 중 상태 그대로 보존 |
| 캐릭터 B: HP, 잔탄(4슬롯), 장착무기, 장전상태 | 상동 |
| 공유: 위치(Transform), 재장전 쿨타임(백그라운드) | 교체 시 위치/각도 계승 |

---

## 4. 사용 서비스 & API

| 서비스/API | 용도 |
|---|---|
| `_InputService` | 태그 키 입력 감지 |
| `_TimerService` | 태그 쿨타임, 무적 시간 타이머 |
| `AvatarRendererComponent` | 캐릭터 외형(RUID) 변경 |
| `_EffectService` | 등장 이펙트/사운드 |

---

## 5. 로직 흐름

### 5-1. 태그 요청 (클라이언트)
1. 태그 키 입력 감지
2. `IsTagReady == false` → 쿨타임 UI 피드백, 요청 안함
3. `IsTagLocked == true` → 입력 무시 (금지 구역)
4. 서버에 태그 요청 이벤트 전달

### 5-2. 태그 실행 (서버)
1. **조건 검증:** 쿨타임, 금지구역, 상태이상(기절), 사망 여부
2. **퇴장:** 현재 캐릭터(A)의 데이터(HP, 탄창, 무기상태) 백업
3. **등장:** 대기 캐릭터(B)의 데이터 로드 → 엔티티에 적용
4. **위치 계승:** Transform(위치/각도) 그대로 유지
5. **외형 변경:** 아바타 RUID/코스튬 교체
6. `CurrentCharIndex` 스왑 (1↔2)
7. **무적 적용:** `HPSystem.IsInvincible = true` → `InvincibleTime` 후 해제
8. **태그 스킬 발동:** 등장 캐릭터 고유 Entry Skill 실행
9. **쿨타임 시작:** `IsTagReady = false` → `TagCooldown` 후 복원

### 5-3. 데이터 스왑 대상
- `HPSystem`: CurrentHP ↔ 백업 HP
- `ReloadComponent`: CurrentAmmo(4슬롯) ↔ 백업 잔탄
- `WeaponSwapComponent`: CurrentWeaponSlot + 4슬롯 데이터 ↔ 백업
- `FireSystemComponent`: 현재 무기 스탯 교체

### 5-4. 동기화
- `CurrentCharIndex` Sync → 클라이언트에서 HUD(초상화, 체력바, 무기 아이콘) 전부 교체

---

## 6. 연동 컴포넌트

| 컴포넌트 | 연동 방식 | 설명 |
|---|---|---|
| `HPSystemComponent` | 데이터 스왑 + 무적 | HP 백업/로드, 교체 무적 |
| `ReloadComponent` | 데이터 스왑 + 재장전 취소 | 재장전 중이면 즉시 취소, 탄약 백업 |
| `WeaponSwapComponent` | 데이터 스왑 | 4슬롯 무기 상태 백업/로드 |
| `FireSystemComponent` | 무기 스탯 반영 | 교체 후 새 캐릭터의 무기 데이터 적용 |
| `MovementComponent` | `CanMove` 제어 | 태그 연출 중 이동 차단 (선택) |
| `GameManagerComponent` | 게임오버 연동 | 현재 캐릭터 사망 = 즉시 게임오버 |

---

## 7. 주의 사항

- [ ] **현재 캐릭터 사망 시 자동 태그 없음** — 즉시 게임오버 (기획서 확정)
- [ ] **대기 중 HP/탄창 회복 없음** — 상태 그대로 보존 (기획서 확정)
- [ ] **재장전 쿨타임은 백그라운드에서 흐름** — 대기 중에도 타이머 진행
- [ ] 벽 근처 태그 시 충돌체 크기 차이로 끼임 가능 → 위치 미세 보정 고려
- [ ] 태그 스킬(Entry Skill) 구체 내용은 캐릭터별 별도 기획 필요 → 인터페이스만 열어둘 것

---

## 8. Codex 구현 체크리스트

- [ ] `@Component` 어트리뷰트로 시작
- [ ] 밸런스 수치 전부 `property`로 선언
- [ ] `[server only]` / `[client only]` 분리
- [ ] `nil` 체크, `isValid` 방어 코드
- [ ] `기획서/4.부록/Code_Documentation.md` 업데이트
- [ ] 완료 후 상태 `🟢 완료`로 변경

---

## 메타 정보

| 항목 | 내용 |
|---|---|
| **작성자** | Antigravity (TD) |
| **담당자** | Codex |
| **작성일** | 2026-02-18 |
| **상태** | 🟡 대기중 |
