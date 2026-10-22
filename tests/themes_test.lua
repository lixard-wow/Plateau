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
check(retail.ThemeKey() == "workbench", "retail starts on Workbench")
check(Same(retail.colors.accent, retail.THEMES.workbench.colors.accent), "Workbench uses its green accent")

local forever = Load("forever")
check(forever.ThemeKey() == "ledger", "WoW Forever starts on Artisan Ledger")
check(Same(forever.colors.accent, forever.THEMES.ledger.colors.accent), "Artisan Ledger uses its brass accent")

local saved = Load("mainline", "classic")
check(saved.ThemeKey() == "classic", "a saved theme choice is used")

local bogus = Load("mainline", "neon")
check(bogus.ThemeKey() == "workbench", "an unknown saved theme falls back to the client default")

local shapes = {}
for _, key in ipairs(retail.THEME_ORDER) do
    local style = Load("mainline", key)
    shapes[#shapes + 1] = table.concat({ style.RADIUS, style.BUTTON_RADIUS, style.font, style.headingFont, style.titleFont, style.TITLE_SIZE, style.sectionFont, style.buttonFont, style.HEADER_HEIGHT, style.ICON_BUTTON }, "|")
end
local oneShape = true
for i = 2, #shapes do
    oneShape = oneShape and shapes[i] == shapes[1]
end
check(oneShape, "every theme uses the same fonts, corners and sizes; only colors change")
check(retail.font:find("Barlow", 1, true) and retail.headingFont:find("Barlow", 1, true), "every theme uses Barlow")

local tokens = {}
for token in pairs(retail.THEMES.workbench.colors) do
    tokens[#tokens + 1] = token
end
for _, key in ipairs(retail.THEME_ORDER) do
    local theme = retail.THEMES[key]
    local missing = {}
    for _, token in ipairs(tokens) do
        if type(theme.colors[token]) ~= "table" then missing[#missing + 1] = token end
    end
    for _, group in ipairs({ "look", "casts", "highlights", "setup" }) do
        if type(theme.groups[group]) ~= "table" then missing[#missing + 1] = group end
    end
    check(theme.name and theme.desc and #missing == 0, theme.name .. " defines every color and section color" .. (#missing > 0 and (": missing " .. table.concat(missing, ", ")) or ""))
end

local picked = Load("mainline")
picked.SetTheme("ledger")
check(Plateau.DB.saved.global.optionsTheme == "ledger", "picking a theme saves it")
picked.SetTheme("neon")
check(Plateau.DB.saved.global.optionsTheme == "ledger", "an unknown theme is not saved")

local live = Load("mainline")
local function Texture()
    local texture = {}
    function texture:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
    function texture:SetVertexColor(r, g, b, a) self.vertex = { r, g, b, a } end
    function texture:SetTextColor(r, g, b, a) self.text = { r, g, b, a } end
    return texture
end
local accentTable = live.colors.accent
local fill, edge, label, fixed, dimmed = Texture(), Texture(), Texture(), Texture(), Texture()
live.Paint(fill, live.colors.surface)
live.PaintVertex(edge, live.groupColors.casts)
live.PaintText(label, live.colors.muted)
live.Paint(fixed, { 0.3, 0.3, 0.3, 1 })
live.Paint(dimmed, live.colors.window, 1, 0.5)
local heard
live.OnTheme(function(key) heard = key end)
live.SetTheme("horde")
local horde = live.THEMES.horde
check(Same(fill.color, horde.colors.surface), "a painted fill switches to the new theme's color without a reload")
check(Same(edge.vertex, horde.groups.casts), "section colors switch too")
check(Same(label.text, horde.colors.muted), "text colors switch too")
check(Same(fixed.color, { 0.3, 0.3, 0.3 }), "colors that are not theme colors stay as they are")
check(math.abs(dimmed.color[1] - horde.colors.window[1] * 0.5) < 1e-9 and dimmed.color[4] == 1, "a darkened theme color keeps its darkening and opacity")
check(live.colors.accent == accentTable and Same(accentTable, horde.colors.accent), "the shared color tables are updated in place, so hover effects pick up the new colors")
check(heard == "horde", "theme listeners hear about the switch")
live.PaintText(label, { 1, 0, 0, 1 })
live.SetTheme("alliance")
check(Same(label.text, { 1, 0, 0 }), "repainting with a fixed color stops the theme from overriding it")

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
