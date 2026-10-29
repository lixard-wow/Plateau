local _, ns = ...

ns.helpTopics = {
    {
        category = "Getting started",
        title = "How Plateau works",
        keywords = "overview basics start intro what is profile whats new changelog",
        text = "Plateau changes how enemy nameplates look: the health bar, name, cast bar, auras and icons. The game still decides which nameplates show, so it keeps working in dungeons and raids.\n\nThe preview at the top shows a sample nameplate, the menu on the left lists the pages, and every change saves right away to the active profile. After an update, Help gets a small mark and What's new is at the top of the Help page.",
    },
    {
        category = "Getting started",
        title = "The preview",
        keywords = "preview sample situations play scenarios cast enemy threat badge showing",
        text = "The preview is a sample enemy nameplate that shows what your settings turn on. The part you are editing is outlined.\n\nOn some pages a button at the bottom left of the preview reads Showing, followed by what the sample shows: the cast kind on Cast bar, the enemy type and threat on Colors, and the badge on Icons. Click it to change the sample. It only changes the preview and is never saved.",
    },
    {
        category = "Getting started",
        title = "Editing on the preview: click and drag",
        keywords = "drag move click position snap shift free place reposition arrow keys nudge type value",
        text = "Click any part of the sample nameplate to open its settings. Drag a part to move it; it snaps to useful spots. Hold Shift while dragging, or turn Snap off next to Undo and Redo, to place it anywhere.\n\nThe arrow keys move the selected part 1 pixel, or 10 with Shift. To set an exact spot, click the number in the readout next to the selected part and type a value.",
    },
    {
        category = "Getting started",
        title = "Moving parts exactly",
        keywords = "arrow keys nudge exact readout type value pixel shortcut shortcuts keyboard ctrl undo redo search",
        text = "Select a part on the preview, then press the arrow keys to move it 1 pixel, or 10 with Shift held. The readout next to the selected part shows its position; click the number and type a value to place it exactly.\n\nIn the settings window, Ctrl+Z undoes a change, Ctrl+Y redoes it and Ctrl+F jumps to the search box.",
    },
    {
        category = "Getting started",
        title = "Looks: ready-made starting points",
        keywords = "looks list presets layouts styles minimal default blizzard like unit frame compact flat heavy setup",
        text = "Setup lists six looks: Minimal, Blizzard-like, Unit frame, Compact, Flat and Heavy. They share one layout and differ only in the bar. Pick one and press Use this look, or double-click it, and it becomes your profile.\n\nType /plt setup to open the list again. Restore built-in on the Profiles page puts a look back to how it shipped.",
    },
    {
        category = "Getting started",
        title = "Undo and redo",
        keywords = "undo redo history revert mistake back ctrl z y",
        text = "Undo and Redo sit under the preview, on the right. Ctrl+Z undoes a change and Ctrl+Y redoes it. Click Undo to pick from a list and step back several changes at once.\n\nUndo keeps the last 20 changes made while this window or setup is open, including Blizzard's nameplate settings. Switching profiles clears it.",
    },
    {
        category = "Getting started",
        title = "Dimmed settings and collapsed sections",
        keywords = "dimmed disabled greyed collapsed section advanced expand hidden",
        text = "A setting that can't do anything right now, such as border thickness while the border is off, is dimmed. Hover it to see what to turn on. Your value is kept.\n\nSome advanced settings sit in collapsed sections, such as Off-screen nameplates on Stacking and clicks, and Blizzard-drawn nameplates on Friendly. Click a heading to open it; search opens it for you.",
    },
    {
        category = "Getting started",
        title = "Searching settings and help",
        keywords = "search find lookup where ctrl f",
        text = "The search box at the top of the window finds any setting by its name or description. Press Ctrl+F to jump to it. Pick a result to go to that setting; collapsed sections open and the setting flashes.\n\nOn the Help page, the box searches help topics instead.",
    },
    {
        category = "Getting started",
        title = "Resetting settings",
        keywords = "reset default restore revert clear start over everything changed only reset page",
        text = "Right-click a setting to reset it to its default. Reset page, at the top right of the page, resets the page you are on, and Reset profile on the Profiles page resets the whole active profile. Both ask you to click again to confirm.\n\nChanged only, next to Reset page, shows just the settings you changed, and each has a small mark beside it. For a recent mistake, Undo is gentler.",
    },
    {
        category = "Getting started",
        title = "Limited settings in dungeons and raids",
        keywords = "limited instance dungeon raid restricted hidden secret warning icon",
        text = "In some dungeon, raid and PvP content the game hides information from addons, such as threat or friendly nameplates. Settings marked with a warning icon depend on it; hover one to see what happens.\n\nWhen the game hides something, Plateau doesn't guess. Nameplates keep their normal colors, and Blizzard draws the parts it controls. Cast colors, aura filters and buff warnings still work there.",
    },
    {
        category = "Profiles",
        title = "Profiles",
        keywords = "profile switch manage character create duplicate rename copy delete default active override",
        text = "A profile holds your nameplate look and aura spell lists. Each character has a default profile, and characters can share one. The active profile, shown at the top right of the window, is the one every page edits.\n\nThe Profiles page creates, duplicates, renames, copies, deletes and restores profiles. Blizzard's nameplate settings are shared by every profile, except Use Blizzard nameplate sizing and Stacking bounds.",
    },
    {
        category = "Profiles",
        title = "Switching profiles automatically",
        keywords = "auto automatic switch content spec specialization dungeon raid delve open world",
        text = "Switch automatically on the Profiles page lets a profile take over in the open world, dungeons, raids, delves and scenarios, arenas and battlegrounds, or for a specialization. Content rules win over specialization rules.\n\nSwitches wait until combat ends and never change your default profile, so leaving the content switches back.",
    },
    {
        category = "Profiles",
        title = "Sharing a profile",
        keywords = "share export import string copy paste friend backup",
        text = "To share, click Export active profile on Profiles, click the string, then press Ctrl+A and Ctrl+C. It carries the look, aura spell lists and boss phase lines, but not Blizzard's settings, automatic rules or Window settings.\n\nTo import, paste a string, optionally name it, and click Import profile. It is saved as a new profile and never replaces one.",
    },
    {
        category = "Pages",
        title = "Size page",
        keywords = "size scale enemy type target focus casting blizzard nameplate size distance bigger smaller",
        text = "Size holds every scale: by enemy type, in and out of combat, and for your target, focus, casting enemies and mouseover. A nameplate uses its largest scale, and only combat scale multiplies another one.\n\nBlizzard's nameplate size and size by distance are here too. Width and height are on Health bar, and friendly scale is on Friendly.",
    },
    {
        category = "Pages",
        title = "Visibility page",
        keywords = "visibility fading fade opacity occluded hidden walls line of sight range distance transparent which nameplates show",
        text = "Visibility picks which nameplates show, how they fade and how enemies look out of combat. Fading covers enemies outside your interrupt range, nameplates other than your target, nameplates behind walls and distant ones.\n\nBehind walls has its own switches for the open world, dungeons, raids, delves and battlegrounds. With range fading, casting enemies stay at full opacity.",
    },
    {
        category = "Pages",
        title = "Stacking and clicks page",
        keywords = "stacking stack overlap spacing movement slide",
        text = "Stacking and clicks keeps nameplates from overlapping. Pick a spacing preset, and turn on Show stacking boxes to see the area the game keeps apart. Stacking bounds decides how much of each nameplate counts, and Movement sets how fast they slide into place.",
    },
    {
        category = "Pages",
        title = "Clickable area",
        keywords = "click area clickable padding offset hitbox",
        text = "Clickable area, on Stacking and clicks, sets the box you click to target an enemy. Show clickable areas draws it while the window is open, and Include cast bar in clickable area adds the cast bar. Click-through friendly nameplates lets clicks pass through friendly nameplates.",
    },
    {
        category = "Pages",
        title = "Out of combat nameplates",
        keywords = "out of combat idle combat scale opacity hide show visibility",
        text = "Out of combat, on the Visibility page, gives enemies that aren't fighting their own look so the ones in combat stand out. They can be more see-through, smaller or one flat color, and can hide parts such as auras or the name.\n\nIt switches back as soon as the enemy enters combat. Your target, players and friendly nameplates are never changed.",
    },
    {
        category = "Pages",
        title = "Health bar page",
        keywords = "health bar width height texture overlay pattern checkers lines border color absorb absorbs execute threshold marker",
        text = "Health bar sets the bar's size, texture, overlay pattern, background and border, plus the fill direction and spark. Your target and focus can use their own texture on Target and focus.\n\nAbsorbs shows shields on the bar. The execute color marks enemies below a health threshold you pick, and health markers draw up to two lines, for example at 20% and 35%.",
    },
    {
        category = "Pages",
        title = "Colors page",
        keywords = "colors color threat class type boss caster elite melee reaction interrupt hostile neutral friendly tapped quest colorblind preset low health",
        text = "Colors sets the health bar colors, in priority order: target or focus, tapped, threat, quest enemies, enemy type or class, then reaction. Colorblind presets set a full palette; click one twice to apply it.\n\nEnemy types gives bosses, casters, lieutenants, elites and other enemies their own color, and enemy players can use class colors. Color by health, under Low health, fades the bar as the enemy loses health.",
    },
    {
        category = "Pages",
        title = "Threat colors",
        keywords = "threat aggro tank percent off-tank warning safe color",
        text = "Threat colors, on the Colors page, color an enemy when the wrong player has aggro. Show threat on picks the bar, its border or both, and you can add warning, safe and off-tank colors. The game can hide threat in some fights; nameplates keep their normal color then.\n\nThreat percent, on Dungeons and raids, shows your threat on each enemy as a number.",
    },
    {
        category = "Pages",
        title = "Friendly page",
        keywords = "friendly nameplates names only npc player instance size dungeon raid",
        text = "Style friendly nameplates with Plateau gives friendly players and NPCs Plateau's look, with their own scale, names only and colors. Friendly players and Friendly NPCs each have their own switch and settings.\n\nIn dungeons, raids and arenas the game locks friendly nameplates, so Blizzard draws them and Blizzard's friendly nameplates, at the bottom of the page, apply instead.",
    },
    {
        category = "Pages",
        title = "Health text",
        keywords = "health text percentage value number format position who enemy attacking target text page",
        text = "Health text, on the Text page, shows the enemy's health as a percentage, value or both. When to show can hide it at full health or show it only on your target, and Color can fade it by health or change it in execute range.\n\nIts size is set here; the font is set once under All plate text.",
    },
    {
        category = "Pages",
        title = "Names",
        keywords = "name text font long names width class color position align enemy target name text page",
        text = "Name, on the Text page, sets where names sit and how long names are shortened or cut. When to show can limit names to your target or hide them while the enemy casts.\n\nEnemy target name, in the same place, shows who the enemy is targeting.",
    },
    {
        category = "Pages",
        title = "Level text",
        keywords = "level number difficulty elite plus text page",
        text = "Level, on the Text page, shows the enemy's level, with + for elites and r for rares. It can color the level by difficulty and hide it on same-level, trivial or instance enemies.",
    },
    {
        category = "Pages",
        title = "Cast bar page",
        keywords = "cast bar spell icon interrupt important glow highlight interrupted who time target marker cooldown spacing background",
        text = "Cast bar picks which casts get a bar, its size, texture and border, and the spell icon. Cast bar colors show whether your interrupt is ready and whether the cast can be interrupted, and important casts can glow.\n\nText shows the spell name, cast time and cast target. Interrupted casts briefly shows who interrupted, and the interrupt ready marker shows where your interrupt comes back.",
    },
    {
        category = "Pages",
        title = "Warnings",
        keywords = "buff warnings warnings tab enrage important major defensive dispellable magic purge dispel border overlay texture warning priority icon",
        text = "The Warnings tab on Auras marks the nameplate when an enemy gains a buff worth reacting to: Important, Major defensive, Enrage or Dispellable Magic. Each can show as a colored border, a health bar overlay or both, and Warning priority picks which one shows when several apply.\n\nThe game classifies these buffs, so warnings work in dungeons and raids. Only warn for buffs you can remove hides the Enrage and Magic warnings you can't act on.",
    },
    {
        category = "Pages",
        title = "Auras page",
        keywords = "aura text font outline shadow tooltips all auras icons tabs layout which auras hidden allowed spells",
        text = "Every tab on Auras is laid out the same way: Show turns the group on, Which auras filters it, Layout places it and Icon styles each icon. Hidden spells and Allowed spells take spell names or IDs separated by commas, saved per specialization.\n\nThe Tooltips tab shows Blizzard's aura tooltip when you hover an icon. Aura text uses the font set under All plate text on the Text page.",
    },
    {
        category = "Pages",
        title = "Your debuffs",
        keywords = "my debuffs your debuffs dots auras own player icons",
        text = "The Your debuffs tab on Auras shows your damage over time effects and other debuffs on enemies. Show other players' debuffs adds theirs after yours.",
    },
    {
        category = "Pages",
        title = "Crowd control",
        keywords = "crowd control cc stun root incapacitate auras",
        text = "The Crowd control tab on Auras shows stuns, incapacitates and roots on enemies, whoever cast them. In dungeons and raids the game decides which auras land here.",
    },
    {
        category = "Pages",
        title = "Enemy buffs",
        keywords = "enemy buffs purge spellsteal soothe enrage dispel",
        text = "The Enemy buffs tab on Auras shows buffs you can purge, steal or soothe, and Show all buffs adds the rest. Buffs the game flags as important show on the Important tab instead.\n\nSpell lists only work on enemy buffs in the open world, because the game hides which buff it is in dungeons and raids.",
    },
    {
        category = "Pages",
        title = "Important auras",
        keywords = "important auras flagged",
        text = "The Important tab on Auras shows buffs the game flags as important on an enemy, except your own. It is off by default, and a buff shows here or on Enemy buffs, not both.",
    },
    {
        category = "Pages",
        title = "Target and focus page",
        keywords = "highlight highlights states targets target focus mouseover arrows brackets glow border recolor opacity tabs",
        text = "Target and focus has a tab each for your target, focus and mouseover. Your target and focus can have a border, a recolored or brighter bar with its own texture, arrows, brackets and a glow. Target settings win when a unit is both.\n\nMouseover highlights the nameplate under your cursor. Scales are on Size, and fading other nameplates is on Visibility.",
    },
    {
        category = "Pages",
        title = "Raid target icon",
        keywords = "raid marker icon skull star icons page",
        text = "Raid target icon, on the Icons page, shows raid markers already set on units. Drag it on the preview to place it, and Raid icon border outlines marked nameplates in the icon's color. Friendly nameplates can use their own position on the Friendly page.",
    },
    {
        category = "Pages",
        title = "Quest icon",
        keywords = "quest icon objective icons page",
        text = "Quest icon, on the Icons page, marks enemies that count toward your quests, with an optional progress count. Quest enemy color colors their health bars, after threat in the color priority.",
    },
    {
        category = "Pages",
        title = "Dungeons and raids page",
        keywords = "mythic plus mob percent mob % enemy forces percent count dungeon m+ enemy forces boss phase lines threat percent",
        text = "Dungeons and raids holds Mythic+ enemy forces, threat percent and boss phase lines. Enemy forces shows how much of the forces bar each enemy is worth during a Mythic+ run.\n\nBoss phase lines mark boss health bars where the fight changes phase. You can edit them per boss or set default lines for other bosses.",
    },
    {
        category = "Pages",
        title = "Enemy power bar",
        keywords = "enemy power bar boss energy rage mana raid encounter unit frames resource percentage position opacity color icons page",
        text = "Enemy power bar, on the Icons page, is a thin bar with an enemy's energy, rage, mana or other power, handy for a raid boss's energy. Enemies without that power get no bar.\n\nDisplay picks which enemies get one, and Text can show the power as a percentage or value when the game provides one.",
    },
    {
        category = "Pages",
        title = "Class resource",
        keywords = "class resource combo points holy power soul shards chi arcane charges essence runes pips icons page",
        text = "Class resource, on the Icons page, shows your combo points, holy power, soul shards, chi, arcane charges, essence or runes on your target's nameplate. It is off by default; Show class resource on target turns it on.",
    },
    {
        category = "Pages",
        title = "Elite icon",
        keywords = "elite rare boss classification dragon icon icons page",
        text = "Elite icon, on the Icons page, puts the dragon on elite, rare and boss nameplates, with a switch for each kind. Drag it on the preview to place it.",
    },
    {
        category = "Pages",
        title = "Blizzard's nameplate settings",
        keywords = "game settings cvar blizzard options names over heads which nameplates show off-screen soft target blizzard-drawn window",
        text = "Blizzard's nameplate settings sit on the Plateau page they belong to, and their tooltip ends with Game setting. Changing one here changes it in Blizzard's Options too, and they are shared by every profile.\n\nPlateau saves the value it replaced and puts it back when you right-click the setting, use Reset page, or type /plt cvars restore. Plateau's own window options are on the Window page.",
    },
    {
        category = "How do I",
        title = "Make elites and casters stand out",
        keywords = "colors elites casters kick priority type color bar",
        text = "Open Colors and turn on Enemy type colors, then pick a color for types such as Casters, Lieutenants and Other elites. To make them bigger, turn on Scale by enemy type on the Size page.",
    },
    {
        category = "How do I",
        title = "See when my interrupt is ready",
        keywords = "interrupt kick ready cooldown cast bar color line kick tracker",
        text = "Cast bars follow your own interrupt. Set the ready and on-cooldown colors under Cast bar colors on the Cast bar page, and turn on Show interrupt ready marker to see where your interrupt comes back.\n\nThe Interrupts page shows which party member kicks which enemy.",
    },
    {
        category = "How do I",
        title = "Hide a spell from my debuffs",
        keywords = "hide spell never show filter thrash moonfire remove aura",
        text = "Open the Your debuffs tab on Auras, go to Which auras and type the spell's name or ID in Hidden spells, then press Enter. Separate several with commas.\n\nThe list is saved per specialization, and a name matches every spell with that name.",
    },
    {
        category = "How do I",
        title = "Move my auras or icons",
        keywords = "move aura placement position icons above below left right center",
        text = "Drag the group on the preview, or set Position, Alignment and Growth direction under Layout on its tab. Hold Shift while dragging, or turn Snap off, to place it freely, and use the arrow keys for small steps.",
    },
    {
        category = "How do I",
        title = "Stop nameplates overlapping",
        keywords = "overlap stacking stack spacing slide crowded",
        text = "Open Stacking and clicks and click a spacing preset: Tight, Balanced or Spread out. Show stacking boxes shows the area the game keeps apart, and Stacking bounds can include the name or cast bar if they overlap.",
    },
    {
        category = "How do I",
        title = "Go back to how it was",
        keywords = "revert restore undo lost broke fix reset old",
        text = "Use Undo for a recent mistake, right-click a setting to reset it, or use Reset page for the whole page. Restore built-in on the Profiles page puts a look back the way it shipped, and /plt cvars restore puts back Blizzard's nameplate settings.\n\nTo start over, type /plt setup and pick a look.",
    },
    {
        category = "Commands",
        title = "Slash commands",
        keywords = "slash commands plt debug setup reset cvars",
        text = "/plt opens the settings window.\n/plt setup opens setup.\n/plt minimap shows or hides the minimap button.\n/plt debug shows the version, profile and active game restrictions. Paste it when you report a bug.\n/plt reset resets the active profile.\n/plt cvars restore puts back every game nameplate setting Plateau changed.",
    },
}

local Style = ns.Style
local C = Style.colors

local controls = {
    { type = "Note", label = "Every feature of Plateau is explained below. On this page, search finds help topics only.", height = 24 },
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
