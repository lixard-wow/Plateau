local _, ns = ...

local Style = ns.Style
local C = Style.colors

local BAR_HEIGHT = 12

function ns.Widgets.Slider(parent, spec)
    local min, max, step = spec.min, spec.max, spec.step or 1
    local pattern = step < 0.01 and "%.3f" or step < 1 and "%.2f" or "%d"

    local row = CreateFrame("Frame", nil, parent)
    row:EnableMouse(true)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local track = Style.Bar(row, Style.CONTROL_WIDTH, BAR_HEIGHT)
    track:SetPoint("LEFT", Style.CONTROL_X, 0)
    track:EnableMouse(true)

    local box = CreateFrame("EditBox", nil, track)
    box:SetPoint("TOPRIGHT", -1, -1)
    box:SetPoint("BOTTOMRIGHT", -1, 1)
    box:SetWidth(44)
    box:SetFrameLevel(track:GetFrameLevel() + 2)
    box:SetAutoFocus(false)
    Style.SetFont(box, Style.buttonFont, 10, "OUTLINE")
    Style.PaintText(box, C.text)
    box:SetJustifyH("RIGHT")
    box:SetTextInsets(2, 3, 0, 0)
    local typing = box:CreateTexture(nil, "BACKGROUND")
    typing:SetAllPoints()
    Style.Paint(typing, C.field, 1)
    typing:Hide()

    local function Clean(value)
        value = math.max(min, math.min(max, value))
        value = min + math.floor((value - min) / step + 0.5) * step
        return tonumber(pattern:format(value))
    end

    local currentValue, lastValue

    local function PositionThumb(value)
        if value == nil then return end
        local fraction = (max > min) and (value - min) / (max - min) or 0
        track:SetFraction(fraction)
    end

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
        local fraction = math.max(0, math.min(1, (cursorX - left) / width))
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
        typing:Show()
        self:HighlightText()
    end)
    box:SetScript("OnEditFocusLost", function()
        typing:Hide()
    end)

    Style.Tooltip(labelHit, spec)
    local hoverOnly = { label = spec.label, tooltip = spec.tooltip, limited = spec.limited }
    Style.Tooltip(track, hoverOnly)
    Style.Tooltip(box, hoverOnly)
    return row
end
