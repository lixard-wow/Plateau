local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH, HEIGHT = 1150, 856
local RAIL = 168
local RAIL_TOP = 8
local PAD = 16
local TITLE = Style.HEADER_HEIGHT
local PREVIEW = 196
local FOOTER = 44
local SPACING = 4
local CONTENT_WIDTH = WIDTH - RAIL - PAD * 2 - 12
local COLUMN_GAP = 24
local COLUMN = math.floor((CONTENT_WIDTH - COLUMN_GAP) / 2)

ns.layout = { width = WIDTH, title = TITLE, preview = PREVIEW, pad = PAD, rail = RAIL, content = CONTENT_WIDTH, column = COLUMN }

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
        line:SetColorTexture(C.line[1], C.line[2], C.line[3], 1)
        line:SetPoint(edge[1])
        line:SetPoint(edge[2])
        if edge[3] then line:SetWidth(edge[3]) end
        if edge[4] then line:SetHeight(edge[4]) end
    end
end
frameFill:SetPoint("TOPLEFT", 1, -1)
frameFill:SetPoint("BOTTOMRIGHT", -1, 1)
tinsert(UISpecialFrames, "PlateauOptions")

local OFFSCREEN_KEEP = 120

local function LooseClamp()
    local width, height = frame:GetWidth(), frame:GetHeight()
    local side = math.max(width - OFFSCREEN_KEEP, 0)
    frame:SetClampRectInsets(side, -side, 0, math.max(height - TITLE, 0))
end

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT")
titleBar:SetPoint("TOPRIGHT")
titleBar:SetHeight(TITLE)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

if Style.theme.headerFill then
    local titleCap = Style.Rounded(titleBar, C.header, "BACKGROUND", -1)
    titleCap:SetPoint("TOPLEFT", 1, -1)
    titleCap:SetPoint("TOPRIGHT", -1, -1)
    titleCap:SetHeight(Style.RADIUS * 2)
    local titleFill = titleBar:CreateTexture(nil, "BACKGROUND")
    titleFill:SetPoint("TOPLEFT", 1, -(1 + Style.RADIUS))
    titleFill:SetPoint("BOTTOMRIGHT", -1, 0)
    titleFill:SetColorTexture(C.header[1], C.header[2], C.header[3], 1)
end

local logo = titleBar:CreateTexture(nil, "ARTWORK")
logo:SetSize(32, 32)
logo:SetPoint("LEFT", PAD, 0)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local TITLE_TEXT = Style.theme.uppercaseTitle and "PLATEAU" or "Plateau"
local titleName = Style.Text(titleBar, 18, C.title)
Style.SetFont(titleName, Style.titleFont, Style.TITLE_SIZE + 4, "")
titleName:SetPoint("LEFT", logo, "RIGHT", 10, 0)
titleName:SetText(TITLE_TEXT)

local titleVersion = Style.Text(titleBar, 11, C.muted)
titleVersion:SetPoint("LEFT", titleName, "RIGHT", 8, -1)
titleVersion:SetText(("v%s"):format(Plateau.version))

local ICON_BUTTON = Style.ICON_BUTTON
local closeX = Style.IconButton(titleBar, "icon_close", ICON_BUTTON, function() frame:Hide() end, "Close", Style.theme.roundClose)
closeX:SetPoint("RIGHT", titleBar, "RIGHT", -8, 0)

local minimizeX = Style.IconButton(titleBar, "icon_minus", ICON_BUTTON, nil, "Minimize")
minimizeX:SetPoint("RIGHT", closeX, "LEFT", -6, 0)

local minimized = false
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

local cpuText = Style.Text(titleBar, 11, C.muted)
cpuText:SetPoint("RIGHT", settingsX, "LEFT", -14, 0)
cpuText:SetJustifyH("RIGHT")

