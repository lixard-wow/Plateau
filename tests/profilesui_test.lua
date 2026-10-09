Enum = Enum or {}
Enum.UITextureSliceMode = Enum.UITextureSliceMode or { Stretched = 0 }
LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Stub = {}
Stub.__index = function(self, key)
    if key == "scripts" then return nil end
    return function(obj, ...)
        if key == "SetScript" then
            local name, fn = ...
            obj.scripts = obj.scripts or {}
            obj.scripts[name] = fn
        elseif key == "HookScript" then
            return
        elseif key == "GetText" then
            return rawget(obj, "text") or ""
        elseif key == "SetText" then
            obj.text = ...
        elseif key == "SetEnabled" then
            obj.enabled = ...
        elseif key == "GetStringWidth" or key == "GetStringHeight" or key == "GetWidth" or key == "GetHeight" then
            return 100
        elseif key == "CreateFontString" or key == "CreateTexture" then
            return setmetatable({}, Stub)
        end
        return obj
    end
end
local function newStub() return setmetatable({}, Stub) end
local created = {}
function CreateFrame() local f = newStub(); created[#created + 1] = f; return f end
UIParent = newStub()
GameTooltip = newStub()
C_Timer = { After = function() end, NewTicker = function() return newStub() end }
function issecretvalue() return false end
local combat = false
function InCombatLockdown() return combat end
function IsShiftKeyDown() return false end
function UnitName() return "Stalador" end
function UnitClass() return "Mage", "MAGE", 8 end
function CreateColor(r, g, b, a) return { r = r, g = g, b = b, a = a } end
function GetRealmName() return "Iridikron" end
function GetTime() return 0 end
local instance, spec = "none", 1
function IsInInstance() return instance ~= "none", instance end
C_SpecializationInfo = {
    GetSpecialization = function() return spec end,
    GetSpecializationInfo = function(index) return index, ({ "Arcane", "Fire", "Frost" })[index] end,
    GetNumSpecializationsForClassID = function() return 3 end,
}

local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
local function load(path) local f = assert(loadfile(path)); f("Plateau", ns) end
load("Plateau/Core/Defaults.lua"); load("Plateau/Core/Database.lua"); load("Plateau/Core/Share.lua"); load("Plateau/Core/AutoProfile.lua")
ns.Builtins = { list = { { name = "Alpha" } }, Label = function(n) return n end, ByName = function(n) return n == "Alpha" and {} or nil end, Values = function() return {} end }
local DB, Auto = ns.DB, ns.AutoProfile
PlateauDB = nil
DB:Init()
DB:Set("look.castbar.height", 21)
DB:CreateProfile("Other", "Default")
DB:SwitchProfile("Default")
DB:Set("look.castbar.height", 30)

Plateau = { DB = DB, Builtins = ns.Builtins, AutoProfile = Auto, CONTENT_TYPES = ns.CONTENT_TYPES, brand = { {1,1,1,1}, {1,1,1,1}, {1,1,1,1} }, Brand = { OnChange = function() end, Text = function(_, t) return t end } }
Plateau.T = Plateau.T or (function() local l = {} assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", l) return l.T end)()
local nsOpt = { Widgets = {}, Style = nil, layout = { content = 938, column = 457 } }
local function loadOpt(path) local f = assert(loadfile(path)); f("Plateau_Options", nsOpt) end
loadOpt("Plateau_Options/Widgets/Style.lua")
loadOpt("Plateau_Options/Widgets/Toggle.lua")
loadOpt("Plateau_Options/Widgets/Dropdown.lua")
loadOpt("Plateau_Options/Widgets/Button.lua")
local specs = {}
local realDropdown = nsOpt.Widgets.Dropdown
nsOpt.Widgets.Dropdown = function(parent, spec) specs[spec.label] = spec return realDropdown(parent, spec) end
loadOpt("Plateau_Options/Widgets/Profiles.lua")
for _, name in ipairs({ "ProfileStatus", "ProfileActions", "AutoProfiles", "ShareProfile", "NamePrompt", "ConfirmPrompt" }) do
    check(type(nsOpt.Widgets[name]) == "function", name .. " widget loads")
end

local asked, namePrompt
local confirmFake = { Ask = function(_, heading, body, label, callback) asked = { heading = heading, body = body, label = label, callback = callback } end }
local nameFake = { Ask = function(_, heading, body, callback, initial, label) namePrompt = { heading = heading, body = body, callback = callback, initial = initial, label = label } end }
nsOpt.Widgets.ConfirmPrompt = function() return confirmFake end
nsOpt.Widgets.NamePrompt = function() return nameFake end

local host = newStub()
local start = #created
local frame = nsOpt.Widgets.ProfileActions(host)
local buttons = {}
for i = start + 1, #created do
    local f = created[i]
    if rawget(f, "scripts") and f.scripts.OnClick then buttons[#buttons + 1] = f end
end
local function find(label)
    for _, b in ipairs(buttons) do
        local l = rawget(b, "label")
        if l and rawget(l, "text") == label then return b end
    end
end
local function click(b) b.scripts.OnClick(b) end
local create, duplicate = find("New profile"), find("Duplicate active")
local rename, replace = find("Rename"), find("Copy settings")
local delete, restore = find("Delete"), find("Restore")
check(create and duplicate and rename and replace and delete and restore, "all the action buttons carry the new labels")

frame:Refresh()
check(replace.enabled == false and delete.enabled == false and restore.enabled == false, "actions are disabled until something is picked")
check(rename.enabled == true, "rename is available for the active profile")

check(DB.views.enemy.castbar.height == 30 and DB.profileName == "Default", "starting on Default with height 30")
specs["Copy settings from"].set("Other")
frame:Refresh()
check(replace.enabled == true, "picking a source enables Copy settings")
click(replace)
check(asked and asked.body:find("Default") and asked.body:find("Other") and asked.body:find("overwritten"), "the confirmation names the source and the destination and warns about overwriting")
check(DB.views.enemy.castbar.height == 30, "nothing changes until the confirmation is accepted")
asked.callback()
check(DB.views.enemy.castbar.height == 21 and DB.saved.profiles.Other ~= nil, "accepting copies the source into the active profile only")

specs["Delete profile"].set("Other")
frame:Refresh()
Auto:Set("content", "raid", "Other")
click(delete)
check(asked.body:find("Other") and asked.body:find("Raids"), "the delete confirmation names the assignment that uses the profile")
check(DB.saved.profiles.Other ~= nil, "nothing is deleted before the confirmation")
asked.callback()
check(DB.saved.profiles.Other == nil and Auto:Get("content", "raid") == "", "accepting deletes the profile and clears its assignment")

specs["Restore built-in"].set("Alpha")
frame:Refresh()
click(restore)
check(asked.body:find("overwritten"), "restoring an existing built-in warns that your changes are overwritten")
DB:DeleteProfile("Alpha")
click(restore)
check(asked.body:find("recreates"), "restoring a missing built-in explains that it recreates it")
local ok, err = pcall(asked.callback)
check(ok, "restore runs without an error" .. (ok and "" or (": " .. tostring(err))))

click(create)
check(namePrompt and namePrompt.heading == "Create new profile" and namePrompt.label == "Create", "Create opens the name prompt")
local created1, reason1 = namePrompt.callback("Fresh")
check(created1 and DB.profileName == "Fresh" and DB:Get("look.castbar.height") == ns.defaults.look.castbar.height, "creating starts from addon defaults and activates the new profile")
DB:Set("look.castbar.height", 25)
click(duplicate)
check(namePrompt.body:find("Fresh"), "Duplicate names the profile it copies")
namePrompt.callback("Fresh copy")
check(DB.profileName == "Fresh copy" and DB:Get("look.castbar.height") == 25, "duplicating copies the active profile")
local dup, dupReason = namePrompt.callback("Fresh")
check(not dup and dupReason:find("already exists"), "a duplicate name is refused in the prompt")

specs["Rename profile"].set("Fresh copy")
click(rename)
check(namePrompt.initial == "Fresh copy" and namePrompt.label == "Rename", "Rename opens with the current name")
local renamed = namePrompt.callback("Renamed")
check(renamed and DB.profileName == "Renamed" and DB:DefaultProfile() == "Renamed", "renaming keeps the active and default references")

local statusHost = newStub()
local status = nsOpt.Widgets.ProfileStatus(statusHost)
check(pcall(status.Refresh, status), "the status block refreshes")
specs["Default profile"].set("Default")
check(DB:DefaultProfile() == "Default" and DB.profileName == "Default", "the default profile control changes the default and, with no rule, the active profile")

local auto = nsOpt.Widgets.AutoProfiles(newStub())
check(specs["Open world"] and specs["Arcane"] and specs["Fire"] and specs["Frost"], "automatic switching lists content types and dynamic specialization names")
local options = specs["Open world"].options()
check(options[1].value == "" and options[1].label == "No override", "the first choice is No override")
check(pcall(auto.Refresh, auto), "the automatic switching block refreshes")

local share = nsOpt.Widgets.ShareProfile(newStub())
check(pcall(share.Refresh, share), "the share block refreshes")
