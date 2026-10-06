local addonName, ns = ...

local GLOSS = "Interface\\AddOns\\" .. addonName .. "\\Art\\Bars\\bar-gloss.png"
local PERL_GREY = { 0.5, 0.5, 0.5, 1 }

ns.presets = {
    looks = {
        {
            key = "big",
            label = "Big & bold",
            subtitle = "Easy to read",
            summary = "Wide, tall plates with large outlined text and a big cast bar. Made to be read at a glance.",
            accent = 3,
            tooltip = "Wide, tall plates with a large outlined name, value and percent health centered on the bar, thicker borders, smooth health with a spark, animated target arrows, important buffs above the bar, and a big cast bar with the timer in the middle and the target on the right.",
            values = {
                ["look.plate.width"] = 170,
                ["look.plate.height"] = 18,
                ["look.health.borderSize"] = 2,
                ["look.health.desaturate"] = true,
                ["look.health.smooth"] = true,
                ["look.health.spark"] = true,
                ["look.name.gap"] = 4,
                ["look.name.outline"] = "THICKOUTLINE",
                ["look.name.size"] = 13,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.format"] = "both",
                ["look.healthText.offsetX"] = 0,
                ["look.healthText.size"] = 11,
                ["look.level.enabled"] = false,
                ["look.level.offsetX"] = 4,
                ["look.level.size"] = 11,
                ["look.castbar.borderSize"] = 2,
                ["look.castbar.gap"] = 1,
                ["look.castbar.height"] = 14,
                ["look.castbar.showIcon"] = false,
                ["look.castbar.showSpark"] = true,
                ["look.castbar.size"] = 10,
                ["look.castbar.targetClassColor"] = true,
                ["look.castbar.targetPosition"] = "INSIDERIGHT",
                ["look.castbar.timerOffsetY"] = 1,
                ["look.castbar.timerPosition"] = "CENTER",
                ["look.auras.cc.offsetX"] = 0,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.important.enabled"] = true,
                ["look.auras.important.offsetY"] = 2,
                ["look.auras.important.side"] = "TOP",
                ["look.auras.mine.align"] = "CENTER",
                ["look.auras.mine.offsetY"] = 22,
                ["look.auras.purge.offsetX"] = 0,
                ["look.auras.purge.offsetY"] = 0,
                ["look.classPower.enabled"] = false,
                ["look.classPower.offsetY"] = 11,
                ["look.classPower.position"] = "CENTER",
                ["look.classification.enabled"] = false,
                ["look.classification.gap"] = 4,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.classification.size"] = 18,
                ["look.enemyPower.enabled"] = false,
                ["look.enemyTarget.enabled"] = true,
                ["look.forces.offsetX"] = -17,
                ["look.forces.offsetY"] = 18,
                ["look.quest.position"] = "TOP",
                ["look.raidMarker.gap"] = 6,
                ["look.raidMarker.offsetY"] = -8,
                ["look.raidMarker.position"] = "TOP",
                ["look.raidMarker.size"] = 22,
                ["look.target.animateArrows"] = true,
                ["look.target.arrowGap"] = 36,
                ["look.target.arrowSize"] = 20,
                ["look.target.arrows"] = true,
            },
        },
        {
            key = "normal",
            label = "Normal",
            subtitle = "Default",
            summary = "Balanced everyday plates: name above, health on the bar and a full cast bar. The look Plateau is built around.",
            accent = 1,
            tooltip = "Plateau's standard look: a medium bar with the name centered above, percent health on the right, health that fills smoothly with a spark and fades from its color as it drops, the raid marker on top, important buffs above on the right, the name of whoever each enemy is targeting, animated target arrows, and a full cast bar with icon, timer and target.",
            values = {
                ["look.plate.width"] = 150,
                ["look.plate.height"] = 14,
                ["look.health.desaturate"] = true,
                ["look.health.smooth"] = true,
                ["look.health.spark"] = true,
                ["look.colors.healthGradient"] = true,
                ["look.name.size"] = 11,
                ["look.healthText.offsetX"] = 0,
                ["look.healthText.size"] = 10,
                ["look.level.enabled"] = false,
                ["look.castbar.gap"] = 1,
                ["look.castbar.height"] = 11,
                ["look.castbar.size"] = 9,
                ["look.castbar.targetOffsetX"] = -17,
                ["look.castbar.targetPosition"] = "INSIDERIGHT",
                ["look.auras.cc.offsetX"] = -2,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.important.align"] = "RIGHT",
                ["look.auras.important.enabled"] = true,
                ["look.auras.important.offsetY"] = 2,
                ["look.auras.important.side"] = "TOP",
                ["look.auras.purge.offsetX"] = 6,
                ["look.auras.purge.offsetY"] = 0,
                ["look.classPower.enabled"] = false,
                ["look.classification.enabled"] = false,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.enemyPower.enabled"] = false,
                ["look.enemyTarget.anchor"] = "CENTER",
                ["look.enemyTarget.enabled"] = true,
                ["look.forces.offsetX"] = -18,
                ["look.forces.position"] = "INSIDELEFT",
                ["look.quest.position"] = "TOP",
                ["look.raidMarker.offsetY"] = -2,
                ["look.raidMarker.position"] = "TOP",
                ["look.target.animateArrows"] = true,
                ["look.target.arrows"] = true,
            },
        },
        {
            key = "zperl",
            label = "Z-Perl",
            subtitle = "Classic unit frames",
            summary = "Styled after Z-Perl unit frames: glossy bars in grey tooltip borders with soft shadowed text.",
            accent = 2,
            tooltip = "Styled after Z-Perl unit frames: a glossy bar inside a thin grey tooltip border on black, the name above and percent health centered in plain shadowed text that turns green, yellow and red as health drops, the level on the left, the raid marker on the top-left corner, a soft yellow glow on your target, and a matching glossy cast bar with icon.",
            values = {
                ["look.plate.width"] = 140,
                ["look.plate.height"] = 12,
                ["look.health.texture"] = GLOSS,
                ["look.health.background"] = { 0, 0, 0, 1 },
                ["look.health.borderStyle"] = "thinTooltip",
                ["look.health.border"] = PERL_GREY,
                ["look.health.borderSize"] = 1,
                ["look.health.smooth"] = true,
                ["look.name.gap"] = 4,
                ["look.name.outline"] = "",
                ["look.name.shadow"] = true,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.offsetX"] = 0,
                ["look.healthText.outline"] = "",
                ["look.healthText.shadow"] = true,
                ["look.healthText.colorByHealth"] = true,
                ["look.level.outline"] = "",
                ["look.level.shadow"] = true,
                ["look.castbar.texture"] = GLOSS,
                ["look.castbar.background"] = { 0, 0, 0, 1 },
                ["look.castbar.borderStyle"] = "thinTooltip",
                ["look.castbar.border"] = PERL_GREY,
                ["look.castbar.borderSize"] = 1,
                ["look.castbar.gap"] = 6,
                ["look.castbar.outline"] = "",
                ["look.castbar.shadow"] = true,
                ["look.raidMarker.position"] = "TOPLEFT",
                ["look.raidMarker.offsetX"] = -6,
                ["look.raidMarker.offsetY"] = -8,
                ["look.raidMarker.size"] = 16,
                ["look.target.ring"] = false,
                ["look.target.glow"] = true,
                ["look.target.glowColor"] = { 1, 1, 0.5, 0.6 },
            },
        },
    },
    styles = {
        {
            key = "inside",
            label = "Compact",
            subtitle = "Name on the bar",
            summary = "A wide bar with the name and health inside it, so each plate takes up as little height as possible.",
            accent = { 0.55, 0.66, 0.8, 1 },
            tooltip = "The author's own setup: a wide bar with the name on the bar at the left and health on the right, the raid marker and quest icon on top, your debuffs above on the left, important buffs above on the right, crowd control on the left, enemy buffs on the right, and a slim cast bar without icon.",
            values = {
                ["look.plate.width"] = 150,
                ["look.plate.height"] = 18,
                ["look.name.gap"] = 0,
                ["look.name.justify"] = "LEFT",
                ["look.name.overflow"] = "end",
                ["look.name.position"] = "CENTER",
                ["look.name.width"] = 95,
                ["look.healthText.size"] = 10,
                ["look.level.enabled"] = false,
                ["look.castbar.height"] = 12,
                ["look.castbar.showIcon"] = false,
                ["look.auras.cc.offsetX"] = 0,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.important.align"] = "RIGHT",
                ["look.auras.important.enabled"] = true,
                ["look.auras.important.offsetY"] = 2,
                ["look.auras.important.side"] = "TOP",
                ["look.auras.mine.offsetY"] = 4,
                ["look.auras.purge.align"] = "RIGHT",
                ["look.auras.purge.offsetX"] = 0,
                ["look.auras.purge.offsetY"] = 0,
                ["look.classPower.enabled"] = false,
                ["look.classification.enabled"] = false,
                ["look.classification.gap"] = 26,
                ["look.classification.offsetX"] = 55,
                ["look.classification.offsetY"] = 31,
                ["look.enemyPower.enabled"] = false,
                ["look.forces.offsetX"] = -16,
                ["look.forces.offsetY"] = 17,
                ["look.quest.position"] = "TOP",
                ["look.raidMarker.offsetY"] = -2,
                ["look.raidMarker.position"] = "TOP",
            },
        },
    },
    palettes = {
        {
            key = "redGreen",
            label = "Red-green preset",
            tooltip = "For deuteranopia and protanopia. Built on the Okabe-Ito palette, the usual colorblind-safe set. Click twice to apply now: recolors reaction, enemy type, threat, and cast bar colors. A starting point, not a guarantee it's ideal for your own eyes - adjust any color afterward.",
            values = {
                ["look.colors.customReaction"] = true,
                ["look.colors.hostile"] = { 0.84, 0.37, 0, 1 },
                ["look.colors.neutral"] = { 0.94, 0.89, 0.26, 1 },
                ["look.colors.bossColor"] = { 0.8, 0.47, 0.65, 1 },
                ["look.colors.lieutenantColor"] = { 0.9, 0.62, 0, 1 },
                ["look.colors.casterColor"] = { 0.34, 0.71, 0.91, 1 },
                ["look.colors.eliteColor"] = { 0, 0.45, 0.7, 1 },
                ["look.colors.trivialColor"] = { 0.6, 0.6, 0.6, 1 },
                ["look.colors.threatBad"] = { 0.94, 0.89, 0.26, 1 },
                ["look.colors.threatWarning"] = { 0.9, 0.62, 0, 1 },
                ["look.colors.threatGood"] = { 0, 0.62, 0.45, 1 },
                ["look.castbar.readyColor"] = { 0, 0.62, 0.45, 1 },
                ["look.castbar.notReadyColor"] = { 0.9, 0.62, 0, 1 },
                ["look.castbar.importantReadyColor"] = { 0.34, 0.71, 0.91, 1 },
                ["look.castbar.importantNotReadyColor"] = { 0.84, 0.37, 0, 1 },
                ["look.castbar.uninterruptible"] = { 0.6, 0.6, 0.6, 1 },
                ["look.castbar.importantUninterruptible"] = { 0.94, 0.89, 0.26, 1 },
            },
        },
        {
            key = "blueYellow",
            label = "Blue-yellow preset",
            tooltip = "For tritanopia: avoids blue-green and yellow-violet pairs, leaning on red, cyan and magenta. Click twice to apply now: recolors reaction, enemy type, threat, and cast bar colors. A starting point, not a guarantee it's ideal for your own eyes - adjust any color afterward.",
            values = {
                ["look.colors.customReaction"] = true,
                ["look.colors.hostile"] = { 0.86, 0.15, 0.15, 1 },
                ["look.colors.neutral"] = { 1, 0.6, 0.8, 1 },
                ["look.colors.bossColor"] = { 0.9, 0.1, 0.6, 1 },
                ["look.colors.lieutenantColor"] = { 0.95, 0.95, 0.95, 1 },
                ["look.colors.casterColor"] = { 0, 0.8, 0.8, 1 },
                ["look.colors.eliteColor"] = { 0.6, 0, 0, 1 },
                ["look.colors.trivialColor"] = { 0.55, 0.55, 0.55, 1 },
                ["look.colors.threatBad"] = { 0.9, 0.1, 0.6, 1 },
                ["look.colors.threatWarning"] = { 1, 0.6, 0.8, 1 },
                ["look.colors.threatGood"] = { 0, 0.8, 0.8, 1 },
                ["look.castbar.readyColor"] = { 0, 0.8, 0.8, 1 },
                ["look.castbar.notReadyColor"] = { 0.86, 0.15, 0.15, 1 },
                ["look.castbar.importantReadyColor"] = { 0.9, 0.1, 0.6, 1 },
                ["look.castbar.importantNotReadyColor"] = { 1, 1, 1, 1 },
                ["look.castbar.uninterruptible"] = { 0.45, 0.45, 0.45, 1 },
                ["look.castbar.importantUninterruptible"] = { 1, 0.6, 0.8, 1 },
            },
        },
    },
}

