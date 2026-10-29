# Plateau Nameplates

Enemy nameplates for World of Warcraft that stay fast in big pulls and work within Midnight's addon rules. Plateau draws its own nameplates and gives you a settings window with a live sample plate: click a part to edit it, drag it to move it.

Version 0.1.3. Tested in the open world and in Mythic dungeons. Raids, PvP and WoW Forever are still being tested.

## Requirements
- Retail: Midnight, patch 12.1.0 or 12.1.5.
- WoW Forever: interface 16001 (still being tested).
- Nothing else. The libraries ship inside the addon.
- Optional: [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) or any media pack. Its bar textures, borders and fonts show up in Plateau's lists.

## Install
- CurseForge: install [Plateau Nameplates](https://www.curseforge.com/wow/addons/plateau) with the CurseForge app.
- By hand: copy the `Plateau` and `Plateau_Options` folders from a release zip into `Interface\AddOns` for your game version, then restart the game.

`Plateau_Options` only loads when you open the settings.

## First run
Plateau asks you to pick one of six looks: Minimal, Blizzard-like, Unit frame, Compact, Flat or Heavy. They all put things in the same places and differ only in the bar. Pick one and change anything later. `/plt setup` shows the list again.

## What it does
- Health bar: texture, border, background, fill direction, absorbs, execute tint and health markers. Boss phase lines show where a fight changes phase; this season's bosses are built in and you can edit any boss.
- Text: one font for all nameplate text, with its own size for the name, health, level and the enemy's target.
- Cast bar: colors that follow your own interrupt (ready, on cooldown, important, uninterruptible), a line where your interrupt comes back, a glow on important casts, the spell icon, a timer, who the cast is aimed at and who interrupted it.
- Colors: by enemy type, by threat for your role (with an off-tank color for tanks), quest enemies, class colors for enemy players, and colorblind presets.
- Auras: your debuffs, crowd control, enemy buffs you can remove, and important auras, each placed and sized on its own. Warnings mark an enemy that gains an important buff, a big defensive, an enrage or a magic buff.
- Icons: raid markers, quest icons, elite icons, faction crests, Mythic+ enemy forces, the enemy's power and your own class resource.
- Target, focus and mouseover: borders, glows, arrows, brackets and a brighter bar.
- Interrupts: party kicker icons on the enemy they can kick, with their cooldowns.
- Visibility, size and stacking: which nameplates show, fading, size by enemy type, stacking presets and the click area.
- Friendly names: friendly players and NPCs can show just their name, with an optional guild or title line, in the open world and delves.

## The settings window
Open it with `/plt`, the Plateau button in the game menu, or the minimap button.

- The preview at the top is a sample nameplate. Click a part to open its settings. Drag a part to move it; it snaps when you drop it near a spot on the bar. Hold Shift to place it freely. Arrow keys move the selected part 1 pixel, Shift and an arrow 10. Click the number next to the selected part to type an exact value.
- A small mark sits beside every setting you changed. Changed only, at the top of each page, hides the rest. Right-click a setting to reset it.
- Undo and Redo sit under the preview (Ctrl+Z and Ctrl+Y). Ctrl+F jumps to search.
- Help at the bottom of the sidebar explains every page. What's new is at the top of Help.

## Profiles
A profile holds every look setting. Each character remembers its profile, and Plateau can switch profiles by content (open world, dungeons, raids, delves) or by specialization. Switches wait until combat ends.

To share a profile, use Export on the Profiles page and paste the string into Import on another computer. The pasted look shows before you import it, and an import never replaces an existing profile.

## Midnight's rules
Since patch 12.0 the game hides some information from addons in combat and in instances. Plateau never reads or compares those hidden values; it passes them to the game's own functions, which is why cast colors, aura filters and warnings keep working in dungeons and raids. Some things the game does not allow at all: friendly nameplates in dungeons, raids and arenas are drawn by Blizzard, and threat can be hidden in some fights. Settings that depend on hidden values say so in their tooltip.

## Commands
- `/plt` or `/plateau` opens the settings.
- `/plt setup` shows the list of looks.
- `/plt whatsnew` opens What's new.
- `/plt minimap` shows or hides the minimap button.
- `/plt reset` resets the active profile.
- `/plt cvars restore` undoes every game nameplate setting Plateau changed.
- `/plt debug` prints details for a bug report.

## Compatibility
Plateau replaces enemy nameplates, so it should not run alongside another nameplate addon. If one is loaded, Plateau offers to turn it off. On WoW Forever, Mythic+ enemy forces is not available.

## Troubleshooting
- After an update, `/reload`. If new files were added, restart the game.
- A nameplate is the wrong color: colors on the Colors page are checked in order, and your target and focus colors win over the rest. `/plt debug` with the enemy targeted says why it has its color.
- To report a bug, include the error text (from BugSack or the game) and the `/plt debug` output.

## For developers
`Plateau/` is the core addon and always loads. `Plateau_Options/` is the settings window and loads on demand. Releases are built with the [BigWigs packager](https://github.com/BigWigsMods/packager).

## License
All rights reserved. You may use Plateau to play World of Warcraft, but not copy, modify or redistribute it. Translations are the exception: you may edit the language files to send one in. See [LICENSE](LICENSE). The bundled fonts and libraries keep their own licenses.

## Credits
- Translations: none yet. Translators will be named here.
- Libraries: LibStub, CallbackHandler, LibSharedMedia-3.0, LibDataBroker, LibDBIcon, LibDeflate.
- Icons and atlases in the preview are Blizzard's.
