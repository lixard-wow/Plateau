local _, ns = ...

ns.helpTopics = {
    {
        category = "Getting started",
        title = "How Plateau works",
        keywords = "overview basics start intro what is minimize profile",
        text = "Plateau replaces the way enemy nameplates look: the health bar, name, cast bar, auras and icons. Everything is drawn by Plateau, but the game still decides what is shown, so it keeps working in dungeons and raids.\n\nThis window has three parts. The preview at the top shows a sample nameplate that updates as you change things. The menu on the left lists a page for each part of the nameplate, grouped by what they do. The page on the right holds that part's settings.\n\nEvery change saves right away. There is no Apply or Save button. Settings live in a profile: each character has a default profile, and the active profile is the one you are editing. Minimize shrinks this window to a small bar that shows the active profile.",
    },
    {
        category = "Getting started",
        title = "The preview",
        keywords = "preview sample situations play scenarios cast enemy threat badge",
        text = "The preview at the top of the window is a sample enemy nameplate that updates as you change settings. The part you are editing is outlined.\n\nThe preview shows what your settings turn on: raid icons, quest icons, auras, absorbs, the power bar and more appear when they are enabled and disappear when they are not. The Target, Focus and Mouseover pages show the sample in that state, and Buff warnings shows its warnings.\n\nA few pages have a Preview button next to Reset this section for things the sample can't tell from your settings: on the Cast bar page it picks the cast the preview plays, on the Health bar page it picks the sample's enemy type and threat, and on the Elite icon page it picks the badge. They only change the preview, are never saved, and go back to their default when you leave the page.\n\nPages that only matter in the world, like the Behavior pages and Game settings, say so under the preview.",
    },
    {
        category = "Getting started",
        title = "Editing on the preview: click and drag",
        keywords = "drag move click position snap shift free place reposition",
        text = "Click any part of the sample nameplate to jump to its settings: the health bar, name, health text, cast bar, icons or a whole aura group. The page opens, the setting you clicked flashes, and the part you are editing is outlined on the preview.\n\nDrag a part to move it. It snaps to the spots that make sense for that part and shows where it will land, leaving a 2 pixel space so pieces never touch. Hold Shift while dragging to place it anywhere you like. The arrow keys nudge a selected part.\n\nThe Snap button under Undo and Redo turns snapping On or Off. Turn it off if you want to place things exactly where you drop them.\n\nMoving a part changes the same Position, Horizontal offset and Vertical offset settings you find on its page, so you can fine-tune with the sliders afterward.",
    },
    {
        category = "Getting started",
        title = "Looks: ready-made starting points",
        keywords = "looks cards presets layouts styles normal slim big bold compact name inside setup",
        text = "The first-time setup walkthrough shows a card for each of the four ready-made looks (Big & bold, Normal, Slim and Compact), each with a small live nameplate. Hover a card to read everything it changes. Press Use this look to switch your whole profile to it, which you can then edit and keep.\n\nTo see the cards again later, type /plt setup to run the walkthrough again, or use Restore built-in on the Profiles page to put any look back to how it shipped.",
    },
    {
        category = "Getting started",
        title = "Undo and redo",
        keywords = "undo redo history revert mistake back",
        text = "Undo and Redo are at the top right of the preview. Every change you make is remembered, and the list names each one, for example Height, Moved Raid target icon or Look: Slim.\n\nClick Undo to step back one change. Open the list beside it to jump back several changes at once. Redo brings back what you undid, until you make a new change.\n\nUndo only tracks what you do while this window or the setup is open. It keeps the last 20 changes, and it also covers the game nameplate settings on the Game settings page. Switching profiles clears the list.",
    },
    {
        category = "Getting started",
        title = "The minimized bar",
        keywords = "minimize restore bar small compact profile performance close hide",
        text = "Minimize turns this window into a small bar with the Plateau icon and your active profile. The bar's top-right corner stays where the window's was. Click the icon, the name or Restore to bring the full window back exactly as it was. The x hides the settings; it never turns Plateau off.\n\nClick the profile name on the bar to pick a different profile without restoring the window. Hover the profile to see the default profile, why an automatic override is active, and any switch waiting for combat to end. Drag the bar anywhere else to move it.",
    },
    {
        category = "Getting started",
        title = "Dimmed settings and collapsed sections",
        keywords = "dimmed disabled greyed collapsed section advanced expand hidden",
        text = "A setting that cannot change anything right now, such as a border thickness while the border is off, is dimmed instead of hidden. Hover it to see what to switch on. Your saved value is kept and the setting works again as soon as you switch that on.\n\nSome pages fold advanced settings into sections that start collapsed, such as the advanced parts of Game settings and Diagnostics on Help. Click a heading to open it. Search opens the right section for you.",
    },
    {
        category = "Getting started",
        title = "Searching settings and help",
        keywords = "search find lookup where",
        text = "The search box at the top of the window finds any setting by its name or by words in its description. Pick a result to jump to it, even when it sits inside a collapsed section, which opens for you. The setting flashes so you can see it.\n\nWhen you are on the Help page, the same box searches only the help topics instead, so you get help text and not settings. Switch to any other page and it searches settings again.",
    },
    {
        category = "Getting started",
        title = "Resetting settings",
        keywords = "reset default restore revert clear",
        text = "There are three levels of reset. Right-click a setting to reset just that one to its default. Reset this section, at the bottom of the window, resets the whole page you are on. Reset everything resets every setting in the current profile. Each of the last two asks you to click again to confirm.\n\nIf you only want to undo a recent mistake, Undo is gentler than a reset.",
    },
    {
        category = "Getting started",
        title = "Limited settings in dungeons and raids",
        keywords = "limited instance dungeon raid restricted hidden secret warning icon",
        text = "In some dungeon, raid and PvP content the game hides information from addons on purpose, for example threat, who a unit is, or friendly nameplates. A setting marked with a warning icon depends on information the game can hide. Hover it to read what happens.\n\nWhen the game hides something, Plateau never guesses. Plates keep their normal colors, and the parts the game draws itself, like friendly nameplates in instances, stay as Blizzard draws them.\n\nMost of Plateau is built so the game does the checking. Cast colors, aura filters and buff warnings work in instances for that reason.",
    },
    {
        category = "Profiles",
        title = "Profiles",
        keywords = "profile switch manage character create duplicate rename copy delete default active override",
        text = "A profile holds your nameplate look and your aura spell lists. Each character has a default profile, and any number of characters can share one. The active profile is the one every page edits; it is the default unless an automatic rule has taken over.\n\nThe button at the bottom left shows the active profile. Click it to switch; the profile you pick also becomes your default. Pick Manage profiles at the bottom of the list to open the Profiles page. There you can create a new profile, duplicate the active one, rename a profile, copy settings from another profile into the active one, delete a profile, or restore a built-in one.\n\nThe Blizzard nameplate settings on Game settings are saved once and shared by every profile and character. Use Blizzard nameplate sizing and Stacking bounds are the exceptions: they belong to the profile.",
    },
    {
        category = "Profiles",
        title = "Switching profiles automatically",
        keywords = "auto automatic switch content spec specialization dungeon raid delve open world",
        text = "On the Profiles page, Switch automatically lets a profile take over in certain content: open world, dungeons, raids, delves and scenarios, arenas and battlegrounds. You can also pick a profile per specialization. Choose No override to leave a rule unused.\n\nContent-specific profiles take priority over specialization profiles. If neither is assigned, your default profile is used. Automatic switches wait until combat ends, and they never change your default profile, so leaving the content brings it back. The top of the page shows which profile is active and why.",
    },
    {
        category = "Profiles",
        title = "Sharing a profile",
        keywords = "share export import string copy paste friend backup",
        text = "To share the active profile, open Profiles, click Export active profile, click the string that appears, press Ctrl+A and then Ctrl+C to copy it. It holds the full look and the aura spell lists, so it looks the same on another computer. It does not hold your default profile, automatic rules, Game settings or Plateau settings.\n\nTo import one, paste the text into the import box, optionally type a profile name, and click Import profile. The string is checked first and saved as a new profile; an empty name becomes Imported. Turn on Activate after import to switch to it at once (or when combat ends). Imports never replace an existing profile, and a refused string changes nothing.",
    },
    {
        category = "Pages",
        title = "Behavior pages",
        keywords = "behavior size scale fading fade opacity occluded hidden walls line of sight range layering stacking stack overlap order click area clickable padding offset distance",
        text = "The Behavior group in the left menu has four pages.\n\nSize holds every scale: Scale by enemy type gives bosses, lieutenants, elites, casters, melee enemies and minor enemies their own size, where 1.00 is normal. Target, Focus and Casting scale grow those plates. A plate uses the biggest scale that applies; target, focus and casting scales never stack. Blizzard's nameplate size and Size by distance are Blizzard's own settings: Use Blizzard nameplate sizing for enemies lets Blizzard's Nameplate Size slider resize enemy plates too, while friendly plates always follow it.\n\nFading holds every way a plate can fade: Range fading for enemies your interrupt cannot reach, Plates you are not targeting while you have a target, Behind walls, By distance, and whether disappearing plates fade out. Under Behind walls, switches below the opacity pick where it applies: the open world, dungeons, raids, delves and scenarios, and battlegrounds and arenas each have their own switch.\n\nLayering and stacking decides which plate is in front where they overlap, and how the game spreads them apart. Use priority-based layering and the Layering order list under it rank bosses, your target, your focus, enemies casting right now, casters, lieutenants, elites, melee and minor enemies; plates of the same rank keep the game's order, nearer over farther. Stacking holds the spacing presets, the stacking switches and Show stacking boxes, which draws the area the game keeps apart. Stacking bounds and spacing decide how much of each plate counts, and Movement holds Instant movement and how fast plates slide.\n\nClickable area has Show clickable areas, which draws the click box on the preview and on real nameplates until you close the window, plus padding and offset sliders and Include cast bar in clickable area.\n\nThese settings affect nameplates in the world; the preview always shows normal size.",
    },
    {
        category = "Pages",
        title = "Out of combat page",
        keywords = "out of combat idle combat scale opacity hide show",
        text = "Out of combat, under States, gives enemies that are not fighting their own look so the ones in combat stand out.\n\nCombat scale (Scale by combat state) has one size for enemies in combat with anyone and one for enemies that are not. It multiplies the enemy type scale from the Size page, so bosses stay bigger than trash either way.\n\nCustomize out-of-combat plates makes them more see-through, narrower or shorter, or one flat bar color, and Show when out of combat picks which of auras, health text, name, level and the icons they keep. It all switches back the moment the enemy enters combat. Your target, players and friendly plates are never changed.",
    },
    {
        category = "Pages",
        title = "Health bar page",
        keywords = "health bar width height texture overlay pattern checkers lines border color absorb absorbs execute threshold marker",
        text = "Size sets the width and height of the bar. Bar picks the texture, an optional Plateau overlay pattern (checkers or diagonal lines leaning either way) laid on top of it, the background color, and the border color, style and thickness. Picking a border color while the style is No border turns on a thin border. Draw border inside puts it on the bar's inner edge instead of around it. Your target and focus can have their own texture and overlay on their pages.\n\nAbsorbs shows shields on the bar. Absorb position picks whether the shield is added after the health or drawn over the bar from the right edge. Show absorb overflow glow shows a glow at the end of the bar when a shield is bigger than the room left, and Absorb texture changes how the shield is drawn.\n\nThe execute indicator colors any enemy's bar while its health is below the threshold you choose, for every class and spec. Health threshold markers draws up to two marker lines on the bar, for example at 20% and 35%, with their own thickness; they don't change where the execute color starts.",
    },
    {
        category = "Pages",
        title = "Health bar colors",
        keywords = "colors color threat class type boss caster elite melee reaction interrupt hostile neutral friendly tapped quest colorblind preset",
        text = "The colors are on the Health bar page, below Execute. They are checked in priority order, not simply top to bottom: target or focus overrides beat everything, then Tapped, then Threat (if enabled), then Quest enemies (if enabled) - which overrides enemy type and reaction colors even though its swatch is on the Quest icon page - then enemy type or class color, then Reaction as the fallback.\n\nTapped enemies sets the color of enemies tapped by another player.\n\nThreat colors an enemy when the wrong player has aggro. If you are a tank, an enemy held by another tank in your group counts as fine, so a tank swap between other tanks does not turn it red. Threat transition and Secure threat color add more cases. Threat color display picks the health bar, its border, or both, so you can keep bar colors by enemy type and let only the outline warn you. The game can hide threat in some fights, and the plate keeps its normal color then.\n\nEnemy players can use class colors. Enemy types colors bosses, lieutenants (elites with more health than usual for their level, or two or more levels above you), elites, casters (enemies that use mana, the ones that can be interrupted), melee and minor enemies, each with its own on or off switch and color. Only in dungeons, raids, and delves keeps type colors out of the open world. Elites means enemies above your level. Minor enemies is also the fallback for any normal enemy that doesn't fit the other rows.\n\nThe cast bar colors are on the Cast bar page.\n\nQuest enemies can color enemies that count toward a quest you have, in a color you pick. It overrides their type or reaction color, but threat, tapped, and your target and focus colors still win. Reaction colors lets you pick your own hostile, neutral and friendly colors.\n\nThe Colorblind presets buttons at the top of the page set a full palette; click a preset twice to apply it.",
    },
    {
        category = "Pages",
        title = "Friendly nameplates page",
        keywords = "friendly nameplates names only npc player instance size dungeon raid",
        text = "Style friendly nameplates with Plateau decides whether friendly players and NPCs use Plateau's look. In dungeons, raids and arenas the game locks friendly nameplates, so Blizzard draws them there and these settings do not apply. The one exception is size: Friendly player name size is Blizzard's own Nameplate Size, the same setting as Nameplate size (Blizzard) on the Size page, so it sizes friendly players there too.\n\nNames only shows just a name with no bar, with separate colors and sizes for players and NPCs. Name height moves the name up or down if it floats too far above the head. Hide the (*) after other realms' player names removes the marker the game adds, even on plates the game draws in dungeons; it takes effect after a /reload. Which friendly NPC names float over heads is on the Game settings page, under Names over heads.",
    },
    {
        category = "Pages",
        title = "Health text page",
        keywords = "health text percentage value number format position horizontal vertical offset who enemy attacking target",
        text = "Show health text turns numbers on the bar on or off. Health format picks percentage, value, both, or value with percentage in brackets. Percentage decimal places sets how many decimals the percentage has in any format that includes one; the plain value format has none. Position, Horizontal offset and Vertical offset place it on the health bar, and Text color sets its color. The Font settings below change its font, size and outline.\n\nWho the enemy is targeting is set on the Name page under Enemy target name.",
    },
    {
        category = "Pages",
        title = "Name page",
        keywords = "name text font long names width class color position align",
        text = "Show names turns names on or off. Text color and Use class colors for player names set the color. Position puts the name above, below, or in one of the corners inside the bar. Text alignment sets left, center or right. Vertical offset moves the name up or down.\n\nShorten names shows the full name, the first or last word, or initials. Long name handling decides what happens when the name is still too wide: leave it or cut it at the end or start. Maximum name width sets where it is cut, and 0 means the width of the plate. Font settings are below.\n\nEnemy target name shows who the enemy is currently targeting, separate from the Cast bar page's cast target. Use class colors colors it by class when available, falling back to the swatch beside it otherwise, with its own position and font.",
    },
    {
        category = "Pages",
        title = "Level page",
        keywords = "level number difficulty elite plus",
        text = "Show level puts the enemy's level on the plate. Color by difficulty colors it like the game does, red for hard and grey for easy, and otherwise it uses the color you pick. Show + for elites marks elites and rare elites. Hide level for same-level non-elites keeps the plate clean when the level is the same as yours. Position, offsets and font are below.",
    },
    {
        category = "Pages",
        title = "Cast bar page",
        keywords = "cast bar spell icon interrupt important glow highlight interrupted who time target marker cooldown spacing background",
        text = "Size and spacing turns cast bars on and sets the width (0 means match the health bar), height and health bar spacing. Bar covers the texture, colors, background, border and an optional cast bar spark.\n\nSpell icon shows the spell's icon. Extend icon across both bars makes one large icon that spans both bars.\n\nInterrupts can show an interrupt cooldown marker on the cast bar when your interrupt will be ready again, so you know whether to wait.\n\nImportant casts get a highlight glow. The game flags which casts are important, so Plateau does not need to know the spell. On interrupted casts, Show interrupter name shows the name for a few seconds. It works for normal casts and channels, including in dungeons and raids.\n\nText sets where the spell name sits across the bar, shows the remaining cast time, switches to tenths below a limit you set, and shows the cast target. Interrupted text, under Extras, styles the message on an interrupted cast on its own: what it says (Interrupted by and the name, the name only, or Interrupted), its position and offsets, font size and color, class color for the name, and whether the spell name stays visible beside it. Drag that name on the preview to move it, or set its position and offsets.\n\nCast bar colors sets the cast bar colors: ready, on cooldown, important casts, uninterruptible, and the colors used when you have no interrupt ability to track.",
    },
    {
        category = "Pages",
        title = "Buff warnings page",
        keywords = "buff warnings enrage important major defensive dispellable magic purge dispel border overlay texture warning priority icon",
        text = "This marks the nameplate itself when the enemy gains a buff you should react to. Buff icons are on Enemy buffs and Important auras. There are four warnings: Important buff, Major defensive buff, Enrage and Dispellable Magic buff. Each has its own on and off switch.\n\nThe warning can be a colored border, a health bar overlay, or both. Border thickness of 0 means no border. When an enemy has several at once, the one at the top of Warning priority is drawn over the others. It starts as Important buff, Major defensive buff, Enrage, then Dispellable Magic buff, and you can move each one up or down.\n\nBlizzard classifies the enemy's buffs, so this works in dungeons and raids. Only warn for buffs you can remove hides the Enrage and Dispellable Magic warnings while you know no spell that removes them. Appearance changes made during combat apply after combat ends.",
    },
    {
        category = "Pages",
        title = "Your debuffs page",
        keywords = "my debuffs your debuffs dots auras own player icons",
        text = "Your damage-over-time effects and other debuffs on enemies.\n\nSize and amount: Icon size, Maximum icons, Icons per row, Icon spacing, and the Sort order. Maximum aura duration hides auras whose total duration is longer than that, permanent ones included, and 0 turns it off.\n\nPlacement picks the Position, which Growth direction icons use, and the Alignment: left, center or right. Horizontal and vertical offsets fine-tune it.\n\nWhich spells has two lists per specialization. Hidden spells hides the ones you list, and Allowed spells shows nothing else. Type spell names or IDs separated by commas and press Enter. A name matches every spell with that name.\n\nOn each icon you can show remaining time, stack count, a border colored by dispel type, and a tint while an effect can be refreshed. Aura text (all groups), further down this page, sets the font, outline, shadow and tooltips for every aura group. The other aura pages link to it.",
    },
    {
        category = "Pages",
        title = "Crowd control page",
        keywords = "crowd control cc stun root incapacitate auras",
        text = "Crowd control effects on enemies, including stuns, incapacitate effects and roots, regardless of who applied them. It has the same options as Your debuffs: size, amount, sort order, placement, spell lists and icon details. In dungeons and raids, Blizzard decides which auras land in the group. Plateau sets how they look and where they go. Aura text (all groups) is on the Your debuffs page and linked from here.",
    },
    {
        category = "Pages",
        title = "Enemy buffs page",
        keywords = "enemy buffs purge spellsteal soothe enrage dispel",
        text = "Buffs on enemies. By default only removable buffs are shown: Magic buffs that can be purged or stolen, and enrages. Each has its own switch.\n\nShow all buffs lists every other buff too, still subject to the other filters and limits. Hide boss auras hides auras the game flags as boss auras, and Hide permanent buffs hides buffs with no end time. The other options are the same as Your debuffs: size, amount, sort order, placement and icon details. A buff the game flags as important shows under Important auras instead of here.",
    },
    {
        category = "Pages",
        title = "Important auras page",
        keywords = "important auras flagged",
        text = "Buffs the game flags as important on an enemy, except ones you cast. This group is disabled by default. Turn it on to see them as icons, with the same size, placement and icon options as the other aura groups. It is a separate group from Enemy buffs: a buff shows in one or the other. Buff warnings can also mark the same buffs on the nameplate.",
    },
    {
        category = "Pages",
        title = "Target, Focus and Mouseover pages",
        keywords = "highlight target focus mouseover arrows brackets glow border recolor opacity",
        text = "Target, Focus, Mouseover and Out of combat each have their own page under States in the left menu.\n\nYour target can have a colored border, a recolored health bar, its own bar texture and overlay pattern, a brighter bar, arrows, corner brackets and a soft glow. Arrows and brackets take any color you choose, and have styles, sizes and spacing from the nameplate. Fading the other plates while you have a target is on the Fading page.\n\nYour focus has the same choices. When a unit is both your target and focus, Target settings take priority.\n\nMouseover highlights the plate under your cursor with a brighter bar and a border.",
    },
    {
        category = "Pages",
        title = "Raid target icon page",
        keywords = "raid marker icon skull star",
        text = "Show raid target icons shows the raid target markers already assigned to units. It does not assign markers or show ground markers. Icon size sets how big. To place it, drag the icon on the preview.",
    },
    {
        category = "Pages",
        title = "Quest icon page",
        keywords = "quest icon objective",
        text = "Marks enemies that count toward your active quest objectives. The game decides which enemies count. Show quest icon turns it on, Icon style changes only how it looks (there are many of Blizzard's own quest icons to choose from), and Icon size sets how big it is.",
    },
    {
        category = "Pages",
        title = "Mythic+ enemy forces page",
        keywords = "mythic plus mob percent mob % enemy forces percent count dungeon m+ enemy forces",
        text = "Shows how much of the Mythic+ enemy forces bar each enemy is worth. It only appears during a Mythic+ run, and only on enemies. Display format picks how the number is written, and Text color sets its color. It shows the enemy's contribution to the required total, not your group's progress.",
    },
    {
        category = "Pages",
        title = "Enemy power bar page",
        keywords = "enemy power bar boss energy rage mana raid encounter unit frames resource percentage position opacity color",
        text = "A thin bar showing an enemy's power: energy, rage, mana or another resource. It is meant for watching a boss's energy in a raid without a boss unit frame.\n\nThe game hides the exact numbers from addons, but Plateau can still fill a bar and show a percentage from them. Enemies with no power of that kind, such as a boss with no energy, simply get no bar, the same way you'd see in Blizzard's own frames. Power information may be unavailable for some enemies or encounters.\n\nShow it on picks bosses only, every enemy, or just your target - bosses use the same enemy types as the Health bar colors and Size. Bar position puts it inside the bottom edge of the health bar, above it, or below it. When it is below, the cast bar moves down to make room, and moves back when the enemy has no bar. Height, width, offsets and opacity place it (opacity covers the background and percentage text too, not just the fill). It uses the power type's usual color, or your own, and can show its percentage as text when the game provides one.",
    },
    {
        category = "Pages",
        title = "Class resource page",
        keywords = "class resource combo points holy power soul shards chi arcane charges essence runes pips",
        text = "Shows your own class resource on your target's nameplate: combo points for rogues and druids, holy power, soul shards, chi, arcane charges, essence, or runes for death knights. Classes without one show nothing.\n\nIt is on by default and does nothing for classes without a resource. Show class resource on target turns it off. Use class color or pick a color, and set the Empty segment color for unfilled segments. Segment width, height and spacing change the segments, and Position, distance and offsets place the row on the nameplate. Runes dim while they recharge. Soul shards fill in tenths, so a partly full shard shows as a partly filled piece.",
    },
    {
        category = "Pages",
        title = "Elite icon page",
        keywords = "elite rare boss classification dragon icon",
        text = "The dragon icon on elite, rare and boss plates. Show classification icon is the master switch. Separate switches pick which kinds show: Elites (gold), Rare elites (silver), Rares (star) and World bosses (gold). Size is set here. To place it, drag the icon on the preview.",
    },
    {
        category = "Pages",
        title = "Game settings page",
        keywords = "game settings cvar blizzard names over heads which nameplates show off-screen preferences",
        text = "These are Blizzard's own nameplate settings that don't belong to a Plateau page. Plateau saves the previous value of any you change here, and puts those saved values back (not Blizzard's defaults) when you right-click a setting, reset the page, or type /plt cvars restore.\n\nOther nameplate addons lists any that could conflict. Each can be turned off from there, or you can turn off Plateau instead if you prefer the other one. Names over heads sets which names float over characters. Which nameplates show decides who gets a plate. Keeping nameplates on screen starts collapsed; click its heading to open it, or search for a setting inside it and it opens for you.\n\nBlizzard settings that belong with a Plateau page live on that page instead: size and size by distance on Size, opacity behind walls and by distance on Fading, stacking and movement on Layering and stacking, and the options for the nameplates the game draws itself on Friendly.\n\nPlateau's own settings (window theme, scale and fonts, tooltips, the game menu and minimap buttons) are on Plateau settings, opened with the gear button at the top of this window, so restoring Blizzard settings does not touch them. The performance numbers are under Diagnostics on the Help page. These settings are shared by every profile.",
    },
    {
        category = "Pages",
        title = "Profiles page",
        keywords = "profiles page manage",
        text = "Where you see the default and active profile, create, duplicate, rename, copy settings between, delete and restore profiles, set which profile switches in automatically, and export or import a profile string. See the Profiles topics under Profiles for how each part works.",
    },
    {
        category = "How do I",
        title = "Make elites and casters stand out",
        keywords = "colors elites casters kick priority type color bar",
        text = "Open Health bar and switch on Use enemy type colors under Enemy types. Turn on the types you care about, such as Casters, Elites and Lieutenants, and pick a color for each. Casters are the ones worth kicking, so a color that pops helps.\n\nFor sizes, open Size and turn on Scale by enemy type to make bosses or casters larger.",
    },
    {
        category = "How do I",
        title = "See when my interrupt is ready",
        keywords = "interrupt kick ready cooldown cast bar color line",
        text = "Cast bars follow your own interrupt. Set the colors under Cast bar colors on the Cast bar page: one for ready and one for on cooldown, and separate pairs for important casts.\n\nOn the Cast bar page, turn on Show interrupt cooldown marker to draw a line where your interrupt comes back during the cast.",
    },
    {
        category = "How do I",
        title = "Hide a spell from my debuffs",
        keywords = "hide spell never show filter thrash moonfire remove aura",
        text = "Open Your debuffs, go to Which spells, and type the spell's name or ID in Hidden spells. Press Enter to save. Use commas to list several. The list is saved per specialization, so switch spec to edit another one.\n\nA name matches every spell with that name, so a debuff that has a different ID from your spell is still hidden. The first time you use a new name, Plateau looks it up in the background for a few seconds.",
    },
    {
        category = "How do I",
        title = "Move my auras or icons",
        keywords = "move aura placement position icons above below left right center",
        text = "Drag the group on the preview and drop it on a spot, or open its page and use Placement. Position sets above, below, left or right. Alignment sets left, center or right along that side. Growth direction sets which way icons are added. Horizontal and vertical offsets move it by pixels.\n\nHold Shift while dragging, or turn Snap off, to place it freely.",
    },
    {
        category = "How do I",
        title = "Stop nameplates overlapping",
        keywords = "overlap stacking stack spacing slide crowded",
        text = "Open Layering and stacking. Under Stacking, click a preset, then click it again to apply it: Tight, Balanced or Spread out. They change only the spacing between plates. Turn on Show stacking boxes to see the area the game keeps apart. If plates overlap because your name or cast bar takes extra room, set Stacking bounds under Stacking bounds and spacing to the option that counts it. Turn on Instant movement under Movement if you also want plates to jump straight to their spot.",
    },
    {
        category = "How do I",
        title = "Go back to how it was",
        keywords = "revert restore undo lost broke fix reset old",
        text = "For a recent mistake, use Undo. To reset one setting, right-click it. To reset a page, use Reset this section. To put a ready-made look back the way it shipped, use Restore built-in on the Profiles page. For the game's own nameplate settings, type /plt cvars restore.\n\nIf you are still not happy, /plt setup opens the first-time walkthrough again.",
    },
    {
        category = "Commands",
        title = "Slash commands",
        keywords = "slash commands sl debug setup reset cvars",
        text = "/plt opens the settings window.\n/plt setup opens the first-time walkthrough.\n/plt minimap shows or hides the minimap button.\n/plt debug shows the version, restrictions, CPU and memory, and how Plateau reads your target. Paste it when you report a bug.\n/plt reset puts every setting in the current profile back to its default.\n/plt cvars restore undoes every game nameplate setting Plateau changed.",
    },
}

