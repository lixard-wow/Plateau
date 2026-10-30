local _, ns = ...

local BlizzardSize = CreateFrame("Frame")
ns.BlizzardSize = BlizzardSize

local gameWidth, gameHeight
local applied = false

local function Wanted()
    local views = ns.DB and ns.DB.views
    local friendly = views and views.enemy and views.enemy.friendly
    if not (friendly and friendly.blizzardSize) then return nil end
    return friendly.blizzardWidth, friendly.blizzardHeight
end

function BlizzardSize:Apply()
    if ns.disabled or not (C_NamePlate and C_NamePlate.SetNamePlateSize) then return end
    if InCombatLockdown() then
        self.pending = true
        return
    end
    self.pending = false
    local width, height = Wanted()
    if width then
        if not applied then
            gameWidth, gameHeight = C_NamePlate.GetNamePlateSize()
        end
        applied = true
        C_NamePlate.SetNamePlateSize(width, height)
    elseif applied then
        applied = false
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
        gameWidth, gameHeight = C_NamePlate.GetNamePlateSize()
        if applied then
            applied = false
            BlizzardSize:Apply()
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
