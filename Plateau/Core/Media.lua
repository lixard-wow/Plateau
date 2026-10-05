local addonName, ns = ...

local ATLAS_PREFIX = "atlas:"
local FLAT = "Interface\\Buttons\\WHITE8X8"
local BARS = "Interface\\AddOns\\" .. addonName .. "\\Art\\Bars\\"

ns.barTextures = {
    { value = BARS .. "bar-smooth.png", label = "Plateau: Smooth" },
    { value = BARS .. "bar-gloss.png", label = "Plateau: Gloss" },
    { value = BARS .. "bar-minimalist.png", label = "Plateau: Minimalist" },
    { value = BARS .. "bar-aluminium.png", label = "Plateau: Aluminium" },
    { value = BARS .. "bar-satin.png", label = "Plateau: Satin" },
    { value = BARS .. "bar-graphite.png", label = "Plateau: Graphite" },
    { value = BARS .. "bar-velvet.png", label = "Plateau: Velvet" },
    { value = BARS .. "bar-glass.png", label = "Plateau: Glass" },
    { value = BARS .. "bar-radiant.png", label = "Plateau: Radiant" },
    { value = BARS .. "bar-skewed.png", label = "Plateau: Skewed" },
}

ns.overlayPatterns = {
    { value = BARS .. "checkers-fine.png", label = "Plateau: Checkers (fine)" },
    { value = BARS .. "checkers-medium.png", label = "Plateau: Checkers (medium)" },
    { value = BARS .. "checkers-large.png", label = "Plateau: Checkers (large)" },
    { value = BARS .. "checkers-xlarge.png", label = "Plateau: Checkers (extra large)" },
    { value = BARS .. "stripes-thin.png", label = "Plateau: Right-leaning lines (thin)" },
    { value = BARS .. "stripes-medium.png", label = "Plateau: Right-leaning lines (medium)" },
    { value = BARS .. "stripes-thick.png", label = "Plateau: Right-leaning lines (thick)" },
    { value = BARS .. "stripes-thin-left.png", label = "Plateau: Left-leaning lines (thin)" },
    { value = BARS .. "stripes-medium-left.png", label = "Plateau: Left-leaning lines (medium)" },
    { value = BARS .. "stripes-thick-left.png", label = "Plateau: Left-leaning lines (thick)" },
}

local TILED = {
    [BARS .. "stripes-thin.png"] = true,
    [BARS .. "stripes-medium.png"] = true,
    [BARS .. "stripes-thick.png"] = true,
    [BARS .. "stripes-thin-left.png"] = true,
    [BARS .. "stripes-medium-left.png"] = true,
    [BARS .. "stripes-thick-left.png"] = true,
}

ns.lineTextures = {
    ["lines-thin"] = BARS .. "stripes-thin.png",
    ["lines-medium"] = BARS .. "stripes-medium.png",
    ["lines-thick"] = BARS .. "stripes-thick.png",
    ["lines-thin-left"] = BARS .. "stripes-thin-left.png",
    ["lines-medium-left"] = BARS .. "stripes-medium-left.png",
    ["lines-thick-left"] = BARS .. "stripes-thick-left.png",
}

ns.checkerTextures = {
    ["checkers-fine"] = BARS .. "checkers-fine.png",
    ["checkers-medium"] = BARS .. "checkers-medium.png",
    ["checkers-large"] = BARS .. "checkers-large.png",
    ["checkers-xlarge"] = BARS .. "checkers-xlarge.png",
}

local ART = "Interface\\AddOns\\" .. addonName .. "\\Art\\Indicators\\"

ns.arrowStyles = {
    chevron = { file = ART .. "chevron.png" },
    chevronBold = { file = ART .. "chevron-bold.png" },
    chevronDouble = { file = ART .. "chevron-double.png" },
    triangle = { file = ART .. "triangle.png" },
    block = { file = ART .. "block.png" },
    tutorial = { left = "NPE_ArrowLeft", right = "NPE_ArrowRight", down = "NPE_ArrowDown", up = "NPE_ArrowUp" },
    tutorialGlow = { left = "NPE_ArrowLeftGlow", right = "NPE_ArrowRightGlow", down = "NPE_ArrowDownGlow", up = "NPE_ArrowUpGlow" },
    torghast = { left = "TorghastDoor-ArrowLeft-32x32", right = "TorghastDoor-ArrowRight-32x32", down = "TorghastDoor-ArrowDown-32x32", up = "TorghastDoor-ArrowUp-32x32" },
    delve = { left = "UI-Journeys-Delve-Arrow-Big-Left", down = "UI-Journeys-Delve-Arrow-down" },
    delveSmall = { left = "UI-Journeys-Delve-Arrow-Small-Left" },
}

