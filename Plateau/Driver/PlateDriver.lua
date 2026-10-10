local _, ns = ...

local CreateFrame = CreateFrame
local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local UnitCanAttack = UnitCanAttack
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local issecretvalue = issecretvalue

local OVERLAY_LEVEL = 20

local SIMPLIFIED_CVAR = "nameplateSimplifiedTypes"
local SIMPLIFIED_SIZE = 0.6
local SIMPLIFIED_HIDE = { auras = true, healthText = true, name = true }
local SIMPLIFIED_HIDE_TARGET = { auras = true }
local simplifyPlayers, simplifyNpcs = false, false

local Driver = CreateFrame("Frame")
ns.Driver = Driver
Driver.eventCount = 0

local function AddOverlay(plate)
    plate:SetFlattensRenderLayers(true)
    local overlay = CreateFrame("Frame", nil, plate)
    overlay:SetFlattensRenderLayers(true)
    overlay:SetAllPoints()
    overlay:SetFrameLevel(plate:GetFrameLevel() + OVERLAY_LEVEL)
    plate.overlay = overlay
    local stackRegion = CreateFrame("Frame", nil, plate.base or plate)
    local fill = stackRegion:CreateTexture()
    fill:SetColorTexture(0, 0, 0, 0)
    fill:SetAllPoints()
    stackRegion.fill = fill
    plate.stackRegion = stackRegion

    local click = CreateFrame("Frame", nil, plate)
    click:SetFrameLevel(overlay:GetFrameLevel() + 30)
    click.fill = click:CreateTexture(nil, "BACKGROUND")
    click.fill:SetAllPoints()
    click.fill:SetColorTexture(0.27, 0.82, 0.76, 0.18)
    click.fill:Hide()
    click.border = ns.CreateBorder(click, click, "OVERLAY")
    click.border:Hide()
    plate.clickArea = click
    plate.state = "enemy"
end

local elements = {}
local emphasisElements = {}
local mouseoverElements = {}
local mouseoverPlate
local configuredElements = {}
local platesByBase = {}
local platesByUnit = {}
local targetPlate, focusPlate
local dimAlpha = 1
local views
local previews = {}
local restyleListeners = {}
local styleOf = {}
local sampleLooks = {}
local sampleStale = {}
local registered = {}
local styleVersion = 0
local gates = {}
local showClickPreview = false
local showWorldClickAreas = false

local function UpdateClickArea(plate)
    local visible = plate.preview ~= nil and showClickPreview or plate.preview == nil and plate.active == true and showWorldClickAreas
    plate.clickArea.fill:SetShown(visible)
    plate.clickArea.border:SetShown(visible)
end

local hitTestPending = false
local clickThroughFriendly = false

local function ApplyHitTest(plate)
    local base = plate.base
    if not base or not base.CanChangeHitTestPoints then return end
    if base:CanChangeHitTestPoints() then
        if clickThroughFriendly and plate.isFriendly and base.ClearAllHitTestPoints then
            base:ClearAllHitTestPoints()
        else
            base:SetAllHitTestPoints(plate.clickArea)
        end
        plate.clickArea.changed = false
    else
        hitTestPending = true
    end
end

local NO_EVENTS = {}

local function Runs(element, plate)
    local key = element.key
    return plate.built[element] and element.enabledIn[plate.state] and (element.nameOnly or not plate.nameOnly)
        and not (plate.hidden and plate.hidden[key]) and not (plate.simplifiedHidden and plate.simplifiedHidden[key])
end
ns.Runs = Runs

local PET_TOKENS = { "pet", "partypet1", "partypet2", "partypet3", "partypet4" }

local function IsPartyPet(unit)
    for i = 1, #PET_TOKENS do
        local same = UnitIsUnit(unit, PET_TOKENS[i])
        if not issecretvalue(same) and same then
            return true
        end
    end
    local owned = UnitPlayerControlled(unit)
    return not issecretvalue(owned) and owned == true
end

local function IsMinion(unit)
    return not UnitIsPlayer(unit) and not ns.UnitColors:IsCompanion(unit) and IsPartyPet(unit)
end

local function Claimable(unit)
    if UnitCanAttack("player", unit) then
        return true
    end
    local friendly = views and views.enemy.friendly
    if not friendly or not friendly.enabled then
        return false
    end
    local isSelf = UnitIsUnit(unit, "player")
    if issecretvalue(isSelf) or isSelf then
        return false
    end
    if UnitIsPlayer(unit) then
        return friendly.players
    end
    local friend = UnitIsFriend("player", unit)
    if not issecretvalue(friend) and not friend then
        return false
    end
    if IsMinion(unit) then
        if not friendly.minions then
            return false, true
        end
        return friendly.players or friendly.npcs
    end
    local owned = UnitPlayerControlled(unit)
    if not issecretvalue(owned) and owned then
        return friendly.players or friendly.npcs
    end
    return friendly.npcs
end

local hider = CreateFrame("Frame")
hider:Hide()

local BLIZZARD_FRAME_EVENTS = {
    "VARIABLES_LOADED", "CVAR_UPDATE", "PLAYER_ENTERING_WORLD", "PLAYER_TARGET_CHANGED", "PLAYER_SOFT_FRIEND_CHANGED",
    "PLAYER_SOFT_ENEMY_CHANGED", "UPDATE_MOUSEOVER_UNIT", "PLAYER_LEVEL_UP", "PLAYER_ROLES_ASSIGNED", "PLAYER_LEVEL_CHANGED",
    "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE", "READY_CHECK", "READY_CHECK_FINISHED", "READY_CHECK_CONFIRM",
    "PARTY_MEMBER_DISABLE", "PARTY_MEMBER_ENABLE", "INCOMING_RESURRECT_CHANGED", "GROUP_JOINED", "GROUP_LEFT",
    "INCOMING_SUMMON_CHANGED",
}

local function RestoreBlizzardPlate(base)
    local unitFrame = base.UnitFrame
    if not (unitFrame and unitFrame.plateauStripped) then return end
    unitFrame.plateauStripped = nil
    unitFrame:SetParent(base)
    local valid = C_EventUtils and C_EventUtils.IsEventValid
    for _, event in ipairs(BLIZZARD_FRAME_EVENTS) do
        if not valid or valid(event) then
            pcall(unitFrame.RegisterEvent, unitFrame, event)
        end
    end
