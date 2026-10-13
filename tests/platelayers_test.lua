local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local seen, clash = {}, nil
for _, path in ipairs({ "Plateau/Elements/Highlight.lua", "Plateau/Elements/Mouseover.lua", "Plateau/Elements/RaidMarker.lua" }) do
    local handle = assert(io.open(path, "rb"))
    local src = handle:read("*a")
    handle:close()
    for name, sublevel in src:gmatch("([%w%.]+) = ns%.CreateBorder%(plate, plate, \"BACKGROUND\", (%-?%d+)%)") do
        if seen[sublevel] then
            clash = (clash or "") .. " " .. seen[sublevel] .. "/" .. name
        end
        seen[sublevel] = name
    end
end
check(next(seen) ~= nil, "found the plate border layers")
check(clash == nil, "each plate ring and glow has its own draw sublevel, so overlapping ones never swap order" .. (clash and (":" .. clash) or ""))
local function level(name)
    for sublevel, owner in pairs(seen) do
        if owner == name then return tonumber(sublevel) end
    end
end
check(level("plate.hoverGlow") < level("plate.hoverRing") and level("set.glow") < level("set.ring"), "glows draw under rings")
