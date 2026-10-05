local _, ns = ...

local UnitIsTapDenied = UnitIsTapDenied
local UnitIsPlayer = UnitIsPlayer
local UnitClassBase = UnitClassBase
local UnitIsBossMob = UnitIsBossMob
local UnitIsLieutenant = UnitIsLieutenant
local UnitClassification = UnitClassification
local UnitPowerType = UnitPowerType
local UnitReaction = UnitReaction
local UnitAffectingCombat = UnitAffectingCombat
local UnitThreatSituation = UnitThreatSituation
local issecretvalue = issecretvalue

local MANA = Enum.PowerType.Mana

local UnitColors = CreateFrame("Frame")
ns.UnitColors = UnitColors

local cfgs = {}
local isTank = false
local inInstance = false
local inRaid = false

local function Unpack(color)
    return color[1], color[2], color[3], color[4]
end

function UnitColors:Configure(db, state)
    cfgs[state] = db
end

local ORDER = { "boss", "lieutenant", "higher", "trivial", "caster", "elite" }
local BOSS_UNITS = { "boss1", "boss2", "boss3", "boss4", "boss5" }
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists

local function IsBossUnit(unit)
    for i = 1, #BOSS_UNITS do
        local boss = BOSS_UNITS[i]
        local exists = UnitExists(boss)
        if not issecretvalue(exists) and exists then
            local ok, same = pcall(UnitIsUnit, unit, boss)
            if ok and not issecretvalue(same) and same then
                return true
            end
        end
    end
    return false
end

local UnitEffectiveLevel = UnitEffectiveLevel

local function IsBossByLevel(unit, classification)
    if classification ~= "elite" and classification ~= "rareelite" then return false end
    if not inInstance then return false end
    local level = UnitEffectiveLevel(unit)
    if issecretvalue(level) or not level then return false end
    if level <= 0 then return true end
    if inRaid then return false end
    local mine = UnitEffectiveLevel("player")
    return not issecretvalue(mine) and mine ~= nil and level >= mine + 2
end

local function IsHigherElite(unit, classification)
    if classification ~= "elite" and classification ~= "rareelite" then return false end
    local level = UnitEffectiveLevel(unit)
    if issecretvalue(level) or not level then return false end
    if level <= 0 then return true end
    local mine = UnitEffectiveLevel("player")
    return not issecretvalue(mine) and mine ~= nil and level > mine
end

local function IsTwoLevelsAbove(unit, classification)
    if classification ~= "elite" and classification ~= "rareelite" then return false end
    local level = UnitEffectiveLevel(unit)
    if issecretvalue(level) or not level or level <= 0 then return false end
    local mine = UnitEffectiveLevel("player")
    return not issecretvalue(mine) and mine ~= nil and level >= mine + 2
end

local function IsAbovePlayerLevel(unit)
    local level = UnitEffectiveLevel(unit)
    if issecretvalue(level) or not level then return false end
    if level <= 0 then return true end
    local mine = UnitEffectiveLevel("player")
    return not issecretvalue(mine) and mine ~= nil and level > mine
end

function UnitColors:MobType(unit, flags)
    local classification = UnitClassification(unit)
    local powerType = UnitPowerType(unit)
    flags.boss = UnitIsBossMob(unit) == true or classification == "worldboss" or IsBossByLevel(unit, classification) or IsBossUnit(unit)
    flags.lieutenant = (UnitIsLieutenant and UnitIsLieutenant(unit) == true and IsAbovePlayerLevel(unit)) or IsTwoLevelsAbove(unit, classification)
    flags.higher = IsHigherElite(unit, classification)
    flags.trivial = classification == "minus" or classification == "trivial"
    flags.caster = not issecretvalue(powerType) and powerType == MANA
    flags.elite = classification == "elite" or classification == "rareelite"
    for i = 1, #ORDER do
        if flags[ORDER[i]] then
            return ORDER[i]
        end
    end
    flags.trivial = true
    return "trivial"
