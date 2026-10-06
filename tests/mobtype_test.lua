function issecretvalue() return false end
function UnitIsTapDenied() return false end
function UnitIsPlayer() return false end
function UnitClassBase() return nil end
function UnitIsBossMob() return false end
function UnitIsLieutenant() return false end
function UnitReaction() return 5 end
function UnitAffectingCombat() return false end
function UnitThreatSituation() return nil end
function UnitEffectiveLevel() return 1 end
function UnitGroupRolesAssigned() return nil end
function UnitIsUnit() return false end
function UnitExists() return false end
function IsInInstance() return false, "none" end
C_SpecializationInfo = { GetSpecialization = function() return nil end, GetSpecializationInfo = function() end }
Enum = { PowerType = { Mana = 0 } }
function CreateFrame()
    local f = {}
    function f:RegisterEvent() end
    function f:RegisterUnitEvent() end
    function f:SetScript() end
    return f
end

local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function MobTypeWith(classification, powerType)
    function UnitClassification() return classification end
    function UnitPowerType() return powerType end
    local ns = {}
    assert(loadfile("Plateau/Features/UnitColors.lua"))("Plateau", ns)
    local flags = {}
    local result = ns.UnitColors:MobType("target", flags)
    return result, flags
end

do
    local result, flags = MobTypeWith("normal", 1)
    check(result == "trivial", "a normal, non-elite, non-caster enemy falls back to trivial (was 'melee')")
    check(flags.trivial == true,
        "the fallback also flips flags.trivial itself, since color/scale lookups read the flags table, not just the returned name")
end
do
    local result = MobTypeWith("normal", 0)
    check(result == "caster", "a mana-using enemy still classifies as caster")
end
do
    local result, flags = MobTypeWith("elite", 1)
    check(result == "elite", "an elite enemy still classifies as elite, not swallowed by the trivial fallback")
    check(flags.trivial == false, "the trivial fallback doesn't also mark an elite enemy as trivial")
end
do
    local result, flags = MobTypeWith("minus", 0)
    check(result == "trivial", "a minus-classified enemy classifies as trivial even if it also uses mana")
    check(flags.trivial == true, "flags.trivial is true for an explicitly minus-classified enemy too")
end
