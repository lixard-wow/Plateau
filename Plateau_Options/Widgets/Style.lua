local addonName, ns = ...

local Style = {}
ns.Style = Style
ns.Widgets = {}

local function Hex(value)
    return {
        tonumber(value:sub(2, 3), 16) / 255,
        tonumber(value:sub(4, 5), 16) / 255,
        tonumber(value:sub(6, 7), 16) / 255,
        1,
    }
end

local FONTS = "Interface\\AddOns\\" .. addonName .. "\\Media\\Fonts\\"
local PLEX = FONTS .. "IBMPlexSansCondensed-Medium.ttf"
local PLEX_SEMI = FONTS .. "IBMPlexSansCondensed-SemiBold.ttf"
local ALEGREYA = FONTS .. "AlegreyaSC-Bold.ttf"

Style.THEME_ORDER = { "survey" }

local function Mix(color, toward, amount)
    return {
        color[1] + (toward - color[1]) * amount,
        color[2] + (toward - color[2]) * amount,
        color[3] + (toward - color[3]) * amount,
        1,
    }
end

local STONE = Hex("#141518")
local STONE_UP = Hex("#1c1e22")
local TABLE = Hex("#0b0c0e")
local SLATE = Hex("#2c3036")
local EDGE = Hex("#000000")
local BONE = Hex("#e2dccf")
local MUTED = Hex("#8e8a82")
local FAINT = Hex("#57554f")
local OCHRE = Hex("#d07a3c")
local OCHRE_HI = Hex("#f0a86a")
local OCHRE_INK = Hex("#1a0f06")
local DANGER = Hex("#c4553a")

Style.THEMES = {
    survey = {
        name = "Survey",
        desc = "Stone, a measured table, and mesa ochre on what you can move.",
        colors = {
            window = STONE,
            rail = STONE,
            header = TABLE,
            surface = TABLE,
            surfaceBorder = EDGE,
            field = TABLE,
            hover = STONE_UP,
            border = SLATE,
            line = SLATE,
            edge = EDGE,
            accent = OCHRE,
            accentHi = OCHRE_HI,
            text = BONE,
            title = BONE,
            heading = MUTED,
            muted = MUTED,
            faint = FAINT,
            warn = DANGER,
            button = STONE_UP,
            buttonBorder = EDGE,
            buttonHover = Mix(STONE_UP, 1, 0.07),
            buttonText = BONE,
            primary = OCHRE,
            primaryBorder = EDGE,
            primaryHover = OCHRE_HI,
            primaryText = OCHRE_INK,
            iconButton = STONE_UP,
            iconButtonBorder = EDGE,
            icon = MUTED,
            iconHover = BONE,
        },
        groups = { look = FAINT, casts = FAINT, highlights = FAINT, setup = FAINT },
    },
}

Style.SHAPE = {
    body = PLEX,
    heading = ALEGREYA,
    radius = 0,
    buttonRadius = 0,
    titleFont = { ALEGREYA, 17 },
    sectionFont = { ALEGREYA, 14 },
    buttonFont = { PLEX_SEMI, 12 },
}

local NON_LATIN = { ruRU = true, koKR = true, zhCN = true, zhTW = true }

local function ChosenTheme()
    local saved = Plateau.DB and Plateau.DB.saved and Plateau.DB.saved.global.optionsTheme
    if Style.THEMES[saved] then
        return saved
    end
    return "survey"
end

function Style.ThemeKey()
    return ChosenTheme()
end

Style.theme = Style.SHAPE
Style.colors = {}
Style.groupColors = {}

local themeTables = {}
local painted = {}
local themeListeners = {}

local function CopyInto(target, source)
    target[1], target[2], target[3], target[4] = source[1], source[2], source[3], source[4] or 1
end

local function LoadPalette(key)
    local theme = Style.THEMES[key] or Style.THEMES.survey
    for name, color in pairs(theme.colors) do
        local slot = Style.colors[name]
        if not slot then
            slot = {}
            Style.colors[name] = slot
            themeTables[slot] = true
        end
        CopyInto(slot, color)
    end
    for name, color in pairs(theme.groups) do
        local slot = Style.groupColors[name]
        if not slot then
            slot = {}
            Style.groupColors[name] = slot
            themeTables[slot] = true
        end
        CopyInto(slot, color)
    end
end

