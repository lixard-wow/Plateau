local _, ns = ...

local SCHEMA_VERSION = 22
local DEFAULT_PROFILE = "Default"
local NAME_LIMIT = 32

local DB = {}
ns.DB = DB

local function IsGroup(value)
    return type(value) == "table" and value[1] == nil
end

local function RepairArrays(saved, defaults)
    for key, default in pairs(defaults) do
        if IsGroup(default) then
            if type(saved[key]) == "table" then
                RepairArrays(saved[key], default)
            end
        elseif type(default) == "table" and type(saved[key]) == "table" then
            local value = saved[key]
            for i = 1, #default do
                if value[i] == nil then
                    value[i] = default[i]
                end
            end
        end
    end
end

local NAME_SCALES = { 0.8, 1, 1.25, 1.4, 1.6 }

local function NameScaleLevel(size, base)
    local ratio = size / base
    local best, bestGap = 2, math.huge
    for level, scale in ipairs(NAME_SCALES) do
        local gap = math.abs(scale - ratio)
        if gap < bestGap then
            best, bestGap = level, gap
        end
    end
    return best
end

local function MigrateLayering(look)
    local scaling = type(look) == "table" and look.scaling
    if type(scaling) ~= "table" then return end
    if scaling.layerByType == true then
        scaling.castFront = true
    end
    scaling.layerByType, scaling.layerOrder = nil, nil
end

local function RenameProfile(db, OLD, NEW)
    if db.profiles and db.profiles[OLD] and not db.profiles[NEW] then
        db.profiles[NEW] = db.profiles[OLD]
        db.profiles[OLD] = nil
        if db.global and db.global.builtins and db.global.builtins[OLD] then
            db.global.builtins[OLD] = nil
            db.global.builtins[NEW] = true
        end
        for character, name in pairs(db.profileKeys or {}) do
            if name == OLD then
                db.profileKeys[character] = NEW
            end
        end
        for _, byCharacter in pairs(db.assignments or {}) do
            for _, byKey in pairs(byCharacter) do
                for key, name in pairs(byKey) do
                    if name == OLD then
                        byKey[key] = NEW
                    end
                end
            end
        end
    end
end

