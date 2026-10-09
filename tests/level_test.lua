local ns = { Elements = {}, Driver = { RegisterElement = function() end, ForEachActive = function() end },
    DB = { views = { enemy = { friendly = { levelEnabled = true } } } } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function issecretvalue() return false end
function ns.ApplyFont() end
function ns.ApplyShadow() end
function ns.PlaceText() end
function ns.Runs() return true end
function UnitLevel() return 90 end
function UnitEffectiveLevel() return 90 end
function UnitClassification() return "normal" end
function UnitQuestTrivialLevelRange() return 8 end
local instance = false
function IsInInstance() return instance end
local zoneHandler
function CreateFrame()
    return { RegisterEvent = function() end, SetScript = function(_, _, fn) zoneHandler = fn end }
end

local function FakeText()
    local t = { shown = false }
    function t:SetText(v) self.text = v end
    function t:SetFormattedText(f, ...) self.text = f:format(...) end
    function t:SetTextColor() end
    function t:Show() self.shown = true end
    function t:Hide() self.shown = false end
    function t:SetWordWrap() end
    return t
end

assert(loadfile("Plateau/Elements/Level.lua"))("Plateau", ns)
local Level = ns.Elements.Level
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Db(extra)
    local db = { colorByDifficulty = false, showElitePlus = true, hideAtPlayerLevel = false, color = { 1, 1, 1, 1 },
        hideInInstances = false, bossText = "unknown", markRares = false, hideTrivial = false }
    for k, v in pairs(extra or {}) do db[k] = v end
    return db
end

local plate = { state = "enemy", overlay = { CreateFontString = function() return FakeText() end } }
Level:Create(plate)
local function Show(extra, level, classification)
    Level:Configure(Db(extra), "enemy")
    Level:Render(plate, level, classification)
    return plate.level.shown and plate.level.text or nil
end

check(Show(nil, 90, "elite") == "90+", "elite gets a +")
check(Show({ markRares = true }, 90, "rare") == "90r", "mark rares adds r")
check(Show({ markRares = true }, 90, "rareelite") == "90r+", "rare elites get r+")
check(Show(nil, 90, "rare") == "90", "rares are unmarked by default")
check(Show(nil, -1, "worldboss") == "??", "bosses show ?? by default")
check(Show({ bossText = "boss" }, -1, "worldboss") == "Boss", "boss text can be Boss")
check(Show({ bossText = "skull" }, -1, "worldboss"):find("Skull") ~= nil, "boss text can be a skull icon")
check(Show({ bossText = "hide" }, -1, "worldboss") == nil, "boss level can be hidden")
check(Show({ hideTrivial = true }, 70, "normal") == nil, "hide trivial hides a level far below yours")
check(Show({ hideTrivial = true }, 85, "normal") == "85", "hide trivial keeps a level within range")

instance = true
zoneHandler()
check(Show({ hideInInstances = true }, 90, "elite") == nil, "hide in dungeons and raids hides levels inside")
instance = false
zoneHandler()
check(Show({ hideInInstances = true }, 90, "elite") == "90+", "and shows them again outside")
