local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
assert(loadfile("Plateau_Options/Panels/PageLogic.lua"))("Plateau_Options", ns)
local Logic = ns.PageLogic

local left, top = Logic.ClampBar(100, 500, 1920, 1080, 340, 30)
check(left == 100 and top == 500, "a position on screen is kept")
left, top = Logic.ClampBar(-50, 2000, 1920, 1080, 340, 30)
check(left == 0 and top == 1080, "a position off the top left is pulled back on screen")
left, top = Logic.ClampBar(1900, 5, 1920, 1080, 340, 30)
check(left == 1920 - 340 and top == 30, "a position off the bottom right is pulled back so the whole bar shows")
left, top = Logic.ClampBar(1500, 400, 1280, 720, 340, 48)
check(left == 1280 - 340 and top == 400, "a smaller screen after a resolution change re-clamps the saved position")
left, top = Logic.ClampBar(10, 10, 1920, 1080, 340, 48)
check(top == 48, "the taller bar with the performance line still fits above the bottom edge")

check(Logic.IsClick(100, 100, 102, 101, 4) == true, "a tiny movement is a click")
check(Logic.IsClick(100, 100, 130, 100, 4) == false, "a real movement is a drag, not a click")
check(Logic.IsClick(100, 100, 100, 110, 4) == false, "vertical movement counts too")
check(Logic.IsClick(nil, nil, 5, 5, 4) == true, "a click with no recorded press still counts")


local base = { raidMarker = { enabled = false, size = 20 }, colors = { threat = false, boss = true }, plain = 5 }
local tree = {}
Logic.ForcedTree(tree, "look.raidMarker.enabled", true)
Logic.ForcedTree(tree, "look.colors.threat", true)
local view = Logic.Overlay(base, tree)
check(view.raidMarker.enabled == true and view.raidMarker.size == 20, "a forced setting shows on while its siblings pass through")
check(view.colors.threat == true and view.colors.boss == true, "forcing one color setting keeps the others")
check(view.plain == 5, "untouched settings read from the real profile")
check(base.raidMarker.enabled == false and base.colors.threat == false, "the real profile is never changed")
check(Logic.Overlay(base, {}).raidMarker == base.raidMarker, "with nothing forced the real tables are returned")
local deep = {}
Logic.ForcedTree(deep, "look.quest.enabled", true)
check(Logic.Overlay({}, deep).quest.enabled == true, "a forced setting under a missing group still reads as forced")
