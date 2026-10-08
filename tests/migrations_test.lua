local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = { version = 1, profiles = { Default = { look = { highlight = { color = { 1, 0, 0, 1 }, size = 3 }, castbar = { height = 14 } } } }, profileKeys = {} }
ns.DB:Init()
local t = ns.DB.profile.look.target
check(PlateauDB.version == 23, "schema bumped to the latest version")
check(t.ringColor[1] == 1 and t.ringColor[2] == 0, "v1 ring color ends up in target.ringColor")
check(t.ringSize == 3, "v1 ring size ends up in target.ringSize")
check(rawget(ns.DB.profile.look, "highlight") == nil, "highlight group removed")
check(ns.DB.profile.look.focus.ring == true and t.dimOthers == 1, "focus/dim defaults readable")
check(ns.DB.profile.look.castbar.height == 14, "unrelated settings untouched")
ns.DB:Shutdown()
check(PlateauDB.profiles.Default.look.target.ringSize == 3, "migrated value survives strip")

PlateauDB = nil
ns.DB:Init()
check(PlateauDB.version == 23 and ns.DB.profile.look.target.ringSize == 2, "fresh install starts at the latest version with defaults")

PlateauDB = { version = 1, profiles = { Default = { look = { health = { tapped = { 0.2, 0.2, 0.9, 1 }, borderSize = 2 } } } }, profileKeys = {} }
ns.DB:Init()
local colors = ns.DB.profile.look.colors
check(colors.tapped[3] == 0.9, "v3: tapped moved from health to colors")
check(rawget(ns.DB.profile.look.health, "tapped") == nil, "v3: health.tapped removed")
check(ns.DB.profile.look.health.borderSize == 2, "v3: other health settings kept")
check(colors.caster == true and colors.casterColor[2] == 0.878, "colors defaults readable")

PlateauDB = { version = 3, profiles = { Default = { look = { highlight = {
    enabled = true, targetRingColor = { 0, 1, 0, 1 }, targetColorBar = true, targetScale = 1.2, dimOthers = 0.6,
    focusRing = false, focusBarColor = { 1, 0, 1, 1 } } } } }, profileKeys = {} }
ns.DB:Init()
local look = ns.DB.profile.look
check(look.target.ringColor[2] == 1 and look.target.colorBar == true and look.target.scale == 1.2 and look.target.dimOthers == 0.6, "v4: target keys moved")
check(look.focus.ring == false and look.focus.barColor[3] == 1, "v4: focus keys moved")
check(look.focus.ringSize == 2 and look.target.dimOthers == 0.6, "v4: untouched keys fall back to defaults")
check(rawget(look, "highlight") == nil, "v4: highlight group gone")
ns.DB:Shutdown()
check(PlateauDB.profiles.Default.look.target.scale == 1.2 and PlateauDB.profiles.Default.look.focus.ring == false, "v4: survives strip")

PlateauDB = { version = 4, profiles = { Default = { look = {
    focus = { useTexture = true, texture = "Interface\\TargetingFrame\\UI-StatusBar", ringSize = 3 },
    target = { useTexture = false, texture = "ignored" } } } }, profileKeys = {} }
ns.DB:Init()
check(not ns.DB.views.focus and not ns.DB.views.target, "v5: focus and target are no longer separate states, so the old per-state texture migration has nothing to attach to")
check(ns.DB.views.enemy.health.texture == ns.defaults.look.health.texture, "v5: base texture untouched")
check(rawget(ns.DB.profile.look.focus, "useTexture") == nil and ns.DB.profile.look.focus.ringSize == 3, "v5: old keys removed, others kept")

