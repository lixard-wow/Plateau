local inInstance, instanceType, inCombat = false, "none", false
function IsInInstance() return inInstance, instanceType end
function InCombatLockdown() return inCombat end
local onEvent
function CreateFrame() return { RegisterEvent = function() end, SetScript = function(_, _, fn) onEvent = fn end } end
local calls = {}
local ns = {
    DB = { saved = { global = {} } },
    CVars = {
        Override = function(_, name, value) calls[#calls + 1] = "override " .. value end,
        ClearOverride = function() calls[#calls + 1] = "clear" end,
    },
}
assert(loadfile("Plateau/Features/OccludedFade.lua"))("Plateau", ns)
local O = ns.OccludedFade
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function last() return calls[#calls] end

O:Update()
check(last() == "clear", "by default hidden nameplates fade everywhere, as before")
O:SetOn("dungeon", false)
check(last() == "clear", "turning dungeons off changes nothing in the open world")
inInstance, instanceType = true, "party"
onEvent(O, "ZONE_CHANGED_NEW_AREA")
check(last() == "override 1", "entering a dungeon with dungeons off keeps hidden nameplates fully visible")
inInstance, instanceType = true, "raid"
onEvent(O, "ZONE_CHANGED_NEW_AREA")
check(last() == "clear", "raids still fade when only dungeons are off")
O:SetOn("raid", false)
check(last() == "override 1", "turning raids off applies right away inside a raid")
inInstance, instanceType = false, "none"
O:SetOn("world", false)
check(last() == "override 1", "open world can be turned off on its own")
for _, t in ipairs({ { "scenario", "delve" }, { "pvp", "pvp" }, { "arena", "pvp" } }) do
    inInstance, instanceType = true, t[1]
    check(O:Kind() == t[2], t[1] .. " counts as " .. t[2])
end
inInstance, instanceType = false, "none"
O:SetOn("world", true)
O:SetOn("dungeon", true)
O:SetOn("raid", true)
check(ns.DB.saved.global.occludedFade == nil, "with every place on, nothing extra is saved")
inCombat = true
local before = #calls
inInstance, instanceType = true, "party"
O:SetOn("dungeon", false)
check(#calls == before, "nothing switches during combat")
inCombat = false
onEvent(O, "PLAYER_REGEN_ENABLED")
check(last() == "override 1", "the switch happens when combat ends")
