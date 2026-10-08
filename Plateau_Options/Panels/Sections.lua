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
    { value = "by", label = "Interrupted by Name" },
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
    { value = "both", label = "Both  (52.3K | 87%)" },
    { value = "paren", label = "Both  (52.3K (87%))" },
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
    table.insert(QUEST_ICONS, 1, { value = "UI-QuestPoiCampaign-QuestBang", label = "Campaign quest (current)" })
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
    { value = "right", label = "Over the bar, from the right edge" },
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
    { value = "abbreviate", label = "Initials + last word  (A. Dawnsong)" },
    { value = "lastInitial", label = "First word + last initial  (Aelindra D.)" },
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
          tooltip = "How see-through it is. 1 is fully solid." },
        { type = "Dropdown", path = path .. ".position", label = "Position", options = SIDES,
          tooltip = "Which side of the nameplate (measured from the health bar) this sits on, or on top of the bar." },
        { type = "Slider", path = path .. ".gap", label = "Distance from the nameplate", min = 0, max = 20,
          tooltip = "How far this sits from the nameplate's edge, in the direction of Position (inward for the Inside options, and no effect at Inside bar, center). Applied before the offsets." },
        { type = "Slider", path = path .. ".offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Nudges it left (negative) or right (positive) from the spot set by Position and distance." },
        { type = "Slider", path = path .. ".offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Nudges it down (negative) or up (positive) from the spot set by Position and distance." }
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
        Plateau.DB:Reset(group)
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
        tooltip = "Same choices as Blizzard's NPC Names option, which sets several game settings together.",
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

local function FriendlyToggle(path, cvar, label)
    return {
        type = "Toggle",
        label = label,
        tooltip = "Also turns Blizzard's own setting on or off, since the game has to show these plates before Plateau can style them.",
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

local function BlizzardDrawn()
    local list = {
        { type = "Header", label = "Blizzard-drawn nameplates", collapsible = true, collapsed = true },
        { type = "Note", label = "These change only the nameplates the game draws itself: friendly nameplates in dungeons, raids and arenas, where the game locks them, and any nameplate Plateau isn't styling. Plateau's own nameplates are not affected, except by the two Simplify friendly switches.", height = 44 },
    }
    local function Add(spec)
        list[#list + 1] = spec
    end
    local function Bits(cvar, enum, entries)
        if not (C_CVar.GetCVar(cvar) and enum) then return end
        for _, entry in ipairs(entries) do
            if enum[entry[1]] and entry.shown ~= false then
                Add(CVarBitToggle(cvar, enum[entry[1]], entry[2], entry[3]))
            end
        end
    end

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
        Add({ type = "Dropdown", label = "Style", options = options,
          get = function() return tonumber(CVars:Get("nameplateStyle")) end,
          set = function(value) CVars:Set("nameplateStyle", value) end,
          reset = function() CVars:Release("nameplateStyle") end,
          resetLabel = "Right-click to undo Plateau's change.",
          path = "cvar.nameplateStyle",
          tooltip = "The overall look of the nameplates the game draws: Modern, Thin, Block, Health focus, Cast focus or Legacy." })
    end

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
        { "Progressive", "Aggro: progressive", "Shows aggro building up gradually on the game's nameplates." },
        { "Flash", "Aggro: flash", "Flashes the game's nameplate when aggro changes." },
        { "HealthBarColor", "Aggro: health bar color", "Colors the game's health bar by aggro." },
    })
    Bits("nameplateEnemyNpcAuraDisplay", Enum.NamePlateEnemyNpcAuraDisplay, {
        { "Buffs", "Enemy NPCs: buffs", "Shows enemy NPC buffs on the nameplates the game draws." },
        { "Debuffs", "Enemy NPCs: your debuffs", "Shows your debuffs on enemy NPCs on the nameplates the game draws." },
        { "CrowdControl", "Enemy NPCs: crowd control", "Shows crowd control on enemy NPCs on the nameplates the game draws." },
    })
    Bits("nameplateEnemyPlayerAuraDisplay", Enum.NamePlateEnemyPlayerAuraDisplay, {
        { "Buffs", "Enemy players: buffs", "Shows enemy player buffs on the nameplates the game draws." },
        { "Debuffs", "Enemy players: your debuffs", "Shows your debuffs on enemy players on the nameplates the game draws." },
        { "LossOfControl", "Enemy players: big debuff", "Shows one large loss-of-control debuff on enemy players." },
    })
    Bits("nameplateFriendlyPlayerAuraDisplay", Enum.NamePlateFriendlyPlayerAuraDisplay, {
        { "Buffs", "Friendly players: your buffs", "Shows your buffs on friendly players on the nameplates the game draws." },
        { "Debuffs", "Friendly players: enemy debuffs", "Shows debuffs from enemies on friendly players on the nameplates the game draws." },
        { "LossOfControl", "Friendly players: big debuff", "Shows one large loss-of-control debuff on friendly players." },
    })
    if C_CVar.GetCVar("nameplateDebuffPadding") then
        Add(CVarSlider("nameplateDebuffPadding", "Debuff padding", 0, 50, 1, "Space between buff and debuff icons on the nameplates the game draws."))
    end
    Bits("nameplateSimplifiedTypes", Enum.NamePlateSimplifiedType, {
        { "Minion", "Simplify minions", "Draws pets, guardians and totems as small simplified nameplates." },
        { "MinusMob", "Simplify minor enemies", "Draws minor enemies as small simplified nameplates." },
        { "FriendlyPlayer", "Simplify friendly players", "Draws friendly players as small simplified nameplates with no name, health text or auras; your target keeps its name. Plateau's friendly plates follow this too. With Only show friendly player names or Show just the name on, only your target's name is left." },
        { "FriendlyNpc", "Simplify friendly NPCs", "Draws friendly NPCs as small simplified nameplates with no name, health text or auras; your target keeps its name. Plateau's friendly plates follow this too. With Show just the name on, only your target's name is left." },
    })
    if C_CVar.GetCVar("nameplateShowDebuffsOnFriendly") then
        Add(CVarToggle("nameplateShowDebuffsOnFriendly", "Friendly plates: show debuffs", "Shows debuffs on friendly players on the nameplates the game draws, like friendly plates in dungeons and raids."))
    end
    if C_CVar.GetCVar("nameplateShowFriendlyClassColor") then
        Add(CVarToggle("nameplateShowFriendlyClassColor", "Class colors: friendly players", "Colors friendly player health bars by class on the nameplates the game draws."))
    end
    if C_CVar.GetCVar("nameplateShowClassColor") then
        Add(CVarToggle("nameplateShowClassColor", "Class colors: enemy players", "Colors enemy player health bars by class on the nameplates the game draws."))
    end
    return list
end

local RADIAL = {
    { value = 0, label = "Off" },
    { value = 1, label = "Target only" },
    { value = 2, label = "Everything I'm fighting" },
}

local STACK_SPACES = {
    { value = "bar", label = "Health bar only (tightest)" },
    { value = "name", label = "Health bar and name" },
    { value = "barcast", label = "Health bar and cast bar" },
    { value = "cast", label = "Health bar, name and cast bar" },
    { value = "all", label = "Everything, including buffs and debuffs" },
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
    StackPreset("tight", "Tight", "Plates sit close together: good for big Mythic+ pulls where you want the whole pack on screen. Changes only the spacing between plates.", { "0.8", "0.7" }),
    StackPreset("balanced", "Balanced", "Blizzard's own spacing, put back exactly as it was before Plateau changed it. Changes only the spacing between plates."),
    StackPreset("spread", "Spread out", "More room between plates, so names, cast bars and icons overlap less. Pulls take more screen height. Changes only the spacing between plates.", { "1.5", "1.1" }),
}

