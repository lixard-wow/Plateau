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
    plate.forces = ns.CreateText(plate.overlay)
end

function Forces:Configure(db, state)
    formats[state] = FORMATS[db.format] or FORMATS.percent
end

function Forces:Style(plate, db)
    ns.StyleText(plate.forces, db, plate)
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
