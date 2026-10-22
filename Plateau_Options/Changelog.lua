local _, ns = ...

ns.changelog = {
    {
        version = "0.1.2",
        sections = {
            {
                title = "Changed",
                items = {
                    "You can drag the settings and setup windows from any empty spot, not just the title bar.",
                    "The target glow pulse now brightens and dims the whole glow, not just its corners.",
                },
            },
        },
    },
    {
        version = "0.1.1",
        sections = {
            {
                title = "New",
                items = {
                    "The target glow can wrap the cast bar while your target casts. Turn it off with Glow around the cast bar under Target.",
                    "A new character's first login opens setup, where you can pick a profile you already have, paste a profile string, or start from a ready-made look. Setup now offers these for every character.",
                },
            },
            {
                title = "Changed",
                items = {
                    "Plateau styles friendly nameplates by default, so friendly NPCs show names instead of Blizzard's health bars in the open world.",
                    "Profile strings now carry the Blizzard nameplate settings you change in Plateau, such as stacking, spacing and max distance. They're applied when you activate the imported profile.",
                },
            },
        },
    },
    {
        version = "0.1.0",
        sections = {
            {
                items = {
                    "First release.",
                },
            },
            {
                title = "Nameplates",
                items = {
                    "Enemy nameplates drawn by Plateau, attached to the game's own nameplates, with friendly names for players and NPCs in the open world and delves.",
                    "Health bar with your choice of texture, border and fill direction, health text, names, levels, absorb shields and execute range.",
                    "Cast bar colored by your own interrupt: ready, on cooldown, important and uninterruptible casts each get their own colors, with a marker for when your interrupt comes back, a glow on important casts, the cast's target and who interrupted it.",
                    "Colors by enemy type, threat for your role, an off-tank color, quest enemies, class colors for players and colorblind palettes.",
                    "Four aura groups (your debuffs, crowd control, enemy buffs, important auras) with per-spec spell lists.",
                    "Buff warnings for important buffs, big defensives, enrages and purgeable magic.",
                    "Boss phase lines for this season's bosses, Mythic+ enemy forces, an enemy power bar and your class resource on your target.",
                    "Target, focus and mouseover highlights, plus sizing, stacking, click area and fading options.",
                },
            },
            {
                title = "Settings window",
                items = {
                    "Live preview: click any part to jump to its settings, or drag it to move it.",
                    "Separate settings for enemy players, friendly units, your target and your focus, each following the enemy settings until you change them.",
                    "Undo and redo, search, built-in help and a short tour.",
                    "Six ready-made looks to start from, and five window themes: Workbench, Artisan's Ledger, Horde, Alliance and Slate.",
                    "Profiles that switch automatically by content or specialization, and profile sharing by text string.",
                    "Blizzard's nameplate settings gathered in one place, with a one-step restore.",
                },
            },
            {
                title = "Commands",
                items = {
                    "`/plt` or `/plateau` opens the settings. `/plt setup`, `/plt minimap`, `/plt reset`, `/plt cvars restore` and `/plt debug` are also available.",
                },
            },
        },
    },
}