LoadPalette(ChosenTheme())

local function ApplyColor(region, kind, color, alpha, scale)
    scale = scale or 1
    local r, g, b, a = color[1] * scale, color[2] * scale, color[3] * scale, alpha or color[4] or 1
    if kind == "texture" then
        region:SetColorTexture(r, g, b, a)
    elseif kind == "vertex" then
        region:SetVertexColor(r, g, b, a)
    else
        region:SetTextColor(r, g, b, a)
    end
end

local function ApplyPaint(region, entry)
    ApplyColor(region, entry.kind, entry.color, entry.alpha, entry.scale)
end

local function Paint(region, kind, color, alpha, scale)
    if themeTables[color] then
        local entry = painted[region]
        if not entry then
            entry = {}
            painted[region] = entry
        end
        entry.kind, entry.color, entry.alpha, entry.scale = kind, color, alpha, scale
        ApplyPaint(region, entry)
        return
    end
    painted[region] = nil
    ApplyColor(region, kind, color, alpha, scale)
end

function Style.Paint(texture, color, alpha, scale)
    Paint(texture, "texture", color, alpha, scale)
end

function Style.PaintVertex(texture, color, alpha, scale)
    Paint(texture, "vertex", color, alpha, scale)
end

function Style.PaintText(fontString, color, alpha)
    Paint(fontString, "text", color, alpha)
end

function Style.OnTheme(callback)
    themeListeners[#themeListeners + 1] = callback
end

function Style.SetTheme(key)
    if not Style.THEMES[key] then return end
    if Plateau.DB and Plateau.DB.saved then
        Plateau.DB.saved.global.optionsTheme = key
    end
    LoadPalette(key)
    for region, entry in pairs(painted) do
        ApplyPaint(region, entry)
    end
    for i = 1, #themeListeners do
        themeListeners[i](key)
    end
end

Style.RADIUS = Style.theme.radius
Style.BUTTON_RADIUS = Style.theme.buttonRadius

function Style.DropArrow(button)
    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Art\\Icons\\icon_chevron_down")
    arrow:SetSize(10, 10)
    arrow:SetPoint("RIGHT", -5, 0)
    local idle, hover = Style.colors.accent, Style.colors.accentHi
    Style.PaintVertex(arrow, idle)
    button:HookScript("OnEnter", function() Style.PaintVertex(arrow, hover) end)
    button:HookScript("OnLeave", function() Style.PaintVertex(arrow, idle) end)
    button.arrow = arrow
    return arrow
end

Style.SCALE_MIN, Style.SCALE_MAX = 0.6, 1.4

local function SavedGlobal()
    return Plateau.DB and Plateau.DB.saved and Plateau.DB.saved.global or {}
end

function Style.Scale()
    local scale = tonumber(SavedGlobal().optionsScale) or 1
    return math.max(Style.SCALE_MIN, math.min(Style.SCALE_MAX, scale))
end

function Style.PixelScale()
    local wanted = Style.Scale()
    local base = UIParent:GetEffectiveScale()
    local factor = PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor()
    if type(base) ~= "number" or base <= 0 or type(factor) ~= "number" or factor <= 0 then
        return wanted
    end
    return wanted * factor / base
end

function Style.PixelRound(frame, value)
    local unit = Style.PixelUnit(frame)
    return math.floor(value / unit + 0.5) * unit
end

function Style.SnapWindow(frame)
    local left, top = frame:GetLeft(), frame:GetTop()
    if not left or not top then return end
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", Style.PixelRound(frame, left), Style.PixelRound(frame, top))
end

local windowDrag

local function EndWindowDrag()
    local drag = windowDrag
    if not drag then return end
    drag:Hide()
    local frame, onStop = drag.frame, drag.onStop
    drag.frame, drag.onStop = nil, nil
    if frame and onStop then
        onStop(frame)
    end
end

local function FollowCursor(self)
    local frame = self.frame
    if not frame or not IsMouseButtonDown("LeftButton") then
        EndWindowDrag()
        return
    end
    local x, y = GetCursorPosition()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.left + (x - self.x) / self.scale, self.top + (y - self.y) / self.scale)
end

