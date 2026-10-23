local _, ns = ...

local StockEvents = {}
ns.StockEvents = StockEvents

StockEvents.FALLBACK = {
    "VARIABLES_LOADED", "CVAR_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "PLAYER_SOFT_FRIEND_CHANGED",
    "PLAYER_SOFT_ENEMY_CHANGED", "UPDATE_MOUSEOVER_UNIT", "PLAYER_LEVEL_UP", "PLAYER_ROLES_ASSIGNED", "PLAYER_LEVEL_CHANGED",
    "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "READY_CHECK", "READY_CHECK_FINISHED", "READY_CHECK_CONFIRM",
    "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "INCOMING_RESURRECT_CHANGED", "GROUP_JOINED", "GROUP_LEFT",
    "INCOMING_SUMMON_CHANGED",
}

StockEvents.KNOWN = {
    "CVAR_UPDATE", "GROUP_JOINED", "GROUP_LEFT", "INCOMING_RESURRECT_CHANGED", "INCOMING_SUMMON_CHANGED",
    "NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED", "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "PLAYER_ENTERING_WORLD",
    "PLAYER_FLAGS_CHANGED", "PLAYER_FOCUS_CHANGED", "PLAYER_GAINS_VEHICLE_DATA", "PLAYER_LEVEL_CHANGED", "PLAYER_LEVEL_UP",
    "PLAYER_LOSES_VEHICLE_DATA", "PLAYER_ROLES_ASSIGNED", "PLAYER_SOFT_ENEMY_CHANGED", "PLAYER_SOFT_FRIEND_CHANGED",
    "PLAYER_TARGET_CHANGED", "RAID_TARGET_UPDATE", "READY_CHECK", "READY_CHECK_CONFIRM", "READY_CHECK_FINISHED",
    "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_AURA", "UNIT_CONNECTION", "UNIT_CTR_OPTIONS", "UNIT_DISPLAYPOWER",
    "UNIT_DISTANCE_CHECK_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "UNIT_FACTION", "UNIT_FLAGS",
    "UNIT_HEALTH", "UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION", "UNIT_IN_RANGE_UPDATE", "UNIT_LEVEL",
    "UNIT_MAXHEALTH", "UNIT_MAXPOWER", "UNIT_MAX_HEALTH_MODIFIERS_CHANGED", "UNIT_NAME_UPDATE", "UNIT_OTHER_PARTY_CHANGED",
    "UNIT_PET", "UNIT_PHASE", "UNIT_POWER_BAR_HIDE", "UNIT_POWER_BAR_SHOW", "UNIT_POWER_UPDATE", "UNIT_POWER_FREQUENT",
    "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE", "UPDATE_MOUSEOVER_UNIT", "VARIABLES_LOADED",
    "UNIT_CLASSIFICATION_CHANGED", "UNIT_TARGET",
    "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_EMPOWER_START", "UNIT_SPELLCAST_EMPOWER_UPDATE", "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "UNIT_SPELLCAST_SUCCEEDED",
}

local function Valid(event)
    local check = C_EventUtils and C_EventUtils.IsEventValid
    return not check or check(event)
end

function StockEvents.Snapshot(frame)
    local saved = {}
    for _, event in ipairs(StockEvents.KNOWN) do
        if Valid(event) then
            local ok, registered, unit1, unit2 = pcall(frame.IsEventRegistered, frame, event)
            if ok and registered then
                saved[#saved + 1] = { event, unit1, unit2 }
            end
        end
    end
    return saved
end

local function Register(frame, event, unit1, unit2)
    if unit1 then
        pcall(frame.RegisterUnitEvent, frame, event, unit1, unit2)
    else
        pcall(frame.RegisterEvent, frame, event)
    end
end

function StockEvents.Replay(frame, saved, fallback)
    if saved and #saved > 0 then
        for _, entry in ipairs(saved) do
            local ok, registered = pcall(frame.IsEventRegistered, frame, entry[1])
            if not (ok and registered) then
                Register(frame, entry[1], entry[2], entry[3])
            end
        end
        return
    end
    for _, event in ipairs(fallback or {}) do
        if Valid(event) then
            local ok, registered = pcall(frame.IsEventRegistered, frame, event)
            if not (ok and registered) then
                Register(frame, event)
            end
        end
    end
end
