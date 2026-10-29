local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Load(flavor, saved, class)
    Plateau = { flavor = flavor, DB = { saved = { global = { optionsTheme = saved } } }, Brand = { OnChange = function() end, Text = function(_, t) return t end } }
    UnitClassBase = function() return class or "MAGE" end
    RAID_CLASS_COLORS = { MAGE = { r = 0.25, g = 0.78, b = 0.92 } }
    local ns = {}
    assert(loadfile("Plateau_Options/Widgets/Style.lua"))("Plateau_Options", ns)
    return ns.Style
end

local function Same(a, b)
    return math.abs(a[1] - b[1]) < 1e-9 and math.abs(a[2] - b[2]) < 1e-9 and math.abs(a[3] - b[3]) < 1e-9
end

local retail = Load("mainline")
check(retail.ThemeKey() == "survey", "retail uses the survey look")
check(Load("forever").ThemeKey() == "survey", "WoW Forever uses the same look")
check(Load("mainline", "classic").ThemeKey() == "survey", "an old saved theme choice falls back to the survey look")
check(retail.RADIUS == 0 and retail.BUTTON_RADIUS == 0, "corners are square")
local accent = retail.colors.accent
check(math.abs(accent[1] - 0xd0 / 255) < 1e-9 and math.abs(accent[2] - 0x7a / 255) < 1e-9 and math.abs(accent[3] - 0x3c / 255) < 1e-9, "the accent is mesa ochre")
for _, token in ipairs({ "window", "rail", "header", "surface", "field", "hover", "border", "edge", "accent", "accentHi", "text", "muted", "faint", "warn", "primaryText" }) do
    check(type(retail.colors[token]) == "table", "the palette defines " .. token)
end

local live = Load("mainline")
local function Texture()
    local texture = {}
    function texture:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
    function texture:SetVertexColor(r, g, b, a) self.vertex = { r, g, b, a } end
    function texture:SetTextColor(r, g, b, a) self.text = { r, g, b, a } end
    return texture
end
local fill, fixed, dimmed = Texture(), Texture(), Texture()
live.Paint(fill, live.colors.surface)
live.Paint(fixed, { 0.3, 0.3, 0.3, 1 })
live.Paint(dimmed, live.colors.window, 1, 0.5)
check(Same(fill.color, live.colors.surface), "a palette color paints")
check(Same(fixed.color, { 0.3, 0.3, 0.3 }), "a fixed color paints as given")
check(math.abs(dimmed.color[1] - live.colors.window[1] * 0.5) < 1e-9 and dimmed.color[4] == 1, "a darkened palette color keeps its darkening and opacity")

local reset = Load("mainline")
local resetPaths, refreshed, menus = nil, 0, 0
Plateau.DB.ResetEverywhere = function(_, paths) resetPaths = paths end
MenuUtil = { CreateContextMenu = function() menus = menus + 1 end }
local hooks = {}
local frame = { HookScript = function(_, name, fn) hooks[name] = fn end }
reset.RightClickReset(frame, { label = "Height", path = "look.castbar.height" }, function() refreshed = refreshed + 1 end)
hooks.OnMouseUp(frame, "LeftButton")
check(resetPaths == nil, "left-click does not reset")
hooks.OnMouseUp(frame, "RightButton")
check(resetPaths and resetPaths[1] == "look.castbar.height" and refreshed == 1 and menus == 0, "right-click resets the setting straight away, with no menu")
local custom = 0
local hooks2 = {}
reset.RightClickReset({ HookScript = function(_, name, fn) hooks2[name] = fn end }, { label = "CVar", reset = function() custom = custom + 1 end }, function() end)
hooks2.OnMouseUp(nil, "RightButton")
check(custom == 1 and menus == 0, "settings with their own reset also reset straight away")

local function PixelLoad(uiScale, optionsScale)
    local style = Load("mainline")
    Plateau.DB.saved.global.optionsScale = optionsScale
    UIParent = { GetEffectiveScale = function() return uiScale end }
    PixelUtil = { GetPixelToUIUnitFactor = function() return 768 / 1440 end }
    return style
end
local function PixelsPerUnit(style, uiScale)
    return style.PixelScale() * uiScale / (768 / 1440)
end
local plain = PixelLoad(0.64, 1)
check(math.abs(PixelsPerUnit(plain, 0.64) - 1) < 1e-9, "at scale 1 one unit is exactly one screen pixel, whatever the UI scale")
local other = PixelLoad(1, 1)
check(math.abs(PixelsPerUnit(other, 1) - 1) < 1e-9, "a different UI scale from another addon still gives one pixel per unit")
local larger = PixelLoad(0.64, 1.15)
check(math.abs(PixelsPerUnit(larger, 0.64) - 1.15) < 1e-9, "the scale slider changes the size smoothly, not in whole-pixel steps")
local tiny = PixelLoad(0.64, 0.2)
check(math.abs(PixelsPerUnit(tiny, 0.64) - 0.6) < 1e-9, "the scale never goes below the slider minimum")
UIParent, PixelUtil = nil, nil
