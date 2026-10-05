local _, ns = ...

local UnitEffectiveLevel = UnitEffectiveLevel
local UnitLevel = UnitLevel
local UnitClassification = UnitClassification
local GetCreatureDifficultyColor = GetCreatureDifficultyColor

local ELITE = { elite = true, rareelite = true, worldboss = true }
local RARE = { rare = true, rareelite = true }
local SKULL = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t"
local BOSS_TEXT = { boss = "Boss", skull = SKULL }

local settings = {}
local bossR, bossG, bossB = 1, 0.1, 0.1
local inInstance = false

local function TrivialRange()
    if UnitQuestTrivialLevelRange then
        return UnitQuestTrivialLevelRange("player")
    end
    if GetQuestGreenRange then
        return GetQuestGreenRange()
    end
    return 8
end

local Level = {
    key = "level",
    events = { "UNIT_LEVEL", "UNIT_CLASSIFICATION_CHANGED" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Level = Level

function Level:Create(plate)
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetWordWrap(false)
    text:Hide()
    plate.level = text
end

function Level:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.colorByDifficulty = db.colorByDifficulty
    s.showElitePlus = db.showElitePlus
    s.hideAtPlayerLevel = db.hideAtPlayerLevel
    s.r, s.g, s.b, s.a = db.color[1], db.color[2], db.color[3], db.color[4]
    s.hideInInstances = db.hideInInstances == true
    s.bossText = db.bossText or "unknown"
    s.markRares = db.markRares == true
    s.hideTrivial = db.hideTrivial == true
    s.version = (s.version or 0) + 1
end

function Level:Style(plate, db)
    local text = plate.level
    ns.ApplyFont(text, db.font, db.size, db.outline)
    ns.ApplyShadow(text, db.shadow)
    if db.anchor == "NAME" then
        text:ClearAllPoints()
        text:SetPoint("RIGHT", plate.name, "LEFT", -3 + db.offsetX, db.offsetY)
    else
        ns.PlaceText(text, plate.health, db.anchor, 3, db.offsetX, db.offsetY)
    end
end

function Level:Enable(plate, unit)
    self:Update(plate, unit)
end

function Level:Disable(plate)
    plate.levelValue = nil
    plate.level:Hide()
end

function Level:OnEvent(plate, _, unit)
    self:Update(plate, unit)
end

function Level:Update(plate, unit)
    self:Render(plate, UnitEffectiveLevel(unit), UnitClassification(unit))
end

function Level:Preview(plate, state)
    self:Render(plate, UnitLevel("player") + state.levelOffset, state.classification)
end

function Level:Render(plate, level, classification)
    local text = plate.level
    if issecretvalue(level) then
        plate.levelValue = nil
        text:Hide()
        return
    end
    local s = settings[plate.state]
    local playerLevel = UnitLevel("player")
    local friendlyEnabled = plate.state ~= "friendly" or ns.DB.views.enemy.friendly.levelEnabled ~= false
    if plate.levelValue == level and plate.levelClass == classification and plate.levelPlayerLevel == playerLevel
        and plate.levelVersion == s.version and plate.levelSettings == s and plate.levelInstance == inInstance
        and plate.levelFriendlyEnabled == friendlyEnabled then
        return
    end
    plate.levelValue, plate.levelClass, plate.levelPlayerLevel = level, classification, playerLevel
    plate.levelVersion, plate.levelSettings, plate.levelInstance = s.version, s, inInstance
    plate.levelFriendlyEnabled = friendlyEnabled

    if not friendlyEnabled or (s.hideInInstances and inInstance) then
        text:Hide()
        return
    end

    if level <= 0 or classification == "worldboss" then
        if s.bossText == "hide" then
            text:Hide()
            return
        end
        text:SetText(BOSS_TEXT[s.bossText] or "??")
        text:SetTextColor(bossR, bossG, bossB)
        text:Show()
        return
    end

    if s.hideAtPlayerLevel and level == playerLevel and not ELITE[classification] then
        text:Hide()
        return
    end

    if s.hideTrivial and playerLevel - level > TrivialRange() then
        text:Hide()
        return
    end

    local rare = s.markRares and RARE[classification] and "r" or ""
    local plus = s.showElitePlus and ELITE[classification] and "+" or ""
    text:SetFormattedText("%d%s%s", level, rare, plus)

    if s.colorByDifficulty and GetCreatureDifficultyColor then
        local color = GetCreatureDifficultyColor(level)
        text:SetTextColor(color.r, color.g, color.b)
    else
        text:SetTextColor(s.r, s.g, s.b, s.a)
    end
    text:Show()
end

local zoneWatcher = CreateFrame("Frame")
zoneWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneWatcher:SetScript("OnEvent", function()
    local now = IsInInstance() == true
    if now ~= inInstance then
        inInstance = now
        ns.Driver:ForEachActive(function(plate)
            if ns.Runs(Level, plate) then
                Level:Update(plate, plate.unit)
            end
        end)
    end
end)

ns.Driver:RegisterElement(Level)