local migrations = {
    [22] = function(db)
        for name, profile in pairs(db.profiles or {}) do
            if type(profile) == "table" and not (ns.Builtins and ns.Builtins.ByName(name)) then
                profile.look = type(profile.look) == "table" and profile.look or {}
                local castbar = type(profile.look.castbar) == "table" and profile.look.castbar or {}
                profile.look.castbar = castbar
                if castbar.uninterruptible == nil then
                    castbar.uninterruptible = { 0.6039, 0.6275, 0.7059, 0.6 }
                end
            end
        end
    end,
    [21] = function(db)
        local function Clear(look)
            local castbar = type(look) == "table" and look.castbar
            if type(castbar) == "table" then
                castbar.interruptible, castbar.channelColor = nil, nil
            end
        end
        for _, profile in pairs(db.profiles or {}) do
            if type(profile) == "table" then
                Clear(profile.look)
                for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                    Clear(override)
                end
            end
        end
    end,
    [19] = function(db)
        for name, profile in pairs(db.profiles or {}) do
            if type(profile) == "table" and not (ns.Builtins and ns.Builtins.ByName(name)) then
                profile.look = type(profile.look) == "table" and profile.look or {}
                for _, key in ipairs({ "classPower", "enemyPower" }) do
                    local element = type(profile.look[key]) == "table" and profile.look[key] or {}
                    profile.look[key] = element
                    if element.enabled == nil then
                        element.enabled = true
                    end
                end
            end
        end
    end,
    [17] = function(db)
        if type(db.global) == "table" then
            db.global.probe, db.global.probeWatch = nil, nil
        end
    end,
    [16] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            if type(profile) == "table" then
                MigrateLayering(profile.look)
                for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                    MigrateLayering(override)
                end
            end
        end
    end,
    [15] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local look = type(profile) == "table" and profile.look
            local friendly = type(look) == "table" and look.friendly
            if type(friendly) == "table" then
                local base = type(look.name) == "table" and tonumber(look.name.size) or 10
                for old, new in pairs({ playerNameSize = "playerNameScale", npcNameSize = "npcNameScale" }) do
                    local size = tonumber(friendly[old])
                    if size and size > 0 and base > 0 then
                        local level = NameScaleLevel(size, base)
                        friendly[new] = level ~= 2 and level or nil
                    end
                    friendly[old] = nil
                end
            end
        end
    end,
    [14] = function(db)
        RenameProfile(db, "Name inside", "Compact")
    end,
    [13] = function(db)
        local patterns = {}
        for _, pattern in ipairs(ns.overlayPatterns or {}) do
            patterns[pattern.value:lower()] = pattern.value
        end
        local function Pattern(value)
            return type(value) == "string" and patterns[value:lower()]
        end
        for _, profile in pairs(db.profiles or {}) do
            local look = type(profile.look) == "table" and profile.look
            if look then
                for _, key in ipairs({ "health", "target", "focus" }) do
                    local group = type(look[key]) == "table" and look[key]
                    local pattern = group and Pattern(group.texture)
                    if pattern then
                        group.texture = nil
                        if group.overlayPattern == nil or group.overlayPattern == "" then
                            group.overlayPattern = pattern
                            if group.overlayAlpha == nil then
                                group.overlayAlpha = 1
                            end
                        end
                    end
                end
                local castbar = type(look.castbar) == "table" and look.castbar
                if castbar and Pattern(castbar.texture) then
                    castbar.texture = nil
                end
            end
        end
    end,
    [12] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local castbar = type(profile.look) == "table" and profile.look.castbar
            if type(castbar) == "table" then
                castbar.enabled = nil
            end
        end
    end,
    [11] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local override = type(profile.states) == "table" and profile.states.friendly
            if type(override) == "table" then
                profile.look = profile.look or {}
                profile.look.friendly = profile.look.friendly or {}
                local friendly = profile.look.friendly
                local name = type(override.name) == "table" and override.name
                if name then
                    if name.mode ~= nil and friendly.nameMode == nil then
                        friendly.nameMode = name.mode
                    end
                    if name.npcMode ~= nil and friendly.npcNameMode == nil then
                        friendly.npcNameMode = name.npcMode
                    end
                    if name.classColors ~= nil and friendly.classColors == nil then
                        friendly.classColors = name.classColors
                    end
                end
                local classification = type(override.classification) == "table" and override.classification
                if classification and classification.enabled ~= nil and friendly.classificationEnabled == nil then
                    friendly.classificationEnabled = classification.enabled
                end
                local level = type(override.level) == "table" and override.level
                if level and level.enabled ~= nil and friendly.levelEnabled == nil then
                    friendly.levelEnabled = level.enabled
                end
            end
            profile.states = nil
        end
    end,
    [10] = function(db)
        local function CopyMelee(colors, scaling)
            if type(colors) == "table" then
                if colors.meleeColor ~= nil and colors.trivialColor == nil then
                    colors.trivialColor = colors.meleeColor
                end
                if colors.melee == false then
                    colors.trivial = false
                end
                colors.melee, colors.meleeColor = nil, nil
            end
            if type(scaling) == "table" then
                if scaling.melee ~= nil and scaling.trivial == nil then
                    scaling.trivial = scaling.melee
                end
                scaling.melee = nil
            end
        end
        for _, profile in pairs(db.profiles or {}) do
            local look = profile.look
            CopyMelee(look and look.colors, look and look.scaling)
            for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                if type(override) == "table" then
                    CopyMelee(override.colors, override.scaling)
                end
            end
        end
        db.baselines = nil
    end,
    [9] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            if type(profile.look) == "table" then
                RepairArrays(profile.look, ns.defaults.look)
            end
        end
    end,
    [8] = function(db)
        local function CopyMode(name)
            if type(name) ~= "table" then return end
            if name.npcMode == nil and name.mode ~= nil then
                name.npcMode = name.mode
            end
        end
        for _, profile in pairs(db.profiles or {}) do
            CopyMode(profile.look and profile.look.name)
            for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                CopyMode(type(override) == "table" and override.name)
            end
        end
    end,
    [2] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local highlight = profile.look and profile.look.highlight
            if highlight then
                highlight.targetRingColor = highlight.targetRingColor or highlight.color
                highlight.targetRingSize = highlight.targetRingSize or highlight.size
                highlight.color, highlight.size = nil, nil
            end
        end
    end,
    [3] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local health = profile.look and profile.look.health
            if health and health.tapped then
                profile.look.colors = profile.look.colors or {}
                profile.look.colors.tapped = profile.look.colors.tapped or health.tapped
                health.tapped = nil
            end
        end
    end,
    [4] = function(db)
        local targetKeys = {
            targetRing = "ring", targetRingColor = "ringColor", targetRingSize = "ringSize",
            targetColorBar = "colorBar", targetBarColor = "barColor", targetBrighten = "brighten",
            targetScale = "scale", dimOthers = "dimOthers",
        }
        local focusKeys = {
            focusRing = "ring", focusRingColor = "ringColor", focusRingSize = "ringSize",
            focusColorBar = "colorBar", focusBarColor = "barColor",
        }
        for _, profile in pairs(db.profiles or {}) do
            local highlight = profile.look and profile.look.highlight
            if highlight then
                local target, focus = {}, {}
                for old, new in pairs(targetKeys) do
                    target[new] = highlight[old]
                end
                for old, new in pairs(focusKeys) do
                    focus[new] = highlight[old]
                end
                profile.look.target = next(target) and target or nil
                profile.look.focus = next(focus) and focus or nil
                profile.look.highlight = nil
            end
        end
    end,
    [5] = function(db)
        for _, profile in pairs(db.profiles or {}) do
            local look = profile.look
            for _, state in ipairs({ "target", "focus" }) do
                local group = look and look[state]
                if type(group) == "table" then
                    if group.useTexture == true and type(group.texture) == "string" then
                        profile.states = profile.states or {}
                        profile.states[state] = profile.states[state] or {}
                        profile.states[state].health = profile.states[state].health or {}
                        profile.states[state].health.texture = group.texture
                    end
                    group.useTexture, group.texture = nil, nil
                end
            end
        end
    end,
    [7] = function(db)
        local function Center(name)
            if type(name) ~= "table" or name.position == "CENTER" then return end
            if name.overflow == "end" and (name.width or 0) == 0 then
                name.overflow = nil
            end
            if name.justify == "LEFT" or name.justify == "RIGHT" then
                name.justify = nil
            end
        end
        for _, profile in pairs(db.profiles or {}) do
            Center(profile.look and profile.look.name)
            for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                Center(type(override) == "table" and override.name)
            end
        end
    end,
    [6] = function(db)
        local function Drop(colors)
            if type(colors) ~= "table" then return end
            if colors.customReaction ~= true then
                colors.hostile, colors.neutral, colors.friendly = nil, nil, nil
            end
        end
        for _, profile in pairs(db.profiles or {}) do
            local base = profile.look and profile.look.colors
            local baseCustom = type(base) == "table" and base.customReaction == true
            Drop(base)
            for _, override in pairs(type(profile.states) == "table" and profile.states or {}) do
                local colors = type(override) == "table" and override.colors
                if type(colors) == "table" then
                    local custom = colors.customReaction
                    if custom == nil then
                        custom = baseCustom
                    end
                    if custom ~= true then
                        colors.hostile, colors.neutral, colors.friendly = nil, nil, nil
                    end
                end
            end
        end
    end,
}

