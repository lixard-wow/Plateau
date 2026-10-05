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
local BARLOW = FONTS .. "Barlow-Regular.ttf"
local BARLOW_COND = FONTS .. "BarlowCondensed-Bold.ttf"
local CINZEL = FONTS .. "Cinzel-Bold.ttf"
local SOURCE = FONTS .. "SourceSans3-Regular.ttf"
local SOURCE_BOLD = FONTS .. "SourceSans3-Bold.ttf"

Style.THEME_ORDER = { "workbench", "ledger", "classic" }

Style.THEMES = {
    workbench = {
        name = "Workbench",
        desc = "Flat charcoal with a green accent and a color for each section.",
        body = BARLOW,
        heading = BARLOW_COND,
        radius = 10,
        grain = 0,
        colors = {
            window = Hex("#171a1f"),
            rail = Hex("#1d2127"),
            field = Hex("#1d2127"),
            hover = Hex("#262b32"),
            border = Hex("#2c323a"),
            accent = Hex("#4fbf8f"),
            text = Hex("#e8ebee"),
            muted = Hex("#9aa3ad"),
            warn = Hex("#e0913a"),
            button = Hex("#262b32"),
            buttonBorder = Hex("#30363f"),
            buttonHover = Hex("#30363f"),
            icon = Hex("#c3cad2"),
            iconHover = Hex("#ffffff"),
        },
        buttonRadius = 4,
        settingsIcon = "icon_sliders",
        groups = { look = Hex("#4fbf8f"), casts = Hex("#a98cf0"), highlights = Hex("#e0a03a"), setup = Hex("#6fa8e8") },
    },
    ledger = {
        name = "Artisan Ledger",
        desc = "Walnut and brass with a serif title face, like a craftsman's ledger.",
        body = SOURCE,
        heading = CINZEL,
        radius = 4,
        grain = 0.05,
        colors = {
            window = Hex("#1c1611"),
            rail = Hex("#241c15"),
            field = Hex("#120e0b"),
            hover = Hex("#2e241b"),
            border = Hex("#5a4630"),
            accent = Hex("#c9a35a"),
            text = Hex("#efe6d6"),
            muted = Hex("#a8998a"),
            warn = Hex("#d0614a"),
            button = Hex("#241c15"),
            buttonBorder = Hex("#5a4630"),
            buttonHover = Hex("#2e241b"),
            icon = Hex("#a8998a"),
            iconHover = Hex("#e9d9b4"),
        },
        buttonRadius = 4,
        roundFields = true,
        settingsIcon = "icon_gear",
        groups = { look = Hex("#c9a35a"), casts = Hex("#b9825a"), highlights = Hex("#9fc58a"), setup = Hex("#8fa3b0") },
    },
    classic = {
        name = "Lixard Classic",
        desc = "The house style of Lixard's addons: near-black, square edges and gold.",
        body = SOURCE,
        heading = SOURCE_BOLD,
        radius = 0,
        grain = 0,
        colors = {
            window = { 0.06, 0.06, 0.06, 1 },
            rail = Hex("#161616"),
            field = Hex("#101010"),
            hover = Hex("#1f1f1f"),
            border = { 0.22, 0.22, 0.22, 1 },
            accent = { 0.78, 0.66, 0.22, 1 },
            text = { 0.92, 0.91, 0.86, 1 },
            muted = { 0.70, 0.70, 0.70, 1 },
            warn = Hex("#d0614a"),
            button = Hex("#161616"),
            buttonBorder = { 0.22, 0.22, 0.22, 1 },
            buttonHover = Hex("#202020"),
            icon = { 0.70, 0.70, 0.70, 1 },
            iconHover = { 0.92, 0.91, 0.86, 1 },
        },
        buttonRadius = 0,
        settingsIcon = "icon_gear",
        roundClose = true,
        groups = { look = { 0.78, 0.66, 0.22, 1 }, casts = { 0.88, 0.76, 0.40, 1 }, highlights = { 0.68, 0.56, 0.18, 1 }, setup = { 0.62, 0.62, 0.62, 1 } },
    },
}

local NON_LATIN = { ruRU = true, koKR = true, zhCN = true, zhTW = true }

local function ChosenTheme()
    local saved = Plateau.DB and Plateau.DB.saved and Plateau.DB.saved.global.optionsTheme
    if Style.THEMES[saved] then
        return saved
    end
    return Plateau.flavor == "forever" and "ledger" or "workbench"