ns.media = LibStub and LibStub("LibSharedMedia-3.0", true)
if ns.media then
    for _, texture in ipairs(ns.barTextures) do
        ns.media:Register(ns.media.MediaType.STATUSBAR, texture.label, texture.value)
    end
end

local function EnsurePattern(bar)
    local clip = bar.patternClip
    if clip then return clip end
    clip = CreateFrame("Frame", nil, bar)
    clip:SetClipsChildren(true)
    local texture = clip:CreateTexture(nil, "ARTWORK")
    texture:SetPoint("TOPLEFT", bar, "TOPLEFT")
    texture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
    clip.texture = texture
    bar.patternClip = clip
    bar:HookScript("OnSizeChanged", function(_, width, height)
        if clip.tile and not issecretvalue(width) and not issecretvalue(height) then
            texture:SetTexCoord(0, math.max(width, 1) / clip.tile, 0, math.max(height, 1) / clip.tile)
        end
    end)
    local function Mirror(_, ...)
        if clip.mirror then
            texture:SetVertexColor(...)
        end
    end
    hooksecurefunc(bar, "SetStatusBarColor", Mirror)
    hooksecurefunc(bar:GetStatusBarTexture(), "SetVertexColor", Mirror)
    return clip
end

function ns.SetBarPattern(bar, path, tile, mirror, r, g, b, a)
    local clip = bar.patternClip
    if not path then
        if clip then
            clip.tile, clip.mirror = nil, false
            clip:Hide()
        end
        return
    end
    clip = EnsurePattern(bar)
    local fill = bar:GetStatusBarTexture()
    clip:ClearAllPoints()
    clip:SetAllPoints(fill)
    clip.tile, clip.mirror = tile, mirror == true
    clip.texture:SetTexture(path, "REPEAT", "REPEAT")
    local width, height = bar:GetSize()
    if issecretvalue(width) or issecretvalue(height) then
        width, height = bar.patternWidth or 128, bar.patternHeight or 16
    else
        bar.patternWidth, bar.patternHeight = width, height
    end
    clip.texture:SetTexCoord(0, math.max(width, 1) / tile, 0, math.max(height, 1) / tile)
    if clip.mirror then
        clip.texture:SetVertexColor(fill:GetVertexColor())
    else
        clip.texture:SetVertexColor(r, g, b, a)
    end
    clip:Show()
end

local OVERLAY_MID = 178.5 / 255

local function EnsureOverlay(bar)
    local clip = bar.overlayClip
    if clip then return clip end
    clip = CreateFrame("Frame", nil, bar)
    clip:SetClipsChildren(true)
    local veil = clip:CreateTexture(nil, "OVERLAY", nil, -1)
    veil:SetPoint("TOPLEFT", bar, "TOPLEFT")
    veil:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
    veil:SetTexture(FLAT)
    clip.veil = veil
    local texture = clip:CreateTexture(nil, "OVERLAY")
    texture:SetPoint("TOPLEFT", bar, "TOPLEFT")
    texture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
    clip.texture = texture
    bar.overlayClip = clip
    bar:HookScript("OnSizeChanged", function(_, width, height)
        if clip.tile and not issecretvalue(width) and not issecretvalue(height) then
            texture:SetTexCoord(0, math.max(width, 1) / clip.tile, 0, math.max(height, 1) / clip.tile)
        end
    end)
    local function Mirror(_, r, g, b, a)
        if clip.alpha then
            a = a or 1
            if issecretvalue(r) or issecretvalue(g) or issecretvalue(b) or issecretvalue(a) then
                texture:SetVertexColor(r, g, b, a)
                veil:SetVertexColor(r, g, b, a)
                return
            end
            texture:SetVertexColor(r, g, b, a * (clip.contrast or 1))
            veil:SetVertexColor(r * OVERLAY_MID, g * OVERLAY_MID, b * OVERLAY_MID, a)
        end
    end
    hooksecurefunc(bar, "SetStatusBarColor", Mirror)
    hooksecurefunc(bar:GetStatusBarTexture(), "SetVertexColor", Mirror)
    return clip
end

