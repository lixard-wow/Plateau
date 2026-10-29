local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Presets.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
PlateauDB = nil
DB:Init()
for _, group in ipairs({ ns.presets.looks, ns.presets.styles, ns.presets.palettes }) do
    for _, preset in ipairs(group) do
        local ok, failed = DB:SetMany(preset.values)
        check(ok, preset.key .. " applies every value (" .. table.concat(failed or {}, ", ") .. ")")
    end
end
DB:Reset()
local looks = {}
for _, look in ipairs(ns.presets.looks) do
    looks[look.key] = look
end
DB:SetMany(looks.familiar.values)
check(DB.views.friendly.plate.width == 120 and DB.views.enemy.plate.width == 120, "preset applies to both views alike, since friendly and enemy share the same settings now")
DB:SetMany(looks.familiar.values)
DB:SetMany(looks.classic.values)
check(DB.views.enemy.name.outline == "" and DB.views.enemy.health.borderSize == 1 and DB.views.enemy.plate.height == 12 and DB.views.enemy.healthText.size == ns.defaults.look.healthText.size, "switching looks clears the previous look's settings")
DB:SetMany(looks.minimal.values)
check(DB.views.enemy.plate.width == 100 and DB.views.enemy.healthText.enabled == true and DB.views.enemy.healthText.anchor == "CENTER" and DB.views.enemy.castbar.iconSpan == false, "minimal puts its bar back with the shared layout")
DB:Set("look.raidMarker.position", "BOTTOMRIGHT")
DB:Set("look.auras.cc.side", "TOP")
DB:SetMany(looks.minimal.values)
check(DB.views.enemy.raidMarker.position == "LEFT" and DB.views.enemy.auras.cc.side == "RIGHT" and DB.views.enemy.name.justify == "CENTER", "minimal puts every position back")

local SAME = { "look.name.position", "look.healthText.anchor", "look.healthText.enabled", "look.level.enabled", "look.classification.enabled",
    "look.raidMarker.position", "look.quest.position", "look.castbar.textJustify", "look.castbar.showTimer", "look.castbar.showTarget",
    "look.auras.mine.side", "look.auras.mine.offsetY", "look.auras.important.enabled", "look.auras.important.side",
    "look.auras.purge.side", "look.auras.cc.side", "look.target.dimOthers", "look.range.enabled" }
local OWN = { inside = { ["look.name.position"] = true, ["look.healthText.anchor"] = true } }
local differ = {}
for _, group in ipairs({ ns.presets.looks, ns.presets.styles }) do
    for _, preset in ipairs(group) do
        for _, path in ipairs(SAME) do
            local base = looks.minimal.values[path]
            if not (OWN[preset.key] and OWN[preset.key][path]) and preset.values[path] ~= base then
                differ[#differ + 1] = preset.key .. " " .. path
            end
        end
    end
end
check(#differ == 0, "every built-in look shares the same parts and places" .. (#differ > 0 and (": " .. table.concat(differ, ", ")) or ""))
check(looks.familiar.values["look.auras.important.enabled"] == true and looks.flat.values["look.classification.enabled"] == false, "every look shows important auras and hides the elite icon")
