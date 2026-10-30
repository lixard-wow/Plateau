local _, ns = ...

local L = ns.L

local Say = ns.Say

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

local function WithOptions(name, method, failText, brokenText, ...)
    ns.WarmThemeFonts()
    local loaded, reason = C_AddOns.LoadAddOn("Plateau_Options")
    local target = loaded and _G[name]
    if target and target[method] then
        target[method](target, ...)
        return true
    end
    if loaded then
        if brokenText then
            Say(brokenText)
        end
    elseif failText then
        Say(failText:format(tostring(reason)))
    end
    return false
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
    return WithOptions("PlateauConflicts", "Open", nil, nil, pending, onDone)
end

local setupWatcher = CreateFrame("Frame")

local function OpenSetup()
    if InCombatLockdown() then
        setupWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end
    setupWatcher:UnregisterEvent("PLAYER_REGEN_ENABLED")
    WithOptions("PlateauSetup", "Open", L["Couldn't open setup: %s"])
end

local function OpenWhatsNew()
    WithOptions("PlateauOptions", "OpenSection", L["Couldn't open settings: %s"], nil, "help")
end

local function CheckWhatsNew()
    local global = ns.DB.saved.global
    local seen = global.lastSeenVersion
    if seen == ns.version or ns.version == "dev" then return end
    global.lastSeenVersion = ns.version
    if seen then
        global.whatsNewUnread = true
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
    Say(L["/plt - open the settings"], true)
    Say(L["/plt setup - pick a ready-made look"], true)
    Say(L["/plt whatsnew - open the changes on the Help page"], true)
    Say(L["/plt minimap - show or hide the minimap button"], true)
    if ns.DebugListed and ns.DebugListed() then
        Say(L["/plt debug - version, profile and target details for bug reports"], true)
    end
    Say(L["/plt reset - reset the active profile"], true)
    Say(L["/plt cvars restore - undo every game nameplate setting Plateau changed"], true)
end

local function OpenOptions()
    WithOptions("PlateauOptions", "Toggle", L["Couldn't open settings: %s"], L["Settings failed to load. Check the first Lua error."])
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
        ns.ReportDisabled()
        return
    end
    local words = {}
    for word in input:gmatch("%S+") do
        words[#words + 1] = word
    end
    local command, path = words[1] and words[1]:lower(), words[2]

    if not command then
        OpenOptions()
    elseif command == "setup" then
        OpenSetup()
    elseif command == "whatsnew" or command == "changelog" then
        OpenWhatsNew()
    elseif command == "minimap" and ns.Minimap then
        local shown = not ns.Minimap:IsShown()
        ns.Minimap:SetShown(shown)
        Say(shown and L["Minimap button shown."] or L["Minimap button hidden. Type /plt minimap to show it."])
    elseif command == "debug" and ns.RunDebug then
        ns.RunDebug(path and path:lower())
    elseif command == "cvars" and path and path:lower() == "restore" then
        ns.CVars:ReleaseAll()
        Say(L["Blizzard nameplate settings restored."])
    elseif command == "reset" then
        local ok, reason = ns.DB:Reset(path)
        Say(ok and (path and L["%s reset to default."]:format(path) or L["All settings reset to default."]) or ((path or "") .. ": " .. tostring(reason)))
    else
        Help()
    end
end

Plateau = {
    L = ns.L,
    T = ns.T,
    ActiveLocale = ns.ActiveLocale,
    DEBUG_BUILD = ns.DEBUG_BUILD == true,
    Debug = ns.Debug,
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
    WaitingForCombat = function()
        local list = {}
        local restyle, clicks = ns.Driver:WaitingForCombat()
        if ns.CVars:IsPending() then list[#list + 1] = L["Blizzard settings"] end
        if clicks then list[#list + 1] = L["Click areas"] end
        if restyle then list[#list + 1] = L["Nameplate look"] end
        if ns.AutoProfile:Status().pending then list[#list + 1] = L["Profile switch"] end
        return list
    end,
    CONTENT_TYPES = ns.CONTENT_TYPES,
    arrowStyles = ns.arrowStyles,
    iconPositions = ns.iconPositions,
    HealthBorderOuter = ns.HealthBorderOuter,
    RepixelPlate = ns.RepixelPlate,
    textPositions = ns.textPositions,
    AuraPlacement = function(db)
        return ns.AuraPlacement(db)
    end,
    media = ns.media,
    PresetLook = ns.PresetLook,
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
    FindConflicts = ns.FindConflicts,
    ResolveConflict = ns.ResolveConflict,
    DisableSelf = function()
        local character = UnitGUID("player")
        C_AddOns.DisableAddOn("Plateau_Options", character)
        C_AddOns.DisableAddOn("Plateau", character)
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
    CurrentSpec = ns.CurrentSpec,
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