end

function UnitColors:ClearMobType(flags)
    for i = 1, #ORDER do
        flags[ORDER[i]] = false
    end
end

local targetTokens = setmetatable({}, { __index = function(tokens, unit)
    local token = unit .. "target"
    tokens[unit] = token
    return token
end })

local function HeldByOtherTank(unit)
    local target = targetTokens[unit]
    local role = UnitGroupRolesAssigned(target)
    if issecretvalue(role) or role ~= "TANK" then return false end
    local mine = UnitIsUnit(target, "player")
    return not issecretvalue(mine) and not mine
end

local function LooseOnGroupMember(unit)
    local target = targetTokens[unit]
    local exists = UnitExists(target)
    if issecretvalue(exists) or not exists then return false end
    local mine = UnitIsUnit(target, "player")
    if issecretvalue(mine) or mine then return false end
    local inParty, inRaid = UnitInParty(target), UnitInRaid(target)
    if issecretvalue(inParty) or issecretvalue(inRaid) then return false end
    return inParty == true or inRaid ~= nil
end

local function ThreatColor(cfg, unit)
    local status = UnitThreatSituation("player", unit)
    if issecretvalue(status) then return nil end
    if isTank then
        if status == nil then
            if not HeldByOtherTank(unit) and LooseOnGroupMember(unit) then
                return cfg.threatBad
            end
            return nil
        end
        if status == 3 then
            return cfg.showThreatGood and cfg.threatGood or nil
        end
        if HeldByOtherTank(unit) then
            return cfg.showThreatGood and cfg.threatGood or nil
        end
        if status == 1 or status == 2 then
            return cfg.showThreatWarning and cfg.threatWarning or nil
        end
        return cfg.threatBad
    end
    if status == 3 then
        return cfg.threatBad
    elseif status == 1 or status == 2 then
        return cfg.showThreatWarning and cfg.threatWarning or nil
    end
    return cfg.showThreatGood and cfg.threatGood or nil
end

local COLOR_KEYS = {}
for i = 1, #ORDER do
    COLOR_KEYS[ORDER[i]] = ORDER[i] .. "Color"
end

local function MobTypeColor(cfg, flags, previewing)
    if not cfg.mobTypes or not flags then return nil end
    if cfg.mobTypesInstancesOnly and not inInstance and not previewing then return nil end
    for i = 1, #ORDER do
        local mobType = ORDER[i]
        if flags[mobType] and cfg[mobType] then
            return cfg[COLOR_KEYS[mobType]]
        end
    end
end

local previewFlags = {}

local function PreviewFlags(state)
    for i = 1, #ORDER do
        previewFlags[ORDER[i]] = false
    end
    if state.mobType then
        previewFlags[state.mobType] = true
        previewFlags.elite = state.classification == "elite" or state.classification == "rareelite"
    end
    return previewFlags
end

local function ReactionColor(cfg, reaction)
    if issecretvalue(reaction) or not cfg.customReaction or not reaction then return nil end
    if reaction <= 3 then
        return cfg.hostile
    elseif reaction == 4 then
        return cfg.neutral
    end
    return cfg.friendly
end

function UnitColors:IsCompanion(unit)
    if UnitIsPlayer(unit) then return false end
    local inParty = UnitInParty(unit)
    return not issecretvalue(inParty) and inParty == true
end

local UnitGUID = UnitGUID
local UnitClassFromGUID = UnitClassFromGUID

function UnitColors:PlayerClass(unit)
    local class = UnitClassBase(unit)
    if not issecretvalue(class) and class then
        return class
    end
    if not (UnitGUID and UnitClassFromGUID) then return nil end
    local ok, guid = pcall(UnitGUID, unit)
    if not ok then return nil end
    local found, _, file = pcall(UnitClassFromGUID, guid)
    if found and file and not issecretvalue(file) then
        return file
    end
    return nil
