local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
assert(loadfile("Plateau/Core/Locale.lua"))("Plateau", ns)
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

check(DB.newCharacter == true, "a character named after login with no saved profile is new")
DB:Shutdown()
playerName = "Freshalt"
DB:Init()
check(DB.newCharacter == false, "a new character on an account with a profile for new characters skips setup")
check(DB.profileName == PlateauDB.global.accountProfile, "...and starts with that profile")
DB:Shutdown()
DB:Init()
check(DB.newCharacter == false, "...and only on its first login")
PlateauDB = nil
playerName = "Firstever"
DB:Init()
check(DB.newCharacter == false, "the very first character on a fresh install gets the normal first-run setup instead")

PlateauDB = {
    profileKeys = { ["Main - Realm"] = "Mine", ["Alt - Realm"] = "Mine", ["Other - Realm"] = "Slim" },
    profiles = { Default = {}, Mine = { look = { friendly = { nameMode = "lastWord" } } }, Slim = {} },
}
playerName = "Brandnew"
DB:Init()
check(PlateauDB.global.accountProfile == "Mine", "an account without a profile for new characters picks the one most characters use")
check(DB.profileName == "Mine", "a new character starts with it instead of Default")
check(DB.views.enemy.friendly.nameMode == "lastWord", "...with that profile's settings")
check(DB.newCharacter == false, "...and doesn't need setup")
DB:Shutdown()

check(DB:SetAccountProfile("Slim") == true, "the profile for new characters can be changed")
check(DB:SetAccountProfile("Missing") == false, "...but only to a profile that exists")
DB:RenameProfile("Slim", "Thin")
check(PlateauDB.global.accountProfile == "Thin", "renaming it keeps it as the profile for new characters")
DB:DeleteProfile("Thin")
check(PlateauDB.global.accountProfile == nil, "deleting it clears the choice")
check(DB:NewCharacterProfile() == DB.fallbackName, "...and new characters fall back to the usual profile")

PlateauDB = { profileKeys = { ["Main - Realm"] = "Mine" }, profiles = { Mine = {} }, global = { accountProfile = "Gone" } }
playerName = "Another"
DB:Init()
check(DB:AccountProfile() == "Mine", "a profile for new characters that no longer exists is replaced by the one most characters use")
check(DB.profileName == "Mine", "...and the new character starts with it")

PlateauDB = { profileKeys = { ["Main - Realm"] = "Gone" }, profiles = { Default = {} } }
playerName = "Lonely"
DB:Init()
check(DB:AccountProfile() == nil, "with no usable profile to pick, none is chosen")
check(DB.newCharacter == true, "...so the new character gets setup")
