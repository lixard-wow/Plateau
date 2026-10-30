local _, ns = ...

local GetTime = GetTime
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitClassBase = UnitClassBase
local issecretvalue = issecretvalue
local type, pairs, ipairs, next, pcall = type, pairs, ipairs, next, pcall

local OWN_WINDOW = 1
local REFRESH_WINDOW = 2
local PAIR_WINDOW = 0.4
local READY_SLACK = 1.5
local DEFAULT_CD = 15

local PARTY = { "party1", "party2", "party3", "party4" }
local PETS = { party1 = "partypet1", party2 = "partypet2", party3 = "partypet3", party4 = "partypet4" }

local CLASS_KICK = {
    DEATHKNIGHT = 47528, DEMONHUNTER = 183752, MAGE = 2139, MONK = 116705, ROGUE = 1766,
    SHAMAN = 57994, WARLOCK = 19647, WARRIOR = 6552, HUNTER = 147362, PALADIN = 96231,
    DRUID = 106839, EVOKER = 351338, PRIEST = 15487,
}

local SPEC_KICK = {
    [65] = false, [66] = 96231, [70] = 96231,
    [102] = 78675, [103] = 106839, [104] = 106839, [105] = false,
    [253] = 147362, [254] = 147362, [255] = 187707,
    [256] = false, [257] = false, [258] = 15487,
    [1467] = 351338, [1468] = false, [1473] = 351338,
}

local PET_KICK = { [15] = 19647, [29] = 89766 }

local KNOWN_CD = {
    [47528] = 15, [183752] = 15, [2139] = 24, [116705] = 15, [1766] = 15, [57994] = 12, [19647] = 24,
    [89766] = 30, [6552] = 15, [147362] = 24, [187707] = 15, [96231] = 15, [106839] = 15, [78675] = 60,
    [351338] = 20, [15487] = 45,
}

local Kicks = CreateFrame("Frame")
ns.Kicks = Kicks

local plates = {}
local where = {}
local members = {}
local ownAt, ownOpen = -1, false
local stopPlate, stopAt = nil, -1
local pending = {}
local lastSession
local inspecting, inspectQueued
local cdCache = {}

local function Readable(value)
    if issecretvalue(value) then return nil end
    return value
end

local function Me()
    local guid = Readable(UnitGUID("player"))
    Kicks.me = guid
    return guid
end

local function Changed(plate)
    local element = ns.Elements and ns.Elements.Kickers
    if element and plate.unit then element:PlateChanged(plate) end
end

local function CooldownChanged(guid)
    local element = ns.Elements and ns.Elements.Kickers
    if element then element:CooldownChanged(guid) end
end

local function Place(guid, plate)
    local old = where[guid]
    if old and old ~= plate and plates[old] then
        plates[old][guid] = nil
        if not next(plates[old]) then plates[old] = nil end
        Changed(old)
    end
    where[guid] = plate
    plates[plate] = plates[plate] or {}
    plates[plate][guid] = GetTime()
    Changed(plate)
end
Kicks.Place = Place

function Kicks:On(plate)
    return plates[plate]
end

function Kicks:Forget(plate)
    local list = plates[plate]
    if not list then return end
    for guid in pairs(list) do
        if where[guid] == plate then where[guid] = nil end
    end
    plates[plate] = nil
end

function Kicks:Remove(guid, plate)
    local list = plates[plate]
    if not (list and list[guid]) then return end
    if GetTime() - list[guid] < 1.5 then return end
    list[guid] = nil
    if not next(list) then plates[plate] = nil end
    if where[guid] == plate then where[guid] = nil end
    Changed(plate)
end

local function PlayerSpec()
    local id = ns.CurrentSpec()
    if id and id > 0 then return id end
end

function Kicks:Info(guid)
    if not guid then return nil end
    if guid == (self.me or Me()) then
        return ns.InterruptReady:GetSpellID(), PlayerSpec()
    end
    local member = members[guid]
    if member then return member.kick, member.spec end
end

function Kicks:Members()
    return members
end

function Kicks:Cooldown(guid)
    if not guid then return nil end
    if guid == (self.me or Me()) then
        return ns.InterruptReady:GetCooldown()
    end
    local member = members[guid]
    if member and member.kick and member.readyAt > GetTime() then
        return nil, member.start, member.cd
    end
end

local function BaseCooldown(spellID)
    local cached = cdCache[spellID]
    if cached then return cached end
    local seconds
    local getter = (C_Spell and C_Spell.GetSpellBaseCooldown) or GetSpellBaseCooldown
    if getter then
        local ok, ms = pcall(getter, spellID)
        if ok and type(ms) == "number" and not issecretvalue(ms) and ms > 0 then seconds = ms / 1000 end
    end
    seconds = seconds or KNOWN_CD[spellID] or DEFAULT_CD
    cdCache[spellID] = seconds
    return seconds
