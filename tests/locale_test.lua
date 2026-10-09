local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
local L, T = ns.L, ns.T

check(L["Show crowd control"] == "Show crowd control", "an untranslated string comes back in English")
check(T(nil) == nil and T(42) == 42 and T("") == "", "T passes numbers, nil and empty text through untouched")

local locale = "deDE"
function GetLocale() return locale end
assert(loadstring('if GetLocale() ~= "deDE" then return end local _, ns = ... local L = ns.L L["Icon size"] = "Symbolgröße" L["Unused"] = ""'))("Plateau", ns)
check(L["Icon size"] == "Symbolgröße", "a language file overrides a string")
check(L["Unused"] == "Unused", "an empty translation falls back to English")
check(L["Opacity"] == "Opacity", "strings a language file leaves out stay English")

locale = "frFR"
assert(loadstring('if GetLocale() ~= "deDE" then return end local _, ns = ... local L = ns.L L["Opacity"] = "Deckkraft"'))("Plateau", ns)
check(L["Opacity"] == "Opacity", "a language file for another language changes nothing")

check(L["A profile called %s already exists"]:format("Tank") == "A profile called Tank already exists", "placeholders survive the lookup")
assert(loadstring('local _, ns = ... ns.L["%s of %s"] = "%2$s von %1$s"'))("Plateau", ns)
check(L["%s of %s"] == "%2$s von %1$s", "translations can reorder placeholders")

ns.SetPseudoLocale(true)
check(L["Opacity"] == "[[Opacity]]" and L["Icon size"] == "[[Symbolgröße]]", "test mode marks every looked-up string")
check(T("") == "", "test mode leaves empty text alone")
ns.SetPseudoLocale(false)
check(L["Opacity"] == "Opacity", "test mode switches off again")

for _, code in ipairs({ "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
    local path = "Plateau/Locales/" .. code .. ".lua"
    local chunk = loadfile(path)
    local first = chunk and io.open(path):read("*l") or ""
    check(chunk ~= nil and first:find('GetLocale%(%) ~= "' .. code .. '"') ~= nil, code .. " file loads and only runs for its own language")
end

local toc = io.open("Plateau/Plateau.toc"):read("*a")
check(toc:find("Core\\Locale.lua") and toc:find("Core\\Locale.lua", 1, true) < toc:find("Core\\Init.lua", 1, true), "the lookup table loads before the rest of the addon")

local template = loadfile("localization/template.lua")
check(template ~= nil, "the translator template is valid Lua")

local LUA = os.getenv("LUA") or "lua5.1"
local pipe = io.popen('"' .. LUA .. '" tests/make_locale_template.lua --check')
local report = pipe:read("*a") or ""
pipe:close()
check(report:find("template up to date") ~= nil, "the translator template matches the code (" .. report:gsub("%s+$", "") .. ")")
