local game = { nameplateShowAll = "0", nameplateMotionSpeed = "0.025" }
local inCombat = false
C_CVar = {
    GetCVar = function(name) return game[name] end,
    SetCVar = function(name, value) game[name] = tostring(value) end,
}
function InCombatLockdown() return inCombat end
local onEvent
function CreateFrame()
    return { RegisterEvent = function() end, SetScript = function(_, _, fn) onEvent = fn end }
end
local ns = { DB = { saved = { global = {} } } }
assert(loadfile("Plateau/Core/CVars.lua"))("Plateau", ns)
local CVars = ns.CVars
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

CVars:Set("nameplateShowAll", 1)
check(game.nameplateShowAll == "1" and CVars:IsManaged("nameplateShowAll"), "set applies and manages")
check(ns.DB.saved.global.cvars.original.nameplateShowAll == "0", "original remembered")
CVars:Set("nameplateShowAll", 0)
check(not CVars:IsManaged("nameplateShowAll") and game.nameplateShowAll == "0", "setting back to original stops managing")

CVars:Set("nameplateMotionSpeed", 0.5)
game.nameplateMotionSpeed = "0.025"
CVars:Apply()
check(game.nameplateMotionSpeed == "0.5", "apply re-sets a managed value the game changed")
CVars:Release("nameplateMotionSpeed")
check(game.nameplateMotionSpeed == "0.025" and not CVars:IsManaged("nameplateMotionSpeed"), "release restores original")

inCombat = true
CVars:Set("nameplateShowAll", 1)
check(game.nameplateShowAll == "0", "combat: set deferred")
inCombat = false
CVars:Apply()
check(game.nameplateShowAll == "1", "after combat: deferred set applied")
inCombat = true
CVars:Release("nameplateShowAll")
check(game.nameplateShowAll == "1", "combat: release deferred")
inCombat = false
CVars:Apply()
check(game.nameplateShowAll == "0" and not CVars:IsManaged("nameplateShowAll"), "after combat: original restored")

CVars:Set("nameplateShowAll", 1)
CVars:Set("nameplateMotionSpeed", 0.3)
CVars:ReleaseAll()
check(game.nameplateShowAll == "0" and game.nameplateMotionSpeed == "0.025", "release all restores everything")
check(next(ns.DB.saved.global.cvars.managed) == nil, "nothing managed after release all")

ns.DB.saved.global.cvars.override = { nameplateSize = { user = "3", value = "5" } }
game.nameplateSize = "5"
onEvent(CVars, "PLAYER_LOGIN")
check(game.nameplateSize == "3" and next(ns.DB.saved.global.cvars.override or {}) == nil, "a size Plateau once set for a dungeon is put back at login and the old record removed")

game.nameplateSize = "4"
CVars:Set("nameplateSize", 3)
game.nameplateSize = "5"
onEvent(CVars, "CVAR_UPDATE", "nameplateSize")
check(CVars:Get("nameplateSize") == "5" and ns.DB.saved.global.cvars.managed.nameplateSize == "5", "a change made in Blizzard's own menu is adopted, so Plateau shows it and keeps it at the next login")
CVars:Apply()
check(game.nameplateSize == "5", "the login re-apply keeps the player's menu change instead of undoing it")
game.nameplateSize = "4"
onEvent(CVars, "CVAR_UPDATE", "nameplateSize")
check(not CVars:IsManaged("nameplateSize"), "setting it back to the value from before Plateau stops managing it")
CVars:Set("nameplateSize", 3)
inCombat = true
CVars:Set("nameplateSize", 2)
game.nameplateSize = "5"
onEvent(CVars, "CVAR_UPDATE", "nameplateSize")
check(ns.DB.saved.global.cvars.managed.nameplateSize == "2", "a Plateau change waiting for combat to end is not overwritten")
inCombat = false
CVars:Apply()
check(game.nameplateSize == "2", "...and is applied after combat")
onEvent(CVars, "CVAR_UPDATE", "nameplateShowAll")
check(not CVars:IsManaged("nameplateShowAll"), "changes to settings Plateau never touched are ignored")

game.nameplateOccludedAlphaMult = "0.4"
check(CVars:Override("nameplateOccludedAlphaMult", 1) and game.nameplateOccludedAlphaMult == "1", "an override sets the live value")
check(CVars:Get("nameplateOccludedAlphaMult") == "0.4", "Plateau still reports the player's own value while overridden")
onEvent(CVars, "CVAR_UPDATE", "nameplateOccludedAlphaMult")
check(CVars:UserValue("nameplateOccludedAlphaMult") == "0.4", "Plateau's own override is not mistaken for a menu change")
CVars:Set("nameplateOccludedAlphaMult", 0.6)
check(game.nameplateOccludedAlphaMult == "1" and CVars:Get("nameplateOccludedAlphaMult") == "0.6", "moving the slider while overridden saves the new value without undoing the override")
game.nameplateOccludedAlphaMult = "0.8"
onEvent(CVars, "CVAR_UPDATE", "nameplateOccludedAlphaMult")
check(CVars:UserValue("nameplateOccludedAlphaMult") == "0.8" and CVars:Get("nameplateOccludedAlphaMult") == "0.8", "a change in Blizzard's menu while overridden becomes the player's value")
CVars:Override("nameplateOccludedAlphaMult", 1)
check(CVars:ClearOverride("nameplateOccludedAlphaMult") and game.nameplateOccludedAlphaMult == "0.8", "ending the override puts the player's value back")
CVars:Override("nameplateOccludedAlphaMult", 1)
onEvent(CVars, "PLAYER_LOGIN")
check(game.nameplateOccludedAlphaMult == "0.8" and not CVars:IsOverridden("nameplateOccludedAlphaMult"), "logging in after leaving mid-override restores the player's value")

CVars:Override("nameplateOccludedAlphaMult", 1)
inCombat = true
onEvent(CVars, "PLAYER_LOGIN")
check(game.nameplateOccludedAlphaMult == "1" and CVars:IsOverridden("nameplateOccludedAlphaMult") and CVars:UserValue("nameplateOccludedAlphaMult") == "0.8", "a reload in combat keeps the override and the player's value instead of losing it")
inCombat = false
onEvent(CVars, "PLAYER_LOGOUT")
check(game.nameplateOccludedAlphaMult == "0.8" and CVars:IsOverridden("nameplateOccludedAlphaMult"), "logging out puts the player's value back but remembers the override")
game.nameplateOccludedAlphaMult = "1"
onEvent(CVars, "PLAYER_LOGIN")
check(game.nameplateOccludedAlphaMult == "0.8" and not CVars:IsOverridden("nameplateOccludedAlphaMult"), "the next login out of combat finishes the restore")
