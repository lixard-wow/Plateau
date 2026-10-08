local _, ns = ...

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitCastingDuration = UnitCastingDuration
local UnitChannelDuration = UnitChannelDuration
local UnitEmpoweredChannelDuration = UnitEmpoweredChannelDuration
local UnitShouldDisplaySpellTargetName = UnitShouldDisplaySpellTargetName
local UnitSpellTargetName = UnitSpellTargetName
local UnitSpellTargetClass = UnitSpellTargetClass
local UnitClassBase = UnitClassBase
local IsSpellImportant = C_Spell.IsSpellImportant
local EvaluateColorValueFromBoolean = C_CurveUtil.EvaluateColorValueFromBoolean
local FLAT = "Interface\\Buttons\\WHITE8X8"
local SPARK = "Interface\\CastingBar\\UI-CastingBar-Spark"
local SHIELD = "Interface\\CastingBar\\UI-CastingBar-Small-Shield"
local issecretvalue = issecretvalue
local CreateDurationTextBinding = C_DurationUtil.CreateDurationTextBinding
local UnitNameFromGUID = UnitNameFromGUID
local UnitClassFromGUID = UnitClassFromGUID
local INTERRUPTED_TEXT = INTERRUPTED or "Interrupted"
local INTERRUPTED_BY = SPELL_INTERRUPTED_BY or "Interrupted by %s"
local InterruptReady = ns.InterruptReady

local TIMER_WIDTH = 30
local READY_TICK = 0.1
local TWIN_LEVEL = 1000
local NO_TWIN = { enabled = false }

local settings = {}

local function NewFormatter()
    local formatter = C_StringUtil.CreateSecondsFormatter()
    formatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
    formatter:SetStripIntervalWhitespace(Enum.SecondsFormatterIntervalWhitespace.Strip)
    formatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
    formatter:SetMaxInterval(Enum.SecondsFormatterInterval.Minutes)
    formatter:SetDesiredUnitCount(1)
    return formatter
end

local ELAPSED = Enum.StatusBarTimerDirection.ElapsedTime
local REMAINING = Enum.StatusBarTimerDirection.RemainingTime

local Castbar = {
    key = "castbar",
    sizeDependent = true,
    events = {
        "UNIT_SPELLCAST_START",
        "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_FAILED",
        "UNIT_SPELLCAST_INTERRUPTED",
        "UNIT_SPELLCAST_DELAYED",
        "UNIT_SPELLCAST_CHANNEL_START",
        "UNIT_SPELLCAST_CHANNEL_UPDATE",
        "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_EMPOWER_START",
        "UNIT_SPELLCAST_EMPOWER_UPDATE",
        "UNIT_SPELLCAST_EMPOWER_STOP",
        "UNIT_SPELLCAST_INTERRUPTIBLE",
        "UNIT_SPELLCAST_NOT_INTERRUPTIBLE",
    },
}
ns.Elements = ns.Elements or {}
ns.Elements.Castbar = Castbar
ns.castTimerPath = "none yet"

local castingBars = {}
local ticker = CreateFrame("Frame")
ticker:Hide()

local function Readiness()
    return InterruptReady:IsTracking()
end

local function SetColor(texture, color)
    texture:SetVertexColor(color[1], color[2], color[3], color[4])
end

local function TargetTextColor(s, unit)
    if s.targetClassColor and RAID_CLASS_COLORS then
        local classFilename = UnitSpellTargetClass(unit)
        if not issecretvalue(classFilename) and classFilename then
            local color = RAID_CLASS_COLORS[classFilename]
            if color then
                return color.r, color.g, color.b, s.targetColor[4]
            end
        end
    end
    return s.targetColor[1], s.targetColor[2], s.targetColor[3], s.targetColor[4]
end

