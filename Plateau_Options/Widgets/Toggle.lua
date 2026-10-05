local _, ns = ...

local Style = ns.Style
local C = Style.colors

local FADED = 0.3
local TRACK_WIDTH, TRACK_HEIGHT = 32, 16
local KNOB = 12
local OFF_X, ON_X = 2, TRACK_WIDTH - KNOB - 2
local DURATION = 0.2

local function MakeToggle(parent, spec)
    local row = CreateFrame("Button", nil, parent)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local track = CreateFrame("Frame", nil, row)
    track:SetSize(TRACK_WIDTH, TRACK_HEIGHT)
    track:SetPoint("LEFT", Style.CONTROL_X, 0)
    Style.Fill(track, C.field)
    Style.Border(track, C.border)
    local knob = track:CreateTexture(nil, "ARTWORK")
    knob:SetSize(KNOB, KNOB)

    local currentX = OFF_X
    local function PlaceKnob(x)
        currentX = x
        knob:ClearAllPoints()
        knob:SetPoint("LEFT", track, "LEFT", x, 0)
    end
    PlaceKnob(OFF_X)

    local animFrom, animTo, animElapsed = OFF_X, OFF_X, DURATION
    local ticker = CreateFrame("Frame", nil, track)
    ticker:Hide()
    ticker:SetScript("OnUpdate", function(self, delta)
        animElapsed = animElapsed + delta
        local t = math.min(animElapsed / DURATION, 1)
        local eased = 1 - (1 - t) ^ 3
        PlaceKnob(animFrom + (animTo - animFrom) * eased)
        if t >= 1 then
            self:Hide()
        end
    end)

    local hovered = false
    function row:SetOn(on, instant)
        local changed = self.on ~= on
        self.on = on
        local tint = Style.StateColor()
        Style.SetBorderColor(track, hovered and tint or C.border)
        if on then
            knob:SetColorTexture(tint[1], tint[2], tint[3], 1)
        else
            knob:SetColorTexture(Style.colors.muted[1], Style.colors.muted[2], Style.colors.muted[3], 1)
        end
        local target = on and ON_X or OFF_X
        if instant or not changed then
            ticker:Hide()
            animFrom, animTo, animElapsed = target, target, DURATION
            PlaceKnob(target)
        else
            animFrom, animTo, animElapsed = currentX, target, 0
            ticker:Show()
        end
    end

    local function RefreshEverything()
        if ns.RefreshAll then
            ns.RefreshAll()
        else
            row:Refresh()
        end
    end

    local function DoToggle()
        ns.SpecSet(spec, not ns.SpecGet(spec))
        RefreshEverything()
    end

    local function UpdateHover(state)
        hovered = state
        row:SetOn(row.on)
    end

    row.label = label
    row.track = track
    row:SetScript("OnClick", DoToggle)
    row:HookScript("OnEnter", function() UpdateHover(true) end)
    row:HookScript("OnLeave", function() UpdateHover(false) end)

    labelHit:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            DoToggle()
        end
    end)
    Style.RightClickReset(labelHit, spec, RefreshEverything)
    Style.Tooltip(labelHit, spec)

    track:EnableMouse(true)
    track:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            DoToggle()
        end
    end)
    track:HookScript("OnEnter", function() UpdateHover(true) end)
    track:HookScript("OnLeave", function() UpdateHover(false) end)
    Style.Tooltip(track, { label = spec.label, tooltip = spec.tooltip, limited = spec.limited })

    row:SetOn(false, true)
    return row
end

function ns.Widgets.Toggle(parent, spec)
    local row = MakeToggle(parent, spec)

    function row:Refresh()
        self:SetOn(ns.SpecGet(spec) == true, not self.initialized)
        self.initialized = true
        Style.OverrideLabel(self.label, spec)
    end

    return row
end

function ns.Widgets.ToggleColor(parent, spec)
    local row = MakeToggle(parent, spec)

    local swatch = ns.Widgets.MakeSwatch(row, spec.colorPath)
    swatch:SetPoint("LEFT", row.track, "RIGHT", 12, 0)

    function row:Refresh()
        local on = ns.Get(spec.path) == true
        self:SetOn(on, not self.initialized)
        self.initialized = true
        swatch:Refresh()
        swatch:SetAlpha(on and 1 or FADED)
        Style.OverrideLabel(self.label, spec)
    end
    local function RefreshEverything()
        if ns.RefreshAll then
            ns.RefreshAll()
        else
            row:Refresh()
        end
    end
    swatch.onChange = RefreshEverything
    Style.Tooltip(swatch, { label = spec.swatchLabel or spec.label, tooltip = spec.swatchTooltip or spec.tooltip, limited = spec.limited })

    return row
end
