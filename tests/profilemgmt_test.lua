LibDeflate = dofile("Plateau/Libs/LibDeflate/LibDeflate.lua")
local ns = { Driver = { Restyle = function() end, RequestRestyle = function() end } }
local character = "Stalador"
function UnitName() return character end
function GetRealmName() return "Iridikron" end
local instance, spec, combat = "none", 1, false
function IsInInstance() return instance ~= "none", instance end
C_SpecializationInfo = {
    GetSpecialization = function() return spec end,
    GetSpecializationInfo = function(index) return index, ({ "Arcane", "Fire", "Frost" })[index] end,
}
function InCombatLockdown() return combat end
function issecretvalue() return false end
function CreateFrame() return { RegisterEvent = function() end, RegisterUnitEvent = function() end, SetScript = function() end } end
local function load(path) assert(loadfile("Plateau/" .. path))("Plateau", ns) end
load("Core/Defaults.lua"); load("Core/Database.lua"); load("Core/Share.lua"); load("Core/AutoProfile.lua")
local DB, Auto = ns.DB, ns.AutoProfile
local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

PlateauDB = nil
DB:Init()
DB:CreateProfile("Raid")
DB:CreateProfile("Tank")
DB:CreateProfile("Solo")
DB:SwitchProfile("Default")
local key = "Stalador - Iridikron"

check(DB:DefaultProfile() == "Default" and DB.profileName == "Default", "default and active start out the same")
local status = Auto:Status()
check(status.default == "Default" and status.active == "Default" and not status.overridden and not status.rule and not status.pending, "no override, no rule, nothing pending")

Auto:Set("content", "raid", "Raid")
Auto:Set("spec", 2, "Tank")
instance = "raid"; Auto:Apply()
status = Auto:Status()
check(DB.profileName == "Raid" and DB:DefaultProfile() == "Default", "a raid override changes the active profile only")
check(status.overridden and status.rule == "Raid override" and status.default == "Default", "the status names the override reason")
instance = "none"; spec = 2; Auto:Apply()
status = Auto:Status()
check(DB.profileName == "Tank" and status.rule == "Fire specialization", "a specialization override is named with the dynamic specialization")
instance = "raid"; Auto:Apply()
check(DB.profileName == "Raid" and Auto:Status().rule == "Raid override", "content wins over specialization")
instance = "none"; spec = 1; Auto:Apply()
check(DB.profileName == "Default" and not Auto:Status().overridden, "with no rule the default profile is used")

instance = "raid"; Auto:Apply()
DB:Set("look.castbar.height", 27)
check(PlateauDB.profiles.Raid.look.castbar.height == 27 and DB:Get("look.castbar.height") == 27, "editing during an override changes the active profile")
DB:SwitchProfile("Default", true)
check(DB.saved.profiles.Default.look == nil or DB.saved.profiles.Default.look.castbar == nil or DB.saved.profiles.Default.look.castbar.height ~= 27, "the default profile was not edited by the override")
Auto:Apply(true)
check(DB.profileName == "Raid", "the override returns")

local ok = DB:SetDefaultProfile("Solo")
check(ok and DB:DefaultProfile() == "Solo" and DB.profileName == "Raid", "changing the default keeps an active override")
instance = "none"; Auto:Apply()
check(DB.profileName == "Solo", "leaving the content falls back to the new default")
DB:SetDefaultProfile("Default")
check(DB.profileName == "Default", "setting the default with no rule applies it")

combat = true
instance = "raid"; Auto:Apply()
status = Auto:Status()
check(DB.profileName == "Default" and status.pending == "Raid", "a switch waiting for combat is reported as pending")
instance = "dungeon"; Auto:Apply()
check(Auto:Status().pending == nil or Auto:Status().pending == "Default", "moving on while waiting updates the pending target")
instance = "raid"
combat = false; Auto:Apply()
check(DB.profileName == "Raid" and not Auto:Status().pending, "the pending switch resolves to the latest applicable profile")
instance = "none"; Auto:Apply()

