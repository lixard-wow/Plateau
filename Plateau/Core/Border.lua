local addonName, ns = ...

local Border = {}
Border.__index = Border

local CORNER = "Interface\\AddOns\\" .. addonName .. "\\Art\\glow-corner"
local CORNERS = {
    { point = "BOTTOMRIGHT", relative = "TOPLEFT", x = -1, y = 1, coords = { 0, 1, 0, 1 } },
    { point = "BOTTOMLEFT", relative = "TOPRIGHT", x = 1, y = 1, coords = { 1, 0, 0, 1 } },
    { point = "TOPRIGHT", relative = "BOTTOMLEFT", x = -1, y = -1, coords = { 0, 1, 1, 0 } },
    { point = "TOPLEFT", relative = "BOTTOMRIGHT", x = 1, y = -1, coords = { 1, 0, 1, 0 } },
}

local function Faded(self)
    return self.fade and (self.style == nil or self.style == "shadow")
end

local function CornersShown(self, shown)
    if self.corners then
        for i = 1, 4 do
            self.corners[i]:SetShown(shown)
        end
    end
end

local function PlaceCorners(self, size, offset)
    local corners = self.corners
    if not corners then return end
    for i, info in ipairs(CORNERS) do
        local corner = corners[i]
        corner:ClearAllPoints()
        corner:SetPoint(info.point, self.anchor, info.relative, info.x * offset, info.y * offset)
        corner:SetSize(size, size)
    end
end

local function Thickness(edge, horizontal, size)
    if horizontal then
        edge:SetHeight(size)
    else
        edge:SetWidth(size)
    end
end

local TOOLTIP_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border"

local EDGE_STYLES = {
    tooltip = { file = TOOLTIP_EDGE, base = 10, step = 2 },
    thinTooltip = { file = TOOLTIP_EDGE, base = 6, step = 2 },
}

local SHADOW_STEP = 3

function ns.CreateBorder(owner, anchor, layer, sublevel)
    local border = setmetatable({ owner = owner, anchor = anchor, edges = {} }, Border)
    for i = 1, 4 do
        local edge = owner:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
        edge:SetSnapToPixelGrid(true)
        edge:SetTexelSnappingBias(0)
        border.edges[i] = edge
    end
    return border
end

function Border:SetAnchor(anchor)
    self.anchor = anchor
end

function ns.HealthBorderOffset(look)
    if look.health.borderStyle == "none" then
        return 0
    end
    return look.health.borderInside and 0 or look.health.borderSize
end

function Border:SetStyle(style, levelAbove)
    self.style = style
    self.levelAbove = levelAbove
end

local function EdgeInfo(style)
    if not style or style == "pixel" or style == "shadow" then return nil end
    return EDGE_STYLES[style] or { file = style, base = 8, step = 2 }
end

function Border:LayoutEdge(info, size, inside)
    local frame = self.edgeFrame
    if not frame then
        frame = CreateFrame("Frame", nil, self.owner, "BackdropTemplate")
        frame:EnableMouse(false)
        self.edgeFrame = frame
    end
    local above = self.levelAbove or self.owner
    frame:SetFrameLevel(above:GetFrameLevel() + 1)
    local edgeSize = info.base + info.step * size
    local pad = inside and 0 or math.floor(edgeSize / 3 + 0.5)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", self.anchor, "TOPLEFT", -pad, pad)
    frame:SetPoint("BOTTOMRIGHT", self.anchor, "BOTTOMRIGHT", pad, -pad)
    if self.edgeFile ~= info.file or self.edgeSize ~= edgeSize then
        self.edgeFile, self.edgeSize = info.file, edgeSize
        frame:SetBackdrop({ edgeFile = info.file, edgeSize = edgeSize })
    end
    if self.color then
        frame:SetBackdropBorderColor(self.color[1], self.color[2], self.color[3], self.color[4])
    end
end

local MIN_PIXEL_SCALE = 0.2

function Border:Layout(size, offset, inside)
    local anchor = self.anchor
    local info = EdgeInfo(self.style)
    local plate = ns.pixelPlate
    if plate then
        local set = plate.pixelSet
        if not set then
            set = {}
            plate.pixelSet = set
        end
        local args = set[self]
        if not args then
            args = {}
            set[self] = args
        end
        args[1], args[2], args[3] = size, offset, inside
    end
    self.empty = size <= 0 or self.style == "none"
    self.laidOut = { size, offset, inside }
    self.cornersOn = false
    if self.style == "none" then
        for i = 1, 4 do
            self.edges[i]:Hide()
        end
        if self.edgeFrame then
            self.edgeFrame:Hide()
        end
        CornersShown(self, false)
        return
    end
    if info then
        for i = 1, 4 do
            self.edges[i]:Hide()
        end
        if not self.empty then
            self:LayoutEdge(info, size, inside)
        end
        self:SetShown(self.shown ~= false)
        return
    end
    if self.style == "shadow" then
        size = size * SHADOW_STEP
    end
    local top, bottom, left, right = self.edges[1], self.edges[2], self.edges[3], self.edges[4]
    offset = offset or 0
    if ns.pixelBorders and PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        local scale = anchor:GetEffectiveScale()
        if scale >= MIN_PIXEL_SCALE then
            local pixel = PixelUtil.GetPixelToUIUnitFactor() / scale
            size = math.floor(size + 0.5) * pixel
            offset = math.floor(offset + 0.5) * pixel
        end
    end
    local outer = offset + size
    local fade = not inside and Faded(self)
    self.cornersOn = fade
    local span = fade and offset or outer
    if fade then
        PlaceCorners(self, size, offset)
    end
    if inside then
        for i = 1, 4 do
            self.edges[i]:ClearAllPoints()
        end
        top:SetPoint("TOPLEFT", anchor, "TOPLEFT", offset, -offset)
        top:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -offset, -offset)
        Thickness(top, true, size)
        bottom:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", offset, offset)
        bottom:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -offset, offset)
        Thickness(bottom, true, size)
        left:SetPoint("TOPLEFT", anchor, "TOPLEFT", offset, -offset - size)
        left:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", offset, offset + size)
        Thickness(left, false, size)
        right:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -offset, -offset - size)
        right:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -offset, offset + size)
        Thickness(right, false, size)
        self:SetShown(self.shown ~= false)
        return
    end

    for i = 1, 4 do
        self.edges[i]:ClearAllPoints()
    end

    top:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", -span, offset)
    top:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", span, offset)
    Thickness(top, true, size)

    bottom:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -span, -offset)
    bottom:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", span, -offset)
    Thickness(bottom, true, size)

    left:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -offset, offset)
    left:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -offset, -offset)
    Thickness(left, false, size)

    right:SetPoint("TOPLEFT", anchor, "TOPRIGHT", offset, offset)
    right:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", offset, -offset)
    Thickness(right, false, size)

    self:SetShown(self.shown ~= false)
