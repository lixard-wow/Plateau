local _, ns = ...

local UnitIsRelatedToActiveQuest = C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest

local GetTooltipUnit = C_TooltipInfo and C_TooltipInfo.GetUnit
local OBJECTIVE = Enum.TooltipDataLineType and Enum.TooltipDataLineType.QuestObjective

local alphas = {}
local progress = {}
local atlasValid = {}

local function AtlasValid(atlas)
    local valid = atlasValid[atlas]
    if valid == nil then
        valid = C_Texture.GetAtlasInfo(atlas) ~= nil
        atlasValid[atlas] = valid
    end
    return valid
end

local Quest = {
    key = "quest",
    globalEvents = { "QUEST_LOG_UPDATE" },
}
ns.Elements = ns.Elements or {}
ns.Elements.Quest = Quest

function Quest:Create(plate)
    local icon = plate.overlay:CreateTexture(nil, "OVERLAY")
    icon:Hide()
    plate.quest = icon
    local text = plate.overlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("LEFT", icon, "RIGHT", 1, 0)
    text:Hide()
    plate.questProgress = text
end

local function Progress(unit)
    if not (GetTooltipUnit and OBJECTIVE) then return nil end
    local ok, data = pcall(GetTooltipUnit, unit)
    if not ok or not data or issecretvalue(data) or type(data.lines) ~= "table" then return nil end
    for _, line in ipairs(data.lines) do
        if line.type == OBJECTIVE and not issecretvalue(line.leftText) and type(line.leftText) == "string" then
            local done, total = line.leftText:match("(%d+)/(%d+)")
            if done and done ~= total then
                return done .. "/" .. total
            end
        end
    end
    return nil
end

function Quest:Configure(db, state)
    alphas[state] = db.alpha
    progress[state] = db.showProgress == true
end

function Quest:Style(plate, db)
    local icon = plate.quest
    icon:SetAtlas(AtlasValid(db.style) and db.style or "QuestNormal")
    icon:SetSize(db.size, db.size)
    ns.PlaceIcon(icon, plate, db.position, db.gap, db.offsetX, db.offsetY)
    ns.ApplyFont(plate.questProgress, STANDARD_TEXT_FONT, math.max(8, math.floor(db.size * 0.55)), "OUTLINE")
end

function Quest:Enable(plate, unit)
    self:Update(plate, unit)
end

function Quest:Disable(plate)
    plate.quest:Hide()
    plate.questProgress:Hide()
end

function Quest:OnEvent(plate, _, unit)
    self:Update(plate, plate.unit or unit)
end

function Quest:Update(plate, unit)
    local icon = plate.quest
    if not UnitIsRelatedToActiveQuest or not unit or plate.isPlayer
        or (ns.DB.views[plate.state].colors.questExcludeBoss and plate.mobType == "boss") then
        icon:Hide()
        plate.questProgress:Hide()
        return
    end
    local related = UnitIsRelatedToActiveQuest(unit)
    icon:SetAlphaFromBoolean(related, alphas[plate.state], 0)
    icon:Show()
    local text = progress[plate.state] and not issecretvalue(related) and related and Progress(unit)
    if text then
        plate.questProgress:SetText(text)
        plate.questProgress:Show()
    else
        plate.questProgress:Hide()
    end
end

function Quest:Preview(plate, state)
    local icon = plate.quest
    icon:SetAlpha(alphas[plate.state])
    local excluded = ns.DB.views[plate.state].colors.questExcludeBoss and state.mobType == "boss"
    icon:SetShown(state.quest == true and not excluded)
    plate.questProgress:SetText("3/8")
    plate.questProgress:SetShown(progress[plate.state] and state.quest == true and not excluded)
end

ns.Driver:RegisterElement(Quest)
