local _, ns = ...

local UnitAffectingCombat = UnitAffectingCombat

local settings = {}
local version = 0

local HIDE_KEYS = { "auras", "healthText", "name", "level", "classification", "raidMarker", "quest", "forces", "enemyPower", "enemyTarget", "castbar" }

local Idle = {
    key = "idle",
    events = { "UNIT_FLAGS" },
}
ns.Idle = Idle

local function IsIdle(plate)
    local s = settings[plate.state]
    return s ~= nil
        and Idle.enabledIn[plate.state]
        and (not s.instancesOnly or IsInInstance() == true)
        and plate.unit ~= nil
        and not plate.isFriendly
        and not plate.isPlayer
        and not plate.isTarget
        and not UnitAffectingCombat(plate.unit)
end

function Idle:Color(plate)
    if not plate.idle then return nil end
    local s = settings[plate.state]
    return s and s.colorBar and s.color or nil
end

local function Refresh(plate)
    local idle = IsIdle(plate) and true or false
    if (plate.idle or false) == idle and plate.idleVersion == version then return end
    plate.idle = idle
    plate.idleVersion = version
    local s = settings[plate.state]
    plate.idleAlpha = idle and s.alpha or 1
    ns.Driver:RefreshAlpha(plate)
    ns.Driver:SetHidden(plate, idle and s.hide or nil)
    local width, height = idle and s.widthScale or 1, idle and s.heightScale or 1
    if (plate.idleW or 1) ~= width or (plate.idleH or 1) ~= height then
        plate.idleW, plate.idleH = width, height
        ns.Driver:ResizeNow(plate)
    end
    local colored = idle and s ~= nil and s.colorBar == true
    if plate.unit and (colored or plate.idleColored) then
        plate.idleColored = colored
        ns.Elements.Health:UpdateColor(plate, plate.unit)
    end
end

function Idle:Create(plate)
end

function Idle:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.alpha = db.alpha
    s.widthScale = db.widthScale
    s.heightScale = db.heightScale
    s.colorBar = db.colorBar
    s.color = db.color
    s.instancesOnly = db.instancesOnly == true
    local hide = {}
    for _, key in ipairs(HIDE_KEYS) do
        hide[key] = db.show[key] == false
    end
    s.hide = hide
end

function Idle:Configured()
    version = version + 1
end

function Idle:Style(plate)
    if plate.active then
        Refresh(plate)
    end
end

function Idle:Enable(plate)
    Refresh(plate)
end

function Idle:Disable(plate)
    local resize = (plate.idleW or 1) ~= 1 or (plate.idleH or 1) ~= 1
    plate.idle = nil
    plate.idleVersion = nil
    plate.idleAlpha = 1
    plate.hidden = nil
    plate.idleW, plate.idleH = nil, nil
    if resize then
        plate.styledAs = nil
        if plate.active then
            ns.Driver:StyleNow(plate)
        end
    end
end

function Idle:OnEvent(plate)
    Refresh(plate)
end

function Idle:UpdateEmphasis(plate)
    Refresh(plate)
end

function Idle:Preview(plate)
    plate.idleAlpha = 1
end

ns.Driver:RegisterElement(Idle)
