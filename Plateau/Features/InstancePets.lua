local _, ns = ...

local CVARS = { "nameplateShowFriendlyPlayerMinions", "UnitNameFriendlyMinionName" }
local INSTANCES = { party = true, raid = true }

local InstancePets = CreateFrame("Frame")
ns.InstancePets = InstancePets

function InstancePets:IsOn()
    return ns.DB.saved.global.hideInstancePets == true
end

function InstancePets:SetOn(on)
    ns.DB.saved.global.hideInstancePets = on == true or nil
    self:Update()
end

function InstancePets:InInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance == true and INSTANCES[instanceType] == true
end

function InstancePets:Update()
    if not (ns.DB and ns.DB.saved) then return end
    if InCombatLockdown() then
        self.pending = true
        return
    end
    self.pending = false
    local hide = self:IsOn() and self:InInstance()
    for _, name in ipairs(CVARS) do
        if hide then
            ns.CVars:Override(name, "0")
        else
            ns.CVars:ClearOverride(name)
        end
    end
end

InstancePets:RegisterEvent("PLAYER_ENTERING_WORLD")
InstancePets:RegisterEvent("ZONE_CHANGED_NEW_AREA")
InstancePets:RegisterEvent("PLAYER_REGEN_ENABLED")
InstancePets:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" and not self.pending then return end
    self:Update()
end)

if Plateau then
    Plateau.InstancePets = InstancePets
end