end

function Style.ThemeKey()
    return ChosenTheme()
end

function Style.SetTheme(key)
    if Style.THEMES[key] and Plateau.DB and Plateau.DB.saved then
        Plateau.DB.saved.global.optionsTheme = key
    end
end

Style.theme = Style.THEMES[ChosenTheme()]
Style.colors = {}
for key, value in pairs(Style.theme.colors) do
    Style.colors[key] = value
end
Style.groupColors = Style.theme.groups
Style.RADIUS = Style.theme.radius
Style.BUTTON_RADIUS = Style.theme.buttonRadius

function Style.DropArrow(button)
    local arrow = button:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    arrow:SetSize(10, 10)
    arrow:SetPoint("RIGHT", -8, 0)
    arrow:SetRotation(-math.pi / 2)
    arrow:SetVertexColor(Style.colors.muted[1], Style.colors.muted[2], Style.colors.muted[3])
    button.arrow = arrow
    return arrow
end

Style.FONT_CHOICES = {
    { value = BARLOW, label = "Barlow" },
    { value = BARLOW_COND, label = "Barlow Condensed" },
    { value = SOURCE, label = "Source Sans 3" },
    { value = SOURCE_BOLD, label = "Source Sans 3 Bold" },
    { value = CINZEL, label = "Cinzel" },
}

Style.SCALE_MIN, Style.SCALE_MAX = 0.6, 1.4

local function SavedGlobal()
    return Plateau.DB and Plateau.DB.saved and Plateau.DB.saved.global or {}
end

function Style.Scale()
    local scale = tonumber(SavedGlobal().optionsScale) or 1
    return math.max(Style.SCALE_MIN, math.min(Style.SCALE_MAX, scale))
end

local gameFont = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
local useGameFont = GetLocale ~= nil and NON_LATIN[GetLocale()] == true

local function ChosenFont(key, themeFont)
    local saved = SavedGlobal()[key]
    if type(saved) == "string" and saved ~= "" then
        return saved
    end
    return useGameFont and gameFont or themeFont
end

Style.font = ChosenFont("optionsFont", Style.theme.body)
Style.headingFont = ChosenFont("optionsHeadingFont", Style.theme.heading)
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
    texture:SetColorTexture(color[1], color[2], color[3], alpha or 1)
end

function Style.ThemedBorder(frame)
    local roundEdge = rawget(frame, "roundEdge")
    if roundEdge then
        local color = Style.StateColor()
        roundEdge:SetVertexColor(color[1], color[2], color[3], 1)
        return
    end
    for _, edge in ipairs(frame.borderEdges) do
        Style.Themed(edge, 1)
    end
end

local LIMITED_BADGE = " |TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:12:12:0:0|t"

