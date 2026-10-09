local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

DB:Init()
check(DB.profile.look.castbar.height == 10, "default read through")
check(DB:Set("look.castbar.height", 14), "set number")
check(DB.profile.look.castbar.height == 14, "number stored")
check(DB:Set("look.castbar.readyColor", {0, 1, 0}), "set color 3 values")
local c = DB.profile.look.castbar.readyColor
check(c[1] == 0 and c[2] == 1 and c[3] == 0 and c[4] == 1, "color alpha filled from default")
check(not DB:Set("look.castbar.height", "big"), "rejects wrong type")
check(not DB:Set("look.castbar.nope", 1), "rejects unknown key")
check(not DB:Set("look.castbar", 1), "rejects group")
check(DB:Set("look.name.enabled", false), "set boolean")
check(DB:Set("look.name.size", 10), "set value equal to default")

DB:Shutdown()
local saved = PlateauDB.profiles.Default
check(saved.look.castbar.height == 14, "changed value kept after strip")
check(saved.look.name.size == nil, "default-equal value stripped")
check(saved.look.health == nil and saved.look.highlight == nil, "untouched groups stripped")
check(saved.behavior == nil, "empty behavior stripped")
local i = saved.look.castbar.readyColor
check(i[1] == 0 and i[2] == 1 and i[3] == 0 and i[4] == 1, "changed color kept whole, not stripped per channel")
check(saved.look.castbar.uninterruptible == nil, "untouched color (equal to default) stripped as a whole")

DB:Init()
c = DB.profile.look.castbar.readyColor
check(c[1] == 0 and c[2] == 1 and c[3] == 0 and c[4] == 1, "reload: whole color survives, no channel silently falls back to default")
check(DB.profile.look.name.enabled == false, "reload: boolean kept")
check(DB:Reset("look.castbar.height") and DB.profile.look.castbar.height == 10, "reset one setting")
check(DB:Reset("look.castbar.readyColor") and DB.profile.look.castbar.readyColor[1] == ns.defaults.look.castbar.readyColor[1], "reset color")
check(DB:Reset() and DB.profile.look.name.enabled == true, "reset all")
check(PlateauDB.version == 24 and PlateauDB.profileKeys["Stalador - Iridikron"] == "Default", "version + profile key")

PlateauDB = { version = "seventeen", global = 3, profiles = { Default = "oops", Other = { look = 5, states = "x" }, [7] = {} }, profileKeys = { ["Stalador - Iridikron"] = 12 }, assignments = "bad" }
local ok = pcall(DB.Init, DB)
check(ok, "damaged saved data with wrong types doesn't stop Plateau from starting")
check(type(PlateauDB.global) == "table" and type(PlateauDB.profiles.Default) == "table", "wrong-type data groups and profiles are replaced")
check(rawget(PlateauDB.profiles.Other, "states") == nil and DB:Get("look.plate.width") ~= nil, "a profile's broken look and states are dropped, settings fall back to defaults")
check(PlateauDB.profiles[7] == nil and PlateauDB.version ~= "seventeen", "non-text profile names and a broken version number are cleared")
DB.charKey = nil
local switched = pcall(DB.UseProfile, DB, "Default", false)
check(switched, "switching profile before the character is known doesn't error")
DB:Shutdown()

LibStub = LibStub or function() return {} end
assert(loadfile("Plateau/Core/Share.lua"))("Plateau", ns)
PlateauDB = { profiles = { Default = { look = { castbar = { textJustify = "SIDEWAYS", height = 12 }, scaling = { boss = 0 } }, states = { friendly = { castbar = { textJustify = 5 } } } } }, profileKeys = {} }
DB:Init()
check(DB:Get("look.castbar.textJustify") == ns.defaults.look.castbar.textJustify and DB:Get("look.castbar.height") == 12, "a saved invalid alignment falls back to the default at login; valid values stay")
check(DB:Get("look.scaling.boss") == 0.1, "a saved zero scale is raised to the minimum at login")
DB:Shutdown()

PlateauDB = { profiles = { Default = {} }, profileKeys = {}, assignments = { ["A - R"] = { content = {}, spec = {} }, ["B - R"] = { content = { raid = "Slim" }, spec = {} } } }
DB:Init()
DB:Shutdown()
check(PlateauDB.assignments["A - R"] == nil and PlateauDB.assignments["B - R"].content.raid == "Slim", "characters with no automatic switching rules aren't saved; real rules are kept")
