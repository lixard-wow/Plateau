local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH = 560
local PAD = 14
local TITLE = 30
local FOOTER = 44
local CONTENT_WIDTH = WIDTH - PAD * 2
local LOOK_ROW = 52
local SAMPLE_WIDTH = 110

local T = Style.T
local IMPORT_BOX_HEIGHT = 80

local function OwnProfiles()
    local options = {}
    for _, name in ipairs(Plateau.DB:ListProfiles()) do
        if not Plateau.Builtins.ByName(name) then
            options[#options + 1] = { value = name, label = name }
        end
    end
    return options
end

local TEXT = {
    title = "Pick a look",
    intro = "You can change any of it later. Nothing here touches your other characters.",
    characterTitle = "Pick a profile for this character",
    characterIntro = "This character doesn't have a profile yet. Use one you already have, or pick a look.",
}

function Widgets.SetupImport(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(IMPORT_BOX_HEIGHT + 56)

    local edit, box = ns.Widgets.TextArea(row, CONTENT_WIDTH - 12)
    box:SetPoint("TOPLEFT")
    box:SetPoint("TOPRIGHT")
    box:SetHeight(IMPORT_BOX_HEIGHT)
    local peek = ns.ImportPeek(box, "sample:setupImport", edit)
    edit:SetScript("OnTextChanged", function(self) peek(self:GetText()) end)

    local message = Style.Text(row, 11, C.muted)
    message:SetWordWrap(true)
    message:SetJustifyH("LEFT")

    local import = Widgets.Button(row, "Import and use", 140, function()
        local ok, name, state, reload = Plateau.DB:ImportProfile(nil, edit:GetText(), true)
        if ok then
            Style.PaintText(message, C.muted)
            message:SetText(ns.ImportedText(name, state, true))
            edit:SetText("")
            edit:ClearFocus()
            if ns.RefreshAll then
                ns.RefreshAll()
            end
            if reload and ns.PromptReload then
                ns.PromptReload()
            end
        else
            Style.PaintText(message, C.warn)
            message:SetText(name or T("Import failed."))
        end
    end)
    import:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -8)
    message:SetPoint("LEFT", import, "RIGHT", 12, 0)
    message:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    Style.Tooltip(import, { label = "Import and use", tooltip = "Adds the pasted profile, makes it active and the default for this character, and applies the Blizzard nameplate settings saved with it." })

    row:SetScript("OnHide", function()
        message:SetText("")
    end)
    return row
end

local frame = CreateFrame("Frame", "PlateauSetup", UIParent)
frame:SetWidth(WIDTH)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:Hide()
Style.Panel(frame, C.window, C.border)
tinsert(UISpecialFrames, "PlateauSetup")
frame:SetScale(Style.PixelScale())
frame:HookScript("OnShow", function(self) Style.FitWindow(self) end)

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT", 1, -1)
titleBar:SetPoint("TOPRIGHT", -1, -1)
titleBar:SetHeight(TITLE)
titleBar:EnableMouse(true)
Style.Fill(titleBar, C.header)
Style.DragWindow(frame, { titleBar, frame }, Style.SnapWindow)

local heading = Style.Text(titleBar, 17, C.title)
Style.SetFont(heading, Style.titleFont, 17, "")
heading:SetPoint("LEFT", PAD, 0)

local closeX = Style.IconButton(titleBar, "icon_close", 20, function() frame:Hide() end, "Close")
closeX:SetPoint("RIGHT", -6, 0)

local intro = Style.Text(frame, 11, C.muted)
intro:SetPoint("TOPLEFT", PAD, -(TITLE + 10))
intro:SetPoint("RIGHT", -PAD, 0)
intro:SetWordWrap(true)
intro:SetJustifyV("TOP")

local body = CreateFrame("Frame", nil, frame)
body:SetPoint("TOPLEFT", PAD, -(TITLE + 32))
body:SetWidth(CONTENT_WIDTH)

local ownRow = Widgets.Dropdown(body, {
    label = "Use a profile you already have",
    tooltip = "Makes this your active profile and the default for this character.",
    options = OwnProfiles,
    get = function() return Plateau.DB:DefaultProfile() end,
    set = function(value) Plateau.DB:SetDefaultProfile(value) end,
})
ownRow:SetWidth(CONTENT_WIDTH)
ownRow:SetPoint("TOPLEFT")

local PREVIEW = 76
local stage = CreateFrame("Frame", nil, body)
stage:SetSize(CONTENT_WIDTH, PREVIEW)
stage:SetClipsChildren(true)
Style.Fill(stage, C.header)
Style.Border(stage, C.edge)
local stageView = ns.LookView(stage, "sample:setup", CONTENT_WIDTH - 40, 1.2)

local list = CreateFrame("Frame", nil, body)
list:SetWidth(CONTENT_WIDTH)

local importView = Widgets.SetupImport(body)
importView:SetWidth(CONTENT_WIDTH)
importView:Hide()

local function EntryOf(preset)
    return Plateau.Builtins.ForPreset(preset)
end

local looks, rows = {}, {}
local chosen
for _, entry in ipairs(Plateau.Builtins.list) do
    for _, preset in ipairs(ns.AllLooks()) do
        if EntryOf(preset) == entry then
            looks[#looks + 1] = preset
        end
    end
end

local function ShowLook(preset)
    if preset and stage:IsShown() then
        stageView:Set(Plateau.PresetLook(preset))
    end
end

local function PaintRows()
    for _, row in ipairs(rows) do
        local on = row.preset == chosen
        row.edge:SetShown(on)
        row.fill:SetShown(on)
    end
    ShowLook(chosen)
end

for i, preset in ipairs(looks) do
    local row = CreateFrame("Button", nil, list)
    row:SetSize(CONTENT_WIDTH, LOOK_ROW)
    row:SetPoint("TOPLEFT", 0, -(i - 1) * LOOK_ROW)
    row.fill = Style.Fill(row, C.hover)
    row.edge = CreateFrame("Frame", nil, row)
    row.edge:SetAllPoints()
    Style.Border(row.edge, C.accent)

    local area = CreateFrame("Frame", nil, row)
    area:SetPoint("LEFT", 10, 0)
    area:SetSize(SAMPLE_WIDTH, LOOK_ROW - 4)
    area:SetClipsChildren(true)
    ns.DrawLookSample(area, preset, SAMPLE_WIDTH - 6)

    local name = Style.Text(row, 13, C.text)
    name:SetPoint("TOPLEFT", area, "TOPRIGHT", 14, -8)
    name:SetText(preset.label)
    local line = Style.Text(row, 11, C.muted)
    line:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
    line:SetPoint("RIGHT", -10, 0)
    line:SetText(preset.summary or "")

    row.preset = preset
    row:SetScript("OnClick", function()
        chosen = preset
        PaintRows()
    end)
    row:SetScript("OnDoubleClick", function()
        chosen = preset
        PaintRows()
        if frame.Use then frame.Use() end
    end)
    Style.Tooltip(row, { label = preset.label, tooltip = preset.tooltip })
    row:HookScript("OnEnter", function() ShowLook(preset) end)
    row:HookScript("OnLeave", function() ShowLook(chosen) end)
    rows[i] = row
end
list:SetHeight(#looks * LOOK_ROW)

local switch = ns.TextButton(frame, "Paste a profile string instead")
switch:SetPoint("BOTTOMLEFT", PAD - 4, 12)

local skipButton = Widgets.Button(frame, "Skip", 80, function() frame:Hide() end)
skipButton:SetPoint("BOTTOMRIGHT", -PAD, 12)

local useButton = Widgets.PrimaryButton(frame, "Use this look", 120, function()
    local entry = chosen and EntryOf(chosen)
    if entry then
        Plateau.DB:UseBuiltin(entry.name)
        if ns.UpdateProfileLabel then
            ns.UpdateProfileLabel()
        end
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end
    frame:Hide()
end)
useButton:SetPoint("RIGHT", skipButton, "LEFT", -8, 0)
frame.Use = function() useButton:Click() end

local importing = false

local function Layout()
    local character = Plateau.DB.newCharacter and Plateau.DB.saved.global.setupDone
    local y = 0
    ownRow:SetShown(character and #OwnProfiles() > 0 and not importing)
    if ownRow:IsShown() then
        ownRow:Refresh()
        y = ownRow:GetHeight() + 10
    end
    stage:ClearAllPoints()
    stage:SetPoint("TOPLEFT", 0, -y)
    stage:SetShown(not importing)
    if not importing then
        y = y + PREVIEW + 8
    end
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", 0, -y)
    list:SetShown(not importing)
    importView:ClearAllPoints()
    importView:SetPoint("TOPLEFT", 0, -y)
    importView:SetShown(importing)
    local height = y + (importing and importView:GetHeight() or list:GetHeight())
    body:SetHeight(height)
    frame:SetHeight(TITLE + 32 + height + 12 + FOOTER)
    switch.label:SetText(T(importing and "Pick a look instead" or "Paste a profile string instead"))
    switch:Fit()
    useButton:SetShown(not importing)
    skipButton.label:SetText(T(importing and "Close" or "Skip"))
end

switch:SetScript("OnClick", function()
    importing = not importing
    Layout()
end)

local openedWith

local function Finish()
    local DB = Plateau.DB
    DB.saved.global.setupDone = true
    DB.newCharacter = false
    local profile = DB:DefaultProfile()
    if profile ~= openedWith or not DB:AccountProfile() then
        DB:SetAccountProfile(profile)
    end
end

ns.OnRefresh(function()
    if frame:IsShown() and ownRow:IsShown() then
        ownRow:Refresh()
    end
end)

frame:SetScript("OnHide", function(self)
    ns.Widgets.HidePrompts()
    if not self.closedByCombat then
        Finish()
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
    local character = Plateau.DB.newCharacter and Plateau.DB.saved.global.setupDone
    openedWith = Plateau.DB:DefaultProfile()
    chosen = nil
    for _, preset in ipairs(looks) do
        local entry = EntryOf(preset)
        if entry and entry.name == Plateau.DB.profileName then
            chosen = preset
        end
    end
    chosen = chosen or looks[1]
    importing = false
    heading:SetText(T(character and TEXT.characterTitle or TEXT.title))
    intro:SetText(T(character and TEXT.characterIntro or TEXT.intro))
    Layout()
    self:Show()
    PaintRows()
    Plateau.RefreshDirtyPreviews()
end

local conflicts = Style.Dialog("PlateauConflicts", 520, 200)

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
conflictText:SetText("These addons also change nameplates and can conflict with Plateau. Select the ones to disable, or disable Plateau instead. Either reloads your UI.")

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

local disableButton = Widgets.PrimaryButton(conflicts, "Disable selected and reload", 190, function()
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

local keepButton = Widgets.Button(conflicts, "Keep all", 110, function()
    for _, entry in ipairs(conflictList) do
        Plateau.IgnoreConflict(entry.name)
    end
    FinishConflicts()
end)
keepButton:SetPoint("RIGHT", disableButton, "LEFT", -8, 0)

local selfButton = Widgets.Button(conflicts, "Disable Plateau", 130, function()
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
    local none = Style.Text(row, 12, C.muted)
    none:SetPoint("TOPLEFT", 0, -6)
    none:SetText("No other nameplate addons detected.")
    none:Hide()
    row.selfButton = Widgets.Button(row, "Disable Plateau and reload", 250, function()
        Plateau.DisableSelf()
        ReloadUI()
    end)

    function row:Refresh()
        for _, entryRow in ipairs(lines) do
            entryRow:Hide()
        end
        row.selfButton:Hide()
        local list = Plateau.FindConflicts()
        none:SetShown(#list == 0)
        if #list == 0 then
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
                entryRow.button = Widgets.Button(entryRow, "Disable and reload", 150)
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
