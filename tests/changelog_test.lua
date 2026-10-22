arg = { "--check" }
assert(loadfile("tests/make_changelog.lua"))()

local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local ns = {}
assert(loadfile("Plateau_Options/Changelog.lua"))("Plateau_Options", ns)
local log = ns.changelog
check(type(log) == "table" and #log > 0, "the in-game changelog has versions")
local toc = io.open("Plateau/Plateau.toc"):read("*a")
local version = toc:match("## Version: ([%w%.%-]+)")
check(log[1] and log[1].version == version, "the newest changelog entry is the version in the .toc (" .. tostring(version) .. ")")
local filled = true
for _, entry in ipairs(log) do
    local items = 0
    for _, section in ipairs(entry.sections) do
        items = items + #section.items
    end
    filled = filled and items > 0
end
check(filled, "every version in the changelog lists at least one change")