local function ApplyFill(bar)
    local state = bar.plate.state
    local s = settings[state]
    local texture = bar:GetStatusBarTexture()
    local readiness = Readiness()
    local nr, ng, nb, na
    local color = readiness and InterruptReady:GetColor(state, "normal")
    if color then
        nr, ng, nb, na = color.r, color.g, color.b, color.a
    else
        local plain = s.ready
        nr, ng, nb, na = plain[1], plain[2], plain[3], plain[4] or 1
    end
    local flag = bar.isImportant
    local twin = bar.twin
    local twinOn = twin.enabled == true
    local ir, ig, ib, ia
    if twinOn or issecretvalue(flag) or flag then
        local important = readiness and InterruptReady:GetColor(state, "important")
        if important then
            ir, ig, ib, ia = important.r, important.g, important.b, important.a
        else
            local plain = s.importantReady
            ir, ig, ib, ia = plain[1], plain[2], plain[3], plain[4] or 1
        end
    end
    if not issecretvalue(flag) and not flag then
        texture:SetVertexColor(nr, ng, nb, na)
    else
        texture:SetVertexColor(
            EvaluateColorValueFromBoolean(flag, ir, nr),
            EvaluateColorValueFromBoolean(flag, ig, ng),
            EvaluateColorValueFromBoolean(flag, ib, nb),
            EvaluateColorValueFromBoolean(flag, ia, na))
    end

    if not issecretvalue(flag) then
        flag = flag == true
    end
    local stop = bar.notInterruptible
    if not issecretvalue(stop) then
        stop = stop == true
    end

    bar.shield:SetAlphaFromBoolean(stop, s.uninterruptible[4] or 1, 0)
    bar.mustStop:SetAlphaFromBoolean(flag, 1, 0)
    bar.mustStop.fill:SetAlphaFromBoolean(stop, s.importantUninterruptible[4] or 1, 0)
    if s.shieldIcon then
        bar.shieldIcon:SetAlphaFromBoolean(stop, 1, 0)
    else
        bar.shieldIcon:SetAlpha(0)
    end
    if not twinOn then
        if s.showCasts == "interruptible" then
            bar:SetAlphaFromBoolean(stop, 0, 1)
        elseif s.showCasts == "important" then
            bar:SetAlphaFromBoolean(flag, 1, 0)
        else
            bar:SetAlpha(1)
        end
        return
    end
    twin:GetStatusBarTexture():SetVertexColor(ir, ig, ib, ia)
    local health, twinHealth = bar.plate.health, twin.health
    if health and twinHealth then
        twinHealth:SetMinMaxValues(health:GetMinMaxValues())
        twinHealth:SetValue(health:GetValue())
        twinHealth:SetStatusBarColor(health:GetStatusBarColor())
        if s.showCasts == "interruptible" then
            local hidden = EvaluateColorValueFromBoolean(flag, EvaluateColorValueFromBoolean(stop, 1, 0), 1)
            health:SetAlpha(hidden)
            health.borderLayer:SetAlpha(hidden)
        else
            health:SetAlphaFromBoolean(flag, 0, 1)
            health.borderLayer:SetAlphaFromBoolean(flag, 0, 1)
        end
    end
    twin.mustStop:SetAlphaFromBoolean(stop, s.importantUninterruptible[4] or 1, 0)
    if s.shieldIcon then
        twin.shieldIcon:SetAlphaFromBoolean(stop, 1, 0)
    else
        twin.shieldIcon:SetAlpha(0)
    end
    if s.showCasts == "interruptible" then
        local allowed = EvaluateColorValueFromBoolean(stop, 0, 1)
        bar:SetAlpha(EvaluateColorValueFromBoolean(flag, 0, allowed))
        twin:SetAlpha(EvaluateColorValueFromBoolean(flag, allowed, 0))
    elseif s.showCasts == "important" then
        bar:SetAlpha(0)
        twin:SetAlphaFromBoolean(flag, 1, 0)
    else
        bar:SetAlphaFromBoolean(flag, 0, 1)
        twin:SetAlphaFromBoolean(flag, 1, 0)
    end
end

local function NormalVisibility(bar, s)
    local flag, stop = bar.isImportant, bar.notInterruptible
    if not issecretvalue(flag) then
        flag = flag == true
    end
    if not issecretvalue(stop) then
        stop = stop == true
    end
    if s.showCasts == "interruptible" then
        bar:SetAlphaFromBoolean(stop, 0, 1)
    elseif s.showCasts == "important" then
        bar:SetAlphaFromBoolean(flag, 1, 0)
    else
        bar:SetAlpha(1)
    end
end

local function ShowRealHealth(plate)
    local health = plate and plate.health
    if health then
        health:SetAlpha(1)
        health.borderLayer:SetAlpha(1)
    end
end

local function StopTwin(bar)
    local twin = bar.twin
    if twin == NO_TWIN then return end
    twin:SetScript("OnUpdate", nil)
    twin.timerBinding:SetEnabled(false)
    twin:Hide()
    ShowRealHealth(bar.plate)
end

local function PointMarker(bar, channel)
    if bar.markerChannel == channel then return end
    bar.markerChannel = channel
    local positioner, marker, line = bar.kickPositioner, bar.kickMarker, bar.kickLine
    local reached = positioner:GetStatusBarTexture()
    local fill = marker:GetStatusBarTexture()
    positioner:SetReverseFill(channel)
    marker:SetReverseFill(channel)
    marker:ClearAllPoints()
    line:ClearAllPoints()
    if channel then
        marker:SetPoint("TOPRIGHT", reached, "TOPLEFT")
        marker:SetPoint("BOTTOMRIGHT", reached, "BOTTOMLEFT")
        line:SetPoint("TOP", fill, "TOPLEFT")
        line:SetPoint("BOTTOM", fill, "BOTTOMLEFT")
    else
        marker:SetPoint("TOPLEFT", reached, "TOPRIGHT")
        marker:SetPoint("BOTTOMLEFT", reached, "BOTTOMRIGHT")
        line:SetPoint("TOP", fill, "TOPRIGHT")
        line:SetPoint("BOTTOM", fill, "BOTTOMRIGHT")
    end
end

local function UpdateKickMarker(bar)
    local clip = bar.kickClip
    local duration = bar.duration
    local kick = settings[bar.plate.state].showKickMarker and duration and InterruptReady:GetCooldown()
    if not kick then
        clip:Hide()
        return
    end
    PointMarker(bar, bar.drains)
    local total = duration:GetTotalDuration()
    if issecretvalue(total) then
        bar.kickMarkerTotal = nil
        bar.kickPositioner:SetMinMaxValues(0, total)
        bar.kickMarker:SetMinMaxValues(0, total)
    elseif bar.kickMarkerTotal ~= total then
        bar.kickMarkerTotal = total
        bar.kickPositioner:SetMinMaxValues(0, total)
        bar.kickMarker:SetMinMaxValues(0, total)
    end
    bar.kickPositioner:SetValue(duration:GetElapsedDuration())
    bar.kickMarker:SetValue(kick:GetRemainingDuration())
    local alpha = EvaluateColorValueFromBoolean(bar.notInterruptible, 0, 1)
    alpha = EvaluateColorValueFromBoolean(kick:IsZero(), 0, alpha)
    bar.kickLine:SetAlpha(alpha)
    clip:Show()
end

local elapsedSinceTick = 0
ticker:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceTick = elapsedSinceTick + elapsed
    if elapsedSinceTick < READY_TICK then return end
    elapsedSinceTick = 0
    for bar in pairs(castingBars) do
        ApplyFill(bar)
        UpdateKickMarker(bar)
    end