end

function UnitColors:SecretClassColor(unit)
    if not (C_ClassColor and C_ClassColor.GetClassColor) then return nil end
    local class = UnitClassBase(unit)
    if not issecretvalue(class) then return nil end
    local ok, color = pcall(C_ClassColor.GetClassColor, class)
    if ok and color then
        return color.r, color.g, color.b, true
    end
    return nil
end

function UnitColors:ClassColor(cfg, unit)
    if not cfg.classColors or not RAID_CLASS_COLORS then return nil end
    local class = self:PlayerClass(unit)
    if not class then
        local r, g, b, ok = self:SecretClassColor(unit)
        if ok then
            return r, g, b, 1, nil, true
        end
        return nil
    end
    local color = RAID_CLASS_COLORS[class]
    if color then
        return color.r, color.g, color.b, 1
    end
end

function UnitColors:Threat(cfg, unit)
    local color = ThreatColor(cfg, unit)
    if color then
        return color[1], color[2], color[3], color[4]
    end
end

function UnitColors:Resolve(plate, unit)
    local cfg = cfgs[plate.state]
    if cfg.showTapped and UnitIsTapDenied(unit) then
        return Unpack(cfg.tapped)
    end

    if plate.isFriendly then
        if UnitIsPlayer(unit) then
            return self:ClassColor(cfg, unit)
        end
        if self:IsCompanion(unit) then
            local r, g, b, a, soft, hidden = self:ClassColor(cfg, unit)
            if hidden or r then
                return r, g, b, a, soft, hidden
            end
        end
        local color = ReactionColor(cfg, UnitReaction(unit, "player"))
        if color then
            return Unpack(color)
        end
        return nil
    end

    if cfg.threat and cfg.threatDisplay ~= "border" and UnitAffectingCombat(unit) then
        local color = ThreatColor(cfg, unit)
        if color then
            return Unpack(color)
        end
    end

    if UnitIsPlayer(unit) then
        if cfg.classColors and RAID_CLASS_COLORS then
            local class = self:PlayerClass(unit)
            if class then
                local color = RAID_CLASS_COLORS[class]
                if color then
                    return color.r, color.g, color.b, 1, true
                end
            else
                local r, g, b, ok = self:SecretClassColor(unit)
                if ok then
                    return r, g, b, 1, nil, true
                end
            end
        end
    else
        local color = MobTypeColor(cfg, plate.mobFlags)
        if color then
            return color[1], color[2], color[3], color[4], true
        end
    end

    local color = ReactionColor(cfg, UnitReaction(unit, "player"))
    if color then
        return color[1], color[2], color[3], color[4], true
    end
end

local MOB_ORDER = { "boss", "lieutenant", "higher", "trivial", "caster", "elite" }
local MOB_LABELS = { boss = "Bosses", lieutenant = "Lieutenants", higher = "Elites", trivial = "Minor enemies", caster = "Casters", elite = "Melee" }

