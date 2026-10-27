local _, ns = ...

local GetTime = GetTime
local UnitGUID = UnitGUID
local issecretvalue = issecretvalue
local type, pairs, next = type, pairs, next

local OWN_WINDOW = 1
local REFRESH_WINDOW = 2

local Kicks = CreateFrame("Frame")
ns.Kicks = Kicks

local plates = {}
local where = {}
local ownAt, ownOpen = -1, false
local stopPlate, stopAt = nil, -1

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

function Kicks:Duration(guid)
    if guid and guid == (self.me or Me()) then
        return ns.InterruptReady:GetCooldown()
    end
end

local function TryPair()
    if not (ownOpen and stopPlate) then return end
    if stopAt - ownAt > OWN_WINDOW or ownAt - stopAt > OWN_WINDOW then return end
    local plate = stopPlate
    ownOpen, stopPlate = false, nil
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
    if not secret then
        if interruptedBy == me then
            ownOpen = false
            Place(me, plate)
        end
        return
    end
    stopPlate, stopAt = plate, GetTime()
    TryPair()
end

local function Refresh()
    local element = ns.Elements and ns.Elements.Kickers
    if element then element:CooldownChanged() end
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
Kicks:SetScript("OnEvent", function(_, event, unit, ...)
    if ns.disabled then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, spellID = ...
        OnOwnCast(spellID)
    elseif event == "SPELL_UPDATE_COOLDOWN" then
        if GetTime() - ownAt <= REFRESH_WINDOW then Refresh() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        Me()
        Refresh()
    elseif event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        local _, _, _, interruptedBy = ...
        OnStop(unit, interruptedBy)
    else
        local _, _, interruptedBy = ...
        OnStop(unit, interruptedBy)
    end
end)
