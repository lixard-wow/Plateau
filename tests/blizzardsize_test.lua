local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local size = { 135, 31 }
local calls = {}
C_NamePlate = {
    GetNamePlateSize = function() return size[1], size[2] end,
    SetNamePlateSize = function(w, h) size[1], size[2] = w, h calls[#calls + 1] = { w, h } end,
}
local combat = false
function InCombatLockdown() return combat end
function CreateFrame() return { RegisterEvent = function() end, SetScript = function() end } end

local reach = { 59, 14, 29 }
local largest = 1
local friendly = { blizzardSize = false, blizzardWidth = 135, blizzardHeight = 31 }
local listener
local ns = {
    DB = { views = { enemy = { friendly = friendly } } },
    Driver = { ClickReach = function() return reach[1], reach[2], reach[3] end, OnRestyle = function(_, fn) listener = fn end },
    Scaling = { Largest = function() return largest end },
}
assert(loadfile("Plateau/Features/BlizzardSize.lua"))("Plateau", ns)

listener()
check(size[1] == 135 and size[2] == 58, "the game's plate box grows to hold the clickable area (height 2 x 29)")

reach = { 50, 10, 10 }
listener()
check(size[1] == 135 and size[2] == 31, "the box goes back to the game's size when the clickable area fits inside it")

friendly.blizzardSize, friendly.blizzardWidth, friendly.blizzardHeight = true, 140, 20
listener()
check(size[1] == 140 and size[2] == 20, "Set their size is used when the clickable area fits inside it")

reach, largest = { 59, 14, 29 }, 1.25
listener()
check(size[1] == 148 and size[2] == 73, "a bigger clickable area wins over Set their size, counting the largest plate scale")

local before = #calls
listener()
check(#calls == before, "nothing is resent when the size hasn't changed")

combat = true
reach = { 100, 14, 29 }
listener()
check(#calls == before, "no size change in combat")
