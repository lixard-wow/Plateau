local _, ns = ...

local CreateFrame = CreateFrame
local UnitHealthPercent = UnitHealthPercent
local UnitSelectionColor = UnitSelectionColor
local UnitAffectingCombat = UnitAffectingCombat
local UnitThreatSituation = UnitThreatSituation
local ZeroToOne = CurveConstants.ZeroToOne
local UnitColors = ns.UnitColors
local UnitIsRelatedToActiveQuest = C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest
local EvaluateColorValueFromBoolean = C_CurveUtil.EvaluateColorValueFromBoolean

local targetColor, focusColor
local targetTexture, focusTexture
local baseTexture = {}
local targetOverlay, targetOverlayAlpha, targetOverlayContrast
local focusOverlay, focusOverlayAlpha, focusOverlayContrast
local baseOverlay, baseOverlayAlpha, baseOverlayContrast = {}, {}, {}
local smooth, desaturate, spark = {}, {}, {}
local fades = {}

local function FadeCurve(fade, r, g, b, a)
    local key = ("%.3f %.3f %.3f %.3f"):format(r, g, b, a)
    local curve = fade.curves[key]
    if curve then
        return curve
    end
    local low, amount = fade.low, fade.amount
    curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    curve:AddPoint(0, CreateColor(r + (low[1] - r) * amount, g + (low[2] - g) * amount, b + (low[3] - b) * amount, a))
    curve:AddPoint(1, CreateColor(r, g, b, a))
    fade.curves[key] = curve
    return curve
end
local SMOOTH = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut

local function SparkCurve()
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, 0)
    curve:AddPoint(0.005, 1)
    curve:AddPoint(0.995, 0)
    return curve
end
local sparkCurve = SparkCurve()

