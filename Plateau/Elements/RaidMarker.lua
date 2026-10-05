local _, ns = ...

local GetRaidTargetIndex = GetRaidTargetIndex
local type = type

local ICON_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcons"
local ROWS = RAID_TARGET_TEXTURE_ROWS or 4
local COLUMNS = RAID_TARGET_TEXTURE_COLUMNS or 4

local MARKER_COLORS = "Interface\\AddOns\\Plateau\\Art\\Indicators\\marker-colors"

local tint = {}

local RaidMarker = {
    key = "raidMarker",
    events = {},
    globalEvents = { "RAID_TARGET_UPDATE" },
    nameOnly = true,
}
ns.Elements = ns.Elements or {}
ns.Elements.RaidMarker = RaidMarker

function RaidMarker:Create(plate)
    local layer = CreateFrame("Frame", nil, plate.overlay)
    layer:SetAllPoints()
    layer:SetFrameLevel(plate.overlay:GetFrameLevel() + 5)
    local icon = layer:CreateTexture(nil, "OVERLAY")
    icon:SetTexture(ICON_TEXTURE)
    icon:Hide()
    plate.raidMarker = icon
    plate.markerRing = ns.CreateBorder(plate, plate, "BACKGROUND", -8)
    plate.markerRing:Hide()
end

function RaidMarker:Configure(db, state)
    tint[state] = db.tintBorder == true and db.tintSize or nil
end

local function ShowRing(plate, index)
    local ring = plate.markerRing
    if not tint[plate.state] or type(index) == "nil" or plate.isTarget or plate.isFocus or plate.nameOnly then
        ring:Hide()
        return
    end
    ring:SetSpriteCell(MARKER_COLORS, index, ROWS, COLUMNS)
    ring:Show()
end

function RaidMarker:Style(plate, db)
    local icon = plate.raidMarker
    icon:SetSize(db.size, db.size)
    icon:SetAlpha(db.alpha)
    ns.PlaceIcon(icon, plate, db.position, db.gap, db.offsetX, db.offsetY)
    plate.markerRing:Layout(db.tintSize or 2, ns.HealthBorderOffset(ns.DB.views[plate.state]))
end

function RaidMarker:Enable(plate, unit)
    self:Update(plate, unit)
end

function RaidMarker:Disable(plate)
    plate.raidMarker:Hide()
    plate.markerRing:Hide()
    plate.markerIndex = nil
end

function RaidMarker:UpdateEmphasis(plate)
    ShowRing(plate, plate.markerIndex)
end

function RaidMarker:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

function RaidMarker:Update(plate, unit)
    local icon = plate.raidMarker
    local index = GetRaidTargetIndex(unit)
    plate.markerIndex = index
    if type(index) == "nil" then
        icon:Hide()
        plate.markerRing:Hide()
        return
    end
    icon:SetSpriteSheetCell(index, ROWS, COLUMNS)
    icon:Show()
    ShowRing(plate, index)
end

function RaidMarker:Preview(plate, state)
    local icon = plate.raidMarker
    if state.raidMarker then
        icon:SetSpriteSheetCell(state.raidMarker, ROWS, COLUMNS)
        icon:Show()
    else
        icon:Hide()
    end
    plate.markerIndex = state.raidMarker
    ShowRing(plate, state.raidMarker)
end

ns.Driver:RegisterElement(RaidMarker)
