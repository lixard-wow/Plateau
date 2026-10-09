local _, ns = ...

local Style = ns.Style
local C = Style.colors

local ITEM_HEIGHT = 22
local LIST_PAD = 5
local MAX_VISIBLE = 12
local MAX_ITEMS = 20
local ICON_SIZE = 16
local CHECK_SIZE = 10

local function SetIcon(texture, icon)
    if not icon then
        texture:Hide()
        return false
    end
    if icon.atlas then
        texture:SetAtlas(icon.atlas)
    else
        texture:SetTexture(icon.file)
    end
    texture:SetRotation(icon.rotation or 0)
    texture:Show()
    return true
end

local function PlaceText(text, icon, hasIcon, rightInset)
    text:ClearAllPoints()
    if hasIcon then
        text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    else
        text:SetPoint("LEFT", 8, 0)
    end
    text:SetPoint("RIGHT", -(rightInset or 8), 0)
end

local catcher, list, scrollTrack, scrollThumb
local listItems = {}
local listOptions, listOffset, listPick, listCurrent, listVisible, listKeepOpen, listPinned, listRows

local function Checked(option)
    if type(option.checked) == "function" then
        return option.checked()
    end
    return option.checked
end

local SCROLL_WIDTH = 4

local function UpdateScrollbar()
    if not scrollTrack then return end
    local total = #listOptions
    if total <= listRows then
        scrollTrack:Hide()
        return
    end
    local track = list:GetHeight() - 4 - LIST_PAD * 2
    if not track or track <= 0 then
        scrollTrack:Hide()
        return
    end
    local thumb = math.max(20, track * listRows / total)
    local range = total - listRows
    scrollTrack:SetHeight(track)
    scrollThumb:SetHeight(thumb)
    scrollThumb:ClearAllPoints()
    scrollThumb:SetPoint("TOP", scrollTrack, "TOP", 0, -(track - thumb) * (listOffset / range))
    scrollTrack:Show()
end

local function Render()
    for i = 1, MAX_ITEMS do
        local item = listItems[i]
        local option
        if i <= listRows then
            option = listOptions[i + listOffset]
        elseif listPinned and i == listRows + 1 then
            option = listPinned
        end
        if option then
            item.option = option
            item:SetEnabled(not option.title)
            item.check:SetShown(option.checked ~= nil)
            item.box:SetShown(option.checked ~= nil)
            if option.checked ~= nil then
                local on = Checked(option)
                local tint = Style.StateColor()
                item.check:SetColorTexture(tint[1], tint[2], tint[3], on and 1 or 0)
                item.text:ClearAllPoints()
                item.text:SetPoint("LEFT", item.box, "RIGHT", 8, 0)
                item.text:SetPoint("RIGHT", -8, 0)
                item.icon:Hide()
            else
                PlaceText(item.text, item.icon, SetIcon(item.icon, option.icon))
            end
            item.text:SetText(option.label)
            local color
            if option.title then
                color = C.muted
            elseif option.color then
                color = option.color
            else
                color = option.value == listCurrent and Style.StateColor() or C.text
            end
            item.text:SetTextColor(color[1], color[2], color[3])
            item:Show()
        else
            item:Hide()
        end
    end
    UpdateScrollbar()
end

local function FitWidth(minimum)
    local widest = minimum
    for i = 1, MAX_ITEMS do
        local item = listItems[i]
        if item:IsShown() then
            local inset = (item.icon:IsShown() or item.box:IsShown()) and 40 or 20
            widest = math.max(widest, math.ceil(item.text:GetUnboundedStringWidth()) + inset)
        end
    end
    if #listOptions > listRows then
        widest = widest + SCROLL_WIDTH + 6
    end
    return widest
end

local function HideList()
    catcher:Hide()
end

