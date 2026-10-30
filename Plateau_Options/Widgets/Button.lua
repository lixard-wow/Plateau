local _, ns = ...

local Style = ns.Style
local C = Style.colors
local T = Style.T

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

local CONFIRM_SECONDS = 5

local function PlainLabel(button)
    Style.PaintText(button.label, C.text)
end

function ns.Widgets.Confirm(button, text, action, opts)
    opts = opts or {}
    local armedText = opts.armedText or "Click again to confirm"
    local restore = opts.restore or PlainLabel
    local armed = false
    local token = 0
    local function Disarm()
        armed = false
        token = token + 1
        button.label:SetText(text)
        restore(button)
    end
    local function Expire()
        token = token + 1
        local mine = token
        C_Timer.After(CONFIRM_SECONDS, function()
            if armed and mine == token and not button:IsMouseOver() then
                Disarm()
            end
        end)
    end
    button:SetScript("OnClick", function(self)
        if armed or opts.instant then
            Disarm()
            action()
            return
        end
        armed = true
        self.label:SetText(armedText)
        Style.PaintText(self.label, C.warn)
        Expire()
    end)
    button:HookScript("OnLeave", function()
        if armed then
            Expire()
        end
    end)
    button:HookScript("OnHide", function()
        if armed then
            Disarm()
        end
    end)
end

function ns.Widgets.PrimaryButton(parent, text, width, onClick)
    return ns.Widgets.Button(parent, text, width, onClick, true)
end

function ns.Widgets.Header(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(spec.part and 34 or 22)

    local text = Style.Text(row, 14, spec.part and C.title or C.heading)
    if spec.part then
        Style.SetFont(text, Style.titleFont, 18, "")
    else
        Style.SetFont(text, Style.sectionFont, Style.SECTION_SIZE, "")
    end
    text:SetPoint("BOTTOMLEFT", 0, 4)
    text:SetText(spec.label)

    local rule = row:CreateTexture(nil, "ARTWORK")
    rule:SetPoint("BOTTOMLEFT")
    rule:SetPoint("BOTTOMRIGHT")
    Style.PixelHeight(rule)
    Style.Paint(rule, C.line, 1)

    if spec.collapsible then
        row:EnableMouse(true)
        local state = Style.Text(row, 11, C.muted)
        state:SetPoint("BOTTOMRIGHT", 0, 4)
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
            Style.PaintText(state, tint)
        end)
        row:SetScript("OnLeave", function()
            Style.PaintText(state, C.muted)
        end)
        Style.Tooltip(row, { label = spec.label, tooltip = "Click to show or hide these settings." })
    end
    return row
end

function ns.Widgets.Link(parent, spec)
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(24)
    local text = Style.Text(row, 12, Style.StateColor())
    text:SetPoint("LEFT", 0, 0)
    text:SetText(T(spec.label) .. "  >")
    row:SetWidth(text:GetStringWidth() + 8)
    row:SetScript("OnClick", function()
        if ns.OpenLink then
            ns.OpenLink(spec.target)
        end
    end)
    row:SetScript("OnEnter", function() Style.PaintText(text, C.text) end)
    row:SetScript("OnLeave", function()
        local tint = Style.StateColor()
        Style.PaintText(text, tint)
    end)
    Style.Tooltip(row, { label = spec.label, tooltip = spec.tooltip })
    function row:SetWidth() end
    return row
end

local WARN_ICON = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:12:12:0:0|t "

