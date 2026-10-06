local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

DB:Init()

local function IsColor(value)
    return type(value) == "table" and value[1] ~= nil
end

local paths = {}
local function Walk(group, prefix)
    for key, value in pairs(group) do
        local path = prefix .. key
        if type(value) == "table" and not IsColor(value) then
            Walk(value, path .. ".")
        else
            paths[#paths + 1] = { path = path, default = value }
        end
    end
end
Walk(ns.defaults, "")
table.sort(paths, function(a, b) return a.path < b.path end)

local wanted, rejected = {}, {}
for _, entry in ipairs(paths) do
    local default, value = entry.default, nil
    if type(default) == "number" then
        value = default + 3
    elseif type(default) == "boolean" then
        value = not default
    elseif type(default) == "string" then
        value = default .. "X"
    else
        value = { 0.11, 0.22, 0.33, default[4] and 0.5 or nil }
    end
    if DB:Set(entry.path, value) then
        wanted[entry.path] = value
    else
        rejected[#rejected + 1] = entry.path
    end
end
check(#rejected == 0, "every default setting accepts a changed value" .. (#rejected > 0 and (": " .. rejected[1]) or ""))

DB:Shutdown()
DB:Init()

local lost = {}
for path, value in pairs(wanted) do
    local got = DB:Get(path)
    local same
    if type(value) == "table" then
        same = got[1] == value[1] and got[2] == value[2] and got[3] == value[3]
    else
        same = got == value
    end
    if not same then
        lost[#lost + 1] = path
    end
end
table.sort(lost)
check(#lost == 0, ("all %d changed settings survive logout and login"):format(#paths) .. (#lost > 0 and (": " .. lost[1]) or ""))

check(DB:Set("look.raidMarker.position", "TOP") and DB:Set("look.raidMarker.gap", 0) and DB:Set("look.raidMarker.offsetY", 2), "raid marker placement set")
DB:Shutdown()
DB:Init()
check(DB:Get("look.raidMarker.position") == "TOP" and DB:Get("look.raidMarker.gap") == 0 and DB:Get("look.raidMarker.offsetY") == 2, "raid marker placement survives logout and login")
