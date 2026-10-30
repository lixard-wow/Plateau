local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
assert(loadfile("Plateau_Options/Panels/PageLogic.lua"))("Plateau_Options", ns)
local Logic = ns.PageLogic

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
