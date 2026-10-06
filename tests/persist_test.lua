local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function IsColor(value)
    return type(value) == "table" and #value >= 3 and #value <= 4 and type(value[1]) == "number"
end

local function Changed(value)
    if type(value) == "boolean" then
        return not value
    elseif type(value) == "number" then
        return value + 1
    elseif type(value) == "string" then
        return value .. "x"
    elseif IsColor(value) then
        return { 1 - value[1], 1 - value[2], 1 - value[3], value[4] or 1 }
    end
end

local leaves = {}
local function Walk(node, prefix)
    for key, value in pairs(node) do
        local path = prefix and (prefix .. "." .. key) or key
        if type(key) == "string" then
            if type(value) == "table" and not IsColor(value) then
                Walk(value, path)
            elseif Changed(value) ~= nil then
                leaves[#leaves + 1] = path
            end
        end
    end
end
Walk(ns.defaults.look, "look")
table.sort(leaves)

PlateauDB = nil
DB:Init()
local wanted, refused = {}, {}
for _, path in ipairs(leaves) do
    local current = DB:Get(path)
    local value = Changed(current)
    if DB:Set(path, value) then
        wanted[path] = value
    else
        refused[#refused + 1] = path
    end
end

DB:Shutdown()
DB:Init()

local lost = {}
local function Same(a, b)
    if IsColor(a) and IsColor(b) then
        for i = 1, 4 do
            if math.abs((a[i] or 1) - (b[i] or 1)) > 1e-9 then return false end
        end
        return true
    end
    return a == b
end
local count = 0
for path, value in pairs(wanted) do
    count = count + 1
    if not Same(DB:Get(path), value) then
        lost[#lost + 1] = path
    end
end
table.sort(lost)
check(count > 300, ("every setting was changed (%d settings)"):format(count))
check(#lost == 0, "every changed setting survives logout and the next load" .. (#lost > 0 and (": lost " .. table.concat(lost, ", ")) or ""))
check(#refused == 0, "no setting refuses a value of its own type" .. (#refused > 0 and (": " .. table.concat(refused, ", ")) or ""))