end

local function PetKick(unit)
    local pet = PETS[unit]
    if not pet or not UnitExists(pet) then return nil end
    local _, family = UnitCreatureFamily(pet)
    family = Readable(family)
    return family and PET_KICK[family]
end

local function KickFor(member)
    if member.class == "WARLOCK" then
        return PetKick(member.unit) or CLASS_KICK.WARLOCK
    end
    if member.spec and SPEC_KICK[member.spec] ~= nil then
        return SPEC_KICK[member.spec] or nil
    end
    return CLASS_KICK[member.class]
end
Kicks.KickFor = KickFor

local function SetKick(member)
    local kick = KickFor(member)
    if kick ~= member.kick then
        member.kick = kick
        member.cd = kick and BaseCooldown(kick) or 0
    end
end

local function Start(member, at)
    if not member.kick then return end
    if member.readyAt - at > member.cd - OWN_WINDOW then return end
    member.start, member.readyAt = at, at + member.cd
    CooldownChanged(member.guid)
end
Kicks.Start = Start

local InspectNext

local function Roster()
    local old = members
    members = {}
    for _, unit in ipairs(PARTY) do
        if UnitExists(unit) then
            local guid = Readable(UnitGUID(unit))
            if guid then
                local member = old[guid] or { guid = guid, readyAt = 0, start = 0, count = 0 }
                member.unit = unit
                member.class = Readable(UnitClassBase(unit))
                member.pet = Readable(UnitGUID(PETS[unit]))
                if not member.spec and GetInspectSpecialization then
                    local spec = Readable(GetInspectSpecialization(unit))
                    if spec and spec > 0 then member.spec = spec end
                end
                SetKick(member)
                members[guid] = member
            end
        end
    end
    Me()
    InspectNext()
end
Kicks.Roster = Roster

function InspectNext()
    if inspecting or inspectQueued or InCombatLockdown() then return end
    if InspectFrame and InspectFrame:IsShown() then return end
    for guid, member in pairs(members) do
        if not member.spec and CanInspect and CanInspect(member.unit) then
            inspectQueued = true
            C_Timer.After(1.5, function()
                inspectQueued = false
                if InCombatLockdown() or not UnitExists(member.unit) or Readable(UnitGUID(member.unit)) ~= guid then return end
                inspecting = guid
                NotifyInspect(member.unit)
            end)
            return
        end
    end
end

local function OnInspect(guid)
    if not guid or guid ~= inspecting then return end
    inspecting = nil
    local member = members[guid]
    if member then
        local spec = Readable(GetInspectSpecialization(member.unit))
        if spec and spec > 0 then
            member.spec = spec
            SetKick(member)
        end
    end
    if not (InspectFrame and InspectFrame:IsShown()) then ClearInspectPlayer() end
    InspectNext()
end

local function Snapshot(guid)
    if not guid then return nil end
    local ok, source = pcall(C_DamageMeter.GetCombatSessionSourceFromType, Enum.DamageMeterSessionType.Current, Enum.DamageMeterType.Interrupts, guid)
    if not ok or type(source) ~= "table" then return nil end
    local spells = source.combatSpells
    local count = type(spells) == "table" and #spells or 0
    local total = Readable(source.totalAmount)
    if type(total) ~= "number" then total = nil end
    return count, total
end

local function Measure(member)
    local count, total = Snapshot(member.guid)
    local petCount, petTotal = Snapshot(member.pet)
    if not count and not petCount then return nil end
    count = (count or 0) + (petCount or 0)
    if total or petTotal then total = (total or 0) + (petTotal or 0) end
    return count, total
end

local function TakeStop(now)
    for i = #pending, 1, -1 do
        if now - pending[i].at > PAIR_WINDOW then table.remove(pending, i) end
    end
    if #pending == 1 then return table.remove(pending, 1).plate end
end

local function Credit(member, now)
    local plate = TakeStop(now)
    if plate and plate.unit then Place(member.guid, plate) end
    Start(member, now)
end

