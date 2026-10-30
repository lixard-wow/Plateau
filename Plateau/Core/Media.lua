local addonName, ns = ...

local issecretvalue = issecretvalue
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
}

ns.media = LibStub and LibStub("LibSharedMedia-3.0", true)
if ns.media then
    for _, texture in ipairs(ns.barTextures) do
        ns.media:Register(ns.media.MediaType.STATUSBAR, texture.label, texture.value)
    end
end

local TILE = 64

local function SpanBar(clip, bar, layer, sublevel)
    local texture = clip:CreateTexture(nil, layer, nil, sublevel)
    texture:SetPoint("TOPLEFT", bar, "TOPLEFT")
    texture:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
    return texture
end

local function NewClip(bar, field, layer, makeMirror)
    local clip = CreateFrame("Frame", nil, bar)
    clip:SetClipsChildren(true)
    local texture = SpanBar(clip, bar, layer)
    clip.texture = texture
    bar[field] = clip
    bar:HookScript("OnSizeChanged", function(_, width, height)
        if clip.tile and not issecretvalue(width) and not issecretvalue(height) then
            texture:SetTexCoord(0, math.max(width, 1) / clip.tile, 0, math.max(height, 1) / clip.tile)
        end
    end)
    local mirror = makeMirror(clip, bar)
    hooksecurefunc(bar, "SetStatusBarColor", mirror)
    hooksecurefunc(bar:GetStatusBarTexture(), "SetVertexColor", mirror)
    return clip
end

local function TileCoords(bar, texture, tile, widthKey, heightKey)
    local width, height = bar:GetSize()
    if issecretvalue(width) or issecretvalue(height) then
        width, height = bar[widthKey] or 128, bar[heightKey] or 16
    else
        bar[widthKey], bar[heightKey] = width, height
    end
    texture:SetTexCoord(0, math.max(width, 1) / tile, 0, math.max(height, 1) / tile)
end

local function PatternMirror(clip)
    local texture = clip.texture
    return function(_, ...)
        if clip.mirror then
            texture:SetVertexColor(...)
        end
    end
end

local function EnsurePattern(bar)
    return bar.patternClip or NewClip(bar, "patternClip", "ARTWORK", PatternMirror)
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
    TileCoords(bar, clip.texture, tile, "patternWidth", "patternHeight")
    if clip.mirror then
        clip.texture:SetVertexColor(fill:GetVertexColor())
    else
        clip.texture:SetVertexColor(r, g, b, a)
    end
    clip:Show()
end

local OVERLAY_MID = 178.5 / 255

local function OverlayMirror(clip, bar)
    local texture = clip.texture
    local veil = SpanBar(clip, bar, "OVERLAY", -1)
    veil:SetTexture(FLAT)
    clip.veil = veil
    return function(_, r, g, b, a)
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
end

local function EnsureOverlay(bar)
    return bar.overlayClip or NewClip(bar, "overlayClip", "OVERLAY", OverlayMirror)
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
        clip.tile, clip.alpha = TILE, alpha
        TileCoords(bar, clip.texture, TILE, "overlayWidth", "overlayHeight")
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
        ns.SetBarPattern(bar, value, TILE, true)
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

local THEME_FONTS = { "IBMPlexSansCondensed-Medium", "IBMPlexSansCondensed-SemiBold", "AlegreyaSC-Bold" }
local fontsWarmed = false

function ns.WarmThemeFonts()
    if fontsWarmed then return end
    fontsWarmed = true
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

local ALPHABETS = {
    { "korean", "Fonts\\2002.TTF" },
    { "simplifiedchinese", "Fonts\\ARKai_T.ttf" },
    { "traditionalchinese", "Fonts\\blei00d.TTF" },
    { "russian", "Fonts\\FRIZQT___CYR.TTF" },
}
local families = {}
local familyCount = 0

local function Family(file, size, flags)
    if not CreateFontFamily then return nil end
    local key = file .. "|" .. size .. "|" .. (flags or "")
    local family = families[key]
    if family == nil then
        local members = { { alphabet = "roman", file = file, height = size, flags = flags or "" } }
        for _, entry in ipairs(ALPHABETS) do
            members[#members + 1] = { alphabet = entry[1], file = entry[2], height = size, flags = flags or "" }
        end
        familyCount = familyCount + 1
        local ok, created = pcall(CreateFontFamily, "PlateauFontFamily" .. familyCount, members)
        family = ok and created or false
        if not ok then
            ns.fontFamilyProblem = created
        end
        families[key] = family
    end
    return family or nil
end

local function UseFamily(fontString, file, size, flags)
    local family = Family(file, size, flags)
    if not family then return end
    local r, g, b, a = fontString:GetTextColor()
    local justifyH, justifyV = fontString:GetJustifyH(), fontString:GetJustifyV()
    fontString:SetFontObject(family)
    fontString:SetTextColor(r, g, b, a)
    fontString:SetJustifyH(justifyH)
    fontString:SetJustifyV(justifyV)
    if fontString.plShadow ~= nil then
        local shadow = fontString.plShadow
        fontString.plShadow = nil
        ns.ApplyShadow(fontString, shadow)
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
            UseFamily(fontString, request.file, request.size, request.flags)
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
    if fontString.plFontFile == file and fontString.plFontSize == size and fontString.plFontFlags == flags then
        return
    end
    fontString.plFontFile, fontString.plFontSize, fontString.plFontFlags = file, size, flags
    if fontString:SetFont(file, size, flags) then
        pending[fontString] = nil
        UseFamily(fontString, file, size, flags)
        return
    end
    pending[fontString] = { file = file, size = size, flags = flags, tries = 0 }
    if not scheduled then
        scheduled = true
        C_Timer.After(RETRY_DELAY, Retry)
    end
end

function ns.ApplyShadow(fontString, enabled)
    if fontString.plShadow == enabled then return end
    fontString.plShadow = enabled
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

local Brand = {}
ns.Brand = Brand

local OCHRE = { 0xd0 / 255, 0x7a / 255, 0x3c / 255 }

function Brand:Color()
    return OCHRE[1], OCHRE[2], OCHRE[3]
end

function Brand:Text(text)
    return "|cffd07a3c" .. text .. "|r"
end

function Brand:OnChange(callback)
    callback(OCHRE[1], OCHRE[2], OCHRE[3])
end
