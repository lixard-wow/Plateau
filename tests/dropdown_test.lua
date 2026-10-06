local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
function Frame:EnableMouse() end
function Frame:EnableMouseWheel() end
function Frame:SetPoint() end
function Frame:SetAllPoints() end
function Frame:SetSize() end
function Frame:SetHeight() end
function Frame:SetWidth() end
function Frame:SetFrameStrata() end
function Frame:SetFrameLevel() end
function Frame:GetFrameLevel() return 0 end
function Frame:GetWidth() return 100 end
function Frame:GetHeight() return 100 end
function Frame:GetTop() return 100 end
function Frame:GetEffectiveScale() return 1 end
function Frame:SetScale(scale) self.scale = scale end
function Frame:SetColorTexture() end
function Frame:SetAtlas() end
function Frame:SetTexture() end
function Frame:SetRotation() end
function Frame:SetText(t) self.text = t end
function Frame:GetText() return self.text end
function Frame:GetUnboundedStringWidth() return 40 end
function Frame:SetTextColor() end
function Frame:ClearAllPoints() end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:IsShown() return self.shown end
function Frame:SetEnabled() end
function Frame:SetShown(state) self.shown = state end
function Frame:CreateTexture() return setmetatable({ shown = true }, Frame) end
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
    local frame = setmetatable({ scripts = {}, hooks = {}, parent = parent, shown = false }, Frame)
    created[#created + 1] = { kind = kind, frame = frame }
    return frame
end

local resetTargets, tooltips, labelHits = {}, {}, {}
local db = {}
local ns = {
    Widgets = {},
    Style = {
        colors = { border = {}, field = {}, accent = {}, hover = {}, window = {}, text = {}, muted = {} },
        CONTROL_X = 0,
        CONTROL_WIDTH = 100,
        RowLabel = function() return setmetatable({}, Frame) end,
        LabelHit = function(label)
            local hit = CreateFrame("Frame", nil, label)
            labelHits[#labelHits + 1] = hit
            return hit
        end,
        Fill = function() return setmetatable({}, Frame) end,
        Border = function() end,
        Field = function() return setmetatable({}, Frame) end,
        Panel = function() end,
        ButtonBox = function() end,
        ThemedBorder = function() end,
        HoverBorder = function() end,
        StateColor = function() return { 1, 1, 1 } end,
        DropArrow = function() end,
        Text = function() return setmetatable({}, Frame) end,
        OverrideLabel = function() end,
        RightClickReset = function(frame, spec, refresh) resetTargets[#resetTargets + 1] = { frame = frame, refresh = refresh } end,
        Tooltip = function(frame, spec) tooltips[#tooltips + 1] = { frame = frame, spec = spec } end,
    },
}
function ns.Get(path) return db[path] end
function ns.Set(path, value) db[path] = value end
assert(loadfile("Plateau_Options/Widgets/Dropdown.lua"))("Plateau_Options", ns)

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

local spec = {
    path = "look.test.mode",
    label = "Test dropdown",
    tooltip = "Picks a mode.",
    options = { { value = "a", label = "A" }, { value = "b", label = "B" } },
}
db[spec.path] = "a"
local row = ns.Widgets.Dropdown({}, spec)
row:Refresh()
local labelHit = labelHits[1]

local button
for _, entry in ipairs(created) do
    if entry.kind == "Button" and entry.frame.parent == row then
        button = entry.frame
    end
end
check(button ~= nil, "found the dropdown button")
check(labelHit ~= nil and labelHit ~= row and labelHit ~= button, "the label has its own hit region, distinct from the row and the button")

check(not IsTarget(resetTargets, row), "right-click-to-reset is not wired to the whole row (no more dead-zone resets)")
check(IsTarget(resetTargets, labelHit), "right-click-to-reset is wired to the label's own hit region")
check(not IsTarget(resetTargets, button), "right-click-to-reset is not wired to the dropdown button")

check(TooltipSpecFor(row) == nil, "the row itself has no tooltip, so hovering dead space beside the button shows nothing")
local hitSpec, buttonSpec = TooltipSpecFor(labelHit), TooltipSpecFor(button)
check(hitSpec ~= nil and hitSpec.path == spec.path, "the label hit region's tooltip carries the real spec, with its reset hint")
check(buttonSpec ~= nil and buttonSpec.path == nil, "the button's own tooltip has no path, so it never claims right-click resets it")

button:Fire("OnClick")
check(ns.ShowList ~= nil, "clicking the button still opens the option list")

local many = {}
for i = 1, 30 do
    many[i] = i % 10 == 1 and { title = true, label = "TITLE " .. i } or { value = "v" .. i, label = "Option " .. i, checked = function() return false end }
end
ns.ShowList(button, many, nil, function() end, { width = 200, keepOpen = true, maxVisible = 20 })
local firstShown
for _, entry in ipairs(created) do
    if entry.kind == "Button" and entry.frame.text and entry.frame.text.text == many[1].label then
        firstShown = entry.frame
    end
end
check(firstShown ~= nil, "a list with no current value and section titles opens scrolled to the top, not the last title")
