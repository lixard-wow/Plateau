local _, ns = ...

local GetAtlasInfo = C_Texture.GetAtlasInfo

local BRIGHTEN_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
local BRIGHTEN_ALPHA = 0.25

local ARROWS = ns.arrowStyles

local ANGLES = { right = 0, left = math.pi, down = -math.pi / 2, up = math.pi / 2 }

local PLACEMENTS = {
    ["in"] = { left = "right", right = "left" },
    out = { left = "left", right = "right" },
    down = { top = "down" },
    up = { bottom = "up" },
    vertical = { top = "down", bottom = "up" },
}

local BRACKETS = {
    splash = "RecruitAFriend_Splash_CornerBracket_",
    reward = "RecruitAFriend_RewardPane_CornerBracket_",
    claim = "RecruitAFriend_ClaimPane_CornerBracket_",
}

local CORNERS = {
    { atlas = "LeftTop", point = "TOPLEFT", x = -1, y = 1 },
    { atlas = "RightTop", point = "TOPRIGHT", x = 1, y = 1 },
    { atlas = "LeftBottom", point = "BOTTOMLEFT", x = -1, y = -1 },
    { atlas = "RightBottom", point = "BOTTOMRIGHT", x = 1, y = -1 },
}

local settings = { target = {}, focus = {} }

local Highlight = {
    key = "target",
    events = {},
}
ns.Elements = ns.Elements or {}
ns.Elements.Highlight = Highlight

local pulsing = {}
local pulseTime = 0
local pulser = CreateFrame("Frame")
pulser:Hide()
pulser:SetScript("OnUpdate", function(self, elapsed)
    pulseTime = pulseTime + elapsed
    local alpha = 0.6 + 0.4 * math.sin(pulseTime * 4)
    local any = false
    for border in pairs(pulsing) do
        any = true
        border:SetAlpha(alpha)
    end
    if not any then
        self:Hide()
    end
end)

local function Pulse(border, on)
    if on then
        if not pulsing[border] then
            pulsing[border] = true
            pulser:Show()
        end
    elseif pulsing[border] then
        pulsing[border] = nil
        border:SetAlpha(1)
    end
end

local BOB = 4
local TOWARD = { TOP = { 0, -BOB }, BOTTOM = { 0, BOB }, LEFT = { BOB, 0 }, RIGHT = { -BOB, 0 } }

local function Bob(texture, side)
    local group = texture.bob
    if not group then
        group = texture:CreateAnimationGroup()
        group:SetLooping("BOUNCE")
        group.move = group:CreateAnimation("Translation")
        group.move:SetDuration(0.45)
        group.move:SetSmoothing("IN_OUT")
        texture.bob = group
    end
    if group.side ~= side then
        local playing = group:IsPlaying()
        group:Stop()
        local offset = TOWARD[side]
        group.move:SetOffset(offset[1], offset[2])
        group.side = side
        if playing then
            group:Play()
        end
    end
end

local function PlayBob(texture, on)
    local group = texture and texture.bob
    if not group then return end
    if on and texture:IsShown() then
        if not group:IsPlaying() then
            group:Play()
        end
    elseif group:IsPlaying() then
        group:Stop()
    end
end

local function IsTinted(color)
    return color[1] < 0.99 or color[2] < 0.99 or color[3] < 0.99
end

local function EnsureArrows(set, plate)
    if not set.arrowLeft then
        set.arrowLeft = plate.overlay:CreateTexture(nil, "OVERLAY")
        set.arrowRight = plate.overlay:CreateTexture(nil, "OVERLAY")
        for _, arrow in ipairs({ set.arrowLeft, set.arrowRight }) do
            arrow:SetSnapToPixelGrid(false)
            arrow:SetTexelSnappingBias(0)
        end
    end
end

local function EnsureBrackets(set, plate)
    if not set.brackets then
        set.brackets = {}
        for i = 1, #CORNERS do
            set.brackets[i] = plate.overlay:CreateTexture(nil, "OVERLAY")
        end
    end
end

local function CreateSet(plate)
    local set = {}
    set.ring = ns.CreateBorder(plate, plate, "BACKGROUND", -8)
    set.glow = ns.CreateBorder(plate, plate, "BACKGROUND", -8)
    if plate.preview then
        EnsureArrows(set, plate)
        EnsureBrackets(set, plate)
    end
    return set