local function EnsureList()
    if catcher then return end

    catcher = CreateFrame("Button", nil, UIParent)
    catcher:SetAllPoints(UIParent)
    catcher:SetFrameStrata("FULLSCREEN_DIALOG")
    catcher:Hide()
    catcher:SetScript("OnClick", HideList)

    list = CreateFrame("Frame", nil, catcher)
    list:SetFrameLevel(catcher:GetFrameLevel() + 10)
    list:EnableMouse(true)
    list:EnableMouseWheel(true)
    Style.Panel(list, C.field, C.accent)
    Style.ThemedBorder(list)

    for i = 1, MAX_ITEMS do
        local item = CreateFrame("Button", nil, list)
        item:SetHeight(ITEM_HEIGHT)
        item:SetPoint("TOPLEFT", 1, -1 - LIST_PAD - (i - 1) * ITEM_HEIGHT)
        item:SetPoint("TOPRIGHT", -1, -1 - LIST_PAD - (i - 1) * ITEM_HEIGHT)
        local hover = Style.Fill(item, C.hover)
        hover:Hide()
        item.icon = item:CreateTexture(nil, "ARTWORK")
        item.icon:SetSize(ICON_SIZE, ICON_SIZE)
        item.icon:SetPoint("LEFT", 8, 0)
        item.text = Style.Text(item, 12, C.text)
        item.box = CreateFrame("Frame", nil, item)
        item.box:SetSize(CHECK_SIZE + 4, CHECK_SIZE + 4)
        item.box:SetPoint("LEFT", 8, 0)
        Style.Field(item.box, C.window, C.border)
        item.check = item.box:CreateTexture(nil, "ARTWORK")
        item.check:SetSize(CHECK_SIZE - 2, CHECK_SIZE - 2)
        item.check:SetPoint("CENTER")
        item:SetScript("OnEnter", function(self)
            if not self.option or not self.option.title then
                hover:Show()
            end
            if self.option and self.option.tooltip then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(Style.T(self.option.tooltipTitle or self.option.label), 1, 1, 1)
                GameTooltip:AddLine(Style.T(self.option.tooltip), 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        item:SetScript("OnLeave", function()
            hover:Hide()
            GameTooltip:Hide()
        end)
        item:SetScript("OnClick", function(self)
            if listKeepOpen then
                listPick(self.option.value, self.option)
                Render()
                return
            end
            HideList()
            listPick(self.option.value, self.option)
        end)
        listItems[i] = item
    end

    scrollTrack = CreateFrame("Frame", nil, list)
    scrollTrack:SetWidth(SCROLL_WIDTH)
    scrollTrack:SetPoint("TOPRIGHT", list, "TOPRIGHT", -2, -2 - LIST_PAD)
    scrollTrack:SetFrameLevel(list:GetFrameLevel() + 20)
    scrollTrack:EnableMouse(true)
    local groove = scrollTrack:CreateTexture(nil, "BACKGROUND")
    groove:SetAllPoints()
    groove:SetColorTexture(C.border[1], C.border[2], C.border[3], 0.6)
    scrollThumb = CreateFrame("Frame", nil, scrollTrack)
    scrollThumb:SetWidth(SCROLL_WIDTH)
    local thumbFill = scrollThumb:CreateTexture(nil, "OVERLAY")
    thumbFill:SetAllPoints()
    local tint = Style.StateColor()
    thumbFill:SetColorTexture(tint[1], tint[2], tint[3], 0.9)
    scrollTrack:Hide()

    local function DragTo()
        local range = #listOptions - listRows
        if range <= 0 then return end
        local top, height = scrollTrack:GetTop(), scrollTrack:GetHeight()
        local thumb = scrollThumb:GetHeight()
        if not top or not height or height <= thumb then return end
        local _, y = GetCursorPosition()
        y = y / scrollTrack:GetEffectiveScale()
        local fraction = math.max(0, math.min(1, (top - y - thumb / 2) / (height - thumb)))
        local offset = math.floor(fraction * range + 0.5)
        if offset ~= listOffset then
            listOffset = offset
            Render()
        end
    end
    scrollTrack:SetScript("OnMouseDown", function(self)
        DragTo()
        self:SetScript("OnUpdate", DragTo)
    end)
    scrollTrack:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    scrollTrack:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    list:SetScript("OnMouseWheel", function(_, delta)
        local maxOffset = math.max(0, #listOptions - listRows)
        listOffset = math.max(0, math.min(maxOffset, listOffset - delta))
        Render()
    end)
end

local function ShowList(owner, options, current, onPick, opts)
    EnsureList()
    list:SetScale(owner:GetEffectiveScale() / catcher:GetEffectiveScale())
    opts = opts or {}
    listOptions, listCurrent, listPick = options, current, onPick
    listVisible = math.min(opts.maxVisible or MAX_VISIBLE, MAX_ITEMS)
    listPinned = opts.pinned
    listRows = math.min(#options, listVisible - (listPinned and 1 or 0))
    listKeepOpen = opts.keepOpen == true
    listOffset = 0
    for index, option in ipairs(options) do
        if current ~= nil and option.value == current then
            listOffset = math.max(0, math.min(#options - listRows, index - math.ceil(listRows / 2)))
        end
    end
    list:ClearAllPoints()
    if opts.up then
        list:SetPoint("BOTTOMLEFT", owner, "TOPLEFT", 0, 2)
    elseif opts.alignRight then
        list:SetPoint("TOPRIGHT", owner, "BOTTOMRIGHT", 0, -2)
    else
        list:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
    end
    list:SetHeight((listRows + (listPinned and 1 or 0)) * ITEM_HEIGHT + 2 + LIST_PAD * 2)
    Render()
    list:SetWidth(opts.width or FitWidth(owner:GetWidth()))
    catcher:Show()
end
ns.ShowList = ShowList

ns.HideDropdownList = function()
    if catcher then
        catcher:Hide()
    end
end

function ns.Widgets.Dropdown(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:EnableMouse(true)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local button = CreateFrame("Button", nil, row)
    button:SetHeight(22)
    button:SetPoint("LEFT", Style.CONTROL_X, 0)
    button:SetWidth(Style.CONTROL_WIDTH)
    Style.ButtonBox(button, C.field, nil, C.border)
    row.label = label
    row.button = button
    Style.DropArrow(button)

    local currentIcon = button:CreateTexture(nil, "ARTWORK")
    currentIcon:SetSize(ICON_SIZE, ICON_SIZE)
    currentIcon:SetPoint("LEFT", 8, 0)
    local current = Style.Text(button, 12, C.text)

    local function Options()
        return type(spec.options) == "function" and spec.options() or spec.options
    end

    local function Get()
        if spec.get then
            return spec.get()
        end
        return ns.Get(spec.path)
    end

    local function Set(value)
        if spec.set then
            spec.set(value)
        else
            ns.Set(spec.path, value)
        end
    end

    function row:Refresh()
        local value = Get()
        local text = spec.unknown or tostring(value)
        local icon
        for _, option in ipairs(Options()) do
            if option.value == value then
                text = option.label
                icon = option.icon
            end
        end
        PlaceText(current, currentIcon, SetIcon(currentIcon, icon), 24)
        current:SetText(text)
        Style.OverrideLabel(label, spec)
    end

    local function RefreshEverything()
        if ns.RefreshAll then
            ns.RefreshAll()
        else
            row:Refresh()
        end
    end

    button:SetScript("OnClick", function(self)
        ShowList(self, Options(), Get(), function(value)
            Set(value)
            RefreshEverything()
        end)
    end)

    if not spec.get or spec.reset then
        Style.RightClickReset(labelHit, spec, RefreshEverything)
    end

    Style.HoverBorder(button, button)
    Style.Tooltip(labelHit, spec)
    Style.Tooltip(button, { label = spec.label, tooltip = spec.tooltip, limited = spec.limited })
    return row
end
