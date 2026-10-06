local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
Plateau = {}
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
check(DB.profileName == "Normal", "fresh install starts on the Normal profile")
check(#DB:ListProfiles() == #ns.Builtins.list, "every built-in profile is created")
check(DB:SwitchProfile("Compact") and DB:Get("look.name.position") ~= ns.defaults.look.name.position, "Compact profile carries the compact look")
check(DB:SwitchProfile("Normal") and DB:Get("look.plate.height") == 14 and DB:Get("look.plate.width") == 150, "Normal profile carries the standard look")
DB:SwitchProfile("Normal")
DB:SwitchProfile("Classic unit frames")
check(DB:Get("look.health.borderStyle") == "thinTooltip" and DB:Get("look.target.glow") == true, "Classic unit frames profile carries its tooltip-border look")
DB:Set("look.plate.height", 20)
check(DB:RestoreBuiltin("Classic unit frames") and DB:Get("look.plate.height") == 12, "restoring a built-in puts it back")
DB:SwitchProfile("Normal")
DB:DeleteProfile("Classic unit frames")
DB:Shutdown()
DB:Init()
check(not has("Classic unit frames"), "a deleted built-in is not created again on load")
check(DB:UseBuiltin("Classic unit frames") and DB.profileName == "Classic unit frames" and has("Classic unit frames"), "picking a deleted built-in recreates it")

PlateauDB = { version = 7, profiles = { Default = { look = { plate = { width = 170 } } } }, profileKeys = { ["Stalador - Iridikron"] = "Default" } }
DB:Init()
check(DB.profileName == "Default" and DB:Get("look.plate.width") == 170, "existing players keep their profile")
check(has("Familiar layout") and has("Normal") and has("Classic unit frames") and has("Compact") and has("Clean and flat") and has("Bold and crisp") and not has("Plateau") and not has("Classic"), "existing players get all six built-ins added")

PlateauDB = { version = 15, profiles = { Plateau = { look = { plate = { width = 170 } } }, Classic = {} }, profileKeys = { ["Stalador - Iridikron"] = "Plateau" },
    global = { builtins = { Plateau = true, Classic = true } } }
DB:Init()
check(DB.profileName == "Plateau" and DB:Get("look.plate.width") == 170 and has("Classic"), "profiles from removed built-ins are kept as ordinary profiles")
check(ns.Builtins.ByName("Plateau") == nil and ns.Builtins.Label("Plateau") == "Plateau", "removed built-ins no longer show as built-in")
