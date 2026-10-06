local inCombat = {}
function UnitAffectingCombat(unit) return inCombat[unit] == true end

local calls = { color = 0, alpha = 0, hidden = 0, style = 0 }
local ns = {
    Elements = { Health = { UpdateColor = function() calls.color = calls.color + 1 end } },
    Driver = {
        RegisterElement = function() end,
        RefreshAlpha = function() calls.alpha = calls.alpha + 1 end,
        SetHidden = function(_, plate, hide) plate.hidden = hide; calls.hidden = calls.hidden + 1 end,
        StyleNow = function() calls.style = calls.style + 1 end,
        ResizeNow = function() calls.style = calls.style + 1 end,
    },
}
assert(loadfile("Plateau/Features/Idle.lua"))("Plateau", ns)
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local Idle = ns.Idle
Idle.enabledIn = { enemy = true }

local GREY = { 0.5, 0.5, 0.5, 1 }
local function Configure(fields)
    local db = { alpha = 0.5, widthScale = 0.8, heightScale = 1, colorBar = true, color = GREY, show = { auras = false } }
    for k, v in pairs(fields or {}) do db[k] = v end
    Idle:Configure(db, "enemy")
    Idle:Configured()
end

local function Plate(fields)
    local plate = { state = "enemy", unit = "nameplate1", active = true }
    for k, v in pairs(fields or {}) do plate[k] = v end
    return plate
end

Configure()
local plate = Plate()
Idle:Enable(plate)
check(plate.idle == true, "an enemy NPC out of combat is idle")
check(plate.idleAlpha == 0.5, "idle plates take the out-of-combat opacity")
check(plate.hidden and plate.hidden.auras == true and plate.hidden.healthText == false, "only the parts switched off in the show list are hidden")
check(plate.idleW == 0.8 and plate.idleH == 1, "idle plates take the out-of-combat bar size")
check(calls.style == 1, "a size change restyles the plate once")
check(Idle:Color(plate) == GREY, "the flat out-of-combat color applies while idle")

local before = calls.style
Idle:OnEvent(plate)
check(calls.style == before, "a repeat event with no change does not restyle again")

inCombat.nameplate1 = true
Idle:OnEvent(plate)
check(plate.idle == false and plate.idleAlpha == 1, "an enemy that enters combat goes back to normal opacity")
check(plate.hidden == nil, "its hidden parts come back")
check(plate.idleW == 1 and calls.style == before + 1, "its size is restored with one restyle")
check(Idle:Color(plate) == nil, "the flat color stops applying in combat")
inCombat.nameplate1 = nil

local target = Plate({ isTarget = true })
Idle:Enable(target)
check(target.idle == false, "your target is never given the out-of-combat look")
local friendly = Plate({ isFriendly = true })
Idle:Enable(friendly)
check(friendly.idle == false, "a friendly plate is never given the out-of-combat look")
local player = Plate({ isPlayer = true })
Idle:Enable(player)
check(player.idle == false, "an enemy player is never given the out-of-combat look")

local released = Plate({ styledAs = "enemy" })
Idle:Enable(released)
released.active = false
local styleBefore = calls.style
Idle:Disable(released)
check(released.styledAs == nil, "a released plate that was resized is marked to be restyled before its next use")
check(released.idleW == nil and released.hidden == nil and released.idleAlpha == 1, "release clears every idle setting")
check(calls.style == styleBefore, "an inactive plate is not restyled on release")

local activeOff = Plate()
Idle:Enable(activeOff)
styleBefore = calls.style
Idle:Disable(activeOff)
check(calls.style == styleBefore + 1, "turning the feature off restyles a plate that is still on screen")

Configure({ colorBar = false, widthScale = 1 })
local colorBefore = calls.color
local plain = Plate()
Idle:Enable(plain)
check(plain.idle == true and Idle:Color(plain) == nil, "with the flat color off, an idle plate keeps its normal color")
check(calls.color == colorBefore, "and the bar is not recolored when it flips idle")

Idle.enabledIn = { enemy = false }
local disabled = Plate()
Idle:Enable(disabled)
check(disabled.idle == false, "nothing is idle while the feature is off")
