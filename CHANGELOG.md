# Changelog

## 0.1.4

### New
- Kick tracker: a party member's class icon shows on the enemy they are marked to kick and on the one they last kicked, with their interrupt's cooldown. Pick what the icon shows, its size, countdown numbers, dungeons only, and whether icons stay after the interrupt is ready. In keys a kick only shows when Plateau can tell who it was.
- Turned off tray in the preview: drag a part into it to turn it off, drag it out to turn it on.
- Drag parts on the preview to place them. They snap to the bar when dropped near it; hold Shift or turn Snap off to place them anywhere. The arrow keys nudge the selected part, and clicking the offset readout lets you type an exact value. Rulers and a crosshair follow the part you drag.
- Hovering a setting outlines its part on the preview.
- Settings changed from the default are marked, and Changed only shows just those.
- Ctrl+Z undoes, Ctrl+Y redoes and Ctrl+F jumps to search. The window reopens at the spot you last scrolled to.
- Disable Plateau for this character only.
- Setup and import show a look before you apply it.
- Friendly page: set the width and height of every nameplate the game draws. Plateau's own nameplates keep their look.
- Stacking box width, height and offset sliders.
- The clickable area can include the cast bar, or only while a cast is up. Include name in clickable area lets you click an enemy's name to target it, on by default.
- Export carries every Blizzard nameplate setting Plateau shows, and import names any missing media addons.
- Names in other alphabets use Blizzard's fonts for that alphabet behind your chosen font.
- Raid, elite, quest and faction icons placed on the same spot line up side by side when more than one shows.

### Changed
- A new settings window: a title strip, a preview with rulers, a flat side menu and sections without cards. Pages are regrouped into fewer, with tabs for auras and for target, focus and mouseover. Window themes, the brand color and the window font settings are gone.
- All nameplate text shares one font, outline and shadow.
- The offset sliders are gone; move parts on the preview instead. Help keeps What's new and the topics the settings can't show; the tour is gone.
- The built-in looks share one layout; only the bars differ.
- Stacking presets set overlap and the game's slide speed together. Instant movement stays on the Stacking page.
- Enemy nameplates stack by default. If you had enemy stacking off, this update turns it on once; turn it off again on the Stacking page and it stays off.
- The enemy power bar shows on bosses only. The Show on choice is gone.
- On/off switches are small bars with a knob that slides across when clicked.
- Every dimmed setting names the switch that turns it on.

### Fixed
- Health, cast and enemy power bars, borders and icons line up to the exact pixel at any UI scale. Plates no longer merge their layers before drawing, which shifted some parts by a pixel.
- The whole clickable area works, padding and cast bar included. The game only takes clicks inside its own nameplate box, so Plateau makes that box big enough. Out of combat only.
- Spell target and enemy target names keep their class color when the game hides the class.
- No more "attempt to compare a secret number" error from the cast bar timer after combat.
- Locked aura and shield buttons are skipped while restyling and finished when the game allows it.
- Right-click reset and change marks work on the clickable area, stacking box and nameplate offset sliders.
- Long spell names on the cast bar stop before the timer.
- Dropdown values too long for the box drop their bracketed detail, and the full value shows in the tooltip. Percent and seconds sliders show their unit.

## 0.1.3

### New
- A redesigned settings window: a header with search, theme buttons, your profile and Undo/Redo; side menu categories that open as you need them; a short description on every page; settings grouped in cards; and a framed live preview.
- Settings window themes only change colors now and switch instantly, without a reload. All five themes share the same fonts and shapes.
- On/off switches are rounded and slide when clicked, and checkboxes in lists are rounded with a check mark.
- What's new: the first time you log in after an update, Plateau shows what changed. Pick Don't show again to turn it off, or open it any time with /plt whatsnew.
- New characters start with the profile you picked in setup, and the Profiles page shows which profile new characters use.

### Changed
- The settings window and its pop-ups sit on whole screen pixels, so borders stay sharp at any UI scale, including scales set by other addons. The window scale setting now changes in steps.
- The settings preview follows Pixel-perfect borders, shows full health and cast bars so edges are easy to see, and no longer shows snap dots while you drag.
- Restyling is lighter: borders, auras, health colors and pixel rounding skip work that hasn't changed.

### Fixed
- The interrupt ready marker could disappear when its thickness was set to 1.
- A newer interrupt message could be hidden early by an older interrupt's timer.
- The settings window jumped away from the cursor when you started dragging it.
- Nameplates Plateau hands back to Blizzard keep updating their auras, cast bar and other details.
- Settings saved by a newer version of Plateau are kept safe instead of being reset when an older version loads them.

## 0.1.2

### Changed
- You can drag the settings and setup windows from any empty spot, not just the title bar.
- The target glow pulse now brightens and dims the whole glow, not just its corners.

## 0.1.1

### New
- The target glow can wrap the cast bar while your target casts. Turn it off with Glow around the cast bar under Target.
- A new character's first login opens setup, where you can pick a profile you already have, paste a profile string, or start from a ready-made look. Setup now offers these for every character.

### Changed
- Plateau styles friendly nameplates by default, so friendly NPCs show names instead of Blizzard's health bars in the open world.
- Profile strings now carry the Blizzard nameplate settings you change in Plateau, such as stacking, spacing and max distance. They're applied when you activate the imported profile.

## 0.1.0

First release.

### Nameplates
- Enemy nameplates drawn by Plateau, attached to the game's own nameplates, with friendly names for players and NPCs in the open world and delves.
- Health bar with your choice of texture, border and fill direction, health text, names, levels, absorb shields and execute range.
- Cast bar colored by your own interrupt: ready, on cooldown, important and uninterruptible casts each get their own colors, with a marker for when your interrupt comes back, a glow on important casts, the cast's target and who interrupted it.
- Colors by enemy type, threat for your role, an off-tank color, quest enemies, class colors for players and colorblind palettes.
- Four aura groups (your debuffs, crowd control, enemy buffs, important auras) with per-spec spell lists.
- Buff warnings for important buffs, big defensives, enrages and purgeable magic.
- Boss phase lines for this season's bosses, Mythic+ enemy forces, an enemy power bar and your class resource on your target.
- Target, focus and mouseover highlights, plus sizing, stacking, click area and fading options.

### Settings window
- Live preview: click any part to jump to its settings, or drag it to move it.
- Separate settings for enemy players, friendly units, your target and your focus, each following the enemy settings until you change them.
- Undo and redo, search, built-in help and a short tour.
- Six ready-made looks to start from, and five window themes: Workbench, Artisan's Ledger, Horde, Alliance and Slate.
- Profiles that switch automatically by content or specialization, and profile sharing by text string.
- Blizzard's nameplate settings gathered in one place, with a one-step restore.

### Commands
- `/plt` or `/plateau` opens the settings. `/plt setup`, `/plt minimap`, `/plt reset`, `/plt cvars restore` and `/plt debug` are also available.