PlateauDB = { version = 5, profiles = {
    Off = { look = { colors = { customReaction = false, neutral = { 1, 0.6, 0.8, 1 } } } },
    On = { look = { colors = { customReaction = true, neutral = { 0.2, 0.2, 0.2, 1 } } } },
}, profileKeys = { ["Stalador - Iridikron"] = "Off" } }
ns.DB:Init()
check(ns.DB.profile.look.colors.neutral[2] == 1 and ns.DB.profile.look.colors.neutral[3] == 0, "v6: unused custom neutral dropped to the game yellow")
ns.DB:SwitchProfile("On")
check(ns.DB.profile.look.colors.neutral[1] == 0.2, "v6: colors kept when they were switched on")
check(ns.DB.profile.look.colors.customReaction == true, "v6: switch kept")

PlateauDB = { version = 6, profiles = {
    Default = { look = { name = { overflow = "end", justify = "LEFT" } }, states = { friendly = { name = { justify = "RIGHT" } } } },
    Inside = { look = { name = { position = "CENTER", overflow = "end", width = 95, justify = "LEFT" } } },
}, profileKeys = { ["Stalador - Iridikron"] = "Default" } }
ns.DB:Init()
check(ns.DB.views.enemy.name.overflow == "none" and ns.DB.views.enemy.name.justify == "CENTER", "v7: full name, centered")
check(ns.DB.views.friendly.name.justify == "CENTER", "v7: friendly override centered")
ns.DB:SwitchProfile("Inside")
check(ns.DB.views.enemy.name.overflow == "end" and ns.DB.views.enemy.name.justify == "LEFT", "v7: name inside the bar kept")

PlateauDB = { version = 7, profiles = {
    Default = { look = { name = { mode = "lastWord" } }, states = { friendly = { name = { mode = "abbreviate" } } } },
}, profileKeys = { ["Stalador - Iridikron"] = "Default" } }
ns.DB:Init()
check(ns.DB.views.enemy.name.mode == "lastWord" and ns.DB.views.enemy.name.npcMode == "lastWord", "v8: NPC shortening picks up the existing player setting")
check(ns.DB.profile.look.friendly.nameMode == "abbreviate" and ns.DB.profile.look.friendly.npcNameMode == "abbreviate",
    "v8->v11: an old friendly name-mode override is carried over to the new independent friendly.nameMode/npcNameMode fields")

PlateauDB = { version = 7, profiles = { Default = { look = { name = { mode = "lastWord", npcMode = "full" } } } }, profileKeys = {} }
ns.DB:Init()
check(ns.DB.views.enemy.name.npcMode == "full", "v8: an explicit npcMode is never overwritten")

PlateauDB = { version = 8, profiles = { Default = { look = { castbar = { readyColor = { [2] = 1 } } } } }, profileKeys = {} }
ns.DB:Init()
local repaired = ns.DB.profile.look.castbar.readyColor
local base = ns.defaults.look.castbar.readyColor
check(repaired[1] == base[1] and repaired[2] == 1 and repaired[3] == base[3] and repaired[4] == 1,
    "v9: a color array left holey by the old per-channel strip is repaired from defaults, keeping the channel that was actually set")

PlateauDB = { version = 9, profiles = {
    Default = { look = { colors = { melee = false }, scaling = { melee = 0.9 } } },
    Custom = { look = { colors = { meleeColor = { 0.1, 0.2, 0.3, 1 } } } },
}, profileKeys = {}, baselines = { Default = { look = { colors = { boss = false } } } } }
ns.DB:Init()
check(ns.DB.profile.look.colors.trivial == false, "v10: melee turned off carries over to trivial")
check(ns.DB.profile.look.scaling.trivial == 0.9, "v10: melee scale carries over to trivial")
check(rawget(ns.DB.profile.look.colors, "melee") == nil and rawget(ns.DB.profile.look.scaling, "melee") == nil, "v10: old melee keys removed")
check(PlateauDB.baselines == nil, "v10: the removed Save Profile baseline is dropped")
ns.DB:UseProfile("Custom")
check(ns.DB.profile.look.colors.trivialColor[3] == 0.3, "v10: a custom melee color carries over to trivialColor")
ns.DB:UseProfile("Default")

