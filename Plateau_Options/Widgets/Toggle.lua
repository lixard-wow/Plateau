local _, ns = ...

local Style = ns.Style
local C = Style.colors

local FADED = 0.3
local TRACK_WIDTH, TRACK_HEIGHT = 30, 12
local PAD = 2
local KNOB = 10
local OFF_X, ON_X = PAD, TRACK_WIDTH - PAD - KNOB
local DURATION = 0.15

local function MakeToggle(parent, spec)
    local row = CreateFrame("Button", nil, parent)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local track = CreateFrame("Frame", nil, row)
    track:SetSize(TRACK_WIDTH, TRACK_HEIGHT)
    track:SetPoint("LEFT", Style.CONTROL_X, 0)
    local _, edge = Style.Panel(track, C.field, C.edge)
    local fill = track:CreateTexture(nil, "ARTWORK", nil, 0)
    fill:SetColorTexture(1, 1, 1, 1)
    local knob = track:CreateTexture(nil, "ARTWORK", nil, 1)
    knob:SetColorTexture(1, 1, 1, 1)
    knob:SetSize(KNOB, TRACK_HEIGHT - PAD * 2)
    track.fill, track.knob = fill, knob

    local knobX = OFF_X
    local function PlaceKnob(x)
        knobX = x
        knob:ClearAllPoints()
        knob:SetPoint("LEFT", track, "LEFT", x, 0)
        local width = x - PAD
        fill:ClearAllPoints()
        fill:SetPoint("TOPLEFT", track, "TOPLEFT", PAD, -PAD)
        fill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", PAD, PAD)
        fill:SetWidth(math.max(width, 0.001))
        fill:SetShown(width > 0.5)
    end
    PlaceKnob(OFF_X)

    local animFrom, animTo, animElapsed = OFF_X, OFF_X, DURATION
    local ticker = CreateFrame("Frame", nil, track)
    ticker:Hide()
    ticker:SetScript("OnUpdate", function(self, delta)
        animElapsed = animElapsed + delta
        local t = math.min(animElapsed / DURATION, 1)
        PlaceKnob(animFrom + (animTo - animFrom) * (1 - (1 - t) ^ 3))
        if t >= 1 then
            self:Hide()
        end
    end)

    local hovered = false
    function row:SetOn(on)
        local animate = self.on ~= nil and self.on ~= on
        self.on = on
        Style.PaintVertex(fill, hovered and C.accentHi or C.accent)
        Style.PaintVertex(knob, (on or hovered) and C.text or C.muted)
        Style.PaintVertex(edge, hovered and C.accent or C.edge)
        local target = on and ON_X or OFF_X
        if animate then
            animFrom, animTo, animElapsed = knobX, target, 0
            ticker:Show()
        elseif not ticker:IsShown() then
            PlaceKnob(target)
        end
    end

    local function RefreshEverything()
        Style.AfterChange(row)
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
    row:SetScript("OnSizeChanged", function(self, width)
        if type(width) == "number" and not issecretvalue(width) then
            self:SetHitRectInsets(0, math.max(0, width - Style.CONTROL_X - TRACK_WIDTH - 6), 0, 0)
        end
    end)
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
        Style.AfterChange(row)
    end
    swatch.onChange = RefreshEverything
    Style.Tooltip(swatch, { label = spec.swatchLabel or spec.label, tooltip = spec.swatchTooltip or spec.tooltip, limited = spec.limited })

    return row
end
