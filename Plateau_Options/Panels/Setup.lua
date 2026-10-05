local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH, HEIGHT = 740, 740
local PREVIEW_HEIGHT = 210
local PREVIEW_SCALE = 1.5
local PAD = 20
local TITLE = 48
local FOOTER = 56
local CONTENT_WIDTH = WIDTH - PAD * 2
local ROW_WIDTH = CONTENT_WIDTH
local SPACING = 6
local COLUMN_GAP = 12
local HALF_WIDTH = (CONTENT_WIDTH - COLUMN_GAP) / 2

local function KickLabel()
    local id = Plateau.InterruptSpell and Plateau.InterruptSpell()
    local name = id and C_Spell.GetSpellName(id)
    if name then
        return ("Plateau found your interrupt: |cff45d1c2%s|r. Cast bars color themselves by whether it's ready, so you can tell at a glance whether to interrupt. These colors also live on the Cast bar page in /plt."):format(name)
    end
    return "No interrupt found for this spec. Cast bars use the plain kickable colors until you switch to a spec that has one. The cast bar colors live on the Cast bar page in /plt."
end

local PET_CVARS = { "nameplateShowEnemyPets", "nameplateShowEnemyGuardians", "nameplateShowEnemyMinions", "nameplateShowEnemyTotems" }

local function PetsToggle()
    local CVars = Plateau.CVars
    return {
        type = "Toggle",
        label = "Show enemy pets, minions and totems",
        tooltip = "Blizzard's four settings for enemy pets, guardians, minions and totems, switched together. Off keeps big pulls less cluttered.",
        get = function()
            for _, name in ipairs(PET_CVARS) do
                if CVars:Get(name) == "1" then
                    return true
                end
            end
            return false
        end,
        set = function(value)
            for _, name in ipairs(PET_CVARS) do
                CVars:Set(name, value and "1" or "0")
            end
        end,
        reset = function()
            for _, name in ipairs(PET_CVARS) do
                CVars:Release(name)
            end
        end,
        resetLabel = "Right-click to undo Plateau's change.",
    }
end

local playerName = UnitName("player")

