# Phase 5: Sound Components 완전 가이드

> **학습 완료일**: 2026-02-08  
> **Components 수**: 1개  
> **카테고리**: Sound System

---

## 📊 Phase 5 통계

| Component | Properties | Methods | Events | 용도 |
|-----------|-----------|---------|--------|------|
| **SoundComponent** | 11 | 14 | 1 | 효과음/BGM 재생 |
| **총계** | **11** | **14** | **1** | - |

---

## 🔊 Sound System 개요

MapleStory Worlds의 사운드 시스템은 **SoundComponent**를 통해 효과음과 배경음악을 재생합니다.

### 핵심 메커니즘
1. **SoundComponent**: 음원 재생, 볼륨/피치 조절, 3D 사운드
2. **리스너 시스템**: 거리 기반 볼륨 조절
3. **동기화 사운드**: 모든 플레이어에게 동기화된 재생

### 사운드 재생 흐름
```
SoundComponent
    ↓ AudioClipRUID 설정
    ↓ Volume, Pitch, Loop 설정
    ↓ SetListenerEntity() (3D 사운드)
    ↓ Play() / PlaySyncedSound()
    ↓ 음원 재생
    ↓ SoundPlayStateChangedEvent 발생
```

---

## 1. SoundComponent

### 📝 개요
- **용도**: 효과음 또는 배경음악 재생 및 관리
- **필수도**: ⭐⭐⭐⭐⭐ (사운드 시스템 필수)
- **핵심 기능**: 음원 재생/정지, 3D 사운드, 동기화 재생

### Properties (11개)

#### 음원 설정
| Property | Type | Sync | 범위 | 설명 |
|----------|------|------|------|------|
| `AudioClipRUID` | string | ✅ | - | 재생할 음원 리소스 ID |
| `Bgm` | boolean | ✅ | - | 배경음악 여부 (true: BGM, false: 효과음) |
| `Loop` | boolean | ✅ | - | 반복 재생 여부 |
| `PlayOnEnable` | boolean | ✅ | - | Enable 활성화 시 자동 재생 |

#### 볼륨 & 피치
| Property | Type | Sync | 범위 | 설명 |
|----------|------|------|------|------|
| `Volume` | float | ✅ | 0.0 ~ 1.0 | 음량 (0: 무음, 1: 최대) |
| `Pitch` | float | ✅ | 0.0 ~ 3.0 | 음높이 & 재생 속도 (1: 기본, 높을수록 빠름) |
| `Mute` | boolean | ✅ | - | 음소거 상태 |

#### 3D 사운드
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `HearingDistance` | float | ✅ | 리스너와의 최대 청취 거리 |
| `SetCameraAsListener` | boolean | ✅ | 화면 중앙을 리스너로 설정 (거리 기반 볼륨 조절) |

#### BGM 특수 설정
| Property | Type | Sync | 설명 |
|----------|------|------|------|
| `KeepBGM` | boolean | ✅ | 이전 BGM과 동일하면 이어서 재생 (Bgm=true, PlayOnEnable=true 시) |

**Inherited from Component:**
- `Enable`, `EnableInHierarchy`, `Entity`

### Methods (14개)

#### 재생 제어
```lua
void Play(string targetUserId = nil)  [Client]
    -- 음원 재생
    -- targetUserId: 특정 플레이어만 재생 (nil: 모든 플레이어)

void Pause(string targetUserId = nil)  [Client]
    -- 음원 일시 정지

void Resume(string targetUserId = nil)  [Client]
    -- 음원 재생 재개

void Stop(string targetUserId = nil)  [Client]
    -- 음원 정지
```

#### 동기화 재생
```lua
void PlaySyncedSound()  [Server]
    -- 모든 플레이어에게 동기화된 음원 재생
    -- Bgm=true면 작동하지 않음

void StopSyncedSound()  [Server]
    -- 동기화 음원 정지
```

#### 재생 상태 확인
```lua
boolean IsPlaying(string targetUserId = nil)  [Client]
    -- 음원 재생 중인지 확인

boolean IsSyncedPlaying()  [ClientOnly]
    -- 동기화 음원 재생 중인지 확인
    -- PlaySyncedSound() 호출 후 StopSyncedSound() 전까지 true
```

#### 재생 위치 제어
```lua
float GetTimePosition()  [ClientOnly]
    -- 현재 재생 위치 (초 단위)
    -- 오디오 클립 미로드 시 -1 반환

float GetTotalTime()  [ClientOnly]
    -- 음원 전체 길이 (초 단위)
    -- 오디오 클립 미로드 시 -1 반환

void SetTimePosition(float timeInSecond, string targetUserId = nil)  [Client]
    -- 재생 위치 변경 (초 단위)
    -- 오디오 클립 미로드 시 동작하지 않음
```

#### 오디오 클립 상태
```lua
boolean IsAudioClipLoaded()  [ClientOnly]
    -- AudioClipRUID 음원이 로드되었는지 확인
    -- GetTimePosition(), GetTotalTime(), SetTimePosition() 사용 전 확인 필요
```

