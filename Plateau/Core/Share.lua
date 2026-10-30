local _, ns = ...

local L = ns.L

local PREFIX = "!SL1!"
local MAX_TEXT = 60000
local MAX_SERIALIZED = 300000
local MAX_NODES = 20000
local MAX_STRING = 200
local MAX_NUMBER = 1e6

local Share = {}
ns.Share = Share

local function Deflate()
    return LibStub and LibStub("LibDeflate", true) or LibDeflate
end

local byte, char, floor = string.byte, string.char, math.floor

local POW = {}
for i = 0, 32 do
    POW[i] = 2 ^ i
end

local LENGTH_BASE = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258 }
local LENGTH_EXTRA = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0 }
local DISTANCE_BASE = { 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577 }
local DISTANCE_EXTRA = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 }
local CODE_ORDER = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 }

local TooLarge = {}

local function Bits(state, need)
    local value, count = state.buffer, state.count
    while count < need do
        local next = byte(state.data, state.position)
        if not next then
            error("truncated", 0)
        end
        state.position = state.position + 1
        value = value + next * POW[count]
        count = count + 8
    end
    state.buffer = floor(value / POW[need])
    state.count = count - need
    return value % POW[need]
end

local function Huffman(lengths, total)
    local counts, symbols, offsets = {}, {}, {}
    for length = 0, 15 do
        counts[length] = 0
    end
    for symbol = 0, total - 1 do
        local length = lengths[symbol] or 0
        counts[length] = counts[length] + 1
    end
    local left = 1
    for length = 1, 15 do
        left = left * 2 - counts[length]
        if left < 0 then
            error("bad code", 0)
        end
    end
    offsets[1] = 0
    for length = 1, 14 do
        offsets[length + 1] = offsets[length] + counts[length]
    end
    for symbol = 0, total - 1 do
        local length = lengths[symbol] or 0
        if length ~= 0 then
            symbols[offsets[length]] = symbol
            offsets[length] = offsets[length] + 1
        end
    end
    return { counts = counts, symbols = symbols }
end

local function DecodeSymbol(state, code)
    local value, first, index = 0, 0, 0
    for length = 1, 15 do
        value = value + Bits(state, 1)
        local count = code.counts[length]
        if value - count < first then
            return code.symbols[index + value - first]
        end
        index = index + count
        first = (first + count) * 2
        value = value * 2
    end
    error("bad symbol", 0)
end

local fixedLiterals, fixedDistances

local function FixedCodes()
    if not fixedLiterals then
        local lengths = {}
        for symbol = 0, 143 do lengths[symbol] = 8 end
        for symbol = 144, 255 do lengths[symbol] = 9 end
        for symbol = 256, 279 do lengths[symbol] = 7 end
        for symbol = 280, 287 do lengths[symbol] = 8 end
        fixedLiterals = Huffman(lengths, 288)
        local distances = {}
        for symbol = 0, 29 do distances[symbol] = 5 end
        fixedDistances = Huffman(distances, 30)
    end
    return fixedLiterals, fixedDistances
end

local function DynamicCodes(state)
    local literalCount = Bits(state, 5) + 257
    local distanceCount = Bits(state, 5) + 1
    local codeCount = Bits(state, 4) + 4
    if literalCount > 286 or distanceCount > 30 then
        error("bad counts", 0)
    end
    local codeLengths = {}
    for i = 1, codeCount do
        codeLengths[CODE_ORDER[i]] = Bits(state, 3)
    end
    local lengthCode = Huffman(codeLengths, 19)
    local lengths, index, total = {}, 0, literalCount + distanceCount
    while index < total do
        local symbol = DecodeSymbol(state, lengthCode)
        if symbol < 16 then
            lengths[index] = symbol
            index = index + 1
        else
            local value, repeats = 0, 0
            if symbol == 16 then
                if index == 0 then
                    error("bad repeat", 0)
                end
                value, repeats = lengths[index - 1], 3 + Bits(state, 2)
            elseif symbol == 17 then
                repeats = 3 + Bits(state, 3)
            else
                repeats = 11 + Bits(state, 7)
            end
            if index + repeats > total then
                error("bad repeat", 0)
            end
            for _ = 1, repeats do
                lengths[index] = value
                index = index + 1
            end
        end
    end
    local literalLengths, distanceLengths = {}, {}
    for symbol = 0, literalCount - 1 do
        literalLengths[symbol] = lengths[symbol]
    end
    for symbol = 0, distanceCount - 1 do
        distanceLengths[symbol] = lengths[literalCount + symbol]
    end
    return Huffman(literalLengths, literalCount), Huffman(distanceLengths, distanceCount)
end

