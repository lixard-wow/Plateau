local _, ns = ...

local strings = {}
local pseudo = false

local L = setmetatable({}, {
    __index = function(_, key)
        if type(key) ~= "string" then return key end
        local value = strings[key] or key
        if pseudo and key ~= "" then
            return "[[" .. value .. "]]"
        end
        return value
    end,
    __newindex = function(_, key, value)
        if type(key) == "string" and type(value) == "string" and value ~= "" then
            strings[key] = value
        end
    end,
})

ns.L = L

function ns.T(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    return L[text]
end

function ns.SetPseudoLocale(on)
    pseudo = on == true
end

function ns.IsPseudoLocale()
    return pseudo
end

function ns.TranslatedCount()
    local count = 0
    for _ in pairs(strings) do
        count = count + 1
    end
    return count
end
