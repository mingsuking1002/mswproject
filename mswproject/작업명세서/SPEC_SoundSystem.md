# 🟡 대기중

---

**[Codex용 작업 명세서]**

## 상태 이력

| 일시 | 상태 |
|---|---|
| 2026-03-03 | 🟡 대기중 |

---

## 1. 개요

① **무기 발사 사운드**: WeaponData에 `fire_sound_ruid` 컬럼 추가, 발사 시 해당 사운드 재생.
② **게임 BGM**: Property로 RUID 설정 가능, 게임 시작 시 루프 재생.

---

## 2. 수정 대상 파일

### ① [MODIFY] WeaponData.csv
- 신규 컬럼: `fire_sound_ruid` (STRING) — 무기별 발사 사운드 RUID
- 신규 컬럼: `fire_sound_volume` (FLOAT, 기본 1.0) — 볼륨 (선택)

### ② [MODIFY] FireSystemComponent.mlua
**Execution Space:** [둘 다] — 사운드 재생은 Client, 사운드 RUID 결정은 Server

**Properties 추가:**
- `(string) CurrentFireSoundRuid = "" // @Sync, WeaponData에서 로드된 발사 사운드 RUID`
- `(number) CurrentFireSoundVolume = 1.0 // 발사 사운드 볼륨`

**Logic:**
- `TryFireServer` → 발사 성공 후 `PlayFireSoundClient(shooterPosition)` RPC 호출
- `PlayFireSoundClient`: `_SoundService:PlaySound(self.CurrentFireSoundRuid, self.CurrentFireSoundVolume, userId)` 실행

**WeaponData 로드 연동:**
- `WeaponSwapComponent.ApplyWeaponDataToFireServer()` 내에서 `fire_sound_ruid` 읽어서 `FireSystemComponent.CurrentFireSoundRuid`에 설정

### ③ [MODIFY] WeaponSwapComponent.mlua
- `ApplyWeaponDataToFireServer()` 또는 무기 장착 시 WeaponData row에서 `fire_sound_ruid` 읽기
- `fireComponent.CurrentFireSoundRuid = row:GetItem("fire_sound_ruid")`

### ④ [NEW] BGMManagerComponent.mlua
**Execution Space:** [Client Only]

**Properties:**
- `(string) BGMRuid = "" // 게임 BGM 사운드 RUID (Maker에서 변경 가능)`
- `(number) BGMVolume = 0.5 // BGM 볼륨`
- `(boolean) BGMLoop = true // 반복 재생`
- `(boolean) AutoPlayOnStart = true // 게임 시작 시 자동 재생`

**Logic:**
- `OnBeginPlay` (Client): `AutoPlayOnStart == true`이면 `_SoundService:PlaySound(self.BGMRuid, self.BGMVolume)`
- 루프 재생: `_SoundService` 루프 옵션 또는 종료 감지 후 재호출
- `StopBGM()` / `PlayBGM()` 외부 호출 가능 (PauseGame 시 BGM 정지 등)

---

## 3. Required MSW Services

- `_SoundService` — `PlaySound(RUID, volume, userId)`, `PlaySoundAtPos(RUID, pos, listener, volume, userId)`

---

## 4. 연동 컴포넌트

| 컴포넌트 | 연동 방식 |
|---|---|
| WeaponSwapComponent | WeaponData row → `fire_sound_ruid` 읽어서 FireSystem에 설정 |
| FireSystemComponent | 발사 성공 시 사운드 재생 RPC |
| GameTimerComponent | PauseGame 시 BGM 정지, ResumeGame 시 재시작 (선택) |

---

## 5. 기획서 참조

- PD 구두 지시 (2026-03-03): "무기 공격 사운드 WeaponData 연동, 게임 BGM Property 설정 가능"

---

## 6. 구현 방식

mcp 이용해서 직접 workspace에서 작업

---

## 7. 주의/최적화 포인트

- **발사 사운드**: 피격 사운드(`ProjectileComponent.TryPlayMonsterHitSoundAtServer`) 패턴 참고 — `_SoundService:PlaySound` 사용
- **BGM 루프**: MSW `_SoundService`에 루프 옵션 없을 경우 → `_TimerService`로 BGM 길이만큼 대기 후 재호출
- **BGMRuid는 Maker Property로 노출** → PD가 직접 RUID 변경 가능
- WeaponData.csv에 사운드 RUID가 비어있으면 사운드 미재생 (방어)