function UnitColors:Explain(plate, unit)
    local cfg = cfgs[plate.state]
    if cfg.showTapped and UnitIsTapDenied(unit) then
        return "tagged by someone else (Colors: Tagged by someone else)"
    end
    local reaction = UnitReaction(unit, "player")
    local function Reaction()
        if issecretvalue(reaction) then
            return "game reaction color (reaction hidden)"
        end
        local kind = (reaction or 0) <= 3 and "Hostile" or reaction == 4 and "Neutral" or "Friendly"
        if cfg.customReaction then
            return ("reaction %s: your %s color (Colors: Reaction)"):format(tostring(reaction), kind)
        end
        return ("reaction %s: the game's %s color (Colors: Use my own colors is off)"):format(tostring(reaction), kind:lower())
    end
    if plate.isFriendly then
        return "friendly plate: " .. Reaction()
    end
    if cfg.threat and cfg.threatDisplay ~= "border" and UnitAffectingCombat(unit) and ThreatColor(cfg, unit) then
        return "threat color (Colors: Threat)"
    end
    if UnitIsPlayer(unit) then
        if cfg.classColors then
            if self:PlayerClass(unit) then
                return "enemy player: class color"
            end
            local _, _, _, hidden = self:SecretClassColor(unit)
            if hidden then
                return "enemy player: class color (class hidden by the game, passed straight to the bar)"
            end
            return "enemy player: class unavailable, so " .. Reaction()
        end
        return Reaction()
    end
    if cfg.mobTypes and not (cfg.mobTypesInstancesOnly and not inInstance) then
        for i = 1, #MOB_ORDER do
            local mobType = MOB_ORDER[i]
            if plate.mobFlags and plate.mobFlags[mobType] and cfg[mobType] then
                return ("enemy type %s (Colors: %s)"):format(MOB_LABELS[mobType], MOB_LABELS[mobType])
            end
        end
        local found = plate.mobType and MOB_LABELS[plate.mobType]
        if found then
            return ("enemy type %s, but its box is off on the Health bar page, so: %s"):format(found, Reaction())
        end
    elseif not cfg.mobTypes then
        return "Color enemies by what they are is off, so: " .. Reaction()
    else
        return "enemy type colors are set to instances only, so: " .. Reaction()
    end
    return Reaction()
end

function UnitColors:PreviewThreat(state, cfg)
    local kind = state.threat
    if not kind or not cfg.threat or state.isPlayer then return nil end
    if kind == "warning" then
        return cfg.showThreatWarning and cfg.threatWarning or nil
    elseif kind == "good" then
        return cfg.showThreatGood and cfg.threatGood or nil
    end
    return cfg.threatBad
end

function UnitColors:ResolvePreview(state, plateState)
    local cfg = cfgs[plateState]
    if state.tapped and cfg.showTapped then
        return Unpack(cfg.tapped)
    end
    if state.isFriendly and not (state.class and cfg.classColors) then
        if cfg.customReaction then
            return Unpack(cfg.friendly)
        end
        return 0, 1, 0, 1
    end
    if state.class and cfg.classColors and RAID_CLASS_COLORS then
        local color = RAID_CLASS_COLORS[state.class]
        if color then
            return color.r, color.g, color.b, 1
        end
    end
    local threat = self:PreviewThreat(state, cfg)
    if threat and cfg.threatDisplay ~= "border" then
        return Unpack(threat)
    end
    if state.questColor and cfg.quest and not (cfg.questExcludeBoss and state.mobType == "boss") then
        return Unpack(cfg.questColor)
    end
    local color = MobTypeColor(cfg, PreviewFlags(state), true)
    if color then
        return Unpack(color)
    end
    color = ReactionColor(cfg, state.neutral and 4 or 2)
    if color then
        return Unpack(color)
    end
    return 1, 0, 0, 1
end

local function UpdateRole()
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local role = specIndex and specIndex > 0 and select(5, C_SpecializationInfo.GetSpecializationInfo(specIndex))
    isTank = role == "TANK"
end

UnitColors:RegisterEvent("PLAYER_ENTERING_WORLD")
UnitColors:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
UnitColors:RegisterEvent("PLAYER_LEVEL_UP")
UnitColors:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LEVEL_UP" then
        if cfgs.enemy then
            ns.Driver:RequestRestyle()
        end
        return
    end
    local wasTank, wasInInstance, wasInRaid = isTank, inInstance, inRaid
    UpdateRole()
    if event == "PLAYER_ENTERING_WORLD" then
        local instance, instanceType = IsInInstance()
        inInstance = instance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario")
        inRaid = instance and instanceType == "raid"
    end
    if cfgs.enemy and (wasTank ~= isTank or wasInInstance ~= inInstance or wasInRaid ~= inRaid) then
        ns.Driver:RequestRestyle()
    end
end)