function Style.DragWindow(frame, handles, onStop)
    local function Start()
        local left, top = frame:GetLeft(), frame:GetTop()
        if not left or not top then return end
        if not windowDrag then
            windowDrag = CreateFrame("Frame")
            windowDrag:Hide()
            windowDrag:SetScript("OnUpdate", FollowCursor)
        end
        windowDrag.frame, windowDrag.onStop = frame, onStop
        windowDrag.left, windowDrag.top = left, top
        windowDrag.x, windowDrag.y = GetCursorPosition()
        windowDrag.scale = frame:GetEffectiveScale()
        windowDrag:Show()
    end
    for _, handle in ipairs(handles) do
        handle:RegisterForDrag("LeftButton")
        handle:SetScript("OnDragStart", Start)
        handle:SetScript("OnDragStop", EndWindowDrag)
    end
end

function Style.FitWindow(frame)
    local scale = Style.PixelScale()
    if frame:GetScale() ~= scale then
        frame:SetScale(scale)
    end
    Style.SnapWindow(frame)
    if Style.RefreshPixels then
        Style.RefreshPixels()
    end
end

local gameFont = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local useGameFont = Plateau.ActiveLocale ~= nil and NON_LATIN[Plateau.ActiveLocale()] == true

local function ChosenFont(themeFont)
    return useGameFont and gameFont or themeFont
end

Style.font = ChosenFont(Style.theme.body)
Style.headingFont = ChosenFont(Style.theme.heading)
Style.titleFont = ChosenFont(Style.theme.titleFont[1])
Style.TITLE_SIZE = Style.theme.titleFont[2]
Style.sectionFont = ChosenFont(Style.theme.sectionFont[1])
Style.SECTION_SIZE = Style.theme.sectionFont[2]
Style.buttonFont = ChosenFont(Style.theme.buttonFont[1])
Style.BUTTON_SIZE = Style.theme.buttonFont[2]
Style.HEADING_SIZE = 14

local FONT_RETRY_DELAY = 0.1
local FONT_MAX_TRIES = 20
local FONT_SETTLE = { 0.5, 1.5, 3 }
local pendingFonts = {}
local settleFonts = setmetatable({}, { __mode = "k" })
local fontRetryScheduled, fontSettleScheduled = false, false

local function Redraw(fontString)
    local text = fontString:GetText()
    if text and text ~= "" then
        fontString:SetText("")
        fontString:SetText(text)
    end
end

local function RetryFonts()
    fontRetryScheduled = false
    for fontString, request in pairs(pendingFonts) do
        request.tries = request.tries + 1
        if fontString:SetFont(request.file, request.size, request.flags) then
            pendingFonts[fontString] = nil
            Redraw(fontString)
        elseif request.tries >= FONT_MAX_TRIES then
            pendingFonts[fontString] = nil
        end
    end
    if next(pendingFonts) and not fontRetryScheduled then
        fontRetryScheduled = true
        C_Timer.After(FONT_RETRY_DELAY, RetryFonts)
    end
end

local function SettleFonts(final)
    for fontString, request in pairs(settleFonts) do
        if not pendingFonts[fontString] and fontString:SetFont(request.file, request.size, request.flags) then
            Redraw(fontString)
        end
        if final then
            settleFonts[fontString] = nil
        end
    end
    if final then
        fontSettleScheduled = false
    end
end

function Style.SetFont(fontString, file, size, flags)
    flags = flags or ""
    if fontString:SetFont(file, size, flags) then
        pendingFonts[fontString] = nil
    else
        fontString:SetFont(gameFont, size, flags)
        pendingFonts[fontString] = { file = file, size = size, flags = flags, tries = 0 }
        if not fontRetryScheduled then
            fontRetryScheduled = true
            C_Timer.After(FONT_RETRY_DELAY, RetryFonts)
        end
    end
    settleFonts[fontString] = { file = file, size = size, flags = flags }
    if not fontSettleScheduled then
        fontSettleScheduled = true
        for index, delay in ipairs(FONT_SETTLE) do
            local final = index == #FONT_SETTLE
            C_Timer.After(delay, function() SettleFonts(final) end)
        end
    end
end

function Style.StateColor()
    return Style.colors.accent
end

function Style.Themed(texture, alpha)
    local color = Style.StateColor()
    Style.Paint(texture, color, alpha or 1)
end

function Style.OutlineFrame(parent, level, color, alpha)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetFrameLevel(parent:GetFrameLevel() + level)
    Style.OutlineEdges(frame, color)
    if alpha then
        frame:SetAlpha(alpha)
    end
    frame:Hide()
    return frame
