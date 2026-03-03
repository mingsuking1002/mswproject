# 🟢 완료

---

**[Codex용 작업 명세서]**

* **Component Name:** `ControlsGuideComponent`
* **Execution Space:** `[Client Only]`

---

## §1. 개요

로비 화면에 **"조작법"** 버튼을 추가하고, 클릭 시 2페이지 이미지 가이드 패널을 표시한다.
화살표 버튼(◀ ▶)으로 페이지 전환, "나가기" 버튼으로 닫기.
**페이지 내용은 텍스트 없이 이미지(Sprite)만 사용.** PD가 준비한 이미지 RUID를 Maker에서 직접 설정.

---

## §2. Properties

```
property string GuidePanelPath       = "/ui/MainGroup/GRGuidePanel"
property string GuideOpenButtonPath  = "/ui/MainGroup/GRGuideOpenButton"
property string GuideCloseButtonPath = "/ui/MainGroup/GRGuidePanel/GRGuideCloseButton"
property string PrevButtonPath       = "/ui/MainGroup/GRGuidePanel/GRGuidePrevButton"
property string NextButtonPath       = "/ui/MainGroup/GRGuidePanel/GRGuideNextButton"
property string Page1Path            = "/ui/MainGroup/GRGuidePanel/GRGuidePage1"
property string Page2Path            = "/ui/MainGroup/GRGuidePanel/GRGuidePage2"
property string PageIndicatorPath    = "/ui/MainGroup/GRGuidePanel/GRGuidePageIndicator"
property integer CurrentPage         = 1
property integer TotalPages          = 2
```

---

## §3. Required MSW Services

- `_EntityService` — UI 엔티티 참조
- `ButtonClickEvent` — 버튼 이벤트 연결

---

## §4. 연동 컴포넌트

- `LobbyFlowComponent` — `IsLobbyActive` 확인용 (로비 상태일 때만 열기 버튼 표시)

---

## §5. Logic Architecture

### 초기화 (`OnBeginPlay` — ClientOnly)
1. `GRGuidePanel` → `Enable = false, Visible = false`
2. `GRGuideOpenButton`에 ButtonClickEvent 연결 → `OpenGuideClient()`
3. `GRGuideCloseButton`에 ButtonClickEvent 연결 → `CloseGuideClient()`
4. `GRGuidePrevButton`에 ButtonClickEvent 연결 → `PrevPageClient()`
5. `GRGuideNextButton`에 ButtonClickEvent 연결 → `NextPageClient()`
6. `CurrentPage = 1`, 페이지 표시 갱신

### `OpenGuideClient()`
```
GRGuidePanel.Enable = true
GRGuidePanel.Visible = true
CurrentPage = 1
ShowPage(1)
```

### `CloseGuideClient()`
```
GRGuidePanel.Enable = false
GRGuidePanel.Visible = false
```

### `NextPageClient()` / `PrevPageClient()`
```
CurrentPage += 1 (또는 -1), clamp(1, TotalPages)
ShowPage(CurrentPage)
```

### `ShowPage(pageIndex)`
```
Page1.Enable = (pageIndex == 1)
Page1.Visible = (pageIndex == 1)
Page2.Enable = (pageIndex == 2)
Page2.Visible = (pageIndex == 2)
PrevButton.Enable = (pageIndex > 1)
NextButton.Enable = (pageIndex < TotalPages)
PageIndicator.Text = pageIndex .. " / " .. TotalPages
```

---

## §6. Maker 배치 — UI 엔티티 (MainGroup)

> **반드시 Maker UI에서 직접 생성.** 외부 파일 생성 금지.

### 6-1. `GRGuideOpenButton` — 조작법 열기 버튼
| 항목 | 값 |
|---|---|
| **부모** | `/ui/MainGroup` |
| **모델** | UIButton |
| **displayOrder** | 5 (GRBG 위, StartButton 아래) |
| **위치** | 하단 왼쪽 영역 `-700, -400` |
| **크기** | `240 × 70` |
| **TextComponent.Text** | `"조작법"` |
| **TextComponent.FontSize** | 28 |
| **TextComponent.Bold** | true |
| **TextComponent.FontColor** | 흰색 |
| **SpriteGUI.Color** | 반투명 검정 `(0,0,0,0.7)` |
| **Enable/Visible** | true (로비 시) |

### 6-2. `GRGuidePanel` — 가이드 패널 (컨테이너)
| 항목 | 값 |
|---|---|
| **부모** | `/ui/MainGroup` |
| **모델** | UISprite (배경) |
| **displayOrder** | 10 (최상단) |
| **Anchors** | Center |
| **위치** | `0, 0` (화면 정중앙) |
| **크기** | `900 × 600` |
| **SpriteGUI.Color** | 반투명 검정 `(0.05, 0.05, 0.05, 0.92)` |
| **Enable/Visible** | false (초기 비활성) |

### 6-3. `GRGuideCloseButton` — 나가기 버튼
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UIButton |
| **위치** | 우측 상단 `310, 255` |
| **크기** | `160 × 50` |
| **Text** | `"나가기"` |
| **FontSize** | 24, Bold |
| **SpriteGUI.Color** | `(0.3, 0.3, 0.3, 0.9)` |

