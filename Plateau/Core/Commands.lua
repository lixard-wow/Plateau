local _, ns = ...

local L = ns.L

local function Say(message)
    print(ns.Brand:Text("Plateau") .. " " .. message)
end

local RESTRICTIONS = { "Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map" }

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
        print("  " .. L["Realm marker cleanup failed. Blizzard's friendly nameplates may show errors."])
    end
    local failures = ns.DB.migrationFailures
    if ns.recovered or (failures and #failures > 0) then
        print("  " .. L["Saved settings: %s"]:format(ns.recovered and L["recovered from damage (%s)"]:format(tostring(ns.recovered)) or L["upgrade problems: %s"]:format(table.concat(failures, "; "))))
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
    print("  " .. L["Interrupt: %s"]:format(kickID and (C_Spell.GetSpellName(kickID) or kickID) or L["none found"]))
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
        local family = plate.name:GetFontObject()
        print("  " .. L["Name font: %s, font family %s, font families allowed %s, problem %s"]:format(
            tostring((plate.name:GetFont())), tostring(family and family:GetName()), tostring(CreateFontFamily ~= nil),
            tostring(ns.fontFamilyProblem or L["none"])))
    else
        print("  " .. L["Target: none"])
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
        Say(L["Couldn't open setup: %s"]:format(tostring(reason)))
    end
end

local function OpenLocalePicker()
    if InCombatLockdown() then
        Say(L["The translation check opens out of combat."])
        return
    end
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauLocalePicker and PlateauLocalePicker.Open then
        PlateauLocalePicker:Open()
    elseif not loaded then
        Say(L["Couldn't open the translation check: %s"]:format(tostring(reason)))
    end
end

local whatsNewWatcher = CreateFrame("Frame")
local pendingSince

local function OpenWhatsNew(since)
    if InCombatLockdown() then
        pendingSince = since or false
        whatsNewWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauWhatsNew and PlateauWhatsNew.Open then
        PlateauWhatsNew:Open(since)
    elseif not loaded then
        Say(L["Couldn't open what's new: %s"]:format(tostring(reason)))
    end
end

whatsNewWatcher:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    local since = pendingSince
    pendingSince = nil
    OpenWhatsNew(since or nil)
end)

local function CheckWhatsNew()
    local global = ns.DB.saved.global
    local seen = global.lastSeenVersion
    if seen == ns.version or ns.version == "dev" then return end
    if global.whatsNewOff then
        global.lastSeenVersion = ns.version
        return
    end
    OpenWhatsNew(seen or "latest")
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
    if ns.disabled then return end
    if event == "PLAYER_LOGIN" then
        ApplyNewUserDefaults()
        C_Timer.After(3, function()
            local function Next()
                if not ns.DB.saved.global.setupDone or ns.DB.newCharacter then
                    ns.DB.saved.global.lastSeenVersion = ns.version
                    OpenSetup()
                else
                    CheckWhatsNew()
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
    Say(L["Commands:"])
    print("  " .. L["/plt - open the settings"])
    print("  " .. L["/plt setup - pick a ready-made look"])
    print("  " .. L["/plt whatsnew - show the changes in each version"])
    print("  " .. L["/plt minimap - show or hide the minimap button"])
    print("  " .. L["/plt debug - version, profile and target details for bug reports"])
    print("  " .. L["/plt debug locale - preview a translation, or show translatable text in [[brackets]]"])
    print("  " .. L["/plt reset - reset the active profile"])
    print("  " .. L["/plt cvars restore - undo every game nameplate setting Plateau changed"])
end

local function OpenOptions()
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    if loaded and PlateauOptions and PlateauOptions.Toggle then
        PlateauOptions:Toggle()
    elseif loaded then
        Say(L["Settings failed to load. Check the first Lua error."])
    else
        Say(L["Couldn't open settings: %s"]:format(tostring(reason)))
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

SLASH_PLATEAU1 = "/plateau"
SLASH_PLATEAU2 = "/plt"
SlashCmdList.PLATEAU = function(input)
    if ns.disabled then
        print("|cffff5555" .. ns.L["Plateau couldn't start:"] .. "|r " .. ns.disabled)
        return
    end
    local words = {}
    for word in input:gmatch("%S+") do
        words[#words + 1] = word
    end
    local command, path = words[1], words[2]

    if not command then
        OpenOptions()
    elseif command == "setup" then
        OpenSetup()
    elseif command == "whatsnew" or command == "changelog" then
        OpenWhatsNew(nil)
    elseif command == "minimap" and ns.Minimap then
        local shown = not ns.Minimap:IsShown()
        ns.Minimap:SetShown(shown)
        Say(shown and L["Minimap button shown."] or L["Minimap button hidden. Type /plt minimap to show it."])
    elseif command == "debug" and path == "locale" then
        OpenLocalePicker()
    elseif command == "debug" then
        Debug()
    elseif command == "cvars" and path == "restore" then
        ns.CVars:ReleaseAll()
        Say(L["Blizzard nameplate settings restored."])
    elseif command == "reset" then
        local ok, reason = ns.DB:Reset(path)
        Say(ok and (path and L["%s reset to default."]:format(path) or L["All settings reset to default."]) or (path .. ": " .. reason))
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
    IsPseudoLocale = function()
        return ns.IsPseudoLocale()
    end,
    LANGUAGES = ns.LANGUAGES,
    LocaleCount = function(code)
        return ns.LocaleCount(code)
    end,
    PreviewLocale = function()
        return ns.PreviewLocale()
    end,
    ActiveLocale = function()
        return ns.ActiveLocale()
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
    SetImportRanges = function(ranges)
        ns.Share.ranges = ranges
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
