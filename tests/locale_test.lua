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

for _, code in ipairs({ "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }) do
    local path = "Plateau/Locales/" .. code .. ".lua"
    local chunk = loadfile(path)
    local second = chunk and io.open(path):read("*a"):match("\n([^\r\n]*)") or ""
    check(chunk ~= nil and second:find('ns.LocaleFile%("' .. code .. '"%)') ~= nil, code .. " file loads through LocaleFile with its own code")
end

local frames = {}
function CreateFrame()
    local frame = { scripts = {} }
    function frame:RegisterEvent() end
    function frame:UnregisterEvent() end
    function frame:SetScript(name, fn) self.scripts[name] = fn end
    frames[#frames + 1] = frame
    return frame
end

local function Fresh(game, debugState, withDebug)
    local fresh = {}
    locale = game
    PlateauDB = { debug = debugState }
    assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", fresh)
    if withDebug ~= false then
        assert(loadfile("Plateau/Core/Debug.lua"))("Plateau", fresh)
    end
    assert(loadstring('local _, ns = ... local L = ns.LocaleFile("deDE") L["Opacity"] = "Deckkraft" L["Blank"] = ""'))("Plateau", fresh)
    assert(loadstring('local _, ns = ... local L = ns.LocaleFile("frFR") L["Opacity"] = "Opacité" L["Icon size"] = "Taille"'))("Plateau", fresh)
    if withDebug ~= false then
        local loader = frames[#frames]
        loader.scripts.OnEvent(loader, "ADDON_LOADED", "Plateau")
    end
    return fresh
end

local stripped = Fresh("deDE", nil, false)
check(stripped.L["Opacity"] == "Deckkraft" and stripped.L["Icon size"] == "Icon size", "without the debug file other language files are thrown away")
check(stripped.Debug == nil and stripped.RunDebug == nil and stripped.DEBUG_BUILD == nil, "without the debug file nothing debug exists")
check(#frames == 0, "without the debug file no frames are made")

local plain = Fresh("enUS")
check(plain.DEBUG_BUILD == true and type(plain.RunDebug) == "function", "the debug file marks a debug build and registers its commands")
check(plain.L["Opacity"] == "Opacity" and plain.ActiveLocale() == "enUS", "with no preview an English client stays English")

local previewed = Fresh("enUS", { previewLocale = "frFR" })
check(previewed.L["Opacity"] == "Opacité" and previewed.L["Icon size"] == "Taille", "a preview shows that language on another client")
check(previewed.ActiveLocale() == "frFR", "the active language follows the preview")
check(previewed.LocaleFile("deDE")["x"] == nil, "staging stops once loading finishes")

local german = Fresh("deDE", { previewLocale = "frFR" })
check(german.L["Opacity"] == "Opacité" and german.L["Blank"] == "Blank", "a preview replaces the game language's strings")
local back = Fresh("deDE", { previewLocale = "enUS" })
check(back.L["Opacity"] == "Opacity", "previewing English on a translated client shows English")

local marked = Fresh("deDE", { pseudoLocale = true })
check(marked.L["Opacity"] == "[[Deckkraft]]" and marked.L["Icon size"] == "[[Icon size]]", "brackets mark every looked-up string")
check(marked.T("") == "", "brackets leave empty text alone")

PlateauDB = { global = { previewLocale = "frFR", pseudoLocale = true, setupDone = true } }
local moved = {}
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", moved)
assert(loadfile("Plateau/Core/Debug.lua"))("Plateau", moved)
frames[#frames].scripts.OnEvent(frames[#frames], "ADDON_LOADED", "Plateau")
check(PlateauDB.debug.previewLocale == "frFR" and PlateauDB.debug.pseudoLocale == true and PlateauDB.global.previewLocale == nil
    and PlateauDB.global.setupDone == true, "old debug choices move out of the real settings into their own key")
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
