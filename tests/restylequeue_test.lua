local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local combat, secret = false, false
function InCombatLockdown() return combat end
function ShouldAurasBeSecret() return secret end
function IsInInstance() return false end
local timers = {}
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end }
C_EventUtils = { IsEventValid = function() return true end }
local frames = {}
function CreateFrame()
    local frame = { events = {} }
    function frame:RegisterEvent(event) self.events[event] = true end
    function frame:SetScript(_, fn) self.handler = fn end
    frames[#frames + 1] = frame
    return frame
end

local ns = {}
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
local restyler = frames[1]
check(restyler.events.PLAYER_REGEN_ENABLED and restyler.events.ADDON_RESTRICTION_STATE_CHANGED, "the shared queue listens for combat end and restriction changes")

local styled, ready = {}, true
local queue = ns.Zone.RestyleQueue(function(item) styled[#styled + 1] = item.name end, function(item) return item.active end, function() return ready end)

local a = { name = "a", active = true }
queue:Restyle(a)
check(#styled == 1, "restyles at once when nothing is restricted")

styled = {}
combat = true
queue:Restyle(a)
queue:Restyle(a)
check(#styled == 0 and #queue.order == 1, "waits in combat and queues an item once")
queue:Settle(a)
check(#styled == 0, "settle keeps waiting while restricted")

combat = false
secret = true
restyler.handler(restyler, "ADDON_RESTRICTION_STATE_CHANGED")
check(#styled == 0, "secret auras still hold the queue")

secret = false
ready = false
restyler.handler(restyler, "PLAYER_REGEN_ENABLED")
check(#styled == 0, "an unconfigured element is not flushed")

ready = true
restyler.handler(restyler, "PLAYER_REGEN_ENABLED")
check(#styled == 1 and #queue.order == 0, "combat end restyles the waiting item")

styled = {}
combat = true
local items = {}
for i = 1, 12 do
    items[i] = { name = "i" .. i, active = i ~= 3 }
    queue:Restyle(items[i])
end
combat = false
restyler.handler(restyler, "PLAYER_REGEN_ENABLED")
check(#styled == 8 and #timers == 1, "flushes eight per frame and schedules the rest")
timers[1]()
check(#styled == 11, "the next frame finishes the batch and skips the released plate")

styled = {}
combat = true
queue:Restyle(a)
combat = false
queue:Settle(a)
check(#styled == 1, "settle restyles a waiting item once restrictions lift")
