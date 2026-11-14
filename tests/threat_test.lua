function issecretvalue(v) return v == "secret" end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function UnitIsTapDenied() return false end
function UnitIsPlayer() return false end
function UnitAffectingCombat() return true end
function UnitReaction() return 2 end
function IsInInstance() return true, "party" end
function IsInRaid() return false end
function GetNumGroupMembers() return 2 end
function GetShapeshiftFormID() return nil end
function UnitGroupRolesAssigned() return "TANK" end
Enum = { PowerType = { Mana = 0 } }
C_SpecializationInfo = {
    GetSpecialization = function() return 1 end,
    GetSpecializationInfo = function() return nil, nil, nil, nil, "TANK" end,
}

local classes = { player = "WARRIOR", party1 = "WARRIOR", party2 = "ROGUE" }
local auras = { player = true, party1 = true }
local threat = {}
local mobTarget = nil
function UnitClass(unit)
    if unit == "nameplate1target" then unit = mobTarget end
    local class = unit and classes[unit]
    return class, class
end
function UnitHasEffectivelyTankAura(unit)
    if unit == "nameplate1target" then unit = mobTarget end
    return unit ~= nil and auras[unit] == true
end
function UnitThreatSituation(who) return threat[who] end
function UnitExists(unit)
    if unit == "nameplate1target" then return mobTarget ~= nil end
    return classes[unit] ~= nil
end
function UnitIsUnit(a, b)
    if a == "nameplate1target" then a = mobTarget end
    return a == b
end
function UnitInParty(unit)
    if unit == "nameplate1target" then unit = mobTarget end
    return unit == "party1" or unit == "party2"
end
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

local restyles = 0
local ns = { flavor = "forever", Driver = { RequestRestyle = function() restyles = restyles + 1 end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
C_EventUtils = C_EventUtils or { IsEventValid = function() return true end }
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
assert(loadfile("Plateau/Features/UnitColors.lua"))("Plateau", ns)
local cfg = {
    threat = true, threatDisplay = "bar", showThreatGood = true, showThreatWarning = true, showOffTank = true,
    threatGood = { 0, 1, 0, 1 }, threatWarning = { 0, 0, 1, 1 }, threatBad = { 1, 0, 0, 1 }, offTankColor = { 0.5, 0, 1, 1 },
}
ns.UnitColors:Configure(cfg, "enemy")
C_Timer = { After = function() end }
script(nil, "PLAYER_ENTERING_WORLD")

local function Threat()
    local r, g, b = ns.UnitColors:Threat(cfg, "nameplate1")
    if r == nil then return "none" end
    if r == 0.5 then return "offtank" end
    if r == 1 then return "bad" end
    if b == 1 then return "warning" end
    if g == 1 then return "good" end
    return "?"
end

check(ns.UnitColors:IsTank() == true, "a warrior with a tank aura is a tank")
check(ns.UnitColors:TankAura() == true, "the debug line can read the tank aura")
threat, mobTarget = { player = 3 }, "player"
check(Threat() == "good", "tank holding the mob: safe color")
threat, mobTarget = { player = 2, party1 = 3 }, "party1"
check(Threat() == "offtank", "the other warrior with a tank aura holds the mob: off-tank color")
threat, mobTarget = { party1 = 3 }, "party1"
check(Threat() == "offtank", "the other tank holds a mob you are not on: off-tank color")

auras.party1 = false
threat, mobTarget = { player = 2, party1 = 3 }, "party1"
check(Threat() == "warning", "a warrior without a tank aura is not the other tank")
auras.party1 = true

threat, mobTarget = { player = 1, party2 = 3 }, "party2"
check(Threat() == "warning", "a mob that left for the rogue: warning, not off-tank")

auras.player = false
restyles = 0
script(nil, "UNIT_AURA")
check(ns.UnitColors:IsTank() == false, "leaving the tank stance makes you a damage dealer")
check(restyles == 1, "losing the tank aura restyles the plates once")
threat, mobTarget = { player = 3 }, "player"
check(Threat() == "bad", "damage dealer with aggro: threat color")
threat, mobTarget = { player = 0, party1 = 3 }, "party1"
check(Threat() == "good", "damage dealer while the tank holds the mob: safe color")

classes.player = "ROGUE"
auras.player = true
script(nil, "UNIT_AURA")
check(ns.UnitColors:IsTank() == false, "only warriors, druids and paladins can be tanks")

classes.player = "WARRIOR"
UnitHasEffectivelyTankAura = nil
script(nil, "UNIT_AURA")
check(ns.UnitColors:IsTank() == false and ns.UnitColors:TankAura() == nil, "without the tank aura function nobody is a tank")
