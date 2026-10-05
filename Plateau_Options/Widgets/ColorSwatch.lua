local _, ns = ...

local Style = ns.Style
local C = Style.colors

local SWATCH_SIZE = 16

local pickerStrata
local function LiftPicker()
    if not pickerStrata then
        pickerStrata = ColorPickerFrame:GetFrameStrata()
        ColorPickerFrame:HookScript("OnHide", function(self)
            self:SetFrameStrata(pickerStrata)
        end)
    end
    ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    ColorPickerFrame:Raise()
end

function ns.Widgets.MakeSwatch(parent, path, setter)
    local swatch = CreateFrame("Button", nil, parent)
    swatch:SetSize(SWATCH_SIZE, SWATCH_SIZE)
    Style.Fill(swatch, { 0.3, 0.3, 0.3, 1 })
    local color = swatch:CreateTexture(nil, "ARTWORK")
    color:SetPoint("TOPLEFT", 1, -1)
    color:SetPoint("BOTTOMRIGHT", -1, 1)
    Style.Border(swatch, C.border)

    function swatch:Refresh()
        local value = ns.Get(path)
        color:SetColorTexture(value[1], value[2], value[3], value[4])
    end

    local pending, scheduled
    local function Flush()
        scheduled = false
        if pending then
            local value = pending
            pending = nil
            if setter then
                setter(value)
            else
                ns.Set(path, value)
            end
            swatch:Refresh()
            if swatch.onChange then
                swatch.onChange()
            end
        end
    end

    local function Save(r, g, b, a)
        pending = { r, g, b, a }
        color:SetColorTexture(r, g, b, a)
        if not scheduled then
            scheduled = true
            C_Timer.After(0.15, Flush)
        end
    end

    local opening, seed, original, changed

    local function Near(a, b)
        return math.abs(a - b) < 0.002
    end

    local function FromPicker()
        if opening then return end
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
        if seed then
            if Near(r, seed[1]) and Near(g, seed[2]) and Near(b, seed[3]) and Near(a, seed[4]) and not IsMouseButtonDown("LeftButton") then
                return
            end
            seed = nil
        end
        changed = true
        Save(r, g, b, a)
    end

    swatch:SetScript("OnClick", function()
        local value = ns.Get(path)
        original = value
        changed = false
        local start = value
        seed = nil
        if math.max(value[1], value[2], value[3]) < 0.001 then
            seed = { 1, 1, 1, value[4] }
            start = seed
        end
        opening = true
        ColorPickerFrame:SetupColorPickerAndShow({
            r = start[1],
            g = start[2],
            b = start[3],
            opacity = start[4],
            hasOpacity = true,
            swatchFunc = FromPicker,
            opacityFunc = FromPicker,
            cancelFunc = function()
                seed = nil
                pending = nil
                if changed then
                    changed = false
                    ns.Set(path, original)
                    swatch:Refresh()
                    if swatch.onChange then
                        swatch.onChange()
                    end
                else
                    swatch:Refresh()
                end
            end,
        })
        opening = false
        LiftPicker()
    end)

    Style.HoverBorder(swatch, swatch)
    return swatch
end

function ns.Widgets.Color(parent, spec)
    local row = CreateFrame("Frame", nil, parent)
    row:EnableMouse(true)
    local label = Style.RowLabel(row, spec)
    local labelHit = Style.LabelHit(label)

    local swatch = ns.Widgets.MakeSwatch(row, spec.path, spec.set)
    swatch:SetPoint("LEFT", Style.CONTROL_X, 0)

    function row:Refresh()
        swatch:Refresh()
        Style.OverrideLabel(label, spec)
    end
    local function RefreshEverything()
        if ns.RefreshAll then
            ns.RefreshAll()
        else
            row:Refresh()
        end
    end
    swatch.onChange = RefreshEverything
    Style.RightClickReset(labelHit, spec, RefreshEverything)

    Style.Tooltip(labelHit, spec)
    Style.Tooltip(swatch, { label = spec.label, tooltip = spec.tooltip, limited = spec.limited })
    return row
end
