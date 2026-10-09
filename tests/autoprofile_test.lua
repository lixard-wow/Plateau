local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local instance, spec, combat = "none", 1, false
function IsInInstance() return instance ~= "none", instance end
C_SpecializationInfo = { GetSpecialization = function() return spec end }
function InCombatLockdown() return combat end
function CreateFrame() return { RegisterEvent = function() end, RegisterUnitEvent = function() end, SetScript = function() end } end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/AutoProfile.lua")
local DB, Auto = ns.DB, ns.AutoProfile
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = nil
DB:Init()
DB:CreateProfile("Raid")
DB:CreateProfile("Tank")
DB:SwitchProfile("Default")
Auto:Set("content", "raid", "Raid")
Auto:Set("spec", 2, "Tank")
check(DB.profileName == "Default", "open world, spec 1: chosen profile")
spec = 2; Auto:Apply()
check(DB.profileName == "Tank", "spec 2 switches to its profile")
check(PlateauDB.profileKeys["Stalador - Iridikron"] == "Default", "automatic switch keeps the chosen profile")
instance = "raid"; Auto:Apply()
check(DB.profileName == "Raid", "raid beats spec")
instance = "none"; spec = 1; Auto:Apply()
check(DB.profileName == "Default", "back to chosen profile when nothing matches")
combat = true; instance = "raid"; Auto:Apply()
check(DB.profileName == "Default", "no switch in combat")
combat = false; Auto:Apply()
check(DB.profileName == "Raid", "switch once combat ends")
DB:SwitchProfile("Default")
DB:DeleteProfile("Raid")
check(Auto:Get("content", "raid") == "", "deleting a profile clears its assignment")
Auto:Apply()
check(DB.profileName == "Default", "deleted assignment falls back")

instance = "none"; spec = 2; Auto:Apply()
check(DB.profileName == "Tank", "spec 2 auto-switches to its profile again")
DB:SwitchProfile("Default")
Auto:Apply()
check(DB.profileName == "Default", "a manual pick is not reverted when nothing about content or spec changed")
spec = 1; Auto:Apply()
check(DB.profileName == "Default", "a real spec change still re-resolves, falling back since spec 1 has no assignment")
spec = 2; Auto:Apply()
check(DB.profileName == "Tank", "a real spec change back re-applies its assignment")

combat = true
Auto:Set("spec", 2, "Default")
check(DB.profileName == "Tank", "editing an assignment in combat is deferred, not applied yet")
combat = false
Auto:Apply()
check(DB.profileName == "Default", "the deferred edit is still forced through once combat ends, even though content/spec didn't change")
