# Changelog

All notable changes to Plateau Nameplates are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [0.1.0-beta] - Unreleased

The first build. Retail 12.1.0 and 12.1.5, and WoW Forever (`16001`).

### 2026-10-05 Z-Perl look

#### Changed
- **Slim is replaced by a new built-in look, Z-Perl,** styled after Z-Perl unit frames: a glossy bar in a thin grey tooltip border on black, plain shadowed text, percent health centered and colored green, yellow and red as health drops, the raid marker on the top-left corner, a soft yellow glow on your target and a matching cast bar with icon. Players who already have a Slim profile keep it as an ordinary profile.

### 2026-10-05 release hardening

#### Fixed
- **Enemy target name in your color no longer errors in dungeons and raids.** The game hides whether a mob is targeting you there; Plateau now passes that hidden answer straight to the color instead of checking it.
- **Blizzard's own friendly nameplates keep working.** Plateau switched off some events on Blizzard's shared plate frames, so friendly plates drawn by the game slowly lost mouseover highlights and soft-target updates. Plateau now gives those events back whenever the game reuses one of those frames for a plate Plateau doesn't draw.
- **Damaged saved settings no longer break Plateau.** Wrong-type data is repaired at login, each settings upgrade step runs on its own, and if the file still can't be read Plateau starts with its defaults, keeps the old data under 'recovered' and says so in chat.
- **Settings are checked at login and on import:** text alignments must be left, center or right, and every scale stays between 0.1 and 5, so a bad value can't cause errors on every nameplate.
- **A refused import no longer changes your boss phase lines**, imported profile names lose color codes and are cut to 32 letters, and profile strings over 20,000 characters are refused before unpacking.
- **Switching profile before the game knows your character** (WoW Forever) no longer errors.
- **Click-through friendly plates updates when a unit turns hostile** (a duel starting, an NPC turning on you), so the enemy plate can be clicked straight away.
- **A /reload in combat no longer loses your Blizzard settings.** Settings Plateau changes for dungeons and raids are put back only once combat allows it, are restored at logout too, and are only forgotten once the game confirms your value is back.
- Smaller safety fixes: Plateau no longer changes Blizzard's target size setting in combat, frame levels the game hides are left alone, and /plt debug reports a failed realm-marker cleanup or damaged saved settings.

#### Changed
- **Smoother pulls after entering a dungeon:** after any restyle (entering or leaving an instance, a spec change, a setting change), Plateau now re-styles its spare and empty nameplates in the background out of combat, a little each frame, instead of when each one first appears mid-pull.
- **No full restyles in the middle of a fight from background changes:** a pet being resummoned, a level-up, a role change or the spell-name lookup finishing now wait until combat ends. Your own setting changes still apply straight away.
- **Cheaper health color fading:** each health change only re-reads the faded color instead of re-working out the whole color.
- **Less idle work and memory:** the full set of 40 spare nameplates is built once per session, after which only a small buffer is topped up after loading screens; elements that are turned off skip their style pass; the class resource no longer listens to your power while it's off or your class has none; encounters aren't recorded while boss phase lines are off; characters with no automatic switching rules aren't saved; and the settings window's fonts load the first time it opens instead of at every login. /plt debug shows how many plates are built, attached and spare, and how many elements are on.
- Building spare nameplates stays within its time budget per frame, and each aura button is only set up once; /plt debug shows how many were built and how many in combat.
- **Probe log is smaller and private:** it keeps at most 300 entries, never stores names, GUIDs or creature IDs, probe watch turns itself off after 4 hours, and the log is cleared when Plateau updates. The existing log is cleared once.

### 2026-10-05 nameplates attach to the game's own

Plateau's nameplates are now part of the game's nameplates instead of floating in a separate layer above them.

