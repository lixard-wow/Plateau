local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets
local T = Style.T

local WIDTH, HEIGHT = 1280, 900
local RAIL = 204
local PAD = 18
local TITLE = math.max(Style.HEADER_HEIGHT, 58)
local STRIPE = 1
local TOP = TITLE + STRIPE
local PAGE_HEAD = 84
local PREVIEW = 232
local PREVIEW_BAR = 36
local FOOTER = 44
local SPACING = 6
local SCROLLBAR = 14
local CONTENT_WIDTH = WIDTH - RAIL - PAD * 2 - SCROLLBAR
local CARD_GAP = 14
local CARD_PAD = 16
local HALF_CARD = math.floor((CONTENT_WIDTH - CARD_GAP) / 2)
local COLUMN = HALF_CARD - CARD_PAD * 2
local WIDE_INNER = CONTENT_WIDTH - CARD_PAD * 2
local PAIR_GAP = WIDE_INNER - COLUMN * 2
local PREVIEW_TOP = TOP + PAGE_HEAD

ns.layout = {
    width = WIDTH, title = TOP, preview = PREVIEW - PREVIEW_BAR, pad = PAD, rail = RAIL, content = WIDE_INNER, column = COLUMN,
    previewTop = PREVIEW_TOP + PREVIEW_BAR, previewLeft = RAIL + PAD, previewRight = PAD + SCROLLBAR,
}

local Logic = ns.PageLogic

local frame = CreateFrame("Frame", "PlateauOptions", UIParent)
frame:SetSize(WIDTH, HEIGHT)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:Hide()
frame:SetScale(Style.Scale())
local frameEdge = Style.Rounded(frame, C.border, "BACKGROUND", -2)
frameEdge:SetAllPoints()
local frameFill = Style.Rounded(frame, C.window, "BACKGROUND", -1)
if Style.theme.innerFrame then
    local ring = CreateFrame("Frame", nil, frame)
    ring:SetPoint("TOPLEFT", 4, -4)
    ring:SetPoint("BOTTOMRIGHT", -4, 4)
    ring:SetFrameLevel(frame:GetFrameLevel() + 400)
    ring:EnableMouse(false)
    for _, edge in ipairs({ { "TOPLEFT", "TOPRIGHT", nil, 1 }, { "BOTTOMLEFT", "BOTTOMRIGHT", nil, 1 }, { "TOPLEFT", "BOTTOMLEFT", 1, nil }, { "TOPRIGHT", "BOTTOMRIGHT", 1, nil } }) do
        local line = ring:CreateTexture(nil, "OVERLAY")
        Style.Paint(line, C.line, 1)
        line:SetPoint(edge[1])
        line:SetPoint(edge[2])
        if edge[3] then line:SetWidth(edge[3]) end
        if edge[4] then line:SetHeight(edge[4]) end
    end
end
Style.PixelInset(frameFill, frame)
tinsert(UISpecialFrames, "PlateauOptions")

local OFFSCREEN_KEEP = 120

local KeepOnScreen

local function LooseClamp()
    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetClampedToScreen(false)
end

local function StopDrag()
    frame:StopMovingOrSizing()
    KeepOnScreen()
end

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT")
titleBar:SetPoint("TOPRIGHT")
titleBar:SetHeight(TITLE)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", StopDrag)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", StopDrag)

local titleCap = Style.Rounded(titleBar, C.rail, "BACKGROUND", -1)
titleCap:SetHeight(Style.RADIUS * 2)
local titleFill = titleBar:CreateTexture(nil, "BACKGROUND")
Style.Paint(titleFill, C.rail, 1)
Style.OnPixels(titleBar, function(px)
    titleCap:ClearAllPoints()
    titleCap:SetPoint("TOPLEFT", px, -px)
    titleCap:SetPoint("TOPRIGHT", -px, -px)
    titleFill:ClearAllPoints()
    titleFill:SetPoint("TOPLEFT", px, -(px + Style.RADIUS))
    titleFill:SetPoint("BOTTOMRIGHT", -px, 0)
end)

local logo = titleBar:CreateTexture(nil, "ARTWORK")
logo:SetSize(42, 42)
logo:SetPoint("LEFT", PAD, 0)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local TITLE_TEXT = Style.theme.uppercaseTitle and "PLATEAU" or "Plateau"
local titleName = Style.Text(titleBar, 18, C.title)
Style.SetFont(titleName, Style.titleFont, Style.TITLE_SIZE + 6, "")
titleName:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 3)
titleName:SetText(TITLE_TEXT)

local titleSub = Style.Text(titleBar, 11, C.muted)
titleSub:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 10, -1)
titleSub:SetText("Nameplates")

local titleVersion = Style.Text(titleBar, 11, C.muted)
titleVersion:SetPoint("LEFT", titleName, "RIGHT", 8, 0)
titleVersion:SetText(("v%s"):format(Plateau.version))

local stripe = CreateFrame("Frame", nil, frame)
Style.OnPixels(frame, function(px)
    stripe:ClearAllPoints()
    stripe:SetPoint("TOPLEFT", px, -TITLE)
    stripe:SetPoint("TOPRIGHT", -px, -TITLE)
end)
stripe:SetHeight(STRIPE)
local stripeLine = stripe:CreateTexture(nil, "ARTWORK")
stripeLine:SetPoint("TOPLEFT")
stripeLine:SetPoint("TOPRIGHT")
Style.PixelHeight(stripeLine)
Style.Paint(stripeLine, C.line)

local ICON_BUTTON = Style.ICON_BUTTON
local closeX = Style.IconButton(titleBar, "icon_close", ICON_BUTTON, function() frame:Hide() end, "Close", Style.theme.roundClose)
closeX:SetPoint("RIGHT", titleBar, "RIGHT", -12, 0)

local minimizeX = Style.IconButton(titleBar, "icon_minus", ICON_BUTTON, nil, "Minimize")
minimizeX:SetPoint("RIGHT", closeX, "LEFT", -6, 0)

local minimized = false

function KeepOnScreen()
    if minimized then return end
    local left, top, width = frame:GetLeft(), frame:GetTop(), frame:GetWidth()
    if not left or not top or not width then return end
    local ratio = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
    local screenWidth, screenHeight = UIParent:GetWidth() * ratio, UIParent:GetHeight() * ratio
    local fixedLeft = math.max(OFFSCREEN_KEEP - width, math.min(left, screenWidth - OFFSCREEN_KEEP))
    local fixedTop = math.max(TITLE, math.min(top, screenHeight))
    if fixedLeft ~= left or fixedTop ~= top then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", fixedLeft, fixedTop)
    end
end
local restoreHeight = HEIGHT
local SetMinimized

minimizeX:SetScript("OnClick", function() SetMinimized(not minimized) end)

local function OpenPreferences()
    if minimized and SetMinimized then
        SetMinimized(false)
    end
    ns.SelectSection("addon")
end

local settingsX = Style.IconButton(titleBar, Style.theme.settingsIcon, ICON_BUTTON, OpenPreferences, "Plateau settings: theme, window scale and fonts")
settingsX:SetPoint("RIGHT", minimizeX, "LEFT", -6, 0)

local undoSlot = CreateFrame("Frame", nil, titleBar)
undoSlot:SetSize(176, 30)
undoSlot:SetPoint("RIGHT", settingsX, "LEFT", -14, 0)
ns.layout.undoSlot = undoSlot

local BAR_WIDTH, BAR_HEIGHT = 340, 30
local BAR_ROW = -15
local CLICK_THRESHOLD = 4

local fullLeft, fullTop, fullRight
local miniDragging = false

local miniBar = CreateFrame("Frame", nil, frame)
miniBar:SetAllPoints(frame)
miniBar:EnableMouse(true)
miniBar:Hide()

local function ClampedBar(left, top)
    local scale = frame:GetScale()
    return Logic.ClampBar(left, top, UIParent:GetWidth() / scale, UIParent:GetHeight() / scale, BAR_WIDTH, BAR_HEIGHT)
end

local function PlaceBar(left, top)
    left, top = ClampedBar(left, top)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

local function SettleBar()
    local left, top = frame:GetLeft(), frame:GetTop()
    if left and top then
        PlaceBar(left, top)
    end
end

local function Draggable(target)
    target:RegisterForDrag("LeftButton")
    target:SetScript("OnDragStart", function()
        miniDragging = true
        frame:StartMoving()
    end)
    target:SetScript("OnDragStop", function()
        frame:StopMovingOrSizing()
        SettleBar()
        C_Timer.After(0, function() miniDragging = false end)
    end)