ns.STATES = { "enemy", "friendly" }

local function ArraysEqual(a, b)
    for i = 1, math.max(#a, #b) do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end

local function Bind(saved, defaults)
    for key, value in pairs(defaults) do
        if IsGroup(value) then
            if type(saved[key]) ~= "table" then
                saved[key] = {}
            end
            Bind(saved[key], value)
        end
    end
    return setmetatable(saved, { __index = defaults })
end

local function Strip(saved, defaults)
    setmetatable(saved, nil)
    for key, value in pairs(saved) do
        local default = defaults[key]
        if default == nil then
            saved[key] = nil
        elseif IsGroup(default) then
            if type(value) == "table" then
                Strip(value, default)
                if next(value) == nil then
                    saved[key] = nil
                end
            else
                saved[key] = nil
            end
        elseif type(value) == "table" and type(default) == "table" then
            if ArraysEqual(value, default) then
                saved[key] = nil
            end
        elseif value == default then
            saved[key] = nil
        end
    end
end

local SPELL_GROUPS = { mine = true, cc = true, purge = true, important = true }
local SPELL_KINDS = { hide = true, only = true, watch = true }

local function CleanSpecSpells(source)
    if type(source) ~= "table" then return nil end
    local clean
    for spec, groups in pairs(source) do
        local id = tonumber(spec)
        if id and type(groups) == "table" then
            for group, kinds in pairs(groups) do
                if SPELL_GROUPS[group] and type(kinds) == "table" then
                    for kind, text in pairs(kinds) do
                        if SPELL_KINDS[kind] and type(text) == "string" and text:find("%S") then
                            clean = clean or {}
                            clean[id] = clean[id] or {}
                            clean[id][group] = clean[id][group] or {}
                            clean[id][group][kind] = text
                        end
                    end
                end
            end
        end
    end
    return clean
end
DB.CleanSpecSpells = CleanSpecSpells

function ns.CurrentSpec()
    local info = C_SpecializationInfo
    local index = info and info.GetSpecialization and info.GetSpecialization()
    if not index or index == 0 then
        return 0, nil
    end
    local id, name = info.GetSpecializationInfo(index)
    return id or 0, name
end

local function Changed()
    if ns.Driver.RequestRestyle then
        ns.Driver:RequestRestyle()
    else
        ns.Driver:Restyle()
    end
end

local function Clear(tbl, skip)
    for key, value in pairs(tbl) do
        if key ~= skip then
            if type(value) == "table" and getmetatable(value) then
                Clear(value)
            else
                tbl[key] = nil
            end
        end
    end
end

local TOP_TABLES = { "global", "profiles", "profileKeys", "assignments" }

local function Repair(db)
    for _, key in ipairs(TOP_TABLES) do
        if db[key] ~= nil and type(db[key]) ~= "table" then
            db[key] = nil
        end
    end
    if db.version ~= nil and type(db.version) ~= "number" then
        db.version = nil
    end
    for name, profile in pairs(db.profiles or {}) do
        if type(name) ~= "string" or type(profile) ~= "table" then
            db.profiles[name] = nil
        else
            if profile.look ~= nil and type(profile.look) ~= "table" then
                profile.look = nil
            end
            if profile.states ~= nil and type(profile.states) ~= "table" then
                profile.states = nil
            end
        end
    end
    for key, name in pairs(db.profileKeys or {}) do
        if type(key) ~= "string" or type(name) ~= "string" then
            db.profileKeys[key] = nil
        end
    end
end

local function Migrate(db)
    local version = db.version or SCHEMA_VERSION
    local failures = {}
    while version < SCHEMA_VERSION do
        version = version + 1
        local step = migrations[version]
        if step then
            local ok, problem = pcall(step, db)
            if not ok then
                failures[#failures + 1] = ("v%d: %s"):format(version, tostring(problem))
            end
        end
    end
    db.version = SCHEMA_VERSION
    return failures
end

local function IsUnknownName(name)
    return not name or name == "" or name == "Unknown" or name == UNKNOWNOBJECT or name == UKNOWNBEING
end

local function CharacterKey()
    local name = UnitName("player")
    if IsUnknownName(name) then
        return nil
    end
    return name .. " - " .. GetRealmName()
end

local function DropUnknownKeys(map)
    if type(map) ~= "table" then return end
    for key in pairs(map) do
        if type(key) == "string" and IsUnknownName(key:match("^(.-) %- ")) then
            map[key] = nil
        end
    end
end

function DB:Init()
    if type(PlateauDB) ~= "table" then
        PlateauDB = {}
    end
    local db = PlateauDB
    Repair(db)
    self.migrationFailures = Migrate(db)
    local Sanitize = ns.Share and ns.Share.Sanitize
    if Sanitize then
        for _, profile in pairs(db.profiles or {}) do
            if type(profile.look) == "table" then
                profile.look = Sanitize(profile.look, ns.defaults.look, "look")
            end
            if type(profile.states) == "table" then
                for state, override in pairs(profile.states) do
                    profile.states[state] = type(override) == "table" and Sanitize(override, ns.defaults.look, "look") or nil
                end
            end
        end
    end
    db.global = db.global or {}
    db.profiles = db.profiles or {}
    db.profileKeys = db.profileKeys or {}
    DropUnknownKeys(db.profileKeys)
    DropUnknownKeys(db.assignments)

    self.saved = db
    self.charKey = CharacterKey()
    local fresh = next(db.profiles) == nil
    self:SeedBuiltins()
    self.fallbackName = (fresh and ns.Builtins) and ns.Builtins.defaultName or DEFAULT_PROFILE
    self:UseProfile(self:ChosenProfile() or self.fallbackName, self.charKey == nil)
end

function DB:ChosenProfile()
    local db = self.saved
    local chosen = self.charKey and db.profileKeys[self.charKey]
    if chosen and not db.profiles[chosen] then
        chosen = self:FallbackProfile() or self.fallbackName
    end
    return chosen
end

function DB:ResolveCharacter()
    if self.charKey or not self.saved then return end
    local key = CharacterKey()
    if not key then return end
    self.charKey = key
    local chosen = self:ChosenProfile()
    if chosen and chosen ~= self.profileName then
        self:SwitchProfile(chosen)
    else
        self.saved.profileKeys[key] = self.profileName
    end
end

function DB:DefaultProfile()
    return self.saved.profileKeys[self.charKey] or self.profileName
end

function DB:FallbackProfile(exclude)
    local profiles = self.saved.profiles
    local preferred = { ns.Builtins and ns.Builtins.defaultName, DEFAULT_PROFILE }
    for _, name in ipairs(preferred) do
        if name ~= exclude and profiles[name] then
            return name
        end
    end
    for _, name in ipairs(self:ListProfiles()) do
        if name ~= exclude then
            return name
        end
    end
end

local FRIENDLY_MARKER_KEYS = { position = true, gap = true, offsetX = true, offsetY = true }

local function FriendlyView(look)
    local marker = setmetatable({}, {
        __index = function(_, key)
            local own = look.friendly.raidMarker
            if own.own and FRIENDLY_MARKER_KEYS[key] then
                return own[key]
            end
            return look.raidMarker[key]
        end,
    })
    return setmetatable({ raidMarker = marker }, { __index = look })
end

function DB:UseProfile(name, temporary)
    local db = self.saved
    db.profiles[name] = db.profiles[name] or {}
    if not temporary and self.charKey then
        db.profileKeys[self.charKey] = name
    end
    self.profileName = name
    local profile = Bind(db.profiles[name], ns.defaults)
    self.profile = profile
    self.views = { enemy = profile.look, friendly = FriendlyView(profile.look) }
end

local function Empty(value)
    return type(value) ~= "table" or next(value) == nil
end

function DB:Shutdown()
    for key, byCharacter in pairs(self.saved.assignments or {}) do
        if type(byCharacter) ~= "table" or (Empty(byCharacter.content) and Empty(byCharacter.spec)) then
            self.saved.assignments[key] = nil
        end
    end
    for _, profile in pairs(self.saved.profiles) do
        local specSpells = CleanSpecSpells(rawget(profile, "specSpells"))
        profile.states = nil
        profile.specSpells = nil
        Strip(profile, ns.defaults)
        profile.specSpells = specSpells
    end
end

local function DeepCopy(source)
    local copy = {}
    for key, value in pairs(source) do
        copy[key] = type(value) == "table" and DeepCopy(value) or value
    end
    return copy
end

function DB:Snapshot()
    return { profile = self.profileName, data = DeepCopy(self.saved.profiles[self.profileName]) }
end

function DB:Restore(snapshot)
    if not snapshot or snapshot.profile ~= self.profileName then
        return false
    end
    self.saved.profiles[snapshot.profile] = DeepCopy(snapshot.data)
    self:UseProfile(snapshot.profile, true)
    Changed()
    return true
end

function DB:ListProfiles()
    local names = {}
    for name in pairs(self.saved.profiles) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

function DB:SwitchProfile(name, temporary)
    if not self.saved.profiles[name] then
        return false, "no profile called " .. tostring(name)
    end
    self:UseProfile(name, temporary)
    ns.Driver:RequestRestyle()
    return true
end

function DB:CreateProfile(name, copyFrom)
    if type(name) ~= "string" or not name:find("%S") then
        return false, "give the profile a name"
    end
    name = name:match("^%s*(.-)%s*$")
    if self.saved.profiles[name] then
        return false, "a profile called " .. name .. " already exists"
    end
    local source = copyFrom and self.saved.profiles[copyFrom]
    self.saved.profiles[name] = source and DeepCopy(source) or {}
    return self:SwitchProfile(name)
end

function DB:CopyProfile(from)
    local source = self.saved.profiles[from]
    if not source or from == self.profileName then
        return false, "pick a different profile to copy from"
    end
    local temporary = self.profileName ~= self:DefaultProfile()
    self.saved.profiles[self.profileName] = DeepCopy(source)
    return self:SwitchProfile(self.profileName, temporary)
end

function DB:SetDefaultProfile(name)
    if not self.saved.profiles[name] then
        return false, "no profile called " .. tostring(name)
    end
    if not self.charKey then
        return self:SwitchProfile(name, true)
    end
    self.saved.profileKeys[self.charKey] = name
    if ns.AutoProfile and ns.AutoProfile.Apply then
        ns.AutoProfile:Apply(true)
        return true
    end
    return self:SwitchProfile(name, true)
end

function DB:ActivateProfile(name)
    if not self.saved.profiles[name] then
        return false, "no profile called " .. tostring(name)
    end
    if self.charKey and InCombatLockdown and InCombatLockdown() and ns.AutoProfile and ns.AutoProfile.Apply then
        self.saved.profileKeys[self.charKey] = name
        ns.AutoProfile:Apply(true)
        return true, "deferred"
    end
    return self:SwitchProfile(name)
end

function DB:RenameProfile(old, new)
    local profiles = self.saved.profiles
    if not profiles[old] then
        return false, "no profile called " .. tostring(old)
    end
    if type(new) ~= "string" or not new:find("%S") then
        return false, "give the profile a name"
    end
    new = new:match("^%s*(.-)%s*$")
    if new == old then
        return false, "that is already its name"
    end
    if profiles[new] then
        return false, "a profile called " .. new .. " already exists"
    end
    profiles[new] = profiles[old]
    profiles[old] = nil
    for character, profile in pairs(self.saved.profileKeys) do
        if profile == old then
            self.saved.profileKeys[character] = new
        end
    end
    for _, assignments in pairs(self.saved.assignments or {}) do
        for _, byKey in pairs(assignments) do
            for key, profile in pairs(byKey) do
                if profile == old then
                    byKey[key] = new
                end
            end
        end
    end
    if self.profileName == old then
        self.profileName = new
    end
    return true, new
end

function DB:ProfileReferences(name)
    local refs = { defaultFor = {}, assignments = {} }
    for character, profile in pairs(self.saved.profileKeys) do
        if profile == name then
            refs.defaultFor[#refs.defaultFor + 1] = character
        end
    end
    table.sort(refs.defaultFor)
    for character, assignments in pairs(self.saved.assignments or {}) do
        for kind, byKey in pairs(assignments) do
            for key, profile in pairs(byKey) do
                if profile == name then
                    refs.assignments[#refs.assignments + 1] = { character = character, kind = kind, key = key }
                end
            end
        end
    end
    table.sort(refs.assignments, function(a, b)
        if a.character ~= b.character then return a.character < b.character end
        if a.kind ~= b.kind then return a.kind < b.kind end
        return tostring(a.key) < tostring(b.key)
    end)
    return refs
end

function DB:GetSpecSpells(group, kind, spec)
    spec = spec or ns.CurrentSpec()
    local all = rawget(self.profile, "specSpells")
    local byGroup = all and all[spec] and all[spec][group]
    return byGroup and byGroup[kind] or ""
end

function DB:SetSpecSpells(group, kind, text, spec)
    if not SPELL_GROUPS[group] or not SPELL_KINDS[kind] then
        return false, "unknown list"
    end
    spec = spec or ns.CurrentSpec()
    local all = rawget(self.profile, "specSpells")
    if type(all) ~= "table" then
        all = {}
        rawset(self.profile, "specSpells", all)
    end
    all[spec] = all[spec] or {}
    all[spec][group] = all[spec][group] or {}
    all[spec][group][kind] = type(text) == "string" and text or ""
    Changed()
    return true
end

local function FullLook(defaults, saved)
    local full = {}
    for key, default in pairs(defaults) do
        local value = type(saved) == "table" and rawget(saved, key) or nil
        if type(default) == "table" and default[1] == nil then
            full[key] = FullLook(default, value)
        elseif type(value) == "table" then
            full[key] = DeepCopy(value)
        elseif value ~= nil then
            full[key] = value
        else
            full[key] = type(default) == "table" and DeepCopy(default) or default
        end
    end
    return full
end

local BOSS_TARGETS = { boss = true, all = true }

local function CleanBossPhases(data)
    if type(data) ~= "table" then return nil end
    local clean = { lines = {}, on = {}, names = {} }
    local count = 0
    local function ValidID(id)
        return type(id) == "number" and id == math.floor(id) and id > 0 and id < 1e7
    end
    if type(data.lines) == "table" then
        for id, text in pairs(data.lines) do
            if ValidID(id) and type(text) == "string" and #text <= 40 and not text:find("[^%d%s%.,]") and count < 500 then
                clean.lines[id] = text
                count = count + 1
            end
        end
    end
    if type(data.on) == "table" then
        for id, on in pairs(data.on) do
            if ValidID(id) and BOSS_TARGETS[on] then
                clean.on[id] = on
            end
        end
    end
    if type(data.names) == "table" then
        for id, name in pairs(data.names) do
            if ValidID(id) and type(name) == "string" and #name <= 60 and (clean.lines[id] or clean.on[id]) then
                clean.names[id] = name
            end
        end
    end
    if next(clean.lines) == nil and next(clean.on) == nil then
        return nil
    end
    return clean
end
DB.CleanBossPhases = CleanBossPhases

local function Copy(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

function DB:ExportProfile()
    local profile = self.saved.profiles[self.profileName]
    local global = self.saved.global
    local full = { look = FullLook(ns.defaults.look, rawget(profile, "look")), states = rawget(profile, "states"), specSpells = rawget(profile, "specSpells") }
    if next(global.bossPhases or {}) or next(global.bossPhaseOn or {}) then
        local names = {}
        for id, name in pairs(global.bossesSeen or {}) do
            if (global.bossPhases and global.bossPhases[id]) or (global.bossPhaseOn and global.bossPhaseOn[id]) then
                names[id] = name
            end
        end
        full.bossPhases = { lines = Copy(global.bossPhases), on = Copy(global.bossPhaseOn), names = names }
    end
    return ns.Share.Export(full, SCHEMA_VERSION)
end

function DB:ImportProfile(name, text, activate)
    local payload, reason = ns.Share.Decode(text)
    if not payload then
        return false, reason
    end
    local version = tonumber(payload.version) or SCHEMA_VERSION
    if version ~= version or version < 1 or version > 1e6 then
        return false, "that profile string is damaged"
    end
    version = math.floor(version)
    if version > SCHEMA_VERSION then
        return false, "that profile is from a newer Plateau - update first"
    end
    local holder = { version = version, profiles = { import = {
        look = type(payload.look) == "table" and payload.look or {},
        states = type(payload.states) == "table" and payload.states or nil,
    } } }
    local migrated, failures = pcall(Migrate, holder)
    if not migrated or #failures > 0 then
        return false, "that profile string is damaged"
    end
    local imported = holder.profiles.import
    local profile = { look = ns.Share.Sanitize(imported.look or {}, ns.defaults.look), specSpells = CleanSpecSpells(payload.specSpells) }
    if type(name) == "string" then
        name = name:gsub("|", ""):match("^%s*(.-)%s*$"):sub(1, NAME_LIMIT)
    end
    if type(name) == "string" and name:find("%S") then
        if self.saved.profiles[name] then
            return false, "a profile called " .. name .. " already exists"
        end
    else
        name = "Imported"
        local number = 1
        while self.saved.profiles[name] do
            number = number + 1
            name = "Imported " .. number
        end
    end
    local bossPhases = CleanBossPhases(payload.bossPhases)
    if bossPhases then
        local global = self.saved.global
        global.bossPhases = global.bossPhases or {}
        global.bossPhaseOn = global.bossPhaseOn or {}
        global.bossesSeen = global.bossesSeen or {}
        for id, text in pairs(bossPhases.lines) do
            global.bossPhases[id] = text
        end
        for id, on in pairs(bossPhases.on) do
            global.bossPhaseOn[id] = on
        end
        for id, name in pairs(bossPhases.names) do
            if not global.bossesSeen[id] then
                global.bossesSeen[id] = name
            end
        end
    end
    self.saved.profiles[name] = profile
    if not activate then
        return true, name
    end
    local ok, state = self:ActivateProfile(name)
    return ok, name, state
end

function DB:DeleteProfile(name)
    if name == self.profileName then
        return false, "switch to another profile before deleting this one"
    end
    if not self.saved.profiles[name] then
        return false, "no profile called " .. tostring(name)
    end
    self.saved.profiles[name] = nil
    local replacement = self:FallbackProfile(name)
    for character, profile in pairs(self.saved.profileKeys) do
        if profile == name then
            self.saved.profileKeys[character] = character == self.charKey and self.profileName or replacement
        end
    end
    for _, assignments in pairs(self.saved.assignments or {}) do
        for _, byKey in pairs(assignments) do
            for key, profile in pairs(byKey) do
                if profile == name then
                    byKey[key] = nil
                end
            end
        end
    end
    return true
end

local segmentCache = {}
local function Segments(path)
    local segments = segmentCache[path]
    if not segments then
        segments = {}
        for part in path:gmatch("[^%.]+") do
            segments[#segments + 1] = part
        end
        segmentCache[path] = segments
    end
    return segments
end

local function Walk(path)
    local node, default = DB.profile, ns.defaults
    local parent, parentDefault, key
    local segments = Segments(path)
    for i = 1, #segments do
        local part = segments[i]
        if type(default) ~= "table" or default[part] == nil then
            return nil
        end
        parent, parentDefault, key = node, default, part
        node = node[part]
        default = default[part]
    end
    return parent, parentDefault, key
end

function DB:Get(path)
    local parent, _, key = Walk(path)
    if parent then
        local value = parent[key]
        if type(value) == "table" then
            return DeepCopy(value), true
        end
        return value, true
    end
    return nil, false
end

local function Assign(path, value)
    local parent, parentDefault, key = Walk(path)
    if not parent then
        return false, "unknown setting"
    end
    local default = parentDefault[key]
    if type(default) == "table" then
        if default[1] == nil then
            return false, "that is a group, pick a setting inside it"
        end
        if type(value) ~= "table" or #value < 3 or #value > #default then
            return false, ("needs %d numbers"):format(#default)
        end
        value = { value[1], value[2], value[3], value[4] or default[4] }
    elseif type(value) ~= type(default) then
        return false, "needs a " .. type(default)
    end
    parent[key] = value
    return true
end

function DB:Set(path, value)
    local ok, reason = Assign(path, value)
    if ok then
        Changed()
    end
    return ok, reason
end

function DB:SetMany(values)
    local failed = {}
    for path, value in pairs(values) do
        if not Assign(path, value) then
            failed[#failed + 1] = path
        end
    end
    Changed()
    return #failed == 0, failed
end

local function ClearOverride(path)
    local parent, _, key = Walk(path)
    if parent then
        parent[key] = nil
    end
end

function DB:ResetEverywhere(paths)
    for _, path in ipairs(paths) do
        ClearOverride(path)
    end
    Changed()
end

function DB:BuildProfile(name, values)
    local previous = self.profileName
    self.saved.profiles[name] = {}
    self:UseProfile(name, true)
    for path, value in pairs(values) do
        Assign(path, value)
    end
    if previous and previous ~= name then
        self:UseProfile(previous, true)
    end
end

function DB:SeedBuiltins()
    local Builtins = ns.Builtins
    if not Builtins then return end
    local seeded = self.saved.global.builtins or {}
    self.saved.global.builtins = seeded
    for _, entry in ipairs(Builtins.list) do
        if not seeded[entry.name] then
            seeded[entry.name] = true
            if not self.saved.profiles[entry.name] then
                self:BuildProfile(entry.name, Builtins.Values(entry))
            end
        end
    end
end

function DB:UseBuiltin(name)
    local entry = ns.Builtins and ns.Builtins.ByName(name)
    if not entry then
        return false, "not a built-in profile"
    end
    if not self.saved.profiles[name] then
        self:BuildProfile(name, ns.Builtins.Values(entry))
    end
    return self:SwitchProfile(name)
end

function DB:RestoreBuiltin(name)
    local entry = ns.Builtins and ns.Builtins.ByName(name)
    if not entry then
        return false, "not a built-in profile"
    end
    self:BuildProfile(name, ns.Builtins.Values(entry))
    if self.profileName == name then
        self:UseProfile(name, true)
    end
    Changed()
    return true
end

function DB:Reset(path)
    if not path then
        Clear(self.profile, "states")
        Changed()
        return true
    end
    local parent, parentDefault, key = Walk(path)
    if not parent then
        return false, "unknown setting"
    end
    if IsGroup(parentDefault[key]) then
        Clear(parent[key])
    else
        parent[key] = nil
    end
    Changed()
    return true
end