end


local atlasRatio = {}

local function SizeToAtlas(texture, atlas, height)
    local ratio = atlasRatio[atlas]
    if ratio == nil then
        local info = GetAtlasInfo(atlas)
        ratio = (info and info.height > 0) and info.width / info.height or 1
        atlasRatio[atlas] = ratio
    end
    texture:SetSize(height * ratio, height)
end

local function Point(texture, style, direction, size)
    if style.file then
        texture:SetTexture(style.file)
        texture:SetRotation(ANGLES[direction])
        texture:SetSize(size, size)
        return
    end
    local atlas, rotation = style[direction], 0
    if not atlas then
        atlas = style.left
        rotation = ANGLES[direction] - ANGLES.left
    end
    texture:SetAtlas(atlas)
    texture:SetRotation(rotation)
    SizeToAtlas(texture, atlas, size)
end

local function StyleSet(set, plate, db, borderSize)
    set.ring:Layout(db.ringSize, borderSize)
    set.ring:SetColor(db.ringColor[1], db.ringColor[2], db.ringColor[3], db.ringColor[4])

    set.glow:Layout(db.glowSize, borderSize)
    set.glow:SetFade(db.glowColor[1], db.glowColor[2], db.glowColor[3], db.glowColor[4])

    if db.arrows then
        EnsureArrows(set, plate)
        local style = ARROWS[db.arrowStyle] or ARROWS.chevronDouble
        local placement = PLACEMENTS[db.arrowPlacement] or PLACEMENTS["in"]
        local left, right = set.arrowLeft, set.arrowRight
        left:ClearAllPoints()
        right:ClearAllPoints()
        if placement.top and placement.bottom then
            Point(left, style, placement.top, db.arrowSize)
            Point(right, style, placement.bottom, db.arrowSize)
            left:SetPoint("BOTTOM", plate, "TOP", 0, db.arrowGap)
            right:SetPoint("TOP", plate, "BOTTOM", 0, -db.arrowGap)
            set.single = false
            Bob(left, "TOP")
            Bob(right, "BOTTOM")
        elseif placement.top then
            Point(left, style, placement.top, db.arrowSize)
            left:SetPoint("BOTTOM", plate, "TOP", 0, db.arrowGap)
            set.single = true
            Bob(left, "TOP")
        elseif placement.bottom then
            Point(left, style, placement.bottom, db.arrowSize)
            left:SetPoint("TOP", plate, "BOTTOM", 0, -db.arrowGap)
            set.single = true
            Bob(left, "BOTTOM")
        else
            Point(left, style, placement.left, db.arrowSize)
            Point(right, style, placement.right, db.arrowSize)
            left:SetPoint("RIGHT", plate, "LEFT", -db.arrowGap, 0)
            right:SetPoint("LEFT", plate, "RIGHT", db.arrowGap, 0)
            set.single = false
            Bob(left, "LEFT")
            Bob(right, "RIGHT")
        end
        local c = db.arrowColor
        local tinted = IsTinted(c)
        left:SetDesaturated(tinted)
        right:SetDesaturated(tinted)
        left:SetVertexColor(c[1], c[2], c[3], c[4])
        right:SetVertexColor(c[1], c[2], c[3], c[4])
    end

    if db.brackets then
        EnsureBrackets(set, plate)
        local prefix = BRACKETS[db.bracketStyle] or BRACKETS.splash
        local b = db.bracketColor
        local bracketTinted = IsTinted(b)
        for i, corner in ipairs(CORNERS) do
            local bracket = set.brackets[i]
            local atlas = prefix .. corner.atlas
            bracket:SetAtlas(atlas)
            SizeToAtlas(bracket, atlas, db.bracketSize)
            bracket:ClearAllPoints()
            bracket:SetPoint(corner.point, plate, corner.point, corner.x * db.bracketGap, corner.y * db.bracketGap)
            bracket:SetDesaturated(bracketTinted)
            bracket:SetVertexColor(b[1], b[2], b[3], b[4])
        end
    end
end