end

function Style.OutlineEdges(frame, color)
    local edges = {}
    for i = 1, 4 do
        edges[i] = frame:CreateTexture(nil, "BORDER")
        edges[i]:SetSnapToPixelGrid(false)
        edges[i]:SetTexelSnappingBias(0)
        if color then
            Style.Paint(edges[i], color, 1)
        else
            Style.Themed(edges[i], 1)
        end
    end
    frame.outlineEdges = edges
    return frame
end

function Style.ThemedBorder(frame)
    local roundEdge = rawget(frame, "roundEdge")
    if roundEdge then
        local color = Style.StateColor()
        Style.PaintVertex(roundEdge, color, 1)
        return
    end
    for _, edge in ipairs(frame.borderEdges) do
        Style.Themed(edge, 1)
    end
end

local LIMITED_BADGE = " |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:12:12:0:0|t"

Style.limited = {
    names = "Not available in dungeons, raids and arenas. The game hides enemy names there, so they show in full.",
    friendly = "Open world only. The game draws friendly nameplates in dungeons, raids and arenas.",
}

function Style.Limited(spec, reason)
    spec.limited = Style.limited[reason] or reason
    return spec
end

function ns.Get(path)
    return Plateau.DB:Get(path)
end

function ns.Set(path, value)
    return Plateau.DB:Set(path, value)
end

function ns.SpecGet(spec)
    if spec.get then
        return spec.get()
    end
    return ns.Get(spec.path)
end

function ns.SpecSet(spec, value)
    if spec.set then
        return spec.set(value)
    end
    return ns.Set(spec.path, value)
end

