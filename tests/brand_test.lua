local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local frames = {}
function CreateFrame()
    local f = { scripts = {}, shown = true }
    function f:RegisterEvent() end
    function f:SetScript(n, fn) self.scripts[n] = fn end
    function f:Hide() self.shown = false end
    function f:Show() self.shown = true end
    function f:SetShown(v) self.shown = v and true or false end
    frames[#frames + 1] = f
    return f
end
local class = "PALADIN"
function UnitClass() return "Paladin", class end
RAID_CLASS_COLORS = { PALADIN = { r = 0.96, g = 0.55, b = 0.73 }, MAGE = { r = 0.25, g = 0.78, b = 0.92 } }
local ns = { DB = { saved = { global = {} } } }
local function noop() end
local source = io.open("Plateau/Core/Media.lua"):read("*a")
local start = source:find('local Brand = CreateFrame%("Frame"%)')
local chunk = assert(loadstring("local ns = ...\n" .. source:sub(start)))
chunk(ns)
local Brand = ns.Brand
local seen = {}
Brand:OnChange(function(r, g, b) seen[#seen + 1] = { r, g, b } end)
Brand.scripts.OnEvent(Brand, "PLAYER_LOGIN")
local r, g, b = Brand:Color()
check(Brand:Mode() == "class" and r == 0.96 and b == 0.73, "class colour is the default and uses the player's class")
check(Brand:Text("Plateau") == "|cfff58cbaPlateau|r", "Text wraps a word in the current colour")
check(#seen >= 2, "listeners hear the change")
check(Brand.shown == false, "the colour cycle timer is off unless cycling")
Brand:SetMode("cycle")
check(Brand.shown == true and ns.DB.saved.global.brandColor == "cycle", "colour cycle starts the timer and is saved")
local before = { Brand:Color() }
Brand.scripts.OnUpdate(Brand, 1)
local after = { Brand:Color() }
check(before[1] ~= after[1] or before[2] ~= after[2] or before[3] ~= after[3], "the cycle moves the colour over time")
Brand:SetMode("random")
local first = { Brand:Color() }
check(Brand.shown == false, "random stops the cycle timer")
Brand:Refresh()
local again = { Brand:Color() }
check(first[1] == again[1] and first[2] == again[2] and first[3] == again[3], "random keeps the same colour for the whole session")
Brand:SetMode("class")
check(ns.DB.saved.global.brandColor == nil, "going back to class colour clears the saved choice")
Brand:SetMode("bogus")
check(Brand:Mode() == "class", "an unknown choice falls back to class colour")
