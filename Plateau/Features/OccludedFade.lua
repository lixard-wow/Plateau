local _, ns = ...

local CVAR = "nameplateOccludedAlphaMult"
local KINDS = { party = "dungeon", raid = "raid", scenario = "delve", delve = "delve", pvp = "pvp", arena = "pvp" }

local OccludedFade = CreateFrame("Frame")
ns.OccludedFade = OccludedFade

function OccludedFade:Kind()
    local inInstance, instanceType = IsInInstance()
    if not inInstance then
        return "world"
    end
    return KINDS[instanceType] or "world"
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
    if not (ns.DB and ns.DB.saved) then return end
    if InCombatLockdown() then
        self.pending = true
        return
    end
    self.pending = false
    if self:IsOn(self:Kind()) then
        ns.CVars:ClearOverride(CVAR)
    else
        ns.CVars:Override(CVAR, "1")
    end
end

OccludedFade:RegisterEvent("PLAYER_ENTERING_WORLD")
OccludedFade:RegisterEvent("ZONE_CHANGED_NEW_AREA")
OccludedFade:RegisterEvent("PLAYER_REGEN_ENABLED")
OccludedFade:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_ENABLED" and not self.pending then return end
    self:Update()
end)

if Plateau then
    Plateau.OccludedFade = OccludedFade
end
