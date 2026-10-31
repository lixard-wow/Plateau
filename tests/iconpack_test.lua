local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

function issecretvalue() return false end
C_CurveUtil = {}

local function Frame(width, height)
    local frame = { width = width, height = height, shown = true }
    function frame:GetWidth() return self.width end
    function frame:GetHeight() return self.height end
    function frame:IsShown() return self.shown end
    function frame:ClearAllPoints() self.point = nil end
    function frame:SetPoint(point, anchor, relative, x, y) self.point = { point, anchor, relative, x, y } end
    function frame:SetSize(w, h) self.width, self.height = w, h end
    return frame
end

local ns = {}
assert(loadfile("Plateau/Core/Layout.lua"))("Plateau", ns)

local function Plate()
    local plate = Frame(120, 10)
    plate.raidMarker = Frame(20, 20)
    plate.classification = Frame(16, 16)
    plate.quest = Frame(16, 16)
    plate.faction = Frame(16, 16)
    return plate
end

local function db(position, x, y)
    return { position = position, gap = 2, offsetX = x or 0, offsetY = y or 0 }
end

local function x(icon) return icon.point[4] end
local function y(icon) return icon.point[5] end

local plate = Plate()
plate.quest.shown, plate.faction.shown = false, false
ns.HoldIcon(plate, plate.raidMarker, db("LEFT"))
ns.HoldIcon(plate, plate.classification, db("LEFT"))
ns.HoldIcon(plate, plate.quest, db("RIGHT"))
ns.HoldIcon(plate, plate.faction, db("TOP"))
check(x(plate.raidMarker) == -2, "the first icon in a left-side group keeps its spot")
check(x(plate.classification) == -2 - 22, "a second icon on the same left spot sits beside it, growing left")
check(x(plate.quest) == 2, "an icon on its own spot is placed as before")

plate.raidMarker.shown = false
ns.PackIcons(plate)
check(x(plate.classification) == -2, "when the first icon hides, the next one takes its spot")

plate = Plate()
plate.quest.shown, plate.faction.shown = false, false
ns.HoldIcon(plate, plate.raidMarker, db("RIGHT"))
ns.HoldIcon(plate, plate.classification, db("RIGHT", 3, 1))
check(x(plate.raidMarker) == 2 and x(plate.classification) == 2 + 22, "icons dropped a few pixels apart still group, growing right")
check(y(plate.classification) == 0, "grouped icons line up with the first icon")

plate = Plate()
plate.faction.shown = false
ns.HoldIcon(plate, plate.raidMarker, db("TOP"))
ns.HoldIcon(plate, plate.classification, db("TOP"))
ns.HoldIcon(plate, plate.quest, db("TOP"))
ns.HoldIcon(plate, plate.faction, db("LEFT"))
local total = 20 + 16 + 16 + 4
check(x(plate.raidMarker) == -total / 2 + 10, "a top group is centered on its spot (first)")
check(x(plate.quest) == total / 2 - 8, "a top group is centered on its spot (last)")
check(x(plate.raidMarker) + x(plate.quest) + 2 == 0 or math.abs((x(plate.raidMarker) - 10) + (x(plate.quest) + 8)) < 1e-9, "a centered group is balanced")

plate = Plate()
ns.HoldIcon(plate, plate.raidMarker, db("LEFT"))
ns.HoldIcon(plate, plate.classification, db("LEFT", 30, 0))
check(x(plate.classification) == 30 - 2, "icons far apart don't group")

plate = Plate()
ns.HoldIcon(plate, plate.raidMarker, db("LEFT"))
plate.faction.plBase = nil
ns.HoldIcon(plate, plate.classification, db("LEFT"))
check(x(plate.classification) == -24, "an icon placed by its own rule (faction beside a name) is left out of groups")
