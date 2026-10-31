local _, ns = ...

local GetCVar = C_CVar.GetCVar
local SetCVar = C_CVar.SetCVar
local InCombatLockdown = InCombatLockdown

local CVars = CreateFrame("Frame")
ns.CVars = CVars

local pending = false
local writing = false

local function Write(name, value)
    writing = true
    SetCVar(name, value)
    writing = false
end

local function ValuesEqual(a, b)
    if a == b then return true end
    local na, nb = tonumber(a), tonumber(b)
    return na ~= nil and nb ~= nil and na == nb
end

local LIMITS = {
    nameplateMotionSpeed = { max = 0.2, fallback = "0.025", instant = 1 },
}

local function Within(name, value)
    local limit, number = LIMITS[name], tonumber(value)
    if limit and number and number > limit.max and number ~= limit.instant then
        return limit.fallback
    end
    return value
end

local function Store()
    local global = ns.DB.saved.global
    global.cvars = global.cvars or {}
    local store = global.cvars
    store.managed = store.managed or {}
    store.original = store.original or {}
    store.restore = store.restore or {}
    if type(store.override) ~= "table" then
        store.override = {}
    end
    return store
end

local function UserValue(store, name)
    local override = store.override[name]
    if override then
        return override.user
    end
    return GetCVar(name)
end

local function WriteIfDifferent(name, value)
    if not ValuesEqual(GetCVar(name), value) then
        Write(name, value)
    end
end

local function Deliver(store, name, value, restoreValue)
    if store.override[name] then
        store.override[name].user = value
    elseif InCombatLockdown() then
        store.restore[name] = restoreValue
        pending = true
    else
        Write(name, value)
    end
end

local function SetLive(store, name, value)
    local override = store.override[name]
    if override then
        override.user = value
        return
    end
    WriteIfDifferent(name, value)
end

function CVars:IsPending()
    return pending
end

function CVars:Apply()
    if InCombatLockdown() then
        pending = true
        return
    end
    pending = false
    local store = Store()
    for name in pairs(LIMITS) do
        local original = store.original[name]
        if original ~= nil then
            store.original[name] = Within(name, original)
        end
        local managed = store.managed[name]
        if managed ~= nil and Within(name, managed) ~= managed then
            store.managed[name] = nil
            local fixed = Within(name, managed)
            if not ValuesEqual(fixed, store.original[name] or fixed) then
                store.managed[name] = fixed
            else
                store.original[name] = nil
                store.restore[name] = fixed
            end
        end
        if store.managed[name] == nil and store.restore[name] == nil and not store.override[name] then
            local live = GetCVar(name)
            if live ~= nil and Within(name, live) ~= live then
                store.restore[name] = Within(name, live)
            end
        end
    end
    for name, override in pairs(store.override) do
        WriteIfDifferent(name, override.value)
    end
    for name, value in pairs(store.restore) do
        SetLive(store, name, value)
        store.restore[name] = nil
    end
    for name, value in pairs(store.managed) do
        SetLive(store, name, value)
    end
end

function CVars:Get(name)
    local store = Store()
    return store.managed[name] or UserValue(store, name)
end

function CVars:UserValue(name)
    return UserValue(Store(), name)
end

function CVars:Set(name, value)
    local store = Store()
    value = Within(name, tostring(value))
    if store.original[name] == nil then
        store.original[name] = UserValue(store, name)
    end
    local reverting = ValuesEqual(value, store.original[name])
    local newManaged = not reverting and value or nil
    if store.managed[name] == newManaged then
        return
    end
    store.managed[name] = newManaged
    if reverting then
        store.original[name] = nil
    end
    Deliver(store, name, value, store.managed[name] == nil and value or nil)
end

local BITS_PER_BYTE = 6
local PADDING = 64

