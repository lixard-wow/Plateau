local _, ns = ...

local UnitName = UnitName
local UnitClassBase = UnitClassBase
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local EvaluateColorValueFromBoolean = C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean
local issecretvalue = issecretvalue

local settings = {}
local tokens = {}

local REFRESH = 0.25

local EnemyTarget = {
    key = "enemyTarget",
    events = { "UNIT_TARGET", "UNIT_THREAT_LIST_UPDATE", "UNIT_FLAGS" },
}
ns.Elements = ns.Elements or {}
ns.Elements.EnemyTarget = EnemyTarget

local function Token(unit)
    local token = tokens[unit]
    if not token then
        token = unit .. "target"
        tokens[unit] = token
    end
    return token
end

function EnemyTarget:Create(plate)
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.enemyTarget = text
end

function EnemyTarget:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.classColors = db.classColors
    s.color = db.color
    s.meColor = db.meColor == true and EvaluateColorValueFromBoolean ~= nil
    s.meColorValue = db.meColorValue
end

function EnemyTarget:Style(plate, db)
    local text = plate.enemyTarget
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
    ns.PlaceText(text, plate.health, db.anchor, 3, db.offsetX, db.offsetY)
end

function EnemyTarget:Enable(plate, unit)
    self:Update(plate, unit)
end

function EnemyTarget:Disable(plate)
    plate.enemyTargetFilled = false
    plate.enemyTarget:Hide()
end

local function Covered(plate)
    local bar = plate.castbar
    return not plate.enemyTargetPreview and bar ~= nil and bar:IsShown() and bar.target:IsShown()
end

function EnemyTarget:RefreshShown(plate)
    plate.enemyTarget:SetShown(plate.enemyTargetFilled == true and not Covered(plate))
end

function EnemyTarget:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

local function BaseColor(s, class)
    if s.classColors and class and RAID_CLASS_COLORS then
        local classColor = RAID_CLASS_COLORS[class]
        if classColor then
            return classColor.r, classColor.g, classColor.b, 1
        end
    end
    local color = s.color
    return color[1], color[2], color[3], color[4]
end

local function Paint(text, s, class, isMe)
    local r, g, b, a = BaseColor(s, class)
    if s.meColor and (issecretvalue(isMe) or isMe ~= nil) then
        local me = s.meColorValue
        r = EvaluateColorValueFromBoolean(isMe, me[1], r)
        g = EvaluateColorValueFromBoolean(isMe, me[2], g)
        b = EvaluateColorValueFromBoolean(isMe, me[3], b)
        a = EvaluateColorValueFromBoolean(isMe, me[4], a)
    end
    text:SetTextColor(r, g, b, a)
end

function EnemyTarget:Update(plate, unit)
    local text = plate.enemyTarget
    if plate.isFriendly then
        plate.enemyTargetFilled = false
        text:Hide()
        return
    end
    local token = Token(unit)
    local name = ns.CleanName(UnitName(token))
    if not issecretvalue(name) and not name then
        plate.enemyTargetFilled = false
        text:Hide()
        return
    end
    local s = settings[plate.state]
    local isPlayer = UnitIsPlayer(token)
    local class = (not issecretvalue(isPlayer) and isPlayer) and ns.UnitColors:PlayerClass(token) or nil
    if issecretvalue(class) then
        class = nil
    end
    local isMe
    if s.meColor then
        local ok, result = pcall(UnitIsUnit, token, "player")
        if ok then
            isMe = result
        end
    end
    Paint(text, s, class, isMe)
    text:SetText(name)
    plate.enemyTargetFilled = true
    self:RefreshShown(plate)
end

function EnemyTarget:Preview(plate, state)
    local text = plate.enemyTarget
    if state.isFriendly then
        plate.enemyTargetFilled = false
        text:Hide()
        return
    end
    Paint(text, settings[plate.state], state.enemyTargetClass or UnitClassBase("player"), state.enemyTargetName == nil)
    text:SetText(state.enemyTargetName or UnitName("player"))
    plate.enemyTargetPreview = true
    plate.enemyTargetFilled = true
    self:RefreshShown(plate)
end

local function RefreshOne(plate)
    if ns.Runs(EnemyTarget, plate) and plate.unit then
        EnemyTarget:Update(plate, plate.unit)
    end
end

local function RefreshAll()
    ns.Driver:ForEachActive(RefreshOne)
end

local refresher = CreateFrame("Frame")
refresher:Hide()
local elapsedSince = 0
refresher:SetScript("OnUpdate", function(_, elapsed)
    elapsedSince = elapsedSince + elapsed
    if elapsedSince < REFRESH then return end
    elapsedSince = 0
    RefreshAll()
end)
refresher:RegisterEvent("PLAYER_REGEN_DISABLED")
refresher:RegisterEvent("PLAYER_REGEN_ENABLED")
refresher:SetScript("OnEvent", function(self, event)
    if ns.disabled then return end
    if event == "PLAYER_REGEN_DISABLED" and EnemyTarget.enabled then
        elapsedSince = 0
        self:Show()
    else
        self:Hide()
    end
    if EnemyTarget.enabled then
        RefreshAll()
    end
end)

ns.Driver:RegisterElement(EnemyTarget)