end
Draggable(miniBar)

local miniIcon = miniBar:CreateTexture(nil, "ARTWORK")
miniIcon:SetSize(18, 18)
miniIcon:SetPoint("LEFT", miniBar, "TOPLEFT", 8, BAR_ROW)
miniIcon:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local miniHit = CreateFrame("Button", nil, miniBar)
miniHit:SetPoint("TOPLEFT", 0, 0)
miniHit:SetSize(96, BAR_HEIGHT)
Draggable(miniHit)

local miniName = Style.Text(miniHit, 13, C.title)
Style.SetFont(miniName, Style.titleFont, Style.TITLE_SIZE, "")
miniName:SetPoint("LEFT", miniBar, "TOPLEFT", 32, BAR_ROW)
miniName:SetText(TITLE_TEXT)

Plateau.Brand:OnChange(function(r, g, b)
    logo:SetVertexColor(r, g, b)
    miniIcon:SetVertexColor(r, g, b)
end)

local miniDot = Style.Text(miniBar, 11, C.muted)
miniDot:SetPoint("LEFT", miniName, "RIGHT", 6, 0)
miniDot:SetText("\194\183")

local miniClose = Style.IconButton(miniBar, "icon_close", 20, function() frame:Hide() end, "Close", Style.theme.roundClose)
miniClose:SetPoint("RIGHT", miniBar, "TOPRIGHT", -6, BAR_ROW)

local miniRestore = Style.IconButton(miniBar, "icon_chevron_down", 20, function()
    if SetMinimized then
        SetMinimized(false)
    end
end, "Restore")
miniRestore:SetPoint("RIGHT", miniClose, "LEFT", -4, 0)

local miniInfo = CreateFrame("Button", nil, miniBar)
miniInfo:SetPoint("LEFT", miniDot, "RIGHT", 6, 0)
miniInfo:SetPoint("RIGHT", miniRestore, "LEFT", -8, 0)
miniInfo:SetHeight(BAR_HEIGHT)
miniInfo:EnableMouse(true)
Draggable(miniInfo)

local miniProfile = Style.Text(miniInfo, 11, C.muted)
miniProfile:SetPoint("LEFT", 0, 0)
miniProfile:SetPoint("RIGHT", 0, 0)
miniProfile:SetWordWrap(false)
miniProfile:SetJustifyH("LEFT")

