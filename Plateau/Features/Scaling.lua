local _, ns = ...

local UnitAffectingCombat = UnitAffectingCombat

local settings = {}
local targetScale = 1
local selectedScale = 1
local follow = false
local sizeFactor, auraFactor = 1, 1

local FALLBACK_SCALES = { 0.8, 1, 1.25, 1.4, 1.6 }

local function PlateScale(index)
    local scales = NamePlateConstants and NamePlateConstants.NAME_PLATE_SCALES
    local entry = scales and scales[index]
    return entry and entry.vertical or FALLBACK_SCALES[index] or 1
end

local function ReadBlizzardSizes()
    local size = tonumber(C_CVar.GetCVar("nameplateSize")) or 1
    local defaultSize = tonumber(C_CVar.GetCVarDefault("nameplateSize")) or 1
    local aura = tonumber(C_CVar.GetCVar("nameplateAuraScale")) or 1
    local defaultAura = tonumber(C_CVar.GetCVarDefault("nameplateAuraScale")) or 1
    return PlateScale(size) / PlateScale(defaultSize), aura / (defaultAura > 0 and defaultAura or 1)
end

local BAND = 200

local function PlaceLevel(plate)
    local level = plate.base:GetFrameLevel() + plate.band * BAND
    if plate.appliedLevel ~= level then
        plate.appliedLevel = level
        plate:SetFrameLevel(level)
    end
end

local function SetBand(plate, band)
    if plate.band == band then return end
    plate.band = band
    PlaceLevel(plate)
end

local TIER_KEYS = { "boss", "target", "focus", "casting", "caster", "lieutenant", "higher", "melee", "trivial" }
local TIER_COUNT = #TIER_KEYS
local VALID_TIER = {}
for _, key in ipairs(TIER_KEYS) do
    VALID_TIER[key] = true
end
local MOB_TIER = { boss = "boss", lieutenant = "lieutenant", higher = "higher", caster = "caster", elite = "melee" }