function ns.Widgets.Note(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    local text = Style.Text(row, spec.size or 11, spec.warn and C.warn or (spec.bright and C.text or C.muted))
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
            text:SetText(prefix .. T(spec.label()))
            Fit()
        end
        row:Refresh()
    else
        text:SetText(prefix .. T(spec.label))
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
        if drag.placed ~= drag.to then
            drag.placed = drag.to
            for position, original in ipairs(ns.PriorityOrder.Display(#lines, drag.from, drag.to)) do
                if original ~= drag.from then
                    local line = lines[original]
                    line:ClearAllPoints()
                    line:SetPoint("TOP", holder, "TOP", 0, -(position - 1) * ROW)
                end
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
        Style.Paint(line.grab, tint, 0.25)
        line.grab:SetAlpha(0)
        line.hover = line:CreateTexture(nil, "BACKGROUND")
        line.hover:SetAllPoints()
        line.hover:SetColorTexture(1, 1, 1, 0.07)
        line.hover:Hide()
        for bar = 1, 3 do
            local grip = line:CreateTexture(nil, "ARTWORK")
            grip:SetSize(10, 2)
            grip:SetPoint("LEFT", 3, (2 - bar) * 4)
            Style.Paint(grip, C.muted, 0.9)
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
        Style.PaintText(button.label, color)
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
            Style.Paint(button.activeBar, tint, 1)
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
        Style.Paint(bar, C.accent, 1)
        bar:Hide()
        button.activeBar = bar
        buttons[#buttons + 1] = button
        x = x + width + 6
        ns.Widgets.Confirm(button, preset.label, function()
            if preset.apply then
                preset.apply()
            else
                ns.Undo.Next(T("Look: %s"):format(T(preset.label)))
                Plateau.DB:SetMany(preset.values)
            end
            Style.AfterChange()
            row:Refresh()
        end, { armedText = "Click to apply", restore = LabelColor, instant = spec.instant })
        Style.Tooltip(button, { label = preset.label, tooltip = preset.tooltip })
    end
    row:Refresh()
    return row
end

function ns.AllLooks()
    local list = {}
    for _, group in ipairs({ Plateau.presets.looks, Plateau.presets.styles }) do
        for _, preset in ipairs(group) do
            list[#list + 1] = preset
        end
    end
    return list
end

local function LookSample()
    return {
        health = 0.72,
        maxHealth = 72700,
        name = "Wastelander Phaseblade",
        levelOffset = 1,
        classification = "elite",
        mobType = "caster",
        auras = {},
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

function ns.LookView(area, name, width, largest)
    local holder = CreateFrame("Frame", nil, area)
    holder:SetSize(1, 1)
    holder:SetPoint("CENTER", 0, 0)
    local view = {}
    function view:Set(look)
        Plateau.SetSampleLook(name, look)
        holder:SetScale(math.min(largest or 0.7, width / look.plate.width))
        if self.plate then
            Plateau.SetPreviewState(self.plate, LookSample())
        else
            self.plate = Plateau.CreatePreview(holder, LookSample(), name)
            self.plate:SetPoint("CENTER")
        end
    end
    return view
end

function ns.DrawLookSample(area, preset, width)
    ns.LookView(area, "sample:" .. preset.key, width):Set(Plateau.PresetLook(preset))
end

function ns.ImportPeek(box, name, edit)
    local area = CreateFrame("Frame", nil, box)
    area:SetPoint("TOPRIGHT", -1, -1)
    area:SetPoint("BOTTOMRIGHT", -1, 1)
    area:SetWidth(150)
    area:SetFrameLevel(box:GetFrameLevel() + 5)
    area:SetClipsChildren(true)
    Style.Fill(area, C.window)
    local edge = area:CreateTexture(nil, "BORDER")
    edge:SetPoint("TOPLEFT")
    edge:SetPoint("BOTTOMLEFT")
    Style.PixelWidth(edge)
    Style.Paint(edge, C.border, 1)
    area:Hide()
    local view = ns.LookView(area, name, 136, 1)
    return function(text)
        local look = type(text) == "string" and text:find("%S") and Plateau.DB:PeekImport(text)
        if look then
            view:Set(look)
        end
        area:SetShown(look and true or false)
        if edit then
            edit:SetTextInsets(6, look and 156 or 6, 6, 6)
        end
    end
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

    local box = Style.Input(row, 11)
    box:SetHeight(22)
    box:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)
    box:SetPoint("RIGHT")

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
                names[#names + 1] = name and ("%s (%d)"):format(name, id) or ("|cffff6655" .. T("%s: not found"):format(token) .. "|r")
            end
        end
        found:SetText(#names > 0 and table.concat(names, ", ") or (spec.empty or "No spells listed"))
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
    box:HookScript("OnEditFocusLost", function(self)
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
            label:SetText(("%s  |cff8c9bb0(%s)|r"):format(T(spec.label), T(spec.suffix())))
        end
    end
    Style.RightClickReset(labelHit, spec, function() row:Refresh() end)
    Style.Tooltip(labelHit, spec)
    Style.Tooltip(box, { label = spec.label, tooltip = spec.tooltip, limited = spec.limited })
    return row
end
