local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = nil
DB:Init()
check(DB.views.friendly.castbar == DB.views.enemy.castbar, "friendly and enemy share every group except the raid marker")
local marker = DB.views.friendly.raidMarker
check(marker.position == DB.views.enemy.raidMarker.position and marker.size == DB.views.enemy.raidMarker.size, "friendly raid marker follows enemy until given its own placement")
DB:Set("look.raidMarker.position", "CENTER")
check(marker.position == "CENTER", "friendly marker follows an enemy change while not separate")
DB:Set("look.friendly.raidMarker.own", true)
DB:Set("look.friendly.raidMarker.position", "TOP")
DB:Set("look.friendly.raidMarker.offsetY", 2)
check(DB.views.friendly.raidMarker.position == "TOP" and DB.views.friendly.raidMarker.offsetY == 2, "friendly marker uses its own placement once separate")
check(DB.views.enemy.raidMarker.position == "CENTER" and DB.views.enemy.raidMarker.offsetY == 0, "moving the friendly marker leaves the enemy marker alone")
DB:Set("look.raidMarker.size", 30)
check(DB.views.friendly.raidMarker.size == 30, "size and the rest stay shared")
DB:Shutdown(); DB:Init()
check(DB.views.friendly.raidMarker.position == "TOP" and DB.views.enemy.raidMarker.position == "CENTER", "both placements survive logout and login")
DB:Reset("look.friendly.raidMarker"); DB:Reset("look.raidMarker")
check(DB:Get("look.castbar.height") == 10, "reads the base default")
DB:Set("look.castbar.height", 14)
check(DB.views.friendly.castbar.height == 14 and DB.views.enemy.castbar.height == 14, "a change is visible identically on both views, since they're the same table")

check(not DB.views.target and not DB.views.focus and not DB.views.player, "target, focus and player are not separate views")

DB:Shutdown()
local saved = PlateauDB.profiles.Default
check(saved.look.castbar.height == 14, "base saved")
check(saved.states == nil, "no per-state override table is ever written")

DB:Init()
check(DB.views.friendly.castbar.height == 14, "reload: value kept")
DB:Set("look.castbar.height", 30)
check(DB.views.enemy.castbar.height == 30 and DB.views.friendly.castbar.height == 30, "a later base change reaches friendly too, since there's nothing to override it")
DB:Reset("look.castbar.height")
check(DB.views.friendly.castbar.height == 10, "reset falls back to the real default, for both views at once")
DB:Reset()
check(DB.views.enemy.castbar.height == 10, "reset all")
check(DB:Get("look.nope.x") == nil and not DB:Set("look.castbar.nope", 1), "unknown paths rejected")

check(DB:Get("look.castbar.height", "friendly") == 10, "an extra state argument to Get doesn't error or change the result")
check(DB:Set("look.castbar.height", 12, "friendly"), "an extra state argument to Set doesn't error")
check(DB:Get("look.castbar.height") == 12, "...and just sets the one real value")
DB:Reset("look.castbar.height")

DB:Set("look.friendly.enabled", true)
check(DB.views.enemy.friendly.enabled == true, "look.friendly.* settings are plain, independent settings")
DB:Shutdown()
check(PlateauDB.profiles.Default.look.friendly.enabled == true, "friendly-only setting saved")
DB:Init()
check(DB.views.friendly.friendly.enabled == true, "friendly-only setting reloads")

DB:SetSpecSpells("mine", "only", "192090, 164812", 104)
DB:SetSpecSpells("mine", "hide", "1079", 103)
check(DB:GetSpecSpells("mine", "only", 104) == "192090, 164812" and DB:GetSpecSpells("mine", "only", 103) == "", "spell lists are kept per spec")
DB:SetSpecSpells("cc", "hide", "   ", 104)
DB:Shutdown()
check(PlateauDB.profiles.Default.specSpells[104].mine.only == "192090, 164812" and PlateauDB.profiles.Default.specSpells[104].cc == nil, "spec lists saved, blank ones dropped")
DB:Init()
check(DB:GetSpecSpells("mine", "hide", 103) == "1079", "spec lists reload")
check(DB:SetSpecSpells("purge", "hide", "1", 104) and DB:GetSpecSpells("purge", "hide", 104) == "1", "enemy buffs have spell lists too")
check(not DB:SetSpecSpells("nope", "hide", "1", 104), "unknown groups have no spell lists")

PlateauDB = nil
DB:Init()
DB:Set("look.plate.width", 150)
local snapshot = DB:Snapshot()
DB:Set("look.plate.width", 190)
DB:Set("look.colors.bossColor", { 0, 0, 1 })
check(DB:Restore(snapshot), "restore accepted")
check(DB:Get("look.plate.width") == 150, "value restored")
check(DB:Get("look.colors.bossColor")[3] ~= 1 or DB:Get("look.colors.bossColor")[1] ~= 0, "later color change undone")
DB:Set("look.plate.width", 170)
check(DB:Get("look.plate.width") == 170, "profile still live after restore")

check(DB:Set("look.plate.width", 190, "player"), "an unrecognized state argument is not rejected outright")
check(not DB.views.player and DB:Get("look.plate.width") == 190, "it lands on the base nameplate instead of a state that never existed")
