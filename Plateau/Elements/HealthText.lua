local _, ns = ...

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthMissing = UnitHealthMissing
local UnitHealthPercent = UnitHealthPercent
local AbbreviateNumbers = AbbreviateNumbers
local ScaleTo100 = CurveConstants.ScaleTo100

local function Abbreviation(k, m, b)
    local breakpoints = {
        { breakpoint = 1000000000, abbreviation = "B", significandDivisor = b[1], fractionDivisor = b[2], abbreviationIsGlobal = false },
        { breakpoint = 1000000, abbreviation = "M", significandDivisor = m[1], fractionDivisor = m[2], abbreviationIsGlobal = false },
        { breakpoint = 1000, abbreviation = "K", significandDivisor = k[1], fractionDivisor = k[2], abbreviationIsGlobal = false },
    }
    local abbreviate = { breakpointData = breakpoints }
    if CreateAbbreviateConfig then
        abbreviate.config = CreateAbbreviateConfig(breakpoints)
    end
    return abbreviate
end

local ABBREVIATIONS = {
    standard = Abbreviation({ 100, 10 }, { 10000, 100 }, { 10000000, 100 }),
    whole = Abbreviation({ 1000, 1 }, { 1000000, 1 }, { 1000000000, 1 }),
    one = Abbreviation({ 100, 10 }, { 100000, 10 }, { 100000000, 10 }),
}

local missingCurve, fullCurve
if C_CurveUtil and C_CurveUtil.CreateCurve then
    missingCurve = C_CurveUtil.CreateCurve()
    missingCurve:SetType(Enum.LuaCurveType.Linear)
    missingCurve:AddPoint(0, 100)
    missingCurve:AddPoint(1, 0)
    fullCurve = C_CurveUtil.CreateCurve()
    fullCurve:SetType(Enum.LuaCurveType.Step)
    fullCurve:AddPoint(0, 1)
    fullCurve:AddPoint(0.9999, 0)
end

local settings = {}

local HealthText = {
    key = "healthText",
    events = { "UNIT_HEALTH", "UNIT_MAXHEALTH" },
}
ns.Elements = ns.Elements or {}
ns.Elements.HealthText = HealthText

local function Blend(from, to, t)
    return {
        from[1] + (to[1] - from[1]) * t,
        from[2] + (to[2] - from[2]) * t,
        from[3] + (to[3] - from[3]) * t,
        from[4] + (to[4] - from[4]) * t,
    }
end

local function Gradient(db, health)
    if health >= 0.5 then
        return Blend(db.colorMid, db.colorHigh, (health - 0.5) * 2)
    end
    return Blend(db.colorLow, db.colorMid, health * 2)
end

local function BaseColor(db, health)
    if db.colorByHealth then
        return Gradient(db, health)
    end
    return db.color
end

local function ColorAt(s, health)
    if s.executeOn and health * 100 < s.threshold then
        return s.executeColor
    end
    return BaseColor(s.db, health)
end

local function ToColor(color)
    return CreateColor(color[1], color[2], color[3], color[4])
end

local function ColorCurve(db, executeOn, threshold)
    local curve = C_CurveUtil.CreateColorCurve()
    curve:SetType(Enum.LuaCurveType.Linear)
    local start = 0
    if executeOn then
        local cut = threshold / 100
        curve:AddPoint(0, ToColor(db.executeTextColor))
        curve:AddPoint(cut, ToColor(db.executeTextColor))
        start = math.min(cut + 0.0001, 1)
        curve:AddPoint(start, ToColor(BaseColor(db, start)))
    else
        curve:AddPoint(0, ToColor(BaseColor(db, 0)))
    end
    if db.colorByHealth then
        if start < 0.5 then
            curve:AddPoint(0.5, ToColor(db.colorMid))
        end
        curve:AddPoint(1, ToColor(db.colorHigh))
    else
        curve:AddPoint(1, ToColor(db.color))
    end
    return curve
end

function HealthText:Create(plate)
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.healthText = text
end

