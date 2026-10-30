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
    fullCurve = ns.StepCurve(0, 1, 0.9999, 0)
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

local function ColorKey(color)
    return ("%.4f,%.4f,%.4f,%.4f"):format(color[1], color[2], color[3], color[4] or 1)
end

local function CurveKey(db, executeOn, threshold)
    local key = executeOn and ("x" .. threshold .. ":" .. ColorKey(db.executeTextColor)) or "-"
    if db.colorByHealth then
        return key .. "|g:" .. ColorKey(db.colorLow) .. ":" .. ColorKey(db.colorMid) .. ":" .. ColorKey(db.colorHigh)
    end
    return key .. "|c:" .. ColorKey(db.color)
end

function HealthText:Create(plate)
    plate.healthText = ns.CreateText(plate.overlay)
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
        local key = CurveKey(db, s.executeOn, s.threshold)
        if s.curveKey ~= key or not s.curve then
            s.curveKey = key
            s.curve = ColorCurve(db, s.executeOn, s.threshold)
        end
    else
        s.curve, s.curveKey = nil, nil
    end
end

function HealthText:Style(plate, db)
    local text = plate.healthText
    ns.FontText(text, db)
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

local function Value(s, number)
    return AbbreviateNumbers(number, s.abbreviate)
end

local function Write(text, s, from, source)
    local mode = s.mode
    if mode == "value" then
        text:SetText(Value(s, from.Health(source)))
    elseif mode == "both" then
        text:SetFormattedText(s.bothFormat, Value(s, from.Health(source)), from.Percent(source))
    elseif mode == "paren" then
        text:SetFormattedText(s.parenFormat, Value(s, from.Health(source)), from.Percent(source))
    elseif mode == "percentFirst" then
        text:SetFormattedText(s.percentFirstFormat, from.Percent(source), Value(s, from.Health(source)))
    elseif mode == "valueMax" then
        text:SetFormattedText("%s / %s", Value(s, from.Health(source)), Value(s, from.Max(source)))
    elseif mode == "missing" then
        text:SetFormattedText("-%s", Value(s, from.Missing(source)))
    elseif mode == "missingPercent" and from.MissingPercent then
        text:SetFormattedText(s.missingPercentFormat, from.MissingPercent(source))
    else
        text:SetFormattedText(s.percentFormat, from.Percent(source))
    end
end

local LIVE = {
    Health = function(unit) return UnitHealth(unit) end,
    Max = function(unit) return UnitHealthMax(unit) end,
    Missing = function(unit) return UnitHealthMissing(unit, false) end,
    Percent = function(unit) return UnitHealthPercent(unit, false, ScaleTo100) end,
    MissingPercent = missingCurve and function(unit) return UnitHealthPercent(unit, false, missingCurve) end,
}

local SAMPLE = {
    Health = function(state) return state.health * state.maxHealth end,
    Max = function(state) return state.maxHealth end,
    Missing = function(state) return state.maxHealth - state.health * state.maxHealth end,
    Percent = function(state) return state.health * 100 end,
    MissingPercent = function(state) return 100 - state.health * 100 end,
}

function HealthText:Update(plate, unit)
    local text = plate.healthText
    local s = settings[plate.state]
    Write(text, s, LIVE, unit)
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
    local s = settings[plate.state]
    Write(text, s, SAMPLE, state)
    text:SetAlpha((s.hideFull and health >= 0.9999) and 0 or 1)
    if s.curve then
        local color = ColorAt(s, health)
        text:SetTextColor(color[1], color[2], color[3], color[4])
    end
    text:Show()
end

ns.Driver:RegisterElement(HealthText)
