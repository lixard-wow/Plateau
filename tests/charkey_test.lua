local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
local playerName = "Unknown"
function UnitName() return playerName end
function GetRealmName() return "Classic Beta PvE 2" end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua")
local DB = ns.DB
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = {
    profileKeys = { ["Crookie - Classic Beta PvE 2"] = "Compact", ["Unknown - Classic Beta PvE 2"] = "Slim" },
    assignments = { ["Unknown - Classic Beta PvE 2"] = { content = {}, spec = {} } },
    profiles = { Default = {}, Compact = { look = { friendly = { nameMode = "lastWord" } } }, Slim = { look = { friendly = { nameMode = "firstWord" } } } },
}
DB:Init()
check(PlateauDB.profileKeys["Unknown - Classic Beta PvE 2"] == nil, "a character saved as Unknown is removed")
check(PlateauDB.assignments["Unknown - Classic Beta PvE 2"] == nil, "...and so are its automatic profile rules")
check(DB.charKey == nil, "while the game hasn't sent the character's name, no character key is used")
local keys = 0
for _ in pairs(PlateauDB.profileKeys) do keys = keys + 1 end
check(keys == 1, "loading before the name is known records nothing under any character")

playerName = "Crookie"
DB:ResolveCharacter()
check(DB.charKey == "Crookie - Classic Beta PvE 2", "at login the real character key is used")
check(DB.profileName == "Compact", "the character's own profile is loaded once its name is known")
check(DB.views.enemy.friendly.nameMode == "lastWord", "...so its saved settings are the ones in use")
DB:Set("look.friendly.nameMode", "firstWord")
check(PlateauDB.profiles.Compact.look.friendly.nameMode == "firstWord", "changes are saved to the character's own profile")

PlateauDB = { profiles = { Default = {} } }
playerName = "Unknown"
DB:Init()
playerName = "Newchar"
DB:ResolveCharacter()
check(PlateauDB.profileKeys["Newchar - Classic Beta PvE 2"] == DB.profileName, "a new character gets the profile it loaded with, saved under its real name")