end)

local function TrackCasting(bar, isCasting)
    castingBars[bar] = isCasting or nil
    ticker:SetShown(InterruptReady:IsTracking() and next(castingBars) ~= nil)
end

local function FallbackOnUpdate(bar)
    bar:SetValue(GetTime() * 1000)
end

local function HoldExpired(bar)
    if bar.holding and bar.holdToken == bar.pendingHoldToken then
        Castbar:Disable(bar.plate)
    end
end

function Castbar:Create(plate)
    local bar = CreateFrame("StatusBar", nil, plate)
    bar:Hide()
    bar.plate = plate

    bar.glow = ns.CreateBorder(bar, bar, "BACKGROUND", -8)
    local borderLayer = CreateFrame("Frame", nil, bar)
    borderLayer:SetAllPoints()
    borderLayer:SetFrameLevel(bar:GetFrameLevel() + 1)
    bar.border = ns.CreateBorder(borderLayer, bar, "BACKGROUND", -7)
    bar.background = bar:CreateTexture(nil, "BACKGROUND")
    bar.background:SetAllPoints()


    local clip = CreateFrame("Frame", nil, bar)
    clip:SetAllPoints()
    clip:SetClipsChildren(true)
    clip:Hide()
    local positioner = CreateFrame("StatusBar", nil, clip)
    positioner:SetAllPoints()
    positioner:SetStatusBarTexture(FLAT)
    positioner:GetStatusBarTexture():SetAlpha(0)
    local marker = CreateFrame("StatusBar", nil, clip)
    marker:SetStatusBarTexture(FLAT)
    marker:GetStatusBarTexture():SetAlpha(0)
    local line = clip:CreateTexture(nil, "OVERLAY")
    bar.kickClip, bar.kickPositioner, bar.kickMarker, bar.kickLine = clip, positioner, marker, line

    local interrupted = CreateFrame("Frame", nil, bar)
    interrupted:SetAllPoints()
    interrupted:SetFrameLevel(bar:GetFrameLevel() + 3)
    interrupted.fill = interrupted:CreateTexture(nil, "ARTWORK")
    interrupted.fill:SetAllPoints()
    interrupted:Hide()
    bar.interrupted = interrupted
    bar.holdToken = 0
    bar.holdCallback = function() HoldExpired(bar) end

    local textLayer = CreateFrame("Frame", nil, bar)
    textLayer:SetAllPoints()
    textLayer:SetFrameLevel(bar:GetFrameLevel() + 4)
    bar.textLayer = textLayer

    bar.spark = textLayer:CreateTexture(nil, "OVERLAY", nil, 2)
    bar.spark:SetTexture(SPARK)
    bar.spark:SetBlendMode("ADD")
    bar.spark:Hide()

    bar.shield = bar:CreateTexture(nil, "ARTWORK", nil, 7)
    bar.shield:SetAllPoints(bar:GetStatusBarTexture() or bar)
    bar.shield:SetAlpha(0)

    local mustStop = CreateFrame("Frame", nil, bar)
    mustStop:SetFrameLevel(bar:GetFrameLevel() + 2)
    mustStop:SetAlpha(0)
    mustStop.fill = mustStop:CreateTexture(nil, "ARTWORK")
    mustStop.fill:SetAllPoints()
    mustStop.fill:SetAlpha(0)
    bar.mustStop = mustStop

    bar.icon = bar:CreateTexture(nil, "ARTWORK")
    bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    bar.shieldIcon = textLayer:CreateTexture(nil, "OVERLAY", nil, 3)
    bar.shieldIcon:SetTexture(SHIELD)
    bar.shieldIcon:SetAlpha(0)
    bar.iconBorder = ns.CreateBorder(bar, bar.icon, "BACKGROUND", -7)

    bar.timer = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.timer:SetJustifyH("RIGHT")

    bar.text = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.text:SetJustifyH("LEFT")
    bar.text:SetWordWrap(false)

    bar.target = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.target:SetJustifyH("CENTER")
    bar.target:SetWordWrap(false)

    bar.interruptText = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bar.interruptText:SetWordWrap(false)
    bar.interruptText:Hide()

    local timerBinding = CreateDurationTextBinding()
    timerBinding:SetFontString(bar.timer)
    timerBinding:SetUpdateInterval(0.1)
    timerBinding:SetEnabled(false)
    bar.timerBinding = timerBinding

    bar.twin = NO_TWIN
    plate.castbar = bar
end

