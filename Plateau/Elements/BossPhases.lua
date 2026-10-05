local _, ns = ...

local issecretvalue = issecretvalue
local IsInInstance = IsInInstance
local MAX_LINES = 4

local BOSSES = {
    { id = 3101, name = "Kystia Manaheart", place = "Murder Row", lines = "20", on = "all" },
    { id = 3102, name = "Zaen Bladesorrow", place = "Murder Row" },
    { id = 3103, name = "Xathuux the Annihilator", place = "Murder Row" },
    { id = 3105, name = "Lithiel Cinderfury", place = "Murder Row" },
    { id = 3207, name = "The Hoardmonger", place = "Den of Nalorakk", lines = "90, 70, 40" },
    { id = 3208, name = "Sentinel of Winter", place = "Den of Nalorakk" },
    { id = 3209, name = "Nalorakk", place = "Den of Nalorakk" },
    { id = 3199, name = "Lightblossom Trinity", place = "The Blinding Vale" },
    { id = 3200, name = "Ikuzz the Light Hunter", place = "The Blinding Vale", lines = "50" },
    { id = 3201, name = "Lightwarden Ruia", place = "The Blinding Vale", lines = "70, 40" },
    { id = 3202, name = "Ziekket", place = "The Blinding Vale" },
    { id = 3285, name = "Taz'Rah", place = "Voidscar Arena" },
    { id = 3286, name = "Atroxus", place = "Voidscar Arena" },
    { id = 3287, name = "Charonus", place = "Voidscar Arena" },
    { id = 3456, name = "Rav'i", place = "Altar of Fangs" },
    { id = 3457, name = "The Writhing Coil", place = "Altar of Fangs" },
    { id = 3458, name = "Zul'jan", place = "Altar of Fangs" },
    { id = 2139, name = "The Golden Serpent", place = "Kings' Rest" },
    { id = 2142, name = "Mchimba the Embalmer", place = "Kings' Rest" },
    { id = 2140, name = "The Council of Tribes", place = "Kings' Rest" },
    { id = 2143, name = "King Dazar", place = "Kings' Rest", lines = "80" },
    { id = 2124, name = "Adderis and Aspix", place = "Temple of Sethraliss", lines = "66, 33" },
    { id = 2125, name = "Merektha", place = "Temple of Sethraliss" },
    { id = 2126, name = "Galvazzt", place = "Temple of Sethraliss" },
    { id = 2127, name = "Avatar of Sethraliss", place = "Temple of Sethraliss" },
    { id = 2609, name = "Melidrussa Chillworn", place = "Ruby Life Pools", lines = "66, 33" },
    { id = 2606, name = "Kokia Blazehoof", place = "Ruby Life Pools" },
    { id = 2623, name = "Kyrakka and Erkhart Stormvein", place = "Ruby Life Pools", lines = "50" },
    { id = 3470, name = "Nek'zali the Soulcoiler", place = "The Venomous Abyss", lines = "50" },
    { id = 3445, name = "Entombed Sentinels", place = "The Venomous Abyss" },
    { id = 3455, name = "Vashnik the Malignant", place = "The Venomous Abyss" },
    { id = 3497, name = "The Lost Explorers", place = "The Venomous Abyss" },
    { id = 3420, name = "Sszorak", place = "The Venomous Abyss" },
    { id = 3421, name = "The Twin Fangs", place = "The Venomous Abyss" },
    { id = 3429, name = "The Coiled Altar", place = "The Venomous Abyss" },
    { id = 3492, name = "Ula'tek", place = "The Venomous Abyss" },
}

local builtin = {}
for _, boss in ipairs(BOSSES) do
    builtin[boss.id] = boss
end

local settings = {}
local encounterID
local inInstance = false

local BossPhases = {
    key = "bossPhases",
    events = { "UNIT_CLASSIFICATION_CHANGED" },
    globalEvents = { "INSTANCE_ENCOUNTER_ENGAGE_UNIT" },
}
ns.Elements = ns.Elements or {}
ns.Elements.BossPhases = BossPhases

local function Global()
    local saved = ns.DB and ns.DB.saved
    return saved and saved.global
end

function ns.BossPhaseLines(id)
    local global = Global()
    local custom = global and global.bossPhases and global.bossPhases[id]
    if custom ~= nil then
        return custom
    end
    local boss = builtin[id]
    return boss and boss.lines or ""
end

function ns.SetBossPhaseLines(id, text)
    local global = Global()
    if not global then return end
    global.bossPhases = global.bossPhases or {}
    local boss = builtin[id]
    if text == nil or text == (boss and boss.lines or "") then
        global.bossPhases[id] = nil
    else
        global.bossPhases[id] = text
    end
end

function ns.BossPhaseTarget(id)
    local global = Global()
    local custom = global and global.bossPhaseOn and global.bossPhaseOn[id]
    if custom ~= nil then
        return custom
    end
    local boss = builtin[id]
    return boss and boss.on or "boss"
end

function ns.SetBossPhaseTarget(id, on)
    local global = Global()
    if not global then return end
    global.bossPhaseOn = global.bossPhaseOn or {}
    local boss = builtin[id]
    if on == nil or on == (boss and boss.on or "boss") then
        global.bossPhaseOn[id] = nil
    else
        global.bossPhaseOn[id] = on
    end
end

function ns.BossPhaseSeen()
    local global = Global()
    return global and global.bossesSeen or {}
end

local function Parse(text, out)
    local count = 0
    if type(text) ~= "string" then return 0 end
    for number in text:gmatch("%d+%.?%d*") do
        local value = tonumber(number)
        if value and value > 0 and value < 100 and count < MAX_LINES then
            count = count + 1
            out[count] = value
        end
    end
    return count
