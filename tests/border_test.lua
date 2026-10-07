local ns = {}
local function Texture()
    local t = { points = {}, shown = true }
    function t:SetSnapToPixelGrid() end
    function t:SetTexelSnappingBias() end
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

local glow = ns.CreateBorder(owner, owner, "BACKGROUND", -8)
glow:Layout(8, 1)
glow:SetFade(0, 0.5, 1, 0.75)
glow:Show()
check(glow.corners and #glow.corners == 4, "a soft glow gets four rounded corners")
check(glow.corners[1].shown and glow.corners[1].width == 8 and glow.corners[1].texture:find("glow%-corner"), "corners show at the glow size")
local top = glow.edges[1].points
check(top[1][4] == -1 and top[2][4] == 1, "the top strip stops at the corners instead of running past them")
check(glow.corners[2].color[4] == 0.75, "corners take the glow color")
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
local plate = {}
local ring = ns.CreateBorder(plateAnchor, plateAnchor, "BACKGROUND", 0)
ns.pixelBorders, ns.pixelPlate, ns.pixelPerfect = true, plate, true
ring:Layout(1, 2)
ns.pixelBorders, ns.pixelPlate = false, nil
check(plate.pixelSet and plate.pixelSet[ring] and plate.pixelSet[ring][1] == 1 and plate.pixelSet[ring][2] == 2, "a border laid out while styling a plate is remembered with its settings")
check(ring.edges[1].height == 1, "one pixel is one screen pixel at the plate's scale")
scale = 2
ns.RepixelPlate(plate)
check(ring.edges[1].height == 0.25, "after the plate is rescaled, its borders are redrawn at one screen pixel again")
check(ns.pixelBorders == false, "redrawing leaves pixel mode the way it found it")
ns.pixelPerfect = false
scale = 1
ns.RepixelPlate(plate)
check(ring.edges[1].height == 0.25, "with pixel-perfect borders off, rescaling leaves borders alone")
scale = 0.05
ns.pixelPerfect = true
ns.RepixelPlate(plate)
check(ring.edges[1].height == 1, "a plate with a tiny scale (just created) keeps interface units instead of huge borders")
