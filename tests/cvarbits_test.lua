C_CVar = { GetCVar = function() return nil end, SetCVar = function() end }
function InCombatLockdown() return false end
function CreateFrame()
    return { RegisterEvent = function() end, SetScript = function() end }
end
local ns = { DB = { saved = { global = {} } } }
assert(loadfile("Plateau/Core/CVars.lua"))("Plateau", ns)
local WithBit = ns.CVars.WithBit
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

check(WithBit("A", 3, true) == "AD", "simplify friendly players on an empty setting writes the same code Blizzard does")
check(WithBit("AD", 3, false) == "A", "turning it back off drops the empty byte")
check(WithBit("AD", 1, true) == "AE", "a second type keeps the first")
check(WithBit("AE", 3, false) == "AA", "clearing one type keeps the other")
check(WithBit("A", 7, true) == "A@A", "a type past the first byte adds a byte")
check(WithBit("A@A", 7, false) == "A", "and removing it shrinks back")
check(WithBit("C]", 2, true) == "C_", "the version character is kept")
