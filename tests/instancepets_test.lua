local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local cvars = { nameplateShowFriendlyPlayerMinions = "1", UnitNameFriendlyMinionName = "1" }
local overrides = {}
local combat = false
local instance = { false, "none" }
function InCombatLockdown() return combat end
function IsInInstance() return instance[1], instance[2] end
function CreateFrame()
    local f = { scripts = {} }
    function f:RegisterEvent() end
    function f:SetScript(name, fn) self.scripts[name] = fn end
    return f
end
local ns = {
    DB = { saved = { global = {} } },
    CVars = {
        Override = function(_, name, value) overrides[name] = overrides[name] or cvars[name]; cvars[name] = value; return true end,
        ClearOverride = function(_, name) if overrides[name] then cvars[name] = overrides[name]; overrides[name] = nil end; return true end,
    },
}
assert(loadfile("Plateau/Features/InstancePets.lua"))("Plateau", ns)
local P = ns.InstancePets
local fire = function(event) P.scripts.OnEvent(P, event) end

fire("PLAYER_ENTERING_WORLD")
check(cvars.nameplateShowFriendlyPlayerMinions == "1", "off by default: nothing changes in the world")
instance = { true, "party" }
fire("PLAYER_ENTERING_WORLD")
check(cvars.nameplateShowFriendlyPlayerMinions == "1", "off by default: nothing changes in a dungeon either")
P:SetOn(true)
check(cvars.nameplateShowFriendlyPlayerMinions == "0" and cvars.UnitNameFriendlyMinionName == "0", "turning it on inside a dungeon hides pet plates and names right away")
instance = { false, "none" }
fire("ZONE_CHANGED_NEW_AREA")
check(cvars.nameplateShowFriendlyPlayerMinions == "1" and cvars.UnitNameFriendlyMinionName == "1", "leaving the dungeon puts the user's values back")
instance = { true, "raid" }
fire("PLAYER_ENTERING_WORLD")
check(cvars.nameplateShowFriendlyPlayerMinions == "0", "raids count too")
instance = { true, "pvp" }
fire("PLAYER_ENTERING_WORLD")
check(cvars.nameplateShowFriendlyPlayerMinions == "1", "battlegrounds are left alone")
instance = { true, "party" }
combat = true
fire("PLAYER_ENTERING_WORLD")
check(cvars.nameplateShowFriendlyPlayerMinions == "1" and P.pending == true, "in combat the change waits")
combat = false
fire("PLAYER_REGEN_ENABLED")
check(cvars.nameplateShowFriendlyPlayerMinions == "0", "...and happens when combat ends")
P:SetOn(false)
check(cvars.nameplateShowFriendlyPlayerMinions == "1" and ns.DB.saved.global.hideInstancePets == nil, "turning it off inside restores the values and clears the saved flag")