#### Added
- **Lixard Classic highlights in your class color:** the selected menu item, toggles, sliders, section colors and main-button outline use the class color of the character you're on (gold when no class is known).
- **Closer to PKT, less washed out:** PKT's own corner textures (rounder buttons and boxes), Artisan Ledger's fine inner frame line, solid gold slider fills, borderless filled buttons on Workbench, and larger text (labels 13, notes, dropdowns and the side menu 12 to 13).
- **Settings window themes now match PKT's.** Each theme uses PKT's full palette and fonts: its own title font and size (Workbench in capitals), cream section headings, button text and font, a plain title bar (a flat filled header on Workbench), a 1 pixel line under it, PKT's icon button colors, and filled main-action buttons (Reload Now, Next, Confirm, Import profile). Pop-ups and look cards get Artisan Ledger's engraved corner brackets or Workbench's accent stripe. The P icon keeps the brand color.
- **Easier-to-read settings window, matching PKT.** The wood-grain texture behind the Artisan Ledger window is gone, descriptions use the brighter Ledger body color, and the window title and P logo use each theme's own title color (Ledger gold, as in PKT). The brand color still colors the minimap button, game menu button and chat.
- **Warnings for settings that clash.** Notes with an alert icon now appear only when a combination applies: Scale casting nameplates together with Enlarge important casts (both pages), the kick marker not showing on the bigger bar, how much of the bigger bar can be clicked, and stacking bounds that keep cast bar room on every plate.
- **Enlarge important casts** (Cast bar page, off by default, size 1.10 to 2.00): casts the game flags as important get a bigger cast bar drawn in front of every other nameplate. The game hides which casts are important, so Plateau keeps a second, bigger bar ready and the game picks which one shows. The kick marker stays on the normal-size bar.
- **New icon and brand colour.** A calligraphy P (Allura) replaces the gradient P, and Plateau's name is one colour instead of a gradient. Brand colour (gear button > Plateau settings) colours the P and the name on the minimap button, the settings title, the game menu button and chat: Class colour (default), Colour cycle or Random each login. The addon list icon is a white P, since the game can't recolour it.
- **Hide friendly pets in dungeons and raids** (Friendly nameplates page, off by default): inside dungeons and raids, other players' pets, totems and minions lose their nameplates and floating names; your own settings come back when you leave.
- **Stacking bounds: Health bar and cast bar.** Counts the cast bar but not the name, for looks that hide names or put them inside the bar.

#### Changed
- **The four ready-made looks were redesigned as one family:** raid marker and quest icon on top, important buffs above the bar, cast bars without a gap. Big & bold and Compact are the author's own setups; Normal is now a 150 by 14 bar with smooth health and animated target arrows; Slim is an 8 pixel bar with small icons tucked beside it. Existing profiles don't change; Restore built-in on the Profiles page applies the new version.
- **Size, distance scaling, showing, hiding and fading come straight from the game**, so they always match Blizzard's own nameplate settings, with no catch-up delay. Plateau's own sizes (target, focus, casting, mouseover, enemy type and combat) are applied on top.
- **Layering is now one switch, Casting enemies in front.** An enemy that is casting draws over its neighbors, your target stays above casting enemies, and Mouseover in front beats both. Everything else keeps the game's nearest-in-front order. Profiles that had priority-based layering on get the new switch turned on.
- Fade hidden nameplates for: turning it off for a type now makes those plates ignore the game's fading entirely.
- **The short command is now /plt** (was /pl), so it no longer clashes with PilotLight. /plateau still works; /sl was removed for the same reason.

#### Removed
- **Use priority-based layering and the Layering order list** (bosses, target, focus, casting, casters, lieutenants, elites, melee, minor enemies), replaced by Casting enemies in front.
- The background check that copied the game's nameplate size and fade every tenth of a second, and the size Plateau used to learn and remember between sessions.

### 2026-10-03 settings pass

Every settings page was reviewed: controls that do nothing in the current setup are greyed out with the reason on hover, and new options were added under an Extras heading at the bottom of each page.

