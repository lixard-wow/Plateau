local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH, HEIGHT = 740, 740
local PAD = 20
local TITLE = 48
local FOOTER = 56
local CONTENT_WIDTH = WIDTH - PAD * 2
local ROW_WIDTH = CONTENT_WIDTH
local SPACING = 6
local COLUMN_GAP = 12
local HALF_WIDTH = (CONTENT_WIDTH - COLUMN_GAP) / 2

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

local PAGE = {
    title = "Pick a look",
    intro = "Each look is a ready-made profile. Choosing one makes it your active and default profile, and new characters start with it too. Fine-tune it any time with /plt.",
    characterTitle = "Pick a profile for this character",
    characterIntro = "This character doesn't have a profile yet. Use one you already set up, paste a profile string, or pick a ready-made look. Change it any time with /plt.",
    controls = function()
        local list = {}
        if #OwnProfiles() > 0 then
            list[#list + 1] = { type = "Header", label = "Use a profile you already have", first = true }
            list[#list + 1] = { type = "Dropdown", label = "Profile",
                tooltip = "Makes this your active profile and the default for this character.",
                options = OwnProfiles,
                get = function() return Plateau.DB:DefaultProfile() end,
                set = function(value) Plateau.DB:SetDefaultProfile(value) end }
        end
        list[#list + 1] = { type = "Header", label = "Import a profile string", first = #list == 0 }
        list[#list + 1] = { type = "SetupImport", wide = true }
        list[#list + 1] = { type = "Header", label = "Or start from a ready-made look" }
        list[#list + 1] = { type = "LookCards", presets = ns.AllLooks(), width = CONTENT_WIDTH, wide = true, mode = "profile" }
        return list
    end,
}

function Widgets.SetupImport(parent)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(IMPORT_BOX_HEIGHT + 56)

    local box = CreateFrame("ScrollFrame", nil, row)
    box:SetPoint("TOPLEFT")
    box:SetPoint("TOPRIGHT")
    box:SetHeight(IMPORT_BOX_HEIGHT)
    Style.Field(box, C.field, C.border)
    local edit = CreateFrame("EditBox", nil, box)
    edit:SetMultiLine(true)
    edit:SetMaxLetters(0)
    edit:SetMaxBytes(65000)
    edit:SetAutoFocus(false)
    Style.SetFont(edit, Style.font, 10, "")
    Style.PaintText(edit, C.text)
    edit:SetWidth(CONTENT_WIDTH - 12)
    edit:SetTextInsets(6, 6, 6, 6)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScrollChild(edit)
    box:EnableMouseWheel(true)
    box:SetScript("OnMouseWheel", function(self, delta)
        local offset, range = self:GetVerticalScroll(), self:GetVerticalScrollRange()
        if issecretvalue(offset) or issecretvalue(range) then return end
        self:SetVerticalScroll(math.max(0, math.min(range, offset - delta * 30)))
    end)
    box:SetScript("OnMouseDown", function() edit:SetFocus() end)

    local message = Style.Text(row, 11, C.muted)
    message:SetWordWrap(true)
    message:SetJustifyH("LEFT")

    local import = Widgets.Button(row, "Import and use", 140, function()
        local ok, name, state, reload = Plateau.DB:ImportProfile(nil, edit:GetText(), true)
        if ok then
            Style.PaintText(message, C.muted)
            if state == "deferred" then
                message:SetText(T("Imported as %s. It becomes active when combat ends."):format(name))
            else
                message:SetText(T("Imported as %s and now active."):format(name))
            end
            local missing = Plateau.DB:MissingMedia(name)
            if #missing > 0 then
                message:SetText(message:GetText() .. " " .. T("Some fonts or textures come from addons not installed here, so defaults are used: %s."):format(table.concat(missing, ", ")))
            end
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
frame:SetSize(WIDTH, HEIGHT)
frame:SetPoint("TOP", UIParent, "CENTER", 0, HEIGHT / 2)
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:Hide()
Style.Panel(frame, C.window, C.border)
Style.Card(frame)
tinsert(UISpecialFrames, "PlateauSetup")
frame:SetScale(Style.PixelScale())
frame:HookScript("OnShow", function(self) Style.FitWindow(self) end)

local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT")
titleBar:SetPoint("TOPRIGHT")
titleBar:SetHeight(TITLE)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
local function StopMoving()
    frame:StopMovingOrSizing()
    Style.SnapWindow(frame)
end
titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
titleBar:SetScript("OnDragStop", StopMoving)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", StopMoving)

local logo = titleBar:CreateTexture(nil, "ARTWORK")
logo:SetSize(32, 32)
logo:SetPoint("LEFT", PAD, 0)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local heading = Style.Text(titleBar, 16, C.text)
heading:SetPoint("LEFT", logo, "RIGHT", 10, 0)

local line = titleBar:CreateTexture(nil, "ARTWORK")
Style.Paint(line, C.line)
Style.PixelHeight(line)
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
Style.PixelHeight(footerLine)
Style.Paint(footerLine, C.border, 1)

local page

local WHEEL_STEP = 40

local function Scroller(page, height)
    local scroll = CreateFrame("ScrollFrame", nil, body)
    scroll:SetAllPoints()
    page:SetParent(scroll)
    page:SetSize(CONTENT_WIDTH, math.max(height, 1))
    scroll:SetScrollChild(page)
    scroll.controls = page.controls

    local track = scroll:CreateTexture(nil, "ARTWORK")
    track:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 8, 0)
    track:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 8, 0)
    track:SetWidth(3)
    Style.Paint(track, C.border, 0.6)
    local thumb = scroll:CreateTexture(nil, "OVERLAY")
    thumb:SetWidth(3)
    Style.Paint(thumb, C.accent, 0.9)

    local function Update()
        local view = scroll:GetHeight()
        local range = math.max(0, height - view)
        local shown = range > 0 and view > 0
        track:SetShown(shown)
        thumb:SetShown(shown)
        if not shown then
            scroll:SetVerticalScroll(0)
            return
        end
        local offset = math.min(scroll:GetVerticalScroll(), range)
        scroll:SetVerticalScroll(offset)
        local size = math.max(24, view * view / height)
        thumb:SetHeight(size)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP", track, "TOP", 0, -(view - size) * offset / range)
    end

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local range = math.max(0, height - self:GetHeight())
        self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * WHEEL_STEP)))
        Update()
    end)
    scroll:SetScript("OnSizeChanged", Update)
    scroll:SetScript("OnShow", Update)
    return scroll