function Castbar:CreateTwin(plate)
    local twin = CreateFrame("StatusBar", nil, plate)
    twin:Hide()
    twin:SetFrameLevel(plate:GetFrameLevel() + TWIN_LEVEL)
    twin.glow = ns.CreateBorder(twin, twin, "BACKGROUND", -8)
    local borderLayer = CreateFrame("Frame", nil, twin)
    borderLayer:SetAllPoints()
    borderLayer:SetFrameLevel(twin:GetFrameLevel() + 1)
    twin.border = ns.CreateBorder(borderLayer, twin, "BACKGROUND", -7)
    twin.background = twin:CreateTexture(nil, "BACKGROUND")
    twin.background:SetAllPoints()

    local textLayer = CreateFrame("Frame", nil, twin)
    textLayer:SetAllPoints()
    textLayer:SetFrameLevel(twin:GetFrameLevel() + 4)

    twin.spark = textLayer:CreateTexture(nil, "OVERLAY", nil, 2)
    twin.spark:SetTexture(SPARK)
    twin.spark:SetBlendMode("ADD")
    twin.spark:Hide()

    twin.mustStop = twin:CreateTexture(nil, "ARTWORK", nil, 7)
    twin.mustStop:SetAlpha(0)

    twin.icon = twin:CreateTexture(nil, "ARTWORK")
    twin.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    twin.iconBorder = ns.CreateBorder(twin, twin.icon, "BACKGROUND", -7)

    twin.shieldIcon = textLayer:CreateTexture(nil, "OVERLAY", nil, 3)
    twin.shieldIcon:SetTexture(SHIELD)
    twin.shieldIcon:SetAlpha(0)

    twin.timer = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    twin.timer:SetJustifyH("RIGHT")
    twin.text = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    twin.text:SetJustifyH("LEFT")
    twin.text:SetWordWrap(false)
    twin.target = textLayer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    twin.target:SetJustifyH("CENTER")
    twin.target:SetWordWrap(false)

    local timerBinding = CreateDurationTextBinding()
    timerBinding:SetFontString(twin.timer)
    timerBinding:SetUpdateInterval(0.1)
    timerBinding:SetEnabled(false)
    twin.timerBinding = timerBinding

    local health = plate.health
    if health then
        local copy = CreateFrame("StatusBar", nil, twin)
        copy:SetMinMaxValues(0, 1)
        copy.background = copy:CreateTexture(nil, "BACKGROUND")
        copy.background:SetAllPoints()
        local copyLayer = CreateFrame("Frame", nil, copy)
        copyLayer:SetAllPoints()
        copyLayer:SetFrameLevel(copy:GetFrameLevel() + 3)
        copy.border = ns.CreateBorder(copyLayer, copy, "BACKGROUND", -7)
        hooksecurefunc(health, "SetValue", function(_, ...) copy:SetValue(...) end)
        hooksecurefunc(health, "SetMinMaxValues", function(_, ...) copy:SetMinMaxValues(...) end)
        hooksecurefunc(health, "SetStatusBarColor", function(_, ...) copy:SetStatusBarColor(...) end)
        hooksecurefunc(health, "SetReverseFill", function(_, ...) copy:SetReverseFill(...) end)
        twin.health = copy
    end
    return twin
end

local function StyleTexts(bar, db)
    ns.ApplyFont(bar.timer, db.font, db.size, db.outline)
    ns.ApplyShadow(bar.timer, db.shadow)
    ns.ApplyShadow(bar.text, db.shadow)
    ns.ApplyShadow(bar.target, db.shadow)
    ns.PlaceIcon(bar.timer, bar, db.timerPosition, 3, db.timerOffsetX, db.timerOffsetY)

    ns.ApplyFont(bar.text, db.font, db.size, db.outline)
    bar.text:SetJustifyH(db.textJustify)
    bar.text:ClearAllPoints()
    local textRightInset = db.showTimer and TIMER_WIDTH or 3
    if db.textJustify == "RIGHT" then
        bar.text:SetPoint("RIGHT", -textRightInset, 0)
    elseif db.textJustify == "CENTER" then
        bar.text:SetPoint("CENTER", (3 - textRightInset) / 2, 0)
    else
        bar.text:SetPoint("LEFT", 3, 0)
    end

    ns.ApplyFont(bar.target, db.font, db.targetSize, db.outline)
    bar.target:SetTextColor(db.targetColor[1], db.targetColor[2], db.targetColor[3], db.targetColor[4])
    ns.PlaceIcon(bar.target, bar, db.targetPosition, 2, db.targetOffsetX, db.targetOffsetY)
    return textRightInset
end

local function StyleTwinHealth(plate, twin, drop, iconOffset, iconRight)
    local copy, health = twin.health, plate.health
    if not copy or not health then return end
    local hdb = ns.DB.views[plate.state].health
    copy:ClearAllPoints()
    copy:SetSize(plate:GetWidth(), plate:GetHeight())
    copy:SetPoint("BOTTOM", twin, "TOP", iconRight and iconOffset / 2 or -iconOffset / 2, drop)
    ns.SetBarTexture(copy, health.texture or hdb.texture)
    copy:SetStatusBarDesaturated(hdb.desaturate == true)
    copy:SetReverseFill(hdb.fillDirection == "right")
    ns.SetBackgroundTexture(copy.background, hdb.backgroundTexture, hdb.background)
    copy.border:SetStyle(hdb.borderStyle, copy)
    copy.border:SetColor(hdb.border[1], hdb.border[2], hdb.border[3], hdb.border[4])
    copy.border:Layout(hdb.borderSize, 0, hdb.borderInside)
end

