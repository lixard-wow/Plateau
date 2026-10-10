local _, ns = ...

local Style = ns.Style
local C = Style.colors

local WIDTH = 340
local PAD = 14

local STEPS = {
    {
        target = "window",
        place = "center",
        title = "Welcome to Plateau",
        text = "Customize every part of your enemy nameplates here. Skip this tour any time, and replay it from the Help page.",
    },
    {
        target = "preview",
        place = "below",
        title = "The live preview",
        text = "This sample nameplate shows your changes as you make them. Click a part to edit it, drag it to move it, and hold Shift to place it freely.",
    },
    {
        target = "snap",
        place = "below",
        title = "Snapping",
        text = "Snap pulls dragged parts onto guide dots. Turn it off to drop them anywhere.",
    },
    {
        target = "undo",
        place = "below",
        title = "Undo and redo",
        text = "Undo steps back through your last 20 changes, and Redo brings them back. Switching profiles clears the list.",
    },
    {
        target = "menu",
        place = "right",
        title = "The pages",
        text = "Each page holds one part of the nameplate. A dot beside a page means it differs from the default. Blizzard's own nameplate settings are on Game settings.",
    },
    {
        target = "search",
        place = "below",
        title = "Search",
        text = "Type a word to find any setting and jump straight to it, even one inside a collapsed section. On the Help page the same box searches only the help topics.",
    },
    {
        target = "minimize",
        place = "below",
        title = "Minimize",
        text = "Shrinks this window to a small bar so you can watch the game while you adjust settings. Click the icon, name or Restore to bring it back.",
    },
    {
        target = "profile",
        place = "above",
        title = "Profiles",
        text = "Your active profile, the one every page edits. Click it to switch or to manage profiles. Changes save automatically.",
    },
}

local callout = CreateFrame("Frame", "PlateauTour", UIParent)
callout:SetSize(WIDTH, 100)
callout:SetFrameStrata("FULLSCREEN_DIALOG")
callout:SetClampedToScreen(true)
callout:EnableMouse(true)
callout:Hide()
Style.Panel(callout, C.window, C.accent)
Style.Card(callout)

local outline = CreateFrame("Frame", nil, UIParent)
outline:SetFrameStrata("FULLSCREEN_DIALOG")
outline:EnableMouse(false)
outline:Hide()
Style.Border(outline, C.accent)

local counter = Style.Text(callout, 10, C.muted)
counter:SetPoint("TOPRIGHT", -PAD, -PAD)

local title = Style.Text(callout, 14, C.text)
title:SetPoint("TOPLEFT", PAD, -PAD)
title:SetPoint("RIGHT", counter, "LEFT", -8, 0)

local body = Style.Text(callout, 12, C.text)
body:SetWordWrap(true)
body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
body:SetWidth(WIDTH - PAD * 2)

local index = 0
local Show

local function Finish()
    index = 0
    callout:Hide()
    outline:Hide()
    Plateau.DB.saved.global.tourDone = true
end

local function Resolve(step)
    local target = ns.tour and ns.tour[step.target]
    if target and target:IsShown() then
        return target
    end
    return nil
end

local backButton, nextButton, skipButton

function Show(step)
    local number = step
    local data = STEPS[number]
    while data and not Resolve(data) do
        number = number + 1
        data = STEPS[number]
    end
    if not data then
        Finish()
        return
    end
    index = number
    local target = Resolve(data)
    local tint = Style.StateColor()
    Style.SetBorderColor(callout, tint)
    Style.SetBorderColor(outline, tint)

    counter:SetFormattedText("%d of %d", number, #STEPS)
    title:SetText(data.title)
    body:SetText(data.text)
    nextButton.label:SetText(number == #STEPS and "Done" or "Next")
    backButton:SetShown(number > 1)
    skipButton:SetShown(number < #STEPS)
    callout:SetHeight(PAD + 18 + 8 + math.ceil(body:GetStringHeight()) + 14 + 24 + PAD)

    callout:ClearAllPoints()
    if data.place == "center" then
        callout:SetPoint("CENTER", target, "CENTER", 0, 0)
        outline:Hide()
    else
        outline:ClearAllPoints()
        outline:SetPoint("TOPLEFT", target, "TOPLEFT", -3, 3)
        outline:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 3, -3)
        outline:Show()
        if data.place == "below" then
            callout:SetPoint("TOP", target, "BOTTOM", 0, -14)
        elseif data.place == "above" then
            callout:SetPoint("BOTTOM", target, "TOP", 0, 14)
        else
            callout:SetPoint("LEFT", target, "RIGHT", 14, 0)
        end
    end
    callout:Show()
end

backButton = ns.Widgets.Button(callout, "Back", 70, function()
    local previous = index - 1
    while previous >= 1 and not Resolve(STEPS[previous]) do
        previous = previous - 1
    end
    if previous >= 1 then
        Show(previous)
    end
end)
backButton:SetPoint("BOTTOMLEFT", PAD, PAD)

nextButton = ns.Widgets.PrimaryButton(callout, "Next", 80, function()
    if index >= #STEPS then
        Finish()
    else
        Show(index + 1)
    end
end)
nextButton:SetPoint("BOTTOMRIGHT", -PAD, PAD)

skipButton = ns.Widgets.Button(callout, "Skip tour", 90, Finish)
skipButton:SetPoint("RIGHT", nextButton, "LEFT", -8, 0)

function ns.StartTour()
    if InCombatLockdown() then return end
    if PlateauSetup and PlateauSetup:IsShown() then return end
    if not PlateauOptions:IsShown() then
        PlateauOptions:Toggle()
    end
    ns.HideDropdownList()
    Show(1)
end

PlateauOptions:HookScript("OnHide", function()
    if callout:IsShown() then
        Finish()
    end
end)

PlateauOptions:HookScript("OnShow", function()
    if Plateau.DB.saved.global.tourDone then return end
    C_Timer.After(0.4, function()
        if PlateauOptions:IsShown() and not Plateau.DB.saved.global.tourDone and not callout:IsShown()
            and not (PlateauSetup and PlateauSetup:IsShown()) then
            ns.StartTour()
        end
    end)
end)
