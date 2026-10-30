local _, ns = ...

local strings = {}
local active

local L = setmetatable({}, {
    __index = function(_, key)
        if type(key) ~= "string" then return key end
        return strings[key] or key
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

function ns.TranslatedCount()
    local count = 0
    for _ in pairs(strings) do
        count = count + 1
    end
    return count
end

local DISCARD = setmetatable({}, { __newindex = function() end })

function ns.LocaleFile(code)
    if code == GetLocale() then
        return L
    end
    return DISCARD
end

function ns.UseLocale(code, entries)
    for key in pairs(strings) do
        strings[key] = nil
    end
    for key, value in pairs(entries) do
        if type(key) == "string" and type(value) == "string" and value ~= "" then
            strings[key] = value
        end
    end
    active = code
end

function ns.ActiveLocale()
    return active or GetLocale()
end
