local ns = { Elements = {}, Driver = { RegisterElement = function() end }, UnitColors = { IsCompanion = function() return false end, PlayerClass = function(_, unit) return UnitClassBase(unit) end },
    DB = { views = { enemy = { friendly = { npcNameScale = nil, nameOffsetY = 0, nameMode = "full", npcNameMode = "full", classColors = true } } } } }
function issecretvalue() return false end
function ns.ApplyFont() end
function ns.ApplyShadow() end
function ns.PlaceText() end
function ns.CleanName(n) return n end
local blizzardSize = "3"
C_CVar = { GetCVarBool = function() return true end, GetCVar = function(name) if name == "nameplateSize" then return blizzardSize end end }

local function FakeRegion()
    local r = { shown = true }
    function r:Show() self.shown = true end
    function r:Hide() self.shown = false end
    function r:SetText(t) self.text = t end
    function r:GetText() return self.text end
    function r:SetTextColor() end
    function r:SetWordWrap() end
    function r:ClearAllPoints() end
    function r:SetHeight() end
    function r:SetPoint() end
    function r:SetClipsChildren() end
    function r:SetJustifyV() end
    function r:SetJustifyH() end
    function r:SetAllPoints() end
    function r:GetStringWidth() return 50 end
    function r:GetWidth() return 100 end
    function r:RegisterEvent() end
    function r:SetScript() end
    function r:SetFrameLevel() end
    function r:GetFrameLevel() return 1 end
    return r
end
function CreateFrame()
    local f = FakeRegion()
    function f:CreateFontString() return FakeRegion() end
    function f:GetFrameLevel() return 1 end
    return f
end

local fakeName, fakeRealm, fakeIsPlayer = "Wastelander Phaseblade", nil, false
function UnitName() return fakeName, fakeRealm end
function UnitIsPlayer() return fakeIsPlayer end
function UnitClassBase() return nil end

assert(loadfile("Plateau/Elements/Name.lua"))("Plateau", ns)
local Name = ns.Elements.Name
local Shorten = ns.ShortenName
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

check(Shorten("Wastelander Phaseblade", "lastWord") == "Phaseblade", "last word")
check(Shorten("Wastelander Phaseblade", "firstWord") == "Wastelander", "first word")
check(Shorten("Grunt", "firstWord") == "Grunt", "first word, single word unchanged")
check(Shorten("Wastelander Phaseblade", "abbreviate") == "W. Phaseblade", "abbreviate two words")
check(Shorten("Grand Void Ritualist", "abbreviate") == "G. V. Ritualist", "abbreviate three words")
check(Shorten("Grunt", "lastWord") == "Grunt" and Shorten("Grunt", "abbreviate") == "Grunt", "single word unchanged")
check(Shorten("Wastelander Phaseblade", "full") == "Wastelander Phaseblade", "full unchanged")
check(Shorten("Aelindra Dawnsong", "lastInitial") == "Aelindra D.", "first word + last initial")
check(Shorten("Grunt", "lastInitial") == "Grunt", "first word + last initial, single word unchanged")
check(Shorten("Aelindra Dawnsong", "initials") == "A.D.", "both initials")
check(Shorten("Grunt", "initials") == "Grunt", "both initials, single word unchanged")
check(Shorten("Élise Dawnsong", "initials") == "É.D.", "both initials keeps a full multi-byte UTF-8 first letter")
check(Shorten("Élise Dawnsong", "lastInitial") == "Élise D.", "first word + last initial keeps a full multi-byte UTF-8 first word")
check(Shorten("Örvar Ångström Kjellén", "abbreviate") == "Ö. Å. Kjellén", "abbreviate keeps full multi-byte UTF-8 initials")

local plate = { overlay = CreateFrame(), state = "friendly", nameOnly = false }
Name:Create(plate)
ns.DB.views.enemy.friendly.npcNameMode = "lastWord"
Name:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "" }, "friendly")
Name:Update(plate, "target")
check(plate.name:GetText() == "Phaseblade", "friendly NPC names dropdown (npcMode) actually applies, not stuck on full")

ns.DB.views.enemy.friendly.npcNameMode = "firstWord"
Name:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "" }, "friendly")
Name:Update(plate, "target")
check(plate.name:GetText() == "Wastelander", "friendly NPC names dropdown switches to first word correctly")

fakeName, fakeRealm, fakeIsPlayer = "Aelindra", "Stormrage", true
Name:Update(plate, "target")
check(plate.name:GetText() == "Aelindra-Stormrage", "realm names on: a friendly player from another realm shows Name-Realm")
Name:Update(plate, "target")
check(plate.nameSize == 9, "friendly player names are not scaled again; the plate already follows Blizzard's Nameplate Size")
fakeIsPlayer = false
ns.DB.views.enemy.friendly.npcNameScale = 3
Name:Update(plate, "target")
check(math.abs(plate.nameSize - 9) < 1e-9, "a friendly NPC at the same step as Blizzard's Nameplate Size gets the same size as players")
ns.DB.views.enemy.friendly.npcNameScale = 5
Name:Update(plate, "target")
check(math.abs(plate.nameSize - 9 * 1.6 / 1.25) < 1e-9, "a larger NPC step scales relative to Blizzard's size")
ns.DB.views.enemy.friendly.npcNameScale = nil
fakeIsPlayer = true
plate.state = "enemy"
Name:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "", mode = "full" }, "enemy")
Name:Update(plate, "target")
check(plate.name:GetText() == "Aelindra", "realm names stay off enemy plates, like Blizzard's setting")
plate.state = "friendly"
fakeName, fakeRealm, fakeIsPlayer = "Wastelander Phaseblade", nil, false

do
    local ns2 = { Elements = {}, Driver = { RegisterElement = function() end }, UnitColors = { IsCompanion = function() return false end, PlayerClass = function(_, unit) return UnitClassBase(unit) end },
        DB = { views = { enemy = { friendly = { npcNameScale = nil, nameOffsetY = 0, nameMode = "full", npcNameMode = "full", classColors = true } } } },
        flavor = "forever" }
    function ns2.ApplyFont() end
    function ns2.ApplyShadow() end
    function ns2.PlaceText() end
    function ns2.CleanName(n) return n end

    function UnitName() return "Zephyrus", "Lost" end
    function UnitIsPlayer() return true end
    function UnitClassBase() return nil end

    assert(loadfile("Plateau/Elements/Name.lua"))("Plateau", ns2)
    local ForeverName = ns2.Elements.Name

    local fplate = { overlay = CreateFrame(), state = "friendly", nameOnly = false }
    ForeverName:Create(fplate)
    ForeverName:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "" }, "friendly")
    ForeverName:Update(fplate, "target")
    check(fplate.name:GetText() == "Zephyrus Lost", "forever: UnitName's second return is combined in as the surname")

    ns2.DB.views.enemy.friendly.nameMode = "lastWord"
    ForeverName:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "" }, "friendly")
    ForeverName:Update(fplate, "target")
    check(fplate.name:GetText() == "Lost", "forever: last word only shows the real surname, not the given name")

    ns2.DB.views.enemy.friendly.nameMode = "firstWord"
    ForeverName:Configure({ color = {1,1,1,1}, font = "x", size = 9, outline = "" }, "friendly")
    ForeverName:Update(fplate, "target")
    check(fplate.name:GetText() == "Zephyrus", "forever: first word only shows the given name")
end
