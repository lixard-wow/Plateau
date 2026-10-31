local _, ns = ...

local BlizzardSize = CreateFrame("Frame")

local gameWidth, gameHeight
local appliedWidth, appliedHeight
local applied = false

local function Wanted()
    local views = ns.DB and ns.DB.views
    local friendly = views and views.enemy and views.enemy.friendly
    if not (friendly and friendly.blizzardSize) then return nil end
    return friendly.blizzardWidth, friendly.blizzardHeight
end

local function ClickFit()
    local half, top, bottom = ns.Driver:ClickReach()
    local scale = ns.Scaling:Largest()
    return math.ceil(half * 2 * scale), math.ceil(math.max(top, bottom) * 2 * scale)
end

function BlizzardSize:Apply()
    if ns.disabled or not (C_NamePlate and C_NamePlate.SetNamePlateSize) then return end
    if InCombatLockdown() then
        self.pending = true
        return
    end
    self.pending = false
    if not applied then
        gameWidth, gameHeight = C_NamePlate.GetNamePlateSize()
    end
    local wantedWidth, wantedHeight = Wanted()
    local fitWidth, fitHeight = ClickFit()
    local width = math.max(wantedWidth or gameWidth or 0, fitWidth)
    local height = math.max(wantedHeight or gameHeight or 0, fitHeight)
    if wantedWidth or (gameWidth and (width > gameWidth or height > gameHeight)) then
        applied = true
        if width ~= appliedWidth or height ~= appliedHeight then
            appliedWidth, appliedHeight = width, height
            C_NamePlate.SetNamePlateSize(width, height)
        end
    elseif applied then
        applied = false
        appliedWidth, appliedHeight = nil, nil
        if gameWidth then
            C_NamePlate.SetNamePlateSize(gameWidth, gameHeight)
        end
    end
end

local hooked = false

local function Hook()
    if hooked or not (NamePlateDriverFrame and NamePlateDriverFrame.UpdateNamePlateSize) then return end
    hooked = true
    hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateSize", function()
        if applied then
            applied = false
            appliedWidth, appliedHeight = nil, nil
            BlizzardSize:Apply()
        else
            gameWidth, gameHeight = C_NamePlate.GetNamePlateSize()
        end
    end)
end
Hook()

ns.Driver:OnRestyle(function()
    BlizzardSize:Apply()
end)

BlizzardSize:RegisterEvent("PLAYER_REGEN_ENABLED")
BlizzardSize:RegisterEvent("ADDON_LOADED")
BlizzardSize:SetScript("OnEvent", function(self, event)
    if event == "ADDON_LOADED" then
        Hook()
        return
    end
    if self.pending then
        self:Apply()
    end
end)
