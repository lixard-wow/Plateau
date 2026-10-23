LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Share.lua")
local DB, Share = ns.DB, ns.Share
local Inflate = Share.Inflate
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local seed = 7
local function Random(n)
    seed = (seed * 1103515245 + 12345) % 2147483648
    return seed % n
end

local function Sample(size, alphabet)
    local parts = {}
    for i = 1, size do
        parts[i] = string.char(32 + Random(alphabet))
    end
    return table.concat(parts)
end

local cases = {
    { "empty", "" },
    { "short text", "Plateau nameplates" },
    { "repeating text", string.rep("look.castbar.height=18;", 400) },
    { "mixed text", Sample(20000, 40) },
    { "noisy text", Sample(5000, 95) },
}
for _, case in ipairs(cases) do
    for _, level in ipairs({ 0, 1, 5, 9 }) do
        local packed = LibDeflate:CompressDeflate(case[2], { level = level })
        local unpacked = Inflate(packed, 1000000)
        check(unpacked == case[2], case[1] .. " unpacks exactly at compression level " .. level)
    end
end

PlateauDB = nil
DB:Init()
DB:Set("look.castbar.height", 18)
local text = DB:ExportProfile()
local payload = Share.Decode(text)
check(type(payload) == "table" and payload.look.castbar.height == 18, "a real profile export still imports")

local bomb = "!SL1!" .. LibDeflate:EncodeForPrint(LibDeflate:CompressDeflate(string.rep("a", 2000000), { level = 9 }))
local started = os.clock()
local result, reason = Share.Decode(bomb)
check(#bomb < 60000 and result == nil and reason ~= nil, "a small string that unpacks to 2 MB is rejected")
local packed = LibDeflate:CompressDeflate(string.rep("a", 2000000), { level = 9 })
local stopped, problem = Inflate(packed, 1000000)
check(stopped == nil and problem == "too large", "unpacking stops at the size limit instead of building the whole thing")
check(os.clock() - started < 2, "rejecting the oversized string stays quick")

local good = LibDeflate:CompressDeflate(string.rep("profile ", 500), { level = 9 })
local truncated, truncatedProblem = Inflate(good:sub(1, #good - 5), 1000000)
check(truncated == nil and truncatedProblem == "damaged", "a cut-off string is rejected as damaged")
check(Inflate("\255\255\255\255", 1000000) == nil, "garbage is rejected")
check(Share.Decode("!SL1!" .. LibDeflate:EncodeForPrint("\255\255\255\255")) == nil, "garbage in a profile string is rejected")
