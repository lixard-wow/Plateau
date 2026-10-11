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