function Widgets.SetupPreview(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(PREVIEW_HEIGHT)
    local label = Style.Text(row, 11, C.muted, "CENTER")
    label:SetPoint("TOP", 0, -2)
    label:SetText("Preview at full size")
    local holder = CreateFrame("Frame", nil, row)
    holder:SetSize(1, 1)
    holder:SetScale(PREVIEW_SCALE)
    holder:SetPoint("CENTER", 0, -8)
    local plate = Plateau.CreatePreview(holder, {
        health = 0.72,
        maxHealth = 72700,
        name = "Wastelander Phaseblade",
        levelOffset = 1,
        classification = "elite",
        mobType = "caster",
        raidMarker = 8,
        quest = true,
        forces = { count = 4, percent = 0.84, text = "0.84" },
        classPower = true,
        enemyPower = true,
        auras = { mine = 3, cc = 1, purge = 1, important = 1 },
        absorb = 0.15,
        cast = {
            progress = 0.6,
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            timer = "1.4",
            target = playerName,
            important = spec and spec.important,
        },
    })
    plate:SetPoint("CENTER")
    return row
end

local STEPS = {
    {
        title = "Pick a look",
        intro = "Each look is a ready-made profile. Using one switches to it and makes it your default; some also set enemy colors. Every part can be changed later with /plt, and your changes are saved in that profile.",
        controls = function()
            return {
                { type = "LookCards", presets = ns.AllLooks(), width = CONTENT_WIDTH, wide = true, mode = "profile" },
            }
        end,
    },
    {
        title = "Which plates show",
        intro = "These are Blizzard's own nameplate settings. Plateau remembers what they were before, so you can always put them back with /plt cvars restore.",
        controls = function()
            return {
                { type = "Header", label = "Enemies", first = true },
                ns.CVarToggle("nameplateShowAll", "Always show nameplates", "Off: plates only appear once you're in combat with an enemy."),
                ns.CVarToggle("nameplateShowEnemies", "Show enemy nameplates", "The master switch for enemy plates. Off hides every one of them."),
                ns.CVarToggle("nameplateShowEnemyMinus", "Show minor enemies", "Blizzard's weakest enemies, usually with a minus sign in their tooltip."),
                ns.CVarToggle("UnitNameNonCombatCreatureName", "Show critter and companion names", "Names floating over critters, battle pets and companions. On by default for new installs."),
                PetsToggle(),
                ns.CVarBitToggle("nameplateStackingTypes", ns.stackTypes.Enemy, "Stack enemy nameplates so they don't overlap",
                    "Nudges overlapping enemy plates apart so they stay readable in a crowd, instead of stacking on top of each other."),
                ns.CVarToggle("nameplateShowOffscreen", "Keep engaged enemies' nameplates on screen", "Shows an off-screen indicator for enemies you're in combat with, so you don't lose track of them."),
                { type = "Header", label = "Friendly" },
                ns.CVarToggle("nameplateShowFriendlyPlayers", "Show friendly player plates", "Also controlled from the Friendly page's 'Friendly players' toggle."),
                ns.CVarToggle("nameplateShowFriendlyNpcs", "Show friendly NPC plates", "Also controlled from the Friendly page's 'Friendly NPCs' toggle."),
                ns.CVarToggle("nameplateShowOnlyNameForFriendlyPlayerUnits", "Only show friendly player names, no bar", "Blizzard's own name-only mode. Plateau has its own version of this on the Friendly page."),
                ns.CVarToggle("nameplateUseClassColorForFriendlyPlayerUnitNames", "Class-color friendly player names", "Colors friendly player names by their class instead of a flat color."),
                { type = "Toggle", label = "Let Plateau style friendly plates in the open world",
                  get = function() return ns.Get("look.friendly.enabled") == true end,
                  set = function(value)
                      Plateau.DB:Set("look.friendly.enabled", value == true)
                      if not value then
                          ns.PromptReload()
                      end
                  end,
                  reset = function()
                      local wasOn = ns.Get("look.friendly.enabled") == true
                      Plateau.DB:Reset("look.friendly.enabled")
                      if wasOn and ns.Get("look.friendly.enabled") ~= true then
                          ns.PromptReload()
                      end
                  end,
                  tooltip = "Off leaves friendly plates to Blizzard. In dungeons and raids Blizzard always draws them." },
                { type = "Toggle", label = "Hide the (*) after other realms' player names",
                  get = function() return not Plateau.DB.saved.global.keepRealmMarker end,
                  set = function(value)
                      Plateau.DB.saved.global.keepRealmMarker = not value
                      ns.PromptReload()
                  end,
                  tooltip = "The game adds (*) to players from other realms. Takes effect after a /reload." },
                { type = "Note", label = "Everything else about which plates show, like names over heads, is on the Game settings page in /plt, and fading behind walls is on the Fading page.", height = 32 },
            }
        end,
    },
    {
        title = "What shows on a plate",
        intro = "Switch each part on or off and watch the plate above change. Every one of these has its own page in /plt with more options.",
        controls = function()
            local function Show(path, label, tooltip)
                return { type = "Toggle", half = true, path = path, label = label, tooltip = tooltip }
            end
            return {
                { type = "SetupPreview", wide = true },
                Show("look.auras.mine.enabled", "Your debuffs", "Debuffs you put on the enemy, such as damage over time."),
                Show("look.auras.cc.enabled", "Crowd control", "Stuns, roots, fears and other control effects on the enemy."),
                Show("look.auras.purge.enabled", "Enemy buffs", "Buffs on the enemy that you can dispel or steal."),
                Show("look.auras.important.enabled", "Important auras", "Auras the game flags as important, whoever put them there."),
                Show("look.castbar.showIcon", "Cast spell icon", "The spell icon beside the cast bar."),
                Show("look.classPower.enabled", "Class resource", "Your combo points, holy power, runes and similar, shown on your target."),
                Show("look.enemyPower.enabled", "Enemy power bar", "A mana or energy bar on enemies that use one."),
                Show("look.healthText.enabled", "Health text", "The health number or percent on the bar."),
                Show("look.name.enabled", "Names", "The enemy's name."),
                Show("look.level.enabled", "Level", "The enemy's level."),
                Show("look.enemyTarget.enabled", "Enemy target name", "Who the enemy is targeting."),
                Show("look.raidMarker.enabled", "Raid target icons", "Skull, cross and the other raid markers."),
                Show("look.quest.enabled", "Quest icon", "Marks enemies you need for a quest."),
                Show("look.forces.enabled", "Mythic+ enemy forces", "How much of the dungeon's enemy forces this enemy is worth."),
                Show("look.classification.enabled", "Elite icon", "The dragon icon for elites, rares and bosses."),
            }
        end,
    },
    {
        title = "Colors",
        intro = "How health bars are colored. Tapped, reaction and the rest are on the Health bar page in /plt.",
        controls = function()
            local function Type(key, label, tooltip)
                return { type = "ToggleColor", half = true, path = "look.colors." .. key, colorPath = "look.colors." .. key .. "Color", label = label, tooltip = tooltip }
            end
            return {
                { type = "SetupPreview", wide = true },
                { type = "Toggle", half = true, path = "look.colors.classColors", label = "Class colors for players",
                  tooltip = "Colors enemy players' health bars by their class instead of a flat reaction color." },
                { type = "Toggle", half = true, path = "look.colors.mobTypes", label = "Color enemies by type",
                  tooltip = "Turns on the type rows below: bosses, casters, lieutenants and so on each get their own color." },
                Type("boss", "Bosses", "Enemies flagged as bosses, including world bosses."),
                Type("caster", "Casters", "Enemies that use mana."),
                Type("lieutenant", "Lieutenants", "An elite above your level that also has more health than usual, or any elite two or more levels above you. Real bosses keep the Bosses color."),
                Type("elite", "Melee enemies", "Elites at your level."),
                Type("higher", "Elites", "Elites above your level."),
                Type("trivial", "Minor enemies", "Weak enemies, plus most ordinary trash at your level."),
                { type = "ToggleColor", half = true, path = "look.colors.threat", colorPath = "look.colors.threatBad", label = "Color by my threat",
                  tooltip = "Colors an enemy when the wrong player has aggro on it." },
                { type = "ToggleColor", half = true, path = "look.colors.quest", colorPath = "look.colors.questColor", label = "Quest enemies",
                  tooltip = "Colors enemies that count toward a quest you have, replacing their type color." },
                { type = "Header", label = "Colorblind-friendly colors" },
                { type = "Presets", presets = Plateau.presets.palettes },
            }
        end,
    },
    {
        title = "Interrupts",
        intro = KickLabel,
        controls = function()
            return {
                { type = "SetupPreview", wide = true },
                { type = "Color", half = true, path = "look.castbar.readyColor", label = "Interrupt ready",
                  tooltip = "Cast bar color when your interrupt is off cooldown and this cast can be stopped." },
                { type = "Color", half = true, path = "look.castbar.notReadyColor", label = "Interrupt on cooldown",
                  tooltip = "Cast bar color when your interrupt is still on cooldown." },
                { type = "Color", half = true, path = "look.castbar.importantReadyColor", label = "Important, interrupt ready",
                  tooltip = "Like Interrupt ready, but for casts flagged important (usually dangerous ones)." },
                { type = "Color", half = true, path = "look.castbar.importantNotReadyColor", label = "Important, kick on cooldown",
                  tooltip = "Like Interrupt on cooldown, but for casts flagged important. You can't stop it right now." },
                { type = "Color", half = true, path = "look.castbar.uninterruptible", label = "Can't be interrupted",
                  tooltip = "Cast bar tint for a cast that can't be interrupted at all. This color's opacity sets how strongly it shows over your bar texture." },
                { type = "Color", half = true, path = "look.castbar.importantUninterruptible", label = "Important, needs CC",
                  tooltip = "Blizzard flags the cast as important and the game says it can't be interrupted, so it needs crowd control: a stun, incapacitate or knockback." },
                { type = "ToggleColor", half = true, path = "look.castbar.kickMarker", colorPath = "look.castbar.kickMarkerColor", label = "Mark when kick is ready",
                  tooltip = "When your interrupt is on cooldown but will be ready before the cast ends, a line marks the moment." },
                { type = "ToggleColor", half = true, path = "look.castbar.showInterrupter", colorPath = "look.castbar.interruptedColor", label = "Show who interrupted",
                  tooltip = "Shows the interrupter's name on the cast bar after a cast gets interrupted." },
                { type = "Note", label = "The important-cast glow, the channel colors and the no-interrupt colors are on the Cast bar page in /plt.", height = 32 },
            }
        end,
    },
    {
        title = "You're set",
        intro = "Plateau is ready. A few things worth knowing:",
        controls = function()
            return {
                { type = "Note", label = "|cff45d1c2/plt|r opens every setting, with a live preview you can click and drag to move things.", height = 32 },
                { type = "Note", label = "|cff45d1c2/plt setup|r brings this walkthrough back anytime.", height = 24 },
                { type = "Note", label = "Different layouts per spec or per content (dungeons, raids, arena)? Make a profile for each, then open the profile button at the bottom left of /plt, pick Manage profiles and set them under Switch automatically.", height = 44 },
                { type = "Note", label = "Your target, focus and the plate under your cursor can stand out in their own way: open /plt and look under States in the left menu.", height = 44 },
                { type = "Note", label = "Auras (your debuffs, crowd control, enemy buffs) and Icons (raid markers, quest, enemy forces, class resource) each have their own group in the left menu, with sizes, positions and more.", height = 44 },
                { type = "Note", label = "Minimize shrinks /plt to a small bar showing your active profile, so you can watch the game while you tweak.", height = 32 },
            }
        end,
    },
}

local frame = CreateFrame("Frame", "PlateauSetup", UIParent)
frame:SetSize(WIDTH, HEIGHT)
frame:SetPoint("TOP", UIParent, "CENTER", 0, HEIGHT / 2)
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:Hide()
Style.Panel(frame, C.window, C.border)
tinsert(UISpecialFrames, "PlateauSetup")

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT")
titleBar:SetPoint("TOPRIGHT")
titleBar:SetHeight(TITLE)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local left, top = frame:GetLeft(), frame:GetTop()
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end)

