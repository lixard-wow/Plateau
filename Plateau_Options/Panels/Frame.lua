local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets
local T = Style.T

local WIDTH, HEIGHT = 1100, 800
local RAIL = 176
local PAD = 20
local TITLE = 30
local TOP = TITLE + 1
local TABLE = 248
local RULER_X, RULER_Y = 14, 28
local TOOLS = 24
local PAGE_HEAD = 40
local SPACING = 2
local SECTION_GAP = 20
local SCROLL_GUTTER = 16
local COLUMN_GAP = 24
local CONTENT_WIDTH = WIDTH - RAIL - 1 - PAD - SCROLL_GUTTER
local COLUMN = math.floor((CONTENT_WIDTH - COLUMN_GAP) / 2)
local PAIR_GAP = CONTENT_WIDTH - COLUMN * 2
local SCROLL_TOP = TOP + TABLE + PAGE_HEAD

ns.layout = {
    width = WIDTH, title = TOP, preview = TABLE - RULER_X - TOOLS, pad = PAD, rail = RAIL, content = CONTENT_WIDTH, column = COLUMN,
    previewTop = TOP + RULER_X, previewLeft = RAIL + 1 + RULER_Y, previewRight = 1,
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
frame:SetScale(Style.PixelScale())
Style.Panel(frame, C.window, C.edge, nil, C.border)
tinsert(UISpecialFrames, "PlateauOptions")

local OFFSCREEN_KEEP = 120

local function KeepOnScreen()
    local left, top, width = frame:GetLeft(), frame:GetTop(), frame:GetWidth()
    if not left or not top or not width then return end
    local ratio = UIParent:GetEffectiveScale() / frame:GetEffectiveScale()
    local screenWidth, screenHeight = UIParent:GetWidth() * ratio, UIParent:GetHeight() * ratio
    local fixedLeft = math.max(OFFSCREEN_KEEP - width, math.min(left, screenWidth - OFFSCREEN_KEEP))
    local fixedTop = math.max(TITLE, math.min(top, screenHeight))
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", math.floor(fixedLeft + 0.5), math.floor(fixedTop + 0.5))
end

local function LooseClamp()
    frame:SetClampRectInsets(0, 0, 0, 0)
    frame:SetClampedToScreen(false)
end

local function StopDrag()
    frame:StopMovingOrSizing()
    KeepOnScreen()
end

local function Line(parent, layer)
    local line = parent:CreateTexture(nil, layer or "ARTWORK")
    Style.Paint(line, C.edge, 1)
    return line
end

local titleBar = CreateFrame("Frame", nil, frame)
Style.OnPixels(frame, function(px)
    titleBar:ClearAllPoints()
    titleBar:SetPoint("TOPLEFT", px * 2, -px * 2)
    titleBar:SetPoint("TOPRIGHT", -px * 2, -px * 2)
end)
titleBar:SetHeight(TITLE - 1)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", StopDrag)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", StopDrag)
Style.Fill(titleBar, C.header)

local titleLine = Line(frame)
titleLine:SetPoint("TOPLEFT", 0, -TITLE)
titleLine:SetPoint("TOPRIGHT", 0, -TITLE)
Style.PixelHeight(titleLine)

local mark = titleBar:CreateTexture(nil, "ARTWORK")
mark:SetTexture("Interface\\AddOns\\Plateau_Options\\Art\\mesa")
mark:SetSize(22, 22)
mark:SetPoint("LEFT", 10, 0)
Style.PaintVertex(mark, C.accent)

local titleName = Style.Text(titleBar, 17, C.title)
Style.SetFont(titleName, Style.titleFont, Style.TITLE_SIZE, "")
titleName:SetPoint("LEFT", mark, "RIGHT", 6, 0)
titleName:SetText("Plateau")

local titleVersion = Style.Text(titleBar, 11, C.muted)
titleVersion:SetPoint("BOTTOMLEFT", titleName, "BOTTOMRIGHT", 6, 1)
titleVersion:SetText(Plateau.version)

local function TextButton(parent, text, onClick)
    local button = CreateFrame("Button", nil, parent)
    button.label = Style.Text(button, 12, C.muted)
    button.label:SetPoint("CENTER")
    button.label:SetText(text)
    button:SetSize(button.label:GetStringWidth() + 8, 20)
    button:SetScript("OnEnter", function(self) Style.PaintText(self.label, C.text) end)
    button:SetScript("OnLeave", function(self) Style.PaintText(self.label, self.restColor or C.muted) end)
    button:SetScript("OnClick", onClick)
    function button:Fit()
        self:SetWidth(self.label:GetStringWidth() + 8)
    end
    return button
end
ns.TextButton = TextButton

local closeX = Style.IconButton(titleBar, "icon_close", 20, function() frame:Hide() end, "Close")
closeX:SetPoint("RIGHT", -6, 0)

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