local function StyleTwin(plate, bar, db, barWidth, height, gap, size, iconRight, drop, iconOffset)
    local wanted = db.importantEnlarge == true and plate.state ~= "friendly"
    if not wanted then
        StopTwin(bar)
        if bar.twin ~= NO_TWIN then
            bar.twin.enabled = false
        end
        ShowRealHealth(plate)
        return
    end
    if bar.twin == NO_TWIN then
        bar.twin = Castbar:CreateTwin(plate)
    end
    local twin = bar.twin
    twin.enabled = true
    twin:ClearAllPoints()
    twin:SetSize(barWidth, height)
    twin:SetPoint("CENTER", bar, "CENTER")
    twin:SetScale(db.importantScale or 1.3)
    StyleTwinHealth(plate, twin, drop, iconOffset, iconRight)
    ns.SetBarTexture(twin, db.texture)
    ns.SetBarOverlay(twin, db.overlayPattern ~= "" and db.overlayPattern or nil, db.overlayAlpha, db.overlayContrast)
    twin.timerBinding:SetFormatter(settings[plate.state].formatter)
    twin.mustStop:ClearAllPoints()
    twin.mustStop:SetAllPoints(twin:GetStatusBarTexture())
    twin.mustStop:SetColorTexture(db.importantUninterruptible[1], db.importantUninterruptible[2], db.importantUninterruptible[3], 1)

    twin.border:SetStyle(db.borderStyle, twin)
    twin.border:SetColor(db.border[1], db.border[2], db.border[3], db.border[4])
    twin.border:Layout(size, 0, db.borderInside)
    twin.background:SetColorTexture(db.background[1], db.background[2], db.background[3], db.background[4])
    twin.glow:Layout(db.glowSize, db.borderInside and 0 or size)
    twin.glow:SetColor(db.importantColor[1], db.importantColor[2], db.importantColor[3], db.importantColor[4])
    twin.glow:SetAlpha(db.importantGlow and 1 or 0)

    twin.icon:ClearAllPoints()
    twin.icon:SetSize(height, height)
    if iconRight then
        twin.icon:SetPoint("LEFT", twin, "RIGHT", gap, 0)
    else
        twin.icon:SetPoint("RIGHT", twin, "LEFT", -gap, 0)
    end
    if db.cropIcon == false then
        twin.icon:SetTexCoord(0, 1, 0, 1)
    else
        twin.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    twin.icon:SetShown(db.showIcon)
    twin.iconBorder:Layout(size)
    twin.iconBorder:SetColor(db.border[1], db.border[2], db.border[3], db.border[4])
    twin.iconBorder:SetShown(db.showIcon)

    twin.spark:ClearAllPoints()
    twin.spark:SetPoint("CENTER", twin:GetStatusBarTexture(), "RIGHT", 0, 0)
    twin.spark:SetSize(math.max(8, height), height * 2.2)
    twin.spark:SetVertexColor(db.sparkColor[1], db.sparkColor[2], db.sparkColor[3], db.sparkColor[4])

    twin.shieldIcon:ClearAllPoints()
    twin.shieldIcon:SetSize(height + 8, height + 8)
    if db.showIcon then
        twin.shieldIcon:SetPoint("CENTER", twin.icon, "CENTER")
    else
        twin.shieldIcon:SetPoint("CENTER", twin, iconRight and "RIGHT" or "LEFT")
    end
    StyleTexts(twin, db)
end

function Castbar:Configure(db, state)
    local s = settings[state] or { formatter = NewFormatter() }
    settings[state] = s
    s.formatter:SetMillisecondsThreshold(db.timerDecimalsBelow)
    s.showSpark = db.showSpark
    s.ready = db.readyColor
    s.notReady = db.notReadyColor
    s.importantReady = db.importantReadyColor
    s.importantNotReady = db.importantNotReadyColor
    s.uninterruptible = db.uninterruptible
    s.importantUninterruptible = db.importantUninterruptible
    s.showTimer = db.showTimer
    s.showTarget = db.showTarget
    s.targetColor = db.targetColor
    s.targetClassColor = db.targetClassColor
    s.showGlow = db.importantGlow
    s.showKickMarker = db.kickMarker
    s.showInterrupter = db.showInterrupter
    s.interruptHold = db.interruptHold
    s.interruptFormat = db.interruptFormat or "by"
    s.interruptClassColor = db.interruptClassColor ~= false
    s.interruptKeepName = db.interruptKeepName == true
    s.showSpellName = db.showSpellName ~= false
    s.drain = db.drainCasts == true
    s.shieldIcon = db.shieldIcon == true
    s.showCasts = db.showCasts or "all"
    InterruptReady:SetColors(state, "normal", db.readyColor, db.notReadyColor)
    InterruptReady:SetColors(state, "important", db.importantReadyColor, db.importantNotReadyColor)
end

