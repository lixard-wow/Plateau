local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local said = {}
local frames = {}
local inCombat = false
local registered = {}

function GetLocale() return "enUS" end
function date() return "12:00:00 " end
function InCombatLockdown() return inCombat end
local NOOP = function() end
local function Stub(fields)
    return setmetatable(fields or {}, { __index = function() return NOOP end })
end

function CreateFrame()
    local frame = Stub({ scripts = {}, events = {} })
    function frame:SetText(text) self.text = text end
    function frame:CreateTexture() return Stub() end
    function frame:RegisterEvent(event) self.events[event] = true end
    function frame:UnregisterEvent(event) self.events[event] = nil end
    function frame:UnregisterAllEvents() self.events = {} end
    function frame:SetScript(name, fn) self.scripts[name] = fn end
    frames[#frames + 1] = frame
    return frame
end

Plateau = {
    RegisterCallback = function(owner, event) registered[event] = owner end,
    UnregisterAllCallbacks = function() registered = {} end,
}

local ns = {}
PlateauDB = { global = { setupDone = true } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
assert(loadfile("Plateau/Core/Debug.lua"))("Plateau", ns)
function ns.Say(message) said[#said + 1] = message end
function ns.WarmThemeFonts() end
C_AddOns = { LoadAddOn = function() return false end }
frames[1].scripts.OnEvent(frames[1], "ADDON_LOADED", "Plateau")

check(#frames == 1, "loading the debug file makes only its loader frame")
check(next(registered) == nil, "nothing is hooked until a debug feature is turned on")

ns.Debug("ignored")
ns.RunDebug("showlog")
check(said[#said] == "Couldn't load Plateau_Options for the debug window.", "the debug window says so when the settings addon cannot load")

inCombat = true
said = {}
ns.RunDebug(nil)
check(said[1] == "The debug window opens after combat.", "an empty /plt debug in combat waits for combat to end")
local waiter = frames[#frames]
check(waiter.events.PLAYER_REGEN_ENABLED == true, "the window is queued for the end of combat")
ns.RunDebug("nonsense")
check(#frames == 2, "unknown input falls back to the list and reuses the same waiter")
inCombat = false
said = {}
waiter.scripts.OnEvent(waiter, "PLAYER_REGEN_ENABLED")
check(waiter.events.PLAYER_REGEN_ENABLED == nil and said[1] == "Couldn't load Plateau_Options for the debug window.", "the queued window opens once after combat")

ns.RunDebug("listed")
check(PlateauDB.debug.listed == true and ns.DebugListed() == true, "toggles save under their own debug key")
check(PlateauDB.global.listed == nil, "toggles never touch the real settings")
ns.RunDebug("listed")
check(PlateauDB.debug.listed == nil and ns.DebugListed() == false, "a toggle switches back off")

ns.RunDebug("log")
check(registered.PLATE_ADDED ~= nil and registered.CAST_START ~= nil, "turning the log on hooks plate and cast events")
local logFrame = frames[#frames]
check(logFrame.events.PLAYER_REGEN_DISABLED == true, "turning the log on listens for combat")
for i = 1, 250 do
    ns.Debug("line", i)
end
ns.RunDebug("log")
check(next(registered) == nil and next(logFrame.events) == nil, "turning the log off removes every hook")

UISpecialFrames, CLOSE = {}, "Close"
function tinsert(t, v) t[#t + 1] = v end
local function Text() return Stub({ SetText = function(self, text) self.text = text end }) end
Plateau.Kit = {
    Style = { colors = {}, Dialog = function() return CreateFrame() end, Text = Text, ButtonBox = NOOP, PaintText = NOOP, DragWindow = NOOP },
    Widgets = { Button = function() return CreateFrame() end, PrimaryButton = function() return CreateFrame() end },
}
ns.RunDebug("showlog")
local box
for _, frame in ipairs(frames) do
    if type(frame.text) == "string" and frame.text:find("line") then box = frame end
end
local shownLines = {}
for line in (box and box.text or ""):gmatch("[^\n]+") do
    shownLines[#shownLines + 1] = line
end
check(#shownLines == 200, "the log keeps only the last 200 lines")
check(shownLines[1] == "12:00:00 line 51" and shownLines[200] == "12:00:00 line 250", "the log shows the newest 200 lines oldest first")

ns.RunDebug("clearlog")
said = {}
ns.RunDebug("showlog")
check(box.text == "Nothing recorded. Turn on Event log first.", "clear log forgets every line")

PlateauDB.debug.echo = true
said = {}
ns.Debug("after off")
check(#said == 0, "nothing is recorded or printed once the log is off")

ns.RunDebug("wipe")
check(PlateauDB.debug == nil and PlateauDB.global.setupDone == true, "reset debug settings clears only the debug key")
check(said[#said] == "Debug settings cleared.", "reset reports through the one output function")
