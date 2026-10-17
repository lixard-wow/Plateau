# Plateau Nameplates

**Fast, readable enemy nameplates for Midnight and WoW Forever — and a settings window where you see every change happen live.**

Plateau replaces Blizzard's enemy nameplates with its own, on retail and WoW Forever. It stays light in big pulls, keeps working in dungeons and raids under Midnight's addon rules, and lets you click any part of a live sample plate to edit it or drag it where you want it.

---

## Pick a Look and Go

The first time you log in, Plateau asks you to pick one of six ready-made looks, shown as live cards:

- **Minimal** (the default)
- **Familiar layout**
- **Classic unit frames**
- **Compact**
- **Clean and flat**
- **Bold and crisp**

Use one as it is, or make it your own. You can switch looks any time with `/plt setup`, or restore any built-in look on the Profiles page.

---

## The Cast Bar

- **Colors that follow your own interrupt** — one color while it's ready, another while it's on cooldown, and separate colors for casts Blizzard flags as important and for casts that can't be interrupted
- **Interrupt marker** — a line on the cast bar showing where your interrupt comes back during the cast
- **Healers too** — a spec with no interrupt sees the "ready" colors on interruptible casts, so you can call them out
- **Glow around important casts**, a spell icon (beside the bar, or one tall icon across the health and cast bars), and a timer that switches to tenths near the end
- **Who it's aimed at** — on its own line or right after the spell name, centered together if you like
- **Who interrupted it**, and a quick flash when a cast is interrupted
- **Join the cast bar to the health bar** inside one shared border

---

## Colors That Mean Something

- **By enemy type** — bosses, lieutenants, elites, casters, melee and minor enemies, each with its own color
- **Threat that fits your role** — as a tank, enemies that aren't on you change color; as damage or healer, enemies that are on you do
- **Off-tank color** — enemies your co-tank is holding get their own color, and a swap between tanks never turns a plate red
- **Quest enemies**, **enemy players** in class colors, and **tapped enemies** in grey
- **Colorblind palettes** for deuteranopia, protanopia and tritanopia

---

## Auras

Four groups, each with its own size, count, order and placement:

- **My debuffs** — your damage-over-time effects, soonest to expire first, with an optional pandemic tint
- **Crowd control** — stuns, incapacitates, roots and more, from anyone
- **Enemy buffs** — by default only the ones you can remove (purge, spellsteal, soothe)
- **Important auras** — buffs Blizzard flags as important

Hide or allow spells per specialization by name or ID.

**Buff warnings** mark a plate with a colored border, a texture and the buff's icon when an enemy gains an important buff, a big defensive, an enrage, or a magic buff you can purge — in the priority order you choose.

---

## Boss and Dungeon Tools

- **Boss phase lines** — marks on boss health bars where the fight changes phase. This season's bosses are built in, every boss can be edited, and new bosses are added as you fight them.
- **Execute range** — tint the bar below a percentage you choose, plus up to two marker lines
- **Mythic+ enemy forces** — how much of the forces bar each enemy is worth
- **Enemy power bar** — watch a boss's energy without unit frames
- **Your class resource** — combo points, holy power, soul shards, chi, arcane charges, essence or runes on your target's plate

---

## Target, Focus and Everything Else

- **Target and focus highlights** — borders, arrows, corner brackets, glows, a brighter bar and their own size
- **Mouseover highlight**, and fading for plates you're not targeting or that are out of interrupt range
- **Health text** as percent, value or both; **names** in any position with long-name handling; **level** with difficulty colors
- **Absorb shields** with an overshield glow
- **Icons** — raid markers, elite / rare / boss, quest markers, and Horde or Alliance crests on players
- **Friendly names** — friendly players and NPCs can show just their name, with an optional guild or title line
- **Sizing and stacking** — size by enemy type, grow while casting, bring your target to the front, adjust the click area, and pick a stacking preset

---

## The Settings Window

Open it with `/plt`, the **Plateau Nameplates** button in the game menu, or the minimap button.

- **Live preview** — click any part of the sample plate to jump to its settings, or drag it to move it
- **Nameplate types** — Enemy, Enemy player, Friendly, My target and My focus. Enemy is the base; the others only differ where you change them.
- **Undo and redo** with a named history of every change
- **Search** every setting by name or description
- **Built-in help** — more than 40 topics covering every page and common how-tos
- **Five window themes** — Workbench, Artisan's Ledger, Horde, Alliance and Slate
- **Blizzard's nameplate settings** gathered in one place. Plateau remembers what they were and can put them back.

The settings window is a separate part that only loads when you open it, so it costs nothing while you play.

---

## Profiles

- One profile holds every setting; each character remembers which one it uses
- **Switch automatically** by content (open world, dungeons, raids, delves) or by specialization
- **Share** a profile as a text string and import it on another computer

---

## Built for Midnight

Since patch 12.0, the game hides some information from addons during combat and in instances. Plateau is built around that:

- It never reads or compares hidden values — it hands them straight to the game, which is why cast colors, aura filters and buff warnings keep working in dungeons and raids
- Settings that depend on hidden information show a warning icon explaining what happens
- Nothing runs on each nameplate every frame, and `/plt debug` shows real performance numbers from the game's own profiler

---

## Commands

| Command | What it does |
|---|---|
| `/plt` or `/plateau` | Open the settings |
| `/plt setup` | Open the look picker |
| `/plt minimap` | Show or hide the minimap button |
| `/plt reset` | Reset the active profile |
| `/plt cvars restore` | Undo every game nameplate setting Plateau changed |
| `/plt debug` | Print version, memory and performance info (include it in bug reports) |

---

## Compatibility

- Works with World of Warcraft: Midnight (retail) and WoW Forever, from the same download
- On WoW Forever, Mythic+ enemy forces isn't available, and threat percent (off by default) always has a number to show, because Forever doesn't hide it
- Plateau replaces enemy nameplates, so it shouldn't run alongside another nameplate addon. If one is loaded, Plateau offers to turn it off.
- **Optional:** [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) or any media pack adds more bar textures, borders and fonts to the pickers
- In dungeons, raids and arenas the game draws friendly nameplates itself, so friendly names only apply in the open world and delves

---

## Feedback and Translations

Found a bug or have an idea? Leave a comment or open an issue on [GitHub](https://github.com/lixard-wow/Plateau/issues). Please include the `/plt debug` output and any error text.

Plateau is in English, and every line can be translated. Translations are welcome on GitHub, and translators are credited.
