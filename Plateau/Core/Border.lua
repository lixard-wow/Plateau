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

local OPPOSITE = { BOTTOMRIGHT = "TOPLEFT", BOTTOMLEFT = "TOPRIGHT", TOPRIGHT = "BOTTOMLEFT", TOPLEFT = "BOTTOMRIGHT" }

local function PlaceCorners(self, size, offset)
    local corners = self.corners
    if not corners then return end
    local outer = offset + size
    for i, info in ipairs(CORNERS) do
        local corner = corners[i]
        corner:ClearAllPoints()
        corner:SetPoint(info.point, self.anchor, info.relative, info.x * offset, info.y * offset)
        corner:SetPoint(OPPOSITE[info.point], self.anchor, info.relative, info.x * outer, info.y * outer)
    end
end

local TOOLTIP_EDGE = "Interface\\Tooltips\\UI-Tooltip-Border"

local EDGE_STYLES = {
    tooltip = { file = TOOLTIP_EDGE, base = 10, step = 2 },
    thinTooltip = { file = TOOLTIP_EDGE, base = 6, step = 2 },
}

local SHADOW_STEP = 3

function ns.SnapTexture(texture)
    texture:SetSnapToPixelGrid(true)
    texture:SetTexelSnappingBias(0)
    return texture
end

local MIN_PIXEL_SCALE = 0.2

local Ring = {}
Ring.__index = Ring

function ns.CreateRing(owner, sublevel)
    local texture = ns.SnapTexture(owner:CreateTexture(nil, "BACKGROUND", nil, sublevel or 0))
    return setmetatable({ owner = owner, texture = texture, shown = true }, Ring)
end

local function OwningPlate(frame)
    for _ = 1, 10 do
        if type(frame) ~= "table" then return nil end
        if type(frame.built) == "table" and frame.health then return frame end
        if not frame.GetParent then return nil end
        frame = frame:GetParent()
    end
end

local function PixelSize(region)
    if not (PixelUtil and PixelUtil.GetPixelToUIUnitFactor) then return nil end
    local scale = region:GetEffectiveScale()
    if type(scale) ~= "number" or (issecretvalue and issecretvalue(scale)) or scale < MIN_PIXEL_SCALE then
        return nil
    end
    return PixelUtil.GetPixelToUIUnitFactor() / scale
end

function Ring:Layout(size)
    local owner, texture = self.owner, self.texture
    if not self.restricted then
        local plate = ns.pixelPlate or OwningPlate(owner)
        if plate then
            plate.pixelSet = plate.pixelSet or {}
            local args = plate.pixelSet[self] or {}
            args[1] = size
            plate.pixelSet[self] = args
        end
    end
    local pixel = ns.pixelPerfect ~= false and PixelSize(owner) or 1
    local reach = math.max(0, math.floor((size or 0) + 0.5)) * pixel
    self.reach = reach
    self.empty = reach <= 0
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", owner, "TOPLEFT", -reach, reach)
    texture:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", reach, -reach)
    texture:SetShown(self.shown and not self.empty)
end

function Ring:SetColor(r, g, b, a)
    self.texture:SetColorTexture(r, g, b, a or 1)
end

function Ring:SetShown(shown)
    self.shown = shown ~= false
    self.texture:SetShown(self.shown and not self.empty)
end

function Ring:Show()
    self:SetShown(true)
end

function Ring:Hide()
    self:SetShown(false)
end

function ns.SetIconBorder(icon, size, color)
    size = size or 0
    icon.border:Layout(size)
    icon.border:SetShown(size > 0)
    if color then
        icon.border:SetColor(color[1], color[2], color[3], color[4] or 1)
    end
end

function ns.DecorateIcon(frame)
    local art = ns.SnapTexture(frame:CreateTexture(nil, "ARTWORK"))
    art:SetAllPoints()
    art:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    frame.art = art
    frame.border = ns.CreateRing(frame, 0)
    return frame
end

function ns.CreateIcon(parent)
    return ns.DecorateIcon(CreateFrame("Frame", nil, parent))
end

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
    return ns.HealthBorderOuter(look.health)
end

function ns.HealthBorderOuter(health)
    if health.borderStyle == "none" or health.borderInside then
        return 0
    end
    local size = health.borderSize or 0
    local info = EDGE_STYLES[health.borderStyle]
    if info then
        return math.floor((info.base + info.step * size) / 3 + 0.5)
    end
    if health.borderStyle == "shadow" then
        return size * SHADOW_STEP
    end
    return size
