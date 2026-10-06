local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
function Frame:SetSize() end
function Frame:SetPoint() end
function Frame:SetScript(name, fn) self.scripts[name] = fn end
function Frame:HookScript() end
function Frame:EnableMouse() end
function Frame:CreateTexture()
    local texture = setmetatable({ scripts = {} }, Frame)
    function texture:SetColorTexture(r, g, b, a) self.shown = { r, g, b, a } end
    return texture
end
function CreateFrame() return setmetatable({ scripts = {} }, Frame) end

local timers = {}
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end }
local function RunTimers()
    local list = timers
    timers = {}
    for _, fn in ipairs(list) do fn() end
end

local mouseDown = false
function IsMouseButtonDown() return mouseDown end

ColorPickerFrame = { cur = { 0, 0, 0 }, alpha = 1 }
function ColorPickerFrame:GetColorRGB() return self.cur[1], self.cur[2], self.cur[3] end
function ColorPickerFrame:GetColorAlpha() return self.alpha end
ColorPickerFrame.strata = "DIALOG"
function ColorPickerFrame:GetFrameStrata() return self.strata end
function ColorPickerFrame:SetFrameStrata(strata) self.strata = strata end
function ColorPickerFrame:Raise() self.raised = true end
function ColorPickerFrame:HookScript(name, fn) self.onHide = fn end
function ColorPickerFrame:SetColorRGB(r, g, b)
    self.cur = { r, g, b }
    if self.swatchFunc then self.swatchFunc() end
end
function ColorPickerFrame:SetupColorPickerAndShow(info)
    self.swatchFunc, self.opacityFunc, self.cancelFunc = info.swatchFunc, info.opacityFunc, info.cancelFunc
    self.opacity = info.opacity
    self.previousValues = { r = info.r, g = info.g, b = info.b, a = info.opacity }
    self:SetColorRGB(info.r, info.g, info.b)
    self.alpha = self.opacity
    if self.opacityFunc then self.opacityFunc() end
end
local function Pick(r, g, b)
    mouseDown = true
    ColorPickerFrame:SetColorRGB(r, g, b)
    mouseDown = false
end
local function Okay()
    ColorPickerFrame.swatchFunc()
    ColorPickerFrame.opacityFunc()
end
local function Cancel()
    ColorPickerFrame.cancelFunc(ColorPickerFrame.previousValues)
end

