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

ns.LANGUAGES = { "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }

local staged = {}
local counts = {}
local preview

function ns.LocaleFile(code)
    if code == GetLocale() then
        return L
    end
    local entries = {}
    if staged then
        staged[code] = entries
    end
    return entries
end

local function Filled(entries)
    local count = 0
    for key, value in pairs(entries) do
        if type(key) == "string" and type(value) == "string" and value ~= "" then
            count = count + 1
        end
    end
    return count
end

function ns.ApplyLocale(code)
    if not staged then return end
    for language, entries in pairs(staged) do
        counts[language] = Filled(entries)
    end
    counts[GetLocale()] = ns.TranslatedCount()
    if code and code ~= GetLocale() then
        for key in pairs(strings) do
            strings[key] = nil
        end
        for key, value in pairs(staged[code] or {}) do
            if type(key) == "string" and type(value) == "string" and value ~= "" then
                strings[key] = value
            end
        end
        preview = code
    end
    staged = nil
end

function ns.LocaleCount(code)
    return counts[code] or 0
end

function ns.PreviewLocale()
    return preview
end

function ns.ActiveLocale()
    return preview or GetLocale()
end
