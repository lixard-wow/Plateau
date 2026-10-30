local function Any()
    return setmetatable({}, { __index = function() return function() end end })
end
function CreateFrame() return Any() end
local now = 100
function GetTime() return now end
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
local timers = {}
C_Timer = { After = function(delay, callback)
    timers[#timers + 1] = { at = now + delay, callback = callback }
end }

local Castbar
local ns = {
    L = setmetatable({}, { __index = function(_, k) return k end }),
    Elements = {},
    InterruptReady = Any(),
    Driver = { RegisterElement = function(_, element) Castbar = element end },
}
ns.NewSecondsFormatter = function() return C_StringUtil.CreateSecondsFormatter() end
assert(loadfile("Plateau/Core/Border.lua"))("Plateau", ns)
assert(loadfile("Plateau/Elements/Castbar.lua"))("Plateau", ns)

local function check(ok, label)
    print((ok and "PASS " or "FAIL ") .. label)
end

local function Upvalue(fn, key)
    for i = 1, 100 do
        local name, value = debug.getupvalue(fn, i)
        if name == key then return value end
        if not name then break end
    end
    error("missing " .. key)
end
local HoldExpired = Upvalue(Castbar.Create, "HoldExpired")

local function NewPlate()
    local plate = { state = "enemy", casting = false }
    local bar = Any()
    plate.castbar, bar.plate = bar, plate
    bar.pair = { on = false }
    for _, key in ipairs({ "timerBinding", "timer", "target", "spark", "kickClip", "glow", "interrupted", "text", "interruptText" }) do
        bar[key] = Any()
    end
    bar.interruptFlash = Any()
    bar.interruptFlash.anim = Any()
    bar.holdCallback = function() HoldExpired(bar) end
    return plate, bar
end

Castbar:Configure({ showInterrupter = true, interruptHold = 3, interruptClassColor = false, interruptFormat = "label" }, "enemy")

local hides = 0
function Castbar:Disable(plate)
    hides = hides + 1
    plate.castbar.holding = false
end

local function Fire(index)
    now = timers[index].at
    timers[index].callback()
end

local plate, bar = NewPlate()
now, hides, timers = 100, 0, {}
Castbar:ShowInterrupted(plate)
now = 101
bar.holding = false
Castbar:ShowInterrupted(plate)
Fire(1)
check(hides == 0 and bar.holding, "an earlier interrupt's timer doesn't hide a newer interrupt")
Fire(2)
check(hides == 1 and not bar.holding, "the newer interrupt hides when its own hold ends")

plate, bar = NewPlate()
now, hides, timers = 100, 0, {}
Castbar:ShowInterrupted(plate)
now = 102
Castbar:ShowInterrupted(plate)
Fire(1)
check(hides == 0 and bar.holding, "a second interrupt during a hold restarts the full hold")
Fire(2)
check(hides == 1, "...and ends three seconds after the second interrupt")

plate, bar = NewPlate()
now, hides, timers = 100, 0, {}
Castbar:ShowInterrupted(plate)
Fire(1)
check(hides == 1, "a single interrupt hides after its hold")

plate, bar = NewPlate()
now, hides, timers = 100, 0, {}
Castbar:ShowInterrupted(plate)
bar.holding = false
Fire(1)
check(hides == 0, "a timer firing after the hold was cleared does nothing")

local SizeKickLine = Upvalue(Castbar.Style, "SizeKickLine")
local function LineBar(scale, width)
    local bar = { kickWidth = width, kickLine = {} }
    function bar:GetEffectiveScale() return scale end
    function bar.kickLine:SetWidth(w) self.width = w end
    return bar
end
PixelUtil = { GetPixelToUIUnitFactor = function() return 0.64 end }
local thin = LineBar(0.32, 1)
SizeKickLine(thin)
check(math.abs(thin.kickLine.width - 2) < 1e-6, "a marker thinner than a screen pixel grows to one pixel")
local small = LineBar(0.5, 1)
SizeKickLine(small)
check(math.abs(small.kickLine.width - 1.28) < 1e-6, "a shrunken plate still gets a one pixel marker")
local thick = LineBar(1, 2)
SizeKickLine(thick)
check(math.abs(thick.kickLine.width - 1.92) < 1e-6, "a thicker marker snaps to whole pixels")
PixelUtil = nil
