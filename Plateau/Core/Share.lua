local _, ns = ...

local PREFIX = "!SL1!"
local MAX_TEXT = 60000
local MAX_SERIALIZED = 1000000
local MAX_NODES = 20000
local MAX_STRING = 200
local MAX_NUMBER = 1e6

local Share = {}
ns.Share = Share

local function Deflate()
    return LibStub and LibStub("LibDeflate", true) or LibDeflate
end

local function Escape(text)
    return (text:gsub("[\\%^|~]", function(c) return "\\" .. c end))
end

local function WriteValue(out, value)
    local kind = type(value)
    if kind == "table" then
        out[#out + 1] = "{"
        for key, inner in pairs(value) do
            WriteValue(out, key)
            WriteValue(out, inner)
        end
        out[#out + 1] = "}"
    elseif kind == "string" then
        out[#out + 1] = "s" .. Escape(value) .. "^"
    elseif kind == "number" then
        out[#out + 1] = "n" .. string.format("%.17g", value) .. "^"
    elseif kind == "boolean" then
        out[#out + 1] = value and "T" or "F"
    end
end

function Share.Serialize(value)
    local out = {}
    WriteValue(out, value)
    return table.concat(out)
end

local function ReadString(text, position)
    local parts = {}
    while position <= #text do
        local c = text:sub(position, position)
        if c == "\\" then
            parts[#parts + 1] = text:sub(position + 1, position + 1)
            position = position + 2
        elseif c == "^" then
            return table.concat(parts), position + 1
        else
            parts[#parts + 1] = c
            position = position + 1
        end
    end
    error("unterminated string")
end

local ReadValue
local nodes

local function ReadTable(text, position, depth)
    if depth > 20 then error("too deeply nested") end
    local result = {}
    while true do
        local c = text:sub(position, position)
        if c == "}" then
            return result, position + 1
        elseif c == "" then
            error("unterminated table")
        end
        local key, value
        key, position = ReadValue(text, position, depth)
        value, position = ReadValue(text, position, depth)
        if type(key) == "table" then error("table keys are not allowed") end
        result[key] = value
    end
end

function ReadValue(text, position, depth)
    nodes = nodes + 1
    if nodes > MAX_NODES then error("too much data") end
    local c = text:sub(position, position)
    if c == "{" then
        return ReadTable(text, position + 1, depth + 1)
    elseif c == "s" then
        return ReadString(text, position + 1)
    elseif c == "n" then
        local finish = text:find("^", position, true)
        if not finish then error("bad number") end
        local number = tonumber(text:sub(position + 1, finish - 1))
        if not number then error("bad number") end
        return number, finish + 1
    elseif c == "T" then
        return true, position + 1
    elseif c == "F" then
        return false, position + 1
    end
    error("unexpected data")
end

function Share.Deserialize(text)
    nodes = 0
    local ok, value, position = pcall(ReadValue, text, 1, 0)
    if not ok then
        return nil, value
    end
    if position <= #text then
        return nil, "extra data at the end"
    end
    return value
end

local function Sanitize(data, defaults)
    local clean = {}
    for key, value in pairs(data) do
        local default = defaults[key]
        if type(default) == "table" and default[1] == nil then
            if type(value) == "table" then
                clean[key] = Sanitize(value, default)
            end
        elseif type(default) == "table" then
            if type(value) == "table" then
                local channels = {}
                for i = 1, 4 do
                    local channel = value[i]
                    local valid = type(channel) == "number" and channel == channel and channel >= -MAX_NUMBER and channel <= MAX_NUMBER
                    channels[i] = valid and channel or default[i]
                end
                clean[key] = channels
            end
        elseif default ~= nil and type(value) == type(default) then
            if type(value) == "number" then
                if value == value and value >= -MAX_NUMBER and value <= MAX_NUMBER then
                    clean[key] = value
                end
            elseif type(value) == "string" then
                if #value <= MAX_STRING then
                    clean[key] = value
                end
            else
                clean[key] = value
            end
        end
    end
    return clean
end
Share.Sanitize = Sanitize

function Share.Export(profile, schemaVersion)
    local payload = { version = schemaVersion, look = profile.look, states = profile.states, specSpells = rawget(profile, "specSpells"), bossPhases = profile.bossPhases }
    local deflate = Deflate()
    local compressed = deflate:CompressDeflate(Share.Serialize(payload), { level = 9 })
    return PREFIX .. deflate:EncodeForPrint(compressed)
end

function Share.Decode(text)
    text = (text or ""):gsub("%s", "")
    if text:sub(1, #PREFIX) ~= PREFIX then
        return nil, "that isn't a Plateau profile string"
    end
    if #text > MAX_TEXT then
        return nil, "that string is too long to be a Plateau profile"
    end
    local deflate = Deflate()
    local compressed = deflate:DecodeForPrint(text:sub(#PREFIX + 1))
    local serialized = compressed and deflate:DecompressDeflate(compressed)
    if not serialized or #serialized > MAX_SERIALIZED then
        return nil, "the string is damaged or incomplete"
    end
    local payload, reason = Share.Deserialize(serialized)
    if type(payload) ~= "table" then
        return nil, "couldn't read the profile: " .. tostring(reason)
    end
    return payload
end