#### Added
- **Boss phase lines.** Lines on boss health bars at the percentages where a fight changes phase. During a boss fight Plateau reads which encounter it is and uses that boss's percentages. Built-in values for this season come from Season 2 guides; every boss can be edited, bosses you fight are added automatically, any boss can be added by encounter ID, lines can go on bosses only or on every enemy in the fight (Kystia Manaheart's line goes on her pet), and default lines cover other bosses. Profile export and import carry them.
- **Health bar:** smooth health changes, fill direction, health spark with thickness, plain texture tint, background texture, and color by health remaining (fades each enemy's normal color toward a low-health color). Tapped color has its own switch.
- **Health text:** percent first, value / max, missing health and missing percent formats; value decimals, % sign, hide at full health, only on my target, color by health remaining, execute range color.
- **Name:** only on my target, match health bar color, hide while casting; enemy target name color when it's you.
- **Level:** hide in dungeons and raids, boss level text, mark rares, hide trivial levels, and a Next to the name position.
- **Cast bar:** spark color, show spell name, casts empty instead of fill, shield icon on uninterruptible casts, which casts to show, crop icon edges.
- **Enemy power bar:** Bosses and casters, bar texture, border, smooth changes, hide at full power, text format, position, font and outline.
- **Behavior:** mouseover scale, friendly nameplate scale, smooth size changes, dim others only in combat, don't dim friendly plates, keep mouseover at full opacity, mouseover in front, nameplate height offset, click-through friendly plates.
- **States:** pulse glow and border and animate arrows for target and focus, an above-and-below arrow placement, mouseover glow, skip friendly plates on mouseover, out-of-combat cast bar and only in dungeons and raids.
- **Auras (per group):** icon shape (square or wide), cooldown swipe, icon border thickness and color, timer and stack count positions.
- **Icons:** marker-colored plate border, quest objective progress, class resource hide when empty and glow at maximum.
- **Minimap button** (LibDBIcon, draggable, tooltip with the active profile) and, on retail, an entry in the addon list next to the minimap. Both have switches on the Plateau settings page (gear button); `/plt minimap` shows or hides the button.
- **Plateau settings page** behind the gear button in the title bar (not in the sidebar, but searchable): window theme, settings window scale (0.60 to 1.40, applies instantly; dropdown lists scale with it), text and heading fonts for the settings window (the bundled fonts plus any LibSharedMedia font; asks for a reload), settings tooltips, game menu button and minimap buttons. These moved off the Game settings page. Artisan Ledger also rounds text boxes and dropdown checkboxes.
- **Three settings themes** (Plateau settings, gear button): Workbench (flat charcoal, green accent, Barlow), Artisan Ledger (walnut and brass, Cinzel headings) and Lixard Classic (near-black, square, gold). Workbench is the default on retail and Artisan Ledger on WoW Forever; switching asks for a reload. Buttons and dropdowns follow the theme's button colors and corners, and the title bar has icon buttons for settings (opens Plateau settings), minimize and close, like PKT. Fonts are bundled under their open font licences.
- **Rounded settings window and pop-ups** with no drop shadows: the setup walkthrough, other-addon warning, tour callouts, profile dialogs, reload prompt, dropdown lists and search results all use the same rounded corners.
- **Renamed to Plateau**, with a new icon: a gradient P. Commands are /plateau and /plt.
- **Critter and companion names on for new installs**: a brand-new install turns on Blizzard's Show critter and companion names once (undo with right-click or /plt cvars restore), and the setup walkthrough has the switch.
- **Include other players' debuffs** (Your debuffs page, off by default): shows debuffs from other players after your own, like Blizzard's nameplates.
- **Show nameplate-only auras** (each aura page, Extras): choose per group whether auras the game shows only on nameplates appear; the preview shows them as a question-mark icon.
- **Fade hidden nameplates for** (Fading page, under Behind walls): enemies and friendly, enemies only, or friendly only take the game's fading.
- **Where hidden nameplates fade** (Fading page, under Behind walls): separate switches for the open world, dungeons, raids, delves and scenarios, and battlegrounds and arenas decide where Occluded nameplate opacity applies. Elsewhere nameplates behind walls stay fully visible; Plateau switches Blizzard's setting as you change zones and puts your value back.
- **Interrupted text** (Cast bar, Extras): the message on an interrupted cast is its own text, with what it says (Interrupted by Name, Name only, Interrupted), position and offsets, font size, color, class color for the name, and an option to keep the spell name showing beside it.
- **Avenger's Shield counts as an interrupt for Protection paladins.** Kick ready coloring, the kick marker on the cast bar and interrupt range fading use whichever of Rebuke or Avenger's Shield is ready sooner (Avenger's Shield when both are, for its 30 yard reach).
- **Friendly player name size is Blizzard's Nameplate Size.** One setting, shown on the Friendly page and as Nameplate size (Blizzard) on the Size page: moving either moves the other, and it also sizes the friendly plates the game draws in dungeons, raids and arenas. Friendly NPC name size uses the same steps, so the same number gives the same size.
- **Friendly:** hide friendly plates in combat, group member name color, realm names on Plateau's friendly plates; Plateau's friendly plates follow Blizzard's Simplify friendly players and NPCs.
- **Game settings:** always show your target's name, always show names on Blizzard's plates, all auras on the personal resource display, soft target icons and size, debuffs on Blizzard's friendly plates.
- **Look picker** restyled as large accent cards with live previews.
- **Probe:** `/plt debug probe` reports which unit calls the game hides; `/plt debug probe watch` logs every enemy plate, pull and boss encounter (with how Plateau drew each plate) and stays on through reloads until turned off.

#### Changed
- Four built-in looks: Big & bold, Normal (the new default), Slim and Compact.
- Friendly player and NPC name sizes use Blizzard's 1 to 5 Nameplate Size steps.
- The preview shows whatever your settings turn on. Preview-only pickers for the cast, enemy type, threat and badge sit next to Reset this section on their pages. The preview cast plays once.
- Snapping is a small Snap button under Undo and Redo.
- The reload prompt appears above the settings window; the settings window can be dragged partly off screen.

#### Fixed
- Bosses that can't be attacked until the pull now get a nameplate when they become attackable.
- Boss nameplates no longer stay invisible until you click off and back on. New plates spawn at full size and opacity instead of following the game's grow-in, which could leave a plate that appeared as your target at almost zero size.
- The settings window opens on WoW Forever again.
- Aura groups with a manually chosen growth direction could sit on top of the health bar (for example Above with new rows below). Groups now always attach by the edge facing the plate; the growth direction only sets the order icons fill in.
- Settings search ranks results by how well the setting's name matches the whole search, so "enemy target name" lands on the Name page's Enemy target name section instead of loosely related settings.
- Plates hidden behind walls came in at full brightness for a second before fading. New plates now take the game's opacity from the first frame (their size still ignores the game's grow-in).
- New plates could appear far too large for a moment after login or after a UI or nameplate scale change, because the size reference was emptied. Plateau now keeps the last reference (also across sessions) until a new one is measured.
- Tint the plate border by marker never drew in game: the game hides which marker a unit has, so the color lookup always gave up. The border now takes its color from a marker-color sheet using the same hidden marker value the icon uses.
- Settings could be saved to the wrong profile when the game hadn't sent your character's name yet at load (it read as "Unknown", seen on WoW Forever). Plateau now waits for the real name at login, and old "Unknown" entries are removed.
- Auras the game shows only on nameplates were left out of every aura group and buff warning. They are included now, like on Blizzard's own nameplates, so Important auras and the important buff warning work again.
- Blizzard settings that Plateau changed now follow changes made in the game's own menu: Plateau shows the new value and no longer puts its old one back at the next login.
- Realm names show again on Blizzard's friendly plates when Hide the (*) is on.
- Tooltips no longer claim that Plateau's friendly name settings reach the plates the game draws in dungeons and raids.

#### Removed
- The Preview scenarios menu and Reset preview.
- The Plateau and Classic built-in looks (saved profiles with those names are kept).
- Finished debug commands: `/plt debug layers`, `watch`, `front`, `unit` and `names`.

### Added

#### Nameplates
- **Plate driver.** Plateau claims enemy plates, hides Blizzard's own, follows Blizzard's click area, and reuses plates instead of creating new ones. Player pets and friendly plates can be included or left to the game.
- **Health bar.** Textures from Blizzard, flat, striped (leaning left or right) and checkered art, and any LibSharedMedia bar. Border styles: none, pixel, shadow, tooltip, thin tooltip and LibSharedMedia borders, with thickness, color, and the option to draw the border inside the bar.
- **Health text** as percent, value, both, or value with percent in brackets, with decimals, font, size, outline, shadow and placement.
- **Name** above, below, or in any corner of the bar. Long-name handling: show in full, cut with or without an ellipsis, keep the last word, or abbreviate. Class colors for players, a maximum width, and full font control.
- **Level** with difficulty colors, a plus after elite levels, and hiding on enemies at your level.
- **Who the enemy is attacking** on the bar, in the target's class color or your own.
- **Absorb shields** after the health or over the bar, with an overshield glow at the end of the bar and a choice of look, calculated by the game so it works in combat.
- **Execute range** tint and up to two health-percentage lines on the bar.
- **Icons.** Raid target markers, elite, rare and boss icons, a quest icon, all placeable in eleven positions.
- **Quest icon** with the modern campaign, important, legendary and repeatable markers on retail, and the classic mark on Forever.
- **Mythic+ enemy forces** showing how much of the enemy forces bar each enemy is worth (retail).
- **Enemy power bar** on bosses (or every enemy, or your target): energy, rage, mana and other resources drawn from values the game hides, inside the health bar, above it or below it.
- **Class resource** on your target (on by default): combo points, holy power, soul shards (in tenths), chi, arcane charges, essence and runes (dimmed while recharging), with color, size, spacing and placement.

#### Cast bar
- Color that follows your own interrupt: ready, on cooldown, and separate pairs for casts Blizzard flags as important.
- Colors for uninterruptible casts, channels, and a spec with no interrupt.
- A line on the cast bar showing where your interrupt comes back during the cast.
- Glow around important casts, spell icon beside the bar or one tall icon spanning the health and cast bars, spark, and a timer that switches to tenths near the end.
- Who the cast is aimed at, with its own position and size, and who interrupted the cast for a moment afterward, on normal casts and channels, including inside dungeons and raids where the game hides the name from addons (it is shown without being read).
- Spell name alignment (left, center or right) positions the text by anchor point, so it moves as soon as you change it.

#### Colors
- Color by enemy type: bosses, lieutenants, elites (enemies above your level), casters, melee, everything else and minor enemies, each with its own switch and color, and an option to use it only in dungeons, raids and delves.
- Threat colors that update on tank swaps, with separate rules for tanks and damage or healer specs, and an enemy held by another tank in your group counting as fine for tanks, optional colors for enemies changing targets and enemies you are holding, shown on the bar, on its border, or both.
- Quest enemy color.
- **Tank threat on loose enemies.** For tanks, an enemy that is in combat with a group member who is not a tank, and has no threat on you yet, gets the threat color.
- **Separate raid icon placement for friendly plates.** On the Friendly page, "Place the raid icon separately from enemies" gives friendly plates their own position, distance and offsets, so moving the icon there leaves enemy plates alone.
- Class colors for enemy players, your own hostile, neutral and friendly colors, and grey for enemies tagged by someone else.
- Two colorblind palettes: deuteranopia and protanopia, and tritanopia.

#### Auras
- Four groups: your debuffs, crowd control, enemy buffs, and important auras. Each has icon size, count, icons per row, spacing, order, a duration limit, placement (side, grow direction, alignment, offsets) and icon details (time left, stack count, dispel-type border, pandemic tint).
- Enemy buffs show only the ones you can remove by default, or every buff, and can hide boss and permanent buffs.
- Per-specialization spell lists to hide spells or show only some. A spell name matches every spell with that name, so a debuff with a different ID than the spell you cast is still caught.
- Buff warnings for important buffs, big defensives, enrages and magic buffs you can purge, drawn as a border, a texture over the bar and an icon, with a priority list you can reorder when several apply.

#### Target, focus and mouseover
- Your target and focus can have a border, a recolored or brightened bar, arrows in several styles and any color, corner brackets, and a soft glow.
- Mouseover highlight with brightening and a border.
- Nameplates you are not targeting can fade.

#### Sizing and layout
- Size by enemy type, a separate target size (or Blizzard's), and growth while casting.
- An adjustable click area with a live box in the preview, a switch that shows the boxes on real nameplates while you adjust them, and an option to include the cast bar.
- Stacking presets (tight, balanced, spread out), an instant-movement switch, and control over how much room each plate takes.
- Fade for enemies out of your interrupt's range.
- **Combat scale.** Enemies in combat can be bigger or smaller than enemies that are not. The size multiplies the enemy type scale, so a boss stays bigger than trash in both states. Players and friendly plates are not affected.
- **Out-of-combat plates.** Enemies that are not in combat can have their own look: opacity, bar width and height, one flat bar color, and a show list for auras, health text, name, level, the elite, raid and quest icons, Mythic+ forces, the enemy power bar and the enemy target name. Your target, players and friendly plates are never changed.
- **Layering order.** With priority-based layering on, you arrange which plates sit in front where they overlap: bosses, your target, your focus, enemies casting right now, casters, lieutenants, elites, melee and minor enemies, by dragging or with Up and Down. A plate takes the highest rank that applies to it, and plates of the same rank keep the game's own order, nearer over farther. All plates share one strata and are ordered by frame level only. With it off, the game's own order is used. This replaces the separate bring-target-to-front and bring-casting-to-front switches.
- **Target scale applies to enemies only.** A friendly target no longer grows with the game's selected scale.
- A page for Blizzard's nameplate settings, with restore for every setting Plateau changed.

#### Settings window
- A live preview with click to edit and drag to move, snapping that leaves one pixel of space, Shift or a Snap switch for free placement, and click areas for every part including the spell name and timer.
- Nameplate types (Enemy, Enemy player, Friendly, My target, My focus) with per-type overrides, and a window that takes the color of the selected type.
- A Preview scenarios list for sample casts (important, uninterruptible, interrupted, channel, no interrupt ability and more), enemy types, elite icons, threat states, tapped and neutral enemies, enemy players, same-level enemies, out-of-range fade, target and focus, buff warnings, raid marker, quest mob, class resource and more, with a Play button for a sample cast.
- Undo and redo with named history, and search that scrolls the chosen setting to the top.
- **Apply to all plates** for a page or a single setting, and reset at the setting, page and profile level.
- Six ready-made looks shown as live cards: Plateau, Normal, Classic, Slim, Big and bold, Name inside.
- Profiles: the page shows your default and active profile, why an automatic override is active and any switch waiting for combat; create, duplicate, rename, copy settings between, delete (with a warning naming what uses it) and restore built-ins; automatic switching by content and specialization in two columns; export and import with an optional activate-after-import switch. The footer shows the active profile.
- Profile export and import as a text string containing every setting, with an optional name and a choice of whether per-type changes come along.
- A first-time setup walkthrough in six fixed-size steps: look, which plates show, which parts show on a plate (switches that update a larger live preview), colors, interrupts and a short summary. A first-open tour of the window, and a Help page with 44 topics.
- **Friendly pets and minions.** A switch on the Friendly page, off by default, for the pets, totems and minions of friendly players. Follower dungeon companions are not affected.
- Friendly player name shortening is shown only on flavors where players have a surname.
- `/plt debug unit` and `/plt debug names` report how Plateau reads your target and whether enemy names can be shortened. `/plt debug` also counts aura buttons built in combat, and `/plt debug flatten` is a measuring experiment.
- A game menu button just above AddOns (with a switch to hide it), the (*) other-realm marker removed from player names even on plates the game draws, a Name height slider for names-only plates, a gradient name in the addon list, a new addon icon, and a Performance readout (CPU, slow frames, memory) from the game's addon profiler.
- Settings that depend on information the game can hide are marked with a warning icon and a tooltip that says what happens.
- **Settings regrouped by topic.** A Behavior group holds Size (every scale, plus Blizzard's size and size by distance), Fading (range fading, plates you are not targeting, behind walls, by distance), Layering and stacking (layering order, stacking, spacing, movement) and Clickable area. Target, Focus, Mouseover and a new Out of combat page sit under States. The options for the nameplates the game draws itself moved to Friendly, and Game settings keeps names over heads, which nameplates show and keeping plates on screen. No setting changed; only where it is shown.
- Sidebar pages in a fixed, task-based order. Cast bar colors live on Cast bar, Enemy target name on Name, and Health threshold markers have their own section on Health bar.
- Controls that cannot affect the result (a border size with the border off, overlay strength with no overlay, custom target scale while Blizzard scaling is on) are dimmed with an explanation instead of hidden.
- Game settings keeps everyday options up front and folds the rest into collapsed sections that search opens for you; performance numbers moved to Diagnostics on the Help page (the title bar CPU readout opens it), and Plateau preferences sit apart from Blizzard settings.
- Aura text (all groups) is one shared section on Your debuffs, linked from the other aura pages.
- A compact minimized bar showing the active profile (with automatic overrides and pending switches in its tooltip), a Restore button and a small close button. It opens with its top-right corner exactly where the window's top-right corner was, stays on screen, and the full window returns to its own position and size, and an optional second line shows recent CPU time per frame and memory (off by default, refreshed every 2 seconds only while shown).
- The preview shows only the scenarios you tick (Reset preview clears them) and marks the button amber when one is switched off in your settings, outlines what you are editing, and says when a page only applies to in-world nameplates.

#### Under the hood
- Plateau never compares or does math on hidden values. Cast colors, aura filters and warnings are decided by the game.
- No per-plate update loops, and no table creation while updating plates.
- Events that did nothing by default were quieted: execute-range updates run only with the highlight on, threat updates are skipped when your threat status has not changed, and adding a plate no longer repeats the target and focus update on the plates already shown.
- Saved settings store only differences from the defaults, with versioned migrations and validation on import.
- A Lua 5.1 test suite for the settings code and a luacheck configuration for the WoW environment.

### Removed during development
- Aura sound cues: the game supports them only for auras on the player, so they do not fit a nameplate addon.
- `/plt get`, `/plt set`, `/plt status` and drag debugging: developer tools. `/plt debug` covers bug reports.

### Known limitations
- Friendly plates are locked in dungeons, raids and arenas, so Blizzard draws them there.
- Enemy name shortening does nothing inside dungeons, where the game hides enemy names from addons.
- Threat can be hidden in some fights, and a plate then keeps its normal color.
- Raids, PvP, arenas and WoW Forever are still being tested.
- Fonts are Latin-only, and the interface is English only.
