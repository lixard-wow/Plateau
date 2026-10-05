local _, ns = ...

local UnitClassification = UnitClassification

local ATLASES = {
    elite = "nameplates-icon-elite-gold",
    worldboss = "nameplates-icon-elite-gold",
    rareelite = "nameplates-icon-elite-silver",
    rare = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Rare-Star",
}

local shownBy = {}

local Classification = {
    key = "classification",
    events = { "UNIT_CLASSIFICATION_CHANGED" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Classification = Classification

function Classification:Create(plate)
    local icon = plate.overlay:CreateTexture(nil, "OVERLAY")
    icon:Hide()
    plate.classification = icon
end

function Classification:Configure(db, state)
    local shown = shownBy[state] or {}
    shownBy[state] = shown
    shown.elite = db.showElite
    shown.worldboss = db.showBoss
    shown.rareelite = db.showRareElite
    shown.rare = db.showRare
end

function Classification:Style(plate, db)
    local icon = plate.classification
    icon:SetSize(db.size, db.size)
    icon:SetAlpha(db.alpha)
    ns.PlaceIcon(icon, plate, db.position, db.gap, db.offsetX, db.offsetY)
end

function Classification:Enable(plate, unit)
    self:Update(plate, unit)
end

function Classification:Disable(plate)
    plate.classificationAtlas = nil
    plate.classification:Hide()
end

function Classification:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

function Classification:Update(plate, unit)
    self:Render(plate, UnitClassification(unit))
end

function Classification:Preview(plate, state)
    self:Render(plate, state.classification)
end

function Classification:Render(plate, classification)
    local icon = plate.classification
    local atlas = shownBy[plate.state][classification] and ATLASES[classification]
    if atlas and plate.state == "friendly" and not ns.DB.views.enemy.friendly.classificationEnabled then
        atlas = nil
    end
    if plate.classificationAtlas == atlas then return end
    plate.classificationAtlas = atlas
    if atlas then
        icon:SetAtlas(atlas)
        icon:Show()
    else
        icon:Hide()
    end
end

ns.Driver:RegisterElement(Classification)
