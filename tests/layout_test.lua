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
Enum = setmetatable({ NamePlateStackType = { Enemy = 1, Friendly = 2 }, NamePlateSimplifiedType = { None = 0, Minion = 1, MinusMob = 2, FriendlyPlayer = 3, FriendlyNpc = 4 } }, { __index = function() return {} end })
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
    CurrentSpec = function() return 1, "Arcane" end,
    Builtins = { Label = function(n) return n end }, FindConflicts = function() return {} end,
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
    { label = "Plate", keys = { "health", "healthColors", "threatColors", "plateText", "name", "healthText", "level", "castbar", "auraMine", "auraCC", "auraPurge", "auraImportant", "shield", "auraAll", "raidMarker", "classification", "quest", "faction", "classPower", "enemyPower" } },
    { label = "In combat", keys = { "target", "focus", "mouseover", "kickers", "forces", "threatText", "bossPhases" } },
    { label = "Showing", keys = { "showing", "fading", "combat", "size", "layering", "clicking" } },
    { keys = { "friendly", "profiles", "addon", "help" } },
}
local problems = Logic.RailProblems(groups, sections)
check(#problems == 0, "the sidebar order lists every page exactly once" .. (#problems > 0 and (": " .. table.concat(problems, "; ")) or ""))

local castPaths = {
    "look.castbar.readyColor", "look.castbar.notReadyColor", "look.castbar.importantReadyColor",
    "look.castbar.importantNotReadyColor", "look.castbar.uninterruptible", "look.castbar.importantUninterruptible",
}
local onCast, onHealth, onColors = paths(byKey.castbar), paths(byKey.health), paths(byKey.healthColors)
for _, path in ipairs(castPaths) do
    check(onCast[path] and not onHealth[path] and not onColors[path], path .. " is on Cast bar and not on the health bar pages")
end
check(byKey.colors == nil, "there is no separate Colors page")
local onQuest = paths(byKey.quest)
for _, path in ipairs({ "look.colors.bossColor", "look.colors.casterColor", "look.colors.hostile", "look.colors.tapped", "look.colors.classColors", "look.colors.mobTypes", "look.colors.healthGradient" }) do
    check(onColors[path] and not onHealth[path], path .. " is on Health bar colors")
end
local onThreat = paths(byKey.threatColors)
for _, path in ipairs({ "look.colors.threat", "look.colors.threatBad", "look.colors.threatDisplay", "look.colors.offTankColor" }) do
    check(onThreat[path] and not onHealth[path] and not onColors[path], path .. " is on Threat colors")
end
for _, path in ipairs({ "look.colors.quest", "look.colors.questColor", "look.colors.questExcludeBoss" }) do
    check(onQuest[path] and not onHealth[path] and not onColors[path], path .. " is on Quest icon only")
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
for _, path in ipairs({ "look.colors.bossColor", "look.colors.hostile", "look.colors.healthGradient" }) do
    check(groupCovers(byKey.healthColors, path) and not groupCovers(byKey.health, path), "resetting Health bar colors covers " .. path .. " and resetting Health bar does not")
end
check(groupCovers(byKey.threatColors, "look.colors.threatBad") and groupCovers(byKey.threatText, "look.threatText.enabled") and not groupCovers(byKey.threatText, "look.colors.threatBad") and not groupCovers(byKey.healthColors, "look.colors.threatBad"), "resetting Threat colors and Threat percent each cover their own part")
check(groupCovers(byKey.health, "look.plate.pixelPerfect") and not groupCovers(byKey.size, "look.plate.pixelPerfect"), "resetting Health bar covers pixel-perfect borders")

local onName, onHealthText = paths(byKey.name), paths(byKey.healthText)
check(onName["look.enemyTarget.enabled"] and not onHealthText["look.enemyTarget.enabled"], "the enemy target toggle moved from Health text to Name")
for _, key in ipairs({ "classColors", "anchor", "size" }) do
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

check(byKey.game == nil, "the separate Game settings page is gone")
local advanced = { { "Off-screen nameplates", "layering" }, { "Blizzard-drawn nameplates", "friendly" } }
for _, entry in ipairs(advanced) do
    local label, key = entry[1], entry[2]
    local index, spec = Logic.FindControl(byKey[key], label, true)
    check(index ~= nil and spec.collapsible == true and spec.collapsed == true, label .. " is a collapsed advanced section on " .. key)
    local count = 0
    for _, g in pairs(Logic.AssignGroups(byKey[key].controls)) do
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
local addonLabels = labelsOf(byKey.addon)
check(addonLabels["Settings window scale"] and addonLabels["Show settings tooltips"] and addonLabels["Show Plateau in game menu"] and not addonLabels["Settings window theme"] and not addonLabels["Text font"], "the Window page holds the scale and the other preferences, with no theme or font pickers")
check(Logic.OFF_MENU.addon == true, "the gear page stays off the sidebar")
check(Logic.FindKeyed(byKey.help, "diagnostics") == nil, "Help no longer has a Diagnostics section; /plt debug has the numbers")

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

check(hasHeader(byKey.auraAll, "Tooltips") and not hasHeader(byKey.auraAll, "Text"), "aura tooltips have their own tab and aura text has no separate font")
local fontPaths = {}
for _, spec in ipairs(byKey.plateText.controls) do
    for _, path in ipairs(spec.paths or {}) do fontPaths[path] = true end
end
local strays = {}
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if spec.path and spec.path:match("%.font$") or spec.path and spec.path:match("%.outline$") then strays[#strays + 1] = spec.path end
    end
end
check(fontPaths["look.name.font"] and fontPaths["look.auras.outline"] and fontPaths["look.castbar.shadow"] and fontPaths["look.enemyPower.font"] and not fontPaths["look.enemyPower.shadow"], "All plate text sets the font, outline and shadow of every plate text")
check(#strays == 0, "no page keeps its own plate font or outline" .. (#strays > 0 and (": " .. table.concat(strays, ", ")) or ""))
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
check(profiles.resetAll == true and profiles.noReset == true, "Profiles shows Reset profile where other pages show Reset this section")
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
check(foundOn("enemy types", "healthColors") and foundOn("reaction colors", "healthColors") and foundOn("colorblind presets", "healthColors"), "enemy type, reaction and palette colors are found on Health bar colors")
check(foundOn("threat colors", "threatColors") and foundOn("threat percent", "threatText"), "threat colors and threat percent are found on their parts")
check(foundOn("color quest enemies", "quest"), "quest enemy color is found on Quest icon")
check(foundOn("dim", "fading") and foundOn("fade", "fading"), "searching dim or fade finds the non-target opacity setting on Fading")
for _, query in ipairs({ "transparency", "colour", "kick", "bigger", "healthbar", "pvp", "hitbox", "gray", "low health", "skull" }) do
    check(#found(query) > 0, "searching " .. query .. " finds something")
end
check(foundOn("enemy target name", "name"), "Enemy target name is found on Name")
check(foundOn("health threshold markers", "health"), "Health threshold markers are found on Health bar")
check(foundOn("stacking presets", "layering") and foundOn("tight balanced", "layering"), "stacking presets are searchable on Layering and stacking")
check(foundOn("movement speed", "layering") and foundOn("behind walls", "fading"), "movement and line-of-sight fading are searchable on their new pages")
check(foundOn("window scale", "addon"), "the Window page is searchable")
check(foundOn("rename profile", "profiles") and foundOn("copy settings from", "profiles") and foundOn("delete profile", "profiles"), "profile actions are searchable")
check(foundOn("export active profile", "profiles") and foundOn("activate after import", "profiles"), "export and import are searchable")
check(foundOn("default profile", "profiles"), "Default profile is searchable")
check(foundOn("no override", "profiles"), "automatic switching terms are searchable")
check(foundOn("aura tooltips", "auraAll") and foundOn("font outline", "plateText"), "aura tooltips and the shared font are searchable")
check(foundOn("maximum aura duration", "auraPurge") and foundOn("sort order", "auraCC"), "shared aura controls are found on each aura page")
check(foundOn("only warn for buffs you can remove", "shield") and foundOn("warning priority", "shield"), "buff warning controls are searchable")
check(foundOn("hidden spells", "auraMine") and foundOn("allowed spells", "auraCC") and foundOn("hidden spells", "auraPurge") and foundOn("allowed spells", "auraImportant"), "spell lists are searchable on every aura page")
check(foundOn("hide on same-level normal enemies", "level"), "renamed Level settings are searchable")
check(foundOn("use class colors for player names", "name") and foundOn("long names", "name"), "renamed Name settings are searchable")
check(foundOn("hostile", "healthColors") and foundOn("mob", "size"), "hostile and mob find enemy settings")
check(foundOn("aggro", "threatColors") and foundOn("hp", "healthText"), "aggro finds Threat and hp finds Health text")
check(foundOn("ally", "friendly") and foundOn("totem", "friendly"), "ally and totem find Friendly settings")
check(foundOn("cc", "auraCC") and foundOn("combo points", "classPower"), "player shorthand finds crowd control and class resource")
check(byKey.personal == nil and foundOn("line of sight", "fading"), "there is no personal resource display page and line of sight finds its setting")
check(labelsOf(byKey.name)["Show your name"] and labelsOf(byKey.name)["NPC names"] and labelsOf(byKey.name)["Show enemy minion names"], "names over heads are on the Name page")
check(labelsOf(byKey.showing)["Always show nameplates"] and labelsOf(byKey.showing)["Enemy minions"] and labelsOf(byKey.showing)["Maximum nameplate distance"], "which nameplates show has its own page")
check(labelsOf(byKey.target)["Soft target icon: enemies"] ~= nil or C_CVar.GetCVar("SoftTargetIconEnemy") == nil, "soft target icons are on the Target page")
check(labelsOf(byKey.layering)["Keep enemies in combat on screen"] and labelsOf(byKey.layering)["Pin off-screen nameplates"], "off-screen nameplates are on Layering and stacking")
local friendlyLabels = labelsOf(byKey.friendly)
check(friendlyLabels["Simplify minions"] and friendlyLabels["Simplify minor enemies"] and friendlyLabels["Simplify friendly players"] and friendlyLabels["Simplify friendly NPCs"], "all four simplify options sit together on Friendly")
local simplifyCount = 0
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if spec.label == "Simplify minions" then simplifyCount = simplifyCount + 1 end
    end
end
check(simplifyCount == 1, "each simplify option is listed once")
local questLabels = labelsOf(byKey.quest)
check(questLabels["Position"] and questLabels["Progress position"], "the quest icon and its progress count each have their own position")
local offsetSliders = {}
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if spec.type == "Slider" and spec.path and not spec.path:match("^look%.plate%.") and (spec.path:match("%.offset[XY]$") or spec.path:match("%.timerOffset[XY]$") or spec.path:match("%.targetOffset[XY]$")) then
            offsetSliders[#offsetSliders + 1] = spec.path
        end
    end
end
check(#offsetSliders == 0, "parts that drag on the preview have no offset sliders" .. (#offsetSliders > 0 and (": " .. table.concat(offsetSliders, ", ")) or ""))
local kept = nsOpt.sliderRanges or {}
check(kept["look.name.offsetX"] and kept["look.name.offsetX"][2] == 200 and kept["look.auras.mine.offsetY"] and kept["look.castbar.timerOffsetX"], "offsets without a slider keep their range for dragging and imports")
local gameTagged = 0
for _, spec in ipairs(byKey.showing.controls) do
    if spec.gameSetting then gameTagged = gameTagged + 1 end
end
check(gameTagged >= 2, "Blizzard settings are tagged as game settings")

local helpTopics = nsOpt.helpTopics
check(#helpTopics >= 5 and #helpTopics <= 10, "Help keeps a short list of topics")
local titles = {}
for _, topic in ipairs(helpTopics) do
    check(type(topic.title) == "string" and type(topic.text) == "string" and type(topic.category) == "string", "Help topic " .. tostring(topic.title) .. " has a title, category and text")
    titles[topic.title] = true
end
check(titles["Limited settings in dungeons and raids"] and titles["Slash commands"] and not titles["Size page"], "Help keeps the topics the settings cannot show and drops the per-page ones")

local function hasPath(key, path)
    return paths(byKey[key])[path] == true
end
for _, path in ipairs({ "look.scaling.enabled", "look.scaling.boss", "look.scaling.focusScale", "look.scaling.castScale", "look.target.scale", "look.plate.followBlizzardSize" }) do
    check(hasPath("size", path), path .. " is on Size")
end
for _, path in ipairs({ "look.range.enabled", "look.range.alpha", "look.target.dimOthers" }) do
    check(hasPath("fading", path), path .. " is on Fading")
end
check(labelsOf(byKey.layering)["Stacking bounds"] == true, "Stacking bounds is on Stacking")
for _, path in ipairs({ "look.scaling.castFront", "look.scaling.importantFront", "look.scaling.mouseoverFront" }) do
    check(not hasPath("layering", path), path .. " is gone")
end
for _, path in ipairs({ "look.plate.clickX", "look.plate.clickY", "look.plate.clickCastBar", "look.plate.clickOffsetY" }) do
    check(hasPath("clicking", path), path .. " is on Clickable area")
end
for _, path in ipairs({ "look.idle.enabled", "look.idle.alpha", "look.idle.instancesOnly" }) do
    check(hasPath("combat", path), path .. " is on Out of combat")
end
for _, path in ipairs({ "look.scaling.combatEnabled", "look.scaling.combatScale", "look.scaling.idleScale", "look.scaling.mouseoverScale" }) do
    check(hasPath("size", path) and groupCovers(byKey.size, path) and not hasPath("combat", path) and not groupCovers(byKey.combat, path), path .. " is on Size and reset with it")
end
check(byKey.behavior == nil, "the old catch-all Behavior page is gone")
check(not hasPath("target", "look.target.dimOthers"), "non-target opacity left the Target page")
check(not groupCovers(byKey.target, "look.target.dimOthers") and not groupCovers(byKey.target, "look.target.scale"), "resetting Target no longer resets settings that moved to Fading and Size")
check(groupCovers(byKey.fading, "look.target.dimOthers") and groupCovers(byKey.size, "look.target.scale"), "resetting Fading and Size covers the settings they now hold")
check(hasHeader(byKey.friendly, "Blizzard-drawn nameplates") and hasHeader(byKey.friendly, "Blizzard's friendly nameplates"), "all Blizzard-drawn nameplate settings are on Friendly")
check(hasHeader(byKey.addon, "Other nameplate addons"), "the addon conflict list is on Plateau settings")
for _, path in ipairs({ "look.friendly.raidMarker.own", "look.friendly.raidMarker.position", "look.scaling.friendlyScale" }) do
    check(hasPath("friendly", path) and groupCovers(byKey.friendly, path), path .. " is on Friendly and reset with it")
end
check(not hasPath("raidMarker", "look.friendly.raidMarker.own") and not hasPath("size", "look.scaling.friendlyScale"), "friendly raid icon placement and scale left Raid target icon and Size")
check(foundOn("stacking bounds", "layering") and foundOn("range fading", "fading") and foundOn("enemy type scale", "size"), "the moved sections are searchable on their new pages")

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
check(Shown("keep room for a cast bar on every nameplate") == false, "no stacking warning for Health bar and name")
DB:Set("look.plate.stackSpace", "barcast")
check(Shown("keep room for a cast bar on every nameplate") == "layering", "stacking bounds that include the cast bar warn about tall stacks")

local unnamed = {}
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if spec.enabledIf and spec.disabledReason == nil then
            unnamed[#unnamed + 1] = section.key .. ": " .. tostring(spec.label)
        end
    end
end
check(#unnamed == 0, "every setting that can be dimmed says which switch turns it on" .. (#unnamed > 0 and (": " .. table.concat(unnamed, "; ")) or ""))

local allLabels, missingSwitch = {}, {}
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if type(spec.label) == "string" then allLabels[spec.label] = true end
    end
end
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        local reason = type(spec.disabledReason) == "string" and spec.disabledReason or nil
        local names = reason and reason:match("^Turn [onf]+ (.-) to use this%.$")
        if names and not names:match("^at least one of") and not names:match("%%s") then
            for name in (names .. " or "):gmatch("(.-) or ") do
                if not allLabels[name] then missingSwitch[#missingSwitch + 1] = section.key .. ": " .. name end
            end
        end
    end
end
check(#missingSwitch == 0, "every switch a dimmed setting points to exists" .. (#missingSwitch > 0 and (": " .. table.concat(missingSwitch, "; ")) or ""))

local unresettable = {}
for _, section in ipairs(sections) do
    for _, spec in ipairs(section.controls) do
        if spec.path and spec.get and not spec.reset and #nsOpt.SpecPaths(spec) == 0 then
            unresettable[#unresettable + 1] = spec.path
        end
    end
end
check(#unresettable == 0, "every setting with a saved path can be reset with a right-click" .. (#unresettable > 0 and (": " .. table.concat(unresettable, ", ")) or ""))
local clickX
for _, spec in ipairs(byKey.clicking.controls) do
    if spec.path == "look.plate.clickX" then clickX = spec end
end
check(clickX and nsOpt.SpecPaths(clickX)[1] == "look.plate.clickX", "Horizontal padding resets look.plate.clickX")
