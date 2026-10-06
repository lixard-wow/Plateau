local _, ns = ...

local Style = ns.Style
local C = Style.colors

local function ROW_WIDTH() return ns.layout.content end
local ROW_STEP = 36
local NAME_LIMIT = 32

local function ProfileOptions(exclude)
    local options = {}
    for _, name in ipairs(Plateau.DB:ListProfiles()) do
        if name ~= exclude then
            options[#options + 1] = { value = name, label = Plateau.Builtins.Label(name) }
        end
    end
    return options
end

local function BuiltinOptions()
    local options = {}
    for _, entry in ipairs(Plateau.Builtins.list) do
        options[#options + 1] = { value = entry.name, label = entry.name }
    end
    return options
end

local function SetButtonEnabled(button, enabled)
    button:SetEnabled(enabled)
    button:SetAlpha(enabled and 1 or 0.5)
    if button.label then
        local color = enabled and C.text or C.muted
        button.label:SetTextColor(color[1], color[2], color[3])
    end
end

local function Inert(button)
    button:HookScript("OnEnter", function(self)
        if not self:IsEnabled() then
            Style.SetBorderColor(self, C.border)
        end
    end)
end

local DANGER_BORDER = { 0.75, 0.3, 0.3 }
local DANGER_TEXT = { 0.95, 0.62, 0.62 }

local function Danger(button)
    button:HookScript("OnEnter", function(self)
        if self:IsEnabled() then
            Style.SetBorderColor(self, DANGER_BORDER)
            self.label:SetTextColor(DANGER_TEXT[1], DANGER_TEXT[2], DANGER_TEXT[3])
        end
    end)
    button:HookScript("OnLeave", function(self)
        if self:IsEnabled() then
            self.label:SetTextColor(C.text[1], C.text[2], C.text[3])
        end
    end)
end

local function Exists(name)
    return name ~= nil and Plateau.DB.saved.profiles[name] ~= nil
end

local function Refreshed()
    if ns.RefreshAll then
        ns.RefreshAll()
    end
    if ns.UpdateProfileLabel then
        ns.UpdateProfileLabel()
    end
end

local function ShortCharacter(character)
    if character == Plateau.DB.charKey then
        return "this character"
    end
    return character
end

local function AssignmentName(entry)
    local where
    if entry.kind == "content" then
        where = tostring(entry.key)
        for _, content in ipairs(Plateau.CONTENT_TYPES) do
            if content.key == entry.key then
                where = content.label
            end
        end
    else
        where = "specialization " .. tostring(entry.key)
        if entry.character == Plateau.DB.charKey then
            local _, name = C_SpecializationInfo.GetSpecializationInfo(entry.key)
            if name then
                where = name .. " specialization"
            end
        end
    end
    return where .. " (" .. ShortCharacter(entry.character) .. ")"
end

function ns.DeleteWarning(name)
    local DB = Plateau.DB
    local refs = DB:ProfileReferences(name)
    local parts = { "Delete the profile " .. name .. "? Its settings are removed and this can't be undone." }
    if #refs.defaultFor > 0 then
        local who = {}
        for _, character in ipairs(refs.defaultFor) do
            who[#who + 1] = ShortCharacter(character)
        end
        local replacement = DB:FallbackProfile(name)
        parts[#parts + 1] = "It is the default profile for " .. table.concat(who, ", ") .. ". This character keeps using " .. DB.profileName .. " as its default; the others switch to " .. tostring(replacement) .. "."
    end
    if #refs.assignments > 0 then
        local where = {}
        for _, entry in ipairs(refs.assignments) do
            where[#where + 1] = AssignmentName(entry)
        end
        parts[#parts + 1] = "It is assigned to " .. table.concat(where, ", ") .. ". Those automatic assignments are removed, so the next rule or the default profile applies instead."
    end
    return table.concat(parts, "\n\n")
end

function ns.ReplaceWarning(source, destination)
    return "Replace the settings of " .. destination .. " with the settings of " .. source .. "?\n\n" .. destination .. "'s current settings will be overwritten. " .. source .. " is not changed, and no profile is switched."
end

function ns.RestoreWarning(name)
    if Exists(name) then
        return "Restore " .. name .. " to how it shipped?\n\nThe profile exists, so your changes to it will be overwritten. Other profiles are not affected and no profile is switched."
    end
    return name .. " doesn't exist right now (it was deleted or renamed).\n\nThis recreates it as it shipped. No profile is switched."
end

local namePrompt

function ns.Widgets.NamePrompt()
    if namePrompt then return namePrompt end
    local box = CreateFrame("Frame", nil, UIParent)
    box:SetSize(400, 190)
    box:SetPoint("CENTER")
    box:SetFrameStrata("DIALOG")
    box:SetToplevel(true)
    box:EnableMouse(true)
    box:Hide()
    Style.Panel(box, C.window, C.border)
    Style.Card(box)

    local title = Style.Text(box, 15, C.heading)
    title:SetPoint("TOPLEFT", 20, -16)

    local text = Style.Text(box, 11, C.muted)
    text:SetPoint("TOPLEFT", 20, -44)
    text:SetPoint("RIGHT", -20, 0)
    text:SetWordWrap(true)

    local edit = CreateFrame("EditBox", nil, box)
    edit:SetSize(360, 24)
    edit:SetPoint("TOPLEFT", 20, -106)
    edit:SetAutoFocus(false)
    Style.SetFont(edit, Style.font, 12, "")
    edit:SetTextColor(C.text[1], C.text[2], C.text[3])
    edit:SetTextInsets(6, 6, 0, 0)
    edit:SetMaxLetters(NAME_LIMIT)
    Style.Field(edit, C.field, C.border)
    edit:SetScript("OnEditFocusGained", function(self) Style.SetBorderColor(self, Style.StateColor()) end)
    edit:SetScript("OnEditFocusLost", function(self) Style.SetBorderColor(self, C.border) end)

    local message = Style.Text(box, 11, C.warn)
    message:SetPoint("TOPLEFT", 20, -136)
    message:SetPoint("RIGHT", -20, 0)

    local onDone

    local function Submit()
        if not edit:GetText():find("%S") then return end
        local ok, reason = onDone(edit:GetText())
        if ok then
            box:Hide()
        else
            message:SetText(reason or "")
        end
    end

    local create = ns.Widgets.Button(box, "Create", 110, Submit, true)
    create:SetPoint("BOTTOMRIGHT", -20, 14)
    local cancel = ns.Widgets.Button(box, "Cancel", 100, function() box:Hide() end)
    cancel:SetPoint("RIGHT", create, "LEFT", -8, 0)
    edit:SetScript("OnEnterPressed", Submit)
    edit:SetScript("OnEscapePressed", function() box:Hide() end)
    edit:SetScript("OnTextChanged", function(self)
        message:SetText("")
        SetButtonEnabled(create, self:GetText():find("%S") ~= nil)
    end)

    function box:Ask(heading, body, callback, initial, actionLabel)
        title:SetText(heading)
        text:SetText(body)
        message:SetText("")
        edit:SetText(initial or "")
        create.label:SetText(actionLabel or "Create")
        SetButtonEnabled(create, (initial or ""):find("%S") ~= nil)
        onDone = callback
        self:Show()
        edit:SetFocus()
        if initial then
            edit:HighlightText()
        end
    end

    namePrompt = box
    return box
end

local confirmPrompt

function ns.Widgets.ConfirmPrompt()
    if confirmPrompt then return confirmPrompt end
    local box = CreateFrame("Frame", nil, UIParent)
    box:SetWidth(440)
    box:SetPoint("CENTER")
    box:SetFrameStrata("DIALOG")
    box:SetToplevel(true)
    box:EnableMouse(true)
    box:Hide()
    Style.Panel(box, C.window, C.border)
    Style.Card(box)

    local title = Style.Text(box, 15, C.heading)
    title:SetPoint("TOPLEFT", 20, -16)

    local text = Style.Text(box, 11, C.muted)
    text:SetPoint("TOPLEFT", 20, -46)
    text:SetWidth(400)
    text:SetWordWrap(true)

    local onConfirm
    local confirm = ns.Widgets.PrimaryButton(box, "Confirm", 150, function()
        box:Hide()
        if onConfirm then
            onConfirm()
        end
    end)
    confirm:SetPoint("BOTTOMRIGHT", -20, 14)
    local cancel = ns.Widgets.Button(box, "Cancel", 100, function() box:Hide() end)
    cancel:SetPoint("RIGHT", confirm, "LEFT", -8, 0)

    function box:Ask(heading, body, actionLabel, callback)
        title:SetText(heading)
        text:SetText(body)
        confirm.label:SetText(actionLabel)
        confirm.label:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
        onConfirm = callback
        local height = text:GetStringHeight()
        if not height or height <= 0 then
            height = 60
        end
        box:SetHeight(math.ceil(height) + 100)
        self:Show()
    end

    confirmPrompt = box
    return box
end

function ns.Widgets.ProfileStatus(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetHeight(ROW_STEP + 60)

    local notice = Style.Text(frame, 11, C.muted)
    notice:SetWordWrap(true)

    local function Say(text, isError)
        local color = isError and C.warn or C.muted
        notice:SetTextColor(color[1], color[2], color[3])
        notice:SetText(text or "")
    end

    local picker = ns.Widgets.Dropdown(frame, {
        label = "Default profile",
        tooltip = "The profile this character falls back to when no automatic rule applies. Changing it does not replace an automatic override that is active right now.",
        options = function() return ProfileOptions() end,
        get = function() return Plateau.DB:DefaultProfile() end,
        set = function(value)
            local ok, reason = Plateau.DB:SetDefaultProfile(value)
            if not ok then
                Say(reason, true)
                return
            end
            local status = Plateau.AutoProfile:Status()
            if status.pending then
                Say("Default profile is now " .. value .. ". " .. status.pending .. " is applied when combat ends.")
            elseif status.overridden then
                Say("Default profile is now " .. value .. ". " .. status.active .. " stays active because of the " .. tostring(status.rule or "automatic rule") .. ".")
            else
                Say("Default profile is now " .. value .. ".")
            end
        end,
    })
    picker:SetPoint("TOPLEFT", 0, 0)

    local active = Style.Text(frame, 13, C.text)
    active:SetPoint("TOPLEFT", 0, -ROW_STEP)
    local detail = Style.Text(frame, 11, C.muted)
    detail:SetPoint("TOPLEFT", active, "BOTTOMLEFT", 0, -4)
    detail:SetWordWrap(true)
    notice:SetPoint("TOPLEFT", detail, "BOTTOMLEFT", 0, -6)

    function frame:Refresh()
        picker:SetWidth(ROW_WIDTH())
        detail:SetWidth(ROW_WIDTH())
        notice:SetWidth(ROW_WIDTH())
        picker:Refresh()
        local status = Plateau.AutoProfile:Status()
        active:SetText("Active profile: " .. status.active)
        local lines = {}
        if status.overridden then
            lines[#lines + 1] = "Override reason: " .. tostring(status.rule or "automatic switch") .. ". Your default profile is " .. status.default .. "."
        elseif status.rule then
            lines[#lines + 1] = "The " .. status.rule .. " (" .. status.target .. ") replaces this profile the next time you change zone or specialization."
        end
        if status.pending then
            lines[#lines + 1] = "Pending switch: " .. status.pending .. " after combat ends."
        end
        lines[#lines + 1] = "Every page edits the active profile" .. (status.overridden and (", " .. status.active .. ", not the default.") or ".")
        detail:SetText(table.concat(lines, "\n"))
        local height = ROW_STEP + 22 + (detail:GetStringHeight() or 16) + 6 + ((notice:GetText() or "") ~= "" and ((notice:GetStringHeight() or 14) + 6) or 0)
        frame:SetHeight(height)
    end

    return frame
end

local GRID_GAP = 8
local ACTION_WIDTH_COMPACT = 120
local GRID_MAX = 470
local ROW_HEIGHT = 28
local HINT_HEIGHT = 14
local SEPARATION = 12

local function GridWidths()
    local available = ROW_WIDTH() - Style.CONTROL_X
    local total = math.max(300, math.min(available, GRID_MAX))
    return total, total - GRID_GAP - ACTION_WIDTH_COMPACT
end

function ns.Widgets.ProfileActions(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local total, selectWidth = GridWidths()
    local copyY = ROW_HEIGHT * 2 + 4
    local deleteY = copyY + ROW_HEIGHT + HINT_HEIGHT + SEPARATION
    local restoreY = deleteY + ROW_HEIGHT + 2
    frame:SetHeight(restoreY + ROW_HEIGHT + 8 + 30)

    local message = Style.Text(frame, 11, C.muted)
    message:SetPoint("BOTTOMLEFT", 0, 0)
    message:SetPoint("BOTTOMRIGHT", 0, 0)
    message:SetWordWrap(true)

    local function Say(text, isError)
        local color = isError and C.warn or C.muted
        message:SetTextColor(color[1], color[2], color[3])
        message:SetText(text or "")
    end

    local renameChoice, copyChoice, deleteChoice, restoreChoice
    local pickers = {}

    local function AfterChange()
        renameChoice, copyChoice, deleteChoice, restoreChoice = nil, nil, nil, nil
        Refreshed()
    end

    local function Active()
        return Plateau.DB.profileName
    end

    local prompt = ns.Widgets.NamePrompt()
    local confirm = ns.Widgets.ConfirmPrompt()

    local createRow = CreateFrame("Frame", nil, frame)
    createRow:SetSize(Style.CONTROL_X + total, ROW_HEIGHT)
    createRow:SetPoint("TOPLEFT", 0, 0)
    local createLabel = Style.Text(createRow, 12, C.text)
    createLabel:SetPoint("LEFT", 0, 0)
    createLabel:SetText("Create profile")

    local function Create(name, duplicate)
        local trimmed = name:match("^%s*(.-)%s*$")
        local ok, reason = Plateau.DB:CreateProfile(name, duplicate and Active() or nil)
        if ok then
            Say("Created " .. trimmed .. " and switched to it. It is now your active and default profile.")
            AfterChange()
        end
        return ok, reason
    end

    local halfWidth = math.floor((total - GRID_GAP) / 2)
    local create = ns.Widgets.Button(createRow, "New profile", halfWidth, function()
        prompt:Ask("Create new profile", "Name the new profile. It starts with every setting at its default, then becomes your active and default profile.", function(name)
            return Create(name, false)
        end, nil, "Create")
    end)
    create:SetPoint("LEFT", Style.CONTROL_X, 0)
    local duplicate = ns.Widgets.Button(createRow, "Duplicate active", total - GRID_GAP - halfWidth, function()
        prompt:Ask("Duplicate active profile", "Name the new profile. It starts as a copy of " .. Active() .. ", then becomes your active and default profile.", function(name)
            return Create(name, true)
        end, nil, "Duplicate")
    end)
    duplicate:SetPoint("LEFT", create, "RIGHT", GRID_GAP, 0)
    Style.Tooltip(create, { label = "New profile", tooltip = "Makes a new profile with every setting at its default, then switches to it. It becomes your default profile as well as the active one." })
    Style.Tooltip(duplicate, { label = "Duplicate active profile", tooltip = "Makes a new profile that starts as a copy of the active profile, then switches to it. It becomes your default profile as well as the active one." })

    local function PickerRow(y, spec, actionLabel, tooltip, onClick)
        local picker = ns.Widgets.Dropdown(frame, spec)
        picker:SetWidth(Style.CONTROL_X + total)
        picker:SetHeight(ROW_HEIGHT)
        picker.button:SetWidth(selectWidth)
        picker:SetPoint("TOPLEFT", 0, -y)
        pickers[#pickers + 1] = picker
        local button = ns.Widgets.Button(picker, actionLabel, ACTION_WIDTH_COMPACT, onClick)
        button:SetPoint("LEFT", picker.button, "RIGHT", GRID_GAP, 0)
        if tooltip then
            Style.Tooltip(button, { label = spec.label, tooltip = tooltip })
        end
        Inert(button)
        return button
    end

    local renameButton = PickerRow(ROW_HEIGHT + 2, {
        label = "Rename profile",
        options = function() return ProfileOptions() end,
        get = function() return renameChoice or Active() end,
        set = function(value) renameChoice = value end,
    }, "Rename", "Gives the chosen profile a new name. Character selections and automatic assignments that use it follow the new name.", function()
        local old = renameChoice or Active()
        prompt:Ask("Rename profile", "Give " .. old .. " a new name. Any character using it, and any automatic assignment, keeps using it under the new name.", function(name)
            local ok, result = Plateau.DB:RenameProfile(old, name)
            if ok then
                local builtin = Plateau.Builtins.ByName(old)
                Say("Renamed " .. old .. " to " .. result .. "." .. (builtin and (" " .. old .. " is a built-in name, so Restore can bring it back as a separate profile.") or ""))
                AfterChange()
                return true
            end
            return false, result
        end, old, "Rename")
    end)

    local copyButton = PickerRow(copyY, {
        label = "Copy settings from",
        options = function() return ProfileOptions(Active()) end,
        unknown = "Pick a profile",
        get = function() return copyChoice end,
        set = function(value) copyChoice = value end,
    }, "Copy settings", nil, function()
        local source, destination = copyChoice, Active()
        if not Exists(source) then return end
        confirm:Ask("Replace profile settings", ns.ReplaceWarning(source, destination), "Replace settings", function()
            local ok, reason = Plateau.DB:CopyProfile(source)
            Say(ok and ("Replaced the settings of " .. destination .. " with the settings of " .. source .. ".") or reason, not ok)
            AfterChange()
        end)
    end)
    copyButton:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        local accent = Style.StateColor()
        GameTooltip:SetText("Copy settings", accent[1], accent[2], accent[3])
        GameTooltip:AddLine("Replaces the settings of " .. Active() .. " (the active profile) with the settings of the profile you picked. The picked profile is not changed and no profile is switched. You will be asked to confirm.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    copyButton:HookScript("OnLeave", function() GameTooltip:Hide() end)

    local hintFrame = CreateFrame("Frame", nil, frame)
    hintFrame:SetSize(selectWidth, HINT_HEIGHT)
    hintFrame:SetPoint("TOPLEFT", Style.CONTROL_X, -(copyY + ROW_HEIGHT))
    hintFrame:EnableMouse(true)
    local hint = Style.Text(hintFrame, 10, C.muted)
    hint:SetPoint("LEFT", 0, 0)
    hint:SetPoint("RIGHT", 0, 0)
    hintFrame:SetScript("OnEnter", function(self)
        local width = hint:GetStringWidth()
        if width and width > selectWidth then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Destination: " .. Active(), 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    hintFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local deleteButton = PickerRow(deleteY, {
        label = "Delete profile",
        options = function() return ProfileOptions(Active()) end,
        unknown = "Pick a profile",
        get = function() return deleteChoice end,
        set = function(value) deleteChoice = value end,
    }, "Delete", "Deletes the profile you picked. The active profile can't be deleted; switch to another one first. You will be asked to confirm.", function()
        local name = deleteChoice
        if not Exists(name) then return end
        confirm:Ask("Delete profile", ns.DeleteWarning(name), "Delete profile", function()
            local ok, reason = Plateau.DB:DeleteProfile(name)
            Say(ok and ("Deleted " .. name .. ".") or reason, not ok)
            AfterChange()
        end)
    end)
    Danger(deleteButton)

    local restoreButton = PickerRow(restoreY, {
        label = "Restore built-in",
        options = BuiltinOptions,
        unknown = "Pick a profile",
        get = function() return restoreChoice end,
        set = function(value) restoreChoice = value end,
    }, "Restore", "Puts a ready-made profile back to how it shipped. If you deleted or renamed it, this recreates it. If it exists, your changes to it are overwritten. No profile is switched.", function()
        local name = restoreChoice
        if not name then return end
        confirm:Ask("Restore built-in profile", ns.RestoreWarning(name), "Restore profile", function()
            local ok, reason = Plateau.DB:RestoreBuiltin(name)
            Say(ok and ("Restored " .. name .. " to how it shipped.") or reason, not ok)
            AfterChange()
        end)
    end)

    Inert(create)
    Inert(duplicate)

    function frame:Refresh()
        for _, picker in ipairs(pickers) do
            picker:Refresh()
        end
        if copyChoice and not Exists(copyChoice) then copyChoice = nil end
        if deleteChoice and not Exists(deleteChoice) then deleteChoice = nil end
        if renameChoice and not Exists(renameChoice) then renameChoice = nil end
        SetButtonEnabled(renameButton, Exists(renameChoice or Active()))
        SetButtonEnabled(copyButton, copyChoice ~= nil and copyChoice ~= Active())
        SetButtonEnabled(deleteButton, deleteChoice ~= nil and deleteChoice ~= Active())
        SetButtonEnabled(restoreButton, restoreChoice ~= nil)
        hint:SetText("Destination: " .. Active())
    end

    return frame
end

function ns.Widgets.AutoProfiles(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local Auto = Plateau.AutoProfile
    local rows = {}
    local columnWidth = ns.layout.column
    local HEADING = 24

    local function Options()
        local options = { { value = "", label = "No override" } }
        for _, option in ipairs(ProfileOptions()) do
            options[#options + 1] = option
        end
        return options
    end

    local function Heading(text, x)
        local heading = Style.Text(frame, 12, Style.StateColor())
        heading:SetPoint("TOPLEFT", x, 0)
        heading:SetText(text)
    end

    local function AddRow(kind, key, label, column, index)
        local row = ns.Widgets.Dropdown(frame, {
            label = label,
            options = Options,
            tooltip = "Uses this profile when " .. (kind == "content" and ("you are in " .. label:lower()) or ("you play " .. label)) .. ". No override means this rule does not apply, so the next rule is checked, and your default profile is used when none applies.",
            get = function() return Auto:Get(kind, key) end,
            set = function(value)
                Auto:Set(kind, key, value)
                Refreshed()
            end,
        })
        row:SetWidth(columnWidth)
        row:SetPoint("TOPLEFT", column == 1 and 0 or (columnWidth + 24), -(HEADING + (index - 1) * ROW_STEP))
        rows[#rows + 1] = row
    end

    Heading("Content", 0)
    Heading("Specialization", columnWidth + 24)

    local contentCount = 0
    for _, content in ipairs(Plateau.CONTENT_TYPES) do
        contentCount = contentCount + 1
        AddRow("content", content.key, content.label, 1, contentCount)
    end
    local classID = select(3, UnitClass("player"))
    local specs = classID and C_SpecializationInfo.GetNumSpecializationsForClassID(classID) or 0
    for index = 1, specs do
        local _, name = C_SpecializationInfo.GetSpecializationInfo(index)
        AddRow("spec", index, name or ("Specialization " .. index), 2, index)
    end

    frame:SetHeight(HEADING + math.max(contentCount, specs) * ROW_STEP)

    function frame:Refresh()
        for _, row in ipairs(rows) do
            row:Refresh()
        end
    end

    return frame
end

local SHARE_BUTTON, SHARE_BOX_HEIGHT = 190, 90

local function ShareBox(frame)
    local box = CreateFrame("ScrollFrame", nil, frame)
    box:SetSize(ROW_WIDTH(), SHARE_BOX_HEIGHT)
    Style.Field(box, C.field, C.border)
    local edit = CreateFrame("EditBox", nil, box)
    edit:SetMultiLine(true)
    edit:SetMaxLetters(0)
    edit:SetMaxBytes(0)
    edit:SetAutoFocus(false)
    Style.SetFont(edit, Style.font, 10, "")
    edit:SetTextColor(C.text[1], C.text[2], C.text[3])
    edit:SetWidth(ROW_WIDTH() - 12)
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
    return edit, box
end

function ns.Widgets.ShareProfile(parent)
    local frame = CreateFrame("Frame", nil, parent)
    local activate = false
    local exported = false

    local function Heading(text)
        local heading = Style.Text(frame, 13, Style.StateColor())
        heading:SetText(text)
        return heading
    end

    local exportHeading = Heading("Export")
    local exportTarget = Style.Text(frame, 12, C.text)
    local exportEdit, exportBox = ShareBox(frame)
    local exportLabel = Style.Text(frame, 12, C.muted)
    exportLabel:SetText("Profile export string")
    local exportHelp = Style.Text(frame, 11, C.muted)
    exportHelp:SetText("Click the box, press Ctrl+A to select everything, then Ctrl+C to copy it. Paste it wherever you want to share it.")
    exportHelp:SetWordWrap(true)
    local export = ns.Widgets.Button(frame, "Export active profile", SHARE_BUTTON, function()
        exportEdit:SetText(Plateau.DB:ExportProfile())
        exported = true
        frame:Layout()
        if ns.RefreshAll then
            ns.RefreshAll()
        end
        exportEdit:SetFocus()
        exportEdit:HighlightText()
    end)
    Style.Tooltip(export, { label = "Export active profile", tooltip = "Turns the active profile into a text string: its full look and its aura spell lists. It does not include your default profile, automatic switching rules, Game settings or Plateau settings." })

    local importHeading = Heading("Import")
    local importLabel = Style.Text(frame, 12, C.text)
    importLabel:SetText("Paste a Plateau profile string")
    local importEdit, importBox = ShareBox(frame)
    local importMessage = Style.Text(frame, 11, C.muted)
    importMessage:SetWordWrap(true)
    local nameLabel = Style.Text(frame, 12, C.text)
    nameLabel:SetText("Profile name (optional)")
    local nameBox = CreateFrame("EditBox", nil, frame)
    nameBox:SetSize(220, 22)
    nameBox:SetAutoFocus(false)
    Style.SetFont(nameBox, Style.font, 11, "")
    nameBox:SetTextColor(C.text[1], C.text[2], C.text[3])
    nameBox:SetTextInsets(6, 6, 0, 0)
    nameBox:SetMaxLetters(NAME_LIMIT)
    Style.Field(nameBox, C.field, C.border)
    nameBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    Style.Tooltip(nameBox, { label = "Profile name (optional)", tooltip = "Leave it empty to call the new profile Imported. A name that is already used is refused; nothing is overwritten." })

    local activateToggle = ns.Widgets.Toggle(frame, {
        label = "Activate after import",
        tooltip = "Off: the imported profile is saved as a new profile and nothing else changes. On: it also becomes your active and default profile, or is applied when combat ends. An automatic rule can still replace it when content or specialization changes.",
        get = function() return activate end,
        set = function(value) activate = value == true end,
    })

    local import = ns.Widgets.PrimaryButton(frame, "Import profile", SHARE_BUTTON, function()
        local ok, name, state = Plateau.DB:ImportProfile(nameBox:GetText(), importEdit:GetText(), activate)
        if ok then
            local color = C.muted
            importMessage:SetTextColor(color[1], color[2], color[3])
            if not activate then
                importMessage:SetText("Imported as " .. name .. ". It is saved but not active.")
            elseif state == "deferred" then
                importMessage:SetText("Imported as " .. name .. ". It becomes your default profile and is applied when combat ends, unless an automatic rule applies.")
            elseif Plateau.DB.profileName == name then
                importMessage:SetText("Imported as " .. name .. ". It is your active and default profile now; an automatic rule can replace it when content or specialization changes.")
            else
                importMessage:SetText("Imported as " .. name .. ". It is your default profile, but an automatic rule keeps " .. Plateau.DB.profileName .. " active.")
            end
            nameBox:SetText("")
            importEdit:SetText("")
            Refreshed()
        else
            local reason = name or "the import failed"
            if reason:find("already exists") then
                reason = reason .. ". Type a different name, or leave it empty."
            end
            importMessage:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
            importMessage:SetText(reason)
        end
        frame:Layout()
    end)
    Style.Tooltip(import, { label = "Import profile", tooltip = "Checks the pasted string first, then saves it as a new profile. Nothing is changed if the string is refused." })

    local function UpdateImport()
        SetButtonEnabled(import, importEdit:GetText():find("%S") ~= nil)
    end
    importEdit:SetScript("OnTextChanged", function()
        importMessage:SetText("")
        UpdateImport()
    end)

    function frame:Layout()
        local width = ROW_WIDTH()
        local y = 0
        exportHeading:ClearAllPoints()
        exportHeading:SetPoint("TOPLEFT", 0, -y)
        y = y + 24
        exportTarget:ClearAllPoints()
        exportTarget:SetPoint("TOPLEFT", 0, -y)
        exportTarget:SetText("Profile to export: " .. Plateau.DB.profileName)
        y = y + 22
        export:ClearAllPoints()
        export:SetPoint("TOPLEFT", 0, -y)
        y = y + 30
        exportLabel:SetShown(exported)
        exportBox:SetShown(exported)
        exportHelp:SetShown(exported)
        if exported then
            exportLabel:ClearAllPoints()
            exportLabel:SetPoint("TOPLEFT", 0, -y)
            y = y + 18
            exportBox:ClearAllPoints()
            exportBox:SetPoint("TOPLEFT", 0, -y)
            y = y + SHARE_BOX_HEIGHT + 6
            exportHelp:ClearAllPoints()
            exportHelp:SetPoint("TOPLEFT", 0, -y)
            exportHelp:SetWidth(width)
            y = y + 34
        end
        y = y + 16
        importHeading:ClearAllPoints()
        importHeading:SetPoint("TOPLEFT", 0, -y)
        y = y + 24
        importLabel:ClearAllPoints()
        importLabel:SetPoint("TOPLEFT", 0, -y)
        y = y + 18
        importBox:ClearAllPoints()
        importBox:SetPoint("TOPLEFT", 0, -y)
        y = y + SHARE_BOX_HEIGHT + 4
        importMessage:ClearAllPoints()
        importMessage:SetPoint("TOPLEFT", 0, -y)
        importMessage:SetWidth(width)
        y = y + 34
        nameLabel:ClearAllPoints()
        nameLabel:SetPoint("TOPLEFT", 0, -(y + 4))
        nameBox:ClearAllPoints()
        nameBox:SetPoint("TOPLEFT", Style.CONTROL_X, -y)
        y = y + 32
        activateToggle:ClearAllPoints()
        activateToggle:SetPoint("TOPLEFT", 0, -y)
        activateToggle:SetWidth(ns.layout.column)
        y = y + 32
        import:ClearAllPoints()
        import:SetPoint("TOPLEFT", 0, -y)
        y = y + 30
        frame:SetHeight(y)
    end

    function frame:Refresh()
        activateToggle:Refresh()
        UpdateImport()
        self:Layout()
    end

    frame:Layout()
    return frame
end
