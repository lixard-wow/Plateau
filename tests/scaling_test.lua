issecretvalue = issecretvalue or function() return false end
local ns = { Driver = { GetPlate = function() return nil end, RegisterElement = function() end } }
local frames = {}
function CreateFrame()
    local frame = { scripts = {}, shown = true }
    function frame:RegisterEvent() end
    function frame:SetScript(name, fn) self.scripts[name] = fn end
    function frame:Hide() self.shown = false end
    function frame:Show() self.shown = true end
    function frame:SetShown(shown) self.shown = shown and true or false end
    function frame:IsShown() return self.shown end
    function frame:SetSize() end
    function frame:SetPoint() end
    function frame:SetAllPoints() end
    function frame:SetFrameStrata() end
    function frame:SetScale(scale) self.scale = scale end
    function frame:SetAlpha(alpha) self.alpha = alpha end
    function frame:GetEffectiveScale() return 1 end
    function frame:SetFrameLevel(level) self.level = level end
    function frame:GetFrameLevel() return self.level or 0 end
    frames[#frames + 1] = frame
    return frame
end
local mockCVar = "1.2"
local now = 100
function GetTime() return now end
C_CVar = { GetCVar = function(name) return name == "nameplateSelectedScale" and mockCVar or nil end }
local inCombat = {}
function UnitAffectingCombat(unit) return inCombat[unit] == true end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Features/Scaling.lua")
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end
local function near(a, b) return math.abs(a - b) < 1e-9 end

local Scaling = ns.Scaling
Scaling.enabledIn = { enemy = true }

local function Configure(fields)
    local db = {
        boss = 1, lieutenant = 1, higher = 1, caster = 1, elite = 1, trivial = 1,
        focusGrow = false, focusScale = 1, castPop = false, castScale = 1,
        combatEnabled = false, combatScale = 1, idleScale = 1,
    }
    for k, v in pairs(fields or {}) do db[k] = v end
    Scaling:Configure(db, "enemy")
end

local function Plate(fields)
    local plate = { state = "enemy", level = 3, strata = "MEDIUM" }
    function plate:SetScale(scale) self.scale = scale end
    function plate:SetFrameLevel(level) self.level = level; self.levelSets = (self.levelSets or 0) + 1 end
    function plate:GetFrameLevel() return self.level end
    function plate:SetFrameStrata(strata) self.strata = strata end
    function plate:GetFrameStrata() return self.strata end
    function plate:GetChildren() return end
    function plate:SetParent(parent) self.parent = parent end
    plate.stackRegion = {}
    function plate.stackRegion:SetScale(scale) self.scale = scale end
    for k, v in pairs(fields or {}) do plate[k] = v end
    return plate
end

local function Base(level)
    local base = { level = level, strata = "WORLD", scale = 1 }
    function base:GetFrameLevel() return self.level end
    function base:GetEffectiveScale() return self.scale end
    function base:GetFrameStrata() return self.strata end
    function base:GetEffectiveAlpha() return 1 end
    function base:IsVisible() return true end
    return base
end

local function Live(fields)
    local plate = Plate(fields)
    plate.active = true
    plate.base = plate.base or Base(105)
    return plate
end

Configure({ boss = 1.2, lieutenant = 1.1, higher = 1.05, trivial = 0.8 })
local trash = Plate({})
Scaling:Apply(trash)
check(trash.scale == 0.8, "ordinary trash follows the Other enemies (trivial) scale")
local bossPlate = Plate({ mobType = "boss" })
Scaling:Apply(bossPlate)
check(bossPlate.scale == 1.2, "a boss follows the boss scale")
local enemyPlayer = Plate({ isPlayer = true })
Scaling:Apply(enemyPlayer)
check(enemyPlayer.scale == 1, "an enemy player is never resized by enemy-type scaling")
local friendlyTrash = Plate({ isFriendly = true })
Scaling:Apply(friendlyTrash)
check(friendlyTrash.scale == 1, "a friendly plate is never resized by enemy-type scaling")

Configure()
mockCVar = "1.2"
Scaling:SetTargetScale(1)
Scaling:Apply(Plate({ isTarget = true }))
mockCVar = "1"
Scaling:RefreshBlizzardScale()
Scaling:SetTargetScale(1.3)
local customTarget = Plate({ isTarget = true })
Scaling:Apply(customTarget)
check(customTarget.scale == 1.3, "disabling Blizzard's target size applies the custom scale immediately, not a stale Blizzard scale")

Configure({ trivial = 0.8, boss = 1.2, combatEnabled = false, combatScale = 1.1, idleScale = 0.9 })
check(Scaling:UsesCombat("enemy") == false, "combat scale reports off when it is off")
local offIdle = Plate({ unit = "nameplate1" })
Scaling:Apply(offIdle)
check(near(offIdle.scale, 0.8), "combat scale off: an idle enemy keeps its type scale")
Configure({ trivial = 0.8, boss = 1.2, combatEnabled = true, combatScale = 1.1, idleScale = 0.9 })
check(Scaling:UsesCombat("enemy") == true, "combat scale reports on when it is on")
local idleTrash = Plate({ unit = "nameplate1" })
Scaling:Apply(idleTrash)
check(near(idleTrash.scale, 0.8 * 0.9), "combat scale on: an idle enemy gets type scale times the out-of-combat scale")
inCombat.nameplate2 = true
local fightingTrash = Plate({ unit = "nameplate2" })
Scaling:Apply(fightingTrash)
check(near(fightingTrash.scale, 0.8 * 1.1), "combat scale on: an enemy in combat gets type scale times the in-combat scale")
inCombat.nameplate3 = true
local fightingBoss = Plate({ unit = "nameplate3", mobType = "boss" })
Scaling:Apply(fightingBoss)
check(near(fightingBoss.scale, 1.2 * 1.1), "combat scale multiplies the type scale, so a boss stays bigger than trash")
local friendlyCombat = Plate({ unit = "nameplate4", isFriendly = true })
Scaling:Apply(friendlyCombat)
check(friendlyCombat.scale == 1, "combat scale never resizes a friendly plate")
local playerCombat = Plate({ unit = "nameplate5", isPlayer = true })
Scaling:Apply(playerCombat)
check(playerCombat.scale == 1, "combat scale never resizes an enemy player")
local noUnit = Plate({})
Scaling:Apply(noUnit)
check(near(noUnit.scale, 0.8), "a plate with no unit yet keeps its type scale")

Configure()
mockCVar = "1.2"
Scaling:RefreshBlizzardScale()
Scaling:SetTargetScale(1)
local enemyTarget = Plate({ isTarget = true })
Scaling:Apply(enemyTarget)
check(near(enemyTarget.scale, 1), "an enemy target adds nothing on top of the game's selected scale, which it inherits")
local friendlyTarget = Plate({ isTarget = true, isFriendly = true })
Scaling:Apply(friendlyTarget)
check(near(friendlyTarget.scale, 1 / 1.2), "a friendly target cancels the game's selected scale, so it stays normal size")
check(near(enemyTarget.stackRegion.scale, 1 / 1.2), "an enemy target's stacking bounds cancel the game's growth, so targeting doesn't reshuffle the stack")
check(near(friendlyTarget.stackRegion.scale, 1 / 1.2), "a friendly target's stacking bounds cancel the game's growth, matching the plate")

Configure()
local function Placed(fields)
    local plate = Live(fields)
    Scaling:Apply(plate)
    return plate
end
local placedTarget = Placed({ isTarget = true, mobType = "boss", casting = true })
check(placedTarget.level == 106, "every plate sits just above its game nameplate, target and casters included")
check(placedTarget.strata == "MEDIUM" and placedTarget.parent == nil, "a plate is never moved to another strata or parent")
check(Placed({ isMouseover = true }).level == 106, "a hovered plate keeps the game's order")

local near1 = Live({ mobType = "elite", base = Base(110) })
local far1 = Live({ mobType = "elite", base = Base(101) })
Scaling:Apply(near1)
Scaling:Apply(far1)
check(near1.level > far1.level, "nearer plates keep the game's order over farther ones")
local attached = Plate({ base = Base(107) })
Scaling:Attach(attached)
check(attached.level == 108, "attaching a plate puts it just above its game nameplate")

local preview = Plate({ preview = true, mobType = "boss", base = Base(105), active = true, casting = true })
Scaling:Apply(preview)
check(preview.levelSets == nil, "preview plates are left alone")


local watcher
for _, frame in ipairs(frames) do
    if frame.scripts.OnEvent then
        watcher = frame
    end
end
NamePlateConstants = { NAME_PLATE_SCALES = { [2] = { vertical = 1 }, [3] = { vertical = 1.25 } } }
C_CVar.GetCVar = function(name)
    if name == "nameplateSize" then return "3" end
    if name == "nameplateSelectedScale" then return mockCVar end
    return nil
end
C_CVar.GetCVarDefault = function(name)
    if name == "nameplateSize" then return "2" end
    return nil
end
ns.Driver.RequestRestyle = function() end
ns.DB = { views = { enemy = { plate = { followBlizzardSize = false } } } }
watcher.scripts.OnEvent(watcher, "PLAYER_LOGIN")
Scaling:Configured()
Configure()
local largeFriendly = Plate({ isFriendly = true })
Scaling:Apply(largeFriendly)
check(near(largeFriendly.scale, 1.25), "friendly plates always follow Blizzard's Nameplate Size")
local largeEnemy = Plate({})
Scaling:Apply(largeEnemy)
check(near(largeEnemy.scale, 1), "with the enemy switch off, enemy plates ignore Blizzard's Nameplate Size")
ns.DB.views.enemy.plate.followBlizzardSize = true
Scaling:Configured()
local followingEnemy = Plate({})
Scaling:Apply(followingEnemy)
check(near(followingEnemy.scale, 1.25), "with the enemy switch on, enemy plates follow it too")

ns.DB.views.enemy.plate.followBlizzardSize = false
Scaling:Configured()

ns.DB.views.enemy.plate.followBlizzardSize = false
Scaling:Configured()
Configure({ mouseoverGrow = true, mouseoverScale = 1.3 })
local hovered = Plate({ mobType = "trivial", isMouseover = true })
Scaling:Apply(hovered)
check(near(hovered.scale, 1.3), "mouseover scale grows the hovered enemy plate")
local friendBaseline = Plate({ isFriendly = true })
Scaling:Apply(friendBaseline)
local hoveredFriend = Plate({ isFriendly = true, isMouseover = true })
Scaling:Apply(hoveredFriend)
check(near(hoveredFriend.scale, friendBaseline.scale), "mouseover scale leaves friendly plates alone")

Configure({ friendlyScale = 0.8 })
local friend = Plate({ isFriendly = true })
Scaling:Apply(friend)
check(near(friend.scale, 0.8 * friendBaseline.scale), "friendly nameplate scale sizes friendly plates")
local foe = Plate({ mobType = "trivial" })
Scaling:Apply(foe)
check(near(foe.scale, 1), "friendly nameplate scale leaves enemy plates alone")


local stale = Live({ mobType = "trivial", base = Base(114) })
Scaling:Apply(stale)
stale.base.level = 101
Scaling:Apply(stale)
check(stale.level == 102, "re-applying puts a plate back just above its game nameplate even when its rank did not change")

local animator
for _, frame in ipairs(frames) do
    if frame.scripts.OnUpdate then animator = frame end
end
Configure({ smooth = true, trivial = 0.8 })
local gliding = Live({ base = Base(105), mobType = "trivial" })
Scaling:Apply(gliding)
gliding.mobType = "boss"
Configure({ smooth = true, trivial = 0.8, boss = 1.3 })
Scaling:Apply(gliding)
Scaling:Reset(gliding)
local ok = pcall(animator.scripts.OnUpdate, animator, 0.016)
check(ok, "a plate removed while its size is still animating does not error")
local orphan = Live({ base = Base(105), mobType = "boss", shownScale = 1 })
Scaling:Apply(orphan)
orphan.appliedScale = nil
ok = pcall(animator.scripts.OnUpdate, animator, 0.016)
check(ok, "the size animation skips a plate that lost its target size")

Configure({ trivial = 0.8, focusGrow = true, focusScale = 1.3, castPop = true, castScale = 1.4, mouseoverGrow = true, mouseoverScale = 1.2 })
mockCVar = "1"
Scaling:RefreshBlizzardScale()
Scaling:SetTargetScale(1.3)
for _, fields in ipairs({ { isTarget = true }, { isFocus = true }, { casting = true }, { isMouseover = true } }) do
    local grown = Plate(fields)
    Scaling:Apply(grown)
    local which = next(fields)
    check(grown.scale > 0.8 and near(grown.stackRegion.scale, 0.8), which .. " grows the plate but keeps its stacking bounds at the normal size")
end
