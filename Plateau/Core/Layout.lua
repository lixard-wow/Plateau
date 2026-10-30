local _, ns = ...

local issecretvalue = issecretvalue
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

local function Size(frame)
    local width, height = frame:GetWidth(), frame:GetHeight()
    if type(width) ~= "number" or type(height) ~= "number" or (issecretvalue and (issecretvalue(width) or issecretvalue(height))) then
        return nil
    end
    return width, height
end

local function Across(point, width)
    if point:find("LEFT") then return 0 end
    if point:find("RIGHT") then return width end
    return width / 2
end

local function Down(point, height)
    if point:find("TOP") then return 0 end
    if point:find("BOTTOM") then return -height end
    return -height / 2
end

function ns.PlaceAt(region, anchor, point, relative, x, y)
    local width, height = Size(region)
    local anchorWidth, anchorHeight = Size(anchor)
    region:ClearAllPoints()
    if not ns.pixelPerfect or not width or not anchorWidth or region.GetStringWidth then
        region:SetPoint(point, anchor, relative, x, y)
        return
    end
    local pixel = ns.PixelUnit(region)
    local baseX, baseY = Across(relative, anchorWidth), Down(relative, anchorHeight)
    local left = ns.Snap(baseX + x - Across(point, width), pixel) - baseX
    local top = ns.Snap(baseY + y - Down(point, height), pixel) - baseY
    region:SetPoint("TOPLEFT", anchor, relative, left, top)
end

function ns.PlaceIcon(region, anchor, key, gap, x, y)
    local width, height = region:GetWidth(), region:GetHeight()
    if region.plPlaceAnchor == anchor and region.plPlaceKey == key and region.plPlaceGap == gap
        and region.plPlaceX == x and region.plPlaceY == y and region.plPlaceW == width and region.plPlaceH == height then
        return
    end
    region.plPlaceAnchor, region.plPlaceKey, region.plPlaceGap, region.plPlaceX, region.plPlaceY = anchor, key, gap, x, y
    region.plPlaceW, region.plPlaceH = width, height
    local position = ns.iconPositions[key] or ns.iconPositions.LEFT
    ns.PlaceAt(region, anchor, position[1], position[2], position[3] * gap + x, position[4] * gap + y)
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

function ns.CreateText(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    return text
end

function ns.FontText(text, db)
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
end

function ns.StyleText(text, db, anchor)
    ns.FontText(text, db)
    text:SetTextColor(db.color[1], db.color[2], db.color[3], db.color[4])
    text:SetAlpha(db.alpha)
    ns.PlaceIcon(text, anchor, db.position, db.gap, db.offsetX, db.offsetY)
end

function ns.ClassColor(class, allowSecret)
    if class == nil then return nil end
    if not issecretvalue(class) then
        return RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] or nil
    end
    if not allowSecret or not (C_ClassColor and C_ClassColor.GetClassColor) then return nil end
    local ok, color = pcall(C_ClassColor.GetClassColor, class)
    return ok and color or nil
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