### 6-4. `GRGuidePage1` — 1페이지 이미지
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UISprite |
| **위치** | `0, 0` (패널 중앙) |
| **크기** | `800 × 480` |
| **SpriteGUIRenderer.ImageRUID** | *(PD가 Maker에서 직접 설정)* |
| **SpriteGUIRenderer.ImageSizeMode** | Fit |
| **Enable/Visible** | true (초기 활성) |

### 6-5. `GRGuidePage2` — 2페이지 이미지
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UISprite |
| **위치** | `0, 0` (패널 중앙) |
| **크기** | `800 × 480` |
| **SpriteGUIRenderer.ImageRUID** | *(PD가 Maker에서 직접 설정)* |
| **SpriteGUIRenderer.ImageSizeMode** | Fit |
| **Enable/Visible** | false (초기 비활성) |

### 6-6. `GRGuidePrevButton` — ◀ 이전 페이지
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UIButton |
| **위치** | 좌측 중앙 `-400, 0` |
| **크기** | `60 × 80` |
| **Text** | `"◀"` |
| **FontSize** | 32, Bold |
| **Enable** | false (1페이지에서 비활성) |

### 6-7. `GRGuideNextButton` — ▶ 다음 페이지
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UIButton |
| **위치** | 우측 중앙 `400, 0` |
| **크기** | `60 × 80` |
| **Text** | `"▶"` |
| **FontSize** | 32, Bold |

### 6-8. `GRGuidePageIndicator` — 페이지 표시
| 항목 | 값 |
|---|---|
| **부모** | `GRGuidePanel` |
| **모델** | UIText |
| **위치** | 하단 중앙 `0, -260` |
| **크기** | `120 × 40` |
| **Text** | `"1 / 2"` |
| **FontSize** | 22, 흰색 |
| **Alignment** | MiddleCenter |

---

## §7. 스크립트 생성

### Maker에서 생성
1. Workspace → MyDesk → ProjectGR → Components → UI
2. **Create Scripts → Create Component** → 이름: `ControlsGuideComponent`
3. 아래 코드 전체를 Script Editor에 붙여넣기
4. DefaultPlayer **또는** 게임 로비 엔티티에 부착

### 코드 뼈대