local function InstantMovement()
    return {
        type = "Toggle",
        label = "Instant movement (no sliding)",
        tooltip = "Plates jump straight to their spot instead of gliding, so they never drift across each other. Turns Movement speed up to 1. Turning it off puts Movement speed back to how it was before. Separate from the spacing presets above.",
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
    local spec = CVarToggle("nameplateShowFriendlyRealmName", "Show friendly players' realm names",
        "Adds a friendly player's home realm to their name when they're from a different one than you, on Plateau's friendly plates and Blizzard's. Blizzard's plates pick up the change after a /reload.")
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
        return "Style friendly nameplates with Plateau is off, so Blizzard draws friendly plates with its own settings."
    end
    return "Friendly players and Friendly NPCs are both off, so Blizzard draws these with its own settings."
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
        return "Only used while Show just the name, no bar is on. Full friendly plates use the Name page's colors."
    end
    return spec
end

local function FriendlyGate(spec)
    return Gate(spec, FriendlyAnyOn, FriendlyOffReason)
end

local function FriendlyPlayersGate(spec)
    return Gate(spec, FriendlyPlayersOn, function()
        if not FriendlyOn() then return FriendlyOffReason() end
        return "Friendly players is off, so Blizzard draws their names with its own settings."
    end)
end

local function FriendlyNpcsGate(spec)
    return Gate(spec, FriendlyNpcsOn, function()
        if not FriendlyOn() then return FriendlyOffReason() end
        return "Friendly NPCs is off, so Blizzard draws their names with its own settings."
    end)
end

local function FriendlyRaidMarkerOn()
    return FriendlyAnyOn() and ns.Get("look.friendly.raidMarker.own") == true
end

local function FriendlyRaidMarkerReason()
    if not FriendlyAnyOn() then return FriendlyOffReason() end
    return "Turn on Place the raid icon separately to use this."
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
    return "Turn on Color by health remaining to use this."
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

local RETAIL_NAME_NOTE = Plateau.flavor ~= "forever" and " Works in the open world. Inside dungeons, raids and Mythic+ the game hides enemy names from addons, so they show in full there." or ""

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
    return "Turn on Show power percentage to use this."
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
    if ns.Get("look.classification.enabled") ~= true then return "Turn on Show classification icon to use this." end
    return "Turn on at least one of Elites, Rare elites, Rares or World bosses to use this."
end

local PREVIEW_CASTS = {
    { value = "normal", label = "Normal cast" },
    { value = "important", label = "Important cast" },
    { value = "cantInterrupt", label = "Uninterruptible cast" },
    { value = "importantStop", label = "Important, uninterruptible (CC required)" },
    { value = "kickCooldown", label = "Interrupt on cooldown" },
    { value = "interrupted", label = "Interrupted" },
}

local PREVIEW_ENEMIES = {
    { value = "caster", label = "Caster" },
    { value = "boss", label = "Boss" },
    { value = "lieutenant", label = "Lieutenant" },
    { value = "higher", label = "Elite" },
    { value = "elite", label = "Melee enemy" },
    { value = "trivial", label = "Minor enemy" },
    { value = "enemyPlayer", label = "Enemy player" },
    { value = "neutral", label = "Neutral enemy" },
    { value = "tapped", label = "Tapped by another player" },
}

local PREVIEW_THREAT = {
    { value = "none", label = "No threat color" },
    { value = "bad", label = "Has aggro" },
    { value = "warning", label = "Losing aggro" },
    { value = "good", label = "Secure threat" },
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

local function GameExtras()
    local list = { { type = "Header", label = "Extras" } }
    local function Add(spec, cvar)
        if C_CVar.GetCVar(cvar) ~= nil then
            list[#list + 1] = spec
        end
    end
    Add(CVarToggle("UnitNameFocused", "Always show your target's name", "The name over your target's head shows even when names over heads are turned off above."), "UnitNameFocused")
    Add(CVarToggle("nameplateForceShowUnitName", "Always show names on Blizzard's plates", "Plates the game draws itself, like friendly plates in dungeons and raids, always include the unit's name."), "nameplateForceShowUnitName")
    Add(CVarToggle("nameplateShowAllPersonalAuras", "Show all your auras on the personal resource display", "Your own bar over your character shows every buff and debuff on you, not just the important ones. Needs Show personal resource display."), "nameplateShowAllPersonalAuras")
    Add(CVarToggle("SoftTargetIconEnemy", "Soft target icon: enemies", "Shows an icon over the enemy you are soft-targeting with action targeting or a controller."), "SoftTargetIconEnemy")
    Add(CVarToggle("SoftTargetIconFriend", "Soft target icon: friends", "Shows an icon over the friendly unit you are soft-targeting."), "SoftTargetIconFriend")
    Add(CVarToggle("SoftTargetIconInteract", "Soft target icon: interactable", "Shows an icon over the object or NPC you can interact with right now."), "SoftTargetIconInteract")
    Add(CVarSlider("SoftTargetNameplateSize", "Soft target icon size", 10, 40, 1, "How big the soft target icons are."), "SoftTargetNameplateSize")
    if #list == 1 then
        return {}
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
    return "Lines at " .. table.concat(values, ", ")
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
        { type = "Dropdown", path = path .. ".sort", label = "Sort order", options = AURA_SORT,
          tooltip = "How icons are ordered within the group. Your own auras always come first, then the rest by the choice here: expiring soonest first (permanent auras last), alphabetical, or the game's default order." },
        { type = "Slider", path = path .. ".maxDuration", label = "Maximum aura duration (seconds, 0 = off)", min = 0, max = 600, step = 5,
          tooltip = "Hides auras whose total duration is longer than this, not auras with a lot of time left. Permanent auras are hidden as soon as this is above 0. 0 turns the limit off. Works in dungeons and raids: the game does the check." },
        { type = "Note", label = "Spell lists are saved separately for each specialization. Switch specializations to edit its lists.", height = 24 },
        SpecSpellList(groupKey, "hide", "Hidden spells", "Empty: no spells excluded",
          "Spell IDs or names, separated by commas. Press Enter to save. A name matches every spell with that name. Hidden spells win if a spell is also in Allowed spells. Works in dungeons and raids for debuffs on enemies. For enemy buffs and important auras it only works in the open world, because the game hides which buff it is in dungeons and raids."),
        SpecSpellList(groupKey, "only", "Allowed spells", "Empty: all spells matching this group's filters are allowed",
          "When filled, only these spells are shown and every other spell in this group is hidden. Spell IDs or names, separated by commas. An allowed spell still has to pass this group's other filters and icon limits, so listing it cannot make an aura appear that would not show otherwise.")
    )
end

local function AuraLayoutControls(path)
    return List(
        { type = "Header", label = "Layout" },
        { type = "Dropdown", path = path .. ".side", label = "Position", options = AURA_SIDES,
          tooltip = "Which side of the nameplate this group of icons sits on." },
        { type = "Dropdown", path = path .. ".align", label = "Alignment", options = AURA_ALIGN,
          tooltip = "Only matters above or below the nameplate. Left starts the group at the bar's left end, Right at its right end (icons grow leftward with Automatic growth), and Center keeps the row centered over or under the bar however many icons show." },
        { type = "Dropdown", path = path .. ".grow", label = "Growth direction", options = AURA_GROW,
          tooltip = "Which way icons are added, and where the next row or column starts once a row is full. Automatic follows Position and Alignment: above or below, icons run right (left when Alignment is Right) and new rows stack up or down away from the bar; on the left, icons run left; on the right, icons run right, with new rows below." },
        { type = "Slider", path = path .. ".offsetX", label = "Horizontal offset", min = -80, max = 80,
          tooltip = "Nudges this group of icons left (negative) or right (positive)." },
        { type = "Slider", path = path .. ".offsetY", label = "Vertical offset", min = -80, max = 80,
          tooltip = "Nudges this group of icons down (negative) or up (positive)." },
        { type = "Slider", path = path .. ".size", label = "Icon size", min = 10, max = 48,
          tooltip = "How big each icon in this group is." },
        { type = "Dropdown", path = path .. ".shape", label = "Icon shape", options = AURA_SHAPES,
          tooltip = "Square shows the whole icon. Wide makes icons shorter (4 by 3) and Extra wide shorter still (about 8 by 5), cropping the top and bottom of the art to save vertical space." },
        { type = "Slider", path = path .. ".maxIcons", label = "Maximum icons", min = 1, max = 12,
          tooltip = "Caps how many icons this group ever shows at once, even if more apply." },
        { type = "Slider", path = path .. ".perRow", label = "Icons per row (or column)", min = 1, max = 12,
          tooltip = "How many icons fit before wrapping to a new row or column." },
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
          tooltip = "The dark clock-wipe over each icon as it runs out. Off leaves just the timer text." },
        { type = "Slider", path = path .. ".borderSize", label = "Icon border thickness", min = 0, max = 3,
          tooltip = "How thick the border around each icon is. 0 removes it." },
        Gate({ type = "Color", path = path .. ".borderColor", label = "Icon border color",
          tooltip = "The color of the border around each icon. Dispel-type colors, when on, draw over it." }, function() return (ns.Get(path .. ".borderSize") or 0) > 0 end, "Raise Icon border thickness above 0 to use this."),
        { type = "Toggle", path = path .. ".dispelBorder", label = "Use dispel-type border colors",
          tooltip = "Colors each icon's border by the aura's dispel type: Magic, curse, poison, disease and enrage each get their own color." }
    )
    if withPandemic then
        controls[#controls + 1] = { type = "Toggle", path = path .. ".pandemic", label = "Tint in the refresh window",
          tooltip = "Turns the icon red once refreshing it would carry the leftover time over (the pandemic window)." }
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
    local on, reason = On(path .. ".enabled"), "Turn on " .. showLabel .. " to use this."
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
        { type = "Header", label = "Text on every aura icon" },
        { type = "Dropdown", path = "look.auras.font", label = "Font", options = Fonts, unknown = "Custom font",
          tooltip = "The typeface used for the time-left and stack-count text on every aura icon." },
        { type = "Dropdown", path = "look.auras.outline", label = "Outline", options = OUTLINES,
          tooltip = "The dark edge drawn around the aura text, to keep it readable over any icon." },
        { type = "Toggle", path = "look.auras.shadow", label = "Drop shadow",
          tooltip = "Adds a soft dark shadow behind the aura text, on top of the outline." },
        { type = "Header", label = "Tooltips" },
        { type = "Toggle", path = "look.auras.tooltips", label = "Show the aura's tooltip on mouseover",
          tooltip = "Hovering an icon shows Blizzard's aura tooltip. Icons never catch clicks, so clicking still targets the enemy." },
        { type = "Toggle", path = "look.auras.tooltipsInCombat", label = "Also show tooltips in combat",
          tooltip = "Off hides aura tooltips specifically while you're in combat, so a crowded fight doesn't spam them as your mouse crosses icons." },
        { type = "Note", label = "In dungeons and raids Blizzard decides which auras land in each group; Plateau sets the size, look and placement. Icon size and text changes made mid-fight apply when combat ends.", height = 44 }
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
    "look.scaling.mouseoverGrow", "look.scaling.mouseoverScale", "look.scaling.friendlyScale", "look.scaling.smooth",
    "look.plate.followBlizzardSize", "look.plate.pixelPerfect",
}
local SIZE_CVARS = { "nameplateSize", "nameplateAuraScale", "nameplateMinScale", "nameplateMaxScale" }
local FADING_PATHS = { "look.range", "look.target.dimOthers", "look.target.dimCombatOnly", "look.target.dimSkipFriendly" }
local FADING_CVARS = { "nameplateOccludedAlphaMult", "nameplateMinAlpha", "nameplatePlayRemovalAnimation" }
local LAYERING_PATHS = { "look.scaling.castFront", "look.plate.stackSpace", "look.scaling.mouseoverFront", "look.plate.offsetY" }
local LAYERING_CVARS = { "nameplateStackingTypes", "nameplateOverlapV", "nameplateOverlapH", "nameplateMotionSpeed", "nameplateOtherAtBase" }
local CLICK_PATHS = { "look.plate.clickX", "look.plate.clickY", "look.plate.clickCastBar", "look.plate.clickOffsetY", "look.plate.clickThroughFriendly" }
local COMBAT_PATHS = { "look.scaling.combatEnabled", "look.scaling.combatScale", "look.scaling.idleScale", "look.idle" }
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
            { type = "Note", label = "Adjust Blizzard's nameplate settings. Plateau saves the previous values of settings you change here so they can be restored. Right-click a setting to restore its saved value. Reset this section or type /plt cvars restore to restore every setting Plateau changed. This puts back the values from before Plateau changed them, not Blizzard's defaults.", height = 44 },

            { type = "Header", label = "Other nameplate addons" },
            { type = "Conflicts" },

            { type = "Header", label = "Names over heads" },
            { type = "Note", label = "Names the game floats over characters (Blizzard's Names options). Nameplates are set under Which nameplates show.", height = 24 },
            CVarToggle("UnitNameOwn", "Show your name", "Floats your own character's name over your head."),
            NpcNames(),
            CVarToggle("UnitNameNonCombatCreatureName", "Show critter and companion names", "Names for non-combat critters, battle pets and companions."),
            CVarToggle("UnitNameFriendlyPlayerName", "Show friendly player names", "Names over friendly players' heads in the world."),
            CVarToggle("UnitNameFriendlyMinionName", "Show friendly minion names", "Names over friendly players' pets, totems and other minions."),
            CVarToggle("UnitNameEnemyPlayerName", "Show enemy player names", "Names over enemy players' heads in the world."),
            CVarToggle("UnitNameEnemyMinionName", "Show enemy minion names", "Names over enemy players' pets, totems and other minions."),

            { type = "Header", label = "Which nameplates show" },
            CVarToggle("nameplateShowAll", "Always show nameplates", "Off: nameplates only appear once you're in combat with an enemy. This controls nameplate visibility."),
            CVarToggle("nameplateShowEnemies", "Enemy nameplates", "The master switch for enemy nameplates. Off hides every one of them. This controls nameplate visibility."),
            Gate(CVarToggle("nameplateShowEnemyMinus", "Minor enemies", "Blizzard's weakest enemies, usually with a minus sign in their tooltip. This controls nameplate visibility."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyMinions", "Enemy minions", "Pets, totems and other minions belonging to enemy players or NPCs. This controls nameplate visibility, not the names over their heads."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyPets", "Enemy pets", "Hunter pets, warlock pets and other player-controlled pets on the enemy side. This controls nameplate visibility."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyGuardians", "Enemy guardians", "Temporary summoned helpers that fight for enemy units. This controls nameplate visibility."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            Gate(CVarToggle("nameplateShowEnemyTotems", "Enemy totems", "Shaman and other totems placed by enemies. This controls nameplate visibility."), EnemiesOn, "Turn on Enemy nameplates to use this."),
            { type = "Link", label = "Configure friendly nameplates on the Friendly nameplates page", target = { section = "friendly" } },
            CVarToggle("nameplateShowSelf", "Show personal resource display", "Shows a health/power bar over your own character. A separate Blizzard system from normal nameplates."),
            CVarSlider("nameplateMaxDistance", "Maximum nameplate distance (yards)", 10, 60, 1, "The farthest away, in yards, a unit can be and still show a nameplate."),

            { type = "Header", label = "Keeping nameplates on screen", collapsible = true, collapsed = true },
            CVarToggle("nameplateShowOffscreen", "Keep engaged enemies' nameplates on screen",
                "Pins the nameplate of an enemy that is in combat with you or your group to the edge of the screen while the enemy itself is off screen."),
            { type = "Dropdown", label = "Off-screen nameplates", options = RADIAL,
              get = function() return tonumber(CVars:Get("nameplateTargetRadialPosition")) or 0 end,
              set = function(value) CVars:Set("nameplateTargetRadialPosition", value) end,
              reset = function() CVars:Release("nameplateTargetRadialPosition") end,
              resetLabel = "Right-click to undo Plateau's change.",
              path = "cvar.nameplateTargetRadialPosition",
              tooltip = "Chooses whose off-screen nameplate is pinned around the edge of the screen: nobody, only your target, or everything you're fighting. Keep engaged enemies' nameplates on screen is a separate setting that applies to enemies in combat with you or your group." },
            CVarSlider("nameplateTopInset", "Top screen margin", 0, 0.3, 0.01, "Fraction of the screen height, measured down from the top edge, that nameplates can't enter (0.10 is 10% of the screen height). 12.1.5 brings this back."),
            CVarSlider("nameplateBottomInset", "Bottom screen margin", 0, 0.3, 0.01, "Fraction of the screen height, measured up from the bottom edge, that nameplates can't enter (0.10 is 10% of the screen height). 12.1.5 brings this back.")


        ), GameExtras()),
    },

    Page("size", "Size", SIZE_PATHS, SIZE_CVARS, List(
        { type = "Header", label = "Nameplate scale", first = true },
        { type = "Note", label = "Each nameplate uses the largest applicable scale from its enemy type, target, focus, or casting settings. Target, focus and casting scales do not stack with each other, but Combat scale, on the Out of combat page, multiplies the enemy type scale. These settings affect nameplates in the world; the preview uses the normal scale.", height = 44 },
        { type = "Header", label = "Enemy type scale" },
        { type = "Toggle", path = "look.scaling.enabled", label = "Scale by enemy type", wide = true,
          tooltip = "Uses the same enemy types as the Enemy types colors on the Health bar page. Sizes never stack: a plate uses the biggest of its enemy type scale, your target scale and the casting scale." },
        Gate({ type = "Slider", path = "look.scaling.boss", label = "Bosses", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for boss-type enemies. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.caster", label = "Casters", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for mana-using enemies. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.lieutenant", label = "Lieutenants", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for lieutenants. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.elite", label = "Melee enemies", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Elite enemies that aren't bosses, lieutenants or casters. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.higher", label = "Elites", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for elites at least one level above you. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        Gate({ type = "Slider", path = "look.scaling.trivial", label = "Minor enemies", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Also the catch-all for any normal enemy that doesn't fit any row above. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.enabled"), "Turn on Scale by enemy type to use this."),
        { type = "Header", label = "Target scale" },
        { type = "Toggle", path = "look.target.useBlizzardScale", label = "Use Blizzard target scaling",
          tooltip = "On: an enemy you target grows by Blizzard's own amount (1.2 by default). If the game's setting has been left at 1, which means no growth, Plateau puts it back to 1.2. Off: Blizzard's growth is turned off and the Custom target scale slider below decides instead." },
        Gate({ type = "Slider", path = "look.target.scale", label = "Custom target scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Scale applied to an enemy target's nameplate when Blizzard target scaling is disabled. Friendly targets are never enlarged. 1.00 is normal size, 1.20 is 20% larger." }, Off("look.target.useBlizzardScale"), "Not used while Use Blizzard target scaling is on."),
        { type = "Header", label = "Focus scale" },
        { type = "Toggle", path = "look.scaling.focusGrow", label = "Scale focus nameplate",
          tooltip = "Makes your focus target's nameplate bigger so it is easy to find in a pack." },
        Gate({ type = "Slider", path = "look.scaling.focusScale", label = "Focus scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Scale applied to your focus target's nameplate. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.focusGrow"), "Turn on Scale focus nameplate to use this."),
        { type = "Header", label = "Casting scale" },
        { type = "Toggle", path = "look.scaling.castPop", label = "Scale casting nameplates",
          tooltip = "Makes a casting enemy easier to spot in a pack. This grows the whole plate on every cast: the game hides which casts are important, so it can't be limited to them." },
        Gate({ type = "Slider", path = "look.scaling.castScale", label = "Casting scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Applies while the enemy is casting or channeling a spell, whichever is currently showing on its cast bar. Doesn't stack with the target or enemy type scale: a casting plate uses whichever is biggest, and Blizzard's own target scale counts too. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.castPop"), "Turn on Scale casting nameplates to use this."),


        { type = "Header", label = "Blizzard's nameplate size" },
        BaseSpec({ type = "Toggle", path = "look.plate.followBlizzardSize", label = "Use Blizzard nameplate sizing for enemies",
          tooltip = "On: Blizzard's Nameplate Size and Debuff Scale (Options > Nameplates) resize Plateau's enemy nameplates too, measured from Blizzard's defaults, so nothing changes until you move them. Off: enemy nameplates use only Plateau's own size settings, such as Width and Height on the Health bar page. Friendly nameplates always follow Blizzard's Nameplate Size, so they match the friendly nameplates the game draws in dungeons and raids. The preview always shows the normal size." }),
        CVarSlider("nameplateSize", "Nameplate size (Blizzard)", 1, 5, 1, "1 Small, 2 Medium, 3 Large, 4 Extra Large, 5 Huge. The same setting as Friendly player name size on the Friendly page: changing one changes the other."),
        CVarSlider("nameplateAuraScale", "Debuff scale (Blizzard)", 0.7, 1.4, 0.1, "Size of buff and debuff icons on the nameplates the game draws. Plateau's aura icons follow it only while Use Blizzard nameplate sizing for enemies is on."),

        { type = "Header", label = "Size by distance" },
        CVarSlider("nameplateMinScale", "Distant nameplate scale", 0.5, 1, 0.05, "How small a nameplate shrinks at Blizzard's max nameplate distance."),
        CVarSlider("nameplateMaxScale", "Nearby nameplate scale", 0.5, 1.5, 0.05, "How big a nameplate grows right next to you."),

        { type = "Header", label = "Extras" },
        { type = "Toggle", path = "look.plate.pixelPerfect", label = "Pixel-perfect borders",
          tooltip = "Draws borders, rings and glows in whole screen pixels at each nameplate's real size, so a 1 pixel border is exactly one pixel wide on every plate. Off draws them in interface units, which can look soft or uneven on scaled plates." },
        { type = "Toggle", path = "look.scaling.mouseoverGrow", label = "Scale mouseover nameplate",
          tooltip = "The enemy plate under your mouse grows. Doesn't stack with the other scales: the biggest one wins." },
        Gate({ type = "Slider", path = "look.scaling.mouseoverScale", label = "Mouseover scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Scale applied to the enemy plate under your mouse. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.mouseoverGrow"), "Turn on Scale mouseover nameplate to use this."),
        { type = "Slider", path = "look.scaling.friendlyScale", label = "Friendly nameplate scale", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for Plateau's friendly plates in the open world, on top of Blizzard's Nameplate Size. In dungeons and raids the game draws friendly plates itself." },
        { type = "Toggle", path = "look.scaling.smooth", label = "Smooth size changes",
          tooltip = "Plates grow and shrink over a moment instead of snapping when you target, focus, hover or an enemy starts casting. New plates still appear at full size." }
    )),

    Page("fading", "Fading", FADING_PATHS, FADING_CVARS, List(
        { type = "Header", label = "Range fading", first = true },
        { type = "Toggle", path = "look.range.enabled", label = "Fade nameplates outside interrupt range",
          tooltip = "Checked four times a second against your class interrupt, so faded plates are the ones you can't interrupt from where you stand." },
        Gate({ type = "Slider", path = "look.range.alpha", label = "Out-of-range opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "How see-through a nameplate gets once its enemy is out of your interrupt range. Lower values are more transparent. Checked four times a second against your class/spec's currently known interrupt spell; if you have none available, nameplates never fade." }, On("look.range.enabled"), "Turn on Fade nameplates outside interrupt range to use this."),

        { type = "Header", label = "Plates you are not targeting" },
        { type = "Slider", path = "look.target.dimOthers", label = "Non-target opacity (dim others)", keywords = "dim dimming dimmed fade faded other plates nameplates friendly transparent", min = 0.2, max = 1, step = 0.05,
          tooltip = "How visible every other nameplate is while you have a target on a nameplate. 1 leaves them alone; lower values fade them so your target stands out. Clearing your target puts them back to normal right away. It stacks with range fading, so plates that are also out of range end up fainter." },

        { type = "Header", label = "Behind walls" },
        CVarSlider("nameplateOccludedAlphaMult", "Occluded nameplate opacity", 0, 1, 0.05, "Opacity multiplier for the nameplate of a unit hidden behind terrain or objects. 1 leaves it unchanged; lower values make it more see-through."),
        { type = "Note", label = "Choose where the opacity above applies. Turn a place off to keep nameplates behind walls fully visible there.", height = 24 },
        { type = "Toggle", label = "Fade in the open world", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("world") end,
          set = function(value) Plateau.OccludedFade:SetOn("world", value == true) end,
          tooltip = "Off: nameplates behind walls stay fully visible in the open world. Occluded nameplate opacity still applies wherever this is on. This switches Blizzard's setting as you change zones and puts your value back when you leave." },
        { type = "Toggle", label = "Fade in dungeons", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("dungeon") end,
          set = function(value) Plateau.OccludedFade:SetOn("dungeon", value == true) end,
          tooltip = "Off: nameplates behind walls stay fully visible in dungeons, including Mythic+. Occluded nameplate opacity still applies wherever this is on. This switches Blizzard's setting as you change zones and puts your value back when you leave." },
        { type = "Toggle", label = "Fade in raids", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("raid") end,
          set = function(value) Plateau.OccludedFade:SetOn("raid", value == true) end,
          tooltip = "Off: nameplates behind walls stay fully visible in raids. Occluded nameplate opacity still applies wherever this is on. This switches Blizzard's setting as you change zones and puts your value back when you leave." },
        { type = "Toggle", label = "Fade in delves and scenarios", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("delve") end,
          set = function(value) Plateau.OccludedFade:SetOn("delve", value == true) end,
          tooltip = "Off: nameplates behind walls stay fully visible in delves and scenarios. Occluded nameplate opacity still applies wherever this is on. This switches Blizzard's setting as you change zones and puts your value back when you leave." },
        { type = "Toggle", label = "Fade in battlegrounds and arenas", visibleIf = function() return Plateau.OccludedFade ~= nil end,
          get = function() return Plateau.OccludedFade ~= nil and Plateau.OccludedFade:IsOn("pvp") end,
          set = function(value) Plateau.OccludedFade:SetOn("pvp", value == true) end,
          tooltip = "Off: nameplates behind walls stay fully visible in battlegrounds and arenas. Occluded nameplate opacity still applies wherever this is on. This switches Blizzard's setting as you change zones and puts your value back when you leave." },
        { type = "Dropdown", path = "look.range.gameFade", label = "Fade hidden nameplates for",
          options = { { value = "both", label = "Enemies and friendly" }, { value = "enemy", label = "Enemies only" }, { value = "friendly", label = "Friendly only" } },
          tooltip = "Which nameplates take the game's fading. The game reports one opacity per nameplate that covers both behind walls and by distance, so a type you leave out ignores both. Plateau's own fading (range, non-target, out of combat) still applies to every type." },

        { type = "Header", label = "By distance" },
        CVarSlider("nameplateMinAlpha", "Distant nameplate opacity", 0, 1, 0.05, "How see-through a nameplate gets at Blizzard's max nameplate distance."),

        { type = "Header", label = "Disappearing nameplates" },
        CVarToggle("nameplatePlayRemovalAnimation", "Fade out disappearing nameplates", "Off: a nameplate vanishes instantly instead of fading."),

        { type = "Header", label = "Extras" },
        Gate({ type = "Toggle", path = "look.target.dimCombatOnly", label = "Dim others only in combat",
          tooltip = "Non-target opacity only applies while you're in combat." }, DimsOthers, "Lower Non-target opacity below 1 to use this."),
        Gate({ type = "Toggle", path = "look.target.dimSkipFriendly", label = "Don't dim friendly plates",
          tooltip = "Non-target opacity only fades enemy plates." }, DimsOthers, "Lower Non-target opacity below 1 to use this."),
        { type = "Toggle", path = "look.range.mouseoverFull", label = "Keep mouseover at full opacity",
          tooltip = "The plate under your mouse ignores Non-target opacity and range fading, so you can always read it." }
    )),

    Page("layering", "Layering and stacking", LAYERING_PATHS, LAYERING_CVARS, List(
        { type = "Header", label = "Nameplate layering", first = true },
        { type = "Toggle", path = "look.scaling.castFront", label = "Casting enemies in front", wide = true,
          keywords = "layering priority order caster casters cast in front draw over overlap",
          tooltip = "An enemy that is casting right now draws over the plates around it, so you can see the cast in a stack. Your target stays above casting enemies. Off: the game's own order, nearer plates over farther ones with your target on top. Mouseover in front (under Extras) beats both." },

        { type = "Header", label = "Stacking" },
        Gate({ type = "Presets", presets = STACK_PRESETS, wide = true, label = "Stacking presets", keywords = "tight balanced spread out spacing overlap crowded stack",
          tooltip = "Ready-made spacing between stacked plates: Tight, Balanced or Spread out. One is always underlined." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        { type = "Note", label = "Click a preset, then click it again within 3 seconds to apply it. The underlined preset is the one in use. Presets change only the spacing between plates.", height = 32 },
        CVarBitToggle("nameplateStackingTypes", STACK.Enemy, "Stack enemy nameplates", "On: enemy nameplates push apart so they don't overlap. Off: they sit over each enemy and can overlap."),
        Gate({ type = "Toggle", label = "Show stacking boxes",
          get = function() return ns.stackBoxesOn == true end,
          set = function(value)
              ns.stackBoxesOn = value
              Plateau.SetStackBoxes(value)
          end,
          tooltip = "Draws each nameplate's stacking box in orange on real nameplates: the area the game keeps apart from other nameplates when it stacks them. Change Stacking bounds or the spacing sliders and watch it react. It stays on after you close this window, so you can watch it in combat, until you turn it off or /reload." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        CVarBitToggle("nameplateStackingTypes", STACK.Friendly, "Stack friendly nameplates", "On: friendly nameplates push apart so they don't overlap. Off: they sit over each unit and can overlap."),

        { type = "Header", label = "Stacking bounds and spacing" },
        Gate({ type = "Dropdown", label = "Stacking bounds", options = STACK_SPACES,
          get = function() return Plateau.DB:Get("look.plate.stackSpace") end,
          set = function(value) Plateau.DB:Set("look.plate.stackSpace", value) end,
          tooltip = "How much of each nameplate counts as its size when stacking: the health bar only, the bar and name, the bar and cast bar, the bar, name and cast bar, or everything including buffs and debuffs. Bigger bounds keep more space between neighbors, but big pulls spread further up the screen." }, StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        Gate(CVarSlider("nameplateOverlapV", "Vertical spacing", 0.3, 2, 0.05, "The vertical space kept between stacked nameplates, as a multiplier. Higher spreads them further apart; lower brings them closer together."), StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),
        Gate(CVarSlider("nameplateOverlapH", "Horizontal spacing", 0.3, 2, 0.05, "The side-to-side space kept between stacked nameplates, as a multiplier. Higher spreads them further apart; lower brings them closer together."), StackingOn, "Turn on Stack enemy or Stack friendly nameplates to use this."),

        { type = "Note", warn = true, height = 32,
          visibleIf = function()
              local space = ns.Get("look.plate.stackSpace")
              return space == "cast" or space == "barcast" or space == "all"
          end,
          label = "These stacking bounds keep room for a cast bar on every plate, casting or not, so big pulls stack much higher up the screen. Health bar only or Health bar and name keep pulls tighter." },

        { type = "Header", label = "Movement" },
        InstantMovement(),
        CVarSlider("nameplateMotionSpeed", "Movement speed", 0, 1, 0.01, "How quickly nameplates slide to their new spot when stacking: 0 is slowest and 1 is instant. Higher snaps faster. 12.1.5 brings this back."),
        CVarToggle("nameplateOtherAtBase", "Position nameplates at feet", "Moves other units' nameplates down to ground level instead of floating above their heads."),

        { type = "Header", label = "Extras" },
        { type = "Toggle", path = "look.scaling.mouseoverFront", label = "Mouseover in front",
          tooltip = "The plate under your mouse is drawn above every other plate, so you can read it in a stack. Beats Casting enemies in front and your target." },
        BaseSpec({ type = "Slider", path = "look.plate.offsetY", label = "Nameplate height (up or down)", min = -60, max = 60,
          tooltip = "Draws Plateau's nameplates higher (positive) or lower (negative) than where the game places them over each unit. The click area moves with them. Stacking still uses the game's position, so plates keep the same spacing between each other. Blizzard's own plates, like friendly plates in dungeons, don't move." })
    )),

    Page("clicking", "Clickable area", CLICK_PATHS, nil, List(
        { type = "Header", label = "Clickable area", first = true },
        { type = "Toggle", label = "Show clickable areas",
          get = function() return ns.clickAreasOn == true end,
          set = function(value)
              ns.clickAreasOn = value
              ns.UpdateClickAreas()
          end,
          tooltip = "Draws the click box on the preview and on real nameplates so you can see exactly where a click lands. It turns itself off when you close this window." },
        BaseSpec({ type = "Slider", path = "look.plate.clickX", label = "Horizontal padding", min = 0, max = 30,
          tooltip = "Extend the clickable area to the left and right of the nameplate. Makes plates easier to click without making them bigger. Same for every nameplate type. Applies to new plates; in combat Blizzard only lets it change as a plate appears." }),
        BaseSpec({ type = "Slider", path = "look.plate.clickY", label = "Vertical padding", min = 0, max = 30,
          tooltip = "Extend the clickable area above and below the nameplate. Makes plates easier to click without making them bigger. Same for every nameplate type." }),
        BaseSpec({ type = "Toggle", path = "look.plate.clickCastBar", label = "Include cast bar in clickable area",
          tooltip = "Extend the clickable area to include the cast bar. Clicking it then targets that enemy too. Same for every nameplate type." }),
        BaseSpec({ type = "Slider", path = "look.plate.clickOffsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Slides the whole clickable area up (positive values) or down (negative values) without changing its size. Up covers the name above the bar; down covers the cast bar." }),
        { type = "Note", label = "Enable Show clickable areas to display the clickable bounds on the preview and in-world nameplates.", height = 24 },

        { type = "Header", label = "Extras" },
        BaseSpec({ type = "Toggle", path = "look.plate.clickThroughFriendly", label = "Click-through friendly plates",
          tooltip = "Plateau's friendly plates stop catching clicks, so you can click the world or the character behind them. The game only allows this change out of combat; a change made in combat applies when it ends." })
    )),

    Page("combat", "Out of combat", COMBAT_PATHS, nil, List(
        { type = "Header", label = "Combat scale", first = true },
        { type = "Toggle", path = "look.scaling.combatEnabled", label = "Scale by combat state",
          tooltip = "Makes enemies that are fighting someone bigger or smaller than enemies that are not. This multiplies with the enemy type scale, so a boss stays bigger than trash in both states. Players and friendly plates are not affected." },
        Gate({ type = "Slider", path = "look.scaling.combatScale", label = "In combat", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for an enemy that is in combat with anyone, including your group. 1.00 is normal size, 1.20 is 20% larger." }, On("look.scaling.combatEnabled"), "Turn on Scale by combat state to use this."),
        Gate({ type = "Slider", path = "look.scaling.idleScale", label = "Out of combat", min = 0.5, max = 1.6, step = 0.05,
          tooltip = "Size multiplier for an enemy that is not in combat. 1.00 is normal size, 0.80 is 20% smaller." }, On("look.scaling.combatEnabled"), "Turn on Scale by combat state to use this."),
        { type = "Header", label = "Out-of-combat plates" },
        { type = "Toggle", path = "look.idle.enabled", label = "Customize out-of-combat plates",
          tooltip = "Gives enemies that are not in combat their own look, so the ones fighting stand out. Your current target is never changed, and neither are players or friendly plates. Combat scale above still sets their size; the width and height here stack on top of it." },
        Gate({ type = "Slider", path = "look.idle.alpha", label = "Opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "How solid an out-of-combat plate is. Lower values fade it so plates in combat stand out." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Slider", path = "look.idle.widthScale", label = "Bar width", min = 0.5, max = 1.5, step = 0.05,
          tooltip = "Width of an out-of-combat plate compared to normal. 1.00 is normal, 0.80 is 20% narrower." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Slider", path = "look.idle.heightScale", label = "Bar height", min = 0.5, max = 1.5, step = 0.05,
          tooltip = "Height of an out-of-combat plate compared to normal. 1.00 is normal, 0.80 is 20% shorter." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "ToggleColor", path = "look.idle.colorBar", colorPath = "look.idle.color", label = "Use one bar color",
          tooltip = "Colors every out-of-combat health bar this color, ignoring enemy type, threat and quest colors. They switch back as soon as the enemy enters combat." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        { type = "Header", label = "Show when out of combat" },
        Gate({ type = "Toggle", path = "look.idle.show.auras", label = "Auras",
          tooltip = "Shows your debuffs, crowd control, enemy buffs and important auras on out-of-combat plates. Off hides them until the enemy enters combat." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.healthText", label = "Health text",
          tooltip = "Shows the health number or percent on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.name", label = "Name",
          tooltip = "Shows the enemy name on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.level", label = "Level",
          tooltip = "Shows the level on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.classification", label = "Elite icon",
          tooltip = "Shows the elite, rare and boss icon on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.raidMarker", label = "Raid target icon",
          tooltip = "Shows the raid marker on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.quest", label = "Quest icon",
          tooltip = "Shows the quest marker on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.forces", label = "Mythic+ enemy forces",
          tooltip = "Shows the enemy forces value on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.enemyPower", label = "Enemy power bar",
          tooltip = "Shows the mana or energy bar on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.enemyTarget", label = "Enemy target name",
          tooltip = "Shows who the enemy is targeting on out-of-combat plates." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),
        Gate({ type = "Toggle", path = "look.idle.show.castbar", label = "Cast bar",
          tooltip = "Shows the cast bar on out-of-combat plates, for casts before a pull or from patrols." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this."),

        { type = "Header", label = "Extras" },
        Gate({ type = "Toggle", path = "look.idle.instancesOnly", label = "Only in dungeons and raids",
          tooltip = "The out-of-combat look only applies inside dungeons, raids and delves, so open-world enemies look normal." }, On("look.idle.enabled"), "Turn on Customize out-of-combat plates to use this.")
    )),

    Section("health", "Health bar", { "look.health", "look.execute", "look.bossPhases", "look.plate.width", "look.plate.height", "look.shield.absorbs", "look.shield.absorbColor", "look.shield.absorbStyle", "look.shield.absorbPosition", "look.shield.absorbGlow", "look.colors.tapped", "look.colors.showTapped", "look.colors.healthGradient", "look.colors.healthLow", "look.colors.healthFade", "look.colors.customReaction", "look.colors.hostile", "look.colors.neutral", "look.colors.friendly", "look.colors.classColors", "look.colors.mobTypes", "look.colors.mobTypesInstancesOnly", "look.colors.boss", "look.colors.bossColor", "look.colors.lieutenant", "look.colors.lieutenantColor", "look.colors.higher", "look.colors.higherColor", "look.colors.caster", "look.colors.casterColor", "look.colors.elite", "look.colors.eliteColor", "look.colors.trivial", "look.colors.trivialColor", "look.colors.threat", "look.colors.showThreatGood", "look.colors.showThreatWarning", "look.colors.threatGood", "look.colors.threatWarning", "look.colors.threatDisplay", "look.colors.threatBad" }, List(
        { type = "Header", label = "Size", first = true },
        { type = "Slider", path = "look.plate.width", label = "Width", min = 60, max = 300,
          tooltip = "How wide every plate is. The cast bar follows this width. 140 fits most names without cutting them off." },
        { type = "Slider", path = "look.plate.height", label = "Height", min = 4, max = 40,
          tooltip = "Thicker bars are easier to read in a big pull; thinner ones overlap less." },

        { type = "Header", label = "Bar" },
        { type = "Dropdown", path = "look.health.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "The fill texture for the health bar. Your target and focus can have their own texture and overlay pattern on the My target and My focus pages; those replace this one on those plates." },
        { type = "Dropdown", path = "look.health.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Layers a Plateau checker or line pattern on top of the bar texture above, tinted to match its color. No overlay shows the texture alone." },
        Gate({ type = "Slider", path = "look.health.overlayAlpha", label = "Overlay strength", min = 0, max = 1, step = 0.05,
          tooltip = "How strong the overlay pattern shows on top of the bar texture." }, Chosen("look.health.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.health.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "How different the pattern's light and dark parts are from each other, separate from how strongly the whole pattern shows. 0 is flat, 1 is the sharpest the pattern gets." }, Chosen("look.health.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Color", path = "look.health.background", label = "Background color",
          tooltip = "Color of the unfilled portion of the health bar." },
        { type = "Dropdown", path = "look.health.borderStyle", label = "Border style", options = BorderStyles, unknown = "Custom border",
          tooltip = "Tooltip styles have rounded corners, so they look squashed on very thin bars; raise the bar height or use Thin tooltip. The border color tints the art, so light colors show it best." },
        { type = "Color", path = "look.health.border", label = "Border color", set = BorderColorSetter("look.health"),
          tooltip = "The color of the border drawn around the health bar. Picking a color while the style is No border or the thickness is 0 turns on a 1 pixel border so you can see it. Click Okay in the color picker to keep a color; clicking outside it or pressing Escape cancels." },
        Gate({ type = "Slider", path = "look.health.borderSize", label = "Border thickness", min = 0, max = 4,
          tooltip = "How thick the border is." }, BorderOn, "Choose a border style to use this."),
        Gate({ type = "Toggle", path = "look.health.borderInside", label = "Draw border inside",
          tooltip = "Draw the border within the health bar's edges. Off wraps it around the outside instead. Target, mouseover and buff warning borders follow." }, BorderOn, "Choose a border style to use this."),

        { type = "Header", label = "Absorbs" },
        { type = "ToggleColor", path = "look.shield.absorbs", colorPath = "look.shield.absorbColor", label = "Show absorbs",
          tooltip = "How much damage the enemy's absorb shield will soak before its health goes down." },
        Gate({ type = "Dropdown", path = "look.shield.absorbPosition", label = "Absorb position", options = ABSORB_POSITIONS,
          tooltip = "Over the bar from the right always shows the whole shield, even on an enemy at full health. After health is Blizzard's style: the shield fills the missing health, and a glow at the end of the bar shows when it's bigger than that." }, On("look.shield.absorbs"), "Turn on Show absorbs to use this."),
        Gate({ type = "Toggle", path = "look.shield.absorbGlow", label = "Show absorb overflow glow",
          tooltip = "Show a glow at the end of the health bar when absorbs extend beyond the bar." }, function() return ns.Get("look.shield.absorbs") == true and ns.Get("look.shield.absorbPosition") == "after" end, "Needs Show absorbs on and Absorb position set to After health."),
        Gate({ type = "Dropdown", path = "look.shield.absorbStyle", label = "Absorb texture", options = AbsorbStyles, unknown = "Custom texture",
          tooltip = "Blizzard is the game's own look: a soft fill with diagonal stripes. The Plateau lines and any bar texture work too; the color swatch tints it." }, On("look.shield.absorbs"), "Turn on Show absorbs to use this."),

        { type = "Header", label = "Execute indicator" },
        { type = "ToggleColor", path = "look.execute.highlight", colorPath = "look.execute.color", label = "Color health bar below execute threshold",
          tooltip = "Tints any enemy's health bar once its health drops below the Execute threshold set just below (20% unless you change it). It works the same for every class and spec and doesn't know your execute spells, so set the threshold to match yours. The marker lines further down are separate and don't move where the tint starts. The tint is drawn over any overlay pattern. Works in dungeons and raids: the game compares the health, Plateau never reads it." },
        Gate({ type = "Slider", path = "look.execute.threshold", label = "Execute threshold (%)", min = 1, max = 90,
          tooltip = "Health percentage below which the execute color is applied." }, On("look.execute.highlight"), "Turn on Color health bar below execute threshold to use this."),
        { type = "Header", label = "Health threshold markers" },
        { type = "ToggleColor", path = "look.execute.lines", colorPath = "look.execute.lineColor", label = "Show health threshold markers",
          tooltip = "Show markers at the specified health percentages. Set a marker to 0 to hide it." },
        Gate({ type = "Slider", path = "look.execute.line1", label = "First marker (%, 0 = off)", min = 0, max = 99,
          tooltip = "Health percent for the first marker line. 0 turns it off." }, On("look.execute.lines"), "Turn on Show health threshold markers to use this."),
        Gate({ type = "Slider", path = "look.execute.line2", label = "Second marker (%, 0 = off)", min = 0, max = 99,
          tooltip = "Health percent for the second marker line. 0 turns it off." }, On("look.execute.lines"), "Turn on Show health threshold markers to use this."),
        Gate({ type = "Slider", path = "look.execute.lineWidth", label = "Marker thickness", min = 1, max = 4,
          tooltip = "How thick the marker lines are." }, On("look.execute.lines"), "Turn on Show health threshold markers to use this."),

        { type = "Header", label = "Boss phase lines" },
        { type = "ToggleColor", path = "look.bossPhases.enabled", colorPath = "look.bossPhases.color", label = "Show boss phase lines",
          tooltip = "Draws lines on boss health bars where the fight changes phase. During a boss fight Plateau knows which boss it is and uses that boss's percentages; other bosses use the default lines below." },
        Gate({ type = "Slider", path = "look.bossPhases.lineWidth", label = "Phase line thickness", min = 1, max = 4,
          tooltip = "How thick the boss phase lines are." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Dropdown", label = "Boss", options = BossOptions,
          get = function() return selectedBoss end,
          set = function(value) selectedBoss = value end,
          tooltip = "Pick a boss to see or change its phase lines. Bosses you have fought that aren't in the list appear at the bottom." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Add a boss by encounter ID", empty = "Type an encounter ID, then a name if you like: 2654 Ara-Kara boss",
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
              if not id then return "Type an encounter ID, then a name if you like: 2654 Ara-Kara boss" end
              return "Press Enter to add encounter " .. id .. (name ~= "" and (" (" .. name .. ")") or "") .. " and pick it above"
          end,
          tooltip = "Adds a boss you haven't fought yet so you can set its lines now. Encounter IDs are listed on sites like Wowhead (search the boss, look for Encounter ID). Bosses you fight are added on their own." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Phase lines for this boss", empty = "No lines for this boss",
          suffix = function() return BossName(selectedBoss) end,
          get = function() return Plateau.BossPhaseLines and Plateau.BossPhaseLines(selectedBoss) or "" end,
          set = function(value) if Plateau.SetBossPhaseLines then Plateau.SetBossPhaseLines(selectedBoss, value) end end,
          reset = function() if Plateau.SetBossPhaseLines then Plateau.SetBossPhaseLines(selectedBoss, nil) end end,
          describe = DescribeLines,
          tooltip = "Health percentages, separated by commas, up to four, like 70, 40. Press Enter to save. Right-click to go back to Plateau's built-in percentages. Saved for your whole account." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Dropdown", label = "Draw this boss's lines on", options = BOSS_TARGETS,
          get = function() return Plateau.BossPhaseTarget and Plateau.BossPhaseTarget(selectedBoss) or "boss" end,
          set = function(value) if Plateau.SetBossPhaseTarget then Plateau.SetBossPhaseTarget(selectedBoss, value) end end,
          tooltip = "Bosses: only plates Plateau treats as a boss. Every enemy in the fight: all enemy plates while this encounter runs, for fights where the phase is on an add or pet, like Kystia Manaheart's Nibbles. The game hides which enemy is which in keys, so Plateau can't pick out just the pet." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "SpellList", label = "Default lines on other bosses", empty = "No default lines",
          get = function() return ns.Get("look.bossPhases.defaults") or "" end,
          set = function(value) ns.Set("look.bossPhases.defaults", value) end,
          reset = function() Plateau.DB:Reset("look.bossPhases.defaults") end,
          describe = DescribeLines,
          tooltip = "Lines for bosses without their own percentages, and for boss plates outside a boss fight. Health percentages separated by commas, up to four." }, On("look.bossPhases.enabled"), BOSS_ON),
        Gate({ type = "Toggle", path = "look.bossPhases.instancesOnly", label = "Default lines only in dungeons and raids",
          tooltip = "Keeps the default lines off open-world bosses." }, On("look.bossPhases.enabled"), BOSS_ON),
        { type = "Note", label = "Built-in percentages come from Season 2 guides. Sources disagree on The Hoardmonger and Adderis and Aspix, so check those in game. Most bosses change phase on energy or timers and have no lines.", height = 44 },

        { type = "Header", label = "Bar extras" },
        { type = "Toggle", path = "look.health.smooth", label = "Smooth health changes",
          tooltip = "The bar slides to its new value instead of jumping. A new plate always starts at the right value." },
        { type = "Dropdown", path = "look.health.fillDirection", label = "Fill direction", options = FILL_DIRECTIONS,
          tooltip = "Which way the health bar fills. Absorbs, the overflow glow, the execute color and the threshold markers follow it." },
        { type = "ToggleColor", path = "look.health.spark", colorPath = "look.health.sparkColor", label = "Health spark",
          tooltip = "A thin bright line at the edge of the health fill, so the exact amount is easy to read. Hidden at full and empty health." },
        Gate({ type = "Slider", path = "look.health.sparkWidth", label = "Spark thickness", min = 1, max = 8,
          tooltip = "How wide the health spark line is." }, On("look.health.spark"), "Turn on Health spark to use this."),
        { type = "Toggle", path = "look.health.desaturate", label = "Plain texture tint",
          tooltip = "Removes the bar texture's own color so the bar shows your colors exactly. Helps with colored textures such as the Blizzard bars; flat textures look the same either way." },
        { type = "Dropdown", path = "look.health.backgroundTexture", label = "Background texture", options = BackgroundBars, unknown = "Custom texture",
          tooltip = "Texture for the empty part of the bar, tinted by Background color. Flat color uses the color alone." },
        { type = "Toggle", path = "look.colors.healthGradient", label = "Color by health remaining",
          tooltip = "Enemies keep the color they would normally have (reaction, enemy type, threat, quest, target or focus color) at full health and fade toward the low-health color as they lose health. Colors the game hides from addons, like some class colors, stay as they are. Not used on friendly plates." },
        Gate({ type = "Color", path = "look.colors.healthLow", label = "Low health color",
          tooltip = "The color health bars fade toward as health runs out. Dark colors work like a shadow; bright ones like a warning." }, On("look.colors.healthGradient"), "Turn on Color by health remaining to use this."),
        Gate({ type = "Slider", path = "look.colors.healthFade", label = "Fade strength", min = 0.1, max = 1, step = 0.05,
          tooltip = "How far the color moves toward the low-health color by the time health is empty. 1 reaches it fully." }, On("look.colors.healthGradient"), "Turn on Color by health remaining to use this."),

        { type = "Header", label = "Colorblind presets" },
        { type = "Presets", presets = Plateau.presets.palettes },
        { type = "Note", label = "Color priority: Target or focus overrides (when enabled) beat everything. Then Tapped, then Threat (if enabled), then Quest enemies (if enabled) - which overrides enemy type and reaction colors below even though it's listed after them - then enemy type or class color, then Reaction as the fallback.", height = 60 },

        { type = "Header", label = "Tapped enemies" },
        { type = "ToggleColor", path = "look.colors.showTapped", colorPath = "look.colors.tapped", label = "Tapped by another player",
          tooltip = "The game's own tap-denial flag: another player (or their group) engaged this enemy first, so you won't get loot or quest credit from it." },

        { type = "Header", label = "Threat" },
        { type = "ToggleColor", path = "look.colors.threat", colorPath = "look.colors.threatBad", label = "Enable threat colors",
          tooltip = "The master switch for all threat coloring below. This color itself is the bad/wrong-aggro state: for a tank, an enemy you don't have; for damage or a healer, an enemy that has you. Only checked in combat." },
        Gate({ type = "Dropdown", path = "look.colors.threatDisplay", label = "Threat color display", options = THREAT_DISPLAY,
          tooltip = "Where threat colors show: the health bar fill, its border, or both. With the border, the bar keeps its normal color and only the outline warns you." }, On("look.colors.threat"), "Turn on Enable threat colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.showThreatWarning", colorPath = "look.colors.threatWarning", label = "Threat transition color",
          tooltip = "A middle state between safe and bad. For a tank: you're about to lose the enemy to someone else, or about to pull it without meaning to. For damage or a healer: your threat is climbing toward pulling aggro, but hasn't yet. Off skips straight from safe to the bad color." }, On("look.colors.threat"), "Turn on Enable threat colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.showThreatGood", colorPath = "look.colors.threatGood", label = "Secure threat color",
          tooltip = "The safe state. For a tank: you securely have the enemy, or another tank in your group does. For damage or a healer: the enemy isn't a threat risk for you right now - it doesn't have to be attacking you specifically. Off leaves these enemies with their normal color instead." }, On("look.colors.threat"), "Turn on Enable threat colors to use this."),

        { type = "Header", label = "Enemy players" },
        { type = "Toggle", path = "look.colors.classColors", label = "Use class colors for enemy players",
          tooltip = "Colors enemy players' health bars by their class instead of a flat reaction color." },

        { type = "Header", label = "Enemy types" },
        { type = "Toggle", path = "look.colors.mobTypes", label = "Use enemy type colors",
          tooltip = "Turns on the type rows below: bosses, casters, lieutenants and so on each get their own color. An enemy matching more than one type uses whichever is highest in this list, skipping any type whose own color is switched off: Bosses, Lieutenants, Elites, Minor enemies, Casters, Melee enemies. The rows below are laid out in a different order." },
        Gate({ type = "Toggle", path = "look.colors.mobTypesInstancesOnly", label = "Only in dungeons, raids, and delves",
          tooltip = "Keeps type colors out of the open world, where every enemy just uses its reaction color instead." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.boss", colorPath = "look.colors.bossColor", label = "Bosses",
          tooltip = "Enemies flagged as bosses, including world bosses." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.caster", colorPath = "look.colors.casterColor", label = "Casters",
          tooltip = "Enemies that use mana." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.lieutenant", colorPath = "look.colors.lieutenantColor", label = "Lieutenants",
          tooltip = "An elite above your level that also has more health than usual, or any elite two or more levels above you. Real bosses keep the Bosses color." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.elite", colorPath = "look.colors.eliteColor", label = "Melee enemies",
          tooltip = "Elites at your level." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.higher", colorPath = "look.colors.higherColor", label = "Elites",
          tooltip = "Elites above your level." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),
        Gate({ type = "ToggleColor", path = "look.colors.trivial", colorPath = "look.colors.trivialColor", label = "Minor enemies",
          tooltip = "Weak enemies, plus most ordinary trash at your level." }, On("look.colors.mobTypes"), "Turn on Use enemy type colors to use this."),

        { type = "Header", label = "Reaction colors" },
        { type = "Toggle", path = "look.colors.customReaction", label = "Use custom reaction colors",
          tooltip = "Off uses the game's own reaction colors. The swatches start at the game's colors; right-click one to go back. This is the lowest-priority color - anything covered by threat, quest, class, or enemy type colors above uses those instead." },
        Gate({ type = "Color", path = "look.colors.hostile", label = "Hostile",
          tooltip = "Color for enemies hostile to you, when not overridden by a type or threat color." }, On("look.colors.customReaction"), "Use custom reaction colors is off, so these use the game's own reaction colors."),
        Gate({ type = "Color", path = "look.colors.neutral", label = "Neutral",
          tooltip = "Color for neutral units that aren't attacking you." }, On("look.colors.customReaction"), "Use custom reaction colors is off, so these use the game's own reaction colors."),
        Gate({ type = "Color", path = "look.colors.friendly", label = "Friendly",
          tooltip = "Color for friendly units, when Use custom reaction colors is on." }, On("look.colors.customReaction"), "Use custom reaction colors is off, so these use the game's own reaction colors.")
    )),

    Friendly("friendly", "Friendly nameplates", "look.friendly", Join(List(
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
          tooltip = "Off leaves friendly plates to Blizzard. Turning it off takes full effect after /reload." },
        Style.Limited(FriendlyToggle("look.friendly.players", "nameplateShowFriendlyPlayers", "Friendly players"), "friendly"),
        Style.Limited(FriendlyToggle("look.friendly.npcs", "nameplateShowFriendlyNpcs", "Friendly NPCs"), "friendly"),
        Style.Limited(Gate({
            type = "Toggle",
            label = "Friendly pets and minions",
            tooltip = "Pets, totems and other minions that belong to a friendly player. Off hides their plates completely, including the game's own. Follower dungeon companions are not affected. Takes effect after a /reload.",
            get = function() return ns.Get("look.friendly.minions") == true end,
            set = function(value)
                Plateau.DB:Set("look.friendly.minions", value == true)
                ns.PromptReload()
            end,
            reset = function()
                Plateau.DB:Reset("look.friendly.minions")
                ns.PromptReload()
            end,
        }, FriendlyOn, FriendlyOffReason), "friendly"),
        { type = "Note", label = "In dungeons, raids and arenas the game locks friendly plates, so Blizzard draws them there. The Blizzard settings at the bottom control those.", height = 32 },

        { type = "Header", label = "Shorten names" },
        FriendlyPlayersGate({ type = "Dropdown", path = "look.friendly.nameMode", label = "Player names", options = SHORTEN_NAMES, limited = Style.limited.friendly, visibleIf = function() return Plateau.flavor == "forever" end,
          tooltip = "How friendly players' names are shortened. Only shown on flavors where players have a given name and a surname." }),
        FriendlyNpcsGate({ type = "Dropdown", path = "look.friendly.npcNameMode", label = "NPC names", options = SHORTEN_NAMES, limited = Style.limited.friendly,
          tooltip = "How friendly NPCs' names are shortened. NPCs commonly have multi-word names, so this is where shortening shows up the most." }),

        { type = "Header", label = "Names only" },
        FriendlyGate({ type = "Toggle", path = "look.friendly.nameOnly", label = "Show just the name, no bar",
          tooltip = "Plateau's friendly plates show only a name, with no health bar underneath. In dungeons and raids the game draws friendly plates; Only show friendly player names below does this there." }),
        CVarToggle("nameplateUseClassColorForFriendlyPlayerUnitNames", "Class-color friendly player names",
            "Blizzard's own setting, so it also covers Blizzard's friendly plates in dungeons and raids."),
        NameOnlyGate(FriendlyPlayersGate({ type = "Color", path = "look.friendly.playerNameColor", label = "Player name color (class colors off)",
          tooltip = "Used for friendly player names on Plateau's plates when class colors above are off. In dungeons and raids the game picks its own name colors." })),
        NameOnlyGate(FriendlyNpcsGate({ type = "Color", path = "look.friendly.npcNameColor", label = "NPC name color",
          tooltip = "Used for friendly NPC names on Plateau's plates. In dungeons and raids the game picks its own name colors." })),
        FriendlyPlayersGate(CVarSlider("nameplateSize", "Friendly player name size", 1, 5, 1,
            "1 Small, 2 Medium, 3 Large, 4 Extra Large, 5 Huge. This is Blizzard's Nameplate Size, so it is the same setting as Nameplate size (Blizzard) on the Size page and in the game's own options: changing one changes the other. It sizes friendly players on Plateau's plates and on the plates the game draws in dungeons, raids and arenas. It also sizes the personal resource bar and anything else the game draws itself.")),
        FriendlyNpcsGate({ type = "Slider", path = "look.friendly.npcNameScale", label = "Friendly NPC name size", min = 1, max = 5,
          tooltip = "1 Small, 2 Medium, 3 Large, 4 Extra Large, 5 Huge, the same steps as Friendly player name size, so the same number gives the same size. Only Plateau's friendly plates use it; the plates the game draws in dungeons and raids use Friendly player name size for everyone." }),
        NameOnlyGate(FriendlyGate({ type = "Slider", path = "look.friendly.nameOffsetY", limited = Style.limited.friendly, label = "Name height (up or down)", min = -60, max = 60,
          tooltip = "Moves the name up or down when only the name shows. Lower it if the name floats too far above the head." })),

        { type = "Header", label = "Raid target icon" },
        FriendlyGate({ type = "Toggle", path = "look.friendly.raidMarker.own", label = "Place the raid icon separately from enemies",
          set = function(value)
              local values = { ["look.friendly.raidMarker.own"] = value == true }
              if value then
                  for _, key in ipairs({ "position", "gap", "offsetX", "offsetY" }) do
                      values["look.friendly.raidMarker." .. key] = Plateau.DB:Get("look.raidMarker." .. key)
                  end
              end
              Plateau.DB:SetMany(values)
          end,
          tooltip = "Off: friendly plates put the raid icon where the Raid target icon page says. On: friendly plates use the position below, and moving the icon on this page's preview no longer moves it on enemy plates. Size and opacity still follow the Raid target icon page." }),
        Gate({ type = "Dropdown", path = "look.friendly.raidMarker.position", label = "Position", options = SIDES,
          tooltip = "Which side of the friendly nameplate this sits on, or on top of the bar." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.gap", label = "Distance from the nameplate", min = 0, max = 20,
          tooltip = "How far the raid icon sits from the friendly nameplate's edge, in the direction of Position. Applied before the offsets." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the raid icon left (negative) or right (positive) from the spot set by Position and distance." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),
        Gate({ type = "Slider", path = "look.friendly.raidMarker.offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Nudges the raid icon down (negative) or up (positive) from the spot set by Position and distance." }, FriendlyRaidMarkerOn, FriendlyRaidMarkerReason),

        { type = "Header", label = "Full nameplate", visibleIf = FriendlyStyled },
        { type = "Note", label = "Shown instead of just the name, above. Everything else about the look, like size and position, follows the regular nameplate settings; these are the only differences.", height = 32, visibleIf = FriendlyStyled },
        FriendlyGate({ type = "Toggle", path = "look.friendly.classColors", label = "Use class colors for names", visibleIf = FriendlyStyled,
          tooltip = "Colors friendly player names by their class instead of a flat color." }),
        FriendlyGate({ type = "Toggle", path = "look.friendly.classificationEnabled", label = "Show the elite/rare icon", visibleIf = FriendlyStyled,
          tooltip = "Shows the elite, rare or boss icon on friendly plates that qualify." }),
        FriendlyGate({ type = "Toggle", path = "look.friendly.levelEnabled", label = "Show the level", visibleIf = FriendlyStyled,
          tooltip = "Shows the friendly unit's level." }),
        { type = "Link", label = "The health bar color is the Friendly swatch on the Health bar page", target = { section = "health", label = "Reaction colors" }, visibleIf = FriendlyStyled },

        { type = "Header", label = "Extras" },
        FriendlyGate({ type = "Toggle", path = "look.friendly.hideInCombat", label = "Hide friendly plates in combat",
          tooltip = "Plateau's friendly plates fade out while you're in combat and come back when it ends. Faded plates can still be clicked unless Click-through friendly plates is on (Clickable area page)." }),
        FriendlyPlayersGate({ type = "ToggleColor", path = "look.friendly.groupColor", colorPath = "look.friendly.groupNameColor", label = "Group member name color",
          tooltip = "Party and raid members' names use this color on Plateau's friendly plates, so your group stands out. Replaces their class color while on." }),

        { type = "Header", label = "Blizzard's friendly plates (dungeons and raids)" },
        CVarToggle("nameplateShowOnlyNameForFriendlyPlayerUnits", "Only show friendly player names",
            "Blizzard applies this to real players only. Follower dungeon companions are NPCs, so they keep their bars."),
        CVarToggle("nameplateShowFriendlyPlayerMinions", "Friendly players' minions",
            "Pets, totems and other minions. Blizzard's name-only setting skips them, so in dungeons and raids they always get a bar. Turn this off to hide them there."),
        { type = "Toggle", label = "Hide friendly pets in dungeons and raids", visibleIf = function() return Plateau.InstancePets ~= nil end,
          keywords = "pet pets minion minions totem names hide dungeon raid instance mythic",
          get = function() return Plateau.InstancePets ~= nil and Plateau.InstancePets:IsOn() end,
          set = function(value) Plateau.InstancePets:SetOn(value == true) end,
          tooltip = "Inside dungeons and raids, hides other players' pets, totems and minions: both their nameplates and the names floating over them. Outside, your own settings for Friendly players' minions and Show friendly minion names come back. Applies after combat if you change it mid-fight. Saved for your account." },
        RealmNameToggle(),
        Gate({ type = "Toggle", label = "Hide the (*) after other realms' player names",
          get = function() return not Plateau.DB.saved.global.keepRealmMarker end,
          set = function(value)
              Plateau.DB.saved.global.keepRealmMarker = not value
              ns.PromptReload()
          end,
          tooltip = "The game adds (*) to players from other realms, including on plates it draws itself in dungeons and raids. This tells the game to leave it off. Takes effect after a /reload." },
          function() return CVars:Get("nameplateShowFriendlyRealmName") ~= "1" end,
          "Show friendly players' realm names is on, so the full realm name shows instead of (*)."),
        { type = "Link", label = "NPC names over heads are under Game settings", target = { section = "game", label = "Names over heads" } }
    ), BlizzardDrawn())),

    Section("healthText", "Health text", "look.healthText", Join(List(
        { type = "Header", label = "Text", first = true },
        { type = "Toggle", path = "look.healthText.enabled", label = "Show health text",
          tooltip = "Shows a number and/or percent for the current health on the bar." }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Dropdown", path = "look.healthText.format", label = "Health format", options = HEALTH_FORMATS,
          tooltip = "Percentage: just the percent, like 87%. Value: the current health, abbreviated, like 52.3K. Both, Percent first and Value / max combine them. Missing health and Missing percent show how much is gone. Percentages follow Percentage decimal places; numbers follow Value decimals." }
    ), List(
        Gate({ type = "Slider", path = "look.healthText.decimals", label = "Percentage decimal places", min = 0, max = 2,
          tooltip = "Number of decimal places shown in health percentages, for example 1 shows 87.4% instead of 87%. Affects any format that includes a percentage." }, HealthTextPercent, HealthTextPercentReason)
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Color", path = "look.healthText.color", label = "Text color",
          tooltip = "The color of the health text." },
        { type = "Dropdown", path = "look.healthText.anchor", label = "Position", options = TEXT_POSITIONS,
          tooltip = "Where the health text sits on the health bar." },
        { type = "Slider", path = "look.healthText.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges the health text left (negative) or right (positive)." },
        { type = "Slider", path = "look.healthText.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges the health text down (negative) or up (positive)." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(HealthTextOn, TEXT_ON, FontControls("look.healthText")), List(
        { type = "Header", label = "Extras" }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "Dropdown", path = "look.healthText.valuePrecision", label = "Value decimals", options = VALUE_PRECISION,
          tooltip = "How health numbers are shortened. Standard is one decimal for thousands and two for millions." },
        { type = "Toggle", path = "look.healthText.percentSign", label = "Show % sign",
          tooltip = "Off shows 87 instead of 87%." },
        { type = "Toggle", path = "look.healthText.hideFull", label = "Hide at full health",
          tooltip = "The text appears once the enemy takes damage." },
        { type = "Toggle", path = "look.healthText.targetOnly", label = "Only on my target",
          tooltip = "Health text shows only on the enemy you are targeting." },
        { type = "Toggle", path = "look.healthText.colorByHealth", label = "Color by health remaining",
          tooltip = "The text fades from the full-health color to the low-health color as the enemy loses health. Separate from the health bar's own setting." }
    ), GateList(HealthTextColors, HealthTextColorsReason,
        { type = "Color", path = "look.healthText.colorHigh", label = "Full health color",
          tooltip = "The text color at full health." },
        { type = "Color", path = "look.healthText.colorMid", label = "Half health color",
          tooltip = "The text color at half health." },
        { type = "Color", path = "look.healthText.colorLow", label = "Low health color",
          tooltip = "The text color as health runs out." }
    ), GateList(HealthTextOn, TEXT_ON,
        { type = "ToggleColor", path = "look.healthText.executeColor", colorPath = "look.healthText.executeTextColor", label = "Execute range color",
          tooltip = "The text turns this color below the execute threshold set on the Health bar page. Beats Color by health remaining." }
    ))),

    Section("name", "Name", { "look.name", "look.enemyTarget" }, Join(List(
        { type = "Header", label = "Name", first = true },
        { type = "Toggle", path = "look.name.enabled", label = "Show names" ,
          tooltip = "Shows the unit's name on the plate." }
    ), GateList(NameOn, NAME_ON,
        { type = "Color", path = "look.name.color", label = "Text color",
          tooltip = "The color of the name. Class colors replace it for player names when Use class colors for player names is on and the game reveals the player's class; NPC names always use this color." },
        { type = "Toggle", path = "look.name.classColors", label = "Use class colors for player names",
          tooltip = "Colors player names by class, overriding Text color. NPC names, and players whose class the game hides, use Text color. Friendly players follow Class-color friendly player names on the Friendly nameplates page instead." },
        { type = "Dropdown", path = "look.name.position", label = "Position", options = NAME_POSITIONS,
          tooltip = "Where the name sits relative to the health bar." },
        { type = "Dropdown", path = "look.name.justify", label = "Text alignment", options = ALIGN,
          tooltip = "Left, center or right, on the bar or above/below it. With Cut at the start, NPC names hug the right edge so the end stays visible; player names stay centered unless they need cutting." },
        { type = "Dropdown", path = "look.name.mode", label = "Shorten names", options = SHORTEN_NAMES, limited = Plateau.flavor ~= "forever" and Style.limited.names or nil,
          tooltip = "Rewrites the name before it is fitted to the available width: the full name, the first or last word, or initials. Abbreviating never cuts letters off; Long name handling deals with a name that is still too wide afterwards. Applies to every enemy, player or NPC. Friendly nameplates have their own player and NPC settings on the Friendly nameplates page." .. RETAIL_NAME_NOTE },
        { type = "Dropdown", label = "Long name handling", options = OVERFLOW_NAMES, path = "look.name.overflow",
          tooltip = "Runs after Shorten names, on a name that is still wider than the available width (Maximum name width, or the plate width when that is 0). Do not truncate lets it run past the plate. Cut at the end or start truncates only the text that does not fit." },
        { type = "Slider", path = "look.name.width", label = "Maximum name width (0 = plate width)", min = 0, max = 250,
          visibleIf = function() return ns.Get("look.name.overflow") ~= "none" end,
          tooltip = "The available width for the name; 0 uses the plate's width (a little less when the name is inside the bar). Names wider than this are truncated. With Cut at the start, \"Wastelander Phaseblade\" becomes \"...Phaseblade\" on every enemy." },
        { type = "Slider", path = "look.name.gap", label = "Vertical offset", min = -10, max = 20,
          tooltip = "Moves the name up or down. Above the bar and Below the bar: the gap between the name and the health bar's edge, so higher values move it away from the bar. Inside bar: positive moves it up. Inside bar, top: positive moves it down from the top edge. Negative values go the opposite way." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(NameOn, NAME_ON, FontControls("look.name")), List(
        { type = "Header", label = "Extras" }
    ), GateList(NameOn, NAME_ON,
        { type = "Toggle", path = "look.name.targetOnly", label = "Only on my target",
          tooltip = "Enemy names show only on the enemy you are targeting. Friendly names are not affected." },
        { type = "Toggle", path = "look.name.matchBar", label = "Match health bar color",
          tooltip = "Enemy names take the health bar's current color, including threat, enemy type, class and health colors. Replaces Text color and class colors for names." },
        { type = "Toggle", path = "look.name.hideCasting", label = "Hide while casting",
          tooltip = "Hides an enemy's name while its cast bar is showing, so the spell name and the enemy's name don't crowd each other." }
    ), List(
        { type = "Header", label = "Enemy target name" },
        { type = "Toggle", path = "look.enemyTarget.enabled", label = "Show enemy target name",
          tooltip = "Display the name of the enemy's current target when available - whoever it's actually targeting right now, like a tank or healer. This is separate from the Cast bar page's cast target, which tracks who a specific spell is aimed at. The game can hide who it is from addons in dungeons, but it still shows here." }
    ), GateList(EnemyTargetOn, ENEMY_TARGET_ON,
        { type = "ToggleColor", path = "look.enemyTarget.classColors", colorPath = "look.enemyTarget.color", label = "Use class colors",
          tooltip = "Color the enemy's target name by class when available. The swatch next to it is the fallback color, used both when this is off and when a class color isn't available (the target isn't a player, or their class can't be read).",
          swatchLabel = "Custom target name color",
          swatchTooltip = "Used when Use class colors is off, or when a class color isn't available." },
        { type = "Dropdown", path = "look.enemyTarget.anchor", label = "Position", options = TEXT_POSITIONS,
          tooltip = "Where this text sits on the health bar." },
        { type = "Slider", path = "look.enemyTarget.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges this text left (negative) or right (positive)." },
        { type = "Slider", path = "look.enemyTarget.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges this text down (negative) or up (positive)." },
        { type = "ToggleColor", path = "look.enemyTarget.meColor", colorPath = "look.enemyTarget.meColorValue", label = "Color when it's you",
          tooltip = "The enemy's target name turns this color while the enemy is targeting you. Works in dungeons too: the game picks the color without telling Plateau who the target is." },
        FontControls("look.enemyTarget")
    ))),

    Section("level", "Level", "look.level", Join(List(
        { type = "Header", label = "Level", first = true },
        { type = "Toggle", path = "look.level.enabled", label = "Show level",
          tooltip = "Shows the unit's level." }
    ), GateList(LevelOn, LEVEL_ON,
        { type = "Toggle", path = "look.level.hideAtPlayerLevel", label = "Hide level for same-level non-elites",
          tooltip = "Hides the level on any enemy that is not an elite, rare elite or boss when its level equals yours (plain rares included). Elites, rare elites and bosses always show their level, and so does any enemy of a different level." },
        { type = "Toggle", path = "look.level.showElitePlus", label = "Show + for elites",
          tooltip = "Adds a + after the level of elites and rare elites, like 90+. Normal enemies and plain rares never get one, and bosses show ??." },
        { type = "Toggle", path = "look.level.colorByDifficulty", label = "Color by difficulty",
          tooltip = "Colors the level by how hard the enemy is compared to your level, using the game's own difficulty colors (grey for trivial, then green, yellow, orange and red for much higher), like the target frame. Unknown (??) and boss levels are always red." },
        { type = "Color", path = "look.level.color", label = "Custom level color",
          tooltip = "The level text's color when Color by difficulty is off, or when the game can't supply a difficulty color. Unknown (??) and boss levels stay red." },
        { type = "Dropdown", path = "look.level.anchor", label = "Position", options = LEVEL_POSITIONS,
          tooltip = "Where the level text sits on the bar." },
        { type = "Slider", path = "look.level.offsetX", label = "Horizontal offset", min = -50, max = 50,
          tooltip = "Nudges the level text left (negative) or right (positive)." },
        { type = "Slider", path = "look.level.offsetY", label = "Vertical offset", min = -30, max = 30,
          tooltip = "Nudges the level text down (negative) or up (positive)." }
    ), List(
        { type = "Header", label = "Font" }
    ), GateList(LevelOn, LEVEL_ON, FontControls("look.level")), List(
        { type = "Header", label = "Extras" }
    ), GateList(LevelOn, LEVEL_ON,
        { type = "Toggle", path = "look.level.hideInInstances", label = "Hide in dungeons and raids",
          tooltip = "Levels inside dungeons and raids are nearly always the same, so this hides them there." },
        { type = "Dropdown", path = "look.level.bossText", label = "Boss level text", options = BOSS_LEVEL_TEXT,
          tooltip = "What shows instead of a level on bosses and enemies whose level is hidden." },
        { type = "Toggle", path = "look.level.markRares", label = "Mark rares",
          tooltip = "Adds an r after the level of rares, like 90r, or 90r+ for rare elites." },
        { type = "Toggle", path = "look.level.hideTrivial", label = "Hide trivial levels",
          tooltip = "Hides the level on grey enemies, the ones too low to give you experience." }
    ))),

    Section("castbar", "Cast bar", "look.castbar", Join(List(
        { type = "Header", label = "Size and spacing", first = true },
        { type = "Slider", path = "look.castbar.width", label = "Width (0 = match health bar)", min = 0, max = 300,
          tooltip = "0 keeps the cast bar exactly as wide as the health bar. Any other width is centered under it, spell icon included." },
        { type = "Slider", path = "look.castbar.height", label = "Height (0 = match health bar)", min = 0, max = 30,
          tooltip = "0 keeps the cast bar exactly as tall as the health bar. Any other height is its own fixed size." },
        { type = "Slider", path = "look.castbar.gap", label = "Health bar spacing", min = 0, max = 20,
          tooltip = "How far the cast bar sits below the health bar. 0 places it flush against the health bar." },

        { type = "Header", label = "Bar" },
        { type = "Dropdown", path = "look.castbar.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "The fill texture for the cast bar." },
        { type = "Dropdown", path = "look.castbar.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Layers a Plateau checker or line pattern on top of the bar texture above, tinted to match its color. No overlay shows the texture alone." },
        Gate({ type = "Slider", path = "look.castbar.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "How different the pattern's light and dark parts are from each other, separate from how strongly the whole pattern shows. 0 is flat, 1 is the sharpest the pattern gets." }, Chosen("look.castbar.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.castbar.overlayAlpha", label = "Overlay strength", min = 0, max = 1, step = 0.05,
          tooltip = "How strong the overlay pattern shows on top of the bar texture." }, Chosen("look.castbar.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Color", path = "look.castbar.background", label = "Background color",
          tooltip = "Color of the unfilled portion of the cast bar." },
        { type = "Dropdown", path = "look.castbar.borderStyle", label = "Border style", options = BorderStyles, unknown = "Custom border",
          tooltip = "Tooltip styles have rounded corners, so they look squashed on very thin bars; raise the bar height or use Thin tooltip. The border color tints the art, so light colors show it best." },
        { type = "Color", path = "look.castbar.border", label = "Border color", set = BorderColorSetter("look.castbar"),
          tooltip = "The color of the border drawn around the cast bar. Picking a color while the style is No border or the thickness is 0 turns on a 1 pixel border so you can see it. Click Okay in the color picker to keep a color; clicking outside it or pressing Escape cancels." },
        Gate({ type = "Slider", path = "look.castbar.borderSize", label = "Border thickness", min = 0, max = 4,
          tooltip = "How thick the border is." }, CastBorderOn, "Choose a border style to use this."),
        Gate({ type = "Toggle", path = "look.castbar.borderInside", label = "Draw border inside",
          tooltip = "Draw the border within the cast bar's edges. Off wraps it around the outside instead." }, CastBorderOn, "Choose a border style to use this."),
        { type = "ToggleColor", path = "look.castbar.showSpark", colorPath = "look.castbar.sparkColor", label = "Show cast bar spark",
          tooltip = "Show a bright highlight at the moving edge of the cast bar, in this color." },

        { type = "Header", label = "Spell icon" },
        { type = "Toggle", path = "look.castbar.showIcon", label = "Show spell icon",
          tooltip = "Shows the spell's own icon next to the cast bar." },
        Gate({ type = "Toggle", path = "look.castbar.iconSpan", label = "Extend icon across both bars",
          tooltip = "Resizes the spell icon to fill the combined height of the health bar and cast bar, and sits beside the whole plate." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.iconSide", label = "Icon position", options = ICON_SIDES,
          tooltip = "Which side of the bars the spell icon sits on." }, On("look.castbar.showIcon"), "Turn on Show spell icon to use this."),

        { type = "Header", label = "Interrupts" },
        { type = "ToggleColor", path = "look.castbar.kickMarker", colorPath = "look.castbar.kickMarkerColor", label = "Show interrupt cooldown marker",
          set = function(value)
              ns.Set("look.castbar.kickMarker", value)
              if value and ns.ShowKickMarkerCast then
                  ns.ShowKickMarkerCast()
              end
          end,
          tooltip = "While your interrupt is on cooldown but will come off cooldown before the cast finishes, a line marks the moment it becomes ready. No line means your interrupt is already ready, or won't be back in time. Tracks whichever interrupt spell your class (and, for some specs, your current pet) knows; if you don't know one, this never shows. The preview always shows it while this is on, so you can adjust it." },
        Gate({ type = "Slider", path = "look.castbar.kickMarkerWidth", label = "Marker thickness", min = 1, max = 6,
          set = function(value)
              ns.Set("look.castbar.kickMarkerWidth", value)
              if ns.ShowKickMarkerCast then
                  ns.ShowKickMarkerCast()
              end
          end,
          tooltip = "How thick the interrupt cooldown marker line is." }, On("look.castbar.kickMarker"), "Turn on Show interrupt cooldown marker to use this."),

        { type = "Header", label = "Important casts" },
        { type = "ToggleColor", path = "look.castbar.importantGlow", colorPath = "look.castbar.importantColor", label = "Highlight important casts",
          tooltip = "Adds a glow around the cast bar for casts the game itself flags as important - usually the ones that wipe the group if they land. This includes important casts that can't be interrupted." },
        Gate({ type = "Slider", path = "look.castbar.glowSize", label = "Glow size", min = 0, max = 6,
          tooltip = "How big the glow around an important cast is." }, On("look.castbar.importantGlow"), "Turn on Highlight important casts to use this."),

        { type = "Header", label = "Interrupted casts" },
        { type = "ToggleColor", path = "look.castbar.showInterrupter", colorPath = "look.castbar.interruptedColor", label = "Show interrupter name",
          tooltip = "Shows the name of the player who interrupted the cast. The bar turns this color and reads \"Interrupted by <name>\" in class color. Names show for your party and raid; the game may hide other names." },
        Gate({ type = "Slider", path = "look.castbar.interruptHold", label = "Display duration (seconds)", min = 0.3, max = 3, step = 0.1,
          tooltip = "How long the interrupted-cast bar and message stay up before clearing." }, On("look.castbar.showInterrupter"), "Turn on Show interrupter name to use this."),

        { type = "Header", label = "Cast bar colors" },
        { type = "Note", label = "Cast bar colors reflect your interrupt's cooldown and whether the cast can be interrupted. Casts flagged as important by Blizzard use separate colors, including important casts that can only be stopped with crowd control. If your spec has no interrupt, casts that can be interrupted show the Interrupt ready colors, so you can call them out.", height = 44 },
        { type = "Color", path = "look.castbar.readyColor", label = "Interrupt ready",
          tooltip = "Cast bar color when your interrupt is off cooldown. This only checks cooldown - it doesn't know if you're in range or otherwise able to actually use it right now." },
        { type = "Color", path = "look.castbar.notReadyColor", label = "Interrupt on cooldown",
          tooltip = "Cast bar color when your interrupt is still on cooldown." },
        { type = "Color", path = "look.castbar.importantReadyColor", label = "Important cast: interrupt ready",
          tooltip = "Like Interrupt ready, but for casts flagged important (usually dangerous ones)." },
        { type = "Color", path = "look.castbar.importantNotReadyColor", label = "Important cast: interrupt on cooldown",
          tooltip = "Like Interrupt on cooldown, but for casts flagged important." },
        { type = "Color", path = "look.castbar.uninterruptible", label = "Uninterruptible cast",
          tooltip = "The game says this cast can't be interrupted. Tints the bar over the interrupt colors and your bar texture, so a shielded cast always looks the same no matter your interrupt. It is solid by default; lower this color's opacity to let the cast color and bar texture show through." },
        { type = "Color", path = "look.castbar.importantUninterruptible", label = "Important cast: uninterruptible, CC required",
          tooltip = "Blizzard flags the cast as important and the game says it can't be interrupted. Both come straight from the game. This cast needs crowd control: stun, incapacitate or knockback it, break line of sight, or use a defensive. The game doesn't say whether CC will work on this enemy. Has its own opacity too, independent of Uninterruptible cast above." },

        { type = "Header", label = "Text" },
        { type = "Dropdown", path = "look.castbar.textJustify", label = "Spell name alignment", options = ALIGN,
          tooltip = "Where the spell name sits across the bar. The interrupted message follows it while its position is Where the spell name is (Interrupted text, under Extras)." },
        { type = "Toggle", path = "look.castbar.showTimer", label = "Show remaining cast time",
          tooltip = "Shows a countdown of the remaining cast time." },
        Gate({ type = "Slider", path = "look.castbar.timerDecimalsBelow", label = "Decimal threshold (seconds)", min = 0, max = 60,
          tooltip = "Below this many seconds remaining, the countdown switches to tenths of a second (2.4 instead of 2s). 0 never shows tenths." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.timerPosition", label = "Cast timer position", options = SIDES,
          tooltip = "Where the cast timer sits on the bar." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Slider", path = "look.castbar.timerOffsetX", label = "Cast timer horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the cast timer left (negative) or right (positive)." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        Gate({ type = "Slider", path = "look.castbar.timerOffsetY", label = "Cast timer vertical offset", min = -40, max = 40,
          tooltip = "Nudges the cast timer down (negative) or up (positive)." }, On("look.castbar.showTimer"), "Turn on Show remaining cast time to use this."),
        { type = "ToggleColor", path = "look.castbar.showTarget", colorPath = "look.castbar.targetColor", label = "Show cast target",
          tooltip = "Show the name of the unit targeted by the spell when available." },
        Gate({ type = "Toggle", path = "look.castbar.targetClassColor", label = "Use class color for cast target",
          tooltip = "Colors the cast target's name by their class instead of the color above. Only applies when the target is a player - the game only ever gives an addon the target's name for a player anyway." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetSize", label = "Cast target font size", min = 6, max = 20,
          tooltip = "How big the cast target's name is." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Dropdown", path = "look.castbar.targetPosition", label = "Cast target position", options = SIDES,
          tooltip = "Where the cast target's name sits on the bar." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetOffsetX", label = "Cast target horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the cast target's name left (negative) or right (positive)." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        Gate({ type = "Slider", path = "look.castbar.targetOffsetY", label = "Cast target vertical offset", min = -40, max = 40,
          tooltip = "Nudges the cast target's name down (negative) or up (positive)." }, On("look.castbar.showTarget"), "Turn on Show cast target to use this."),
        { type = "Header", label = "Font" },
        FontControls("look.castbar"),

        { type = "Header", label = "Extras" },
        { type = "Toggle", path = "look.castbar.showSpellName", label = "Show spell name",
          tooltip = "Off leaves the spell name out, for slim bars where the timer is enough. Interrupted by <name> still shows." },
        { type = "Toggle", path = "look.castbar.drainCasts", label = "Casts empty instead of fill",
          tooltip = "A normal cast's bar starts full and drains as it finishes, the way channels already do. The interrupt marker follows." },
        { type = "Toggle", path = "look.castbar.shieldIcon", label = "Shield icon on uninterruptible casts",
          tooltip = "Shows a small shield over the spell icon (or the start of the bar when the icon is off) while a cast can't be interrupted, on top of the Uninterruptible cast tint." },
        { type = "Dropdown", path = "look.castbar.showCasts", label = "Which casts to show", options = SHOW_CASTS,
          tooltip = "All casts, only casts you can interrupt, or only casts the game flags as important. Hidden casts still count for Casting scale and other cast features." },
        { type = "Toggle", path = "look.castbar.cropIcon", label = "Crop icon edges",
          tooltip = "Trims the spell icon's built-in border so only the art shows. Off shows the full icon." },

        { type = "Header", label = "Interrupted text" }
    ), GateList(On("look.castbar.showInterrupter"), "Turn on Show interrupter name to use this.",
            { type = "Dropdown", path = "look.castbar.interruptFormat", label = "Interrupted text shows", options = INTERRUPT_FORMATS,
              tooltip = "What the message on an interrupted cast says: Interrupted by and the player's name, just the name, or just Interrupted." },
            { type = "Dropdown", path = "look.castbar.interruptPosition", label = "Interrupted text position", options = INTERRUPT_POSITIONS,
              tooltip = "Where the interrupted message sits. Where the spell name is keeps it in the spell name's spot and follows Spell name alignment; any other choice gives it its own place." },
            { type = "Slider", path = "look.castbar.interruptOffsetX", label = "Interrupted text horizontal offset", min = -60, max = 60,
              tooltip = "Nudges the interrupted message left (negative) or right (positive)." },
            { type = "Slider", path = "look.castbar.interruptOffsetY", label = "Interrupted text vertical offset", min = -60, max = 60,
              tooltip = "Nudges the interrupted message down (negative) or up (positive)." },
            { type = "Slider", path = "look.castbar.interruptSize", label = "Interrupted text font size", min = 6, max = 24,
              tooltip = "How big the interrupted message is. It uses the cast bar's font and outline." },
            { type = "Color", path = "look.castbar.interruptTextColor", label = "Interrupted text color",
              tooltip = "The color of the message. The player's name uses their class color when Class color for the name is on." },
            { type = "Toggle", path = "look.castbar.interruptClassColor", label = "Class color for the name",
              tooltip = "Shows the interrupting player's name in their class color. The game may hide who interrupted for players outside your group; the name then shows in the text color, or the message reads Interrupted." },
            { type = "Toggle", path = "look.castbar.interruptKeepName", label = "Keep showing the spell name",
              tooltip = "Off replaces the spell name with the interrupted message. On keeps the spell name and shows the message separately, so move the message somewhere else with Interrupted text position." }))),

    Section("shield", "Buff warnings", { "look.shield.alertImportant", "look.shield.alertColor", "look.shield.alertDefensive", "look.shield.defensiveColor", "look.shield.alertEnrage", "look.shield.enrageColor", "look.shield.alertMagic", "look.shield.magicColor", "look.shield.alertOnlyMine", "look.shield.alertSize", "look.shield.alertTexture", "look.shield.alertTextureAlpha" }, List(
        { type = "Note", label = "Highlight enemy buffs with a colored border or health bar overlay on the nameplate itself. Buff icons are on Enemy buffs and Important auras.", height = 32 },

        { type = "Header", label = "Warnings" },
        { type = "ToggleColor", path = "look.shield.alertImportant", colorPath = "look.shield.alertColor", label = "Important buff",
          tooltip = "Buffs the game itself flags as important on enemies, the ones you're meant to notice. Blizzard decides which buffs count; Plateau has no list of its own." },
        { type = "ToggleColor", path = "look.shield.alertEnrage", colorPath = "look.shield.enrageColor", label = "Enrage",
          tooltip = "Any enrage effect that can be removed (Soothe, Tranquilizing Shot, Shiv)." },
        { type = "ToggleColor", path = "look.shield.alertDefensive", colorPath = "look.shield.defensiveColor", label = "Major defensive buff",
          tooltip = "Major damage-reduction buffs on the enemy, the ones the game itself flags as big defensives. Blizzard decides which buffs count." },
        { type = "ToggleColor", path = "look.shield.alertMagic", colorPath = "look.shield.magicColor", label = "Dispellable Magic buff",
          tooltip = "Any Magic buff that can be removed (Purge, Dispel Magic, Consume Magic, Spellsteal, Tranquilizing Shot, Devour Magic). Buffs you could take with Spellsteal count." },
        Gate({ type = "Toggle", path = "look.shield.alertOnlyMine", label = "Only warn for buffs you can remove",
          tooltip = "Applies to Enrage and Dispellable Magic buff only. Hides those warnings while you know no spell that removes them: Soothe, Tranquilizing Shot or Shiv for enrages; Purge, Dispel Magic, Consume Magic, Spellsteal, Tranquilizing Shot or your pet's Devour Magic for Magic. It checks the spells you currently know, so it updates when you change spec, talents or pet. It does not check cooldowns, range or whether the spell is usable." }, Any(On("look.shield.alertEnrage"), On("look.shield.alertMagic")), "Turn on Enrage or Dispellable Magic buff to use this."),
        { type = "Slider", path = "look.shield.alertSize", label = "Border thickness (0 = no border)", min = 0, max = 8,
          tooltip = "How thick the warning border is." },
        { type = "Dropdown", path = "look.shield.alertTexture", label = "Health bar overlay", options = ALERT_TEXTURES,
          tooltip = "Lays a texture in the warning's color over the whole health bar, on top of the border or instead of it. Set Border thickness to 0 for the overlay alone." },
        Gate({ type = "Slider", path = "look.shield.alertTextureAlpha", label = "Overlay opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "How opaque the health bar overlay is." }, Chosen("look.shield.alertTexture"), "Choose a Health bar overlay to use this."),
        { type = "PriorityList", path = "look.shield.alertOrder", label = "Warning priority", keys = { "important", "defensive", "enrage", "magic" },
          names = { important = "Important buff", defensive = "Major defensive buff", enrage = "Enrage", magic = "Dispellable Magic buff" },
          tooltip = "When multiple warning categories apply, the highest-priority one is drawn on top of the others. Turned-off categories are ignored, and a category's border and overlay share the same priority. Drag a row to move it, or use Up and Down." },

        { type = "Note", label = "Works in dungeons and raids: Blizzard classifies the enemy's buffs and Plateau only styles the warnings. Appearance changes made during combat apply after combat ends.", height = 44 }
    )),

    Section("auraAll", "All auras", AURA_TEXT_PATHS, AuraTextControls()),
    AuraPage("auraMine", "Your debuffs", "look.auras.mine", "mine",
        "Show your damage-over-time effects and other debuffs on enemies.", 24,
        "Show your debuffs", "Shows icons for your own damage-over-time effects and other debuffs on the enemy. Crowd control effects you apply appear in the Crowd control group instead.",
        List(
            { type = "Toggle", path = "look.auras.mine.includeOthers", label = "Include other players' debuffs",
              tooltip = "Also shows debuffs other players put on the enemy, after your own, like Blizzard's nameplates do. Crowd control stays in its own group. Can get busy in raids. The preview adds one sample icon for them." }
        ), true),
    AuraPage("auraCC", "Crowd control", "look.auras.cc", "cc",
        "Show crowd control effects on enemies, including stuns, incapacitate effects, and roots, regardless of who applied them.", 44,
        "Show crowd control", "Shows icons for stuns, incapacitates, roots and other crowd control on the enemy, no matter who applied it."),
    AuraPage("auraPurge", "Enemy buffs", "look.auras.purge", "purge",
        "Show buffs on enemies. By default, only buffs that can be removed (purged, stolen or soothed) are shown. Enable Show all buffs to include other buffs.", 32,
        "Show enemy buffs", "Shows icons for buffs on the enemy.",
        List(
            { type = "Toggle", path = "look.auras.purge.allBuffs", label = "Show all buffs",
              tooltip = "Off shows only removable buffs: Magic buffs that can be purged or stolen, and enrages. On shows every buff on the enemy except important ones and ones you cast. Hide boss auras, Hide permanent buffs, Maximum aura duration and Maximum icons still apply. Buffs the game flags as important appear under Important auras instead." },
            Gate({ type = "Toggle", path = "look.auras.purge.showMagic", label = "Magic buffs I can purge or spellsteal",
              tooltip = "Shows magic buffs you have a spell to remove (Purge, Dispel Magic, Consume Magic, Spellsteal, Devour Magic)." }, Off("look.auras.purge.allBuffs"), "Not used while Show all buffs is on."),
            Gate({ type = "Toggle", path = "look.auras.purge.showEnrage", label = "Enrages I can soothe",
              tooltip = "Shows enrage effects you have a spell to remove (Soothe, Tranquilizing Shot, Shiv)." }, Off("look.auras.purge.allBuffs"), "Not used while Show all buffs is on."),
            { type = "Toggle", path = "look.auras.purge.hideBoss", label = "Hide boss auras",
              tooltip = "Hides buffs the game flags as boss auras (auras from boss mechanics). It checks the aura itself, not the unit, so ordinary buffs on a boss still show. Works in dungeons and raids: the game does the check." },
            { type = "Toggle", path = "look.auras.purge.hidePermanent", label = "Hide permanent buffs",
              tooltip = "Buffs with no end time, like the one every enemy gets in a Mythic dungeon. Timed buffs still show. Works in dungeons and raids: the game does the check." }
        )),
    AuraPage("auraImportant", "Important auras", "look.auras.important", "important",
        "Show buffs flagged as important by Blizzard. Disabled by default.", 24,
        "Show important auras", "Shows icons for buffs Blizzard flags as important on this enemy, except ones you cast. This is a separate group of icons from Enemy buffs: a buff appears in one or the other. Buff warnings can also mark the same buffs on the nameplate. These are not necessarily removable or something you must act on."),
    Section("target", "Target", TARGET_LOOK, List(
        { type = "Header", label = "My target", first = true },
        { type = "ToggleColor", path = "look.target.ring", colorPath = "look.target.ringColor", label = "Show target border",
          swatchLabel = "Target border color", swatchTooltip = "The color of the border around your target.",
          tooltip = "A colored outline around the whole plate so your target stands out. Click the swatch to change its color." },
        Gate({ type = "Slider", path = "look.target.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the border around your target is." }, On("look.target.ring"), "Turn on Show target border to use this."),
        { type = "ToggleColor", path = "look.target.colorBar", colorPath = "look.target.barColor", label = "Use custom target color",
          swatchLabel = "Target bar color", swatchTooltip = "The health bar color used for your target.",
          tooltip = "Overrides your target's health bar color with this one, no matter what type it is." },
        { type = "Dropdown", path = "look.target.texture", label = "Target bar texture", options = HighlightBars, unknown = "Custom texture",
          tooltip = "A different bar texture just for your target, so it stands out from the rest." },
        { type = "Dropdown", path = "look.target.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Layers a checker or line pattern on top of the bar texture above, tinted to match its color, instead of replacing it." },
        Gate({ type = "Slider", path = "look.target.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "How strong the overlay pattern shows on your target's bar." }, Chosen("look.target.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.target.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "How different the pattern's light and dark parts are from each other, separate from how strongly the whole pattern shows. 0 is flat, 1 is the sharpest the pattern gets." }, Chosen("look.target.overlayPattern"), "Choose an overlay pattern to use this."),
        { type = "Toggle", path = "look.target.brighten", label = "Brighten target health bar",
          tooltip = "Adds the soft glow Blizzard's classic plates put on your target's health bar. Its strength is fixed." },

        { type = "Header", label = "Arrows" },
        { type = "ToggleColor", path = "look.target.arrows", colorPath = "look.target.arrowColor", label = "Show target arrows",
          swatchLabel = "Target arrow color", swatchTooltip = "Tints the arrows pointing at your target. Leave it white to keep the arrow's own colors.",
          tooltip = "Pick any color and the arrow is tinted to match. Leave it white to keep the arrow's own colors." },
        Gate({ type = "Dropdown", path = "look.target.arrowStyle", label = "Arrow style", options = ARROW_STYLES,
          tooltip = "The shape of the arrows pointing at your target." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Slider", path = "look.target.arrowSize", label = "Arrow size", min = 8, max = 48,
          tooltip = "How big the arrows are." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Dropdown", path = "look.target.arrowPlacement", label = "Arrow placement", options = ARROW_PLACEMENTS,
          tooltip = "Which sides of the nameplate the arrows sit on." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Slider", path = "look.target.arrowGap", label = "Arrow spacing", min = 0, max = 60,
          tooltip = "How far the arrows sit from the edge of the nameplate (its side edges, or its top and bottom edges for the above and below placements). 0 puts them against the edge. 26 clears the raid marker and elite icon at their default sizes." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),
        Gate({ type = "Toggle", path = "look.target.animateArrows", label = "Animate arrows",
          tooltip = "The target arrows bob gently toward the plate." }, On("look.target.arrows"), "Turn on Show target arrows to use this."),

        { type = "Header", label = "Corner brackets" },
        { type = "ToggleColor", path = "look.target.brackets", colorPath = "look.target.bracketColor", label = "Show target brackets",
          swatchLabel = "Target bracket color", swatchTooltip = "Tints the corner brackets around your target.",
          tooltip = "Draws a bracket in each corner of your target's nameplate." },
        Gate({ type = "Dropdown", path = "look.target.bracketStyle", label = "Bracket style", options = BRACKET_STYLES,
          tooltip = "The look of the corner brackets." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),
        Gate({ type = "Slider", path = "look.target.bracketSize", label = "Bracket size", min = 6, max = 32,
          tooltip = "How big the corner brackets are." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),
        Gate({ type = "Slider", path = "look.target.bracketGap", label = "Bracket spacing", min = 0, max = 20,
          tooltip = "How far each bracket is pushed outward from its corner of the nameplate. 0 puts each bracket right on the corner." }, On("look.target.brackets"), "Turn on Show target brackets to use this."),

        { type = "Header", label = "Glow" },
        { type = "ToggleColor", path = "look.target.glow", colorPath = "look.target.glowColor", label = "Show target glow",
          swatchLabel = "Target glow color", swatchTooltip = "The color of the glow around your target. Lower its opacity for a subtler glow.",
          tooltip = "Fades out from the edge of the nameplate. Lower the color's opacity for a subtler glow." },
        Gate({ type = "Slider", path = "look.target.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the glow spreads from the nameplate's edge." }, On("look.target.glow"), "Turn on Show target glow to use this."),
        Gate({ type = "Toggle", path = "look.target.pulse", label = "Pulse glow and border",
          tooltip = "Your target's glow and border slowly pulse brighter and dimmer." }, Any(On("look.target.ring"), On("look.target.glow")), "Turn on Show target border or Show target glow to use this."),

        { type = "Link", label = "Fading the plates you are not targeting is on the Fading page", target = { section = "fading", label = "Plates you are not targeting" } }
    )),

    Section("focus", "Focus", "look.focus", List(
        { type = "Header", label = "My focus", first = true },
        { type = "ToggleColor", path = "look.focus.ring", colorPath = "look.focus.ringColor", label = "Show focus border",
          swatchLabel = "Focus border color", swatchTooltip = "The color of the border around your focus.",
          tooltip = "A colored outline around the whole plate so your focus stands out. Click the swatch to change its color." },
        Gate({ type = "Slider", path = "look.focus.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the border around your focus is." }, On("look.focus.ring"), "Turn on Show focus border to use this."),
        { type = "ToggleColor", path = "look.focus.colorBar", colorPath = "look.focus.barColor", label = "Use custom focus color",
          swatchLabel = "Focus bar color", swatchTooltip = "The health bar color used for your focus.",
          tooltip = "Overrides your focus's health bar color with this one. Easy to spot your interrupt target in a big pull." },
        { type = "Dropdown", path = "look.focus.texture", label = "Focus bar texture", options = HighlightBars, unknown = "Custom texture",
          tooltip = "A different bar texture just for your focus, so it stands out from the rest." },
        { type = "Dropdown", path = "look.focus.overlayPattern", label = "Overlay pattern", options = OverlayPatterns, unknown = "Custom pattern",
          tooltip = "Layers a checker or line pattern on top of the bar texture above, tinted to match its color, instead of replacing it." },
        Gate({ type = "Slider", path = "look.focus.overlayAlpha", label = "Overlay opacity", min = 0, max = 1, step = 0.05,
          tooltip = "How strong the overlay pattern shows on your focus's bar." }, Chosen("look.focus.overlayPattern"), "Choose an overlay pattern to use this."),
        Gate({ type = "Slider", path = "look.focus.overlayContrast", label = "Overlay contrast", min = 0, max = 1, step = 0.05,
          tooltip = "How different the pattern's light and dark parts are from each other, separate from how strongly the whole pattern shows. 0 is flat, 1 is the sharpest the pattern gets." }, Chosen("look.focus.overlayPattern"), "Choose an overlay pattern to use this."),

        { type = "Header", label = "Arrows" },
        { type = "ToggleColor", path = "look.focus.arrows", colorPath = "look.focus.arrowColor", label = "Show focus arrows",
          swatchLabel = "Focus arrow color", swatchTooltip = "Tints the arrows pointing at your focus. Leave it white to keep the arrow's own colors.",
          tooltip = "Pick any color and the arrow is tinted to match. Leave it white to keep the arrow's own colors." },
        Gate({ type = "Dropdown", path = "look.focus.arrowStyle", label = "Arrow style", options = ARROW_STYLES,
          tooltip = "The shape of the arrows pointing at your focus." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Slider", path = "look.focus.arrowSize", label = "Arrow size", min = 8, max = 48,
          tooltip = "How big the arrows are." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Dropdown", path = "look.focus.arrowPlacement", label = "Arrow placement", options = ARROW_PLACEMENTS,
          tooltip = "Which sides of the nameplate the arrows sit on." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Slider", path = "look.focus.arrowGap", label = "Arrow spacing", min = 0, max = 60,
          tooltip = "How far the arrows sit from the edge of the nameplate (its side edges, or its top and bottom edges for the above and below placements). 0 puts them against the edge. 26 clears the raid marker and elite icon at their default sizes." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),
        Gate({ type = "Toggle", path = "look.focus.animateArrows", label = "Animate arrows",
          tooltip = "The focus arrows bob gently toward the plate." }, On("look.focus.arrows"), "Turn on Show focus arrows to use this."),

        { type = "Header", label = "Corner brackets" },
        { type = "ToggleColor", path = "look.focus.brackets", colorPath = "look.focus.bracketColor", label = "Show focus brackets",
          swatchLabel = "Focus bracket color", swatchTooltip = "Tints the corner brackets around your focus.",
          tooltip = "Draws a bracket in each corner of your focus's nameplate." },
        Gate({ type = "Dropdown", path = "look.focus.bracketStyle", label = "Bracket style", options = BRACKET_STYLES,
          tooltip = "The look of the corner brackets." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),
        Gate({ type = "Slider", path = "look.focus.bracketSize", label = "Bracket size", min = 6, max = 32,
          tooltip = "How big the corner brackets are." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),
        Gate({ type = "Slider", path = "look.focus.bracketGap", label = "Bracket spacing", min = 0, max = 20,
          tooltip = "How far each bracket is pushed outward from its corner of the nameplate. 0 puts each bracket right on the corner." }, On("look.focus.brackets"), "Turn on Show focus brackets to use this."),

        { type = "Header", label = "Glow" },
        { type = "ToggleColor", path = "look.focus.glow", colorPath = "look.focus.glowColor", label = "Show focus glow",
          swatchLabel = "Focus glow color", swatchTooltip = "The color of the glow around your focus. Lower its opacity for a subtler glow.",
          tooltip = "Fades out from the edge of the nameplate. Lower the color's opacity for a subtler glow." },
        Gate({ type = "Slider", path = "look.focus.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the glow spreads from the nameplate's edge." }, On("look.focus.glow"), "Turn on Show focus glow to use this."),
        Gate({ type = "Toggle", path = "look.focus.pulse", label = "Pulse glow and border",
          tooltip = "Your focus's glow and border slowly pulse brighter and dimmer." }, Any(On("look.focus.ring"), On("look.focus.glow")), "Turn on Show focus border or Show focus glow to use this."),
        { type = "Note", label = "When a unit is both your target and focus, Target settings take priority. The focus border, glow, arrows and brackets are hidden; for bar color, texture and overlay, Target's choice is used wherever it is turned on, and Focus's applies where Target's is not." }
    )),

    Section("mouseover", "Mouseover", "look.mouseover", Join(List(
        { type = "Header", label = "The plate under your cursor", first = true },
        { type = "Toggle", path = "look.mouseover.enabled", label = "Enable mouseover highlight",
          tooltip = "Highlights the nameplate of whatever your cursor is over, whether you point at the nameplate itself or at the unit in the world. Turning it off removes both the border and the brightening." }
    ), GateList(HoverOn, HOVER_ON,
        { type = "Toggle", path = "look.mouseover.brighten", label = "Brighten health bar",
          tooltip = "Adds the soft glow Blizzard's classic plates use on mouseover. Highlight intensity sets how strong it is." },
        Gate({ type = "Slider", path = "look.mouseover.brightenAmount", label = "Highlight intensity", min = 0.05, max = 0.6, step = 0.05,
          tooltip = "How strong the brightening is. It only applies while Brighten health bar is on and does not change the border." }, On("look.mouseover.brighten"), "Turn on Brighten health bar to use this."),
        { type = "ToggleColor", path = "look.mouseover.ring", colorPath = "look.mouseover.ringColor", label = "Show mouseover border",
          swatchLabel = "Mouseover border color", swatchTooltip = "The color of the border around the nameplate under your cursor.",
          tooltip = "Draws a colored border around the nameplate under your cursor." },
        Gate({ type = "Slider", path = "look.mouseover.ringSize", label = "Border thickness", min = 1, max = 6,
          tooltip = "How thick the mouseover border is." }, On("look.mouseover.ring"), "Turn on Show mouseover border to use this.")
    ), List(
        { type = "Header", label = "Extras" }
    ), GateList(HoverOn, HOVER_ON,
        { type = "ToggleColor", path = "look.mouseover.glow", colorPath = "look.mouseover.glowColor", label = "Show mouseover glow",
          tooltip = "A soft glow around the plate under your cursor, like the target and focus glow." }
    ), List(
        Gate({ type = "Slider", path = "look.mouseover.glowSize", label = "Glow size", min = 2, max = 24,
          tooltip = "How far the mouseover glow spreads from the nameplate's edge." }, HoverGlowOn, HoverGlowReason)
    ), GateList(HoverOn, HOVER_ON,
        { type = "Toggle", path = "look.mouseover.skipFriendly", label = "Skip friendly plates",
          tooltip = "Hovering a friendly plate doesn't highlight it." }
    ))),

    Section("raidMarker", "Raid target icon", "look.raidMarker", Join(List(
        { type = "Header", label = "Raid target icon", first = true },
        { type = "Toggle", path = "look.raidMarker.enabled", label = "Show raid target icons",
          tooltip = "Shows the raid target marker (star, circle, diamond and so on) already assigned to a unit. It does not assign markers, and it does not show ground or world markers." }
    ), GateList(On("look.raidMarker.enabled"), "Turn on Show raid target icons to use this.",
        { type = "Slider", path = "look.raidMarker.size", label = "Icon size", min = 8, max = 40,
          tooltip = "How big the raid marker icon is." },
        Placement("look.raidMarker")
    ), List(
        { type = "Header", label = "Extras" }
    ), GateList(On("look.raidMarker.enabled"), "Turn on Show raid target icons to use this.",
        { type = "Toggle", path = "look.raidMarker.tintBorder", label = "Tint the plate border by marker",
          tooltip = "Draws a border in the marker's color around a marked plate: skull white, cross red, square blue, moon silver, triangle green, diamond purple, circle orange, star yellow. Your target and focus borders take its place on those plates." }
    ), List(
        Gate({ type = "Slider", path = "look.raidMarker.tintSize", label = "Marker border thickness", min = 1, max = 6,
          tooltip = "How thick the marker-colored border is." }, function() return ns.Get("look.raidMarker.enabled") == true and ns.Get("look.raidMarker.tintBorder") == true end,
          function()
              if ns.Get("look.raidMarker.enabled") ~= true then return "Turn on Show raid target icons to use this." end
              return "Turn on Tint the plate border by marker to use this."
          end)
    ))),

    Section("quest", "Quest icon", { "look.quest", "look.colors.quest", "look.colors.questColor", "look.colors.questExcludeBoss" }, Join(
        List(
        { type = "Header", label = "Quest icon", first = true },
        { type = "Note", label = "Mark enemies that count toward your active quest objectives.", height = 32 },
        { type = "Toggle", path = "look.quest.enabled", label = "Show quest icon",
          tooltip = "Marks nameplates of enemies the game links to a quest in your log. The game decides which enemies count, so it can't mark enemies for quests you haven't picked up. Players never get one, bosses skip it when Exclude bosses is on (further down this page), and it isn't available on every game version." },
        Gate({ type = "Dropdown", path = "look.quest.style", label = "Icon style", options = QUEST_ICONS,
          tooltip = "Changes the icon's appearance only, not which enemies or quests qualify. Campaign, important, legendary and repeatable are the game's own quest marker artwork." }, On("look.quest.enabled"), "Turn on Show quest icon to use this."),
        Gate({ type = "Slider", path = "look.quest.size", label = "Icon size", min = 8, max = 40,
          tooltip = "How big the quest icon is." }, On("look.quest.enabled"), "Turn on Show quest icon to use this.")
        ),
        GateList(On("look.quest.enabled"), "Turn on Show quest icon to use this.", Placement("look.quest")),
        List(
        { type = "Header", label = "Quest enemy color" },
        { type = "ToggleColor", path = "look.colors.quest", colorPath = "look.colors.questColor", label = "Color quest enemies",
          tooltip = "Enemies that count toward an active quest get this color, overriding their type or reaction color. Threat, tapped, and your target and focus colors still win. The game decides which enemies count, so it works anywhere quests do; it can't flag enemies for quests you haven't picked up." },
        { type = "Toggle", path = "look.colors.questExcludeBoss", label = "Exclude bosses",
          tooltip = "Bosses keep their own Bosses color and skip quest coloring entirely - this also hides the separate quest icon on the Quest page for them. Dungeon and raid bosses can share a creature ID with an unrelated outdoor quest, which looks wrong on a boss even though the game is technically right." }
        ),
        List(
        { type = "Header", label = "Extras" },
        Gate({ type = "Toggle", path = "look.quest.showProgress", label = "Show objective progress",
          tooltip = "Small text like 3/8 next to the quest icon, read from the enemy's tooltip. Works in the open world; inside instances the game may hide it, and then only the icon shows." }, On("look.quest.enabled"), "Turn on Show quest icon to use this.")
        )
    )),

    Section("forces", "Mythic+ enemy forces", "look.forces", Join(
        List(
            { type = "Header", label = "Mythic+ enemy forces", first = true },
            { type = "Note", label = "Show each enemy's contribution to the enemy forces requirement during an active Mythic+ run.", height = 32 },
            { type = "Toggle", path = "look.forces.enabled", label = "Show enemy forces",
              tooltip = "Shows how much of the required enemy forces total this enemy is worth, right on its nameplate. It is the enemy's contribution, not your group's current progress. It only appears during an active Mythic+ run, on enemies the game reports a value for." },
            Gate({ type = "Dropdown", path = "look.forces.format", label = "Display format", options = FORCES_FORMATS,
              tooltip = "Percentage shows the enemy's share of the required total (like 0.84%). Count shows its raw enemy forces value (like 4). Both shows the count followed by the percentage. Enemies the game reports no value for show nothing." }, On("look.forces.enabled"), "Turn on Show enemy forces to use this."),
            Gate({ type = "Color", path = "look.forces.color", label = "Text color",
              tooltip = "Color of the enemy forces text." }, On("look.forces.enabled"), "Turn on Show enemy forces to use this.")
        ),
        GateList(On("look.forces.enabled"), "Turn on Show enemy forces to use this.", Placement("look.forces")),
        List({ type = "Header", label = "Font" }),
        GateList(On("look.forces.enabled"), "Turn on Show enemy forces to use this.", FontControls("look.forces"))
    )),

    Section("enemyPower", "Enemy power bar", "look.enemyPower", Join(List(
        { type = "Header", label = "Display", first = true },
        { type = "Note", label = "Display an enemy's mana, rage, energy, or other power on its nameplate. Power information may be unavailable for some enemies or encounters.", height = 44 },
        { type = "Toggle", path = "look.enemyPower.enabled", label = "Show enemy power bar",
          tooltip = "Adds a thin bar for the enemy's energy, rage, mana or other power to its nameplate." }
    ), GateList(PowerOn, POWER_ON,
        { type = "Dropdown", path = "look.enemyPower.show", label = "Show it on", options = ENEMY_POWER_SHOW,
          tooltip = "Every enemy: all enemy nameplates. My target only: just the enemy you're targeting. Bosses only: enemies Plateau classifies as bosses - the same classification Colors and Behavior use, based on the game's own boss flag, world boss status, and being a boss1-5 unit token." },
        { type = "Dropdown", path = "look.enemyPower.position", label = "Bar position", options = ENEMY_POWER_POSITIONS,
          tooltip = "Where the power bar sits relative to the health bar." },
        { type = "Slider", path = "look.enemyPower.height", label = "Height", min = 2, max = 20,
          tooltip = "How tall the power bar is." },
        { type = "Slider", path = "look.enemyPower.width", label = "Width (0 = match health bar)", min = 0, max = 300,
          tooltip = "Set the power bar's width. Use 0 to match the health bar." },
        { type = "Slider", path = "look.enemyPower.offsetX", label = "Horizontal offset", min = -40, max = 40,
          tooltip = "Nudges the power bar left (negative) or right (positive)." },
        { type = "Slider", path = "look.enemyPower.offsetY", label = "Vertical offset", min = -40, max = 40,
          tooltip = "Nudges the power bar down (negative) or up (positive)." },
        { type = "Slider", path = "look.enemyPower.alpha", label = "Opacity", min = 0.1, max = 1, step = 0.05,
          tooltip = "Set the power bar's opacity. Lower values make it more transparent. Affects the whole bar, including its background and percentage text, not just the fill." },
        { type = "ToggleColor", path = "look.enemyPower.customColor", colorPath = "look.enemyPower.color", label = "Use custom power color",
          tooltip = "Use the selected color instead of the power type's default color (rage red, energy yellow, and so on)." },
        { type = "Color", path = "look.enemyPower.backgroundColor", label = "Background color",
          tooltip = "Color of the unfilled portion of the power bar." },
        { type = "Toggle", path = "look.enemyPower.showText", label = "Show power percentage",
          tooltip = "Display the enemy's current power as a percentage of its maximum, when available. Not every enemy exposes this; nothing prints if the game doesn't provide it." }
    ), List(
        Gate({ type = "Slider", path = "look.enemyPower.textSize", label = "Font size", min = 6, max = 20,
          tooltip = "Set the size of the power percentage text." }, PowerText, PowerTextReason)
    ), List(
        { type = "Header", label = "Extras" }
    ), GateList(PowerOn, POWER_ON,
        { type = "Dropdown", path = "look.enemyPower.texture", label = "Bar texture", options = Bars, unknown = "Custom texture",
          tooltip = "The fill texture for the power bar." },
        { type = "ToggleColor", path = "look.enemyPower.border", colorPath = "look.enemyPower.borderColor", label = "Border",
          tooltip = "A thin border around the power bar." },
        { type = "Toggle", path = "look.enemyPower.smooth", label = "Smooth changes",
          tooltip = "The bar slides to its new value instead of jumping." },
        { type = "Toggle", path = "look.enemyPower.hideFull", label = "Hide at full power",
          tooltip = "Hides the power bar while the enemy's power is full, so it appears once they start spending it." }
    ), GateList(PowerText, PowerTextReason,
        { type = "Dropdown", path = "look.enemyPower.textFormat", label = "Text format", options = POWER_TEXT_FORMATS,
          tooltip = "Percent, the current amount abbreviated, or both." },
        { type = "Dropdown", path = "look.enemyPower.textAnchor", label = "Text position", options = POWER_TEXT_ANCHORS,
          tooltip = "Where the text sits on the power bar." },
        { type = "Dropdown", path = "look.enemyPower.font", label = "Font", options = Fonts, unknown = "Custom font",
          tooltip = "The typeface used for the power text." },
        { type = "Dropdown", path = "look.enemyPower.outline", label = "Font outline", options = OUTLINES,
          tooltip = "The dark edge drawn around each letter, to keep it readable over any background." }
    ))),

    Section("classPower", "Class resource", "look.classPower", Join(
        List(
            { type = "Header", label = "Class resource", first = true },
            { type = "Note", label = "Display your class resource on your target's nameplate. Available resources depend on your class.", height = 44 },
            { type = "Toggle", path = "look.classPower.enabled", label = "Show class resource on target",
              tooltip = "Adds your own resource to your current hostile target's nameplate: combo points (Rogue, and Druid while in Cat Form), holy power (Paladin), soul shards (Warlock), chi (Windwalker Monk), arcane charges (Arcane Mage), essence (Evoker) or runes (Death Knight). This is your resource, not the target's power (see Enemy power bar). Other classes and specs show nothing, and so does having no target or a friendly one." }
        ), GateTable(On("look.classPower.enabled"), "Turn on Show class resource on target to use this.", List(
            { type = "Toggle", path = "look.classPower.classColor", label = "Use class color",
              tooltip = "Colors each filled segment with your class color instead of the Color below." },
            Gate({ type = "Color", path = "look.classPower.color", label = "Color",
              tooltip = "Color of each filled segment. Used whenever Use class color is off." }, Off("look.classPower.classColor"), "Not used while Use class color is on."),
            { type = "Color", path = "look.classPower.emptyColor", label = "Empty segment color",
              tooltip = "Color of each segment that isn't filled, meaning resource you don't have right now. Death Knight runes that are recharging aren't shown this way: they stay full and are dimmed. Soul shards fill in tenths, so a partly full shard fills partway." },
            { type = "Slider", path = "look.classPower.pipWidth", label = "Segment width (0 = match health bar)", min = 0, max = 40,
              tooltip = "How wide each segment of the resource is. At 0 the segments stretch so the whole resource is exactly as wide as the health bar, like the cast bar's width setting." },
            { type = "Slider", path = "look.classPower.pipHeight", label = "Segment height", min = 2, max = 24,
              tooltip = "How tall each segment of the resource is." },
            { type = "Slider", path = "look.classPower.spacing", label = "Segment spacing", min = 0, max = 10,
              tooltip = "Gap between adjacent segments." }
        )),
        GateList(On("look.classPower.enabled"), "Turn on Show class resource on target to use this.", Placement("look.classPower")),
        List({ type = "Header", label = "Extras" }),
        GateList(On("look.classPower.enabled"), "Turn on Show class resource on target to use this.",
            { type = "Toggle", path = "look.classPower.hideEmpty", label = "Hide when empty",
              tooltip = "Hides the resource while you have none of it, like no combo points. Death Knight runes always show." },
            { type = "Toggle", path = "look.classPower.glowMax", label = "Glow at maximum",
              tooltip = "The resource glows in its own color while it is full, as a cue to spend it." }
        )
    )),

    Section("classification", "Elite icon", "look.classification", Join(List(
        { type = "Header", label = "Elite, rare and boss icon", first = true },
        { type = "Toggle", path = "look.classification.enabled", label = "Show classification icon",
          tooltip = "The master switch for Blizzard's elite/rare/boss badge. The four switches below choose which classifications get it. Separate from Plateau's own enemy-type coloring." }
    ), GateList(On("look.classification.enabled"), "Turn on Show classification icon to use this.",
        { type = "Toggle", path = "look.classification.showElite", label = "Elites (gold)",
          tooltip = "Shows the badge on elites." },
        { type = "Toggle", path = "look.classification.showRareElite", label = "Rare elites (silver)",
          tooltip = "Shows the badge on rare elites." },
        { type = "Toggle", path = "look.classification.showRare", label = "Rares (star)",
          tooltip = "Shows the badge on rares." },
        { type = "Toggle", path = "look.classification.showBoss", label = "World bosses (gold)",
          tooltip = "Shows the gold badge on enemies the game classifies as world bosses. That is the game's own classification, so not every dungeon or raid boss counts." }
    ), GateList(BadgeOn, BadgeReason,
        { type = "Slider", path = "look.classification.size", label = "Icon size", min = 8, max = 40,
          tooltip = "How big the badge is." },
        Placement("look.classification")
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
              tooltip = "The look of Plateau's settings window and pop-ups. Workbench is flat charcoal with a green accent; Artisan Ledger is walnut and brass with a serif title face; Lixard Classic is near-black, square and gold. Your nameplates don't change. Takes effect after a reload." },
            { type = "Dropdown", label = "Brand colour", keywords = "color colour brand icon minimap class rainbow cycle random logo",
              options = { { value = "class", label = "Class colour" }, { value = "cycle", label = "Colour cycle" }, { value = "random", label = "Random each login" } },
              get = function() return Plateau.Brand:Mode() end,
              set = function(value) Plateau.Brand:SetMode(value) end,
              reset = function() Plateau.Brand:SetMode("class") end,
              tooltip = "The colour of Plateau's P icon and name on the minimap button, the game menu button and Plateau's chat messages. This window's title uses the window theme's own colour. Class colour follows the character you're playing; Colour cycle slowly shifts through the rainbow; Random each login picks a new colour every time you log in. The icon in the game's addon list can't change colour." },
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
              tooltip = "How big this settings window is, on top of your game's UI scale. 1.00 is normal size. Your nameplates don't change." },
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
              tooltip = "The font for labels, buttons and descriptions in this settings window. Theme font uses the one that comes with the window theme. Fonts from other addons appear here too. Your nameplates don't change; set their fonts on the Name and Health text pages. Takes effect after a reload." },
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
              tooltip = "The font for page titles, section headings and the Plateau name in this settings window. Theme font uses the one that comes with the window theme. Takes effect after a reload." },
            { type = "Header", label = "Help and access" },
            { type = "Toggle", label = "Show settings tooltips",
              get = function() return Plateau.DB.saved.global.tooltipsEnabled ~= false end,
              set = function(value) Plateau.DB.saved.global.tooltipsEnabled = value == true end,
              tooltip = "Off hides the hover tooltips that explain what each setting does, for when you already know your way around. Right-click-to-reset hints and instance-limit warnings still show." },
            { type = "Toggle", label = "Show Plateau in game menu",
              get = function() return not Plateau.DB.saved.global.hideMenuButton end,
              set = function(value) Plateau.DB.saved.global.hideMenuButton = not value end,
              tooltip = "The button above AddOns in the Escape menu. Turn it off if you would rather open the settings with /plt. Takes effect the next time the menu opens." },
            { type = "Toggle", label = "Show minimap button", visibleIf = function() return Plateau.Minimap ~= nil end,
              get = function() return Plateau.Minimap ~= nil and Plateau.Minimap:IsShown() end,
              set = function(value) Plateau.Minimap:SetShown(value == true) end,
              tooltip = "A Plateau button on the edge of the minimap that opens the settings. Drag it to move it around the minimap. /plt minimap also shows or hides it." },
            { type = "Toggle", label = "Show in the addon list by the minimap", visibleIf = function() return Plateau.Minimap ~= nil and Plateau.Minimap:HasCompartment() end,
              get = function() return Plateau.Minimap ~= nil and Plateau.Minimap:InCompartment() end,
              set = function(value) Plateau.Minimap:SetCompartment(value == true) end,
              tooltip = "Adds Plateau to the game's addon dropdown next to the minimap, so the settings are a click away even with the minimap button hidden." }
        ),
    },

    {
        key = "profiles",
        title = "Profiles",
        noReset = true,
        controls = List(
            { type = "Note", label = "Profiles store your nameplate look and your aura spell lists. Each character has its own default profile.", height = 24 },
            { type = "ProfileStatus", label = "Default profile", keywords = "active profile override reason pending switch character",
              tooltip = "The profile this character falls back to when no automatic rule applies. The active profile is the one every page edits." },
            { type = "Header", label = "Manage profiles", keywords = "create new duplicate active rename copy settings from replace current delete restore built-in" },
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
    health = {
        HeaderPick("enemy", "Preview enemy", PREVIEW_ENEMIES, "The kind of enemy the preview shows, so you can see its color." .. NOT_SAVED),
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