PlateauDB = { version = 10, profiles = {
    Default = { look = { name = { mode = "lastWord", classColors = false } }, states = { friendly = {
        name = { mode = "firstWord", classColors = true },
        classification = { enabled = false },
        level = { enabled = false },
    } } },
}, profileKeys = {} }
ns.DB:Init()
local friendly = ns.DB.profile.look.friendly
check(friendly.nameMode == "firstWord", "v11: an old friendly name-mode override carries over to look.friendly.nameMode")
check(friendly.classColors == true, "v11: an old friendly class-colors override carries over to look.friendly.classColors")
check(friendly.classificationEnabled == false, "v11: an old friendly classification-enabled override carries over")
check(friendly.levelEnabled == false, "v11: an old friendly level-enabled override carries over")
check(rawget(ns.DB.profile, "states") == nil, "v11: the old per-state override table is dropped")
check(ns.DB.views.friendly.name == ns.DB.views.enemy.name, "v11: friendly and enemy share the same settings, no override layer")

PlateauDB = { version = 11, profiles = {
    Default = { look = { castbar = { enabled = false, height = 14 } } },
    Other = { look = { castbar = { enabled = true } } },
}, profileKeys = {} }
ns.DB:Init()
check(rawget(ns.DB.profile.look.castbar, "enabled") == nil, "v12: a saved 'cast bars off' setting is cleared, since the toggle is gone and bars always show")
check(ns.DB.profile.look.castbar.height == 14, "v12: other cast bar settings are untouched")
ns.DB:UseProfile("Other")
check(rawget(ns.DB.profile.look.castbar, "enabled") == nil, "v12: a saved 'cast bars on' setting is cleared too, nothing left to read it")

CreateFrame = CreateFrame or function()
    return { RegisterEvent = function() end, SetScript = function() end, Hide = function() end, Show = function() end, SetShown = function() end }
end
load("Core/Media.lua")
local BARS = "Interface\\AddOns\\Plateau\\Art\\Bars\\"
PlateauDB = { version = 12, profiles = {
    Default = { look = {
        health = { texture = BARS .. "checkers-fine.png", borderSize = 2 },
        target = { texture = BARS .. "stripes-thin.png", overlayPattern = BARS .. "checkers-medium.png" },
        focus = { texture = "Interface\\TargetingFrame\\UI-StatusBar" },
        castbar = { texture = BARS .. "checkers-large.png", height = 14 },
    } },
}, profileKeys = {} }
ns.DB:Init()
local migrated = ns.DB.profile.look
check(rawget(migrated.health, "texture") == nil, "v13: a Plateau pattern saved as the health texture is cleared back to the default texture")
check(migrated.health.overlayPattern == BARS .. "checkers-fine.png" and migrated.health.overlayAlpha == 1,
    "v13: that pattern moves to the health overlay at full strength, so the bar looks the same")
check(migrated.health.borderSize == 2, "v13: other health settings are untouched")
check(rawget(migrated.target, "texture") == nil and migrated.target.overlayPattern == BARS .. "checkers-medium.png",
    "v13: a target pattern texture is cleared without replacing an overlay the user already picked")
check(migrated.focus.texture == "Interface\\TargetingFrame\\UI-StatusBar", "v13: a real texture is left alone")
check(rawget(migrated.castbar, "texture") == nil and migrated.castbar.height == 14, "v13: a pattern cast bar texture is cleared, other cast bar settings kept")

PlateauDB = { version = 13, profiles = {
    ["Name inside"] = { look = { name = { position = "CENTER" } } },
    Slim = { look = {} },
}, profileKeys = {
    ["Stalador - Iridikron"] = "Name inside",
    ["Other - Iridikron"] = "Slim",
}, global = { builtins = { ["Name inside"] = true, Slim = true } },
assignments = { ["Stalador - Iridikron"] = {
    content = { instance1 = "Name inside" },
    spec = { [1] = "Slim" },
} } }
ns.DB:Init()
check(rawget(PlateauDB.profiles, "Name inside") == nil and PlateauDB.profiles.Compact ~= nil,
    "v14: the 'Name inside' built-in is renamed to 'Compact', keeping its saved settings")
