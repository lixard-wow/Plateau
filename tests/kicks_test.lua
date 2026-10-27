local now = 100
function GetTime() return now end
function issecretvalue(v) return v == "SECRET" end
local group = {
    player = { guid = "Player-1-A", class = "ROGUE" },
    party1 = { guid = "Player-1-B", class = "MAGE" },
    party2 = { guid = "Player-1-C", class = "SHAMAN" },
}
function UnitGUID(unit) return group[unit] and group[unit].guid end
function UnitExists(unit) return group[unit] ~= nil end
function UnitClassBase(unit) return group[unit] and group[unit].class end
function UnitCreatureFamily() return nil end
function GetInspectSpecialization() return 0 end
function InCombatLockdown() return true end
local timers = {}
C_Timer = { After = function(delay, fn) timers[#timers + 1] = { delay = delay, fn = fn, n = #timers } end }
local function flush()
    local list = timers
    timers = {}
    table.sort(list, function(a, b) if a.delay ~= b.delay then return a.delay < b.delay end return a.n < b.n end)
    for _, timer in ipairs(list) do timer.fn() end
end
local spells = {}
Enum = { DamageMeterType = { Interrupts = 5 }, DamageMeterSessionType = { Current = 1 } }
C_DamageMeter = { GetCombatSessionSourceFromType = function(_, _, guid)
    local list = {}
    for i = 1, spells[guid] or 0 do list[i] = i end
    return { combatSpells = list, totalAmount = "SECRET" }
end }
C_Spell = { GetSpellBaseCooldown = function(id) return ({ [2139] = 24000, [57994] = 12000 })[id] end }
local handler
function CreateFrame()
    return { RegisterEvent = function() end, RegisterUnitEvent = function() end, SetScript = function(_, _, fn) handler = fn end }
end
local plates = { nameplate1 = { unit = "nameplate1" }, nameplate2 = { unit = "nameplate2" }, nameplate3 = { unit = "nameplate3" } }
local ns = {
    Driver = { GetPlate = function(_, unit) return plates[unit] end },
    InterruptReady = { IsKick = function(_, id) return id == 1766 end, GetCooldown = function() return "DURATION" end },
    Elements = { Kickers = { PlateChanged = function() end, CooldownChanged = function() end } },
}
assert(loadfile("Plateau/Features/Kicks.lua"))("Plateau", ns)
local Kicks = ns.Kicks
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function cast(id) handler(nil, "UNIT_SPELLCAST_SUCCEEDED", "player", "cast", id) end
local function stop(unit, by) handler(nil, "UNIT_SPELLCAST_INTERRUPTED", unit, "cast", 5, by) end
local function meter() handler(nil, "DAMAGE_METER_COMBAT_SESSION_UPDATED", 5, 1) flush() end
local function on(plate, guid) local list = Kicks:On(plates[plate]) return list and list[guid] ~= nil end
handler(nil, "GROUP_ROSTER_UPDATE")
meter()

cast(1766)
stop("nameplate1", "SECRET")
check(on("nameplate1", "Player-1-A"), "your kick then a hidden-kicker stop lands on that plate")

now = 110
stop("nameplate2", "SECRET")
cast(1766)
flush()
check(on("nameplate2", "Player-1-A") and Kicks:On(plates.nameplate1) == nil, "stop first then your kick also pairs, and your icon moves off the old plate")

now = 140
stop("nameplate1", "Player-1-A")
check(on("nameplate1", "Player-1-A"), "a readable kicker that is you places you at once")
check(select(1, Kicks:Cooldown("Player-1-A")) == "DURATION", "your cooldown is the game's own")

now = 150
stop("nameplate3", "Player-1-B")
local _, start, length = Kicks:Cooldown("Player-1-B")
check(on("nameplate3", "Player-1-B") and start == 150 and length == 24, "a readable party kicker gets the plate and their interrupt's cooldown")

now = 200
spells["Player-1-C"] = 1
stop("nameplate2", "SECRET")
meter()
check(on("nameplate2", "Player-1-C"), "in a key the damage meter proves who kicked")
_, start, length = Kicks:Cooldown("Player-1-C")
check(start == 200 and length == 12, "their cooldown starts at the kick")

now = 205
stop("nameplate1", "SECRET")
meter()
check(on("nameplate1", "Player-1-B"), "the only party member with a ready kick is the kicker when the meter says nothing")

now = 260
stop("nameplate3", "SECRET")
meter()
check(not on("nameplate3", "Player-1-B") and not on("nameplate3", "Player-1-C"), "two ready kickers and no proof: nobody is guessed")

Kicks:Forget(plates.nameplate1)
check(Kicks:On(plates.nameplate1) == nil, "a plate that goes away forgets its kicks")
check(Kicks.KickFor({ class = "PRIEST", spec = 256 }) == nil and Kicks.KickFor({ class = "PRIEST", spec = 258 }) == 15487, "specs without an interrupt have none")
