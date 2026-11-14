local addonName, ns = ...

ns.DEBUG_BUILD = true

local L = ns.L

local LOG_SIZE = 200
local PAD = 20
local WIDTH = 420
local ROW = 40
local GAP = 4
local TOP = 52
local FOOTER = 52
local ICON = "Interface\\AddOns\\Plateau\\Art\\icon"
local ON, OFF, PENDING = "On", "Off", "  (reload)"
local AFTER_COMBAT = "The debug window opens after combat."
local NO_KIT = "Couldn't load Plateau_Options for the debug window."
local RELOAD = "Reload to apply."

local LANGUAGES = { "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" }
local LANGUAGE_NAMES = {
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

local RESTRICTIONS = { "Combat", "Encounter", "ChallengeMode", "PvPMatch", "Map" }

local GAME_EVENTS = {
    "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "ZONE_CHANGED_NEW_AREA", "ENCOUNTER_START", "ENCOUNTER_END",
    "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED", "ADDON_RESTRICTION_STATE_CHANGED",
}

local function Chat(message, continued)
    ns.Say(message, continued)
end

local function State()
    if type(PlateauDB) ~= "table" then
        PlateauDB = {}
    end
    if type(PlateauDB.debug) ~= "table" then
        PlateauDB.debug = {}
    end
    local state = PlateauDB.debug
    local global = PlateauDB.global
    if type(global) == "table" and (global.previewLocale ~= nil or global.pseudoLocale ~= nil) then
        state.previewLocale = state.previewLocale or global.previewLocale
        state.pseudoLocale = state.pseudoLocale or global.pseudoLocale
        global.previewLocale, global.pseudoLocale = nil, nil
    end
    return state
end

local function Show(value)
    if issecretvalue and issecretvalue(value) then
        return L["hidden"]
    end
    return tostring(value)
end

local staged = {}
local counts = {}
local applied = {}

function ns.LocaleFile(code)
    if code == GetLocale() then
        return L
    end
    local entries = {}
    if staged then
        staged[code] = entries
    end
    return entries
end

local function Filled(entries)
    local count = 0
    for key, value in pairs(entries) do
        if type(key) == "string" and type(value) == "string" and value ~= "" then
            count = count + 1
        end
    end
    return count
end

local function Brackets()
    local meta = getmetatable(L)
    local lookup = meta.__index
    meta.__index = function(self, key)
        local value = lookup(self, key)
        if type(key) == "string" and key ~= "" then
            return "[[" .. value .. "]]"
        end
        return value
    end
end

local function ApplyLanguage()
    if not staged then return end
    for code, entries in pairs(staged) do
        counts[code] = Filled(entries)
    end
    counts[GetLocale()] = ns.TranslatedCount()
    local state = State()
    local code = state.previewLocale
    if code and code ~= GetLocale() then
        ns.UseLocale(code, staged[code] or {})
    end
    staged = nil
    applied.previewLocale = code
    applied.pseudoLocale = state.pseudoLocale == true
    if applied.pseudoLocale then
        Brackets()
    end
end

local log, logNext, logCount = nil, 1, 0
local logging = false
local logFrame

function ns.Debug(...)
    if not logging then return end
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = Show((select(i, ...)))
    end
    local line = date("%H:%M:%S ") .. table.concat(parts, " ")
    log[logNext] = line
    logNext = logNext % LOG_SIZE + 1
    logCount = math.min(logCount + 1, LOG_SIZE)
    if State().echo then
        Chat(line, true)
    end
end

local function LogLines()
    local lines = {}
    if not log then return lines end
    local first = logCount < LOG_SIZE and 1 or logNext
    for i = 0, logCount - 1 do
        lines[#lines + 1] = log[(first - 1 + i) % LOG_SIZE + 1]
    end
    return lines
end

local function Quiet() end

local function LogFire(event, unit, plate)
    if event == "PLATE_ADDED" then
        ns.Debug("plate added", unit, plate.state, plate.mobType)
    elseif event == "PLATE_REMOVED" then
        ns.Debug("plate removed", unit)
    elseif event == "CAST_START" then
        ns.Debug("cast start", unit)
    end
end

local function SetLogging(on)
    if on == logging then return end
    logging = on
    if on then
        log = log or {}
        ns.Fire = LogFire
        if not logFrame then
            logFrame = CreateFrame("Frame")
            logFrame:SetScript("OnEvent", function(_, event, ...)
                ns.Debug(event, ...)
            end)
        end
        for _, event in ipairs(GAME_EVENTS) do
            pcall(logFrame.RegisterEvent, logFrame, event)
        end
    else
        ns.Fire = Quiet
        if logFrame then
            logFrame:UnregisterAllEvents()
        end
    end
end

local function ClearLog()
    log = logging and {} or nil
    logNext, logCount = 1, 0
end

local function ColorLines(lines)
    for _, unit in ipairs({ "target", "focus" }) do
        local shown = ns.Driver:GetPlate(unit)
        if shown then
            local look = ns.DB.views.enemy
            local override = (shown.isTarget and look.target.colorBar and L["Target page: Use custom target color"])
                or (shown.isFocus and look.focus.colorBar and L["Focus page: Use custom focus color"])
            local r, g, b = shown.health:GetStatusBarColor()
            local current = (not issecretvalue(r) and r) and ("%.2f %.2f %.2f"):format(r, g, b) or L["hidden"]
            lines[#lines + 1] = (unit == "target" and L["Target color: %s  [bar now %s]"] or L["Focus color: %s  [bar now %s]"]):format(
                override or ns.UnitColors:Explain(shown, unit), current)
        end
    end
    return lines
end

local function ReportLines()
    local total, claimed = ns.Driver:CountActive()
    local lines = { L["%s (%s), profile %s"]:format(ns.version, ns.flavor, ns.DB.profileName) }
    local active = {}
    local states = C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
    if states then
        for _, name in ipairs(RESTRICTIONS) do
            local kind = Enum.AddOnRestrictionType[name]
            if kind and states(kind) == Enum.AddOnRestrictionState.Active then
                active[#active + 1] = name
            end
        end
    end
    lines[#lines + 1] = L["Restrictions active: %s"]:format(#active > 0 and table.concat(active, ", ") or L["none"])
    lines[#lines + 1] = L["Plates: %d showing, %d drawn by Plateau"]:format(total, claimed)
    if ns.realmPurgeFailed then
        lines[#lines + 1] = L["Realm marker cleanup failed. Blizzard's friendly nameplates may show errors."]
    end
    local failures = ns.DB.migrationFailures
    if ns.recovered or (failures and #failures > 0) then
        lines[#lines + 1] = L["Saved settings: %s"]:format(ns.recovered and L["recovered from damage (%s)"]:format(tostring(ns.recovered)) or L["upgrade problems: %s"]:format(table.concat(failures, "; ")))
    end
    if ns.BossPhaseStatus then
        local encounter, problem = ns.BossPhaseStatus()
        if problem then
            lines[#lines + 1] = L["Boss phase lines: encounter %s, last problem: %s"]:format(tostring(encounter or L["none"]), tostring(problem))
        else
            lines[#lines + 1] = L["Boss phase lines: encounter %s"]:format(tostring(encounter or L["none"]))
        end
    end
    local kickID = ns.InterruptReady:GetSpellID()
    lines[#lines + 1] = L["Interrupt: %s"]:format(kickID and (C_Spell.GetSpellName(kickID) or kickID) or L["none found"])
    ColorLines(lines)
    local plate = ns.Driver:GetPlate("target")
    if plate then
        lines[#lines + 1] = L["Target: state %s, enemy type %s, boss %s, classification %s, level %s"]:format(
            plate.state, tostring(plate.mobType), Show(UnitIsBossMob("target")), Show(UnitClassification("target")),
            Show(UnitEffectiveLevel("target")))
        local family = plate.name:GetFontObject()
        lines[#lines + 1] = L["Name font: %s, font family %s, font families allowed %s, problem %s"]:format(
            tostring((plate.name:GetFont())), tostring(family and family:GetName()), tostring(CreateFontFamily ~= nil),
            tostring(ns.fontFamilyProblem or L["none"]))
    else
        lines[#lines + 1] = L["Target: none"]
    end
    return lines
end

local function PrintLines(lines)
    Chat(lines[1])
    for i = 2, #lines do
        Chat(lines[i], true)
    end
end

local waiter, waiting

local function WhenSafe(open)
    if not InCombatLockdown() then
        open()
        return
    end
    waiting = open
    if not waiter then
        waiter = CreateFrame("Frame")
        waiter:SetScript("OnEvent", function(self)
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            local run = waiting
            waiting = nil
            if run then
                run()
            end
        end)
    end
    waiter:RegisterEvent("PLAYER_REGEN_ENABLED")
    Chat(AFTER_COMBAT)
end

local function Kit()
    if not Plateau.Kit then
        ns.WarmThemeFonts()
        C_AddOns.LoadAddOn("Plateau_Options")
    end
    if not Plateau.Kit then
        Chat(NO_KIT)
    end
    return Plateau.Kit
end

local function Dialog(kit, name, heading, width)
    local Style = kit.Style
    local frame = Style.Dialog(name, width)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    Style.DragWindow(frame, { frame }, Style.SnapWindow)
    tinsert(UISpecialFrames, name)
    local logo = frame:CreateTexture(nil, "ARTWORK")
    logo:SetSize(22, 22)
    logo:SetPoint("TOPLEFT", PAD, -14)
    logo:SetTexture(ICON)
    frame.heading = Style.Text(frame, 15, Style.colors.text)
    frame.heading:SetPoint("LEFT", logo, "RIGHT", 10, 0)
    frame.heading:SetText(heading)
    frame.closeButton = kit.Widgets.Button(frame, CLOSE, 90, function() frame:Hide() end)
    frame.closeButton:SetPoint("BOTTOMRIGHT", -PAD, 14)
    frame.rows = {}
    return frame
end

local function Row(kit, frame, index)
    if frame.rows[index] then return frame.rows[index] end
    local Style, C = kit.Style, kit.Style.colors
    local row = CreateFrame("Button", nil, frame)
    row:SetHeight(ROW)
    row:SetPoint("TOPLEFT", PAD, -(TOP + (index - 1) * (ROW + GAP)))
    row:SetPoint("RIGHT", -PAD, 0)
    Style.ButtonBox(row, C.field, nil, C.border, C.hover)
    row.name = Style.Text(row, 12, C.text)
    row.name:SetPoint("TOPLEFT", 10, -6)
    row.name:SetPoint("RIGHT", -80, 0)
    row.about = Style.Text(row, 11, C.muted)
    row.about:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -3)
    row.about:SetPoint("RIGHT", -80, 0)
    row.state = Style.Text(row, 11, C.muted, "RIGHT")
    row.state:SetPoint("RIGHT", -10, 0)
    function row:Fill(name, about, state, lit)
        self.name:SetText(name)
        self.about:SetText(about)
        self.state:SetText(state or "")
        Style.PaintText(self.state, lit and C.accent or C.muted)
        self:Show()
    end
    frame.rows[index] = row
    return row
end

local function Fit(frame, count)
    for i = count + 1, #frame.rows do
        frame.rows[i]:Hide()
    end
    frame:SetHeight(TOP + count * (ROW + GAP) + FOOTER)
end

local textBox

local function ShowText(heading, lines)
    WhenSafe(function()
        local kit = Kit()
        if not kit then return end
        if not textBox then
            local width = 560
            textBox = Dialog(kit, "PlateauDebugText", "", width)
            textBox:SetHeight(400)
            local scroll = CreateFrame("ScrollFrame", nil, textBox, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", PAD, -TOP)
            scroll:SetPoint("BOTTOMRIGHT", -PAD - 24, FOOTER)
            local edit = CreateFrame("EditBox", nil, scroll)
            edit:SetMultiLine(true)
            edit:SetAutoFocus(false)
            edit:SetFontObject(ChatFontNormal)
            edit:SetWidth(width - PAD * 2 - 24)
            edit:SetScript("OnEscapePressed", function() textBox:Hide() end)
            edit:SetScript("OnTextChanged", function(self, typed)
                if typed then
                    self:SetText(textBox.content or "")
                    self:HighlightText()
                end
            end)
            edit:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
            scroll:SetScrollChild(edit)
            textBox.edit = edit
        end
        textBox.heading:SetText(heading)
        textBox.content = table.concat(lines, "\n")
        textBox.edit:SetText(textBox.content)
        textBox:Show()
        textBox.edit:SetFocus()
    end)
end

local languages, chosen

local function LanguageChoices()
    local game = GetLocale()
    local choices = { game }
    if not game:find("^en") then
        choices[#choices + 1] = "enUS"
    end
    for _, code in ipairs(LANGUAGES) do
        if code ~= game then
            choices[#choices + 1] = code
        end
    end
    return choices
end

local function RefreshLanguages()
    local kit = Plateau.Kit
    local game = GetLocale()
    local choices = LanguageChoices()
    for i, code in ipairs(choices) do
        local row = Row(kit, languages, i)
        local about
        if code == "enUS" then
            about = "Plateau's own text"
        elseif code == game then
            about = ("Game language, %d translated texts"):format(counts[code] or 0)
        else
            about = ("%d translated texts"):format(counts[code] or 0)
        end
        row:Fill(LANGUAGE_NAMES[code] or code, about, chosen == code and "Chosen" or nil, chosen == code)
        row:SetScript("OnClick", function()
            chosen = code
            RefreshLanguages()
        end)
    end
    Fit(languages, #choices)
end

local function OpenLanguages()
    WhenSafe(function()
        local kit = Kit()
        if not kit then return end
        if not languages then
            languages = Dialog(kit, "PlateauDebugLanguages", "Translation check", WIDTH)
            local apply = kit.Widgets.PrimaryButton(languages, "Apply and reload", 150, function()
                State().previewLocale = chosen ~= GetLocale() and chosen or nil
                ReloadUI()
            end)
            apply:SetPoint("RIGHT", languages.closeButton, "LEFT", -8, 0)
        end
        chosen = applied.previewLocale or GetLocale()
        RefreshLanguages()
        languages:Show()
    end)
end

local list
local COMMANDS

local function ToggleState(entry)
    local on = State()[entry.toggle] == true
    local text = on and ON or OFF
    if entry.reload and on ~= (applied[entry.toggle] == true) then
        text = text .. PENDING
    end
    return text, on
end

local function RefreshList()
    if not (list and list:IsShown()) then return end
    for i, entry in ipairs(COMMANDS) do
        local row = Row(Plateau.Kit, list, i)
        local state, lit
        if entry.toggle then
            state, lit = ToggleState(entry)
        end
        row:Fill(entry.name, entry.about, state, lit)
        row:SetScript("OnClick", function()
            entry.Activate()
            RefreshList()
        end)
    end
    Fit(list, #COMMANDS)
end

local function OpenList()
    WhenSafe(function()
        local kit = Kit()
        if not kit then return end
        if not list then
            list = Dialog(kit, "PlateauDebug", "Plateau debug", WIDTH)
        end
        list:Show()
        RefreshList()
    end)
end

local function Wipe()
    local reload = applied.previewLocale ~= nil or applied.pseudoLocale
    SetLogging(false)
    log, logNext, logCount = nil, 1, 0
    PlateauDB.debug = nil
    Chat("Debug settings cleared." .. (reload and " " .. RELOAD or ""))
end

COMMANDS = {
    { key = "report", name = "Bug report", about = "Print version, profile and target details to chat.",
      run = function() PrintLines(ReportLines()) end },
    { key = "copy", name = "Copy bug report", about = "The same details in a box you can copy.",
      run = function() ShowText("Bug report", ReportLines()) end },
    { key = "color", name = "Why this color", about = "Explain the target and focus health bar colors.",
      run = function()
          local lines = ColorLines({ "Health bar colors" })
          if #lines == 1 then
              lines[2] = L["Target: none"]
          end
          PrintLines(lines)
      end },
    { key = "log", name = "Event log", about = ("Record plate, cast, combat and zone events (last %d)."):format(LOG_SIZE),
      toggle = "log", apply = SetLogging },
    { key = "echo", name = "Log to chat", about = "Also print each log line to chat while the log runs.",
      toggle = "echo" },
    { key = "showlog", name = "Show log", about = "Open the recorded lines in a box you can copy.",
      run = function()
          local lines = LogLines()
          if #lines == 0 then
              lines[1] = "Nothing recorded. Turn on Event log first."
          end
          ShowText("Event log", lines)
      end },
    { key = "clearlog", name = "Clear log", about = "Forget every recorded line.",
      run = ClearLog },
    { key = "language", aliases = { "locale" }, name = "Translation check", about = "Show Plateau in another language. Reloads.",
      run = OpenLanguages },
    { key = "brackets", name = "Show [[brackets]]", about = "Wrap every translatable text in brackets.",
      toggle = "pseudoLocale", reload = true },
    { key = "listed", name = "List in /plt help", about = "Show /plt debug in the /plt command list.",
      toggle = "listed" },
    { key = "wipe", name = "Reset debug settings", about = "Turn everything here off and clear the log.",
      run = Wipe },
}

local byKey = {}

for _, entry in ipairs(COMMANDS) do
    byKey[entry.key] = entry
    for _, alias in ipairs(entry.aliases or {}) do
        byKey[alias] = entry
    end
    if entry.toggle then
        entry.Activate = function()
            local state = State()
            local on = state[entry.toggle] ~= true
            state[entry.toggle] = on or nil
            if entry.apply then
                entry.apply(on)
            end
            Chat(("%s: %s"):format(entry.name, (ToggleState(entry))) .. (entry.reload and " " .. RELOAD or ""))
        end
    else
        entry.Activate = entry.run
    end
end

function ns.RunDebug(key)
    local entry = key and byKey[key]
    if entry then
        entry.Activate()
        RefreshList()
    else
        OpenList()
    end
end

function ns.DebugListed()
    return State().listed == true
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
    if name ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    self:SetScript("OnEvent", nil)
    ApplyLanguage()
    if State().log then
        SetLogging(true)
    end
end)
