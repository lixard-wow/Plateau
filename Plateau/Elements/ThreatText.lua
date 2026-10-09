local _, ns = ...

local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local issecretvalue = issecretvalue
local pcall = pcall

local FORMAT = "%.0f%%"

local hideZero = {}

local ThreatText = {
    key = "threatText",
    events = { "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE" },
}
ns.Elements = ns.Elements or {}
ns.Elements.ThreatText = ThreatText

function ThreatText:Create(plate)
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.threatText = text
end

function ThreatText:Configure(db, state)
    hideZero[state] = db.hideZero ~= false
end

function ThreatText:Style(plate, db)
    local text = plate.threatText
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
    text:SetTextColor(db.color[1], db.color[2], db.color[3], db.color[4])
    text:SetAlpha(db.alpha)
    ns.PlaceIcon(text, plate, db.position, db.gap, db.offsetX, db.offsetY)
end

function ThreatText:Enable(plate, unit)
    self:Update(plate, unit)
end

function ThreatText:Disable(plate)
    plate.threatText:Hide()
end

function ThreatText:OnEvent(plate, _, unit)
    self:Update(plate, plate.unit or unit)
end

function ThreatText:Update(plate, unit)
    local text = plate.threatText
    if not (UnitDetailedThreatSituation and unit) or plate.isPlayer or plate.isFriendly then
        text:Hide()
        return
    end
    local ok, _, _, scaled = pcall(UnitDetailedThreatSituation, "player", unit)
    if not ok then
        text:Hide()
        return
    end
    if issecretvalue(scaled) then
        text:SetShown(pcall(text.SetFormattedText, text, FORMAT, scaled))
        return
    end
    if not scaled or (hideZero[plate.state] and scaled <= 0) then
        text:Hide()
        return
    end
    text:SetFormattedText(FORMAT, scaled)
    text:Show()
end

function ThreatText:Preview(plate, state)
    local text = plate.threatText
    if state.isPlayer or state.isFriendly then
        text:Hide()
        return
    end
    text:SetFormattedText(FORMAT, 87)
    text:Show()
end

ns.Driver:RegisterElement(ThreatText)
