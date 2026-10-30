local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Read(path)
    local file = assert(io.open(path, "r"))
    local text = file:read("*a")
    file:close()
    return text
end

local function Block(text, name)
    local start = text:find("local " .. name .. " = {", 1, true)
    assert(start, name .. " not found")
    local depth, i = 0, text:find("{", start, true)
    local first = i
    while i <= #text do
        local c = text:sub(i, i)
        if c == "{" then
            depth = depth + 1
        elseif c == "}" then
            depth = depth - 1
            if depth == 0 then
                return text:sub(first, i)
            end
        end
        i = i + 1
    end
    error(name .. " not closed")
end

local ready = Read("Plateau/Features/InterruptReady.lua")
local known = {}
for _, name in ipairs({ "candidates", "extras" }) do
    for id in Block(ready, name):gmatch("(%d+)") do
        known[tonumber(id)] = true
    end
end

local kicks = Read("Plateau/Features/Kicks.lua")
local used = {}
for id in Block(kicks, "CLASS_KICK"):gmatch("= (%d+)") do used[tonumber(id)] = "CLASS_KICK" end
for id in Block(kicks, "SPEC_KICK"):gmatch("%] = (%d+)") do used[tonumber(id)] = "SPEC_KICK" end
for id in Block(kicks, "PET_KICK"):gmatch("%] = (%d+)") do used[tonumber(id)] = "PET_KICK" end
for id in Block(kicks, "KNOWN_CD"):gmatch("%[(%d+)%] =") do used[tonumber(id)] = "KNOWN_CD" end

local count, missing = 0, {}
for id, where in pairs(used) do
    count = count + 1
    if not known[id] then
        missing[#missing + 1] = where .. " " .. id
    end
end
table.sort(missing)
check(count >= 15, "Kicks lists its interrupt spells (" .. count .. " found)")
check(#missing == 0, "every interrupt Kicks tracks is also one InterruptReady knows" .. (#missing > 0 and (": " .. table.concat(missing, ", ")) or ""))
for id in Block(kicks, "CLASS_KICK"):gmatch("= (%d+)") do
    if not Block(kicks, "KNOWN_CD"):find("%[" .. id .. "%]") then
        missing[#missing + 1] = "no cooldown for " .. id
    end
end
check(#missing == 0, "every class kick has a known cooldown" .. (#missing > 0 and (": " .. table.concat(missing, ", ")) or ""))