local logo = titleBar:CreateTexture(nil, "ARTWORK")
logo:SetSize(32, 32)
logo:SetPoint("LEFT", PAD, 0)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local heading = Style.Text(titleBar, 16, C.text)
heading:SetPoint("LEFT", logo, "RIGHT", 10, 0)

local counter = Style.Text(titleBar, 11, C.muted, "RIGHT")
counter:SetPoint("RIGHT", -PAD, 0)

local G = Style.groupColors
local line = Style.GradientLine(titleBar, { G.look, G.casts, G.highlights }, 2)
line:SetPoint("BOTTOMLEFT", 1, 0)
line:SetPoint("BOTTOMRIGHT", -1, 0)

local intro = Style.Text(frame, 12, C.muted)
intro:SetPoint("TOPLEFT", PAD, -(TITLE + 16))
intro:SetPoint("RIGHT", -PAD, 0)
intro:SetWordWrap(true)
intro:SetJustifyV("TOP")

local body = CreateFrame("Frame", nil, frame)
body:SetPoint("TOPLEFT", PAD, -(TITLE + 64))
body:SetPoint("BOTTOMRIGHT", -PAD, FOOTER)

local footerLine = frame:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("BOTTOMLEFT", 1, FOOTER)
footerLine:SetPoint("BOTTOMRIGHT", -1, FOOTER)
footerLine:SetHeight(1)
footerLine:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)

