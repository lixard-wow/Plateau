local ns = {}
local function Texture()
    local t = { points = {}, shown = true }
    function t:SetSnapToPixelGrid(v) self.snap = v end
    function t:SetTexelSnappingBias(v) self.bias = v end
    function t:ClearAllPoints() self.points = {} end
    function t:SetPoint(...) self.points[#self.points + 1] = { ... } end
    function t:SetHeight(v) self.height = v end
    function t:SetWidth(v) self.width = v end
    function t:SetSize(w, h) self.width, self.height = w, h end
    function t:SetShown(v) self.shown = v and true or false end
    function t:Hide() self.shown = false end
    function t:SetColorTexture() end
    function t:SetVertexColor(r, g, b, a) self.color = { r, g, b, a } end
    function t:SetGradient() end
    function t:SetTexture(path) self.texture = path end
    function t:SetTexCoord() end
    function t:SetAlpha(a) self.alpha = a end
    function t:GetDrawLayer() return "BACKGROUND", -8 end
    return t
end
local owner = { CreateTexture = function() return Texture() end }
function CreateColor(r, g, b, a)
    return { SetRGBA = function() end }
end
assert(loadfile("Plateau/Core/Border.lua"))("Plateau", ns)
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function Thick(edge)
    local a, b = edge.points[1], edge.points[2]
    return a and b and (a[5] - b[5]) or nil
end

local glow = ns.CreateBorder(owner, owner, "BACKGROUND", -8)
glow:Layout(8, 1)
glow:SetFade(0, 0.5, 1, 0.75)
glow:Show()
check(glow.corners and #glow.corners == 4, "a soft glow gets four rounded corners")
check(glow.corners[1].shown and glow.corners[1].width == 8 and glow.corners[1].texture:find("glow%-corner"), "corners show at the glow size")
local top = glow.edges[1].points
check(top[1][4] == -1 and top[2][4] == 1, "the top strip stops at the corners instead of running past them")
check(glow.corners[2].color[4] == 0.75, "corners take the glow color")
local snapped = glow.edges[1].snap == true
for i = 1, 4 do
    snapped = snapped and glow.corners[i].snap == true and glow.corners[i].bias == 0
end
check(snapped, "glow corners stay on the pixel grid like the strips, so a moving glow does not shimmer")
glow:SetAlpha(0.4)
check(glow.corners[3].alpha == 0.4, "pulsing fades the corners with the strips")
glow:Hide()
check(not glow.corners[4].shown, "hiding the glow hides its corners")

local border = ns.CreateBorder(owner, owner, "BACKGROUND", 0)
border:SetStyle("pixel")
border:Layout(1, 0)
border:SetColor(0, 0, 0, 1)
border:Show()
check(border.corners == nil and border.edges[1].points[1][4] == -1, "a plain border keeps square full-length edges")

local shadow = ns.CreateBorder(owner, owner, "BACKGROUND", 0)
shadow:SetStyle("shadow")
shadow:Layout(1, 0)
shadow:SetColor(0, 0, 0, 1)
shadow:Show()
check(shadow.corners and shadow.corners[1].shown, "the shadow border style gets rounded corners too")
shadow:SetStyle("pixel")
shadow:Layout(1, 0)
shadow:SetColor(0, 0, 0, 1)
shadow:Show()
check(not shadow.corners[1].shown, "switching back to a plain border hides the corners")

local scale = 0.5
local plateAnchor = { CreateTexture = owner.CreateTexture, GetEffectiveScale = function() return scale end }
PixelUtil = { GetPixelToUIUnitFactor = function() return 0.5 end }
local plate = { GetEffectiveScale = function() return scale end }
local ring = ns.CreateBorder(plateAnchor, plateAnchor, "BACKGROUND", 0)
ns.pixelBorders, ns.pixelPlate, ns.pixelPerfect = true, plate, true
ring:Layout(1, 2)
ns.pixelBorders, ns.pixelPlate = false, nil
check(plate.pixelSet and plate.pixelSet[ring] and plate.pixelSet[ring][1] == 1 and plate.pixelSet[ring][2] == 2, "a border laid out while styling a plate is remembered with its settings")
check(Thick(ring.edges[1]) == 1, "one pixel is one screen pixel at the plate's scale")
scale = 2
ns.RepixelPlate(plate)
check(Thick(ring.edges[1]) == 0.25, "after the plate is rescaled, its borders are redrawn at one screen pixel again")
local before = ring.edges[1].points
ns.RepixelPlate(plate)
check(ring.edges[1].points == before, "redrawing at an unchanged scale is skipped")
check(ns.pixelBorders == false, "redrawing leaves pixel mode the way it found it")
ns.pixelPerfect = false
scale = 1
ns.RepixelPlate(plate)
check(Thick(ring.edges[1]) == 0.25, "with pixel-perfect borders off, rescaling leaves borders alone")
scale = 0.05
ns.pixelPerfect = true
ns.RepixelPlate(plate)
check(Thick(ring.edges[1]) == 1, "a plate with a tiny scale (just created) keeps interface units instead of huge borders")

local guarded = {}
local auraRing = ns.CreateBorder(plateAnchor, plateAnchor, "BACKGROUND", 0)
auraRing.restricted = true
ns.pixelBorders, ns.pixelPlate = true, guarded
auraRing:Layout(1, 0)
ns.pixelBorders, ns.pixelPlate = false, nil
check(guarded.pixelSet == nil or guarded.pixelSet[auraRing] == nil, "borders on Blizzard's protected aura icons are never redrawn later, so restrictions can't block them")

local joinOwner = { CreateTexture = owner.CreateTexture }
local seam = ns.CreateBorder(joinOwner, joinOwner, "BACKGROUND", 0)
seam:Layout(1, 0)
seam:Show()
seam:SetEdgeHidden(1, true)
check(not seam.edges[1].shown and seam.edges[2].shown and seam.edges[3].shown and seam.edges[4].shown, "a joined cast bar hides only its top edge")
seam:Hide()
seam:Show()
check(not seam.edges[1].shown and seam.edges[2].shown, "the hidden edge stays hidden when the border is shown again")
seam:SetEdgeHidden(1, false)
check(seam.edges[1].shown, "unjoining brings the top edge back")

issecretvalue = issecretvalue or function() return false end
PixelUtil = { GetPixelToUIUnitFactor = function() return 0.5333 end }
local sized = { rawWidth = 125, rawHeight = 11, GetEffectiveScale = function() return 1 end }
function sized:SetSize(w, h) self.w, self.h = w, h end
ns.pixelPerfect = true
ns.SnapPlateSize(sized)
local pixelsWide, pixelsHigh = sized.w / 0.5333, sized.h / 0.5333
check(math.abs(pixelsWide - math.floor(pixelsWide + 0.5)) < 1e-6 and math.abs(pixelsHigh - math.floor(pixelsHigh + 0.5)) < 1e-6, "a nameplate is sized to whole screen pixels, so its edges do not shimmer as it moves")
check(math.abs(sized.w - 125) <= 0.5333 / 2 + 1e-9, "the snapped width is within half a pixel of the setting")
local calls = 0
function sized:SetSize(w, h) calls = calls + 1 end
ns.SnapPlateSize(sized)
check(calls == 0, "an unchanged size is not set again")
local previewPlate = { rawWidth = 125, rawHeight = 11, preview = true, GetEffectiveScale = function() return 1 end }
function previewPlate:SetSize(w, h) self.w = w end
ns.SnapPlateSize(previewPlate)
check(math.abs(previewPlate.w / 0.5333 - math.floor(previewPlate.w / 0.5333 + 0.5)) < 1e-6, "the settings preview is sized to whole screen pixels like a real nameplate")
ns.pixelPerfect = false
ns.SnapPlateSize(previewPlate)
check(previewPlate.w == 125, "with pixel-perfect off the settings preview keeps the exact size")
ns.pixelPerfect = true

ns.pixelPerfect, ns.pixelBorders = nil, nil
local steady = ns.CreateBorder(owner, owner, "BACKGROUND", 0)
local clears = 0
local edge = steady.edges[1]
local clear = edge.ClearAllPoints
function edge:ClearAllPoints() clears = clears + 1 clear(self) end
steady:Layout(2, 1)
local laid = steady.laidOut
clears = 0
steady:Layout(2, 1)
check(clears == 0, "laying out a border again with the same settings does no anchor work")
check(steady.laidOut == laid, "...and reuses its saved layout instead of making a new one")
steady:Layout(3, 1)
check(clears == 1 and Thick(steady.edges[1]) == 3, "a new size lays the border out again")
steady:SetAnchor({})
clears = 0
steady:Layout(3, 1)
check(clears == 1, "a new anchor lays the border out again")
steady:Show()
steady:Hide()
steady:Layout(3, 1)
check(not steady.edges[1].shown, "a skipped layout still respects a hidden border")

local fades = 0
local soft = ns.CreateBorder(owner, owner, "BACKGROUND", 0)
soft:Layout(4, 1)
local topEdge = soft.edges[1]
local gradient = topEdge.SetGradient
function topEdge:SetGradient(...) fades = fades + 1 gradient(self, ...) end
soft:SetFade(1, 0, 0, 1)
local saved = soft.fadeColor
fades = 0
soft:SetFade(1, 0, 0, 1)
check(fades == 0, "setting the same glow color again does nothing")
check(soft.fadeColor == saved, "...and keeps its saved color instead of making a new one")
soft:SetFade(0, 1, 0, 1)
check(fades == 1, "a new glow color is applied")
soft:SetPulse(0.4)
fades = 0
soft:SetFade(0, 1, 0, 1)
check(fades == 1, "the same color is applied again after a pulse dimmed it")

local roundCalls = 0
local function Region()
    return { SetRoundLayoutToNearestPixel = function(self, on) roundCalls = roundCalls + 1 self.rounded = on end }
end
local function Node(regions, children)
    local node = Region()
    node.regions, node.children = regions, children
    function node:GetRegions() return unpack(self.regions) end
    function node:GetChildren() return unpack(self.children) end
    function node:IsForbidden() return false end
    return node
end
local leaf = Node({ Region(), Region() }, {})
local skipped = Node({ Region() }, {})
skipped.AddAuraGroup = function() end
local root = Node({ Region() }, { leaf, skipped })
ns.pixelPerfect = true
ns.RoundLayout(root)
check(roundCalls == 5 and leaf.regions[2].rounded == true, "pixel rounding reaches every frame and region of a plate")
check(skipped.rounded == nil and skipped.regions[1].rounded == nil, "...but never an aura container's internals")
roundCalls = 0
ns.RoundLayout(root)
check(roundCalls == 0, "rounding a plate again with the same setting changes nothing")
leaf.regions[3] = Region()
ns.RoundLayout(root)
check(roundCalls == 1 and leaf.regions[3].rounded == true, "art added later is rounded on the next pass")
roundCalls = 0
ns.pixelPerfect = false
ns.RoundLayout(root)
check(roundCalls == 6 and root.rounded == false, "turning pixel-perfect off updates everything")
