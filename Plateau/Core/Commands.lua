local _, ns = ...

local PREFIX = "|cff7fb2e5Plateau|r "

local function Say(message)
    print(PREFIX .. message)
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
    local now = GetTime()
    if lastEventTime and now > lastEventTime then
        print(("  Plate events: %.1f per second since the last /pl debug"):format((ns.Driver.eventCount - lastEventCount) / (now - lastEventTime)))
    else
        print("  Plate events: run /pl debug again in a few seconds for a rate")
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

local PROBE_LIMIT = 1500

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

local function ProbeStore(entry)
    local log = ProbeLog()
    log[#log + 1] = entry
    while #log > PROBE_LIMIT do
        table.remove(log, 1)
    end
end

local function ProbeUnit(unit, context, kind)
    if not UnitExists(unit) then return false end
    local entry = { kind = kind, unit = unit, context = context, results = {} }
    local readable, hidden = {}, {}
    for _, call in ipairs(PROBE_CALLS) do
        local state, value = ProbeValue(call[2], unit)
        entry.results[call[1]] = value and (state .. ": " .. value) or state
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
    print(("  Saved to the probe log (%d entries). /pl debug probe watch logs every enemy plate as it appears."):format(#ProbeLog()))
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
        state.plate = ("active %s, shown %s, visible %s, alpha %s (applied %s, game %s, range %s, idle %s), scale %s (distance %s, reference %s), level %s band %s"):format(
            Shown(plate.active), Shown(plate:IsShown()), Shown(plate:IsVisible()), Shown(plate:GetEffectiveAlpha()),
            Shown(plate.appliedAlpha), Shown(plate.baseAlpha), Shown(plate.rangeAlpha), Shown(plate.idleAlpha),
            Shown(plate.appliedScale), Shown(plate.distanceFactor), Shown(ns.Scaling:Reference()), Shown(plate.appliedLevel), Shown(plate.band))
        state.flags = ("state %s, friendly %s, player %s, type %s, target %s, casting %s, nameOnly %s, appearing %s"):format(
            Shown(plate.state), Shown(plate.isFriendly), Shown(plate.isPlayer), Shown(plate.mobType), Shown(plate.isTarget),
            Shown(plate.casting), Shown(plate.nameOnly), Shown(plate.appearing))
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
    ns.DB.saved.global.probeWatch = on or nil
    if on then
        Say("probe watch on: every enemy plate that appears (what the game hides, and how Plateau drew it), every pull and every boss encounter is logged. It stays on through reloads and logouts until /pl debug probe watch off. /reload to save the log and any errors.")
    else
        Say(("probe watch off. %d entries in the log; /reload to save them."):format(#ProbeLog()))
    end
end

local probeResume = CreateFrame("Frame")
probeResume:RegisterEvent("PLAYER_LOGIN")
probeResume:SetScript("OnEvent", function()
    if ns.DB.saved and ns.DB.saved.global.probeWatch then
        SetProbeWatch(true)
        Say("probe watch is still on and logging. /pl debug probe watch off to stop.")
    end
end)

local function DebugProbeClear()
    ns.DB.saved.global.probe = nil
    Say("probe log cleared.")
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
    print("  /pl - open the settings")
    print("  /pl setup - the first-time walkthrough")
    print("  /pl minimap - show or hide the minimap button")
    print("  /pl debug - version, restrictions and memory, for bug reports")
    print("  /pl debug reset - start counting slow frames from now")
    print("  /pl debug probe - what the game hides about your target, focus, mouseover and bosses right now")
    print("  /pl debug probe watch [off] - log every enemy plate, pull and boss encounter; /pl debug probe clear empties the log")
    print("  /pl reset - put every setting in this profile back to its default")
    print("  /pl cvars restore - undo every game nameplate setting Plateau changed")
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
    button:SetText(ns.GradientText("Plateau"))
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
SLASH_PLATEAU2 = "/pl"
SLASH_PLATEAU3 = "/sl"
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
        Say(shown and "minimap button shown." or "minimap button hidden. /pl minimap brings it back.")
    elseif command == "debug" and path == "reset" then
        ns.ResetPerformanceCounts()
        Say("slow-frame counts reset. Run /pl debug later to see how many happened since.")
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
    GradientText = ns.GradientText,
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