end

local function BuildPage()
    local page = CreateFrame("Frame", nil, body)
    page:SetSize(CONTENT_WIDTH, 1)
    page.controls = {}
    local y = 0
    local column, rowTop, rowHeight = 0, 0, 0
    local function EndRow()
        if column == 1 then
            y = rowTop + rowHeight + SPACING
            column = 0
        end
    end
    for _, spec in ipairs(PAGE.controls()) do
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
    return Scroller(page, y)
end

local function Refresh()
    for _, control in ipairs(page.controls) do
        control:Refresh()
    end
end

ns.OnRefresh(function()
    if frame:IsShown() and page then
        Refresh()
    end
end)

local openedWith

local function Finish()
    local DB = Plateau.DB
    DB.saved.global.setupDone = true
    DB.newCharacter = false
    local chosen = DB:DefaultProfile()
    if chosen ~= openedWith or not DB:AccountProfile() then
        DB:SetAccountProfile(chosen)
    end
end

local function Done(openOptions)
    Finish()
    frame:Hide()
    if openOptions and PlateauOptions then
        PlateauOptions:Show()
    end
end

local openButton = Widgets.PrimaryButton(frame, "Open settings", 130, function() Done(true) end)
openButton:SetPoint("BOTTOMRIGHT", -PAD, 14)

local doneButton = Widgets.Button(frame, "Done", 90, function() Done(false) end)
doneButton:SetPoint("RIGHT", openButton, "LEFT", -8, 0)

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
    self:Show()
    heading:SetText(character and PAGE.characterTitle or PAGE.title)
    intro:SetText(character and PAGE.characterIntro or PAGE.intro)
    page = page or BuildPage()
    page:Show()
    Refresh()
    Plateau.RefreshDirtyPreviews()
end

local conflicts = CreateFrame("Frame", "PlateauConflicts", UIParent)
conflicts:SetSize(520, 200)
conflicts:SetPoint("CENTER")
conflicts:SetFrameStrata("DIALOG")
conflicts:SetToplevel(true)
conflicts:EnableMouse(true)
conflicts:Hide()
Style.Panel(conflicts, C.window, C.border)
Style.Card(conflicts)

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
