local _, ns = ...

local Style = ns.Style

local OUTLINES = {
    { value = "", label = "None" },
    { value = "OUTLINE", label = "Thin outline" },
    { value = "THICKOUTLINE", label = "Thick outline" },
}

local ALIGN = {
    { value = "LEFT", label = "Left" },
    { value = "CENTER", label = "Center" },
    { value = "RIGHT", label = "Right" },
}

local SIDES = {
    { value = "TOP", label = "Above" },
    { value = "BOTTOM", label = "Below" },
    { value = "LEFT", label = "Left" },
    { value = "RIGHT", label = "Right" },
    { value = "CENTER", label = "Inside bar, center" },
    { value = "TOPLEFT", label = "Above bar, left" },
    { value = "TOPRIGHT", label = "Above bar, right" },
    { value = "BOTTOMLEFT", label = "Below bar, left" },
    { value = "BOTTOMRIGHT", label = "Below bar, right" },
    { value = "INSIDELEFT", label = "Inside bar, left" },
    { value = "INSIDERIGHT", label = "Inside bar, right" },
}

local INTERRUPT_POSITIONS = {
    { value = "SPELL", label = "Where the spell name is" },
    { value = "TOP", label = "Above" },
    { value = "BOTTOM", label = "Below" },
    { value = "LEFT", label = "Left" },
    { value = "RIGHT", label = "Right" },
    { value = "CENTER", label = "Inside bar, center" },
    { value = "TOPLEFT", label = "Above bar, left" },
    { value = "TOPRIGHT", label = "Above bar, right" },
    { value = "BOTTOMLEFT", label = "Below bar, left" },
    { value = "BOTTOMRIGHT", label = "Below bar, right" },
    { value = "INSIDELEFT", label = "Inside bar, left" },
    { value = "INSIDERIGHT", label = "Inside bar, right" },
}

local INTERRUPT_FORMATS = {
    { value = "by", label = "Interrupted by <name>" },
    { value = "name", label = "Name only" },
    { value = "label", label = "Interrupted" },
}

local TEXT_POSITIONS = {
    { value = "LEFT", label = "Inside bar, left" },
    { value = "CENTER", label = "Inside bar, center" },
    { value = "RIGHT", label = "Inside bar, right" },
    { value = "INSIDETOPLEFT", label = "Inside bar, top left" },
    { value = "INSIDETOPRIGHT", label = "Inside bar, top right" },
    { value = "INSIDEBOTTOMLEFT", label = "Inside bar, bottom left" },
    { value = "INSIDEBOTTOMRIGHT", label = "Inside bar, bottom right" },
    { value = "TOP", label = "Above the bar" },
    { value = "BOTTOM", label = "Below the bar" },
    { value = "TOPLEFT", label = "Above, left end" },
    { value = "TOPRIGHT", label = "Above, right end" },
    { value = "BOTTOMLEFT", label = "Below, left end" },
    { value = "BOTTOMRIGHT", label = "Below, right end" },
    { value = "OUTSIDELEFT", label = "Left of the bar" },
    { value = "OUTSIDERIGHT", label = "Right of the bar" },
}

local NAME_POSITIONS = {
    { value = "TOP", label = "Above the bar" },
    { value = "BOTTOM", label = "Below the bar" },
    { value = "CENTER", label = "Inside bar" },
    { value = "INSIDETOP", label = "Inside bar, top" },
}

local ARROW_STYLES = {
    { value = "chevron", label = "Chevron" },
    { value = "chevronBold", label = "Chevron (bold)" },
    { value = "chevronDouble", label = "Double chevron" },
    { value = "triangle", label = "Solid triangle" },
    { value = "block", label = "Block arrow" },
    { value = "tutorial", label = "Blizzard tutorial" },
    { value = "tutorialGlow", label = "Blizzard tutorial (glowing)" },
    { value = "torghast", label = "Torghast" },
    { value = "delve", label = "Delve" },
    { value = "delveSmall", label = "Delve (small)" },
}

for _, option in ipairs(ARROW_STYLES) do
    local style = Plateau.arrowStyles[option.value]
    option.icon = style.file and { file = style.file } or { atlas = style.right or style.left, rotation = style.right and 0 or math.pi }
end

local ARROW_PLACEMENTS = {
    { value = "in", label = "Both sides, pointing in" },
    { value = "out", label = "Both sides, pointing out" },
    { value = "down", label = "Above, pointing down" },
    { value = "up", label = "Below, pointing up" },
    { value = "vertical", label = "Above and below, pointing in" },
}

local BRACKET_STYLES = {
    { value = "splash", label = "Square corners" },
    { value = "reward", label = "Wide corners" },
    { value = "claim", label = "Thin corners" },
}

local AURA_SIDES = {
    { value = "TOP", label = "Above" },
    { value = "BOTTOM", label = "Below" },
    { value = "LEFT", label = "Left" },
    { value = "RIGHT", label = "Right" },
}

local AURA_ALIGN = {
    { value = "LEFT", label = "Left" },
    { value = "CENTER", label = "Center" },
    { value = "RIGHT", label = "Right" },
}

local HEALTH_FORMATS = {
    { value = "percent", label = "Percentage  (87%)" },
    { value = "value", label = "Value  (52.3K)" },
    { value = "both", label = "Value | percent  (52.3K | 87%)" },
    { value = "paren", label = "Value (percent)  (52.3K (87%))" },
    { value = "percentFirst", label = "Percent first  (87% | 52.3K)" },
    { value = "valueMax", label = "Value / max  (52.3K / 60K)" },
    { value = "missing", label = "Missing health  (-7.7K)" },
    { value = "missingPercent", label = "Missing percent  (-13%)" },
}

