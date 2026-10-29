local _, ns = ...

ns.helpTopics = {
    {
        category = "Good to know",
        title = "Moving parts exactly",
        keywords = "drag move click position snap shift free place arrow keys nudge exact readout type value pixel shortcut keyboard ctrl undo redo search",
        text = "Drag a part on the preview to move it; it snaps when you drop it near the bar. Hold Shift while dragging, or turn Snap off next to Undo and Redo, to place it anywhere.\n\nThe arrow keys move the selected part 1 pixel, or 10 with Shift. Click the number in the readout next to the selected part to type an exact value. Ctrl+Z undoes, Ctrl+Y redoes and Ctrl+F jumps to search.",
    },
    {
        category = "Good to know",
        title = "Limited settings in dungeons and raids",
        keywords = "limited instance dungeon raid restricted hidden secret warning icon midnight",
        text = "In some dungeon, raid and PvP content the game hides information from addons, such as threat or friendly nameplates. Settings marked with a warning icon depend on it; hover one to see what happens.\n\nWhen the game hides something, Plateau doesn't guess. Nameplates keep their normal colors, and Blizzard draws the parts it controls. Cast colors, aura filters and buff warnings still work there.",
    },
    {
        category = "Good to know",
        title = "Why a nameplate has its color",
        keywords = "colors color wrong priority order threat class type boss caster elite reaction tapped quest target focus",
        text = "Health bar colors are checked in order: target or focus, tapped, threat, quest enemies, enemy type or class, then reaction. The first one that applies wins.\n\nTarget an enemy and type /plt debug to see which color it got and why.",
    },
    {
        category = "Good to know",
        title = "Switching profiles automatically",
        keywords = "profile auto automatic switch content spec specialization dungeon raid delve open world",
        text = "Switch automatically on the Profiles page lets a profile take over in the open world, dungeons, raids, delves and scenarios, arenas and battlegrounds, or for a specialization. Content rules win over specialization rules.\n\nSwitches wait until combat ends and never change your default profile, so leaving the content switches back.",
    },
    {
        category = "Good to know",
        title = "Sharing a profile",
        keywords = "profile share export import string copy paste friend backup",
        text = "To share, click Export active profile on Profiles, click the string, then press Ctrl+A and Ctrl+C. It carries the look, aura spell lists and boss phase lines, but not Blizzard's settings, automatic rules or Window settings.\n\nTo import, paste a string, optionally name it, and click Import profile. The look shows before you import it, and it is saved as a new profile that never replaces one.",
    },
    {
        category = "Good to know",
        title = "Blizzard's nameplate settings",
        keywords = "game settings cvar blizzard options names over heads restore",
        text = "Blizzard's nameplate settings sit on the Plateau page they belong to, and their tooltip ends with Game setting. Changing one here changes it in Blizzard's Options too, and they are shared by every profile.\n\nPlateau saves the value it replaced and puts it back when you right-click the setting, use Reset page, or type /plt cvars restore.",
    },
    {
        category = "Commands",
        title = "Slash commands",
        keywords = "slash commands plt debug setup reset cvars whatsnew minimap",
        text = "/plt opens the settings window.\n/plt setup shows the list of looks.\n/plt whatsnew opens What's new.\n/plt minimap shows or hides the minimap button.\n/plt debug prints details for a bug report.\n/plt reset resets the active profile.\n/plt cvars restore puts back every game nameplate setting Plateau changed.",
    },
}

local Style = ns.Style
local C = Style.colors

local controls = {
    { type = "Note", label = "Hover any setting to see what it does. On this page, search finds help topics only.", height = 24 },
    { type = "Actions", buttons = {
        { label = "Open setup", width = 120, click = function() if PlateauSetup then PlateauSetup:Open() end end },
    } },
}

for i, entry in ipairs(ns.changelog or {}) do
    controls[#controls + 1] = { type = "Header", label = Style.T("What's new in %s"):format(entry.version), collapsible = i > 1, collapsed = i > 1, keywords = "changelog changes update patch notes version whatsnew" }
    for _, part in ipairs(entry.sections) do
        if part.title then
            controls[#controls + 1] = { type = "Note", label = part.title, size = 14, bright = true, padTop = 8 }
        end
        for _, item in ipairs(part.items) do
            controls[#controls + 1] = { type = "Note", label = "- " .. item, size = 12, bright = true }
        end
    end
end

local category
for _, topic in ipairs(ns.helpTopics) do
    if topic.category ~= category then
        category = topic.category
        controls[#controls + 1] = { type = "Header", label = category }
    end
    controls[#controls + 1] = { type = "Note", label = topic.title, size = 14, bright = true, padTop = 14, helpTopic = topic }
    controls[#controls + 1] = { type = "Note", label = topic.text, size = 12, bright = true }
end

ns.sections[#ns.sections + 1] = { key = "help", title = "Help", noReset = true, controls = controls }