end

function ns.RepixelPlate(plate)
    local set = plate.pixelSet
    if not set or not ns.pixelPerfect then return end
    local previous = ns.pixelBorders
    ns.pixelBorders = true
    for border, args in pairs(set) do
        border:Layout(args[1], args[2], args[3])
    end
    ns.pixelBorders = previous
end

function Border:SetColor(r, g, b, a)
    local color = self.color
    if color and color[1] == r and color[2] == g and color[3] == b and color[4] == a and self.colorStyle == self.style then
        return
    end
    color = color or {}
    color[1], color[2], color[3], color[4] = r, g, b, a
    self.color = color
    self.colorStyle = self.style
    if self.edgeFrame and EdgeInfo(self.style) then
        self.edgeFrame:SetBackdropBorderColor(r, g, b, a)
        return
    end
    if self.style == "shadow" then
        self:SetFade(r, g, b, a)
        return
    end
    self.fade = false
    for i = 1, 4 do
        self.edges[i]:SetColorTexture(r, g, b, a)
        self.edges[i]:SetVertexColor(1, 1, 1, 1)
    end
end

function Border:SetSpriteCell(path, index, rows, columns)
    self.color, self.colorStyle = nil, nil
    for i = 1, 4 do
        local edge = self.edges[i]
        edge:SetTexture(path, nil, nil, "NEAREST")
        edge:SetVertexColor(1, 1, 1, 1)
        edge:SetSpriteSheetCell(index, rows, columns)
    end
end

function Border:SetFade(r, g, b, a)
    local inner, outer = self.fadeInner, self.fadeOuter
    if inner then
        inner:SetRGBA(r, g, b, a)
        outer:SetRGBA(r, g, b, 0)
    else
        inner = CreateColor(r, g, b, a)
        outer = CreateColor(r, g, b, 0)
        self.fadeInner, self.fadeOuter = inner, outer
    end
    local top, bottom, left, right = self.edges[1], self.edges[2], self.edges[3], self.edges[4]
    for i = 1, 4 do
        self.edges[i]:SetColorTexture(1, 1, 1, 1)
    end
    top:SetGradient("VERTICAL", inner, outer)
    bottom:SetGradient("VERTICAL", outer, inner)
    left:SetGradient("HORIZONTAL", outer, inner)
    right:SetGradient("HORIZONTAL", inner, outer)
    if not self.corners then
        local layer, sublevel = top:GetDrawLayer()
        self.corners = {}
        for i, info in ipairs(CORNERS) do
            local corner = self.owner:CreateTexture(nil, layer, nil, sublevel)
            corner:SetTexture(CORNER)
            corner:SetTexCoord(info.coords[1], info.coords[2], info.coords[3], info.coords[4])
            corner:Hide()
            self.corners[i] = corner
        end
    end
    for i = 1, 4 do
        self.corners[i]:SetVertexColor(r, g, b, a)
    end
    if not self.fade then
        self.fade = true
        if self.laidOut then
            self:Layout(self.laidOut[1], self.laidOut[2], self.laidOut[3])
        end
    end
end

function Border:SetShown(shown)
    self.shown = shown
    local visible = shown and not self.empty
    local edge = EdgeInfo(self.style) ~= nil
    for i = 1, 4 do
        self.edges[i]:SetShown(visible and not edge)
    end
    CornersShown(self, visible and not edge and self.cornersOn == true)
    if self.edgeFrame then
        self.edgeFrame:SetShown(visible and edge)
    end
end

function Border:Show()
    self:SetShown(true)
end

function Border:Hide()
    self:SetShown(false)
end

function Border:SetAlpha(alpha)
    for i = 1, 4 do
        self.edges[i]:SetAlpha(alpha)
        if self.corners then
            self.corners[i]:SetAlpha(alpha)
        end
    end
    if self.edgeFrame then
        self.edgeFrame:SetAlpha(alpha)
    end
end

function Border:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
    for i = 1, 4 do
        self.edges[i]:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
        if self.corners then
            self.corners[i]:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
        end
    end
    if self.edgeFrame then
        self.edgeFrame:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
    end
end

function Border:IsVisible()
    if self.edgeFrame and EdgeInfo(self.style) then
        return self.edgeFrame:IsVisible()
    end
    return self.edges[1]:IsVisible()
end

function Border:GetAlpha()
    if self.edgeFrame and EdgeInfo(self.style) then
        return self.edgeFrame:GetAlpha()
    end
    return self.edges[1]:GetAlpha()
end
