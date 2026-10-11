local saved = { global = {} }
local ns = { DB = { saved = saved } }
assert(loadfile("Plateau/Features/PersonalDisplay.lua"))("Plateau", ns)
local PersonalDisplay = ns.PersonalDisplay

local function check(ok, label)
    print((ok and "PASS " or "FAIL ") .. label)
end

check(PersonalDisplay:IsOn(), "Plateau style is on by default")
PersonalDisplay:SetOn(false)
check(not PersonalDisplay:IsOn() and saved.global.skinPersonal == false, "turning it off saves off")
PersonalDisplay:SetOn(true)
check(PersonalDisplay:IsOn() and saved.global.skinPersonal == nil, "turning it back on saves on")