function Castbar:Style(plate, db)
    local bar = plate.castbar
    local height, gap, size = (db.height and db.height > 0) and db.height or plate:GetHeight(), db.gap, db.borderSize
    local drop = gap + (plate.castShift or 0)
    local span = db.showIcon and db.iconSpan
    local iconOffset = (db.showIcon and not span) and (height + gap) or 0

    local iconRight = db.iconSide == "RIGHT"
    local total = (db.width and db.width > 0) and db.width or plate:GetWidth()
    local barWidth = math.max(10, total - iconOffset)
    bar:ClearAllPoints()
    if db.width and db.width > 0 then
        bar:SetPoint("TOP", plate, "BOTTOM", (iconRight and -iconOffset or iconOffset) / 2, -drop)
        bar:SetWidth(barWidth)
    else
        bar:SetPoint("TOPLEFT", plate, "BOTTOMLEFT", iconRight and 0 or iconOffset, -drop)
        bar:SetPoint("TOPRIGHT", plate, "BOTTOMRIGHT", iconRight and -iconOffset or 0, -drop)
    end
    bar:SetHeight(height)
    ns.SetBarTexture(bar, db.texture)
    ns.SetBarOverlay(bar, db.overlayPattern ~= "" and db.overlayPattern or nil, db.overlayAlpha, db.overlayContrast)
    bar.timerBinding:SetFormatter(settings[plate.state].formatter)
    bar.kickMarker:SetWidth(barWidth)
    bar.kickClip:SetFrameLevel(bar:GetFrameLevel() + 2)
    bar.kickLine:SetWidth(db.kickMarkerWidth)
    bar.kickLine:SetColorTexture(db.kickMarkerColor[1], db.kickMarkerColor[2], db.kickMarkerColor[3], db.kickMarkerColor[4])
    bar.markerChannel = nil
    bar.shield:ClearAllPoints()
    bar.shield:SetAllPoints(bar:GetStatusBarTexture())
    bar.shield:SetColorTexture(db.uninterruptible[1], db.uninterruptible[2], db.uninterruptible[3], 1)
    bar.mustStop:ClearAllPoints()
    bar.mustStop:SetAllPoints(bar:GetStatusBarTexture())
    bar.mustStop.fill:SetColorTexture(db.importantUninterruptible[1], db.importantUninterruptible[2], db.importantUninterruptible[3], 1)
    local hit = db.interruptedColor
    bar.interrupted.fill:SetColorTexture(hit[1], hit[2], hit[3], hit[4])

    bar.border:SetStyle(db.borderStyle, bar)
    bar.border:SetColor(db.border[1], db.border[2], db.border[3], db.border[4])
    bar.border:Layout(size, 0, db.borderInside)
    bar.background:SetColorTexture(db.background[1], db.background[2], db.background[3], db.background[4])

    bar.glow:Layout(db.glowSize, db.borderInside and 0 or size)
    bar.glow:SetColor(db.importantColor[1], db.importantColor[2], db.importantColor[3], db.importantColor[4])
    bar.glow:SetAlpha(0)

    bar.icon:ClearAllPoints()
    if span then
        local tall = ns.DB.views[plate.state].plate.height + drop + height
        bar.icon:SetSize(tall, tall)
        if iconRight then
            bar.icon:SetPoint("TOPLEFT", plate, "TOPRIGHT", gap, 0)
        else
            bar.icon:SetPoint("TOPRIGHT", plate, "TOPLEFT", -gap, 0)
        end
    else
        bar.icon:SetSize(height, height)
        if iconRight then
            bar.icon:SetPoint("LEFT", bar, "RIGHT", gap, 0)
        else
            bar.icon:SetPoint("RIGHT", bar, "LEFT", -gap, 0)
        end
    end
    bar.spark:ClearAllPoints()
    bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
    bar.spark:SetSize(math.max(8, height), height * 2.2)
    local spark = db.sparkColor
    bar.spark:SetVertexColor(spark[1], spark[2], spark[3], spark[4])
    if db.cropIcon == false then
        bar.icon:SetTexCoord(0, 1, 0, 1)
    else
        bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    local shieldSize = height + 8
    bar.shieldIcon:ClearAllPoints()
    bar.shieldIcon:SetSize(shieldSize, shieldSize)
    if db.showIcon then
        bar.shieldIcon:SetPoint("CENTER", bar.icon, "CENTER")
    else
        bar.shieldIcon:SetPoint("CENTER", bar, iconRight and "RIGHT" or "LEFT")
    end
    bar.icon:SetShown(db.showIcon)
    bar.iconBorder:Layout(size)
    bar.iconBorder:SetColor(db.border[1], db.border[2], db.border[3], db.border[4])
    bar.iconBorder:SetShown(db.showIcon)

    local textRightInset = StyleTexts(bar, db)
    StyleTwin(plate, bar, db, barWidth, height, gap, size, iconRight, drop, iconOffset)

    local interruptText = bar.interruptText
    ns.ApplyFont(interruptText, db.font, db.interruptSize or db.size, db.outline)
    ns.ApplyShadow(interruptText, db.shadow)
    local hit = db.interruptTextColor or { 1, 1, 1, 1 }
    interruptText:SetTextColor(hit[1], hit[2], hit[3], hit[4])
    interruptText:ClearAllPoints()
    local x, y = db.interruptOffsetX or 0, db.interruptOffsetY or 0
    if (db.interruptPosition or "SPELL") == "SPELL" then
        interruptText:SetJustifyH(db.textJustify)
        if db.textJustify == "RIGHT" then
            interruptText:SetPoint("RIGHT", bar, "RIGHT", -textRightInset + x, y)
        elseif db.textJustify == "CENTER" then
            interruptText:SetPoint("CENTER", bar, "CENTER", (3 - textRightInset) / 2 + x, y)
        else
            interruptText:SetPoint("LEFT", bar, "LEFT", 3 + x, y)
        end
    else
        interruptText:SetJustifyH("CENTER")
        ns.PlaceIcon(interruptText, bar, db.interruptPosition, 2, x, y)
    end

    ApplyFill(bar)
end

function Castbar:Reposition(plate)
    if not plate.castbar then return end
    local db = ns.DB.views[plate.state].castbar
    self:Style(plate, db)
end

function Castbar:Enable(plate, unit)
    self:Refresh(plate, unit)
end

function Castbar:Disable(plate)
    local bar = plate.castbar
    if not bar:IsShown() and not bar.holding and bar.duration == nil then
        return
    end
    bar.holdToken = bar.holdToken + 1
    if bar:IsShown() and not bar.holding then
        bar.stoppedAt = GetTime()
    end
    bar.holding = false
    bar.interrupted:Hide()
    bar.interruptText:Hide()
    bar:SetScript("OnUpdate", nil)
    bar.timerBinding:SetEnabled(false)
    bar.duration = nil
    bar.kickClip:Hide()
    bar.mustStop:SetAlpha(0)
    StopTwin(bar)
    TrackCasting(bar, false)
    if plate.casting then
        plate.casting = false
        ns.Scaling:Apply(plate)
        ns.Elements.Name:RefreshShown(plate)
    end
    bar:Hide()
end

local function WriteInterrupter(text, s, name)
    if s.interruptFormat == "name" then
        text:SetText(name)
    else
        text:SetFormattedText(INTERRUPTED_BY, name)
    end
end

local function InterruptText(text, interruptedBy, s)
    if s.interruptFormat == "label" or (not issecretvalue(interruptedBy) and interruptedBy == nil) then
        text:SetText(INTERRUPTED_TEXT)
        return
    end
    local name = UnitNameFromGUID(interruptedBy)
    if issecretvalue(name) then
        WriteInterrupter(text, s, name)
        return
    end
    if not name or name == "" then
        text:SetText(INTERRUPTED_TEXT)
        return
    end
    local _, class = UnitClassFromGUID(interruptedBy)
    local color = s.interruptClassColor and not issecretvalue(class) and class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if color then
        name = color:WrapTextInColorCode(name)
    end
    WriteInterrupter(text, s, name)