local dots = {}
for i = 1, #STEPS do
    local dot = frame:CreateTexture(nil, "ARTWORK")
    dot:SetSize(8, 8)
    dot:SetPoint("BOTTOM", frame, "BOTTOM", (i - (#STEPS + 1) / 2) * 16, FOOTER / 2 - 4)
    dots[i] = dot
end

local pages = {}
local current = 1
local skipButton, backButton, nextButton

local function BuildPage(index)
    local page = CreateFrame("Frame", nil, body)
    page:SetAllPoints()
    page.controls = {}
    local y = 0
    local column, rowTop, rowHeight = 0, 0, 0
    local function EndRow()
        if column == 1 then
            y = rowTop + rowHeight + SPACING
            column = 0
        end
    end
    for _, spec in ipairs(STEPS[index].controls()) do
        local widget = Widgets[spec.type](page, spec)
        if spec.half then
            widget:SetWidth(HALF_WIDTH)
            if column == 0 then
                rowTop, rowHeight = y, widget:GetHeight()
                widget:SetPoint("TOPLEFT", 0, -y)
                column = 1
            else
                widget:SetPoint("TOPLEFT", HALF_WIDTH + COLUMN_GAP, -rowTop)
                rowHeight = math.max(rowHeight, widget:GetHeight())
                EndRow()
            end
        else
            EndRow()
            local wide = spec.type == "Header" or spec.type == "Note" or spec.wide
            widget:SetWidth(wide and CONTENT_WIDTH or ROW_WIDTH)
            widget:SetPoint("TOPLEFT", 0, -y)
            y = y + widget:GetHeight() + SPACING
        end
        if widget.Refresh then
            page.controls[#page.controls + 1] = widget
        end
    end
    EndRow()
    page.contentHeight = y
    return page
end

local function Show(index)
    current = index
    local step = STEPS[index]
    heading:SetText(step.title)
    counter:SetText(("Step %d of %d"):format(index, #STEPS))
    intro:SetText(type(step.intro) == "function" and step.intro() or step.intro)
    for i, page in pairs(pages) do
        page:SetShown(i == index)
    end
    pages[index] = pages[index] or BuildPage(index)
    pages[index]:Show()
    for _, control in ipairs(pages[index].controls) do
        control:Refresh()
    end
    for i, dot in ipairs(dots) do
        local color = i == index and C.accent or C.border
        dot:SetColorTexture(color[1], color[2], color[3], 1)
    end
    backButton:SetShown(index > 1)
    nextButton.label:SetText(index == #STEPS and "Finish" or "Next")
    skipButton:SetShown(index < #STEPS)
    Plateau.RefreshDirtyPreviews()
end

ns.OnRefresh(function()
    if frame:IsShown() and pages[current] then
        for _, control in ipairs(pages[current].controls) do
            control:Refresh()
        end
    end
end)

local function Done(openOptions)
    Plateau.DB.saved.global.setupDone = true
    frame:Hide()
    if openOptions and PlateauOptions then
        PlateauOptions:Show()
    end
end

skipButton = Widgets.Button(frame, "Skip setup", 110, function() Done(false) end)
skipButton:SetPoint("BOTTOMLEFT", PAD, 14)

nextButton = Widgets.Button(frame, "Next", 110, function()
    if current == #STEPS then
        Done(true)
    else
        Show(current + 1)
    end
end)
nextButton:SetPoint("BOTTOMRIGHT", -PAD, 14)

backButton = Widgets.Button(frame, "Back", 90, function()
    if current > 1 then
        Show(current - 1)
    end
end)
backButton:SetPoint("RIGHT", nextButton, "LEFT", -8, 0)

frame:SetScript("OnHide", function(self)
    if not self.closedByCombat then
        Plateau.DB.saved.global.setupDone = true
    end
    self.closedByCombat = false
    ns.HideDropdownList()
end)

frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(self)
    if self:IsShown() then
        self.closedByCombat = true
        self:Hide()
    end
end)

function frame:Open()
    if InCombatLockdown() then return end
    if PlateauOptions and PlateauOptions:IsShown() then
        PlateauOptions:Hide()
    end
    self:Show()
    Show(1)
end

local conflicts = CreateFrame("Frame", "PlateauConflicts", UIParent)
conflicts:SetSize(520, 200)
conflicts:SetPoint("CENTER")
conflicts:SetFrameStrata("DIALOG")
conflicts:SetToplevel(true)
conflicts:EnableMouse(true)
conflicts:Hide()
Style.Panel(conflicts, C.window, C.border)

local conflictLogo = conflicts:CreateTexture(nil, "ARTWORK")
conflictLogo:SetSize(22, 22)
conflictLogo:SetPoint("TOPLEFT", PAD, -14)
conflictLogo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local conflictTitle = Style.Text(conflicts, 15, C.text)
conflictTitle:SetPoint("LEFT", conflictLogo, "RIGHT", 10, 0)
conflictTitle:SetText("Other nameplate addons found")

local conflictText = Style.Text(conflicts, 11, C.muted)
conflictText:SetPoint("TOPLEFT", PAD, -48)
conflictText:SetPoint("RIGHT", -PAD, 0)
conflictText:SetWordWrap(true)
conflictText:SetText("These also change nameplates. With two running, plates can flicker, double up or ignore settings. Tick the ones to turn off, or turn off Plateau instead if you would rather use one of them. Either reloads your UI.")

local conflictRows = {}
local conflictList = {}
local conflictDone

local function ConflictRow(index)
    local row = conflictRows[index]
    if row then return row end
    local spec = {
        label = "",
        get = function() return conflictList[index] and conflictList[index].checked end,
        set = function(value)
            if conflictList[index] then
                conflictList[index].checked = value
            end
        end,
    }
    row = Widgets.Toggle(conflicts, spec)
    row.spec = spec
    row:SetWidth(420)
    row:SetPoint("TOPLEFT", PAD, -(90 + (index - 1) * 28))
    conflictRows[index] = row
    return row
end

local function FinishConflicts()
    conflicts:Hide()
    local done = conflictDone
    conflictDone = nil
    if done then
        done()
    end
end

local disableButton = Widgets.Button(conflicts, "Turn off ticked and reload", 190, function()
    local any = false
    for _, entry in ipairs(conflictList) do
        if entry.checked then
            Plateau.ResolveConflict(entry)
            any = true
        else
            Plateau.IgnoreConflict(entry.name)
        end
    end
    if any then
        ReloadUI()
    else
        FinishConflicts()
    end
end)
disableButton:SetPoint("BOTTOMRIGHT", -PAD, 14)

local keepButton = Widgets.Button(conflicts, "Keep them", 110, function()
    for _, entry in ipairs(conflictList) do
        Plateau.IgnoreConflict(entry.name)
    end
    FinishConflicts()
end)
keepButton:SetPoint("RIGHT", disableButton, "LEFT", -8, 0)

local selfButton = Widgets.Button(conflicts, "Turn off Plateau", 130, function()
    Plateau.DisableSelf()
    ReloadUI()
end)
selfButton:SetPoint("BOTTOMLEFT", PAD, 14)

function conflicts:Open(list, onDone)
    conflictList = {}
    for i, entry in ipairs(list) do
        conflictList[i] = { name = entry.name, title = entry.title, elvui = entry.elvui, checked = true }
    end
    conflictDone = onDone
    for i, row in ipairs(conflictRows) do
        row:SetShown(i <= #conflictList)
    end
    for i, entry in ipairs(conflictList) do
        local row = ConflictRow(i)
        row.spec.label = entry.elvui and "ElvUI nameplates (ElvUI itself stays on)" or entry.title
        row:Refresh()
        row:Show()
    end
    self:SetHeight(140 + #conflictList * 28)
    self:Show()
end

function Widgets.Conflicts(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(40)
    local lines = {}
    row.selfButton = Widgets.Button(row, "Turn off Plateau instead and reload", 250, function()
        Plateau.DisableSelf()
        ReloadUI()
    end)

    function row:Refresh()
        for _, entryRow in ipairs(lines) do
            entryRow:Hide()
        end
        row.selfButton:Hide()
        local list = Plateau.FindConflicts()
        if #list == 0 then
            local entryRow = lines[1] or Style.Text(row, 12, C.muted)
            lines[1] = entryRow
            entryRow:ClearAllPoints()
            entryRow:SetPoint("TOPLEFT", 0, -6)
            entryRow:SetText("No other nameplate addons detected.")
            entryRow:Show()
            row:SetHeight(28)
            return
        end
        row.selfButton:ClearAllPoints()
        row.selfButton:SetPoint("TOPLEFT", 0, -(#list * 32 + 4))
        row.selfButton:Show()
        for i, entry in ipairs(list) do
            local entryRow = lines[i]
            if not entryRow then
                entryRow = CreateFrame("Frame", nil, row)
                entryRow:SetSize(440, 28)
                entryRow.text = Style.Text(entryRow, 12, C.text)
                entryRow.text:SetPoint("LEFT")
                entryRow.button = Widgets.Button(entryRow, "Turn off and reload", 150)
                entryRow.button:SetPoint("RIGHT")
                lines[i] = entryRow
            end
            entryRow:ClearAllPoints()
            entryRow:SetPoint("TOPLEFT", 0, -((i - 1) * 32))
            entryRow.text:SetText(entry.elvui and "ElvUI nameplates" or entry.title)
            entryRow.button:SetScript("OnClick", function()
                Plateau.ResolveConflict(entry)
                ReloadUI()
            end)
            entryRow:Show()
        end
        row:SetHeight(#list * 32 + 36)
    end

    row:Refresh()
    return row
end
