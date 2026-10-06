local _, ns = ...

local Style = ns.Style
local C = Style.colors

local THUMB_SIZE = 13

function ns.Widgets.Slider(parent, spec)
    local min, max, step = spec.min, spec.max, spec.step or 1
    local pattern = step < 1 and "%.2f" or "%d"

    local row = CreateFrame("Frame", nil, parent)
    row:EnableMouse(true)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local box = CreateFrame("EditBox", nil, row)
    box:SetSize(52, 18)
    box:SetPoint("RIGHT")
    box:SetAutoFocus(false)
    Style.SetFont(box, Style.font, 11, "")
    box:SetTextColor(C.text[1], C.text[2], C.text[3])
    box:SetJustifyH("RIGHT")
    box:SetTextInsets(4, 5, 0, 0)
    Style.Field(box, C.field, C.border)

    local track = CreateFrame("Frame", nil, row)
    track:SetPoint("LEFT", Style.CONTROL_X, 0)
    track:SetPoint("RIGHT", box, "LEFT", -12, 0)
    track:SetHeight(14)
    track:EnableMouse(true)

    local groove = track:CreateTexture(nil, "BACKGROUND")
    groove:SetPoint("LEFT")
    groove:SetPoint("RIGHT")
    groove:SetHeight(4)
    groove:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)

    local thumb = track:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(THUMB_SIZE, THUMB_SIZE)
    Style.Themed(thumb, 1)
    local round = track:CreateMaskTexture()
    round:SetTexture("Interface\\Masks\\CircleMaskScalable", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    round:SetAllPoints(thumb)
    thumb:AddMaskTexture(round)

    local fill = track:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", groove)
    fill:SetPoint("RIGHT", thumb, "CENTER")
    fill:SetHeight(4)
    Style.Themed(fill, 1)

    local function Clean(value)
        value = math.max(min, math.min(max, value))
        value = min + math.floor((value - min) / step + 0.5) * step
        return tonumber(pattern:format(value))
    end

    local currentValue, lastValue

    local function PositionThumb(value)
        local width = track:GetWidth()
        if not width or width <= 0 or value == nil then return end
        local usable = math.max(width - THUMB_SIZE, 1)
        local fraction = (max > min) and (value - min) / (max - min) or 0
        fraction = math.max(0, math.min(1, fraction))
        thumb:ClearAllPoints()
        thumb:SetPoint("LEFT", track, "LEFT", fraction * usable, 0)
    end
    track:SetScript("OnSizeChanged", function() PositionThumb(currentValue) end)

    local function SetDisplay(value)
        currentValue = value
        PositionThumb(value)
        box:SetText(pattern:format(value))
    end

    local function Apply(value)
        value = Clean(value)
        lastValue = value
        SetDisplay(value)
        ns.SpecSet(spec, value)
        Style.OverrideLabel(label, spec)
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end

    function row:Refresh()
        local value = ns.SpecGet(spec)
        lastValue = value
        SetDisplay(value)
        Style.OverrideLabel(label, spec)
    end
    Style.RightClickReset(labelHit, spec, function()
        row:Refresh()
        if ns.RefreshAll then
            ns.RefreshAll()
        end
    end)

    local pending, scheduled
    local function Flush()
        scheduled = false
        if pending ~= nil then
            local value = pending
            pending = nil
            Apply(value)
        end
    end
    local function QueueChange(value)
        value = Clean(value)
        pending = value
        SetDisplay(value)
        if spec.applyOnRelease then return end
        if not scheduled then
            scheduled = true
            C_Timer.After(0.15, Flush)
        end
    end

    local function ValueAtCursor()
        local width, left = track:GetWidth(), track:GetLeft()
        if not width or width <= 0 or not left then return currentValue or lastValue or min end
        local cursorX = GetCursorPosition() / track:GetEffectiveScale()
        local usable = math.max(width - THUMB_SIZE, 1)
        local fraction = (cursorX - left - THUMB_SIZE / 2) / usable
        fraction = math.max(0, math.min(1, fraction))
        return min + fraction * (max - min)
    end

    local driver = CreateFrame("Frame")
    driver:Hide()
    driver:SetScript("OnUpdate", function()
        if not IsMouseButtonDown("LeftButton") then
            driver:Hide()
            Flush()
            return
        end
        QueueChange(ValueAtCursor())
    end)

    track:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        QueueChange(ValueAtCursor())
        driver:Show()
    end)
    track:SetScript("OnMouseUp", function(_, button)
        if button ~= "LeftButton" then return end
        driver:Hide()
        Flush()
    end)

    box:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText())
        if value then
            Apply(Clean(value))
        else
            row:Refresh()
        end
        self:ClearFocus()
    end)
    box:SetScript("OnEscapePressed", function(self)
        row:Refresh()
        self:ClearFocus()
    end)
    box:SetScript("OnEditFocusGained", function(self)
        Style.SetBorderColor(self, Style.StateColor())
        self:HighlightText()
    end)
    box:SetScript("OnEditFocusLost", function(self)
        Style.SetBorderColor(self, C.border)
    end)

    Style.Tooltip(labelHit, spec)
    local hoverOnly = { label = spec.label, tooltip = spec.tooltip, limited = spec.limited }
    Style.Tooltip(track, hoverOnly)
    Style.Tooltip(box, hoverOnly)
    return row
end
