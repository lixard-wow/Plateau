Enum = Enum or {}
Enum.UITextureSliceMode = Enum.UITextureSliceMode or { Stretched = 0 }
LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local budget = 0
debug.sethook(function()
    budget = budget + 1
    if budget > 2000 then error(debug.traceback("endless loop"), 0) end
end, "", 100000)

local NUMBERS = { GetStringWidth = true, GetStringHeight = true, GetWidth = true, GetHeight = true, GetEffectiveScale = true,
    GetScale = true, GetLeft = true, GetTop = true, GetRight = true, GetBottom = true, GetFrameLevel = true, GetVerticalScroll = true,
    GetNumLetters = true, GetValue = true, GetCursorPosition = true }
local Stub = {}
Stub.__index = function(self, key)
    if key == "scripts" then return nil end
    return function(obj, ...)
        if key == "SetScript" then
            local name, fn = ...
            obj.scripts = obj.scripts or {}
            obj.scripts[name] = fn
        elseif key == "GetScript" then
            return obj.scripts and obj.scripts[...] or nil
        elseif key == "GetText" then
            return rawget(obj, "text") or ""
        elseif key == "SetText" then
            obj.text = ...
        elseif NUMBERS[key] then
            return 100
        elseif key == "GetChildren" or key == "GetRegions" or key == "GetPoint" then
            return
        elseif key == "IsShown" or key == "IsVisible" or key == "IsMouseOver" or key == "HasFocus" then
            return false
        elseif key == "SetFont" then
            return true
        elseif key == "CreateFontString" or key == "CreateTexture" or key == "CreateAnimationGroup" or key == "CreateAnimation" then
            return setmetatable({}, Stub)
        end
        return obj
    end
end
local function newStub() return setmetatable({}, Stub) end
function CreateFrame(_, name)
    local frame = newStub()
    if name then _G[name] = frame end
    return frame
end
UIParent, GameTooltip, ColorPickerFrame = newStub(), newStub(), newStub()
UISpecialFrames = {}
C_Timer = { After = function() end, NewTicker = function() return newStub() end, NewTimer = function() return newStub() end }
function issecretvalue() return false end
function InCombatLockdown() return false end
function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function UnitName() return "Stalador" end
function UnitClass() return "Mage", "MAGE", 8 end
function UnitClassBase() return "MAGE" end
function UnitLevel() return 90 end
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end
function GetRealmName() return "Iridikron" end
function GetTime() return 0 end
function GetCursorPosition() return 0, 0 end
function GetLocale() return "enUS" end
function hooksecurefunc() end
function IsInInstance() return false, "none" end
function GetCVar() return "1" end
function GetCVarBool() return true end
C_CVar = { GetCVar = function() return "1" end, GetCVarBool = function() return true end, GetCVarBitfield = function() return false end, SetCVar = function() end }
C_AddOns = { IsAddOnLoaded = function() return false end, GetAddOnMetadata = function() return "" end, DoesAddOnExist = function() return false end, GetNumAddOns = function() return 0 end }
C_SpecializationInfo = {
    GetSpecialization = function() return 1 end,
    GetSpecializationInfo = function(index) return index, "Arcane" end,
    GetNumSpecializationsForClassID = function() return 3 end,
}
C_Texture = { GetAtlasInfo = function() return nil end }
C_Spell = { GetSpellInfo = function() return nil end, GetSpellTexture = function() return nil end, GetSpellName = function() return nil end }
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
RAID_CLASS_COLORS = { MAGE = { r = 0.25, g = 0.78, b = 0.92 } }
tinsert, tremove = table.insert, table.remove
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function strtrim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end
function debugprofilestop() return 0 end