local db = {}
local writes = 0
local resetTargets, tooltips, labelHits = {}, {}, {}
local ns = {
    Widgets = {},
    Style = {
        colors = { border = {} },
        Fill = function() end,
        Border = function() end,
        HoverBorder = function() end,
        RowLabel = function() return setmetatable({ scripts = {} }, Frame) end,
        LabelHit = function(label)
            local hit = CreateFrame("Frame")
            labelHits[#labelHits + 1] = hit
            return hit
        end,
        OverrideLabel = function() end,
        RightClickReset = function(frame, spec, refresh) resetTargets[#resetTargets + 1] = { frame = frame, refresh = refresh } end,
        Tooltip = function(frame, spec) tooltips[#tooltips + 1] = { frame = frame, spec = spec } end,
    },
}
function ns.Get(path) local v = db[path] return { v[1], v[2], v[3], v[4] } end
function ns.Set(path, value) writes = writes + 1 db[path] = { value[1], value[2], value[3], value[4] } end
assert(loadfile("Plateau_Options/Widgets/ColorSwatch.lua"))("Plateau_Options", ns)

local function Swatch(start, setter)
    db.color = start
    writes = 0
    return ns.Widgets.MakeSwatch({}, "color", setter)
end
local function Stored() return db.color end
local function Is(value, r, g, b)
    return math.abs(value[1] - r) < 0.001 and math.abs(value[2] - g) < 0.001 and math.abs(value[3] - b) < 0.001
end

local swatch = Swatch({ 0, 0, 0, 1 })
swatch.scripts.OnClick()
RunTimers()
check(Is(ColorPickerFrame.cur, 1, 1, 1), "a black color opens the picker at white, so the wheel picks real colors")
check(writes == 0 and Is(Stored(), 0, 0, 0), "just opening the picker on a black color saves nothing")
Okay()
RunTimers()
check(writes == 0 and Is(Stored(), 0, 0, 0), "Okay without touching anything keeps black")

swatch.scripts.OnClick()
Pick(1, 0, 0)
Okay()
RunTimers()
check(Is(Stored(), 1, 0, 0), "picking red on the wheel and pressing Okay saves red")

db.color = { 0, 0, 0, 1 }
swatch.scripts.OnClick()
Pick(0, 1, 0)
RunTimers()
check(Is(Stored(), 0, 1, 0), "the color previews live while the picker is open")
Cancel()
check(Is(Stored(), 0, 0, 0), "Cancel puts back the real starting color (black), not the white the picker opened at")

db.color = { 0, 0, 0, 1 }
swatch.scripts.OnClick()
Pick(1, 1, 1)
Okay()
RunTimers()
check(Is(Stored(), 1, 1, 1), "deliberately clicking white on the wheel saves white")

db.color = { 0, 0, 0, 1 }
writes = 0
swatch.scripts.OnClick()
Cancel()
RunTimers()
check(writes == 0, "cancelling without changing anything writes nothing")

swatch = Swatch({ 0.2, 0.4, 0.9, 1 })
swatch.scripts.OnClick()
RunTimers()
check(Is(ColorPickerFrame.cur, 0.2, 0.4, 0.9) and writes == 0, "a normal color opens as itself and opening saves nothing")
Pick(0, 1, 0)
Okay()
RunTimers()
check(Is(Stored(), 0, 1, 0), "a normal color still changes as before")

local received
swatch = Swatch({ 0, 0, 0, 1 }, function(value) received = value db.color = value end)
swatch.scripts.OnClick()
Pick(1, 0, 0)
Okay()
RunTimers()
check(received and Is(received, 1, 0, 0), "a control's own setter receives the picked color")
received = nil
swatch.scripts.OnClick()
Pick(0, 0, 1)
Cancel()
RunTimers()
check(received == nil and Is(Stored(), 1, 0, 0), "Cancel restores the color without calling the control's setter, so a cancel never switches a border on")

local spec = { path = "look.test.border", label = "Border color", tooltip = "The border color." }
db["look.test.border"] = { 0.1, 0.2, 0.3, 1 }
local row = ns.Widgets.Color({}, spec)
local labelHit = labelHits[1]

local function IsTarget(list, frame)
    for _, entry in ipairs(list) do
        if entry.frame == frame then return true end
    end
    return false
end
check(labelHit ~= nil and labelHit ~= row, "the label has its own hit region, distinct from the row")
check(not IsTarget(resetTargets, row), "right-click-to-reset is not wired to the whole row (no more dead-zone resets)")
check(IsTarget(resetTargets, labelHit), "right-click-to-reset is wired to the label's own hit region")

local hitSpec, swatchFrame, swatchSpec
for _, t in ipairs(tooltips) do
    if t.frame == labelHit then
        hitSpec = t.spec
    else
        swatchFrame, swatchSpec = t.frame, t.spec
    end
end
check(hitSpec ~= nil and hitSpec.path == "look.test.border", "the label hit region's tooltip carries the real spec, with its reset hint")
check(swatchSpec ~= nil and swatchSpec.path == nil, "the swatch's own tooltip has no path, so it never claims right-click resets it")
check(swatchFrame ~= nil and swatchFrame ~= row and swatchFrame ~= labelHit, "the swatch is a distinct frame from the row and the label hit region")
check(not IsTarget(resetTargets, swatchFrame), "right-click-to-reset is not wired to the swatch itself anymore")

check(ColorPickerFrame.strata == "FULLSCREEN_DIALOG" and ColorPickerFrame.raised, "the picker opens above the settings window, so a click on OK can't land on the window and count as cancel")
ColorPickerFrame.onHide(ColorPickerFrame)
check(ColorPickerFrame.strata == "DIALOG", "the picker goes back to its normal layer when it closes")
