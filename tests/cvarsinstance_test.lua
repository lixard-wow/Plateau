local game = { nameplateShowFriendlyPlayerMinions = "1", UnitNameFriendlyMinionName = "1" }
local onEvent
C_CVar = {
    GetCVar = function(name) return game[name] end,
    SetCVar = function(name, value)
        game[name] = tostring(value)
        onEvent(ns_cvars, "CVAR_UPDATE", name)
    end,
}
function InCombatLockdown() return false end
local inside = true
function IsInInstance() return inside, inside and "party" or "none" end
function CreateFrame()
    local frame = { RegisterEvent = function() end }
    frame.SetScript = function(_, _, fn)
        if not onEvent then onEvent = fn end
    end
    return frame
end

local ns = { DB = { saved = { global = { hideInstancePets = true } } } }
assert(loadfile("Plateau/Core/CVars.lua"))("Plateau", ns)
ns_cvars = ns.CVars
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
assert(loadfile("Plateau/Features/InstancePets.lua"))("Plateau", ns)
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

onEvent(ns.CVars, "PLAYER_LOGIN")
ns.InstancePets:Update()
check(game.nameplateShowFriendlyPlayerMinions == "0" and game.UnitNameFriendlyMinionName == "0", "in a dungeon, friendly minions are hidden")
check(ns.InstancePets:IsOn(), "Plateau's own change does not count as the player's")

game.nameplateShowFriendlyPlayerMinions = "1"
onEvent(ns.CVars, "CVAR_UPDATE", "nameplateShowFriendlyPlayerMinions")
check(not ns.InstancePets:IsOn(), "turning minions on in Blizzard's menu stops hiding them in dungeons")
check(game.nameplateShowFriendlyPlayerMinions == "1" and game.UnitNameFriendlyMinionName == "1", "both minion settings are back on")
check(not ns.CVars:IsOverridden("nameplateShowFriendlyPlayerMinions"), "no override left to undo it on reload")

onEvent(ns.CVars, "PLAYER_LOGOUT")
onEvent(ns.CVars, "PLAYER_LOGIN")
ns.InstancePets:Update()
check(game.nameplateShowFriendlyPlayerMinions == "1", "still on after a reload in the dungeon")
