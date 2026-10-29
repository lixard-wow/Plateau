local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
Plateau = {}
Plateau.T = Plateau.T or (function() local l = {} assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", l) return l.T end)()
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Presets.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function has(name)
    for _, profile in ipairs(DB:ListProfiles()) do
        if profile == name then return true end
    end
    return false
end

PlateauDB = nil
DB:Init()
check(DB.profileName == "Minimal", "fresh install starts on the Minimal profile")
check(#DB:ListProfiles() == #ns.Builtins.list, "every built-in profile is created")
check(DB:SwitchProfile("Compact") and DB:Get("look.name.position") ~= ns.defaults.look.name.position, "Compact profile carries the compact look")
check(DB:SwitchProfile("Minimal") and DB:Get("look.plate.height") == 12 and DB:Get("look.plate.width") == 100, "Minimal profile carries the default look")
DB:SwitchProfile("Minimal")
DB:SwitchProfile("Unit frame")
check(DB:Get("look.health.borderStyle") == "thinTooltip" and DB:Get("look.target.glow") == true, "Unit frame profile carries its tooltip-border look")
DB:Set("look.plate.height", 20)
check(DB:RestoreBuiltin("Unit frame") and DB:Get("look.plate.height") == 12, "restoring a built-in puts it back")
DB:Set("look.plate.height", 20)
DB:Reset()
check(DB:Get("look.plate.height") == 12 and DB:Get("look.health.borderStyle") == "thinTooltip", "resetting everything on a built-in puts back its own look, not the defaults")
DB:SwitchProfile("Compact")
DB:Reset()
check(DB:Get("look.name.position") ~= ns.defaults.look.name.position, "each built-in resets to its own look")
DB:SwitchProfile("Minimal")
DB:DeleteProfile("Unit frame")
DB:Shutdown()
DB:Init()
check(not has("Unit frame"), "a deleted built-in is not created again on load")
check(DB:UseBuiltin("Unit frame") and DB.profileName == "Unit frame" and has("Unit frame"), "picking a deleted built-in recreates it")

PlateauDB = { version = 7, profiles = { Default = { look = { plate = { width = 170 } } } }, profileKeys = { ["Stalador - Iridikron"] = "Default" } }
DB:Init()
check(DB.profileName == "Default" and DB:Get("look.plate.width") == 170, "existing players keep their profile")
check(has("Blizzard-like") and has("Minimal") and has("Unit frame") and has("Compact") and has("Flat") and has("Heavy") and not has("Plateau") and not has("Classic"), "existing players get all six built-ins added")

PlateauDB = { version = 15, profiles = { Plateau = { look = { plate = { width = 170 } } }, Classic = {} }, profileKeys = { ["Stalador - Iridikron"] = "Plateau" },
    global = { builtins = { Plateau = true, Classic = true } } }
DB:Init()
check(DB.profileName == "Plateau" and DB:Get("look.plate.width") == 170 and has("Classic"), "profiles from removed built-ins are kept as ordinary profiles")
check(ns.Builtins.ByName("Plateau") == nil and ns.Builtins.Label("Plateau") == "Plateau", "removed built-ins no longer show as built-in")