local function ShowSet(set, config, shown)
    set.ring:SetShown(shown and config.ring)
    set.glow:SetShown(shown and config.glow)
    Pulse(set.ring, shown and config.ring and config.pulse)
    Pulse(set.glow, shown and config.glow and config.pulse)
    if set.arrowLeft then
        set.arrowLeft:SetShown(shown and config.arrows)
        set.arrowRight:SetShown(shown and config.arrows and not set.single)
        PlayBob(set.arrowLeft, shown and config.arrows and config.animateArrows)
        PlayBob(set.arrowRight, shown and config.arrows and config.animateArrows and not set.single)
    end
    if set.brackets then
        for i = 1, #set.brackets do
            set.brackets[i]:SetShown(shown and config.brackets)
        end
    end
end

local function FocusSet(plate)
    local set = plate.focusSet
    if not set then
        set = CreateSet(plate)
        plate.focusSet = set
        local look = ns.DB.views[plate.state]
        StyleSet(set, plate, ns.DB.views.enemy.focus, ns.HealthBorderOffset(look))
    end
    return set
end

function Highlight:Create(plate)
    plate.targetSet = CreateSet(plate)
    if plate.preview then
        FocusSet(plate)
    end

    local wash = plate.health:CreateTexture(nil, "ARTWORK", nil, 7)
    wash:SetTexture(BRIGHTEN_TEXTURE)
    wash:SetBlendMode("ADD")
    wash:SetAlpha(BRIGHTEN_ALPHA)
    wash:Hide()
    plate.targetWash = wash
end

local function Remember(config, db)
    config.ring = db.ring
    config.glow = db.glow
    config.arrows = db.arrows
    config.brackets = db.brackets
    config.pulse = db.pulse == true
    config.animateArrows = db.animateArrows == true
end

local SELECTED_SCALE = "nameplateSelectedScale"

function Highlight:Configure(db, state)
    if state ~= "enemy" then return end
    Remember(settings.target, db)
    settings.target.brighten = db.brighten
    local CVars = ns.CVars
    if db.useBlizzardScale then
        if CVars:IsManaged(SELECTED_SCALE) and CVars:Get(SELECTED_SCALE) == "1" then
            CVars:Release(SELECTED_SCALE)
        end
        if not InCombatLockdown() and not CVars:IsManaged(SELECTED_SCALE) and CVars:Get(SELECTED_SCALE) == "1" then
            C_CVar.SetCVar(SELECTED_SCALE, C_CVar.GetCVarDefault(SELECTED_SCALE))
        end
    elseif CVars:Get(SELECTED_SCALE) ~= "1" then
        CVars:Set(SELECTED_SCALE, "1")
    end
    ns.Scaling:RefreshBlizzardScale()
    local scale = db.useBlizzardScale and 1 or db.scale
    settings.target.scale = scale
    ns.Scaling:SetTargetScale(scale)
    Remember(settings.focus, ns.DB.views.enemy.focus)
end

function Highlight:Style(plate)
    local look = ns.DB.views[plate.state]
    local borderSize = ns.HealthBorderOffset(look)
    StyleSet(plate.targetSet, plate, ns.DB.views.enemy.target, borderSize)
    if plate.focusSet then
        StyleSet(plate.focusSet, plate, ns.DB.views.enemy.focus, borderSize)
    end
    plate.targetWash:ClearAllPoints()
    plate.targetWash:SetAllPoints(plate.health:GetStatusBarTexture())
end

local function Clear(plate)
    ShowSet(plate.targetSet, settings.target, false)
    if plate.focusSet then
        ShowSet(plate.focusSet, settings.focus, false)
    end
    plate.targetWash:Hide()
end

function Highlight:Enable(plate)
    Clear(plate)
end

function Highlight:Disable(plate)
    Clear(plate)
end

function Highlight:OnEvent()
end

function Highlight:UpdateEmphasis(plate)
    local isTarget = plate.isTarget
    local isFocus = plate.isFocus and not isTarget
    ShowSet(plate.targetSet, settings.target, isTarget)
    if isFocus then
        ShowSet(FocusSet(plate), settings.focus, true)
    elseif plate.focusSet then
        ShowSet(plate.focusSet, settings.focus, false)
    end
    plate.targetWash:SetShown(isTarget and settings.target.brighten)
    ns.Scaling:Apply(plate)
end

function Highlight:Preview(plate)
    self:UpdateEmphasis(plate)
end

ns.Driver:RegisterElement(Highlight)
