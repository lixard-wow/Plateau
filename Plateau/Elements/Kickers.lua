local _, ns = ...

local GetRaidTargetIndex = GetRaidTargetIndex
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitClassBase = UnitClassBase
local UnitName = UnitName
local issecretvalue = issecretvalue
local type, pairs, ipairs, time = type, pairs, ipairs, time

local WHITE = "Interface\\Buttons\\WHITE8X8"
local CLASS_SHEET = "Interface\\WorldStateFrame\\Icons-Classes"
local UNITS = { "player", "party1", "party2", "party3", "party4" }
local MARK_LIFE = 4 * 60 * 60
local GAP = 2

local CHAT_EVENTS = {
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local KEYWORDS = { "interrupt", "kick", "focus" }

local TAGS = {
    star = 1, circle = 2, coin = 2, diamond = 3, triangle = 4, moon = 5, square = 6, cross = 7, x = 7, skull = 8,
}
for i = 1, 8 do
    TAGS["rt" .. i] = i
    local label = _G["RAID_TARGET_" .. i]
    if type(label) == "string" then TAGS[label:lower()] = i end
end
if type(INTERRUPT) == "string" then KEYWORDS[#KEYWORDS + 1] = INTERRUPT:lower() end

local includeSelf = {}
local owners = {}
local version = 0

local Kickers = {
    key = "kickers",
    events = {},
    globalEvents = { "RAID_TARGET_UPDATE" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Kickers = Kickers

local function Readable(value)
    if issecretvalue(value) then return nil end
    return value
end

local function Marks()
    local global = ns.DB and ns.DB.saved and ns.DB.saved.global
    if not global then return {} end
    global.kickMarks = global.kickMarks or {}
    return global.kickMarks
end

local function ClassIcon(texture, class)
    local atlas = class and "classicon-" .. class:lower()
    if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
        texture:SetAtlas(atlas)
        return
    end
    local coords = class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class]
    texture:SetTexture(CLASS_SHEET)
    if coords then
        texture:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    else
        texture:SetTexCoord(0, 1, 0, 1)
    end
end

local function OwnMarker()
    local db = FocusControlDB
    local marker = type(db) == "table" and tonumber(db.marker)
    if marker and marker >= 1 and marker <= 8 then return marker end
end

local function Rebuild()
    local marks, now = Marks(), time()
    for guid, mark in pairs(marks) do
        if type(mark) ~= "table" or now - (mark.at or 0) > MARK_LIFE then marks[guid] = nil end
    end
    local list = {}
    local wantSelf = includeSelf.enemy ~= false
    for _, unit in ipairs(UNITS) do
        if UnitExists(unit) and (unit ~= "player" or wantSelf) then
            local guid = Readable(UnitGUID(unit))
            local marker = guid and marks[guid] and marks[guid].marker
            if unit == "player" then marker = OwnMarker() or marker end
            if marker then
                list[marker] = list[marker] or {}
                local entry = list[marker]
                entry[#entry + 1] = { class = Readable(UnitClassBase(unit)), name = Readable(UnitName(unit)) }
            end
        end
    end
    owners = list
    version = version + 1
    ns.Driver:ForEachActive(function(plate)
        if plate.built[Kickers] and Kickers.enabledIn[plate.state] then
            Kickers:Update(plate, plate.unit)
        end
    end)
end
Kickers.Rebuild = Rebuild

local function ParseMarker(text)
    local lower = text:lower()
    local found
    for tag in lower:gmatch("{(.-)}") do
        local index = TAGS[tag]
        if index then
            if found and found ~= index then return nil end
            found = index
        end
    end
    if not found then return nil end
    for _, word in ipairs(KEYWORDS) do
        if lower:find(word, 1, true) then return found end
    end
end
Kickers.ParseMarker = ParseMarker

local function InGroup(guid)
    for _, unit in ipairs(UNITS) do
        if UnitExists(unit) and Readable(UnitGUID(unit)) == guid then return true end
    end
end

local function OnChat(text, guid)
    text, guid = Readable(text), Readable(guid)
    if type(text) ~= "string" or type(guid) ~= "string" or not InGroup(guid) then return end
    local marker = ParseMarker(text)
    if not marker then return end
    Marks()[guid] = { marker = marker, at = time() }
    Rebuild()
end

local watcher = CreateFrame("Frame")
for _, event in ipairs(CHAT_EVENTS) do watcher:RegisterEvent(event) end
watcher:RegisterEvent("GROUP_ROSTER_UPDATE")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function(_, event, text, ...)
    if ns.disabled then return end
    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        Rebuild()
        return
    end
    local guid = select(11, ...)
    pcall(OnChat, text, guid)
end)

local function Gate(lane, low)
    local bar = CreateFrame("StatusBar", nil, lane)
    bar:SetAllPoints()
    bar:SetStatusBarTexture(WHITE)
    bar:SetStatusBarColor(0, 0, 0, 0)
    bar:SetMinMaxValues(low, low + 1)
    bar:SetValue(0)
    return bar
end

local function Lane(plate, marker)
    local lane = CreateFrame("Frame", nil, plate.kickHolder)
    lane:SetPoint("TOPLEFT")
    lane:SetPoint("BOTTOMRIGHT")
    lane.open = Gate(lane, marker - 1)
    lane.shut = Gate(lane, marker)
    local clip = CreateFrame("Frame", nil, lane)
    clip:SetClipsChildren(true)
    clip:SetPoint("TOPLEFT", lane.shut:GetStatusBarTexture(), "TOPRIGHT")
    clip:SetPoint("BOTTOMRIGHT", lane.open:GetStatusBarTexture(), "BOTTOMRIGHT")
    local content = CreateFrame("Frame", nil, clip)
    content:SetAllPoints(lane)
    lane.content = content
    lane.icons = {}
    plate.kickLanes[marker] = lane
    return lane
end

local function Icon(lane, index)
    local icon = lane.icons[index]
    if icon then return icon end
    icon = {
        edge = lane.content:CreateTexture(nil, "OVERLAY", nil, 1),
        art = lane.content:CreateTexture(nil, "OVERLAY", nil, 2),
    }
    icon.edge:SetColorTexture(0, 0, 0, 1)
    lane.icons[index] = icon
    return icon
end

local function PaintIcon(icon, lane, index, owner, size)
    local x = (index - 1) * (size + GAP)
    icon.edge:ClearAllPoints()
    icon.edge:SetPoint("TOPLEFT", lane, "TOPLEFT", x, 0)
    icon.edge:SetSize(size, size)
    icon.art:ClearAllPoints()
    icon.art:SetPoint("TOPLEFT", icon.edge, "TOPLEFT", 1, -1)
    icon.art:SetPoint("BOTTOMRIGHT", icon.edge, "BOTTOMRIGHT", -1, 1)
    ClassIcon(icon.art, owner.class)
    local color = owner.class and C_ClassColor and C_ClassColor.GetClassColor(owner.class)
    if color then
        icon.edge:SetColorTexture(color.r, color.g, color.b, 1)
    else
        icon.edge:SetColorTexture(0, 0, 0, 1)
    end
    icon.edge:Show()
    icon.art:Show()
end

local function Sync(plate, list)
    if plate.kickVersion == version and not list then return end
    plate.kickVersion = list and -1 or version
    local size = plate.kickSize or 18
    local source = list or owners
    local widest = 1
    for marker = 1, 8 do
        local entries = source[marker]
        local lane = plate.kickLanes[marker]
        if entries then
            lane = lane or Lane(plate, marker)
            for index, owner in ipairs(entries) do
                PaintIcon(Icon(lane, index), lane, index, owner, size)
            end
            for index = #entries + 1, #lane.icons do
                lane.icons[index].edge:Hide()
                lane.icons[index].art:Hide()
            end
            if #entries > widest then widest = #entries end
            lane:Show()
        elseif lane then
            lane:Hide()
        end
    end
    plate.kickHolder:SetSize(widest * size + (widest - 1) * GAP, size)
end

local function Feed(plate, value)
    for marker = 1, 8 do
        local lane = plate.kickLanes[marker]
        if lane and lane:IsShown() then
            lane.open:SetValue(value)
            lane.shut:SetValue(value)
        end
    end
end

function Kickers:Create(plate)
    local holder = CreateFrame("Frame", nil, plate.overlay)
    holder:SetFrameLevel(plate.overlay:GetFrameLevel() + 5)
    holder:SetSize(1, 1)
    holder:Hide()
    plate.kickHolder = holder
    plate.kickLanes = {}
end

function Kickers:Configure(db, state)
    local value = db.includeSelf ~= false
    if includeSelf[state] ~= value then
        includeSelf[state] = value
        if state == "enemy" then Rebuild() end
    end
end

function Kickers:Style(plate, db)
    local holder = plate.kickHolder
    holder:SetAlpha(db.alpha)
    if plate.kickSize ~= db.size then
        plate.kickSize = db.size
        plate.kickVersion = nil
    end
    ns.PlaceIcon(holder, plate, db.position, db.gap, db.offsetX, db.offsetY)
end

function Kickers:Enable(plate, unit)
    self:Update(plate, unit)
end

function Kickers:Disable(plate)
    plate.kickHolder:Hide()
end

function Kickers:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

function Kickers:Update(plate, unit)
    local holder = plate.kickHolder
    if plate.isFriendly or not unit or not next(owners) then
        holder:Hide()
        return
    end
    Sync(plate)
    local index = GetRaidTargetIndex(unit)
    Feed(plate, type(index) == "nil" and 0 or index)
    holder:Show()
end

function Kickers:Preview(plate, state)
    local holder = plate.kickHolder
    if not state.showKickers then
        holder:Hide()
        return
    end
    local marker = state.raidMarker or 8
    local list = { [marker] = { { class = UnitClassBase("player") } } }
    Sync(plate, list)
    Feed(plate, marker)
    holder:Show()
end

ns.Driver:RegisterElement(Kickers)