local cpuButton = CreateFrame("Button", nil, titleBar)
cpuButton:SetAllPoints(cpuText)
cpuButton:SetScript("OnClick", function()
    if ns.OpenLink then
        ns.OpenLink({ section = "help", key = "diagnostics" })
    end
end)
Style.Tooltip(cpuButton, { label = "Plateau CPU", tooltip = "Click to open Diagnostics on the Help page for the full performance numbers." })

local function UpdateCpu()
    local ms, percent = Plateau.CpuReadout()
    if ms then
        cpuText:SetText(("Plateau CPU  %.3f ms (%.1f%%)"):format(ms, percent))
    else
        cpuText:SetText("")
    end
end

local cpuTicker
local cpuWatcher = CreateFrame("Frame", nil, titleBar)
cpuWatcher:SetScript("OnShow", function()
    UpdateCpu()
    if not cpuTicker then
        cpuTicker = C_Timer.NewTicker(2, UpdateCpu)
    end
end)
cpuWatcher:SetScript("OnHide", function()
    if cpuTicker then
        cpuTicker:Cancel()
        cpuTicker = nil
    end
end)

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
    GameTooltip:SetText("Active profile: " .. status.active, accent[1], accent[2], accent[3])
    if status.overridden then
        GameTooltip:AddLine("Default profile: " .. status.default, 1, 1, 1, true)
        GameTooltip:AddLine("Active because of: " .. tostring(status.rule or "an automatic switch"), C.warn[1], C.warn[2], C.warn[3], true)
    end
    if status.pending then
        GameTooltip:AddLine("Pending switch: " .. status.pending .. " after combat ends.", C.warn[1], C.warn[2], C.warn[3], true)
    end
    GameTooltip:AddLine("Click the profile to switch to another one. Click the icon or name, or Restore, to bring the settings back. Drag anywhere else to move this bar.", 0.7, 0.7, 0.7, true)
    GameTooltip:Show()
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
    local options = {}
    for _, name in ipairs(Plateau.DB:ListProfiles()) do
        options[#options + 1] = { value = name, label = Plateau.Builtins.Label(name) }
    end
    ns.ShowList(self, options, Plateau.DB.profileName, function(value)
        if value ~= Plateau.DB.profileName or value ~= Plateau.DB:DefaultProfile() then
            Plateau.DB:ActivateProfile(value)
            ns.UpdateProfileLabel()
            ns.RefreshAll()
        end
    end, { width = 220 })
end)

function ns.UpdateMiniBar()
    local status = Plateau.AutoProfile:Status()
    local text = status.active
    if status.pending then
        text = text .. " (pending)"
    elseif status.overridden then
        text = text .. " (auto)"
    end
    miniProfile:SetText(text)
end

local screenWatcher = CreateFrame("Frame")
screenWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
screenWatcher:RegisterEvent("UI_SCALE_CHANGED")
screenWatcher:SetScript("OnEvent", function()
    if minimized then
        local left, top = frame:GetLeft(), frame:GetTop()
        if left and top then
            PlaceBar(left, top)
        end
    end
end)

local titleLine = Style.GradientLine(titleBar, { C.line, C.line }, 1)
titleLine:SetPoint("BOTTOMLEFT", 1, 0)
titleLine:SetPoint("BOTTOMRIGHT", -1, 0)

local rail = CreateFrame("Frame", nil, frame)
rail:SetPoint("TOPLEFT", 1, -TITLE)
rail:SetPoint("BOTTOMLEFT", 1, 1)
rail:SetWidth(RAIL)
Style.Rounded(rail, C.rail):SetAllPoints()
Style.SquareCorners(rail, C.rail, { "TOPLEFT", "TOPRIGHT", "BOTTOMRIGHT" })

local railEdge = rail:CreateTexture(nil, "ARTWORK")
railEdge:SetPoint("TOPRIGHT")
railEdge:SetPoint("BOTTOMRIGHT")
railEdge:SetWidth(1)
railEdge:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)


local SECTION_BAR = 36