```lua
@Component
script ControlsGuideComponent extends Component

    property string GuidePanelPath = "/ui/MainGroup/GRGuidePanel"
    property string GuideOpenButtonPath = "/ui/MainGroup/GRGuideOpenButton"
    property string GuideCloseButtonPath = "/ui/MainGroup/GRGuidePanel/GRGuideCloseButton"
    property string PrevButtonPath = "/ui/MainGroup/GRGuidePanel/GRGuidePrevButton"
    property string NextButtonPath = "/ui/MainGroup/GRGuidePanel/GRGuideNextButton"
    property string Page1Path = "/ui/MainGroup/GRGuidePanel/GRGuidePage1"
    property string Page2Path = "/ui/MainGroup/GRGuidePanel/GRGuidePage2"
    property string PageIndicatorPath = "/ui/MainGroup/GRGuidePanel/GRGuidePageIndicator"

    @ExecSpace("ClientOnly")
    method void OnBeginPlay()
        self._T.CurrentPage = 1
        self._T.TotalPages = 2
        self._T.OpenHandler = nil
        self._T.CloseHandler = nil
        self._T.PrevHandler = nil
        self._T.NextHandler = nil
        self:CloseGuideClient()
        self:BindButtonsClient()
    end

    @ExecSpace("ClientOnly")
    method void BindButtonsClient()
        -- 열기 버튼
        local openBtn = _EntityService:GetEntityByPath(self.GuideOpenButtonPath)
        if openBtn ~= nil and isvalid(openBtn) == true then
            if openBtn.ButtonComponent == nil then
                pcall(function() openBtn:AddComponent("MOD.Core.ButtonComponent") end)
            end
            if openBtn.ButtonComponent ~= nil and self._T.OpenHandler == nil then
                local ok, handler = pcall(function()
                    return openBtn:ConnectEvent(ButtonClickEvent, function()
                        self:OpenGuideClient()
                    end)
                end)
                if ok == true then self._T.OpenHandler = handler end
            end
        end

        -- 닫기 버튼
        local closeBtn = _EntityService:GetEntityByPath(self.GuideCloseButtonPath)
        if closeBtn ~= nil and isvalid(closeBtn) == true then
            if closeBtn.ButtonComponent == nil then
                pcall(function() closeBtn:AddComponent("MOD.Core.ButtonComponent") end)
            end
            if closeBtn.ButtonComponent ~= nil and self._T.CloseHandler == nil then
                local ok, handler = pcall(function()
                    return closeBtn:ConnectEvent(ButtonClickEvent, function()
                        self:CloseGuideClient()
                    end)
                end)
                if ok == true then self._T.CloseHandler = handler end
            end
        end

        -- 이전 버튼
        local prevBtn = _EntityService:GetEntityByPath(self.PrevButtonPath)
        if prevBtn ~= nil and isvalid(prevBtn) == true then
            if prevBtn.ButtonComponent == nil then
                pcall(function() prevBtn:AddComponent("MOD.Core.ButtonComponent") end)
            end
            if prevBtn.ButtonComponent ~= nil and self._T.PrevHandler == nil then
                local ok, handler = pcall(function()
                    return prevBtn:ConnectEvent(ButtonClickEvent, function()
                        self:PrevPageClient()
                    end)
                end)
                if ok == true then self._T.PrevHandler = handler end
            end
        end

        -- 다음 버튼
        local nextBtn = _EntityService:GetEntityByPath(self.NextButtonPath)
        if nextBtn ~= nil and isvalid(nextBtn) == true then
            if nextBtn.ButtonComponent == nil then
                pcall(function() nextBtn:AddComponent("MOD.Core.ButtonComponent") end)
            end
            if nextBtn.ButtonComponent ~= nil and self._T.NextHandler == nil then
                local ok, handler = pcall(function()
                    return nextBtn:ConnectEvent(ButtonClickEvent, function()
                        self:NextPageClient()
                    end)
                end)
                if ok == true then self._T.NextHandler = handler end
            end
        end
    end

    @ExecSpace("ClientOnly")
    method void OpenGuideClient()
        local panel = _EntityService:GetEntityByPath(self.GuidePanelPath)
        if panel == nil or isvalid(panel) == false then return end
        pcall(function()
            panel.Enable = true
            panel.Visible = true
        end)
        self._T.CurrentPage = 1
        self:ShowPageClient(1)
    end

    @ExecSpace("ClientOnly")
    method void CloseGuideClient()
        local panel = _EntityService:GetEntityByPath(self.GuidePanelPath)
        if panel ~= nil and isvalid(panel) == true then
            pcall(function()
                panel.Enable = false
                panel.Visible = false
            end)
        end
    end

    @ExecSpace("ClientOnly")
    method void NextPageClient()
        local page = self._T.CurrentPage + 1
        if page > self._T.TotalPages then page = self._T.TotalPages end
        self._T.CurrentPage = page
        self:ShowPageClient(page)
    end

    @ExecSpace("ClientOnly")
    method void PrevPageClient()
        local page = self._T.CurrentPage - 1
        if page < 1 then page = 1 end
        self._T.CurrentPage = page
        self:ShowPageClient(page)
    end

    @ExecSpace("ClientOnly")
    method void ShowPageClient(integer pageIndex)
        local page1 = _EntityService:GetEntityByPath(self.Page1Path)
        local page2 = _EntityService:GetEntityByPath(self.Page2Path)

        if page1 ~= nil and isvalid(page1) == true then
            pcall(function()
                page1.Enable = (pageIndex == 1)
                page1.Visible = (pageIndex == 1)
            end)
        end
        if page2 ~= nil and isvalid(page2) == true then
            pcall(function()
                page2.Enable = (pageIndex == 2)
                page2.Visible = (pageIndex == 2)
            end)
        end

        -- 화살표 활성/비활성
        local prevBtn = _EntityService:GetEntityByPath(self.PrevButtonPath)
        if prevBtn ~= nil and isvalid(prevBtn) == true then
            pcall(function()
                prevBtn.Enable = (pageIndex > 1)
                prevBtn.Visible = (pageIndex > 1)
            end)
        end
        local nextBtn = _EntityService:GetEntityByPath(self.NextButtonPath)
        if nextBtn ~= nil and isvalid(nextBtn) == true then
            pcall(function()
                nextBtn.Enable = (pageIndex < self._T.TotalPages)
                nextBtn.Visible = (pageIndex < self._T.TotalPages)
            end)
        end

        -- 페이지 인디케이터
        local indicator = _EntityService:GetEntityByPath(self.PageIndicatorPath)
        if indicator ~= nil and isvalid(indicator) == true then
            pcall(function()
                indicator.TextComponent.Text = tostring(pageIndex) .. " / " .. tostring(self._T.TotalPages)
            end)
        end
    end

end
```

---

## §8. 주의/최적화 포인트

- **Client Only** — 서버 부하 0. 모든 로직이 클라이언트에서 실행.
- 버튼 바인딩은 `OnBeginPlay` 1회만 수행, 이벤트 핸들러 중복 등록 방지(`_T.OpenHandler ~= nil` 체크).
- 패널 닫을 때 `Enable = false`로 raycast 차단 → 게임플레이 입력 방해 없음.

---

## §9. 기획서 참조

- PD 직접 지시. 이미지 자료는 PD가 준비 완료, Maker에서 RUID 직접 설정.

---

## §10. 구현 방식

**MCP + Maker 직접 작업:**
1. Maker에서 §6의 UI 엔티티를 **MainGroup 하위에 수동 생성**
2. Maker에서 §7 절차대로 `ControlsGuideComponent` 스크립트 생성
3. DefaultPlayer 엔티티에 `ControlsGuideComponent` 부착
