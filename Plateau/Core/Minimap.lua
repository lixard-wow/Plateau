local _, ns = ...

local LDB = LibStub("LibDataBroker-1.1", true)
local DBIcon = LibStub("LibDBIcon-1.0", true)
if not (LDB and DBIcon) then return end

local NAME = "Plateau"

local Minimap = {}
ns.Minimap = Minimap

local broker = LDB:NewDataObject(NAME, {
    type = "launcher",
    text = NAME,
    icon = "Interface\\AddOns\\Plateau\\Art\\icon",
    OnClick = function()
        ns.OpenOptions()
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddDoubleLine(ns.Brand:Text(NAME), ("v%s"):format(ns.version or ""))
        local db = ns.DB
        if db and db.profileName and ns.AutoProfile then
            local status = ns.AutoProfile:Status()
            tooltip:AddLine("Profile: " .. status.active, 1, 1, 1)
        end
        tooltip:AddLine(" ")
        tooltip:AddLine("Click to open the settings.", 0.6, 0.8, 1)
        tooltip:AddLine("Drag to move this button.", 0.6, 0.8, 1)
    end,
})

ns.Brand:OnChange(function(r, g, b)
    broker.iconG, broker.iconB = g, b
    broker.iconR = r
end)

local function Settings()
    local global = ns.DB.saved.global
    if type(global.minimap) ~= "table" then
        global.minimap = { showInCompartment = true }
    end
    return global.minimap
end

function Minimap:IsShown()
    return not Settings().hide
end

function Minimap:SetShown(shown)
    local db = Settings()
    db.hide = not shown or nil
    if shown then
        DBIcon:Show(NAME)
    else
        DBIcon:Hide(NAME)
    end
end

function Minimap:HasCompartment()
    return DBIcon:IsButtonCompartmentAvailable() == true
end

function Minimap:InCompartment()
    return DBIcon:IsButtonInCompartment(NAME)
end

function Minimap:SetCompartment(shown)
    if shown then
        DBIcon:AddButtonToCompartment(NAME)
    else
        DBIcon:RemoveButtonFromCompartment(NAME)
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    DBIcon:Register(NAME, broker, Settings())
end)

if Plateau then
    Plateau.Minimap = Minimap
end
