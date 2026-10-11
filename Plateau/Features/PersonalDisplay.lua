local _, ns = ...

local BG_ATLAS = "UI-HUD-CoolDownManager-Bar-BG"
local TEXT_KEYS = { "TextString", "LeftText", "RightText" }

local PersonalDisplay = {}
ns.PersonalDisplay = PersonalDisplay

local skins = {}
local hooked = false

local function FindBackground(bar)
    for _, region in ipairs({ bar:GetRegions() }) do
        if region.GetAtlas and region:GetAtlas() == BG_ATLAS then
            return region
        end
    end
end

local function Skin(bar)
    local s = skins[bar]
    if s then return s end
    local fill = bar:GetStatusBarTexture()
    s = { atlas = fill and fill:GetAtlas(), blizzBackground = FindBackground(bar), fonts = {} }
    local layer = CreateFrame("Frame", nil, bar)
    layer:SetAllPoints()
    layer:SetFrameLevel(bar:GetFrameLevel() + 3)
    s.layer = layer
    s.border = ns.CreateBorder(layer, bar, "BACKGROUND", -7)
    s.background = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    s.background:SetAllPoints()
    for _, key in ipairs(TEXT_KEYS) do
        local text = bar[key]
        if text and text.GetFont then
            s.fonts[text] = { text:GetFont() }
        end
    end
    skins[bar] = s
    return s
end

local function Restore(bar, s)
    if not s.on then return end
    s.on = false
    ns.SetBarPattern(bar, nil)
    ns.SetBarOverlay(bar, nil)
    if s.atlas then
        bar:SetStatusBarTexture(s.atlas)
    end
    bar:GetStatusBarTexture():SetAlpha(1)
    bar:SetStatusBarDesaturated(false)
    if s.blizzBackground then
        s.blizzBackground:Show()
    end
    s.background:Hide()
    s.layer:Hide()
    for text, font in pairs(s.fonts) do
        if font[1] then
            text:SetFont(font[1], font[2], font[3])
        end
    end
end

local function ApplyTexture(bar, health)
    ns.SetBarTexture(bar, health.texture)
    bar:SetStatusBarDesaturated(health.desaturate == true)
    local overlay = health.overlayPattern ~= "" and health.overlayPattern or nil
    ns.SetBarOverlay(bar, overlay, health.overlayAlpha, health.overlayContrast)
end

local function Apply(bar, look)
    local s = Skin(bar)
    local health = look.health
    s.on = true
    ApplyTexture(bar, health)
    if s.blizzBackground then
        s.blizzBackground:Hide()
    end
    ns.SetBackgroundTexture(s.background, health.backgroundTexture, health.background)
    s.background:Show()
    s.layer:Show()
    s.border:SetStyle(health.borderStyle, s.layer)
    s.border:SetColor(health.border[1], health.border[2], health.border[3], health.border[4])
    s.border:Layout(health.borderSize, 0, health.borderInside)
    local text = look.healthText
    for fontString, font in pairs(s.fonts) do
        fontString:SetFont(text.font, font[2] or text.size, text.outline)
    end
end

local pips

local function LayoutPips()
    local count, look = pips.count, pips.look
    if not (count and look) then return end
    local health = look.health
    local spacing = look.classPower.spacing + (health.borderInside and 0 or health.borderSize * 2)
    local width = (pips:GetWidth() - (count - 1) * spacing) / count
    if width <= 0 then return end
    for i = 1, count do
        local pip = pips.bars[i]
        pip:ClearAllPoints()
        pip:SetSize(width, pips:GetHeight())
        pip:SetPoint("LEFT", (i - 1) * (width + spacing), 0)
        pip:Show()
    end
    for i = count + 1, #pips.bars do
        pips.bars[i]:Hide()
    end
end

local function Pips(frame)
    if pips then return pips end
    pips = CreateFrame("Frame", nil, frame.ClassFrameContainer)
    pips.bars = {}
    pips:SetScript("OnSizeChanged", LayoutPips)
    return pips
end

local function StylePips(frame, look, count)
    local holder = Pips(frame)
    local container = frame.ClassFrameContainer
    local health = look.health
    local outside = health.borderInside and 0 or health.borderSize
    holder:ClearAllPoints()
    holder:SetPoint("TOP", container, "TOP", 0, -(container.yOffset or 0) - outside)
    holder:SetPoint("LEFT", frame.HealthBarsContainer, "LEFT")
    holder:SetPoint("RIGHT", frame.HealthBarsContainer, "RIGHT")
    holder:SetHeight(frame.PowerBar:GetHeight())
    local red, green, blue = ns.ClassResource.Color(look.classPower)
    for i = 1, count do
        local pip = holder.bars[i]
        if not pip then
            pip = CreateFrame("StatusBar", nil, holder)
            holder.bars[i] = pip
        end
        Apply(pip, look)
        pip:SetStatusBarColor(red, green, blue, 1)
    end
    holder.count, holder.look = count, look
    LayoutPips()
end

local function RefreshPips()
    local frame = PersonalResourceDisplayFrame
    local classFrame = frame and frame.classFrame
    if not classFrame then return end
    local on = PersonalDisplay:IsOn()
    local count = on and ns.ClassResource.Count()
    classFrame:SetAlpha(count and 0 or 1)
    if not count then
        if pips then pips:Hide() end
        return
    end
    local look = ns.DB.views.enemy
    if not pips or pips.count ~= count or pips.look ~= look or pips.styled ~= pips.version then
        StylePips(frame, look, count)
        pips.styled = pips.version
    end
    ns.ClassResource.Fill(pips.bars, count)
    pips:Show()
end

local function Bars(frame)
    local container = frame.HealthBarsContainer
    return container and container.healthBar, frame.PowerBar, frame.AlternatePowerBar
end

function PersonalDisplay:IsOn()
    return ns.DB.saved.global.skinPersonal ~= false
end

function PersonalDisplay:SetOn(on)
    if on == false then
        ns.DB.saved.global.skinPersonal = false
    else
        ns.DB.saved.global.skinPersonal = nil
    end
    self:Update()
end

function PersonalDisplay:Update()
    local frame = PersonalResourceDisplayFrame
    if not (frame and ns.DB and ns.DB.saved and ns.DB.views) then return end
    local on = self:IsOn()
    local look = ns.DB.views.enemy
    if on and not hooked and frame.UpdateAlternatePowerBar then
        hooked = true
        hooksecurefunc(frame, "UpdateAlternatePowerBar", function()
            local alt = frame.AlternatePowerBar
            local s = alt and skins[alt]
            if s and s.on then
                ApplyTexture(alt, ns.DB.views.enemy.health)
            end
        end)
        if frame.SetupClassBar then
            hooksecurefunc(frame, "SetupClassBar", RefreshPips)
        end
    end
    local health, power, alt = Bars(frame)
    for _, bar in ipairs({ health, power, alt }) do
        if on then
            Apply(bar, look)
        elseif skins[bar] then
            Restore(bar, skins[bar])
        end
    end
    if ns.ClassResource then
        ns.ClassResource.Watch(on and RefreshPips or nil)
    end
    if pips then
        pips.version = (pips.version or 0) + 1
    end
    RefreshPips()
end

if ns.Driver and ns.Driver.OnRestyle then
    ns.Driver:OnRestyle(function()
        PersonalDisplay:Update()
    end)
end

if Plateau then
    Plateau.PersonalDisplay = PersonalDisplay
end
