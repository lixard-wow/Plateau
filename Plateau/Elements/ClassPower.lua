local _, ns = ...

local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerDisplayMod = UnitPowerDisplayMod
local GetRuneCooldown = GetRuneCooldown
local UnitClassBase = UnitClassBase
local UnitPowerType = UnitPowerType
local issecretvalue = issecretvalue

local POWER = Enum.PowerType
local WHITE = "Interface\\Buttons\\WHITE8X8"
local MAX_PIPS = 8
local RUNES = "runes"

local BY_CLASS = {
    ROGUE = POWER.ComboPoints,
    DRUID = POWER.ComboPoints,
    PALADIN = POWER.HolyPower,
    WARLOCK = POWER.SoulShards,
    MONK = POWER.Chi,
    MAGE = POWER.ArcaneCharges,
    EVOKER = POWER.Essence,
    DEATHKNIGHT = RUNES,
}

local DEFAULT_MAX = {
    [POWER.ComboPoints] = 5,
    [POWER.HolyPower] = 5,
    [POWER.SoulShards] = 5,
    [POWER.Chi] = 5,
    [POWER.ArcaneCharges] = 4,
    [POWER.Essence] = 5,
    [RUNES] = 6,
}

local RESOURCE_TOKEN = {
    [POWER.ComboPoints] = "COMBO_POINTS",
    [POWER.HolyPower] = "HOLY_POWER",
    [POWER.SoulShards] = "SOUL_SHARDS",
    [POWER.Chi] = "CHI",
    [POWER.ArcaneCharges] = "ARCANE_CHARGES",
    [POWER.Essence] = "ESSENCE",
}

local ONLY_SPECS = {
    MONK = { [269] = true },
    MAGE = { [62] = true },
}

local NEEDS_CAT_FORM = { DRUID = true }

local resource, resourceMax, displayMod, needsCat

local ClassPower = {
    key = "classPower",
}
ns.Elements = ns.Elements or {}
ns.Elements.ClassPower = ClassPower

local function Detect()
    local class = UnitClassBase("player")
    resource = not issecretvalue(class) and class and BY_CLASS[class] or nil
    resourceMax, displayMod = nil, 1
    needsCat = class and NEEDS_CAT_FORM[class] or false
    local only = class and ONLY_SPECS[class]
    if resource and only then
        local spec = ns.CurrentSpec()
        if spec ~= 0 and not only[spec] then
            resource = nil
        end
    end
    if not resource then return end
    if resource == RUNES then
        resourceMax = 6
        return
    end
    local max = UnitPowerMax("player", resource)
    if issecretvalue(max) or not max or max <= 0 then
        resourceMax = DEFAULT_MAX[resource]
    else
        resourceMax = max
    end
    displayMod = UnitPowerDisplayMod and UnitPowerDisplayMod(resource) or 1
    if issecretvalue(displayMod) or not displayMod or displayMod <= 0 then
        displayMod = 1
    end
end

function ClassPower:Create(plate)
    local holder = CreateFrame("Frame", nil, plate.overlay)
    holder:Hide()
    holder.pips = {}
    holder.glow = ns.CreateBorder(holder, holder, "BACKGROUND", -8)
    holder.glow:Hide()
    plate.classPower = holder
end

local function Pip(holder, index)
    local pip = holder.pips[index]
    if pip then return pip end
    pip = CreateFrame("StatusBar", nil, holder)
    pip:SetStatusBarTexture(WHITE)
    pip.back = pip:CreateTexture(nil, "BACKGROUND")
    pip.back:SetAllPoints()
    pip.back:SetTexture(WHITE)
    holder.pips[index] = pip
    return pip
end

local function Colors(db)
    local color = db.color
    if db.classColor then
        local swatch = ns.ClassColor(UnitClassBase("player"))
        if swatch then
            return swatch.r, swatch.g, swatch.b
        end
    end
    return color[1], color[2], color[3]
end

local function Layout(plate, db, count)
    local holder = plate.classPower
    local width = db.pipWidth
    local height = db.pipHeight
    local spacing = ns.WholePixels(holder, db.spacing)
    height = ns.WholePixels(holder, height, 1)
    if not width or width <= 0 then
        local view = ns.DB.views[plate.state]
        local total = view.plate.width * (plate.idleW or 1) * (plate.simplifiedSize or 1)
        local pixel = ns.pixelPerfect and ns.PixelUnit(holder) or nil
        width = math.max(1, (total - (count - 1) * spacing) / count)
        if pixel then
            width = math.max(1, math.floor(width / pixel)) * pixel
        end
    else
        width = ns.WholePixels(holder, width, 1)
    end
    holder:SetSize(count * width + (count - 1) * spacing, height)
    ns.PlaceIcon(holder, plate, db.position, db.gap, db.offsetX, db.offsetY)
    holder:SetAlpha(db.alpha)
    local red, green, blue = Colors(db)
    local empty = db.emptyColor
    for i = 1, count do
        local pip = Pip(holder, i)
        pip:ClearAllPoints()
        pip:SetSize(width, height)
        pip:SetPoint("LEFT", (i - 1) * (width + spacing), 0)
        pip:SetStatusBarColor(red, green, blue, 1)
        pip.back:SetVertexColor(empty[1], empty[2], empty[3], empty[4])
        pip:Show()
    end
    for i = count + 1, #holder.pips do
        holder.pips[i]:Hide()
    end
    holder.count = count
    holder.glow:Layout(6, 0)
    holder.glow:SetFade(red, green, blue, 0.9)