function ns.SpecPaths(spec)
    if spec.paths then
        return spec.paths
    end
    if not spec.cachedPaths then
        local paths = {}
        if not spec.get then
            paths[#paths + 1] = spec.path
        end
        paths[#paths + 1] = spec.colorPath
        spec.cachedPaths = paths
    end
    return spec.cachedPaths
end

function Style.OverrideLabel(label, spec)
    local setText = label.RawSetText or label.SetText
    setText(label, Plateau.T(spec.label) .. (spec.limited and LIMITED_BADGE or ""))
    Style.PaintText(label, Style.colors.text)
end

function Style.AfterChange(target)
    if ns.RefreshAll then
        ns.RefreshAll()
    elseif type(target) == "function" then
        target()
    elseif target then
        target:Refresh()
    end
end

function Style.RightClickReset(frame, spec, refresh)
    frame:HookScript("OnMouseUp", function(self, button)
        if button ~= "RightButton" then return end
        if spec.reset and not spec.paths then
            spec.reset()
            Style.AfterChange(refresh)
            return
        end
        local paths = ns.SpecPaths(spec)
        if #paths == 0 then return end
        Plateau.DB:ResetEverywhere(paths)
        Style.AfterChange(refresh)
    end)
end

local function Snap(texture)
    texture:SetSnapToPixelGrid(true)
    texture:SetTexelSnappingBias(0)
    return texture
end
Style.Snap = Snap
Style.HOVER_MARK = { 1, 1, 1, 1 }
Style.PICK_MARK = { 0.25, 1, 0.35, 1 }

function Style.Fill(frame, color, layer)
    local texture = Snap(frame:CreateTexture(nil, layer or "BACKGROUND"))
    texture:SetAllPoints()
    Style.Paint(texture, color)
    return texture
end

local ART = "Interface\\AddOns\\" .. addonName .. "\\Art\\"
local ROUND = ART .. "round%d"
local ICONS = ART .. "Icons\\"

function Style.Rounded(frame, color, layer, sublevel, radius)
    radius = radius or Style.RADIUS
    local texture = Snap(frame:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0))
    if radius == "circle" then
        texture:SetTexture(ICONS .. "circle")
    elseif radius > 0 then
        texture:SetTexture(ROUND:format(radius))
        texture:SetTextureSliceMargins(radius, radius, radius, radius)
        texture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    else
        texture:SetColorTexture(1, 1, 1, 1)
    end
    Style.PaintVertex(texture, color)
    return texture
end

local pixelSized = {}
local pixelWatchers = {}

function Style.PixelUnit(region)
    local scale = region:GetEffectiveScale()
    if not (PixelUtil and PixelUtil.GetPixelToUIUnitFactor) or type(scale) ~= "number" or (issecretvalue and issecretvalue(scale)) or scale <= 0 then
        return 1
    end
    return PixelUtil.GetPixelToUIUnitFactor() / scale
end

local EDGE_POINTS = {
    top = { "TOPLEFT", 0, 0, "TOPRIGHT", 0, -1 },
    bottom = { "BOTTOMLEFT", 0, 1, "BOTTOMRIGHT", 0, 0 },
    left = { "TOPLEFT", 0, 0, "BOTTOMLEFT", 1, 0 },
    right = { "TOPRIGHT", -1, 0, "BOTTOMRIGHT", 0, 0 },
}

local function ApplyPixel(region, how)
    local unit = Style.PixelUnit(region)
    if type(how) == "table" and how.edge then
        local p = EDGE_POINTS[how.edge]
        region:ClearAllPoints()
        region:SetPoint("TOPLEFT", how.frame, p[1], p[2] * unit, p[3] * unit)
        region:SetPoint("BOTTOMRIGHT", how.frame, p[4], p[5] * unit, p[6] * unit)
    elseif how == "width" then
        region:SetWidth(unit)
    elseif how == "height" then
        region:SetHeight(unit)
    else
        local inset = unit * how[2]
        region:ClearAllPoints()
        region:SetPoint("TOPLEFT", how[1], "TOPLEFT", inset, -inset)
        region:SetPoint("BOTTOMRIGHT", how[1], "BOTTOMRIGHT", -inset, inset)
    end
end

function Style.PixelWidth(region)
    if region.SetSnapToPixelGrid then
        Snap(region)
    end
    pixelSized[region] = "width"
    ApplyPixel(region, "width")
end

function Style.PixelHeight(region)
    if region.SetSnapToPixelGrid then
        Snap(region)
    end
    pixelSized[region] = "height"
    ApplyPixel(region, "height")
end

function Style.PixelEdge(region, frame, edge)
    if region.SetSnapToPixelGrid then
        Snap(region)
    end
    local how = { edge = edge, frame = frame }
    pixelSized[region] = how
    ApplyPixel(region, how)
end

function Style.PixelInset(region, parent, pixels)
    if region.SetSnapToPixelGrid then
        Snap(region)
    end
    local how = { parent, pixels or 1 }
    pixelSized[region] = how
    ApplyPixel(region, how)
end

function Style.OnPixels(region, callback)
    pixelWatchers[#pixelWatchers + 1] = { region, callback }
    callback(Style.PixelUnit(region))
end

function Style.RefreshPixels()
    for region, how in pairs(pixelSized) do
        ApplyPixel(region, how)
    end
    for i = 1, #pixelWatchers do
        local entry = pixelWatchers[i]
        entry[2](Style.PixelUnit(entry[1]))
    end
end

function Style.Panel(frame, fill, border, radius, line)
    local edge = Style.Rounded(frame, border, "BACKGROUND", -3, radius)
    edge:SetAllPoints()
    local inset = 1
    if line then
        local ring = Style.Rounded(frame, line, "BACKGROUND", -2, radius)
        Style.PixelInset(ring, frame, 1)
        inset = 2
    end
    local inner = Style.Rounded(frame, fill, "BACKGROUND", -1, radius)
    Style.PixelInset(inner, frame, inset)
    frame.roundEdge = edge
    frame.roundFill = inner
    return inner, edge
end

function Style.ButtonBox(button, fill, radius, border, hover)
    local C = Style.colors
    fill = fill or C.button
    border = border or C.buttonBorder
    hover = hover or C.buttonHover
    local inner = Style.Panel(button, fill, border, radius or Style.BUTTON_RADIUS)
    button.restBorder = border
    button:HookScript("OnEnter", function()
        Style.PaintVertex(inner, hover, 1)
    end)
    button:HookScript("OnLeave", function()
        Style.PaintVertex(inner, fill)
    end)
    return inner
end

function Style.IconButton(parent, icon, size, onClick, tooltip, round)
    local C = Style.colors
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    Style.ButtonBox(button, C.iconButton, round and "circle" or Style.BUTTON_RADIUS, C.iconButtonBorder, C.hover)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture(ICONS .. icon)
    button.icon:SetSize(math.floor(size * 0.5 + 0.5), math.floor(size * 0.5 + 0.5))
    button.icon:SetPoint("CENTER")
    Style.PaintVertex(button.icon, C.icon, 1)
    button:HookScript("OnEnter", function(self)
        Style.PaintVertex(self.icon, C.iconHover, 1)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(Plateau.T(self.tooltip), 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    button:HookScript("OnLeave", function(self)
        Style.PaintVertex(self.icon, C.icon, 1)
        GameTooltip:Hide()
    end)
    button.tooltip = tooltip
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    return button
end

function Style.Input(parent, size)
    local edit = CreateFrame("EditBox", nil, parent)
    edit:SetAutoFocus(false)
    Style.SetFont(edit, Style.font, size or 11, "")
    Style.PaintText(edit, Style.colors.text)
    edit:SetTextInsets(6, 6, 0, 0)
    Style.Field(edit, Style.colors.field, Style.colors.border)
    edit:SetScript("OnEditFocusGained", function(self) Style.SetBorderColor(self, Style.StateColor()) end)
    edit:SetScript("OnEditFocusLost", function(self) Style.SetBorderColor(self, Style.colors.border) end)
    return edit
end

function Style.KeyCatcher(parent, onKey, wanted, onCombat)
    local catcher = CreateFrame("Frame", nil, parent)
    catcher:EnableKeyboard(false)
    if not InCombatLockdown() then
        catcher:SetPropagateKeyboardInput(true)
    end
    function catcher:Arm(on)
        if InCombatLockdown() then return end
        self:SetPropagateKeyboardInput(true)
        self:EnableKeyboard(on)
    end
    catcher:SetScript("OnKeyDown", function(self, key)
        if InCombatLockdown() then return end
        self:SetPropagateKeyboardInput(onKey(key) ~= true)
    end)
    catcher:RegisterEvent("PLAYER_REGEN_DISABLED")
    catcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    catcher:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            self:SetPropagateKeyboardInput(true)
            self:EnableKeyboard(false)
            if onCombat then
                onCombat()
            end
        else
            self:Arm(wanted())
        end
    end)
    return catcher
end

function Style.Dialog(name, width, height)
    local box = CreateFrame("Frame", name, UIParent)
    if height then
        box:SetSize(width, height)
    else
        box:SetWidth(width)
    end
    box:SetPoint("CENTER")
    box:SetFrameStrata("FULLSCREEN_DIALOG")
    box:HookScript("OnShow", function(self) Style.FitWindow(self) end)
    box:SetToplevel(true)
    box:EnableMouse(true)
    box:Hide()
    Style.Panel(box, Style.colors.window, Style.colors.border)
    return box
end

function Style.Border(frame, color)
    local edges = {}
    for i = 1, 4 do
        edges[i] = Snap(frame:CreateTexture(nil, "BORDER"))
    end
    Style.PixelEdge(edges[1], frame, "top")
    Style.PixelEdge(edges[2], frame, "bottom")
    Style.PixelEdge(edges[3], frame, "left")
    Style.PixelEdge(edges[4], frame, "right")
    frame.borderEdges = edges
    Style.SetBorderColor(frame, color)
end

function Style.Field(frame, fill, border)
    local texture = Style.Fill(frame, fill)
    Style.Border(frame, border)
    return texture
end

function Style.SetBorderColor(frame, color)
    local roundEdge = rawget(frame, "roundEdge")
    if roundEdge then
        Style.PaintVertex(roundEdge, color)
        return
    end
    local edges = rawget(frame, "borderEdges")
    if not edges then return end
    for i = 1, 4 do
        Style.Paint(edges[i], color)
    end
end

function Style.Bar(parent, width, height)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(width, height)
    local back = Style.Panel(bar, Style.colors.field, Style.colors.edge)
    local fill = bar:CreateTexture(nil, "ARTWORK", nil, 0)
    fill:SetPoint("TOPLEFT", back)
    fill:SetPoint("BOTTOMLEFT", back)
    Style.Paint(fill, Style.colors.accent, 1)
    local spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    spark:SetPoint("TOPRIGHT", fill)
    spark:SetPoint("BOTTOMRIGHT", fill)
    Style.PixelWidth(spark)
    Style.Paint(spark, Style.colors.accentHi, 1)
    bar.back, bar.fill, bar.spark = back, fill, spark
    function bar:SetFraction(fraction)
        fraction = math.max(0, math.min(1, fraction or 0))
        local inner = math.max(self:GetWidth() - 2 * Style.PixelUnit(self), 0)
        fill:SetShown(fraction > 0)
        spark:SetShown(fraction > 0)
        fill:SetWidth(math.max(inner * fraction, 0.001))
        self.fraction = fraction
    end
    bar:SetScript("OnSizeChanged", function(self) self:SetFraction(self.fraction) end)
    return bar
end

Style.ROW_HEIGHT = 22
Style.LABEL_WIDTH = 156
Style.CONTROL_X = 164
Style.CONTROL_WIDTH = 170

function Style.RowLabel(row, spec)
    local label = Style.Text(row, 12, Style.colors.text)
    label:SetPoint("LEFT", 0, 0)
    label:SetWidth(Style.LABEL_WIDTH)
    label:SetWordWrap(true)
    label:SetMaxLines(2)
    label:SetText(spec.label)
    row:SetHeight(label:GetStringHeight() > 15 and 32 or Style.ROW_HEIGHT)
    return label
end

function Style.LabelHit(label)
    local hit = CreateFrame("Frame", nil, label:GetParent())
    hit:SetAllPoints(label)
    hit:EnableMouse(true)
    return hit
end

local function T(text)
    return Plateau.T(text)
end
Style.T = T

local function TranslatedSetText(self, text)
    self:RawSetText(T(text))
end

local function TranslatedSetFormattedText(self, pattern, ...)
    self:RawSetFormattedText(T(pattern), ...)
end

function Style.Translates(fontString)
    if fontString.RawSetText then return fontString end
    fontString.RawSetText = fontString.SetText
    fontString.SetText = TranslatedSetText
    fontString.RawSetFormattedText = fontString.SetFormattedText
    fontString.SetFormattedText = TranslatedSetFormattedText
    return fontString
end

function Style.Text(parent, size, color, justify)
    local text = Style.Translates(parent:CreateFontString(nil, "OVERLAY"))
    Style.SetFont(text, size >= Style.HEADING_SIZE and Style.headingFont or Style.font, size, "")
    Style.PaintText(text, color)
    text:SetJustifyH(justify or "LEFT")
    text:SetWordWrap(false)
    return text
end

local function ChangeHint(spec, explain)
    if not explain then return nil end
    if spec.reset and not spec.paths then
        return spec.resetLabel or "Right-click to reset to Plateau's default."
    end
    if #ns.SpecPaths(spec) == 0 then return nil end
    return "Right-click to reset to Plateau's default."
end

function Style.TipTitle(owner, anchor, text)
    GameTooltip:SetOwner(owner, anchor)
    local accent = Style.StateColor()
    GameTooltip:SetText(text, accent[1], accent[2], accent[3])
end

function Style.Tooltip(owner, spec)
    owner:HookScript("OnEnter", function(self)
        local explain = spec.tooltip and Plateau.DB.saved.global.tooltipsEnabled ~= false
        local hint = ChangeHint(spec, explain)
        if not explain and not hint and not spec.limited then return end
        Style.TipTitle(self, "ANCHOR_RIGHT", T(spec.label) or "")
        if explain then
            GameTooltip:AddLine(T(spec.tooltip), 1, 1, 1, true)
            if spec.gameSetting then
                GameTooltip:AddLine(T("Game setting: also changes Blizzard's Options."), 0.6, 0.6, 0.6, true)
            end
        end
        if spec.limited then
            local warn = Style.colors.warn
            GameTooltip:AddLine(LIMITED_BADGE .. " " .. T("Limited in instances:") .. " " .. T(spec.limited), warn[1], warn[2], warn[3], true)
        end
        if hint then
            local hintColor = Style.colors.accent
            GameTooltip:AddLine(T(hint), hintColor[1], hintColor[2], hintColor[3], true)
        end
        GameTooltip:Show()
    end)
    owner:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function Style.HoverBorder(owner, target)
    owner:HookScript("OnEnter", function()
        Style.SetBorderColor(target, Style.StateColor())
    end)
    owner:HookScript("OnLeave", function()
        Style.SetBorderColor(target, rawget(target, "restBorder") or Style.colors.border)
    end)
end
