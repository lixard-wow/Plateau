local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Frame = {}
Frame.__index = Frame
function Frame:SetClipsChildren() end
function Frame:SetAllPoints() end
function Frame:ClearAllPoints() end
function Frame:SetPoint() end
function Frame:Hide() self.shown = false end
function Frame:SetScript(name, fn) self.scripts = self.scripts or {}; self.scripts[name] = fn end
function Frame:RegisterEvent() end
function Frame:SetShown(v) self.shown = v and true or false end
function Frame:Show() self.shown = true end
function Frame:SetAlpha(a) self.a = a end
function Frame:GetAlpha() return self.a end
function Frame:SetTexture(path) self.path = path end
function Frame:SetTexCoord(...) self.texCoord = { ... } end
function Frame:SetVertexColor(r, g, b, a) self.r, self.g, self.b, self.a = r, g, b, a end
function Frame:GetVertexColor() return self.r, self.g, self.b, self.a end
function Frame:HookScript(name, fn)
    self.hooks = self.hooks or {}
    self.hooks[name] = self.hooks[name] or {}
    table.insert(self.hooks[name], fn)
end
function Frame:Fire(name, ...)
    for _, fn in ipairs((self.hooks or {})[name] or {}) do
        fn(self, ...)
    end
end
function Frame:CreateTexture()
    return setmetatable({}, Frame)
end
function CreateFrame(_, _, parent)
    return setmetatable({ parent = parent }, Frame)
end

local hooks = {}
function hooksecurefunc(obj, name, fn)
    hooks[obj] = hooks[obj] or {}
    hooks[obj][name] = hooks[obj][name] or {}
    table.insert(hooks[obj][name], fn)
end
local function Fire(obj, name, ...)
    for _, fn in ipairs((hooks[obj] or {})[name] or {}) do
        fn(obj, ...)
    end
end

local ns = {}
function issecretvalue() return false end
assert(loadfile("Plateau/Core/Media.lua"))("Plateau", ns)

local bar = setmetatable({}, Frame)
bar.fillTexture = setmetatable({}, Frame)
bar.fillTexture:SetVertexColor(0.8, 0.2, 0.2, 1)
function bar:GetStatusBarTexture() return self.fillTexture end
function bar:SetStatusBarColor(r, g, b, a)
    self.fillTexture:SetVertexColor(r, g, b, a)
    Fire(bar, "SetStatusBarColor", r, g, b, a)
end
function bar:GetSize() return 180, 12 end

local MID = 178.5 / 255
local PATTERN = "Interface\\AddOns\\Plateau\\Art\\Bars\\checkers-fine.png"

ns.SetBarOverlay(bar, PATTERN, 0.6, 0.5)
local clip = bar.overlayClip
check(clip ~= nil, "SetBarOverlay creates the overlay clip frame")
check(clip.veil ~= nil, "the clip has a separate veil texture behind the pattern")
check(clip.alpha == 0.6, "the clip's own alpha is the overlay-strength value")
check(clip.texture:GetAlpha() == 0.5, "the pattern texture's own alpha is the contrast value, independent of overlay strength")

local pr, pg, pb, pa = clip.texture:GetVertexColor()
check(pr == 0.8 and pg == 0.2 and pb == 0.2, "the pattern is tinted to exactly match the bar's fill color")
check(pa == 0.5, "and its alpha is the fill's own alpha (1) times contrast (0.5), not overwritten back to 1")

local vr, vg, vb, va = clip.veil:GetVertexColor()
check(math.abs(vr - 0.8 * MID) < 0.0001 and math.abs(vg - 0.2 * MID) < 0.0001 and math.abs(vb - 0.2 * MID) < 0.0001 and va == 1,
    "the veil is tinted to the fill color scaled to the pattern's own midpoint brightness (178.5/255), so blending toward it doesn't shift the overall hue")

bar:SetStatusBarColor(1, 1, 1, 1)
local function Blended(rawByte, contrast)
    return math.floor((MID * (1 - contrast) + (rawByte / 255) * contrast) * 255 + 0.5)
end
ns.SetBarOverlay(bar, PATTERN, 1, 1)
check(Blended(20, clip.texture:GetAlpha()) == 20 and Blended(255, clip.texture:GetAlpha()) == 255,
    "contrast 1 shows the art's actual raw range (20 dark, 255 light) unmodified")
ns.SetBarOverlay(bar, PATTERN, 1, 0.5)
check(Blended(20, clip.texture:GetAlpha()) == 99 and Blended(255, clip.texture:GetAlpha()) == 217,
    "contrast 0.5 (the default) is a real midpoint blend, not a no-op - darker than raw but not fully flat")
check(Blended(20, clip.texture:GetAlpha()) < 140,
    "the new wider-range art (dark=20) makes the default noticeably darker than the old fixed-contrast look (140) was - a real, visible change to the default, not just the ceiling")

ns.SetBarOverlay(bar, PATTERN, 1, 0)
check(clip.texture:GetAlpha() == 0, "contrast 0 makes the pattern fully transparent, leaving only the flat veil - no visible pattern at all")

ns.SetBarOverlay(bar, PATTERN, 1, 1)
check(clip.texture:GetAlpha() == 1, "contrast 1 shows the pattern at its full baked-in range, with no veil showing through")

ns.SetBarOverlay(bar, "", 1, 1)
check(clip.shown == false, "clearing the overlay pattern hides the whole clip, veil included")

ns.SetBarOverlay(bar, PATTERN, 0.6, 0.5)
bar:SetStatusBarColor(0.1, 0.9, 0.3, 1)
pr, pg, pb = clip.texture:GetVertexColor()
vr, vg, vb = clip.veil:GetVertexColor()
check(pr == 0.1 and pg == 0.9 and pb == 0.3, "a live health-color change re-tints the pattern texture reactively")
check(math.abs(vr - 0.1 * MID) < 0.0001 and math.abs(vg - 0.9 * MID) < 0.0001 and math.abs(vb - 0.3 * MID) < 0.0001,
    "and re-tints the veil to match, keeping the contrast blend correct as health color changes")
check(clip.texture:GetAlpha() == 0.5, "the contrast value itself is untouched by a health-color-only change")