function HealthText:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.db = db
    s.mode = db.format
    local decimals = math.max(0, math.min(2, math.floor(db.decimals)))
    local percent = "%." .. decimals .. "f" .. (db.percentSign == false and "" or "%%")
    s.percentFormat = percent
    s.missingPercentFormat = "-" .. percent
    s.bothFormat = "%s | " .. percent
    s.parenFormat = "%s (" .. percent .. ")"
    s.percentFirstFormat = percent .. " | %s"
    s.abbreviate = ABBREVIATIONS[db.valuePrecision] or ABBREVIATIONS.standard
    s.hideFull = db.hideFull == true and fullCurve ~= nil
    s.targetOnly = db.targetOnly == true
    local execute = ns.DB.views[state] and ns.DB.views[state].execute
    s.threshold = execute and execute.threshold or 20
    s.executeOn = db.executeColor == true
    s.executeColor = db.executeTextColor
    if (db.colorByHealth or s.executeOn) and C_CurveUtil and C_CurveUtil.CreateColorCurve then
        s.curve = ColorCurve(db, s.executeOn, s.threshold)
    else
        s.curve = nil
    end
end

function HealthText:Style(plate, db)
    local text = plate.healthText
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
    text:SetTextColor(db.color[1], db.color[2], db.color[3], db.color[4])
    ns.PlaceText(text, plate.health, db.anchor, 3, db.offsetX, db.offsetY)
end

local function ApplyShown(plate)
    local s = settings[plate.state]
    plate.healthText:SetShown(not s.targetOnly or plate.isTarget == true)
end

function HealthText:Enable(plate, unit)
    ApplyShown(plate)
    self:Update(plate, unit)
end

function HealthText:Disable(plate)
    plate.healthText:Hide()
end

function HealthText:UpdateEmphasis(plate)
    ApplyShown(plate)
end

function HealthText:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

local function Value(s, number)
    return AbbreviateNumbers(number, s.abbreviate)
end

function HealthText:Update(plate, unit)
    local text = plate.healthText
    local s = settings[plate.state]
    local mode = s.mode
    if mode == "value" then
        text:SetText(Value(s, UnitHealth(unit)))
    elseif mode == "both" then
        text:SetFormattedText(s.bothFormat, Value(s, UnitHealth(unit)), UnitHealthPercent(unit, false, ScaleTo100))
    elseif mode == "paren" then
        text:SetFormattedText(s.parenFormat, Value(s, UnitHealth(unit)), UnitHealthPercent(unit, false, ScaleTo100))
    elseif mode == "percentFirst" then
        text:SetFormattedText(s.percentFirstFormat, UnitHealthPercent(unit, false, ScaleTo100), Value(s, UnitHealth(unit)))
    elseif mode == "valueMax" then
        text:SetFormattedText("%s / %s", Value(s, UnitHealth(unit)), Value(s, UnitHealthMax(unit)))
    elseif mode == "missing" then
        text:SetFormattedText("-%s", Value(s, UnitHealthMissing(unit, false)))
    elseif mode == "missingPercent" and missingCurve then
        text:SetFormattedText(s.missingPercentFormat, UnitHealthPercent(unit, false, missingCurve))
    else
        text:SetFormattedText(s.percentFormat, UnitHealthPercent(unit, false, ScaleTo100))
    end
    if s.hideFull then
        text:SetAlpha(UnitHealthPercent(unit, false, fullCurve))
    else
        text:SetAlpha(1)
    end
    if s.curve then
        local color = UnitHealthPercent(unit, false, s.curve)
        text:SetTextColor(color.r, color.g, color.b, color.a)
    end
end

function HealthText:Preview(plate, state)
    local text = plate.healthText
    local health = state.health
    local percent = health * 100
    local value = health * state.maxHealth
    local s = settings[plate.state]
    local mode = s.mode
    if mode == "value" then
        text:SetText(Value(s, value))
    elseif mode == "both" then
        text:SetFormattedText(s.bothFormat, Value(s, value), percent)
    elseif mode == "paren" then
        text:SetFormattedText(s.parenFormat, Value(s, value), percent)
    elseif mode == "percentFirst" then
        text:SetFormattedText(s.percentFirstFormat, percent, Value(s, value))
    elseif mode == "valueMax" then
        text:SetFormattedText("%s / %s", Value(s, value), Value(s, state.maxHealth))
    elseif mode == "missing" then
        text:SetFormattedText("-%s", Value(s, state.maxHealth - value))
    elseif mode == "missingPercent" then
        text:SetFormattedText(s.missingPercentFormat, 100 - percent)
    else
        text:SetFormattedText(s.percentFormat, percent)
    end
    text:SetAlpha((s.hideFull and health >= 0.9999) and 0 or 1)
    if s.curve then
        local color = ColorAt(s, health)
        text:SetTextColor(color[1], color[2], color[3], color[4])
    end
    text:Show()
end

ns.Driver:RegisterElement(HealthText)
