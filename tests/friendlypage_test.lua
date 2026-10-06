LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

function issecretvalue() return false end
function UnitClassBase() return "MAGE" end
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end
GameTooltip = { SetOwner = function() end, SetText = function() end, AddLine = function() end, Show = function() end, Hide = function() end }
local stub = { HookScript = function() end, SetScript = function() end }
function CreateFrame() return stub end

local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
local function load(path) assert(loadfile(path))("Plateau", ns) end
load("Plateau/Core/Defaults.lua"); load("Plateau/Core/Database.lua"); load("Plateau/Core/Share.lua")
local DB = ns.DB
PlateauDB = nil
DB:Init()

Plateau = { DB = DB, brand = { { 1, 1, 1, 1 }, { 1, 1, 1, 1 }, { 1, 1, 1, 1 } }, Brand = { OnChange = function() end, Text = function(_, t) return t end } }
local nsOpt = {}
local function loadOpt(path) assert(loadfile(path))("Plateau_Options", nsOpt) end
loadOpt("Plateau_Options/Widgets/Style.lua")

local function FriendlyStyled()
    return nsOpt.Get("look.friendly.nameOnly") == false
end

local classColors = { path = "look.friendly.classColors", label = "Use class colors for names" }

DB:Set("look.friendly.nameOnly", true)
check(FriendlyStyled() == false, "hidden while name-only is on, the shape the Friendly page's Full nameplate controls use")
DB:Set("look.friendly.nameOnly", false)
check(FriendlyStyled() == true, "shown once a full nameplate is drawn")

check(nsOpt.SpecGet(classColors) == ns.defaults.look.friendly.classColors, "a Friendly-only control starts at its own default")
DB:Set("look.name.classColors", true)
nsOpt.SpecSet(classColors, false)
check(DB.views.enemy.name.classColors == true, "Enemy's own class-colors setting is untouched")
check(nsOpt.SpecGet(classColors) == false, "Friendly's independent class-colors setting took the new value")
check(DB.views.friendly.name == DB.views.enemy.name, "friendly reads the same settings as enemy apart from the raid marker placement")

DB:Reset("look.friendly.classColors")
check(nsOpt.SpecGet(classColors) == ns.defaults.look.friendly.classColors, "resetting Friendly's own setting returns it to its own default")
check(DB.views.enemy.name.classColors == true, "...without touching Enemy's setting")
