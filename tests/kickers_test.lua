local global = {}
local active = {}
local ns = { Elements = {}, DB = { saved = { global = global } },
    Driver = { RegisterElement = function() end, ForEachActive = function(_, fn) for _, p in ipairs(active) do fn(p) end end } }
function issecretvalue() return false end
time = os.time
function IsInInstance() return false, "none" end
local handler
function CreateFrame()
    return { RegisterEvent = function() end, SetScript = function(_, _, fn) handler = fn end }
end
local group = {
    player = { guid = "Player-1-A", class = "ROGUE", name = "Me" },
    party1 = { guid = "Player-1-B", class = "MAGE", name = "Bee" },
    party2 = { guid = "Player-1-C", class = "SHAMAN", name = "Cee" },
}
function UnitExists(unit) return group[unit] ~= nil end
function UnitGUID(unit) return group[unit] and group[unit].guid end
function UnitClassBase(unit) return group[unit] and group[unit].class end
function UnitName(unit) return group[unit] and group[unit].name end
function GetRaidTargetIndex() return nil end
RAID_TARGET_8 = "Skull"

ns.Readable = function(value) if issecretvalue(value) then return nil end return value end
ns.AtlasExists = function(atlas) return C_Texture ~= nil and C_Texture.GetAtlasInfo ~= nil and C_Texture.GetAtlasInfo(atlas) ~= nil end
assert(loadfile("Plateau/Elements/Kickers.lua"))("Plateau", ns)
local Kickers = ns.Elements.Kickers
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Parse = Kickers.ParseMarker
check(Parse("Interrupt target set to {skull}") == 8, "FocusControl's line reads as skull")
check(Parse("kicking {star}") == 1, "kicking {star} reads as star")
check(Parse("my FOCUS is {rt5}") == 5, "rt tags and any case work")
check(Parse("pull {skull}") == nil, "a marker without a kick word is ignored")
check(Parse("kick {skull} then {cross}") == nil, "two different markers are ignored")
check(Parse("kick {skull} {skull}") == 8, "the same marker twice still counts")
check(Parse("interrupt nothing") == nil, "no marker, no owner")

local function chat(text, guid)
    handler(nil, "CHAT_MSG_PARTY", text, "Name", "", "", "", "", 0, 0, "", 0, 1, guid)
end
chat("Interrupt target set to {moon}", "Player-1-B")
check(global.kickMarks["Player-1-B"] and global.kickMarks["Player-1-B"].marker == 5, "a party member's announce is saved by their GUID")
chat("Interrupt target set to {skull}", "Player-9-Z")
check(global.kickMarks["Player-9-Z"] == nil, "someone outside the group is ignored")
chat("kick {square}", "Player-1-C")
check(global.kickMarks["Player-1-C"].marker == 6, "a typed announce counts too")
chat("kick {star}", "Player-1-C")
check(global.kickMarks["Player-1-C"].marker == 1, "a newer announce replaces the old marker")
global.kickMarks["Player-1-B"].at = 0
handler(nil, "GROUP_ROSTER_UPDATE")
check(global.kickMarks["Player-1-B"] == nil, "old announces expire")
FocusControlDB = { marker = 7 }
handler(nil, "GROUP_ROSTER_UPDATE")
check(true, "own FocusControl marker rebuild runs")

local function Shape(list)
    local parts = {}
    for _, seg in ipairs(list) do parts[#parts + 1] = seg.low .. "-" .. seg.high .. (#seg.owners > 0 and "*" or "") end
    return table.concat(parts, " ")
end
check(Shape(Kickers.Segments({})) == "0-8", "no owners: one range covers every marker and no marker")
check(Shape(Kickers.Segments({ [8] = { {} } })) == "0-7 8-8*", "skull owned: skull alone, the rest shared")
check(Shape(Kickers.Segments({ [1] = { {} }, [5] = { {} } })) == "0-0 1-1* 2-4 5-5* 6-8", "star and moon owned split the gaps around them")
