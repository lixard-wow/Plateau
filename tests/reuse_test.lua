local ns = { Elements = {}, Driver = { RegisterElement = function() end } }
function issecretvalue() return false end
function ns.ApplyFont() end
function ns.ApplyShadow() end
function ns.PlaceText() end
function ns.PlaceIcon() end

local function FakeRegion()
    local region = { shown = true }
    function region:Show() self.shown = true end
    function region:Hide() self.shown = false end
    function region:IsShown() return self.shown end
    function region:SetShown(v) self.shown = v and true or false end
    function region:SetSize() end
    function region:SetWordWrap() end
    function region:SetJustifyV() end
    function region:SetAtlas(a) self.atlas = a end
    function region:SetText(t) self.text = t end
    function region:SetFormattedText(fmt, ...) self.text = fmt:format(...) end
    function region:SetTextColor() end
    function region:SetAlpha() end
    return region
end

function CreateFrame()
    local frame = FakeRegion()
    function frame:CreateTexture() return FakeRegion() end
    function frame:CreateFontString() return FakeRegion() end
    function frame:RegisterEvent() end
    function frame:SetScript() end
    return frame
end

local classification, level = "elite", 79
function UnitClassification() return classification end
function UnitEffectiveLevel() return level end
function UnitLevel() return 80 end

local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Elements/Classification.lua")
load("Elements/Level.lua")

local Classification, Level = ns.Elements.Classification, ns.Elements.Level
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local plate = { overlay = CreateFrame(), state = "enemy" }
Classification:Create(plate)
Classification:Configure({ showElite = true, showBoss = true, showRareElite = true, showRare = true }, "enemy")
Level:Create(plate)
Level:Configure({ colorByDifficulty = false, showElitePlus = true, hideAtPlayerLevel = false, color = { 1, 1, 1, 1 } }, "enemy")

Classification:Enable(plate, "unitA")
check(plate.classification.shown == true, "classification icon shown for unitA")
Classification:Disable(plate)
check(plate.classification.shown == false, "classification icon hidden on disable")
Classification:Enable(plate, "unitB")
check(plate.classification.shown == true, "classification icon shown again for unitB with the same classification as unitA")

Level:Enable(plate, "unitA")
check(plate.level.shown == true, "level text shown for unitA")
Level:Disable(plate)
check(plate.level.shown == false, "level text hidden on disable")
Level:Enable(plate, "unitB")
check(plate.level.shown == true, "level text shown again for unitB at the same level as unitA")
