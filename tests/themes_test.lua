local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local function Load(flavor, saved, class)
    Plateau = { flavor = flavor, DB = { saved = { global = { optionsTheme = saved } } }, Brand = { OnChange = function() end, Text = function(_, t) return t end } }
    UnitClassBase = function() return class or "MAGE" end
    RAID_CLASS_COLORS = { MAGE = { r = 0.25, g = 0.78, b = 0.92 } }
    local ns = {}
    assert(loadfile("Plateau_Options/Widgets/Style.lua"))("Plateau_Options", ns)
    return ns.Style
end

local retail = Load("mainline")
check(retail.ThemeKey() == "workbench", "retail starts on Workbench")
check(retail.RADIUS == 10, "Workbench has 10 pixel corners")
check(retail.StateColor() == retail.colors.accent, "Workbench uses its green accent, like PKT's Workbench")

local forever = Load("forever")
check(forever.ThemeKey() == "ledger", "WoW Forever starts on Artisan Ledger")
check(forever.RADIUS == 4, "Artisan Ledger has 4 pixel corners")
check(forever.StateColor() == forever.colors.accent, "Artisan Ledger uses its brass accent")
check(forever.font:find("SourceSans3", 1, true) and forever.headingFont:find("Cinzel", 1, true), "Artisan Ledger uses Source Sans for text and Cinzel for headings")

local classic = Load("mainline", "classic")
check(classic.ThemeKey() == "classic", "a saved theme choice is used")
check(classic.RADIUS == 0, "Lixard Classic has square corners")
check(math.abs(classic.colors.accent[1] - 0.25) < 1e-9 and math.abs(classic.colors.accent[3] - 0.92) < 1e-9, "Lixard Classic highlights in the class color of the character you're on")
check(classic.StateColor() == classic.colors.accent and classic.groupColors.look == classic.colors.accent, "Lixard Classic's toggles, sliders and section colors follow the class color")
check(math.abs(classic.THEMES.classic.colors.accent[1] - 0.78) < 1e-9, "the theme itself keeps the gold accent for when no class is known")
check(math.abs(retail.colors.accent[1] - 0.25) > 0.01, "other themes keep their own accent")

local bogus = Load("mainline", "neon")
check(bogus.ThemeKey() == "workbench", "an unknown saved theme falls back to the client default")

for _, key in ipairs(retail.THEME_ORDER) do
    local theme = retail.THEMES[key]
    local complete = theme.name and theme.body and theme.heading and theme.colors and theme.groups
    for _, token in ipairs({ "window", "rail", "field", "hover", "border", "accent", "text", "muted", "warn" }) do
        complete = complete and theme.colors[token] ~= nil
    end
    for _, group in ipairs({ "look", "casts", "highlights", "setup" }) do
        complete = complete and theme.groups[group] ~= nil
    end
    check(complete, theme.name .. " defines every color, section color, font and gradient")
end

local picked = Load("mainline")
picked.SetTheme("ledger")
check(Plateau.DB.saved.global.optionsTheme == "ledger", "picking a theme saves it")
picked.SetTheme("neon")
check(Plateau.DB.saved.global.optionsTheme == "ledger", "an unknown theme is not saved")

local PKT_COLORS = { "title", "heading", "line", "surface", "surfaceBorder", "buttonText", "primary", "primaryBorder", "primaryHover", "primaryText", "iconButton", "iconButtonBorder" }
for key, theme in pairs(retail.THEMES) do
    local missing = {}
    for _, color in ipairs(PKT_COLORS) do
        if type(theme.colors[color]) ~= "table" then missing[#missing + 1] = color end
    end
    check(#missing == 0, key .. " has every PKT color" .. (#missing > 0 and (": missing " .. table.concat(missing, ", ")) or ""))
    check(type(theme.titleFont) == "table" and type(theme.sectionFont) == "table" and type(theme.buttonFont) == "table" and theme.headerHeight and theme.iconButton, key .. " has PKT fonts and header sizes")
    check(not theme.headerFill or type(theme.colors.header) == "table", key .. " has a header color when its header is filled")
end
check(retail.THEMES.ledger.colors.title[1] > 0.9 and retail.THEMES.ledger.brackets == true, "Artisan Ledger uses PKT's gold title and corner brackets")
