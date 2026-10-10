# Plateau Nameplates

Nameplates for World of Warcraft that stay fast, read clearly in a big pull, and work inside Blizzard's Midnight addon rules.

Plateau replaces the enemy nameplates with its own, and gives you a settings window where you can see every change happen on a live sample plate, click a piece to edit it, and drag it where you want it.

**Status:** beta. Played in the open world and in Mythic dungeons. Raids, PvP and WoW Forever are still being tested.

## Contents
- [Requirements](#requirements)
- [Install](#install)
- [First run](#first-run)
- [What you get](#what-you-get)
- [The settings window](#the-settings-window)
- [Profiles and looks](#profiles-and-looks)
- [Sharing a profile](#sharing-a-profile)
- [How Midnight's rules affect this addon](#how-midnights-rules-affect-this-addon)
- [Commands](#commands)
- [Languages](#languages)
- [Compatibility](#compatibility)
- [Troubleshooting](#troubleshooting)
- [For developers](#for-developers)

## Requirements
- **Retail:** World of Warcraft Midnight, patch 12.1.0 or 12.1.5 (`120100`, `120105`).
- **WoW Forever:** interface `16001` (launching Nov 4, 2026; still being tested).
- Nothing else. The libraries it uses ship inside the addon.
- **Optional:** the [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) addon (or any addon that adds textures, borders and fonts to the shared media library). Plateau lists everything registered there in its texture, border and font pickers, so a pack such as SharedMedia adds a long list of bar textures, Charcoal among them.

## Install
1. On this page, click **Code**, then **Download ZIP**.
2. Open the zip. Inside the `Plateau-main` folder are two folders: `Plateau` and `Plateau_Options`.
3. Copy both into `World of Warcraft\_retail_\Interface\AddOns` (for WoW Forever, the `Interface\AddOns` folder of that game version), then restart the game.

`Plateau_Options` loads only when you open the settings, so it costs nothing while you play. A CurseForge release is coming later.

## First run
The first time you log in, Plateau asks you to pick a look from six ready-made styles. Everything else is set up in the settings window, which opens with a short tour of its parts. You can skip both, and bring them back any time: `/plt setup` for the look picker, or the buttons at the top of the **Help** page for the tour.

## What you get

### The plate
- **Health bar** with your choice of texture (Blizzard's, flat, striped, checkered, or any LibSharedMedia bar), border style (none, pixel, shadow, tooltip, thin tooltip, or LibSharedMedia borders), border thickness, and the border drawn around or inside the bar.
- **Health text** as percent, value, both, or value with percent in brackets, with decimals and placement.
- **Name** placed above, below, or in any corner of the bar, with long-name handling (show in full, cut, keep the last word, or abbreviate), class colors for players, and free font, size and outline.
- **Level** with difficulty coloring, a plus after elite levels, and hiding on enemies at your level.
- **Who the enemy is attacking** shown on the bar in the target's class color.
- **Absorb shields** drawn after the health or over the bar, with an overshield glow and choice of look.
- **Execute range and health lines:** tint the bar below a percentage you choose, and draw up to two marker lines.
- **Boss phase lines:** lines on boss health bars where the fight changes phase. Plateau knows which boss you are fighting and uses that boss's percentages; this season's bosses come built in, every boss can be edited, and bosses you fight are added on their own.

### The cast bar
- Colors that follow **your own interrupt**: one color while it is ready, another while it is on cooldown, and separate pairs for casts Blizzard flags as important. Uninterruptible casts have their own colors. A spec with no interrupt sees the ready colors on casts that can be interrupted, so healers can call them out.
- A **line on the cast bar** showing where your interrupt comes back during the cast.
- **Glow around important casts**, spell icon (beside the bar or one tall icon spanning the health and cast bars), timer that switches to tenths near the end, who the cast is aimed at (on its own line or right after the spell name), and who interrupted it.
- **Interrupt flash:** the bar flashes once when a cast is interrupted.
- **Join the cast bar to the health bar** inside one shared border, with a line between them.

### Colors
- **By enemy type:** bosses, lieutenants, elites, casters, melee and minor enemies, each with its own switch and color.
- **Threat:** the right rule for your spec. As a tank an enemy that is not on you turns the color, and as damage or healer an enemy that is on you does. Optionally also color enemies that are changing targets or that you are holding. Show it on the bar, on the bar's border, or both.
- **Off-tank color:** as a tank, an enemy another tank in your group is holding gets its own color, so your co-tank's enemies stand apart from yours and from loose ones. A swap between tanks never turns a plate red.
- **Quest enemies:** enemies you need for a quest get their own color.
- **Players:** class colors for enemy players. **Reaction:** your own hostile, neutral and friendly colors. **Tagged by someone else:** grey.
- **Colorblind palettes:** ready-made colors for deuteranopia and protanopia, and for tritanopia.

### Auras
Four groups, each with its own size, count, order, placement (above, below, left or right, growing and aligning as you like) and icon details:
- **My debuffs:** your own damage-over-time effects and debuffs, soonest to expire first. Optional tint in the pandemic window.
- **Crowd control:** stuns, incapacitates, roots and more, from anyone.
- **Enemy buffs:** by default only the ones you can remove (purge, spellsteal, soothe), or every buff. Boss and permanent buffs can be hidden.
- **Important auras:** buffs Blizzard flags as important.

Spell lists per specialization let you hide spells (`Never show these`) or show only some. Type names or IDs, and a name matches every spell with that name.

**Buff warnings** mark a plate with a colored border, a texture over the health bar, and the buff's icon when an enemy gains an important buff, a big defensive, an enrage, or a magic buff you can purge. If several apply at once, the one at the top of your priority list is drawn over the others; it starts as important, big defensive, enraged, magic, and you can reorder it.

### Target, focus and mouseover
Your target can have a colored border, a recolored or brightened bar, arrows (several styles, any color), corner brackets, and a soft glow. Your focus has the same options, and mouseover highlights the plate under your cursor. Plates you are not targeting can fade.

### Icons
Raid markers, elite, rare and boss icons, a quest icon (with modern campaign, important, legendary and repeatable markers on retail), a **Horde or Alliance crest** on players (optionally only when they're flagged for PvP), and **Mythic+ enemy forces**: how much of the enemy forces bar each enemy is worth.

### Threat percent
Your threat on each enemy as a percentage. WoW Forever shares the number with addons; on retail the game may hide it, and then nothing shows. Off by default.

### Friendly names
Friendly players and NPCs can show just their name. Optionally add a smaller line underneath: the player's guild, or an NPC's title such as `<Banker>`. These work in the open world and delves, since the game draws friendly plates itself in dungeons and raids.

### Enemy power bar
A thin bar showing an enemy's energy, rage, mana or other power, on bosses by default, so you can watch a boss's energy in a raid without unit frames. It is drawn from values the game hides, so it works even though Plateau cannot read the number.

### Your class resource
Combo points, holy power, soul shards, chi, arcane charges, essence or runes, drawn on your target's plate, on the top edge of the health bar. It only shows for specs and forms that use it: Druids in Cat Form, Windwalker Monks and Arcane Mages, plus every Rogue, Paladin, Warlock, Evoker and Death Knight. Set Segment width to 0 to make it exactly as wide as the health bar. Off by default.

### Sizing, layers and stacking
- Size by enemy type, a separate size for your target (or Blizzard's), and growth while an enemy casts.
- Your focus can grow too, with its own size.
- Your target and casting enemies can be brought to the front.
- Adjustable click area, with a switch that draws the click boxes on the preview and on real nameplates while you adjust them, and an option to include the cast bar.
- Stacking presets (tight, balanced, spread out), an instant-movement switch, and control over how much room each plate takes.
- Fade for enemies out of your interrupt's range.

### Blizzard's own nameplate settings
A page gathers the game's nameplate settings (which nameplates show, names over heads, off-screen plates, distance scaling and more). Plateau changes only the ones you change, remembers what they were, and puts them back on request: right-click a setting, reset the page, or type `/plt cvars restore`.

## The settings window
Open it with `/plt`, or the **Plateau Nameplates** button in the game menu (Escape), just above **AddOns**, or the minimap button (on retail Plateau is also in the addon list next to the minimap). Switches on the Plateau settings page (the gear button) hide each of these.

- **Live preview.** A sample plate updates as you change things. Click any part to jump to that part's settings: the page opens and the exact control flashes, or the page title flashes when the part is the whole section (the cast bar, for example). Drag a part to move it: it snaps to spots that make sense and leaves a one pixel space. Hold Shift to place it anywhere, or turn **Snap** off.
- **Nameplate types.** Enemy, Enemy player, Friendly, My target and My focus are stacked down the left. Enemy is the base. The others follow it and only differ where you change them, and the window takes the color of the type you pick.
- **Preview follows your settings.** Whatever you turn on shows on the sample. A **Preview** button next to Reset this section picks the sample's cast (Cast bar page), enemy type and threat (Health bar colors page), threat (Threat page) or badge (Elite icon page); it only changes the preview.
- **Undo and redo.** Every change is remembered and named ("Moved Raid target icon", "Look: Clean and flat"). Open the list to step back several at once.
- **Search.** Finds any setting by name or by words in its description and scrolls it to the top. On the Help page it searches only the help topics.
- **Pages.** One page per part of the nameplate, plus Looks at the top and Game settings and Help at the bottom.
- **Apply to all plates.** Copies every setting and position on the current page from the type you are editing to all plates.
- **Reset.** Right-click a setting to reset it, use **Reset this section**, or **Reset profile** on the Profiles page to reset the active profile.
- **Help.** A page of 44 topics covering every page and the common how-tos.

## Profiles and looks
A profile holds every look setting, including your per-type changes. Each character remembers which profile it uses.

- **Looks** are six ready-made profiles shown as live cards: Minimal (the default), Familiar layout, Classic unit frames, Compact, Clean and flat, and Bold and crisp. Press Use this look on a card to switch to it. **Restore a built-in profile** puts one back to how it shipped.
- **Switch automatically.** Choose a profile for the open world, dungeons, raids, and delves and scenarios, or per specialization. Content-specific profiles beat specialization profiles, your default profile is the fallback, and automatic switches wait until combat ends.
- **Manage** them from the button at the bottom left of the window, or the Profiles page: start fresh, copy the current one, copy another into this one, delete.

## Sharing a profile
On the Profiles page, **Export active profile** gives you a text string with every setting. On another computer, paste it into the import box and click **Import profile**. A name is optional, and the profile is used right away. You can choose whether your per-type changes come along. An import never replaces an existing profile.

## How Midnight's rules affect this addon
Since patch 12.0 the game hides some information from addons during combat and in instances, such as enemy health values, casts and which enemy a unit is. Plateau is built around that:

- It never reads, compares or does math on a hidden value. It hands the value straight to the game's own functions, which can use it safely. That is why cast colors, aura filters and buff warnings keep working in dungeons and raids.
- Some things the game simply does not allow. Friendly nameplates are locked in dungeons, raids and arenas, so Blizzard draws them there. The game hides who interrupts a channeled cast, so that name may be missing. Threat can be hidden in some fights, and a plate then keeps its normal color. A setting that depends on hidden information shows a warning icon, and its tooltip explains what happens.
- Nothing runs on each nameplate every frame, and updates avoid creating tables, so memory churn stays low. **Diagnostics** on the Help page shows the real numbers from the game's own profiler.

## Commands
- `/plt` opens the settings.
- `/plt setup` opens the look picker from the first-time setup.
- `/plt minimap` shows or hides the minimap button.
- `/plt debug` prints the version, restrictions, memory and CPU numbers. Paste it when you report a bug.
- `/plt debug reset` starts counting slow frames from now.
- `/plt reset` resets the active profile: a built-in look goes back to how it shipped, any other profile to the defaults.
- `/plt cvars restore` undoes every game nameplate setting Plateau changed.

## Languages
Plateau is in English. Every string can be translated, and translations are welcome: the [LICENSE](LICENSE) allows you to edit the language files to send one in, and translators are credited here. See [localization/README.md](localization/README.md) for how.

## Compatibility
- Plateau replaces Blizzard's enemy nameplates. If another nameplate addon is loaded, a dialog on first run offers to disable the other one, since two would fight over the same plates.
- Your game's nameplate settings are shared with other addons. Plateau records the ones it changes and restores them on request.

## Troubleshooting
- **Something looks wrong after an update:** `/reload`. New files need a full game restart.
- **A plate is the wrong color:** the colors on the Health bar colors page are checked top to bottom, and your target and focus colors win over all of them. Threat and tagged colors win over enemy type colors. Some settings are overridden for one nameplate type only. A dot in the left menu marks a page that differs from the default.
- **An error appears:** copy it from BugSack (or the game's error window) and `/plt debug` output when you report it.
- **Everything is a mess:** `/plt reset` for the current profile, or `/plt cvars restore` for the game's own settings.

## For developers
Layout:
```
Plateau/           core addon (always loaded)
Plateau_Options/   settings UI (load on demand)
```
Releases are packaged with the [BigWigs packager](https://github.com/BigWigsMods/packager); libraries are pulled in as externals by `.pkgmeta`.

## License
All rights reserved. You may use Plateau to play World of Warcraft, but not copy, modify or redistribute it. The one exception is translations: you may edit the language files to send a translation to the author. See [LICENSE](LICENSE). The bundled fonts and libraries keep their own licenses.

## Credits
- Translations: none yet. Translators will be named here.
- Libraries: LibStub, CallbackHandler, LibSharedMedia-3.0, LibDeflate.
- Icons and atlases used in the preview and quest markers are Blizzard's.