local profileButton = TextButton(titleBar, "", function(self)
    GameTooltip:Hide()
    ShowProfileList(self, true)
end)
profileButton:SetPoint("RIGHT", closeX, "LEFT", -12, 0)
profileButton:SetScript("OnEnter", function(self)
    Style.PaintText(self.label, C.text)
    local status = Plateau.AutoProfile:Status()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    local accent = Style.StateColor()
    GameTooltip:SetText(T("Active profile: %s"):format(status.active), accent[1], accent[2], accent[3])
    GameTooltip:AddLine(T("Default profile: %s"):format(status.default), 1, 1, 1, true)
    if status.overridden then
        GameTooltip:AddLine(T("Active because of: %s"):format(T(tostring(status.rule or "an automatic switch"))), C.warn[1], C.warn[2], C.warn[3], true)
    end
    if status.pending then
        GameTooltip:AddLine(T("Switches to %s after combat."):format(status.pending), C.warn[1], C.warn[2], C.warn[3], true)
    end
    GameTooltip:Show()
end)
profileButton:HookScript("OnLeave", function() GameTooltip:Hide() end)

local screenWatcher = CreateFrame("Frame")
screenWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
screenWatcher:RegisterEvent("UI_SCALE_CHANGED")
screenWatcher:SetScript("OnEvent", function()
    if ns.ApplyScale then
        ns.ApplyScale()
    end
    Style.RefreshPixels()
end)

local rail = CreateFrame("Frame", nil, frame)
Style.OnPixels(frame, function(px)
    rail:ClearAllPoints()
    rail:SetPoint("TOPLEFT", px * 2, -(TOP))
    rail:SetPoint("BOTTOMLEFT", px * 2, px * 2)
end)
rail:SetWidth(RAIL - 2)
Style.Fill(rail, C.rail)

local railEdge = Line(frame)
railEdge:SetPoint("TOPLEFT", RAIL, -TOP)
railEdge:SetPoint("BOTTOMLEFT", RAIL, 0)
Style.PixelWidth(railEdge)

local tableFrame = CreateFrame("Frame", nil, frame)
Style.OnPixels(frame, function(px)
    tableFrame:ClearAllPoints()
    tableFrame:SetPoint("TOPLEFT", RAIL + 1, -TOP)
    tableFrame:SetPoint("TOPRIGHT", -px * 2, -TOP)
end)
tableFrame:SetHeight(TABLE)
Style.Fill(tableFrame, C.surface)
local tableLine = Line(frame)
tableLine:SetPoint("TOPLEFT", RAIL + 1, -(TOP + TABLE))
tableLine:SetPoint("TOPRIGHT", 0, -(TOP + TABLE))
Style.PixelHeight(tableLine)

local TICK, MAJOR = 10, 50

local function Ruler(vertical)
    local ruler = CreateFrame("Frame", nil, tableFrame)
    local base = ruler:CreateTexture(nil, "ARTWORK")
    Style.Paint(base, C.border, 1)
    local ticks, labels = {}, {}
    ruler:SetScript("OnSizeChanged", function(self, width, height)
        local length = vertical and height or width
        if issecretvalue(length) then return end
        local count = math.floor(length / TICK)
        for i = 0, count do
            local major = i % (MAJOR / TICK) == 0
            local tick = ticks[i]
            if not tick then
                tick = self:CreateTexture(nil, "ARTWORK")
                ticks[i] = tick
            end
            Style.Paint(tick, major and C.faint or C.border, 1)
            tick:ClearAllPoints()
            if vertical then
                tick:SetPoint("TOPRIGHT", 0, -i * TICK)
                tick:SetSize(major and 8 or 4, 1)
            else
                tick:SetPoint("BOTTOMLEFT", i * TICK, 0)
                tick:SetSize(1, major and 8 or 4)
            end
            tick:Show()
            if major and i > 0 then
                local label = labels[i]
                if not label then
                    label = Style.Text(self, 9, C.faint)
                    labels[i] = label
                end
                label:ClearAllPoints()
                if vertical then
                    label:SetPoint("TOPRIGHT", -10, -i * TICK + 5)
                else
                    label:SetPoint("BOTTOMLEFT", i * TICK + 3, 5)
                end
                label:SetText(i * TICK)
                label:Show()
            end
        end
        for i = count + 1, #ticks do
            ticks[i]:Hide()
            if labels[i] then labels[i]:Hide() end
        end
    end)
    if vertical then
        ruler:SetPoint("TOPLEFT", 0, -RULER_X)
        ruler:SetPoint("BOTTOMLEFT", 0, 0)
        ruler:SetWidth(RULER_Y)
        base:SetPoint("TOPRIGHT")
        base:SetPoint("BOTTOMRIGHT")
        Style.PixelWidth(base)
    else
        ruler:SetPoint("TOPLEFT", RULER_Y, 0)
        ruler:SetPoint("TOPRIGHT", 0, 0)
        ruler:SetHeight(RULER_X)
        base:SetPoint("BOTTOMLEFT")
        base:SetPoint("BOTTOMRIGHT")
        Style.PixelHeight(base)
    end
    return ruler
