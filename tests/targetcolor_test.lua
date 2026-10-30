local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local SECRET = setmetatable({}, { __tostring = function() return "secret" end })
function issecretvalue(v) return v == SECRET end
RAID_CLASS_COLORS = { DEATHKNIGHT = { r = 0.77, g = 0.12, b = 0.23 } }
C_ClassColor = { GetClassColor = function(class) return class == SECRET and { r = "sr", g = "sg", b = "sb" } or RAID_CLASS_COLORS[class] end }
C_CurveUtil = { EvaluateColorValueFromBoolean = function(flag, a, b) return flag and a or b end }
FOREIGN_SERVER_LABEL = " (*)"
function CreateFrame() return {} end

local ns = { L = setmetatable({}, { __index = function(_, k) return k end }) }
assert(loadfile("Plateau/Core/Layout.lua"))("Plateau", ns)

local plain = ns.ClassColor("DEATHKNIGHT")
check(plain and plain.r == 0.77, "a readable class gets its class color")
check(ns.ClassColor(SECRET) == nil, "a hidden class gives no color without the secret fallback")
local hidden = ns.ClassColor(SECRET, true)
check(hidden and hidden.r == "sr", "a hidden class still gets the game's class color through the secret fallback")

local castbar = io.open("Plateau/Elements/Castbar.lua"):read("*a")
check(castbar:find("ns.ClassColor(UnitSpellTargetClass(unit), true)", 1, true) ~= nil, "the cast bar spell target name uses the secret fallback")
local enemyTarget = io.open("Plateau/Elements/EnemyTarget.lua"):read("*a")
check(enemyTarget:find("ns.ClassColor(class, true)", 1, true) ~= nil, "the enemy target name uses the secret fallback")
check(enemyTarget:find("issecretvalue(class) then", 1, true) == nil, "the enemy target name no longer throws away a hidden class")
