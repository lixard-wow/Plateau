local _, ns = ...

local Border = {}
Border.__index = Border

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

function Border:Layout(size, offset, inside)
    local anchor = self.anchor
    local info = EdgeInfo(self.style)
    self.empty = size <= 0 or self.style == "none"
    if self.style == "none" then
        for i = 1, 4 do
            self.edges[i]:Hide()
        end
        if self.edgeFrame then
            self.edgeFrame:Hide()
        end
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
        local pixel = PixelUtil.GetPixelToUIUnitFactor() / anchor:GetEffectiveScale()
        size = math.floor(size + 0.5) * pixel
        offset = math.floor(offset + 0.5) * pixel
    end
    local outer = offset + size
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

    top:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", -outer, offset)
    top:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", outer, offset)
    Thickness(top, true, size)

    bottom:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -outer, -offset)
    bottom:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", outer, -offset)
    Thickness(bottom, true, size)

    left:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -offset, offset)
    left:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -offset, -offset)
    Thickness(left, false, size)

    right:SetPoint("TOPLEFT", anchor, "TOPRIGHT", offset, offset)
    right:SetPoint("BOTTOMLEFT", anchor, "BOTTOMRIGHT", offset, -offset)
    Thickness(right, false, size)

    self:SetShown(self.shown ~= false)
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
end

function Border:SetShown(shown)
    self.shown = shown
    local visible = shown and not self.empty
    local edge = EdgeInfo(self.style) ~= nil
    for i = 1, 4 do
        self.edges[i]:SetShown(visible and not edge)
    end
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
    end
    if self.edgeFrame then
        self.edgeFrame:SetAlpha(alpha)
    end
end

function Border:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
    for i = 1, 4 do
        self.edges[i]:SetAlphaFromBoolean(value, alphaIfTrue, alphaIfFalse)
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