local sectionBar = CreateFrame("Frame", nil, frame)
sectionBar:SetPoint("TOPLEFT", RAIL + 1, -(TITLE + PREVIEW))
sectionBar:SetPoint("TOPRIGHT", -1, -(TITLE + PREVIEW))
sectionBar:SetHeight(SECTION_BAR)
Style.Fill(sectionBar, C.rail)

local sectionBarLine = sectionBar:CreateTexture(nil, "ARTWORK")
sectionBarLine:SetPoint("BOTTOMLEFT")
sectionBarLine:SetPoint("BOTTOMRIGHT")
sectionBarLine:SetHeight(1)
sectionBarLine:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)

local sectionTitle = Style.Text(sectionBar, 15, C.text)
sectionTitle:SetPoint("LEFT", PAD, 0)

local SCROLL_TOP = TITLE + PREVIEW + SECTION_BAR + 4
local BANNER = 26
local BANNER_TOP = TITLE + PREVIEW + SECTION_BAR + 10

local scroll = CreateFrame("ScrollFrame", nil, frame)
scroll:SetPoint("TOPLEFT", RAIL + PAD, -SCROLL_TOP)

local banner = CreateFrame("Frame", nil, frame)
banner:Hide()
banner:SetPoint("TOPLEFT", RAIL + PAD, -BANNER_TOP)
banner:SetPoint("TOPRIGHT", -(PAD + 8), -BANNER_TOP)
banner:SetHeight(BANNER)
banner.fill = banner:CreateTexture(nil, "BACKGROUND")
banner.fill:SetAllPoints()
banner.fill:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 0.14)
banner.bar = banner:CreateTexture(nil, "ARTWORK")
banner.bar:SetPoint("TOPLEFT")
banner.bar:SetPoint("BOTTOMLEFT")
banner.bar:SetWidth(3)
banner.bar:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 1)
banner.text = Style.Text(banner, 11, C.text)
banner.text:SetPoint("LEFT", 12, 0)
banner.text:SetPoint("RIGHT", -8, 0)
banner.text:SetText("Help. The search box above searches only these topics.")
scroll:SetPoint("BOTTOMRIGHT", -(PAD + 8), FOOTER)
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
    trackLine:SetColorTexture(C.border[1], C.border[2], C.border[3], 0.6)

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
        local range = Range(scroller)
        if range <= 8 then
            thumb:Hide()
            track:Hide()
            return
        end
        local view = scroller:GetHeight()
        local size = math.max(24, view * view / (view + range))
        thumb:SetHeight(size)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(view - size) * math.min(Offset(scroller), range) / range)
        thumb:Show()
        track:Show()
    end
    return Update, track, thumb
end

local UpdateThumb, scrollTrack, scrollThumb = Scrollbar(scroll, frame, 6)

scroll:SetScript("OnMouseWheel", function(self, delta)
    local target = Offset(self) - delta * 48
    self:SetVerticalScroll(math.max(0, math.min(Range(self), target)))
    UpdateThumb()
end)
scroll:SetScript("OnScrollRangeChanged", UpdateThumb)

local footerLine = frame:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("BOTTOMLEFT", RAIL + 1, FOOTER)
footerLine:SetPoint("BOTTOMRIGHT", -1, FOOTER)
footerLine:SetHeight(1)
footerLine:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)

local closeButton = Widgets.Button(frame, "Close", 100, function() frame:Hide() end)
closeButton:SetPoint("BOTTOMRIGHT", -PAD, 11)

