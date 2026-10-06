local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
function Frame:EnableMouse() end
function Frame:SetPoint() end
function Frame:SetSize() end
function Frame:SetColorTexture(r, g, b, a) self.color = { r, g, b, a } end
function Frame:SetAlpha(a) self.alpha = a end
function Frame:ClearAllPoints() end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown end
function Frame:CreateTexture() return setmetatable({}, Frame) end
function Frame:SetScript(name, fn) self.scripts[name] = fn end
function Frame:HookScript(name, fn)
    self.hooks[name] = self.hooks[name] or {}
    table.insert(self.hooks[name], fn)
end
function Frame:Fire(name, ...)
    if self.scripts[name] then self.scripts[name](self, ...) end
    for _, fn in ipairs(self.hooks[name] or {}) do fn(self, ...) end
end

local created = {}
function CreateFrame(kind, _, parent)
    local frame = setmetatable({ scripts = {}, hooks = {}, parent = parent }, Frame)
    created[#created + 1] = { kind = kind, frame = frame }
    return frame
end

local resetTargets, tooltips, borderColors = {}, {}, {}
local labelHits = {}
local db = {}
local ns = {
    Widgets = {},
    Style = {
        colors = { border = {}, field = {}, muted = { 0.5, 0.5, 0.5, 1 } },
        CONTROL_X = 0,
        RowLabel = function() return setmetatable({}, Frame) end,
        LabelHit = function(label)
            local hit = CreateFrame("Frame", nil, label)
            labelHits[#labelHits + 1] = hit
            return hit
        end,
        Fill = function() end,
        Border = function() end,
        HoverBorder = function() end,
        StateColor = function() return { 1, 1, 1 } end,
        SetBorderColor = function(frame, color) borderColors[#borderColors + 1] = { frame = frame, color = color } end,
        OverrideLabel = function() end,
        RightClickReset = function(frame, spec, refresh) resetTargets[#resetTargets + 1] = { frame = frame, refresh = refresh } end,
        Tooltip = function(frame, spec) tooltips[#tooltips + 1] = { frame = frame, spec = spec } end,
    },
}
function ns.SpecGet(spec) return db[spec.path] end
function ns.SpecSet(spec, value) db[spec.path] = value end
function ns.Get(path) return db[path] end
function ns.Set(path, value) db[path] = value end
assert(loadfile("Plateau_Options/Widgets/ColorSwatch.lua"))("Plateau_Options", ns)
assert(loadfile("Plateau_Options/Widgets/Toggle.lua"))("Plateau_Options", ns)

local function IsTarget(list, frame)
    for _, entry in ipairs(list) do
        if entry.frame == frame then return true end
    end
    return false
end
local function TooltipSpecFor(frame)
    for _, t in ipairs(tooltips) do
        if t.frame == frame then return t.spec end
    end
end

local spec = { path = "look.test.on", label = "Test toggle", tooltip = "A toggle." }
db[spec.path] = false
local row = ns.Widgets.Toggle({}, spec)
row:Refresh()
local labelHit = labelHits[1]

local track
for _, entry in ipairs(created) do
    if entry.kind == "Frame" and entry.frame.parent == row then
        track = entry.frame
    end
end
check(track ~= nil, "found the track frame (the switch graphic)")
check(labelHit ~= nil and labelHit ~= row and labelHit ~= track, "the label has its own hit region, distinct from the row and the track")

check(not IsTarget(resetTargets, row), "right-click-to-reset is not wired to the whole row (no more dead-zone resets)")
check(IsTarget(resetTargets, labelHit), "right-click-to-reset is wired to the label's own hit region")
check(not IsTarget(resetTargets, track), "right-click-to-reset is not wired to the track")

check(TooltipSpecFor(row) == nil, "the row itself has no tooltip, so hovering dead space (below the track, beside it) shows nothing")
local hitSpec, trackSpec = TooltipSpecFor(labelHit), TooltipSpecFor(track)
check(hitSpec ~= nil and hitSpec.path == spec.path, "the label hit region's tooltip carries the real spec, with its reset hint")
check(trackSpec ~= nil and trackSpec.path == nil, "the track's own tooltip has no path, so it never claims right-click resets it")

check(db[spec.path] == false, "starts off")
track:Fire("OnMouseUp", "LeftButton")
check(db[spec.path] == true, "left-clicking the track itself still toggles the value")
track:Fire("OnMouseUp", "RightButton")
check(db[spec.path] == true, "right-clicking the track does nothing (it doesn't reset or toggle)")
labelHit:Fire("OnMouseUp", "LeftButton")
check(db[spec.path] == false, "left-clicking the label text still toggles the value")
row:Fire("OnClick")
check(db[spec.path] == true, "clicking elsewhere on the row (native Button click) still toggles the value too")

borderColors = {}
track:Fire("OnEnter")
check(#borderColors > 0 and borderColors[#borderColors].frame == track, "hovering the track still drives the shared hover-tint update")
track:Fire("OnLeave")
check(#borderColors > 0 and borderColors[#borderColors].frame == track, "leaving the track restores the hover-tint update too")

resetTargets, tooltips = {}, {}
local colorSpec = { path = "look.test.colorOn", colorPath = "look.test.color", label = "Colored toggle", tooltip = "Toggles a colored thing." }
db[colorSpec.path] = false
db[colorSpec.colorPath] = { 1, 0, 0, 1 }
local colorRow = ns.Widgets.ToggleColor({}, colorSpec)
colorRow:Refresh()

local colorTrack, swatch
for _, entry in ipairs(created) do
    if entry.kind == "Frame" and entry.frame.parent == colorRow then
        colorTrack = entry.frame
    end
    if entry.kind == "Button" and entry.frame.parent == colorRow then
        swatch = entry.frame
    end
end
check(swatch ~= nil, "found the color swatch next to the switch")
check(not IsTarget(resetTargets, swatch), "right-click-to-reset is not wired to the ToggleColor swatch")
local swatchSpec = TooltipSpecFor(swatch)
check(swatchSpec ~= nil and swatchSpec.path == nil, "the ToggleColor swatch's own tooltip has no path either")
check(swatchSpec.label == colorSpec.label, "without an override, the swatch's tooltip label falls back to the toggle's own label")

tooltips = {}
local customSpec = {
    path = "look.test.colorOn2", colorPath = "look.test.color2", label = "Colored toggle 2",
    tooltip = "Toggles a colored thing.", swatchLabel = "Custom swatch label", swatchTooltip = "Custom swatch tooltip.",
}
db[customSpec.path] = false
db[customSpec.colorPath] = { 0, 1, 0, 1 }
local customRow = ns.Widgets.ToggleColor({}, customSpec)
customRow:Refresh()
local customSwatch
for _, entry in ipairs(created) do
    if entry.kind == "Button" and entry.frame.parent == customRow then
        customSwatch = entry.frame
    end
end
local customSwatchSpec = TooltipSpecFor(customSwatch)
check(customSwatchSpec ~= nil and customSwatchSpec.label == "Custom swatch label" and customSwatchSpec.tooltip == "Custom swatch tooltip.",
    "swatchLabel/swatchTooltip let a ToggleColor swatch show its own distinct tooltip")