function CVars.WithBit(value, index, on)
    local bits = {}
    for position = 2, #value do
        local byte = value:byte(position) % PADDING
        for offset = 0, BITS_PER_BYTE - 1 do
            bits[(position - 2) * BITS_PER_BYTE + offset] = byte % 2 == 1
            byte = math.floor(byte / 2)
        end
    end
    bits[index - 1] = on and true or false
    local count = math.max(#value - 1, math.floor((index - 1) / BITS_PER_BYTE) + 1)
    local out = { value:sub(1, 1) }
    for group = 0, count - 1 do
        local byte = 0
        for offset = BITS_PER_BYTE - 1, 0, -1 do
            byte = byte * 2 + (bits[group * BITS_PER_BYTE + offset] and 1 or 0)
        end
        out[#out + 1] = string.char(byte + PADDING)
    end
    while #out > 1 and out[#out] == string.char(PADDING) do
        out[#out] = nil
    end
    return table.concat(out)
end

function CVars.HasBit(value, index)
    local bit = index - 1
    local position = math.floor(bit / BITS_PER_BYTE) + 2
    if type(value) ~= "string" or position > #value then return false end
    local byte = value:byte(position) % PADDING
    return math.floor(byte / 2 ^ (bit % BITS_PER_BYTE)) % 2 == 1
end

function CVars:IsManaged(name)
    return Store().managed[name] ~= nil
end

function CVars:Release(name)
    local store = Store()
    local original = store.original[name]
    store.managed[name] = nil
    store.original[name] = nil
    if original ~= nil then
        Deliver(store, name, original, original)
    end
end

function CVars:Override(name, value)
    if InCombatLockdown() or GetCVar(name) == nil then return false end
    local store = Store()
    value = tostring(value)
    local override = store.override[name]
    if not override then
        override = { user = GetCVar(name) }
        store.override[name] = override
    end
    override.value = value
    WriteIfDifferent(name, value)
    return true
end

function CVars:ClearOverride(name)
    local store = Store()
    local override = store.override[name]
    if not override then return true end
    if InCombatLockdown() then return false end
    store.override[name] = nil
    if override.user ~= nil then
        WriteIfDifferent(name, override.user)
    end
    return true
end

function CVars:IsOverridden(name)
    return Store().override[name] ~= nil
end

function CVars:ManagedCopy()
    local copy = {}
    for name, value in pairs(Store().managed) do
        copy[name] = value
    end
    return copy
end

function CVars:RestoreManaged(snapshot)
    local current = self:ManagedCopy()
    for name, value in pairs(snapshot) do
        if current[name] ~= value then
            self:Set(name, value)
        end
    end
    for name in pairs(current) do
        if snapshot[name] == nil then
            self:Release(name)
        end
    end
end

function CVars:ReleaseAll()
    local store = Store()
    local names = {}
    for name in pairs(store.original) do
        names[#names + 1] = name
    end
    for _, name in ipairs(names) do
        self:Release(name)
    end
end

local ready = false

function CVars:Adopt(name)
    if not ready or pending then return end
    local store = Store()
    local live = GetCVar(name)
    if live == nil then return end
    local override = store.override[name]
    if override then
        if ValuesEqual(live, override.value) then return end
        override.user = live
        if not writing and self.OnOverrideChanged then
            self:OnOverrideChanged(name, live)
        end
    end
    local managed = store.managed[name]
    if managed == nil or ValuesEqual(live, managed) then return end
    if ValuesEqual(live, store.original[name]) then
        store.managed[name] = nil
        store.original[name] = nil
    else
        store.managed[name] = live
    end
end

local function RestoreOverrides(forget)
    if InCombatLockdown() or not (ns.DB and ns.DB.saved) then return end
    local store = Store()
    for name, override in pairs(store.override) do
        if type(override) ~= "table" or override.user == nil then
            store.override[name] = nil
        else
            WriteIfDifferent(name, override.user)
            if forget and ValuesEqual(GetCVar(name), override.user) then
                store.override[name] = nil
            end
        end
    end
end

CVars:RegisterEvent("PLAYER_LOGIN")
CVars:RegisterEvent("PLAYER_LOGOUT")
CVars:RegisterEvent("PLAYER_REGEN_ENABLED")
CVars:RegisterEvent("CVAR_UPDATE")
CVars:SetScript("OnEvent", function(self, event, name)
    if ns.disabled then return end
    if event == "CVAR_UPDATE" then
        self:Adopt(name)
        return
    end
    if event == "PLAYER_LOGOUT" then
        RestoreOverrides(false)
        return
    end
    if event == "PLAYER_LOGIN" then
        RestoreOverrides(true)
    end
    if event == "PLAYER_LOGIN" or pending then
        self:Apply()
    end
    if event == "PLAYER_LOGIN" then
        ready = true
    end
end)