local function Ranks(text)
    local list, seen = {}, {}
    for key in text:gmatch("%a+") do
        if VALID_TIER[key] and not seen[key] then
            seen[key] = true
            list[#list + 1] = key
        end
    end
    for index, key in ipairs(TIER_KEYS) do
        if not seen[key] then
            seen[key] = true
            local position = 1
            local previous = TIER_KEYS[index - 1]
            if previous then
                for i = 1, #list do
                    if list[i] == previous then
                        position = i + 1
                        break
                    end
                end
            end
            table.insert(list, position, key)
        end
    end
    local ranks = {}
    for rank, key in ipairs(list) do
        ranks[key] = rank
    end
    return ranks
end

local function PriorityRank(plate, ranks)
    local best = ranks[MOB_TIER[plate.mobType] or "trivial"]
    if plate.isTarget and ranks.target < best then
        best = ranks.target
    end
    if plate.isFocus and ranks.focus < best then
        best = ranks.focus
    end
    if plate.casting == true and ranks.casting < best then
        best = ranks.casting
    end
    return best
end

local Scaling = {
    key = "scaling",
    events = {},
}
ns.Scaling = Scaling

function Scaling:AuraFactor()
    return follow and auraFactor or 1
end

function Scaling:SetTargetScale(scale)
    targetScale = scale
end

function Scaling:RefreshBlizzardScale()
    selectedScale = tonumber(C_CVar.GetCVar("nameplateSelectedScale")) or 1
end

local reference
local provisional = false
local floorRatio = 1
local PROVISIONAL_DROP = 0.5
local MIN_FACTOR = 0.1
local TARGET_SETTLE = 1
local smoothScale = false

local function ReadFloorRatio()
    local minScale = tonumber(C_CVar.GetCVar("nameplateMinScale"))
    local maxScale = tonumber(C_CVar.GetCVar("nameplateMaxScale"))
    if minScale and maxScale and maxScale > 0 then
        return math.min(1, minScale / maxScale)
    end
    return 0.8
end

local function SavedReference()
    local saved = ns.DB and ns.DB.saved and ns.DB.saved.global
    return saved and tonumber(saved.scaleReference)
end

local function SaveReference()
    local saved = ns.DB and ns.DB.saved and ns.DB.saved.global
    if saved then
        saved.scaleReference = reference
    end
end

function Scaling:ResetReference()
    reference = reference or SavedReference()
    provisional = reference ~= nil
    floorRatio = ReadFloorRatio()
end

local function Learn(measured)
    if provisional then
        if measured < reference * PROVISIONAL_DROP then return end
        reference, provisional = measured, false
        SaveReference()
    elseif not reference or measured > reference then
        reference = measured
        SaveReference()
    end
end

function Scaling:Reference()
    return reference
end
local animating = {}
local animator = CreateFrame("Frame")
animator:Hide()
animator:SetScript("OnUpdate", function(self, elapsed)
    local step = math.min(1, elapsed * 12)
    local any = false
    for plate in pairs(animating) do
        local goal = plate.appliedScale
        local current = plate.shownScale or goal
        current = current + (goal - current) * step
        if math.abs(goal - current) < 0.002 or not plate.active then
            current = goal
            animating[plate] = nil
        else
            any = true
        end
        plate.shownScale = current
        plate:SetScale(current)
    end
    if not any then
        self:Hide()
    end
end)

local function SetPlateScale(plate, net)
    if smoothScale and not plate.preview and not plate.appearing and plate.shownScale then
        animating[plate] = true
        animator:Show()
        return
    end
    animating[plate] = nil
    plate.shownScale = net
    plate:SetScale(net)
end

function Scaling:Apply(plate)
    local scale = 1
    local s = settings[plate.state]
    if s and not plate.isFriendly and not plate.isPlayer and self.enabledIn[plate.state] then
        scale = s[plate.mobType or "trivial"] or 1
    end
    if s and s.combatEnabled and not plate.isFriendly and not plate.isPlayer and plate.unit then
        scale = scale * (UnitAffectingCombat(plate.unit) and s.combatScale or s.idleScale)
    end
    local blizzard = 1
    if plate.isTarget then
        blizzard = selectedScale > 0 and selectedScale or 1
        local target = targetScale * blizzard
        if not plate.isFriendly and target > scale then
            scale = target
        end
    end
    if s and plate.isFocus and s.focusGrow and s.focusScale > scale then
        scale = s.focusScale
    end
    if s and plate.casting and s.castPop and s.castScale > scale then
        scale = s.castScale
    end
    if s and plate.isMouseover and s.mouseoverGrow and not plate.isFriendly and s.mouseoverScale > scale then
        scale = s.mouseoverScale
    end
    if follow or plate.isFriendly then
        scale = scale * sizeFactor
    end
    if s and plate.isFriendly then
        scale = scale * (s.friendlyScale or 1)
    end
    local net = plate.preview and 1 or scale * (plate.distanceFactor or reference or 1)
    if plate.appliedScale ~= net then
        plate.appliedScale = net
        SetPlateScale(plate, net)
    end
    if not plate.preview then
        local stack = scale / blizzard
        if plate.appliedStack ~= stack then
            plate.appliedStack = stack
            plate.stackRegion:SetScale(stack)
        end
    end

    if plate.preview or not plate.base then
        return
    end
    local band = 0
    if s and plate.active and s.mouseoverFront and plate.isMouseover then
        band = TIER_COUNT + 1
    elseif s and plate.active and s.layerByType and not plate.isFriendly and not plate.isPlayer then
        band = TIER_COUNT - PriorityRank(plate, s.ranks)
    end
    SetBand(plate, band)
end

local function Measure(plate, container, divisor)
    local distance = plate.base:GetEffectiveScale() / container:GetEffectiveScale() / divisor
    if distance >= MIN_FACTOR then
        return distance
    end
end

local function Clamp(distance)
    if not reference then
        return distance
    end
    return math.max(reference * floorRatio, math.min(reference, distance or reference))
end

function Scaling:Follow(plate, container)
    local distance
    local now = GetTime()
    if plate.isTarget then
        plate.targetSeen = now
    end
    if plate.appearing then
        distance = nil
    elseif plate.isTarget then
        distance = reference or Measure(plate, container, selectedScale)
    else
        local measured = Measure(plate, container, 1)
        local settled = not plate.targetSeen or now - plate.targetSeen > TARGET_SETTLE
        if measured and settled and plate.mobType ~= "boss" then
            Learn(measured)
        end
        distance = Clamp(measured)
    end
    local changed = false
    if distance and plate.distanceFactor ~= distance then
        plate.distanceFactor = distance
        self:Apply(plate)
        changed = true
    end
    if plate.band then
        local before = plate.appliedLevel
        PlaceLevel(plate)
        changed = changed or before ~= plate.appliedLevel
    end
    return changed
end

function Scaling:Create()
end

function Scaling:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.boss = db.boss
    s.lieutenant = db.lieutenant
    s.higher = db.higher
    s.caster = db.caster
    s.elite = db.elite
    s.trivial = db.trivial
    s.focusGrow = db.focusGrow
    s.focusScale = db.focusScale
    s.castPop = db.castPop
    s.castScale = db.castScale
    s.layerByType = db.layerByType
    s.ranks = Ranks(db.layerOrder)
    s.combatEnabled = db.combatEnabled
    s.combatScale = db.combatScale
    s.idleScale = db.idleScale
    s.mouseoverGrow = db.mouseoverGrow == true
    s.mouseoverScale = db.mouseoverScale or 1
    s.friendlyScale = db.friendlyScale or 1
    s.mouseoverFront = db.mouseoverFront == true
    if state == "enemy" then
        smoothScale = db.smooth == true
    end
end

function Scaling:Style()
end

function Scaling:Enable(plate)
end

function Scaling:RankOf(plate)
    local s = settings[plate.state]
    if not (s and s.layerByType) or plate.isFriendly or plate.isPlayer then
        return nil
    end
    return PriorityRank(plate, s.ranks)
end

function Scaling:UsesCombat(state)
    local s = settings[state]
    return s ~= nil and s.combatEnabled == true
end

function Scaling:Disable(plate)
    self:Apply(plate)
end

function Scaling:OnEvent()
end

function Scaling:Preview(plate)
    self:Apply(plate)
end

function Scaling:Configured()
    follow = ns.DB.views.enemy.plate.followBlizzardSize == true
end

local REFERENCE_CVARS = { nameplateSize = true, nameplateMinScale = true, nameplateMaxScale = true, nameplateGlobalScale = true, uiScale = true, useUiScale = true }

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("CVAR_UPDATE")
watcher:RegisterEvent("UI_SCALE_CHANGED")
watcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
watcher:SetScript("OnEvent", function(_, event, name)
    if event ~= "CVAR_UPDATE" or REFERENCE_CVARS[name] then
        Scaling:ResetReference()
    end
    if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then return end
    if event == "CVAR_UPDATE" and name ~= "nameplateSize" and name ~= "nameplateAuraScale" and name ~= "nameplateSelectedScale" then return end
    local plate, aura = ReadBlizzardSizes()
    local selected = tonumber(C_CVar.GetCVar("nameplateSelectedScale")) or 1
    if plate ~= sizeFactor or aura ~= auraFactor or selected ~= selectedScale then
        sizeFactor, auraFactor = plate, aura
        selectedScale = selected
        if ns.DB.views then
            ns.Driver:RequestRestyle()
        end
    end
end)

ns.Driver:RegisterElement(Scaling)