local Select, UpdateChrome, RevealRail
local profileButton = Widgets.Button(frame, "", 250)
profileButton:SetPoint("BOTTOMLEFT", RAIL + PAD, 11)
Style.DropArrow(profileButton)
local profile = profileButton.label
profileButton:SetScript("OnClick", function(self)
    local options = { { title = true, label = "SWITCH ACTIVE PROFILE (ALSO SETS IT AS DEFAULT)" } }
    for _, name in ipairs(Plateau.DB:ListProfiles()) do
        options[#options + 1] = { value = name, label = Plateau.Builtins.Label(name) }
    end
    ns.ShowList(self, options, Plateau.DB.profileName, function(value)
        if value == false then
            for _, section in ipairs(ns.sections) do
                if section.key == "profiles" and Select then
                    Select(section)
                end
            end
            return
        end
        if value ~= Plateau.DB.profileName or value ~= Plateau.DB:DefaultProfile() then
            Plateau.DB:ActivateProfile(value)
            ns.UpdateProfileLabel()
            ns.RefreshAll()
        end
    end, { width = 220, up = true, pinned = { value = false, label = "Manage profiles..." } })
end)
profileButton:HookScript("OnEnter", function(self)
    local status = Plateau.AutoProfile:Status()
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    local accent = Style.StateColor()
    GameTooltip:SetText("Active profile: " .. status.active, accent[1], accent[2], accent[3])
    GameTooltip:AddLine("Every page edits this profile. Click to switch it; the profile you pick also becomes your default profile.", 1, 1, 1, true)
    GameTooltip:AddLine("Default profile: " .. status.default, 1, 1, 1, true)
    if status.overridden then
        GameTooltip:AddLine("Active because of: " .. tostring(status.rule or "an automatic switch") .. ". Picking another profile here can be replaced by the automatic rules when you change zone or specialization.", C.warn[1], C.warn[2], C.warn[3], true)
    end
    if status.pending then
        GameTooltip:AddLine("Pending after combat: " .. status.pending, C.warn[1], C.warn[2], C.warn[3], true)
    end
    GameTooltip:Show()
end)
profileButton:HookScript("OnLeave", function() GameTooltip:Hide() end)

local function Confirming(button, text, action)
    local armed = false
    button:SetScript("OnClick", function(self)
        if armed then
            armed = false
            self.label:SetText(text)
            self.label:SetTextColor(C.text[1], C.text[2], C.text[3])
            action()
            return
        end
        armed = true
        self.label:SetText("Click again to confirm")
        self.label:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
        C_Timer.After(3, function()
            if armed then
                armed = false
                self.label:SetText(text)
                self.label:SetTextColor(C.text[1], C.text[2], C.text[3])
            end
        end)
    end)
end

local pages = {}
local resetSection
local railButtons = {}
local current

local PAGE_TOP = 8

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
    SetupPreview = true,
}

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
        line = page:CreateTexture(nil, "BACKGROUND")
        line:SetWidth(1)
        line:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)
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
        GameTooltip:SetText(type(spec.label) == "string" and spec.label or "", accent[1], accent[2], accent[3])
        GameTooltip:AddLine(Logic.DisabledReason(spec) or "Not used with the current settings.", 1, 1, 1, true)
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

local function LayoutPage(page)
    local y = PAGE_TOP
    local waiting
    local dividers = 0
    local function EndLine(right)
        local height = waiting.naturalHeight
        if right then
            height = math.max(height, right.naturalHeight)
            PlaceRow(right, COLUMN + COLUMN_GAP, y, height, true)
            dividers = dividers + 1
            local line = Divider(page, dividers)
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", COLUMN + COLUMN_GAP / 2, -y)
            line:SetHeight(height)
            line:Show()
        end
        PlaceRow(waiting, 0, y, height, true)
        waiting = nil
        y = y + height + SPACING
    end
    for _, row in ipairs(page.rows) do
        local hidden = row.group ~= nil and page.collapsed[row.group] == true
        local visible = Logic.RowShown(row.spec, hidden)
        row.widget:SetShown(visible)
        if visible then
            ApplyEnabled(row)
            if row.wide then
                if waiting then
                    EndLine()
                end
                local height = row.widget:GetHeight()
                PlaceRow(row, 0, y, height)
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
    for i = dividers + 1, #page.dividers do
        page.dividers[i]:Hide()
    end
    page:SetHeight(y + PAD)
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


