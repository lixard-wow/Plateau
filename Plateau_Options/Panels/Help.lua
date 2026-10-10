local _, ns = ...

ns.helpTopics = {
    {
        category = "Getting started",
        title = "How Plateau works",
        keywords = "overview basics start intro what is minimize profile",
        text = "Plateau replaces the way enemy nameplates look: the health bar, name, cast bar, auras and icons. Everything is drawn by Plateau, but the game still decides what is shown, so it keeps working in dungeons and raids.\n\nThis window has three parts. The preview at the top shows a sample nameplate that updates as you change things. The menu on the left lists a page for each part of the nameplate, grouped by what they do. The page on the right holds that part's settings.\n\nEvery change saves right away. There is no Apply or Save button. Settings live in a profile: each character has a default profile, and the active profile is the one you are editing.",
    },
    {
        category = "Getting started",
        title = "The preview",
        keywords = "preview sample situations play scenarios cast enemy threat badge",
        text = "The preview at the top of the window is a sample enemy nameplate that updates as you change settings. The part you are editing is outlined.\n\nThe preview shows what your settings turn on: raid icons, quest icons, auras, absorbs, the power bar and more appear when they are enabled and disappear when they are not. The Target, Focus and Mouseover pages show the sample in that state, and Buff warnings shows its warnings.\n\nA few pages have a Preview button next to Reset this section for things the sample can't tell from your settings: on the Cast bar page it picks the cast the preview plays, on the Health bar colors page it picks the sample's enemy type and threat, on the Threat page its threat, and on the Elite icon page the badge. They only change the preview, are never saved, and go back to their default when you leave the page.\n\nPages that only matter in the world, like the Behavior pages and Game settings, say so under the preview.",
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
        keywords = "looks cards presets layouts styles minimal default familiar classic unit frames clean flat bold crisp compact name inside setup",
        text = "The first-time setup shows a card for each of the six ready-made looks (Minimal, Familiar layout, Classic unit frames, Compact, Clean and flat, and Bold and crisp), each with a small live nameplate. Several are inspired by popular nameplate and unit frame addons, rebuilt from Plateau's own settings. Hover a card to read everything it changes. Press Use this look to switch your whole profile to it, which you can then edit and keep.\n\nTo see the cards again later, type /plt setup to run the walkthrough again, or use Restore built-in on the Profiles page to put any look back to how it shipped.",
    },
    {
        category = "Getting started",
        title = "Undo and redo",
        keywords = "undo redo history revert mistake back",
        text = "Undo and Redo are at the top right of the preview. Every change you make is remembered, and the list names each one, for example Height, Moved Raid target icon or Look: Clean and flat.\n\nClick Undo to step back one change. Open the list beside it to jump back several changes at once. Redo brings back what you undid, until you make a new change.\n\nUndo only tracks what you do while this window or the setup is open. It keeps the last 20 changes, and it also covers the game nameplate settings on the Game settings page. Switching profiles clears the list.",
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
        text = "In some dungeon, raid and PvP content the game hides information from addons on purpose, for example threat, who a unit is, or friendly nameplates. A setting marked with a warning icon depends on information the game can hide. Hover it to read what happens.\n\nWhen the game hides something, Plateau never guesses. Nameplates keep their normal colors, and the parts the game draws itself, like friendly nameplates in instances, stay as Blizzard draws them.\n\nMost of Plateau is built so the game does the checking. Cast colors, aura filters and buff warnings work in instances for that reason.",
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
        text = "To share the active profile, open Profiles, click Export active profile, click the string that appears, press Ctrl+A and then Ctrl+C to copy it. It holds the full look, the aura spell lists and boss phase lines, so it looks the same on another computer. It does not hold your default profile, automatic rules, Game settings or Plateau settings.\n\nTo import one, paste the text into the import box, optionally type a profile name, and click Import profile. The string is checked first and saved as a new profile; an empty name becomes Imported. Turn on Activate after import to switch to it at once (or when combat ends). Imports never replace an existing profile, and a refused string changes nothing.",
    },
    {
        category = "Pages",
        title = "Size page",
        keywords = "size scale enemy type target focus casting blizzard nameplate size distance bigger smaller",
        text = "Size holds every scale. Scale by enemy type gives bosses, casters, lieutenants, higher-level elites, other elites and other enemies their own size. Target, Focus and Casting scale grow those nameplates. A nameplate uses the biggest scale that applies; they never stack.\n\nBlizzard nameplate size and Size by distance are Blizzard's own settings. Use Blizzard nameplate sizing for enemies lets Blizzard's Nameplate Size resize enemy nameplates too; friendly nameplates always follow it. The preview always shows normal size.",
    },
    {
        category = "Pages",
        title = "Fading page",
        keywords = "fading fade opacity occluded hidden walls line of sight range distance transparent",
        text = "Fading holds every way a nameplate can fade: Range fading for enemies your interrupt can't reach, Non-target fading while you have a target, Behind walls, By distance, and whether disappearing nameplates fade out.\n\nUnder Behind walls, separate switches pick where it applies: the open world, dungeons, raids, delves and scenarios, and battlegrounds and arenas.",
    },
    {
        category = "Pages",
        title = "Layering and stacking page",
        keywords = "layering stacking stack overlap order spacing movement slide front",
        text = "Layering decides which nameplate is in front where nameplates overlap. Casting enemies in front draws a casting enemy over its neighbors, with your target still on top; otherwise nearer nameplates draw over farther ones.\n\nStacking holds the spacing presets, the stacking switches and Show stacking boxes, which draws the area the game keeps apart. Stacking bounds and spacing decide how much of each nameplate counts. Movement holds Instant movement and how fast nameplates slide.",
    },
    {
        category = "Pages",
        title = "Clickable area page",
        keywords = "click area clickable padding offset hitbox",
        text = "Show clickable areas draws the click box on the preview and on real nameplates until you close the window. Padding and offset sliders resize and move it, and Include cast bar in clickable area adds the cast bar to it.",
    },
    {
        category = "Pages",
        title = "Out of combat page",
        keywords = "out of combat idle combat scale opacity hide show",
        text = "Out of combat, under States, gives enemies that are not fighting their own look so the ones in combat stand out.\n\nCombat scale (Scale by combat state) has one size for enemies in combat with anyone and one for enemies that are not. It multiplies the enemy type scale from the Size page, so bosses stay bigger than trash either way.\n\nCustomize out-of-combat nameplates makes them more see-through, narrower or shorter, or one flat bar color, and Show when out of combat picks which of auras, health text, name, level and the icons they keep. It all switches back the moment the enemy enters combat. Your target, players and friendly nameplates are never changed.",
    },
    {
        category = "Pages",
        title = "Health bar page",
        keywords = "health bar width height texture overlay pattern checkers lines border color absorb absorbs execute threshold marker",
        text = "Size sets the width and height of the bar; every scale is on the Size page. Bar picks the texture, an optional Plateau overlay pattern (checkers or diagonal lines leaning either way) laid on top of it, the background color and texture, and the border color, style and thickness. Picking a border color while the style is No border turns on a thin border. Draw border inside puts it on the bar's inner edge instead of around it. Pixel-perfect borders keeps borders crisp at any size. Your target and focus can have their own texture and overlay on their pages.\n\nFill sets smooth health changes, the fill direction and the spark at the edge of the fill. Health bar colors are on their own page.\n\nAbsorbs shows shields on the bar. Absorb position picks whether the shield is added after the health or drawn over the bar from the right edge. Show overflow glow shows a glow at the end of the bar when a shield is bigger than the room left, and Absorb texture changes how the shield is drawn.\n\nThe execute indicator colors any enemy's bar while its health is below the threshold you choose, for every class and spec. Show health markers draws up to two marker lines on the bar, for example at 20% and 35%, with their own thickness; they don't change where the execute color starts.\n\nBoss phase lines draws lines on boss health bars where the fight changes phase. Plateau uses the current boss's percentages, and you can edit them per boss or set default lines for other bosses.",
    },
    {
        category = "Pages",
        title = "Health bar colors page",
        keywords = "colors color threat class type boss caster elite melee reaction interrupt hostile neutral friendly tapped quest colorblind preset",
        text = "Health bar colors holds the bar's colors, listed in priority order: target or focus colors, then Tapped, then Threat, then Quest enemies, then enemy type or class color, then Reaction. Target and focus colors are on their own pages, threat colors on the Threat page, and Quest enemy color on the Quest icon page. Color by health, under Low health, fades the bar toward a low health color as the enemy loses health.\n\nEnemy types colors bosses, casters, lieutenants, other elites, higher-level elites and other enemies, each with its own switch and color. Other enemies is also the fallback for any enemy that doesn't fit the other rows. Enemy players can use class colors instead.\n\nThe Colorblind presets set a full palette; click a preset twice to apply it. Cast bar colors are on the Cast bar page.",
    },
    {
        category = "Pages",
        title = "Threat page",
        keywords = "threat aggro tank percent off-tank warning safe color",
        text = "Threat colors an enemy when the wrong player has aggro. For a tank, an enemy held by another tank in your group counts as safe. Show threat on picks the health bar, its border, or both. Threat warning color and Threat safe color add a middle and a safe state, and Off-tank color marks enemies another tank holds. The game can hide threat in some fights; nameplates keep their normal color then.\n\nThreat percent shows your threat on each enemy as a number, with its own position and font.",
    },
    {
        category = "Pages",
        title = "Friendly nameplates page",
        keywords = "friendly nameplates names only npc player instance size dungeon raid",
        text = "Style friendly nameplates with Plateau decides whether friendly players and NPCs use Plateau's look. In dungeons, raids and arenas the game locks friendly nameplates, so Blizzard draws them there and these settings do not apply. The one exception is size: Blizzard nameplate size is Blizzard's own Nameplate Size, the same setting as Nameplate size on the Size page, so it sizes friendly players there too.\n\nNames only shows just a name with no bar, with separate colors and sizes for players and NPCs. Name vertical offset moves the name up or down if it floats too far above the head. Hide realm marker (*) removes the marker the game adds, even on nameplates the game draws in dungeons; it takes effect after a /reload. Which friendly NPC names float over heads is on the Game settings page, under Names over heads.",
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
        text = "Show names turns names on or off. Text color and Use class colors for player names set the color. Position puts the name above, below, or in one of the corners inside the bar. Text alignment sets left, center or right. Distance from bar moves the name closer to or farther from the bar.\n\nShorten names shows the full name, the first or last word, or initials. Long names decides what happens when the name is still too wide: leave it or cut it at the end or start. Maximum name width sets where it is cut, and 0 means the width of the nameplate. Font settings are below.\n\nEnemy target name shows who the enemy is currently targeting, separate from the Cast bar page's cast target. Use class colors colors it by class when available, falling back to the swatch beside it otherwise, with its own position and font.",
    },
    {
        category = "Pages",
        title = "Level page",
        keywords = "level number difficulty elite plus",
        text = "Show level puts the enemy's level on the nameplate. Color by difficulty colors it like the game does, red for hard and grey for easy, and otherwise it uses the color you pick. Show + for elites marks elites and rare elites. Hide on same-level normal enemies keeps the nameplate clean when the level is the same as yours. Position, offsets and font are below.",
    },
    {
        category = "Pages",
        title = "Cast bar page",
        keywords = "cast bar spell icon interrupt important glow highlight interrupted who time target marker cooldown spacing background",
        text = "Show picks which casts get a cast bar: all, only ones you can interrupt, or only important ones. Size and spacing sets the width (0 matches the health bar), height and distance from the health bar, and can join both bars inside one border. Bar covers the texture, overlay, background, border, the spark and whether bars drain instead of fill.\n\nSpell icon shows the spell's icon, can stretch it across both bars, crop its edges and add a shield on casts you can't interrupt.\n\nInterrupts can show an interrupt ready marker on the cast bar where your interrupt comes back, so you know whether to wait. Important casts get a highlight glow; the game decides which casts are important.\n\nCast bar colors show whether your interrupt is ready and whether the cast can be interrupted. With no interrupt ability, casts that can be interrupted use the ready colors, so you can call them out.\n\nText holds the spell name, its alignment and the remaining cast time, which switches to tenths below a limit you set. Cast target shows who the spell is aimed at, with its own color, size and position.\n\nInterrupted casts shows who interrupted the cast for a moment, and styles that message: what it says, its position, size and color, class color for the name, whether the spell name stays, and a flash. Drag the message on the preview to move it.",
    },
    {
        category = "Pages",
        title = "Buff warnings page",
        keywords = "buff warnings enrage important major defensive dispellable magic purge dispel border overlay texture warning priority icon",
        text = "This marks the nameplate itself when the enemy gains a buff you should react to. Buff icons are on Enemy buffs and Important auras. There are four warnings: Important buff, Major defensive buff, Enrage and Dispellable Magic buff. Each has its own on and off switch.\n\nThe warning can be a colored border, a health bar overlay, or both. Border thickness of 0 means no border. When an enemy has several at once, the one at the top of Warning priority is drawn over the others. It starts as Important buff, Major defensive buff, Enrage, then Dispellable Magic buff, and you can move each one up or down.\n\nBlizzard classifies the enemy's buffs, so this works in dungeons and raids. Only warn for buffs you can remove hides the Enrage and Dispellable Magic warnings while you know no spell that removes them. Appearance changes made during combat apply after combat ends.",
    },
    {
        category = "Pages",
        title = "Aura text and tooltips page",
        keywords = "aura text font outline shadow tooltips all auras icons",
        text = "Settings shared by every aura group. Text sets the font, outline and shadow for the time and stack text on all aura icons. Tooltips shows Blizzard's aura tooltip when you hover an icon, with a separate switch for combat. Icons never catch clicks, so clicking still targets the enemy.\n\nEvery aura page is laid out the same way. Show turns the group on, with any options that belong only to it. Which auras sets the Sort order and a Maximum aura duration (auras that last longer are hidden, permanent ones included, and 0 turns it off), plus two spell lists per specialization: Hidden spells hides the ones you list, and Allowed spells shows nothing else. Type spell names or IDs separated by commas and press Enter. A name matches every spell with that name.\n\nLayout places the group: Position, Alignment, Growth direction and offsets, then Icon size, Icon shape, Maximum icons, Icons per row and Icon spacing.\n\nIcon covers each icon: remaining time and stack count with their sizes and positions, the cooldown swipe, the icon border, and dispel-type border colors.",
    },
    {
        category = "Pages",
        title = "Your debuffs page",
        keywords = "my debuffs your debuffs dots auras own player icons",
        text = "Your damage-over-time effects and other debuffs on enemies. Show other players' debuffs, under Show, adds debuffs other players put on the enemy after your own. Icon also has a tint for the window when refreshing an effect carries leftover time over.",
    },
    {
        category = "Pages",
        title = "Crowd control page",
        keywords = "crowd control cc stun root incapacitate auras",
        text = "Crowd control effects on enemies, including stuns, incapacitate effects and roots, regardless of who applied them. In dungeons and raids, Blizzard decides which auras land in the group. Plateau sets how they look and where they go.",
    },
    {
        category = "Pages",
        title = "Enemy buffs page",
        keywords = "enemy buffs purge spellsteal soothe enrage dispel",
        text = "Buffs on enemies. By default only removable buffs are shown: Magic buffs that can be purged or stolen, and enrages, each with its own switch under Show. Show all buffs lists every other buff too. Hide boss auras hides auras the game flags as boss auras, and Hide permanent buffs hides buffs with no end time. A buff the game flags as important shows under Important auras instead of here. Spell lists only work on enemy buffs in the open world, because the game hides which buff it is in dungeons and raids.",
    },
    {
        category = "Pages",
        title = "Important auras page",
        keywords = "important auras flagged",
        text = "Buffs the game flags as important on an enemy, except ones you cast. This group is off by default. It is a separate group from Enemy buffs: a buff shows in one or the other. Buff warnings can also mark the same buffs on the nameplate.",
    },
    {
        category = "Pages",
        title = "Target, Focus and Mouseover pages",
        keywords = "highlight target focus mouseover arrows brackets glow border recolor opacity",
        text = "Target, Focus, Mouseover and Out of combat each have their own page under States in the left menu.\n\nYour target can have a colored border, a recolored health bar, its own bar texture and overlay pattern, a brighter bar, arrows, corner brackets and a soft glow. Arrows and brackets take any color you choose, and have styles, sizes and spacing from the nameplate. Fading the other nameplates while you have a target is on the Fading page.\n\nYour focus has the same choices. When a unit is both your target and focus, Target settings take priority.\n\nMouseover highlights the nameplate under your cursor with a brighter bar and a border.",
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
        text = "A thin bar showing an enemy's power: energy, rage, mana or another resource. It is meant for watching a boss's energy in a raid without a boss unit frame.\n\nThe game hides the exact numbers from addons, but Plateau can still fill a bar and show a percentage from them. Enemies with no power of that kind, such as a boss with no energy, simply get no bar, as in Blizzard's own frames. Power information may be unavailable for some enemies or encounters.\n\nShow on picks bosses only, every enemy, or just your target - bosses use the same enemy types as the Health bar colors and Size. Bar position puts it inside the bottom edge of the health bar, above it, or below it. When it is below, the cast bar moves down to make room, and moves back when the enemy has no bar. Height, width, offsets and opacity place it (opacity covers the background and percentage text too, not just the fill). It uses the power type's usual color, or your own, and can show its percentage as text when the game provides one.",
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
        text = "The dragon icon on elite, rare and boss nameplates. Show elite icon is the master switch. Separate switches pick which kinds show: Elites, Rare elites, Rares and World bosses. Size is set here. To place it, drag the icon on the preview.",
    },
    {
        category = "Pages",
        title = "Game settings page",
        keywords = "game settings cvar blizzard names over heads which nameplates show off-screen preferences",
        text = "These are Blizzard's own nameplate settings that don't belong to a Plateau page. Plateau saves the previous value of any you change here, and puts those saved values back (not Blizzard's defaults) when you right-click a setting, reset the page, or type /plt cvars restore.\n\nOther nameplate addons lists any that could conflict. Each can be turned off from there, or you can turn off Plateau instead if you prefer the other one. Names over heads sets which names float over characters. Which nameplates show decides who gets a nameplate. Off-screen nameplates starts collapsed; click its heading to open it, or search for a setting inside it and it opens for you.\n\nBlizzard settings that belong with a Plateau page live on that page instead: size and size by distance on Size, opacity behind walls and by distance on Fading, stacking and movement on Layering and stacking, and the options for the nameplates the game draws itself on Friendly.\n\nPlateau's own settings (window theme, scale and fonts, tooltips, the game menu and minimap buttons) are on Plateau settings, opened with the gear button at the top of this window, so restoring Blizzard settings does not touch them. The performance numbers are under Diagnostics on the Help page. These settings are shared by every profile.",
    },
    {
        category = "How do I",
        title = "Make elites and casters stand out",
        keywords = "colors elites casters kick priority type color bar",
        text = "Open Health bar colors and switch on Enemy type colors under Enemy types. Turn on the types you care about, such as Casters, Other elites and Lieutenants, and pick a color for each. Casters are the ones worth kicking, so a color that pops helps.\n\nFor sizes, open Size and turn on Scale by enemy type to make bosses or casters larger.",
    },
    {
        category = "How do I",
        title = "See when my interrupt is ready",
        keywords = "interrupt kick ready cooldown cast bar color line",
        text = "Cast bars follow your own interrupt. Set the colors under Cast bar colors on the Cast bar page: one for ready and one for on cooldown, and separate pairs for important casts.\n\nOn the Cast bar page, turn on Show interrupt ready marker to draw a line where your interrupt comes back during the cast.",
    },
    {
        category = "How do I",
        title = "Hide a spell from my debuffs",
        keywords = "hide spell never show filter thrash moonfire remove aura",
        text = "Open Your debuffs, go to Which auras, and type the spell's name or ID in Hidden spells. Press Enter to save. Use commas to list several. The list is saved per specialization, so switch spec to edit another one.\n\nA name matches every spell with that name, so a debuff that has a different ID from your spell is still hidden. The first time you use a new name, Plateau looks it up in the background for a few seconds.",
    },
    {
        category = "How do I",
        title = "Move my auras or icons",
        keywords = "move aura placement position icons above below left right center",
        text = "Drag the group on the preview and drop it on a spot, or set it on its page. On aura pages these settings are under Layout. Position sets above, below, left or right. Alignment sets left, center or right along that side. Growth direction sets which way icons are added. Horizontal and vertical offsets move it by pixels.\n\nHold Shift while dragging, or turn Snap off, to place it freely.",
    },
    {
        category = "How do I",
        title = "Stop nameplates overlapping",
        keywords = "overlap stacking stack spacing slide crowded",
        text = "Open Layering and stacking. Under Stacking, click a preset, then click it again to apply it: Tight, Balanced or Spread out. They change only the spacing between nameplates. Turn on Show stacking boxes to see the area the game keeps apart. If nameplates overlap because your name or cast bar takes extra room, change Stacking bounds to include it. Turn on Instant movement under Movement if you also want nameplates to jump straight to their spot.",
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
        keywords = "slash commands plt debug setup reset cvars",
        text = "/plt opens the settings window.\n/plt setup opens the look picker from the first-time setup.\n/plt minimap shows or hides the minimap button.\n/plt debug shows the version, restrictions, CPU and memory, and how Plateau reads your target. Paste it when you report a bug.\n/plt reset puts every setting in the current profile back to its default.\n/plt cvars restore undoes every game nameplate setting Plateau changed.",
    },
}

local Style = ns.Style
local C = Style.colors

function ns.Widgets.ResetEverything(parent)
    local button = ns.Widgets.Button(parent, "Reset everything", 150)
    ns.Widgets.Confirm(button, "Reset everything", function()
        Plateau.DB:Reset(nil)
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end)
    return button
end

local controls = {
    { type = "Note", label = "Every feature of Plateau is explained below. On this page, search finds help topics only.", height = 24 },
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
    { type = "Note", label = "CPU is Plateau's own time, not total frame time. Reset slow-frame counters clears only Slow frames since reset.", height = 30 },
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
