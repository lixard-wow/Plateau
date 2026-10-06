local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
local frames = {}

local function PointOf(frame, point)
    local x, y = (frame.l + frame.r) / 2, (frame.t + frame.b) / 2
    if point:find("LEFT") then x = frame.l elseif point:find("RIGHT") then x = frame.r end
    if point:find("TOP") then y = frame.t elseif point:find("BOTTOM") then y = frame.b end
    return x, y
end

local function NewFrame(parent)
    local frame = setmetatable({ parent = parent, shown = true, scripts = {}, l = 0, r = 0, t = 0, b = 0 }, Frame)
    frames[#frames + 1] = frame
    return frame
end

function Frame:Rect(l, r, t, b) self.l, self.r, self.t, self.b = l, r, t, b return self end
function Frame:GetLeft() return self.l end
function Frame:GetRight() return self.r end
function Frame:GetTop() return self.t end
function Frame:GetBottom() return self.b end
function Frame:GetWidth() return self.r - self.l end
function Frame:GetHeight() return self.t - self.b end
function Frame:GetParent() return self.parent end
function Frame:IsVisible() return self.shown end
function Frame:IsShown() return self.shown end
function Frame:Show() self.shown = true end
function Frame:Hide() self.shown = false end
function Frame:SetShown(shown) self.shown = shown and true or false end
function Frame:GetEffectiveScale() return 1 end
function Frame:ClearAllPoints() end
function Frame:SetSize(w, h)
    local cx, cy = (self.l + self.r) / 2, (self.t + self.b) / 2
    self.l, self.r, self.t, self.b = cx - w / 2, cx + w / 2, cy + h / 2, cy - h / 2
end
function Frame:SetPoint(point, rel, relPoint, x, y)
    if type(rel) ~= "table" then return end
    self.anchor, self.anchorPoint, self.anchorX, self.anchorY = rel, relPoint, x or 0, y or 0
    local w, h = self:GetWidth(), self:GetHeight()
    local ax, ay = PointOf(rel, relPoint)
    ax, ay = ax + (x or 0), ay + (y or 0)
    local fx = point:find("LEFT") and -w / 2 or point:find("RIGHT") and w / 2 or 0
    local fy = point:find("TOP") and h / 2 or point:find("BOTTOM") and -h / 2 or 0
    local cx, cy = ax - fx, ay - fy
    self.l, self.r, self.t, self.b = cx - w / 2, cx + w / 2, cy + h / 2, cy - h / 2
end
function Frame:SetAllPoints(rel)
    rel = rel or self.parent
    self.l, self.r, self.t, self.b = rel.l, rel.r, rel.t, rel.b
end
function Frame:SetScript(name, fn) self.scripts[name] = fn end
function Frame:HookScript(name, fn) self.scripts[name] = fn end
function Frame:GetFrameLevel() return 1 end
function Frame:SetFrameLevel() end
function Frame:EnableKeyboard() end
function Frame:SetPropagateKeyboardInput() end
function Frame:RegisterEvent() end
function Frame:CreateTexture()
    local texture = NewFrame(self)
    texture.isTexture = true
    return texture
end
function Frame:SetColorTexture() end
function Frame:SetDrawLayer() end

function CreateFrame(_, _, parent) return NewFrame(parent) end
UIParent = NewFrame():Rect(0, 4000, 4000, 0)

local cursorX, cursorY, mouseDown = 0, 0, false
function GetCursorPosition() return cursorX, cursorY end
function IsMouseButtonDown() return mouseDown end
function IsShiftKeyDown() return false end
function InCombatLockdown() return false end

local db = {}
local saved
local coreNs = {}
assert(loadfile("Plateau/Core/Layout.lua"))("Plateau", coreNs)
Plateau = {
    iconPositions = coreNs.iconPositions,
    textPositions = coreNs.textPositions,
    DB = {
        saved = { global = {} },
        Get = function(_, path) return db[path] end,
        SetMany = function(_, values)
            saved = values
            for k, v in pairs(values) do db[k] = v end
        end,
    },
}

local ns = { Style = {
    colors = { muted = { 0.5, 0.5, 0.5 }, accent = { 1, 1, 1 } },
    Border = function() end,
    ThemedBorder = function() end,
    StateColor = function() return { 1, 1, 1 } end,
} }
local firstFrame = #frames + 1
assert(loadfile("Plateau_Options/Panels/Drag.lua"))("Plateau_Options", ns)
local Drag = ns.Drag
local driver
for i = firstFrame, #frames do
    if frames[i].scripts.OnUpdate then driver = frames[i] end
end
local function Tick() driver.scripts.OnUpdate(driver) end

local panel = NewFrame(UIParent):Rect(-1000, 1000, 1000, -1000)
Drag.SetDotParent(panel)

local function Dots()
    local list = {}
    for _, frame in ipairs(frames) do
        if frame.isTexture and frame.shown and frame.anchor then
            list[#list + 1] = frame
        end
    end
    return list
end

local function DotAt(x, y)
    for _, dot in ipairs(Dots()) do
        local cx, cy = (dot.l + dot.r) / 2, (dot.t + dot.b) / 2
        if math.abs(cx - x) < 0.01 and math.abs(cy - y) < 0.01 then return dot end
    end
end

local function Drop(spec, spot, fromX, fromY, toX, toY)
    saved = nil
    cursorX, cursorY, mouseDown = fromX, fromY, true
    Drag.Press(spec, spot)
    cursorX, cursorY = fromX + (toX > fromX and 5 or -5), fromY
    Tick()
    cursorX, cursorY = toX + (toX > fromX and 5 or -5), toY
    Tick()
    local shown = Dots()
    local snapshot = {}
    for i, dot in ipairs(shown) do
        snapshot[i] = { x = (dot.l + dot.r) / 2, y = (dot.t + dot.b) / 2, anchor = dot.anchor }
    end
    mouseDown = false
    Tick()
    return snapshot
end

local function Placed(width, height, anchor, key, gap, x, y)
    local probe = NewFrame():Rect(0, width, height, 0)
    local position = Plateau.iconPositions[key]
    probe:SetPoint(position[1], anchor, position[2], position[3] * gap + x, position[4] * gap + y)
    return probe
end

local plate = NewFrame(panel):Rect(0, 100, 10, 0)
plate.health = NewFrame(plate):Rect(0, 100, 10, 0)
plate.castbar = NewFrame(plate):Rect(0, 100, -2, -12)
plate.classPower = NewFrame(plate):Rect(20, 70, -40, -46)
local targets = { plate.health, plate.castbar, plate.classPower }
Drag.SetTargets(function() return targets end)

db["look.classPower.position"] = "BOTTOM"
db["look.classPower.gap"] = 22
db["look.classPower.offsetX"] = 0
db["look.classPower.offsetY"] = 0
local classSpot = NewFrame(plate)
local classSpec = Drag.PositionSpec({ path = "look.classPower", region = plate.classPower, anchor = function() return plate end, noRing = true })
Drag.Register(classSpot, classSpec)

local dots = Drop(classSpec, classSpot, 45, -43, 51, -18)
check(#dots >= 6, "class resource drag shows snap dots around the other items (" .. #dots .. " dots)")
local belowCast
for _, dot in ipairs(dots) do
    if dot.anchor == plate.castbar and math.abs(dot.x - 50) < 0.01 and math.abs(dot.y + 14) < 0.01 then belowCast = dot end
end
check(belowCast ~= nil, "a dot sits 2px under the middle of the cast bar")
local selfDot = false
for _, dot in ipairs(dots) do
    if dot.anchor == plate.classPower then selfDot = true end
end
check(not selfDot, "the dragged item never shows dots on itself")
check(saved and saved["look.classPower.position"] ~= nil, "dropping near the cast bar saves a class resource position")
if saved then
    local probe = Placed(50, 6, plate, db["look.classPower.position"], 22, db["look.classPower.offsetX"], db["look.classPower.offsetY"])
    local tx, ty = PointOf(probe, "TOP")
    check(math.abs(tx - 50) < 0.01 and math.abs(ty + 14) < 0.01,
        "saved class resource values render its top exactly at that dot (got " .. tx .. "," .. ty .. ")")
end

plate.classPower:Rect(20, 70, -40, -46)
dots = Drop(classSpec, classSpot, 45, -43, 128, -8)
if saved then
    local probe = Placed(50, 6, plate, db["look.classPower.position"], 22, db["look.classPower.offsetX"], db["look.classPower.offsetY"])
    local lx, ly = PointOf(probe, "LEFT")
    check(math.abs(lx - 102) < 0.01 and math.abs(ly + 7) < 0.01,
        "dropping beside the cast bar attaches to its right edge (got " .. lx .. "," .. ly .. ")")
else
    check(false, "dropping beside the cast bar saves a position")
end

plate.nameClip = NewFrame(plate):Rect(0, 100, 24, 12)
plate.name = NewFrame(plate.nameClip):Rect(30, 70, 21, 15)
plate.raidMarker = NewFrame(plate):Rect(10, 28, 28, 10)
targets = { plate.health, plate.castbar, plate.name, plate.raidMarker }
db["look.name.position"] = "TOP"
db["look.name.gap"] = 2
local nameSpot = NewFrame(plate)
local nameSpec = Drag.NameSpec(plate)
Drag.Register(nameSpot, nameSpec)
dots = Drop(nameSpec, nameSpot, 50, 18, 50, 37)
check(saved and saved["look.name.position"] == "TOP" and saved["look.name.gap"] == 20,
    "name snaps its bottom 2px above the raid marker (got " .. tostring(saved and saved["look.name.position"]) .. " " .. tostring(saved and saved["look.name.gap"]) .. ")")
local nameSelf = false
for _, dot in ipairs(dots) do
    if dot.anchor == plate.name then nameSelf = true end
end
check(not nameSelf, "name never shows dots on its own text")

plate.nameClip:Rect(0, 100, 24, 12)
plate.classPower:Rect(20, 70, -100, -106)
plate.castbar.target = NewFrame(plate.castbar):Rect(40, 60, -14, -22)
targets = { plate.health, plate.castbar, plate.castbar.target, plate.classPower }
db["look.castbar.gap"] = 2
local castSpot = NewFrame(plate)
local castSpec = Drag.CastbarSpec(plate)
Drag.Register(castSpot, castSpec)
dots = Drop(castSpec, castSpot, 50, -7, 50, -10)
local farDot, childDot = false, false
for _, dot in ipairs(dots) do
    if dot.anchor == plate.classPower then farDot = true end
    if dot.anchor == plate.castbar.target then childDot = true end
end
check(not farDot, "the cast bar shows no dots on items it can't reach (more than 30px away)")
check(not childDot, "the cast bar shows no dots on its own text, which moves with it")
check(#dots >= 1, "the cast bar still shows its snap point under the health bar")

plate.classPower:Rect(20, 70, -40, -46)
targets = { plate.health, plate.castbar, plate.classPower }
local ok = pcall(Drop, classSpec, classSpot, 45, -43, 200, -60)
check(ok, "a drop far from every item does not error")

local function Text(parent, l, r, t, b, words, justify)
    local text = NewFrame(parent):Rect(l, r, t, b)
    text.GetStringWidth = function() return words end
    text.GetJustifyH = function() return justify end
    return text
end

plate.castbar:Rect(0, 100, -2, -12)
plate.castbar.text = Text(plate.castbar, 3, 70, -2, -12, 40, "LEFT")
plate.classPower:Rect(20, 70, -40, -46)
targets = { plate.health, plate.castbar, plate.castbar.text, plate.classPower }
dots = Drop(classSpec, classSpot, 45, -43, 50, -30)
local offCentreEdge, wordsRight = false, false
for _, dot in ipairs(dots) do
    local onBarEdge = math.abs(dot.y + 14) < 0.01 or math.abs(dot.y) < 0.01
    if onBarEdge and math.abs(dot.x - 50) > 0.01 then offCentreEdge = true end
    if dot.anchor == plate.castbar.text and math.abs(dot.x - 45) < 0.01 and math.abs(dot.y + 7) < 0.01 then wordsRight = true end
end
check(not offCentreEdge, "the spell name inside the cast bar adds no stray dots on the bar's top or bottom edge")
check(wordsRight, "the spell name's side dot sits just past the visible words, not its stretched layout box")

plate.enemyPowerBar = NewFrame(plate):Rect(0, 100, -1, -5)
targets = { plate.health, plate.castbar, plate.enemyPowerBar }
db["look.enemyPower.position"] = "below"
local powerSpot = NewFrame(plate)
local powerSpec = Drag.EnemyPowerSpec(plate)
Drag.Register(powerSpot, powerSpec)
dots = Drop(powerSpec, powerSpot, 50, -3, 50, -6)
local castDot = false
for _, dot in ipairs(dots) do
    if dot.anchor == plate.castbar then castDot = true end
end
check(not castDot, "enemy power bar shows no dots on the cast bar, which it pushes down")
