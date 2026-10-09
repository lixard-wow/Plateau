local _, ns = ...

local L = ns.L

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
    if ns.Driver and ns.Driver.ResetClaimTime then ns.Driver:ResetClaimTime() end
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
            lines[#lines + 1] = L["Recent CPU time: %.2f ms per frame"]:format(recent)
            lines[#lines + 1] = L["Session average CPU time: %.2f ms per frame"]:format(session or 0)
            lines[#lines + 1] = L["Peak CPU time: %.1f ms (worst frame)"]:format(peak or 0)
            local ok, all = pcall(profiler.GetOverallMetric, metrics.RecentAverageTime)
            if ok and type(all) == "number" and not issecretvalue(all) and all > 0 then
                lines[#lines + 1] = L["Share of addon CPU time: %.1f%%"]:format(recent / all * 100)
            end
        end
        local over5, over10, over50 = SlowCounts()
        if over5 then
            if baseline then
                lines[#lines + 1] = L["Slow frames since reset: over 5 ms %d, over 10 ms %d, over 50 ms %d"]:format(
                    over5 - baseline[1], over10 - baseline[2], over50 - baseline[3])
            end
            lines[#lines + 1] = L["Slow frames this session: over 5 ms %d, over 10 ms %d, over 50 ms %d"]:format(over5, over10, over50)
        end
    else
        lines[#lines + 1] = L["CPU numbers aren't available: the game's addon profiler is off or missing."]
    end
    local megabytes = ns.MemoryReadout()
    if megabytes then
        lines[#lines + 1] = L["Memory usage: %.1f MB"]:format(megabytes)
    end
    local total, claimed = ns.Driver:CountActive()
    if ns.auraButtons then
        lines[#lines + 1] = L["Aura buttons built: %d (%d of them in combat)"]:format(ns.auraButtons.built, ns.auraButtons.combat)
    end
    if ns.Driver.PoolStats then
        local builtTotal, attached, spare, on, all = ns.Driver:PoolStats()
        lines[#lines + 1] = L["Plates built: %d (%d on game nameplates, %d spare); elements on: %d of %d"]:format(builtTotal, attached, spare, on, all)
        if ns.Driver.BuildTime then
            local count, average, slowest, parts = ns.Driver:BuildTime()
            if count > 0 then
                lines[#lines + 1] = L["Time to build one plate: %.1f ms on average, %.1f ms slowest"]:format(average, slowest)
                local top = {}
                for i = 1, math.min(3, #parts) do
                    top[#top + 1] = ("%s %.1f ms"):format(parts[i].key, parts[i].ms)
                end
                if #top > 0 then
                    lines[#lines + 1] = L["Slowest parts to build: %s"]:format(table.concat(top, ", "))
                end
            end
        end
        if ns.Driver.ClaimTime then
            local count, average, slowest, restyles, over1, worstFrame, parts, swapped, versionRestyles = ns.Driver:ClaimTime()
            if count > 0 then
                lines[#lines + 1] = L["Time to set up a plate for a new unit: %.3f ms on average, %.2f ms slowest (%d set-ups, %d needed a full restyle, %d avoided one by swapping in a ready spare)"]:format(average, slowest, count, restyles, swapped or 0)
                lines[#lines + 1] = L["Frames where set-ups took over 1 ms: %d (worst frame %.2f ms)"]:format(over1, worstFrame)
                lines[#lines + 1] = L["Why set-ups restyled: %d because Plateau restyled all plates since, %d because the plate last showed the other kind of unit"]:format(versionRestyles or 0, restyles - (versionRestyles or 0))
                local top = {}
                for i = 1, math.min(5, #parts) do
                    top[#top + 1] = ("%s %.3f ms"):format(parts[i].key, parts[i].ms)
                end
                if #top > 0 then
                    lines[#lines + 1] = L["Slowest set-up steps (average per set-up): %s"]:format(table.concat(top, ", "))
                end
            end
        end
        if ns.Driver.RestyleReasons then
            local reasons = {}
            for key, n in pairs(ns.Driver:RestyleReasons()) do
                reasons[#reasons + 1] = ("%s %d"):format(key, n)
            end
            table.sort(reasons)
            lines[#lines + 1] = L["Full restyles of all plates, by reason: %s"]:format(#reasons > 0 and table.concat(reasons, ", ") or L["none"])
        end
    end
    lines[#lines + 1] = L["Visible nameplates: %d"]:format(total)
    lines[#lines + 1] = L["Nameplates styled by Plateau: %d"]:format(claimed)
    return lines
end

local RESTRICTIONS = { "Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map" }
local lastEventCount, lastEventTime

local function Debug()
    local total, claimed = ns.Driver:CountActive()
    Say(L["%s (%s), profile %s"]:format(ns.version, ns.flavor, ns.DB.profileName))
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
    print("  " .. L["Restrictions active: %s"]:format(#active > 0 and table.concat(active, ", ") or L["none"]))
    print("  " .. L["Plates: %d showing, %d drawn by Plateau"]:format(total, claimed))
    if ns.realmPurgeFailed then
        print("  " .. L["Realm marker cleanup didn't finish: Blizzard's friendly plates may show errors. Report this with your BugSack log."])
    end
    local failures = ns.DB.migrationFailures
    if ns.recovered or (failures and #failures > 0) then
        print("  " .. L["Saved settings: %s"]:format(ns.recovered and L["recovered from damage (%s)"]:format(tostring(ns.recovered)) or L["upgrade problems: %s"]:format(table.concat(failures, "; "))))
    end
    local now = GetTime()
    if lastEventTime and now > lastEventTime then
        print("  " .. L["Plate events: %.1f per second since the last /plt debug"]:format((ns.Driver.eventCount - lastEventCount) / (now - lastEventTime)))
    else
        print("  " .. L["Plate events: run /plt debug again in a few seconds for a rate"])
    end
    lastEventCount, lastEventTime = ns.Driver.eventCount, now
    for _, line in ipairs(ns.PerformanceLines()) do
        print("  " .. line)
    end
    if ns.BossPhaseStatus then
        local encounter, problem = ns.BossPhaseStatus()
        if problem then
            print("  " .. L["Boss phase lines: encounter %s, last problem: %s"]:format(tostring(encounter or L["none"]), tostring(problem)))
        else
            print("  " .. L["Boss phase lines: encounter %s"]:format(tostring(encounter or L["none"])))
        end
    end
    local kickID = ns.InterruptReady:GetSpellID()
    print("  " .. L["Cast timer: %s. Interrupt: %s"]:format(ns.castTimerPath, kickID and (C_Spell.GetSpellName(kickID) or kickID) or L["none found"]))
    for _, unit in ipairs({ "target", "focus" }) do
        local shown = ns.Driver:GetPlate(unit)
        if shown then
            local look = ns.DB.views.enemy
            local override = (shown.isTarget and look.target.colorBar and L["Target page: Use custom target color"])
                or (shown.isFocus and look.focus.colorBar and L["Focus page: Use custom focus color"])
            local r, g, b = shown.health:GetStatusBarColor()
            local current = (not issecretvalue(r) and r) and ("%.2f %.2f %.2f"):format(r, g, b) or L["hidden"]
            print("  " .. (unit == "target" and L["Target color: %s  [bar now %s]"] or L["Focus color: %s  [bar now %s]"]):format(
                override or ns.UnitColors:Explain(shown, unit), current))
        end
    end
    local plate = ns.Driver:GetPlate("target")
    if plate then
        local function Show(value)
            if issecretvalue(value) then return L["hidden"] end
            return tostring(value)
        end
        print("  " .. L["Target: state %s, enemy type %s, boss %s, classification %s, level %s"]:format(
            plate.state, tostring(plate.mobType), Show(UnitIsBossMob("target")), Show(UnitClassification("target")),
            Show(UnitEffectiveLevel("target"))))
    else
        print("  " .. L["Target: none (target a mob to see how Plateau reads it)"])
    end
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
    ns.WarmThemeFonts()
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
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauSetup and PlateauSetup.Open then
        PlateauSetup:Open()
    elseif not loaded then
        Say(L["could not open setup: %s"]:format(tostring(reason)))
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
    Say(L["commands:"])
    print("  " .. L["/plt - open the settings"])
    print("  " .. L["/plt setup - pick a ready-made look"])
    print("  " .. L["/plt minimap - show or hide the minimap button"])
    print("  " .. L["/plt debug - version, restrictions and memory, for bug reports"])
    print("  " .. L["/plt debug reset - start counting slow frames from now"])
    print("  " .. L["/plt reset - put every setting in this profile back to its default"])
    print("  " .. L["/plt cvars restore - undo every game nameplate setting Plateau changed"])
end

local function OpenOptions()
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauOptions and PlateauOptions.Toggle then
        PlateauOptions:Toggle()
    elseif loaded then
        Say(L["options didn't finish loading - check BugSack for the first error."])
    else
        Say(L["could not open options: %s"]:format(tostring(reason)))
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
        Say(shown and L["minimap button shown."] or L["minimap button hidden. /plt minimap brings it back."])
    elseif command == "debug" and path == "reset" then
        ns.ResetPerformanceCounts()
        Say(L["slow-frame counts reset. Run /plt debug later to see how many happened since."])
    elseif command == "debug" then
        Debug()
    elseif command == "cvars" and path == "restore" then
        ns.CVars:ReleaseAll()
        Say(L["put every nameplate game setting back the way it was before Plateau changed it."])
    elseif command == "reset" then
        local ok, reason = ns.DB:Reset(path)
        Say(ok and (path and L["reset %s"]:format(path) or L["reset all settings"]) or (path .. ": " .. reason))
    else
        Help()
    end
end

Plateau = {
    L = ns.L,
    T = ns.T,
    SetPseudoLocale = function(on)
        ns.DB.saved.global.pseudoLocale = on == true or nil
        ns.SetPseudoLocale(on)
    end,
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