local Health = {
    key = "health",
    events = {
        "UNIT_HEALTH",
        "UNIT_MAXHEALTH",
        "UNIT_FACTION",
        "UNIT_FLAGS",
        "UNIT_CLASSIFICATION_CHANGED",
        "UNIT_DISPLAYPOWER",
        "UNIT_THREAT_LIST_UPDATE",
        "UNIT_THREAT_SITUATION_UPDATE",
        "UNIT_TARGET",
    },
    gatedEvents = { UNIT_THREAT_LIST_UPDATE = "threat", UNIT_THREAT_SITUATION_UPDATE = "threat", UNIT_TARGET = "threat" },
    globalEvents = { "INSTANCE_ENCOUNTER_ENGAGE_UNIT", "QUEST_LOG_UPDATE" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Health = Health

function Health:Create(plate)
    local bar = CreateFrame("StatusBar", nil, plate)
    bar:SetAllPoints()
    bar:SetMinMaxValues(0, 1)
    local borderLayer = CreateFrame("Frame", nil, plate)
    borderLayer:SetAllPoints()
    borderLayer:SetFrameLevel(bar:GetFrameLevel() + 3)
    bar.borderLayer = borderLayer
    bar.border = ns.CreateBorder(borderLayer, plate, "BACKGROUND", -7)
    bar.background = bar:CreateTexture(nil, "BACKGROUND")
    bar.background:SetAllPoints()
    plate.health = bar
    bar.spark = ns.MarkerLayer(plate):CreateTexture(nil, "OVERLAY", nil, 3)
    bar.spark:SetTexture("Interface\\Buttons\\WHITE8X8")
    bar.spark:SetBlendMode("ADD")
    bar.spark:Hide()
    plate.mobFlags = {}
end

function Health:Configure(db, state)
    baseTexture[state] = db.texture
    baseOverlay[state] = db.overlayPattern ~= "" and db.overlayPattern or nil
    baseOverlayAlpha[state] = db.overlayAlpha
    baseOverlayContrast[state] = db.overlayContrast
    smooth[state] = db.smooth == true and SMOOTH or nil
    desaturate[state] = db.desaturate == true
    spark[state] = db.spark == true
    local colors = ns.DB.views[state] and ns.DB.views[state].colors
    if colors and colors.healthGradient and C_CurveUtil and C_CurveUtil.CreateColorCurve then
        fades[state] = { low = colors.healthLow, amount = colors.healthFade or 0.75, curves = {} }
    else
        fades[state] = nil
    end
    if state ~= "enemy" then return end
    local look = ns.DB.views.enemy
    targetColor = look.target.colorBar and look.target.barColor or nil
    focusColor = look.focus.colorBar and look.focus.barColor or nil
    targetTexture = look.target.texture ~= "" and look.target.texture or nil
    focusTexture = look.focus.texture ~= "" and look.focus.texture or nil
    targetOverlay = look.target.overlayPattern ~= "" and look.target.overlayPattern or nil
    targetOverlayAlpha = look.target.overlayAlpha
    targetOverlayContrast = look.target.overlayContrast
    focusOverlay = look.focus.overlayPattern ~= "" and look.focus.overlayPattern or nil
    focusOverlayAlpha = look.focus.overlayAlpha
    focusOverlayContrast = look.focus.overlayContrast
end

local function ResolveOverlay(plate)
    if plate.isTarget and targetOverlay then
        return targetOverlay, targetOverlayAlpha, targetOverlayContrast
    end
    if plate.isFocus and focusOverlay then
        return focusOverlay, focusOverlayAlpha, focusOverlayContrast
    end
    return baseOverlay[plate.state], baseOverlayAlpha[plate.state], baseOverlayContrast[plate.state]
end

local function ApplyTexture(plate)
    local texture = (plate.isTarget and targetTexture) or (plate.isFocus and focusTexture) or baseTexture[plate.state]
    local bar = plate.health
    if bar.texture ~= texture then
        bar.texture = texture
        ns.SetBarTexture(bar, texture)
        bar:SetStatusBarDesaturated(desaturate[plate.state] == true)
    end
    local overlay, overlayAlpha, overlayContrast = ResolveOverlay(plate)
    if bar.overlay ~= overlay or bar.overlayAlphaValue ~= overlayAlpha or bar.overlayContrastValue ~= overlayContrast then
        bar.overlay, bar.overlayAlphaValue, bar.overlayContrastValue = overlay, overlayAlpha, overlayContrast
        ns.SetBarOverlay(bar, overlay, overlayAlpha, overlayContrast)
    end
end

function Health:Style(plate, db)
    local bar = plate.health
    local size = db.borderSize
    bar.texture = nil
    ApplyTexture(plate)
    bar.border:SetStyle(db.borderStyle, bar.borderLayer)
    bar.border:SetColor(db.border[1], db.border[2], db.border[3], db.border[4])
    bar.border:Layout(size, 0, db.borderInside)
    ns.SetBackgroundTexture(bar.background, db.backgroundTexture, db.background)
    local reverse = db.fillDirection == "right"
    bar:SetReverseFill(reverse)
    local fill = bar:GetStatusBarTexture()
    local edge = reverse and "LEFT" or "RIGHT"
    local sparkTexture = bar.spark
    sparkTexture:ClearAllPoints()
    sparkTexture:SetPoint("TOP", fill, "TOP" .. edge)
    sparkTexture:SetPoint("BOTTOM", fill, "BOTTOM" .. edge)
    sparkTexture:SetWidth(db.sparkWidth or 2)
    sparkTexture:SetVertexColor(db.sparkColor[1], db.sparkColor[2], db.sparkColor[3], db.sparkColor[4])
    sparkTexture:SetShown(db.spark == true)
end

function Health:Enable(plate, unit)
    plate.health:Show()
    plate.health.border:Show()
    self:UpdateMobType(plate, unit)
    ns.Scaling:Apply(plate)
    self:UpdateColor(plate, unit)
    self:Update(plate, unit, true)
end

function Health:UpdateMobType(plate, unit)
    if plate.isFriendly then
        plate.mobType = nil
        UnitColors:ClearMobType(plate.mobFlags)
    else
        plate.mobType = UnitColors:MobType(unit, plate.mobFlags)
    end
end

function Health:Disable(plate)
    plate.mobType = nil
    UnitColors:ClearMobType(plate.mobFlags)
    plate.health:Hide()
    plate.health.border:Hide()
    plate.healthGradient = nil
end

function Health:OnEvent(plate, event, unit)
    if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        self:Update(plate, unit)
        if plate.healthGradient then
            self:UpdateColor(plate, plate.unit or unit)
        end
        return
    end
    if event == "QUEST_LOG_UPDATE" then
        if not ns.DB.views[plate.state].colors.quest then return end
        self:UpdateColor(plate, plate.unit or unit)
        return
    end
    if event == "UNIT_CLASSIFICATION_CHANGED" or event == "UNIT_DISPLAYPOWER" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        self:UpdateMobType(plate, unit)
        ns.Scaling:Apply(plate)
        local quest = ns.Elements.Quest
        if quest and ns.Runs(quest, plate) then
            quest:Update(plate, plate.unit or unit)
        end
    end
    if (event == "UNIT_THREAT_LIST_UPDATE" or event == "UNIT_THREAT_SITUATION_UPDATE") and not plate.isFriendly then
        local status = UnitThreatSituation("player", plate.unit or unit)
        if not issecretvalue(status) then
            local seen = status == nil and false or status
            if plate.threatSeen == seen then return end
            self:UpdateColor(plate, plate.unit or unit)
            plate.threatSeen = seen
            return
        end
    end
    if event == "UNIT_FLAGS" and ns.Scaling:UsesCombat(plate.state) then
        ns.Scaling:Apply(plate)
    end
    self:UpdateColor(plate, plate.unit or unit)
end

function Health:Update(plate, unit, snap)
    local bar = plate.health
    local interpolation = not snap and smooth[plate.state]
    if interpolation then
        bar:SetValue(UnitHealthPercent(unit, false, ZeroToOne), interpolation)
    else
        bar:SetValue(UnitHealthPercent(unit, false, ZeroToOne))
    end
    if spark[plate.state] then
        bar.spark:SetAlpha(UnitHealthPercent(unit, false, sparkCurve))
    end
end

function Health:UpdateEmphasis(plate)
    if plate.unit then
        self:UpdateColor(plate, plate.unit)
    end
end

local function Paint(plate, r, g, b, a)
    plate.health:SetStatusBarColor(r, g, b, a)
    local name = ns.Elements.Name
    if name then
        name:BarColor(plate, r, g, b, a)
    end
end

local function Finish(plate, unit, r, g, b, a)
    local fade = fades[plate.state]
    a = a or 1
    if fade and not plate.isFriendly and not issecretvalue(r) and not issecretvalue(g) and not issecretvalue(b) and not issecretvalue(a) then
        local color = UnitHealthPercent(unit, false, FadeCurve(fade, r, g, b, a))
        plate.healthGradient = true
        Paint(plate, color.r, color.g, color.b, color.a)
        return
    end
    plate.healthGradient = nil
    Paint(plate, r, g, b, a)
end

local function UpdateBorder(plate, unit)
    local look = ns.DB.views[plate.state]
    local colors = look.colors
    if not colors.threat or colors.threatDisplay == "bar" then return end
    local border = plate.health.border
    local r, g, b, a
    if not plate.isFriendly and UnitAffectingCombat(unit) then
        r, g, b, a = UnitColors:Threat(colors, unit)
    end
    if r then
        border:SetColor(r, g, b, a)
    else
        local base = look.health.border
        border:SetColor(base[1], base[2], base[3], base[4])
    end
end

function Health:UpdateColor(plate, unit)
    local bar = plate.health
    plate.threatSeen = nil
    ApplyTexture(plate)
    UpdateBorder(plate, unit)
    local override = (plate.isTarget and targetColor) or (plate.isFocus and focusColor) or ns.Idle:Color(plate)
    if override then
        Finish(plate, unit, override[1], override[2], override[3], override[4])
        return
    end
    local r, g, b, a, soft, hidden = UnitColors:Resolve(plate, unit)
    if hidden or r then
        local colors = ns.DB.views[plate.state].colors
        if not hidden and soft and colors.quest and UnitIsRelatedToActiveQuest and not (colors.questExcludeBoss and plate.mobType == "boss") then
            local isQuest = UnitIsRelatedToActiveQuest(unit)
            local quest = colors.questColor
            r = EvaluateColorValueFromBoolean(isQuest, quest[1], r)
            g = EvaluateColorValueFromBoolean(isQuest, quest[2], g)
            b = EvaluateColorValueFromBoolean(isQuest, quest[3], b)
        end
        Finish(plate, unit, r, g, b, a)
    else
        Finish(plate, unit, UnitSelectionColor(unit, false))
    end
end

function Health:Preview(plate, state)
    local bar = plate.health
    bar:Show()
    bar.border:Show()
    plate.mobType = state.mobType
    ApplyTexture(plate)
    bar:SetValue(state.health)
    if spark[plate.state] then
        local health = state.health or 1
        bar.spark:SetAlpha((health > 0.005 and health < 0.995) and 1 or 0)
    end
    local override = (plate.isTarget and targetColor) or (plate.isFocus and focusColor)
    local r, g, b, a
    if override then
        r, g, b, a = override[1], override[2], override[3], override[4]
    else
        r, g, b, a = UnitColors:ResolvePreview(state, plate.state)
    end
    local fade = fades[plate.state]
    if fade and not state.isFriendly then
        local t = (1 - (state.health or 1)) * fade.amount
        local low = fade.low
        r, g, b = r + (low[1] - r) * t, g + (low[2] - g) * t, b + (low[3] - b) * t
    end
    Paint(plate, r, g, b, a)
    local colors = ns.DB.views[plate.state].colors
    local threat = UnitColors:PreviewThreat(state, colors)
    if threat and colors.threatDisplay ~= "bar" then
        bar.border:SetColor(threat[1], threat[2], threat[3], threat[4])
    end
end

ns.Driver:RegisterElement(Health)