check(PlateauDB.profiles.Compact.look.name.position == "CENTER", "v14: the renamed profile's settings survive untouched")
check(PlateauDB.global.builtins["Name inside"] == nil and PlateauDB.global.builtins.Compact == true,
    "v14: the seeded-builtin flag moves with the rename, so it's never reseeded under the old name")
check(PlateauDB.profileKeys["Stalador - Iridikron"] == "Compact", "v14: a character using the old name now uses the new one")
check(PlateauDB.profileKeys["Other - Iridikron"] == "Slim", "v14: a character on an unrelated profile is untouched")
check(PlateauDB.assignments["Stalador - Iridikron"].content.instance1 == "Compact", "v14: a content auto-profile assignment is renamed")
check(PlateauDB.assignments["Stalador - Iridikron"].spec[1] == "Slim", "v14: an unrelated spec auto-profile assignment is untouched")

PlateauDB = { version = 13, profiles = {
    ["Name inside"] = { look = { name = { position = "CENTER" } } },
    Compact = { look = { name = { position = "BOTTOM" } } },
}, profileKeys = {} }
ns.DB:Init()
check(PlateauDB.profiles["Name inside"] ~= nil and PlateauDB.profiles.Compact.look.name.position == "BOTTOM",
    "v14: if the player already has their own profile called Compact, the old one is left alone rather than overwriting it")

PlateauDB = { version = 14, profiles = {
    Default = { look = { friendly = { playerNameSize = 14, npcNameSize = 12 } } },
    Big = { look = { name = { size = 12 }, friendly = { playerNameSize = 12, npcNameSize = 20 } } },
    Small = { look = { friendly = { playerNameSize = 8, npcNameSize = 0 } } },
}, profileKeys = {} }
ns.DB:Init()
local p = PlateauDB.profiles
check(p.Default.look.friendly.playerNameScale == 4 and p.Default.look.friendly.npcNameScale == 3,
    "v15: 14pt and 12pt friendly names over a 10pt base become Extra Large and Large")
check(p.Default.look.friendly.playerNameSize == nil and p.Default.look.friendly.npcNameSize == nil, "v15: the old point sizes are removed")
check(p.Big.look.friendly.playerNameScale == nil and p.Big.look.friendly.npcNameScale == 5,
    "v15: the step is measured from the profile's own name size; matching it stays Medium (the default)")
check(p.Small.look.friendly.playerNameScale == 1 and p.Small.look.friendly.npcNameScale == nil,
    "v15: a smaller size becomes Small, and 0 (follow the name size) becomes Medium")

PlateauDB = { version = 15, profiles = {
    On = { look = { scaling = { layerByType = true, layerOrder = "boss,target", boss = 1.3 } }, states = { friendly = { scaling = { layerByType = true } } } },
    Off = { look = { scaling = { layerByType = false, layerOrder = "trivial" } } },
}, profileKeys = { ["Stalador - Iridikron"] = "On" } }
ns.DB:Init()
local on = PlateauDB.profiles.On.look.scaling
check(PlateauDB.version == 23 and on.castFront == true, "v16: priority layering on becomes Casting enemies in front on")
check(on.layerByType == nil and on.layerOrder == nil and on.boss == 1.3, "v16: the old layering keys are removed and other scaling settings kept")
check(PlateauDB.profiles.On.states.friendly.scaling.castFront == true and PlateauDB.profiles.On.states.friendly.scaling.layerByType == nil, "v16: state overrides are converted too")
local off = PlateauDB.profiles.Off.look.scaling
check(off.castFront == nil and off.layerByType == nil and off.layerOrder == nil, "v16: priority layering off leaves Casting enemies in front at its default")
ns.DB:Shutdown()