local Style = ns.Style
local C = Style.colors

function ns.Widgets.ResetEverything(parent)
    local button = ns.Widgets.Button(parent, "Reset everything", 150)
    local armed = false
    button:SetScript("OnClick", function(self)
        if armed then
            armed = false
            self.label:SetText("Reset everything")
            self.label:SetTextColor(C.text[1], C.text[2], C.text[3])
            Plateau.DB:Reset(nil)
            if ns.RefreshAll then
                ns.RefreshAll()
            end
            return
        end
        armed = true
        self.label:SetText("Click again to confirm")
        self.label:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
        C_Timer.After(3, function()
            if armed then
                armed = false
                self.label:SetText("Reset everything")
                self.label:SetTextColor(C.text[1], C.text[2], C.text[3])
            end
        end)
    end)
    return button
end

local controls = {
    { type = "Note", label = "Every feature of Plateau is explained below. When you are on this page, the search box at the top searches only this help, so type a word like cast, drag or profile to jump to a topic.", height = 44 },
    { type = "Actions", buttons = {
        { label = "Replay the tour", width = 150, click = function() if ns.StartTour then ns.StartTour() end end },
        { label = "Run first-time setup", width = 170, click = function() if PlateauSetup then PlateauSetup:Open() end end },
    } },
    { type = "Header", label = "Start over" },
    { type = "Note", label = "Puts every setting in the current profile back to its default. Your other profiles are untouched.", height = 24 },
    { type = "ResetEverything" },
    { type = "Header", label = "Diagnostics", collapsible = true, collapsed = true, searchable = true, key = "diagnostics",
      keywords = "performance cpu memory usage slow frames statistics refresh reset counters profiler",
      helpTopic = {
          title = "Diagnostics",
          category = "Diagnostics",
          keywords = "performance cpu memory usage slow frames statistics refresh reset counters profiler",
          text = "Diagnostics shows how much CPU time and memory Plateau uses, read from the game's own profiler. The numbers update only when you open this section or click Refresh statistics, so they cost nothing while you are not looking. CPU figures are Plateau's own execution time, not total game frame time. The game's slow-frame counts can't be reset, so Plateau also shows how many happened since you last clicked Reset slow-frame counters; the this-session counts and the CPU figures are not cleared.",
      } },
    { type = "Note", height = 90, label = function()
        return table.concat(Plateau.PerformanceLines(), "\n")
    end },
    { type = "Note", label = "CPU figures are Plateau's own execution time from the game's addon profiler, not total game frame time. Reset slow-frame counters only restarts Slow frames since reset; Slow frames this session and the CPU figures are not cleared.", height = 44 },
    { type = "Actions", buttons = {
        { label = "Refresh statistics", width = 170, click = function() ns.RefreshAll() end },
        { label = "Reset slow-frame counters", width = 200, click = function()
            Plateau.ResetPerformanceCounts()
            ns.RefreshAll()
        end },
    } },
}

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