combat = true
local activated, state = DB:ActivateProfile("Solo")
check(activated and state == "deferred" and DB.profileName == "Default" and DB:DefaultProfile() == "Solo", "activating during combat sets the default and defers the switch")
combat = false; Auto:Apply()
check(DB.profileName == "Solo", "the deferred activation applies after combat")
DB:SetDefaultProfile("Default")

instance = "raid"; Auto:Apply()
check(DB.profileName == "Raid", "override active before copying")
DB:CreateProfile("Source")
DB:Set("look.castbar.height", 33)
DB:SwitchProfile("Default")
DB:SetDefaultProfile("Default")
instance = "raid"; Auto:Apply(true)
check(DB.profileName == "Raid", "raid override active again")
check(DB:CopyProfile("Source"), "copy settings into the active profile")
check(DB:DefaultProfile() == "Default", "copying while overridden keeps the default profile")
check(DB.saved.profiles.Raid.look.castbar.height == 33, "the copy went into the active profile")
check(not DB.saved.profiles.Default.look or not DB.saved.profiles.Default.look.castbar or DB.saved.profiles.Default.look.castbar.height ~= 33, "no other profile changed")
instance = "none"; Auto:Apply()

local refs = DB:ProfileReferences("Tank")
check(#refs.assignments == 1 and refs.assignments[1].kind == "spec" and refs.assignments[1].key == 2 and refs.assignments[1].character == key, "references list the specialization assignment")
check(#refs.defaultFor == 0, "an unused profile is nobody's default")
DB.saved.profileKeys["Other - Iridikron"] = "Tank"
DB.saved.assignments["Other - Iridikron"] = { content = { dungeon = "Tank" }, spec = {} }
refs = DB:ProfileReferences("Tank")
check(#refs.defaultFor == 1 and refs.defaultFor[1] == "Other - Iridikron" and #refs.assignments == 2, "references include other characters")

local renamed, newName = DB:RenameProfile("Tank", "  Main tank  ")
check(renamed and newName == "Main tank", "rename trims the name")
check(DB.saved.profiles.Tank == nil and DB.saved.profiles["Main tank"] ~= nil, "the old name is gone")
check(DB.saved.profileKeys["Other - Iridikron"] == "Main tank", "another character's default follows the rename")
check(Auto:Get("spec", 2) == "Main tank" and DB.saved.assignments["Other - Iridikron"].content.dungeon == "Main tank", "automatic assignments follow the rename")
spec = 2; Auto:Apply(true)
check(DB.profileName == "Main tank", "the renamed profile still switches in automatically")
check(DB:RenameProfile("Main tank", "Tank2") and DB.profileName == "Tank2" and DB:DefaultProfile() == "Default", "renaming the active override keeps the default profile")
DB:RenameProfile("Tank2", "Tank")
spec = 1; Auto:Apply(true)
check(not DB:RenameProfile("Tank", "Solo"), "a duplicate name is refused")
check(not DB:RenameProfile("Tank", "   "), "an empty name is refused")
check(not DB:RenameProfile("Tank", "Tank"), "renaming to the same name is refused")
check(not DB:RenameProfile("Nope", "Anything"), "renaming a missing profile is refused")
check(DB.saved.profiles.Solo ~= nil and DB.saved.profiles.Tank ~= nil, "refused renames changed nothing")
DB:SwitchProfile("Default")
check(DB:RenameProfile("Default", "Base") and DB:DefaultProfile() == "Base" and DB.profileName == "Base", "renaming the default profile updates the character selection")
DB:RenameProfile("Base", "Default")

DB.saved.profileKeys["Other - Iridikron"] = "Tank"
local removed, reason = DB:DeleteProfile("Tank")
check(removed, "deleting an assigned profile works")
check(Auto:Get("spec", 2) == "" and next(DB.saved.assignments["Other - Iridikron"].content) == nil, "its assignments are removed everywhere")
local fallback = DB.saved.profileKeys["Other - Iridikron"]
check(DB.saved.profiles[fallback] ~= nil and fallback ~= "Tank", "another character's default falls back to a profile that exists")
check(not DB:DeleteProfile("Default"), "the active profile can't be deleted")

instance = "raid"; Auto:Apply(true)
check(DB.profileName == "Raid" and DB:DefaultProfile() == "Default", "override active before deleting the default")
check(DB:DeleteProfile("Default"), "the default profile can be deleted while an override is active")
check(DB:DefaultProfile() == "Raid" and DB.saved.profiles[DB:DefaultProfile()] ~= nil, "the active profile becomes the default so nothing dangles")
instance = "none"; Auto:Apply(true)
check(DB.profileName == "Raid", "the active profile keeps running once the override ends")

PlateauDB.profileKeys[key] = "Missing"
DB:Init()
check(DB.saved.profiles[DB.profileName] ~= nil and DB.profileName ~= "Missing", "a stale default from old data falls back to an existing profile at login")
check(PlateauDB.profiles.Missing == nil, "the missing profile was not invented")

DB:SwitchProfile("Solo")
local text = DB:ExportProfile()
local before = #DB:ListProfiles()
local okImport, importedName, activation = DB:ImportProfile("Copy", text)
check(okImport and importedName == "Copy" and activation == nil, "import creates a new profile")
check(DB.profileName == "Solo" and DB:DefaultProfile() == "Solo", "import does not activate by default")
check(#DB:ListProfiles() == before + 1, "import added exactly one profile")
okImport, importedName = DB:ImportProfile("Copy", text)
check(not okImport and importedName:find("already exists"), "a duplicate import name is refused")
check(#DB:ListProfiles() == before + 1, "the refused import changed nothing")
local snapshot = DB:Snapshot()
okImport = DB:ImportProfile("Bad", "!SL1!zzzz")
check(not okImport and DB.saved.profiles.Bad == nil and #DB:ListProfiles() == before + 1, "a damaged string creates nothing")
okImport, importedName, activation = DB:ImportProfile("Live", text, true)
check(okImport and activation == nil and DB.profileName == "Live" and DB:DefaultProfile() == "Live", "activating an import makes it the active and default profile")
combat = true
okImport, importedName, activation = DB:ImportProfile("Later", text, true)
check(okImport and activation == "deferred" and DB.profileName == "Live" and DB:DefaultProfile() == "Later", "activating in combat defers the switch")
combat = false; Auto:Apply()
check(DB.profileName == "Later", "the deferred import activates after combat")
okImport, importedName = DB:ImportProfile("", text)
check(okImport and importedName == "Imported", "an empty name gets a generated one")
okImport, importedName = DB:ImportProfile("", text)
check(okImport and importedName == "Imported 2", "generated names never overwrite")

local exported = ns.Share.Decode(text)
check(exported.look ~= nil and exported.assignments == nil and exported.profileKeys == nil, "an export carries the look and spell lists, not assignments or selections")

DB:SwitchProfile("Solo")
DB:SetSpecSpells("mine", "hide", "12345", 1)
local specText = DB:ExportProfile()
DB:ImportProfile("WithSpells", specText)
check(rawget(DB.saved.profiles.WithSpells, "specSpells")[1].mine.hide == "12345", "aura spell lists travel with an export")

local global = DB.saved.global
global.bossPhases = { [3201] = "60, 30" }
global.bossPhaseOn = { [3101] = "boss" }
global.bossesSeen = { [3201] = "Lightwarden Ruia", [3101] = "Kystia Manaheart", [9999] = "Not shared" }
local bossText = DB:ExportProfile()
global.bossPhases, global.bossPhaseOn, global.bossesSeen = nil, nil, nil
DB:ImportProfile("WithBosses", bossText)
check(global.bossPhases and global.bossPhases[3201] == "60, 30", "boss phase lines travel with an export")
check(global.bossPhaseOn and global.bossPhaseOn[3101] == "boss", "boss line targets travel with an export")
check(global.bossesSeen and global.bossesSeen[3201] == "Lightwarden Ruia" and global.bossesSeen[9999] == nil, "only the names of bosses with settings are shared")
local clean = DB.CleanBossPhases({ lines = { [1] = "50", [2] = "os.exit()", ["x"] = "50", [3] = string.rep("1", 80) }, on = { [1] = "everything" } })
check(clean and clean.lines[1] == "50" and clean.lines[2] == nil and clean.lines.x == nil and clean.lines[3] == nil and clean.on[1] == nil, "imported boss lines are checked: only plain percentages and known targets get in")
