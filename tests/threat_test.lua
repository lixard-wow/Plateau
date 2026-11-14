function issecretvalue(v) return v == "secret" end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function UnitIsTapDenied() return false end
function UnitIsPlayer() return false end
function UnitAffectingCombat() return true end
function UnitReaction() return 2 end
function IsInInstance() return true, "party" end
function IsInRaid() return false end
function GetNumGroupMembers() return 3 end
function UnitClass() return "Warrior", "WARRIOR" end
Enum = { PowerType = { Mana = 0 } }

local status, mobTarget = nil, nil
function UnitThreatSituation(who)
    if who == "player" then return status end
end
function UnitExists(unit)
    if unit == "nameplate1target" then return mobTarget ~= nil end
    return false
end
function UnitIsUnit(a, b) return a == "nameplate1target" and b == "player" and mobTarget == "player" end
function UnitInParty(unit) return unit == "nameplate1target" and mobTarget == "party1" end
function UnitInRaid() return nil end

local script
function CreateFrame()
    local f = {}
    function f:RegisterEvent() end
    function f:RegisterUnitEvent() end
    function f:SetScript(_, fn) script = fn end
    return f
end

local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = { Driver = { RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
C_EventUtils = C_EventUtils or { IsEventValid = function() return true end }
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
assert(loadfile("Plateau/Features/UnitColors.lua"))("Plateau", ns)
local cfg = {
    threat = true, threatDisplay = "bar", showThreatGood = false, showThreatWarning = true,
    threatGood = { 0, 1, 0, 1 }, threatWarning = { 0, 0, 1, 1 }, threatBad = { 1, 0, 0, 1 },
}
ns.UnitColors:Configure(cfg, "enemy")
C_Timer = { After = function() end }
script(nil, "PLAYER_ENTERING_WORLD")

local function Threat()
    local r, g, b = ns.UnitColors:Threat(cfg, "nameplate1")
    if r == nil then return "none" end
    if r == 1 then return "bad" end
    if b == 1 then return "warning" end
    if g == 1 then return "good" end
    return "?"
end

status, mobTarget = 3, "player"
check(Threat() == "none", "you have threat: no threat color, the mob keeps its normal color")
cfg.showThreatGood = true
check(Threat() == "good", "you have threat with the have-threat color on: that color")
cfg.showThreatGood = false

status = 2
check(Threat() == "warning", "you are about to lose threat: warning color")
status = 1
check(Threat() == "warning", "you are about to pull threat: warning color")
cfg.showThreatWarning = false
check(Threat() == "none", "warning color off: no threat color while threat changes")
cfg.showThreatWarning = true

status, mobTarget = 0, "party1"
check(Threat() == "bad", "someone else has threat while you are on the list: threat color")

status, mobTarget = nil, "party1"
check(Threat() == "bad", "the mob hits a group member and you are not on its list: threat color")

status, mobTarget = nil, nil
check(Threat() == "none", "mob not fighting your group: no threat color")

status = "secret"
check(Threat() == "none", "hidden threat: no threat color")

check(ns.UnitColors.IsTank == nil, "no role rules left")
