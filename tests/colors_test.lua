local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
Plateau = {}
Plateau.T = Plateau.T or (function() local l = {} assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", l) return l.T end)()
function UnitName() return "Stalador" end
function GetRealmName() return "Iridikron" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Presets.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local set = DB:ColorPaths().set
check(set["look.colors.hostile"] and set["look.colors.threatBad"] and set["look.castbar.readyColor"] and set["look.castbar.uninterruptible"], "cast, reaction and threat colors count as colors")
check(set["look.enemyTarget.color"] and set["look.name.classColors"] and set["look.target.ringColor"] and set["look.mouseover.ringColor"], "name, enemy target and highlight colors count as colors")
check(not set["look.health.background"] and not set["look.health.border"] and not set["look.castbar.border"] and not set["look.auras.mine.borderColor"], "backgrounds and borders are part of a look, not its colors")
check(not set["look.plate.width"] and not set["look.name.size"] and not set["look.health.texture"], "sizes, fonts and textures are not colors")

local touched = {}
for _, group in ipairs({ ns.presets.looks, ns.presets.styles }) do
    for _, preset in ipairs(group) do
        for path in pairs(preset.values) do
            if set[path] then touched[#touched + 1] = preset.key .. ":" .. path end
        end
    end
end
check(#touched == 0, "built-in looks no longer change any colors" .. (#touched > 0 and (" (" .. table.concat(touched, ", ") .. ")") or ""))

PlateauDB = nil
DB:Init()
DB:SwitchProfile("Minimal")
DB:Set("look.castbar.readyColor", { 0.1, 0.2, 0.3, 1 })
DB:Set("look.colors.hostile", { 0.9, 0.1, 0.1, 1 })
DB:Set("look.plate.width", 222)
local ok, count = DB:CopyColors("*")
check(ok and count == #DB:ListProfiles() - 1, "copying colors reaches every other profile")
local other = PlateauDB.profiles["Compact"].look
check(other.castbar.readyColor[2] == 0.2 and other.colors.hostile[1] == 0.9, "the other profile gets the active profile's colors")
check(not (other.plate and other.plate.width == 222), "layout settings are not copied")
check(not DB:CopyColors("Minimal") and not DB:CopyColors("Nope"), "copying to itself or a missing profile is refused")
check(DB:CopyColors("Compact") == true, "copying to a single profile works")
