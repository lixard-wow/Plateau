local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local ns = {}
local source = io.open("Plateau/Core/Media.lua"):read("*a")
local start = source:find("local Brand = {}", 1, true)
local chunk = assert(loadstring("local ns = ...\n" .. source:sub(start)))
chunk(ns)
local Brand = ns.Brand
local r, g, b = Brand:Color()
check(math.abs(r - 0xd0 / 255) < 1e-9 and math.abs(g - 0x7a / 255) < 1e-9 and math.abs(b - 0x3c / 255) < 1e-9, "the brand color is mesa ochre")
check(Brand:Text("Plateau") == "|cffd07a3cPlateau|r", "Text wraps a word in the brand color")
local heard
Brand:OnChange(function(...) heard = { ... } end)
check(heard and heard[1] == r and heard[3] == b, "OnChange hands the color to the caller straight away")
