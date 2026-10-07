local _, ns = ...

local CreateFrame = CreateFrame
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local InCombatLockdown = InCombatLockdown
local ShouldAurasBeSecret = C_Secrets and C_Secrets.ShouldAurasBeSecret
local issecretvalue = issecretvalue

local CreateCalculator = CreateUnitHealPredictionCalculator
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local ClampModes = Enum.UnitDamageAbsorbClampMode
local calculator = CreateCalculator and UnitGetDetailedHealPrediction and ClampModes and CreateCalculator()
local appliedClamp
local OVERSHIELD = "Interface\\RaidFrame\\Shield-Overshield"
local STRIPES = "Interface\\RaidFrame\\Shield-Overlay"
local SHIELD_FILL = "Interface\\RaidFrame\\Shield-Fill"
local FLAT = "Interface\\Buttons\\WHITE8X8"

local SLOTS = {
    { key = "magic", filter = "HELPFUL|DISPELLABLE|INCLUDE_NAME_PLATE_ONLY", candidates = { includeDispelTypes = { Magic = true } } },
    { key = "enrage", filter = "HELPFUL|DISPELLABLE|INCLUDE_NAME_PLATE_ONLY", candidates = { includeDispelTypes = { Enrage = true } } },
    { key = "defensive", filter = "HELPFUL|BIG_DEFENSIVE|INCLUDE_NAME_PLATE_ONLY" },
    { key = "important", filter = "HELPFUL|IMPORTANT|INCLUDE_NAME_PLATE_ONLY" },
}

local PREVIEW_TOGGLES = {
    important = "alertImportant",
    defensive = "alertDefensive",
    enrage = "alertEnrage",
    magic = "alertMagic",
}

local function AlertTexture(key)
    if key == "shield" then
        return STRIPES
    elseif key == "solid" then
        return FLAT
    end
    return ns.lineTextures[key] or ns.checkerTextures[key]
end

local function SetAlertFill(fill, config, c)
    local path = AlertTexture(config.alertTexture)
    if not path then
        fill:Hide()
        return false
    end
    local tiled = path ~= FLAT and path ~= ns.checkerTextures[config.alertTexture]
    fill:SetTexture(path, "REPEAT", "REPEAT")
    fill:SetHorizTile(tiled)
    fill:SetVertTile(tiled)
    if not tiled then
        fill:SetTexCoord(0, 1, 0, 1)
    end
    fill:SetVertexColor(c[1], c[2], c[3], config.alertTextureAlpha)
    return true
end

local ENRAGE_REMOVERS = { 2908, 19801, 5938 }
local MAGIC_REMOVERS = { 370, 378773, 528, 278326, 30449, 19801 }
local PET_MAGIC_REMOVERS = { 19505 }
local canRemove = { enrage = false, magic = false }

local function KnowsAny(list, bank)
    for i = 1, #list do
        if ns.FindKnownSpell(list[i], bank) then
            return true
        end
    end
    return false
end

local DEFAULT_ORDER = { "important", "defensive", "enrage", "magic" }
local orders = {}