function ns.SetBarOverlay(bar, path, alpha, contrast)
    alpha = alpha or 1
    contrast = contrast or 1
    local clip = bar.overlayClip
    if not path or path == "" then
        if clip then
            clip.tile, clip.alpha = nil, nil
            clip:Hide()
        end
        return
    end
    clip = EnsureOverlay(bar)
    local fill = bar:GetStatusBarTexture()
    clip:ClearAllPoints()
    clip:SetAllPoints(fill)
    clip.texture:SetTexture(path, "REPEAT", "REPEAT")
    clip.contrast = contrast
    if TILED[path] then
        local tile = 64
        clip.tile, clip.alpha = tile, alpha
        local width, height = bar:GetSize()
        if issecretvalue(width) or issecretvalue(height) then
            width, height = bar.overlayWidth or 128, bar.overlayHeight or 16
        else
            bar.overlayWidth, bar.overlayHeight = width, height
        end
        clip.texture:SetTexCoord(0, math.max(width, 1) / tile, 0, math.max(height, 1) / tile)
    else
        clip.tile, clip.alpha = nil, alpha
        clip.texture:SetTexCoord(0, 1, 0, 1)
    end
    local r, g, b, a = fill:GetVertexColor()
    if issecretvalue(r) or issecretvalue(g) or issecretvalue(b) or issecretvalue(a) then
        clip.texture:SetVertexColor(r, g, b, a)
        clip.veil:SetVertexColor(r, g, b, a)
    else
        clip.texture:SetVertexColor(r, g, b, a * contrast)
        clip.veil:SetVertexColor(r * OVERLAY_MID, g * OVERLAY_MID, b * OVERLAY_MID, a)
    end
    clip:SetAlpha(clip.alpha)
    clip:Show()
end

