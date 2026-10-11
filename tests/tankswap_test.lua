function issecretvalue(v) return v == "secret" end
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function UnitIsTapDenied() return false end
function UnitIsPlayer() return false end
function UnitAffectingCombat() return true end
function UnitReaction() return 2 end
function IsInInstance() return true, "raid" end
function IsInRaid() return true end
function GetNumGroupMembers() return 3 end
Enum = { PowerType = { Mana = 0 } }
C_SpecializationInfo = {
    GetSpecialization = function() return 1 end,
    GetSpecializationInfo = function() return nil, nil, nil, nil, "TANK" end,
}

local roles = { raid1 = "TANK", raid2 = "TANK", raid3 = "DAMAGER" }
local threat = {}
local mobTarget = "secret"
function UnitGroupRolesAssigned(unit)
    if unit == "nameplate1target" then return mobTarget end
    return roles[unit] or "NONE"
end
function UnitExists(unit) return roles[unit] ~= nil end
function UnitIsUnit(a, b) return a == "raid1" and b == "player" end
function UnitThreatSituation(who, unit)
    if who == "player" then who = "raid1" end
    return threat[who]
end

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

threat = { raid1 = 3, raid2 = 2 }
local r, g = Color()
check(r == 0 and g == 1, "holding the mob yourself shows the good color")

threat = { raid1 = 2, raid2 = 3 }
r, g = Color()
check(r == 0.5 and g == 0, "after the other tank taunts, the off-tank color shows even when the mob's target is hidden")

threat = { raid2 = 3 }
r, g = Color()
check(r == 0.5 and g == 0, "a mob held by the other tank shows the off-tank color when you're not on its threat list")

threat = { raid1 = 2, raid3 = 3 }
r, g = Color()
check(r == 0 and g == 0, "a mob that left the tanks for a damage dealer shows the warning color, not off-tank")

roles.raid2 = "DAMAGER"
script(nil, "PLAYER_ROLES_ASSIGNED")
threat = { raid1 = 2, raid2 = 3 }
r, g = Color()
check(r == 0 and g == 0, "a player who switched off tank no longer counts as the other tank")
