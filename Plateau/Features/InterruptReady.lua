local _, ns = ...

local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration
local IsSpellKnown = C_SpellBook.IsSpellKnown
local issecretvalue = issecretvalue
local PLAYER_BANK = Enum.SpellBookSpellBank.Player
local PET_BANK = Enum.SpellBookSpellBank.Pet
local FindSpellBookSlotForSpell = C_SpellBook.FindSpellBookSlotForSpell
local GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo

function ns.FindKnownSpell(id, bank)
    if IsSpellKnown(id, bank) then
        return id
    end
    local name = C_Spell.GetSpellName(id)
    if not name or not FindSpellBookSlotForSpell then return nil end
    local slot, slotBank = FindSpellBookSlotForSpell(name)
    if not slot then return nil end
    local info = GetSpellBookItemInfo(slot, slotBank)
    local known = info and info.spellID
    if known and IsSpellKnown(known, slotBank) then
        return known
    end
    return nil
end

local candidates = {
    WARRIOR = { { 6552 }, { 72 } },
    ROGUE = { { 1766 } },
    MAGE = { { 2139 } },
    SHAMAN = { { 57994 }, { 8042 } },
    HUNTER = { { 147362 }, { 187707 } },
    DEATHKNIGHT = { { 47528 } },
    DEMONHUNTER = { { 183752 } },
    MONK = { { 116705 } },
    PALADIN = { { 96231 } },
    DRUID = { { 106839 }, { 78675 } },
    PRIEST = { { 15487 } },
    EVOKER = { { 351338 } },
    WARLOCK = { { 119910 }, { 132409 }, { 119914 }, { 19647, true }, { 89766, true } },
}

local extras = {
    PALADIN = { 31935 },
}

local InterruptReady = CreateFrame("Frame")
ns.InterruptReady = InterruptReady

local spellID, activeID
local extraIDs = {}
local remainingCurve
local curves = {}
local cooldownAt, cooldown
local colorAt, colors = {}, {}

function InterruptReady:Refresh()
    spellID, activeID = nil, nil
    cooldownAt = nil
    for i = #extraIDs, 1, -1 do
        extraIDs[i] = nil
    end
    local class = UnitClassBase("player")
    local list = candidates[class]
    if not list then return end
    for i = 1, #list do
        local id, isPet = list[i][1], list[i][2]
        local known = ns.FindKnownSpell(id, isPet and PET_BANK or PLAYER_BANK)
        if known then
            spellID = known
            break
        end
    end
    for _, id in ipairs(extras[class] or {}) do
        local known = ns.FindKnownSpell(id, PLAYER_BANK)
        if known and known ~= spellID then
            extraIDs[#extraIDs + 1] = known
        end
    end
    if not spellID and extraIDs[1] then
        spellID = table.remove(extraIDs, 1)
    end
    activeID = spellID
end

function InterruptReady:SetColors(state, kind, ready, notReady)
    curves[state] = curves[state] or {}
    local curve = curves[state][kind]
    if curve then
        curve:ClearPoints()
    else
        curve = C_CurveUtil.CreateColorCurve()
        curve:SetType(Enum.LuaCurveType.Step)
        curves[state][kind] = curve
    end
    curve:AddPoint(0, CreateColor(ready[1], ready[2], ready[3], ready[4]))
    curve:AddPoint(0.001, CreateColor(notReady[1], notReady[2], notReady[3], notReady[4]))
end

function InterruptReady:IsTracking()
    return spellID ~= nil
end

function InterruptReady:GetSpellID()
    if extraIDs[1] then
        self:GetCooldown()
    end
    return activeID
end

local function Duration(id)
    local duration = GetSpellCooldownDuration(id, true)
    if issecretvalue(duration) or not duration then
        return nil
    end
    return duration
end

local function Remaining(duration)
    if not remainingCurve then
        remainingCurve = C_CurveUtil.CreateCurve()
        remainingCurve:AddPoint(0, 0)
        remainingCurve:AddPoint(3600, 3600)
    end
    local remaining = duration:EvaluateRemainingDuration(remainingCurve)
    if issecretvalue(remaining) or type(remaining) ~= "number" then
        return nil
    end
    return remaining
end

function InterruptReady:GetCooldown()
    if not spellID then return nil end
    local now = GetTime()
    if cooldownAt == now then
        return cooldown
    end
    cooldownAt = now
    local best, bestID = Duration(spellID), spellID
    if best and extraIDs[1] then
        local bestRemaining = Remaining(best)
        for i = 1, #extraIDs do
            local id = extraIDs[i]
            local duration = Duration(id)
            local remaining = duration and Remaining(duration)
            if remaining and bestRemaining and remaining <= bestRemaining then
                best, bestID, bestRemaining = duration, id, remaining
            end
        end
    end
    activeID = bestID
    cooldown = best
    return best
end

function InterruptReady:GetColor(state, kind)
    local byKind = curves[state]
    local curve = byKind and byKind[kind]
    if not curve then return nil end
    local now = GetTime()
    if colorAt[curve] == now then
        return colors[curve] or nil
    end
    colorAt[curve] = now
    local duration = self:GetCooldown()
    local color = duration and duration:EvaluateRemainingDuration(curve)
    if issecretvalue(color) or not color then
        color = false
    end
    colors[curve] = color
    return color or nil
end

InterruptReady:RegisterEvent("PLAYER_LOGIN")
InterruptReady:RegisterEvent("SPELLS_CHANGED")
InterruptReady:RegisterUnitEvent("UNIT_PET", "player")
InterruptReady:SetScript("OnEvent", InterruptReady.Refresh)
