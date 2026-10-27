local _, ns = ...

local GetRaidTargetIndex = GetRaidTargetIndex
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitClassBase = UnitClassBase
local UnitName = UnitName
local issecretvalue = issecretvalue
local type, pairs, ipairs, time, next = type, pairs, ipairs, time, next

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
local segments = { { low = 0, high = 8, owners = {} } }
local classes = {}
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

local function Segments(byMarker)
    local list, low = {}, nil
    for value = 0, 8 do
        local owned = byMarker[value]
        if owned then
            if low then list[#list + 1] = { low = low, high = value - 1, owners = {} } end
            low = nil
            list[#list + 1] = { low = value, high = value, owners = owned }
        elseif not low then
            low = value
        end
    end
    if low then list[#list + 1] = { low = low, high = 8, owners = {} } end
    return list
end
Kickers.Segments = Segments

local function Refresh(plate)
    if plate.built[Kickers] and Kickers.enabledIn[plate.state] then
        Kickers:Update(plate, plate.unit)
    end
end

local function Rebuild()
    local marks, now = Marks(), time()
    for guid, mark in pairs(marks) do
        if type(mark) ~= "table" or now - (mark.at or 0) > MARK_LIFE then marks[guid] = nil end
    end
    local byMarker = {}
    local wantSelf = includeSelf.enemy ~= false
    for _, unit in ipairs(UNITS) do
        if UnitExists(unit) then
            local guid = Readable(UnitGUID(unit))
            if guid then classes[guid] = Readable(UnitClassBase(unit)) end
            local marker = guid and marks[guid] and marks[guid].marker
            if unit == "player" then marker = OwnMarker() or marker end
            if marker and (unit ~= "player" or wantSelf) then
                byMarker[marker] = byMarker[marker] or {}
                local owned = byMarker[marker]
                owned[#owned + 1] = { guid = guid, class = classes[guid], name = Readable(UnitName(unit)) }
            end
        end
    end
    segments = Segments(byMarker)
    version = version + 1
    ns.Driver:ForEachActive(Refresh)
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

local function Gate(parent)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetAllPoints()
    bar:SetStatusBarTexture(WHITE)
    bar:SetStatusBarColor(0, 0, 0, 0)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(0)
    return bar
end

local function Segment(plate, index)
    local seg = plate.kickSegs[index]
    if seg then return seg end
    seg = CreateFrame("Frame", nil, plate.kickHolder)
    seg:SetPoint("TOPLEFT")
    seg:SetPoint("BOTTOMRIGHT")
    seg.open = Gate(seg)
    seg.shut = Gate(seg)
    local clip = CreateFrame("Frame", nil, seg)
    clip:SetClipsChildren(true)
    clip:SetPoint("TOPLEFT", seg.shut:GetStatusBarTexture(), "TOPRIGHT")
    clip:SetPoint("BOTTOMRIGHT", seg.open:GetStatusBarTexture(), "BOTTOMRIGHT")
    local content = CreateFrame("Frame", nil, clip)
    content:SetAllPoints(seg)
    seg.content = content
    seg.icons = {}
    plate.kickSegs[index] = seg
    return seg
end

local function Icon(seg, index)
    local icon = seg.icons[index]
    if icon then return icon end
    icon = CreateFrame("Frame", nil, seg.content)
    icon.edge = icon:CreateTexture(nil, "OVERLAY", nil, 1)
    icon.edge:SetAllPoints()
    icon.art = icon:CreateTexture(nil, "OVERLAY", nil, 2)
    icon.art:SetPoint("TOPLEFT", 1, -1)
    icon.art:SetPoint("BOTTOMRIGHT", -1, 1)
    local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    cd:SetAllPoints(icon.art)
    cd:SetDrawEdge(false)
    cd:SetHideCountdownNumbers(false)
    if cd.SetCountdownFont then pcall(cd.SetCountdownFont, cd, "GameFontHighlightSmallOutline") end
    icon.cd = cd
    seg.icons[index] = icon
    return icon
end

local function ApplyCooldown(icon)
    local cd = icon.cd
    if icon.sample then
        cd:SetCooldown(GetTime() - 6, 15)
        return
    end
    local duration = ns.Kicks:Duration(icon.guid)
    if duration and cd.SetCooldownFromDurationObject then
        cd:SetCooldownFromDurationObject(duration)
    else
        cd:Clear()
    end
end

local function PaintIcon(icon, seg, slot, entry, size)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", seg, "TOPLEFT", (slot - 1) * (size + GAP), 0)
    icon:SetSize(size, size)
    ClassIcon(icon.art, entry.class)
    local color = entry.class and C_ClassColor and C_ClassColor.GetClassColor(entry.class)
    if color then
        icon.edge:SetColorTexture(color.r, color.g, color.b, 1)
    else
        icon.edge:SetColorTexture(0, 0, 0, 1)
    end
    icon.guid, icon.sample = entry.guid, entry.sample
    ApplyCooldown(icon)
    icon:Show()
end

local function Entries(seg, kicked)
    local list, seen = {}, {}
    for _, owner in ipairs(seg.owners) do
        list[#list + 1] = owner
        if owner.guid then seen[owner.guid] = true end
    end
    if kicked then
        local extra = {}
        for guid in pairs(kicked) do
            if not seen[guid] then extra[#extra + 1] = guid end
        end
        table.sort(extra)
        for _, guid in ipairs(extra) do
            list[#list + 1] = { guid = guid, class = classes[guid] }
        end
    end
    return list
end

local function Sync(plate, specs, kicked)
    local size = plate.kickSize or 18
    local widest = 0
    for index, spec in ipairs(specs) do
        local seg = Segment(plate, index)
        local entries = Entries(spec, kicked)
        if #entries > 0 then
            seg.open:SetMinMaxValues(spec.low - 1, spec.low)
            seg.shut:SetMinMaxValues(spec.high, spec.high + 1)
            for slot, entry in ipairs(entries) do
                PaintIcon(Icon(seg, slot), seg, slot, entry, size)
            end
            for slot = #entries + 1, #seg.icons do
                seg.icons[slot]:Hide()
            end
            if #entries > widest then widest = #entries end
            seg:Show()
        else
            seg:Hide()
        end
    end
    for index = #specs + 1, #plate.kickSegs do
        plate.kickSegs[index]:Hide()
    end
    plate.kickHolder:SetSize(math.max(widest * size + (widest - 1) * GAP, 1), size)
    return widest > 0
end

local function Feed(plate, value)
    for _, seg in ipairs(plate.kickSegs) do
        if seg:IsShown() then
            seg.open:SetValue(value)
            seg.shut:SetValue(value)
        end
    end
end

function Kickers:Create(plate)
    local holder = CreateFrame("Frame", nil, plate.overlay)
    holder:SetFrameLevel(plate.overlay:GetFrameLevel() + 5)
    holder:SetSize(1, 1)
    holder:Hide()
    plate.kickHolder = holder
    plate.kickSegs = {}
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
    if not plate.active then ns.Kicks:Forget(plate) end
    plate.kickVersion = nil
    plate.kickHolder:Hide()
end

function Kickers:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

function Kickers:PlateChanged(plate)
    plate.kickVersion = nil
    Refresh(plate)
end

function Kickers:CooldownChanged()
    local me = ns.Kicks.me
    if not me then return end
    ns.Driver:ForEachActive(function(plate)
        if plate.kickHolder and plate.kickHolder:IsShown() then
            for _, seg in ipairs(plate.kickSegs) do
                for _, icon in ipairs(seg.icons) do
                    if icon.guid == me and icon:IsShown() then ApplyCooldown(icon) end
                end
            end
        end
    end)
end

function Kickers:Update(plate, unit)
    local holder = plate.kickHolder
    if plate.isFriendly or not unit then
        holder:Hide()
        return
    end
    if plate.kickVersion ~= version then
        plate.kickVersion = version
        plate.kickAny = Sync(plate, segments, ns.Kicks:On(plate))
    end
    if not plate.kickAny then
        holder:Hide()
        return
    end
    local index = GetRaidTargetIndex(unit)
    Feed(plate, type(index) == "nil" and 0 or index)
    holder:Show()
end

function Kickers:Preview(plate, state)
    local holder = plate.kickHolder
    plate.kickVersion = nil
    if not state.showKickers then
        holder:Hide()
        return
    end
    local marker = state.raidMarker or 0
    local sample = { { low = 0, high = 8, owners = { { class = UnitClassBase("player"), sample = true } } } }
    Sync(plate, sample)
    Feed(plate, marker)
    holder:Show()
end

ns.Driver:RegisterElement(Kickers)