end

function Castbar:ShowInterrupted(plate, interruptedBy)
    local bar = plate.castbar
    local s = settings[plate.state]
    TrackCasting(bar, false)
    bar:SetScript("OnUpdate", nil)
    bar.timerBinding:SetEnabled(false)
    bar.timer:Hide()
    bar.target:Hide()
    bar.spark:Hide()
    bar.kickClip:Hide()
    bar.glow:SetAlpha(0)
    StopTwin(bar)
    NormalVisibility(bar, s)
    bar.interrupted:Show()
    bar:Show()
    if not s.interruptKeepName then
        bar.text:SetText("")
    end
    if not pcall(InterruptText, bar.interruptText, interruptedBy, s) then
        bar.interruptText:SetText(INTERRUPTED_TEXT)
    end
    bar.interruptText:Show()
    bar.holding = true
    if plate.casting then
        plate.casting = false
        ns.Scaling:Apply(plate)
        ns.Elements.Name:RefreshShown(plate)
    end
    bar.holdToken = bar.holdToken + 1
    bar.pendingHoldToken = bar.holdToken
    C_Timer.After(s.interruptHold, bar.holdCallback)
end

function Castbar:OnEvent(plate, event, unit, _, _, _, interruptedBy)
    local s = settings[plate.state]
    local bar = plate.castbar
    local recent = bar:IsShown() or (bar.stoppedAt ~= nil and GetTime() - bar.stoppedAt < 0.3)
    if s.showInterrupter and recent then
        if event == "UNIT_SPELLCAST_INTERRUPTED" then
            self:ShowInterrupted(plate, interruptedBy)
            return
        elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" and (issecretvalue(interruptedBy) or interruptedBy ~= nil) then
            self:ShowInterrupted(plate, interruptedBy)
            return
        end
    end
    if plate.castbar.holding and (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
        return
    end
    if event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        plate.castbar.notInterruptible = false
        ApplyFill(plate.castbar)
        UpdateKickMarker(plate.castbar)
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        plate.castbar.notInterruptible = true
        ApplyFill(plate.castbar)
        UpdateKickMarker(plate.castbar)
    else
        self:Refresh(plate, unit, event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED")
    end
end

function Castbar:Refresh(plate, unit, ending)
    local bar = plate.castbar
    if bar.holding then
        bar.holding = false
        bar.holdToken = bar.holdToken + 1
        bar.interrupted:Hide()
        bar.interruptText:Hide()
    end
    local s = settings[plate.state]
    local name, _, texture, startMs, endMs, isTradeskill, _, notInterruptible, spellID = UnitCastingInfo(unit)
    local duration, direction
    local normalCast = isTradeskill ~= nil

    if isTradeskill ~= nil then
        duration = UnitCastingDuration(unit)
        direction = ELAPSED
    else
        if ending and not bar.channel then
            self:Disable(plate)
            return
        end
        local isEmpowered
        name, _, texture, startMs, endMs, isTradeskill, notInterruptible, spellID, isEmpowered = UnitChannelInfo(unit)
        if isTradeskill == nil then
            self:Disable(plate)
            return
        end
        if isEmpowered then
            duration = UnitEmpoweredChannelDuration(unit, true)
            direction = ELAPSED
        else
            duration = UnitChannelDuration(unit)
            direction = REMAINING
        end
    end
    local channel = direction == REMAINING
    if s.drain and normalCast then
        direction = REMAINING
    end

    if not issecretvalue(notInterruptible) and not notInterruptible then
        notInterruptible = false
    end
    bar.notInterruptible = notInterruptible
    bar.channel = channel
    bar.drains = direction == REMAINING
    local important = IsSpellImportant(spellID)
    bar.isImportant = important
    ApplyFill(bar)

    if s.showGlow then
        bar.glow:SetAlphaFromBoolean(important, 1, 0)
    else
        bar.glow:SetAlpha(0)
    end

    if s.showTarget and UnitShouldDisplaySpellTargetName(unit) then
        bar.target:SetText(UnitSpellTargetName(unit))
        bar.target:SetTextColor(TargetTextColor(s, unit))
        bar.target:Show()
    else
        bar.target:Hide()
    end

    bar.icon:SetTexture(texture)
    bar.text:SetText(s.showSpellName and name or "")

    if not issecretvalue(duration) and duration then
        bar:SetScript("OnUpdate", nil)
        bar:SetTimerDuration(duration, nil, direction)
        bar.duration = duration
        bar.timerBinding:SetDuration(duration)
        bar.timerBinding:SetEnabled(s.showTimer)
        bar.timer:SetShown(s.showTimer)
        ns.castTimerPath = "native"
    else
        bar:SetMinMaxValues(startMs, endMs)
        bar:SetValue(GetTime() * 1000)
        bar:SetScript("OnUpdate", FallbackOnUpdate)
        bar.duration = nil
        bar.timerBinding:SetEnabled(false)
        bar.timer:Hide()
        ns.castTimerPath = "fallback"
    end

    bar.spark:SetShown(s.showSpark)
    local twin = bar.twin
    if twin.enabled then
        twin.icon:SetTexture(texture)
        twin.text:SetText(s.showSpellName and name or "")
        if bar.target:IsShown() then
            twin.target:SetText(UnitSpellTargetName(unit))
            twin.target:SetTextColor(TargetTextColor(s, unit))
            twin.target:Show()
        else
            twin.target:Hide()
        end
        if bar.duration then
            twin:SetScript("OnUpdate", nil)
            twin:SetTimerDuration(bar.duration, nil, direction)
            twin.timerBinding:SetDuration(bar.duration)
            twin.timerBinding:SetEnabled(s.showTimer)
            twin.timer:SetShown(s.showTimer)
        else
            twin:SetMinMaxValues(startMs, endMs)
            twin:SetValue(GetTime() * 1000)
            twin:SetScript("OnUpdate", FallbackOnUpdate)
            twin.timerBinding:SetEnabled(false)
            twin.timer:Hide()
        end
        twin.spark:SetShown(s.showSpark)
        twin:Show()
    end
    TrackCasting(bar, true)
    if not plate.casting then
        ns.Fire("CAST_START", unit, plate)
        plate.casting = true
        ns.Scaling:Apply(plate)
        ns.Elements.Name:RefreshShown(plate)
    end
    UpdateKickMarker(bar)
    bar:Show()
end

function Castbar:Preview(plate, state)
    local bar = plate.castbar
    local cast = state.cast
    local s = settings[plate.state]
    if not cast then
        self:Disable(plate)
        return
    end

    bar:SetScript("OnUpdate", nil)
    bar.timerBinding:SetEnabled(false)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue((s.drain and not cast.channel) and (1 - cast.progress) or cast.progress)
    local interrupted = cast.interrupted and s.showInterrupter
    bar.shieldIcon:SetAlpha((s.shieldIcon and cast.notInterruptible) and 1 or 0)
    if s.showCasts == "interruptible" then
        bar:SetAlpha(cast.notInterruptible and 0 or 1)
    elseif s.showCasts == "important" then
        bar:SetAlpha(cast.important and 1 or 0)
    else
        bar:SetAlpha(1)
    end
    bar.interrupted:SetShown(interrupted)

    local texture = bar:GetStatusBarTexture()
    local fill
    if cast.important then
        fill = cast.onCooldown and s.importantNotReady or s.importantReady
    else
        fill = cast.onCooldown and s.notReady or s.ready
    end
    SetColor(texture, fill)
    bar.shield:SetColorTexture(s.uninterruptible[1], s.uninterruptible[2], s.uninterruptible[3], 1)
    bar.shield:SetAlpha(cast.notInterruptible and (s.uninterruptible[4] or 1) or 0)
    bar.mustStop:SetAlpha(cast.important and 1 or 0)
    bar.mustStop.fill:SetColorTexture(s.importantUninterruptible[1], s.importantUninterruptible[2], s.importantUninterruptible[3], 1)
    bar.mustStop.fill:SetAlpha(cast.notInterruptible and (s.importantUninterruptible[4] or 1) or 0)
    if s.showKickMarker and not cast.notInterruptible then
        bar.kickClip:Show()
        bar.kickLine:SetAlpha(1)
        PointMarker(bar, false)
        bar.kickPositioner:SetMinMaxValues(0, 1)
        bar.kickPositioner:SetValue(cast.progress)
        bar.kickMarker:SetMinMaxValues(0, 1)
        bar.kickMarker:SetValue(0.25)
    else
        bar.kickClip:Hide()
    end
    bar.glow:SetAlpha((s.showGlow and cast.important) and 1 or 0)

    plate.casting = true
    ns.Scaling:Apply(plate)
    bar.spark:SetShown(s.showSpark)
    bar.icon:SetTexture(cast.icon)
    bar.text:SetText(s.showSpellName and cast.name or "")
    bar.timer:SetText(cast.timer)
    bar.timer:SetShown(s.showTimer and not interrupted)
    bar.interruptText:SetShown(interrupted)
    if interrupted then
        if not s.interruptKeepName then
            bar.text:SetText("")
        end
        if not pcall(InterruptText, bar.interruptText, UnitGUID("player"), s) then
            bar.interruptText:SetText(INTERRUPTED_TEXT)
        end
        bar.kickClip:Hide()
        bar.glow:SetAlpha(0)
        bar.spark:Hide()
    end

    if s.showTarget and cast.target and not interrupted then
        bar.target:SetText(cast.target)
        if s.targetClassColor and RAID_CLASS_COLORS and RAID_CLASS_COLORS[UnitClassBase("player")] then
            local color = RAID_CLASS_COLORS[UnitClassBase("player")]
            bar.target:SetTextColor(color.r, color.g, color.b, s.targetColor[4])
        else
            bar.target:SetTextColor(s.targetColor[1], s.targetColor[2], s.targetColor[3], s.targetColor[4])
        end
        bar.target:Show()
    else
        bar.target:Hide()
    end

    local twin = bar.twin
    if twin.enabled and cast.important and not interrupted then
        twin:SetMinMaxValues(0, 1)
        twin:SetValue((s.drain and not cast.channel) and (1 - cast.progress) or cast.progress)
        SetColor(twin:GetStatusBarTexture(), cast.onCooldown and s.importantNotReady or s.importantReady)
        twin.mustStop:SetAlpha(cast.notInterruptible and (s.importantUninterruptible[4] or 1) or 0)
        twin.shieldIcon:SetAlpha((s.shieldIcon and cast.notInterruptible) and 1 or 0)
        twin.icon:SetTexture(cast.icon)
        twin.text:SetText(s.showSpellName and cast.name or "")
        twin.timer:SetText(cast.timer)
        twin.timer:SetShown(s.showTimer)
        twin.target:SetShown(bar.target:IsShown())
        twin.target:SetText(bar.target:GetText() or "")
        twin.target:SetTextColor(bar.target:GetTextColor())
        twin.spark:SetShown(s.showSpark)
        twin:SetAlpha(bar:GetAlpha())
        bar:SetAlpha(0)
        twin:Show()
    else
        StopTwin(bar)
    end
    bar:Show()
end

ns.Driver:RegisterElement(Castbar)
