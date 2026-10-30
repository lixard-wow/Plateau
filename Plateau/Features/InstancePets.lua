local _, ns = ...

local PLATE_CVARS = { "nameplateShowFriendlyPlayerMinions", "nameplateShowFriendlyPlayerPets",
    "nameplateShowFriendlyPlayerGuardians", "nameplateShowFriendlyPlayerTotems" }
local CVARS = { "UnitNameFriendlyMinionName", "UnitNameFriendlyPetName", "UnitNameFriendlyGuardianName",
    "UnitNameFriendlyTotemName" }
for _, name in ipairs(PLATE_CVARS) do
    CVARS[#CVARS + 1] = name
end
local INSTANCES = { party = true, raid = true }

local InstancePets = CreateFrame("Frame")
ns.InstancePets = InstancePets

local function HiddenPlates(turnOn)
    local hidden = false
    for _, name in ipairs(PLATE_CVARS) do
        local value = ns.CVars:UserValue(name)
        if value ~= nil and value ~= "1" then
            hidden = true
            if not turnOn then break end
            ns.CVars:Set(name, "1")
        end
    end
    return hidden
end

function InstancePets:PlatesShown()
    return not HiddenPlates(false)
end

function InstancePets:ShowPlates()
    HiddenPlates(true)
end

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
    if not (ns.DB and ns.DB.saved) or not ns.Zone.OutOfCombat(self) then return end
    local hide = self:IsOn() and self:InInstance()
    for _, name in ipairs(CVARS) do
        if hide then
            ns.CVars:Override(name, "0")
        else
            ns.CVars:ClearOverride(name)
        end
    end
end

function ns.CVars:OnOverrideChanged(name, value)
    if value ~= "1" or not InstancePets:IsOn() then return end
    for _, cvar in ipairs(CVARS) do
        if cvar == name then
            InstancePets:SetOn(false)
            return
        end
    end
end

ns.Zone.Watch(InstancePets, InstancePets.Update)

if Plateau then
    Plateau.InstancePets = InstancePets
end
