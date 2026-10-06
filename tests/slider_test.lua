local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
function Frame:EnableMouse() end
function Frame:SetPoint() end
function Frame:SetSize() end
function Frame:SetHeight() end
function Frame:SetFont() end
function Frame:SetTextColor() end
function Frame:SetJustifyH() end
function Frame:SetTextInsets() end
function Frame:SetAutoFocus() end
function Frame:SetColorTexture() end
function Frame:SetAllPoints() end
function Frame:AddMaskTexture() end
function Frame:SetTexture() end
function Frame:ClearAllPoints() end
function Frame:CreateTexture() return setmetatable({}, Frame) end
function Frame:CreateMaskTexture() return setmetatable({}, Frame) end
function Frame:GetWidth() return self.width end
function Frame:GetLeft() return self.left end
function Frame:GetEffectiveScale() return 1 end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown end
function Frame:SetScript(name, fn) self.scripts[name] = fn end
function Frame:HookScript(name, fn)
    self.hooks[name] = self.hooks[name] or {}
    table.insert(self.hooks[name], fn)
end
function Frame:Fire(name, ...)
    if self.scripts[name] then self.scripts[name](self, ...) end
    for _, fn in ipairs(self.hooks[name] or {}) do fn(self, ...) end
end
function Frame:GetText() return self.text end
function Frame:SetText(t) self.text = t end

local timers = {}
C_Timer = { After = function(_, fn) timers[#timers + 1] = fn end }
local function RunTimers()
    local list = timers
    timers = {}
    for _, fn in ipairs(list) do fn() end
end

local cursorX, mouseDown = 0, false
function GetCursorPosition() return cursorX end
function IsMouseButtonDown() return mouseDown end

local created = {}
function CreateFrame(kind, _, parent)
    local frame = setmetatable({ scripts = {}, hooks = {}, parent = parent }, Frame)
    created[#created + 1] = { kind = kind, frame = frame }
    return frame
end

local resetTargets = {}
local tooltips = {}
local labelHits = {}
local ns = {
    Widgets = {},
    Style = {
        colors = { border = {}, text = {} },
        font = "font",
        SetFont = function(fontString, file, size, flags) fontString:SetFont(file, size, flags) end,
        CONTROL_X = 0,
        RowLabel = function() return setmetatable({}, Frame) end,
        LabelHit = function(label)
            local hit = CreateFrame("Frame", nil, label)
            labelHits[#labelHits + 1] = hit
            return hit
        end,
        Fill = function() end,
        Border = function() end,
        Field = function() end,
        Themed = function() end,
        OverrideLabel = function() end,
        Tooltip = function(frame, spec) tooltips[#tooltips + 1] = { frame = frame, spec = spec } end,
        RightClickReset = function(frame) resetTargets[#resetTargets + 1] = frame end,
    },
}
local db = {}
function ns.SpecGet(spec) return db[spec.path] end
function ns.SpecSet(spec, value) db[spec.path] = value end
assert(loadfile("Plateau_Options/Widgets/Slider.lua"))("Plateau_Options", ns)

local spec = { path = "look.test.value", min = 0, max = 100 }
db[spec.path] = 20
local row = ns.Widgets.Slider({}, spec)
local labelHit = labelHits[1]

local track, driver
for _, entry in ipairs(created) do
    if entry.kind == "Frame" and entry.frame ~= row and not track and entry.frame.parent == row then
        track = entry.frame
    end
    if entry.kind == "Frame" and entry.frame.parent == nil then
        driver = entry.frame
    end
end
check(track ~= nil, "found the track frame that replaces the native Slider")
check(driver ~= nil, "found the shared drag-update driver frame")
check(labelHit ~= nil and labelHit ~= row and labelHit ~= track, "the label has its own hit region, distinct from the row and the track")

track.left, track.width = 100, 200
row:Refresh()

local THUMB = 13
local function CursorFor(value)
    local usable = 200 - THUMB
    local fraction = value / 100
    return 100 + THUMB / 2 + fraction * usable
end

local function IsTarget(list, frame)
    for _, f in ipairs(list) do
        if f == frame then return true end
    end
    return false
end
check(not IsTarget(resetTargets, row), "right-click-to-reset is not wired to the whole row (no more dead-zone resets)")
check(IsTarget(resetTargets, labelHit), "right-click-to-reset is wired to the label's own hit region")
check(not IsTarget(resetTargets, track), "right-click-to-reset is not wired to the track")

local function TooltipSpecFor(frame)
    for _, t in ipairs(tooltips) do
        if t.frame == frame then return t.spec end
    end
end
check(TooltipSpecFor(row) == nil, "the row itself has no tooltip, so hovering dead space between the track and the box shows nothing")
check(TooltipSpecFor(labelHit).path == spec.path, "the label hit region's tooltip carries the real spec, with its reset hint")
local trackSpec = TooltipSpecFor(track)
check(trackSpec ~= nil and trackSpec.path == nil, "the track's tooltip has no path, so it never claims right-click resets it")
local boxFrame
for _, entry in ipairs(created) do
    if entry.kind == "EditBox" then boxFrame = entry.frame end
end
local boxSpec = TooltipSpecFor(boxFrame)
check(boxSpec ~= nil and boxSpec.path == nil, "the value box's tooltip also has no path, so it never claims right-click resets it either")

cursorX = CursorFor(45)
track:Fire("OnMouseDown", "LeftButton")
check(driver:IsShown(), "pressing left on the track starts the drag driver")
mouseDown = true
driver:Fire("OnUpdate")
cursorX = CursorFor(70)
driver:Fire("OnUpdate")
mouseDown = false
driver:Fire("OnUpdate")
RunTimers()
check(db[spec.path] == 70, "dragging left-click across the track changes and saves the value")
check(not driver:IsShown(), "the driver stops itself once the mouse button is released")

db[spec.path] = 20
row:Refresh()
cursorX = CursorFor(60)
track:Fire("OnMouseDown", "RightButton")
RunTimers()
check(db[spec.path] == 20, "right-clicking the track does not move or save anything")
check(not driver:IsShown(), "right-clicking the track never starts the drag driver")

cursorX = CursorFor(45)
track:Fire("OnMouseDown", "LeftButton")
mouseDown = true
driver:Fire("OnUpdate")
track:Fire("OnMouseUp", "LeftButton")
mouseDown = false
RunTimers()
check(db[spec.path] == 45, "left-click still works normally right after a no-op right-click")