end

function ns.CastbarJoined(look, shift)
    local cast = look.castbar
    return cast.joinBorder and (shift or 0) == 0 and cast.borderStyle == "pixel" and look.health.borderStyle == "pixel"
end

function ns.PixelUnit(region)
    return PixelSize(region) or 1
end

function ns.CastbarGap(look, shift)
    if ns.CastbarJoined(look, shift) then
        return ns.HealthBorderOffset(look)
    end
    return look.castbar.gap
end

function Border:SetStyle(style, levelAbove)
    self.style = style
    self.levelAbove = levelAbove
end

local customEdges = {}

local function EdgeInfo(style)
    if not style or style == "pixel" or style == "shadow" then return nil end
    local info = EDGE_STYLES[style] or customEdges[style]
    if not info then
        info = { file = style, base = 8, step = 2 }
        customEdges[style] = info
    end
    return info
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
    local plate = ns.pixelPlate or OwningPlate(self.owner)
    if plate and not self.restricted then
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
    local laid = self.laidOut
    if not laid then
        laid = {}
        self.laidOut = laid
    end
    laid[1], laid[2], laid[3] = size, offset, inside
    self.cornersOn = false
    if self.style == "none" then
        self.laidStyle = nil
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
        self.laidStyle = nil
        for i = 1, 4 do
            self.edges[i]:Hide()
        end
        if not self.empty then
            self:LayoutEdge(info, size, inside)
        end
        self:SetShown(self.shown ~= false)
        return
    end
    offset = offset or 0
    local pixel = false
    if ns.pixelBorders or (ns.pixelPerfect == true and plate) then
        pixel = PixelSize(anchor) or false
    end
    local fade = not inside and Faded(self)
    self.cornersOn = fade
    local hasCorners = self.corners ~= nil
    if self.laidStyle == self.style and self.laidAnchor == anchor and self.laidSize == size and self.laidOffset == offset
        and self.laidInside == inside and self.laidPixel == pixel and self.laidFade == fade and self.laidCorners == hasCorners then
        self:SetShown(self.shown ~= false)
        return
    end
    self.laidStyle, self.laidAnchor, self.laidSize, self.laidOffset = self.style, anchor, size, offset
    self.laidInside, self.laidPixel, self.laidFade, self.laidCorners = inside, pixel, fade, hasCorners
    if self.style == "shadow" then
        size = size * SHADOW_STEP
    end
    local top, bottom, left, right = self.edges[1], self.edges[2], self.edges[3], self.edges[4]
    if pixel then
        size = math.floor(size + 0.5) * pixel
        offset = math.floor(offset + 0.5) * pixel
    end
    local outer = offset + size
    local span = fade and offset or outer
    if fade then
        PlaceCorners(self, size, offset)
    end
    if inside then
        for i = 1, 4 do
            self.edges[i]:ClearAllPoints()
        end
        top:SetPoint("TOPLEFT", anchor, "TOPLEFT", offset, -offset)
        top:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", -offset, -offset - size)
        bottom:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", offset, offset + size)
        bottom:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -offset, offset)
        left:SetPoint("TOPLEFT", anchor, "TOPLEFT", offset, -offset - size)
        left:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", offset + size, offset + size)
        right:SetPoint("TOPLEFT", anchor, "TOPRIGHT", -offset - size, -offset - size)
        right:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -offset, offset + size)
        self:SetShown(self.shown ~= false)
        return
    end

    for i = 1, 4 do
        self.edges[i]:ClearAllPoints()
    end

    top:SetPoint("TOPLEFT", anchor, "TOPLEFT", -span, outer)
    top:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", span, offset)

    bottom:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -span, -offset)
    bottom:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", span, -outer)

    left:SetPoint("TOPLEFT", anchor, "TOPLEFT", -outer, offset)
    left:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMLEFT", -offset, -offset)

    right:SetPoint("TOPLEFT", anchor, "TOPRIGHT", offset, offset)
    right:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", outer, -offset)

    self:SetShown(self.shown ~= false)
end