end

local scratch = {}

local function LinesFor(plate)
    local s = settings[plate.state]
    if not s or plate.isFriendly then
        return 0
    end
    local isBoss = plate.mobType == "boss"
    if encounterID then
        local text = ns.BossPhaseLines(encounterID)
        if text ~= "" and (isBoss or ns.BossPhaseTarget(encounterID) == "all") then
            return Parse(text, scratch)
        end
    end
    if not isBoss then
        return 0
    end
    if s.instancesOnly and not inInstance then
        return 0
    end
    return Parse(s.defaults, scratch)
end

function BossPhases:Create(plate)
    plate.phaseLines = {}
end

function BossPhases:Configure(db, state)
    settings[state] = db
end

local function Line(plate, index)
    local line = plate.phaseLines[index]
    if not line then
        line = ns.MarkerLayer(plate):CreateTexture(nil, "OVERLAY", nil, 2)
        line:Hide()
        plate.phaseLines[index] = line
    end
    return line
end

local function HideLines(plate)
    for _, line in ipairs(plate.phaseLines) do
        line:Hide()
    end
end

local function Draw(plate)
    local count = LinesFor(plate)
    local s = settings[plate.state]
    if count == 0 or not s then
        HideLines(plate)
        return
    end
    local width = plate:GetWidth()
    if issecretvalue(width) or not width or width <= 0 then
        HideLines(plate)
        return
    end
    local reverse = ns.DB.views[plate.state].health.fillDirection == "right"
    local side = reverse and "RIGHT" or "LEFT"
    local direction = reverse and -1 or 1
    local color = s.color
    for i = 1, MAX_LINES do
        local line = plate.phaseLines[i]
        if i <= count then
            line = line or Line(plate, i)
            local x = direction * width * scratch[i] / 100
            line:ClearAllPoints()
            line:SetPoint("TOP", plate.health, "TOP" .. side, x, 0)
            line:SetPoint("BOTTOM", plate.health, "BOTTOM" .. side, x, 0)
            line:SetWidth(s.lineWidth or 2)
            line:SetColorTexture(color[1], color[2], color[3], color[4])
            line:Show()
        elseif line then
            line:Hide()
        end
    end
end

function BossPhases:Update(plate)
    local ok, err = pcall(Draw, plate)
    if not ok then
        ns.bossPhaseError = tostring(err)
        pcall(HideLines, plate)
    end
end

function BossPhases:Style(plate)
    self:Update(plate)
end

function BossPhases:Enable(plate)
    self:Update(plate)
end

function BossPhases:Disable(plate)
    pcall(HideLines, plate)
end

function BossPhases:OnEvent(plate)
    self:Update(plate)
end

function BossPhases:UpdateEmphasis(plate)
    self:Update(plate)
end

function BossPhases:Preview(plate, state)
    local ok = pcall(function()
        local s = settings[plate.state]
        local text = s and s.defaults or ""
        if state.mobType == "boss" and text == "" then
            text = "70, 40"
        end
        local count = (s and state.mobType == "boss" and not state.isFriendly) and Parse(text, scratch) or 0
        if count == 0 then
            HideLines(plate)
            return
        end
        local saved = plate.mobType
        plate.mobType = "boss"
        local savedEncounter = encounterID
        encounterID = nil
        Draw(plate)
        encounterID = savedEncounter
        plate.mobType = saved
    end)
    if not ok then
        pcall(HideLines, plate)
    end
end

local function RefreshAll()
    ns.Driver:ForEachActive(function(plate)
        if ns.Runs(BossPhases, plate) then
            BossPhases:Update(plate)
        end
    end)
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("ENCOUNTER_START")
watcher:RegisterEvent("ENCOUNTER_END")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:SetScript("OnEvent", function(_, event, id, name)
    pcall(function()
        if event == "ENCOUNTER_START" then
            if issecretvalue(id) or type(id) ~= "number" then
                encounterID = nil
            else
                encounterID = id
                local global = Global()
                if global and not issecretvalue(name) and type(name) == "string" then
                    global.bossesSeen = global.bossesSeen or {}
                    global.bossesSeen[id] = name
                end
            end
        elseif event == "ENCOUNTER_END" then
            encounterID = nil
        else
            encounterID = nil
            inInstance = IsInInstance() == true
        end
        RefreshAll()
    end)
end)

function ns.BossPhaseStatus()
    return encounterID, ns.bossPhaseError
end

Plateau.bossPhaseList = BOSSES
Plateau.BossPhaseLines = ns.BossPhaseLines
Plateau.SetBossPhaseLines = function(id, text)
    ns.SetBossPhaseLines(id, text)
    RefreshAll()
end
Plateau.BossPhaseSeen = ns.BossPhaseSeen
Plateau.BossPhaseTarget = ns.BossPhaseTarget
Plateau.AddBossPhaseBoss = function(id, name)
    local global = Global()
    if not global or type(id) ~= "number" or id <= 0 or id >= 1e7 then return false end
    global.bossesSeen = global.bossesSeen or {}
    if name and name ~= "" then
        global.bossesSeen[id] = name
    elseif not global.bossesSeen[id] and not builtin[id] then
        global.bossesSeen[id] = "Encounter " .. id
    end
    return true
end
Plateau.SetBossPhaseTarget = function(id, on)
    ns.SetBossPhaseTarget(id, on)
    RefreshAll()
end

ns.Driver:RegisterElement(BossPhases)
