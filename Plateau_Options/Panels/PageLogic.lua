local _, ns = ...

local Logic = {}
ns.PageLogic = Logic

local expanded = {}

function Logic.AssignGroups(controls)
    local groups = {}
    local current
    for index, spec in ipairs(controls) do
        if spec.type == "Header" then
            current = spec.collapsible and index or nil
        else
            groups[index] = current
        end
    end
    return groups
end

local function StateKey(sectionKey, spec)
    return sectionKey .. ":" .. tostring(spec.label)
end

function Logic.IsCollapsed(sectionKey, spec)
    local saved = expanded[StateKey(sectionKey, spec)]
    if saved ~= nil then
        return not saved
    end
    return spec.collapsed == true
end

function Logic.SetCollapsed(sectionKey, spec, collapsed)
    expanded[StateKey(sectionKey, spec)] = not collapsed
end

function Logic.ResetCollapsed()
    for key in pairs(expanded) do
        expanded[key] = nil
    end
end

function Logic.RowShown(spec, hiddenByGroup)
    if hiddenByGroup then
        return false
    end
    return not spec.visibleIf or (spec.visibleIf() and true or false)
end

function Logic.IsEnabled(spec)
    if not spec.enabledIf then
        return true
    end
    return spec.enabledIf() ~= false
end

function Logic.DisabledReason(spec)
    local reason = spec.disabledReason
    if type(reason) == "function" then
        return reason()
    end
    return reason
end

function Logic.FindControl(section, label, headerOnly)
    for index, spec in ipairs(section.controls) do
        if spec.label == label and (not headerOnly or spec.type == "Header") then
            return index, spec
        end
    end
end

function Logic.FindKeyed(section, key)
    for index, spec in ipairs(section.controls) do
        if spec.key == key then
            return index, spec
        end
    end
end

Logic.OFF_MENU = { addon = true }

