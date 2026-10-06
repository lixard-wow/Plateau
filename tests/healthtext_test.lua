local ns = { Elements = {}, Driver = { RegisterElement = function() end }, DB = { views = { enemy = { execute = { threshold = 20 } } } } }
function issecretvalue() return false end
CurveConstants = { ScaleTo100 = 100 }
Enum = { LuaCurveType = { Step = 0, Linear = 1 } }
local function FakeCurve() return { SetType = function() end, AddPoint = function() end } end
C_CurveUtil = { CreateCurve = FakeCurve, CreateColorCurve = FakeCurve }
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end
function AbbreviateNumbers(value, abbreviate)
    local k = abbreviate.breakpointData[3]
    if value >= 1000 then
        local whole = math.floor(value / k.significandDivisor) / k.fractionDivisor
        return (k.fractionDivisor == 1 and "%d" or "%.1f"):format(whole) .. "K"
    end
    return tostring(math.floor(value))
end
function ns.ApplyFont() end
function ns.ApplyShadow() end
function ns.PlaceText() end

local function FakeText()
    local t = {}
    function t:SetText(v) self.text = v end
    function t:SetFormattedText(f, ...) self.text = f:format(...) end
    function t:SetTextColor(r, g, b, a) self.color = { r, g, b, a } end
    function t:SetAlpha(a) self.alpha = a end
    function t:Show() self.shown = true end
    function t:Hide() self.shown = false end
    function t:SetShown(v) self.shown = v end
    function t:SetWordWrap() end
    return t
end

assert(loadfile("Plateau/Elements/HealthText.lua"))("Plateau", ns)
local HealthText = ns.Elements.HealthText
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Db(extra)
    local db = {
        format = "percent", decimals = 0, color = { 1, 1, 1, 1 }, valuePrecision = "standard", percentSign = true,
        hideFull = false, targetOnly = false, colorByHealth = false,
        colorHigh = { 0, 1, 0, 1 }, colorMid = { 1, 1, 0, 1 }, colorLow = { 1, 0, 0, 1 },
        executeColor = false, executeTextColor = { 1, 0, 1, 1 },
    }
    for k, v in pairs(extra or {}) do db[k] = v end
    return db
end

local plate = { state = "enemy", overlay = { CreateFontString = function() return FakeText() end } }
HealthText:Create(plate)
local sample = { health = 0.87, maxHealth = 60000 }

local function Show(extra, health)
    HealthText:Configure(Db(extra), "enemy")
    HealthText:Preview(plate, { health = health or sample.health, maxHealth = sample.maxHealth })
    return plate.healthText.text
end

check(Show({ format = "percent" }) == "87%", "percent")
check(Show({ format = "percent", percentSign = false }) == "87", "percent without the % sign")
check(Show({ format = "value" }) == "52.2K", "value, standard precision")
check(Show({ format = "value", valuePrecision = "whole" }) == "52K", "value, whole numbers")
check(Show({ format = "both" }) == "52.2K | 87%", "both")
check(Show({ format = "paren" }) == "52.2K (87%)", "both with brackets")
check(Show({ format = "percentFirst" }) == "87% | 52.2K", "percent first")
check(Show({ format = "valueMax" }) == "52.2K / 60.0K", "value / max")
check(Show({ format = "missing" }) == "-7.8K", "missing health")
check(Show({ format = "missingPercent" }) == "-13%", "missing percent")

Show({ hideFull = true }, 1)
check(plate.healthText.alpha == 0, "hide at full health hides an untouched enemy")
Show({ hideFull = true }, 0.5)
check(plate.healthText.alpha == 1, "hide at full health shows a damaged enemy")

Show({ colorByHealth = true }, 1)
check(plate.healthText.color[1] == 0 and plate.healthText.color[2] == 1, "color by health: full health uses the full color")
Show({ colorByHealth = true }, 0.5)
check(plate.healthText.color[1] == 1 and plate.healthText.color[2] == 1, "color by health: half health uses the half color")
Show({ colorByHealth = true, executeColor = true }, 0.1)
check(plate.healthText.color[1] == 1 and plate.healthText.color[3] == 1, "execute range color beats color by health below the threshold")

HealthText:Configure(Db({ targetOnly = true }), "enemy")
plate.isTarget = false
HealthText:UpdateEmphasis(plate)
check(plate.healthText.shown == false, "only on my target hides it on other enemies")
plate.isTarget = true
HealthText:UpdateEmphasis(plate)
check(plate.healthText.shown == true, "only on my target shows it on the target")
