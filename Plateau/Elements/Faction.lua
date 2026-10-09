local _, ns = ...

local UnitFactionGroup = UnitFactionGroup
local UnitIsPVP = UnitIsPVP
local issecretvalue = issecretvalue

local ATLASES = {
    Horde = "UI-HUD-UnitFrame-Player-PVP-HordeIcon",
    Alliance = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon",
}

local FILES = {
    Horde = "Interface\\TargetingFrame\\UI-PVP-Horde",
    Alliance = "Interface\\TargetingFrame\\UI-PVP-Alliance",
}

local hasAtlases = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(ATLASES.Horde) ~= nil

local onlyPvP = {}

local Faction = {
    key = "faction",
    events = { "UNIT_FACTION" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Faction = Faction

function Faction:Create(plate)
    local icon = plate.overlay:CreateTexture(nil, "OVERLAY")
    icon:Hide()
    plate.faction = icon
end

function Faction:Configure(db, state)
    onlyPvP[state] = db.onlyPvP == true
end

function Faction:Style(plate, db)
    local icon = plate.faction
    icon:SetSize(db.size, db.size)
    icon:SetAlpha(db.alpha)
    ns.PlaceIcon(icon, plate, db.position, db.gap, db.offsetX, db.offsetY)
end

function Faction:Enable(plate, unit)
    self:Update(plate, unit)
end

function Faction:Disable(plate)
    plate.factionShown = nil
    plate.faction:Hide()
end

function Faction:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

local function Readable(value)
    if issecretvalue(value) then return nil end
    return value
end

function Faction:Update(plate, unit)
    if not plate.isPlayer then
        self:Render(plate, nil)
        return
    end
    local group = Readable(UnitFactionGroup(unit))
    if group and onlyPvP[plate.state] and Readable(UnitIsPVP(unit)) ~= true then
        group = nil
    end
    self:Render(plate, group)
end

function Faction:Preview(plate, state)
    self:Render(plate, state.isPlayer and "Alliance" or nil)
end

function Faction:Render(plate, group)
    local icon = plate.faction
    if group ~= "Horde" and group ~= "Alliance" then
        group = nil
    end
    if plate.factionShown == group then return end
    plate.factionShown = group
    if not group then
        icon:Hide()
        return
    end
    if hasAtlases then
        icon:SetAtlas(ATLASES[group])
    else
        icon:SetTexture(FILES[group])
    end
    icon:Show()
end

ns.Driver:RegisterElement(Faction)