end
Ruler(false)
Ruler(true)

local previewStage = CreateFrame("Frame", nil, tableFrame)
previewStage:SetPoint("TOPLEFT", RULER_Y, -RULER_X)
previewStage:SetPoint("BOTTOMRIGHT", 0, TOOLS)
previewStage:SetClipsChildren(true)

local dots = tableFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
dots:SetPoint("TOPLEFT", RULER_Y, -RULER_X)
dots:SetPoint("BOTTOMRIGHT")
dots:SetTexture("Interface\\AddOns\\Plateau_Options\\Art\\dots", "REPEAT", "REPEAT")
dots:SetHorizTile(true)
dots:SetVertTile(true)
Style.PaintVertex(dots, C.border, 0.9)

local anchorMark = CreateFrame("Frame", nil, previewStage)
anchorMark:SetSize(9, 9)
anchorMark:SetPoint("CENTER")
for _, vertical in ipairs({ true, false }) do
    local stroke = anchorMark:CreateTexture(nil, "BACKGROUND")
    Style.Paint(stroke, C.faint, 1)
    stroke:SetPoint("CENTER")
    stroke:SetSize(vertical and 1 or 9, vertical and 9 or 1)
end

local previewBar = CreateFrame("Frame", nil, tableFrame)
previewBar:SetPoint("BOTTOMLEFT", RULER_Y, 0)
previewBar:SetPoint("BOTTOMRIGHT", 0, 0)
previewBar:SetHeight(TOOLS)

local undoSlot = CreateFrame("Frame", nil, previewBar)
undoSlot:SetSize(176, 20)
undoSlot:SetPoint("RIGHT", previewBar, "RIGHT", -112, 0)
ns.layout.undoSlot = undoSlot

ns.previewBar, ns.previewStage = previewBar, previewStage

local pageHead = CreateFrame("Frame", nil, frame)
pageHead:SetPoint("TOPLEFT", RAIL + 1 + PAD, -(TOP + TABLE + 1))
pageHead:SetPoint("TOPRIGHT", -SCROLL_GUTTER, -(TOP + TABLE + 1))
pageHead:SetHeight(PAGE_HEAD)

local sectionTitle = Style.Text(pageHead, 22, C.title)
Style.SetFont(sectionTitle, Style.titleFont, 22, "")
sectionTitle:SetPoint("BOTTOMLEFT", 0, 8)

local sectionCount = Style.Text(pageHead, 11, C.faint)
sectionCount:SetPoint("BOTTOMLEFT", sectionTitle, "BOTTOMRIGHT", 10, 2)

local BANNER = 22

local scroll = CreateFrame("ScrollFrame", nil, frame)
scroll:SetPoint("TOPLEFT", RAIL + 1 + PAD, -SCROLL_TOP)
scroll:SetPoint("BOTTOMRIGHT", -SCROLL_GUTTER, 2)
scroll:EnableMouseWheel(true)

