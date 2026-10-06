local ns = { Elements = {}, Driver = { RegisterElement = function() end } }
function issecretvalue() return false end
C_CurveUtil = {
    EvaluateColorValueFromBoolean = function(cond, a, b) return cond and a or b end,
    CreateCurve = function() return { SetType = function() end, AddPoint = function() end } end,
}
Enum = { LuaCurveType = { Step = 0, Linear = 1 }, StatusBarInterpolation = { Immediate = 0, ExponentialEaseOut = 1 } }
CurveConstants = { ZeroToOne = 1 }
function UnitHealthPercent(_, _, curve) if type(curve) == "table" and curve.testColor then return curve.testColor end return 0.5 end
function UnitSelectionColor() return 1, 1, 1, 1 end
function UnitAffectingCombat() return false end

ns.UnitColors = {
    ClearMobType = function() end,
    MobType = function() end,
    Resolve = function() return nil end,
    ResolvePreview = function() return 1, 1, 1, 1 end,
    PreviewThreat = function() return nil end,
    Threat = function() return nil end,
}
ns.Scaling = { Apply = function() end }

local barTextureLog, barOverlayLog = {}, {}
function ns.SetBarTexture(bar, value)
    barTextureLog[#barTextureLog + 1] = { bar = bar, value = value }
end
function ns.SetBarOverlay(bar, value, alpha, contrast)
    barOverlayLog[#barOverlayLog + 1] = { bar = bar, value = value, alpha = alpha, contrast = contrast }
end

function ns.SetBackgroundTexture() end
function ns.MarkerLayer(plate) return plate.health end
function ns.CreateBorder()
    local b = {}
    function b:SetStyle() end
    function b:SetColor() end
    function b:Layout() end
    function b:Show() end
    function b:Hide() end
    return b
end

local function FakeRegion()
    local r = {}
    function r:SetAllPoints() end
    function r:SetPoint() end
    function r:SetFrameLevel() end
    function r:GetFrameLevel() return 1 end
    function r:SetMinMaxValues() end
    function r:SetValue() end
    function r:Show() end
    function r:Hide() end
    function r:SetStatusBarColor() end
    function r:SetColorTexture() end
    function r:CreateTexture() return FakeRegion() end
    return setmetatable(r, { __index = function() return function() end end })
end
function CreateFrame() return FakeRegion() end

assert(loadfile("Plateau/Elements/Health.lua"))("Plateau", ns)
local Health = ns.Elements.Health
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local COLORS = { threat = false, threatDisplay = "bar", threatBad = { 1, 0, 0, 1 }, quest = false, questExcludeBoss = false }
ns.DB = {
    views = {
        enemy = {
            target = { colorBar = false, texture = "", overlayPattern = "CHECK_TARGET", overlayAlpha = 0.7, overlayContrast = 0.9 },
            focus = { colorBar = false, texture = "", overlayPattern = "CHECK_FOCUS", overlayAlpha = 0.6, overlayContrast = 0.8 },
            colors = COLORS,
        },
        friendly = { colors = COLORS },
    },
}

Health:Configure({ texture = "BASE", overlayPattern = "CHECK_BASE", overlayAlpha = 0.3, overlayContrast = 0.4 }, "enemy")

local plate = { state = "enemy" }
Health:Create(plate)

plate.isTarget, plate.isFocus = false, false
Health:Preview(plate, { health = 0.5 })
local last = barOverlayLog[#barOverlayLog]
check(last.value == "CHECK_BASE" and last.alpha == 0.3 and last.contrast == 0.4, "base overlay applies when not targeting or focusing")

plate.isTarget, plate.isFocus = true, false
Health:Preview(plate, { health = 0.5 })
last = barOverlayLog[#barOverlayLog]
check(last.value == "CHECK_TARGET" and last.alpha == 0.7 and last.contrast == 0.9, "target's own overlay overrides the base overlay")

plate.isTarget, plate.isFocus = false, true
Health:Preview(plate, { health = 0.5 })
last = barOverlayLog[#barOverlayLog]
check(last.value == "CHECK_FOCUS" and last.alpha == 0.6 and last.contrast == 0.8, "focus's own overlay overrides the base overlay")

ns.DB.views.enemy.target.overlayPattern = ""
Health:Configure({ texture = "BASE", overlayPattern = "CHECK_BASE", overlayAlpha = 0.3, overlayContrast = 0.4 }, "enemy")
plate.isTarget, plate.isFocus = true, false
Health:Preview(plate, { health = 0.5 })
last = barOverlayLog[#barOverlayLog]
check(last.value == "CHECK_BASE" and last.alpha == 0.3 and last.contrast == 0.4,
    "target with no overlay of its own falls back to the base overlay AND its matching alpha and contrast together")

ns.DB.views.enemy.target.overlayPattern, ns.DB.views.enemy.target.overlayContrast = "CHECK_TARGET", 0.9
Health:Configure({ texture = "BASE", overlayPattern = "CHECK_BASE", overlayAlpha = 0.3, overlayContrast = 0.4 }, "enemy")
Health:Preview(plate, { health = 0.5 })
local countBeforeContrastOnly = #barOverlayLog
ns.DB.views.enemy.target.overlayContrast = 0.2
Health:Configure({ texture = "BASE", overlayPattern = "CHECK_BASE", overlayAlpha = 0.3, overlayContrast = 0.4 }, "enemy")
Health:Preview(plate, { health = 0.5 })
check(#barOverlayLog == countBeforeContrastOnly + 1, "a contrast-only change still re-applies the overlay")
last = barOverlayLog[#barOverlayLog]
check(last.contrast == 0.2 and last.alpha == 0.7, "the new contrast value is sent, alpha untouched")

local countBefore = #barOverlayLog
Health:Preview(plate, { health = 0.5 })
check(#barOverlayLog == countBefore, "repeating the same overlay doesn't call SetBarOverlay again")

local fastPlate = { state = "enemy", unit = "nameplate1" }
Health:Create(fastPlate)
local painted
fastPlate.health.SetStatusBarColor = function(_, r, g, b, a) painted = { r, g, b, a } end
local curve = { testColor = { r = 0.2, g = 0.4, b = 0.6, a = 1 } }
local fullRecolours = 0
local previousUpdateColor = Health.UpdateColor
Health.UpdateColor = function() fullRecolours = fullRecolours + 1 end
fastPlate.healthGradient, fastPlate.fadeCurve = true, curve
Health:OnEvent(fastPlate, "UNIT_HEALTH", "nameplate1")
check(fullRecolours == 0 and painted and painted[1] == 0.2 and painted[3] == 0.6, "a health tick with health fading only re-evaluates the fade curve, without a full recolour")
fastPlate.healthGradient, fastPlate.fadeCurve = nil, nil
painted = nil
Health:OnEvent(fastPlate, "UNIT_HEALTH", "nameplate1")
check(fullRecolours == 0 and painted == nil, "without health fading a health tick doesn't recolour at all")
Health:OnEvent(fastPlate, "UNIT_TARGET", "nameplate1")
check(fullRecolours == 1, "other events still run the full recolour")
Health.UpdateColor = previousUpdateColor
