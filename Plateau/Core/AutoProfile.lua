local _, ns = ...

local L = ns.L

local AutoProfile = CreateFrame("Frame")
ns.AutoProfile = AutoProfile

ns.CONTENT_TYPES = {
    { key = "world", label = "Open world" },
    { key = "dungeon", label = "Dungeons" },
    { key = "raid", label = "Raids" },
    { key = "delve", label = "Delves and scenarios" },
    { key = "arena", label = "Arenas" },
    { key = "battleground", label = "Battlegrounds" },
}

local INSTANCE_CONTENT = {
    none = "world",
    party = "dungeon",
    raid = "raid",
    scenario = "delve",
    arena = "arena",
    pvp = "battleground",
}

local pending = false
local pendingForce = false
local lastContent, lastSpec
local listeners = {}

function AutoProfile:OnChange(callback)
    listeners[#listeners + 1] = callback
end

local function Notify()
    for i = 1, #listeners do
        listeners[i]()
    end
end

function AutoProfile:Assignments()
    local saved = ns.DB.saved
    saved.assignments = saved.assignments or {}
    local key = ns.DB.charKey
    local byCharacter = key and saved.assignments[key] or {}
    if key then
        saved.assignments[key] = byCharacter
    end
    byCharacter.content = byCharacter.content or {}
    byCharacter.spec = byCharacter.spec or {}
    return byCharacter
end

function AutoProfile:ResolveSource(content, spec, fallback, profiles)
    local assignments = self:Assignments()
    local byContent = content and assignments.content[content]
    if byContent and profiles[byContent] then
        return byContent, "content", content
    end
    local bySpec = spec and assignments.spec[spec]
    if bySpec and profiles[bySpec] then
        return bySpec, "spec", spec
    end
    return fallback
end

function AutoProfile:Resolve(content, spec, fallback, profiles)
    return (self:ResolveSource(content, spec, fallback, profiles))
end

local CONTENT_RULES = {
    world = { label = "Open world override" },
    dungeon = { label = "Dungeon override" },
    raid = { label = "Raid override" },
    delve = { label = "Delve or scenario override" },
    arena = { label = "Arena override" },
    battleground = { label = "Battleground override" },
}

function AutoProfile:RuleName(kind, key)
    if kind == "content" then
        local rule = CONTENT_RULES[key]
        return rule and L[rule.label] or L["%s override"]:format(tostring(key))
    end
    local _, name = C_SpecializationInfo.GetSpecializationInfo(key)
    if name then
        return L["%s specialization"]:format(name)
    end
    return L["Specialization %s specialization"]:format(tostring(key))
end

function AutoProfile:Status()
    local db = ns.DB
    local default = db:DefaultProfile()
    local target, kind, key = self:ResolveSource(self:CurrentContent(), self:CurrentSpec(), default, db.saved.profiles)
    local status = {
        default = default,
        active = db.profileName,
        overridden = db.profileName ~= default,
        target = target,
    }
    if kind and target ~= default then
        status.rule = self:RuleName(kind, key)
    end
    if pending and target ~= db.profileName then
        status.pending = target
    end
    return status
end

function AutoProfile:CurrentContent()
    local _, instanceType = IsInInstance()
    return INSTANCE_CONTENT[instanceType or "none"] or "world"
end

function AutoProfile:CurrentSpec()
    local index = C_SpecializationInfo.GetSpecialization()
    return (index and index > 0) and index or nil
end

function AutoProfile:Apply(force)
    if InCombatLockdown() then
        pending = true
        pendingForce = pendingForce or force or false
        Notify()
        return
    end
    pending = false
    force = force or pendingForce
    pendingForce = false
    local content, spec = self:CurrentContent(), self:CurrentSpec()
    if not force and content == lastContent and spec == lastSpec then
        Notify()
        return
    end
    lastContent, lastSpec = content, spec
    local db = ns.DB
    local chosen = db:DefaultProfile()
    local target = self:Resolve(content, spec, chosen, db.saved.profiles)
    if target ~= db.profileName and db.saved.profiles[target] then
        db:SwitchProfile(target, true)
    end
    Notify()
end

function AutoProfile:Set(kind, key, profileName)
    self:Assignments()[kind][key] = profileName ~= "" and profileName or nil
    self:Apply(true)
end

function AutoProfile:Get(kind, key)
    return self:Assignments()[kind][key] or ""
end

AutoProfile:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoProfile:RegisterEvent("ZONE_CHANGED_NEW_AREA")
AutoProfile:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
AutoProfile:RegisterEvent("PLAYER_REGEN_ENABLED")
AutoProfile:SetScript("OnEvent", function(self, event)
    if event ~= "PLAYER_REGEN_ENABLED" or pending then
        self:Apply()
    end
end)
