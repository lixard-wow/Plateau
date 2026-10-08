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
    local baseLevel, current = plate.base:GetFrameLevel(), plate:GetFrameLevel()
    if issecretvalue(baseLevel) or issecretvalue(current) then return end
    local level = baseLevel + 1 + (plate.band or 0) * BAND
    if current ~= level then
        plate:SetFrameLevel(level)
    end
end

local function SetBand(plate, band)
    plate.band = band
    PlaceLevel(plate)
end

local BAND_CASTING, BAND_TARGET, BAND_MOUSEOVER = 1, 2, 3

local Scaling = {
    key = "scaling",
    nameOnly = true,
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

local smoothScale = false

local animating = {}
local animator = CreateFrame("Frame")
animator:Hide()
animator:SetScript("OnUpdate", function(self, elapsed)
    local step = math.min(1, elapsed * 12)
    local any = false
    for plate in pairs(animating) do
        local goal = plate.appliedScale
        if not goal then
            animating[plate] = nil
        else
            local current = plate.shownScale or goal
            current = current + (goal - current) * step
            local done = math.abs(goal - current) < 0.002 or not plate.active
            if done then
                current = goal
                animating[plate] = nil
            else
                any = true
            end
            plate.shownScale = current
            plate:SetScale(current)
            if done and ns.RepixelPlate then
                ns.RepixelPlate(plate)
            end
        end
    end
    if not any then
        self:Hide()
    end
end)

local function SetPlateScale(plate, net)
    if smoothScale and not plate.preview and plate.shownScale then
        animating[plate] = true
        animator:Show()
        return
    end
    animating[plate] = nil
    plate.shownScale = net
    plate:SetScale(net)
    if not plate.preview and ns.RepixelPlate then
        ns.RepixelPlate(plate)
    end
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
    local net = plate.preview and 1 or scale / blizzard
    if plate.appliedScale ~= net then
        plate.appliedScale = net
        SetPlateScale(plate, net)
    end
    if not plate.preview and plate.appliedStack ~= net then
        plate.appliedStack = net
        plate.stackRegion:SetScale(net)
    end

    if plate.preview or not plate.base then
        return
    end
    local band = 0
    if s and plate.active then
        if s.mouseoverFront and plate.isMouseover then
            band = BAND_MOUSEOVER
        elseif s.castFront and not plate.isFriendly then
            if plate.isTarget then
                band = BAND_TARGET
            elseif plate.casting == true then
                band = BAND_CASTING
            end
        end
    end
    SetBand(plate, band)
end

function Scaling:Attach(plate)
    plate.band = nil
    PlaceLevel(plate)
end

function Scaling:Reset(plate)
    animating[plate] = nil
    plate.appliedScale, plate.appliedStack, plate.shownScale = nil, nil, nil
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
    s.castFront = db.castFront == true
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
    self:Apply(plate)
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

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_LOGIN")
watcher:RegisterEvent("CVAR_UPDATE")
watcher:SetScript("OnEvent", function(_, event, name)
    if event == "CVAR_UPDATE" and name ~= "nameplateSize" and name ~= "nameplateAuraScale" and name ~= "nameplateSelectedScale" then return end
    local plate, aura = ReadBlizzardSizes()
    local selected = tonumber(C_CVar.GetCVar("nameplateSelectedScale")) or 1
    if plate ~= sizeFactor or aura ~= auraFactor or selected ~= selectedScale then
        sizeFactor, auraFactor = plate, aura
        selectedScale = selected
        if ns.DB.views then
            ns.Driver:RequestRestyle(false, "Blizzard nameplate size settings")
        end
    end
end)

ns.Driver:RegisterElement(Scaling)
