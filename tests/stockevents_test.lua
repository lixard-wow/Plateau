local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau/Driver/StockEvents.lua"))("Plateau", ns)
local StockEvents = ns.StockEvents

local function StockFrame()
    local frame = { events = {}, calls = 0 }
    function frame:RegisterEvent(event)
        self.calls = self.calls + 1
        self.events[event] = { true }
    end
    function frame:RegisterUnitEvent(event, unit1, unit2)
        self.calls = self.calls + 1
        self.events[event] = { true, unit1, unit2 }
    end
    function frame:UnregisterAllEvents()
        self.events = {}
    end
    function frame:IsEventRegistered(event)
        local entry = self.events[event]
        if not entry then return false end
        return true, entry[2], entry[3]
    end
    return frame
end

local unitFrame = StockFrame()
unitFrame:RegisterUnitEvent("UNIT_AURA", "nameplate3")
unitFrame:RegisterUnitEvent("UNIT_FACTION", "nameplate3")
unitFrame:RegisterUnitEvent("NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED", "nameplate3")
unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
unitFrame:RegisterEvent("RAID_TARGET_UPDATE")
local castBar = StockFrame()
castBar:RegisterUnitEvent("UNIT_SPELLCAST_START", "nameplate3")

local savedFrame, savedBar = StockEvents.Snapshot(unitFrame), StockEvents.Snapshot(castBar)
unitFrame:UnregisterAllEvents()
castBar:UnregisterAllEvents()
StockEvents.Replay(unitFrame, savedFrame, StockEvents.FALLBACK)
StockEvents.Replay(castBar, savedBar)

local function Has(frame, event, unit)
    local registered, unit1 = frame:IsEventRegistered(event)
    return registered and unit1 == unit
end
check(Has(unitFrame, "UNIT_AURA", "nameplate3") and Has(unitFrame, "UNIT_FACTION", "nameplate3")
    and Has(unitFrame, "NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED", "nameplate3"), "handing a plate back restores its unit events for the same unit")
check(Has(unitFrame, "PLAYER_FOCUS_CHANGED", nil) and Has(unitFrame, "RAID_TARGET_UPDATE", nil), "handing a plate back restores its focus and raid marker events")
check(Has(castBar, "UNIT_SPELLCAST_START", "nameplate3"), "handing a plate back restores the stock cast bar's cast events")
check(not unitFrame:IsEventRegistered("VARIABLES_LOADED"), "only the events the frame really had come back, not a generic list")

local before = unitFrame.calls
StockEvents.Replay(unitFrame, savedFrame, StockEvents.FALLBACK)
check(unitFrame.calls == before, "restoring twice registers nothing again")

unitFrame:UnregisterAllEvents()
unitFrame:RegisterUnitEvent("UNIT_AURA", "nameplate7")
StockEvents.Replay(unitFrame, savedFrame, StockEvents.FALLBACK)
check(Has(unitFrame, "UNIT_AURA", "nameplate7"), "an event Blizzard already set up for a new unit is left alone")
check(Has(unitFrame, "UNIT_FACTION", "nameplate3"), "events Blizzard hasn't set up yet still come back")

local empty = StockFrame()
StockEvents.Replay(empty, {}, StockEvents.FALLBACK)
check(empty:IsEventRegistered("PLAYER_TARGET_CHANGED") and empty:IsEventRegistered("CVAR_UPDATE"), "a frame stripped before it had any events gets the stock global events back")

local broken = StockFrame()
function broken:IsEventRegistered() error("forbidden") end
local ok = pcall(StockEvents.Snapshot, broken)
check(ok, "a frame that refuses to report its events doesn't break hiding")
