local _, ns = ...

local UnitPowerType = UnitPowerType
local UnitPowerPercent = UnitPowerPercent
local UnitHasPowerType = UnitHasPowerType
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local AbbreviateNumbers = AbbreviateNumbers
local SMOOTH = Enum.StatusBarInterpolation and Enum.StatusBarInterpolation.ExponentialEaseOut
local issecretvalue = issecretvalue
local ZeroToOne = CurveConstants.ZeroToOne
local ScaleTo100 = CurveConstants.ScaleTo100
local WHITE = "Interface\\Buttons\\WHITE8X8"

local POWER_COLORS = {
    MANA = { 0.2, 0.5, 1 },
    RAGE = { 1, 0.15, 0.15 },
    ENERGY = { 1, 0.85, 0.1 },
    FOCUS = { 1, 0.5, 0.25 },
    FURY = { 0.79, 0.26, 0.99 },
    PAIN = { 1, 0.61, 0 },
    RUNIC_POWER = { 0, 0.82, 1 },
    LUNAR_POWER = { 0.3, 0.52, 0.9 },
    MAELSTROM = { 0, 0.5, 1 },
    INSANITY = { 0.4, 0, 0.8 },
    ESSENCE = { 0.2, 0.58, 0.5 },
    ALTERNATE = { 0.75, 0.75, 0.75 },
}
local FALLBACK_COLOR = { 1, 0.85, 0.1 }

local settings = {}
local fullCurves = {}

local function FullCurve(alpha)
    if not (C_CurveUtil and C_CurveUtil.CreateCurve) then return nil end
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, alpha)
    curve:AddPoint(0.9999, 0)
    return curve
end

local EnemyPower = {
    key = "enemyPower",
    events = { "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER" },
}
ns.Elements = ns.Elements or {}
ns.Elements.EnemyPower = EnemyPower

function EnemyPower:Create(plate)
    local bar = CreateFrame("StatusBar", nil, plate)
    bar:SetStatusBarTexture(WHITE)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    bar:Hide()
    bar.back = bar:CreateTexture(nil, "BACKGROUND")
    bar.back:SetAllPoints()
    bar.back:SetTexture(WHITE)
    bar.text = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.text:SetPoint("CENTER")
    bar.border = ns.CreateBorder(bar, bar, "BACKGROUND", -7)
    bar.border:Hide()
    plate.enemyPowerBar = bar
end

function EnemyPower:Configure(db, state)
    settings[state] = db
    fullCurves[state] = db.hideFull and FullCurve(db.alpha) or nil
end

function EnemyPower:Style(plate, db)
    local bar = plate.enemyPowerBar
    local health = plate.health
    bar:SetFrameLevel(health:GetFrameLevel() + 5)
    bar:SetHeight(db.height)
    bar:ClearAllPoints()
    local point, relative = "BOTTOM", "BOTTOM"
    if db.position == "above" then
        point, relative = "BOTTOM", "TOP"
    elseif db.position == "below" then
        point, relative = "TOP", "BOTTOM"
    end
    if db.width > 0 then
        bar:SetWidth(db.width)
        bar:SetPoint(point, health, relative, db.offsetX, db.offsetY)
    else
        bar:SetPoint(point .. "LEFT", health, relative .. "LEFT", db.offsetX, db.offsetY)
        bar:SetPoint(point .. "RIGHT", health, relative .. "RIGHT", db.offsetX, db.offsetY)
    end
    local back = db.backgroundColor
    bar.back:SetVertexColor(back[1], back[2], back[3], back[4])
    ns.SetBarTexture(bar, db.texture or WHITE)
    ns.ApplyFont(bar.text, db.font, db.textSize, db.outline)
    local anchor = db.textAnchor or "CENTER"
    bar.text:ClearAllPoints()
    bar.text:SetPoint(anchor, bar, anchor, anchor == "LEFT" and 2 or anchor == "RIGHT" and -2 or 0, 0)
    bar.text:SetJustifyH(anchor)
    bar.text:SetShown(db.showText)
    if db.border then
        bar.border:SetStyle("pixel", bar)
        bar.border:SetColor(db.borderColor[1], db.borderColor[2], db.borderColor[3], db.borderColor[4])
        bar.border:Layout(1, 0, false)
        bar.border:Show()
    else
        bar.border:Hide()
    end
    bar:SetAlpha(db.alpha)