local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
local function load(path) local f = assert(loadfile(path)); f("Plateau", ns) end
C_EventUtils = C_EventUtils or { IsEventValid = function() return true end }
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
load("Plateau/Core/Defaults.lua"); load("Plateau/Core/Database.lua"); load("Plateau/Core/Share.lua"); load("Plateau/Core/AutoProfile.lua")
load("Plateau/Core/Media.lua"); load("Plateau/Core/Layout.lua"); load("Plateau/Core/Presets.lua")
ns.Builtins = { list = { { name = "Alpha" } }, Label = function(n) return n end, ByName = function() return nil end, ForPreset = function() return nil end, Values = function() return {} end }
PlateauDB = nil
ns.DB:Init()

local Any
Any = setmetatable({}, { __index = function() return Any end, __call = function() return Any end })
Plateau = setmetatable({
    DB = ns.DB, Builtins = ns.Builtins, AutoProfile = ns.AutoProfile, CONTENT_TYPES = ns.CONTENT_TYPES, version = "0.1.3",
    presets = ns.presets, overlayPatterns = ns.overlayPatterns, barTextures = ns.barTextures, arrowStyles = ns.arrowStyles,
    iconPositions = ns.iconPositions, textPositions = ns.textPositions, LANGUAGES = ns.LANGUAGES, bossPhaseList = {},
    defaults = ns.defaults, L = ns.L, Builtins = ns.Builtins,
    brand = { { 1, 1, 1, 1 }, { 1, 1, 1, 1 }, { 1, 1, 1, 1 } },
    Brand = { OnChange = function() end, Text = function(_, t) return t end },
    T = ns.T, BossPhaseSeen = function() return {} end, BossPhaseLines = function() return "" end, BossPhaseTarget = function() return nil end,
}, { __index = function(_, key) if key:match("^%u") then return Any end end })

local nsOpt = {}
local ok, problem = true, nil
for line in io.lines("Plateau_Options/Plateau_Options.toc") do
    local file = line:match("^([%w\\]+%.lua)%s*$")
    if file and ok then
        local chunk, err = loadfile("Plateau_Options/" .. file:gsub("\\", "/"))
        if not chunk then
            ok, problem = false, err
        else
            local done, why = pcall(chunk, "Plateau_Options", nsOpt)
            if not done then
                ok, problem = false, file .. ": " .. tostring(why)
            end
        end
    end
end
check(ok, "every options file loads" .. (problem and (": " .. problem) or ""))

if ok then
    local built, failed = 0, {}
    for _, section in ipairs(nsOpt.sections) do
        budget = 0
        local done, why = pcall(nsOpt.SelectSection, section.key)
        if done then
            built = built + 1
        else
            failed[#failed + 1] = section.key .. ": " .. tostring(why)
        end
    end
    check(#failed == 0, "every page builds (" .. built .. " built)" .. (#failed > 0 and ("; " .. table.concat(failed, " | ")) or ""))
    local refreshed = pcall(nsOpt.RefreshAll)
    check(refreshed, "refreshing the open page works")
    local pages, placed, bad = 0, {}, {}
    for _, group in ipairs(nsOpt.railGroups) do
        for _, page in ipairs(group.pages) do
            pages = pages + 1
            budget = 0
            local done, why = pcall(nsOpt.SelectSection, page.key)
            if not done then
                bad[#bad + 1] = page.key .. ": " .. tostring(why)
            end
            for _, part in ipairs(page.parts) do
                if placed[part.key] then
                    bad[#bad + 1] = part.key .. " is on two pages"
                end
                placed[part.key] = true
            end
        end
    end
    for _, section in ipairs(nsOpt.sections) do
        if not placed[section.key] then
            bad[#bad + 1] = section.key .. " is on no page"
        end
    end
    check(#bad == 0, pages .. " sidebar pages open and hold every part once" .. (#bad > 0 and ("; " .. table.concat(bad, " | ")) or ""))
    local opened = pcall(nsOpt.OpenSetting, "level", 2) and pcall(nsOpt.OpenSetting, "focus", 2) and pcall(nsOpt.OpenSetting, "addon", 2)
    check(opened, "opening a setting inside a merged page or a tab works")
end
