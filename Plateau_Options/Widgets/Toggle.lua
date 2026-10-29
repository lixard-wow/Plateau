local _, ns = ...

local Style = ns.Style
local C = Style.colors

local FADED = 0.3
local BAR_WIDTH, BAR_HEIGHT = 24, 10

local function MakeToggle(parent, spec)
    local row = CreateFrame("Button", nil, parent)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local track = Style.Bar(row, BAR_WIDTH, BAR_HEIGHT)
    track:SetPoint("LEFT", Style.CONTROL_X, 0)

    local hovered = false
    function row:SetOn(on)
        self.on = on
        track:SetFraction(on and 1 or 0)
        Style.PaintVertex(track.back, (hovered and not on) and C.hover or C.field)
        Style.Paint(track.fill, hovered and C.accentHi or C.accent, 1)
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

    row:SetOn(false)
    return row
end

function ns.Widgets.Toggle(parent, spec)
    local row = MakeToggle(parent, spec)

    function row:Refresh()
        self:SetOn(ns.SpecGet(spec) == true)
        Style.OverrideLabel(self.label, spec)
    end

    return row
end

function ns.Widgets.ToggleColor(parent, spec)
    local row = MakeToggle(parent, spec)

    local swatch = ns.Widgets.MakeSwatch(row, spec.colorPath)
    swatch:SetPoint("LEFT", row.track, "RIGHT", 8, 0)

    function row:Refresh()
        local on = ns.Get(spec.path) == true
        self:SetOn(on)
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
