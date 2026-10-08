local _, ns = ...

local UnitName = UnitName
local UnitIsPlayer = UnitIsPlayer
local UnitClassBase = UnitClassBase
local issecretvalue = issecretvalue

local settings = {}

local NAME_SCALES = { 0.8, 1, 1.25, 1.4, 1.6 }

local FRIENDLY_REALM_CVAR = "nameplateShowFriendlyRealmName"
local friendlyRealmNames = false

local Name = {
    key = "name",
    events = { "UNIT_NAME_UPDATE" },
    nameOnly = true,
}
ns.Elements = ns.Elements or {}
ns.Elements.Name = Name

local function FirstChar(word)
    return word:match("^[%z\1-\127\194-\244][\128-\191]*") or word:sub(1, 1)
end

local function Shorten(name, mode)
    if mode == "lastWord" then
        return name:match("(%S+)%s*$") or name
    elseif mode == "firstWord" then
        return name:match("^(%S+)") or name
    elseif mode == "abbreviate" then
        local words = {}
        for word in name:gmatch("%S+") do
            words[#words + 1] = word
        end
        if #words < 2 then
            return name
        end
        for i = 1, #words - 1 do
            words[i] = FirstChar(words[i]) .. "."
        end
        return table.concat(words, " ")
    elseif mode == "lastInitial" then
        local words = {}
        for word in name:gmatch("%S+") do
            words[#words + 1] = word
        end
        if #words < 2 then
            return name
        end
        return words[1] .. " " .. FirstChar(words[#words]) .. "."
    elseif mode == "initials" then
        local words = {}
        for word in name:gmatch("%S+") do
            words[#words + 1] = word
        end
        if #words < 2 then
            return name
        end
        for i = 1, #words do
            words[i] = FirstChar(words[i]) .. "."
        end
        return table.concat(words)
    end
    return name
end
ns.ShortenName = Shorten

function Name:Create(plate)
    local clip = CreateFrame("Frame", nil, plate)
    clip:SetFrameLevel(plate.overlay:GetFrameLevel())
    clip:SetClipsChildren(true)
    local text = clip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.nameClip = clip
    plate.name = text
end

function Name:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    if state == "friendly" then
        local friendly = ns.DB.views.enemy.friendly
        s.mode = ns.flavor == "forever" and friendly.nameMode or "full"
        s.npcMode = friendly.npcNameMode
        s.classColors = friendly.classColors
    else
        s.mode = db.mode
        s.npcMode = db.npcMode
        s.classColors = db.classColors
    end
    s.r, s.g, s.b, s.a = db.color[1], db.color[2], db.color[3], db.color[4]
    s.font, s.size, s.outline = db.font, db.size, db.outline
    s.targetOnly = db.targetOnly == true
    s.hideCasting = db.hideCasting == true
    s.matchBar = db.matchBar == true
end

local function Visible(plate)
    if plate.isFriendly then return true end
    local s = settings[plate.state]
    if s.targetOnly and not plate.isTarget then return false end
    if s.hideCasting and plate.casting then return false end
    return true
end

function Name:RefreshShown(plate)
    if plate.active and ns.Runs(self, plate) then
        plate.name:SetShown(Visible(plate))
    end
end

function Name:UpdateEmphasis(plate)
    self:RefreshShown(plate)
end

function Name:BarColor(plate, r, g, b, a)
    plate.barR, plate.barG, plate.barB, plate.barA = r, g, b, a
    plate.barColorSet = true
    local s = settings[plate.state]
    if s and s.matchBar and not plate.nameOnly then
        plate.name:SetTextColor(r, g, b, a)
    end
end

function Name:ApplySize(plate, isPlayer)
    local s = settings[plate.state]
    local size = s.size
    if plate.state == "friendly" and not isPlayer then
        local npc = NAME_SCALES[ns.DB.views.enemy.friendly.npcNameScale]
        local blizzard = NAME_SCALES[tonumber(C_CVar.GetCVar("nameplateSize"))] or 1
        if npc then
            size = size * npc / blizzard
        end
    end
    if plate.nameSize ~= size or plate.nameFont ~= s.font or plate.nameOutline ~= s.outline then
        plate.nameSize, plate.nameFont, plate.nameOutline = size, s.font, s.outline
        ns.ApplyFont(plate.name, s.font, size, s.outline)
        plate.nameClip:SetHeight(size + 6)
    end
end

function Name:Style(plate, db)
    local clip, text = plate.nameClip, plate.name
    ns.ApplyFont(text, db.font, db.size, db.outline)
    plate.nameSize, plate.nameFont, plate.nameOutline = db.size, db.font, db.outline
    ns.ApplyShadow(text, db.shadow)
    text:SetTextColor(db.color[1], db.color[2], db.color[3], db.color[4])

    clip:ClearAllPoints()
    clip:SetHeight(db.size + 6)
    local topInside = not plate.nameOnly and db.position == "INSIDETOP"
    local inBar = plate.nameOnly or db.position == "CENTER" or topInside
    local inset = inBar and 3 or 0
    local vertical, relative, y = "BOTTOM", "TOP", db.gap
    if topInside then
        vertical, relative, y = "TOP", "TOP", -db.gap
    elseif inBar then
        vertical, relative = "", ""
    elseif db.position == "BOTTOM" then
        vertical, relative, y = "TOP", "BOTTOM", -db.gap
    end
    if plate.nameOnly then
        y = y + ns.DB.views.enemy.friendly.nameOffsetY
    end
    local justify = plate.nameOnly and "CENTER" or db.justify
    local width = db.width or 0
    if width == 0 and plate.nameOnly then
        width = 300
    end
    if width > 0 then
        clip:SetWidth(width)
        local side, x = "", 0
        if justify == "LEFT" then
            side, x = "LEFT", inset
        elseif justify == "RIGHT" then
            side, x = "RIGHT", -inset
        end
        local point = vertical .. side
        local relativePoint = relative .. side
        clip:SetPoint(point ~= "" and point or "CENTER", plate, relativePoint ~= "" and relativePoint or "CENTER", x, y)
    else
        clip:SetPoint(vertical .. "LEFT", plate, relative .. "LEFT", inset, y)
        clip:SetPoint(vertical .. "RIGHT", plate, relative .. "RIGHT", -inset, y)
    end

    text:ClearAllPoints()
    plate.nameCutStart = nil
    clip:SetClipsChildren(db.overflow ~= "none")
    local top = topInside and "TOP" or ""
    plate.nameTop = top
    text:SetJustifyV(topInside and "TOP" or "MIDDLE")
    if db.overflow == "none" then
        local side = justify == "LEFT" and "LEFT" or justify == "RIGHT" and "RIGHT" or ""
        local point = top .. side
        if point == "" then
            point = "CENTER"
        end
        text:SetPoint(point, clip, point)
        text:SetJustifyH(justify)
    elseif db.overflow == "start" then
        text:SetPoint(top .. "RIGHT", clip, top .. "RIGHT")
        text:SetJustifyH("RIGHT")
        plate.nameCutStart = justify
    else
        text:SetAllPoints(clip)
        text:SetJustifyH(justify)
    end
end

function Name:Enable(plate, unit)
    plate.name:SetShown(Visible(plate))
    self:Update(plate, unit)
end

function Name:Disable(plate)
    plate.name:SetText("")
    plate.name:Hide()
    plate.barColorSet = nil
end

function Name:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

local function FitCutStart(plate)
    local justify = plate.nameCutStart
    if not justify or justify == "RIGHT" then return end
    local text, clip = plate.name, plate.nameClip
    local width = text:GetStringWidth()
    local room = clip:GetWidth()
    text:ClearAllPoints()
    local top = plate.nameTop or ""
    if not issecretvalue(width) and not issecretvalue(room) and width <= room then
        local side = justify == "LEFT" and "LEFT" or ""
        local point = top .. side
        if point == "" then
            point = "CENTER"
        end
        text:SetPoint(point, clip, point)
    else
        text:SetPoint(top .. "RIGHT", clip, top .. "RIGHT")
    end
end

function Name:Update(plate, unit)
    local rawName, surname = UnitName(unit)
    local name = ns.CleanName(rawName)
    if ns.flavor == "forever" and not issecretvalue(name) and name and not issecretvalue(surname) and surname and surname ~= "" then
        name = name .. " " .. surname
    end
    local isPlayer = UnitIsPlayer(unit) == true
    local db = settings[plate.state]
    local mode = plate.state == "friendly" and (isPlayer and db.mode or db.npcMode) or db.mode
    if mode ~= "full" and not issecretvalue(name) and name then
        if plate.shortenSource == name and plate.shortenMode == mode then
            name = plate.shortenResult
        else
            local shortened = Shorten(name, mode)
            plate.shortenSource, plate.shortenMode, plate.shortenResult = name, mode, shortened
            name = shortened
        end
    end
    if isPlayer and friendlyRealmNames and plate.state == "friendly" and ns.flavor ~= "forever"
        and not issecretvalue(name) and name and not issecretvalue(surname) and surname and surname ~= "" then
        name = name .. "-" .. surname
    end
    plate.name:SetText(name)
    self:ApplySize(plate, isPlayer)
    FitCutStart(plate)
    local class
    if isPlayer or ns.UnitColors:IsCompanion(unit) then
        class = ns.UnitColors:PlayerClass(unit) or UnitClassBase(unit)
    end
    self:Color(plate, class)
end

local FRIENDLY_CLASS_CVAR = "nameplateUseClassColorForFriendlyPlayerUnitNames"
local friendlyClassColors = C_CVar.GetCVarBool(FRIENDLY_CLASS_CVAR) ~= false
friendlyRealmNames = C_CVar.GetCVarBool(FRIENDLY_REALM_CVAR) == true

local cvarWatcher = CreateFrame("Frame")
cvarWatcher:RegisterEvent("CVAR_UPDATE")
cvarWatcher:RegisterEvent("PLAYER_LOGIN")
cvarWatcher:SetScript("OnEvent", function(_, event, name)
    if event == "CVAR_UPDATE" and name ~= FRIENDLY_CLASS_CVAR and name ~= FRIENDLY_REALM_CVAR then return end
    local value = C_CVar.GetCVarBool(FRIENDLY_CLASS_CVAR) ~= false
    local realms = C_CVar.GetCVarBool(FRIENDLY_REALM_CVAR) == true
    if value ~= friendlyClassColors or realms ~= friendlyRealmNames then
        friendlyClassColors = value
        friendlyRealmNames = realms
        ns.Driver:RequestRestyle(false, "friendly name settings")
    end
end)

local function ClassColor(class)
    if issecretvalue(class) or not class then return nil end
    return RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
end

local function ApplySecretClass(text, class)
    if not issecretvalue(class) or not (C_ClassColor and C_ClassColor.GetClassColor) then return false end
    local ok, color = pcall(C_ClassColor.GetClassColor, class)
    if ok and color then
        text:SetTextColor(color.r, color.g, color.b, 1)
        return true
    end
    return false
end

local function InGroup(unit)
    if not unit then return false end
    local party = UnitInParty(unit)
    if not issecretvalue(party) and party then return true end
    local raid = UnitInRaid(unit)
    return not issecretvalue(raid) and raid ~= nil
end

function Name:Color(plate, class)
    local text = plate.name
    if plate.state == "friendly" and class and plate.isPlayer ~= false then
        local friendly = ns.DB.views.enemy.friendly
        if friendly.groupColor and InGroup(plate.unit) then
            local c = friendly.groupNameColor
            text:SetTextColor(c[1], c[2], c[3], c[4])
            return
        end
    end
    if not plate.nameOnly then
        local s = settings[plate.state]
        if s.matchBar and plate.barColorSet then
            text:SetTextColor(plate.barR, plate.barG, plate.barB, plate.barA)
            return
        end
        local wanted = s.classColors
        if plate.state == "friendly" then
            wanted = friendlyClassColors
        end
        local color = wanted and ClassColor(class)
        if color then
            text:SetTextColor(color.r, color.g, color.b, 1)
        elseif wanted and ApplySecretClass(text, class) then
            return
        else
            text:SetTextColor(s.r, s.g, s.b, s.a)
        end
        return
    end
    local friendly = ns.DB.views.enemy.friendly
    local color = friendlyClassColors and ClassColor(class)
    if color then
        text:SetTextColor(color.r, color.g, color.b, 1)
        return
    end
    if friendlyClassColors and ApplySecretClass(text, class) then
        return
    end
    local fallback = class and friendly.playerNameColor or friendly.npcNameColor
    text:SetTextColor(fallback[1], fallback[2], fallback[3], fallback[4])
end

function Name:Preview(plate, state)
    local db = settings[plate.state]
    local mode = plate.state == "friendly" and (state.isPlayer and db.mode or db.npcMode) or db.mode
    plate.name:SetText(Shorten(state.name, mode))
    self:ApplySize(plate, state.isPlayer == true)
    FitCutStart(plate)
    self:Color(plate, state.isPlayer and state.class)
    plate.name:Show()
end

ns.Driver:RegisterElement(Name)