end

local function Wanted(plate, db)
    if plate.isFriendly or plate.isPlayer then
        return false
    end
    if db.show == "all" then
        return true
    elseif db.show == "target" then
        return plate.isTarget == true
    elseif db.show == "bossesCasters" then
        return plate.mobType == "boss" or (plate.mobFlags and plate.mobFlags.caster == true)
    end
    return plate.mobType == "boss"
end

local function SetCastShift(plate, shift)
    if (plate.castShift or 0) ~= shift then
        plate.castShift = shift
        ns.Elements.Castbar:Reposition(plate)
    end
end

local function HideBar(plate)
    if plate.powerShown ~= false then
        plate.powerShown = false
        plate.enemyPowerBar:Hide()
    end
    SetCastShift(plate, 0)
end

function EnemyPower:Update(plate, unit, snap)
    local bar = plate.enemyPowerBar
    local db = settings[plate.state]
    if not (unit and db and Wanted(plate, db)) then
        HideBar(plate)
        return
    end
    local powerType, token = UnitPowerType(unit)
    local has = UnitHasPowerType(unit, powerType)
    if not issecretvalue(has) and has == false then
        HideBar(plate)
        return
    end
    local max = UnitPowerMax(unit, powerType)
    if not issecretvalue(max) and max and max <= 0 then
        HideBar(plate)
        return
    end
    local safeToken = not issecretvalue(token) and token or nil
    local safePowerType = not issecretvalue(powerType) and powerType or nil
    local color = db.customColor and db.color or (safeToken and POWER_COLORS[safeToken])
        or (safePowerType and POWER_COLORS[safePowerType]) or FALLBACK_COLOR
    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    if db.smooth and SMOOTH and not snap then
        bar:SetValue(UnitPowerPercent(unit, powerType, false, ZeroToOne), SMOOTH)
    else
        bar:SetValue(UnitPowerPercent(unit, powerType, false, ZeroToOne))
    end
    if db.showText then
        local format = db.textFormat
        if format == "value" then
            bar.text:SetText(AbbreviateNumbers(UnitPower(unit, powerType)))
        elseif format == "both" then
            bar.text:SetFormattedText("%s | %d%%", AbbreviateNumbers(UnitPower(unit, powerType)), UnitPowerPercent(unit, powerType, false, ScaleTo100))
        else
            bar.text:SetFormattedText("%d%%", UnitPowerPercent(unit, powerType, false, ScaleTo100))
        end
    end
    local curve = fullCurves[plate.state]
    if curve then
        bar:SetAlpha(UnitPowerPercent(unit, powerType, false, curve))
    end
    if plate.powerShown ~= true then
        plate.powerShown = true
        bar:Show()
    end
    SetCastShift(plate, db.position == "below" and (db.height + 1 + math.max(0, -db.offsetY)) or 0)
end

function EnemyPower:Enable(plate, unit)
    self:Update(plate, unit, true)
end

function EnemyPower:Disable(plate)
    HideBar(plate)
end

function EnemyPower:OnEvent(plate, _, unit)
    self:Update(plate, plate.unit or unit)
end

function EnemyPower:UpdateEmphasis(plate)
    if plate.unit then
        self:Update(plate, plate.unit)
    end
end

function EnemyPower:Preview(plate, state)
    local bar = plate.enemyPowerBar
    local db = settings[plate.state]
    if not state.enemyPower then
        HideBar(plate)
        return
    end
    SetCastShift(plate, db.position == "below" and (db.height + 1 + math.max(0, -db.offsetY)) or 0)
    local color = db.customColor and db.color or POWER_COLORS.ENERGY
    bar:SetStatusBarColor(color[1], color[2], color[3], 1)
    bar:SetValue(0.6)
    bar:SetAlpha(db.alpha)
    if db.showText then
        if db.textFormat == "value" then
            bar.text:SetText("60")
        elseif db.textFormat == "both" then
            bar.text:SetText("60 | 60%")
        else
            bar.text:SetText("60%")
        end
    end
    plate.powerShown = true
    bar:Show()
end

ns.Driver:RegisterElement(EnemyPower)
