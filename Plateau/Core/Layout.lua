local _, ns = ...

ns.iconPositions = {
    TOP = { "BOTTOM", "TOP", 0, 1 },
    BOTTOM = { "TOP", "BOTTOM", 0, -1 },
    LEFT = { "RIGHT", "LEFT", -1, 0 },
    RIGHT = { "LEFT", "RIGHT", 1, 0 },
    CENTER = { "CENTER", "CENTER", 0, 0 },
    TOPLEFT = { "BOTTOMLEFT", "TOPLEFT", 0, 1 },
    TOPRIGHT = { "BOTTOMRIGHT", "TOPRIGHT", 0, 1 },
    BOTTOMLEFT = { "TOPLEFT", "BOTTOMLEFT", 0, -1 },
    BOTTOMRIGHT = { "TOPRIGHT", "BOTTOMRIGHT", 0, -1 },
    INSIDELEFT = { "LEFT", "LEFT", 1, 0 },
    INSIDERIGHT = { "RIGHT", "RIGHT", -1, 0 },
}

ns.textPositions = {
    LEFT = { "LEFT", "LEFT", 1, 0, "LEFT" },
    CENTER = { "CENTER", "CENTER", 0, 0, "CENTER" },
    RIGHT = { "RIGHT", "RIGHT", -1, 0, "RIGHT" },
    TOP = { "BOTTOM", "TOP", 0, 1, "CENTER" },
    BOTTOM = { "TOP", "BOTTOM", 0, -1, "CENTER" },
    TOPLEFT = { "BOTTOMLEFT", "TOPLEFT", 0, 1, "LEFT" },
    TOPRIGHT = { "BOTTOMRIGHT", "TOPRIGHT", 0, 1, "RIGHT" },
    BOTTOMLEFT = { "TOPLEFT", "BOTTOMLEFT", 0, -1, "LEFT" },
    BOTTOMRIGHT = { "TOPRIGHT", "BOTTOMRIGHT", 0, -1, "RIGHT" },
    INSIDETOPLEFT = { "TOPLEFT", "TOPLEFT", 1, -1, "LEFT" },
    INSIDETOPRIGHT = { "TOPRIGHT", "TOPRIGHT", -1, -1, "RIGHT" },
    INSIDEBOTTOMLEFT = { "BOTTOMLEFT", "BOTTOMLEFT", 1, 1, "LEFT" },
    INSIDEBOTTOMRIGHT = { "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1, "RIGHT" },
    OUTSIDELEFT = { "RIGHT", "LEFT", -1, 0, "RIGHT" },
    OUTSIDERIGHT = { "LEFT", "RIGHT", 1, 0, "LEFT" },
}

function ns.PlaceIcon(region, anchor, key, gap, x, y)
    if region.slPlaceAnchor == anchor and region.slPlaceKey == key and region.slPlaceGap == gap
        and region.slPlaceX == x and region.slPlaceY == y then
        return
    end
    region.slPlaceAnchor, region.slPlaceKey, region.slPlaceGap, region.slPlaceX, region.slPlaceY = anchor, key, gap, x, y
    local position = ns.iconPositions[key] or ns.iconPositions.LEFT
    region:ClearAllPoints()
    region:SetPoint(position[1], anchor, position[2], position[3] * gap + x, position[4] * gap + y)
end

function ns.PlaceText(text, anchor, key, gap, x, y)
    if text.slPlaceAnchor == anchor and text.slPlaceKey == key and text.slPlaceGap == gap
        and text.slPlaceX == x and text.slPlaceY == y then
        return
    end
    text.slPlaceAnchor, text.slPlaceKey, text.slPlaceGap, text.slPlaceX, text.slPlaceY = anchor, key, gap, x, y
    local position = ns.textPositions[key] or ns.textPositions.CENTER
    text:ClearAllPoints()
    text:SetPoint(position[1], anchor, position[2], position[3] * gap + x, position[4] * gap + y)
    text:SetJustifyH(position[5])
end

local FOREIGN_SUFFIX = ((FOREIGN_SERVER_LABEL or " (*)"):gsub("%p", "%%%0")) .. "$"

function ns.CleanName(name)
    if type(name) == "string" and not issecretvalue(name) then
        return (name:gsub(FOREIGN_SUFFIX, ""))
    end
    return name
end

function ns.MarkerLayer(plate)
    local layer = plate.markerLayer
    if not layer then
        layer = CreateFrame("Frame", nil, plate.health)
        layer:SetAllPoints()
        layer:SetFrameLevel(plate.health:GetFrameLevel() + 3)
        plate.markerLayer = layer
    end
    return layer
end
