LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Share.lua")
local DB, Share = ns.DB, ns.Share
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local sample = { a = "x^y\z|w", b = 1.25, c = true, d = { 0.1, 0.2, 0.3, 1 }, [3] = false }
local round = Share.Deserialize(Share.Serialize(sample))
check(round.a == sample.a and round.b == 1.25 and round.c == true and round.d[3] == 0.3 and round[3] == false, "serializer round trip incl. escapes")
check(Share.Deserialize("{s1^") == nil and Share.Deserialize("x") == nil, "malformed data rejected")

PlateauDB = nil
DB:Init()
DB:Set("look.castbar.height", 18)
DB:Set("look.castbar.interruptible", { 0, 1, 0 })
local text = DB:ExportProfile()
local exported = ns.Share.Decode(text)
check(exported.look.colors.elite ~= nil and exported.look.colors.eliteColor ~= nil, "export carries every setting, not just changes")
check(type(text) == "string" and text:sub(1, 5) == "!SL1!" and not text:find("[^%w%(%)!]"), "export is printable")

check(DB:ImportProfile("Shared", text, true), "import creates a profile")
check(DB.profileName == "Shared", "import switches to it")
check(DB.views.enemy.castbar.height == 18 and DB.views.enemy.castbar.interruptible[2] == 1, "base look imported")
check(DB.views.friendly.castbar.height == 18, "friendly reads the same imported look, since there's no override layer anymore")
check(not DB:ImportProfile("Shared", text), "existing name rejected")
check(not DB:ImportProfile("Bad", "hello"), "non-Plateau string rejected")
check(not DB:ImportProfile("Bad", "!SL1!zzzz"), "damaged string rejected")

local hostile = LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(Share.Serialize({
    version = 4, look = { castbar = { height = "tall", nope = 1, interruptible = { "a" } }, junk = { x = 1 } } })))
check(DB:ImportProfile("Hostile", "!SL1!" .. hostile, true), "import with wrong types still succeeds")
check(DB.views.enemy.castbar.height == 10 and DB.views.enemy.castbar.interruptible[1] == 1, "wrong types dropped, defaults used")
check(rawget(DB.saved.profiles.Hostile.look, "junk") == nil, "unknown groups dropped")

local old = LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(Share.Serialize({
    version = 1, look = { highlight = { color = { 1, 0, 0, 1 }, size = 4 } } })))
check(DB:ImportProfile("Old", "!SL1!" .. old, true) and DB.views.enemy.target.ringSize == 4, "old-version string is migrated before cleaning")

local function pack(value)
    return "!SL1!" .. LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(Share.Serialize(value)))
end
local function raw(serialized)
    return "!SL1!" .. LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(serialized))
end

check(not DB:ImportProfile("V1", pack({ version = -1e308, look = {} }), true), "endless-migration version rejected")
check(not DB:ImportProfile("V2", pack({ version = 1e308, look = {} }), true), "huge version rejected")
check(not DB:ImportProfile("V3", pack({ version = 0, look = {} }), true), "zero version rejected")
check(DB:ImportProfile("V4", pack({ version = 1.5, look = { highlight = { color = { 1, 0, 0, 1 }, size = 9 } } }), true) and DB.views.enemy.target.ringSize == 9, "fractional version is floored and migrated")
check(not DB:ImportProfile("V5", pack({ version = 1, look = { highlight = "text" } }), true), "migration that cannot read the data is refused")
check(DB.saved.profiles.V5 == nil, "refused import creates nothing")

check(DB:ImportProfile("Big1", raw("{sversion^n7^slook^{scastbar^{sheight^n1e999^}}}"), true) and DB.views.enemy.castbar.height == 10, "infinite number dropped")
check(DB:ImportProfile("Big2", pack({ version = 7, look = { castbar = { height = 5e9 } } }), true) and DB.views.enemy.castbar.height == 10, "out of range number dropped")
check(DB:ImportProfile("Big3", raw("{sversion^n7^slook^{scastbar^{sinterruptible^{n1^n1e999^n2^n0.5^n3^n0.5^n4^n1^}}}}"), true) and DB.views.enemy.castbar.interruptible[1] == 1, "infinite colour channel replaced with the default")
check(DB:ImportProfile("Long1", pack({ version = 7, look = { castbar = { font = string.rep("a", 5000) } } }), true) and #tostring(DB.views.enemy.castbar.font) < 300, "overlong string dropped")

local wide = {}
for i = 1, 30000 do wide[i] = true end
check(not DB:ImportProfile("Wide", pack({ version = 7, look = wide }), true), "payload with too many values rejected")
check(not DB:ImportProfile("Long2", "!SL1!" .. string.rep("a", 70000), true), "oversize string rejected")

check(#text < 60000, "a real export is well under the size limit")
check(#DB:ExportProfile() < 20000, "a real export is a sensible size: " .. #DB:ExportProfile())

DB.saved.global.bossPhases = { [111] = "70,40" }
local existingName = next(DB.saved.profiles)
local withBoss = pack({ version = 17, look = {}, bossPhases = { lines = { [111] = "10" }, on = {}, names = {} } })
check(not DB:ImportProfile(existingName, withBoss, false) and DB.saved.global.bossPhases[111] == "70,40", "an import refused for a duplicate name leaves your boss phase lines alone")
local okPipe, pipeName = DB:ImportProfile("|cffff0000Red|r" .. string.rep("x", 60), pack({ version = 17, look = {} }), false)
check(okPipe and not pipeName:find("|", 1, true) and #pipeName <= 32, "imported names lose color codes and are cut to 32 letters")
local okBlank, blankName = DB:ImportProfile("|||", pack({ version = 17, look = {} }), false)
check(okBlank and blankName:find("^Imported"), "a name that is empty after cleaning becomes Imported")
check(not DB:ImportProfile("Long", "!SL1!" .. string.rep("A", 20001), false), "strings over 20,000 characters are refused before unpacking")

local okBad, badName = DB:ImportProfile("Bad values", pack({ version = 17, look = { castbar = { textJustify = "SIDEWAYS", importantScale = 0 }, scaling = { boss = -2, castScale = 99 }, name = { justify = "RIGHT" } } }), false)
check(okBad, "an import with bad values still imports")
local bad = DB.saved.profiles[badName].look
check(bad.castbar.textJustify == nil and bad.name.justify == "RIGHT", "an unknown text alignment is dropped and a valid one kept")
check(bad.castbar.importantScale == 0.1 and bad.scaling.boss == 0.1 and bad.scaling.castScale == 5, "scale values are kept between 0.1 and 5, so the game never gets a zero or negative scale")
