local function check(c, m) print((c and "PASS " or "FAIL ") .. m) end

local inside, kind, delve = false, "none", false
function IsInInstance() return inside, kind end
C_PartyInfo = { IsDelveInProgress = function() return delve end }
C_EventUtils = { IsEventValid = function() return true end }
C_Timer = { After = function() end }
function InCombatLockdown() return false end
function CreateFrame() return { RegisterEvent = function() end, SetScript = function() end } end

local ns = {}
assert(loadfile("Plateau/Core/Zone.lua"))("Plateau", ns)
local Zone = ns.Zone

local OLD_FADE = { party = "dungeon", raid = "raid", scenario = "delve", delve = "delve", pvp = "pvp", arena = "pvp" }
local OLD_CONTENT = { none = "world", party = "dungeon", raid = "raid", scenario = "delve", delve = "delve", arena = "arena", pvp = "battleground" }
local NEW_FADE = { dungeon = "dungeon", raid = "raid", delve = "delve", battleground = "pvp", arena = "pvp" }
local PETS = { dungeon = true, raid = true }

local bad = 0
for _, k in ipairs({ "none", "party", "raid", "scenario", "delve", "pvp", "arena", "neighborhood" }) do
    for _, i in ipairs({ true, false }) do
        for _, d in ipairs({ true, false }) do
            inside, kind, delve = i, k, d
            local z = Zone.Read()
            local fade = z.inInstance and (NEW_FADE[z.content] or "world") or "world"
            local oldFade = i and (OLD_FADE[k] or "world") or "world"
            local pets = z.inInstance and PETS[z.content] == true
            local oldPets = i == true and (k == "party" or k == "raid")
            local colors = (z.inInstance and z.type ~= "pvp" and z.type ~= "arena") or z.inDelve
            local oldColors = (i == true and k ~= "pvp" and k ~= "arena") or d == true or false
            local raid = z.inInstance and z.type == "raid"
            local oldRaid = i == true and k == "raid"
            local same = fade == oldFade and pets == oldPets and colors == oldColors and raid == oldRaid
                and z.content == (OLD_CONTENT[k] or "world") and (z.type == "party") == (k == "party")
                and z.inInstance == (i == true)
            if not same then
                bad = bad + 1
                print("DIFF", k, i, d, fade, oldFade, pets, oldPets, colors, oldColors, z.content)
            end
        end
    end
end
check(bad == 0, "the shared zone read answers every place the way its old copy did")

inside, kind = nil, nil
local z = Zone.Read()
check(z.inInstance == false and z.type == "none" and z.content == "world", "a missing answer reads as the open world")
C_PartyInfo = nil
check(Zone.Read().inDelve == false, "no delve API reads as not in a delve")
