local addonName, ns = ...

local L = ns.L

local GLOSS = "Interface\\AddOns\\" .. addonName .. "\\Art\\Bars\\bar-gloss.png"
local TOOLTIP_GREY = { 0.5, 0.5, 0.5, 1 }
local SMOOTH = "Interface\\AddOns\\" .. addonName .. "\\Art\\Bars\\bar-smooth.png"
local ARIAL_NARROW = "Fonts\\ARIALN.TTF"

ns.presets = {
    looks = {
        {
            key = "familiar",
            label = "Blizzard-like",
            summary = "Small flat bar with a soft dark edge.",
            accent = { 0.98, 0.72, 0.28, 1 },
            tooltip = "120 by 14 flat bar with a soft dark edge. Glow and corner brackets on your target.",
            values = {
                ["look.plate.width"] = 120,
                ["look.plate.height"] = 14,
                ["look.health.background"] = { 0.114, 0.114, 0.114, 0.89 },
                ["look.health.border"] = { 0, 0, 0, 0.834 },
                ["look.name.font"] = ARIAL_NARROW,
                ["look.name.size"] = 11,
                ["look.name.outline"] = "",
                ["look.name.shadow"] = true,
                ["look.name.position"] = "BOTTOM",
                ["look.name.gap"] = 1,
                ["look.name.hideCasting"] = true,
                ["look.healthText.font"] = ARIAL_NARROW,
                ["look.healthText.format"] = "both",
                ["look.healthText.decimals"] = 1,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.offsetX"] = 0,
                ["look.level.font"] = ARIAL_NARROW,
                ["look.level.size"] = 8,
                ["look.level.outline"] = "",
                ["look.level.shadow"] = true,
                ["look.level.anchor"] = "TOPRIGHT",
                ["look.level.offsetX"] = 0,
                ["look.level.offsetY"] = 1,
                ["look.castbar.font"] = ARIAL_NARROW,
                ["look.castbar.size"] = 10,
                ["look.castbar.gap"] = 0,
                ["look.castbar.height"] = 10,
                ["look.castbar.background"] = { 0.114, 0.114, 0.114, 0.89 },
                ["look.castbar.border"] = { 0, 0, 0, 0.834 },
                ["look.castbar.textJustify"] = "CENTER",
                ["look.castbar.timerOffsetX"] = -2,
                ["look.castbar.showSpark"] = true,
                ["look.castbar.showTarget"] = false,
                ["look.target.ring"] = false,
                ["look.target.glow"] = true,
                ["look.target.brackets"] = true,
                ["look.target.bracketStyle"] = "claim",
                ["look.target.bracketSize"] = 8,
                ["look.target.bracketGap"] = 2,
                ["look.target.dimOthers"] = 0.6,
                ["look.target.dimCombatOnly"] = true,
                ["look.range.enabled"] = true,
                ["look.range.alpha"] = 0.65,
                ["look.mouseover.brightenAmount"] = 0.3,
                ["look.auras.mine.align"] = "LEFT",
                ["look.auras.mine.offsetY"] = 5,
                ["look.auras.mine.size"] = 24,
                ["look.auras.mine.shape"] = "flat",
                ["look.auras.mine.timerSize"] = 11,
                ["look.auras.purge.side"] = "TOP",
                ["look.auras.purge.align"] = "RIGHT",
                ["look.auras.purge.offsetX"] = 0,
                ["look.auras.purge.offsetY"] = 5,
                ["look.auras.purge.size"] = 24,
                ["look.auras.purge.shape"] = "flat",
                ["look.auras.cc.side"] = "RIGHT",
                ["look.auras.cc.offsetX"] = 4,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.cc.size"] = 26,
                ["look.auras.cc.shape"] = "flat",
                ["look.raidMarker.position"] = "LEFT",
                ["look.raidMarker.gap"] = 2,
                ["look.raidMarker.size"] = 22,
                ["look.classification.position"] = "TOPLEFT",
                ["look.classification.size"] = 12,
                ["look.quest.position"] = "LEFT",
                ["look.forces.position"] = "INSIDELEFT",
                ["look.forces.offsetX"] = 0,
            },
        },
        {
            key = "minimal",
            label = "Minimal",
            summary = "Thin bar with a fine black edge.",
            accent = { 0.27, 0.82, 0.76, 1 },
            tooltip = "100 by 12 bar with a fine black edge and a spark. Glow on your target.",
            values = {
                ["look.plate.width"] = 100,
                ["look.plate.height"] = 12,
                ["look.health.background"] = { 0, 0, 0, 0.9 },
                ["look.health.border"] = { 0, 0, 0, 0.9 },
                ["look.health.spark"] = true,
                ["look.health.smooth"] = true,
                ["look.name.font"] = ARIAL_NARROW,
                ["look.name.size"] = 11,
                ["look.name.gap"] = -3,
                ["look.healthText.enabled"] = false,
                ["look.level.enabled"] = false,
                ["look.castbar.font"] = ARIAL_NARROW,
                ["look.castbar.size"] = 9,
                ["look.castbar.height"] = 8,
                ["look.castbar.gap"] = 1,
                ["look.castbar.background"] = { 0, 0, 0, 0.9 },
                ["look.castbar.border"] = { 0, 0, 0, 0.9 },
                ["look.castbar.iconSpan"] = true,
                ["look.castbar.textJustify"] = "CENTER",
                ["look.castbar.showTimer"] = false,
                ["look.castbar.showTarget"] = false,
                ["look.target.ring"] = false,
                ["look.target.glow"] = true,
                ["look.target.glowSize"] = 8,
                ["look.target.dimOthers"] = 0.5,
                ["look.target.dimCombatOnly"] = true,
                ["look.mouseover.brightenAmount"] = 0.4,
                ["look.auras.mine.align"] = "CENTER",
                ["look.auras.mine.offsetY"] = 15,
                ["look.auras.mine.size"] = 24,
                ["look.auras.mine.shape"] = "wide",
                ["look.auras.mine.maxIcons"] = 10,
                ["look.auras.mine.perRow"] = 5,
                ["look.auras.purge.size"] = 24,
                ["look.auras.purge.shape"] = "wide",
                ["look.auras.purge.offsetY"] = 0,
                ["look.raidMarker.position"] = "RIGHT",
                ["look.raidMarker.gap"] = 8,
                ["look.raidMarker.size"] = 24,
                ["look.quest.position"] = "LEFT",
                ["look.quest.size"] = 18,
                ["look.classification.position"] = "BOTTOMLEFT",
                ["look.classification.size"] = 16,
                ["look.classification.showElite"] = false,
                ["look.forces.position"] = "INSIDERIGHT",
                ["look.forces.offsetX"] = 0,
            },
        },
        {
            key = "classic",
            label = "Unit frame",
            summary = "Glossy bar in a grey tooltip border.",
            accent = { 0.9, 0.28, 0.37, 1 },
            tooltip = "140 by 12 glossy bar in a grey tooltip border. Glow on your target.",
            values = {
                ["look.plate.width"] = 140,
                ["look.plate.height"] = 12,
                ["look.health.texture"] = GLOSS,
                ["look.health.background"] = { 0, 0, 0, 1 },
                ["look.health.borderStyle"] = "thinTooltip",
                ["look.health.border"] = TOOLTIP_GREY,
                ["look.health.borderSize"] = 1,
                ["look.health.smooth"] = true,
                ["look.name.gap"] = 4,
                ["look.name.outline"] = "",
                ["look.name.shadow"] = true,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.offsetX"] = 0,
                ["look.healthText.outline"] = "",
                ["look.healthText.shadow"] = true,
                ["look.level.outline"] = "",
                ["look.level.shadow"] = true,
                ["look.castbar.texture"] = GLOSS,
                ["look.castbar.background"] = { 0, 0, 0, 1 },
                ["look.castbar.borderStyle"] = "thinTooltip",
                ["look.castbar.border"] = TOOLTIP_GREY,
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
            },
        },
        {
            key = "flat",
            label = "Flat",
            summary = "Tall flat bar with a dark inner edge.",
            accent = { 0.31, 0.56, 0.97, 1 },
            tooltip = "156 by 17 flat bar with a dark inner edge and a tall cast bar. Glow on your target.",
            values = {
                ["look.plate.width"] = 156,
                ["look.plate.height"] = 17,
                ["look.health.background"] = { 0.12, 0.12, 0.12, 1 },
                ["look.health.border"] = { 0.067, 0.067, 0.067, 1 },
                ["look.health.borderInside"] = true,
                ["look.name.font"] = ARIAL_NARROW,
                ["look.name.size"] = 11,
                ["look.name.outline"] = "",
                ["look.name.shadow"] = true,
                ["look.name.gap"] = 4,
                ["look.healthText.font"] = ARIAL_NARROW,
                ["look.healthText.size"] = 11,
                ["look.healthText.outline"] = "",
                ["look.healthText.shadow"] = true,
                ["look.healthText.offsetX"] = -2,
                ["look.level.enabled"] = false,
                ["look.castbar.font"] = ARIAL_NARROW,
                ["look.castbar.size"] = 11,
                ["look.castbar.outline"] = "",
                ["look.castbar.shadow"] = true,
                ["look.castbar.height"] = 17,
                ["look.castbar.gap"] = 0,
                ["look.castbar.background"] = { 0.1, 0.1, 0.1, 0.9 },
                ["look.castbar.borderStyle"] = "none",
                ["look.castbar.showSpark"] = true,
                ["look.castbar.timerOffsetX"] = -3,
                ["look.castbar.targetPosition"] = "INSIDERIGHT",
                ["look.castbar.targetOffsetX"] = -30,
                ["look.castbar.targetSize"] = 10,
                ["look.target.ring"] = false,
                ["look.target.glow"] = true,
                ["look.target.glowSize"] = 6,
                ["look.auras.mine.align"] = "CENTER",
                ["look.auras.mine.offsetY"] = 18,
                ["look.auras.mine.size"] = 24,
                ["look.auras.mine.maxIcons"] = 5,
                ["look.auras.mine.perRow"] = 5,
                ["look.auras.purge.side"] = "LEFT",
                ["look.auras.purge.offsetX"] = -4,
                ["look.auras.purge.offsetY"] = 0,
                ["look.auras.purge.size"] = 22,
                ["look.auras.cc.side"] = "RIGHT",
                ["look.auras.cc.offsetX"] = 4,
                ["look.auras.cc.offsetY"] = 0,
                ["look.auras.cc.size"] = 22,
                ["look.raidMarker.position"] = "TOPRIGHT",
                ["look.raidMarker.size"] = 22,
                ["look.classification.position"] = "TOPLEFT",
                ["look.classification.size"] = 18,
                ["look.quest.position"] = "TOPLEFT",
                ["look.quest.offsetX"] = 20,
                ["look.forces.position"] = "INSIDELEFT",
                ["look.forces.offsetX"] = 0,
            },
        },
        {
            key = "bold",
            label = "Heavy",
            summary = "Shaded bar with a thick border.",
            accent = { 0.66, 0.52, 0.98, 1 },
            tooltip = "125 by 16 shaded bar with a thick slate border. Arrows on your target.",
            values = {
                ["look.plate.width"] = 125,
                ["look.plate.height"] = 16,
                ["look.health.texture"] = SMOOTH,
                ["look.health.background"] = { 0.2, 0.05, 0.05, 1 },
                ["look.health.border"] = { 0.16, 0.24, 0.23, 1 },
                ["look.health.borderSize"] = 2,
                ["look.health.spark"] = true,
                ["look.name.font"] = ARIAL_NARROW,
                ["look.name.size"] = 12,
                ["look.name.shadow"] = true,
                ["look.name.gap"] = 2,
                ["look.healthText.font"] = ARIAL_NARROW,
                ["look.healthText.format"] = "value",
                ["look.healthText.size"] = 12,
                ["look.healthText.shadow"] = true,
                ["look.healthText.anchor"] = "CENTER",
                ["look.healthText.offsetX"] = 0,
                ["look.level.enabled"] = false,
                ["look.castbar.font"] = ARIAL_NARROW,
                ["look.castbar.size"] = 11,
                ["look.castbar.shadow"] = true,
                ["look.castbar.height"] = 16,
                ["look.castbar.gap"] = 1,
                ["look.castbar.texture"] = SMOOTH,
                ["look.castbar.background"] = { 0.12, 0.12, 0.12, 1 },
                ["look.castbar.border"] = { 0.16, 0.24, 0.23, 1 },
                ["look.castbar.borderSize"] = 2,
                ["look.castbar.showTimer"] = false,
                ["look.castbar.targetPosition"] = "INSIDERIGHT",
                ["look.castbar.targetSize"] = 10,
                ["look.target.ring"] = false,
                ["look.target.arrows"] = true,
                ["look.target.arrowStyle"] = "chevron",
                ["look.target.arrowSize"] = 16,
                ["look.mouseover.ring"] = true,
                ["look.mouseover.ringSize"] = 2,
                ["look.auras.mine.offsetY"] = 18,
                ["look.auras.purge.side"] = "LEFT",
                ["look.auras.purge.offsetX"] = -4,
                ["look.auras.purge.offsetY"] = 0,
                ["look.auras.cc.side"] = "RIGHT",
                ["look.auras.cc.offsetX"] = 4,
                ["look.auras.cc.offsetY"] = 0,
                ["look.raidMarker.position"] = "TOP",
                ["look.raidMarker.gap"] = 18,
                ["look.raidMarker.size"] = 19,
                ["look.classification.position"] = "LEFT",
                ["look.classification.size"] = 15,
                ["look.forces.position"] = "INSIDELEFT",
                ["look.forces.offsetX"] = 0,
            },
        },
    },
    styles = {
        {
            key = "inside",
            label = "Compact",
            summary = "Short wide bar with the name inside, for big pulls.",
            accent = { 0.52, 0.84, 0.35, 1 },
            tooltip = "150 by 18 bar with the name inside on the left and health on the right, so each plate takes little height.",
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
            tooltip = "Colors for deuteranopia and protanopia, based on the Okabe-Ito palette. Click twice to recolor reaction, enemy type, threat and cast bar colors.",
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
            tooltip = "Colors for tritanopia, using red, cyan and magenta. Click twice to recolor reaction, enemy type, threat and cast bar colors.",
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
    "look.name.position", "look.name.justify", "look.name.offsetX", "look.name.gap", "look.name.width", "look.name.overflow",
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

local Copy = ns.DeepCopy

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

local SHARED = {
    ["look.name.position"] = "TOP",
    ["look.name.justify"] = "CENTER",
    ["look.name.offsetX"] = 0,
    ["look.name.hideCasting"] = false,
    ["look.healthText.enabled"] = true,
    ["look.healthText.format"] = "percent",
    ["look.healthText.anchor"] = "CENTER",
    ["look.healthText.offsetX"] = 0,
    ["look.healthText.offsetY"] = 0,
    ["look.level.enabled"] = false,
    ["look.classification.enabled"] = false,
    ["look.raidMarker.enabled"] = true,
    ["look.raidMarker.position"] = "LEFT",
    ["look.raidMarker.gap"] = 4,
    ["look.raidMarker.size"] = 20,
    ["look.raidMarker.offsetX"] = 0,
    ["look.raidMarker.offsetY"] = 0,
    ["look.quest.position"] = "TOPRIGHT",
    ["look.quest.gap"] = 2,
    ["look.quest.offsetX"] = 0,
    ["look.quest.offsetY"] = 0,
    ["look.forces.position"] = "INSIDELEFT",
    ["look.forces.offsetX"] = 0,
    ["look.forces.offsetY"] = 0,
    ["look.castbar.showIcon"] = true,
    ["look.castbar.iconSide"] = "LEFT",
    ["look.castbar.iconSpan"] = false,
    ["look.castbar.textJustify"] = "LEFT",
    ["look.castbar.showTimer"] = true,
    ["look.castbar.timerPosition"] = "INSIDERIGHT",
    ["look.castbar.showTarget"] = false,
    ["look.auras.mine.enabled"] = true,
    ["look.auras.mine.side"] = "TOP",
    ["look.auras.mine.align"] = "LEFT",
    ["look.auras.mine.offsetX"] = 0,
    ["look.auras.mine.offsetY"] = 18,
    ["look.auras.important.enabled"] = true,
    ["look.auras.important.side"] = "TOP",
    ["look.auras.important.align"] = "RIGHT",
    ["look.auras.important.offsetX"] = 0,
    ["look.auras.important.offsetY"] = 18,
    ["look.auras.purge.enabled"] = true,
    ["look.auras.purge.side"] = "LEFT",
    ["look.auras.purge.align"] = "LEFT",
    ["look.auras.purge.offsetX"] = -28,
    ["look.auras.purge.offsetY"] = 0,
    ["look.auras.cc.enabled"] = true,
    ["look.auras.cc.side"] = "RIGHT",
    ["look.auras.cc.align"] = "LEFT",
    ["look.auras.cc.offsetX"] = 4,
    ["look.auras.cc.offsetY"] = 0,
}

local SHARED_DEFAULTS = {
    "look.target.dimOthers", "look.target.dimCombatOnly", "look.range.enabled", "look.range.alpha",
    "look.castbar.timerOffsetX", "look.castbar.targetPosition", "look.castbar.targetOffsetX", "look.castbar.targetSize",
    "look.classification.position", "look.classification.size", "look.classification.gap", "look.classification.offsetX",
    "look.classification.offsetY", "look.classification.showElite", "look.quest.size",
    "look.auras.mine.maxIcons", "look.auras.mine.perRow", "look.classPower.enabled", "look.enemyPower.enabled",
}

local OWN = {
    inside = {
        ["look.name.position"] = "CENTER",
        ["look.name.justify"] = "LEFT",
        ["look.healthText.anchor"] = "RIGHT",
        ["look.healthText.offsetX"] = -3,
        ["look.forces.position"] = "TOP",
        ["look.forces.gap"] = 2,
    },
}

local function SharedDefault(path)
    local node = ns.defaults
    for part in path:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[part]
    end
    return node
end

function ns.SharedLookValues(preset)
    local values = {}
    for path, value in pairs(SHARED) do
        values[path] = value
    end
    for _, path in ipairs(SHARED_DEFAULTS) do
        values[path] = SharedDefault(path)
    end
    for path, value in pairs(OWN[preset.key] or {}) do
        values[path] = value
    end
    return values
end

for _, group in ipairs({ ns.presets.looks, ns.presets.styles }) do
    for _, preset in ipairs(group) do
        for path, value in pairs(ns.SharedLookValues(preset)) do
            preset.values[path] = value
        end
    end
end

Complete(ns.presets.looks)
Complete(ns.presets.styles)

local Builtins = {}
ns.Builtins = Builtins

Builtins.list = {
    { name = "Minimal", group = "looks", key = "minimal" },
    { name = "Blizzard-like", group = "looks", key = "familiar" },
    { name = "Unit frame", group = "looks", key = "classic" },
    { name = "Compact", group = "styles", key = "inside" },
    { name = "Flat", group = "looks", key = "flat" },
    { name = "Heavy", group = "looks", key = "bold" },
}

Builtins.defaultName = "Minimal"

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
        return name .. "  |cff8a93a6" .. L["(built-in)"] .. "|r"
    end
    return name
end
