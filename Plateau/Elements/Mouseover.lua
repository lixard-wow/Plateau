local _, ns = ...

local settings = {}

local Mouseover = {
    key = "mouseover",
}
ns.Elements = ns.Elements or {}
ns.Elements.Mouseover = Mouseover

function Mouseover:Create(plate)
    plate.hoverRing = ns.CreateBorder(plate, plate, "BACKGROUND", -4)
    plate.hoverRing:Hide()
    plate.hoverGlow = ns.CreateBorder(plate, plate, "BACKGROUND", -7)
    plate.hoverGlow:Hide()
    plate.hoverWash = ns.CreateWash(plate, 6)
end

function Mouseover:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.ring = db.ring
    s.brighten = db.brighten
    s.glow = db.glow == true
    s.skipFriendly = db.skipFriendly == true
end

function Mouseover:Style(plate, db)
    ns.StyleRingGlow(plate.hoverRing, plate.hoverGlow, db, ns.HealthBorderOffset(ns.DB.views[plate.state]))
    ns.FitWash(plate.hoverWash, plate.health)
    plate.hoverWash:SetAlpha(db.brightenAmount)
end

function Mouseover:Enable(plate)
    self:SetMouseover(plate, plate.isMouseover)
end

function Mouseover:Disable(plate)
    plate.hoverRing:Hide()
    plate.hoverWash:Hide()
    plate.hoverGlow:Hide()
end

function Mouseover:SetMouseover(plate, hovered)
    local s = settings[plate.state]
    if s.skipFriendly and plate.isFriendly then
        hovered = false
    end
    plate.hoverRing:SetShown(hovered and s.ring or false)
    plate.hoverWash:SetShown(hovered and s.brighten or false)
    plate.hoverGlow:SetShown(hovered and s.glow or false)
end

function Mouseover:Preview(plate, state)
    self:SetMouseover(plate, state.mouseover == true)
end

ns.Driver:RegisterElement(Mouseover)