#### 3D 사운드 설정
```lua
void SetListenerEntity(Entity entity, string targetUserId = nil)  [Client]
    -- 리스너 엔티티 설정
    -- 리스너와의 거리가 멀수록 음량 감소
    -- SetCameraAsListener보다 우선
```

**Inherited from Component:**
- `boolean IsClient()`, `boolean IsServer()`

### Events (1개)

| Event | 발생 조건 | Space |
|-------|----------|-------|
| `SoundPlayStateChangedEvent` | SoundService BGM 또는 SoundComponent 효과음 재생 상태 변경 시 | Client |

### 사용 패턴

#### 기본 효과음 재생
```lua
[client only]
void OnBeginPlay()
{
    local sound = self.Entity.SoundComponent
    
    -- 음원 설정
    sound.AudioClipRUID = "jump_sound_ruid"
    sound.Volume = 0.8
    sound.Pitch = 1.0
    sound.Loop = false
    
    -- 재생
    sound:Play()
}
```

#### 3D 사운드 (거리 기반)
```lua
[client only]
void OnBeginPlay()
{
    local sound = self.Entity.SoundComponent
    
    -- 음원 설정
    sound.AudioClipRUID = "ambient_sound_ruid"
    sound.Loop = true
    sound.HearingDistance = 50  -- 50 거리까지 들림
    
    -- 로컬 플레이어를 리스너로 설정
    sound:SetListenerEntity(_UserService.LocalPlayer)
    
    -- 재생
    sound:Play()
}
```

#### BGM 재생
```lua
[client only]
void OnBeginPlay()
{
    local sound = self.Entity.SoundComponent
    
    -- BGM 설정
    sound.Bgm = true
    sound.AudioClipRUID = "bgm_ruid"
    sound.Volume = 0.5
    sound.Loop = true
    sound.PlayOnEnable = true
    sound.KeepBGM = true  -- 같은 BGM이면 이어서 재생
}
```

#### 동기화 사운드 (모든 플레이어)
```lua
[server only]
void PlayExplosionSound()
{
    local sound = self.Entity.SoundComponent
    
    sound.AudioClipRUID = "explosion_sound_ruid"
    sound.Volume = 1.0
    
    -- 모든 플레이어에게 동기화 재생
    sound:PlaySyncedSound()
}

[server only]
void StopExplosionSound()
{
    self.Entity.SoundComponent:StopSyncedSound()
}
```

#### 재생 위치 제어
```lua
[client only]
void SkipToMiddle()
{
    local sound = self.Entity.SoundComponent
    
    -- 오디오 클립 로드 확인
    if sound:IsAudioClipLoaded() then
        local totalTime = sound:GetTotalTime()
        local middleTime = totalTime / 2
        
        -- 중간 지점으로 이동
        sound:SetTimePosition(middleTime)
    else
        log("Audio clip not loaded yet")
    end
}

[client only]
void ShowProgress()
{
    local sound = self.Entity.SoundComponent
    
    if sound:IsAudioClipLoaded() then
        local current = sound:GetTimePosition()
        local total = sound:GetTotalTime()
        local progress = (current / total) * 100
        
        log("Progress: " .. progress .. "%")
    end
}
```

---

## 🎯 Phase 5 핵심 패턴

### 1. 효과음 시스템
```lua
-- 점프 효과음
[server only] [self]
HandlePlayerActionEvent(PlayerActionEvent event)
{
    if event.ActionName == "Jump" then
        local sound = self.Entity.SoundComponent
        sound.AudioClipRUID = "jump_sound_ruid"
        sound.Volume = 0.7
        sound:Play()
    end
}
```

### 2. 거리 기반 3D 사운드
```lua
-- 폭포 소리 (가까이 갈수록 커짐)
[client only]
void OnBeginPlay()
{
    local sound = self.Entity.SoundComponent
    
    sound.AudioClipRUID = "waterfall_sound_ruid"
    sound.Loop = true
    sound.HearingDistance = 100
    sound.Volume = 1.0
    
    -- 플레이어를 리스너로 설정
    sound:SetListenerEntity(_UserService.LocalPlayer)
    sound:Play()
}
```

### 3. 조건부 BGM 전환
```lua
-- 전투 시작 시 BGM 변경
[client only]
void StartBattle()
{
    local sound = self.Entity.SoundComponent
    
    sound.Bgm = true
    sound.AudioClipRUID = "battle_bgm_ruid"
    sound.Loop = true
    sound.Volume = 0.6
    sound.KeepBGM = false  -- 새 BGM으로 교체
    
    sound:Play()
}

[client only]
void EndBattle()
{
    local sound = self.Entity.SoundComponent
    
    sound.AudioClipRUID = "normal_bgm_ruid"
    sound.KeepBGM = false
    
    sound:Play()
}
```

