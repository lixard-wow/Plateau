local ns = {}
assert(loadfile("Plateau_Options/Widgets/PriorityOrder.lua"))("Plateau_Options", ns)
local Order = ns.PriorityOrder
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function same(a, b)
    if #a ~= #b then return false end
    for i = 1, #a do
        if a[i] ~= b[i] then return false end
    end
    return true
end

check(Order.SlotAt(0, 24, 8) == 1, "the top of the list is slot 1")
check(Order.SlotAt(23, 24, 8) == 1, "just inside the first row is still slot 1")
check(Order.SlotAt(24, 24, 8) == 2, "the next row is slot 2")
check(Order.SlotAt(100, 24, 8) == 5, "a position in the fifth row is slot 5")
check(Order.SlotAt(-50, 24, 8) == 1, "dragging above the list clamps to the first slot")
check(Order.SlotAt(9999, 24, 8) == 8, "dragging below the list clamps to the last slot")

check(same(Order.Display(4, 2, 2), { 1, 2, 3, 4 }), "dropping a row where it started changes nothing")
check(same(Order.Display(4, 4, 1), { 4, 1, 2, 3 }), "moving the last row to the top shifts the others down")
check(same(Order.Display(4, 1, 4), { 2, 3, 4, 1 }), "moving the first row to the bottom shifts the others up")
check(same(Order.Display(5, 2, 4), { 1, 3, 4, 2, 5 }), "moving a row down two places")
check(same(Order.Display(5, 4, 2), { 1, 4, 2, 3, 5 }), "moving a row up two places")

local list = { "boss", "target", "focus", "caster" }
check(same(Order.Reorder(list, 4, 1), { "caster", "boss", "target", "focus" }), "reordering moves the dragged entry to the dropped slot")
check(same(list, { "boss", "target", "focus", "caster" }), "reordering leaves the original list untouched")
check(same(Order.Reorder({ "a" }, 1, 1), { "a" }), "a one-entry list reorders to itself")

local keys = { "boss", "target", "focus", "casting", "caster", "trivial" }
check(same(Order.Complete({ "caster", "boss", "target", "focus", "trivial" }, keys), { "caster", "boss", "target", "focus", "casting", "trivial" }), "a new key is placed right after its default neighbour in a saved order")
check(same(Order.Complete({}, keys), keys), "an empty saved order becomes the default order")
check(same(Order.Complete({ "trivial" }, keys), { "boss", "target", "focus", "casting", "caster", "trivial" }), "keys missing from a short saved order fill in at their default places")
check(same(Order.Complete({ "target", "boss", "focus", "casting", "caster", "trivial" }, keys), { "target", "boss", "focus", "casting", "caster", "trivial" }), "a complete saved order is left as it is")

