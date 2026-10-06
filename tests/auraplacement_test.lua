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
for _, f in ipairs(failures) do print("  " .. f) end
