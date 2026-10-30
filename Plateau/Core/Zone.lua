local _, ns = ...

local IsInInstance = IsInInstance

local Zone = { inInstance = false }
ns.Zone = Zone

local function Read()
    Zone.inInstance = IsInInstance() == true
end

function Zone.OutOfCombat(owner)
    if InCombatLockdown() then
        owner.pending = true
        return false
    end
    owner.pending = false
    return true
end

function Zone.Watch(frame, update)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", function(self, event)
        if ns.disabled then return end
        if event == "PLAYER_REGEN_ENABLED" and not self.pending then return end
        update(self)
    end)
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:SetScript("OnEvent", Read)
