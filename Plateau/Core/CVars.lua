local _, ns = ...

local GetCVar = C_CVar.GetCVar
local SetCVar = C_CVar.SetCVar
local InCombatLockdown = InCombatLockdown

local CVars = CreateFrame("Frame")
ns.CVars = CVars

local pending = false

local function ValuesEqual(a, b)
    if a == b then return true end
    local na, nb = tonumber(a), tonumber(b)
    return na ~= nil and nb ~= nil and na == nb
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

local function SetLive(store, name, value)
    local override = store.override[name]
    if override then
        override.user = value
        return
    end
    if not ValuesEqual(GetCVar(name), value) then
        SetCVar(name, value)
    end
end

function CVars:Apply()
    if InCombatLockdown() then
        pending = true
        return
    end
    pending = false
    local store = Store()
    for name, override in pairs(store.override) do
        if not ValuesEqual(GetCVar(name), override.value) then
            SetCVar(name, override.value)
        end
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
    value = tostring(value)
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
    if store.override[name] then
        store.override[name].user = value
    elseif InCombatLockdown() then
        store.restore[name] = store.managed[name] == nil and value or nil
        pending = true
    else
        SetCVar(name, value)
    end
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
        if store.override[name] then
            store.override[name].user = original
        elseif InCombatLockdown() then
            store.restore[name] = original
            pending = true
        else
            SetCVar(name, original)
        end
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
    if not ValuesEqual(GetCVar(name), value) then
        SetCVar(name, value)
    end
    return true
end

function CVars:ClearOverride(name)
    local store = Store()
    local override = store.override[name]
    if not override then return true end
    if InCombatLockdown() then return false end
    store.override[name] = nil
    if override.user ~= nil and not ValuesEqual(GetCVar(name), override.user) then
        SetCVar(name, override.user)
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

local function RestoreOverrides()
    local store = Store()
    for name, override in pairs(store.override) do
        if type(override) == "table" and override.user ~= nil and not ValuesEqual(GetCVar(name), override.user) then
            SetCVar(name, override.user)
        end
        store.override[name] = nil
    end
end

CVars:RegisterEvent("PLAYER_LOGIN")
CVars:RegisterEvent("PLAYER_REGEN_ENABLED")
CVars:RegisterEvent("CVAR_UPDATE")
CVars:SetScript("OnEvent", function(self, event, name)
    if event == "CVAR_UPDATE" then
        self:Adopt(name)
        return
    end
    if event == "PLAYER_LOGIN" then
        RestoreOverrides()
    end
    if event == "PLAYER_LOGIN" or pending then
        self:Apply()
    end
    if event == "PLAYER_LOGIN" then
        ready = true
    end
end)