local function BuildPage(section)
    local page = CreateFrame("Frame", nil, scroll)
    page:SetWidth(CONTENT_WIDTH)
    page.rows = {}
    page.dividers = {}
    page.sectionKey = section.key
    page.collapsed = {}
    local groups = Logic.AssignGroups(section.controls)

    for index, spec in ipairs(section.controls) do
        if spec.collapsible then
            spec.onToggle = function() ToggleGroup(page, index) end
            page.collapsed[index] = Logic.IsCollapsed(section.key, spec)
        end
        local widget = Widgets[spec.type](page, spec)
        if spec.collapsible then
            widget:SetCollapsed(page.collapsed[index])
        end
        local wide = WIDE[spec.type] or spec.wide == true
        widget:SetWidth(wide and CONTENT_WIDTH or COLUMN)
        page.rows[index] = { widget = widget, spec = spec, y = 0, wide = wide, naturalHeight = widget:GetHeight(), group = groups[index] }
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
    if railButtons[section.key] then
        railButtons[section.key]:SetSelected(true)
        RevealRail(railButtons[section.key])
    end
    sectionTitle:SetText(section.title)
    UpdateThumb()
    ns.UpdateClickAreas()
    UpdateChrome()
    if ns.PageChanged then
        ns.PageChanged()
    end
    if resetSection then
        resetSection:SetShown(not section.noReset)
    end
    if ns.UpdatePickButtons then
        ns.UpdatePickButtons(section)
    end

end

local OFF_MENU = Logic.OFF_MENU

local RAIL_GROUPS = {
    { label = "Profile", keys = { "profiles" } },
    { label = "Nameplates", keys = { "health", "healthText", "name", "level", "castbar", "enemyPower" } },
    { label = "Behavior", keys = { "size", "fading", "layering", "clicking" } },
    { label = "States", keys = { "target", "focus", "mouseover", "combat" } },
    { label = "Auras", keys = { "auraMine", "auraPurge", "auraCC", "auraImportant", "shield" } },
    { label = "Icons", keys = { "raidMarker", "quest", "classification", "forces", "classPower" } },
    { label = "Friendly", keys = { "friendly" } },
    { label = "Game", keys = { "game" } },
    { label = "Help", keys = { "help" } },
}
local RAIL_ROW = 21
local RAIL_HEADER = 21

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

local function RailButton(section, y)
    local tint = Style.StateColor()
    local button = CreateFrame("Button", nil, railContent)
    button:SetHeight(RAIL_ROW)
    button:SetPoint("TOPLEFT", 0, -y)
    button:SetPoint("TOPRIGHT", 0, -y)
    button.y = y

    local hover = Style.Fill(button, C.hover)
    hover:Hide()
    local marker = button:CreateTexture(nil, "ARTWORK")
    marker:SetPoint("TOPLEFT")
    marker:SetPoint("BOTTOMLEFT")
    marker:SetWidth(3)
    marker:SetColorTexture(tint[1], tint[2], tint[3], 1)
    marker:Hide()
    button.marker = marker

    local label = Style.Text(button, 13, C.muted)
    label:SetPoint("LEFT", PAD + 4, 0)
    label:SetText(section.title)

    function button:SetSelected(selected)
        self.selected = selected
        marker:SetShown(selected)
        hover:SetShown(selected)
        local color = selected and C.text or C.muted
        label:SetTextColor(color[1], color[2], color[3])
    end

    button:SetScript("OnEnter", function() hover:Show() end)
    button:SetScript("OnLeave", function(self) hover:SetShown(self.selected) end)
    button:SetScript("OnClick", function() Select(section) end)
    railButtons[section.key] = button
end

ns.railGroups = RAIL_GROUPS

resetSection = Widgets.Button(sectionBar, "Reset this section", 150)
resetSection:SetPoint("RIGHT", -PAD, 0)
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
    RefreshPage(pages[current.key])
end)