local banner = CreateFrame("Frame", nil, frame)
banner:Hide()
banner:SetPoint("TOPLEFT", RAIL + 1 + PAD, -SCROLL_TOP)
banner:SetPoint("TOPRIGHT", -SCROLL_GUTTER, -SCROLL_TOP)
banner:SetHeight(BANNER)
banner.text = Style.Text(banner, 11, C.muted)
banner.text:SetPoint("LEFT", 0, 0)
banner.text:SetPoint("RIGHT", 0, 0)
banner.text:SetText("On this page, search finds help topics only.")

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
    track:SetWidth(8)
    if gap < 0 then
        track:SetHitRectInsets(-gap, 0, 0, 0)
    end

    local thumb = CreateFrame("Frame", nil, track)
    thumb:SetWidth(8)
    thumb:EnableMouse(true)
    local thumbEdge = thumb:CreateTexture(nil, "OVERLAY", nil, 0)
    thumbEdge:SetPoint("TOP")
    thumbEdge:SetPoint("BOTTOM")
    thumbEdge:SetWidth(6)
    Style.Paint(thumbEdge, C.edge, 1)
    local thumbFill = thumb:CreateTexture(nil, "OVERLAY", nil, 1)
    thumbFill:SetPoint("TOP", 0, -1)
    thumbFill:SetPoint("BOTTOM", 0, 1)
    thumbFill:SetWidth(4)
    Style.Paint(thumbFill, C.border, 1)

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
    track:SetScript("OnMouseDown", function(self)
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

local UpdateThumb = Scrollbar(scroll, frame, 4)

scroll:SetScript("OnMouseWheel", function(self, delta)
    local target = Offset(self) - delta * 44
    self:SetVerticalScroll(math.max(0, math.min(Range(self), target)))
    UpdateThumb()
end)
scroll:SetScript("OnScrollRangeChanged", UpdateThumb)

local Select, UpdateChrome

local Confirming = ns.Widgets.Confirm

local pages = {}
local resetSection, resetAll
local railButtons = {}
local current

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

local function ClearFocusIn(parent)
    local children = { parent:GetChildren() }
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

local function StackRows(rows, x, y, wide)
    local waiting
    local function EndLine(right)
        local height = waiting.naturalHeight
        if right then
            height = math.max(height, right.naturalHeight)
            PlaceRow(right, x + COLUMN + PAIR_GAP, y, height, true)
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
    local count = 0
    for _, row in ipairs(page.rows) do
        local hidden = row.group ~= nil and page.collapsed[row.group] == true
        local visible = Logic.RowShown(row.spec, hidden)
        row.widget:SetShown(visible)
        if visible then
            ApplyEnabled(row)
            if not WIDE[row.spec.type] then
                count = count + 1
            end
        end
    end
    page.settingCount = count
    local columns = { 0, 0 }
    local function Bottom()
        return math.max(columns[1], columns[2])
    end
    for _, block in ipairs(page.blocks) do
        local any = block.header ~= nil and block.header.widget:IsShown()
        if not any then
            for _, row in ipairs(block.rows) do
                if row.widget:IsShown() then
                    any = true
                    break
                end
            end
        end
        if any then
            local left, top
            if block.wide then
                left, top = 0, Bottom()
            else
                local which = columns[2] < columns[1] and 2 or 1
                left, top = (which - 1) * (COLUMN + PAIR_GAP), columns[which]
                block.column = which
            end
            local y = top
            if block.header and block.header.widget:IsShown() then
                local height = block.header.widget:GetHeight()
                PlaceRow(block.header, left, y, height)
                y = y + height + 4
            end
            local bottom = StackRows(block.rows, left, y, block.wide) - SPACING + SECTION_GAP
            if block.wide then
                columns[1], columns[2] = bottom, bottom
            else
                columns[block.column] = bottom
            end
        end
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

local function PlanBlocks(controls)
    local blocks, blockOf = {}, {}
    local block = { indexes = {} }
    blocks[1] = block
    for index, spec in ipairs(controls) do
        if spec.type == "Header" then
            block = { indexes = {}, headerIndex = index, wide = spec.part == true or nil }
            blocks[#blocks + 1] = block
        else
            block.indexes[#block.indexes + 1] = index
            if (WIDE[spec.type] and not FLEXIBLE[spec.type]) or spec.wide == true then
                block.wide = true
            end
        end
        blockOf[index] = block
    end
    if not blocks[1].headerIndex then
        blocks[1].wide = true
    end
    return blocks, blockOf
end

local function BuildPage(section)
    local page = CreateFrame("Frame", nil, scroll)
    page:SetWidth(CONTENT_WIDTH)
    page.rows = {}
    page.sectionKey = section.key
    page.collapsed = {}
    local groups = Logic.AssignGroups(section.controls)
    local plan, blockOf = PlanBlocks(section.controls)

    for index, spec in ipairs(section.controls) do
        if spec.collapsible then
            spec.onToggle = function() ToggleGroup(page, index) end
            page.collapsed[index] = Logic.IsCollapsed(section.key, spec)
        end
        local widget = Widgets[spec.type](page, spec)
        if spec.collapsible then
            widget:SetCollapsed(page.collapsed[index])
        end
        local block = blockOf[index]
        local wide = WIDE[spec.type] or spec.wide == true
        local width
        if spec.type == "Header" then
            width = block.wide and CONTENT_WIDTH or COLUMN
        elseif wide then
            width = block.wide and CONTENT_WIDTH or COLUMN
        else
            width = COLUMN
        end
        widget:SetWidth(width)
        page.rows[index] = { widget = widget, spec = spec, y = 0, wide = wide, naturalHeight = widget:GetHeight(), group = groups[index] }
    end

    page.blocks = {}
    for _, entry in ipairs(plan) do
        local block = { wide = entry.wide == true, rows = {} }
        for _, index in ipairs(entry.indexes) do
            block.rows[#block.rows + 1] = page.rows[index]
        end
        if entry.headerIndex then
            block.header = page.rows[entry.headerIndex]
        end
        if block.header or #block.rows > 0 then
            page.blocks[#page.blocks + 1] = block
        end
    end

    LayoutPage(page)
    return page
end

local PAGE_GROUPS = {
    { label = "Plate", pages = {
        { key = "bar", title = "Health bar", parts = { "health" } },
        { key = "colors", title = "Colors", parts = { "healthColors", "threatColors" } },
        { key = "text", title = "Text", parts = { "name", "healthText", "level" } },
        { key = "castbar", title = "Cast bar", parts = { "castbar" } },
        { key = "auras", title = "Auras", tabs = { "auraMine", "auraCC", "auraPurge", "auraImportant", "shield", "auraAll" } },
        { key = "icons", title = "Icons", parts = { "raidMarker", "classification", "quest", "faction", "classPower", "enemyPower" } },
    } },
    { label = "In combat", pages = {
        { key = "targets", title = "Target and focus", tabs = { "target", "focus", "mouseover" } },
        { key = "kicks", title = "Interrupts", parts = { "kickers" } },
        { key = "dungeons", title = "Dungeons and raids", parts = { "forces", "threatText", "bossPhases" } },
    } },
    { label = "Showing", pages = {
        { key = "visibility", title = "Visibility", parts = { "showing", "fading", "combat" } },
        { key = "size", title = "Size", parts = { "size" } },
        { key = "stacking", title = "Stacking and clicks", parts = { "layering", "clicking" } },
    } },
    { pages = {
        { key = "friendly", title = "Friendly", parts = { "friendly" } },
        { key = "profiles", title = "Profiles", parts = { "profiles", "addon" } },
        { key = "help", title = "Help", parts = { "help" } },
    } },
}
local TAB_TITLES = { auraMine = "Your debuffs", auraImportant = "Important", shield = "Warnings", auraAll = "Text and tooltips" }

local sectionsByKey = {}
for _, section in ipairs(ns.sections) do
    sectionsByKey[section.key] = section
end

local pagesByKey, partPage = {}, {}

local function Groups(section)
    if type(section.group) == "table" then
        return section.group
    end
    return section.group and { section.group } or {}
end

local function ResetPart(section)
    if section.reset then
        section.reset()
    else
        for _, path in ipairs(Groups(section)) do
            Plateau.DB:Reset(path)
        end
    end
end

local function MergePicks(parts)
    local picks, seen = {}, {}
    for _, part in ipairs(parts) do
        for _, pick in ipairs(part.picks or {}) do
            if not seen[pick.label] then
                seen[pick.label] = true
                picks[#picks + 1] = pick
            end
        end
    end
    return #picks > 0 and picks or nil
end

local function PageFrom(def)
    local parts = {}
    for _, key in ipairs(def.tabs or def.parts) do
        if sectionsByKey[key] then
            parts[#parts + 1] = sectionsByKey[key]
        end
    end
    if #parts == 0 then return nil end
    local page = { key = def.key, title = def.title, parts = parts, here = {} }
    for _, part in ipairs(parts) do
        page.here[part.key] = true
    end
    if def.tabs then
        page.tabs = parts
        for _, part in ipairs(parts) do
            part.tabTitle = TAB_TITLES[part.key] or part.title
            part.here = { [part.key] = true }
            partPage[part.key] = { page = page, tab = part, offset = 0 }
        end
        return page
    end
    local controls, single = {}, #parts == 1
    for _, part in ipairs(parts) do
        if not single then
            controls[#controls + 1] = { type = "Header", label = part.title, part = true }
        end
        partPage[part.key] = { page = page, offset = #controls, start = not single and #controls or nil }
        for _, spec in ipairs(part.controls) do
            controls[#controls + 1] = spec
        end
        page.noReset = page.noReset or part.noReset
        page.resetAll = page.resetAll or part.resetAll
    end
    page.controls = controls
    page.picks = MergePicks(parts)
    page.reset = function()
        for _, part in ipairs(parts) do
            if not part.noReset then
                ResetPart(part)
            end
        end
    end
    return page
end

local railGroups = {}
for _, group in ipairs(PAGE_GROUPS) do
    local built = { label = group.label, pages = {}, keys = {} }
    for _, def in ipairs(group.pages) do
        local page = PageFrom(def)
        if page then
            built.pages[#built.pages + 1] = page
            pagesByKey[page.key] = page
            for _, part in ipairs(page.parts) do
                built.keys[#built.keys + 1] = part.key
            end
        end
    end
    railGroups[#railGroups + 1] = built
end
ns.railGroups = railGroups

local shown

local function Shown(page, tab)
    if not page.tabs then return page end
    return tab or page.activeTab or page.tabs[1]
end

function ns.UpdateClickAreas()
    local on = frame:IsShown() and ns.clickAreasOn == true
    Plateau.SetClickAreas(on, on)
    if ns.SetPreviewSection and shown then
        ns.SetPreviewSection(shown.key, shown.here, shown.tabTitle and (T(current.title) .. ": " .. T(shown.tabTitle)) or shown.title)
    end
end

local function PageCount(page)
    local count = page.settingCount or 0
    sectionCount:SetText(count > 0 and T(count == 1 and "%d setting" or "%d settings"):format(count) or "")
end

local tabButtons = {}

local function UpdateTabs()
    local list = current and current.tabs or {}
    local anchor
    for i = 1, math.max(#list, #tabButtons) do
        local part = list[i]
        local button = tabButtons[i]
        if part and not button then
            button = CreateFrame("Button", nil, pageHead)
            button:SetHeight(18)
            button.back = CreateFrame("Frame", nil, button)
            button.back:SetAllPoints()
            Style.Border(button.back, C.edge)
            Style.Fill(button.back, C.accent)
            local top = CreateFrame("Frame", nil, button)
            top:SetAllPoints()
            top:SetFrameLevel(button.back:GetFrameLevel() + 1)
            button.label = Style.Text(top, 12, C.muted)
            button.label:SetPoint("CENTER")
            button:SetScript("OnEnter", function(self)
                if not self.on then Style.PaintText(self.label, C.text) end
            end)
            button:SetScript("OnLeave", function(self)
                Style.PaintText(self.label, self.on and C.primaryText or C.muted)
            end)
            tabButtons[i] = button
        end
        if part then
            local on = part == shown
            button.on = on
            button.label:SetText(T(part.tabTitle))
            button:SetWidth(button.label:GetStringWidth() + 16)
            Style.PaintText(button.label, on and C.primaryText or C.muted)
            button.back:SetShown(on)
            button:ClearAllPoints()
            if anchor then
                button:SetPoint("LEFT", anchor, "RIGHT", 4, 0)
            else
                button:SetPoint("LEFT", sectionTitle, "RIGHT", 12, 0)
            end
            button:SetScript("OnClick", function() Select(current, part) end)
            button:Show()
            anchor = button
        elseif button then
            button:Hide()
        end
    end
    sectionCount:ClearAllPoints()
    if anchor then
        sectionCount:SetPoint("LEFT", anchor, "RIGHT", 12, 0)
    else
        sectionCount:SetPoint("BOTTOMLEFT", sectionTitle, "BOTTOMRIGHT", 10, 2)
    end
end

function Select(page, tab)
    ns.HideDropdownList()
    if shown and pages[shown.key] then
        pages[shown.key]:Hide()
    end
    if current and railButtons[current.key] then
        railButtons[current.key]:SetSelected(false)
    end
    current = page
    shown = Shown(page, tab)
    if page.tabs then
        page.activeTab = shown
    end
    Plateau.DB.saved.global.lastSection = shown.key

    local view = pages[shown.key]
    if not view then
        view = BuildPage(shown)
        pages[shown.key] = view
    end
    scroll:SetScrollChild(view)
    scroll:SetVerticalScroll(0)
    view:Show()
    RefreshPage(view)
    if railButtons[page.key] then
        railButtons[page.key]:SetSelected(true)
    end
    sectionTitle:SetText(page.title)
    PageCount(view)
    UpdateTabs()
    UpdateThumb()
    ns.UpdateClickAreas()
    UpdateChrome()
    if ns.PageChanged then
        ns.PageChanged()
    end
    if resetSection then
        resetSection:SetShown(not shown.noReset)
        resetAll:SetShown(shown.resetAll == true)
    end
    if ns.UpdatePickButtons then
        ns.UpdatePickButtons(shown)
    end
end

local RAIL_ROW = 22
local RAIL_LABEL = 22
local RAIL_GAP = 14

local railScroll = CreateFrame("ScrollFrame", nil, rail)
railScroll:SetPoint("TOPLEFT", 0, -10)
railScroll:SetPoint("BOTTOMRIGHT", 0, 0)
railScroll:EnableMouseWheel(true)
local railContent = CreateFrame("Frame", nil, railScroll)
railContent:SetWidth(RAIL - 2)
railScroll:SetScrollChild(railContent)
local railBar = CreateFrame("Frame", nil, rail)
railBar:SetAllPoints()
railBar:SetFrameLevel(rail:GetFrameLevel() + 10)
local UpdateRailThumb = Scrollbar(railScroll, railBar, -9)
railScroll:SetScript("OnMouseWheel", function(self, delta)
    local target = Offset(self) - delta * RAIL_ROW * 2
    self:SetVerticalScroll(math.max(0, math.min(Range(self), target)))
    UpdateRailThumb()
end)
railScroll:SetScript("OnScrollRangeChanged", UpdateRailThumb)

local function RailButton(page, y)
    local button = CreateFrame("Button", nil, railContent)
    button:SetHeight(RAIL_ROW)
    button:SetPoint("TOPLEFT", 0, -y)
    button:SetPoint("TOPRIGHT", 0, -y)

    local markEdge = button:CreateTexture(nil, "ARTWORK", nil, 0)
    markEdge:SetSize(6, 10)
    markEdge:SetPoint("LEFT", 4, 0)
    Style.Paint(markEdge, C.edge, 1)
    local markFill = button:CreateTexture(nil, "ARTWORK", nil, 1)
    markFill:SetSize(4, 8)
    markFill:SetPoint("CENTER", markEdge)
    Style.Paint(markFill, C.accent, 1)

    local label = Style.Text(button, 13, C.muted)
    label:SetPoint("LEFT", 14, 0)
    label:SetPoint("RIGHT", -8, 0)
    label:SetText(page.title)

    function button:SetSelected(selected)
        self.selected = selected
        markEdge:SetShown(selected)
        markFill:SetShown(selected)
        Style.PaintText(label, selected and C.text or C.muted)
    end
    button:SetSelected(false)

    button:SetScript("OnEnter", function() Style.PaintText(label, C.text) end)
    button:SetScript("OnLeave", function(self) Style.PaintText(label, self.selected and C.text or C.muted) end)
    button:SetScript("OnClick", function() Select(page) end)
    railButtons[page.key] = button
    return button
end

do
    local y = 0
    for i, group in ipairs(railGroups) do
        if i > 1 then
            y = y + RAIL_GAP
        end
        if group.label then
            local label = Style.Text(railContent, 13, C.faint)
            Style.SetFont(label, Style.sectionFont, 13, "")
            label:SetPoint("TOPLEFT", 14, -(y + 4))
            label:SetText(group.label)
            y = y + RAIL_LABEL
        end
        for _, page in ipairs(group.pages) do
            RailButton(page, y)
            y = y + RAIL_ROW
        end
    end
    railContent:SetHeight(y + 10)
end

resetSection = TextButton(pageHead, "Reset page")
resetSection:SetPoint("BOTTOMRIGHT", 0, 8)
Confirming(resetSection, "Reset page", function()
    ResetPart(shown)
    ns.RefreshAll()
end)
resetSection:HookScript("OnClick", function(self) self:Fit() end)

resetAll = TextButton(pageHead, "Reset profile")
resetAll:SetPoint("BOTTOMRIGHT", 0, 8)
resetAll:Hide()
Confirming(resetAll, "Reset profile", function()
    Plateau.DB:Reset(nil)
    ns.RefreshAll()
end)
resetAll:HookScript("OnClick", function(self) self:Fit() end)

local pickButtons = {}
for i = 1, 2 do
    local button = TextButton(previewBar, "")
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
    local anchor
    for i, button in ipairs(pickButtons) do
        local pick = picks[i]
        if pick then
            button.label:SetFormattedText(T("Showing %s"), "|cffe2dccf" .. T(PickLabel(pick)) .. "|r")
            button:Fit()
            button.tip.label = pick.label
            button.tip.tooltip = pick.tooltip
            button:ClearAllPoints()
            if anchor then
                button:SetPoint("LEFT", anchor, "RIGHT", 12, 0)
            else
                button:SetPoint("LEFT", previewBar, "LEFT", 6, 0)
            end
            button:SetScript("OnClick", function(self)
                ns.ShowList(self, pick.options, pick.get(), function(value)
                    pick.set(value)
                    ns.UpdatePickButtons(shown)
                end, { width = 260 })
            end)
            button:Show()
            anchor = button
        else
            button:Hide()
        end
    end
end

local function FitHeight()
    frame:SetHeight(math.floor(math.min(HEIGHT, (UIParent:GetHeight() * UIParent:GetEffectiveScale() - 40 * frame:GetEffectiveScale()) / frame:GetEffectiveScale())))
    LooseClamp()
end
FitHeight()

function ns.ApplyScale()
    local old, new = frame:GetScale(), Style.PixelScale()
    if math.abs(old - new) < 1e-6 then return end
    local left, right, top = frame:GetLeft(), frame:GetRight(), frame:GetTop()
    frame:SetScale(new)
    Style.RefreshPixels()
    FitHeight()
    if left and right and top then
        local ratio = old / new
        frame:ClearAllPoints()
        frame:SetPoint("TOP", UIParent, "BOTTOMLEFT", (left + right) / 2 * ratio, top * ratio)
        KeepOnScreen()
    end
end

hooksecurefunc(UIParent, "SetScale", function()
    if frame:IsShown() then
        ns.ApplyScale()
    end
end)

function ns.UpdateProfileLabel()
    local status = Plateau.AutoProfile:Status()
    local name = status.active
    if status.pending then
        name = T("%s (pending)"):format(name)
    elseif status.overridden then
        name = T("%s (override)"):format(name)
    end
    profileButton.label:SetFormattedText(T("Profile %s"), "|cffe2dccf" .. name .. "|r")
    profileButton:Fit()
end

Plateau.AutoProfile:OnChange(function()
    if not frame:IsShown() then return end
    ns.UpdateProfileLabel()
    if current and current.key == "profiles" and pages[current.key] then
        RefreshPage(pages[current.key])
    end
end)

function UpdateChrome()
    local helpPage = current ~= nil and current.key == "help"
    banner:SetShown(helpPage)
    scroll:SetPoint("TOPLEFT", RAIL + 1 + PAD, -(helpPage and (SCROLL_TOP + BANNER) or SCROLL_TOP))
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
    if shown then
        local page = pages[shown.key]
        if page then
            RefreshPage(page)
            PageCount(page)
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

local function Locate(key)
    local where = partPage[key]
    if where then
        return where.page, where.tab, where
    end
    return pagesByKey[key]
end

local ScrollToRow

function ns.SelectSection(key)
    local page, tab, where = Locate(key)
    if not page then return end
    if page ~= current or (tab and tab ~= shown) then
        Select(page, tab)
    end
    if where and where.start and pages[page.key] then
        ScrollToRow(pages[page.key], where.start + 1)
    end
end

frame:SetScript("OnShow", function()
    ns.ApplyScale()
    KeepOnScreen()
    Style.RefreshPixels()
    ns.UpdateProfileLabel()
    if current then
        Select(current, shown)
    else
        local page, tab = Locate(Plateau.DB.saved.global.lastSection)
        if page then
            Select(page, tab)
        else
            Select(railGroups[1].pages[1])
        end
    end
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
local flashFill = Style.Fill(flash, C.accent)
Style.Paint(flashFill, C.accent, 0.12)
flash:Hide()
local flashToken = 0

local function Flash(widget)
    flash:ClearAllPoints()
    flash:SetPoint("TOPLEFT", widget, "TOPLEFT", -4, 2)
    flash:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", 4, -2)
    flash:Show()
    flashToken = flashToken + 1
    local token = flashToken
    C_Timer.After(1.8, function()
        if token == flashToken then
            flash:Hide()
        end
    end)
end

function ScrollToRow(page, index, flashIt)
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
        if flashIt then
            Flash(row.widget)
        end
    end)
end

function ns.OpenSetting(sectionKey, index)
    local page, tab, where = Locate(sectionKey)
    if not page then return end
    if page ~= current or (tab and tab ~= shown) then
        Select(page, tab)
    end
    ScrollToRow(pages[shown.key], (where and where.offset or 0) + index, true)
end

function ns.OpenLink(target)
    if not target then return end
    for _, section in ipairs(ns.sections) do
        if section.key == target.section then
            local found
            if target.key then
                found = Logic.FindKeyed(section, target.key)
            else
                found = Logic.FindControl(section, target.label, true)
            end
            if found then
                ns.OpenSetting(section.key, found)
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
    local own = {}
    for key, page in pairs(pagesByKey) do
        if not sectionsByKey[key] then
            own[#own + 1] = { key = key, title = page.title, controls = {} }
        end
    end
    for _, entry in ipairs(Logic.BuildSettingsIndex(own)) do
        index[#index + 1] = entry
    end
end

local MAX_RESULTS = 12
local RESULT_ROW = 20

local box = CreateFrame("EditBox", nil, titleBar)
box:SetSize(240, 18)
box:SetPoint("LEFT", titleBar, "LEFT", RAIL + 8, 0)
box:SetAutoFocus(false)
box:SetFontObject("GameFontHighlightSmall")
box:SetTextInsets(7, 7, 0, 0)
Style.Panel(box, C.field, C.edge, nil, C.border)

local placeholder = Style.Text(box, 12, C.faint)
placeholder:SetPoint("LEFT", 7, 0)
placeholder:SetText("Search")

ns.tour = { window = frame, menu = rail, search = box, profile = profileButton, minimize = closeX }

local results = CreateFrame("Frame", nil, frame)
results:SetFrameLevel(frame:GetFrameLevel() + 300)
results:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -2)
results:SetWidth(box:GetWidth())
results:EnableMouse(true)
Style.Panel(results, C.window, C.edge, nil, C.border)
results:Hide()

local empty = Style.Text(results, 12, C.muted)
empty:SetPoint("TOPLEFT", 8, -7)
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
    row:SetPoint("TOPLEFT", 2, -(3 + (i - 1) * RESULT_ROW))
    row:SetPoint("TOPRIGHT", -2, -(3 + (i - 1) * RESULT_ROW))
    row.hover = Style.Fill(row, C.hover)
    row.hover:Hide()
    row.where = Style.Text(row, 11, C.muted, "RIGHT")
    row.where:SetPoint("RIGHT", -6, 0)
    row.label = Style.Text(row, 12, C.text)
    row.label:SetPoint("LEFT", 6, 0)
    row.label:SetPoint("RIGHT", row.where, "LEFT", -8, 0)
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
    results:SetHeight(#matches > 0 and (#matches * RESULT_ROW + 6) or 28)
    results:Show()
    Highlight(1)
end

function ns.PageChanged()
    box:SetText("")
    results:Hide()
    placeholder:SetText(current and current.key == "help" and "Search help" or "Search")
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
    ns.Widgets.HidePrompts()
end)
