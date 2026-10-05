local _, ns = ...

local BRIGHTEN_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"

local settings = {}

local Mouseover = {
    key = "mouseover",
    events = {},
}
ns.Elements = ns.Elements or {}
ns.Elements.Mouseover = Mouseover

function Mouseover:Create(plate)
    plate.hoverRing = ns.CreateBorder(plate, plate, "BACKGROUND", -8)
    plate.hoverRing:Hide()
    plate.hoverGlow = ns.CreateBorder(plate, plate, "BACKGROUND", -8)
    plate.hoverGlow:Hide()
    local wash = plate.health:CreateTexture(nil, "ARTWORK", nil, 6)
    wash:SetTexture(BRIGHTEN_TEXTURE)
    wash:SetBlendMode("ADD")
    wash:Hide()
    plate.hoverWash = wash
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
    local look = ns.DB.views[plate.state]
    plate.hoverRing:Layout(db.ringSize, ns.HealthBorderOffset(look))
    plate.hoverRing:SetColor(db.ringColor[1], db.ringColor[2], db.ringColor[3], db.ringColor[4])
    plate.hoverGlow:Layout(db.glowSize, ns.HealthBorderOffset(look))
    plate.hoverGlow:SetFade(db.glowColor[1], db.glowColor[2], db.glowColor[3], db.glowColor[4])
    plate.hoverWash:ClearAllPoints()
    plate.hoverWash:SetAllPoints(plate.health:GetStatusBarTexture())
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

function Mouseover:OnEvent()
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