function Logic.RailProblems(groups, sections)
    local problems, seen = {}, {}
    local known = {}
    for _, section in ipairs(sections) do
        known[section.key] = true
    end
    for _, group in ipairs(groups) do
        for _, key in ipairs(group.keys) do
            if not known[key] then
                problems[#problems + 1] = "unknown page " .. key
            elseif seen[key] then
                problems[#problems + 1] = "duplicate page " .. key
            end
            seen[key] = true
        end
    end
    for _, section in ipairs(sections) do
        if not seen[section.key] and not Logic.OFF_MENU[section.key] then
            problems[#problems + 1] = "page missing from the sidebar: " .. section.key
        end
    end
    return problems
end

function Logic.ClampBar(left, top, screenWidth, screenHeight, barWidth, barHeight)
    left = math.max(0, math.min(left, screenWidth - barWidth))
    top = math.max(barHeight, math.min(top, screenHeight))
    return left, top
end

function Logic.IsClick(downX, downY, upX, upY, threshold)
    if not downX or not downY or not upX or not upY then
        return true
    end
    return math.abs(upX - downX) <= threshold and math.abs(upY - downY) <= threshold
end

function Logic.ForcedTree(tree, path, value)
    local node = tree
    local segments = {}
    for segment in path:gmatch("[^.]+") do
        segments[#segments + 1] = segment
    end
    for index = 2, #segments - 1 do
        node[segments[index]] = node[segments[index]] or {}
        node = node[segments[index]]
    end
    node[segments[#segments]] = value
    return tree
end

function Logic.Overlay(base, forced)
    return setmetatable({}, {
        __index = function(_, key)
            local value = base[key]
            local override = forced[key]
            if type(override) == "table" then
                return Logic.Overlay(type(value) == "table" and value or {}, override)
            elseif override ~= nil then
                return override
            end
            return value
        end,
    })
end

function Logic.Plain(text)
    if type(text) ~= "string" then
        return ""
    end
    return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):lower())
end

local SYNONYMS = {
    { "opacity", "transparency transparent alpha see-through fade faded dim" },
    { "color", "colour recolor tint" },
    { "grey", "gray", true },
    { "gray", "grey", true },
    { "interrupt", "kick stop silence" },
    { "uninterruptible", "unkickable cc stun" },
    { "position", "move placement anchor location" },
    { "offset", "move nudge shift" },
    { "distance", "gap spacing" },
    { "size", "bigger smaller larger tiny resize" },
    { "scale", "bigger smaller larger tiny resize zoom" },
    { "width", "wider narrower resize" },
    { "height", "taller shorter thicker thinner resize" },
    { "health bar", "healthbar" },
    { "health text", "numbers hp value percent" },
    { "debuff", "dot damage over time" },
    { "clickable", "hitbox clickbox click box mouse" },
    { "snapping", "snap grid magnet drag" },
    { "arena", "pvp" },
    { "battleground", "pvp" },
    { "execute", "low health critical finish" },
    { "raid target", "marker skull star diamond triangle moon square cross circle" },
    { "alignment", "justify" },
    { "performance", "fps lag slow cpu memory" },
    { "outline", "bold thick" },
    { "important", "dangerous priority" },
    { "buff warning", "alert enrage dispel purge defensive" },
    { "enem", "hostile hostiles mob mobs foe foes trash adds npc" },
    { "friendly", "ally allies friend friends" },
    { "npc", "mob mobs creature creatures" },
    { "health", "hp life" },
    { "threat", "aggro tank tanking taunt" },
    { "aggro", "threat" },
    { "cast", "casting castbar spell spells" },
    { "crowd control", "cc stun stuns root fear polymorph sheep incapacitate" },
    { "aura", "buff buffs debuff debuffs" },
    { "buff", "aura auras" },
    { "debuff", "aura auras" },
    { "dispel", "purge cleanse" },
    { "purge", "dispel spellsteal steal" },
    { "enrage", "soothe" },
    { "absorb", "shield shields" },
    { "tapped", "tagged grey gray" },
    { "mouseover", "hover hovered cursor mouse" },
    { "target", "selected selection" },
    { "level", "lvl" },
    { "elite", "rare rares boss dragon classification" },
    { "boss", "encounter raid" },
    { "quest", "objective objectives" },
    { "class resource", "combo points holy power soul shards chi runes essence arcane charges pips" },
    { "power", "energy rage mana resource" },
    { "personal resource", "prd personal bar player bar" },
    { "pet", "pets minion minions totem totems guardian guardians companion" },
    { "minion", "pet pets totem totems" },
    { "realm", "server" },
    { "combat", "fight fighting" },
    { "font", "text typeface" },
    { "texture", "skin statusbar bar style" },
    { "border", "edge frame" },
    { "glow", "highlight shine" },
    { "fading", "fade transparency" },
    { "behind walls", "line of sight los occluded wall walls" },
    { "range", "distance reach" },
    { "stacking", "overlap overlapping spread stack" },
    { "mythic+", "m+ mplus keystone key count percent" },
    { "look", "preset style theme layout" },
    { "profile", "config configuration setup" },
    { "reset", "default defaults restore" },
}

local function Synonyms(tooltip, ...)
    local text = table.concat({ ... }, " "):lower()
    local full = text .. " " .. tostring(tooltip or ""):lower()
    local extra = {}
    for i = 1, #SYNONYMS do
        local rule = SYNONYMS[i]
        if (rule[3] and full or text):find(rule[1], 1, true) then
            extra[#extra + 1] = SYNONYMS[i][2]
        end
    end
    return table.concat(extra, " ")
end

local function Localized(text)
    return Plateau.T(text)
end
Logic.Localized = Localized

function Logic.LocalizedText(...)
    local extra = {}
    for i = 1, select("#", ...) do
        local text = select(i, ...)
        if type(text) == "string" and text ~= "" then
            local translated = Localized(text)
            if translated ~= text then
                extra[#extra + 1] = Logic.Plain(translated)
            end
        end
    end
    if #extra == 0 then
        return ""
    end
    return " " .. table.concat(extra, " ")
end

local function LabelScore(label, words, query)
    local score
    if label == query then
        score = 6
    elseif label:find(query, 1, true) then
        score = 5
    else
        local inLabel = 0
        for _, word in ipairs(words) do
            if label:find(word, 1, true) then
                inLabel = inLabel + 1
            end
        end
        if inLabel == #words then
            score = 4
        elseif label:sub(1, #words[1]) == words[1] then
            score = 3
        elseif inLabel > 0 then
            score = 2
        else
            score = 1
        end
    end
    return score
end

function Logic.SearchScore(entry, words, query)
    for _, word in ipairs(words) do
        if not entry.text:find(word, 1, true) then
            return nil
        end
    end
    local score = LabelScore(entry.labelText, words, query)
    if entry.labelLocal then
        score = math.max(score, LabelScore(entry.labelLocal, words, query))
    end
    if entry.heading then
        score = score + 0.5
    end
    return score
end

local function LocalLabel(text)
    local translated = Localized(text)
    if type(translated) ~= "string" or translated == text then
        return nil
    end
    return Logic.Plain(translated)
end

function Logic.BuildSettingsIndex(sections)
    local Plain = Logic.Plain
    local Extra = Logic.LocalizedText
    local index = {}
    for _, section in ipairs(sections) do
        local isHelp = section.key == "help"
        if not isHelp and section.title then
            index[#index + 1] = {
                section = section,
                index = 1,
                label = section.title,
                where = "Page",
                labelText = Plain(section.title),
                labelLocal = LocalLabel(section.title),
                text = Plain(section.title) .. " page " .. Synonyms(nil, section.title) .. Extra(section.title, "Page"),
            }
        end
        local header = ""
        for i, spec in ipairs(section.controls) do
            if spec.type == "Header" then
                header = type(spec.label) == "string" and spec.label or ""
            end
            if type(spec.label) == "string" and spec.type ~= "Note" and spec.type ~= "Link" and (not isHelp or spec.searchable) then
                index[#index + 1] = {
                    section = section,
                    index = i,
                    label = spec.label,
                    where = spec.type == "Header" and section.title or (header ~= "" and (Localized(section.title) .. "  >  " .. Localized(header)) or section.title),
                    labelText = Plain(spec.label),
                    labelLocal = LocalLabel(spec.label),
                    heading = spec.type == "Header",
                    text = Plain(spec.label) .. " " .. Plain(spec.tooltip) .. " " .. Plain(spec.keywords) .. " " .. Plain(section.title) .. " " .. Plain(header) .. " " .. Synonyms(spec.tooltip, spec.label, section.title, header, spec.keywords or "") .. Extra(spec.label, spec.tooltip, spec.keywords, section.title, header),
                }
            end
        end
    end
    return index
end
