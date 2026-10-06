local _, ns = ...

local function Say(message)
    print(ns.Brand:Text("Plateau") .. " " .. message)
end

local function Metric(profiler, metric)
    local ok, value = pcall(profiler.GetAddOnMetric, ns.name, metric)
    if ok and type(value) == "number" and not issecretvalue(value) then
        return value
    end
end

local baseline

local function SlowCounts()
    local profiler = C_AddOnProfiler
    local metrics = Enum.AddOnProfilerMetric
    if not (profiler and profiler.IsEnabled and profiler.IsEnabled() and metrics) then return nil end
    local over5 = Metric(profiler, metrics.CountTimeOver5Ms)
    if not over5 then return nil end
    return over5, Metric(profiler, metrics.CountTimeOver10Ms) or 0, Metric(profiler, metrics.CountTimeOver50Ms) or 0
end

function ns.ResetPerformanceCounts()
    local a, b, c = SlowCounts()
    baseline = a and { a, b, c } or nil
end

function ns.CpuReadout()
    local profiler = C_AddOnProfiler
    local metrics = Enum.AddOnProfilerMetric
    if not (profiler and profiler.IsEnabled and profiler.IsEnabled() and metrics) then return nil end
    local recent = Metric(profiler, metrics.RecentAverageTime)
    if not recent then return nil end
    local fps = GetFramerate()
    local percent = fps and fps > 0 and recent / (1000 / fps) * 100 or 0
    return recent, percent
end

function ns.MemoryReadout()
    if not (UpdateAddOnMemoryUsage and GetAddOnMemoryUsage) then return nil end
    UpdateAddOnMemoryUsage()
    local kilobytes = GetAddOnMemoryUsage(ns.name)
    if type(kilobytes) ~= "number" or issecretvalue(kilobytes) then return nil end
    return kilobytes / 1024
end

