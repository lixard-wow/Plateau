local _, ns = ...

local GetUnitCriteriaProgressValues = C_ScenarioInfo and C_ScenarioInfo.GetUnitCriteriaProgressValues
local IsChallengeModeActive = C_PartyInfo and C_PartyInfo.IsChallengeModeActive
local select = select

local FORMATS = {
    percent = "%3$s%%",
    count = "%1$s",
    both = "%1$s (%3$s%%)",
}

local formats = {}

local Forces = {
    key = "forces",
    globalEvents = { "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Forces = Forces

function Forces:Create(plate)
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.forces = text
end

function Forces:Configure(db, state)
    formats[state] = FORMATS[db.format] or FORMATS.percent
end

function Forces:Style(plate, db)
    local text = plate.forces
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
    text:SetTextColor(db.color[1], db.color[2], db.color[3], db.color[4])
    text:SetAlpha(db.alpha)
    ns.PlaceIcon(text, plate, db.position, db.gap, db.offsetX, db.offsetY)
end

function Forces:Enable(plate, unit)
    self:Update(plate, unit)
end

function Forces:Disable(plate)
    plate.forces:Hide()
end

function Forces:OnEvent(plate, _, unit)
    self:Update(plate, plate.unit or unit)
end

function Forces:Update(plate, unit)
    if not (GetUnitCriteriaProgressValues and IsChallengeModeActive and unit) or plate.isPlayer or plate.isFriendly or not IsChallengeModeActive() then
        plate.forces:Hide()
        return
    end
    self:Render(plate, GetUnitCriteriaProgressValues(unit))
end

function Forces:Render(plate, ...)
    local text = plate.forces
    if select("#", ...) == 0 then
        text:Hide()
        return
    end
    text:SetFormattedText(formats[plate.state], ...)
    text:Show()
end

function Forces:Preview(plate, state)
    if state.forces then
        self:Render(plate, state.forces.count, state.forces.percent, state.forces.text)
    else
        plate.forces:Hide()
    end
end

ns.Driver:RegisterElement(Forces)
