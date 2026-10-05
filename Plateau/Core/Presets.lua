local _, ns = ...

ns.presets = {
    looks = {
        {
            key = "big",
            label = "Big & bold",
            subtitle = "Easy to read",
            summary = "Wide, tall plates with large outlined text and a big cast bar. Made to be read at a glance.",
            accent = 3,
            tooltip = "Wide, tall plates with large outlined text, value and percent health centered on the bar, thicker borders, roomier icon spacing and a big cast bar.",
            values = {
                ["look.name.gap"] = 4,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.offsetX"] = 0,
                ["look.level.offsetX"] = 4,
                ["look.raidMarker.gap"] = 6,
                ["look.classification.gap"] = 4,
                ["look.auras.mine.offsetY"] = 20,
                ["look.auras.cc.offsetX"] = 0,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.purge.offsetX"] = 0,
                ["look.auras.purge.offsetY"] = 0,
                ["look.auras.important.offsetY"] = -24,
                ["look.castbar.gap"] = 4,
                ["look.plate.width"] = 170,
                ["look.plate.height"] = 18,
                ["look.health.borderSize"] = 2,
                ["look.name.size"] = 13,
                ["look.name.outline"] = "THICKOUTLINE",
                ["look.healthText.format"] = "both",
                ["look.healthText.size"] = 11,
                ["look.level.size"] = 11,
                ["look.castbar.height"] = 14,
                ["look.castbar.size"] = 10,
                ["look.castbar.borderSize"] = 2,
                ["look.auras.mine.size"] = 24,
                ["look.auras.cc.size"] = 24,
                ["look.auras.purge.size"] = 24,
                ["look.auras.important.size"] = 24,
                ["look.classification.size"] = 18,
                ["look.raidMarker.size"] = 22,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.forces.offsetX"] = -17,
                ["look.forces.offsetY"] = 18,
                ["look.raidMarker.offsetX"] = -19,
            },
        },
        {
            key = "normal",
            label = "Normal",
            subtitle = "Default",
            summary = "Balanced everyday plates: name above, health on the bar and a full cast bar. The look Plateau is built around.",
            accent = 1,
            tooltip = "Plateau's standard look and layout: name centered above, percent health on the right of the bar, level on the left, raid marker left and elite icon right of the plate, your debuffs above, crowd control left, enemy buffs right, and a full cast bar with icon, timer and target.",
            values = {
                ["look.auras.cc.offsetX"] = 0,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.purge.offsetX"] = 6,
                ["look.auras.purge.offsetY"] = 0,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.forces.offsetX"] = -11,
                ["look.forces.offsetY"] = 15,
                ["look.raidMarker.offsetX"] = -18,},
        },
        {
            key = "slim",
            label = "Slim",
            subtitle = "Big pulls",
            summary = "Thin bars and small text that stay readable when a whole room is on screen.",
            accent = 2,
            tooltip = "Thinner bars and small text for crowded pulls: no health text or level, the name on the left, your debuffs above on the right, tight spacing and a slim cast bar without icon or timer.",
            values = {
                ["look.name.gap"] = 2,
                ["look.raidMarker.gap"] = 3,
                ["look.classification.gap"] = 2,
                ["look.auras.mine.align"] = "LEFT",
                ["look.auras.mine.offsetY"] = 19,
                ["look.auras.cc.offsetX"] = -4,
                ["look.auras.purge.offsetX"] = 4,
                ["look.auras.important.offsetY"] = -12,
                ["look.castbar.gap"] = 2,
                ["look.plate.width"] = 130,
                ["look.plate.height"] = 9,
                ["look.healthText.enabled"] = false,
                ["look.level.enabled"] = false,
                ["look.name.size"] = 10,
                ["look.castbar.height"] = 8,
                ["look.castbar.showIcon"] = false,
                ["look.castbar.showTimer"] = false,
                ["look.castbar.showTarget"] = false,
                ["look.auras.mine.size"] = 18,
                ["look.auras.cc.size"] = 18,
                ["look.auras.purge.size"] = 18,
                ["look.auras.important.size"] = 18,
                ["look.classification.size"] = 12,
                ["look.raidMarker.size"] = 16,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.auras.purge.offsetY"] = 0,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.mine.offsetX"] = 30,
                ["look.raidMarker.offsetY"] = -5,
                ["look.raidMarker.offsetX"] = -20,
                ["look.forces.offsetX"] = -17,
                ["look.forces.offsetY"] = 13,
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
            tooltip = "The author's own setup: a wide, tall bar with the name on the bar at the left, no cast bar border, health and target highlights, focus and casting plates that grow, a power bar below bosses, and debuffs, crowd control and enemy buffs placed around the bar.",
            values = {
                ["look.auras.cc.align"] = "RIGHT",
                ["look.auras.cc.offsetX"] = 0,
                ["look.auras.cc.offsetY"] = 2,
                ["look.auras.cc.side"] = "TOP",
                ["look.auras.important.enabled"] = true,
                ["look.auras.important.offsetY"] = 2,
                ["look.auras.important.side"] = "TOP",
                ["look.auras.mine.align"] = "RIGHT",
                ["look.auras.mine.offsetX"] = 2,
                ["look.auras.mine.offsetY"] = 0,
                ["look.auras.mine.side"] = "RIGHT",
                ["look.auras.purge.allBuffs"] = true,
                ["look.auras.purge.offsetX"] = -2,
                ["look.auras.purge.offsetY"] = 0,
                ["look.auras.purge.side"] = "LEFT",
                ["look.castbar.borderStyle"] = "none",
                ["look.castbar.gap"] = 1,
                ["look.castbar.height"] = 15,
                ["look.castbar.importantGlow"] = false,
                ["look.castbar.interruptHold"] = 1.5,
                ["look.castbar.kickMarkerWidth"] = 1,
                ["look.castbar.shadow"] = true,
                ["look.castbar.showIcon"] = false,
                ["look.castbar.showSpark"] = true,
                ["look.castbar.size"] = 10,
                ["look.castbar.targetSize"] = 10,
                ["look.classPower.enabled"] = false,
                ["look.classPower.offsetY"] = 14,
                ["look.classPower.position"] = "CENTER",
                ["look.classification.enabled"] = false,
                ["look.classification.gap"] = 26,
                ["look.classification.position"] = "TOPRIGHT",
                ["look.colors.quest"] = true,
                ["look.enemyPower.position"] = "below",
                ["look.enemyPower.showText"] = true,
                ["look.focus.arrowGap"] = 0,
                ["look.focus.arrowSize"] = 30,
                ["look.focus.arrowStyle"] = "block",
                ["look.focus.arrows"] = true,
                ["look.focus.ring"] = false,
                ["look.forces.gap"] = 2,
                ["look.forces.position"] = "TOP",
                ["look.friendly.enabled"] = true,
                ["look.friendly.npcNameScale"] = 4,
                ["look.friendly.npcs"] = false,
                ["look.health.borderInside"] = true,
                ["look.health.borderStyle"] = "none",
                ["look.healthText.decimals"] = 1,
                ["look.healthText.size"] = 10,
                ["look.level.enabled"] = false,
                ["look.level.size"] = 11,
                ["look.mouseover.ring"] = true,
                ["look.name.gap"] = 0,
                ["look.name.justify"] = "LEFT",
                ["look.name.position"] = "CENTER",
                ["look.name.width"] = 95,
                ["look.plate.clickCastBar"] = true,
                ["look.plate.height"] = 20,
                ["look.plate.stackSpace"] = "cast",
                ["look.plate.width"] = 180,
                ["look.quest.position"] = "TOP",
                ["look.quest.size"] = 22,
                ["look.quest.style"] = "UI-QuestPoiLegendary-QuestBang",
                ["look.raidMarker.position"] = "CENTER",
                ["look.raidMarker.size"] = 24,
                ["look.scaling.boss"] = 1.2,
                ["look.scaling.castPop"] = true,
                ["look.scaling.castScale"] = 1.2,
                ["look.scaling.enabled"] = true,
                ["look.scaling.focusGrow"] = true,
                ["look.scaling.trivial"] = 1,
                ["look.target.arrowGap"] = 0,
                ["look.target.arrowSize"] = 30,
                ["look.target.arrows"] = true,
                ["look.target.brighten"] = true,
                ["look.target.dimOthers"] = 0.9,
                ["look.target.glowSize"] = 10,
                ["look.target.ring"] = false,
                ["look.target.scale"] = 1.2,
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
    { name = "Slim", group = "looks", key = "slim" },
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
