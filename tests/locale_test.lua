local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
local L, T = ns.L, ns.T

check(L["Show crowd control"] == "Show crowd control", "an untranslated string comes back in English")
check(T(nil) == nil and T(42) == 42 and T("") == "", "T passes numbers, nil and empty text through untouched")

local locale = "deDE"
function GetLocale() return locale end
assert(loadstring('local _, ns = ... local L = ns.LocaleFile("deDE") L["Icon size"] = "Symbolgröße" L["Unused"] = ""'))("Plateau", ns)
check(L["Icon size"] == "Symbolgröße", "a language file overrides a string")
check(L["Unused"] == "Unused", "an empty translation falls back to English")
check(L["Opacity"] == "Opacity", "strings a language file leaves out stay English")

locale = "frFR"
assert(loadstring('local _, ns = ... local L = ns.LocaleFile("deDE") L["Opacity"] = "Deckkraft"'))("Plateau", ns)
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
    local second = chunk and io.open(path):read("*a"):match("\n([^\r\n]*)") or ""
    check(chunk ~= nil and second:find('ns.LocaleFile%("' .. code .. '"%)') ~= nil, code .. " file loads through LocaleFile with its own code")
end

local function Fresh(game)
    local fresh = {}
    locale = game
    assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", fresh)
    assert(loadstring('local _, ns = ... local L = ns.LocaleFile("deDE") L["Opacity"] = "Deckkraft" L["Blank"] = ""'))("Plateau", fresh)
    assert(loadstring('local _, ns = ... local L = ns.LocaleFile("frFR") L["Opacity"] = "Opacité" L["Icon size"] = "Taille"'))("Plateau", fresh)
    return fresh
end

local plain = Fresh("enUS")
plain.ApplyLocale(nil)
check(plain.L["Opacity"] == "Opacity" and plain.PreviewLocale() == nil, "with no preview an English client stays English")
check(plain.LocaleCount("deDE") == 1 and plain.LocaleCount("frFR") == 2, "counts only filled translations per language")
check(plain.ActiveLocale() == "enUS", "the active language is the game's with no preview")

local previewed = Fresh("enUS")
previewed.ApplyLocale("frFR")
check(previewed.L["Opacity"] == "Opacité" and previewed.L["Icon size"] == "Taille", "a preview shows that language on another client")
check(previewed.ActiveLocale() == "frFR", "the active language follows the preview")
previewed.ApplyLocale("deDE")
check(previewed.L["Opacity"] == "Opacité", "the language is fixed once loading finishes")

local german = Fresh("deDE")
german.ApplyLocale("frFR")
check(german.L["Opacity"] == "Opacité" and german.L["Blank"] == "Blank", "a preview replaces the game language's strings")
local back = Fresh("deDE")
back.ApplyLocale("enUS")
check(back.L["Opacity"] == "Opacity", "previewing English on a translated client shows English")
check(back.LocaleCount("deDE") == 1, "the game language's count is kept")
locale = "frFR"

local toc = io.open("Plateau/Plateau.toc"):read("*a")
check(toc:find("Core\\Locale.lua") and toc:find("Core\\Locale.lua", 1, true) < toc:find("Core\\Init.lua", 1, true), "the lookup table loads before the rest of the addon")

local template = loadfile("localization/template.lua")
check(template ~= nil, "the translator template is valid Lua")

local LUA = os.getenv("LUA") or "lua5.1"
local pipe = io.popen('"' .. LUA .. '" tests/make_locale_template.lua --check')
local report = pipe:read("*a") or ""
pipe:close()
check(report:find("template up to date") ~= nil, "the translator template matches the code (" .. report:gsub("%s+$", "") .. ")")