local function Default(path)
    local node = ns.defaults
    for part in path:gmatch("[^%.]+") do
        node = node and node[part]
    end
    if type(node) == "table" then
        return { node[1], node[2], node[3], node[4] }
    end
    return node
end

local LAYOUT = {
    "look.name.position", "look.name.justify", "look.name.gap", "look.name.width", "look.name.overflow",
    "look.healthText.anchor", "look.healthText.offsetX", "look.healthText.offsetY",
    "look.level.anchor", "look.level.offsetX", "look.level.offsetY",
    "look.raidMarker.position", "look.raidMarker.gap", "look.raidMarker.offsetX", "look.raidMarker.offsetY",
    "look.health.borderStyle", "look.castbar.borderStyle", "look.health.borderInside", "look.castbar.borderInside",
    "look.classification.position", "look.classification.gap", "look.classification.offsetX", "look.classification.offsetY",
    "look.quest.position", "look.quest.gap", "look.quest.offsetX", "look.quest.offsetY",
    "look.forces.position", "look.forces.gap", "look.forces.offsetX", "look.forces.offsetY",
    "look.castbar.gap", "look.castbar.width", "look.castbar.targetPosition", "look.castbar.targetOffsetX", "look.castbar.targetOffsetY", "look.castbar.iconSide", "look.castbar.iconSpan",
    "look.enemyTarget.enabled", "look.enemyTarget.anchor", "look.enemyTarget.offsetX", "look.enemyTarget.offsetY",
}
for _, group in ipairs({ "mine", "cc", "purge", "important" }) do
    for _, key in ipairs({ "side", "align", "grow", "offsetX", "offsetY", "perRow", "spacing" }) do
        LAYOUT[#LAYOUT + 1] = "look.auras." .. group .. "." .. key
    end
end

local function Complete(list)
    local keys = {}
    for _, path in ipairs(LAYOUT) do
        keys[path] = true
    end
    for _, preset in ipairs(list) do
        for path in pairs(preset.values) do
            keys[path] = true
        end
    end
    for _, preset in ipairs(list) do
        for path in pairs(keys) do
            if preset.values[path] == nil then
                preset.values[path] = Default(path)
            end
        end
    end
end

local function Copy(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = type(value) == "table" and Copy(value) or value
    end
    return copy
end

function ns.PresetLook(preset)
    if preset.look then
        return preset.look
    end
    local look = Copy(ns.defaults.look)
    for path, value in pairs(preset.values) do
        local node = { look = look }
        local parent, key
        for part in path:gmatch("[^%.]+") do
            parent, key = node, part
            node = type(node) == "table" and node[part] or nil
        end
        if parent and key then
            parent[key] = type(value) == "table" and Copy(value) or value
        end
    end
    preset.look = look
    return look
end

Complete(ns.presets.looks)
Complete(ns.presets.styles)

local Builtins = {}
ns.Builtins = Builtins

Builtins.list = {
    { name = "Big & bold", group = "looks", key = "big" },
    { name = "Normal", group = "looks", key = "normal" },
    { name = "Z-Perl", group = "looks", key = "zperl" },
    { name = "Compact", group = "styles", key = "inside" },
}

Builtins.defaultName = "Normal"

local byName = {}
for _, entry in ipairs(Builtins.list) do
    byName[entry.name] = entry
end

function Builtins.ByName(name)
    return byName[name]
end

local function Preset(entry)
    for _, preset in ipairs(ns.presets[entry.group] or {}) do
        if preset.key == entry.key then
            return preset
        end
    end
end

function Builtins.ForPreset(preset)
    for _, entry in ipairs(Builtins.list) do
        if Preset(entry) == preset then
            return entry
        end
    end
end

function Builtins.Values(entry)
    local preset = Preset(entry)
    return preset and preset.values or {}
end

function Builtins.Label(name)
    if byName[name] then
        return name .. "  |cff8a93a6(built-in)|r"
    end
    return name
end
