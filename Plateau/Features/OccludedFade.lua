local _, ns = ...

local CVAR = "nameplateOccludedAlphaMult"
local KINDS = { dungeon = "dungeon", raid = "raid", delve = "delve", battleground = "pvp", arena = "pvp" }

local OccludedFade = CreateFrame("Frame")
ns.OccludedFade = OccludedFade

function OccludedFade:Kind()
    local zone = ns.Zone.Read()
    if not zone.inInstance then
        return "world"
    end
    return KINDS[zone.content] or "world"
end

function OccludedFade:IsOn(kind)
    local places = ns.DB.saved.global.occludedFade
    return not (type(places) == "table" and places[kind] == false)
end

function OccludedFade:SetOn(kind, on)
    local global = ns.DB.saved.global
    if type(global.occludedFade) ~= "table" then
        global.occludedFade = {}
    end
    if on == false then
        global.occludedFade[kind] = false
    else
        global.occludedFade[kind] = nil
    end
    if next(global.occludedFade) == nil then
        global.occludedFade = nil
    end
    self:Update()
end

function OccludedFade:Update()
    if not (ns.DB and ns.DB.saved) or not ns.Zone.OutOfCombat(self) then return end
    if self:IsOn(self:Kind()) then
        ns.CVars:ClearOverride(CVAR)
    else
        ns.CVars:Override(CVAR, "1")
    end
end

ns.Zone.Watch(OccludedFade, OccludedFade.Update)

if Plateau then
    Plateau.OccludedFade = OccludedFade
end
