local function Any()
    return setmetatable({}, { __index = function() return function() end end })
end
function CreateFrame() return Any() end
function GetTime() return 100 end
function issecretvalue() return false end
C_Spell = {}
C_CurveUtil = {}
C_DurationUtil = {}
C_StringUtil = { CreateSecondsFormatter = Any }
Enum = {
    StatusBarTimerDirection = { ElapsedTime = 0, RemainingTime = 1 },
    SecondsFormatterAbbreviation = {},
    SecondsFormatterIntervalWhitespace = {},
    SecondsFormatterInterval = {},
}

local Castbar
local ns = {
    L = setmetatable({}, { __index = function(_, k) return k end }),
    Elements = {},
    InterruptReady = Any(),
    Driver = { RegisterElement = function(_, element) Castbar = element end },
}
assert(loadfile("Plateau/Elements/Castbar.lua"))("Plateau", ns)

local function check(ok, label)
    print((ok and "PASS " or "FAIL ") .. label)
end

Castbar:Configure({ showInterrupter = true, interruptHold = 3 }, "enemy")

local refreshed
function Castbar:Refresh() refreshed = true end

local plate = { state = "enemy", castbar = { holding = true, IsShown = function() return true end } }

for _, event in ipairs({
    "UNIT_SPELLCAST_STOP",
    "UNIT_SPELLCAST_FAILED",
    "UNIT_SPELLCAST_CHANNEL_STOP",
    "UNIT_SPELLCAST_DELAYED",
    "UNIT_SPELLCAST_CHANNEL_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_UPDATE",
    "UNIT_SPELLCAST_EMPOWER_STOP",
    "UNIT_SPELLCAST_INTERRUPTIBLE",
    "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
}) do
    refreshed = false
    Castbar:OnEvent(plate, event, "nameplate1")
    check(not refreshed and plate.castbar.holding, event .. " keeps the interrupted bar up")
end

for _, event in ipairs({ "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_EMPOWER_START" }) do
    refreshed = false
    Castbar:OnEvent(plate, event, "nameplate1")
    check(refreshed, event .. " replaces the interrupted bar with the new cast")
end

local shownWith, showCount = nil, 0
local realShow = Castbar.ShowInterrupted
function Castbar:ShowInterrupted(_, interruptedBy) shownWith, showCount = interruptedBy, showCount + 1 end
local live = { state = "enemy", castbar = { IsShown = function() return true end } }
Castbar:OnEvent(live, "UNIT_SPELLCAST_INTERRUPTED", "nameplate1", "cast-guid", 12345, "Player-1-ABC", 7)
check(shownWith == "Player-1-ABC", "an interrupted cast reads who kicked from the interruptedBy slot, not castBarID")
showCount = 0
Castbar:OnEvent(live, "UNIT_SPELLCAST_CHANNEL_STOP", "nameplate1", "cast-guid", 12345, nil, 7)
check(showCount == 0, "a channel that ends on its own is not shown as interrupted")
Castbar:OnEvent(live, "UNIT_SPELLCAST_CHANNEL_STOP", "nameplate1", "cast-guid", 12345, "Player-1-ABC", 7)
check(showCount == 1 and shownWith == "Player-1-ABC", "a kicked channel shows who kicked it")
Castbar.ShowInterrupted = realShow

function Castbar:ShowInterrupted(_, interruptedBy) shownWith, showCount = interruptedBy, showCount + 1 end
local held = { state = "enemy", castbar = { holding = true, IsShown = function() return true end } }
shownWith, showCount = "Player-1-ABC", 0
Castbar:OnEvent(held, "UNIT_SPELLCAST_INTERRUPTED", "nameplate1", "cast-guid", 12345, nil, 7)
check(showCount == 0 and shownWith == "Player-1-ABC", "a second interrupt report without a kicker keeps the kicker's name")
Castbar:OnEvent(held, "UNIT_SPELLCAST_INTERRUPTED", "nameplate1", "cast-guid", 12345, "Player-2-DEF", 7)
check(showCount == 1 and shownWith == "Player-2-DEF", "a held bar still takes a report that names the kicker")
Castbar.ShowInterrupted = realShow
