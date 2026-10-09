local addonName, ns = ...

ns.name = addonName
ns.version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "dev"

local interface = select(4, GetBuildInfo())
ns.flavor = interface < 20000 and "forever" or "mainline"

local PURGE_KEY_LIMIT = 10000

local function PurgeKey(options, key)
    options[key] = nil
    local filler = 42
    local tries = 0
    repeat
        if options[filler] == nil then
            options[filler] = nil
        end
        filler = filler + 1
        tries = tries + 1
    until issecurevariable(options, key) or tries > PURGE_KEY_LIMIT
    ns.realmPurgeFailed = not issecurevariable(options, key) or nil
end

function ns.ApplyRealmMarker()
    if NamePlateFriendlyFrameOptions and not ns.DB.saved.global.keepRealmMarker
        and not C_CVar.GetCVarBool("nameplateShowFriendlyRealmName") then
        PurgeKey(NamePlateFriendlyFrameOptions, "updateNameUsesGetUnitName")
    end
end

local function StartDatabase()
    local ok, problem = pcall(ns.DB.Init, ns.DB)
    if ok then return true end
    local broken = PlateauDB
    PlateauDB = { recovered = { at = date("%Y-%m-%d %H:%M"), error = tostring(problem), data = broken } }
    ns.recovered = tostring(problem)
    ok, problem = pcall(ns.DB.Init, ns.DB)
    if ok then return true end
    ns.disabled = tostring(problem)
    return false
end

local function ReportStartup()
    local failures = ns.DB.migrationFailures
    if ns.disabled then
        print("|cffff5555Plateau couldn't start:|r " .. ns.disabled)
    elseif ns.recovered then
        print("|cffffd200Plateau:|r your saved settings were damaged and couldn't be read, so Plateau started with its default settings. The old data is kept in the saved file under 'recovered'. Error: " .. ns.recovered)
    elseif failures and #failures > 0 then
        print("|cffffd200Plateau:|r some saved settings couldn't be updated to this version: " .. table.concat(failures, "; "))
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGOUT")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(self, event, name)
    if ns.disabled then
        if event == "PLAYER_LOGIN" then
            ReportStartup()
        end
        return
    end
    if event == "PLAYER_LOGIN" then
        C_Timer.After(5, ReportStartup)
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        ns.DB:ResolveCharacter()
        if ns.DB.charKey then
            self:UnregisterEvent("PLAYER_LOGIN")
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    elseif event == "PLAYER_LOGOUT" then
        ns.Driver:UnregisterAllEvents()
        ns.DB:Shutdown()
    elseif name == addonName then
        self:UnregisterEvent("ADDON_LOADED")
        if not StartDatabase() then
            ns.Driver:UnregisterAllEvents()
            return
        end
        ns.SetPseudoLocale(ns.DB.saved.global.pseudoLocale == true)
        ns.ApplyRealmMarker()
        ns.Driver:Restyle("addon loaded")
    end
end)
