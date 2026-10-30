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
    LEFTTOP = { "TOPRIGHT", "TOPLEFT", -1, 0 },
    LEFTBOTTOM = { "BOTTOMRIGHT", "BOTTOMLEFT", -1, 0 },
    RIGHTTOP = { "TOPLEFT", "TOPRIGHT", 1, 0 },
    RIGHTBOTTOM = { "BOTTOMLEFT", "BOTTOMRIGHT", 1, 0 },
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
    if region.plPlaceAnchor == anchor and region.plPlaceKey == key and region.plPlaceGap == gap
        and region.plPlaceX == x and region.plPlaceY == y then
        return
    end
    region.plPlaceAnchor, region.plPlaceKey, region.plPlaceGap, region.plPlaceX, region.plPlaceY = anchor, key, gap, x, y
    local position = ns.iconPositions[key] or ns.iconPositions.LEFT
    region:ClearAllPoints()
    region:SetPoint(position[1], anchor, position[2], position[3] * gap + x, position[4] * gap + y)
end

function ns.PlaceText(text, anchor, key, gap, x, y)
    if text.plPlaceAnchor == anchor and text.plPlaceKey == key and text.plPlaceGap == gap
        and text.plPlaceX == x and text.plPlaceY == y then
        return
    end
    text.plPlaceAnchor, text.plPlaceKey, text.plPlaceGap, text.plPlaceX, text.plPlaceY = anchor, key, gap, x, y
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
