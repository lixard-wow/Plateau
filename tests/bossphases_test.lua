local global = {}
local views = { enemy = { health = { fillDirection = "left" } } }
local ns = { Elements = {}, MarkerLayer = function(plate) return plate.health end, DB = { saved = { global = global }, views = views },
    Driver = { RegisterElement = function() end, ForEachActive = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function ns.Runs() return true end
function issecretvalue() return false end
local instance = true
function IsInInstance() return instance end
local handler
function CreateFrame()
    return { RegisterEvent = function() end, SetScript = function(_, _, fn) handler = fn end }
end
Plateau = {}
Plateau.T = Plateau.T or (function() local l = {} assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", l) return l.T end)()

assert(loadfile("Plateau/Elements/BossPhases.lua"))("Plateau", ns)
local BossPhases = ns.Elements.BossPhases
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Texture()
    local t = { shown = false, points = {} }
    function t:Show() self.shown = true end
    function t:Hide() self.shown = false end
    function t:ClearAllPoints() self.points = {} end
    function t:SetPoint(point, _, _, x) self.points[#self.points + 1] = { point = point, x = x } end
    function t:SetWidth() end
    function t:SetColorTexture() end
    return t
end

local function Plate(mobType)
    local plate = { state = "enemy", mobType = mobType }
    plate.health = { CreateTexture = function() return Texture() end }
    function plate:GetWidth() return 200 end
    BossPhases:Create(plate)
    return plate
end

local function Shown(plate)
    local xs = {}
    for _, line in ipairs(plate.phaseLines) do
        if line.shown then xs[#xs + 1] = line.points[1].x end
    end
    return xs
end

BossPhases:Configure({ color = { 1, 1, 1, 1 }, lineWidth = 2, defaults = "", instancesOnly = true }, "enemy")

local boss = Plate("boss")
handler(nil, "PLAYER_ENTERING_WORLD")
BossPhases.enabled = false
handler(nil, "ENCOUNTER_START", 3202, "Someone Else")
check(not (global.bossesSeen and global.bossesSeen[3202]), "with boss phase lines off, encounters aren't recorded")
handler(nil, "ENCOUNTER_END")
BossPhases.enabled = true
handler(nil, "ENCOUNTER_START", 3201, "Lightwarden Ruia")
BossPhases:Update(boss)
local xs = Shown(boss)
check(#xs == 2 and xs[1] == 140 and xs[2] == 80, "Lightwarden Ruia gets her built-in 70 and 40 lines")
check(global.bossesSeen and global.bossesSeen[3201] == "Lightwarden Ruia", "the boss is remembered for the settings list")

Plateau.SetBossPhaseLines(3201, "55")
BossPhases:Update(boss)
xs = Shown(boss)
check(#xs == 1 and xs[1] == 110, "your own percentages replace the built-in ones")
Plateau.SetBossPhaseLines(3201, nil)
check(Plateau.BossPhaseLines(3201) == "70, 40", "right-click reset goes back to the built-in percentages")

local trash = Plate("caster")
BossPhases:Update(trash)
check(#Shown(trash) == 0, "non-boss plates never get phase lines")

handler(nil, "ENCOUNTER_START", 2139, "The Golden Serpent")
BossPhases:Update(boss)
check(#Shown(boss) == 0, "a boss with no health phases gets no lines")

BossPhases:Configure({ color = { 1, 1, 1, 1 }, lineWidth = 2, defaults = "30", instancesOnly = true }, "enemy")
handler(nil, "ENCOUNTER_END")
BossPhases:Update(boss)
xs = Shown(boss)
check(#xs == 1 and xs[1] == 60, "outside a fight, boss plates use the default lines")

instance = false
handler(nil, "PLAYER_ENTERING_WORLD")
BossPhases:Update(boss)
check(#Shown(boss) == 0, "default lines stay off open-world bosses")

local broken = Plate("boss")
function broken:GetWidth() error("measuring failed") end
instance = true
handler(nil, "PLAYER_ENTERING_WORLD")
local ok = pcall(BossPhases.Update, BossPhases, broken)
check(ok and ns.bossPhaseError ~= nil, "a failure inside is caught silently and noted for /plt debug")

handler(nil, "ENCOUNTER_START", 3101, "Kystia Manaheart")
local pet = Plate("elite")
BossPhases:Update(pet)
xs = Shown(pet)
check(#xs == 1 and xs[1] == 40, "Kystia's fight puts the 20% line on her pet, a non-boss enemy")
Plateau.SetBossPhaseTarget(3101, "boss")
BossPhases:Update(pet)
check(#Shown(pet) == 0, "switching Kystia to bosses only takes it off the pet")
Plateau.SetBossPhaseTarget(3101, nil)
check(Plateau.BossPhaseTarget(3101) == "all", "reset puts Kystia back on every enemy")
handler(nil, "ENCOUNTER_START", 3201, "Lightwarden Ruia")
BossPhases:Update(pet)
check(#Shown(pet) == 0, "other bosses' lines stay off non-boss plates")

check(Plateau.AddBossPhaseBoss(2654, "Ara-Kara boss") and global.bossesSeen[2654] == "Ara-Kara boss", "a boss can be added by encounter ID with a name")
check(Plateau.AddBossPhaseBoss(2655, "") and global.bossesSeen[2655] == "Encounter 2655", "an ID without a name gets a placeholder name")
check(not Plateau.AddBossPhaseBoss(-1), "a bad ID is refused")
