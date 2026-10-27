local now = 100
function GetTime() return now end
function issecretvalue(v) return v == "SECRET" end
function UnitGUID(unit) return unit == "player" and "Player-1-A" or nil end
local timers = {}
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end }
local handler
function CreateFrame()
    return { RegisterEvent = function() end, RegisterUnitEvent = function() end, SetScript = function(_, _, fn) handler = fn end }
end
local plates = { nameplate1 = { unit = "nameplate1" }, nameplate2 = { unit = "nameplate2" } }
local changed = {}
local ns = {
    Driver = { GetPlate = function(_, unit) return plates[unit] end },
    InterruptReady = { IsKick = function(_, id) return id == 1766 end, GetCooldown = function() return "DURATION" end },
    Elements = { Kickers = { PlateChanged = function(_, plate) changed[#changed + 1] = plate end, CooldownChanged = function() end } },
}
assert(loadfile("Plateau/Features/Kicks.lua"))("Plateau", ns)
local Kicks = ns.Kicks
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function cast(id) handler(nil, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", id) end
local function stop(unit, by) handler(nil, "UNIT_SPELLCAST_INTERRUPTED", unit, "cast", 5, by) end

cast(1766)
stop("nameplate1", "SECRET")
check(Kicks:On(plates.nameplate1) and Kicks:On(plates.nameplate1)["Player-1-A"], "your kick then a hidden-kicker stop lands on that plate")

now = 110
stop("nameplate2", "SECRET")
cast(1766)
check(Kicks:On(plates.nameplate2) and Kicks:On(plates.nameplate1) == nil, "stop first then your kick also pairs, and your icon moves off the old plate")

now = 120
stop("nameplate1", "SECRET")
now = 122
cast(1766)
check(Kicks:On(plates.nameplate1) == nil, "a stop two seconds before your kick is not yours")

now = 130
cast(2139)
stop("nameplate1", "SECRET")
check(Kicks:On(plates.nameplate1) == nil, "a spell that isn't a kick does nothing")

now = 140
stop("nameplate1", "Player-1-A")
check(Kicks:On(plates.nameplate1) and Kicks:On(plates.nameplate1)["Player-1-A"], "a readable kicker that is you places you at once")

now = 150
stop("nameplate2", "Player-9-Z")
check(Kicks:On(plates.nameplate2) == nil, "someone else's readable kick is not yours")

Kicks:Forget(plates.nameplate1)
check(Kicks:On(plates.nameplate1) == nil, "a plate that goes away forgets its kicks")
check(Kicks:Duration("Player-1-A") == "DURATION" and Kicks:Duration("Player-9-Z") == nil, "only your own cooldown is known so far")