end

local function HideBlizzardPlate(base)
    local unitFrame = base.UnitFrame
    if not unitFrame then return end

    unitFrame:SetParent(hider)
    unitFrame:UnregisterAllEvents()
    unitFrame.plateauStripped = true

    local castBar = unitFrame.castBar or (unitFrame.CastBarsContainer and unitFrame.CastBarsContainer.castBar)
    if castBar then
        castBar:UnregisterAllEvents()
    end
end

function Driver:RegisterElement(element)
    elements[#elements + 1] = element
    element.enabledIn = {}
    if element.UpdateEmphasis then
        emphasisElements[#emphasisElements + 1] = element
    end
    if element.SetMouseover then
        mouseoverElements[#mouseoverElements + 1] = element
    end
    if element.Configured then
        configuredElements[#configuredElements + 1] = element
    end
end

local AURA_GROUPS = { "mine", "cc", "purge", "important" }

local function AurasAbove(look)
    local auras = look.auras
    if not auras.enabled then return 0 end
    local top = 0
    for i = 1, #AURA_GROUPS do
        local group = auras[AURA_GROUPS[i]]
        if group and group.enabled and group.side == "TOP" then
            local rows = math.ceil(group.maxIcons / math.max(group.perRow, 1))
            local extent = group.offsetY + rows * group.size + (rows - 1) * group.spacing
            if extent > top then
                top = extent
            end
        end
    end
    return top
end

local function StackSpace(look, space)
    local above, below = 0, 0
    if space ~= "bar" and space ~= "barcast" and look.name.enabled then
        if look.name.position == "TOP" then
            above = look.name.size + look.name.gap
        elseif look.name.position == "BOTTOM" then
            below = look.name.size + look.name.gap
        end
    end
    if space == "cast" or space == "barcast" or space == "all" then
        local cast = look.castbar
        local height = (cast.height and cast.height > 0) and cast.height or look.plate.height
        below = below + height + cast.gap + cast.borderSize * 2
    end
    if space == "all" then
        above = math.max(above, AurasAbove(look))
    end
    return above, below
end

local function SizePlate(plate, look)
    local simplified = plate.simplifiedSize or 1
    local width, height = look.plate.width * (plate.idleW or 1) * simplified, look.plate.height * (plate.idleH or 1) * simplified
    plate:SetSize(width, height)
    local above, below = StackSpace(look, views.enemy.plate.stackSpace)
    local stackRegion = plate.stackRegion
    local stackHeight = height + above + below
    local bottom = -height / 2 - below
    if stackRegion.width ~= width or stackRegion.height ~= stackHeight or stackRegion.base ~= bottom then
        stackRegion.width, stackRegion.height, stackRegion.base = width, stackHeight, bottom
        stackRegion:ClearAllPoints()
        stackRegion:SetSize(width, stackHeight)
        stackRegion:SetPoint("BOTTOMLEFT", stackRegion:GetParent(), "CENTER", -width / 2, bottom)
    end
end

local buildTime = { count = 0, total = 0, slowest = 0 }
local partTime = {}

local function AddPartTime(element, started)
    local key = element.key or "?"
    partTime[key] = (partTime[key] or 0) + debugprofilestop() - started
end

local function DisableElement(element, plate)
    if plate.built[element] then
        element:Disable(plate)
    end
end

local AddHandlers

local function BuildMissing(plate)
    for i = 1, #elements do
        local element = elements[i]
        if element.enabled ~= false and not plate.built[element] then
            element:Create(plate)
            AddHandlers(plate, element, element.events)
            AddHandlers(plate, element, element.globalEvents)
            plate.built[element] = true
        end
    end
end

local function StylePlate(plate)
    BuildMissing(plate)
    local look = views[plate.state]
    plate.styledAs = styleOf[plate.state]
    plate.styleVersion = styleVersion
    plate.nameOnly = plate.state == "friendly" and views.enemy.friendly.nameOnly == true
    SizePlate(plate, look)
    local click, size = plate.clickArea, views.enemy.plate
    local shift = size.clickOffsetY or 0
    local cast = look.castbar
    local castHeight = (cast.height and cast.height > 0) and cast.height or look.plate.height
    local extra = size.clickCastBar and (castHeight + cast.gap + cast.borderSize * 2) or 0
    if click.x ~= size.clickX or click.y ~= size.clickY or click.shift ~= shift or click.extra ~= extra then
        click.x, click.y, click.shift, click.extra = size.clickX, size.clickY, shift, extra
        click.changed = true
        click:ClearAllPoints()
        click:SetPoint("TOPLEFT", plate, "TOPLEFT", -size.clickX, size.clickY + shift)
        click:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", size.clickX, -size.clickY + shift - extra)
    end
    click.border:Layout(1)
    click.border:SetColor(0.27, 0.82, 0.76, 0.9)
    UpdateClickArea(plate)
    local pixel = ns.pixelPerfect and not plate.preview
    local wasPixel = ns.pixelBorders
    if pixel then
        ns.pixelBorders, ns.pixelPlate = true, plate
    end
    for i = 1, #elements do
        local element = elements[i]
        if plate.built[element] and element.enabledIn[plate.state] then
            local started = plate.timing and debugprofilestop()
            element:Style(plate, look[element.key])
            if started then
                AddPartTime(element, started)
            end
        end
    end
    if pixel then
        ns.pixelBorders, ns.pixelPlate = wasPixel, nil
        plate.pixelScale = plate:GetEffectiveScale()
    end
end

local function EnableElements(plate, unit)
    for i = 1, #elements do
        local element = elements[i]
        if Runs(element, plate) then
            element:Enable(plate, unit)
        else
            DisableElement(element, plate)
        end
    end
end

local function StateFor(plate)
    return plate.isFriendly and "friendly" or "enemy"
end

local UpdateSimplified

local function ApplyEmphasis(plate)
    if not plate then return end
    plate.isTarget = plate.active and plate == targetPlate
    plate.isFocus = plate.active and plate == focusPlate
    if not plate.active then return end

    local state = StateFor(plate)
    if plate.state ~= state then
        plate.state = state
        if plate.styledAs ~= styleOf[state] or plate.styleVersion ~= styleVersion then
            StylePlate(plate)
        end
        EnableElements(plate, plate.unit)
        ns.Scaling:Apply(plate)
    end
    UpdateSimplified(plate)

    for i = 1, #emphasisElements do
        local element = emphasisElements[i]
        if Runs(element, plate) then
            element:UpdateEmphasis(plate)
        end
    end
    Driver:RefreshAlpha(plate)
end

function Driver:StyleNow(plate)
    StylePlate(plate)
end

function Driver:ResizeNow(plate)
    local look = views[plate.state]
    SizePlate(plate, look)
    for i = 1, #elements do
        local element = elements[i]
        if element.sizeDependent and plate.built[element] and element.enabledIn[plate.state] then
            local pixel = ns.pixelPerfect and not plate.preview
            if pixel then
                ns.pixelBorders, ns.pixelPlate = true, plate
            end
            element:Style(plate, look[element.key])
            if pixel then
                ns.pixelBorders, ns.pixelPlate = false, nil
            end
        end
    end
end

local function ApplyHidden(plate, field, hide)
    local old = plate[field]
    plate[field] = hide
    local unit = plate.unit
    if not (plate.active and unit) then return end
    for i = 1, #elements do
        local element = elements[i]
        local key = element.key
        if ((old and old[key]) or false) ~= ((hide and hide[key]) or false) then
            if Runs(element, plate) then
                element:Enable(plate, unit)
            else
                DisableElement(element, plate)
            end
        end
    end
end

function Driver:SetHidden(plate, hide)
    ApplyHidden(plate, "hidden", hide)
end

function UpdateSimplified(plate)
    local simplified = plate.isFriendly and (plate.isPlayer and simplifyPlayers or not plate.isPlayer and simplifyNpcs)
    local size = simplified and SIMPLIFIED_SIZE or nil
    if plate.simplifiedSize ~= size then
        plate.simplifiedSize = size
        Driver:ResizeNow(plate)
    end
    local hide = simplified and (plate.isTarget and SIMPLIFIED_HIDE_TARGET or SIMPLIFIED_HIDE) or nil
    if plate.simplifiedHidden ~= hide then
        ApplyHidden(plate, "simplifiedHidden", hide)
    end
end

local dimCombatOnly, dimSkipFriendly, mouseoverFull = false, false, false
local gameFadeEnemy, gameFadeFriendly = true, true
local hideFriendlyCombat = false
local inCombat = false

local function Dims(plate)
    if dimSkipFriendly and plate.isFriendly then return false end
    if dimCombatOnly and not inCombat then return false end
    if mouseoverFull and plate.isMouseover then return false end
    return true
end

function Driver:RefreshAlpha(plate)
    local range = (mouseoverFull and plate.isMouseover) and 1 or (plate.rangeAlpha or 1)
    local alpha = range * (plate.idleAlpha or 1)
    if not plate.preview then
        if targetPlate and not plate.isTarget and Dims(plate) then
            alpha = alpha * dimAlpha
        end
        if hideFriendlyCombat and inCombat and plate.isFriendly then
            alpha = 0
        end
        local ignoreGame = not (plate.isFriendly and gameFadeFriendly or not plate.isFriendly and gameFadeEnemy)
        if plate.ignoresGameFade ~= ignoreGame and plate.SetIgnoreParentAlpha then
            plate.ignoresGameFade = ignoreGame
            plate:SetIgnoreParentAlpha(ignoreGame)
        end
    end
    if plate.appliedAlpha ~= alpha then
        plate.appliedAlpha = alpha
        plate:SetAlpha(alpha)
    end
end

function Driver:ForEachActive(callback)
    for _, plate in pairs(platesByUnit) do
        if plate.active then
            callback(plate)
        end
    end
end

local function FindPlate(unit)
    local base = GetNamePlateForUnit(unit)
    local plate = base and platesByBase[base]
    if plate and plate.active then
        return plate
    end
end

local function NotifyMouseover(plate, hovered)
    plate.isMouseover = hovered
    if not plate.active then return end
    ns.Scaling:Apply(plate)
    Driver:RefreshAlpha(plate)
    for i = 1, #mouseoverElements do
        local element = mouseoverElements[i]
        if Runs(element, plate) then
            element:SetMouseover(plate, hovered)
        end
    end
end

local mouseWatcher = CreateFrame("Frame")
mouseWatcher:Hide()

local function SetMouseover(plate)
    if plate == mouseoverPlate then return end
    if mouseoverPlate then
        NotifyMouseover(mouseoverPlate, false)
    end
    mouseoverPlate = plate
    if plate then
        NotifyMouseover(plate, true)
    end
    mouseWatcher:SetShown(plate ~= nil)
end

local sinceCheck = 0
mouseWatcher:SetScript("OnUpdate", function(_, elapsed)
    sinceCheck = sinceCheck + elapsed
    if sinceCheck < 0.1 then return end
    sinceCheck = 0
    SetMouseover(FindPlate("mouseover"))
end)

local function ApplyIfChanged(plate, oldTarget, oldFocus)
    if plate and ((plate == oldTarget) ~= (plate == targetPlate) or (plate == oldFocus) ~= (plate == focusPlate)) then
        ApplyEmphasis(plate)
    end
end

local function UpdateEmphasis()
    local oldTarget, oldFocus = targetPlate, focusPlate
    targetPlate, focusPlate = FindPlate("target"), FindPlate("focus")

    if dimAlpha < 1 and (oldTarget == nil) ~= (targetPlate == nil) then
        for _, plate in pairs(platesByUnit) do
            if plate.active and plate ~= oldTarget and plate ~= oldFocus and plate ~= targetPlate and plate ~= focusPlate then
                Driver:RefreshAlpha(plate)
            end
        end
    end

    ApplyIfChanged(oldTarget, oldTarget, oldFocus)
    if oldFocus ~= oldTarget then
        ApplyIfChanged(oldFocus, oldTarget, oldFocus)
    end
    if targetPlate ~= oldTarget and targetPlate ~= oldFocus then
        ApplyIfChanged(targetPlate, oldTarget, oldFocus)
    end
    if focusPlate ~= oldTarget and focusPlate ~= oldFocus and focusPlate ~= targetPlate then
        ApplyIfChanged(focusPlate, oldTarget, oldFocus)
    end
end

local claimTime = { count = 0, total = 0, slowest = 0, restyles = 0, versionRestyles = 0, framesOver1 = 0, worstFrame = 0, frameAt = nil, frameMs = 0, parts = {} }

local shown = { enemy = 0, friendly = 0 }
local demand = { peak = { enemy = 0, friendly = 0 }, combatPeak = { enemy = 0, friendly = 0 }, misses = 0, combatMisses = 0, missMs = 0, worstMiss = 0 }
local session = { misses = 0, combatMisses = 0, missMs = 0, worstMiss = 0, deferred = 0, longestWait = 0 }
demand.deferred, demand.longestWait = 0, 0

local function NotePeaks(combat)
    combat = combat or InCombatLockdown()
    for state, n in pairs(shown) do
        if n > demand.peak[state] then
            demand.peak[state] = n
        end
        if combat and n > demand.combatPeak[state] then
            demand.combatPeak[state] = n
        end
    end
end

local function CountShown(plate, state)
    local old = plate.countedAs
    if old == state then return end
    if old then
        shown[old] = shown[old] - 1
    end
    plate.countedAs = state
    if state then
        shown[state] = shown[state] + 1
        NotePeaks()
    end
end

local function ClaimPart(key, started)
    local now = debugprofilestop()
    claimTime.parts[key] = (claimTime.parts[key] or 0) + now - started
    return now
end

local function ClaimDone(started)
    local ms = debugprofilestop() - started
    claimTime.count = claimTime.count + 1
    claimTime.total = claimTime.total + ms
    if ms > claimTime.slowest then claimTime.slowest = ms end
    local now = GetTime()
    if claimTime.frameAt ~= now then
        claimTime.frameAt = now
        claimTime.frameMs = 0
        claimTime.counted = false
    end
    claimTime.frameMs = claimTime.frameMs + ms
    if claimTime.frameMs > claimTime.worstFrame then claimTime.worstFrame = claimTime.frameMs end
    if claimTime.frameMs > 1 and not claimTime.counted then
        claimTime.counted = true
        claimTime.framesOver1 = claimTime.framesOver1 + 1
    end
end

local function Claim(plate, unit)
    local claimStarted = debugprofilestop()
    local base = plate.base
    HideBlizzardPlate(base)
    if base.SetStackingBoundsFrame then
        base:SetStackingBoundsFrame(plate.stackRegion)
    end
    plate:UnregisterAllEvents()
    plate.active = true

    for k in pairs(registered) do
        registered[k] = nil
    end
    for i = 1, #elements do
        local element = elements[i]
        if element.enabled then
            local events, gated = element.events or NO_EVENTS, element.gatedEvents
            for j = 1, #events do
                local event = events[j]
                if not registered[event] and not (gated and gated[event] and not gates[gated[event]]) then
                    plate:RegisterUnitEvent(event, unit)
                    registered[event] = true
                end
            end
            local globalEvents = element.globalEvents
            if globalEvents then
                for j = 1, #globalEvents do
                    local event = globalEvents[j]
                    if not registered[event] then
                        plate:RegisterEvent(event)
                        registered[event] = true
                    end
                end
            end
        end
    end

    if not registered.UNIT_FACTION then
        plate:RegisterUnitEvent("UNIT_FACTION", unit)
    end
    local t = ClaimPart("events", claimStarted)
    plate.isPlayer = UnitIsPlayer(unit) == true
    plate.isFriendly = not UnitCanAttack("player", unit)
    ApplyHitTest(plate)
    local baseState = plate.isFriendly and "friendly" or "enemy"
    if plate.state ~= baseState then
        plate.state = baseState
    end
    CountShown(plate, baseState)
    t = ClaimPart("unit checks", t)
    if plate.styledAs ~= styleOf[baseState] or plate.styleVersion ~= styleVersion then
        claimTime.restyles = claimTime.restyles + 1
        if plate.styleVersion ~= styleVersion then
            claimTime.versionRestyles = claimTime.versionRestyles + 1
        end
        StylePlate(plate)
        t = ClaimPart("restyle", t)
    end
    for i = 1, #elements do
        local element = elements[i]
        if Runs(element, plate) then
            element:Enable(plate, unit)
        else
            DisableElement(element, plate)
        end
        local key = element.claimKey
        if not key then
            key = "enable " .. (element.key or "?")
            element.claimKey = key
        end
        t = ClaimPart(key, t)
    end
    ns.Scaling:Apply(plate)
    UpdateClickArea(plate)
    plate:Show()
    t = ClaimPart("scale and show", t)
    UpdateEmphasis()
    ApplyEmphasis(plate)
    t = ClaimPart("highlight", t)
    ns.Fire("PLATE_ADDED", unit, plate)
    ClaimPart("callbacks", t)
    ClaimDone(claimStarted)
end

local watched = {}

local function Watch(plate)
    CountShown(plate, nil)
    plate.active = false
    plate:Hide()
    ns.Scaling:Reset(plate)
    plate.stackRegion:SetScale(1)
end

local OnUnitAdded

local function RecheckWatched()
    for unit in pairs(watched) do
        if Claimable(unit) then
            OnUnitAdded(unit)
        end
    end
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("UNIT_FACTION")
watcher:RegisterEvent("UNIT_FLAGS")
watcher:SetScript("OnEvent", function(_, _, unit)
    if unit and watched[unit] and Claimable(unit) then
        OnUnitAdded(unit)
    end
end)

function AddHandlers(plate, element, events)
    if not events then return end
    for j = 1, #events do
        local event = events[j]
        local handlers = plate.handlers[event]
        if not handlers then
            handlers = {}
            plate.handlers[event] = handlers
        end
        handlers[#handlers + 1] = element
    end
end

local function OnPlateEvent(plate, event, ...)
    Driver.eventCount = Driver.eventCount + 1
    local unit = plate.unit
    if not plate.active then
        if Claimable(unit) then
            Claim(plate, unit)
        end
        return
    end

    if event == "UNIT_FACTION" then
        local isFriendly = not UnitCanAttack("player", unit)
        if isFriendly ~= plate.isFriendly then
            plate.isFriendly = isFriendly
            ApplyHitTest(plate)
            ApplyEmphasis(plate)
        end
    end

    local handlers = plate.handlers[event]
    if handlers then
        for i = 1, #handlers do
            local element = handlers[i]
            if Runs(element, plate) then
                element:OnEvent(plate, event, unit, ...)
            end
        end
    end
end

local pools = { enemy = {}, friendly = {} }
local swaps = 0
local POOL_TARGET = { enemy = 16, friendly = 4 }
local POOL_BUFFER = { enemy = 8, friendly = 2 }
local built = { enemy = 0, friendly = 0 }

local function PoolTest()
    local global = ns.DB and ns.DB.saved and ns.DB.saved.global
    return global and global.poolTest
end

local function PoolSize(state)
    local test = PoolTest()
    if test == "off" then
        return 0, 0
    end
    if state == "friendly" and not (views and views.enemy.friendly.enabled) then
        return 0, 0
    end
    if type(test) == "number" and state == "enemy" then
        return test, math.ceil(test / 2)
    end
    return POOL_TARGET[state], POOL_BUFFER[state]
end

local function PoolWanted(state)
    local target, buffer = PoolSize(state)
    local want = built[state] < target and target or buffer
    return #pools[state] < want
end
local POOL_ORDER = { "enemy", "friendly" }
local BUILD_BUDGET_MS = 3
local WARM_DELAY = 2
local building
local stale = {}

local function StartBuild(state)
    local started = debugprofilestop()
    built[state] = built[state] + 1
    local plate = CreateFrame("Frame", nil, hider)
    plate:Hide()
    plate.handlers = {}
    plate.built = {}
    AddOverlay(plate)
    plate.state = state
    return { plate = plate, state = state, index = 1, stepIndex = 1, spent = debugprofilestop() - started }
end

local function RunBuild(job, deadline)
    local plate = job.plate
    while job.index <= #elements do
        local element = elements[job.index]
        if element.enabled ~= false then
            local started = debugprofilestop()
            element:Create(plate)
            AddPartTime(element, started)
            AddHandlers(plate, element, element.events)
            AddHandlers(plate, element, element.globalEvents)
            plate.built[element] = true
        end
        job.index = job.index + 1
        if deadline and debugprofilestop() > deadline then
            return false
        end
    end
    if not job.wired then
        job.wired = true
        plate:SetScript("OnEvent", OnPlateEvent)
        if deadline and debugprofilestop() > deadline then
            return false
        end
    end
    local look = views and views[job.state]
    if look then
        plate.nameOnly = job.state == "friendly" and views.enemy.friendly.nameOnly == true
        while job.stepIndex <= #elements do
            local element = elements[job.stepIndex]
            if element.BuildStep and plate.built[element] and element.enabledIn[job.state] then
                local started = debugprofilestop()
                local done = element:BuildStep(plate, look[element.key], deadline)
                AddPartTime(element, started)
                if not done then
                    return false
                end
            end
            job.stepIndex = job.stepIndex + 1
            if deadline and debugprofilestop() > deadline then
                return false
            end
        end
    end
    plate.timing = true
    StylePlate(plate)
    plate.timing = nil
    return true
end

local function StepBuild(job, deadline)
    local started = debugprofilestop()
    local done = RunBuild(job, deadline)
    job.spent = (job.spent or 0) + debugprofilestop() - started
    if done then
        buildTime.count = buildTime.count + 1
        buildTime.total = buildTime.total + job.spent
        buildTime.slowest = math.max(buildTime.slowest, job.spent)
    end
    return done
end

local function BuildPlate(state)
    local job = StartBuild(state)
    StepBuild(job)
    return job.plate
end

local showStackBoxes = false

local function ApplyStackBox(plate)
    local region = plate.stackRegion
    if showStackBoxes then
        region.fill:SetColorTexture(1, 0.55, 0.1, 0.22)
        if not region.border then
            region.border = ns.CreateBorder(region, region, "OVERLAY")
            region.border:Layout(1)
            region.border:SetColor(1, 0.55, 0.1, 0.9)
        end
        region.border:SetShown(true)
    else
        region.fill:SetColorTexture(0, 0, 0, 0)
        if region.border then
            region.border:SetShown(false)
        end
    end
end

function Driver:SetStackBoxes(on)
    showStackBoxes = on == true
    for _, plate in pairs(platesByBase) do
        ApplyStackBox(plate)
    end
end

local plateOffsetY = 0

local function AnchorPlate(plate, base)
    plate:ClearAllPoints()
    plate:SetPoint("CENTER", base, "CENTER", 0, plateOffsetY)
end

local function AssignBase(plate, base)
    plate:SetParent(base)
    AnchorPlate(plate, base)
    plate.base = base
    ns.Scaling:Attach(plate)
    local stackRegion = plate.stackRegion
    stackRegion:SetParent(base)
    if stackRegion.width then
        stackRegion:ClearAllPoints()
        stackRegion:SetPoint("BOTTOMLEFT", base, "CENTER", -stackRegion.width / 2, stackRegion.base)
    end
    platesByBase[base] = plate
    ApplyStackBox(plate)
end

local function CreatePlate(base, unit)
    local preferred = (unit and not UnitCanAttack("player", unit)) and "friendly" or "enemy"
    local fallback = preferred == "enemy" and "friendly" or "enemy"
    local plate = table.remove(pools[preferred]) or table.remove(pools[fallback])
    local combat = InCombatLockdown()
    if not plate then
        local started = debugprofilestop()
        plate = BuildPlate(preferred)
        local ms = debugprofilestop() - started
        demand.misses = demand.misses + 1
        if combat then
            demand.combatMisses = demand.combatMisses + 1
        end
        demand.missMs = demand.missMs + ms
        if ms > demand.worstMiss then
            demand.worstMiss = ms
        end
        session.misses = session.misses + 1
        if combat then
            session.combatMisses = session.combatMisses + 1
        end
        session.missMs = session.missMs + ms
        if ms > session.worstMiss then
            session.worstMiss = ms
        end
    end
    local spare = #pools.enemy + #pools.friendly
    if not demand.minSpare or spare < demand.minSpare then
        demand.minSpare = spare
    end
    if combat and (not demand.minSpareCombat or spare < demand.minSpareCombat) then
        demand.minSpareCombat = spare
    end
    local attachStarted = debugprofilestop()
    AssignBase(plate, base)
    ClaimPart("attach", attachStarted)
    return plate
end

local pending = {}
local pendingSet = {}
local flushing = false

local function SpareCount(state)
    return #pools[state] + #pools[state == "enemy" and "friendly" or "enemy"]
end

local function ClaimPending(force)
    while #pending > 0 do
        local unit = pending[1]
        local entry = pendingSet[unit]
        if entry and not force and SpareCount(entry.state) == 0 then
            return
        end
        table.remove(pending, 1)
        if entry then
            pendingSet[unit] = nil
            local waited = debugprofilestop() - entry.at
            demand.deferred = demand.deferred + 1
            session.deferred = session.deferred + 1
            if waited > demand.longestWait then
                demand.longestWait = waited
            end
            if waited > session.longestWait then
                session.longestWait = waited
            end
            flushing = true
            OnUnitAdded(unit)
            flushing = false
        end
    end
end

local poolWarmer = CreateFrame("Frame")
poolWarmer:Hide()
poolWarmer:SetScript("OnUpdate", function(self)
    if InCombatLockdown() then return end
    local started = debugprofilestop()
    if #pending > 0 then
        ClaimPending()
        if #pending > 0 then
            if not building then
                local entry = pendingSet[pending[1]]
                building = StartBuild(entry and entry.state or "enemy")
            end
            if StepBuild(building, started + BUILD_BUDGET_MS) then
                local list = pools[building.state]
                list[#list + 1] = building.plate
                building = nil
                ClaimPending()
            end
            return
        end
    end
    local plate = next(stale)
    while plate do
        stale[plate] = nil
        if not plate.active and plate.styleVersion ~= styleVersion then
            StylePlate(plate)
        end
        if debugprofilestop() > started + BUILD_BUDGET_MS then
            return
        end
        plate = next(stale)
    end
    if not building then
        for _, state in ipairs(POOL_ORDER) do
            if PoolWanted(state) then
                building = StartBuild(state)
                break
            end
        end
        if not building then
            self:Hide()
            return
        end
    end
    if StepBuild(building, started + BUILD_BUDGET_MS) then
        local list = pools[building.state]
        list[#list + 1] = building.plate
        building = nil
    end
end)
poolWarmer:RegisterEvent("PLAYER_ENTERING_WORLD")
poolWarmer:SetScript("OnEvent", function(self)
    C_Timer.After(WARM_DELAY, function()
        self:Show()
    end)
end)

local function SpareStyledFor(state)
    local list = pools[state]
    for i = #list, 1, -1 do
        local spare = list[i]
        if spare.styledAs == styleOf[state] and spare.styleVersion == styleVersion then
            return table.remove(list, i)
        end
    end
end

local function SwapToStyled(plate, base, state)
    if plate.styledAs == styleOf[state] and plate.styleVersion == styleVersion then
        return plate
    end
    local spare = SpareStyledFor(state)
    if not spare then
        return plate
    end
    platesByBase[base] = nil
    plate.base = nil
    plate:Hide()
    plate:SetParent(hider)
    plate:ClearAllPoints()
    plate.stackRegion:SetParent(plate)
    if plate.styleVersion ~= styleVersion then
        stale[plate] = true
        poolWarmer:Show()
    end
    local list = pools[plate.state]
    list[#list + 1] = plate
    AssignBase(spare, base)
    swaps = swaps + 1
    return spare
end

function OnUnitAdded(unit)
    local base = GetNamePlateForUnit(unit)
    if not base then return end

    local claimable, hiddenMinion = Claimable(unit)
    local plate = platesByBase[base]
    if claimable then
        watched[unit] = nil
        if not plate then
            if not flushing and not (inCombat or InCombatLockdown()) and #pools.enemy == 0 and #pools.friendly == 0 then
                if not pendingSet[unit] then
                    pendingSet[unit] = { state = UnitCanAttack("player", unit) and "enemy" or "friendly", at = debugprofilestop() }
                    pending[#pending + 1] = unit
                end
                RestoreBlizzardPlate(base)
                poolWarmer:Show()
                return
            end
            plate = CreatePlate(base, unit)
            if not InCombatLockdown() then
                poolWarmer:Show()
            end
        else
            plate = SwapToStyled(plate, base, UnitCanAttack("player", unit) and "enemy" or "friendly")
        end
        plate.unit = unit
        platesByUnit[unit] = plate
        Claim(plate, unit)
        return
    end

    watched[unit] = true
    if plate then
        plate.unit = unit
        platesByUnit[unit] = plate
        Watch(plate)
    end
    if hiddenMinion then
        HideBlizzardPlate(base)
    else
        RestoreBlizzardPlate(base)
    end
end

local function OnUnitRemoved(unit)
    watched[unit] = nil
    pendingSet[unit] = nil
    local plate = platesByUnit[unit]
    if not plate then return end
    platesByUnit[unit] = nil

    CountShown(plate, nil)
    plate:UnregisterAllEvents()
    plate.active = false
    plate.isTarget, plate.isFocus, plate.isPlayer, plate.isFriendly = false, false, false, false
    for i = 1, #elements do
        DisableElement(elements[i], plate)
    end
    if plate.simplifiedSize then
        plate.styledAs = nil
    end
    plate.simplifiedSize, plate.simplifiedHidden = nil, nil
    plate.unit = nil
    plate.clickArea.fill:Hide()
    plate.clickArea.border:Hide()
    plate:SetAlpha(1)
    plate.appliedAlpha = 1
    ns.Scaling:Reset(plate)
    plate:Hide()

    if plate == targetPlate or plate == focusPlate then
        UpdateEmphasis()
    end
    if plate == mouseoverPlate then
        SetMouseover(nil)
    end
    plate.isMouseover = false
    ns.Fire("PLATE_REMOVED", unit, plate)
end

local function PreviewState(state)
    return state.isFriendly and "friendly" or "enemy"
end

local function RenderPreview(plate)
    local state = plate.preview
    plate.isTarget, plate.isFocus, plate.isFriendly = state.isTarget, state.isFocus, state.isFriendly
    for i = 1, #elements do
        local element = elements[i]
        if Runs(element, plate) and element.Preview then
            element:Preview(plate, state)
        else
            DisableElement(element, plate)
        end
    end
    local range = ns.DB.views[plate.state].range
    plate.rangeAlpha = state.outOfRange and range and range.alpha or nil
    Driver:RefreshAlpha(plate)
    plate:Show()
end

local ConfigureState

local function DrawPreview(plate)
    ns.pixelBorders = true
    local state = plate.state
    if sampleStale[state] and sampleLooks[state] then
        sampleStale[state] = nil
        ConfigureState(state, sampleLooks[state])
    end
    local real = views[state]
    local forced = plate.previewLook and real and plate.previewLook(real)
    if forced then
        views[state] = forced
        ConfigureState(state, forced)
    end
    StylePlate(plate)
    RenderPreview(plate)
    if forced then
        views[state] = real
        ConfigureState(state, real)
    end
    ns.pixelBorders = false
end

function Driver:CreatePreview(parent, state, sample)
    local plate = CreateFrame("Frame", nil, parent)
    plate.handlers = {}
    plate.built = {}
    plate.preview = state
    plate.sample = sample
    AddOverlay(plate)
    plate.state = sample or PreviewState(state)
    for i = 1, #elements do
        elements[i]:Create(plate)
        plate.built[elements[i]] = true
    end
    previews[#previews + 1] = plate
    DrawPreview(plate)
    return plate
end

function Driver:RefreshDirtyPreviews()
    for i = 1, #previews do
        local plate = previews[i]
        if plate.previewDirty and plate:IsVisible() then
            plate.previewDirty = false
            DrawPreview(plate)
        end
    end
end

function Driver:SetPreviewState(plate, state)
    plate.preview = state
    plate.state = plate.sample or PreviewState(state)
    DrawPreview(plate)
end

function ConfigureState(state, look)
    ns.UnitColors:Configure(look.colors, state)
    for i = 1, #elements do
        local element = elements[i]
        local config = look[element.key]
        element.enabledIn[state] = config.enabled ~= false
        if element.Configure then
            element:Configure(config, state)
        end
    end
end

function Driver:SetSampleLook(name, look)
    sampleLooks[name] = look
    sampleStale[name] = nil
    if views then
        views[name] = look
        ConfigureState(name, look)
    end
end

function Driver:OnRestyle(callback)
    restyleListeners[#restyleListeners + 1] = callback
end

local restyleQueue = CreateFrame("Frame")
restyleQueue:Hide()
restyleQueue:SetScript("OnUpdate", function(self)
    self:Hide()
    Driver:Restyle()
end)

local restyleAfterCombat = false
local restyleReasons = {}
local pendingReasons = {}
local deferredReasons = {}

function Driver:RequestRestyle(background, reason)
    reason = reason or "other"
    if background and InCombatLockdown() then
        restyleAfterCombat = true
        deferredReasons[reason] = true
        return
    end
    pendingReasons[reason] = true
    restyleQueue:Show()
end

function Driver:RestyleReasons()
    return restyleReasons
end

function Driver:Restyle(reason)
    restyleQueue:Hide()
    if reason then
        pendingReasons[reason] = true
    end
    local counted = false
    for key in pairs(pendingReasons) do
        restyleReasons[key] = (restyleReasons[key] or 0) + 1
        pendingReasons[key] = nil
        counted = true
    end
    if not counted then
        restyleReasons.other = (restyleReasons.other or 0) + 1
    end
    views = ns.DB.views
    dimAlpha = views.enemy.target.dimOthers
    ns.pixelPerfect = views.enemy.plate.pixelPerfect ~= false
    dimCombatOnly = views.enemy.target.dimCombatOnly == true
    local offsetY = views.enemy.plate.offsetY or 0
    if offsetY ~= plateOffsetY then
        plateOffsetY = offsetY
        for base, plate in pairs(platesByBase) do
            AnchorPlate(plate, base)
        end
    end
    hideFriendlyCombat = views.enemy.friendly.hideInCombat == true
    inCombat = InCombatLockdown() == true
    dimSkipFriendly = views.enemy.target.dimSkipFriendly == true
    mouseoverFull = views.enemy.range.mouseoverFull == true
    local gameFade = views.enemy.range.gameFade or "both"
    gameFadeEnemy = gameFade ~= "friendly"
    gameFadeFriendly = gameFade ~= "enemy"
    local clickThrough = views.enemy.plate.clickThroughFriendly == true
    local hitTestChanged = clickThrough ~= clickThroughFriendly
    clickThroughFriendly = clickThrough
    local types = Enum.NamePlateSimplifiedType
    local hasSimplified = types ~= nil and C_CVar.GetCVar(SIMPLIFIED_CVAR) ~= nil
    simplifyPlayers = hasSimplified and types.FriendlyPlayer ~= nil and C_CVar.GetCVarBitfield(SIMPLIFIED_CVAR, types.FriendlyPlayer) == true
    simplifyNpcs = hasSimplified and types.FriendlyNpc ~= nil and C_CVar.GetCVarBitfield(SIMPLIFIED_CVAR, types.FriendlyNpc) == true
    local toggled = false

    local threat = false
    for _, state in ipairs(ns.STATES) do
        local look = views[state]
        threat = threat or look.colors.threat == true
        local distinct = state == "enemy" or (state == "friendly" and (views.enemy.friendly.nameOnly == true or views.enemy.friendly.raidMarker.own == true))
        styleOf[state] = distinct and state or "enemy"
        ConfigureState(state, look)
    end
    for name, sampleLook in pairs(sampleLooks) do
        views[name] = sampleLook
        sampleStale[name] = true
    end

    for i = 1, #elements do
        local element = elements[i]
        local enabled = false
        for _, state in ipairs(ns.STATES) do
            enabled = enabled or element.enabledIn[state]
        end
        if element.enabled ~= enabled then
            toggled = true
        end
        element.enabled = enabled
    end
    if gates.threat ~= threat then
        gates.threat = threat
        toggled = true
    end
    for i = 1, #configuredElements do
        configuredElements[i]:Configured()
    end

    styleVersion = styleVersion + 1
    for _, plate in pairs(platesByUnit) do
        if plate.active then
            StylePlate(plate)
        end
    end
    for _, plate in pairs(platesByBase) do
        if not plate.active then
            stale[plate] = true
        end
    end
    for _, list in pairs(pools) do
        for i = 1, #list do
            stale[list[i]] = true
        end
    end
    if next(stale) then
        poolWarmer:Show()
    end
    local dropped
    for unit, plate in pairs(platesByUnit) do
        if plate.active and not Claimable(unit) then
            dropped = dropped or {}
            dropped[#dropped + 1] = unit
        elseif plate.active then
            if plate.clickArea.changed or hitTestChanged then
                ApplyHitTest(plate)
            end
            if toggled then
                Claim(plate, unit)
            else
                EnableElements(plate, unit)
                ns.Scaling:Apply(plate)
                ApplyEmphasis(plate)
            end
        elseif Claimable(unit) then
            watched[unit] = nil
            Claim(plate, unit)
        end
    end
    if dropped then
        for i = 1, #dropped do
            OnUnitRemoved(dropped[i])
            OnUnitAdded(dropped[i])
        end
    end
    RecheckWatched()

    for i = 1, #previews do
        local plate = previews[i]
        if plate:IsVisible() then
            DrawPreview(plate)
        else
            plate.previewDirty = true
        end
    end
    for i = 1, #restyleListeners do
        restyleListeners[i]()
    end
end

function Driver:SetClickAreas(preview, world)
    showClickPreview = preview == true
    showWorldClickAreas = world == true
    for i = 1, #previews do
        UpdateClickArea(previews[i])
    end
    for _, plate in pairs(platesByUnit) do
        UpdateClickArea(plate)
    end
end

function Driver:IsClaimable(unit)
    return Claimable(unit)
end

function Driver:GetPlate(unit)
    local plate = platesByUnit[unit]
    if plate and plate.active then
        return plate
    end
    return FindPlate(unit)
end

function Driver:BuildTime()
    local count = buildTime.count
    local parts = {}
    for key, total in pairs(partTime) do
        parts[#parts + 1] = { key = key, ms = count > 0 and total / count or 0 }
    end
    table.sort(parts, function(a, b) return a.ms > b.ms end)
    return count, count > 0 and buildTime.total / count or 0, buildTime.slowest, parts
end

function Driver:ClaimTime()
    local count = claimTime.count
    local parts = {}
    for key, total in pairs(claimTime.parts) do
        parts[#parts + 1] = { key = key, ms = count > 0 and total / count or 0 }
    end
    table.sort(parts, function(a, b) return a.ms > b.ms end)
    return count, count > 0 and claimTime.total / count or 0, claimTime.slowest, claimTime.restyles, claimTime.framesOver1, claimTime.worstFrame, parts, swaps, claimTime.versionRestyles
end

function Driver:ResetClaimTime()
    claimTime.count, claimTime.total, claimTime.slowest, claimTime.restyles = 0, 0, 0, 0
    claimTime.framesOver1, claimTime.worstFrame, claimTime.frameAt, claimTime.frameMs = 0, 0, nil, 0
    claimTime.parts = {}
    claimTime.versionRestyles = 0
    swaps = 0
    demand.misses, demand.combatMisses, demand.missMs, demand.worstMiss = 0, 0, 0, 0
    demand.minSpare, demand.minSpareCombat = nil, nil
    demand.deferred, demand.longestWait = 0, 0
    for state, n in pairs(shown) do
        demand.peak[state] = n
        demand.combatPeak[state] = 0
    end
    for key in pairs(restyleReasons) do
        restyleReasons[key] = nil
    end
end

function Driver:PoolStats()
    local attached, off = 0, 0
    for _ in pairs(platesByBase) do
        attached = attached + 1
    end
    for i = 1, #elements do
        if not elements[i].enabled then
            off = off + 1
        end
    end
    return built.enemy + built.friendly, attached, #pools.enemy + #pools.friendly, #elements - off, #elements
end

function Driver:CountActive()
    local total, claimed = 0, 0
    for _, plate in pairs(platesByUnit) do
        if plate.active then
            total = total + 1
            claimed = claimed + 1
        end
    end
    for _ in pairs(watched) do
        total = total + 1
    end
    for _ in pairs(pendingSet) do
        total = total + 1
    end
    return total, claimed
end

function Driver:Demand()
    return demand, shown, session
end

function Driver:PoolPlan()
    local enemyTarget, enemyBuffer = PoolSize("enemy")
    local friendlyTarget, friendlyBuffer = PoolSize("friendly")
    return PoolTest(), enemyTarget, enemyBuffer, friendlyTarget, friendlyBuffer
end

Driver:RegisterEvent("NAME_PLATE_UNIT_ADDED")
Driver:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
Driver:RegisterEvent("PLAYER_TARGET_CHANGED")
Driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
Driver:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
Driver:RegisterEvent("PLAYER_REGEN_ENABLED")
Driver:RegisterEvent("PLAYER_REGEN_DISABLED")
Driver:RegisterEvent("CVAR_UPDATE")
Driver:RegisterEvent("ENCOUNTER_START")
Driver:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
Driver:SetScript("OnEvent", function(_, event, arg)
    if event == "PLAYER_REGEN_ENABLED" and restyleAfterCombat then
        restyleAfterCombat = false
        for key in pairs(deferredReasons) do
            pendingReasons[key] = true
            deferredReasons[key] = nil
        end
        restyleQueue:Show()
    end
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        inCombat = event == "PLAYER_REGEN_DISABLED"
        if inCombat then
            NotePeaks(true)
            if #pending > 0 then
                ClaimPending(true)
            end
        else
            poolWarmer:Show()
        end
        if (dimCombatOnly and targetPlate) or hideFriendlyCombat then
            for _, plate in pairs(platesByUnit) do
                if plate.active then
                    Driver:RefreshAlpha(plate)
                end
            end
        end
    end
    if event == "ENCOUNTER_START" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" or event == "PLAYER_REGEN_DISABLED" then
        RecheckWatched()
    end
    if event == "ENCOUNTER_START" or event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
        return
    end
    if event == "CVAR_UPDATE" then
        if arg == SIMPLIFIED_CVAR then
            Driver:RequestRestyle(false, "simplified plates setting")
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        if hitTestPending then
            hitTestPending = false
            for _, plate in pairs(platesByUnit) do
                if plate.active then
                    ApplyHitTest(plate)
                end
            end
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        return
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        UpdateEmphasis()
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        SetMouseover(FindPlate("mouseover"))
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        OnUnitAdded(arg)
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        OnUnitRemoved(arg)
    end
end)