Style.limited = {
    names = "Doesn't work in dungeons, raids and arenas on retail: the game hides enemy names from addons there, so Plateau can't shorten them and they show in full.",
    friendly = "Only in the open world. In dungeons, raids and arenas the game locks friendly nameplates, so Blizzard draws them there and these settings don't apply.",
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
    label:SetText(spec.label .. (spec.limited and LIMITED_BADGE or ""))
    label:SetTextColor(Style.colors.text[1], Style.colors.text[2], Style.colors.text[3], Style.colors.text[4])
end

local function AfterChange(refresh)
    if ns.RefreshAll then
        ns.RefreshAll()
    else
        refresh()
    end
end

local function OpenMenu(owner, spec, refresh)
    local DB = Plateau.DB
    local paths = ns.SpecPaths(spec)
    MenuUtil.CreateContextMenu(owner, function(_, root)
        root:CreateTitle(spec.label or "")
        root:CreateButton("Reset to default", function()
            DB:ResetEverywhere(paths)
            AfterChange(refresh)
        end)
    end)
end

function Style.RightClickReset(frame, spec, refresh)
    frame:HookScript("OnMouseUp", function(self, button)
        if button ~= "RightButton" then return end
        if spec.reset and not spec.paths then
            spec.reset()
            refresh()
            return
        end
        if #ns.SpecPaths(spec) == 0 then return end
        GameTooltip:Hide()
        OpenMenu(self, spec, refresh)
    end)
end

function Style.Fill(frame, color, layer)
    local texture = frame:CreateTexture(nil, layer or "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(color[1], color[2], color[3], color[4])
    return texture
end

local GRAIN = "Interface\\AddOns\\" .. addonName .. "\\Art\\grain.png"
local GRAIN_TILE = 128

function Style.Grain(frame, alpha)
    local texture = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    texture:SetAllPoints()
    texture:SetTexture(GRAIN, "REPEAT", "REPEAT")
    texture:SetAlpha(alpha or Style.theme.grain)
    texture:SetShown((alpha or Style.theme.grain) > 0)
    local function Resize(_, width, height)
        if not width or width <= 0 or not height or height <= 0 then return end
        texture:SetTexCoord(0, width / GRAIN_TILE, 0, height / GRAIN_TILE)
    end
    frame:HookScript("OnSizeChanged", Resize)
    Resize(frame, frame:GetWidth(), frame:GetHeight())
    return texture
end

local ART = "Interface\\AddOns\\" .. addonName .. "\\Art\\"
local ROUND = ART .. "round%d.png"
local ICONS = ART .. "Icons\\"

function Style.Rounded(frame, color, layer, sublevel, radius)
    radius = radius or Style.RADIUS
    local texture = frame:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
    if radius == "circle" then
        texture:SetTexture(ICONS .. "circle")
    elseif radius > 0 then
        texture:SetTexture(ROUND:format(radius))
        texture:SetTextureSliceMargins(radius, radius, radius, radius)
        texture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    else
        texture:SetColorTexture(1, 1, 1, 1)
    end
    texture:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
    return texture
end

function Style.Panel(frame, fill, border, radius)
    local edge = Style.Rounded(frame, border, "BACKGROUND", -2, radius)
    edge:SetAllPoints()
    local inner = Style.Rounded(frame, fill, "BACKGROUND", -1, radius)
    inner:SetPoint("TOPLEFT", 1, -1)
    inner:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.roundEdge = edge
    frame.roundFill = inner
    return inner, edge
end

function Style.ButtonBox(button, fill, radius)
    local C = Style.colors
    fill = fill or C.button
    local inner = Style.Panel(button, fill, C.buttonBorder, radius or Style.BUTTON_RADIUS)
    button.restBorder = C.buttonBorder
    button:HookScript("OnEnter", function()
        inner:SetVertexColor(C.buttonHover[1], C.buttonHover[2], C.buttonHover[3], 1)
    end)
    button:HookScript("OnLeave", function()
        inner:SetVertexColor(fill[1], fill[2], fill[3], fill[4] or 1)
    end)
    return inner
end

function Style.IconButton(parent, icon, size, onClick, tooltip, round)
    local C = Style.colors
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    Style.ButtonBox(button, C.button, round and "circle" or Style.BUTTON_RADIUS)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture(ICONS .. icon)
    button.icon:SetSize(math.floor(size * 0.5 + 0.5), math.floor(size * 0.5 + 0.5))
    button.icon:SetPoint("CENTER")
    button.icon:SetVertexColor(C.icon[1], C.icon[2], C.icon[3], 1)
    button:HookScript("OnEnter", function(self)
        self.icon:SetVertexColor(C.iconHover[1], C.iconHover[2], C.iconHover[3], 1)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(self.tooltip, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    button:HookScript("OnLeave", function(self)
        self.icon:SetVertexColor(C.icon[1], C.icon[2], C.icon[3], 1)
        GameTooltip:Hide()
    end)
    button.tooltip = tooltip
    if onClick then
        button:SetScript("OnClick", onClick)
    end
    return button
end

function Style.SetIcon(button, icon)
    button.icon:SetTexture(ICONS .. icon)
end

function Style.SquareCorners(frame, color, corners, layer, sublevel)
    if Style.RADIUS <= 0 then return end
    for _, point in ipairs(corners) do
        local texture = frame:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
        texture:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
        texture:SetSize(Style.RADIUS, Style.RADIUS)
        texture:SetPoint(point)
    end
end

function Style.Border(frame, color)
    local edges = {}
    for i = 1, 4 do
        edges[i] = frame:CreateTexture(nil, "BORDER")
    end
    edges[1]:SetPoint("TOPLEFT")
    edges[1]:SetPoint("TOPRIGHT")
    edges[1]:SetHeight(1)
    edges[2]:SetPoint("BOTTOMLEFT")
    edges[2]:SetPoint("BOTTOMRIGHT")
    edges[2]:SetHeight(1)
    edges[3]:SetPoint("TOPLEFT")
    edges[3]:SetPoint("BOTTOMLEFT")
    edges[3]:SetWidth(1)
    edges[4]:SetPoint("TOPRIGHT")
    edges[4]:SetPoint("BOTTOMRIGHT")
    edges[4]:SetWidth(1)
    frame.borderEdges = edges
    Style.SetBorderColor(frame, color)
end

function Style.Field(frame, fill, border)
    if Style.theme.roundFields and Style.BUTTON_RADIUS > 0 then
        return Style.Panel(frame, fill, border, Style.BUTTON_RADIUS)
    end
    local texture = Style.Fill(frame, fill)
    Style.Border(frame, border)
    return texture
end

function Style.GradientLine(parent, colors, height)
    local line = CreateFrame("Frame", nil, parent)
    line:SetHeight(height or 2)
    local pieces = #colors - 1
    local segments = {}
    for i = 1, pieces do
        local segment = line:CreateTexture(nil, "ARTWORK")
        segment:SetColorTexture(1, 1, 1, 1)
        local a, b = colors[i], colors[i + 1]
        segment:SetGradient("HORIZONTAL", CreateColor(a[1], a[2], a[3], a[4] or 1), CreateColor(b[1], b[2], b[3], b[4] or 1))
        segments[i] = segment
    end
    line:SetScript("OnSizeChanged", function(self, width)
        local each = width / pieces
        for i, segment in ipairs(segments) do
            segment:ClearAllPoints()
            segment:SetPoint("TOPLEFT", self, "TOPLEFT", (i - 1) * each, 0)
            segment:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", (i - 1) * each, 0)
            segment:SetWidth(each)
        end
    end)
    return line
end

function Style.SetBorderColor(frame, color)
    local roundEdge = rawget(frame, "roundEdge")
    if roundEdge then
        roundEdge:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
        return
    end
    for i = 1, 4 do
        frame.borderEdges[i]:SetColorTexture(color[1], color[2], color[3], color[4])
    end
end

Style.ROW_HEIGHT = 28
Style.LABEL_WIDTH = 200
Style.CONTROL_X = 210
Style.CONTROL_WIDTH = 240

function Style.RowLabel(row, spec)
    local label = Style.Text(row, 12, Style.colors.text)
    label:SetPoint("LEFT", 0, 0)
    label:SetWidth(Style.LABEL_WIDTH)
    label:SetWordWrap(true)
    label:SetMaxLines(2)
    label:SetText(spec.label)
    row:SetHeight(label:GetStringHeight() > 16 and 40 or Style.ROW_HEIGHT)
    return label
end

function Style.LabelHit(label)
    local hit = CreateFrame("Frame", nil, label:GetParent())
    hit:SetAllPoints(label)
    hit:EnableMouse(true)
    return hit
end

function Style.Text(parent, size, color, justify)
    local text = parent:CreateFontString(nil, "OVERLAY")
    Style.SetFont(text, size >= Style.HEADING_SIZE and Style.headingFont or Style.font, size, "")
    text:SetTextColor(color[1], color[2], color[3], color[4])
    text:SetJustifyH(justify or "LEFT")
    text:SetWordWrap(false)
    return text
end

local function ChangeHint(spec, explain)
    if not explain then return nil end
    if spec.reset and not spec.paths then
        return spec.resetLabel or "Right-click to reset to default."
    end
    if #ns.SpecPaths(spec) == 0 then return nil end
    return "Right-click to reset to default."
end

function Style.Tooltip(owner, spec)
    owner:HookScript("OnEnter", function(self)
        local explain = spec.tooltip and Plateau.DB.saved.global.tooltipsEnabled ~= false
        local hint = ChangeHint(spec, explain)
        if not explain and not hint and not spec.limited then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local accent = Style.StateColor()
        GameTooltip:SetText(spec.label or "", accent[1], accent[2], accent[3])
        if explain then
            GameTooltip:AddLine(spec.tooltip, 1, 1, 1, true)
        end
        if spec.limited then
            local warn = Style.colors.warn
            GameTooltip:AddLine(LIMITED_BADGE .. " Limited in instances: " .. spec.limited, warn[1], warn[2], warn[3], true)
        end
        if hint then
            local hintColor = Style.colors.accent
            GameTooltip:AddLine(hint, hintColor[1], hintColor[2], hintColor[3], true)
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