local function Scan(sessionID)
    if sessionID ~= lastSession then
        lastSession = sessionID
        for _, member in pairs(members) do member.count, member.total = 0, nil end
    end
    local now = GetTime()
    local proven = {}
    for _, member in pairs(members) do
        local count, total = Measure(member)
        if count then
            local kicked
            if total and member.total then
                kicked = total - member.total == 1
            else
                kicked = count - (member.count or 0) == 1
            end
            if kicked then proven[#proven + 1] = member end
            member.count = count
            member.total = total or member.total
        end
    end
    if #proven == 1 then
        Credit(proven[1], now)
    else
        for _, member in ipairs(proven) do Start(member, now) end
    end
end

local scanPending, scanSession

local function OnMeter(meterType, sessionID)
    if not (Enum.DamageMeterType and meterType == Enum.DamageMeterType.Interrupts) then return end
    scanSession = sessionID
    if scanPending then return end
    scanPending = true
    C_Timer.After(0.05, function()
        scanPending = false
        Scan(scanSession)
    end)
end

local function Eliminate()
    local now = GetTime()
    if #pending ~= 1 or now - pending[1].at > PAIR_WINDOW + 0.2 then
        for i = #pending, 1, -1 do pending[i] = nil end
        return
    end
    local candidate, found = nil, 0
    for _, member in pairs(members) do
        if member.kick and member.readyAt - pending[1].at <= READY_SLACK then
            candidate, found = member, found + 1
        end
    end
    if found == 1 then
        local plate = table.remove(pending, 1).plate
        if plate.unit then Place(candidate.guid, plate) end
        Start(candidate, now)
    else
        pending[1] = nil
    end
end

local function TryPair()
    if not (ownOpen and stopPlate) then return end
    if stopAt - ownAt > OWN_WINDOW or ownAt - stopAt > OWN_WINDOW then return end
    local plate = stopPlate
    ownOpen, stopPlate = false, nil
    for i = #pending, 1, -1 do
        if pending[i].plate == plate then table.remove(pending, i) end
    end
    local me = Kicks.me or Me()
    if me and plate.unit then Place(me, plate) end
end

local function OnStop(unit, interruptedBy)
    if type(unit) ~= "string" or not unit:find("^nameplate") then return end
    local secret = issecretvalue(interruptedBy)
    if not secret and (interruptedBy == nil or interruptedBy == "") then return end
    local plate = ns.Driver:GetPlate(unit)
    if not plate then return end
    local me = Kicks.me or Me()
    local now = GetTime()
    if not secret then
        if interruptedBy == me then
            ownOpen = false
            Place(me, plate)
            return
        end
        local member = members[interruptedBy]
        if not member then
            for _, entry in pairs(members) do
                if entry.pet == interruptedBy then member = entry end
            end
        end
        if member then
            Place(member.guid, plate)
            Start(member, now)
        end
        return
    end
    if ownOpen and now - ownAt <= OWN_WINDOW then
        stopPlate, stopAt = plate, now
        TryPair()
        return
    end
    stopPlate, stopAt = plate, now
    pending[#pending + 1] = { plate = plate, at = now }
    C_Timer.After(PAIR_WINDOW + 0.1, function()
        if ownOpen and stopPlate == plate then TryPair() end
        Eliminate()
    end)
end

local function Refresh()
    CooldownChanged(Kicks.me or Me())
end

local function OnOwnCast(spellID)
    if issecretvalue(spellID) or not ns.InterruptReady:IsKick(spellID) then return end
    ownAt, ownOpen = GetTime(), true
    if stopPlate and ownAt - stopAt > OWN_WINDOW then stopPlate = nil end
    TryPair()
    C_Timer.After(0.05, Refresh)
end

Kicks:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
Kicks:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
Kicks:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
Kicks:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
Kicks:RegisterEvent("SPELL_UPDATE_COOLDOWN")
Kicks:RegisterEvent("PLAYER_ENTERING_WORLD")
Kicks:RegisterEvent("GROUP_ROSTER_UPDATE")
Kicks:RegisterEvent("UNIT_PET")
Kicks:RegisterEvent("INSPECT_READY")
Kicks:RegisterEvent("PLAYER_REGEN_ENABLED")
if C_DamageMeter and C_DamageMeter.GetCombatSessionSourceFromType then
    Kicks:RegisterEvent("DAMAGE_METER_COMBAT_SESSION_UPDATED")
end
Kicks:SetScript("OnEvent", function(_, event, unit, ...)
    if ns.disabled then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, spellID = ...
        OnOwnCast(spellID)
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        if GetTime() - ownAt <= REFRESH_WINDOW then Refresh() end
    elseif event == "DAMAGE_METER_COMBAT_SESSION_UPDATED" then
        OnMeter(unit, ...)
    elseif event == "INSPECT_READY" then
        OnInspect(unit)
    elseif event == "PLAYER_REGEN_ENABLED" then
        InspectNext()
    elseif event == "UNIT_PET" and unit ~= "player" and not PETS[unit] then
        return
    elseif event == "PLAYER_ENTERING_WORLD" or event == "GROUP_ROSTER_UPDATE" or event == "UNIT_PET" then
        Roster()
        Refresh()
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local _, _, _, interruptedBy = ...
        OnStop(unit, interruptedBy)
    else
        local _, _, interruptedBy = ...
        OnStop(unit, interruptedBy)
    end
end)