### 4. 피치 변화 효과
```lua
-- 속도에 따라 피치 변화
[client only]
void OnUpdate(number delta)
{
    local speed = self.Entity.MovementComponent.InputSpeed
    local sound = self.Entity.SoundComponent
    
    -- 속도가 빠를수록 피치 높아짐 (0.5 ~ 2.0)
    sound.Pitch = 0.5 + (speed / 10) * 1.5
}
```

### 5. 페이드 인/아웃
```lua
-- 볼륨 페이드 아웃
[client only]
void FadeOut(number duration)
{
    local sound = self.Entity.SoundComponent
    local startVolume = sound.Volume
    local elapsed = 0
    
    while elapsed < duration do
        wait(0.1)
        elapsed = elapsed + 0.1
        
        local progress = elapsed / duration
        sound.Volume = startVolume * (1 - progress)
    end
    
    sound:Stop()
    sound.Volume = startVolume  -- 원래 볼륨으로 복원
}

-- 볼륨 페이드 인
[client only]
void FadeIn(number duration)
{
    local sound = self.Entity.SoundComponent
    local targetVolume = sound.Volume
    
    sound.Volume = 0
    sound:Play()
    
    local elapsed = 0
    while elapsed < duration do
        wait(0.1)
        elapsed = elapsed + 0.1
        
        local progress = elapsed / duration
        sound.Volume = targetVolume * progress
    end
}
```

### 6. 특정 플레이어만 재생
```lua
-- 특정 플레이어에게만 효과음 재생
[server only]
void PlaySoundToPlayer(string userId)
{
    local sound = self.Entity.SoundComponent
    
    sound.AudioClipRUID = "notification_sound_ruid"
    sound:Play(userId)  -- 해당 플레이어만 들음
}
```

### 7. 재생 상태 모니터링
```lua
-- 음원 재생 완료 감지
[client only]
void WaitForSoundEnd()
{
    local sound = self.Entity.SoundComponent
    
    sound.Loop = false
    sound:Play()
    
    -- 재생 완료까지 대기
    while sound:IsPlaying() do
        wait(0.1)
    end
    
    log("Sound finished playing")
    self:OnSoundComplete()
}
```

### 8. 동기화 사운드 + 이벤트
```lua
-- 모든 플레이어에게 동기화된 카운트다운 사운드
[server only]
void PlayCountdown()
{
    for i = 3, 1, -1 do
        local sound = self.Entity.SoundComponent
        sound.AudioClipRUID = "countdown_" .. i .. "_ruid"
        sound:PlaySyncedSound()
        
        wait(1)
    end
    
    -- 시작 사운드
    local startSound = self.Entity.SoundComponent
    startSound.AudioClipRUID = "start_sound_ruid"
    startSound:PlaySyncedSound()
    
    self:StartGame()
}
```

---

## 🔗 관련 서비스 & 이벤트

### 관련 서비스
- **SoundService**: 전역 BGM 재생
  - `PlayBGM(audioClipRUID, volume, loop)`
  - `StopBGM()`
  - `SetBGMVolume(volume)`

### 관련 이벤트
- **SoundPlayStateChangedEvent**: 재생 상태 변경 시
  - `IsPlaying`: 재생 중 여부
  - `SoundType`: BGM 또는 효과음

### 관련 컴포넌트
- **UserService**: 로컬 플레이어 접근 (`LocalPlayer`)

---

## 💡 Best Practices

### 1. 오디오 클립 로드 확인
```lua
-- 재생 위치 제어 전 반드시 확인
if sound:IsAudioClipLoaded() then
    sound:SetTimePosition(10)
else
    log("Wait for audio clip to load")
end
```

### 2. Client vs Server
- **Play/Pause/Resume/Stop**: Client 함수 (targetUserId로 특정 플레이어 지정 가능)
- **PlaySyncedSound/StopSyncedSound**: Server 함수 (모든 플레이어 동기화)

### 3. BGM vs 효과음
- **BGM**: `Bgm=true`, `Loop=true`, `KeepBGM=true`
- **효과음**: `Bgm=false`, `Loop=false`

### 4. 3D 사운드 설정
- `SetListenerEntity()` > `SetCameraAsListener` (우선순위)
- `HearingDistance`로 최대 청취 거리 제한

### 5. 성능 최적화
- 불필요한 Loop 사운드는 `Stop()` 호출
- 동기화 사운드는 필요할 때만 사용 (네트워크 부하)

---

## 📋 다음 단계

Phase 5 완료! 다음은:
- **Phase 6**: UI Advanced Components (5개) - ScrollViewComponent, SliderComponent 등
- **Phase 7**: Physics Components (4개) - RigidbodyComponent, ColliderComponent 등

---

> **학습 완료**: 2026-02-08  
> **참고**: BGMComponent, FootstepSoundComponent는 API 문서가 존재하지 않아 제외되었습니다.  
> **다음 목표**: Phase 6 - UI Advanced Components 학습
