local _, ns = ...

local IsSpellInRange = C_Spell.IsSpellInRange
local InterruptReady = ns.InterruptReady

local CHECK_INTERVAL = 0.25

local settings = {}

local Range = {
    key = "range",
    events = {},
}
ns.Range = Range

function Range:Create(plate)
    plate.rangeAlpha = 1
end

function Range:Configure(db, state)
    local s = settings[state] or {}
    settings[state] = s
    s.alpha = db.alpha
end

function Range:Style()
end

local function Check(plate)
    local alpha = 1
    local spellID = InterruptReady:GetSpellID()
    if spellID and Range.enabledIn[plate.state] and plate.unit then
        if IsSpellInRange(spellID, plate.unit) == false then
            alpha = settings[plate.state].alpha
        end
    end
    if plate.rangeAlpha ~= alpha then
        plate.rangeAlpha = alpha
        ns.Driver:RefreshAlpha(plate)
    end
end

function Range:Enable(plate)
    Check(plate)
end

function Range:Disable(plate)
    if plate.rangeAlpha ~= 1 then
        plate.rangeAlpha = 1
        ns.Driver:RefreshAlpha(plate)
    end
end

function Range:OnEvent()
end

function Range:Preview(plate)
    plate.rangeAlpha = 1
end

local ticker = CreateFrame("Frame")
ticker:Hide()
local sinceCheck = 0
local hadSpellID = false
ticker:SetScript("OnUpdate", function(_, elapsed)
    sinceCheck = sinceCheck + elapsed
    if sinceCheck < CHECK_INTERVAL then return end
    sinceCheck = 0
    if InterruptReady:GetSpellID() then
        hadSpellID = true
        ns.Driver:ForEachActive(Check)
    elseif hadSpellID then
        hadSpellID = false
        ns.Driver:ForEachActive(function(plate) Range:Disable(plate) end)
    end
end)

function Range:Configured()
    ticker:SetShown(self.enabled == true)
end

ns.Driver:RegisterElement(Range)
