LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

function issecretvalue() return false end
function UnitClassBase() return "MAGE" end
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end
GameTooltip = { SetOwner = function() end, SetText = function() end, AddLine = function() end, Show = function() end, Hide = function() end }
local stub = setmetatable({}, { __index = function() return function() return stub end end })
function CreateFrame() return stub end
Enum = setmetatable({ NamePlateStackType = { Enemy = 1, Friendly = 2 } }, { __index = function() return {} end })
C_CVar = setmetatable({}, { __index = function() return function() return "0" end end })
C_Timer = { After = function() end }
C_Spell = setmetatable({}, { __index = function() return function() end end })
UnitFrameUtil = {}

local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
local function load(path) assert(loadfile(path))("Plateau", ns) end
load("Plateau/Core/Defaults.lua"); load("Plateau/Core/Database.lua"); load("Plateau/Core/Share.lua")
local DB = ns.DB
PlateauDB = nil
DB:Init()

Plateau = {
    DB = DB, flavor = "mainline", brand = { { 1, 1, 1, 1 }, { 1, 1, 1, 1 }, { 1, 1, 1, 1 } },
    Brand = { OnChange = function() end, Text = function(_, t) return t end }, presets = { palettes = {}, looks = {}, styles = {} },
    CVars = { Get = function() return "0" end, Set = function() end, Release = function() end, IsManaged = function() return false end },
    CurrentSpec = function() return 1, "Arcane" end, PerformanceLines = function() return {} end,
    Builtins = { Label = function(n) return n end }, FindConflicts = function() return {} end,
    ResetPerformanceCounts = function() end,
    barTextures = {}, overlayPatterns = {}, media = setmetatable({}, { __index = function() return function() return {} end end }),
    arrowStyles = setmetatable({}, { __index = function() return { file = 'x' } end }),
}
Plateau.T = Plateau.T or (function() local l = {} assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", l) return l.T end)()
local nsOpt = { Widgets = {}, sections = {} }
local function loadOpt(path) assert(loadfile(path))("Plateau_Options", nsOpt) end
loadOpt("Plateau_Options/Widgets/Style.lua")
loadOpt("Plateau_Options/Panels/PageLogic.lua")
local Logic = nsOpt.PageLogic

local ok, err = pcall(loadOpt, "Plateau_Options/Panels/Sections.lua")
check(ok, "Sections.lua loads under the test stubs" .. (ok and "" or (": " .. tostring(err))))
if not ok then return end
local ok2, err2 = pcall(loadOpt, "Plateau_Options/Panels/Help.lua")
check(ok2, "Help.lua loads under the test stubs" .. (ok2 and "" or (": " .. tostring(err2))))

local sections = nsOpt.sections
local byKey = {}
for _, section in ipairs(sections) do byKey[section.key] = section end

local function paths(section)
    local list = {}
    for _, spec in ipairs(section.controls) do
        if spec.path then list[spec.path] = true end
        if spec.colorPath then list[spec.colorPath] = true end
    end
    return list
end

local groups = {
    { label = "Profile", keys = { "profiles" } },
    { label = "Nameplates", keys = { "health", "healthText", "threatText", "name", "level", "castbar", "enemyPower" } },
    { label = "Behavior", keys = { "size", "fading", "layering", "clicking" } },
    { label = "States", keys = { "target", "focus", "mouseover", "combat" } },
    { label = "Auras", keys = { "auraAll", "auraMine", "auraCC", "auraPurge", "auraImportant", "shield" } },
    { label = "Icons", keys = { "raidMarker", "quest", "classification", "faction", "forces", "classPower" } },
    { label = "Friendly", keys = { "friendly" } },
    { label = "Game", keys = { "game" } },
    { label = "Help", keys = { "help" } },
}
local problems = Logic.RailProblems(groups, sections)
check(#problems == 0, "the sidebar order lists every page exactly once" .. (#problems > 0 and (": " .. table.concat(problems, "; ")) or ""))

local castPaths = {
    "look.castbar.readyColor", "look.castbar.notReadyColor", "look.castbar.importantReadyColor",
    "look.castbar.importantNotReadyColor", "look.castbar.uninterruptible", "look.castbar.importantUninterruptible",
}
local onCast, onHealth = paths(byKey.castbar), paths(byKey.health)
for _, path in ipairs(castPaths) do
    check(onCast[path] and not onHealth[path], path .. " is on Cast bar and not on Health bar")
end
check(byKey.colors == nil, "there is no separate Colors page")
local onQuest = paths(byKey.quest)
for _, path in ipairs({ "look.colors.bossColor", "look.colors.casterColor", "look.colors.threatBad", "look.colors.hostile", "look.colors.tapped", "look.colors.classColors", "look.colors.mobTypes" }) do
    check(onHealth[path], path .. " is on Health bar")
end
for _, path in ipairs({ "look.colors.quest", "look.colors.questColor", "look.colors.questExcludeBoss" }) do
    check(onQuest[path] and not onHealth[path], path .. " is on Quest icon only")
end
local function hasHeader(section, label)
    for _, spec in ipairs(section.controls) do
        if spec.type == "Header" and spec.label == label then return true end
    end
    return false
end
check(hasHeader(byKey.castbar, "Cast bar colors"), "Cast bar has a Cast bar colors section")
check(not hasHeader(byKey.health, "Cast bar colors"), "Health bar has no Cast bar colors section")
local function groupCovers(section, path)
    local group = section.group
    if type(group) == "string" then group = { group } end
    for _, prefix in ipairs(group or {}) do
        if path == prefix or path:sub(1, #prefix + 1) == prefix .. "." then return true end
    end
    return false
end
for _, path in ipairs(castPaths) do
    check(groupCovers(byKey.castbar, path) and not groupCovers(byKey.health, path), "resetting Cast bar covers " .. path .. " and resetting Health bar does not")
end

local onName, onHealthText = paths(byKey.name), paths(byKey.healthText)
check(onName["look.enemyTarget.enabled"] and not onHealthText["look.enemyTarget.enabled"], "the enemy target toggle moved from Health text to Name")
for _, key in ipairs({ "classColors", "anchor", "offsetX", "offsetY", "font", "size", "outline", "shadow" }) do
    local path = "look.enemyTarget." .. key
    check(onName[path] and not onHealthText[path], path .. " lives on Name")
end
check(groupCovers(byKey.name, "look.enemyTarget.enabled") and not groupCovers(byKey.healthText, "look.enemyTarget.enabled"), "resetting Name covers the enemy target settings and resetting Health text does not")
check(groupCovers(byKey.healthText, "look.healthText.enabled") and groupCovers(byKey.name, "look.name.enabled"), "each page still resets its own settings")
check(hasHeader(byKey.name, "Enemy target name"), "Name has an Enemy target name section")

local health = byKey.health
check(hasHeader(health, "Health threshold markers") and hasHeader(health, "Execute indicator"), "Health bar separates threshold markers from execute coloring")
local seenMarkers, executeBeforeMarkers = false, true
for _, spec in ipairs(health.controls) do
    if spec.type == "Header" and spec.label == "Health threshold markers" then seenMarkers = true end
    if seenMarkers and (spec.path == "look.execute.highlight" or spec.path == "look.execute.threshold") then executeBeforeMarkers = false end
end
check(executeBeforeMarkers, "the execute color and threshold stay in the execute section")

for key, section in pairs(byKey) do
    for _, spec in ipairs(section.controls) do
        if spec.enabledIf then
            local reason = spec.disabledReason
            if type(reason) == "function" then reason = reason() end
            check(type(reason) == "string" and reason ~= "", key .. " control " .. tostring(spec.label) .. " explains why it is disabled")
            local okCall, value = pcall(spec.enabledIf)
            check(okCall and type(value) == "boolean", key .. " control " .. tostring(spec.label) .. " has a boolean dependency test")
        end
        if spec.type == "Link" then
            local target = byKey[spec.target.section]
            check(target ~= nil, key .. " link points at a real page: " .. tostring(spec.target.section))
            if target and spec.target.label then
                check(Logic.FindControl(target, spec.target.label, true) ~= nil, key .. " link points at a real heading: " .. spec.target.label)
            end
        end
    end
end

local game = byKey.game
local gameGroups = Logic.AssignGroups(game.controls)
local advanced = { "Off-screen nameplates" }
for _, label in ipairs(advanced) do
    local index, spec = Logic.FindControl(game, label, true)
    check(index ~= nil and spec.collapsible == true and spec.collapsed == true, label .. " is a collapsed advanced section on Game settings")
    local count = 0
    for _, g in pairs(gameGroups) do
        if g == index then count = count + 1 end
    end
    check(count > 0, label .. " contains controls")
end
local function labelsOf(section)
    local set = {}
    for _, spec in ipairs(section.controls) do
        if spec.label then set[spec.label] = true end
    end
    return set
end
local gameLabels = labelsOf(game)
local addonLabels = labelsOf(byKey.addon)
check(not gameLabels["Show settings tooltips"] and not gameLabels["Settings window theme"], "Plateau preferences left Game settings")
check(addonLabels["Settings window theme"] and addonLabels["Settings window scale"] and addonLabels["Text font"] and addonLabels["Heading font"] and addonLabels["Show settings tooltips"] and addonLabels["Show Plateau in game menu"], "the gear page holds theme, scale, fonts and the other preferences")
check(Logic.OFF_MENU.addon == true, "the gear page stays off the sidebar")
check(not gameLabels["Refresh statistics"] and not hasHeader(game, "Performance"), "performance controls left Game settings")
local diagIndex, diagSpec = Logic.FindKeyed(byKey.help, "diagnostics")
check(diagIndex ~= nil and diagSpec.collapsible == true and diagSpec.searchable == true, "Help has a collapsible, searchable Diagnostics section")

local sample = { { type = "Header", collapsible = true }, { type = "Toggle" }, { type = "Header" }, { type = "Toggle" } }
check(Logic.AssignGroups(sample)[2] == 1, "controls under a collapsible header belong to it")
check(Logic.AssignGroups(sample)[4] == nil, "a plain header ends the collapsible group")
check(Logic.RowShown({ visibleIf = function() return true end }, true) == false, "a collapsed group hides its rows even when visibleIf allows them")
check(Logic.RowShown({}, false) == true, "rows without conditions are shown")
Logic.SetCollapsed("game", { label = "Movement" }, false)
check(Logic.IsCollapsed("game", { label = "Movement", collapsed = true }) == false, "an expanded section stays expanded for the session")
Logic.ResetCollapsed()
check(Logic.IsCollapsed("game", { label = "Movement", collapsed = true }) == true, "sections start collapsed again after a reset")

local disabled = { enabledIf = function() return false end, disabledReason = "because" }
check(Logic.IsEnabled(disabled) == false and Logic.DisabledReason(disabled) == "because", "a failing dependency disables the control with its reason")
check(Logic.IsEnabled({}) == true, "controls without a dependency stay enabled")

DB:Set("look.target.ring", false)
local ringSize
for _, spec in ipairs(byKey.target.controls) do
    if spec.path == "look.target.ringSize" then ringSize = spec end
end
check(ringSize and Logic.IsEnabled(ringSize) == false, "Border thickness is dimmed while the target border is off")
DB:Set("look.target.ring", true)
check(Logic.IsEnabled(ringSize) == true, "Border thickness comes back as soon as the border is on")
check(DB:Get("look.target.ringSize") == ns.defaults.look.target.ringSize, "dimming a control does not change its saved value")

DB:Set("look.target.useBlizzardScale", true)
local customScale
for _, spec in ipairs(byKey.size.controls) do
    if spec.path == "look.target.scale" then customScale = spec end
end
check(customScale and Logic.IsEnabled(customScale) == false, "Custom target scale is dimmed while Blizzard target scaling is on")
DB:Set("look.target.useBlizzardScale", false)
check(Logic.IsEnabled(customScale) == true, "Custom target scale is available when Blizzard scaling is off")

check(hasHeader(byKey.auraAll, "Text") and hasHeader(byKey.auraAll, "Tooltips"), "shared aura text and tooltips live on the Aura text and tooltips page")
for _, key in ipairs({ "auraMine", "auraCC", "auraPurge", "auraImportant" }) do
    check(hasHeader(byKey[key], "Show") and hasHeader(byKey[key], "Which auras") and hasHeader(byKey[key], "Layout") and hasHeader(byKey[key], "Icon"), key .. " uses the same Show, Which auras, Layout and Icon sections")
    check(not hasHeader(byKey[key], "Extras") and not hasHeader(byKey[key], "Aura text (all groups)"), key .. " has no leftover Extras or aura text sections")
end

local profiles = byKey.profiles
local order = {}
for _, spec in ipairs(profiles.controls) do
    if spec.type ~= "Note" then order[#order + 1] = spec.type == "Header" and ("Header:" .. spec.label) or spec.type end
end
check(order[1] == "ProfileStatus" and order[2] == "Header:Manage profiles" and order[3] == "ProfileActions", "Profiles opens with status, then management actions")
check(order[4] == "Header:Switch automatically" and order[5] == "AutoProfiles" and order[6] == "Header:Share" and order[7] == "ShareProfile", "automatic switching comes after management and sharing comes last")
check(order[8] == "Header:What a profile includes", "the scope explanation sits at the end")
local scopeIndex = Logic.FindControl(profiles, "What a profile includes", true)
check(profiles.controls[scopeIndex].collapsible == true, "the scope explanation is collapsible")
check(profiles.title == "Profiles", "the page title is unchanged")

local index = Logic.BuildSettingsIndex(sections)
local function found(query)
    local words = {}
    for word in query:lower():gmatch("%S+") do words[#words + 1] = word end
    local hits = {}
    for _, entry in ipairs(index) do
        local all = true
        for _, word in ipairs(words) do
            if not entry.text:find(word, 1, true) then all = false break end
        end
        if all then hits[#hits + 1] = entry end
    end
    return hits
end
local function foundOn(query, sectionKey)
    for _, entry in ipairs(found(query)) do
        if entry.section.key == sectionKey then return true end
    end
    return false
end

for _, section in ipairs(sections) do
    if section.key ~= "help" then
        local pageEntry
        for _, entry in ipairs(index) do
            if entry.section == section and entry.where == "Page" then pageEntry = entry end
        end
        check(pageEntry ~= nil and pageEntry.label == section.title, section.title .. " page can be found by its name")
    end
end

local unlabeled = { Presets = true, Actions = true, Conflicts = true, AutoProfiles = true, Note = true, Link = true, Header = true }
for _, section in ipairs(sections) do
    if section.key ~= "help" then
        for _, spec in ipairs(section.controls) do
            if not unlabeled[spec.type] then
                check(type(spec.label) == "string" and spec.label ~= "", section.title .. " control of type " .. tostring(spec.type) .. " is searchable by label")
            end
        end
    end
end

check(foundOn("cast bar colors", "castbar"), "cast bar colors are found on Cast bar")
check(not foundOn("cast bar colors", "health") or foundOn("cast bar colors", "castbar"), "the moved cast colors point at Cast bar")
check(foundOn("interrupt ready", "castbar") and not foundOn("interrupt ready", "health"), "Interrupt ready is only found on Cast bar")
check(foundOn("enemy types", "health") and foundOn("reaction colors", "health") and foundOn("colorblind presets", "health"), "enemy type, reaction and palette colors are found on Health bar")
check(foundOn("color quest enemies", "quest"), "quest enemy color is found on Quest icon")
check(foundOn("dim", "fading") and foundOn("fade", "fading"), "searching dim or fade finds the non-target opacity setting on Fading")
for _, query in ipairs({ "transparency", "colour", "kick", "bigger", "healthbar", "pvp", "hitbox", "gray", "low health", "skull" }) do
    check(#found(query) > 0, "searching " .. query .. " finds something")
end
check(foundOn("enemy target name", "name"), "Enemy target name is found on Name")
check(foundOn("health threshold markers", "health"), "Health threshold markers are found on Health bar")
check(foundOn("stacking presets", "layering") and foundOn("tight balanced", "layering"), "stacking presets are searchable on Layering and stacking")
check(foundOn("movement speed", "layering") and foundOn("behind walls", "fading"), "movement and line-of-sight fading are searchable on their new pages")
check(foundOn("window scale", "addon") and foundOn("heading font", "addon") and foundOn("settings window theme", "addon"), "Plateau settings are searchable")
check(foundOn("diagnostics", "help") and foundOn("slow frames", "help"), "Diagnostics on Help is searchable from the settings search")
check(foundOn("rename profile", "profiles") and foundOn("copy settings from", "profiles") and foundOn("delete profile", "profiles"), "profile actions are searchable")
check(foundOn("export active profile", "profiles") and foundOn("activate after import", "profiles"), "export and import are searchable")
check(foundOn("default profile", "profiles"), "Default profile is searchable")
check(foundOn("no override", "profiles"), "automatic switching terms are searchable")
check(foundOn("aura text", "auraAll"), "shared aura text is found on Aura text and tooltips")
check(foundOn("maximum aura duration", "auraPurge") and foundOn("sort order", "auraCC"), "shared aura controls are found on each aura page")
check(foundOn("only warn for buffs you can remove", "shield") and foundOn("warning priority", "shield"), "buff warning controls are searchable")
check(foundOn("hidden spells", "auraMine") and foundOn("allowed spells", "auraCC") and foundOn("hidden spells", "auraPurge") and foundOn("allowed spells", "auraImportant"), "spell lists are searchable on every aura page")
check(foundOn("hide level for same-level", "level"), "renamed Level settings are searchable")
check(foundOn("use class colors for player names", "name") and foundOn("long name handling", "name"), "renamed Name settings are searchable")

local helpTopics = nsOpt.helpTopics
check(#helpTopics >= 40, "Help topics are loaded for the Help search")
local titles = {}
for _, topic in ipairs(helpTopics) do
    check(type(topic.title) == "string" and type(topic.text) == "string" and type(topic.category) == "string", "Help topic " .. tostring(topic.title) .. " has a title, category and text")
    titles[topic.title] = true
end
check(titles["The minimized bar"] and titles["Dimmed settings and collapsed sections"], "the new Help topics exist")

local function hasPath(key, path)
    return paths(byKey[key])[path] == true
end
for _, path in ipairs({ "look.scaling.enabled", "look.scaling.boss", "look.scaling.focusScale", "look.scaling.castScale", "look.target.scale", "look.plate.followBlizzardSize" }) do
    check(hasPath("size", path), path .. " is on Size")
end
for _, path in ipairs({ "look.range.enabled", "look.range.alpha", "look.target.dimOthers" }) do
    check(hasPath("fading", path), path .. " is on Fading")
end
check(labelsOf(byKey.layering)["Stacking bounds"] == true, "Stacking bounds is on Layering and stacking")
for _, path in ipairs({ "look.scaling.castFront", "look.scaling.mouseoverFront" }) do
    check(hasPath("layering", path), path .. " is on Layering and stacking")
end
for _, path in ipairs({ "look.plate.clickX", "look.plate.clickY", "look.plate.clickCastBar", "look.plate.clickOffsetY" }) do
    check(hasPath("clicking", path), path .. " is on Clickable area")
end
for _, path in ipairs({ "look.scaling.combatEnabled", "look.scaling.combatScale", "look.scaling.idleScale", "look.idle.enabled", "look.idle.alpha" }) do
    check(hasPath("combat", path), path .. " is on Out of combat")
end
check(byKey.behavior == nil, "the old catch-all Behavior page is gone")
check(not hasPath("target", "look.target.dimOthers"), "non-target opacity left the Target page")
check(not groupCovers(byKey.target, "look.target.dimOthers") and not groupCovers(byKey.target, "look.target.scale"), "resetting Target no longer resets settings that moved to Fading and Size")
check(groupCovers(byKey.fading, "look.target.dimOthers") and groupCovers(byKey.size, "look.target.scale"), "resetting Fading and Size covers the settings they now hold")
check(not groupCovers(byKey.size, "look.scaling.castFront") and groupCovers(byKey.layering, "look.scaling.castFront"), "resetting Size does not touch Casting enemies in front")
check(hasHeader(byKey.friendly, "Blizzard-drawn nameplates") and not hasHeader(game, "Blizzard-drawn nameplates"), "the options for nameplates the game draws moved to Friendly")
check(not hasHeader(game, "Stacking and movement") and not hasHeader(game, "Occlusion"), "stacking and fading left Game settings")
check(foundOn("casting enemies in front", "layering") and foundOn("priority", "layering") and foundOn("range fading", "fading") and foundOn("enemy type scale", "size"), "the moved sections are searchable on their new pages")

local function ranked(query)
    local words = {}
    for word in query:gmatch("%S+") do words[#words + 1] = word end
    local scored = {}
    for _, entry in ipairs(index) do
        local score = Logic.SearchScore(entry, words, query)
        if score then scored[#scored + 1] = { entry = entry, score = score } end
    end
    table.sort(scored, function(a, b) if a.score ~= b.score then return a.score > b.score end return a.entry.label < b.entry.label end)
    return scored
end
local top = ranked("enemy target name")
check(top[1].entry.section.key == "name" and top[1].entry.heading, "searching enemy target name puts the Name page's Enemy target name section first")
check(top[3] and top[3].entry.label == "Show enemy target name", "...followed by the matching settings, ahead of loose description matches")
local cast = ranked("cast bar colors")
check(cast[1].entry.section.key == "castbar", "searching cast bar colors still lands on Cast bar first")

local warnings = {}
for _, section in ipairs(nsOpt.sections) do
    for _, spec in ipairs(section.controls) do
        if spec.type == "Note" and spec.visibleIf and type(spec.label) == "string" then
            warnings[#warnings + 1] = { page = section.key, spec = spec }
        end
    end
end
local function Shown(fragment)
    for _, w in ipairs(warnings) do
        if w.spec.label:find(fragment, 1, true) then
            return w.spec.visibleIf() and w.page or false
        end
    end
    return nil
end
DB:Set("look.plate.stackSpace", "name")
check(Shown("keep room for a cast bar on every plate") == false, "no stacking warning for Health bar and name")
DB:Set("look.plate.stackSpace", "barcast")
check(Shown("keep room for a cast bar on every plate") == "layering", "stacking bounds that include the cast bar warn about tall stacks")