function ns.SetBarTexture(bar, value)
    if TILED[value] then
        bar:SetStatusBarTexture(FLAT)
        bar:GetStatusBarTexture():SetAlpha(0)
        ns.SetBarPattern(bar, value, 64, true)
        return
    end
    if value:sub(1, #ATLAS_PREFIX) == ATLAS_PREFIX then
        bar:SetStatusBarTexture(FLAT)
        bar:GetStatusBarTexture():SetAtlas(value:sub(#ATLAS_PREFIX + 1))
    else
        bar:SetStatusBarTexture(value)
    end
    bar:GetStatusBarTexture():SetAlpha(1)
    ns.SetBarPattern(bar, nil)
end

function ns.SetBackgroundTexture(texture, value, color)
    texture:SetHorizTile(false)
    texture:SetVertTile(false)
    if not value or value == "" then
        texture:SetVertexColor(1, 1, 1, 1)
        texture:SetColorTexture(color[1], color[2], color[3], color[4])
        return
    end
    if value:sub(1, #ATLAS_PREFIX) == ATLAS_PREFIX then
        texture:SetAtlas(value:sub(#ATLAS_PREFIX + 1))
    elseif TILED[value] then
        texture:SetTexture(value, "REPEAT", "REPEAT")
        texture:SetHorizTile(true)
        texture:SetVertTile(true)
    else
        texture:SetTexture(value)
    end
    texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

local RETRY_DELAY = 0.1
local MAX_TRIES = 10
local FALLBACK = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

local THEME_FONTS = { "Barlow-Regular", "Barlow-SemiBold", "BarlowCondensed-Bold", "Cinzel-Bold", "SourceSans3-Regular", "SourceSans3-Bold" }
function ns.WarmThemeFonts()
    local warmer = CreateFrame("Frame", nil, UIParent)
    warmer:SetSize(40, 40)
    warmer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    warmer:SetAlpha(0.01)
    warmer:SetFrameStrata("BACKGROUND")
    C_Timer.After(5, function() warmer:Hide() end)
    for _, name in ipairs(THEME_FONTS) do
        local text = warmer:CreateFontString(nil, "OVERLAY")
        text:SetPoint("BOTTOMLEFT")
        if text:SetFont("Interface\\AddOns\\Plateau_Options\\Media\\Fonts\\" .. name .. ".ttf", 12, "") then
            text:SetText("Plateau")
        end
    end
end

local pending = {}
local scheduled = false

local function Retry()
    scheduled = false
    for fontString, request in pairs(pending) do
        request.tries = request.tries + 1
        if fontString:SetFont(request.file, request.size, request.flags) then
            pending[fontString] = nil
        elseif request.tries >= MAX_TRIES then
            fontString:SetFont(FALLBACK, request.size, request.flags)
            pending[fontString] = nil
        end
    end
    if next(pending) and not scheduled then
        scheduled = true
        C_Timer.After(RETRY_DELAY, Retry)
    end
end

function ns.ApplyFont(fontString, file, size, flags)
    if fontString.slFontFile == file and fontString.slFontSize == size and fontString.slFontFlags == flags then
        return
    end
    fontString.slFontFile, fontString.slFontSize, fontString.slFontFlags = file, size, flags
    if fontString:SetFont(file, size, flags) then
        pending[fontString] = nil
        return
    end
    pending[fontString] = { file = file, size = size, flags = flags, tries = 0 }
    if not scheduled then
        scheduled = true
        C_Timer.After(RETRY_DELAY, Retry)
    end
end

function ns.ApplyShadow(fontString, enabled)
    if fontString.slShadow == enabled then return end
    fontString.slShadow = enabled
    if enabled then
        fontString:SetShadowOffset(1, -1)
        fontString:SetShadowColor(0, 0, 0, 1)
    else
        fontString:SetShadowOffset(0, 0)
        fontString:SetShadowColor(0, 0, 0, 0)
    end
end

ns.brand = {
    { 0.27, 0.82, 0.76, 1 },
    { 0.66, 0.52, 0.98, 1 },
    { 0.98, 0.72, 0.28, 1 },
}

local Brand = CreateFrame("Frame")
ns.Brand = Brand

local BRAND_MODES = { class = true, cycle = true, random = true }
local CYCLE_SECONDS = 12
local CYCLE_STEP = 0.05
local FALLBACK = { 0.21, 0.76, 0.79 }
local current = { FALLBACK[1], FALLBACK[2], FALLBACK[3] }
local brandListeners = {}
local hue = 0
local randomColor

local function HsvToRgb(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return v, t, p end
    if i == 1 then return q, v, p end
    if i == 2 then return p, v, t end
    if i == 3 then return p, q, v end
    if i == 4 then return t, p, v end
    return v, p, q
end

local function ClassColor()
    local _, class = UnitClass("player")
    local color = class and ((C_ClassColor and C_ClassColor.GetClassColor(class)) or (RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]))
    if color then
        return color.r, color.g, color.b
    end
    return FALLBACK[1], FALLBACK[2], FALLBACK[3]
end

local function SetBrandColor(r, g, b)
    if current[1] == r and current[2] == g and current[3] == b then return end
    current[1], current[2], current[3] = r, g, b
    for i = 1, #brandListeners do
        brandListeners[i](r, g, b)
    end
end

function Brand:Mode()
    local saved = ns.DB and ns.DB.saved and ns.DB.saved.global.brandColor
    return BRAND_MODES[saved] and saved or "class"
end

function Brand:SetMode(mode)
    if not (ns.DB and ns.DB.saved) then return end
    ns.DB.saved.global.brandColor = (BRAND_MODES[mode] and mode ~= "class") and mode or nil
    self:Refresh()
end

function Brand:Color()
    return current[1], current[2], current[3]
end

function Brand:Hex()
    return ("ff%02x%02x%02x"):format(current[1] * 255 + 0.5, current[2] * 255 + 0.5, current[3] * 255 + 0.5)
end

function Brand:Text(text)
    return "|c" .. self:Hex() .. text .. "|r"
end

function Brand:OnChange(callback)
    brandListeners[#brandListeners + 1] = callback
    callback(current[1], current[2], current[3])
end

function Brand:Refresh()
    local mode = self:Mode()
    self:SetShown(mode == "cycle")
    if mode == "class" then
        SetBrandColor(ClassColor())
    elseif mode == "random" then
        if not randomColor then
            randomColor = { HsvToRgb(math.random(), 0.6, 1) }
        end
        SetBrandColor(randomColor[1], randomColor[2], randomColor[3])
    else
        SetBrandColor(HsvToRgb(hue, 0.6, 1))
    end
end

local sinceStep = 0
Brand:Hide()
Brand:SetScript("OnUpdate", function(_, elapsed)
    hue = (hue + elapsed / CYCLE_SECONDS) % 1
    sinceStep = sinceStep + elapsed
    if sinceStep < CYCLE_STEP then return end
    sinceStep = 0
    SetBrandColor(HsvToRgb(hue, 0.6, 1))
end)
Brand:RegisterEvent("PLAYER_LOGIN")
Brand:SetScript("OnEvent", function(self)
    self:Refresh()
end)