local pickButtons = {}
for i = 1, 2 do
    local button = Widgets.Button(sectionBar, "", 150)
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
    local anchor, point = resetSection, "LEFT"
    if not (resetSection and resetSection:IsShown()) then
        anchor, point = sectionBar, "RIGHT"
    end
    for i, button in ipairs(pickButtons) do
        local pick = picks[i]
        if pick then
            button.label:SetText("Preview: " .. PickLabel(pick))
            button:SetWidth(button.label:GetStringWidth() + 34)
            button.tip.label = pick.label
            button.tip.tooltip = pick.tooltip
            button:ClearAllPoints()
            button:SetPoint("RIGHT", anchor, point, point == "RIGHT" and -PAD or -8, 0)
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
end

local railHeaders = {}
local railY = PAD / 2
local placed = {}
for _, group in ipairs(RAIL_GROUPS) do
    local header = Style.Text(railContent, 11, Style.StateColor())
    header:SetPoint("TOPLEFT", PAD - 4, -(railY + 7))
    railHeaders[#railHeaders + 1] = header
    header:SetText(group.label:upper())
    railY = railY + RAIL_HEADER
    for _, key in ipairs(group.keys) do
        local section = sectionsByKey[key]
        if section then
            RailButton(section, railY)
            placed[key] = true
            railY = railY + RAIL_ROW
        end
    end
end
for _, section in ipairs(ns.sections) do
    if not placed[section.key] and not OFF_MENU[section.key] then
        RailButton(section, railY)
        railY = railY + RAIL_ROW
    end
end
railContent:SetHeight(railY + PAD / 2)
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
    FitHeight()
    if left and right and top and not minimized then
        local ratio = old / new
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", (left + right) / 2 * ratio, top * ratio)
    end
end

function ns.UpdateProfileLabel()
    local status = Plateau.AutoProfile:Status()
    local text = "Active: " .. status.active
    if status.pending then
        text = text .. " (pending)"
    elseif status.overridden then
        text = text .. " (override)"
    end
    profile:SetText(text)
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
    scroll:SetPoint("TOPLEFT", RAIL + PAD, -(helpPage and (BANNER_TOP + BANNER + 6) or SCROLL_TOP))
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
                        text = (topic.title .. " " .. (topic.keywords or "") .. " " .. topic.text .. " " .. topic.category):lower(),
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
box:SetSize(240, 24)
box:SetPoint("RIGHT", settingsX, "LEFT", -12, 0)
cpuText:ClearAllPoints()
cpuText:SetPoint("RIGHT", box, "LEFT", -14, 0)
box:SetAutoFocus(false)
box:SetFontObject("GameFontHighlightSmall")
box:SetTextInsets(24, 8, 0, 0)
Style.Field(box, C.field, C.border)

local glass = box:CreateTexture(nil, "ARTWORK")
glass:SetAtlas("common-search-magnifyingglass")
glass:SetSize(12, 12)
glass:SetPoint("LEFT", 8, 0)
glass:SetVertexColor(C.muted[1], C.muted[2], C.muted[3])

local placeholder = Style.Text(box, 11, C.muted)
placeholder:SetPoint("LEFT", 24, 0)
placeholder:SetText("Search settings")

ns.tour = { window = frame, menu = rail, search = box, profile = profileButton, minimize = minimizeX }

local results = CreateFrame("Frame", nil, frame)
results:SetFrameLevel(frame:GetFrameLevel() + 300)
results:SetPoint("TOPRIGHT", box, "BOTTOMRIGHT", 0, -4)
results:SetWidth(380)
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
        local score = Logic.SearchScore(entry, words, query)
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
        footerLine:Hide()
        titleVersion:Hide()
        cpuText:Hide()
        cpuButton:Hide()
        cpuWatcher:Hide()
        titleLine:Hide()
        box:Hide()
        results:Hide()
        scrollTrack:Hide()
        scrollThumb:Hide()
        frame:SetSize(BAR_WIDTH, BAR_HEIGHT)
        frame:SetClampRectInsets(0, 0, 0, 0)
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
        footerLine:Show()
        titleVersion:Show()
        cpuText:Show()
        cpuButton:Show()
        cpuWatcher:Show()
        titleLine:Show()
        box:Show()
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

frame:HookScript("OnHide", function() SetMinimized(false) end)
