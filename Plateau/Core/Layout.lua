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
    local width, height = Size(region)
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

function ns.StepCurve(...)
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    for i = 1, select("#", ...), 2 do
        curve:AddPoint(select(i, ...), (select(i + 1, ...)))
    end
    return curve
end

function ns.NewSecondsFormatter(millisecondsThreshold)
    local formatter = C_StringUtil.CreateSecondsFormatter()
    formatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
    formatter:SetStripIntervalWhitespace(Enum.SecondsFormatterIntervalWhitespace.Strip)
    formatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
    formatter:SetMaxInterval(Enum.SecondsFormatterInterval.Minutes)
    formatter:SetDesiredUnitCount(1)
    if millisecondsThreshold then
        formatter:SetMillisecondsThreshold(millisecondsThreshold)
    end
    return formatter
end

function ns.Readable(value)
    if issecretvalue(value) then return nil end
    return value
end

local atlasExists = {}

function ns.AtlasExists(atlas)
    local exists = atlasExists[atlas]
    if exists == nil then
        exists = C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil and C_Texture.GetAtlasInfo(atlas) ~= nil
        atlasExists[atlas] = exists
    end
    return exists
end

function ns.StyleIcon(icon, plate, db)
    ns.SizeIcon(icon, db.size)
    icon:SetAlpha(db.alpha)
    ns.HoldIcon(plate, icon, db)
end

local PACK_SPACING = 2
local PACKED = { "raidMarker", "classification", "quest", "faction" }
local groups = {}

local function BaseCenter(icon, plateWidth, plateHeight)
    local base = icon.plBase
    if not base then return nil end
    local width, height = Size(icon)
    if not width then return nil end
    local position = ns.iconPositions[base[1]] or ns.iconPositions.LEFT
    local x = Across(position[2], plateWidth) + position[3] * base[2] + base[3] - Across(position[1], width) + width / 2
    local y = Down(position[2], plateHeight) + position[4] * base[2] + base[4] - Down(position[1], height) - height / 2
    return x, y, width, height
end

local function Direction(icon)
    local point = (ns.iconPositions[icon.plBase[1]] or ns.iconPositions.LEFT)[1]
    if point:find("RIGHT") then return -1 end
    if point:find("LEFT") then return 1 end
    return 0
end

local function PackGroup(plate, group)
    local leader, total, shown = nil, 0, 0
    for i = 1, group.n do
        local icon = group[i]
        if icon:IsShown() then
            leader = leader or icon
            shown = shown + 1
            total = total + (Size(icon))
        end
    end
    total = total + PACK_SPACING * math.max(0, shown - 1)
    local direction = leader and Direction(leader) or 0
    local cursor = direction == 0 and -total / 2 or 0
    for i = 1, group.n do
        local icon = group[i]
        if leader and icon:IsShown() then
            local width = (Size(icon))
            local shift = direction > 0 and cursor or direction < 0 and -cursor or cursor + width / 2
            cursor = cursor + width + PACK_SPACING
            local base = leader.plBase
            ns.PlaceIcon(icon, plate, base[1], base[2], base[3] + shift, base[4])
        else
            local base = icon.plBase
            ns.PlaceIcon(icon, plate, base[1], base[2], base[3], base[4])
        end
    end
end

function ns.PackIcons(plate)
    local plateWidth, plateHeight = Size(plate)
    plateWidth, plateHeight = plateWidth or plate.rawWidth, plateHeight or plate.rawHeight
    if not plateWidth then return end
    local count = 0
    for _, key in ipairs(PACKED) do
        local icon = plate[key]
        local x, y, width, height
        if icon then
            x, y, width, height = BaseCenter(icon, plateWidth, plateHeight)
        end
        if x then
            local group
            for i = 1, count do
                local other = groups[i]
                if math.abs(other.x - x) <= math.min(other.width, width) / 2 and math.abs(other.y - y) <= math.min(other.height, height) / 2 then
                    group = other
                    break
                end
            end
            if not group then
                count = count + 1
                group = groups[count] or {}
                groups[count] = group
                group.x, group.y, group.width, group.height, group.n = x, y, width, height, 0
            end
            group.n = group.n + 1
            group[group.n] = icon
        end
    end
    for i = 1, count do
        PackGroup(plate, groups[i])
    end
end

function ns.HoldIcon(plate, icon, db)
    local base = icon.plBase or {}
    icon.plBase = base
    base[1], base[2], base[3], base[4] = db.position, db.gap, db.offsetX, db.offsetY
    ns.PackIcons(plate)
end

local Evaluate = C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean

function ns.PickColor(flag, r1, g1, b1, a1, r2, g2, b2, a2)
    return Evaluate(flag, r1, r2), Evaluate(flag, g1, g2), Evaluate(flag, b1, b2), Evaluate(flag, a1, a2)
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
