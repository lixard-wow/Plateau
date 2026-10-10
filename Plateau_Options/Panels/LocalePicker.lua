local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH = 460
local PAD = 20
local TOP = 116
local ROW = 26
local FOOTER = 56

local NAMES = {
    enUS = "English",
    deDE = "German",
    esES = "Spanish (Spain)",
    esMX = "Spanish (Mexico)",
    frFR = "French",
    itIT = "Italian",
    koKR = "Korean",
    ptBR = "Portuguese (Brazil)",
    ruRU = "Russian",
    zhCN = "Chinese (Simplified)",
    zhTW = "Chinese (Traditional)",
}

local frame = CreateFrame("Frame", "PlateauLocalePicker", UIParent)
frame:SetWidth(WIDTH)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()
Style.Panel(frame, C.window, C.border)
Style.Card(frame)
tinsert(UISpecialFrames, "PlateauLocalePicker")

local logo = frame:CreateTexture(nil, "ARTWORK")
logo:SetSize(22, 22)
logo:SetPoint("TOPLEFT", PAD, -14)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")

local title = Style.Text(frame, 15, C.text)
title:SetPoint("LEFT", logo, "RIGHT", 10, 0)
title:SetText("Translation check")

local intro = Style.Text(frame, 11, C.muted)
intro:SetPoint("TOPLEFT", PAD, -48)
intro:SetPoint("RIGHT", -PAD, 0)
intro:SetWordWrap(true)
intro:SetText("Show Plateau in another language to check a translation. Blizzard's own text stays in your game's language. The number is how many texts that language translates. Applying reloads your UI.")

local chosen, brackets
local rows = {}

local function Choices()
    local game = GetLocale()
    local list = { game }
    if not game:find("^en") then
        list[#list + 1] = "enUS"
    end
    for _, code in ipairs(Plateau.LANGUAGES) do
        if code ~= game then
            list[#list + 1] = code
        end
    end
    return list
end

local function RefreshRows()
    for _, row in ipairs(rows) do
        if row:IsShown() then
            row:Refresh()
        end
    end
end

local function LanguageRow(index)
    if rows[index] then return rows[index] end
    local spec = { label = "" }
    spec.get = function() return chosen == spec.code end
    spec.set = function()
        chosen = spec.code
        RefreshRows()
    end
    local row = Widgets.Toggle(frame, spec)
    row.spec = spec
    row:SetWidth(WIDTH - PAD * 2)
    row:SetPoint("TOPLEFT", PAD, -(TOP + (index - 1) * ROW))
    rows[index] = row
    return row
end

local bracketRow = Widgets.Toggle(frame, {
    label = "Show [[brackets]]",
    tooltip = "Wraps every text that can be translated in [[double brackets]]. Text without brackets can't be translated.",
    get = function() return brackets end,
    set = function(value) brackets = value end,
})
bracketRow:SetWidth(WIDTH - PAD * 2)

local applyButton = Widgets.PrimaryButton(frame, "Apply and reload", 150, function()
    local global = Plateau.DB.saved.global
    global.previewLocale = chosen ~= GetLocale() and chosen or nil
    global.pseudoLocale = brackets or nil
    ReloadUI()
end)
applyButton:SetPoint("BOTTOMRIGHT", -PAD, 14)

local cancelButton = Widgets.Button(frame, "Cancel", 90, function() frame:Hide() end)
cancelButton:SetPoint("RIGHT", applyButton, "LEFT", -8, 0)

frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:SetScript("OnEvent", function(self)
    self:Hide()
end)

function frame:Open()
    if InCombatLockdown() then return end
    local game = GetLocale()
    chosen = Plateau.PreviewLocale() or game
    brackets = Plateau.IsPseudoLocale()
    local list = Choices()
    for i, row in ipairs(rows) do
        row:SetShown(i <= #list)
    end
    for i, code in ipairs(list) do
        local row = LanguageRow(i)
        local name = NAMES[code] or code
        if code == game then
            row.spec.label = ("Game language: %s  |cff888888%d|r"):format(name, Plateau.LocaleCount(code))
        elseif code == "enUS" then
            row.spec.label = name
        else
            row.spec.label = ("%s  |cff888888%d|r"):format(name, Plateau.LocaleCount(code))
        end
        row.spec.code = code
        row:Refresh()
        row:Show()
    end
    local bottom = TOP + #list * ROW + 10
    bracketRow:ClearAllPoints()
    bracketRow:SetPoint("TOPLEFT", PAD, -bottom)
    bracketRow:Refresh()
    self:SetHeight(bottom + ROW + FOOTER + 6)
    self:Show()
end