local LEVEL_POSITIONS = {}
for _, option in ipairs(TEXT_POSITIONS) do
    LEVEL_POSITIONS[#LEVEL_POSITIONS + 1] = option
end
LEVEL_POSITIONS[#LEVEL_POSITIONS + 1] = { value = "NAME", label = "Next to the name" }

local BOSS_LEVEL_TEXT = {
    { value = "unknown", label = "??" },
    { value = "boss", label = "Boss" },
    { value = "skull", label = "Skull icon" },
    { value = "hide", label = "Hide" },
}

local SHOW_CASTS = {
    { value = "all", label = "All casts" },
    { value = "interruptible", label = "Only interruptible" },
    { value = "important", label = "Only important" },
}

local VALUE_PRECISION = {
    { value = "standard", label = "Standard  (52.3K, 1.23M)" },
    { value = "whole", label = "Whole numbers  (52K, 1M)" },
    { value = "one", label = "One decimal  (52.3K, 1.2M)" },
}

local BUILTIN_FONTS = {}
for _, font in ipairs({
    { value = STANDARD_TEXT_FONT, label = "Game default (matches your language)" },
    { value = UNIT_NAME_FONT, label = "Unit names (matches your language)" },
    { value = DAMAGE_TEXT_FONT, label = "Damage numbers (matches your language)" },
}) do
    if font.value then
        BUILTIN_FONTS[#BUILTIN_FONTS + 1] = font
    end
end
for _, font in ipairs({
    { value = "Fonts\\FRIZQT__.TTF", label = "Friz Quadrata" },
    { value = "Fonts\\ARIALN.TTF", label = "Arial Narrow" },
    { value = "Fonts\\skurri.ttf", label = "Skurri" },
    { value = "Fonts\\MORPHEUS.TTF", label = "Morpheus" },
}) do
    BUILTIN_FONTS[#BUILTIN_FONTS + 1] = font
end

local BUILTIN_BARS = {
    { value = "Interface\\Buttons\\WHITE8X8", label = "Flat" },
    { value = "atlas:UI-HUD-CoolDownManager-Bar", label = "Blizzard Midnight" },
    { value = "atlas:nameplates-bar-fill", label = "Blizzard nameplate" },
    { value = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill", label = "Blizzard classic" },
    { value = "Interface\\TargetingFrame\\UI-StatusBar", label = "Blizzard" },
    { value = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill", label = "Blizzard raid" },
    { value = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", label = "Blizzard skills" },
}
for _, texture in ipairs(Plateau.barTextures) do
    BUILTIN_BARS[#BUILTIN_BARS + 1] = texture
end

local PLACEHOLDER_MEDIA = { ["Texture Not Found"] = true }

local mediaCache = {}

local function MediaList(builtin, kind)
    local media = Plateau.media or (LibStub and LibStub("LibSharedMedia-3.0", true))
    local count = media and #media:List(kind) or 0
    local cached = mediaCache[kind]
    if cached and cached.builtin == builtin and cached.count == count then
        return cached.options
    end
    local options = {}
    local seen = {}
    for _, option in ipairs(builtin) do
        if not seen[option.value] then
            options[#options + 1] = option
            seen[option.value] = true
        end
    end
    if media then
        for _, name in ipairs(media:List(kind)) do
            local path = not PLACEHOLDER_MEDIA[name] and media:Fetch(kind, name)
            if path and not seen[path] then
                options[#options + 1] = { value = path, label = name }
                seen[path] = true
            end
        end
    end
    mediaCache[kind] = { builtin = builtin, count = count, options = options }
    return options
end

local function Fonts()
    return MediaList(BUILTIN_FONTS, "font")
end

function ns.OptionsFonts()
    local options = { { value = "", label = "Theme font" } }
    local seen = {}
    for _, list in ipairs({ Style.FONT_CHOICES, Fonts() }) do
        for _, option in ipairs(list) do
            if not seen[option.value] then
                seen[option.value] = true
                options[#options + 1] = option
            end
        end
    end
    return options
end

local function Bars()
    return MediaList(BUILTIN_BARS, "statusbar")
end

local function OverlayPatterns()
    local options = { { value = "", label = "No overlay" } }
    for _, pattern in ipairs(Plateau.overlayPatterns) do
        options[#options + 1] = pattern
    end
    return options
end

local FILL_DIRECTIONS = {
    { value = "left", label = "Left to right" },
    { value = "right", label = "Right to left" },
}

local function BackgroundBars()
    local options = { { value = "", label = "Flat color" } }
    for _, option in ipairs(Bars()) do
        if option.value ~= "Interface\\Buttons\\WHITE8X8" then
            options[#options + 1] = option
        end
    end
    return options
end

local function HighlightBars()
    local options = { { value = "", label = "Use health bar texture" } }
    for _, option in ipairs(Bars()) do
        options[#options + 1] = option
    end
    return options
end

local BUILTIN_BORDERS = {
    { value = "none", label = "No border" },
    { value = "pixel", label = "Pixel (solid line)" },
    { value = "shadow", label = "Soft shadow" },
    { value = "tooltip", label = "Tooltip" },
    { value = "thinTooltip", label = "Thin tooltip" },
}

local function BorderStyles()
    local options = MediaList(BUILTIN_BORDERS, "border")
    for i = #options, 1, -1 do
        local value = options[i].value
        if options[i].label == "None" or (type(value) == "string" and value:find("None$")) then
            table.remove(options, i)
        end
    end
    return options
end

local function BorderColorSetter(group)
    return function(value)
        local values = { [group .. ".border"] = value }
        if ns.Get(group .. ".borderStyle") == "none" then
            values[group .. ".borderStyle"] = "pixel"
        end
        if (ns.Get(group .. ".borderSize") or 0) <= 0 then
            values[group .. ".borderSize"] = 1
        end
        Plateau.DB:SetMany(values)
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end
end

local ABSORB_STYLES = {
    { value = "blizzard", label = "Blizzard shield (fill and stripes)" },
    { value = "stripes", label = "Blizzard stripes only" },
    { value = "lines-thin", label = "Plateau: Right-leaning lines (thin)" },
    { value = "lines-medium", label = "Plateau: Right-leaning lines (medium)" },
    { value = "lines-thick", label = "Plateau: Right-leaning lines (thick)" },
    { value = "lines-thin-left", label = "Plateau: Left-leaning lines (thin)" },
    { value = "lines-medium-left", label = "Plateau: Left-leaning lines (medium)" },
    { value = "lines-thick-left", label = "Plateau: Left-leaning lines (thick)" },
    { value = "solid", label = "Solid color" },
}

local function AbsorbStyles()
    local list = {}
    for _, style in ipairs(ABSORB_STYLES) do
        list[#list + 1] = style
    end
    for _, bar in ipairs(Bars()) do
        list[#list + 1] = bar
    end
    return list
end

local AURA_GROW = {
    { value = "auto", label = "Automatic" },
    { value = "right-down", label = "Right, new rows below" },
    { value = "right-up", label = "Right, new rows above" },
    { value = "left-down", label = "Left, new rows below" },
    { value = "left-up", label = "Left, new rows above" },
    { value = "down-right", label = "Down, new columns to the right" },
    { value = "down-left", label = "Down, new columns to the left" },
    { value = "up-right", label = "Up, new columns to the right" },
    { value = "up-left", label = "Up, new columns to the left" },
}

local function SpecSpellList(group, kind, label, empty, tooltip)
    return {
        type = "SpellList",
        label = label,
        empty = empty,
        tooltip = tooltip,
        suffix = function()
            local _, name = Plateau.CurrentSpec()
            return name or "no spec"
        end,
        get = function() return Plateau.DB:GetSpecSpells(group, kind) end,
        set = function(value) Plateau.DB:SetSpecSpells(group, kind, value) end,
        reset = function() Plateau.DB:SetSpecSpells(group, kind, "") end,
    }
end

local function FontControls(path)
    return
        { type = "Dropdown", path = path .. ".font", label = "Font", options = Fonts, unknown = "Custom font",
          tooltip = "The typeface used for this text." },
        { type = "Slider", path = path .. ".size", label = "Font size", min = 6, max = 24,
          tooltip = "How big the text is." },
        { type = "Dropdown", path = path .. ".outline", label = "Font outline", options = OUTLINES,
          tooltip = "The dark edge drawn around each letter, to keep it readable over any background." },
        { type = "Toggle", path = path .. ".shadow", label = "Text shadow",
          tooltip = "Adds a soft dark shadow behind the text, on top of the outline." }
end

local THREAT_DISPLAY = {
    { value = "bar", label = "Health bar" },
    { value = "border", label = "Health bar border" },
    { value = "both", label = "Both" },
}

local ENEMY_POWER_SHOW = {
    { value = "bosses", label = "Bosses only" },
    { value = "bossesCasters", label = "Bosses and casters" },
    { value = "all", label = "Every enemy" },
    { value = "target", label = "My target only" },
}

local POWER_TEXT_FORMATS = {
    { value = "percent", label = "Percent  (60%)" },
    { value = "value", label = "Value  (45.2K)" },
    { value = "both", label = "Both  (45.2K | 60%)" },
}

local POWER_TEXT_ANCHORS = {
    { value = "LEFT", label = "Left" },
    { value = "CENTER", label = "Center" },
    { value = "RIGHT", label = "Right" },
}

local ENEMY_POWER_POSITIONS = {
    { value = "inside", label = "Inside the bottom of health bar" },
    { value = "above", label = "Above health bar" },
    { value = "below", label = "Below health bar" },
}

local QUEST_ICONS = {
    { value = "QuestNormal", label = "Yellow exclamation mark" },
    { value = "QuestObjective", label = "Quest objective" },
}

if Plateau.flavor ~= "forever" then
    table.insert(QUEST_ICONS, 1, { value = "UI-QuestPoiCampaign-QuestBang", label = "Campaign quest" })
    table.insert(QUEST_ICONS, 2, { value = "UI-QuestPoiImportant-QuestBang", label = "Important quest" })
    table.insert(QUEST_ICONS, 3, { value = "UI-QuestPoiLegendary-QuestBang", label = "Legendary quest" })
    table.insert(QUEST_ICONS, 4, { value = "UI-QuestPoiRecurring-QuestBang", label = "Repeatable quest" })
end

local MORE_QUEST_ICONS = {
    { value = "QuestDaily", label = "Daily quest (blue exclamation)" },
    { value = "SmallQuestBang", label = "Small exclamation mark" },
    { value = "capPts-questbang-blue", label = "Blue exclamation mark" },
    { value = "worldquest-questmarker-questbang", label = "World quest exclamation" },
    { value = "Islands-QuestBang", label = "Islands exclamation" },
    { value = "QuestBonusObjective", label = "Bonus objective" },
    { value = "UI-DailyQuestPoiCampaign-QuestBang", label = "Daily campaign quest" },
    { value = "UI-QuestPoiWrapper-QuestBang", label = "Wrapper quest" },
    { value = "Quest-Campaign-Available", label = "Campaign quest (map style)" },
    { value = "quest-important-available", label = "Important quest (map style)" },
    { value = "quest-legendary-available", label = "Legendary quest (map style)" },
    { value = "quest-recurring-available", label = "Repeatable quest (map style)" },
    { value = "quest-wrapper-available", label = "Wrapper quest (map style)" },
}

for _, option in ipairs(MORE_QUEST_ICONS) do
    if not (C_Texture and C_Texture.GetAtlasInfo) or C_Texture.GetAtlasInfo(option.value) then
        QUEST_ICONS[#QUEST_ICONS + 1] = option
    end
end

for _, option in ipairs(QUEST_ICONS) do
    option.icon = { atlas = option.value }
end

local FORCES_FORMATS = {
    { value = "percent", label = "Percentage  (0.84%)" },
    { value = "count", label = "Count  (4)" },
    { value = "both", label = "Both  (4 (0.84%))" },
}

local ICON_SIDES = {
    { value = "LEFT", label = "Left" },
    { value = "RIGHT", label = "Right" },
}

local AURA_SORT = {
    { value = "expiration", label = "Expiring soonest first" },
    { value = "name", label = "Alphabetical" },
    { value = "default", label = "Blizzard order" },
}

local ABSORB_POSITIONS = {
    { value = "after", label = "After health (Blizzard style)" },
    { value = "right", label = "From the right edge" },
}

local ALERT_TEXTURES = {
    { value = "none", label = "None" },
    { value = "lines-thin", label = "Right-leaning lines (thin)" },
    { value = "lines-medium", label = "Right-leaning lines (medium)" },
    { value = "lines-thick", label = "Right-leaning lines (thick)" },
    { value = "lines-thin-left", label = "Left-leaning lines (thin)" },
    { value = "lines-medium-left", label = "Left-leaning lines (medium)" },
    { value = "lines-thick-left", label = "Left-leaning lines (thick)" },
    { value = "checkers-fine", label = "Checkers (fine)" },
    { value = "checkers-medium", label = "Checkers (medium)" },
    { value = "checkers-large", label = "Checkers (large)" },
    { value = "checkers-xlarge", label = "Checkers (extra large)" },
    { value = "shield", label = "Blizzard shield stripes" },
    { value = "solid", label = "Solid tint" },
}

local SHORTEN_NAMES = {
    { value = "full", label = "Full name" },
    { value = "firstWord", label = "First word only  (Aelindra)" },
    { value = "lastWord", label = "Last word only  (Dawnsong)" },
    { value = "abbreviate", label = "Initial and last word  (A. Dawnsong)" },
    { value = "lastInitial", label = "First word and last initial  (Aelindra D.)" },
    { value = "initials", label = "Both initials  (A.D.)" },
}

local OVERFLOW_NAMES = {
    { value = "none", label = "Do not truncate" },
    { value = "end", label = "Cut at the end  (Wastelander Pha...)" },
    { value = "start", label = "Cut at the start  (...lander Phaseblade)" },
}

local function Placement(path)
    return
        { type = "Slider", path = path .. ".alpha", label = "Opacity", min = 0, max = 1, step = 0.05,
          tooltip = "How solid it is. 1 is fully solid." },
        { type = "Dropdown", path = path .. ".position", label = "Position", options = SIDES,
          tooltip = "Which side of the health bar this sits on, or on top of it." },
        { type = "Slider", path = path .. ".gap", label = "Distance", min = 0, max = 20,
          tooltip = "Space between this and the edge of the health bar. Has no effect at Inside bar, center." },
        { type = "Slider", path = path .. ".offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Moves it left or right." },
        { type = "Slider", path = path .. ".offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Moves it up or down." }
end

local function Section(key, title, group, controls)
    return { key = key, title = title, group = group, controls = controls }
end

local function FriendlyStyled()
    return ns.Get("look.friendly.nameOnly") == false
end

local function Friendly(key, title, group, controls)
    local section = Section(key, title, group, controls)
    section.reset = function()
        local wasOn = ns.Get("look.friendly.enabled") == true
        for _, path in ipairs(group) do
            Plateau.DB:Reset(path)
        end
        if wasOn and ns.Get("look.friendly.enabled") ~= true then
            ns.PromptReload()
        end
    end
    return section
end

local CVars = Plateau.CVars

local function CVarSpec(kind, name, label, extra)
    local spec = extra or {}
    spec.type = kind
    spec.label = label
    spec.path = "cvar." .. name
    spec.reset = function() CVars:Release(name) end
    spec.resetLabel = "Right-click to undo Plateau's change."
    if kind == "Toggle" then
        spec.get = function() return CVars:Get(name) == "1" end
        spec.set = function(value) CVars:Set(name, value and "1" or "0") end
    else
        spec.get = function() return tonumber(CVars:Get(name)) or 0 end
        spec.set = function(value) CVars:Set(name, value) end
    end
    return spec
end

local function CVarToggle(name, label, tooltip)
    return CVarSpec("Toggle", name, label, { tooltip = tooltip })
end

local NPC_NAME_CVARS = { "UnitNameFriendlySpecialNPCName", "UnitNameHostleNPC", "UnitNameInteractiveNPC", "UnitNameNPC", "ShowQuestUnitCircles" }
local NPC_NAME_VALUES = {
    [1] = { "1", "0", "0", "0", "0" },
    [2] = { "1", "1", "0", "0", "1" },
    [3] = { "1", "1", "1", "0", "1" },
    [4] = { "0", "0", "0", "1", "1" },
    [5] = { "0", "0", "0", "0", "1" },
}
local NPC_NAME_OPTIONS = {
    { value = 1, label = NPC_NAMES_DROPDOWN_TRACKED or "Quest and tracked NPCs" },
    { value = 2, label = NPC_NAMES_DROPDOWN_HOSTILE or "Hostile NPCs" },
    { value = 3, label = NPC_NAMES_DROPDOWN_INTERACTIVE or "Interactive NPCs" },
    { value = 4, label = NPC_NAMES_DROPDOWN_ALL or "All NPCs" },
    { value = 5, label = NPC_NAMES_DROPDOWN_NONE or "None" },
}

local function NpcNames()
    return {
        type = "Dropdown",
        label = "NPC names",
        options = NPC_NAME_OPTIONS,
        tooltip = "Chooses which NPCs show their names over their heads.",
        get = function()
            local function On(name) return CVars:Get(name) == "1" end
            if On("UnitNameNPC") then return 4 end
            local special, hostile = On("UnitNameFriendlySpecialNPCName"), On("UnitNameHostleNPC")
            if special and hostile and On("UnitNameInteractiveNPC") then return 3 end
            if special and hostile then return 2 end
            if special then return 1 end
            return 5
        end,
        set = function(value)
            local values = NPC_NAME_VALUES[value]
            if not values then return end
            for i, name in ipairs(NPC_NAME_CVARS) do
                CVars:Set(name, values[i])
            end
        end,
        reset = function()
            for _, name in ipairs(NPC_NAME_CVARS) do
                CVars:Release(name)
            end
        end,
        resetLabel = "Right-click to undo Plateau's change.",
    }
end

local function CVarBitToggle(name, index, label, tooltip)
    return {
        type = "Toggle",
        label = label,
        tooltip = tooltip,
        path = "cvar." .. name .. "." .. tostring(index),
        reset = function() CVars:Release(name) end,
        resetLabel = "Right-click to undo Plateau's change.",
        get = function()
            return index ~= nil and C_CVar.GetCVar(name) ~= nil and C_CVar.GetCVarBitfield(name, index) == true
        end,
        set = function(value)
            if index == nil or C_CVar.GetCVar(name) == nil or InCombatLockdown() then return end
            local before = C_CVar.GetCVar(name)
            C_CVar.SetCVarBitfield(name, index, value)
            local after = C_CVar.GetCVar(name)
            C_CVar.SetCVar(name, before)
            CVars:Set(name, after)
        end,
    }
end

local reloadPrompt

local function EnsureReloadPrompt()
    if reloadPrompt then return reloadPrompt end
    local prompt = CreateFrame("Frame", "PlateauReloadPrompt", UIParent)
    prompt:SetSize(360, 110)
    prompt:SetPoint("TOP", UIParent, "TOP", 0, -220)
    prompt:SetFrameStrata("FULLSCREEN_DIALOG")
    prompt:SetToplevel(true)
    prompt:EnableMouse(true)
    Style.Panel(prompt, Style.colors.window, Style.colors.border)
    Style.Card(prompt)
    prompt:Hide()
    tinsert(UISpecialFrames, "PlateauReloadPrompt")

    local text = Style.Text(prompt, 13, Style.colors.text)
    text:SetPoint("TOPLEFT", 16, -16)
    text:SetPoint("TOPRIGHT", -16, -16)
    text:SetJustifyH("LEFT")
    text:SetWordWrap(true)
    text:SetText("This change only fully takes effect after a UI reload. Reload now?")

    local later = ns.Widgets.Button(prompt, "Later", 120, function() prompt:Hide() end)
    later:SetPoint("BOTTOMLEFT", 16, 16)
    local reload = ns.Widgets.Button(prompt, "Reload Now", 120, function() ReloadUI() end, true)
    reload:SetPoint("BOTTOMRIGHT", -16, 16)

    reloadPrompt = prompt
    return prompt
end

function ns.PromptReload()
    local prompt = EnsureReloadPrompt()
    prompt:Show()
    prompt:Raise()
end

local STACK = Enum.NamePlateStackType or {}

local function FriendlyToggle(path, cvar, label, tooltip)
    return {
        type = "Toggle",
        label = label,
        tooltip = tooltip,
        get = function() return CVars:Get(cvar) == "1" and ns.Get(path) ~= false end,
        set = function(value)
            CVars:Set(cvar, value and "1" or "0")
            Plateau.DB:Set(path, value == true)
        end,
        reset = function()
            CVars:Release(cvar)
            Plateau.DB:Reset(path)
        end,
    }
end

local function CVarSlider(name, label, min, max, step, tooltip)
    return CVarSpec("Slider", name, label, { min = min, max = max, step = step, tooltip = tooltip })
end

local function BlizzardDrawn(friendly)
    local list = {}
    local function Add(spec)
        list[#list + 1] = spec
    end
    local function Bits(cvar, enum, entries)
        if not (C_CVar.GetCVar(cvar) and enum) then return end
        for _, entry in ipairs(entries) do
            if enum[entry[1]] and entry.shown ~= false and (entry.friendly == true) == (friendly == true) then
                Add(CVarBitToggle(cvar, enum[entry[1]], entry[2], entry[3]))
            end
        end
    end
    local function Toggle(cvar, label, tooltip, forFriendly)
        if C_CVar.GetCVar(cvar) and (forFriendly == true) == (friendly == true) then
            Add(CVarToggle(cvar, label, tooltip))
        end
    end

    if not friendly then
        Add({ type = "Header", label = "Blizzard-drawn nameplates", collapsible = true, collapsed = true })
        Add({ type = "Note", label = "These only change nameplates the game draws itself. The friendly ones are on the Friendly page.", height = 24 })
        if C_CVar.GetCVar("nameplateStyle") and Enum.NamePlateStyle then
            local style = Enum.NamePlateStyle
            local options = {
                { value = style.Modern, label = "Modern" },
                { value = style.Thin, label = "Thin" },
                { value = style.Block, label = "Block" },
                { value = style.HealthFocus, label = "Health focus" },
                { value = style.CastFocus, label = "Cast focus" },
                { value = style.Legacy, label = "Legacy" },
            }
            if NameplatesOverrides and NameplatesOverrides.ShowClassicStyleOption and NameplatesOverrides.ShowClassicStyleOption() then
                table.insert(options, 1, { value = style.Classic, label = "Classic" })
            end
            Add({ type = "Dropdown", label = "Nameplate style", options = options,
              get = function() return tonumber(CVars:Get("nameplateStyle")) end,
              set = function(value) CVars:Set("nameplateStyle", value) end,
              reset = function() CVars:Release("nameplateStyle") end,
              resetLabel = "Right-click to undo Plateau's change.",
              path = "cvar.nameplateStyle",
              tooltip = "The look of the nameplates the game draws." })
        end
    end
    Toggle("nameplateForceShowUnitName", "Always show names on Blizzard nameplates", "Nameplates the game draws itself always show the unit's name.")

    Bits("nameplateInfoDisplay", Enum.NamePlateInfoDisplay, {
        { "CurrentHealthPercent", "Show health percent", "Shows the health percentage on the nameplates the game draws." },
        { "CurrentHealthValue", "Show health value", "Shows the health number on the nameplates the game draws." },
        { "RarityIcon", "Show rarity icon", "Shows the elite or rare icon on the nameplates the game draws." },
    })
    local important = not (NameplatesOverrides and NameplatesOverrides.ShowHighlightImportantCastsOption) or NameplatesOverrides.ShowHighlightImportantCastsOption()
    Bits("nameplateCastBarDisplay", Enum.NamePlateCastBarDisplay, {
        { "SpellName", "Cast bar: spell name", "Shows the spell name on the game's cast bars." },
        { "SpellIcon", "Cast bar: spell icon", "Shows the spell icon on the game's cast bars." },
        { "SpellTarget", "Cast bar: spell target", "Shows who the spell is aimed at on the game's cast bars." },
        { "HighlightImportantCasts", "Cast bar: highlight important casts", "Highlights casts the game flags as important.", shown = important },
        { "HighlightWhenCastTarget", "Cast bar: highlight when aimed at you", "Highlights a cast when you are its target." },
    })
    Bits("nameplateThreatDisplay", Enum.NamePlateThreatDisplay, {
        { "Progressive", "Threat display: progressive", "Shows threat building up gradually on the game's nameplates." },
        { "Flash", "Threat display: flash", "Flashes the game's nameplate when threat changes." },
        { "HealthBarColor", "Threat display: health bar color", "Colors the game's health bar by threat." },
    })
    Bits("nameplateEnemyNpcAuraDisplay", Enum.NamePlateEnemyNpcAuraDisplay, {
        { "Buffs", "Enemy NPCs: buffs", "Shows enemy NPC buffs on the nameplates the game draws." },
        { "Debuffs", "Enemy NPCs: your debuffs", "Shows your debuffs on enemy NPCs on the nameplates the game draws." },
        { "CrowdControl", "Enemy NPCs: crowd control", "Shows crowd control on enemy NPCs on the nameplates the game draws." },
    })
    Bits("nameplateEnemyPlayerAuraDisplay", Enum.NamePlateEnemyPlayerAuraDisplay, {
        { "Buffs", "Enemy players: buffs", "Shows enemy player buffs on the nameplates the game draws." },
        { "Debuffs", "Enemy players: your debuffs", "Shows your debuffs on enemy players on the nameplates the game draws." },
        { "LossOfControl", "Enemy players: loss of control", "Shows one large loss-of-control debuff on enemy players." },
    })
    Bits("nameplateFriendlyPlayerAuraDisplay", Enum.NamePlateFriendlyPlayerAuraDisplay, {
        { "Buffs", "Friendly players: your buffs", "Shows your buffs on friendly players on the nameplates the game draws.", friendly = true },
        { "Debuffs", "Friendly players: enemy debuffs", "Shows debuffs from enemies on friendly players on the nameplates the game draws.", friendly = true },
        { "LossOfControl", "Friendly players: loss of control", "Shows one large loss-of-control debuff on friendly players.", friendly = true },
    })
    Toggle("nameplateShowDebuffsOnFriendly", "Friendly players: show debuffs", "Shows debuffs on friendly players on the nameplates the game draws.", true)
    if not friendly and C_CVar.GetCVar("nameplateDebuffPadding") then
        Add(CVarSlider("nameplateDebuffPadding", "Debuff padding", 0, 50, 1, "Space between buff and debuff icons on the nameplates the game draws."))
    end
    Bits("nameplateSimplifiedTypes", Enum.NamePlateSimplifiedType, {
        { "Minion", "Simplify minions", "Draws pets, guardians and totems as small simplified nameplates." },
        { "MinusMob", "Simplify minor enemies", "Draws minor enemies as small simplified nameplates." },
        { "FriendlyPlayer", "Simplify friendly players", "Draws friendly players as small nameplates without name, health text or auras. Your target keeps its name. Also applies to Plateau's nameplates.", friendly = true },
        { "FriendlyNpc", "Simplify friendly NPCs", "Draws friendly NPCs as small nameplates without name, health text or auras. Your target keeps its name. Also applies to Plateau's nameplates.", friendly = true },
    })
    Toggle("nameplateShowFriendlyClassColor", "Class colors: friendly players", "Colors friendly player health bars by class on the nameplates the game draws.", true)
    Toggle("nameplateShowClassColor", "Class colors: enemy players", "Colors enemy player health bars by class on the nameplates the game draws.")
    return list
end

local RADIAL = {
    { value = 0, label = "Off" },
    { value = 1, label = "Target only" },
    { value = 2, label = "All enemies in combat" },
}

local STACK_SPACES = {
    { value = "bar", label = "Health bar only" },
    { value = "name", label = "Health bar and name" },
    { value = "barcast", label = "Health bar and cast bar" },
    { value = "cast", label = "Health bar, name and cast bar" },
    { value = "all", label = "Everything, including auras" },
}

local STACK_CVARS = { "nameplateOverlapV", "nameplateOverlapH" }

local function Near(name, value)
    local current = tonumber(CVars:Get(name))
    return current ~= nil and math.abs(current - tonumber(value)) < 0.001
end

local function StackPreset(key, label, tooltip, values)
    return {
        key = key,
        label = label,
        tooltip = tooltip,
        isActive = function()
            if not values then
                return not CVars:IsManaged("nameplateOverlapV") and not CVars:IsManaged("nameplateOverlapH")
            end
            return Near("nameplateOverlapV", values[1]) and Near("nameplateOverlapH", values[2])
        end,
        apply = function()
            for i, name in ipairs(STACK_CVARS) do
                if values then
                    CVars:Set(name, values[i])
                else
                    CVars:Release(name)
                end
            end
        end,
    }
end

local STACK_PRESETS = {
    StackPreset("tight", "Tight", "Nameplates sit close together, so big pulls fit on screen.", { "0.8", "0.7" }),
    StackPreset("balanced", "Balanced", "Restores your spacing from before Plateau changed it."),
    StackPreset("spread", "Spread out", "More room between nameplates, so they overlap less. Big pulls take more of the screen.", { "1.5", "1.1" }),
}

local function InstantMovement()
    return {
        type = "Toggle",
        label = "Instant movement",
        tooltip = "Nameplates jump to their new spot instead of sliding. Sets Movement speed to 1; turning it off restores your previous speed.",
        get = function() return Near("nameplateMotionSpeed", "1") end,
        set = function(value)
            if value then
                CVars:Set("nameplateMotionSpeed", "1")
            else
                CVars:Release("nameplateMotionSpeed")
            end
        end,
        reset = function() CVars:Release("nameplateMotionSpeed") end,
        resetLabel = "Right-click to undo Plateau's change.",
    }
end

local function BaseSpec(spec)
    spec.get = function() return Plateau.DB:Get(spec.path) end
    spec.set = function(value) Plateau.DB:Set(spec.path, value) end
    return spec
end

local function List(...)
    return { ... }
end

local function Join(...)
    local out = {}
    for i = 1, select("#", ...) do
        for _, control in ipairs((select(i, ...))) do
            out[#out + 1] = control
        end
    end
    return out
end

local function Gate(spec, test, reason)
    spec.enabledIf = test
    spec.disabledReason = reason
    return spec
end

local function On(path)
    return function() return ns.Get(path) == true end
end

local function Off(path)
    return function() return ns.Get(path) ~= true end
end

local function RealmNameToggle()
    local spec = CVarToggle("nameplateShowFriendlyRealmName", "Show realm names",
        "Adds the realm to the names of friendly players from other realms. Blizzard's nameplates update after a UI reload.")
    local set, reset = spec.set, spec.reset
    spec.set = function(value)
        set(value)
        if not Plateau.DB.saved.global.keepRealmMarker then
            ns.PromptReload()
        end
    end
    spec.reset = function()
        reset()
        if not Plateau.DB.saved.global.keepRealmMarker then
            ns.PromptReload()
        end
    end
    return spec
end

local function FriendlyOn()
    return ns.Get("look.friendly.enabled") == true
end

local function FriendlyPlayersOn()
    return FriendlyOn() and CVars:Get("nameplateShowFriendlyPlayers") == "1" and ns.Get("look.friendly.players") ~= false
end

local function FriendlyNpcsOn()
    return FriendlyOn() and CVars:Get("nameplateShowFriendlyNpcs") == "1" and ns.Get("look.friendly.npcs") ~= false
end

local function FriendlyAnyOn()
    return FriendlyPlayersOn() or FriendlyNpcsOn()
end

local function FriendlyOffReason()
    if not FriendlyOn() then
        return "Turn on Style friendly nameplates with Plateau to use this."
    end
    return "Turn on Friendly players or Friendly NPCs to use this."
end

local function NameOnlyGate(spec)
    local own, ownReason = spec.enabledIf, spec.disabledReason
    spec.enabledIf = function()
        return (not own or own()) and ns.Get("look.friendly.nameOnly") == true
    end
    spec.disabledReason = function()
        if own and not own() then
            return type(ownReason) == "function" and ownReason() or ownReason
        end
        return "Turn on Show names only to use this."
    end
    return spec
end

local function FriendlyGate(spec)
    return Gate(spec, FriendlyAnyOn, FriendlyOffReason)
end

local function FriendlyPlayersGate(spec)
    return Gate(spec, FriendlyPlayersOn, function()
        if not FriendlyOn() then return FriendlyOffReason() end
        return "Turn on Friendly players to use this."
    end)
end

local function FriendlyNpcsGate(spec)
    return Gate(spec, FriendlyNpcsOn, function()
        if not FriendlyOn() then return FriendlyOffReason() end
        return "Turn on Friendly NPCs to use this."
    end)
end

local function FriendlyRaidMarkerOn()
    return FriendlyAnyOn() and ns.Get("look.friendly.raidMarker.own") == true
end

local function FriendlyRaidMarkerReason()
    if not FriendlyAnyOn() then return FriendlyOffReason() end
    return "Turn on Separate friendly position to use this."
end

local function BorderOn()
    local style = ns.Get("look.health.borderStyle")
    return style ~= nil and style ~= "" and style ~= "none"
end

local function GateList(test, reason, ...)
    local specs = { ... }
    for _, spec in ipairs(specs) do
        Gate(spec, test, reason)
    end
    return specs
end

local PERCENT_FORMATS = { percent = true, both = true, paren = true, percentFirst = true, missingPercent = true }
local TEXT_ON = "Turn on Show health text to use this."

local function HealthTextOn()
    return ns.Get("look.healthText.enabled") == true
end

local function HealthTextPercent()
    return HealthTextOn() and PERCENT_FORMATS[ns.Get("look.healthText.format")] == true
end

local function HealthTextPercentReason()
    if not HealthTextOn() then return TEXT_ON end
    return "This format has no percentage."
end

local function HealthTextColors()
    return HealthTextOn() and ns.Get("look.healthText.colorByHealth") == true
end

local function HealthTextColorsReason()
    if not HealthTextOn() then return TEXT_ON end
    return "Turn on Color text by health to use this."
end

local NAME_ON = "Turn on Show names to use this."
local ENEMY_TARGET_ON = "Turn on Show enemy target name to use this."
local LEVEL_ON = "Turn on Show level to use this."

local function NameOn()
    return ns.Get("look.name.enabled") == true
end

local function EnemyTargetOn()
    return ns.Get("look.enemyTarget.enabled") == true
end

local function LevelOn()
    return ns.Get("look.level.enabled") == true
end

local RETAIL_NAME_NOTE = Plateau.flavor ~= "forever" and " In dungeons, raids and Mythic+ names always show in full." or ""

local function CastBorderOn()
    local style = ns.Get("look.castbar.borderStyle")
    return style ~= nil and style ~= "" and style ~= "none"
end

local POWER_ON = "Turn on Show enemy power bar to use this."

local function PowerOn()
    return ns.Get("look.enemyPower.enabled") == true
end

local function PowerText()
    return PowerOn() and ns.Get("look.enemyPower.showText") == true
end

local function PowerTextReason()
    if not PowerOn() then return POWER_ON end
    return "Turn on Show power text to use this."
end

local function StackingOn()
    if not (C_CVar.GetCVar("nameplateStackingTypes") and STACK) then return true end
    return (STACK.Enemy and C_CVar.GetCVarBitfield("nameplateStackingTypes", STACK.Enemy) == true)
        or (STACK.Friendly and C_CVar.GetCVarBitfield("nameplateStackingTypes", STACK.Friendly) == true)
end

local function DimsOthers()
    return (ns.Get("look.target.dimOthers") or 1) < 1
end

local HOVER_ON = "Turn on Enable mouseover highlight to use this."

local function HoverOn()
    return ns.Get("look.mouseover.enabled") == true
end

local function HoverGlowOn()
    return HoverOn() and ns.Get("look.mouseover.glow") == true
end

local function HoverGlowReason()
    if not HoverOn() then return HOVER_ON end
    return "Turn on Show mouseover glow to use this."
end

local function Any(...)
    local tests = { ... }
    return function()
        for _, test in ipairs(tests) do
            if test() then return true end
        end
        return false
    end
end

local BADGE_KEYS = { "showElite", "showRareElite", "showRare", "showBoss" }

local function BadgeOn()
    if ns.Get("look.classification.enabled") ~= true then return false end
    for _, key in ipairs(BADGE_KEYS) do
        if ns.Get("look.classification." .. key) == true then return true end
    end
    return false
end

local function BadgeReason()
    if ns.Get("look.classification.enabled") ~= true then return "Turn on Show elite icon to use this." end
    return "Turn on at least one of Elites, Rare elites, Rares or World bosses to use this."
end

local PREVIEW_CASTS = {
    { value = "normal", label = "Normal cast" },
    { value = "important", label = "Important cast" },
    { value = "cantInterrupt", label = "Uninterruptible cast" },
    { value = "importantStop", label = "Important, uninterruptible" },
    { value = "kickCooldown", label = "Interrupt on cooldown" },
    { value = "interrupted", label = "Interrupted" },
}

local PREVIEW_ENEMIES = {
    { value = "caster", label = "Caster" },
    { value = "boss", label = "Boss" },
    { value = "lieutenant", label = "Lieutenant" },
    { value = "higher", label = "Higher-level elite" },
    { value = "elite", label = "Elite" },
    { value = "trivial", label = "Minor enemy" },
    { value = "enemyPlayer", label = "Enemy player" },
    { value = "neutral", label = "Neutral enemy" },
    { value = "tapped", label = "Tapped by another player" },
}

local PREVIEW_THREAT = {
    { value = "none", label = "No threat color" },
    { value = "bad", label = "Has aggro" },
    { value = "warning", label = "Losing aggro" },
    { value = "good", label = "Safe threat" },
}

local PREVIEW_BADGES = {
    { value = "elite", label = "Elite (gold)" },
    { value = "rareelite", label = "Rare elite (silver)" },
    { value = "rare", label = "Rare (star)" },
    { value = "worldboss", label = "World boss (gold)" },
    { value = "normal", label = "Normal (no icon)" },
}

local function HeaderPick(key, label, options, tooltip)
    return {
        label = label, options = options, tooltip = tooltip,
        get = function() return ns.GetPreviewPick and ns.GetPreviewPick(key) end,
        set = function(value)
            if ns.SetPreviewPick then
                ns.SetPreviewPick(key, value)
            end
        end,
    }
end

local function EnemiesOn()
    return CVars:Get("nameplateShowEnemies") == "1"
end

local function GameExtras(group)
    local list = {}
    local function Add(spec, cvar)
        if C_CVar.GetCVar(cvar) ~= nil then
            list[#list + 1] = spec
        end
    end
    if group == "names" then
        Add(CVarToggle("UnitNameFocused", "Always show your target's name", "Shows your target's name over its head even when names over heads are off."), "UnitNameFocused")
    elseif group == "personal" then
        list[1] = { type = "Header", label = "Personal resource display" }
        list[2] = CVarToggle("nameplateShowSelf", "Personal resource display", "Shows your health and power in a bar over your character.")
        Add(Gate(CVarToggle("nameplateShowAllPersonalAuras", "Show all personal auras", "Shows every buff and debuff on you on the personal resource display, not just important ones."),
            function() return CVars:Get("nameplateShowSelf") == "1" end, "Turn on Personal resource display to use this."), "nameplateShowAllPersonalAuras")
    elseif group == "soft" then
        Add(CVarToggle("SoftTargetIconEnemy", "Soft target icon: enemies", "Shows an icon over the enemy you are soft-targeting with action targeting or a controller."), "SoftTargetIconEnemy")
        Add(CVarToggle("SoftTargetIconFriend", "Soft target icon: friends", "Shows an icon over the friendly unit you are soft-targeting."), "SoftTargetIconFriend")
        Add(CVarToggle("SoftTargetIconInteract", "Soft target icon: interactable", "Shows an icon over the object or NPC you can interact with right now."), "SoftTargetIconInteract")
        Add(CVarSlider("SoftTargetNameplateSize", "Soft target icon size", 10, 40, 1, "How big the soft target icons are."), "SoftTargetNameplateSize")
        if #list > 0 then
            table.insert(list, 1, { type = "Header", label = "Soft target icons" })
        end
    end
    return list
end

local BOSS_ON = "Turn on Show boss phase lines to use this."
local BOSS_TARGETS = {
    { value = "boss", label = "Bosses" },
    { value = "all", label = "Every enemy in the fight" },
}
local selectedBoss = 3201

local function BossName(id)
    for _, boss in ipairs(Plateau.bossPhaseList or {}) do
        if boss.id == id then
            return boss.name
        end
    end
    local seen = Plateau.BossPhaseSeen and Plateau.BossPhaseSeen() or {}
    return seen[id] or tostring(id)
end

local function BossOptions()
    local options = {}
    local place
    for _, boss in ipairs(Plateau.bossPhaseList or {}) do
        if boss.place ~= place then
            place = boss.place
            options[#options + 1] = { title = true, label = place:upper() }
        end
        local lines = Plateau.BossPhaseLines and Plateau.BossPhaseLines(boss.id) or ""
        options[#options + 1] = { value = boss.id, label = lines ~= "" and (boss.name .. "  (" .. lines .. ")") or boss.name }
    end
    local seen = Plateau.BossPhaseSeen and Plateau.BossPhaseSeen() or {}
    local extra = {}
    for id, name in pairs(seen) do
        local known = false
        for _, boss in ipairs(Plateau.bossPhaseList or {}) do
            if boss.id == id then known = true break end
        end
        if not known then
            extra[#extra + 1] = { value = id, label = name }
        end
    end
    if #extra > 0 then
        table.sort(extra, function(a, b) return a.label < b.label end)
        options[#options + 1] = { title = true, label = "OTHER BOSSES YOU'VE FOUGHT" }
        for _, option in ipairs(extra) do
            options[#options + 1] = option
        end
    end
    return options
end

local function DescribeLines(text)
    local values = {}
    for number in (text or ""):gmatch("%d+%.?%d*") do
        local value = tonumber(number)
        if value and value > 0 and value < 100 and #values < 4 then
            values[#values + 1] = value .. "%"
        end
    end
    if #values == 0 then
        return "No lines"
    end
    return Plateau.T("Lines at %s"):format(table.concat(values, ", "))
end

local function Chosen(path)
    return function()
        local value = ns.Get(path)
        return value ~= nil and value ~= "" and value ~= "none"
    end
end

local AURA_SHAPES = {
    { value = "square", label = "Square" },
    { value = "wide", label = "Wide" },
    { value = "flat", label = "Extra wide" },
}

local AURA_TEXT_POINTS = {
    { value = "CENTER", label = "Center" },
    { value = "TOP", label = "Top" },
    { value = "BOTTOM", label = "Bottom" },
    { value = "TOPLEFT", label = "Top left" },
    { value = "TOPRIGHT", label = "Top right" },
    { value = "BOTTOMLEFT", label = "Bottom left" },
    { value = "BOTTOMRIGHT", label = "Bottom right" },
}

local function AuraWhichControls(path, groupKey)
    return List(
        { type = "Header", label = "Which auras" },
        { type = "Slider", path = path .. ".maxDuration", label = "Maximum aura duration", min = 0, max = 600, step = 5,
          tooltip = "Hides auras with a total duration longer than this many seconds, and permanent auras. 0 turns the limit off." },
        { type = "Note", label = "Spell lists are saved separately for each specialization. Switch specializations to edit its lists.", height = 24 },
        SpecSpellList(groupKey, "hide", "Hidden spells", "Empty: no spells excluded",
          "Spells that never show in this group. Enter spell IDs or names, separated by commas, and press Enter. Enemy buffs and important auras can only be hidden in the open world."),
        SpecSpellList(groupKey, "only", "Allowed spells", "Empty: all spells matching this group's filters are allowed",
          "When filled, only these spells show in this group. Enter spell IDs or names, separated by commas. They still have to pass the group's other filters.")
    )
end

local function AuraLayoutControls(path)
    return List(
        { type = "Header", label = "Layout" },
        { type = "Dropdown", path = path .. ".sort", label = "Sort order", options = AURA_SORT,
          tooltip = "The order of icons in this group. Your own auras always come first." },
        { type = "Dropdown", path = path .. ".side", label = "Position", options = AURA_SIDES,
          tooltip = "Which side of the nameplate this group of icons sits on." },
        { type = "Dropdown", path = path .. ".align", label = "Alignment", options = AURA_ALIGN,
          tooltip = "Where the row starts when the icons are above or below the nameplate." },
        { type = "Dropdown", path = path .. ".grow", label = "Growth direction", options = AURA_GROW,
          tooltip = "The direction new icons are added, and where a new row or column starts. Automatic follows Position and Alignment." },
        { type = "Slider", path = path .. ".offsetX", label = "Horizontal offset", min = -80, max = 80,
          tooltip = "Nudges this group of icons left (negative) or right (positive)." },
        { type = "Slider", path = path .. ".offsetY", label = "Vertical offset", min = -80, max = 80,
          tooltip = "Nudges this group of icons down (negative) or up (positive)." },
        { type = "Slider", path = path .. ".size", label = "Icon size", min = 10, max = 48,
          tooltip = "How big each icon in this group is." },
        { type = "Dropdown", path = path .. ".shape", label = "Icon shape", options = AURA_SHAPES,
          tooltip = "Square shows the whole icon. Wide and Extra wide crop the top and bottom to save height." },
        { type = "Slider", path = path .. ".maxIcons", label = "Maximum icons", min = 1, max = 12,
          tooltip = "Caps how many icons this group ever shows at once, even if more apply." },
        { type = "Slider", path = path .. ".perRow", label = "Icons per row", min = 1, max = 12,
          tooltip = "How many icons fit before starting a new row, or a new column when icons grow up or down." },
        { type = "Slider", path = path .. ".spacing", label = "Icon spacing", min = 0, max = 10,
          tooltip = "Gap between adjacent icons in this group." }
    )
end

local function AuraIconControls(path, withPandemic)
    local controls = List(
        { type = "Header", label = "Icon" },
        { type = "Toggle", path = path .. ".showTimer", label = "Show remaining time",
          tooltip = "Shows a countdown of the remaining duration on each icon." },
        Gate({ type = "Slider", path = path .. ".timerSize", label = "Timer font size", min = 6, max = 20,
          tooltip = "How big the countdown text is." }, On(path .. ".showTimer"), "Turn on Show remaining time to use this."),
        Gate({ type = "Dropdown", path = path .. ".timerPosition", label = "Timer position", options = AURA_TEXT_POINTS,
          tooltip = "Where the remaining time sits on each icon." }, On(path .. ".showTimer"), "Turn on Show remaining time to use this."),
        { type = "Toggle", path = path .. ".showStacks", label = "Show stack count",
          tooltip = "Shows the number of stacks on each icon, when it has more than one." },
        Gate({ type = "Slider", path = path .. ".stackSize", label = "Stack count font size", min = 6, max = 20,
          tooltip = "How big the stack count text is." }, On(path .. ".showStacks"), "Turn on Show stack count to use this."),
        Gate({ type = "Dropdown", path = path .. ".stackPosition", label = "Stack count position", options = AURA_TEXT_POINTS,
          tooltip = "Where the stack count sits on each icon." }, On(path .. ".showStacks"), "Turn on Show stack count to use this."),
        { type = "Toggle", path = path .. ".swipe", label = "Cooldown swipe",
          tooltip = "Shows a dark sweep over each icon as the aura runs out." },
        { type = "Slider", path = path .. ".borderSize", label = "Icon border thickness", min = 0, max = 3,
          tooltip = "How thick the border around each icon is. 0 removes it." },
        Gate({ type = "Color", path = path .. ".borderColor", label = "Icon border color",
          tooltip = "The color of the border around each icon. Dispel-type colors, when on, draw over it." }, function() return (ns.Get(path .. ".borderSize") or 0) > 0 end, "Raise Icon border thickness above 0 to use this."),
        { type = "Toggle", path = path .. ".dispelBorder", label = "Color borders by dispel type",
          tooltip = "Colors each icon's border by dispel type: Magic, Curse, Poison, Disease or Enrage." }
    )
    if withPandemic then
        controls[#controls + 1] = { type = "Toggle", path = path .. ".pandemic", label = "Highlight when refreshable",
          tooltip = "Turns the icon red once recasting it would keep the remaining time." }
    end
    return controls
end

local function GateTable(test, reason, list)
    for _, spec in ipairs(list) do
        if spec.enabledIf then
            local own, ownReason = spec.enabledIf, spec.disabledReason
            spec.enabledIf = function() return test() and own() end
            spec.disabledReason = function()
                if not test() then return reason end
                if type(ownReason) == "function" then return ownReason() end
                return ownReason
            end
        elseif spec.type ~= "Header" and spec.type ~= "Note" and spec.type ~= "Link" then
            Gate(spec, test, reason)
        end
    end
    return list
end

local function AuraPage(key, title, path, groupKey, intro, introHeight, showLabel, showTooltip, extras, withPandemic)
    local on, reason = On(path .. ".enabled"), Plateau.T("Turn on %s to use this."):format(Plateau.T(showLabel))
    return Section(key, title, path, Join(
        List(
            { type = "Note", label = intro, height = introHeight },
            { type = "Header", label = "Show" },
            { type = "Toggle", path = path .. ".enabled", label = showLabel, tooltip = showTooltip }
        ),
        GateTable(on, reason, extras or {}),
        GateTable(on, reason, AuraWhichControls(path, groupKey)),
        GateTable(on, reason, AuraLayoutControls(path)),
        GateTable(on, reason, AuraIconControls(path, withPandemic))
    ))
end

local AURA_TEXT_PATHS = { "look.auras.font", "look.auras.outline", "look.auras.shadow", "look.auras.tooltips", "look.auras.tooltipsInCombat" }

local function AuraTextControls()
    return List(
        { type = "Note", label = "Settings shared by every aura group: the time and stack text on each icon, and tooltips.", height = 24 },
        { type = "Header", label = "Text" },
        { type = "Dropdown", path = "look.auras.font", label = "Font", options = Fonts, unknown = "Custom font",
          tooltip = "The typeface for the time and stack text on every aura icon." },
        { type = "Dropdown", path = "look.auras.outline", label = "Font outline", options = OUTLINES,
          tooltip = "A dark edge around the aura text to keep it readable." },
        { type = "Toggle", path = "look.auras.shadow", label = "Text shadow",
          tooltip = "Adds a soft dark shadow behind the aura text." },
        { type = "Header", label = "Tooltips" },
        { type = "Toggle", path = "look.auras.tooltips", label = "Show aura tooltips",
          tooltip = "Shows the aura's tooltip when you mouse over its icon. Clicking still targets the enemy." },
        { type = "Toggle", path = "look.auras.tooltipsInCombat", label = "Show tooltips in combat",
          tooltip = "Off hides aura tooltips during combat." },
        { type = "Note", label = "In dungeons and raids the game decides which auras go in each group. Icon size and text changes made in combat apply after combat ends.", height = 32 }
    )
end

local function Page(key, title, paths, cvars, controls)
    local section = Section(key, title, paths, controls)
    if cvars then
        section.reset = function()
            for _, path in ipairs(paths) do
                Plateau.DB:Reset(path)
            end
            for _, name in ipairs(cvars) do
                CVars:Release(name)
            end
        end
    end
    return section
end

local SIZE_PATHS = {
    "look.scaling.enabled", "look.scaling.boss", "look.scaling.lieutenant", "look.scaling.higher", "look.scaling.caster",
    "look.scaling.elite", "look.scaling.trivial", "look.scaling.focusGrow", "look.scaling.focusScale",
    "look.scaling.castPop", "look.scaling.castScale", "look.target.useBlizzardScale", "look.target.scale",
    "look.scaling.mouseoverGrow", "look.scaling.mouseoverScale", "look.scaling.smooth",
    "look.scaling.combatEnabled", "look.scaling.combatScale", "look.scaling.idleScale",
    "look.plate.followBlizzardSize",
}
local SIZE_CVARS = { "nameplateSize", "nameplateAuraScale", "nameplateMinScale", "nameplateMaxScale" }
local FADING_PATHS = { "look.range", "look.target.dimOthers", "look.target.dimCombatOnly", "look.target.dimSkipFriendly" }
local FADING_CVARS = { "nameplateOccludedAlphaMult", "nameplateMinAlpha", "nameplatePlayRemovalAnimation" }
local LAYERING_PATHS = { "look.scaling.castFront", "look.plate.stackSpace", "look.scaling.mouseoverFront", "look.plate.offsetY" }
local LAYERING_CVARS = { "nameplateStackingTypes", "nameplateOverlapV", "nameplateOverlapH", "nameplateMotionSpeed", "nameplateOtherAtBase" }
local CLICK_PATHS = { "look.plate.clickX", "look.plate.clickY", "look.plate.clickCastBar", "look.plate.clickOffsetY", "look.plate.clickThroughFriendly" }
local COMBAT_PATHS = { "look.idle" }
local TARGET_LOOK = {}
for _, key in ipairs({ "ring", "ringColor", "ringSize", "colorBar", "barColor", "texture", "overlayPattern", "overlayAlpha",
    "overlayContrast", "brighten", "arrows", "arrowStyle", "arrowPlacement", "arrowSize", "arrowGap", "arrowColor",
    "brackets", "bracketStyle", "bracketSize", "bracketGap", "bracketColor", "glow", "glowColor", "glowSize" }) do
    TARGET_LOOK[#TARGET_LOOK + 1] = "look.target." .. key
end

ns.sections = {
    {
        key = "game",
        title = "Game settings",
        reset = function()
            CVars:ReleaseAll()
        end,
        controls = Join(List(
            { type = "Note", label = "Changes Blizzard's own nameplate settings. Right-click a setting to undo Plateau's change, or type /plt cvars restore to undo them all. This restores your previous values, not Blizzard's defaults.", height = 32 },

            { type = "Header", label = "Names over heads" },
            { type = "Note", label = "Names shown over characters' heads. These are Blizzard's Names options.", height = 24 },
            CVarToggle("UnitNameOwn", "Show your name", "Shows your character's name over your head."),
            NpcNames(),
            CVarToggle("UnitNameNonCombatCreatureName", "Show critter and companion names", "Shows names over critters, battle pets and companions."),
            CVarToggle("UnitNameFriendlyPlayerName", "Show friendly player names", "Shows names over friendly players' heads."),
            CVarToggle("UnitNameFriendlyMinionName", "Show friendly minion names", "Shows names over friendly players' pets, totems and other minions."),
            CVarToggle("UnitNameEnemyPlayerName", "Show enemy player names", "Shows names over enemy players' heads."),
            CVarToggle("UnitNameEnemyMinionName", "Show enemy minion names", "Shows names over enemy players' pets, totems and other minions.")
        ), GameExtras("names"), List(

            { type = "Header", label = "Which nameplates show" },
            CVarToggle("nameplateShowAll", "Always show nameplates", "Shows nameplates at all times. Off: only during combat."),
            CVarToggle("nameplateShowEnemies", "Enemy nameplates", "Shows nameplates for enemies. Off hides all of them."),
            Gate(CVarToggle("nameplateShowEnemyMinus", "Minor enemies", "Shows nameplates for minor enemies, the weakest trash units."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyMinions", "Enemy minions", "Shows nameplates for enemy pets, totems and other minions."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyPets", "Enemy pets", "Shows nameplates for enemy players' pets."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyGuardians", "Enemy guardians", "Shows nameplates for temporary helpers summoned by enemies."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyTotems", "Enemy totems", "Shows nameplates for enemy totems."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            CVarSlider("nameplateMaxDistance", "Maximum nameplate distance", 10, 60, 1, "How far away, in yards, a unit can be and still show a nameplate.")
        ), GameExtras("personal"), GameExtras("soft"), List(

            { type = "Header", label = "Off-screen nameplates", collapsible = true, collapsed = true },
            CVarToggle("nameplateShowOffscreen", "Keep enemies in combat on screen",
                "Pins nameplates of enemies in combat with your group to the screen edge while they are off screen."),
            { type = "Dropdown", label = "Pin off-screen nameplates", options = RADIAL,
              get = function() return tonumber(CVars:Get("nameplateTargetRadialPosition")) or 0 end,
              set = function(value) CVars:Set("nameplateTargetRadialPosition", value) end,
              reset = function() CVars:Release("nameplateTargetRadialPosition") end,
              resetLabel = "Right-click to undo Plateau's change.",
              path = "cvar.nameplateTargetRadialPosition",
              tooltip = "Pins your target, or every enemy you are fighting, around the screen edge while off screen." },
            CVarSlider("nameplateTopInset", "Top screen margin", 0, 0.3, 0.01, "Keeps nameplates out of the top of the screen. 0.10 is 10% of the screen height. Works from patch 12.1.5."),
            CVarSlider("nameplateBottomInset", "Bottom screen margin", 0, 0.3, 0.01, "Keeps nameplates out of the bottom of the screen. 0.10 is 10% of the screen height. Works from patch 12.1.5.")
        ), BlizzardDrawn()),
    },

    Page("size", "Size", SIZE_PATHS, SIZE_CVARS, List(
        { type = "Header", label = "Nameplate scale", first = true },
        { type = "Note", label = "Each nameplate uses its largest scale below; they don't stack. Combat scale multiplies the enemy type scale. The preview always shows normal size.", height = 32 },
        { type = "Toggle", path = "look.scaling.smooth", label = "Smooth size changes",
          tooltip = "Nameplates grow and shrink smoothly instead of snapping." },
        { type = "Header", label = "Enemy type scale" },
        { type = "Toggle", path = "look.scaling.enabled", label = "Scale by enemy type", wide = true,
          tooltip = "Sizes enemy nameplates by type, using the same types as the Health bar colors." },
        Gate({ type = "Slider", path = "look.scaling.boss", label = "Bosses", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of boss nameplates." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.caster", label = "Casters", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of enemies that use mana." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.lieutenant", label = "Lieutenants", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of lieutenants and elites two or more levels above you." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.elite", label = "Other elites", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of elites that aren't bosses, lieutenants, higher-level elites or casters." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.higher", label = "Higher-level elites", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of elites one level above you." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.trivial", label = "Other enemies", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of minor enemies and every enemy not covered above." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        { type = "Header", label = "Combat scale" },
        { type = "Toggle", path = "look.scaling.combatEnabled", label = "Scale by combat state",
          tooltip = "Sizes enemy NPCs differently in and out of combat. Multiplies the enemy type scale." },
        Gate({ type = "Slider", path = "look.scaling.combatScale", label = "In combat", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of enemies in combat with anyone." }, On("look.scaling.combatEnabled"), "Turn on Scale by combat state to use this."),
        Gate({ type = "Slider", path = "look.scaling.idleScale", label = "Out of combat", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of enemies not in combat." }, On("look.scaling.combatEnabled"), "Turn on Scale by combat state to use this."),
        { type = "Header", label = "Target scale" },
        { type = "Toggle", path = "look.target.useBlizzardScale", label = "Use Blizzard target scaling",
          tooltip = "Your enemy target grows by Blizzard's target scale. Turn off to set your own size below." },
        Gate({ type = "Slider", path = "look.target.scale", label = "Custom target scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of your enemy target's nameplate. Friendly targets never grow." }, Off("look.target.useBlizzardScale"), "Not used while Use Blizzard target scaling is on."),
        { type = "Header", label = "Focus scale" },
        { type = "Toggle", path = "look.scaling.focusGrow", label = "Scale focus nameplate",
          tooltip = "Changes the size of your focus's nameplate." },
        Gate({ type = "Slider", path = "look.scaling.focusScale", label = "Focus scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of your focus's nameplate." }, On("look.scaling.focusGrow"), "Turn on Scale focus nameplate to use this."),
        { type = "Header", label = "Casting scale" },
        { type = "Toggle", path = "look.scaling.castPop", label = "Scale casting nameplates",
          tooltip = "Changes the size of an enemy's nameplate while it casts. Applies to every cast." },
        Gate({ type = "Slider", path = "look.scaling.castScale", label = "Casting scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of an enemy's nameplate while it casts or channels." }, On("look.scaling.castPop"), "Turn on Scale casting nameplates to use this."),
        { type = "Header", label = "Mouseover scale" },
        { type = "Toggle", path = "look.scaling.mouseoverGrow", label = "Scale mouseover nameplate",
          tooltip = "Changes the size of the enemy nameplate under your cursor." },
        Gate({ type = "Slider", path = "look.scaling.mouseoverScale", label = "Mouseover scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of the enemy nameplate under your cursor." }, On("look.scaling.mouseoverGrow"), "Turn on Scale mouseover nameplate to use this."),

        { type = "Header", label = "Blizzard nameplate size" },
        BaseSpec({ type = "Toggle", path = "look.plate.followBlizzardSize", label = "Use Blizzard nameplate sizing for enemies",
          tooltip = "Blizzard's Nameplate Size and Debuff Scale also resize enemy nameplates. Friendly nameplates always follow Nameplate Size." }),
        CVarSlider("nameplateSize", "Nameplate size", 1, 5, 1, "Blizzard's Nameplate Size, from 1 (Small) to 5 (Huge). Same setting as Blizzard nameplate size on the Friendly page."),
        CVarSlider("nameplateAuraScale", "Debuff scale", 0.7, 1.4, 0.1, "Blizzard's aura icon size. Plateau's auras follow it while Use Blizzard nameplate sizing for enemies is on."),

        { type = "Header", label = "Size by distance" },
        CVarSlider("nameplateMinScale", "Distant nameplate scale", 0.5, 1, 0.05, "Size of nameplates at the maximum nameplate distance."),
        CVarSlider("nameplateMaxScale", "Nearby nameplate scale", 0.5, 1.5, 0.05, "Size of nameplates right next to you.")
    )),

    Page("fading", "Fading", FADING_PATHS, FADING_CVARS, List(
        { type = "Header", label = "Range fading", first = true },
        { type = "Toggle", path = "look.range.enabled", label = "Fade nameplates outside interrupt range",
          tooltip = "Fades enemies you are too far away to interrupt." },
        Gate({ type = "Slider", path = "look.range.alpha", label = "Out-of-range opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "Opacity of enemies outside your interrupt range. Nameplates never fade if you know no interrupt." }, On("look.range.enabled"), "Turn on Fade nameplates outside interrupt range to use this."),

        { type = "Header", label = "Non-target fading" },
        { type = "Slider", path = "look.target.dimOthers", label = "Non-target opacity", keywords = "dim dimming dimmed dim others fade faded other plates nameplates friendly transparent", min = 0.2, max = 1, step = 0.05,
          tooltip = "Opacity of every other nameplate while you have a target. Stacks with range fading." },
        Gate({ type = "Toggle", path = "look.target.dimCombatOnly", label = "Dim others only in combat",
          tooltip = "Non-target opacity applies only while you are in combat." }, DimsOthers, "Lower Non-target opacity below 1 to use this."),
        Gate({ type = "Toggle", path = "look.target.dimSkipFriendly", label = "Don't dim friendly nameplates",
          tooltip = "Non-target opacity fades only enemy nameplates." }, DimsOthers, "Lower Non-target opacity below 1 to use this."),
        { type = "Toggle", path = "look.range.mouseoverFull", label = "Keep mouseover at full opacity",
          tooltip = "The nameplate under your cursor ignores Non-target opacity and range fading." },

        { type = "Header", label = "Behind walls" },
        CVarSlider("nameplateOccludedAlphaMult", "Behind-wall opacity", 0, 1, 0.05, "Opacity of nameplates for units behind walls or terrain."),
        { type = "Note", label = "Choose where nameplates behind walls fade.", height = 24 },
        { type = "Toggle", label = "Fade in the open world", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("world") end,
          set = function(value) Plateau.OccludedFade:SetOn("world", value == true) end,
          tooltip = "Fades nameplates behind walls in the open world." },
        { type = "Toggle", label = "Fade in dungeons", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("dungeon") end,
          set = function(value) Plateau.OccludedFade:SetOn("dungeon", value == true) end,
          tooltip = "Fades nameplates behind walls in dungeons, including Mythic+." },
        { type = "Toggle", label = "Fade in raids", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("raid") end,
          set = function(value) Plateau.OccludedFade:SetOn("raid", value == true) end,
          tooltip = "Fades nameplates behind walls in raids." },
        { type = "Toggle", label = "Fade in delves and scenarios", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("delve") end,
          set = function(value) Plateau.OccludedFade:SetOn("delve", value == true) end,
          tooltip = "Fades nameplates behind walls in delves and scenarios." },
        { type = "Toggle", label = "Fade in battlegrounds and arenas", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("pvp") end,
          set = function(value) Plateau.OccludedFade:SetOn("pvp", value == true) end,
          tooltip = "Fades nameplates behind walls in battlegrounds and arenas." },

        { type = "Header", label = "By distance" },
        CVarSlider("nameplateMinAlpha", "Distant nameplate opacity", 0, 1, 0.05, "Opacity of nameplates at the maximum nameplate distance."),

        { type = "Header", label = "Blizzard fading" },
        { type = "Dropdown", path = "look.range.gameFade", label = "Blizzard fading applies to",
          options = { { value = "both", label = "Enemies and friendly" }, { value = "enemy", label = "Enemies only" }, { value = "friendly", label = "Friendly only" } },
          tooltip = "Which nameplates use Blizzard's behind-wall and distance fading. Plateau's own fading applies to all of them." },
        CVarToggle("nameplatePlayRemovalAnimation", "Fade out disappearing nameplates", "Nameplates fade out instead of vanishing.")
    )),

    Page("layering", "Layering and stacking", LAYERING_PATHS, LAYERING_CVARS, List(
        { type = "Header", label = "Nameplate layering", first = true },
        { type = "Toggle", path = "look.scaling.castFront", label = "Casting enemies in front", wide = true,
          keywords = "layering priority order caster casters cast in front draw over overlap",
          tooltip = "Casting enemies draw over nearby nameplates. Your target stays on top." },
        { type = "Toggle", path = "look.scaling.mouseoverFront", label = "Mouseover in front",
          tooltip = "The nameplate under your cursor draws above all others, including your target." },

        { type = "Header", label = "Stacking" },
        CVarBitToggle("nameplateStackingTypes", STACK.Enemy, "Stack enemy nameplates", "Enemy nameplates move apart instead of overlapping."),
        CVarBitToggle("nameplateStackingTypes", STACK.Friendly, "Stack friendly nameplates", "Friendly nameplates move apart instead of overlapping."),
        Gate({ type = "Presets", presets = STACK_PRESETS, wide = true, label = "Stacking presets", keywords = "tight balanced spread out spacing overlap crowded stack",
          tooltip = "Ready-made spacing between stacked nameplates." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        { type = "Note", label = "Click a preset twice to apply it. The underlined preset is in use.", height = 24 },
        Gate({ type = "Toggle", label = "Show stacking boxes",
          get = function() return ns.stackBoxesOn == true end,
          set = function(value)
              ns.stackBoxesOn = value
              Plateau.SetStackBoxes(value)
          end,
          tooltip = "Outlines the area each nameplate keeps clear when stacking. Stays on until you turn it off or /reload." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),

        { type = "Header", label = "Stacking bounds and spacing" },
        Gate({ type = "Dropdown", label = "Stacking bounds", options = STACK_SPACES,
          get = function() return Plateau.DB:Get("look.plate.stackSpace") end,
          set = function(value) Plateau.DB:Set("look.plate.stackSpace", value) end,
          tooltip = "Which parts of a nameplate count when stacking. Larger bounds spread big pulls further up the screen." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        Gate(CVarSlider("nameplateOverlapV", "Vertical spacing", 0.3, 2, 0.05, "Vertical space between stacked nameplates."), StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        Gate(CVarSlider("nameplateOverlapH", "Horizontal spacing", 0.3, 2, 0.05, "Horizontal space between stacked nameplates."), StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),

        { type = "Note", warn = true, height = 32,
          visibleIf = function()
              local space = ns.Get("look.plate.stackSpace")
              return space == "cast" or space == "barcast" or space == "all"
          end,
          label = "These bounds keep room for a cast bar on every nameplate, so big pulls stack much higher. Health bar only or Health bar and name keep pulls tighter." },

        { type = "Header", label = "Movement" },
        InstantMovement(),
        CVarSlider("nameplateMotionSpeed", "Movement speed", 0, 1, 0.01, "How fast nameplates slide into place when stacking. Requires patch 12.1.5."),

        { type = "Header", label = "Position" },
        BaseSpec({ type = "Slider", path = "look.plate.offsetY", label = "Nameplate vertical offset", min = -60, max = 60,
          tooltip = "Moves nameplates up or down from their usual spot. Doesn't change stacking or nameplates the game draws itself." }),
        CVarToggle("nameplateOtherAtBase", "Position nameplates at feet", "Shows nameplates at units' feet instead of above their heads.")
    )),

    Page("clicking", "Clickable area", CLICK_PATHS, nil, List(
        { type = "Header", label = "Clickable area", first = true },
        { type = "Toggle", label = "Show clickable areas",
          get = function() return ns.clickAreasOn == true end,
          set = function(value)
              ns.clickAreasOn = value
              ns.UpdateClickAreas()
          end,
          tooltip = "Outlines where clicks land on the preview and on nameplates. Turns off when you close this window." },
        BaseSpec({ type = "Slider", path = "look.plate.clickX", label = "Horizontal padding", min = 0, max = 30,
          tooltip = "Widens the clickable area without enlarging the nameplate. In combat, applies as new nameplates appear." }),
        BaseSpec({ type = "Slider", path = "look.plate.clickY", label = "Vertical padding", min = 0, max = 30,
          tooltip = "Makes the clickable area taller without enlarging the nameplate." }),
        BaseSpec({ type = "Slider", path = "look.plate.clickOffsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Moves the clickable area up or down without changing its size." }),
        BaseSpec({ type = "Toggle", path = "look.plate.clickCastBar", label = "Include cast bar in clickable area",
          tooltip = "Clicking an enemy's cast bar also targets it." }),

        { type = "Header", label = "Friendly nameplates" },
        BaseSpec({ type = "Toggle", path = "look.plate.clickThroughFriendly", label = "Click-through friendly nameplates",
          tooltip = "Clicks pass through Plateau's friendly nameplates to whatever is behind them. Changes made in combat apply when combat ends." })
    )),

    Page("combat", "Out of combat", COMBAT_PATHS, nil, List(
        { type = "Header", label = "Out-of-combat nameplates", first = true },
        { type = "Toggle", path = "look.idle.enabled", label = "Customize out-of-combat nameplates",
          tooltip = "Gives enemies not in combat their own look. Your target, players and friendly nameplates are never changed." },
        Gate({ type = "Toggle", path = "look.idle.instancesOnly", label = "Only in instances",
          tooltip = "Applies the out-of-combat look only inside instances, such as dungeons, raids and delves." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Slider", path = "look.idle.alpha", label = "Opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "Opacity of out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Slider", path = "look.idle.widthScale", label = "Bar width", min = 0.5, max = 1.5, step = 0.05,
          tooltip = "Width of out-of-combat nameplates compared to normal." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Slider", path = "look.idle.heightScale", label = "Bar height", min = 0.5, max = 1.5, step = 0.05,
          tooltip = "Height of out-of-combat nameplates compared to normal." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "ToggleColor", path = "look.idle.colorBar", colorPath = "look.idle.color", label = "Use one bar color",
          tooltip = "Colors every out-of-combat health bar this color, replacing type, threat and quest colors." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        { type = "Header", label = "Show when out of combat" },
        Gate({ type = "Toggle", path = "look.idle.show.auras", label = "Auras",
          tooltip = "Shows auras on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.healthText", label = "Health text",
          tooltip = "Shows health text on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.name", label = "Name",
          tooltip = "Shows the name on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.level", label = "Level",
          tooltip = "Shows the level on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.classification", label = "Elite icon",
          tooltip = "Shows the elite icon on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.raidMarker", label = "Raid target icon",
          tooltip = "Shows the raid target icon on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.quest", label = "Quest icon",
          tooltip = "Shows the quest icon on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.forces", label = "Mythic+ enemy forces",
          tooltip = "Shows enemy forces on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.enemyPower", label = "Enemy power bar",
          tooltip = "Shows the enemy power bar on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.enemyTarget", label = "Enemy target name",
          tooltip = "Shows the enemy's target on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.castbar", label = "Cast bar",
          tooltip = "Shows the cast bar on out-of-combat nameplates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat nameplates to use this.")
    )),

    Section("health", "Health bar", { "look.health", "look.execute", "look.bossPhases", "look.plate.width", "look.plate.height", "look.plate.pixelPerfect", "look.shield.absorbs", "look.shield.absorbColor", "look.shield.absorbStyle", "look.shield.absorbPosition", "look.shield.absorbGlow" }, List(
        { type = "Header", label = "Size", first = true },
        { type = "Slider", path = "look.plate.width", label = "Width", min = 60, max = 300,
          tooltip = "Width of every nameplate. The cast bar matches it." },
        { type = "Slider", path = "look.plate.height", label = "Height", min = 4, max = 40,
          tooltip = "Height of the health bar." },

        { type = "Header", label = "Bar" },
        { type = "Dropdown", path = "look.health.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "Fill texture of the health bar. Your target and focus can use their own on the Target and Focus pages." },
        { type = "Toggle", path = "look.health.desaturate", label = "Desaturate texture",
          tooltip = "Removes the texture's own color so bar colors show exactly." },
        { type = "Dropdown", path = "look.health.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "A pattern drawn over the bar texture, tinted to match the bar." },
        Gate({ type = "Slider", path = "look.health.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "How visible the overlay pattern is." }, Chosen("look.health.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.health.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "Difference between the pattern's light and dark parts. 0 is flat." }, Chosen("look.health.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Color", path = "look.health.background", label = "Background color",
          tooltip = "Color of the unfilled portion of the health bar." },
        { type = "Dropdown", path = "look.health.backgroundTexture", label = "Background texture", options = BackgroundBars, unknown = "Custom texture",
          tooltip = "Texture of the empty part of the bar, tinted by Background color." },
        { type = "Dropdown", path = "look.health.borderStyle", label = "Border style", options = BorderStyles, unknown = "Custom border",
          tooltip = "Style of the border around the health bar. Tooltip styles suit taller bars." },
        { type = "Color", path = "look.health.border", label = "Border color", set = BorderColorSetter("look.health"),
          tooltip = "Color of the border around the health bar. Picking a color with no border turns on a thin one." },
        Gate({ type = "Slider", path = "look.health.borderSize", label = "Border thickness", min = 0, max = 4,
          tooltip = "How thick the border is." }, BorderOn, "Choose a border style to use this."),
        Gate({ type = "Toggle", path = "look.health.borderInside", label = "Draw border inside",
          tooltip = "Draws the border inside the bar's edges instead of around them. Target, mouseover and buff warning borders follow." }, BorderOn, "Choose a border style to use this."),
        { type = "Toggle", path = "look.plate.pixelPerfect", label = "Pixel-perfect borders",
          tooltip = "Keeps borders and glows crisp at every nameplate size." },

        { type = "Header", label = "Fill" },
        { type = "Toggle", path = "look.health.smooth", label = "Smooth health changes",
          tooltip = "Animates health changes instead of jumping." },
        { type = "Dropdown", path = "look.health.fillDirection", label = "Fill direction", options = FILL_DIRECTIONS,
          tooltip = "Direction the health bar fills." },
        { type = "ToggleColor", path = "look.health.spark", colorPath = "look.health.sparkColor", label = "Show spark",
          tooltip = "Shows a bright line at the edge of the health fill." },
        Gate({ type = "Slider", path = "look.health.sparkWidth", label = "Spark thickness", min = 1, max = 8,
          tooltip = "Thickness of the spark line." }, On("look.health.spark"), "Turn on Show spark to use this."),

        { type = "Header", label = "Absorbs" },
        { type = "ToggleColor", path = "look.shield.absorbs", colorPath = "look.shield.absorbColor", label = "Show absorbs",
          tooltip = "Shows damage absorption shields on the health bar." },
        Gate({ type = "Dropdown", path = "look.shield.absorbPosition", label = "Absorb position", options = ABSORB_POSITIONS,
          tooltip = "Where the shield is drawn. After health fills the missing health, like Blizzard's frames. From the right edge always shows the whole shield." }, On("look.shield.absorbs"), "Turn on Show absorbs to use this."),
        Gate({ type = "Toggle", path = "look.shield.absorbGlow", label = "Show overflow glow",
          tooltip = "Shows a glow at the end of the bar when the shield is larger than the missing health." }, function() return ns.Get("look.shield.absorbs") == true and ns.Get("look.shield.absorbPosition") == "after" end, "Needs Show absorbs on and Absorb position set to After health."),
        Gate({ type = "Dropdown", path = "look.shield.absorbStyle", label = "Absorb texture", options = AbsorbStyles, unknown = "Custom texture",
          tooltip = "Texture of the absorb shield, tinted by the Show absorbs color." }, On("look.shield.absorbs"), "Turn on Show absorbs to use this."),

        { type = "Header", label = "Execute indicator" },
        { type = "ToggleColor", path = "look.execute.highlight", colorPath = "look.execute.color", label = "Execute range color",
          tooltip = "Colors an enemy's health bar when its health is below the execute threshold. Set the threshold to match your execute spells." },
        Gate({ type = "Slider", path = "look.execute.threshold", label = "Execute threshold", min = 1, max = 90,
          tooltip = "Health percentage where execute range begins." }, On("look.execute.highlight"), "Turn on Execute range color to use this."),
        { type = "Header", label = "Health threshold markers" },
        { type = "ToggleColor", path = "look.execute.lines", colorPath = "look.execute.lineColor", label = "Show health markers",
          tooltip = "Draws lines on the health bar at set health percentages." },
        Gate({ type = "Slider", path = "look.execute.line1", label = "First marker", min = 0, max = 99,
          tooltip = "Health percentage for the first marker. 0 hides it." }, On("look.execute.lines"), "Turn on Show health markers to use this."),
        Gate({ type = "Slider", path = "look.execute.line2", label = "Second marker", min = 0, max = 99,
          tooltip = "Health percentage for the second marker. 0 hides it." }, On("look.execute.lines"), "Turn on Show health markers to use this."),
        Gate({ type = "Slider", path = "look.execute.lineWidth", label = "Marker thickness", min = 1, max = 4,
          tooltip = "Thickness of the marker lines." }, On("look.execute.lines"), "Turn on Show health markers to use this."),

        { type = "Header", label = "Boss phase lines" },
        { type = "ToggleColor", path = "look.bossPhases.enabled", colorPath = "look.bossPhases.color", label = "Show boss phase lines",
          tooltip = "Draws lines on boss health bars where the fight changes phase." },
        Gate({ type = "Slider", path = "look.bossPhases.lineWidth", label = "Phase line thickness", min = 1, max = 4,
          tooltip = "Thickness of the boss phase lines." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Dropdown", label = "Boss", options = BossOptions,
          get = function() return selectedBoss end,
          set = function(value) selectedBoss = value end,
          tooltip = "The boss whose phase lines you are editing. Bosses you have fought are added at the bottom." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Add a boss", empty = "Encounter ID and optional name: 2654 Ara-Kara",
          get = function() return "" end,
          set = function(value)
              local id, name = (value or ""):match("^%s*(%d+)%s*[,%-:=]?%s*(.-)%s*$")
              id = tonumber(id)
              if id and Plateau.AddBossPhaseBoss and Plateau.AddBossPhaseBoss(id, name) then
                  selectedBoss = id
              end
          end,
          describe = function(text)
              local id, name = (text or ""):match("^%s*(%d+)%s*[,%-:=]?%s*(.-)%s*$")
              if not id then return "Encounter ID and optional name: 2654 Ara-Kara" end
              if name ~= "" then
                  return Plateau.T("Press Enter to add encounter %s (%s) and pick it above"):format(id, name)
              end
              return Plateau.T("Press Enter to add encounter %s and pick it above"):format(id)
          end,
          tooltip = "Adds a boss by encounter ID so you can set its lines before you fight it. Bosses you fight are added automatically." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Phase lines", empty = "No lines for this boss",
          suffix = function() return BossName(selectedBoss) end,
          get = function() return Plateau.BossPhaseLines and Plateau.BossPhaseLines(selectedBoss) or "" end,
          set = function(value) if Plateau.SetBossPhaseLines then Plateau.SetBossPhaseLines(selectedBoss, value) end end,
          reset = function() if Plateau.SetBossPhaseLines then Plateau.SetBossPhaseLines(selectedBoss, nil) end end,
          describe = DescribeLines,
          tooltip = "Up to four health percentages for this boss, separated by commas (70, 40). Right-click to restore the built-in lines. Shared by all your characters." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Dropdown", label = "Show lines on", options = BOSS_TARGETS,
          get = function() return Plateau.BossPhaseTarget and Plateau.BossPhaseTarget(selectedBoss) or "boss" end,
          set = function(value) if Plateau.SetBossPhaseTarget then Plateau.SetBossPhaseTarget(selectedBoss, value) end end,
          tooltip = "Bosses only, or every enemy in the encounter. Use every enemy when the phase depends on an add or pet." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Default phase lines", empty = "No default lines",
          get = function() return ns.Get("look.bossPhases.defaults") or "" end,
          set = function(value) ns.Set("look.bossPhases.defaults", value) end,
          reset = function() Plateau.DB:Reset("look.bossPhases.defaults") end,
          describe = DescribeLines,
          tooltip = "Up to four health percentages for bosses without their own lines, separated by commas." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Toggle", path = "look.bossPhases.instancesOnly", label = "Default lines only in dungeons and raids",
          tooltip = "Hides the default lines on open-world bosses." }, On("look.bossPhases.enabled"), BOSS_ON),
        { type = "Note", label = "Built-in lines may not match every boss. Bosses that change phase on energy or a timer have no lines.", height = 32 }
    )),

    Section("healthColors", "Health bar colors", { "look.colors.tapped", "look.colors.showTapped", "look.colors.healthGradient", "look.colors.healthLow", "look.colors.healthFade", "look.colors.customReaction", "look.colors.hostile", "look.colors.neutral", "look.colors.friendly", "look.colors.classColors", "look.colors.mobTypes", "look.colors.mobTypesInstancesOnly", "look.colors.boss", "look.colors.bossColor", "look.colors.lieutenant", "look.colors.lieutenantColor", "look.colors.higher", "look.colors.higherColor", "look.colors.caster", "look.colors.casterColor", "look.colors.elite", "look.colors.eliteColor", "look.colors.trivial", "look.colors.trivialColor" }, List(
        { type = "Header", label = "Colorblind presets", first = true },
        { type = "Presets", presets = Plateau.presets.palettes },
        { type = "Note", label = "Color priority: target or focus, tapped, threat (Threat page), quest (Quest icon page), enemy type or class, reaction. The colors below follow that order.", height = 32 },

        { type = "Header", label = "Tapped enemies" },
        { type = "ToggleColor", path = "look.colors.showTapped", colorPath = "look.colors.tapped", label = "Tapped by another player",
          tooltip = "Color for enemies tagged by another player. You won't receive loot or credit from them." },

        { type = "Header", label = "Enemy players" },
        { type = "Toggle", path = "look.colors.classColors", label = "Use class colors for enemy players",
          tooltip = "Colors enemy player health bars by class." },

        { type = "Header", label = "Enemy types" },
        { type = "Toggle", path = "look.colors.mobTypes", label = "Enemy type colors",
          tooltip = "Colors enemies by type. An enemy that matches several types uses the first in this order: bosses, lieutenants, higher-level elites, minor enemies, casters, other elites." },
        Gate({ type = "Toggle", path = "look.colors.mobTypesInstancesOnly", label = "Only in dungeons, raids and delves",
          tooltip = "Open-world enemies use reaction colors." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.boss", colorPath = "look.colors.bossColor", label = "Bosses",
          tooltip = "Bosses and world bosses." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.caster", colorPath = "look.colors.casterColor", label = "Casters",
          tooltip = "Enemies that use mana." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.lieutenant", colorPath = "look.colors.lieutenantColor", label = "Lieutenants",
          tooltip = "Lieutenants above your level, and elites two or more levels above you." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.elite", colorPath = "look.colors.eliteColor", label = "Other elites",
          tooltip = "Elites that match no other type." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.higher", colorPath = "look.colors.higherColor", label = "Higher-level elites",
          tooltip = "Elites one level above you." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.trivial", colorPath = "look.colors.trivialColor", label = "Other enemies",
          tooltip = "Minor enemies, and any enemy that matches no other type." }, On("look.colors.mobTypes"), "Turn on Enemy type colors to use this."),

        { type = "Header", label = "Reaction colors" },
        { type = "Toggle", path = "look.colors.customReaction", label = "Custom reaction colors",
          tooltip = "Replaces the game's hostile, neutral and friendly colors. Right-click a color to restore the game's." },
        Gate({ type = "Color", path = "look.colors.hostile", label = "Hostile",
          tooltip = "Color for hostile units." }, On("look.colors.customReaction"), "Turn on Custom reaction colors to use this."),
        Gate({ type = "Color", path = "look.colors.neutral", label = "Neutral",
          tooltip = "Color for neutral units." }, On("look.colors.customReaction"), "Turn on Custom reaction colors to use this."),
        Gate({ type = "Color", path = "look.colors.friendly", label = "Friendly",
          tooltip = "Color for friendly units." }, On("look.colors.customReaction"), "Turn on Custom reaction colors to use this."),

        { type = "Header", label = "Low health" },
        { type = "Toggle", path = "look.colors.healthGradient", label = "Color by health",
          tooltip = "Enemy health bars fade toward the low health color as they lose health." },
        Gate({ type = "Color", path = "look.colors.healthLow", label = "Low health color",
          tooltip = "Color the bar fades toward as health drops." }, On("look.colors.healthGradient"), "Turn on Color by health to use this."),
        Gate({ type = "Slider", path = "look.colors.healthFade", label = "Fade strength", min = 0.1, max = 1, step = 0.05,
          tooltip = "How close the bar gets to the low health color at 0 health. 1 reaches it fully." }, On("look.colors.healthGradient"), "Turn on Color by health to use this.")
    )),

    Friendly("friendly", "Friendly nameplates", { "look.friendly", "look.scaling.friendlyScale" }, Join(List(
        { type = "Header", label = "Friendly nameplates", first = true },
        { type = "Toggle", limited = Style.limited.friendly, label = "Style friendly nameplates with Plateau",
          get = function() return ns.Get("look.friendly.enabled") == true end,
          set = function(value)
              Plateau.DB:Set("look.friendly.enabled", value == true)
              if not value then
                  ns.PromptReload()
              end
          end,
          reset = function()
              local wasOn = ns.Get("look.friendly.enabled") == true
              Plateau.DB:Reset("look.friendly.enabled")
              if wasOn and ns.Get("look.friendly.enabled") ~= true then
                  ns.PromptReload()
              end
          end,
          tooltip = "Off: Blizzard draws friendly nameplates. Turning it off needs a UI reload." },
        FriendlyGate({ type = "Slider", path = "look.scaling.friendlyScale", label = "Friendly nameplate scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size of Plateau's friendly nameplates in the open world." }),
        FriendlyGate({ type = "Toggle", path = "look.friendly.hideInCombat", label = "Hide friendly nameplates in combat",
          tooltip = "Fades out friendly nameplates during combat. They can still be clicked unless Click-through friendly nameplates is on." }),
        FriendlyGate({ type = "Toggle", path = "look.friendly.nameOnly", label = "Show names only",
          tooltip = "Hides the health bar on friendly nameplates and shows only the name. In dungeons and raids, use Only show friendly player names." }),
        NameOnlyGate(FriendlyGate({ type = "Slider", path = "look.friendly.nameOffsetY", limited = Style.limited.friendly, label = "Name vertical offset", min = -60, max = 60,
          tooltip = "Moves the name up or down." })),
        NameOnlyGate(FriendlyGate({ type = "Slider", path = "look.friendly.subtitleSize", label = "Guild and title text size", min = 6, max = 16,
          tooltip = "The font size of guild names and NPC titles." })),
        { type = "Note", label = "In dungeons, raids and arenas the game draws friendly nameplates itself. Blizzard's friendly nameplates, at the bottom of this page, control those.", height = 32 },

        { type = "Header", label = "Friendly players" },
        Style.Limited(FriendlyToggle("look.friendly.players", "nameplateShowFriendlyPlayers", "Friendly players",
            "Shows nameplates for friendly players. Also changes Blizzard's matching setting."), "friendly"),
        FriendlyPlayersGate({ type = "Dropdown", path = "look.friendly.nameMode", label = "Shorten player names", options = SHORTEN_NAMES, limited = Style.limited.friendly, visibleIf = function() return Plateau.flavor == "forever" end,
          tooltip = "How friendly player names are shortened." }),
        FriendlyPlayersGate(CVarSlider("nameplateSize", "Blizzard nameplate size", 1, 5, 1,
            "Blizzard's Nameplate Size, from 1 (Small) to 5 (Huge). Sizes friendly player names and every nameplate the game draws, including the personal resource display. Same setting as on the Size page.")),
        CVarToggle("nameplateUseClassColorForFriendlyPlayerUnitNames", "Class-colored player names",
            "Colors friendly player names by class, including on Blizzard's nameplates."),
        NameOnlyGate(Gate({ type = "Color", path = "look.friendly.playerNameColor", label = "Player name color",
          tooltip = "The color of friendly player names when Class-colored player names is off." },
          function() return FriendlyPlayersOn() and CVars:Get("nameplateUseClassColorForFriendlyPlayerUnitNames") ~= "1" end,
          function()
              if not FriendlyOn() then return FriendlyOffReason() end
              if not FriendlyPlayersOn() then return "Turn on Friendly players to use this." end
              return "Turn off Class-colored player names to use this."
          end)),
        FriendlyPlayersGate({ type = "ToggleColor", path = "look.friendly.groupColor", colorPath = "look.friendly.groupNameColor", label = "Group member name color",
          tooltip = "Colors the names of party and raid members, replacing their class color." }),
        NameOnlyGate(FriendlyPlayersGate({ type = "ToggleColor", path = "look.friendly.guildLine", colorPath = "look.friendly.guildColor", label = "Show guild names",
          tooltip = "Shows a player's guild, like <Plateau>, on a smaller line under their name." })),
        RealmNameToggle(),
        Gate({ type = "Toggle", label = "Hide realm marker (*)",
          get = function() return not Plateau.DB.saved.global.keepRealmMarker end,
          set = function(value)
              Plateau.DB.saved.global.keepRealmMarker = not value
              ns.PromptReload()
          end,
          tooltip = "Hides the (*) after the names of players from other realms. Needs a UI reload." },
          function() return CVars:Get("nameplateShowFriendlyRealmName") ~= "1" end,
          "Turn off Show realm names to use this."),

        { type = "Header", label = "Friendly NPCs" },
        Style.Limited(FriendlyToggle("look.friendly.npcs", "nameplateShowFriendlyNpcs", "Friendly NPCs",
            "Shows nameplates for friendly NPCs. Also changes Blizzard's matching setting."), "friendly"),
        FriendlyNpcsGate({ type = "Dropdown", path = "look.friendly.npcNameMode", label = "Shorten NPC names", options = SHORTEN_NAMES, limited = Style.limited.friendly,
          tooltip = "How friendly NPC names are shortened." }),
        FriendlyNpcsGate({ type = "Slider", path = "look.friendly.npcNameScale", label = "NPC name size", min = 1, max = 5,
          tooltip = "The size of friendly NPC names on Plateau's nameplates, from 1 (Small) to 5 (Huge)." }),
        NameOnlyGate(FriendlyNpcsGate({ type = "Color", path = "look.friendly.npcNameColor", label = "NPC name color",
          tooltip = "The color of friendly NPC names." })),
        NameOnlyGate(FriendlyNpcsGate({ type = "ToggleColor", path = "look.friendly.npcTitle", colorPath = "look.friendly.npcTitleColor", label = "Show NPC titles",
          tooltip = "Shows an NPC's title, like <Banker>, on a smaller line under their name." })),

        { type = "Header", label = "Pets and minions" },
        Style.Limited(Gate({
            type = "Toggle",
            label = "Show in the open world",
            keywords = "pet pets minion minions totem friendly",
            tooltip = "Shows nameplates for friendly players' pets, totems and minions outside dungeons and raids.",
            get = function() return ns.Get("look.friendly.minions") == true end,
            set = function(value)
                Plateau.DB:Set("look.friendly.minions", value == true)
            end,
            reset = function()
                Plateau.DB:Reset("look.friendly.minions")
            end,
        }, FriendlyOn, FriendlyOffReason), "friendly"),
        { type = "Toggle", label = "Show in dungeons and raids", visibleIf = function() return Plateau.InstancePets ~= nil end,
          keywords = "pet pets minion minions totem names hide dungeon raid instance mythic friendly",
          get = function()
              return CVars:UserValue("nameplateShowFriendlyPlayerMinions") == "1" and not Plateau.InstancePets:IsOn()
          end,
          set = function(value)
              if value then
                  if CVars:UserValue("nameplateShowFriendlyPlayerMinions") ~= "1" then
                      CVars:Set("nameplateShowFriendlyPlayerMinions", "1")
                  end
                  Plateau.InstancePets:SetOn(false)
              else
                  Plateau.InstancePets:SetOn(true)
              end
          end,
          tooltip = "Shows nameplates and names for friendly players' pets, totems and minions in dungeons and raids. Saved for your account." },

        { type = "Header", label = "Full nameplate", visibleIf = FriendlyStyled },
        { type = "Note", label = "Used when Show names only is off. Everything else follows the regular nameplate settings.", height = 24, visibleIf = FriendlyStyled },
        FriendlyGate({ type = "Toggle", path = "look.friendly.classificationEnabled", label = "Show elite icon", visibleIf = FriendlyStyled,
          tooltip = "Shows the elite, rare or boss icon on friendly nameplates." }),
        FriendlyGate({ type = "Toggle", path = "look.friendly.levelEnabled", label = "Show level", visibleIf = FriendlyStyled,
          tooltip = "Shows the friendly unit's level." }),

        { type = "Header", label = "Raid target icon" },
        FriendlyGate({ type = "Toggle", path = "look.friendly.raidMarker.own", label = "Separate friendly position",
          set = function(value)
              local values = { ["look.friendly.raidMarker.own"] = value == true }
              if value then
                  for _, key in ipairs({ "position", "gap", "offsetX", "offsetY" }) do
                      values["look.friendly.raidMarker." .. key] = Plateau.DB:Get("look.raidMarker." .. key)
                  end
              end
              Plateau.DB:SetMany(values)
          end,
          tooltip = "Friendly nameplates use their own raid icon position, set below. Size and opacity stay shared." }),
        Gate({ type = "Dropdown", path = "look.friendly.raidMarker.position", label = "Position", options = SIDES,
          tooltip = "Where the raid icon sits around a friendly health bar." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.gap", label = "Distance", min = 0, max = 20,
          tooltip = "Space between the raid icon and the friendly nameplate." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Moves the raid icon left or right." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Moves the raid icon up or down." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),

        { type = "Header", label = "Blizzard's friendly nameplates" },
        { type = "Note", label = "Change the friendly nameplates the game draws, such as in dungeons, raids and arenas.", height = 24 },
        CVarToggle("nameplateShowOnlyNameForFriendlyPlayerUnits", "Only show friendly player names",
            "Shows only names on friendly players' nameplates the game draws, such as in dungeons and raids. Follower dungeon companions keep their bars.")
    ), BlizzardDrawn(true))),

    Section("healthText", "Health text", "look.healthText", Join(List(
        { type = "Header", label = "Text", first = true },
        { type = "Toggle", path = "look.healthText.enabled", label = "Show health text",
          tooltip = "Shows health as a number or percentage on the bar." }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Dropdown", path = "look.healthText.format", label = "Health format", options = HEALTH_FORMATS,
          tooltip = "How health is shown." }
    ), List(
        Gate({ type = "Slider", path = "look.healthText.decimals", label = "Percentage decimal places", min = 0, max = 2,
          tooltip = "Decimal places shown in health percentages." }, HealthTextPercent, HealthTextPercentReason)
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Dropdown", path = "look.healthText.valuePrecision", label = "Number format", options = VALUE_PRECISION,
          tooltip = "How large health numbers are shortened." },
        { type = "Toggle", path = "look.healthText.percentSign", label = "Show % sign",
          tooltip = "Shows a % sign after percentages." },
        { type = "Dropdown", path = "look.healthText.anchor", label = "Position", options = TEXT_POSITIONS,
          tooltip = "Where the health text sits on the health bar." },
        { type = "Slider", path = "look.healthText.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges the health text left (negative) or right (positive)." },
        { type = "Slider", path = "look.healthText.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges the health text down (negative) or up (positive)." }
    ), List(
        { type = "Header", label = "When to show" }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Toggle", path = "look.healthText.hideFull", label = "Hide at full health",
          tooltip = "Hides the text until the enemy takes damage." },
        { type = "Toggle", path = "look.healthText.targetOnly", label = "Only on my target",
          tooltip = "Shows health text only on your target." }
    ), List(
        { type = "Header", label = "Color" }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Color", path = "look.healthText.color", label = "Text color",
          tooltip = "Color of the health text." },
        { type = "Toggle", path = "look.healthText.colorByHealth", label = "Color text by health",
          tooltip = "The text fades from the full health color to the low health color as health drops." }
    ), GateList(HealthTextColors, HealthTextColorsReason,
        { type = "Color", path = "look.healthText.colorHigh", label = "Full health color",
          tooltip = "Text color at full health." },
        { type = "Color", path = "look.healthText.colorMid", label = "Half health color",
          tooltip = "Text color at half health." },
        { type = "Color", path = "look.healthText.colorLow", label = "Low health color",
          tooltip = "Text color at low health." }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "ToggleColor", path = "look.healthText.executeColor", colorPath = "look.healthText.executeTextColor", label = "Execute range color",
          tooltip = "The text turns this color in execute range. The threshold is set on the Health bar page." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(HealthTextOn, TEXT_ON, FontControls("look.healthText")))),

    Section("name", "Name", { "look.name", "look.enemyTarget" }, Join(List(
        { type = "Header", label = "Name", first = true },
        { type = "Toggle", path = "look.name.enabled", label = "Show names",
          tooltip = "Shows the unit's name on the nameplate." }
    ), GateList(NameOn, NAME_ON,
        { type = "Color", path = "look.name.color", label = "Text color",
          tooltip = "Color of the name. Player names can use class colors instead." },
        { type = "Toggle", path = "look.name.classColors", label = "Use class colors for player names",
          tooltip = "Colors enemy player names by class. Friendly players are set on the Friendly nameplates page." },
        { type = "Toggle", path = "look.name.matchBar", label = "Match health bar color",
          tooltip = "Enemy names use the health bar's current color." },
        { type = "Dropdown", path = "look.name.position", label = "Position", options = NAME_POSITIONS,
          tooltip = "Where the name sits relative to the health bar." },
        { type = "Dropdown", path = "look.name.justify", label = "Text alignment", options = ALIGN,
          tooltip = "Aligns the name left, center or right." },
        { type = "Slider", path = "look.name.gap", label = "Distance from bar", min = -10, max = 20,
          tooltip = "Space between the name and the health bar. When the name is inside the bar, moves it up or down." },
        { type = "Dropdown", path = "look.name.mode", label = "Shorten names", options = SHORTEN_NAMES, limited = Plateau.flavor ~= "forever" and Style.limited.names or nil,
          tooltip = "Shortens enemy names to a word or initials." .. RETAIL_NAME_NOTE },
        { type = "Dropdown", label = "Long names", options = OVERFLOW_NAMES, path = "look.name.overflow",
          tooltip = "How names wider than the maximum width are cut." },
        { type = "Slider", path = "look.name.width", label = "Maximum name width", min = 0, max = 250,
          visibleIf = function() return ns.Get("look.name.overflow") ~= "none" end,
          tooltip = "Widest a name can be before it is cut. 0 uses the nameplate width." }
    ), List(
        { type = "Header", label = "When to show" }
    ), GateList(NameOn, NAME_ON,
        { type = "Toggle", path = "look.name.targetOnly", label = "Only on my target",
          tooltip = "Shows enemy names only on your target." },
        { type = "Toggle", path = "look.name.hideCasting", label = "Hide while casting",
          tooltip = "Hides an enemy's name while its cast bar is showing." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(NameOn, NAME_ON, FontControls("look.name")), List(
        { type = "Header", label = "Enemy target name" },
        { type = "Toggle", path = "look.enemyTarget.enabled", label = "Show enemy target name",
          tooltip = "Shows who the enemy is targeting." }
    ), GateList(EnemyTargetOn, ENEMY_TARGET_ON,
        { type = "ToggleColor", path = "look.enemyTarget.classColors", colorPath = "look.enemyTarget.color", label = "Use class colors",
          tooltip = "Colors the target's name by class. Otherwise it uses the color shown.",
          swatchLabel = "Custom target name color",
          swatchTooltip = "Used when Use class colors is off, or when a class color isn't available." },
        { type = "ToggleColor", path = "look.enemyTarget.meColor", colorPath = "look.enemyTarget.meColorValue", label = "Color when targeting you",
          tooltip = "The target's name turns this color when the enemy is targeting you." },
        { type = "Dropdown", path = "look.enemyTarget.anchor", label = "Position", options = TEXT_POSITIONS,
          tooltip = "Where the target's name sits on the health bar." },
        { type = "Slider", path = "look.enemyTarget.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges this text left (negative) or right (positive)." },
        { type = "Slider", path = "look.enemyTarget.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges this text down (negative) or up (positive)." }
    ), List(
        { type = "Header", label = "Enemy target font" }
    ), GateList(EnemyTargetOn, ENEMY_TARGET_ON, FontControls("look.enemyTarget")))),

    Section("level", "Level", "look.level", Join(List(
        { type = "Header", label = "Level", first = true },
        { type = "Toggle", path = "look.level.enabled", label = "Show level",
          tooltip = "Shows the unit's level." }
    ), GateList(LevelOn, LEVEL_ON,
        { type = "Toggle", path = "look.level.showElitePlus", label = "Show + for elites",
          tooltip = "Adds + after the level of elites and rare elites (90+)." },
        { type = "Toggle", path = "look.level.markRares", label = "Show r for rares",
          tooltip = "Adds r after the level of rares (90r, or 90r+ for rare elites)." },
        { type = "Dropdown", path = "look.level.bossText", label = "Boss level text", options = BOSS_LEVEL_TEXT,
          tooltip = "What shows instead of a level on bosses and enemies whose level is hidden." },
        { type = "Toggle", path = "look.level.colorByDifficulty", label = "Color by difficulty",
          tooltip = "Colors the level by difficulty, like the target frame." },
        { type = "Color", path = "look.level.color", label = "Custom level color",
          tooltip = "Level color when Color by difficulty is off. Boss and unknown levels stay red." },
        { type = "Dropdown", path = "look.level.anchor", label = "Position", options = LEVEL_POSITIONS,
          tooltip = "Where the level text sits on the bar." },
        { type = "Slider", path = "look.level.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges the level text left (negative) or right (positive)." },
        { type = "Slider", path = "look.level.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges the level text down (negative) or up (positive)." }
    ), List(
        { type = "Header", label = "When to show" }
    ), GateList(LevelOn, LEVEL_ON,
        { type = "Toggle", path = "look.level.hideAtPlayerLevel", label = "Hide on same-level normal enemies",
          tooltip = "Hides the level on non-elite enemies at your level." },
        { type = "Toggle", path = "look.level.hideTrivial", label = "Hide trivial levels",
          tooltip = "Hides the level on gray enemies too low to give experience." },
        { type = "Toggle", path = "look.level.hideInInstances", label = "Hide in dungeons and raids",
          tooltip = "Hides levels in dungeons and raids." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(LevelOn, LEVEL_ON, FontControls("look.level")))),

    Section("castbar", "Cast bar", "look.castbar", Join(List(
        { type = "Header", label = "Show", first = true },
        { type = "Dropdown", path = "look.castbar.showCasts", label = "Casts to show", options = SHOW_CASTS,
          tooltip = "Which casts get a cast bar. Hidden casts still count for Casting scale." },

        { type = "Header", label = "Size and spacing" },
        { type = "Slider", path = "look.castbar.width", label = "Width", min = 0, max = 300,
          tooltip = "Width of the cast bar. 0 matches the health bar." },
        { type = "Slider", path = "look.castbar.height", label = "Height", min = 0, max = 30,
          tooltip = "Height of the cast bar. 0 matches the health bar." },
        { type = "Slider", path = "look.castbar.gap", label = "Health bar spacing", min = 0, max = 20,
          tooltip = "Space between the cast bar and the health bar." },
        { type = "Toggle", path = "look.castbar.joinBorder", label = "Join cast bar to health bar",
          tooltip = "Joins the cast bar to the health bar inside one border. Needs the Pixel border on both bars." },

        { type = "Header", label = "Bar" },
        { type = "Dropdown", path = "look.castbar.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "Fill texture of the cast bar." },
        { type = "Dropdown", path = "look.castbar.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "A pattern drawn over the bar texture, tinted to match the bar." },
        Gate({ type = "Slider", path = "look.castbar.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "How visible the overlay pattern is." }, Chosen("look.castbar.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.castbar.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "Difference between the pattern's light and dark parts. 0 is flat." }, Chosen("look.castbar.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Color", path = "look.castbar.background", label = "Background color",
          tooltip = "Color of the unfilled portion of the cast bar." },
        { type = "Dropdown", path = "look.castbar.borderStyle", label = "Border style", options = BorderStyles, unknown = "Custom border",
          tooltip = "Style of the border around the cast bar. Tooltip styles suit taller bars." },
        { type = "Color", path = "look.castbar.border", label = "Border color", set = BorderColorSetter("look.castbar"),
          tooltip = "Color of the border around the cast bar. Picking a color with no border turns on a thin one." },
        Gate({ type = "Slider", path = "look.castbar.borderSize", label = "Border thickness", min = 0, max = 4,
          tooltip = "How thick the border is." }, CastBorderOn, "Choose a border style to use this."),
        Gate({ type = "Toggle", path = "look.castbar.borderInside", label = "Draw border inside",
          tooltip = "Draws the border inside the bar's edges instead of around them." }, CastBorderOn, "Choose a border style to use this."),
        { type = "ToggleColor", path = "look.castbar.showSpark", colorPath = "look.castbar.sparkColor", label = "Show cast bar spark",
          tooltip = "Shows a bright line at the moving edge of the cast bar." },
        { type = "Toggle", path = "look.castbar.drainCasts", label = "Drain cast bars",
          tooltip = "Cast bars start full and empty as the cast finishes, like channels." },

        { type = "Header", label = "Spell icon" },
        { type = "Toggle", path = "look.castbar.showIcon", label = "Show spell icon",
          tooltip = "Shows the spell's icon next to the cast bar." },
        Gate({ type = "Toggle", path = "look.castbar.iconSpan", label = "Extend icon across both bars",
          tooltip = "Makes the spell icon as tall as the health bar and cast bar together." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.iconSide", label = "Icon position", options = ICON_SIDES,
          tooltip = "Which side of the bars the spell icon sits on." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),
        Gate({ type = "Toggle", path = "look.castbar.cropIcon", label = "Crop icon edges",
          tooltip = "Trims the spell icon's border." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),
        Gate({ type = "Toggle", path = "look.castbar.shieldIcon", label = "Shield icon on uninterruptible casts",
          tooltip = "Shows a shield on the spell icon when a cast can't be interrupted." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),

        { type = "Header", label = "Interrupts" },
        { type = "ToggleColor", path = "look.castbar.kickMarker", colorPath = "look.castbar.kickMarkerColor", label = "Show interrupt ready marker",
          set = function(value)
              ns.Set("look.castbar.kickMarker", value)
              if value and ns.ShowKickMarkerCast then
                  ns.ShowKickMarkerCast()
              end
          end,
          tooltip = "Marks the point in the cast where your interrupt comes off cooldown. Shown only when it will be ready before the cast ends." },
        Gate({ type = "Slider", path = "look.castbar.kickMarkerWidth", label = "Marker thickness", min = 1, max = 6,
          set = function(value)
              ns.Set("look.castbar.kickMarkerWidth", value)
              if ns.ShowKickMarkerCast then
                  ns.ShowKickMarkerCast()
              end
          end,
          tooltip = "Thickness of the interrupt ready marker." }, On("look.castbar.kickMarker"), "Turn on Show interrupt ready marker to use this."),

        { type = "Header", label = "Important casts" },
        { type = "ToggleColor", path = "look.castbar.importantGlow", colorPath = "look.castbar.importantColor", label = "Highlight important casts",
          tooltip = "Adds a glow to casts the game marks as important, including ones that can't be interrupted." },
        Gate({ type = "Slider", path = "look.castbar.glowSize", label = "Glow size", min = 0, max = 6,
          tooltip = "Size of the glow around important casts." }, On("look.castbar.importantGlow"), "Turn on Highlight important casts to use this."),

        { type = "Header", label = "Cast bar colors" },
        { type = "Note", label = "Cast bar colors show whether your interrupt is ready and whether the cast can be interrupted. Important casts use their own colors.", height = 32 },
        { type = "Color", path = "look.castbar.readyColor", label = "Interrupt ready",
          tooltip = "Cast bar color when your interrupt is off cooldown. Range is not checked. Also used when you have no interrupt." },
        { type = "Color", path = "look.castbar.notReadyColor", label = "Interrupt on cooldown",
          tooltip = "Cast bar color when your interrupt is on cooldown." },
        { type = "Color", path = "look.castbar.importantReadyColor", label = "Important cast: interrupt ready",
          tooltip = "Color for important casts when your interrupt is off cooldown." },
        { type = "Color", path = "look.castbar.importantNotReadyColor", label = "Important cast: interrupt on cooldown",
          tooltip = "Color for important casts when your interrupt is on cooldown." },
        { type = "Color", path = "look.castbar.uninterruptible", label = "Uninterruptible cast",
          tooltip = "Color for casts that can't be interrupted. Lower its opacity to let the bar show through." },
        { type = "Color", path = "look.castbar.importantUninterruptible", label = "Important cast: uninterruptible",
          tooltip = "Color for important casts that can't be interrupted." },

        { type = "Header", label = "Text" },
        { type = "Toggle", path = "look.castbar.showSpellName", label = "Show spell name",
          tooltip = "Shows the spell's name on the cast bar." },
        { type = "Dropdown", path = "look.castbar.textJustify", label = "Spell name alignment", options = ALIGN,
          tooltip = "Aligns the spell name on the bar." },
        { type = "Toggle", path = "look.castbar.showTimer", label = "Show remaining cast time",
          tooltip = "Shows the time left on the cast." },
        Gate({ type = "Slider", path = "look.castbar.timerDecimalsBelow", label = "Show tenths below", min = 0, max = 60,
          tooltip = "Seconds remaining when the timer starts showing tenths. 0 never shows them." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.timerPosition", label = "Cast timer position", options = SIDES,
          tooltip = "Where the cast timer sits on the bar." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Slider", path = "look.castbar.timerOffsetX", label = "Cast timer horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the cast timer left (negative) or right (positive)." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Slider", path = "look.castbar.timerOffsetY", label = "Cast timer vertical offset", min = -40, max = 40,
          tooltip = "Nudges the cast timer down (negative) or up (positive)." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),

        { type = "Header", label = "Cast target" },
        { type = "ToggleColor", path = "look.castbar.showTarget", colorPath = "look.castbar.targetColor", label = "Show cast target",
          tooltip = "Shows who the spell is aimed at, when known." },
        Gate({ type = "Toggle", path = "look.castbar.targetClassColor", label = "Use class color for cast target",
          tooltip = "Colors the cast target's name by class." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetSize", label = "Cast target font size", min = 6, max = 20,
          tooltip = "Size of the cast target's name." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.targetPosition", label = "Cast target position",
          options = (function()
              local list = { { value = "AFTERNAME", label = "Right after the spell name" } }
              for _, side in ipairs(SIDES) do list[#list + 1] = side end
              return list
          end)(),
          tooltip = "Where the cast target's name sits on the bar." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetOffsetX", label = "Cast target horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the cast target's name left (negative) or right (positive)." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetOffsetY", label = "Cast target vertical offset", min = -40, max = 40,
          tooltip = "Nudges the cast target's name down (negative) or up (positive)." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),

        { type = "Header", label = "Font" }
    ), List(FontControls("look.castbar")), List(
        { type = "Header", label = "Interrupted casts" },
        { type = "ToggleColor", path = "look.castbar.showInterrupter", colorPath = "look.castbar.interruptedColor", label = "Show interrupter name",
          tooltip = "Shows who interrupted the cast, and turns the bar this color." }
    ), GateList(On("look.castbar.showInterrupter"), "Turn on Show interrupter name to use this.",
            { type = "Slider", path = "look.castbar.interruptHold", label = "Interrupted bar duration", min = 0.3, max = 3, step = 0.1,
              tooltip = "Seconds the interrupted bar stays visible." },
            { type = "Dropdown", path = "look.castbar.interruptFormat", label = "Interrupted message", options = INTERRUPT_FORMATS,
              tooltip = "What an interrupted cast bar says." },
            { type = "Dropdown", path = "look.castbar.interruptPosition", label = "Interrupted text position", options = INTERRUPT_POSITIONS,
              tooltip = "Where the interrupted message sits on the bar." },
            { type = "Slider", path = "look.castbar.interruptOffsetX", label = "Interrupted text horizontal offset", min = -60, max = 60,
              tooltip = "Nudges the interrupted message left (negative) or right (positive)." },
            { type = "Slider", path = "look.castbar.interruptOffsetY", label = "Interrupted text vertical offset", min = -60, max = 60,
              tooltip = "Nudges the interrupted message down (negative) or up (positive)." },
            { type = "Slider", path = "look.castbar.interruptSize", label = "Interrupted text font size", min = 6, max = 24,
              tooltip = "Size of the interrupted message." },
            { type = "Color", path = "look.castbar.interruptTextColor", label = "Interrupted text color",
              tooltip = "Color of the interrupted message." },
            { type = "Toggle", path = "look.castbar.interruptClassColor", label = "Class color for the name",
              tooltip = "Shows the interrupter's name in their class color." },
            { type = "Toggle", path = "look.castbar.interruptKeepName", label = "Keep spell name",
              tooltip = "Keeps the spell name and shows the interrupted message in its own position." },
            { type = "ToggleColor", path = "look.castbar.interruptFlash", colorPath = "look.castbar.interruptFlashColor", label = "Flash when interrupted",
              tooltip = "The cast bar flashes this color when a cast is interrupted." }))),

    Section("shield", "Buff warnings", { "look.shield.alertImportant", "look.shield.alertColor", "look.shield.alertDefensive", "look.shield.defensiveColor", "look.shield.alertEnrage", "look.shield.enrageColor", "look.shield.alertMagic", "look.shield.magicColor", "look.shield.alertOnlyMine", "look.shield.alertSize", "look.shield.alertTexture", "look.shield.alertTextureAlpha" }, List(
        { type = "Note", label = "Marks enemies that have certain buffs with a colored border or a health bar overlay. Buff icons are on Enemy buffs and Important auras.", height = 32 },

        { type = "Header", label = "Warnings" },
        { type = "ToggleColor", path = "look.shield.alertImportant", colorPath = "look.shield.alertColor", label = "Important buff",
          tooltip = "Marks enemies that have a buff the game flags as important." },
        { type = "ToggleColor", path = "look.shield.alertEnrage", colorPath = "look.shield.enrageColor", label = "Enrage",
          tooltip = "Marks enemies that have an enrage effect that can be removed." },
        { type = "ToggleColor", path = "look.shield.alertDefensive", colorPath = "look.shield.defensiveColor", label = "Major defensive buff",
          tooltip = "Marks enemies that have a buff the game flags as a major defensive." },
        { type = "ToggleColor", path = "look.shield.alertMagic", colorPath = "look.shield.magicColor", label = "Dispellable Magic buff",
          tooltip = "Marks enemies that have a Magic buff that can be dispelled or stolen." },
        Gate({ type = "Toggle", path = "look.shield.alertOnlyMine", label = "Only warn for buffs you can remove",
          tooltip = "Hides the Enrage and Magic warnings when you know no spell that removes them. Cooldowns and range are not checked." }, Any(On("look.shield.alertEnrage"), On("look.shield.alertMagic")), "Turn on Enrage or Dispellable Magic buff to use this."),
        { type = "Slider", path = "look.shield.alertSize", label = "Border thickness", min = 0, max = 8,
          tooltip = "How thick the warning border is. 0 hides the border." },
        { type = "Dropdown", path = "look.shield.alertTexture", label = "Health bar overlay", options = ALERT_TEXTURES,
          tooltip = "Covers the health bar with a pattern in the warning's color." },
        Gate({ type = "Slider", path = "look.shield.alertTextureAlpha", label = "Overlay opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "How opaque the health bar overlay is." }, Chosen("look.shield.alertTexture"), "Choose a Health bar overlay to use this."),
        { type = "PriorityList", path = "look.shield.alertOrder", label = "Warning priority", keys = { "important", "defensive", "enrage", "magic" },
          names = { important = "Important buff", defensive = "Major defensive buff", enrage = "Enrage", magic = "Dispellable Magic buff" },
          tooltip = "When several warnings apply, the highest one shows. Drag a row, or use Up and Down, to reorder." },

        { type = "Note", label = "Changes made in combat apply after combat ends.", height = 24 }
    )),

    Section("auraAll", "Aura text and tooltips", AURA_TEXT_PATHS, AuraTextControls()),
    AuraPage("auraMine", "Your debuffs", "look.auras.mine", "mine",
        "Shows your damage-over-time effects and other debuffs on enemies.", 24,
        "Show your debuffs", "Shows icons for your debuffs on the enemy. Crowd control you apply shows in the Crowd control group.",
        List(
            { type = "Toggle", path = "look.auras.mine.includeOthers", label = "Show other players' debuffs",
              tooltip = "Also shows debuffs from other players, after your own." }
        ), true),
    AuraPage("auraCC", "Crowd control", "look.auras.cc", "cc",
        "Shows crowd control on enemies, such as stuns and roots, from any source.", 32,
        "Show crowd control", "Shows icons for stuns, incapacitates, roots and other crowd control on the enemy, from any source."),
    AuraPage("auraPurge", "Enemy buffs", "look.auras.purge", "purge",
        "Shows buffs on enemies. By default only buffs that can be removed are shown.", 32,
        "Show enemy buffs", "Shows icons for buffs on the enemy.",
        List(
            { type = "Toggle", path = "look.auras.purge.allBuffs", label = "Show all buffs",
              tooltip = "Off: only buffs that can be removed. On: every buff except important ones and your own." },
            Gate({ type = "Toggle", path = "look.auras.purge.showMagic", label = "Magic buffs you can remove",
              tooltip = "Shows Magic buffs you know a spell to purge or steal." }, Off("look.auras.purge.allBuffs"), "Not used while Show all buffs is on."),
            Gate({ type = "Toggle", path = "look.auras.purge.showEnrage", label = "Enrages you can remove",
              tooltip = "Shows enrage effects you know a spell to soothe." }, Off("look.auras.purge.allBuffs"), "Not used while Show all buffs is on."),
            { type = "Toggle", path = "look.auras.purge.hideBoss", label = "Hide boss auras",
              tooltip = "Hides auras from boss mechanics. Ordinary buffs on a boss still show." },
            { type = "Toggle", path = "look.auras.purge.hidePermanent", label = "Hide permanent buffs",
              tooltip = "Hides buffs with no duration, such as the one every enemy gets in a Mythic dungeon." }
        )),
    AuraPage("auraImportant", "Important auras", "look.auras.important", "important",
        "Shows buffs the game flags as important on enemies.", 24,
        "Show important auras", "Shows icons for buffs the game flags as important on the enemy, except your own. A buff shows here or under Enemy buffs, not both."),
    Section("target", "Target", TARGET_LOOK, List(
        { type = "Header", label = "Border", first = true },
        { type = "ToggleColor", path = "look.target.ring", colorPath = "look.target.ringColor", label = "Show target border",
          swatchLabel = "Target border color", swatchTooltip = "The color of the border around your target.",
          tooltip = "Outlines your target's nameplate." },
        Gate({ type = "Slider", path = "look.target.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the border around your target is." }, On("look.target.ring"), "Turn on Show target border to use this."),

        { type = "Header", label = "Health bar" },
        { type = "ToggleColor", path = "look.target.colorBar", colorPath = "look.target.barColor", label = "Use custom target color",
          swatchLabel = "Target bar color", swatchTooltip = "The health bar color used for your target.",
          tooltip = "Colors your target's health bar, whatever its type." },
        { type = "Dropdown", path = "look.target.texture", label = "Target bar texture", options = HighlightBars, unknown = "Custom texture",
          tooltip = "Health bar texture for your target." },
        { type = "Dropdown", path = "look.target.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Adds a checker or line pattern over your target's bar texture." },
        Gate({ type = "Slider", path = "look.target.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "Opacity of the overlay pattern." }, Chosen("look.target.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.target.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "Difference between the pattern's light and dark parts." }, Chosen("look.target.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Toggle", path = "look.target.brighten", label = "Brighten target health bar",
          tooltip = "Brightens your target's health bar, like Blizzard's classic nameplates." },

        { type = "Header", label = "Arrows" },
        { type = "ToggleColor", path = "look.target.arrows", colorPath = "look.target.arrowColor", label = "Show target arrows",
          swatchLabel = "Target arrow color", swatchTooltip = "Tints the arrows pointing at your target. Leave it white to keep the arrow's own colors.",
          tooltip = "Shows arrows pointing at your target's nameplate." },
        Gate({ type = "Dropdown", path = "look.target.arrowStyle", label = "Arrow style", options = ARROW_STYLES,
          tooltip = "The shape of the arrows pointing at your target." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Slider", path = "look.target.arrowSize", label = "Arrow size", min = 8, max = 48,
          tooltip = "Size of the arrows." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Dropdown", path = "look.target.arrowPlacement", label = "Arrow placement", options = ARROW_PLACEMENTS,
          tooltip = "Which sides of the nameplate the arrows sit on." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Slider", path = "look.target.arrowGap", label = "Arrow distance", min = 0, max = 60,
          tooltip = "Distance between the arrows and the nameplate's edge." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Toggle", path = "look.target.animateArrows", label = "Animate arrows",
          tooltip = "The arrows bob gently toward the nameplate." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),

        { type = "Header", label = "Corner brackets" },
        { type = "ToggleColor", path = "look.target.brackets", colorPath = "look.target.bracketColor", label = "Show target brackets",
          swatchLabel = "Target bracket color", swatchTooltip = "Tints the corner brackets around your target.",
          tooltip = "Draws a bracket in each corner of your target's nameplate." },
        Gate({ type = "Dropdown", path = "look.target.bracketStyle", label = "Bracket style", options = BRACKET_STYLES,
          tooltip = "The look of the corner brackets." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),
        Gate({ type = "Slider", path = "look.target.bracketSize", label = "Bracket size", min = 6, max = 32,
          tooltip = "Size of the corner brackets." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),
        Gate({ type = "Slider", path = "look.target.bracketGap", label = "Bracket distance", min = 0, max = 20,
          tooltip = "How far the brackets sit outside the nameplate's corners." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),

        { type = "Header", label = "Glow" },
        { type = "ToggleColor", path = "look.target.glow", colorPath = "look.target.glowColor", label = "Show target glow",
          swatchLabel = "Target glow color", swatchTooltip = "The color of the glow around your target. Lower its opacity for a subtler glow.",
          tooltip = "Shows a glow around your target's nameplate." },
        Gate({ type = "Slider", path = "look.target.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the glow spreads from the nameplate." }, On("look.target.glow"), "Turn on Show target glow to use this."),
        Gate({ type = "Toggle", path = "look.target.pulse", label = "Pulse glow and border",
          tooltip = "Your target's glow and border slowly pulse brighter and dimmer." }, Any(On("look.target.ring"), On("look.target.glow")), "Turn on Show target border or Show target glow to use this.")

    )),

    Section("focus", "Focus", "look.focus", List(
        { type = "Header", label = "Border", first = true },
        { type = "ToggleColor", path = "look.focus.ring", colorPath = "look.focus.ringColor", label = "Show focus border",
          swatchLabel = "Focus border color", swatchTooltip = "The color of the border around your focus.",
          tooltip = "Outlines your focus's nameplate." },
        Gate({ type = "Slider", path = "look.focus.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the border around your focus is." }, On("look.focus.ring"), "Turn on Show focus border to use this."),

        { type = "Header", label = "Health bar" },
        { type = "ToggleColor", path = "look.focus.colorBar", colorPath = "look.focus.barColor", label = "Use custom focus color",
          swatchLabel = "Focus bar color", swatchTooltip = "The health bar color used for your focus.",
          tooltip = "Colors your focus's health bar, whatever its type." },
        { type = "Dropdown", path = "look.focus.texture", label = "Focus bar texture", options = HighlightBars, unknown = "Custom texture",
          tooltip = "Health bar texture for your focus." },
        { type = "Dropdown", path = "look.focus.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Adds a checker or line pattern over your focus's bar texture." },
        Gate({ type = "Slider", path = "look.focus.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "Opacity of the overlay pattern." }, Chosen("look.focus.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.focus.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "Difference between the pattern's light and dark parts." }, Chosen("look.focus.overlayPattern"), "Choose an overlay pattern to use this."),

        { type = "Header", label = "Arrows" },
        { type = "ToggleColor", path = "look.focus.arrows", colorPath = "look.focus.arrowColor", label = "Show focus arrows",
          swatchLabel = "Focus arrow color", swatchTooltip = "Tints the arrows pointing at your focus. Leave it white to keep the arrow's own colors.",
          tooltip = "Shows arrows pointing at your focus's nameplate." },
        Gate({ type = "Dropdown", path = "look.focus.arrowStyle", label = "Arrow style", options = ARROW_STYLES,
          tooltip = "The shape of the arrows pointing at your focus." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Slider", path = "look.focus.arrowSize", label = "Arrow size", min = 8, max = 48,
          tooltip = "Size of the arrows." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Dropdown", path = "look.focus.arrowPlacement", label = "Arrow placement", options = ARROW_PLACEMENTS,
          tooltip = "Which sides of the nameplate the arrows sit on." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Slider", path = "look.focus.arrowGap", label = "Arrow distance", min = 0, max = 60,
          tooltip = "Distance between the arrows and the nameplate's edge." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Toggle", path = "look.focus.animateArrows", label = "Animate arrows",
          tooltip = "The arrows bob gently toward the nameplate." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),

        { type = "Header", label = "Corner brackets" },
        { type = "ToggleColor", path = "look.focus.brackets", colorPath = "look.focus.bracketColor", label = "Show focus brackets",
          swatchLabel = "Focus bracket color", swatchTooltip = "Tints the corner brackets around your focus.",
          tooltip = "Draws a bracket in each corner of your focus's nameplate." },
        Gate({ type = "Dropdown", path = "look.focus.bracketStyle", label = "Bracket style", options = BRACKET_STYLES,
          tooltip = "The look of the corner brackets." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),
        Gate({ type = "Slider", path = "look.focus.bracketSize", label = "Bracket size", min = 6, max = 32,
          tooltip = "Size of the corner brackets." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),
        Gate({ type = "Slider", path = "look.focus.bracketGap", label = "Bracket distance", min = 0, max = 20,
          tooltip = "How far the brackets sit outside the nameplate's corners." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),

        { type = "Header", label = "Glow" },
        { type = "ToggleColor", path = "look.focus.glow", colorPath = "look.focus.glowColor", label = "Show focus glow",
          swatchLabel = "Focus glow color", swatchTooltip = "The color of the glow around your focus. Lower its opacity for a subtler glow.",
          tooltip = "Shows a glow around your focus's nameplate." },
        Gate({ type = "Slider", path = "look.focus.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the glow spreads from the nameplate." }, On("look.focus.glow"), "Turn on Show focus glow to use this."),
        Gate({ type = "Toggle", path = "look.focus.pulse", label = "Pulse glow and border",
          tooltip = "Your focus's glow and border slowly pulse brighter and dimmer." }, Any(On("look.focus.ring"), On("look.focus.glow")), "Turn on Show focus border or Show focus glow to use this."),
        { type = "Note", label = "When your target is also your focus, Target settings win. Focus bar settings fill in where Target's are off." }
    )),

    Section("mouseover", "Mouseover", "look.mouseover", Join(List(
        { type = "Header", label = "Mouseover highlight", first = true },
        { type = "Toggle", path = "look.mouseover.enabled", label = "Enable mouseover highlight",
          tooltip = "Highlights the nameplate under your cursor, or of the unit your cursor is over in the world." }
    ), GateList(HoverOn, HOVER_ON,
        { type = "Toggle", path = "look.mouseover.skipFriendly", label = "Skip friendly nameplates",
          tooltip = "Friendly nameplates aren't highlighted." },
        { type = "Toggle", path = "look.mouseover.brighten", label = "Brighten health bar",
          tooltip = "Brightens the health bar under your cursor, like Blizzard's classic nameplates." },
        Gate({ type = "Slider", path = "look.mouseover.brightenAmount", label = "Highlight intensity", min = 0.05, max = 0.6, step = 0.05,
          tooltip = "How much the health bar brightens." }, On("look.mouseover.brighten"), "Turn on Brighten health bar to use this.")
    ), List(
        { type = "Header", label = "Border" }
    ), GateList(HoverOn, HOVER_ON,
        { type = "ToggleColor", path = "look.mouseover.ring", colorPath = "look.mouseover.ringColor", label = "Show mouseover border",
          swatchLabel = "Mouseover border color", swatchTooltip = "The color of the border around the nameplate under your cursor.",
          tooltip = "Outlines the nameplate under your cursor." },
        Gate({ type = "Slider", path = "look.mouseover.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the mouseover border is." }, On("look.mouseover.ring"), "Turn on Show mouseover border to use this.")
    ), List(
        { type = "Header", label = "Glow" }
    ), GateList(HoverOn, HOVER_ON,
        { type = "ToggleColor", path = "look.mouseover.glow", colorPath = "look.mouseover.glowColor", label = "Show mouseover glow",
          swatchLabel = "Mouseover glow color", swatchTooltip = "The color of the glow around the nameplate under your cursor.",
          tooltip = "Shows a glow around the nameplate under your cursor." }
    ), List(
        Gate({ type = "Slider", path = "look.mouseover.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the glow spreads from the nameplate." }, HoverGlowOn, HoverGlowReason)
    ))),

    Section("raidMarker", "Raid target icon", "look.raidMarker", Join(List(
        { type = "Header", label = "Raid target icon", first = true },
        { type = "Toggle", path = "look.raidMarker.enabled", label = "Show raid target icons",
          tooltip = "Shows raid target icons on nameplates." }
    ), GateList(On("look.raidMarker.enabled"), "Turn on Show raid target icons to use this.",
        { type = "Slider", path = "look.raidMarker.size", label = "Icon size", min = 8, max = 40,
          tooltip = "Size of the raid target icon." },
        Placement("look.raidMarker")
    ), List(
        { type = "Header", label = "Raid icon border" }
    ), GateList(On("look.raidMarker.enabled"), "Turn on Show raid target icons to use this.",
        { type = "Toggle", path = "look.raidMarker.tintBorder", label = "Color border by raid icon",
          tooltip = "Outlines marked nameplates in the icon's color. Target and focus borders take priority." }
    ), List(
        Gate({ type = "Slider", path = "look.raidMarker.tintSize", label = "Raid icon border thickness", min = 1, max = 6,
          tooltip = "How thick the raid icon border is." }, function() return ns.Get("look.raidMarker.enabled") == true and ns.Get("look.raidMarker.tintBorder") == true end,
          function()
              if ns.Get("look.raidMarker.enabled") ~= true then return "Turn on Show raid target icons to use this." end
              return "Turn on Color border by raid icon to use this."
          end)
    ), List(
    ))),

    Section("quest", "Quest icon", { "look.quest", "look.colors.quest", "look.colors.questColor", "look.colors.questExcludeBoss" }, Join(
        List(
        { type = "Header", label = "Quest icon", first = true },
        { type = "Toggle", path = "look.quest.enabled", label = "Show quest icon",
          tooltip = "Marks enemies needed for quests in your log. Not available on every game version." },
        { type = "Toggle", path = "look.colors.questExcludeBoss", label = "Exclude bosses",
          tooltip = "Bosses never get the quest icon or quest color." },
        Gate({ type = "Dropdown", path = "look.quest.style", label = "Icon style", options = QUEST_ICONS,
          tooltip = "The quest icon's artwork." }, On("look.quest.enabled"), "Turn on Show quest icon to use this."),
        Gate({ type = "Slider", path = "look.quest.size", label = "Icon size", min = 8, max = 40,
          tooltip = "Size of the quest icon." }, On("look.quest.enabled"), "Turn on Show quest icon to use this."),
        Gate({ type = "Toggle", path = "look.quest.showProgress", label = "Show objective progress",
          tooltip = "Shows quest progress, like 3/8, beside the icon. May be hidden inside instances." }, On("look.quest.enabled"), "Turn on Show quest icon to use this.")
        ),
        GateList(On("look.quest.enabled"), "Turn on Show quest icon to use this.", Placement("look.quest")),
        List(
        { type = "Header", label = "Quest enemy color" },
        { type = "ToggleColor", path = "look.colors.quest", colorPath = "look.colors.questColor", label = "Color quest enemies",
          tooltip = "Colors the health bars of enemies needed for your quests. Threat, tapped, target and focus colors take priority." }
        )
    )),

    Section("forces", "Mythic+ enemy forces", "look.forces", Join(
        List(
            { type = "Header", label = "Mythic+ enemy forces", first = true },
            { type = "Toggle", path = "look.forces.enabled", label = "Show enemy forces",
              tooltip = "Shows how much enemy forces each enemy is worth during a Mythic+ run." },
            Gate({ type = "Dropdown", path = "look.forces.format", label = "Display format", options = FORCES_FORMATS,
              tooltip = "How the enemy forces value is shown." }, On("look.forces.enabled"), "Turn on Show enemy forces to use this."),
            Gate({ type = "Color", path = "look.forces.color", label = "Text color",
              tooltip = "Color of the enemy forces text." }, On("look.forces.enabled"), "Turn on Show enemy forces to use this.")
        ),
        GateList(On("look.forces.enabled"), "Turn on Show enemy forces to use this.", Placement("look.forces")),
        List({ type = "Header", label = "Font" }),
        GateList(On("look.forces.enabled"), "Turn on Show enemy forces to use this.", FontControls("look.forces"))
    )),

    Section("threatText", "Threat", { "look.threatText", "look.colors.threat", "look.colors.threatBad", "look.colors.threatDisplay", "look.colors.showThreatWarning", "look.colors.threatWarning", "look.colors.showThreatGood", "look.colors.threatGood", "look.colors.showOffTank", "look.colors.offTankColor" }, Join(
        List(
            { type = "Header", label = "Threat colors", first = true },
            { type = "ToggleColor", path = "look.colors.threat", colorPath = "look.colors.threatBad", label = "Threat colors",
              tooltip = "Colors enemies by threat in combat. This color means threat is wrong: a tank lost aggro, or anyone else has it." },
            Gate({ type = "Dropdown", path = "look.colors.threatDisplay", label = "Show threat on", options = THREAT_DISPLAY,
              tooltip = "Shows threat on the health bar, its border, or both." }, On("look.colors.threat"), "Turn on Threat colors to use this."),
            Gate({ type = "ToggleColor", path = "look.colors.showThreatWarning", colorPath = "look.colors.threatWarning", label = "Threat warning color",
              tooltip = "Used when threat is about to change hands." }, On("look.colors.threat"), "Turn on Threat colors to use this."),
            Gate({ type = "ToggleColor", path = "look.colors.showThreatGood", colorPath = "look.colors.threatGood", label = "Threat safe color",
              tooltip = "Used when threat is where it should be." }, On("look.colors.threat"), "Turn on Threat colors to use this."),
            Gate({ type = "ToggleColor", path = "look.colors.showOffTank", colorPath = "look.colors.offTankColor", label = "Off-tank color",
              tooltip = "Tanks only. Used for enemies held by another tank in your group." }, On("look.colors.threat"), "Turn on Threat colors to use this."),
            { type = "Header", label = "Threat percent" },
            { type = "Note", label = "Your threat on each enemy as a percentage. 100% means you have aggro. The game may hide this number on Retail.", height = 32 },
            { type = "Toggle", path = "look.threatText.enabled", label = "Show threat percent",
              tooltip = "Shows your threat on each enemy NPC as a percentage." },
            Gate({ type = "Toggle", path = "look.threatText.hideZero", label = "Hide at 0%",
              tooltip = "Hides the text on enemies you have no threat on." }, On("look.threatText.enabled"), "Turn on Show threat percent to use this."),
            Gate({ type = "Color", path = "look.threatText.color", label = "Text color",
              tooltip = "Color of the threat percent text." }, On("look.threatText.enabled"), "Turn on Show threat percent to use this.")
        ),
        GateList(On("look.threatText.enabled"), "Turn on Show threat percent to use this.", Placement("look.threatText")),
        List({ type = "Header", label = "Font" }),
        GateList(On("look.threatText.enabled"), "Turn on Show threat percent to use this.", FontControls("look.threatText"))
    )),

    Section("enemyPower", "Enemy power bar", "look.enemyPower", Join(List(
        { type = "Header", label = "Display", first = true },
        { type = "Note", label = "Shows an enemy's mana, rage, energy or other power. Some enemies and encounters don't provide it.", height = 32 },
        { type = "Toggle", path = "look.enemyPower.enabled", label = "Show enemy power bar",
          tooltip = "Adds a thin bar for the enemy's power to its nameplate." }
    ), GateList(PowerOn, POWER_ON,
        { type = "Dropdown", path = "look.enemyPower.show", label = "Show on", options = ENEMY_POWER_SHOW,
          tooltip = "Which enemies get a power bar. Bosses are the same enemies as the Bosses health bar color." },
        { type = "Toggle", path = "look.enemyPower.hideFull", label = "Hide at full power",
          tooltip = "Hides the power bar while the enemy's power is full." }
    ), List(
        { type = "Header", label = "Bar" }
    ), GateList(PowerOn, POWER_ON,
        { type = "Dropdown", path = "look.enemyPower.position", label = "Bar position", options = ENEMY_POWER_POSITIONS,
          tooltip = "Where the power bar sits relative to the health bar." },
        { type = "Slider", path = "look.enemyPower.height", label = "Height", min = 2, max = 20,
          tooltip = "Height of the power bar." },
        { type = "Slider", path = "look.enemyPower.width", label = "Width", min = 0, max = 300,
          tooltip = "Width of the power bar. 0 matches the health bar." },
        { type = "Slider", path = "look.enemyPower.offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the power bar left (negative) or right (positive)." },
        { type = "Slider", path = "look.enemyPower.offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Nudges the power bar down (negative) or up (positive)." },
        { type = "Slider", path = "look.enemyPower.alpha", label = "Opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "Opacity of the power bar and its text." },
        { type = "Dropdown", path = "look.enemyPower.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "Fill texture of the power bar." },
        { type = "ToggleColor", path = "look.enemyPower.customColor", colorPath = "look.enemyPower.color", label = "Custom power color",
          tooltip = "Uses this color instead of the power type's usual color." },
        { type = "Color", path = "look.enemyPower.backgroundColor", label = "Background color",
          tooltip = "Color of the unfilled portion of the power bar." },
        { type = "ToggleColor", path = "look.enemyPower.border", colorPath = "look.enemyPower.borderColor", label = "Border",
          tooltip = "Shows a thin border around the power bar." },
        { type = "Toggle", path = "look.enemyPower.smooth", label = "Smooth changes",
          tooltip = "Animates power changes instead of jumping." }
    ), List(
        { type = "Header", label = "Text" }
    ), GateList(PowerOn, POWER_ON,
        { type = "Toggle", path = "look.enemyPower.showText", label = "Show power text",
          tooltip = "Shows the enemy's power on the bar, when available." }
    ), GateList(PowerText, PowerTextReason,
        { type = "Dropdown", path = "look.enemyPower.textFormat", label = "Text format", options = POWER_TEXT_FORMATS,
          tooltip = "How the power text is shown." },
        { type = "Dropdown", path = "look.enemyPower.textAnchor", label = "Text position", options = POWER_TEXT_ANCHORS,
          tooltip = "Where the text sits on the power bar." },
        { type = "Dropdown", path = "look.enemyPower.font", label = "Font", options = Fonts, unknown = "Custom font",
          tooltip = "Font of the power text." },
        { type = "Slider", path = "look.enemyPower.textSize", label = "Font size", min = 6, max = 20,
          tooltip = "Size of the power text." },
        { type = "Dropdown", path = "look.enemyPower.outline", label = "Font outline", options = OUTLINES,
          tooltip = "The dark edge drawn around each letter, to keep it readable over any background." }
    ))),

    Section("classPower", "Class resource", "look.classPower", Join(
        List(
            { type = "Header", label = "Class resource", first = true },
            { type = "Toggle", path = "look.classPower.enabled", label = "Show class resource on target",
              tooltip = "Shows your combo points, holy power, chi or other class resource on your enemy target's nameplate." }
        ), GateTable(On("look.classPower.enabled"), "Turn on Show class resource on target to use this.", List(
            { type = "Toggle", path = "look.classPower.hideEmpty", label = "Hide when empty",
              tooltip = "Hides the resource while you have none. Death Knight runes always show." },
            { type = "Toggle", path = "look.classPower.glowMax", label = "Glow at maximum",
              tooltip = "The resource glows while it is full." },
            { type = "Toggle", path = "look.classPower.classColor", label = "Use class color",
              tooltip = "Colors filled segments with your class color." },
            Gate({ type = "Color", path = "look.classPower.color", label = "Color",
              tooltip = "Color of filled segments." }, Off("look.classPower.classColor"), "Not used while Use class color is on."),
            { type = "Color", path = "look.classPower.emptyColor", label = "Empty segment color",
              tooltip = "Color of empty segments." },
            { type = "Slider", path = "look.classPower.pipWidth", label = "Segment width", min = 0, max = 40,
              tooltip = "Width of each segment. 0 matches the health bar's width." },
            { type = "Slider", path = "look.classPower.pipHeight", label = "Segment height", min = 2, max = 24,
              tooltip = "Height of each segment." },
            { type = "Slider", path = "look.classPower.spacing", label = "Segment spacing", min = 0, max = 10,
              tooltip = "Space between segments." }
        )),
        GateList(On("look.classPower.enabled"), "Turn on Show class resource on target to use this.", Placement("look.classPower"))
    )),

    Section("classification", "Elite icon", "look.classification", Join(List(
        { type = "Header", label = "Elite, rare and boss icon", first = true },
        { type = "Toggle", path = "look.classification.enabled", label = "Show elite icon",
          tooltip = "Shows Blizzard's elite, rare and boss icon. Choose which enemies get it below." }
    ), GateList(On("look.classification.enabled"), "Turn on Show elite icon to use this.",
        { type = "Toggle", path = "look.classification.showElite", label = "Elites",
          tooltip = "Shows the gold icon on elites." },
        { type = "Toggle", path = "look.classification.showRareElite", label = "Rare elites",
          tooltip = "Shows the silver icon on rare elites." },
        { type = "Toggle", path = "look.classification.showRare", label = "Rares",
          tooltip = "Shows the star icon on rares." },
        { type = "Toggle", path = "look.classification.showBoss", label = "World bosses",
          tooltip = "Shows the gold icon on world bosses. Most dungeon and raid bosses aren't world bosses." }
    ), GateList(BadgeOn, BadgeReason,
        { type = "Slider", path = "look.classification.size", label = "Icon size", min = 8, max = 40,
          tooltip = "Size of the elite icon." },
        Placement("look.classification")
    ))),

    Section("faction", "Faction icon", "look.faction", Join(List(
        { type = "Header", label = "Horde or Alliance icon", first = true },
        { type = "Toggle", path = "look.faction.enabled", label = "Show faction icon on players",
          tooltip = "Shows the Horde or Alliance icon on other players' nameplates. Not shown on names-only friendly nameplates." }
    ), GateList(On("look.faction.enabled"), "Turn on Show faction icon on players to use this.",
        { type = "Toggle", path = "look.faction.onlyPvP", label = "Only when flagged for PvP",
          tooltip = "Shows the icon only on players flagged for PvP, like the target frame." },
        { type = "Slider", path = "look.faction.size", label = "Icon size", min = 8, max = 40,
          tooltip = "Size of the faction icon." },
        Placement("look.faction")
    ))),

    {
        key = "addon",
        title = "Plateau settings",
        reset = function()
            local global = Plateau.DB.saved.global
            local reload = global.optionsFont ~= nil or global.optionsHeadingFont ~= nil
            global.optionsScale, global.optionsFont, global.optionsHeadingFont = nil, nil, nil
            ns.ApplyScale()
            if reload then
                ns.PromptReload()
            end
        end,
        controls = List(
            { type = "Note", label = "Plateau's own preferences for this settings window, not your nameplates. They are saved once for your account and are not part of a profile.", height = 24 },
            { type = "Header", label = "Other nameplate addons" },
            { type = "Conflicts" },
            { type = "Header", label = "Settings window" },
            { type = "Dropdown", label = "Settings window theme",
              options = { { value = "workbench", label = "Workbench" }, { value = "ledger", label = "Artisan Ledger" }, { value = "classic", label = "Lixard Classic" } },
              get = function() return Style.ThemeKey() end,
              set = function(value)
                  if value ~= Style.ThemeKey() then
                      Style.SetTheme(value)
                      ns.PromptReload()
                  end
              end,
              tooltip = "The look of Plateau's settings window and pop-ups. Nameplates are not affected. Requires a reload." },
            { type = "Dropdown", label = "Brand color", keywords = "color colour brand icon minimap class rainbow cycle random logo",
              options = { { value = "class", label = "Class color" }, { value = "cycle", label = "Color cycle" }, { value = "random", label = "Random each login" } },
              get = function() return Plateau.Brand:Mode() end,
              set = function(value) Plateau.Brand:SetMode(value) end,
              reset = function() Plateau.Brand:SetMode("class") end,
              tooltip = "The color of Plateau's icon and name on the minimap button, game menu button and chat messages." },
            { type = "Slider", label = "Settings window scale", min = Style.SCALE_MIN, max = Style.SCALE_MAX, step = 0.05, applyOnRelease = true, keywords = "size zoom bigger smaller options window ui scale",
              get = function() return Style.Scale() end,
              set = function(value)
                  Plateau.DB.saved.global.optionsScale = value
                  ns.ApplyScale()
              end,
              reset = function()
                  Plateau.DB.saved.global.optionsScale = nil
                  ns.ApplyScale()
              end,
              tooltip = "The size of this settings window, on top of your UI scale. Nameplates are not affected." },
            { type = "Header", label = "Fonts" },
            { type = "Dropdown", label = "Text font", keywords = "font typeface options window",
              options = function() return ns.OptionsFonts() end,
              get = function() return Plateau.DB.saved.global.optionsFont or "" end,
              set = function(value)
                  if value == (Plateau.DB.saved.global.optionsFont or "") then return end
                  Plateau.DB.saved.global.optionsFont = value ~= "" and value or nil
                  ns.PromptReload()
              end,
              reset = function()
                  Plateau.DB.saved.global.optionsFont = nil
                  ns.PromptReload()
              end,
              tooltip = "The font for text in this settings window. Nameplates are not affected. Requires a reload." },
            { type = "Dropdown", label = "Heading font", keywords = "font typeface title header options window",
              options = function() return ns.OptionsFonts() end,
              get = function() return Plateau.DB.saved.global.optionsHeadingFont or "" end,
              set = function(value)
                  if value == (Plateau.DB.saved.global.optionsHeadingFont or "") then return end
                  Plateau.DB.saved.global.optionsHeadingFont = value ~= "" and value or nil
                  ns.PromptReload()
              end,
              reset = function()
                  Plateau.DB.saved.global.optionsHeadingFont = nil
                  ns.PromptReload()
              end,
              tooltip = "The font for titles and headings in this settings window. Requires a reload." },
            { type = "Header", label = "Help and access" },
            { type = "Toggle", label = "Show settings tooltips",
              get = function() return Plateau.DB.saved.global.tooltipsEnabled ~= false end,
              set = function(value) Plateau.DB.saved.global.tooltipsEnabled = value == true end,
              tooltip = "Shows a description when you hover a setting. Reset hints and instance warnings always show." },
            { type = "Toggle", label = "Show Plateau in game menu",
              get = function() return not Plateau.DB.saved.global.hideMenuButton end,
              set = function(value) Plateau.DB.saved.global.hideMenuButton = not value end,
              tooltip = "Adds a Plateau button above AddOns in the Game Menu. Takes effect the next time the menu opens." },
            { type = "Toggle", label = "Show minimap button", visibleIf = function() return Plateau.Minimap ~= nil end,
              get = function() return Plateau.Minimap ~= nil and Plateau.Minimap:IsShown() end,
              set = function(value) Plateau.Minimap:SetShown(value == true) end,
              tooltip = "A button on the minimap that opens the settings. Drag it to move it." },
            { type = "Toggle", label = "Show in addon compartment", visibleIf = function() return Plateau.Minimap ~= nil and Plateau.Minimap:HasCompartment() end,
              get = function() return Plateau.Minimap ~= nil and Plateau.Minimap:InCompartment() end,
              set = function(value) Plateau.Minimap:SetCompartment(value == true) end,
              tooltip = "Lists Plateau in the addon compartment by the minimap." }
        ),
    },

    {
        key = "profiles",
        title = "Profiles",
        noReset = true,
        resetAll = true,
        controls = List(
            { type = "Note", label = "Profiles store your nameplate look and your aura spell lists. Each character has its own default profile.", height = 24 },
            { type = "ProfileStatus", label = "Default profile", keywords = "active profile override reason pending switch character",
              tooltip = "The profile this character falls back to when no automatic rule applies. The active profile is the one every page edits." },
            { type = "Header", label = "Manage profiles", keywords = "create new duplicate active rename copy settings from replace current delete restore built-in reset profile reset everything defaults start over" },
            { type = "ProfileActions", label = "Create profile", keywords = "new profile duplicate active rename profile copy settings from delete profile restore built-in",
              tooltip = "Create, duplicate, rename, copy settings between, delete and restore profiles." },
            { type = "Header", label = "Switch automatically", keywords = "content specialization override raid dungeon delve arena battleground open world no override" },
            { type = "Note", label = "Content-specific profiles take priority over specialization profiles. If neither is assigned, your default profile is used. Automatic switches apply after combat ends.", height = 32 },
            { type = "AutoProfiles" },
            { type = "Header", label = "Share", keywords = "export import profile string copy paste backup" },
            { type = "ShareProfile", label = "Export active profile", keywords = "import profile profile export string paste a plateau profile string activate after import profile name",
              tooltip = "Export the active profile as a text string, or import a string as a new profile." },
            { type = "Header", label = "What a profile includes", collapsible = true, collapsed = true, keywords = "scope saved shared game settings spell lists automatic rules export" },
            { type = "Note", label = "In a profile: every Plateau setting on the Nameplates, Behavior, States, Auras, Icons and Friendly pages. Blizzard's own settings, which some of those pages also show, are not part of a profile.", height = 32 },
            { type = "Note", label = "Aura spell lists (Hidden spells and Allowed spells) are saved in the profile and per specialization, so a different profile or specialization shows a different set.", height = 32 },
            { type = "Note", label = "Not in a profile: your default profile and the automatic switching rules (saved per character), the Blizzard nameplate settings on Game settings (saved once for your account and shared by every profile and character), Plateau settings (the gear button), and boss phase lines (saved for your account). Export and import carry the look, the aura spell lists and your boss phase lines; importing adds those boss lines to yours.", height = 58 }
        ),
    },
}

local MAINLINE_ONLY = { forces = true }
if Plateau.flavor == "forever" then
    local kept = {}
    for _, section in ipairs(ns.sections) do
        if not MAINLINE_ONLY[section.key] then
            kept[#kept + 1] = section
        end
    end
    ns.sections = kept
end

local NOT_SAVED = " Only the preview changes; nothing is saved, and it goes back to the default when you leave this page."
local SECTION_PICKS = {
    castbar = { HeaderPick("cast", "Preview cast", PREVIEW_CASTS, "The kind of cast the preview plays while this page is open, so you can see each cast bar color." .. NOT_SAVED) },
    healthColors = {
        HeaderPick("enemy", "Preview enemy", PREVIEW_ENEMIES, "The kind of enemy the preview shows, so you can see its color." .. NOT_SAVED),
        HeaderPick("threat", "Preview threat", PREVIEW_THREAT, "The threat state the preview shows, so you can see its color." .. NOT_SAVED),
    },
    threatText = {
        HeaderPick("threat", "Preview threat", PREVIEW_THREAT, "The threat state the preview shows, so you can see its color." .. NOT_SAVED),
    },
    classification = { HeaderPick("badge", "Preview badge", PREVIEW_BADGES, "The badge the preview shows." .. NOT_SAVED) },
}
for _, section in ipairs(ns.sections) do
    section.picks = SECTION_PICKS[section.key]
end

ns.CVarToggle = CVarToggle
ns.CVarBitToggle = CVarBitToggle
ns.stackTypes = STACK
