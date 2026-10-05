local _, ns = ...

local CreateFrame = CreateFrame
local UnitHealthPercent = UnitHealthPercent
local FLAT = "Interface\\Buttons\\WHITE8X8"

local settings = {}

local Execute = {
    key = "execute",
    sizeDependent = true,
    events = { "UNIT_HEALTH", "UNIT_MAXHEALTH" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Execute = Execute

local function StepCurve(threshold)
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, 1)
    curve:AddPoint(threshold / 100, 0)
    return curve
end

function Execute:Create(plate)
    local layer = CreateFrame("Frame", nil, plate.health)
    layer:SetAllPoints()
    layer:SetFrameLevel(plate.health:GetFrameLevel() + 2)
    local overlay = layer:CreateTexture(nil, "ARTWORK")
    overlay:SetTexture(FLAT)
    overlay:SetAlpha(0)
    plate.executeOverlay = overlay

    plate.thresholdLines = {}
    for i = 1, 2 do
        local line = ns.MarkerLayer(plate):CreateTexture(nil, "OVERLAY", nil, 1)
        line:Hide()
        plate.thresholdLines[i] = line
    end
end

function Execute:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.highlight = db.highlight
    if s.threshold ~= db.threshold then
        s.threshold = db.threshold
        s.curve = StepCurve(db.threshold)
    end
end

function Execute:Style(plate, db)
    local overlay = plate.executeOverlay
    overlay:SetShown(settings[plate.state].highlight == true)
    overlay:ClearAllPoints()
    overlay:SetAllPoints(plate.health:GetStatusBarTexture())
    overlay:SetVertexColor(db.color[1], db.color[2], db.color[3], db.color[4])

    local width = plate:GetWidth()
    local reverse = ns.DB.views[plate.state].health.fillDirection == "right"
    local side = reverse and "RIGHT" or "LEFT"
    local direction = reverse and -1 or 1
    local lines = plate.thresholdLines
    for i = 1, 2 do
        local percent = i == 1 and db.line1 or db.line2
        local line = lines[i]
        line:ClearAllPoints()
        line:SetColorTexture(db.lineColor[1], db.lineColor[2], db.lineColor[3], db.lineColor[4])
        line:SetWidth(db.lineWidth)
        line:SetPoint("TOP", plate.health, "TOP" .. side, direction * width * percent / 100, 0)
        line:SetPoint("BOTTOM", plate.health, "BOTTOM" .. side, direction * width * percent / 100, 0)
        line:SetShown(db.lines and percent > 0 and percent < 100)
    end
end

function Execute:Enable(plate, unit)
    self:Update(plate, unit)
end

function Execute:Disable(plate)
    plate.executeOverlay:SetAlpha(0)
    for _, line in ipairs(plate.thresholdLines) do
        line:Hide()
    end
end

function Execute:OnEvent(plate, _, unit)
    if not settings[plate.state].highlight then return end
    self:Update(plate, unit)
end

function Execute:Update(plate, unit)
    local s = settings[plate.state]
    if s.highlight then
        plate.executeOverlay:SetAlpha(UnitHealthPercent(unit, false, s.curve))
    else
        plate.executeOverlay:SetAlpha(0)
    end
end

function Execute:Preview(plate, state)
    local s = settings[plate.state]
    plate.executeOverlay:SetShown(s.highlight == true)
    plate.executeOverlay:SetAlpha((s.highlight and state.health * 100 < s.threshold) and 1 or 0)
end

ns.Driver:RegisterElement(Execute)