local function Priority(config)
    local text = config.alertOrder
    local order = orders[text]
    if order then
        return order
    end
    local ranks, list, seen = {}, {}, {}
    for key in tostring(text):gmatch("%a+") do
        if not seen[key] and PREVIEW_TOGGLES[key] then
            seen[key] = true
            list[#list + 1] = key
        end
    end
    for _, key in ipairs(DEFAULT_ORDER) do
        if not seen[key] then
            list[#list + 1] = key
        end
    end
    for rank, key in ipairs(list) do
        ranks[key] = rank
    end
    order = { ranks = ranks, list = list }
    orders[text] = order
    return order
end

local configs = {}
local dirtySlots = {}
local queuedSlots = {}
local dirtyOrder = {}
local FLUSH_BATCH = 8

local Shield = {
    key = "shield",
    sizeDependent = true,
    events = { "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_MAXHEALTH", "UNIT_HEALTH" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Shield = Shield

local function Restricted()
    return InCombatLockdown() or (ShouldAurasBeSecret and ShouldAurasBeSecret())
end

local function StyleSlot(button)
    local plate = button.plate
    local config = configs[plate.state]
    button:SetSize(1, 1)
    button:ClearAllPoints()
    button:SetPoint("CENTER", plate)
    button:EnableMouseMotion(false)
    button.glow:Layout(config.alertSize, ns.HealthBorderOffset(ns.DB.views[plate.state]))
    local key = button.slotKey
    local c = (key == "enrage" and config.enrageColor) or (key == "magic" and config.magicColor)
        or (key == "defensive" and config.defensiveColor) or config.alertColor
    button.glow:SetColor(c[1], c[2], c[3], c[4])
    local wanted = Shield:SlotWanted(config, key)
    button.fill:SetShown(SetAlertFill(button.fill, config, c) and wanted)
    button.glow:SetShown(wanted)
    local parent = button:GetParent()
    if parent then
        pcall(button.SetFrameLevel, button, parent:GetFrameLevel() + 1 + (#DEFAULT_ORDER - Priority(config).ranks[key]) * 10)
    end
end

local function MarkSlotDirty(button)
    dirtySlots[button] = true
    if not queuedSlots[button] then
        queuedSlots[button] = true
        dirtyOrder[#dirtyOrder + 1] = button
    end
end

local function FlushDirtySlots()
    if Restricted() then return end
    local processed = 0
    while #dirtyOrder > 0 and processed < FLUSH_BATCH do
        local button = table.remove(dirtyOrder)
        queuedSlots[button] = nil
        if dirtySlots[button] and button.plate.active then
            dirtySlots[button] = nil
            StyleSlot(button)
        end
        processed = processed + 1
    end
    if #dirtyOrder > 0 then
        C_Timer.After(0, FlushDirtySlots)
    end
end

local function SlotInitializer(plate, slotKey)
    return function(button)
        if button.plateauInit then return end
        button.plateauInit = true
        if ns.CountAuraButton then
            ns.CountAuraButton()
        end
        button.plate = plate
        button.slotKey = slotKey
        plate.shieldSlots[#plate.shieldSlots + 1] = button

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetAlpha(0)
        button.icon = icon
        button.glow = ns.CreateBorder(button, plate, "OVERLAY", 3)
        button.glow.restricted = true
        button.fill = button:CreateTexture(nil, "BACKGROUND")
        button.fill:SetAllPoints(plate.health)
        button.fill:Hide()

        button:SetIcon(icon)
        if configs[plate.state] then
            StyleSlot(button)
        end
    end
end

function Shield:Create(plate)
    plate.shieldSlots = {}
    local absorb = CreateFrame("StatusBar", nil, plate.health)
    absorb:SetStatusBarTexture(SHIELD_FILL)
    absorb:SetMinMaxValues(0, 1)
    absorb:SetValue(0)
    plate.health:SetClipsChildren(true)
    plate.absorb = absorb

    local glow = plate.overlay:CreateTexture(nil, "ARTWORK")
    glow:SetTexture(OVERSHIELD)
    glow:SetBlendMode("ADD")
    glow:SetPoint("TOPLEFT", plate.health, "TOPRIGHT", -4, 1)
    glow:SetPoint("BOTTOMLEFT", plate.health, "BOTTOMRIGHT", -4, -1)
    glow:SetWidth(12)
    glow:Hide()
    plate.absorbGlow = glow

    local container = CreateFrame("AuraContainer", nil, plate.overlay, "CustomAuraContainerTemplate")
    container:SetEnabled(false)
    container:SetPoint("CENTER", plate)
    for _, slot in ipairs(SLOTS) do
        container:AddAuraSlot(slot.key, slot.filter, { initializeFrame = SlotInitializer(plate, slot.key), candidateFilters = slot.candidates })
    end
    plate.shieldContainer = container

    plate.shieldPreview = ns.CreateBorder(plate.overlay, plate, "OVERLAY", 3)
    plate.shieldPreview:Hide()
    plate.shieldPreviewFill = plate.overlay:CreateTexture(nil, "BACKGROUND")
    plate.shieldPreviewFill:SetAllPoints(plate.health)
    plate.shieldPreviewFill:Hide()
end

function Shield:SlotWanted(config, key)
    if key == "important" then
        return config.alertImportant == true
    elseif key == "defensive" then
        return config.alertDefensive == true
    elseif key == "enrage" then
        return config.alertEnrage == true and (canRemove.enrage or not config.alertOnlyMine)
    elseif key == "magic" then
        return config.alertMagic == true and (canRemove.magic or not config.alertOnlyMine)
    end
    return false
end

function Shield:AnyWanted(config)
    for _, slot in ipairs(SLOTS) do
        if self:SlotWanted(config, slot.key) then
            return true
        end
    end
    return false
end

function Shield:Configure(db, state)
    configs[state] = db
end

function Shield:Style(plate, db)
    local absorb = plate.absorb
    local reverse = ns.DB.views[plate.state].health.fillDirection == "right"
    local near, far = reverse and "LEFT" or "RIGHT", reverse and "RIGHT" or "LEFT"
    absorb:ClearAllPoints()
    if db.absorbPosition == "after" then
        local fill = plate.health:GetStatusBarTexture()
        absorb:SetPoint("TOP" .. far, fill, "TOP" .. near)
        absorb:SetPoint("BOTTOM" .. far, fill, "BOTTOM" .. near)
        absorb:SetWidth(plate:GetWidth())
        absorb:SetReverseFill(reverse)
    else
        absorb:SetAllPoints(plate.health)
        absorb:SetReverseFill(not reverse)
    end
    local glow = plate.absorbGlow
    glow:ClearAllPoints()
    local inset = reverse and 4 or -4
    glow:SetPoint("TOP" .. far, plate.health, "TOP" .. near, inset, 1)
    glow:SetPoint("BOTTOM" .. far, plate.health, "BOTTOM" .. near, inset, -1)
    glow:SetWidth(12)
    if reverse then
        glow:SetTexCoord(1, 0, 0, 1)
    else
        glow:SetTexCoord(0, 1, 0, 1)
    end
    local c = db.absorbColor
    local style = db.absorbStyle
    if style == "blizzard" then
        ns.SetBarTexture(absorb, SHIELD_FILL)
        absorb:SetStatusBarColor(c[1], c[2], c[3], c[4])
        ns.SetBarPattern(absorb, STRIPES, 20, false, 1, 1, 1, c[4])
    elseif style == "stripes" or ns.lineTextures[style] then
        ns.SetBarTexture(absorb, FLAT)
        absorb:GetStatusBarTexture():SetAlpha(0)
        ns.SetBarPattern(absorb, ns.lineTextures[style] or STRIPES, ns.lineTextures[style] and 64 or 20, false, c[1], c[2], c[3], c[4])
    else
        ns.SetBarTexture(absorb, style == "solid" and FLAT or style)
        absorb:SetStatusBarColor(c[1], c[2], c[3], c[4])
    end

    local container = plate.shieldContainer
    if container.SetAuraSlotEnabled then
        for _, slot in ipairs(SLOTS) do
            container:SetAuraSlotEnabled(slot.key, self:SlotWanted(db, slot.key))
        end
    end

    plate.shieldPreview:Layout(db.alertSize, ns.HealthBorderOffset(ns.DB.views[plate.state]))
    local a = db.alertColor
    plate.shieldPreview:SetColor(a[1], a[2], a[3], a[4])
    plate.shieldPreviewFill.wanted = SetAlertFill(plate.shieldPreviewFill, db, a)
    if Restricted() then
        for i = 1, #plate.shieldSlots do
            MarkSlotDirty(plate.shieldSlots[i])
        end
    else
        for i = 1, #plate.shieldSlots do
            local button = plate.shieldSlots[i]
            dirtySlots[button] = nil
            StyleSlot(button)
        end
    end
end

function Shield:Enable(plate, unit)
    local config = configs[plate.state]
    plate.shieldPreview:Hide()
    plate.shieldPreviewFill:Hide()
    plate.absorb:SetShown(config.absorbs)
    plate.absorbGlow:SetShown(config.absorbs and config.absorbGlow and config.absorbPosition == "after")
    self:Update(plate, unit)
    local container = plate.shieldContainer
    if container.currentUnit ~= unit then
        container.currentUnit = unit
        container:SetUnit(unit)
    end
    local on = self:AnyWanted(config)
    if container.isOn ~= on then
        container.isOn = on
        container:SetEnabled(on)
    end
    for i = 1, #plate.shieldSlots do
        local button = plate.shieldSlots[i]
        if dirtySlots[button] then
            if Restricted() then
                MarkSlotDirty(button)
            else
                dirtySlots[button] = nil
                StyleSlot(button)
            end
        end
    end
end

function Shield:Disable(plate)
    plate.absorb:Hide()
    plate.absorbGlow:Hide()
    plate.shieldContainer:SetEnabled(false)
    plate.shieldContainer.isOn = false
    plate.shieldContainer.currentUnit = nil
    plate.shieldPreview:Hide()
    plate.shieldPreviewFill:Hide()
end

function Shield:OnEvent(plate, event, unit)
    self:Update(plate, unit, event)
end

function Shield:Update(plate, unit, event)
    local config = configs[plate.state]
    if not config.absorbs then return end
    local after = config.absorbPosition == "after"
    if event == "UNIT_HEALTH" and not (after and calculator) then return end
    local absorb = plate.absorb
    local max = UnitHealthMax(unit)
    if issecretvalue(max) then
        plate.shieldMax = nil
        absorb:SetMinMaxValues(0, max)
    elseif plate.shieldMax ~= max then
        plate.shieldMax = max
        absorb:SetMinMaxValues(0, max)
    end
    if not calculator then
        absorb:SetValue(UnitGetTotalAbsorbs(unit))
        return
    end
    local clamp = after and ClampModes.MissingHealthWithoutIncomingHeals or ClampModes.MaximumHealth
    if clamp ~= appliedClamp then
        appliedClamp = clamp
        calculator:SetDamageAbsorbClampMode(clamp)
    end
    UnitGetDetailedHealPrediction(unit, nil, calculator)
    local amount, clamped = calculator:GetDamageAbsorbs()
    absorb:SetValue(amount)
    if after and config.absorbGlow then
        plate.absorbGlow:SetAlphaFromBoolean(clamped, 1, 0)
    end
end

function Shield:Preview(plate, state)
    local config = configs[plate.state]
    plate.shieldContainer:SetEnabled(false)
    plate.shieldContainer.isOn = false
    plate.shieldContainer.currentUnit = nil
    local absorb = plate.absorb
    absorb:SetShown(config.absorbs)
    absorb:SetMinMaxValues(0, 1)
    local amount = state.absorb or 0
    local after = config.absorbPosition == "after"
    local missing = 1 - (state.health or 1)
    if after and amount > missing then
        absorb:SetValue(missing)
    else
        absorb:SetValue(amount)
    end
    plate.absorbGlow:SetShown(config.absorbs and config.absorbGlow and after and amount > missing)
    local alerts = state.alerts
    local key
    if alerts then
        for _, slotKey in ipairs(Priority(config).list) do
            if alerts[slotKey] and config[PREVIEW_TOGGLES[slotKey]] then
                key = slotKey
                break
            end
        end
    end
    if not key then
        plate.shieldPreview:Hide()
        plate.shieldPreviewFill:Hide()
        return
    end
    local c = (key == "enrage" and config.enrageColor) or (key == "magic" and config.magicColor)
        or (key == "defensive" and config.defensiveColor) or config.alertColor
    plate.shieldPreview:SetColor(c[1], c[2], c[3], c[4])
    plate.shieldPreview:Show()
    plate.shieldPreviewFill:SetShown(SetAlertFill(plate.shieldPreviewFill, config, c))
end

local abilities = CreateFrame("Frame")
abilities:RegisterEvent("PLAYER_LOGIN")
abilities:RegisterEvent("SPELLS_CHANGED")
abilities:RegisterUnitEvent("UNIT_PET", "player")
abilities:SetScript("OnEvent", function()
    local enrage = KnowsAny(ENRAGE_REMOVERS, Enum.SpellBookSpellBank.Player)
    local magic = KnowsAny(MAGIC_REMOVERS, Enum.SpellBookSpellBank.Player) or KnowsAny(PET_MAGIC_REMOVERS, Enum.SpellBookSpellBank.Pet)
    if enrage ~= canRemove.enrage or magic ~= canRemove.magic then
        canRemove.enrage, canRemove.magic = enrage, magic
        if configs.enemy then
            ns.Driver:RequestRestyle(true)
        end
    end
end)

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
if C_EventUtils.IsEventValid("ADDON_RESTRICTION_STATE_CHANGED") then
    watcher:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
end
watcher:SetScript("OnEvent", function()
    if #dirtyOrder > 0 and configs.enemy then
        FlushDirtySlots()
    end
end)

ns.Driver:RegisterElement(Shield)
