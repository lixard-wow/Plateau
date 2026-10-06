local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
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
DB:SetMany(looks.big.values)
check(DB.views.friendly.plate.width == 170 and DB.views.enemy.plate.width == 170, "preset applies to both views alike, since friendly and enemy share the same settings now")
DB:SetMany(looks.big.values)
DB:SetMany(looks.zperl.values)
check(DB.views.enemy.name.outline == "" and DB.views.enemy.health.borderSize == 1 and DB.views.enemy.plate.height == 12 and DB.views.enemy.healthText.size == ns.defaults.look.healthText.size, "switching looks clears the previous look's settings")
DB:SetMany(looks.normal.values)
check(DB.views.enemy.plate.width == 150 and DB.views.enemy.healthText.enabled == true and DB.views.enemy.castbar.showIcon == true, "normal puts the standard look back")
DB:Set("look.raidMarker.position", "BOTTOMRIGHT")
DB:Set("look.auras.cc.side", "TOP")
DB:SetMany(looks.normal.values)
check(DB.views.enemy.raidMarker.position == "TOP" and DB.views.enemy.auras.cc.side == "LEFT" and DB.views.enemy.name.justify == "CENTER", "normal puts every position back")