local function Inflate(data, limit)
    local state = { data = data, position = 1, buffer = 0, count = 0 }
    local out, size = {}, 0
    local function Run()
        repeat
            local last = Bits(state, 1)
            local kind = Bits(state, 2)
            if kind == 0 then
                state.buffer, state.count = 0, 0
                local position = state.position
                local low1, high1, low2, high2 = byte(data, position, position + 3)
                if not high2 then
                    error("truncated", 0)
                end
                local length = low1 + high1 * 256
                if length + low2 + high2 * 256 ~= 65535 then
                    error("bad stored block", 0)
                end
                if size + length > limit then
                    error(TooLarge, 0)
                end
                position = position + 4
                if position + length - 1 > #data then
                    error("truncated", 0)
                end
                for i = 0, length - 1 do
                    size = size + 1
                    out[size] = byte(data, position + i)
                end
                state.position = position + length
            elseif kind == 1 or kind == 2 then
                local literals, distances
                if kind == 1 then
                    literals, distances = FixedCodes()
                else
                    literals, distances = DynamicCodes(state)
                end
                while true do
                    local symbol = DecodeSymbol(state, literals)
                    if symbol < 256 then
                        if size >= limit then
                            error(TooLarge, 0)
                        end
                        size = size + 1
                        out[size] = symbol
                    elseif symbol == 256 then
                        break
                    else
                        local slot = symbol - 256
                        if slot > 29 then
                            error("bad length", 0)
                        end
                        local length = LENGTH_BASE[slot] + Bits(state, LENGTH_EXTRA[slot])
                        local code = DecodeSymbol(state, distances)
                        if code > 29 then
                            error("bad distance", 0)
                        end
                        local distance = DISTANCE_BASE[code + 1] + Bits(state, DISTANCE_EXTRA[code + 1])
                        if distance > size then
                            error("bad distance", 0)
                        end
                        if size + length > limit then
                            error(TooLarge, 0)
                        end
                        for _ = 1, length do
                            size = size + 1
                            out[size] = out[size - distance]
                        end
                    end
                end
            else
                error("bad block", 0)
            end
        until last == 1
    end
    local ok, problem = pcall(Run)
    if not ok then
        return nil, problem == TooLarge and "too large" or "damaged"
    end
    local parts = {}
    for first = 1, size, 4096 do
        parts[#parts + 1] = char(unpack(out, first, math.min(first + 4095, size)))
    end
    return table.concat(parts)
end

Share.Inflate = Inflate

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
    error(L["unterminated string"])
end

local ReadValue
local nodes

local function ReadTable(text, position, depth)
    if depth > 20 then error(L["too deeply nested"]) end
    local result = {}
    while true do
        local c = text:sub(position, position)
        if c == "}" then
            return result, position + 1
        elseif c == "" then
            error(L["unterminated table"])
        end
        local key, value
        key, position = ReadValue(text, position, depth)
        value, position = ReadValue(text, position, depth)
        if type(key) == "table" then error(L["table keys are not allowed"]) end
        result[key] = value
    end
end

function ReadValue(text, position, depth)
    nodes = nodes + 1
    if nodes > MAX_NODES then error(L["too much data"]) end
    local c = text:sub(position, position)
    if c == "{" then
        return ReadTable(text, position + 1, depth + 1)
    elseif c == "s" then
        return ReadString(text, position + 1)
    elseif c == "n" then
        local finish = text:find("^", position, true)
        if not finish then error(L["bad number"]) end
        local number = tonumber(text:sub(position + 1, finish - 1))
        if not number then error(L["bad number"]) end
        return number, finish + 1
    elseif c == "T" then
        return true, position + 1
    elseif c == "F" then
        return false, position + 1
    end
    error(L["unexpected data"])
end

function Share.Deserialize(text)
    nodes = 0
    local ok, value, position = pcall(ReadValue, text, 1, 0)
    if not ok then
        return nil, value
    end
    if position <= #text then
        return nil, L["extra data at the end"]
    end
    return value
end

local JUSTIFY_KEYS = { justify = true, textJustify = true }
local JUSTIFY = { LEFT = true, CENTER = true, RIGHT = true }
local TYPE_SCALES = { boss = true, lieutenant = true, higher = true, caster = true, elite = true, trivial = true }
local MIN_SCALE, MAX_SCALE = 0.1, 5

local function IsScale(key, parent)
    return type(key) == "string" and (key:find("[Ss]cale$") ~= nil or (parent == "scaling" and TYPE_SCALES[key] == true))
end

local function Sanitize(data, defaults, parent, prefix)
    prefix = prefix or "look"
    local clean = {}
    for key, value in pairs(data) do
        local default = defaults[key]
        if ns.DB.IsGroup(default) then
            if type(value) == "table" then
                clean[key] = Sanitize(value, default, key, prefix .. "." .. tostring(key))
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
                    if IsScale(key, parent) then
                        value = math.max(MIN_SCALE, math.min(MAX_SCALE, value))
                    end
                    local range = Share.ranges and Share.ranges[prefix .. "." .. tostring(key)]
                    if range then
                        value = math.max(range[1], math.min(range[2], value))
                    end
                    clean[key] = value
                end
            elseif type(value) == "string" then
                if #value <= MAX_STRING and (not JUSTIFY_KEYS[key] or JUSTIFY[value]) then
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
    local payload = { version = schemaVersion, look = profile.look, specSpells = rawget(profile, "specSpells"), bossPhases = profile.bossPhases, game = profile.game }
    local deflate = Deflate()
    local compressed = deflate:CompressDeflate(Share.Serialize(payload), { level = 9 })
    return PREFIX .. deflate:EncodeForPrint(compressed)
end

function Share.Decode(text)
    text = (text or ""):gsub("%s", "")
    if text:sub(1, #PREFIX) ~= PREFIX then
        return nil, L["Not a Plateau profile string."]
    end
    if #text > MAX_TEXT then
        return nil, L["This string is too long to be a Plateau profile."]
    end
    local deflate = Deflate()
    local compressed = deflate:DecodeForPrint(text:sub(#PREFIX + 1))
    if not compressed then
        return nil, L["This string is damaged or incomplete."]
    end
    local serialized, problem = Inflate(compressed, MAX_SERIALIZED)
    if not serialized then
        if problem == "too large" then
            return nil, L["This string is too long to be a Plateau profile."]
        end
        return nil, L["This string is damaged or incomplete."]
    end
    local payload, reason = Share.Deserialize(serialized)
    if type(payload) ~= "table" then
        return nil, L["Couldn't read the profile: %s"]:format(tostring(reason))
    end
    return payload
end
