# Plateau Nameplates

Enemy nameplates for Midnight and WoW Forever that stay light in big pulls and keep working in dungeons and raids under Midnight's addon rules. The settings window has a live sample nameplate: click a part to edit it, drag it to move it.

## Getting started

The first time you log in, Plateau asks you to pick a look: Minimal, Blizzard-like, Unit frame, Compact, Flat or Heavy. All six put things in the same places and differ only in the bar, so you can switch without relearning anything. Change any of it later in `/plt`, or type `/plt setup` to see the list again.

## Cast bar

The cast bar colors follow your own interrupt: one color while it is ready, another while it is on cooldown, and separate colors for important and uninterruptible casts. A line on the bar shows where your interrupt comes back. Specs without an interrupt see the ready colors on casts that can be kicked, so healers can call them out. Important casts can glow, and the bar can show the spell icon, a timer, who the cast is aimed at and who interrupted it.

## Colors

Color enemies by type (boss, lieutenant, elite, caster, melee, minor), by threat for your role, and with an off-tank color so your co-tank's enemies stand apart. Quest enemies, enemy players and tapped enemies have their own colors, and there are colorblind presets.

## Auras

Your debuffs, crowd control, enemy buffs you can remove, and important auras each have their own place, size and count. Spells can be hidden or allowed per specialization. Warnings mark an enemy that gains an important buff, a big defensive, an enrage or a magic buff you can purge.

## Dungeons and raids

Boss phase lines show where a fight changes phase; this season's bosses are built in and every boss can be edited. Mythic+ enemy forces shows what each enemy is worth. You can also show the enemy's power, your own class resource on your target, an execute tint and health markers.

## Everything else

Target, focus and mouseover highlights; party kicker icons with cooldowns; raid, quest, elite and faction icons; size by enemy type; stacking presets; an adjustable click area; and friendly names with an optional guild or title line in the open world and delves.

## Settings window

Open it with `/plt`, the Plateau button in the game menu, or the minimap button. Parts snap when dropped near the bar, arrow keys nudge the selected part, and you can type an exact position. Changed settings are marked, and Changed only shows just those. Undo, redo and search have keyboard shortcuts, and Help explains every page. The window only loads when you open it.

## Profiles

Each character remembers its profile. Plateau can switch profiles by content (open world, dungeons, raids, delves) or by specialization, after combat ends. Share a profile as a text string; the look shows before you import it.

## Midnight's rules

Since patch 12.0 the game hides some information from addons in combat and in instances. Plateau never reads or compares those values. It passes them to the game's own functions, so cast colors, aura filters and warnings keep working. Settings that depend on hidden values say so in their tooltip.

## Commands

| Command | What it does |
|---|---|
| `/plt` or `/plateau` | Open the settings |
| `/plt setup` | Show the list of looks |
| `/plt whatsnew` | Open What's new |
| `/plt minimap` | Show or hide the minimap button |
| `/plt reset` | Reset the active profile |
| `/plt cvars restore` | Undo every game nameplate setting Plateau changed |
| `/plt debug` | Print details for a bug report |

## Compatibility

Works on Midnight (retail) and WoW Forever from the same download. On WoW Forever, Mythic+ enemy forces is not available. Plateau replaces enemy nameplates, so it should not run with another nameplate addon; if one is loaded, Plateau offers to turn it off. In dungeons, raids and arenas the game draws friendly nameplates itself. Optional: [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) or any media pack adds more textures, borders and fonts.

## Feedback

Found a bug or have an idea? Leave a comment or open an issue on [GitHub](https://github.com/lixard-wow/Plateau/issues), and include the `/plt debug` output and any error text. Translations are welcome on GitHub.