function ns.SnapPlateSize(plate)
    local width, height = plate.rawWidth, plate.rawHeight
    if not width then return end
    if ns.pixelPerfect and PixelUtil and PixelUtil.GetPixelToUIUnitFactor then
        local scale = plate:GetEffectiveScale()
        if not issecretvalue(scale) and scale >= MIN_PIXEL_SCALE then
            local pixel = PixelUtil.GetPixelToUIUnitFactor() / scale
            width = math.max(1, math.floor(width / pixel + 0.5)) * pixel
            height = math.max(1, math.floor(height / pixel + 0.5)) * pixel
        end
    end
    if plate.sizedWidth ~= width or plate.sizedHeight ~= height then
        plate.sizedWidth, plate.sizedHeight = width, height
        plate:SetSize(width, height)
    end
end

local RoundTree

local function Round(object, enabled)
    if object.plateauRound ~= enabled then
        object.plateauRound = enabled
        object:SetRoundLayoutToNearestPixel(enabled)
    end
end

local function RoundRegions(enabled, ...)
    for i = 1, select("#", ...) do
        Round((select(i, ...)), enabled)
    end
end

local function RoundChildren(enabled, ...)
    for i = 1, select("#", ...) do
        local child = select(i, ...)
        if not child:IsForbidden() and not child.AddAuraGroup and not child.AddAuraSlot then
            RoundTree(child, enabled)
        end
    end
end

function RoundTree(frame, enabled)
    Round(frame, enabled)
    RoundRegions(enabled, frame:GetRegions())
    RoundChildren(enabled, frame:GetChildren())
end

function ns.RoundLayout(frame)
    if not frame.SetRoundLayoutToNearestPixel then return end
    RoundTree(frame, ns.pixelPerfect == true)
end

local repixelHooks = {}

function ns.OnRepixel(callback)
    repixelHooks[#repixelHooks + 1] = callback
end

function ns.RepixelPlate(plate)
    local set = plate.pixelSet
    if not set or not ns.pixelPerfect then return end
    local scale = plate:GetEffectiveScale()
    if plate.pixelScale == scale then return end
    plate.pixelScale = scale
    ns.SnapPlateSize(plate)
    local previous = ns.pixelBorders
    ns.pixelBorders = true
    for border, args in pairs(set) do
        border:Layout(args[1], args[2], args[3])
    end
    ns.pixelBorders = previous
    for i = 1, #repixelHooks do
        repixelHooks[i](plate)
    end
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

local function ApplyFade(self, r, g, b, a)
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
            corner:SetSnapToPixelGrid(true)
            corner:SetTexelSnappingBias(0)
            corner:SetTexture(CORNER)
            corner:SetTexCoord(info.coords[1], info.coords[2], info.coords[3], info.coords[4])
            corner:Hide()
            self.corners[i] = corner
        end
    end
    for i = 1, 4 do
        self.corners[i]:SetVertexColor(r, g, b, a)
    end
end

function Border:SetFade(r, g, b, a)
    local color = self.fadeColor
    if color and self.fade and not self.pulsed and color[1] == r and color[2] == g and color[3] == b and color[4] == a then
        return
    end
    color = color or {}
    color[1], color[2], color[3], color[4] = r, g, b, a
    self.fadeColor = color
    self.pulsed = false
    ApplyFade(self, r, g, b, a)
    if not self.fade then
        self.fade = true
        if self.laidOut then
            self:Layout(self.laidOut[1], self.laidOut[2], self.laidOut[3])
        end
    end
end

function Border:SetEdgeHidden(index, hidden)
    local list = self.hiddenEdges
    if not list then
        if not hidden then return end
        list = {}
        self.hiddenEdges = list
    end
    if (list[index] == true) == (hidden == true) then return end
    list[index] = hidden == true or nil
    self:SetShown(self.shown ~= false)
end

function Border:SetShown(shown)
    self.shown = shown
    local visible = shown and not self.empty
    local edge = EdgeInfo(self.style) ~= nil
    local hidden = self.hiddenEdges
    for i = 1, 4 do
        self.edges[i]:SetShown(visible and not edge and not (hidden and hidden[i]))
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

function Border:SetPulse(alpha)
    local color = self.fade and self.fadeColor
    self.pulsed = alpha ~= 1
    if color then
        ApplyFade(self, color[1], color[2], color[3], color[4] * alpha)
    else
        self:SetAlpha(alpha)
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
