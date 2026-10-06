local _, ns = ...

local Style = ns.Style
local C = Style.colors

function ns.Widgets.Button(parent, text, width, onClick, primary)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, 22)
    if primary then
        Style.ButtonBox(button, C.primary, nil, C.primaryBorder, C.primaryHover)
    else
        Style.ButtonBox(button)
    end

    local color = primary and C.primaryText or C.buttonText
    button.label = Style.Text(button, 11, color, "CENTER")
    Style.SetFont(button.label, Style.buttonFont, Style.BUTTON_SIZE, "")
    button.label:SetPoint("LEFT", 6, 0)
    button.label:SetPoint("RIGHT", -6, 0)
    button.label:SetText(text)
    button:HookScript("OnMouseDown", function(self) self.label:SetPoint("LEFT", 6, -1) self.label:SetPoint("RIGHT", -6, -1) end)
    button:HookScript("OnMouseUp", function(self) self.label:SetPoint("LEFT", 6, 0) self.label:SetPoint("RIGHT", -6, 0) end)

    button:SetScript("OnClick", onClick)
    return button
end

function ns.Widgets.PrimaryButton(parent, text, width, onClick)
    return ns.Widgets.Button(parent, text, width, onClick, true)
end

function ns.Widgets.Header(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(spec.first and 24 or 36)

    local tick = row:CreateTexture(nil, "ARTWORK")
    tick:SetSize(3, 12)
    tick:SetPoint("BOTTOMLEFT", 0, 7)
    local tint = Style.StateColor()
    tick:SetColorTexture(tint[1], tint[2], tint[3], 1)

    local text = Style.Text(row, 13, C.heading)
    Style.SetFont(text, Style.sectionFont, Style.SECTION_SIZE + 1, "")
    text:SetPoint("BOTTOMLEFT", tick, "BOTTOMRIGHT", 8, -1)
    text:SetText(spec.label)

    local line = row:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT")
    line:SetPoint("BOTTOMRIGHT")
    line:SetHeight(1)
    line:SetColorTexture(C.line[1], C.line[2], C.line[3], 1)

    if spec.collapsible then
        row:EnableMouse(true)
        local state = Style.Text(row, 11, C.muted)
        state:SetPoint("BOTTOMRIGHT", 0, 6)
        function row:SetCollapsed(collapsed)
            state:SetText(collapsed and "Show" or "Hide")
        end
        row:SetCollapsed(spec.collapsed == true)
        row:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" and spec.onToggle then
                spec.onToggle()
            end
        end)
        row:SetScript("OnEnter", function()
            local tint = Style.StateColor()
            state:SetTextColor(tint[1], tint[2], tint[3])
        end)
        row:SetScript("OnLeave", function()
            state:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
        end)
        Style.Tooltip(row, { label = spec.label, tooltip = "Click to show or hide these settings. Searching for a setting inside opens the section for you." })
    end
    return row
end

function ns.Widgets.Link(parent, spec)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(24)
    local text = Style.Text(row, 12, Style.StateColor())
    text:SetPoint("LEFT", 0, 0)
    text:SetText(spec.label .. "  >")
    row:SetWidth(text:GetStringWidth() + 8)
    row:SetScript("OnClick", function()
        if ns.OpenLink then
            ns.OpenLink(spec.target)
        end
    end)
    row:SetScript("OnEnter", function() text:SetTextColor(C.text[1], C.text[2], C.text[3]) end)
    row:SetScript("OnLeave", function()
        local tint = Style.StateColor()
        text:SetTextColor(tint[1], tint[2], tint[3])
    end)
    Style.Tooltip(row, { label = spec.label, tooltip = spec.tooltip })
    function row:SetWidth() end
    return row
end

local WARN_ICON = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:12:12:0:0|t "

