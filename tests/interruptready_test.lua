function wipe(t) for k in pairs(t) do t[k] = nil end return t end
local known = {}
local remaining = {}
local now = 1
function GetTime() return now end
local secret = false
local cooling = {}
function issecretvalue(v) return secret and type(v) == "number" end
function UnitClassBase() return "PALADIN" end
Enum = { SpellBookSpellBank = { Player = 0, Pet = 1 }, LuaCurveType = { Step = 1 } }
local function Duration(id)
    return { id = id, EvaluateRemainingDuration = function(self, curve)
        if curve.numeric then return remaining[self.id] end
        return remaining[self.id] > 0 and "notReady" or "ready"
    end }
end
C_Spell = {
    GetSpellCooldownDuration = function(id) return Duration(id) end,
    GetSpellCooldown = function(id) return { isActive = cooling[id] == true, isOnGCD = false } end,
    GetSpellName = function() return nil end,
}
C_SpellBook = {
    IsSpellKnown = function(id) return known[id] == true end,
    FindSpellBookSlotForSpell = function() return nil end,
    GetSpellBookItemInfo = function() return nil end,
}
C_CurveUtil = {
    CreateCurve = function() return { numeric = true, AddPoint = function() end } end,
}
local onEvent
function CreateFrame()
    return { RegisterEvent = function() end, RegisterUnitEvent = function() end, SetScript = function(_, _, f) onEvent = f end }
end
local ns = {}
assert(loadfile("Plateau/Features/InterruptReady.lua"))("Plateau", ns)
local IR = ns.InterruptReady
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

known[96231] = true
IR:Refresh()
remaining[96231] = 0
check(IR:GetSpellID() == 96231, "a paladin without Avenger's Shield tracks Rebuke")

known[31935] = true
IR:Refresh()
remaining[96231], remaining[31935] = 10, 0
now = 2
check(IR:GetCooldown().id == 31935 and IR:GetSpellID() == 31935, "Rebuke on cooldown, Avenger's Shield ready: the kick counts as ready through Avenger's Shield")
remaining[96231], remaining[31935] = 0, 8
now = 3
check(IR:GetCooldown().id == 96231 and IR:GetSpellID() == 96231, "Avenger's Shield on cooldown, Rebuke ready: Rebuke is used")
remaining[96231], remaining[31935] = 12, 5
now = 4
check(IR:GetCooldown().id == 31935, "both on cooldown: the one ready sooner is shown")
remaining[96231], remaining[31935] = 0, 0
now = 5
check(IR:GetSpellID() == 31935, "both ready: Avenger's Shield wins, so range fading uses its 30 yard reach")

known[96231] = nil
IR:Refresh()
remaining[31935] = 0
now = 6
check(IR:GetSpellID() == 31935 and IR:IsTracking(), "with only Avenger's Shield known, it is tracked on its own")

known[96231], known[31935] = true, true
IR:Refresh()
secret = true
remaining[96231], remaining[31935] = 10, 0
cooling[96231], cooling[31935] = true, false
onEvent(IR, "SPELL_UPDATE_COOLDOWN")
now = 7
check(IR:GetCooldown().id == 31935, "in combat with hidden timers, Rebuke on cooldown and Avenger's Shield ready: Avenger's Shield is used")
cooling[96231], cooling[31935] = false, true
onEvent(IR, "SPELL_UPDATE_COOLDOWN")
now = 8
check(IR:GetCooldown().id == 96231, "in combat with hidden timers, Avenger's Shield on cooldown: Rebuke is used")
cooling[96231], cooling[31935] = true, true
onEvent(IR, "SPELL_UPDATE_COOLDOWN")
now = 9
check(IR:GetCooldown().id == 96231, "in combat with hidden timers, both on cooldown: Rebuke is shown")
cooling[96231], cooling[31935] = false, false
onEvent(IR, "SPELL_UPDATE_COOLDOWN")
now = 10
check(IR:GetSpellID() == 31935, "in combat with hidden timers, both ready: Avenger's Shield wins for its reach")
