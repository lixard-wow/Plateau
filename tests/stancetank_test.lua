function issecretvalue(v) return v == "secret" end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function UnitIsTapDenied() return false end
function UnitIsPlayer() return false end
function UnitAffectingCombat() return true end
function UnitReaction() return 2 end
function IsInInstance() return false, "none" end
function IsInRaid() return false end
function GetNumGroupMembers() return 0 end
function UnitExists() return false end
function UnitIsUnit() return false end
function UnitClass() return "Warrior", "WARRIOR" end
Enum = { PowerType = { Mana = 0 } }
C_SpecializationInfo = {
    GetSpecialization = function() return 0 end,
    GetSpecializationInfo = function() return nil end,
}

local form, lfgRole, status = nil, "NONE", nil
function GetShapeshiftFormID() return form end
function UnitGroupRolesAssigned(unit)
    if unit == "player" then return lfgRole end
    return "NONE"
end
function UnitThreatSituation() return status end

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
local ns = { Driver = { RequestRestyle = function() restyles = restyles + 1 end } }
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

local plate = { state = "enemy" }
local function Color()
    local r, g, b = ns.UnitColors:Resolve(plate, "nameplate1")
    return r, g, b
end

status = 3
local r, g = Color()
check(r == 1 and g == 0, "without a spec or stance, holding a mob shows the danger color")

form = 18
restyles = 0
script(nil, "UPDATE_SHAPESHIFT_FORM")
r, g = Color()
check(r == 0 and g == 1, "in Defensive Stance, holding a mob shows the good color")
check(restyles == 1, "entering a tank stance restyles the plates once")

status = nil
form = 5
script(nil, "UPDATE_SHAPESHIFT_FORM")
check(restyles == 1, "switching between tank forms does not restyle again")

form = nil
script(nil, "UPDATE_SHAPESHIFT_FORM")
status = 3
r, g = Color()
check(r == 1 and g == 0, "leaving the tank stance goes back to damage dealer colors")

lfgRole = "TANK"
script(nil, "PLAYER_ROLES_ASSIGNED")
r, g = Color()
check(r == 0 and g == 1, "a tank role from the group finder counts as tank")