PlateauDB = { version = 16, global = { probe = { { kind = "x" }, { kind = "y" } }, probeWatch = true, spellIDsByName = { a = {} } }, profiles = { Default = {} }, profileKeys = {} }
ns.DB:Init()
check(PlateauDB.global.probe == nil and PlateauDB.global.probeWatch == nil, "v17: the old probe log and probe watch are cleared")
check(PlateauDB.global.spellIDsByName ~= nil, "v17: other account data is kept")
ns.DB:Shutdown()

load("Core/Presets.lua")

PlateauDB = { version = 18, profiles = { Default = {}, Mine = { look = { enemyPower = { enabled = false } } }, Minimal = {} }, profileKeys = {} }
ns.DB:Init()
own = PlateauDB.profiles
check(own.Default.look.classPower.enabled == true and own.Default.look.enemyPower.enabled == true, "v19: your own profiles keep the class resource and enemy power bars")
check(own.Mine.look.enemyPower.enabled == false and own.Mine.look.classPower.enabled == true, "v19: a value you already chose is kept")
check(ns.DB:SwitchProfile("Minimal") and ns.DB:Get("look.classPower.enabled") == false and ns.DB:Get("look.enemyPower.enabled") == false, "v19: built-in looks have both bars off")
ns.DB:Shutdown()

PlateauDB = { version = 20, profiles = { Default = { look = { castbar = { interruptible = { 1, 0, 0, 1 }, channelColor = { 0, 0, 1, 1 }, height = 14 } },
    states = { target = { castbar = { interruptible = { 0, 1, 0, 1 } } } } } }, profileKeys = {} }
ns.DB:Init()
local cleaned = PlateauDB.profiles.Default
check(cleaned.look.castbar.interruptible == nil and cleaned.look.castbar.channelColor == nil and cleaned.look.castbar.height == 14, "v21: the removed no-interrupt cast colors are cleared, other cast bar settings kept")
check(cleaned.states.target.castbar.interruptible == nil, "v21: they are cleared from state overrides too")
ns.DB:Shutdown()

load("Core/Presets.lua")
PlateauDB = { version = 21, profiles = { Default = {}, Mine = { look = { castbar = { uninterruptible = { 1, 0, 0, 0.3 } } } }, Minimal = {} }, profileKeys = {} }
ns.DB:Init()
local own = PlateauDB.profiles
check(own.Default.look.castbar.uninterruptible[4] == 0.6, "v22: your own profiles keep the old see-through uninterruptible color")
check(own.Mine.look.castbar.uninterruptible[1] == 1 and own.Mine.look.castbar.uninterruptible[4] == 0.3, "v22: an uninterruptible color you picked is kept")
check(ns.DB:SwitchProfile("Minimal") and ns.DB:Get("look.castbar.uninterruptible")[4] == 1, "v22: built-in looks draw uninterruptible casts solid")
ns.DB:Shutdown()

PlateauDB = { version = 22, profiles = { Default = {}, Mine = { look = { classPower = { position = "LEFT", offsetY = 5 } } }, Minimal = {} }, profileKeys = {} }
ns.DB:Init()
own = PlateauDB.profiles
local pinned = own.Default.look.classPower
check(pinned.position == "BOTTOM" and pinned.gap == 22 and pinned.offsetY == 0, "v23: your own profiles keep the class resource below the plate")
check(own.Mine.look.classPower.position == "LEFT" and own.Mine.look.classPower.offsetY == 5 and own.Mine.look.classPower.gap == 22, "v23: a class resource spot you picked is kept")
check(ns.DB:SwitchProfile("Minimal") and ns.DB:Get("look.classPower.position") == "TOP" and ns.DB:Get("look.classPower.offsetY") == -3, "v23: built-in looks put the class resource on the health bar's top edge")
ns.DB:Shutdown()
