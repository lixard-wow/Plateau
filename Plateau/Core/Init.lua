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
end

function ns.ApplyRealmMarker()
    if NamePlateFriendlyFrameOptions and not ns.DB.saved.global.keepRealmMarker
        and not C_CVar.GetCVarBool("nameplateShowFriendlyRealmName") then
        PurgeKey(NamePlateFriendlyFrameOptions, "updateNameUsesGetUnitName")
    end
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGOUT")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "PLAYER_LOGIN" and ns.WarmThemeFonts then
        ns.WarmThemeFonts()
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
        ns.DB:Init()
        ns.ApplyRealmMarker()
        ns.Driver:Restyle()
    end
end)