local function ShowProfileTip(owner)
    local status = Plateau.AutoProfile:Status()
    GameTooltip:SetOwner(owner, "ANCHOR_BOTTOM")
    local accent = Style.StateColor()
    GameTooltip:SetText(T("Active profile: %s"):format(status.active), accent[1], accent[2], accent[3])
    if status.overridden then
        GameTooltip:AddLine(T("Default profile: %s"):format(status.default), 1, 1, 1, true)
        GameTooltip:AddLine(T("Active because of: %s"):format(T(tostring(status.rule or "an automatic switch"))), C.warn[1], C.warn[2], C.warn[3], true)
    end
    if status.pending then
        GameTooltip:AddLine(T("Switches to %s after combat."):format(status.pending), C.warn[1], C.warn[2], C.warn[3], true)
    end
    GameTooltip:AddLine(T("Click the profile to switch. Click the icon, name or Restore to reopen the settings. Drag to move."), 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
end

local function ShowProfileList(owner, alignRight)
    local options = {}
    for _, name in ipairs(Plateau.DB:ListProfiles()) do
        options[#options + 1] = { value = name, label = Plateau.Builtins.Label(name) }
    end
    ns.ShowList(owner, options, Plateau.DB.profileName, function(value)
        if value ~= Plateau.DB.profileName or value ~= Plateau.DB:DefaultProfile() then
            Plateau.DB:ActivateProfile(value)
            ns.UpdateProfileLabel()
            ns.RefreshAll()
        end
    end, { width = 220, alignRight = alignRight })
end

miniInfo:SetScript("OnEnter", function(self) ShowProfileTip(self) end)
miniInfo:SetScript("OnLeave", function() GameTooltip:Hide() end)
miniHit:HookScript("OnEnter", function(self) ShowProfileTip(self) end)
miniHit:HookScript("OnLeave", function() GameTooltip:Hide() end)
local pressX, pressY
miniHit:SetScript("OnMouseDown", function()
    pressX, pressY = GetCursorPosition()
end)
miniHit:SetScript("OnClick", function()
    local x, y = GetCursorPosition()
    if miniDragging or not Logic.IsClick(pressX, pressY, x, y, CLICK_THRESHOLD) then return end
    if SetMinimized then
        SetMinimized(false)
    end
end)

local infoPressX, infoPressY
miniInfo:SetScript("OnMouseDown", function()
    infoPressX, infoPressY = GetCursorPosition()
end)
miniInfo:SetScript("OnClick", function(self)
    local x, y = GetCursorPosition()
    if miniDragging or not Logic.IsClick(infoPressX, infoPressY, x, y, CLICK_THRESHOLD) then return end
    GameTooltip:Hide()
    ShowProfileList(self)
end)

function ns.UpdateMiniBar()
    local status = Plateau.AutoProfile:Status()
    if status.pending then
        miniProfile:SetFormattedText("%s (pending)", status.active)
    elseif status.overridden then
        miniProfile:SetFormattedText("%s (override)", status.active)
    else
        miniProfile:SetText(status.active)
    end
end

local screenWatcher = CreateFrame("Frame")
screenWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
screenWatcher:RegisterEvent("UI_SCALE_CHANGED")
screenWatcher:SetScript("OnEvent", function()
    Style.RefreshPixels()
    if minimized then
        local left, top = frame:GetLeft(), frame:GetTop()
        if left and top then
            PlaceBar(left, top)
        end
    end
end)

local profileButton = CreateFrame("Button", nil, titleBar)
profileButton:SetSize(200, 30)
Style.ButtonBox(profileButton, C.field, Style.BUTTON_RADIUS, C.border, C.hover)
local profile = Style.Text(profileButton, 12, C.text)
profile:SetPoint("LEFT", 12, 0)
profile:SetPoint("RIGHT", -26, 0)
Style.DropArrow(profileButton)
profileButton:SetScript("OnEnter", function(self)
    local status = Plateau.AutoProfile:Status()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    local accent = Style.StateColor()
    GameTooltip:SetText(T("Active profile: %s"):format(status.active), accent[1], accent[2], accent[3])
    GameTooltip:AddLine(T("Every page edits this profile. Click to switch, or manage profiles on the Profiles page."), 1, 1, 1, true)
    GameTooltip:AddLine(T("Default profile: %s"):format(status.default), 1, 1, 1, true)
    if status.overridden then
        GameTooltip:AddLine(T("Active because of: %s. Automatic switching can replace your choice when you change zone or specialization."):format(T(tostring(status.rule or "an automatic switch"))), C.warn[1], C.warn[2], C.warn[3], true)
    end
    if status.pending then
        GameTooltip:AddLine(T("Switches to %s after combat."):format(status.pending), C.warn[1], C.warn[2], C.warn[3], true)
    end
    GameTooltip:Show()
end)
profileButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
profileButton:SetScript("OnClick", function(self)
    GameTooltip:Hide()
    ShowProfileList(self, true)
end)

local themePicker = CreateFrame("Frame", nil, titleBar)
themePicker:SetSize(#Style.THEME_ORDER * 24 + 12, 30)
Style.Panel(themePicker, C.rail, C.border)
local themeDots = {}

local function PaintThemeDots()
    local chosenKey = Style.ThemeKey()
    for _, dot in ipairs(themeDots) do
        local chosen = dot.key == chosenKey
        Style.PaintVertex(dot.ring, chosen and C.text or dot.theme.colors.border)
        dot.core:SetSize(chosen and 10 or 8, chosen and 10 or 8)
    end
end

function ns.ApplyTheme(key)
    if key == Style.ThemeKey() or not Style.THEMES[key] then return end
    Style.SetTheme(key)
    PaintThemeDots()
    if ns.RefreshAll then
        ns.RefreshAll()
    end
end

for i, key in ipairs(Style.THEME_ORDER) do
    local theme = Style.THEMES[key]
    if theme then
        local dot = CreateFrame("Button", nil, themePicker)
        dot:SetSize(20, 20)
        dot:SetPoint("LEFT", 6 + (i - 1) * 24, 0)
        dot.key, dot.theme = key, theme
        dot.ring = Style.Rounded(dot, theme.colors.border, "ARTWORK", 0, "circle")
        dot.ring:SetAllPoints()
        local fill = Style.Rounded(dot, theme.colors.window, "ARTWORK", 1, "circle")
        fill:SetPoint("TOPLEFT", 2, -2)
        fill:SetPoint("BOTTOMRIGHT", -2, 2)
        dot.core = Style.Rounded(dot, theme.colors.accent, "ARTWORK", 2, "circle")
        dot.core:SetPoint("CENTER")
        dot:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(T(theme.name), 1, 1, 1)
            GameTooltip:AddLine(T(theme.desc or ""), 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine(T(key == Style.ThemeKey() and "The current settings window theme." or "Click to switch the settings window to this theme."), C.muted[1], C.muted[2], C.muted[3], true)
            GameTooltip:Show()
        end)
        dot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        dot:SetScript("OnClick", function(self)
            ns.ApplyTheme(key)
            self:GetScript("OnEnter")(self)
        end)
        themeDots[#themeDots + 1] = dot
    end
end
PaintThemeDots()

local rail = CreateFrame("Frame", nil, frame)
Style.OnPixels(frame, function(px)
    rail:ClearAllPoints()
    rail:SetPoint("TOPLEFT", px, -TOP)
    rail:SetPoint("BOTTOMLEFT", px, px)
end)
rail:SetWidth(RAIL)
Style.Rounded(rail, C.rail):SetAllPoints()
Style.SquareCorners(rail, C.rail, { "TOPLEFT", "TOPRIGHT", "BOTTOMRIGHT" })

local railEdge = rail:CreateTexture(nil, "ARTWORK")
railEdge:SetPoint("TOPRIGHT")
railEdge:SetPoint("BOTTOMRIGHT")
Style.PixelWidth(railEdge)
Style.Paint(railEdge, C.border, 1)

local pageHead = CreateFrame("Frame", nil, frame)
pageHead:SetPoint("TOPLEFT", RAIL + 1 + PAD, -TOP)
pageHead:SetPoint("TOPRIGHT", -(PAD + SCROLLBAR), -TOP)
pageHead:SetHeight(PAGE_HEAD)

local crumb = Style.Text(pageHead, 11, C.muted)
crumb:SetPoint("TOPLEFT", 0, -14)

local sectionTitle = Style.Text(pageHead, 18, C.title)
Style.SetFont(sectionTitle, Style.titleFont, Style.TITLE_SIZE + 10, "")
sectionTitle:SetPoint("TOPLEFT", crumb, "BOTTOMLEFT", 0, -6)

local sectionDesc = Style.Text(pageHead, 12, C.muted)
sectionDesc:SetPoint("TOPLEFT", sectionTitle, "BOTTOMLEFT", 0, -6)
sectionDesc:SetPoint("RIGHT", pageHead, "RIGHT", -330, 0)

local previewBox = CreateFrame("Frame", nil, frame)
previewBox:SetPoint("TOPLEFT", RAIL + 1 + PAD, -PREVIEW_TOP)
previewBox:SetPoint("TOPRIGHT", -(PAD + SCROLLBAR), -PREVIEW_TOP)
previewBox:SetHeight(PREVIEW)
Style.Panel(previewBox, C.surface, C.surfaceBorder)

local previewBar = CreateFrame("Frame", nil, previewBox)
Style.OnPixels(previewBox, function(px)
    previewBar:ClearAllPoints()
    previewBar:SetPoint("TOPLEFT", px, -px)
    previewBar:SetPoint("TOPRIGHT", -px, -px)
end)
previewBar:SetHeight(PREVIEW_BAR - 1)
local previewBarLine = previewBar:CreateTexture(nil, "ARTWORK")
previewBarLine:SetPoint("BOTTOMLEFT")
previewBarLine:SetPoint("BOTTOMRIGHT")
Style.PixelHeight(previewBarLine)
Style.Paint(previewBarLine, C.border, 1)
local previewLabel = Style.Text(previewBar, 11, C.muted)
previewLabel:SetPoint("LEFT", 14, 0)
previewLabel:SetText("LIVE PREVIEW")
local previewDot = previewBar:CreateTexture(nil, "ARTWORK")
previewDot:SetSize(7, 7)
previewDot:SetPoint("LEFT", previewLabel, "RIGHT", 10, 0)
previewDot:SetColorTexture(0.31, 0.82, 0.55, 1)
local previewNote = Style.Text(previewBar, 11, C.muted)
previewNote:SetPoint("LEFT", previewDot, "RIGHT", 6, 0)
previewNote:SetText("Changes show here and in game as you make them")

local previewStage = CreateFrame("Frame", nil, previewBox)
Style.OnPixels(previewBox, function(px)
    previewStage:ClearAllPoints()
    previewStage:SetPoint("TOPLEFT", px, -PREVIEW_BAR)
    previewStage:SetPoint("BOTTOMRIGHT", -px, px)
end)
previewStage:SetClipsChildren(true)
do
    local inner = math.max(Style.RADIUS - 1, 0)
    local stageFill = Style.Rounded(previewStage, C.window, "BACKGROUND", 0, inner)
    stageFill:SetAllPoints()
    Style.PaintVertex(stageFill, C.window, 1, 0.55)
    local stageTop = previewStage:CreateTexture(nil, "BACKGROUND", nil, 0)
    stageTop:SetPoint("TOPLEFT")
    stageTop:SetPoint("TOPRIGHT")
    stageTop:SetHeight(inner)
    Style.Paint(stageTop, C.window, 1, 0.55)
    local stageGlow = Style.Rounded(previewStage, { 1, 1, 1, 1 }, "BACKGROUND", 1, inner)
    stageGlow:SetPoint("BOTTOMLEFT")
    stageGlow:SetPoint("BOTTOMRIGHT")
    stageGlow:SetHeight(PREVIEW * 0.7)
    local function PaintGlow()
        local accent = C.accent
        stageGlow:SetGradient("VERTICAL", CreateColor(accent[1], accent[2], accent[3], 0.09), CreateColor(accent[1], accent[2], accent[3], 0))
    end
    PaintGlow()
    Style.OnTheme(PaintGlow)
    local stageDots = previewStage:CreateTexture(nil, "BACKGROUND", nil, 2)
    stageDots:SetPoint("TOPLEFT")
    stageDots:SetPoint("BOTTOMRIGHT", 0, inner)
    stageDots:SetTexture("Interface\\AddOns\\Plateau_Options\\Art\\dots", "REPEAT", "REPEAT")
    stageDots:SetHorizTile(true)
    stageDots:SetVertTile(true)
    Style.PaintVertex(stageDots, C.border, 0.9)
end

ns.previewBar, ns.previewStage = previewBar, previewStage

local SCROLL_TOP = PREVIEW_TOP + PREVIEW + 12
local BANNER = 26
local BANNER_TOP = SCROLL_TOP

local scroll = CreateFrame("ScrollFrame", nil, frame)
scroll:SetPoint("TOPLEFT", RAIL + 1 + PAD, -SCROLL_TOP)

local banner = CreateFrame("Frame", nil, frame)
banner:Hide()
banner:SetPoint("TOPLEFT", RAIL + 1 + PAD, -BANNER_TOP)
banner:SetPoint("TOPRIGHT", -(PAD + SCROLLBAR), -BANNER_TOP)
banner:SetHeight(BANNER)
banner.fill = banner:CreateTexture(nil, "BACKGROUND")
banner.fill:SetAllPoints()
Style.Paint(banner.fill, C.muted, 0.14)
banner.bar = banner:CreateTexture(nil, "ARTWORK")
banner.bar:SetPoint("TOPLEFT")
banner.bar:SetPoint("BOTTOMLEFT")
banner.bar:SetWidth(3)
Style.Paint(banner.bar, C.muted, 1)
banner.text = Style.Text(banner, 11, C.text)
banner.text:SetPoint("LEFT", 12, 0)
banner.text:SetPoint("RIGHT", -8, 0)
banner.text:SetText("On this page, search finds help topics only.")
scroll:SetPoint("BOTTOMRIGHT", -(PAD + SCROLLBAR), FOOTER + 6)
scroll:EnableMouseWheel(true)

local function Range(scroller)
    local child = scroller:GetScrollChild()
    local content = child and child:GetHeight()
    local view = scroller:GetHeight()
    if not content or issecretvalue(content) or issecretvalue(view) then
        return 0
    end
    return math.max(0, content - view)
end

local function Offset(scroller)
    local offset = scroller:GetVerticalScroll()
    if issecretvalue(offset) then
        return 0
    end
    return offset
end

local function Scrollbar(scroller, parent, gap)
    local track = CreateFrame("Frame", nil, parent)
    track:SetPoint("TOPLEFT", scroller, "TOPRIGHT", gap, 0)
    track:SetPoint("BOTTOMLEFT", scroller, "BOTTOMRIGHT", gap, 0)
    track:SetWidth(9)
    if gap < 0 then
        track:SetHitRectInsets(-gap, 0, 0, 0)
    end
    local trackLine = track:CreateTexture(nil, "ARTWORK")
    trackLine:SetPoint("TOP")
    trackLine:SetPoint("BOTTOM")
    trackLine:SetWidth(3)
    Style.Paint(trackLine, C.border, 0.6)

    local thumb = CreateFrame("Frame", nil, track)
    thumb:SetWidth(9)
    thumb:EnableMouse(true)
    local thumbFill = thumb:CreateTexture(nil, "OVERLAY")
    thumbFill:SetPoint("TOP")
    thumbFill:SetPoint("BOTTOM")
    thumbFill:SetWidth(3)
    Style.Themed(thumbFill, 0.55)

    local Update
    local dragging, dragStartY, dragStartScroll = false, 0, 0
    thumb:SetScript("OnMouseDown", function(self)
        dragging = true
        dragStartY = select(2, GetCursorPosition())
        dragStartScroll = Offset(scroller)
        self:SetScript("OnUpdate", function()
            local range = Range(scroller)
            local view = scroller:GetHeight()
            local size = math.max(24, view * view / (view + range))
            local travel = view - size
            if travel <= 0 or issecretvalue(range) or issecretvalue(view) then return end
            local _, y = GetCursorPosition()
            local delta = (dragStartY - y) / self:GetEffectiveScale()
            scroller:SetVerticalScroll(math.max(0, math.min(range, dragStartScroll + delta / travel * range)))
            Update()
        end)
    end)
    thumb:SetScript("OnMouseUp", function(self)
        dragging = false
        self:SetScript("OnUpdate", nil)
    end)
    thumb:SetScript("OnHide", function(self)
        dragging = false
        self:SetScript("OnUpdate", nil)
    end)
    track:Hide()
    scroller:HookScript("OnSizeChanged", function() Update() end)
    track:EnableMouse(true)
    track:SetScript("OnMouseDown", function(self, button)
        if dragging or thumb:IsMouseOver() then return end
        local range = Range(scroller)
        local view = scroller:GetHeight()
        if range <= 0 or issecretvalue(range) or issecretvalue(view) then return end
        local _, cursorY = GetCursorPosition()
        local top = self:GetTop()
        if issecretvalue(top) then return end
        local clickY = (top - cursorY / self:GetEffectiveScale())
        local size = math.max(24, view * view / (view + range))
        local travel = math.max(1, view - size)
        local target = (clickY - size / 2) / travel * range
        scroller:SetVerticalScroll(math.max(0, math.min(range, target)))
        Update()
    end)

    Update = function()
        if minimized then
            thumb:Hide()
            track:Hide()
            return
        end
        local view = scroller:GetHeight()
        local range = Range(scroller)
        if issecretvalue(view) or issecretvalue(range) or not view or view <= 0 or range <= 8 then
            thumb:Hide()
            track:Hide()
            return
        end
        local size = math.max(24, view * view / (view + range))
        thumb:SetHeight(size)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(view - size) * math.min(Offset(scroller), range) / range)
        thumb:Show()
        track:Show()
    end
    return Update, track, thumb
end

local UpdateThumb, scrollTrack, scrollThumb = Scrollbar(scroll, frame, 4)

scroll:SetScript("OnMouseWheel", function(self, delta)
    local target = Offset(self) - delta * 48
    self:SetVerticalScroll(math.max(0, math.min(Range(self), target)))
    UpdateThumb()
end)
scroll:SetScript("OnScrollRangeChanged", UpdateThumb)

local footer = CreateFrame("Frame", nil, frame)
footer:SetPoint("BOTTOMLEFT", RAIL + 1, 1)
footer:SetPoint("BOTTOMRIGHT", -1, 1)
footer:SetHeight(FOOTER)
local footerLine = footer:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("TOPLEFT")
footerLine:SetPoint("TOPRIGHT")
Style.PixelHeight(footerLine)
Style.Paint(footerLine, C.border, 1)

local footerText = Style.Text(footer, 12, C.muted)
footerText:SetPoint("LEFT", PAD, 0)
footerText:SetPoint("RIGHT", -250, 0)

local closeButton = Widgets.Button(footer, "Close", 100, function() frame:Hide() end)
closeButton:SetPoint("RIGHT", -PAD, 0)

local whatsNewButton = Widgets.Button(footer, "What's new", 110, function()
    if PlateauWhatsNew then
        PlateauWhatsNew:Open(nil)
    end
end)
whatsNewButton:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)

local Select, UpdateChrome, RevealRail, OpenRailFor

local Confirming = ns.Widgets.Confirm

local pages = {}
local resetSection, resetAll
local railButtons = {}
local current

local PAGE_TOP = 2

local WIDE = {
    Header = true,
    Note = true,
    Actions = true,
    Presets = true,
    LookCards = true,
    SpellList = true,
    PriorityList = true,
    ProfileStatus = true,
    ProfileActions = true,
    AutoProfiles = true,
    ShareProfile = true,
    Conflicts = true,
    Link = true,
}

local FLEXIBLE = { Header = true, Note = true, Link = true }

local function PlaceRow(row, x, top, lineHeight, stretch)
    if stretch then
        row.widget:SetHeight(lineHeight)
    end
    row.widget:ClearAllPoints()
    row.widget:SetPoint("TOPLEFT", x, -top)
    row.y = top
end

local function Divider(page, index)
    local line = page.dividers[index]
    if not line then
        if not page.lines then
            page.lines = CreateFrame("Frame", nil, page)
            page.lines:SetAllPoints()
            page.lines:SetFrameLevel(page:GetFrameLevel() + 1)
        end
        line = page.lines:CreateTexture(nil, "ARTWORK")
        Style.PixelWidth(line)
        Style.Paint(line, C.border, 1)
        page.dividers[index] = line
    end
    return line
end

local function ClearFocusIn(frame)
    local children = { frame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        if child.ClearFocus then
            child:ClearFocus()
        end
        ClearFocusIn(child)
    end
end

local function BuildShield(row)
    local spec = row.spec
    local shield = CreateFrame("Frame", nil, row.widget)
    shield:SetAllPoints(row.widget)
    shield:SetFrameLevel(row.widget:GetFrameLevel() + 40)
    shield:EnableMouse(true)
    shield:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local accent = Style.StateColor()
        GameTooltip:SetText(type(spec.label) == "string" and T(spec.label) or "", accent[1], accent[2], accent[3])
        GameTooltip:AddLine(T(Logic.DisabledReason(spec) or "Not used with the current settings."), 1, 1, 1, true)
        GameTooltip:Show()
    end)
    shield:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    row.shield = shield
    return shield
end

local DISABLED_ALPHA = 0.4

local function ApplyEnabled(row)
    if Logic.IsEnabled(row.spec) then
        if row.shield and row.shield:IsShown() then
            row.shield:Hide()
            row.widget:SetAlpha(1)
        end
        return
    end
    local shield = row.shield or BuildShield(row)
    if not shield:IsShown() then
        shield:Show()
        ClearFocusIn(row.widget)
    end
    row.widget:SetAlpha(DISABLED_ALPHA)
end

local function RowHeight(row)
    if FLEXIBLE[row.spec.type] or row.wide then
        return row.widget:GetHeight()
    end
    return row.naturalHeight
end

local function StackRows(page, rows, x, y, wide)
    local waiting
    local function EndLine(right)
        local height = waiting.naturalHeight
        if right then
            height = math.max(height, right.naturalHeight)
            PlaceRow(right, x + COLUMN + PAIR_GAP, y, height, true)
            page.dividerCount = page.dividerCount + 1
            local line = Divider(page, page.dividerCount)
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", x + COLUMN + PAIR_GAP / 2, -y)
            line:SetHeight(height)
            line:Show()
        end
        PlaceRow(waiting, x, y, height, true)
        waiting = nil
        y = y + height + SPACING
    end
    for _, row in ipairs(rows) do
        if row.widget:IsShown() then
            if not wide or row.wide then
                if waiting then
                    EndLine()
                end
                local height = RowHeight(row)
                PlaceRow(row, x, y, height, not row.wide and not FLEXIBLE[row.spec.type])
                y = y + height + SPACING
            elseif waiting then
                EndLine(row)
            else
                waiting = row
            end
        end
    end
    if waiting then
        EndLine()
    end
    return y
end

local function LayoutPage(page)
    page.dividerCount = 0
    for _, row in ipairs(page.rows) do
        local hidden = row.group ~= nil and page.collapsed[row.group] == true
        local visible = Logic.RowShown(row.spec, hidden)
        row.widget:SetShown(visible)
        if visible then
            ApplyEnabled(row)
        end
    end
    local y = PAGE_TOP
    local columns = { y, y }
    local function Bottom()
        return math.max(columns[1], columns[2])
    end
    for _, card in ipairs(page.cards) do
        local any = card.header ~= nil and card.header.widget:IsShown()
        if not any then
            for _, row in ipairs(card.rows) do
                if row.widget:IsShown() then
                    any = true
                    break
                end
            end
        end
        if card.frame then
            card.frame:SetShown(any)
        end
        if any then
            if not card.frame then
                local top = Bottom()
                local bottom = StackRows(page, card.rows, CARD_PAD, top, true)
                if bottom > top then
                    columns[1], columns[2] = bottom + CARD_GAP - SPACING, bottom + CARD_GAP - SPACING
                end
            else
                local left, top, width
                if card.wide then
                    left, top, width = 0, Bottom(), CONTENT_WIDTH
                else
                    local which = columns[2] < columns[1] and 2 or 1
                    left, top, width = (which - 1) * (HALF_CARD + CARD_GAP), columns[which], HALF_CARD
                    card.column = which
                end
                local inner = top + CARD_PAD - 4
                if card.header and card.header.widget:IsShown() then
                    local height = card.header.widget:GetHeight()
                    PlaceRow(card.header, left + CARD_PAD, inner, height)
                    inner = inner + height + SPACING
                end
                local bottom = StackRows(page, card.rows, left + CARD_PAD, inner, card.wide) - SPACING + CARD_PAD
                card.frame:ClearAllPoints()
                card.frame:SetPoint("TOPLEFT", left, -top)
                card.frame:SetSize(width, bottom - top)
                if card.wide then
                    columns[1], columns[2] = bottom + CARD_GAP, bottom + CARD_GAP
                else
                    columns[card.column] = bottom + CARD_GAP
                end
            end
        end
    end
    for i = page.dividerCount + 1, #page.dividers do
        page.dividers[i]:Hide()
    end
    page:SetHeight(Bottom() + PAD)
end

local function RefreshPage(page)
    for _, row in ipairs(page.rows) do
        if row.widget.Refresh and not (row.group and page.collapsed[row.group]) then
            row.widget:Refresh()
        end
    end
    LayoutPage(page)
end

local function ToggleGroup(page, index)
    local row = page.rows[index]
    local collapsed = not page.collapsed[index]
    page.collapsed[index] = collapsed
    Logic.SetCollapsed(page.sectionKey, row.spec, collapsed)
    row.widget:SetCollapsed(collapsed)
    RefreshPage(page)
    UpdateThumb()
end

local function ExpandGroup(page, index)
    if page.collapsed[index] then
        ToggleGroup(page, index)
    end
end

local function CardFrame(page)
    local card = CreateFrame("Frame", nil, page)
    card:SetFrameLevel(page:GetFrameLevel())
    Style.Panel(card, C.surface, C.surfaceBorder)
    return card
end

local function PlanCards(controls)
    local cards, cardOf = {}, {}
    local card = { rows = {}, indexes = {} }
    cards[1] = card
    for index, spec in ipairs(controls) do
        if spec.type == "Header" then
            card = { rows = {}, indexes = {}, headerIndex = index }
            cards[#cards + 1] = card
        else
            card.indexes[#card.indexes + 1] = index
            if (WIDE[spec.type] and not FLEXIBLE[spec.type]) or spec.wide == true then
                card.wide = true
            end
            if not card.headerIndex and spec.type ~= "Note" then
                card.boxed = true
            end
        end
        cardOf[index] = card
    end
    if cards[1].boxed then
        cards[1].wide = true
    end
    return cards, cardOf
end

local function BuildPage(section)
    local page = CreateFrame("Frame", nil, scroll)
    page:SetWidth(CONTENT_WIDTH)
    page.rows = {}
    page.dividers = {}
    page.sectionKey = section.key
    page.collapsed = {}
    local groups = Logic.AssignGroups(section.controls)
    local plan, cardOf = PlanCards(section.controls)

    for index, spec in ipairs(section.controls) do
        if spec.collapsible then
            spec.onToggle = function() ToggleGroup(page, index) end
            page.collapsed[index] = Logic.IsCollapsed(section.key, spec)
        end
        local widget = Widgets[spec.type](page, spec)
        if spec.collapsible then
            widget:SetCollapsed(page.collapsed[index])
        end
        local card = cardOf[index]
        local wide = WIDE[spec.type] or spec.wide == true
        local inCard = card.headerIndex ~= nil
        local width
        if spec.type == "Header" then
            width = (card.wide and WIDE_INNER or COLUMN)
        elseif wide then
            width = (inCard and not card.wide) and COLUMN or WIDE_INNER
        else
            width = COLUMN
        end
        widget:SetWidth(width)
        page.rows[index] = { widget = widget, spec = spec, y = 0, wide = wide, naturalHeight = widget:GetHeight(), group = groups[index] }
    end

    page.cards = {}
    for _, entry in ipairs(plan) do
        local card = { wide = entry.wide == true, rows = {} }
        for _, index in ipairs(entry.indexes) do
            card.rows[#card.rows + 1] = page.rows[index]
        end
        if entry.headerIndex then
            card.header = page.rows[entry.headerIndex]
        end
        if entry.headerIndex or entry.boxed then
            card.frame = CardFrame(page)
        end
        if card.header or #card.rows > 0 then
            page.cards[#page.cards + 1] = card
        end
    end

    LayoutPage(page)
    return page
end

function ns.UpdateClickAreas()
    local on = frame:IsShown() and ns.clickAreasOn == true
    Plateau.SetClickAreas(on, on)
    if ns.SetPreviewSection and current then
        ns.SetPreviewSection(current.key)
    end
end

local DESCRIPTIONS = {
    profiles = { desc = "Choose which profile this character uses, make new ones and share them." },
    health = { desc = "Size, texture, border and absorbs of the health bar." },
    healthColors = { desc = "How the health bar is colored: by reaction, class, unit type and threat." },
    healthText = { desc = "The health numbers on the bar and how they are written." },
    name = { desc = "The unit's name and the name of whoever it is targeting." },
    level = { desc = "The level number and when it shows." },
    castbar = { desc = "How enemy casts look, and whether your interrupt is back before the cast finishes." },
    threatText = { desc = "Threat colors and the threat percent for tanks and damage dealers." },
    enemyPower = { desc = "A small power bar for enemies that use mana, energy or rage." },
    classPower = { desc = "Your combo points, holy power, runes and other class resources." },
    forces = { desc = "How much each enemy adds to Mythic+ enemy forces." },
    showing = { desc = "Which nameplates show, and when." },
    size = { desc = "Plate sizes and how much bigger your target, casters and casting enemies get." },
    fading = { desc = "Fading for plates out of range, behind walls or not your target." },
    layering = { desc = "How overlapping nameplates spread out and stack." },
    clicking = { desc = "How big the clickable area of each plate is." },
    target = { desc = "How your current target stands out." },
    focus = { desc = "How your focus target stands out." },
    mouseover = { desc = "How the plate under your cursor stands out." },
    combat = { desc = "A separate, quieter look for nameplates out of combat." },
    auraAll = { desc = "Text, timers and tooltips shared by every aura group." },
    auraMine = { desc = "Your own debuffs on enemies." },
    auraCC = { desc = "Crowd control on enemies, such as stuns and fears." },
    auraPurge = { desc = "Buffs on enemies, such as ones you can purge or steal." },
    auraImportant = { desc = "Important auras that need your attention." },
    shield = { desc = "Warnings for important, defensive, enrage and magic buffs." },
    raidMarker = { desc = "Raid target icons like skull and cross." },
    quest = { desc = "Quest icons and quest progress on enemies." },
    classification = { desc = "The elite, rare and boss badge." },
    faction = { desc = "The Horde or Alliance icon on players." },
    friendly = { desc = "Nameplates for your group and other friendly units." },
    help = { desc = "Answers, commands and how to report a problem." },
    addon = { desc = "Preferences for this settings window. Not part of a profile." },
}

local GROUP_COLORS = {
    Profile = "setup",
    Nameplates = "look",
    Behavior = "highlights",
    Targets = "highlights",
    Auras = "casts",
    Icons = "setup",
    Friendly = "look",
}

local function GroupColor(label)
    local groups = Style.groupColors or {}
    return groups[GROUP_COLORS[label] or ""] or C.muted
end

local groupOf = {}

function Select(section)
    ns.HideDropdownList()
    if current then
        local currentPage = pages[current.key]
        if currentPage then
            currentPage:Hide()
        end
        if railButtons[current.key] then
            railButtons[current.key]:SetSelected(false)
        end
    end
    current = section
    Plateau.DB.saved.global.lastSection = section.key

    local page = pages[section.key]
    if not page then
        page = BuildPage(section)
        pages[section.key] = page
    end
    scroll:SetScrollChild(page)
    scroll:SetVerticalScroll(0)
    page:Show()
    RefreshPage(page)
    if OpenRailFor then
        OpenRailFor(section.key)
    end
    if railButtons[section.key] then
        railButtons[section.key]:SetSelected(true)
        RevealRail(railButtons[section.key])
    end
    local group = groupOf[section.key]
    crumb:SetText(group and group.label or "Plateau")
    sectionTitle:SetText(section.title)
    local about = DESCRIPTIONS[section.key]
    sectionDesc:SetText(about and about.desc or "")
    UpdateThumb()
    ns.UpdateClickAreas()
    UpdateChrome()
    if ns.PageChanged then
        ns.PageChanged()
    end
    if resetSection then
        resetSection:SetShown(not section.noReset)
        resetAll:SetShown(section.resetAll == true)
    end
    if ns.UpdatePickButtons then
        ns.UpdatePickButtons(section)
    end

end

local OFF_MENU = Logic.OFF_MENU

local RAIL_GROUPS = {
    { label = "Profile", keys = { "profiles" } },
    { label = "Nameplates", keys = { "health", "healthColors", "healthText", "name", "level", "castbar", "threatText", "enemyPower", "classPower", "forces" } },
    { label = "Behavior", keys = { "showing", "size", "fading", "layering", "clicking" } },
    { label = "Targets", keys = { "target", "focus", "mouseover", "combat" } },
    { label = "Auras", keys = { "auraAll", "auraMine", "auraCC", "auraPurge", "auraImportant", "shield" } },
    { label = "Icons", keys = { "raidMarker", "quest", "classification", "faction" } },
    { label = "Friendly", keys = { "friendly" } },
    { label = "Help", keys = { "help" } },
}
local RAIL_ROW = 24
local RAIL_HEADER = 30
local RAIL_TOP = 6

local railScroll = CreateFrame("ScrollFrame", nil, rail)
railScroll:SetPoint("TOPLEFT", 0, -(RAIL_TOP + 1))
railScroll:SetPoint("BOTTOMRIGHT", -1, 0)
railScroll:EnableMouseWheel(true)
local railContent = CreateFrame("Frame", nil, railScroll)
railContent:SetWidth(RAIL - 1)
railScroll:SetScrollChild(railContent)
local railBar = CreateFrame("Frame", nil, rail)
railBar:SetAllPoints()
railBar:SetFrameLevel(rail:GetFrameLevel() + 10)
local UpdateRailThumb = Scrollbar(railScroll, railBar, -5)
railScroll:SetScript("OnMouseWheel", function(self, delta)
    local target = Offset(self) - delta * RAIL_ROW * 2
    self:SetVerticalScroll(math.max(0, math.min(Range(self), target)))
    UpdateRailThumb()
end)
railScroll:SetScript("OnScrollRangeChanged", UpdateRailThumb)

function RevealRail(button)
    local view = railScroll:GetHeight()
    if not button.y or issecretvalue(view) then return end
    local offset = Offset(railScroll)
    local top, bottom = button.y - RAIL_HEADER, button.y + RAIL_ROW
    if top < offset then
        railScroll:SetVerticalScroll(math.max(0, top))
    elseif bottom > offset + view then
        railScroll:SetVerticalScroll(math.min(Range(railScroll), bottom - view))
    end
    UpdateRailThumb()
end

local sectionsByKey = {}
for _, section in ipairs(ns.sections) do
    sectionsByKey[section.key] = section
end

local function RailButton(section, tint)
    tint = tint or Style.StateColor()
    local button = CreateFrame("Button", nil, railContent)
    button:SetHeight(RAIL_ROW)

    local hover = Style.Rounded(button, C.hover, "BACKGROUND", 0, Style.BUTTON_RADIUS)
    hover:SetPoint("TOPLEFT", 8, 0)
    hover:SetPoint("BOTTOMRIGHT", -8, 0)
    hover:Hide()
    local marker = button:CreateTexture(nil, "ARTWORK")
    marker:SetPoint("TOPLEFT", 8, -3)
    marker:SetPoint("BOTTOMLEFT", 8, 3)
    marker:SetWidth(3)
    Style.Paint(marker, tint, 1)
    marker:Hide()
    button.marker = marker

    local label = Style.Text(button, 13, C.muted)
    label:SetPoint("LEFT", PAD + 4, 0)
    label:SetPoint("RIGHT", -10, 0)
    label:SetText(section.title)

    function button:SetSelected(selected)
        self.selected = selected
        marker:SetShown(selected)
        hover:SetShown(selected)
        local color = selected and C.text or C.muted
        Style.PaintText(label, color)
    end

    button:SetScript("OnEnter", function() hover:Show() end)
    button:SetScript("OnLeave", function(self) hover:SetShown(self.selected) end)
    button:SetScript("OnClick", function() Select(section) end)
    railButtons[section.key] = button
    return button
end

ns.railGroups = RAIL_GROUPS

resetSection = Widgets.Button(pageHead, "Reset this section", 150)
resetSection:SetPoint("BOTTOMRIGHT", 0, 14)
Confirming(resetSection, "Reset this section", function()
    if current.reset then
        current.reset()
    elseif type(current.group) == "table" then
        for _, group in ipairs(current.group) do
            Plateau.DB:Reset(group)
        end
    else
        Plateau.DB:Reset(current.group)
    end
    ns.RefreshAll()
end)

resetAll = Widgets.Button(pageHead, "Reset profile", 150)
resetAll:SetPoint("BOTTOMRIGHT", 0, 14)
resetAll:Hide()
Confirming(resetAll, "Reset profile", function()
    Plateau.DB:Reset(nil)
    if ns.RefreshAll then
        ns.RefreshAll()
    end
end)

local SNAP_ROOM = 94 + 22

local pickButtons = {}
for i = 1, 2 do
    local button = Widgets.Button(previewBar, "", 150)
    Style.DropArrow(button)
    button.tip = { label = "", tooltip = "" }
    Style.Tooltip(button, button.tip)
    button:Hide()
    pickButtons[i] = button
end

local function PickLabel(pick)
    local value = pick.get()
    for _, option in ipairs(pick.options) do
        if option.value == value then
            return option.label
        end
    end
    return tostring(value)
end

function ns.UpdatePickButtons(section)
    local picks = section and section.picks or {}
    local anchor, point = previewBar, "RIGHT"
    for i, button in ipairs(pickButtons) do
        local pick = picks[i]
        if pick then
            button.label:SetFormattedText("Preview: %s", T(PickLabel(pick)))
            button:SetWidth(button.label:GetStringWidth() + 34)
            button.tip.label = pick.label
            button.tip.tooltip = pick.tooltip
            button:ClearAllPoints()
            button:SetPoint("RIGHT", anchor, point, point == "RIGHT" and -SNAP_ROOM or -8, 0)
            button:SetScript("OnClick", function(self)
                ns.ShowList(self, pick.options, pick.get(), function(value)
                    pick.set(value)
                    ns.UpdatePickButtons(current)
                end, { width = 260, alignRight = true })
            end)
            button:Show()
            anchor, point = button, "LEFT"
        else
            button:Hide()
        end
    end
    previewNote:SetShown(not picks[1])
end

local railGroups = {}
local railLoose = {}
local openGroup

local function PlaceRailRow(row, y)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -y)
    row:SetPoint("TOPRIGHT", 0, -y)
    row.y = y
end

local function LayoutRail()
    local y = PAD / 2
    for _, group in ipairs(railGroups) do
        PlaceRailRow(group.header, y)
        y = y + RAIL_HEADER
        local open = openGroup == group
        group.header.arrow:SetRotation(open and 0 or math.pi / 2)
        for _, button in ipairs(group.buttons) do
            button:SetShown(open)
            if open then
                PlaceRailRow(button, y)
                y = y + RAIL_ROW
            end
        end
        if open then
            y = y + 6
        end
    end
    for _, button in ipairs(railLoose) do
        PlaceRailRow(button, y)
        y = y + RAIL_ROW
    end
    railContent:SetHeight(y + PAD / 2)
    UpdateRailThumb()
end

local function RailHeader(group, tint)
    local header = CreateFrame("Button", nil, railContent)
    header:SetHeight(RAIL_HEADER)
    local hover = Style.Rounded(header, C.hover, "BACKGROUND", 0, Style.BUTTON_RADIUS)
    hover:SetPoint("TOPLEFT", 8, -2)
    hover:SetPoint("BOTTOMRIGHT", -8, 2)
    hover:Hide()
    local mark = header:CreateTexture(nil, "ARTWORK")
    mark:SetSize(8, 8)
    mark:SetPoint("LEFT", PAD - 2, 0)
    Style.Paint(mark, tint, 1)
    local label = Style.Text(header, 11, C.muted)
    label:SetPoint("LEFT", mark, "RIGHT", 8, 0)
    label:SetText(T(group.label):upper())
    local arrow = header:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\AddOns\\Plateau_Options\\Art\\Icons\\icon_chevron_down")
    arrow:SetSize(10, 10)
    arrow:SetPoint("RIGHT", -14, 0)
    Style.PaintVertex(arrow, tint)
    header.arrow = arrow
    header:SetScript("OnEnter", function()
        hover:Show()
        Style.PaintText(label, C.text)
    end)
    header:SetScript("OnLeave", function()
        hover:Hide()
        Style.PaintText(label, C.muted)
    end)
    header:SetScript("OnClick", function()
        if openGroup == group then
            openGroup = nil
            LayoutRail()
            return
        end
        if current and groupOf[current.key] == group then
            openGroup = group
            LayoutRail()
            return
        end
        local remembered = Plateau.DB.saved.global.railLast
        local key = type(remembered) == "table" and remembered[group.label]
        Select(groupOf[key] == group and sectionsByKey[key] or group.buttons[1].section)
    end)
    return header
end

local placed = {}
for _, entry in ipairs(RAIL_GROUPS) do
    local group = { label = entry.label, buttons = {} }
    local tint = GroupColor(entry.label)
    for _, key in ipairs(entry.keys) do
        local section = sectionsByKey[key]
        if section then
            local button = RailButton(section, tint)
            button.section = section
            group.buttons[#group.buttons + 1] = button
            groupOf[key] = group
            placed[key] = true
        end
    end
    if #group.buttons > 0 then
        group.header = RailHeader(group, tint)
        railGroups[#railGroups + 1] = group
    end
end
for _, section in ipairs(ns.sections) do
    if not placed[section.key] and not OFF_MENU[section.key] then
        railLoose[#railLoose + 1] = RailButton(section)
    end
end

function OpenRailFor(key)
    local group = groupOf[key]
    if group then
        openGroup = group
        local global = Plateau.DB.saved.global
        if type(global.railLast) ~= "table" then
            global.railLast = {}
        end
        global.railLast[group.label] = key
    end
    LayoutRail()
end
LayoutRail()
local function FitHeight()
    if minimized then return end
    frame:SetHeight(math.min(HEIGHT, (UIParent:GetHeight() - 40) / frame:GetScale()))
    LooseClamp()
end
FitHeight()

function ns.ApplyScale()
    local old, new = frame:GetScale(), Style.Scale()
    if old == new then return end
    local left, right, top = frame:GetLeft(), frame:GetRight(), frame:GetTop()
    frame:SetScale(new)
    Style.RefreshPixels()
    FitHeight()
    if left and right and top and not minimized then
        local ratio = old / new
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", (left + right) / 2 * ratio, top * ratio)
    end
end

function ns.UpdateProfileLabel()
    local status = Plateau.AutoProfile:Status()
    if status.pending then
        profile:SetFormattedText("Profile: %s (pending)", status.active)
    elseif status.overridden then
        profile:SetFormattedText("Profile: %s (override)", status.active)
    else
        profile:SetFormattedText("Profile: %s", status.active)
    end
    footerText:SetFormattedText("Changes save to %s as you make them. Open this window any time with /plt.", status.active)
    ns.UpdateMiniBar()
end

Plateau.AutoProfile:OnChange(function()
    if not frame:IsShown() then return end
    ns.UpdateProfileLabel()
    if current and current.key == "profiles" and pages[current.key] then
        RefreshPage(pages[current.key])
    end
end)

function UpdateChrome()
    local helpPage = not minimized and current ~= nil and current.key == "help"
    banner:SetShown(helpPage)
    scroll:SetPoint("TOPLEFT", RAIL + 1 + PAD, -(helpPage and (BANNER_TOP + BANNER + 6) or SCROLL_TOP))
    UpdateThumb()
    if ns.RefreshChips then
        ns.RefreshChips()
    end
end

local refreshListeners = {}

function ns.OnRefresh(callback)
    refreshListeners[#refreshListeners + 1] = callback
end

function ns.RefreshAll()
    if current then
        local page = pages[current.key]
        if page then
            RefreshPage(page)
        end
    end
    UpdateChrome()
    for i = 1, #refreshListeners do
        refreshListeners[i]()
    end
end

local specWatcher = CreateFrame("Frame")
specWatcher:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
specWatcher:SetScript("OnEvent", function()
    if frame:IsShown() then
        ns.RefreshAll()
    end
end)

local cvarRefreshQueued = false
local cvarWatcher = CreateFrame("Frame")
cvarWatcher:RegisterEvent("CVAR_UPDATE")
cvarWatcher:SetScript("OnEvent", function()
    if cvarRefreshQueued or not frame:IsShown() then return end
    cvarRefreshQueued = true
    C_Timer.After(0, function()
        cvarRefreshQueued = false
        if frame:IsShown() then
            ns.RefreshAll()
        end
    end)
end)

function ns.SelectSection(key)
    for _, section in ipairs(ns.sections) do
        if section.key == key then
            Select(section)
            return
        end
    end
end

frame:SetScript("OnShow", function()
    Style.RefreshPixels()
    ns.UpdateProfileLabel()
    Select(current or sectionsByKey[Plateau.DB.saved.global.lastSection] or sectionsByKey.health or ns.sections[1])
    Plateau.RefreshDirtyPreviews()
end)

frame:SetScript("OnHide", function()
    ns.HideDropdownList()
    ns.clickAreasOn = false
    ns.UpdateClickAreas()
end)

function frame:Toggle()
    self:SetShown(not self:IsShown())
end

local flash = CreateFrame("Frame", nil, frame)
flash:SetFrameLevel(frame:GetFrameLevel() + 60)
Style.Border(flash, C.accent)
Style.ThemedBorder(flash)
local flashFill = Style.Fill(flash, { C.accent[1], C.accent[2], C.accent[3], 0.12 })
Style.Themed(flashFill, 0.12)
flash:Hide()
local flashToken = 0

local function Flash(widget)
    flash:ClearAllPoints()
    flash:SetPoint("TOPLEFT", widget, "TOPLEFT", -4, 2)
    flash:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", 4, -2)
    flash:SetAlpha(1)
    flashFill:Show()
    flash:Show()
    flashToken = flashToken + 1
    local token = flashToken
    C_Timer.After(1.8, function()
        if token == flashToken then
            flash:Hide()
        end
    end)
end

function ns.OpenSetting(sectionKey, index)
    ns.SelectSection(sectionKey)
    local page = pages[sectionKey]
    local row = page and page.rows[index]
    if not row then return end
    local group = row.group or (row.spec.collapsible and index or nil)
    if group then
        ExpandGroup(page, group)
    end
    C_Timer.After(0, function()
        local view = scroll:GetHeight()
        if not issecretvalue(view) and page:GetHeight() < row.y - 24 + view then
            page:SetHeight(row.y - 24 + view)
        end
        scroll:SetVerticalScroll(math.max(0, math.min(Range(scroll), row.y - 24)))
        UpdateThumb()
        Flash(row.widget)
    end)
end

function ns.OpenLink(target)
    if not target then return end
    for _, section in ipairs(ns.sections) do
        if section.key == target.section then
            local index
            if target.key then
                index = Logic.FindKeyed(section, target.key)
            else
                index = Logic.FindControl(section, target.label, true)
            end
            if index then
                ns.OpenSetting(section.key, index)
            else
                ns.SelectSection(section.key)
            end
            return
        end
    end
end

function ns.FlashTitle()
    C_Timer.After(0, function()
        Flash(sectionTitle)
    end)
end

local index = {}

local helpIndex = {}

local function BuildHelpIndex()
    for _, section in ipairs(ns.sections) do
        if section.key == "help" then
            for i, spec in ipairs(section.controls) do
                local topic = spec.helpTopic
                if topic then
                    helpIndex[#helpIndex + 1] = {
                        section = section,
                        index = i,
                        label = topic.title,
                        where = topic.category,
                        labelText = topic.title:lower(),
                        labelLocal = T(topic.title) ~= topic.title and T(topic.title):lower() or nil,
                        text = (topic.title .. " " .. (topic.keywords or "") .. " " .. topic.text .. " " .. topic.category):lower() .. Logic.LocalizedText(topic.title, topic.keywords, topic.text, topic.category),
                    }
                end
            end
        end
    end
end

local function BuildIndex()
    for _, entry in ipairs(Logic.BuildSettingsIndex(ns.sections)) do
        index[#index + 1] = entry
    end
end

local MAX_RESULTS = 12
local RESULTS_PAD = 5
local RESULT_ROW = 34

local box = CreateFrame("EditBox", nil, titleBar)
box:SetSize(320, 32)
box:SetPoint("LEFT", titleBar, "LEFT", RAIL + 1 + PAD, 0)
box:SetAutoFocus(false)
box:SetFontObject("GameFontHighlight")
box:SetTextInsets(30, 10, 0, 0)
Style.Field(box, C.field, C.border)

local glass = box:CreateTexture(nil, "ARTWORK")
glass:SetAtlas("common-search-magnifyingglass")
glass:SetSize(14, 14)
glass:SetPoint("LEFT", 10, 0)
Style.PaintVertex(glass, C.muted)

local placeholder = Style.Text(box, 12, C.muted)
placeholder:SetPoint("LEFT", 30, 0)
placeholder:SetText("Search settings")

local themeLabelGap = 12
themePicker:SetPoint("LEFT", box, "RIGHT", themeLabelGap + 4, 0)
profileButton:SetPoint("RIGHT", undoSlot, "LEFT", -12, 0)

ns.tour = { window = frame, menu = rail, search = box, profile = profileButton, minimize = minimizeX }

local results = CreateFrame("Frame", nil, frame)
results:SetFrameLevel(frame:GetFrameLevel() + 300)
results:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -4)
results:SetWidth(420)
results:EnableMouse(true)
Style.Panel(results, C.window, C.border)
results:Hide()

local empty = Style.Text(results, 11, C.muted)
empty:SetPoint("TOPLEFT", 12, -12)
empty:SetText("No settings match")

local rows = {}
local matches = {}
local highlighted = 1

local function Open(match)
    if not match then return end
    results:Hide()
    box:ClearFocus()
    ns.OpenSetting(match.section.key, match.index)
end

local function Highlight(which)
    highlighted = which
    for i, row in ipairs(rows) do
        row.hover:SetShown(i == which and row:IsShown())
    end
end

local function Row(i)
    local row = rows[i]
    if row then return row end
    row = CreateFrame("Button", nil, results)
    row:SetHeight(RESULT_ROW)
    row:SetPoint("TOPLEFT", 1, -(1 + RESULTS_PAD + (i - 1) * RESULT_ROW))
    row:SetPoint("TOPRIGHT", -1, -(1 + RESULTS_PAD + (i - 1) * RESULT_ROW))
    row.hover = Style.Fill(row, C.hover)
    row.hover:Hide()
    row.label = Style.Text(row, 12, C.text)
    row.label:SetPoint("TOPLEFT", 12, -5)
    row.label:SetPoint("RIGHT", -12, 0)
    row.where = Style.Text(row, 10, C.muted)
    row.where:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -3)
    row.where:SetPoint("RIGHT", -12, 0)
    row:SetScript("OnEnter", function() Highlight(i) end)
    row:SetScript("OnClick", function() Open(matches[i]) end)
    rows[i] = row
    return row
end


local function Search(query)
    wipe(matches)
    query = query:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if #query < 2 then
        results:Hide()
        return
    end
    if #index == 0 then
        BuildIndex()
    end
    if #helpIndex == 0 then
        BuildHelpIndex()
    end
    local onHelp = current ~= nil and current.key == "help"
    local source = onHelp and helpIndex or index
    empty:SetText(onHelp and "No help topics match" or "No settings match")
    local words = {}
    for word in query:gmatch("%S+") do
        words[#words + 1] = word
    end
    local scored = {}
    for _, entry in ipairs(source) do
        local spec = entry.where ~= "Page" and entry.section.controls[entry.index]
        local score = (not spec or Logic.RowShown(spec)) and Logic.SearchScore(entry, words, query)
        if score then
            scored[#scored + 1] = { entry = entry, score = score }
        end
    end
    table.sort(scored, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.entry.label < b.entry.label
    end)
    for i = 1, math.min(MAX_RESULTS, #scored) do
        matches[i] = scored[i].entry
    end

    for i = 1, math.max(#rows, #matches) do
        local match = matches[i]
        if match then
            local row = Row(i)
            row.label:SetText(match.label)
            row.where:SetText(match.where)
            row:Show()
        elseif rows[i] then
            rows[i]:Hide()
        end
    end
    empty:SetShown(#matches == 0)
    results:SetHeight(#matches > 0 and (#matches * RESULT_ROW + 2 + RESULTS_PAD * 2) or 36)
    results:Show()
    Highlight(1)
end

function ns.PageChanged()
    box:SetText("")
    results:Hide()
    placeholder:SetText(current and current.key == "help" and "Search help" or "Search settings")
    placeholder:SetShown(not box:HasFocus())
end

box:SetScript("OnTextChanged", function(self)
    local text = self:GetText()
    placeholder:SetShown(text == "" and not self:HasFocus())
    Search(text)
end)
box:SetScript("OnEditFocusGained", function()
    placeholder:Hide()
    Search(box:GetText())
end)
box:SetScript("OnEditFocusLost", function(self)
    placeholder:SetShown(self:GetText() == "")
    C_Timer.After(0.2, function()
        if not box:HasFocus() and not results:IsMouseOver() then
            results:Hide()
        end
    end)
end)
box:SetScript("OnEnterPressed", function()
    Open(matches[highlighted] or matches[1])
end)
box:SetScript("OnEscapePressed", function(self)
    self:SetText("")
    self:ClearFocus()
    results:Hide()
end)
box:SetScript("OnArrowPressed", function(_, key)
    if #matches == 0 then return end
    if key == "DOWN" then
        Highlight(highlighted % #matches + 1)
    elseif key == "UP" then
        Highlight((highlighted - 2) % #matches + 1)
    end
end)

frame:HookScript("OnHide", function()
    results:Hide()
    box:ClearFocus()
end)

function SetMinimized(min)
    if minimized == min then return end
    minimized = min
    if min then
        restoreHeight = frame:GetHeight()
        fullLeft, fullTop, fullRight = frame:GetLeft(), frame:GetTop(), frame:GetRight()
        for _, child in ipairs({ frame:GetChildren() }) do
            if child ~= miniBar and child ~= flash then
                child.plateauWasShown = child:IsShown()
                child:Hide()
            end
        end
        flash:Hide()
        results:Hide()
        scrollTrack:Hide()
        scrollThumb:Hide()
        frame:SetSize(BAR_WIDTH, BAR_HEIGHT)
        frame:SetClampRectInsets(0, 0, 0, 0)
        frame:SetClampedToScreen(true)
        PlaceBar((fullRight or BAR_WIDTH) - BAR_WIDTH, fullTop or UIParent:GetHeight() / frame:GetScale())
        miniBar:Show()
        ns.UpdateMiniBar()
    else
        miniBar:Hide()
        for _, child in ipairs({ frame:GetChildren() }) do
            if child.plateauWasShown then
                child:Show()
            end
        end
        frame:SetSize(WIDTH, restoreHeight)
        LooseClamp()
        if fullLeft and fullTop then
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", fullLeft, fullTop)
        end
        UpdateThumb()
        if ns.RefreshPreviewEditing then
            ns.RefreshPreviewEditing()
            C_Timer.After(0, ns.RefreshPreviewEditing)
        end
    end
end

frame:HookScript("OnHide", function()
    SetMinimized(false)
    ns.Widgets.HidePrompts()
end)