end

function ClassPower:Style(plate, db)
    if plate.classPower.count then
        Layout(plate, db, plate.classPower.count)
    end
end

local function ActiveCount()
    if not resource then return nil end
    if needsCat then
        local power = UnitPowerType("player")
        if issecretvalue(power) or power ~= POWER.Energy then
            return nil
        end
    end
    if resource ~= RUNES then
        local max = UnitPowerMax("player", resource)
        if not issecretvalue(max) and max and max > 0 then
            resourceMax = max
        end
    end
    return math.min(resourceMax or DEFAULT_MAX[resource], MAX_PIPS)
end

local function FillPips(pips, count)
    if resource == RUNES then
        for i = 1, count do
            local pip = pips[i]
            local _, _, ready = GetRuneCooldown(i)
            pip:SetMinMaxValues(0, 1)
            pip:SetValue(1)
            if issecretvalue(ready) then
                pip:SetAlphaFromBoolean(ready, 1, 0.3)
            else
                pip:SetAlpha(ready and 1 or 0.3)
            end
        end
        return nil
    end
    local value = UnitPower("player", resource, true)
    for i = 1, count do
        local pip = pips[i]
        pip:SetMinMaxValues((i - 1) * displayMod, i * displayMod)
        pip:SetValue(value)
        pip:SetAlpha(1)
    end
    return not issecretvalue(value) and value or nil
end

function ClassPower:Update(plate)
    local holder = plate.classPower
    local db = ns.DB.views[plate.state].classPower
    if not (resource and plate.isTarget and not plate.isFriendly and db.enabled) then
        holder:Hide()
        return
    end
    local count = ActiveCount()
    if not count then
        holder:Hide()
        return
    end
    if holder.count ~= count or holder.styledFor ~= db then
        holder.styledFor = db
        Layout(plate, db, count)
    end
    local known = FillPips(holder.pips, count)
    if resource ~= RUNES then
        if db.hideEmpty and known and known <= 0 then
            holder:Hide()
            return
        end
        holder.glow:SetShown(db.glowMax == true and known and known >= count * displayMod or false)
    end
    holder:Show()
end

function ClassPower:Enable(plate)
    self:Update(plate)
end

function ClassPower:Disable(plate)
    plate.classPower:Hide()
end

function ClassPower:OnEvent()
end

function ClassPower:UpdateEmphasis(plate)
    self:Update(plate)
end

function ClassPower:Preview(plate, state)
    local holder = plate.classPower
    local db = ns.DB.views[plate.state].classPower
    if not (state.classPower and db.enabled) then
        holder:Hide()
        return
    end
    local count = resourceMax or 5
    Layout(plate, db, count)
    for i = 1, count do
        local pip = holder.pips[i]
        pip:SetMinMaxValues(0, 1)
        pip:SetValue(i <= math.ceil(count * 0.6) and 1 or 0)
        pip:SetAlpha(1)
    end
    holder.glow:Hide()
    holder:Show()
end

local listener = CreateFrame("Frame")
local armed = false

local function Unlisten()
    listener:UnregisterEvent("UNIT_POWER_UPDATE")
    listener:UnregisterEvent("UNIT_MAXPOWER")
    listener:UnregisterEvent("RUNE_POWER_UPDATE")
    listener:UnregisterEvent("UNIT_DISPLAYPOWER")
end

local function Arm()
    local want = ClassPower.enabled == true and resource ~= nil
    if want == armed then return end
    armed = want
    if want then
        listener:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
        listener:RegisterUnitEvent("UNIT_MAXPOWER", "player")
        listener:RegisterEvent("RUNE_POWER_UPDATE")
        if needsCat then
            listener:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
        end
    else
        Unlisten()
    end
end

function ClassPower:Configured()
    Arm()
end

listener:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
listener:RegisterEvent("PLAYER_TALENT_UPDATE")
listener:RegisterEvent("PLAYER_ENTERING_WORLD")
listener:SetScript("OnEvent", function(_, event, unit, powerToken)
    if ns.disabled then return end
    if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
        if resource and resource ~= RUNES then
            local token = RESOURCE_TOKEN[resource]
            if token and powerToken and powerToken ~= token then return end
        end
    elseif event ~= "RUNE_POWER_UPDATE" and event ~= "UNIT_DISPLAYPOWER" then
        Detect()
        armed = false
        Unlisten()
        Arm()
    end
    local plate = ns.Driver:GetPlate("target")
    if plate and plate.built[ClassPower] then
        ClassPower:Update(plate)
    end
end)

Detect()

ns.Driver:RegisterElement(ClassPower)