function ns.PerformanceLines()
    local lines = {}
    local profiler = C_AddOnProfiler
    local metrics = Enum.AddOnProfilerMetric
    if profiler and profiler.IsEnabled and profiler.IsEnabled() and metrics then
        local recent = Metric(profiler, metrics.RecentAverageTime)
        local session = Metric(profiler, metrics.SessionAverageTime)
        local peak = Metric(profiler, metrics.PeakTime)
        if recent then
            lines[#lines + 1] = ("Recent CPU time: %.2f ms per frame"):format(recent)
            lines[#lines + 1] = ("Session average CPU time: %.2f ms per frame"):format(session or 0)
            lines[#lines + 1] = ("Peak CPU time: %.1f ms (worst frame)"):format(peak or 0)
            local ok, all = pcall(profiler.GetOverallMetric, metrics.RecentAverageTime)
            if ok and type(all) == "number" and not issecretvalue(all) and all > 0 then
                lines[#lines + 1] = ("Share of addon CPU time: %.1f%%"):format(recent / all * 100)
            end
        end
        local over5, over10, over50 = SlowCounts()
        if over5 then
            if baseline then
                lines[#lines + 1] = ("Slow frames since reset: over 5 ms %d, over 10 ms %d, over 50 ms %d"):format(
                    over5 - baseline[1], over10 - baseline[2], over50 - baseline[3])
            end
            lines[#lines + 1] = ("Slow frames this session: over 5 ms %d, over 10 ms %d, over 50 ms %d"):format(over5, over10, over50)
        end
    else
        lines[#lines + 1] = "CPU numbers aren't available: the game's addon profiler is off or missing."
    end
    local megabytes = ns.MemoryReadout()
    if megabytes then
        lines[#lines + 1] = ("Memory usage: %.1f MB"):format(megabytes)
    end
    local total, claimed = ns.Driver:CountActive()
    lines[#lines + 1] = ("Visible nameplates: %d"):format(total)
    lines[#lines + 1] = ("Nameplates styled by Plateau: %d"):format(claimed)
    return lines
end

local RESTRICTIONS = { "Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map" }
local lastEventCount, lastEventTime

local function Debug()
    local total, claimed = ns.Driver:CountActive()
    Say(("%s (%s), profile %s"):format(ns.version, ns.flavor, ns.DB.profileName))
    local active = {}
    local states = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
    if states then
        for _, name in ipairs(RESTRICTIONS) do
            local kind = Enum.AddOnRestrictionType[name]
            if kind and states(kind) == Enum.AddOnRestrictionState.Active then
                active[#active + 1] = name
            end
        end
    end
    print(("  Restrictions active: %s"):format(#active > 0 and table.concat(active, ", ") or "none"))
    print(("  Plates: %d showing, %d drawn by Plateau"):format(total, claimed))
    if ns.realmPurgeFailed then
        print("  Realm marker cleanup didn't finish: Blizzard's friendly plates may show errors. Report this with your BugSack log.")
    end
    local failures = ns.DB.migrationFailures
    if ns.recovered or (failures and #failures > 0) then
        print(("  Saved settings: %s"):format(ns.recovered and ("recovered from damage (" .. ns.recovered .. ")") or ("upgrade problems: " .. table.concat(failures, "; "))))
    end
    local now = GetTime()
    if lastEventTime and now > lastEventTime then
        print(("  Plate events: %.1f per second since the last /plt debug"):format((ns.Driver.eventCount - lastEventCount) / (now - lastEventTime)))
    else
        print("  Plate events: run /plt debug again in a few seconds for a rate")
    end
    lastEventCount, lastEventTime = ns.Driver.eventCount, now
    for _, line in ipairs(ns.PerformanceLines()) do
        print("  " .. line)
    end
    if ns.BossPhaseStatus then
        local encounter, problem = ns.BossPhaseStatus()
        print(("  Boss phase lines: encounter %s%s"):format(tostring(encounter or "none"), problem and (", last problem: " .. problem) or ""))
    end
    local kickID = ns.InterruptReady:GetSpellID()
    print(("  Cast timer: %s. Interrupt: %s"):format(ns.castTimerPath, kickID and (C_Spell.GetSpellName(kickID) or kickID) or "none found"))
    for _, unit in ipairs({ "target", "focus" }) do
        local shown = ns.Driver:GetPlate(unit)
        if shown then
            local look = ns.DB.views.enemy
            local override = (shown.isTarget and look.target.colorBar and "Target page: Use custom target color")
                or (shown.isFocus and look.focus.colorBar and "Focus page: Use custom focus color")
            local r, g, b = shown.health:GetStatusBarColor()
            local current = (not issecretvalue(r) and r) and ("%.2f %.2f %.2f"):format(r, g, b) or "hidden"
            print(("  %s color: %s  [bar now %s]"):format(unit == "target" and "Target" or "Focus",
                override or ns.UnitColors:Explain(shown, unit), current))
        end
    end
    local plate = ns.Driver:GetPlate("target")
    if plate then
        local function Show(value)
            if issecretvalue(value) then return "hidden" end
            return tostring(value)
        end
        print(("  Target: state %s, enemy type %s, boss %s, classification %s, level %s"):format(
            plate.state, tostring(plate.mobType), Show(UnitIsBossMob("target")), Show(UnitClassification("target")),
            Show(UnitEffectiveLevel("target"))))
    else
        print("  Target: none (target a mob to see how Plateau reads it)")
    end
end

local PROBE_LIMIT = 300
local PROBE_WATCH_HOURS = 4
local PROBE_PRIVATE = { name = true, nameUnmodified = true, guid = true, creatureID = true }

local PROBE_CALLS = {
    { "name", function(u) return UnitName(u) end },
    { "nameUnmodified", function(u) return UnitNameUnmodified(u) end },
    { "guid", function(u) return UnitGUID(u) end },
    { "creatureID", function(u) return UnitCreatureID(u) end },
    { "classification", function(u) return UnitClassification(u) end },
    { "isBoss", function(u) return UnitIsBossMob(u) end },
    { "isLieutenant", function(u) return UnitIsLieutenant(u) end },
    { "level", function(u) return UnitLevel(u) end },
    { "effectiveLevel", function(u) return UnitEffectiveLevel(u) end },
    { "health", function(u) return UnitHealth(u) end },
    { "healthMax", function(u) return UnitHealthMax(u) end },
    { "healthPercent", function(u) return UnitHealthPercent(u, false) end },
    { "reaction", function(u) return UnitReaction(u, "player") end },
    { "creatureType", function(u) return UnitCreatureType(u) end },
    { "inCombat", function(u) return UnitAffectingCombat(u) end },
    { "threat", function(u) return UnitThreatSituation("player", u) end },
    { "casting", function(u) return UnitCastingInfo(u) end },
}

local PROBE_UNITS = { "target", "focus", "mouseover", "boss1", "boss2", "boss3", "boss4", "boss5" }

local function ProbeValue(fn, unit)
    local ok, value = pcall(fn, unit)
    if not ok then
        return "error", nil
    end
    if issecretvalue(value) then
        return "hidden", nil
    end
    if value == nil then
        return "nil", nil
    end
    return "readable", tostring(value)
end

local function ProbeContext()
    local active = {}
    local states = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
    if states then
        for _, name in ipairs(RESTRICTIONS) do
            local kind = Enum.AddOnRestrictionType[name]
            if kind and states(kind) == Enum.AddOnRestrictionState.Active then
                active[#active + 1] = name
            end
        end
    end
    local inInstance, instanceType = IsInInstance()
    local secrets = C_Secrets and C_Secrets.HasSecretRestrictions and C_Secrets.HasSecretRestrictions()
    return {
        time = date("%H:%M:%S"),
        zone = GetRealZoneText(),
        instance = inInstance and instanceType or "none",
        combat = InCombatLockdown() == true,
        encounter = IsEncounterInProgress and IsEncounterInProgress() == true or false,
        restrictions = #active > 0 and table.concat(active, ",") or "none",
        secrets = secrets == true,
    }
end

local function ContextLine(context)
    return ("%s %s (%s), combat %s, encounter %s, restrictions %s, secret rules %s"):format(context.time, context.zone or "?",
        context.instance, tostring(context.combat), tostring(context.encounter), context.restrictions, tostring(context.secrets))
end

local function ProbeLog()
    local global = ns.DB.saved.global
    global.probe = global.probe or {}
    return global.probe
end

local PROBE_TRIM = 60

local function ProbeStore(entry)
    local log = ProbeLog()
    log[#log + 1] = entry
    local count = #log
    if count > PROBE_LIMIT + PROBE_TRIM then
        local drop = count - PROBE_LIMIT
        for i = 1, PROBE_LIMIT do
            log[i] = log[i + drop]
        end
        for i = PROBE_LIMIT + 1, count do
            log[i] = nil
        end
    end
end

local function ProbeUnit(unit, context, kind)
    if not UnitExists(unit) then return false end
    local entry = { kind = kind, unit = unit, context = context, results = {} }
    local readable, hidden = {}, {}
    for _, call in ipairs(PROBE_CALLS) do
        local state, value = ProbeValue(call[2], unit)
        entry.results[call[1]] = (value and not PROBE_PRIVATE[call[1]]) and (state .. ": " .. value) or state
        if state == "readable" then
            readable[#readable + 1] = call[1] .. "=" .. value
        elseif state == "hidden" then
            hidden[#hidden + 1] = call[1]
        end
    end
    ProbeStore(entry)
    return true, readable, hidden
end

local function DebugProbe()
    local context = ProbeContext()
    Say("probe: " .. ContextLine(context))
    local any = false
    for _, unit in ipairs(PROBE_UNITS) do
        local found, readable, hidden = ProbeUnit(unit, context, "manual")
        if found then
            any = true
            print(("  |cffffd200%s|r hidden: %s"):format(unit, #hidden > 0 and table.concat(hidden, ", ") or "nothing"))
            print(("    readable: %s"):format(#readable > 0 and table.concat(readable, ", ") or "nothing"))
        end
    end
    if not any then
        print("  No target, focus, mouseover or boss units. Target an enemy and run it again.")
    end
    print(("  Saved to the probe log (%d entries). /plt debug probe watch logs every enemy plate as it appears."):format(#ProbeLog()))
end

local function Shown(value)
    if issecretvalue(value) then return "hidden" end
    if type(value) == "number" then return ("%.2f"):format(value) end
    return tostring(value)
end

local function HiddenKeys(hide)
    if type(hide) ~= "table" then return "none" end
    local keys = {}
    for key, on in pairs(hide) do
        if on then keys[#keys + 1] = key end
    end
    table.sort(keys)
    return #keys > 0 and table.concat(keys, ",") or "none"
end

local function NameplateToken(unit)
    if unit:find("^nameplate") then
        return unit
    end
    local found
    ns.Driver:ForEachActive(function(plate)
        if found or not plate.unit then return end
        local ok, same = pcall(UnitIsUnit, plate.unit, unit)
        if ok and not issecretvalue(same) and same then
            found = plate.unit
        end
    end)
    return found
end

local function PlateState(unit, kind)
    if not UnitExists(unit) then return end
    local token = NameplateToken(unit)
    local base, plate
    if token then
        local ok, result = pcall(C_NamePlate.GetNamePlateForUnit, token)
        base = ok and result or nil
        plate = ns.Driver:GetPlate(token)
    end
    local state = {
        unit = token and (unit .. " = " .. token) or (unit .. " (no matching Plateau plate, or the game hides which plate it is)"),
        isBoss = Shown(UnitIsBossMob(unit)),
        classification = Shown(UnitClassification(unit)),
        claimable = Shown(ns.Driver:IsClaimable(unit)),
        base = base and ("visible %s, alpha %s, scale %s"):format(Shown(base:IsVisible()), Shown(base:GetEffectiveAlpha()), Shown(base:GetEffectiveScale())) or "none",
    }
    if plate then
        state.plate = ("active %s, shown %s, visible %s, alpha %s (applied %s, game %s, range %s, idle %s), scale %s (effective %s, ignores game fade %s), level %s band %s"):format(
            Shown(plate.active), Shown(plate:IsShown()), Shown(plate:IsVisible()), Shown(plate:GetEffectiveAlpha()),
            Shown(plate.appliedAlpha), Shown(plate.base and plate.base:GetEffectiveAlpha()), Shown(plate.rangeAlpha), Shown(plate.idleAlpha),
            Shown(plate.appliedScale), Shown(plate:GetEffectiveScale()), Shown(plate.ignoresGameFade), Shown(plate:GetFrameLevel()), Shown(plate.band))
        state.flags = ("state %s, friendly %s, player %s, type %s, target %s, casting %s, nameOnly %s, attached %s"):format(
            Shown(plate.state), Shown(plate.isFriendly), Shown(plate.isPlayer), Shown(plate.mobType), Shown(plate.isTarget),
            Shown(plate.casting), Shown(plate.nameOnly), Shown(plate:GetParent() == plate.base))
        local lines = 0
        for _, line in ipairs(plate.phaseLines or {}) do
            if line:IsShown() then lines = lines + 1 end
        end
        state.parts = ("health %s, name %s, hidden %s, simplified %s, phase lines %d"):format(
            Shown(plate.health and plate.health:IsShown()), Shown(plate.name and plate.name:IsShown()),
            HiddenKeys(plate.hidden), HiddenKeys(plate.simplifiedHidden), lines)
        state.attackable = Shown(UnitCanAttack("player", token))
        local powerType, powerToken = UnitPowerType(token)
        state.power = ("%s (%s), caster flag %s"):format(Shown(powerToken), Shown(powerType), Shown(plate.mobFlags and plate.mobFlags.caster))
        state.reaction = Shown(UnitReaction(token, "player"))
    else
        state.plate = "Plateau has no plate for this unit"
    end
    ProbeStore({ kind = kind, context = ProbeContext(), state = state })
end

local function PlateStateLater(unit, kind)
    C_Timer.After(0.5, function()
        PlateState(unit, kind)
    end)
end

local probeWatcher = CreateFrame("Frame")
probeWatcher:SetScript("OnEvent", function(_, event, unit, ...)
    if event == "ENCOUNTER_START" or event == "ENCOUNTER_END" then
        local payload = {}
        for i, value in ipairs({ unit, ... }) do
            payload[i] = issecretvalue(value) and "hidden" or tostring(value)
        end
        ProbeStore({ kind = event .. " payload", context = ProbeContext(), payload = table.concat(payload, ", ") })
    end
    if event == "NAME_PLATE_UNIT_ADDED" then
        if not UnitCanAttack("player", unit) then
            PlateStateLater(unit, "plate state (not attackable yet)")
            return
        end
        ProbeUnit(unit, ProbeContext(), "plate added")
        PlateStateLater(unit, "plate state")
    elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_END" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        local context = ProbeContext()
        ProbeStore({ kind = event, context = context })
        if event == "ENCOUNTER_START" or event == "PLAYER_REGEN_DISABLED" then
            for _, token in ipairs(PROBE_UNITS) do
                ProbeUnit(token, context, event)
            end
        end
        if event == "ENCOUNTER_START" then
            for i = 1, 5 do
                PlateStateLater("boss" .. i, "boss plate state")
            end
            for _, delay in ipairs({ 1, 5, 15 }) do
                C_Timer.After(delay, function()
                    local tokens = {}
                    ns.Driver:ForEachActive(function(plate)
                        if plate.unit then tokens[#tokens + 1] = plate.unit end
                    end)
                    for _, token in ipairs(tokens) do
                        PlateState(token, "encounter plate (" .. delay .. "s in)")
                    end
                end)
            end
        end
    end
end)

local PROBE_EVENTS = { "NAME_PLATE_UNIT_ADDED", "ENCOUNTER_START", "ENCOUNTER_END", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED" }

local function SetProbeWatch(on)
    for _, event in ipairs(PROBE_EVENTS) do
        if on then
            probeWatcher:RegisterEvent(event)
        else
            probeWatcher:UnregisterEvent(event)
        end
    end
end

local function DebugProbeWatch(arg)
    local on = arg ~= "off"
    SetProbeWatch(on)
    ns.DB.saved.global.probeWatch = on and (time() + PROBE_WATCH_HOURS * 3600) or nil
    if on then
        Say(("probe watch on: every enemy plate that appears (what the game hides, and how Plateau drew it), every pull and every boss encounter is logged. It stays on through reloads for %d hours, or until /plt debug probe watch off. Names and GUIDs are not stored. /reload to save the log and any errors."):format(PROBE_WATCH_HOURS))
    else
        Say(("probe watch off. %d entries in the log; /reload to save them."):format(#ProbeLog()))
    end
end

local probeResume = CreateFrame("Frame")
probeResume:RegisterEvent("PLAYER_LOGIN")
probeResume:SetScript("OnEvent", function()
    local global = ns.DB.saved and ns.DB.saved.global
    if not global then return end
    if global.probeVersion ~= ns.version then
        global.probe, global.probeWatch = nil, nil
        global.probeVersion = ns.version
    end
    local untilTime = global.probeWatch
    if type(untilTime) == "number" and time() < untilTime then
        SetProbeWatch(true)
        Say("probe watch is still on and logging. /plt debug probe watch off to stop.")
    else
        global.probeWatch = nil
    end
end)

local function DebugProbeClear()
    ns.DB.saved.global.probe = nil
    Say("probe log cleared.")
end

local LAYER_TICK = 0.1
local LAYER_FRONT_LEVEL = 9000
local LAYER_COLORS = { front = { 0.9, 0.15, 0.15, 0.9 }, other = { 0.2, 0.45, 0.95, 0.9 } }

local layers = { mode = nil, boxes = {}, seen = {}, ticker = nil }

local function LayerStats()
    return {
        started = date("%H:%M:%S"), mode = layers.mode, ticks = 0, plates = 0,
        baseLevelChanges = 0, baseStrataChanges = 0, baseLevelChangesInCombat = 0,
        levelChangeOnTarget = 0, boxUndone = 0, setFailures = 0, setFailuresInCombat = 0,
        secretScale = 0, strata = {}, levelMin = nil, levelMax = nil, fixedApi = false,
    }
end

local function TrySet(box, method, ...)
    local fn = box[method]
    if not fn then return false end
    local ok = pcall(fn, box, ...)
    if not ok then
        local stats = layers.stats
        stats.setFailures = stats.setFailures + 1
        if InCombatLockdown() then
            stats.setFailuresInCombat = stats.setFailuresInCombat + 1
        end
        ProbeStore({ kind = "layers set failed", method = method, combat = InCombatLockdown(), context = ProbeContext() })
    end
    return ok
end

local function LayerBox(base)
    local box = layers.boxes[base]
    if box then return box end
    box = CreateFrame("Frame", nil, base)
    box:SetSize(200, 60)
    box:SetPoint("CENTER", base, "CENTER", 0, 10)
    box.fill = box:CreateTexture(nil, "ARTWORK")
    box.fill:SetAllPoints()
    box.label = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    box.label:SetPoint("CENTER")
    layers.boxes[base] = box
    return box
end

local function PaintBox(box, front, base)
    local color = front and LAYER_COLORS.front or LAYER_COLORS.other
    box.fill:SetColorTexture(color[1], color[2], color[3], color[4])
    local baseStrata = base:GetFrameStrata()
    local baseLevel = base:GetFrameLevel()
    if issecretvalue(baseStrata) or issecretvalue(baseLevel) then
        baseStrata, baseLevel = "BACKGROUND", 1
    end
    local strata, level
    if layers.mode == "strata" then
        strata = front and "HIGH" or baseStrata
        level = baseLevel + 1
    else
        strata = baseStrata
        level = front and LAYER_FRONT_LEVEL or baseLevel + 1
    end
    if box.wantStrata and (box:GetFrameStrata() ~= box.wantStrata or box:GetFrameLevel() ~= box.wantLevel) then
        layers.stats.boxUndone = layers.stats.boxUndone + 1
        ProbeStore({ kind = "layers box undone", want = box.wantStrata .. " " .. box.wantLevel, got = box:GetFrameStrata() .. " " .. box:GetFrameLevel(), combat = InCombatLockdown() })
    end
    if box.wantStrata ~= strata or box.wantLevel ~= level then
        TrySet(box, "SetFixedFrameStrata", false)
        TrySet(box, "SetFixedFrameLevel", false)
        TrySet(box, "SetFrameStrata", strata)
        TrySet(box, "SetFrameLevel", level)
        TrySet(box, "SetFixedFrameStrata", true)
        TrySet(box, "SetFixedFrameLevel", true)
    end
    box.wantStrata, box.wantLevel = box:GetFrameStrata(), box:GetFrameLevel()
    box.label:SetText(("%s  %s %d"):format(front and "TARGET" or "other", box.wantStrata, box.wantLevel))
    box:Show()
end

local function LayerTick(targetChanged)
    local stats = layers.stats
    stats.ticks = stats.ticks + 1
    local targetBase = C_NamePlate.GetNamePlateForUnit("target")
    local active = {}
    local plates = C_NamePlate.GetNamePlates() or {}
    if #plates > stats.plates then
        stats.plates = #plates
    end
    for _, base in ipairs(plates) do
        active[base] = true
        local level, strata = base:GetFrameLevel(), base:GetFrameStrata()
        if issecretvalue(level) or issecretvalue(strata) then
            stats.secretLevel = (stats.secretLevel or 0) + 1
            level, strata = 0, "secret"
        end
        stats.strata[strata] = true
        stats.levelMin = math.min(stats.levelMin or level, level)
        stats.levelMax = math.max(stats.levelMax or level, level)
        local scale = base:GetEffectiveScale()
        if issecretvalue(scale) then
            stats.secretScale = stats.secretScale + 1
        end
        local last = layers.seen[base]
        if last then
            if last.level ~= level then
                stats.baseLevelChanges = stats.baseLevelChanges + 1
                if InCombatLockdown() then
                    stats.baseLevelChangesInCombat = stats.baseLevelChangesInCombat + 1
                end
                if targetChanged then
                    stats.levelChangeOnTarget = stats.levelChangeOnTarget + 1
                end
                ProbeStore({ kind = "layers base level", from = last.level, to = level, target = base == targetBase, combat = InCombatLockdown(), targetChanged = targetChanged == true })
            end
            if last.strata ~= strata then
                stats.baseStrataChanges = stats.baseStrataChanges + 1
                ProbeStore({ kind = "layers base strata", from = last.strata, to = strata, target = base == targetBase, combat = InCombatLockdown() })
            end
        end
        layers.seen[base] = { level = level, strata = strata }
        PaintBox(LayerBox(base), base == targetBase, base)
    end
    for base, box in pairs(layers.boxes) do
        if not active[base] then
            box:Hide()
            box.wantStrata, box.wantLevel = nil, nil
            layers.seen[base] = nil
        end
    end
end

local layerEvents = CreateFrame("Frame")
layerEvents:SetScript("OnEvent", function()
    if layers.mode then
        LayerTick(true)
    end
end)

local function LayerSummary(stats)
    local strata = {}
    for name in pairs(stats.strata) do
        strata[#strata + 1] = name
    end
    table.sort(strata)
    Say(("layers test (%s mode) results:"):format(stats.mode))
    print(("  most plates at once: %d, checks: %d"):format(stats.plates, stats.ticks))
    print(("  Blizzard plate strata seen: %s, levels %s to %s"):format(#strata > 0 and table.concat(strata, ", ") or "none", tostring(stats.levelMin), tostring(stats.levelMax)))
    print(("  Blizzard plate level changes: %d (%d in combat, %d right after a target change), strata changes: %d"):format(stats.baseLevelChanges, stats.baseLevelChangesInCombat, stats.levelChangeOnTarget, stats.baseStrataChanges))
    print(("  test boxes undone by the game: %d, refused changes: %d (%d in combat), secret scale reads: %d, secret level reads: %d"):format(stats.boxUndone, stats.setFailures, stats.setFailuresInCombat, stats.secretScale, stats.secretLevel or 0))
    print("  Most important: did the red box draw over the blue boxes where they overlapped? Note yes or no for each mode.")
end

local function StopLayers()
    if layers.ticker then
        layers.ticker:Cancel()
        layers.ticker = nil
    end
    layerEvents:UnregisterAllEvents()
    for _, box in pairs(layers.boxes) do
        box:Hide()
        box.wantStrata, box.wantLevel = nil, nil
    end
    wipe(layers.seen)
    if layers.stats then
        ProbeStore({ kind = "layers summary", stats = layers.stats, context = ProbeContext() })
        LayerSummary(layers.stats)
    end
    layers.mode, layers.stats = nil, nil
end

local function DebugLayers(arg)
    if arg == "off" then
        if not layers.mode then
            Say("the layers test isn't running.")
            return
        end
        StopLayers()
        Say("layers test stopped. /reload to save the log.")
        return
    end
    local mode = arg == "level" and "level" or "strata"
    if layers.mode then
        StopLayers()
    end
    layers.mode = mode
    layers.stats = LayerStats()
    layers.stats.fixedApi = UIParent.SetFixedFrameStrata ~= nil
    layerEvents:RegisterEvent("PLAYER_TARGET_CHANGED")
    layerEvents:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    layers.ticker = C_Timer.NewTicker(LAYER_TICK, function() LayerTick(false) end)
    LayerTick(false)
    if mode == "strata" then
        Say("layers test on (strata mode): your target's box is red and set to HIGH strata; every other plate's box is blue in Blizzard's strata.")
    else
        Say("layers test on (level mode): every box stays in Blizzard's strata; your target's red box gets frame level 9000, the blue boxes sit just above their own plate.")
    end
    print("  Stand near a pack so plates overlap, target one in the middle, and check whether the red box covers the blue boxes next to it. Retarget, move and pull a few times.")
    print("  /plt debug layers level and /plt debug layers strata switch modes; /plt debug layers off stops and prints the results.")
end

local CONFLICTS = {
    { name = "Platynator", title = "Platynator" },
    { name = "Plater", title = "Plater" },
    { name = "Kui_Nameplates", title = "KuiNameplates" },
    { name = "TidyPlates_ThreatPlates", title = "Threat Plates" },
    { name = "TidyPlates", title = "TidyPlates" },
    { name = "NeatPlates", title = "NeatPlates" },
    { name = "BetterBlizzPlates", title = "BetterBlizzPlates" },
    { name = "EllesmereUINameplates", title = "EllesmereUI Nameplates" },
}

local function ElvUINameplates()
    local engine = C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI and ElvUI[1]
    local private = engine and engine.private
    return private and private.nameplates and private.nameplates.enable == true and engine or nil
end

function ns.FindConflicts()
    local found = {}
    for _, entry in ipairs(CONFLICTS) do
        if C_AddOns.IsAddOnLoaded(entry.name) then
            found[#found + 1] = entry
        end
    end
    if ElvUINameplates() then
        found[#found + 1] = { name = "ElvUI", title = "ElvUI nameplates", elvui = true }
    end
    return found
end

function ns.ResolveConflict(entry)
    if entry.elvui then
        local engine = ElvUINameplates()
        if engine then
            engine.private.nameplates.enable = false
        end
    else
        C_AddOns.DisableAddOn(entry.name)
    end
end

local function OpenConflicts(onDone)
    local ignored = ns.DB.saved.global.conflictsIgnored or {}
    local pending = {}
    for _, entry in ipairs(ns.FindConflicts()) do
        if not ignored[entry.name] then
            pending[#pending + 1] = entry
        end
    end
    if #pending == 0 or InCombatLockdown() then
        return false
    end
    local loaded = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauConflicts and PlateauConflicts.Open then
        PlateauConflicts:Open(pending, onDone)
        return true
    end
    return false
end

local setupWatcher = CreateFrame("Frame")

local function OpenSetup()
    if InCombatLockdown() then
        setupWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    setupWatcher:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauSetup and PlateauSetup.Open then
        PlateauSetup:Open()
    elseif not loaded then
        Say("could not open setup: " .. tostring(reason))
    end
end

local NEW_USER_CVARS = { UnitNameNonCombatCreatureName = "1" }

local function ApplyNewUserDefaults()
    local global = ns.DB.saved.global
    if global.setupDone or global.newUserDefaults then return end
    global.newUserDefaults = true
    for name, value in pairs(NEW_USER_CVARS) do
        if C_CVar.GetCVar(name) ~= nil then
            ns.CVars:Set(name, value)
        end
    end
end

setupWatcher:RegisterEvent("PLAYER_LOGIN")
setupWatcher:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        ApplyNewUserDefaults()
        C_Timer.After(3, function()
            local function Next()
                if not ns.DB.saved.global.setupDone then
                    OpenSetup()
                end
            end
            if not OpenConflicts(Next) then
                Next()
            end
        end)
    else
        OpenSetup()
    end
end)

local function Help()
    Say("commands:")
    print("  /plt - open the settings")
    print("  /plt setup - the first-time walkthrough")
    print("  /plt minimap - show or hide the minimap button")
    print("  /plt debug - version, restrictions and memory, for bug reports")
    print("  /plt debug reset - start counting slow frames from now")
    print("  /plt debug probe - what the game hides about your target, focus, mouseover and bosses right now")
    print("  /plt debug probe watch [off] - log every enemy plate, pull and boss encounter; /plt debug probe clear empties the log")
    print("  /plt debug layers [level|off] - test whether a plate can draw in front of its neighbours (red box = target)")
    print("  /plt reset - put every setting in this profile back to its default")
    print("  /plt cvars restore - undo every game nameplate setting Plateau changed")
end

local function OpenOptions()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauOptions and PlateauOptions.Toggle then
        PlateauOptions:Toggle()
    elseif loaded then
        Say("options didn't finish loading - check BugSack for the first error.")
    else
        Say("could not open options: " .. tostring(reason))
    end
end
ns.OpenOptions = OpenOptions

local function BuildFlatLook(button)
    local defaults = {}
    for i = 1, select("#", button:GetRegions()) do
        local region = select(i, button:GetRegions())
        if region:IsObjectType("Texture") then
            defaults[#defaults + 1] = region
        end
    end
    local flat = {}
    local fill = button:CreateTexture(nil, "BACKGROUND", nil, -6)
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMRIGHT", -2, 2)
    fill:SetColorTexture(0.1, 0.1, 0.1, 0.8)
    flat[#flat + 1] = fill
    local function Edge(from, to, width, height)
        local edge = button:CreateTexture(nil, "OVERLAY", nil, 7)
        edge:SetColorTexture(1, 1, 1, 0.14)
        edge:SetPoint(from, fill, from)
        edge:SetPoint(to, fill, to)
        if width then
            edge:SetWidth(width)
        end
        if height then
            edge:SetHeight(height)
        end
        flat[#flat + 1] = edge
    end
    Edge("TOPLEFT", "TOPRIGHT", nil, 1)
    Edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 1)
    Edge("TOPLEFT", "BOTTOMLEFT", 1, nil)
    Edge("TOPRIGHT", "BOTTOMRIGHT", 1, nil)
    local hover = button:CreateTexture(nil, "HIGHLIGHT")
    hover:SetPoint("TOPLEFT", fill, "TOPLEFT")
    hover:SetPoint("BOTTOMRIGHT", fill, "BOTTOMRIGHT")
    hover:SetColorTexture(1, 1, 1, 0.08)
    return function(useFlat)
        for _, region in ipairs(defaults) do
            region:SetAlpha(useFlat and 0 or 1)
        end
        for _, region in ipairs(flat) do
            region:SetShown(useFlat)
        end
    end
end

local function MenuButton(text)
    for candidate in GameMenuFrame.buttonPool:EnumerateActive() do
        if candidate:GetText() == text then
            return candidate
        end
    end
end

local function ShiftDown(belowTop, amount)
    for candidate in GameMenuFrame.buttonPool:EnumerateActive() do
        local candidateTop = candidate:GetTop()
        if candidateTop and candidateTop <= belowTop + 2 then
            local p, rel, rp, cx, cy = candidate:GetPoint(1)
            if p then
                candidate:ClearAllPoints()
                candidate:SetPoint(p, rel, rp, cx, (cy or 0) - amount)
            end
        end
    end
end

local function HookGameMenu()
    local button = CreateFrame("Button", "PlateauGameMenuButton", GameMenuFrame, "MainMenuFrameButtonTemplate")
    local SetFlat = BuildFlatLook(button)
    button:SetText(ns.Brand:Text("Plateau"))
    ns.Brand:OnChange(function()
        if button:IsShown() then
            button:SetText(ns.Brand:Text("Plateau"))
        end
    end)
    local fontString = button:GetFontString()
    if fontString then
        local path, size, flags = fontString:GetFont()
        if path then
            fontString:SetFont(path, size - 2, flags)
        end
    end
    button:SetScript("OnClick", function()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
        HideUIPanel(GameMenuFrame)
        OpenOptions()
    end)
    button:Hide()

    local pending = false
    local function Place()
        pending = false
        if InCombatLockdown() or not GameMenuFrame:IsShown() or ns.DB.saved.global.hideMenuButton then
            button:Hide()
            return
        end
        local addOns = MenuButton(ADDONS)
        if not (addOns and addOns:GetTop()) then
            button:Hide()
            return
        end
        local width, height = addOns:GetSize()
        local extra = height + 4
        SetFlat(addOns.Left ~= nil and addOns.Left:GetAlpha() == 0)
        button:SetSize(width, height)
        button:ClearAllPoints()
        local point, relative, relativePoint, x, y = addOns:GetPoint(1)
        if not point then
            button:Hide()
            return
        end
        ShiftDown(addOns:GetTop(), extra)
        button:SetPoint(point, relative, relativePoint, x, y)
        button:SetText(ns.Brand:Text("Plateau"))
        button:Show()
        GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + extra)
    end

    hooksecurefunc(GameMenuFrame, "Layout", function()
        button:Hide()
        if not pending then
            pending = true
            C_Timer.After(0, Place)
        end
    end)
end

if GameMenuFrame and GameMenuFrame.buttonPool then
    HookGameMenu()
else
    EventUtil.ContinueOnAddOnLoaded("Blizzard_GameMenu", function()
        if GameMenuFrame and GameMenuFrame.buttonPool then
            HookGameMenu()
        end
    end)
end

local resetFrame = CreateFrame("Frame")
resetFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
resetFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    C_Timer.After(2, ns.ResetPerformanceCounts)
end)

SLASH_PLATEAU1 = "/plateau"
SLASH_PLATEAU2 = "/plt"
SlashCmdList.PLATEAU = function(input)
    local words = {}
    for word in input:gmatch("%S+") do
        words[#words + 1] = word
    end
    local command, path = words[1], words[2]

    if not command then
        OpenOptions()
    elseif command == "setup" then
        OpenSetup()
    elseif command == "minimap" and ns.Minimap then
        local shown = not ns.Minimap:IsShown()
        ns.Minimap:SetShown(shown)
        Say(shown and "minimap button shown." or "minimap button hidden. /plt minimap brings it back.")
    elseif command == "debug" and path == "reset" then
        ns.ResetPerformanceCounts()
        Say("slow-frame counts reset. Run /plt debug later to see how many happened since.")
    elseif command == "debug" and path == "layers" then
        DebugLayers(words[3])
    elseif command == "debug" and path == "probe" and words[3] == "watch" then
        DebugProbeWatch(words[4])
    elseif command == "debug" and path == "probe" and words[3] == "clear" then
        DebugProbeClear()
    elseif command == "debug" and path == "probe" then
        DebugProbe()
    elseif command == "debug" then
        Debug()
    elseif command == "cvars" and path == "restore" then
        ns.CVars:ReleaseAll()
        Say("put every nameplate game setting back the way it was before Plateau changed it.")
    elseif command == "reset" then
        local ok, reason = ns.DB:Reset(path)
        Say(ok and ("reset " .. (path or "all settings")) or (path .. ": " .. reason))
    else
        Help()
    end
end

Plateau = {
    DB = ns.DB,
    defaults = ns.defaults,
    version = ns.version,
    flavor = ns.flavor,
    overlayPatterns = ns.overlayPatterns,
    barTextures = ns.barTextures,
    CVars = ns.CVars,
    presets = ns.presets,
    brand = ns.brand,
    CpuReadout = function()
        return ns.CpuReadout()
    end,
    MemoryReadout = function()
        return ns.MemoryReadout()
    end,
    PerformanceLines = function()
        return ns.PerformanceLines()
    end,
    ResetPerformanceCounts = function()
        ns.ResetPerformanceCounts()
    end,
    Brand = ns.Brand,
    Builtins = ns.Builtins,
    AutoProfile = ns.AutoProfile,
    CONTENT_TYPES = ns.CONTENT_TYPES,
    arrowStyles = ns.arrowStyles,
    iconPositions = ns.iconPositions,
    textPositions = ns.textPositions,
    AuraPlacement = function(db)
        return ns.AuraPlacement(db)
    end,
    media = ns.media,
    PresetLook = function(preset)
        return ns.PresetLook(preset)
    end,
    SetSampleLook = function(name, look)
        ns.Driver:SetSampleLook(name, look)
    end,
    CreatePreview = function(parent, state, sample)
        return ns.Driver:CreatePreview(parent, state, sample)
    end,
    SetPreviewState = function(plate, state)
        ns.Driver:SetPreviewState(plate, state)
    end,
    RefreshDirtyPreviews = function()
        ns.Driver:RefreshDirtyPreviews()
    end,
    FindConflicts = function()
        return ns.FindConflicts()
    end,
    ResolveConflict = function(entry)
        ns.ResolveConflict(entry)
    end,
    DisableSelf = function()
        C_AddOns.DisableAddOn("Plateau_Options")
        C_AddOns.DisableAddOn("Plateau")
    end,
    IgnoreConflict = function(name)
        local global = ns.DB.saved.global
        global.conflictsIgnored = global.conflictsIgnored or {}
        global.conflictsIgnored[name] = true
    end,
    InterruptSpell = function()
        return ns.InterruptReady:GetSpellID()
    end,
    OpenSetup = function()
        OpenSetup()
    end,
    CurrentSpec = function()
        return ns.CurrentSpec()
    end,
    SetClickAreas = function(preview, world)
        ns.Driver:SetClickAreas(preview, world)
    end,
    SetStackBoxes = function(on)
        ns.Driver:SetStackBoxes(on)
    end,
    OnRestyle = function(callback)
        ns.Driver:OnRestyle(callback)
    end,
    GetPlate = function(unit)
        return ns.Driver:GetPlate(unit)
    end,
}

Plateau.callbacks = LibStub("CallbackHandler-1.0"):New(Plateau)

function ns.Fire(event, ...)
    Plateau.callbacks:Fire(event, ...)
end
