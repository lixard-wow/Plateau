local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local newer = {
    version = 30,
    profiles = { Default = { look = { plate = { width = 177 }, futureSetting = true } } },
    profileKeys = { ["Stalador - Iridikron"] = "Default" },
    global = { futureGlobal = "keep" },
}
PlateauDB = newer
ns.DB:Init()
check(ns.DB.newerSchema == 30, "settings from a newer version are recognized")
check(PlateauDB.newerBackup == newer and newer.version == 30, "the newer settings are kept as they were, version included")
check(newer.profiles.Default.look.futureSetting == true and newer.profiles.Default.look.plate.width == 177, "settings this version doesn't know are not removed")
check(newer.global.futureGlobal == "keep", "account-wide settings from the newer version are kept too")
check(PlateauDB.version == 29 and ns.DB.profile ~= nil, "this version runs on its own settings in the meantime")
ns.DB:Shutdown()

ns.DB:Init()
check(ns.DB.newerSchema == nil and PlateauDB.newerBackup == newer and newer.profiles.Default.look.futureSetting == true, "logging in again keeps the backup untouched")
ns.DB:Shutdown()

newer.version = 29
ns.DB:Init()
check(ns.DB.restoredNewer == 29 and PlateauDB == newer, "a version that understands the backup puts it back")
check(ns.DB.profile.look.plate.width == 177, "the restored settings are in use")
check(PlateauDB.newerBackup == nil, "the backup isn't kept twice after it's restored")
ns.DB:Shutdown()

for _, bad in ipairs({ -1e9, 1.5, math.huge, -math.huge }) do
    PlateauDB = { version = bad, profiles = { Default = { look = { plate = { width = 150 } } } }, profileKeys = {} }
    local ok = pcall(ns.DB.Init, ns.DB)
    check(ok and PlateauDB.version == 29 and ns.DB.newerSchema == nil and ns.DB.profile.look.plate.width == 150, "a broken version number (" .. tostring(bad) .. ") is treated as current without looping")
    ns.DB:Shutdown()
end

PlateauDB = { version = 0 / 0, profiles = {}, profileKeys = {} }
check(pcall(ns.DB.Init, ns.DB) and PlateauDB.version == 29, "a NaN version number is treated as current")
