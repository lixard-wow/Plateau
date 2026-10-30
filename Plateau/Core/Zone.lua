local _, ns = ...

local IsInInstance = IsInInstance

local CONTENT = {
    party = "dungeon",
    raid = "raid",
    scenario = "delve",
    delve = "delve",
    arena = "arena",
    pvp = "battleground",
}

local Zone = { inInstance = false, type = "none", content = "world", inDelve = false }
ns.Zone = Zone

function Zone.Read()
    local inside, kind = IsInInstance()
    Zone.inInstance = inside == true
    Zone.type = kind or "none"
    Zone.content = CONTENT[Zone.type] or "world"
    Zone.inDelve = C_PartyInfo and C_PartyInfo.IsDelveInProgress and C_PartyInfo.IsDelveInProgress() == true or false
    return Zone
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

function Zone.Restricted()
    return InCombatLockdown() or (ShouldAurasBeSecret and ShouldAurasBeSecret())
end

local FLUSH_BATCH = 8
local queues = {}

local Queue = {}
Queue.__index = Queue

function Queue:Mark(item)
    self.dirty[item] = true
    if not self.queued[item] then
        self.queued[item] = true
        self.order[#self.order + 1] = item
    end
end

function Queue:Restyle(item)
    if Zone.Restricted() then
        self:Mark(item)
    else
        self.dirty[item] = nil
        self.style(item)
    end
end

function Queue:Settle(item)
    if self.dirty[item] then
        self:Restyle(item)
    end
end

function Queue:Flush()
    if Zone.Restricted() then return end
    local order = self.order
    local processed = 0
    while #order > 0 and processed < FLUSH_BATCH do
        local item = table.remove(order)
        self.queued[item] = nil
        if self.dirty[item] and self.alive(item) then
            self.dirty[item] = nil
            self.style(item)
        end
        processed = processed + 1
    end
    if #order > 0 then
        C_Timer.After(0, self.flush)
    end
end

function Zone.RestyleQueue(style, alive, ready)
    local queue = setmetatable({ dirty = {}, queued = {}, order = {}, style = style, alive = alive, ready = ready }, Queue)
    queue.flush = function() queue:Flush() end
    queues[#queues + 1] = queue
    return queue
end

local restyler = CreateFrame("Frame")
restyler:RegisterEvent("PLAYER_REGEN_ENABLED")
if C_EventUtils.IsEventValid("ADDON_RESTRICTION_STATE_CHANGED") then
    restyler:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
end
restyler:SetScript("OnEvent", function()
    if ns.disabled then return end
    for _, queue in ipairs(queues) do
        if #queue.order > 0 and queue.ready() then
            queue:Flush()
        end
    end
end)

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:SetScript("OnEvent", Zone.Read)
