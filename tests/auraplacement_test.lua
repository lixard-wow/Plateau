local function Stub()
    local stub = {}
    return setmetatable(stub, {
        __index = function(t, k) local child = Stub(); rawset(t, k, child); return child end,
        __call = function() return Stub() end,
    })
end
setmetatable(_G, { __index = function(t, k) local child = Stub(); rawset(t, k, child); return child end })
AnchorUtil = { FlowDirection = { Right = "right", Left = "left", Down = "down", Up = "up" }, FlowLayoutAxis = { Horizontal = "horizontal", Vertical = "vertical" } }
local ns = { Driver = { RegisterElement = function() end }, Elements = {} }
assert(loadfile("Plateau/Elements/Auras.lua"))("Plateau", ns)
local Placement = ns.AuraPlacement
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local FACING = {
    TOP = { attach = "BOTTOM", relative = "TOP" },
    BOTTOM = { attach = "TOP", relative = "BOTTOM" },
    LEFT = { attach = "RIGHT", relative = "LEFT" },
    RIGHT = { attach = "LEFT", relative = "RIGHT" },
}
local AWAY = { TOP = "up", BOTTOM = "down", LEFT = "left", RIGHT = "right" }
local GROWS = { "auto", "right-down", "right-up", "left-down", "left-up", "down-right", "down-left", "up-right", "up-left" }

local covered, attachOk, relativeOk, originOk, autoOk = 0, true, true, true, true
local failures = {}
for side, facing in pairs(FACING) do
    for _, align in ipairs({ "LEFT", "CENTER", "RIGHT" }) do
        for _, grow in ipairs(GROWS) do
            covered = covered + 1
            local point, relative, horizontal, vertical, _, attach = Placement({ side = side, align = align, grow = grow })
            local name = side .. "/" .. align .. "/" .. grow
            if not attach:find(facing.attach, 1, true) then
                attachOk = false
                failures[#failures + 1] = name .. " attaches by " .. attach
            end
            if not relative:find(facing.relative, 1, true) then
                relativeOk = false
                failures[#failures + 1] = name .. " attaches to the plate's " .. relative
            end
            local wantV = vertical == "down" and "TOP" or "BOTTOM"
            local wantH = horizontal == "right" and "LEFT" or "RIGHT"
            if point ~= wantV .. wantH then
                originOk = false
                failures[#failures + 1] = name .. " fills from " .. point
            end
            if grow == "auto" then
                local away = AWAY[side]
                if (side == "TOP" or side == "BOTTOM") and vertical ~= away or (side == "LEFT" or side == "RIGHT") and horizontal ~= away then
                    autoOk = false
                    failures[#failures + 1] = name .. " grows toward the plate"
                end
            end
        end
    end
end
check(covered == 108, "every position, alignment and growth combination is checked (" .. covered .. ")")
check(attachOk, "each group attaches by the edge facing the plate, so icons never sit on the health bar")
check(relativeOk, "each group attaches to the plate edge named by its position")
check(originOk, "icons fill from the corner their growth direction starts at")
check(autoOk, "automatic growth always moves away from the plate")
local _, _, _, _, _, attachCenter = Placement({ side = "TOP", align = "CENTER", grow = "auto" })
check(attachCenter == "BOTTOM", "centered above the plate stays centered")
local _, relUp, _, _, _, attachUp = Placement({ side = "LEFT", align = "LEFT", grow = "up-left" })
check(relUp == "BOTTOMLEFT" and attachUp == "BOTTOMRIGHT", "on the left with rows growing up, the group starts at the plate's bottom")
local squareHeight, squareTop = ns.AuraShape({ shape = "square" })
local wideHeight, wideTop, wideBottom = ns.AuraShape({ shape = "wide" })
local flatHeight, flatTop, flatBottom = ns.AuraShape({ shape = "flat" })
check(squareHeight == 1 and math.abs(squareTop - 0.08) < 1e-6, "square icons show the whole art")
check(wideHeight == 0.75 and math.abs(wideTop - 0.185) < 1e-6 and math.abs(wideBottom - 0.815) < 1e-6, "wide icons keep their 4 by 3 crop")
check(flatHeight < wideHeight and math.abs((flatBottom - flatTop) / 0.84 - flatHeight) < 1e-6, "extra wide icons are flatter and crop the art to match, so it isn't squashed")
check(ns.AuraShape({}) == 1, "an unknown shape falls back to square")
local PartCount = ns.Elements.Auras.PartCount
local mine = { key = "mine", parts = { {}, { others = true } } }
local purge = { key = "purge", parts = { {}, {} } }
check(PartCount(mine, 1, { enabled = true, maxIcons = 6 }, false) == 6, "an enabled group gets its icons")
check(PartCount(mine, 1, { enabled = false, maxIcons = 6 }, false) == 0, "a switched-off group gets no icons, so none are built for it")
check(PartCount(mine, 2, { enabled = true, maxIcons = 6 }, false) == 0, "other players' debuffs get no icons unless that option is on")
check(PartCount(mine, 2, { enabled = true, maxIcons = 6, includeOthers = true }, false) == 6, "other players' debuffs get icons once turned on")
check(PartCount(purge, 2, { enabled = true, maxIcons = 3, showEnrage = false }, false) == 0, "enrage buffs get no icons when hidden")
check(PartCount(purge, 2, { enabled = true, maxIcons = 3 }, true) == 0, "show all buffs uses only the first enemy buff group")
local A = ns.Elements.Auras
A.canDispel[1], A.canDispel[2] = false, true
check(PartCount(purge, 1, { enabled = true, maxIcons = 3 }, false) == 0, "without an offensive dispel, the dispellable buffs group builds no icons")
check(PartCount(purge, 2, { enabled = true, maxIcons = 3 }, false) == 3, "an enrage remover still gets the enrage group")
check(PartCount(purge, 1, { enabled = true, maxIcons = 3 }, true) == 3, "show all buffs ignores what your class can remove")
A.canDispel[1], A.canDispel[2] = true, true
local known = {}
ns.FindKnownSpell = function(id) return known[id] and id or nil end
known[2908] = true
check(A.DetectDispels() == true and A.canDispel[1] == false and A.canDispel[2] == true, "a druid with Soothe gets only the enrage group")
check(A.DetectDispels() == false, "nothing changes when spells haven't changed")
known[2908], known[30449] = nil, true
check(A.DetectDispels() == true and A.canDispel[1] == true and A.canDispel[2] == false, "a mage with Spellsteal gets only the dispellable buffs group")
for _, f in ipairs(failures) do print("  " .. f) end
