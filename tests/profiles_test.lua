local restyles = 0
local ns = { Driver = { Restyle = function() end, RequestRestyle = function() restyles = restyles + 1 end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = nil
DB:Init()
DB:Set("look.castbar.height", 18)
check(DB:CreateProfile("Raid"), "create empty profile")
check(DB.profileName == "Raid" and DB.views.enemy.castbar.height == 10, "new empty profile uses defaults")
check(PlateauDB.profileKeys["Stalador - Iridikron"] == "Raid", "character now uses the new profile")
check(DB:CreateProfile("M+", "Default"), "create profile copied from Default")
check(DB.views.enemy.castbar.height == 18 and DB.views.friendly.castbar.height == 18, "copy includes the base settings, friendly and enemy alike")
DB:Set("look.castbar.height", 30)
DB:SwitchProfile("Default")
check(DB.views.enemy.castbar.height == 18, "copy is independent of the source")
check(not DB:CreateProfile("Raid"), "duplicate name rejected")
check(not DB:CreateProfile("   "), "blank name rejected")
local names = DB:ListProfiles()
check(#names == 3 and names[1] == "Default" and names[2] == "M+" and names[3] == "Raid", "list is sorted")
check(DB:CopyProfile("M+") and DB.views.enemy.castbar.height == 30, "copy another profile into the current one")
check(not DB:CopyProfile("Default"), "can't copy a profile onto itself")
check(not DB:DeleteProfile("Default"), "can't delete the active profile")
check(DB:DeleteProfile("Raid") and #DB:ListProfiles() == 2, "delete another profile")
DB:Shutdown()
check(PlateauDB.profiles["M+"].look.castbar.height == 30, "profiles survive save")
DB:Init()
check(DB.profileName == "Default" and DB.views.enemy.castbar.height == 30, "reload keeps active profile")
check(restyles > 0, "switching requests a restyle")