function ns.Widgets.Note(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    local text = Style.Text(row, spec.size or 12, spec.warn and C.warn or (spec.bright and C.text or C.muted))
    local prefix = spec.warn and WARN_ICON or ""
    text:SetWordWrap(true)
    if spec.bright then
        text:SetSpacing(3)
    end
    local top = spec.padTop or 0
    text:SetPoint("TOPLEFT", 0, -4 - top)
    row:SetHeight(spec.height or 32)
    local SetWidth = row.SetWidth
    local function Fit()
        local height = text:GetStringHeight()
        if height and height > 0 then
            row:SetHeight(math.ceil(height) + 10 + top)
        end
    end
    function row:SetWidth(width)
        SetWidth(self, width)
        text:SetWidth(width)
        Fit()
    end
    if type(spec.label) == "function" then
        function row:Refresh()
            text:SetText(prefix .. spec.label())
            Fit()
        end
        row:Refresh()
    else
        text:SetText(prefix .. spec.label)
    end
    return row
end

function ns.Widgets.PriorityList(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    local ROW = 24
    local DROP = 30
    row:SetHeight(#spec.keys * ROW + 6 + DROP)
    local holder = CreateFrame("Frame", nil, row)
    holder:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -DROP)
    holder:SetPoint("RIGHT", row, "RIGHT")
    holder:SetHeight(#spec.keys * ROW)
    local label = Style.Text(row, 12, C.text)
    label:SetPoint("TOPLEFT", 0, -5)
    label:SetWidth(Style.LABEL_WIDTH)
    label:SetWordWrap(true)
    label:SetText(spec.label)
    row.label = label

    local hint = Style.Text(row, 10, C.muted)
    hint:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -3)
    hint:SetWidth(Style.LABEL_WIDTH)
    hint:SetWordWrap(true)
    hint:SetText("Drag any row up or down to reorder")

    local function Order()
        local list, seen = {}, {}
        for key in tostring(ns.Get(spec.path)):gmatch("%a+") do
            if not seen[key] and spec.names[key] then
                seen[key] = true
                list[#list + 1] = key
            end
        end
        return ns.PriorityOrder.Complete(list, spec.keys)
    end

    local lines = {}
    local drag

    local function Rest()
        for i, line in ipairs(lines) do
            line:ClearAllPoints()
            line:SetPoint("TOP", holder, "TOP", 0, -(i - 1) * ROW)
            line:SetFrameLevel(line.baseLevel)
            line.grab:SetAlpha(0)
        end
    end

    local function Layout()
        local top = holder:GetTop()
        if not top then return end
        local _, cursorY = GetCursorPosition()
        local offset = top - cursorY / row:GetEffectiveScale()
        drag.to = ns.PriorityOrder.SlotAt(offset, ROW, #lines)
        for position, original in ipairs(ns.PriorityOrder.Display(#lines, drag.from, drag.to)) do
            if original ~= drag.from then
                local line = lines[original]
                line:ClearAllPoints()
                line:SetPoint("TOP", holder, "TOP", 0, -(position - 1) * ROW)
            end
        end
        local held = lines[drag.from]
        held:ClearAllPoints()
        held:SetPoint("TOP", holder, "TOP", 0, -math.max(0, math.min((#lines - 1) * ROW, offset - ROW / 2)))
    end

    local function StopDrag(apply)
        if not drag then return end
        local finished = drag
        drag = nil
        row:SetScript("OnUpdate", nil)
        if apply and finished.to ~= finished.from then
            ns.Set(spec.path, table.concat(ns.PriorityOrder.Reorder(Order(), finished.from, finished.to), ","))
        end
        Rest()
        row:Refresh()
    end

    local function StartDrag(index)
        if drag then return end
        drag = { from = index, to = index }
        lines[index]:SetFrameLevel(lines[index].baseLevel + 20)
        lines[index].grab:SetAlpha(1)
        row:SetScript("OnUpdate", Layout)
        Layout()
    end

    local function Move(index, step)
        local list = Order()
        local target = index + step
        if target < 1 or target > #list then return end
        list[index], list[target] = list[target], list[index]
        ns.Set(spec.path, table.concat(list, ","))
        row:Refresh()
    end

    for i = 1, #spec.keys do
        local line = CreateFrame("Frame", nil, row)
        line:SetHeight(ROW)
        line:SetPoint("TOP", holder, "TOP", 0, -(i - 1) * ROW)
        line:SetWidth(300)
        line.baseLevel = line:GetFrameLevel()
        line.grab = line:CreateTexture(nil, "BACKGROUND")
        line.grab:SetAllPoints()
        local tint = Style.StateColor()
        line.grab:SetColorTexture(tint[1], tint[2], tint[3], 0.25)
        line.grab:SetAlpha(0)
        line.hover = line:CreateTexture(nil, "BACKGROUND")
        line.hover:SetAllPoints()
        line.hover:SetColorTexture(1, 1, 1, 0.07)
        line.hover:Hide()
        for bar = 1, 3 do
            local grip = line:CreateTexture(nil, "ARTWORK")
            grip:SetSize(10, 2)
            grip:SetPoint("LEFT", 3, (2 - bar) * 4)
            grip:SetColorTexture(C.muted[1], C.muted[2], C.muted[3], 0.9)
        end
        line:EnableMouse(true)
        line:RegisterForDrag("LeftButton")
        line:SetScript("OnEnter", function(self) if not drag then self.hover:Show() end end)
        line:SetScript("OnLeave", function(self) self.hover:Hide() end)
        line:SetScript("OnDragStart", function(self) self.hover:Hide(); StartDrag(i) end)
        line:SetScript("OnDragStop", function() StopDrag(true) end)
        line.rank = Style.Text(line, 11, C.muted)
        line.rank:SetPoint("LEFT", 24, 0)
        line.rank:SetWidth(30)
        line.rank:SetJustifyH("LEFT")
        line.name = Style.Text(line, 12, C.text)
        line.name:SetPoint("LEFT", 62, 0)
        line.up = ns.Widgets.Button(line, "Up", 48, function() Move(i, -1) end)
        line.up:SetPoint("RIGHT", -54, 0)
        line.down = ns.Widgets.Button(line, "Down", 48, function() Move(i, 1) end)
        line.down:SetPoint("RIGHT", 0, 0)
        lines[i] = line
    end

    row:HookScript("OnHide", function() StopDrag(false) end)

    function row:Refresh()
        local list = Order()
        for i, line in ipairs(lines) do
            local key = list[i]
            line.rank:SetText(tostring(i))
            line.name:SetText(spec.names[key])
            line.up:SetEnabled(i > 1)
            line.up:SetAlpha(i > 1 and 1 or 0.35)
            line.down:SetEnabled(i < #list)
            line.down:SetAlpha(i < #list and 1 or 0.35)
        end
        Style.OverrideLabel(label, spec)
    end

    local labelHit = CreateFrame("Frame", nil, row)
    labelHit:SetPoint("TOPLEFT", label, "TOPLEFT", -2, 2)
    labelHit:SetPoint("BOTTOMRIGHT", hint, "BOTTOMRIGHT", 2, -2)
    labelHit:EnableMouse(true)
    Style.RightClickReset(labelHit, spec, function() row:Refresh() end)
    Style.Tooltip(labelHit, spec)
    return row
end

function ns.Widgets.Actions(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(28)
    local previous
    for _, item in ipairs(spec.buttons) do
        local button = ns.Widgets.Button(row, item.label, item.width, item.click)
        if previous then
            button:SetPoint("LEFT", previous, "RIGHT", 8, 0)
        else
            button:SetPoint("LEFT", 0, 0)
        end
        previous = button
    end
    return row
end

function ns.Widgets.Presets(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(28)
    local buttons = {}
    local function Same(a, b)
        if type(a) == "table" and type(b) == "table" then
            for i = 1, 3 do
                if math.abs((a[i] or 0) - (b[i] or 0)) > 0.001 then
                    return false
                end
            end
            return true
        end
        return a == b
    end
    local function ValuesActive(values)
        for path, value in pairs(values) do
            if not Same(ns.Get(path), value) then
                return false
            end
        end
        return true
    end
    local function LabelColor(button)
        local color = button.active and Style.StateColor() or C.text
        button.label:SetTextColor(color[1], color[2], color[3])
    end
    function row:Refresh()
        for _, button in ipairs(buttons) do
            local preset = button.preset
            if preset.isActive then
                button.active = preset.isActive() == true
            else
                button.active = preset.values ~= nil and ValuesActive(preset.values)
            end
            local tint = Style.StateColor()
            button.activeBar:SetColorTexture(tint[1], tint[2], tint[3], 1)
            button.activeBar:SetShown(button.active)
            LabelColor(button)
        end
    end
    local x = 0
    for _, preset in ipairs(spec.presets) do
        local button = ns.Widgets.Button(row, preset.label, 118)
        local width = math.max(118, math.ceil(button.label:GetStringWidth()) + 28)
        button:SetWidth(width)
        button:SetPoint("LEFT", x, 0)
        button.preset = preset
        local bar = button:CreateTexture(nil, "OVERLAY")
        bar:SetPoint("BOTTOMLEFT", 1, 1)
        bar:SetPoint("BOTTOMRIGHT", -1, 1)
        bar:SetHeight(2)
        bar:SetColorTexture(C.accent[1], C.accent[2], C.accent[3], 1)
        bar:Hide()
        button.activeBar = bar
        buttons[#buttons + 1] = button
        x = x + width + 6
        local armed = false
        button:SetScript("OnClick", function(self)
            if not armed then
                armed = true
                self.label:SetText("Click to apply")
                self.label:SetTextColor(C.warn[1], C.warn[2], C.warn[3])
                C_Timer.After(3, function()
                    armed = false
                    self.label:SetText(preset.label)
                    LabelColor(self)
                end)
                return
            end
            armed = false
            self.label:SetText(preset.label)
            LabelColor(self)
            if preset.apply then
                preset.apply()
            else
                ns.Undo.Next("Look: " .. preset.label)
                Plateau.DB:SetMany(preset.values)
            end
            if ns.RefreshAll then
                ns.RefreshAll()
            end
            row:Refresh()
        end)
        Style.Tooltip(button, { label = preset.label, tooltip = preset.tooltip })
    end
    row:Refresh()
    return row
end

local CARD_WIDTH, CARD_GAP, CARD_INSET, CARD_EDGE, CARD_TAG, CARD_BUTTON = 156, 16, 14, 3, 18, 28

function ns.AllLooks()
    local list = {}
    for _, group in ipairs({ Plateau.presets.looks, Plateau.presets.styles }) do
        for _, preset in ipairs(group) do
            list[#list + 1] = preset
        end
    end
    return list
end
local SAMPLE_HEIGHT = 84

local function Same(a, b)
    if type(a) == "table" and type(b) == "table" then
        for i = 1, 4 do
            if math.abs((a[i] or 1) - (b[i] or 1)) > 0.001 then
                return false
            end
        end
        return true
    end
    return a == b
end

local function Matches(preset)
    for path, value in pairs(preset.values) do
        if not Same(value, ns.Get(path)) then
            return false
        end
    end
    return true
end

local function CardSample()
    return {
        health = 0.72,
        maxHealth = 72700,
        name = "Wastelander Phaseblade",
        levelOffset = 1,
        classification = "elite",
        mobType = "caster",
        raidMarker = 8,
        auras = { mine = 2, cc = 1, purge = 1 },
        absorb = 0,
        alerts = {},
        cast = {
            progress = 0.6,
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            timer = "1.4",
        },
    }
end

local function DrawSample(area, preset, ratio)
    local look = Plateau.PresetLook(preset)
    local name = "sample:" .. preset.key
    Plateau.SetSampleLook(name, look)
    local holder = CreateFrame("Frame", nil, area)
    holder:SetSize(1, 1)
    holder:SetPoint("CENTER", 0, 0)
    holder:SetScale(math.min(0.62, 118 / look.plate.width) * ratio)
    local plate = Plateau.CreatePreview(holder, CardSample(), name)
    plate:SetPoint("CENTER")
end

function ns.CardMode(spec)
    if spec and spec.mode then
        return spec.mode
    end
    return Plateau.DB.saved.global.cardMode or "profile"
end

local function CardProfile(spec, preset)
    local entry = Plateau.Builtins.ForPreset(preset)
    if entry and ns.CardMode(spec) == "profile" then
        return entry.name
    end
    return nil
end

function ns.Widgets.LookCards(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    local count = #spec.presets
    local stripWidth = spec.width or ns.layout.content
    local cardWidth = math.floor((stripWidth - (count - 1) * CARD_GAP) / count)
    local ratio = (cardWidth - CARD_INSET * 2) / CARD_WIDTH
    local previewHeight = math.floor(SAMPLE_HEIGHT * ratio)
    local cardHeight = CARD_EDGE + 14 + 16 + 4 + 10 + 12 + previewHeight + 12 + 42 + 12 + CARD_BUTTON + CARD_INSET
    row:SetHeight(CARD_TAG + cardHeight + 6)
    local cards = {}
    local strip = CreateFrame("Frame", nil, row)
    strip:SetSize(stripWidth, CARD_TAG + cardHeight)
    strip:SetPoint("TOP")

    local function Apply(preset)
        local profile = CardProfile(spec, preset)
        if profile then
            Plateau.DB:UseBuiltin(profile)
            if ns.UpdateProfileLabel then
                ns.UpdateProfileLabel()
            end
        else
            ns.Undo.Next("Look: " .. preset.label)
            Plateau.DB:SetMany(preset.values)
        end
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end

    for i, preset in ipairs(spec.presets) do
        local accent = type(preset.accent) == "table" and preset.accent or Plateau.brand[preset.accent or 1] or C.accent
        local card = CreateFrame("Frame", nil, strip)
        card:SetSize(cardWidth, cardHeight)
        card:SetPoint("TOPLEFT", (i - 1) * (cardWidth + CARD_GAP), -CARD_TAG)
        card:EnableMouse(true)
        Style.Fill(card, C.field)
        Style.Border(card, C.border)
        if Style.theme.brackets then
            Style.Brackets(card, accent, 7, 2)
        end

        card.tag = Style.Text(strip, 10, accent, "CENTER")
        card.tag:SetPoint("BOTTOM", card, "TOP", 0, 5)
        card.tag:SetText("IN USE")

        card.edge = card:CreateTexture(nil, "ARTWORK")
        card.edge:SetPoint("TOPLEFT", 1, -1)
        card.edge:SetPoint("TOPRIGHT", -1, -1)
        card.edge:SetHeight(CARD_EDGE)
        card.edge:SetColorTexture(accent[1], accent[2], accent[3], 1)

        local title = Style.Text(card, 15, accent, "CENTER")
        title:SetPoint("TOP", card.edge, "BOTTOM", 0, -14)
        title:SetText(preset.label)

        local subtitle = Style.Text(card, 9, C.muted, "CENTER")
        subtitle:SetPoint("TOP", title, "BOTTOM", 0, -4)
        subtitle:SetText((preset.subtitle or ""):upper())

        local area = CreateFrame("Frame", nil, card)
        area:SetPoint("TOPLEFT", CARD_INSET, -(CARD_EDGE + 14 + 16 + 4 + 10 + 12))
        area:SetPoint("TOPRIGHT", -CARD_INSET, -(CARD_EDGE + 14 + 16 + 4 + 10 + 12))
        area:SetHeight(previewHeight)
        area:SetClipsChildren(true)
        Style.Fill(area, C.window)
        Style.Border(area, C.border)
        DrawSample(area, preset, ratio)

        local summary = Style.Text(card, 11, C.muted, "CENTER")
        summary:SetPoint("TOPLEFT", area, "BOTTOMLEFT", 0, -12)
        summary:SetPoint("TOPRIGHT", area, "BOTTOMRIGHT", 0, -12)
        summary:SetWordWrap(true)
        summary:SetMaxLines(3)
        summary:SetJustifyV("TOP")
        summary:SetText(preset.summary or "")

        local button = ns.Widgets.Button(card, "", cardWidth - CARD_INSET * 2, function(self)
            if not card.active then
                Apply(preset)
            end
        end)
        button:SetHeight(CARD_BUTTON)
        button:SetPoint("BOTTOM", 0, CARD_INSET)
        Style.SetFont(button.label, Style.font, 12, "")
        button.tint = Style.Fill(button, C.window, "BORDER")
        button:HookScript("OnLeave", function()
            if not card.active then
                Style.SetBorderColor(button, accent)
            end
        end)
        card.button = button

        card.preset = preset
        card.accent = accent
        Style.Tooltip(card, { label = preset.label, tooltip = preset.tooltip })
        cards[i] = card
    end

    function row:Refresh()
        for _, card in ipairs(cards) do
            local profile = CardProfile(spec, card.preset)
            if profile then
                card.active = Plateau.DB.profileName == profile
            else
                card.active = Matches(card.preset)
            end
            local accent = card.accent
            card.tag:SetShown(card.active)
            card.edge:SetAlpha(card.active and 1 or 0.55)
            Style.SetBorderColor(card, card.active and accent or C.border)
            local button = card.button
            if card.active then
                button.label:SetText("In use")
                button.label:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
                button.tint:SetColorTexture(C.window[1], C.window[2], C.window[3], 1)
                Style.SetBorderColor(button, C.border)
            else
                button.label:SetText(profile and "Use this look" or "Apply this look")
                button.label:SetTextColor(C.text[1], C.text[2], C.text[3])
                button.tint:SetColorTexture(accent[1] * 0.22, accent[2] * 0.22, accent[3] * 0.22, 1)
                Style.SetBorderColor(button, accent)
            end
            button:SetEnabled(not card.active)
        end
    end

    return row
end

function ns.Widgets.SpellList(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(62)
    row:EnableMouse(true)

    local label = Style.Text(row, 12, C.text)
    label:SetPoint("TOPLEFT", 0, -2)
    label:SetPoint("RIGHT")
    label:SetText(spec.label)
    local labelHit = Style.LabelHit(label)

    local box = CreateFrame("EditBox", nil, row)
    box:SetHeight(22)
    box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    box:SetPoint("RIGHT")
    box:SetAutoFocus(false)
    Style.SetFont(box, Style.font, 11, "")
    box:SetTextColor(C.text[1], C.text[2], C.text[3])
    box:SetTextInsets(6, 6, 0, 0)
    Style.Field(box, C.field, C.border)

    local found = Style.Text(row, 10, C.muted)
    found:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -4)
    found:SetPoint("RIGHT")

    local function Describe(text)
        if spec.describe then
            found:SetText(spec.describe(text))
            return
        end
        local names = {}
        for token in (text or ""):gmatch("[^,;]+") do
            token = token:match("^%s*(.-)%s*$")
            if token ~= "" then
                local id = tonumber(token) or (C_Spell.GetSpellIDForSpellIdentifier and C_Spell.GetSpellIDForSpellIdentifier(token))
                local name = id and C_Spell.GetSpellName(id)
                names[#names + 1] = name and ("%s (%d)"):format(name, id) or ("|cffff6655%s: not found|r"):format(token)
            end
        end
        found:SetText(#names > 0 and table.concat(names, ", ") or (spec.empty or "Empty: nothing filtered"))
    end

    local function Save(self)
        local text = self:GetText()
        ns.SpecSet(spec, text)
        row:Refresh()
    end

    box:SetScript("OnEnterPressed", function(self)
        Save(self)
        self:ClearFocus()
    end)
    box:SetScript("OnEscapePressed", function(self)
        self:SetText(ns.SpecGet(spec) or "")
        self:ClearFocus()
    end)
    box:SetScript("OnEditFocusGained", function(self)
        Style.SetBorderColor(self, Style.StateColor())
    end)
    box:SetScript("OnEditFocusLost", function(self)
        Style.SetBorderColor(self, C.border)
        if self:GetText() ~= (ns.SpecGet(spec) or "") then
            Save(self)
        end
    end)

    function row:Refresh()
        local text = ns.SpecGet(spec) or ""
        box:SetText(text)
        Describe(text)
        Style.OverrideLabel(label, spec)
        if spec.suffix then
            label:SetText(("%s  |cff8c9bb0(%s)|r"):format(spec.label, spec.suffix()))
        end
    end
    Style.RightClickReset(labelHit, spec, function() row:Refresh() end)
    Style.Tooltip(labelHit, spec)
    Style.Tooltip(box, { label = spec.label, tooltip = spec.tooltip, limited = spec.limited })
    return row
end
