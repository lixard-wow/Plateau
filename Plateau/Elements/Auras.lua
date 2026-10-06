local _, ns = ...

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local ShouldAurasBeSecret = C_Secrets and C_Secrets.ShouldAurasBeSecret
local Sort = AuraContainerSortMethod
local Flow = AnchorUtil.FlowDirection
local DispelStyle = Enum.CustomAuraButtonDispelTypeTextureStyle

local PANDEMIC_COLOR = { 1, 0.2, 0.2, 0.45 }

local SORT_METHODS = {
    expiration = Sort.Expiration,
    name = Sort.Name,
    default = Sort.Default,
}

local GROUPS = {
    {
        key = "mine",
        harmful = true,
        pandemic = true,
        parts = {
            { filter = "HARMFUL|PLAYER|!CROWD_CONTROL", sort = Sort.Expiration },
            { filter = "HARMFUL|!PLAYER|!CROWD_CONTROL", sort = Sort.Expiration, others = true },
        },
    },
    {
        key = "cc",
        harmful = true,
        parts = { { filter = "HARMFUL|CROWD_CONTROL", sort = Sort.Expiration } },
    },
    {
        key = "purge",
        helpful = true,
        parts = {
            { filter = "HELPFUL|!IMPORTANT|!PLAYER", candidates = { isStealable = true, excludeDispelTypes = { Enrage = true } } },
            { filter = "HELPFUL|!IMPORTANT|!PLAYER", candidates = { includeDispelTypes = { Enrage = true } } },
        },
    },
    {
        key = "important",
        helpful = true,
        parts = { { filter = "HELPFUL|IMPORTANT|!PLAYER" } },
    },
}

local NAMEPLATE_ONLY = "|INCLUDE_NAME_PLATE_ONLY"
local NAMEPLATE_ONLY_SAMPLE = "Interface\\Icons\\INV_Misc_QuestionMark"
local OTHERS_SAMPLE = "Interface\\Icons\\Spell_Shadow_CurseOfTounges"

local timerFormatter = C_StringUtil.CreateSecondsFormatter()
timerFormatter:SetDefaultAbbreviation(Enum.SecondsFormatterAbbreviation.OneLetter)
timerFormatter:SetStripIntervalWhitespace(Enum.SecondsFormatterIntervalWhitespace.Strip)
timerFormatter:SetMinInterval(Enum.SecondsFormatterInterval.Seconds)
timerFormatter:SetMaxInterval(Enum.SecondsFormatterInterval.Minutes)
timerFormatter:SetDesiredUnitCount(1)
timerFormatter:SetMillisecondsThreshold(0)
local DURATION_TEXT_OPTIONS = { textFormatter = timerFormatter }

local configs = {}
local signatureCache = {}
local dirtyContainers = {}
local queuedContainers = {}
local dirtyOrder = {}
local FLUSH_BATCH = 8

local Auras = {
    key = "auras",
    events = {},
}
ns.Elements = ns.Elements or {}
ns.Elements.Auras = Auras

local function Restricted()
    return InCombatLockdown() or (ShouldAurasBeSecret and ShouldAurasBeSecret())
end

local CORNER_OFFSETS = {
    CENTER = { 0, 0 }, TOP = { 0, 1 }, BOTTOM = { 0, -1 },
    TOPLEFT = { -2, 1 }, TOPRIGHT = { 2, 1 }, BOTTOMLEFT = { -2, -1 }, BOTTOMRIGHT = { 2, -1 },
}

local function PlaceText(text, button, point)
    local offset = CORNER_OFFSETS[point] or CORNER_OFFSETS.CENTER
    text:ClearAllPoints()
    text:SetPoint(CORNER_OFFSETS[point] and point or "CENTER", button, CORNER_OFFSETS[point] and point or "CENTER", offset[1], offset[2])
end

local function StyleButton(button, group, container)
    local config = configs[container.plate.state]
    local db = config[group.key]
    local size = db.size * ns.Scaling:AuraFactor()
    local wide = db.shape == "wide"
    button:SetSize(size, wide and size * 0.75 or size)
    if wide then
        button.iconTexture:SetTexCoord(0.08, 0.92, 0.185, 0.815)
    else
        button.iconTexture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    button.cooldownFrame:SetDrawSwipe(db.swipe ~= false)
    PlaceText(button.timer, button, db.timerPosition)
    PlaceText(button.stacks, button, db.stackPosition or "BOTTOMRIGHT")
    button:SetMouseClickEnabled(false)
    button:EnableMouseMotion(config.tooltips == true)
    if button.SetHideTooltipInCombat then
        button:SetHideTooltipInCombat(not config.tooltipsInCombat)
    end

    local borderSize = db.borderSize or 1
    button.border:Layout(borderSize)
    button.border:SetShown(borderSize > 0)
    local borderColor = db.borderColor
    if borderColor then
        button.border:SetColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4])
    end
    ns.ApplyFont(button.timer, config.font, db.timerSize, config.outline)
    ns.ApplyFont(button.stacks, config.font, db.stackSize, config.outline)
    ns.ApplyShadow(button.timer, config.shadow)
    ns.ApplyShadow(button.stacks, config.shadow)

    button:ClearDurationText()
    if db.showTimer then
        button:SetDurationText(button.timer, DURATION_TEXT_OPTIONS)
    end
    button.timer:SetShown(db.showTimer)
    button.stacks:SetShown(db.showStacks)
    button.dispelFrame:SetShown(db.dispelBorder)
    if button.pandemic then
        button.pandemic:SetAlpha(db.pandemic and 1 or 0)
    end
end

local function StyleContainerButtons(container)
    for i = 1, #container.buttons do
        StyleButton(container.buttons[i], container.group, container)
    end
end

local function MarkDirty(container)
    dirtyContainers[container] = true
    if not queuedContainers[container] then
        queuedContainers[container] = true
        dirtyOrder[#dirtyOrder + 1] = container
    end
end

local function FlushDirtyButtons()
    if Restricted() then return end
    local processed = 0
    while #dirtyOrder > 0 and processed < FLUSH_BATCH do
        local container = table.remove(dirtyOrder)
        queuedContainers[container] = nil
        if dirtyContainers[container] and container.plate.active then
            dirtyContainers[container] = nil
            StyleContainerButtons(container)
        end
        processed = processed + 1
    end
    if #dirtyOrder > 0 then
        C_Timer.After(0, FlushDirtyButtons)
    end
end

ns.auraButtons = ns.auraButtons or { built = 0, combat = 0 }

local function CountButton()
    local counts = ns.auraButtons
    counts.built = counts.built + 1
    if InCombatLockdown() then
        counts.combat = counts.combat + 1
    end
end
ns.CountAuraButton = CountButton

local function Initializer(container, group)
    return function(button)
        if button.plateauInit then return end
        button.plateauInit = true
        CountButton()
        container.buttons[#container.buttons + 1] = button

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        button.iconTexture = icon

        local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawBling(false)
        cooldown:SetDrawEdge(false)
        cooldown:SetHideCountdownNumbers(true)
        cooldown:SetReverse(true)
        button.cooldownFrame = cooldown

        button.border = ns.CreateBorder(button, button, "OVERLAY", 1)
        button.border:SetColor(0, 0, 0, 1)

        local texts = CreateFrame("Frame", nil, button)
        texts:SetAllPoints()
        texts:SetFrameLevel(cooldown:GetFrameLevel() + 2)
        button.timer = texts:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.timer:SetPoint("CENTER", 0, 0)
        button.stacks = texts:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        button.stacks:SetPoint("BOTTOMRIGHT", 2, -1)

        button.dispelFrame = CreateFrame("Frame", nil, button)
        button.dispelFrame:SetAllPoints()
        button.dispelFrame:SetFrameLevel(texts:GetFrameLevel() + 1)
        local dispel = button.dispelFrame:CreateTexture(nil, "OVERLAY")
        dispel:SetPoint("TOPLEFT", -1, 1)
        dispel:SetPoint("BOTTOMRIGHT", 1, -1)

        button:SetIcon(icon)
        button:SetDurationCooldown(cooldown)
        button:SetApplicationCount(button.stacks, {})
        button:AddDispelTypeTexture(dispel, {
            showWhenHarmful = group.harmful or false,
            showWhenHelpful = group.helpful or false,
            style = DispelStyle.Border,
        })

        if group.pandemic and button.AddPandemicRegion then
            local pandemic = button:CreateTexture(nil, "OVERLAY")
            pandemic:SetAllPoints(icon)
            pandemic:SetColorTexture(PANDEMIC_COLOR[1], PANDEMIC_COLOR[2], PANDEMIC_COLOR[3], PANDEMIC_COLOR[4])
            button:AddPandemicRegion(pandemic)
            button.pandemic = pandemic
        end

        if configs[container.plate.state] then
            StyleButton(button, group, container)
        end
    end
end

function Auras:Create(plate)
    plate.auras = {}
    for _, group in ipairs(GROUPS) do
        local container = CreateFrame("AuraContainer", nil, plate.overlay, "CustomAuraContainerTemplate")
        container:SetEnabled(false)
        container.buttons = {}
        container.group = group
        container.plate = plate
        container.keys = {}
        container.filters = {}
        for index, part in ipairs(group.parts) do
            local key = group.key .. index
            container.keys[index] = key
            container.filters[index] = part.filter .. NAMEPLATE_ONLY
            container:AddAuraGroup(key, container.filters[index], {
                initializeFrame = Initializer(container, group),
                sortMethod = part.sort,
                candidateFilters = part.candidates,
            })
        end
        plate.auras[group.key] = container
    end
end

function Auras:Configure(db, state)
    configs[state] = db
end

local HORIZONTAL = AnchorUtil.FlowLayoutAxis.Horizontal
local VERTICAL = AnchorUtil.FlowLayoutAxis.Vertical

local GROW = {
    ["right-down"] = { Flow.Right, Flow.Down, HORIZONTAL },
    ["right-up"] = { Flow.Right, Flow.Up, HORIZONTAL },
    ["left-down"] = { Flow.Left, Flow.Down, HORIZONTAL },
    ["left-up"] = { Flow.Left, Flow.Up, HORIZONTAL },
    ["down-right"] = { Flow.Right, Flow.Down, VERTICAL },
    ["down-left"] = { Flow.Left, Flow.Down, VERTICAL },
    ["up-right"] = { Flow.Right, Flow.Up, VERTICAL },
    ["up-left"] = { Flow.Left, Flow.Up, VERTICAL },
}

local function AutoPlacement(db)
    local right = db.align == "RIGHT"
    local center = db.align == "CENTER"
    local horizontal = right and Flow.Left or Flow.Right
    if db.side == "BOTTOM" then
        if center then
            return "TOPLEFT", "BOTTOM", Flow.Right, Flow.Down, "TOP"
        end
        return right and "TOPRIGHT" or "TOPLEFT", right and "BOTTOMRIGHT" or "BOTTOMLEFT", horizontal, Flow.Down
    elseif db.side == "LEFT" then
        return "TOPRIGHT", "TOPLEFT", Flow.Left, Flow.Down
    elseif db.side == "RIGHT" then
        return "TOPLEFT", "TOPRIGHT", Flow.Right, Flow.Down
    end
    if center then
        return "BOTTOMLEFT", "TOP", Flow.Right, Flow.Up, "BOTTOM"
    end
    return right and "BOTTOMRIGHT" or "BOTTOMLEFT", right and "TOPRIGHT" or "TOPLEFT", horizontal, Flow.Up
end

local function Placement(db)
    local point, relative, horizontal, vertical, anchor = AutoPlacement(db)
    local attach = anchor or point
    local grow = GROW[db.grow]
    if not grow then
        return point, relative, horizontal, vertical, HORIZONTAL, attach
    end
    horizontal, vertical = grow[1], grow[2]
    point = (vertical == Flow.Down and "TOP" or "BOTTOM") .. (horizontal == Flow.Right and "LEFT" or "RIGHT")
    if db.side == "LEFT" or db.side == "RIGHT" then
        local row = vertical == Flow.Down and "TOP" or "BOTTOM"
        local inner = db.side == "LEFT" and "RIGHT" or "LEFT"
        return point, row .. db.side, horizontal, vertical, grow[3], row .. inner
    end
    return point, relative, horizontal, vertical, grow[3], attach
end
ns.AuraPlacement = Placement

local GetSpellName = C_Spell.GetSpellName
local GetSpellTexture = C_Spell.GetSpellTexture
local IsChallengeModeActive = C_PartyInfo and C_PartyInfo.IsChallengeModeActive
local LAST_SPELL_ID, SCAN_BATCH, SCAN_BUDGET_MS, SCAN_RETRY = 2000000, 250, 1, 0.5
local scanWanted, scanFound, scanIcons, scanning, scanProgress = {}, {}, {}, false, 0
local pendingWanted = {}
local migratedSpellNames = false
ns.spellNameVersion = 0

local function NameCache()
    local global = ns.DB and ns.DB.saved and ns.DB.saved.global
    if not global then return nil end
    if not migratedSpellNames then
        migratedSpellNames = true
        global.spellNames = nil
    end
    global.spellIDsByName = global.spellIDsByName or {}
    return global.spellIDsByName
end

local WantName

local function ScanBlocked()
    return InCombatLockdown() or (IsChallengeModeActive and IsChallengeModeActive())
end

local function ScanStep(from)
    if ScanBlocked() then
        C_Timer.After(SCAN_RETRY, function() ScanStep(from) end)
        return
    end
    local last = from
    local started = debugprofilestop()
    repeat
        local batchEnd = math.min(last + SCAN_BATCH, LAST_SPELL_ID)
        for id = last + 1, batchEnd do
            local name = GetSpellName(id)
            local key = name and scanWanted[name]
            if key then
                local list = scanFound[key]
                list[#list + 1] = id
            end
        end
        last = batchEnd
    until last >= LAST_SPELL_ID or debugprofilestop() - started > SCAN_BUDGET_MS or ScanBlocked()
    scanProgress = last
    if last < LAST_SPELL_ID then
        C_Timer.After(0, function() ScanStep(last) end)
        return
    end
    local cache = NameCache()
    for key, list in pairs(scanFound) do
        local icon = scanIcons[key]
        if icon then
            local same = {}
            for _, id in ipairs(list) do
                if GetSpellTexture(id) == icon then
                    same[#same + 1] = id
                end
            end
            list = same
        end
        if cache then cache[key] = list end
    end
    scanWanted, scanFound, scanIcons, scanning, scanProgress = {}, {}, {}, false, 0
    ns.spellNameVersion = ns.spellNameVersion + 1
    ns.Driver:RequestRestyle(true)
    if next(pendingWanted) then
        local queued = pendingWanted
        pendingWanted = {}
        for token, resolved in pairs(queued) do
            WantName(token, resolved)
        end
    end
end

function WantName(token, resolved)
    if scanning and scanProgress > 0 then
        pendingWanted[token] = resolved or pendingWanted[token]
        return
    end
    local key = token:lower()
    scanFound[key] = scanFound[key] or {}
    scanWanted[token] = key
    scanIcons[key] = resolved and GetSpellTexture(resolved) or nil
    local canonical = resolved and GetSpellName(resolved)
    if canonical then
        scanWanted[canonical] = key
    end
    if not scanning then
        scanning = true
        C_Timer.After(0, function() ScanStep(0) end)
    end
end

local function SpellSet(text)
    if type(text) ~= "string" or text == "" then return nil end
    local set
    local cache = NameCache()
    for token in text:gmatch("[^,;]+") do
        token = token:match("^%s*(.-)%s*$")
        local id = tonumber(token)
        if id then
            set = set or {}
            set[id] = true
        elseif token ~= "" then
            local resolved = C_Spell.GetSpellIDForSpellIdentifier and C_Spell.GetSpellIDForSpellIdentifier(token)
            if resolved then
                set = set or {}
                set[resolved] = true
            end
            local known = cache and cache[token:lower()]
            if known then
                for _, spellID in ipairs(known) do
                    set = set or {}
                    set[spellID] = true
                end
            elseif cache and not scanFound[token:lower()] then
                WantName(token, resolved)
            end
        end
    end
    return set
end
ns.AuraSpellSet = SpellSet

local function SpecLists(groupKey)
    return ns.DB:GetSpecSpells(groupKey, "hide"), ns.DB:GetSpecSpells(groupKey, "only")
end

local PERMANENT_CUTOFF = 31536000

local function Candidates(base, db, groupKey)
    local maxDuration = (db.maxDuration or 0) > 0 and db.maxDuration or nil
    if not maxDuration and db.hidePermanent then
        maxDuration = PERMANENT_CUTOFF
    end
    local hideText, onlyText = SpecLists(groupKey)
    local hide, only = SpellSet(hideText), SpellSet(onlyText)
    local hideBoss = db.hideBoss == true
    if not maxDuration and not hide and not only and not hideBoss then
        return base
    end
    local filters = {}
    if base then
        for key, value in pairs(base) do
            filters[key] = value
        end
    end
    filters.maxDuration = maxDuration
    if hideBoss then
        filters.isBossAura = false
    end
    filters.excludeSpellIDs = hide
    filters.includeSpellIDs = only
    return filters
end

function Auras:Style(plate, db)
    for _, group in ipairs(GROUPS) do
        local container = plate.auras[group.key]
        local groupDb = db[group.key]
        local point, relative, horizontal, vertical, axis, anchor = Placement(groupDb)
        container:ClearAllPoints()
        container:SetPoint(anchor, plate, relative, groupDb.offsetX, groupDb.offsetY)
        container:SetFlowLayoutAxis(axis)
        container:SetFlowLayoutAnchorPoint(point)
        container:SetFlowLayoutGrowthDirection(horizontal, vertical)
        local perRow = math.max(1, groupDb.perRow)
        container:SetFlowLayoutMaximumLineSize(perRow * groupDb.size * ns.Scaling:AuraFactor() + (perRow - 1) * groupDb.spacing)
        local sortMethod = SORT_METHODS[groupDb.sort] or Sort.Default
        if container.sortMethod ~= sortMethod then
            container.sortMethod = sortMethod
            for _, key in ipairs(container.keys) do
                container:SetAuraGroupSortMethod(key, sortMethod, AuraContainerSortDirection.Normal)
            end
        end
        local allBuffs = groupDb.allBuffs == true
        for index, key in ipairs(container.keys) do
            container:SetAuraGroupLayout(key, { elementSpacing = groupDb.spacing, lineSpacing = groupDb.spacing })
            local count = groupDb.maxIcons
            if group.parts[index].others and groupDb.includeOthers ~= true then
                count = 0
            elseif allBuffs and index > 1 then
                count = 0
            elseif group.key == "purge" and not allBuffs then
                if (index == 1 and groupDb.showMagic == false) or (index == 2 and groupDb.showEnrage == false) then
                    count = 0
                end
            end
            container:SetAuraGroupMaxFrameCount(key, count)
        end
        local hideText, onlyText = SpecLists(group.key)
        local byState = signatureCache[plate.state]
        if not byState then
            byState = {}
            signatureCache[plate.state] = byState
        end
        local cached = byState[group.key]
        local signature
        if cached and cached.allBuffs == allBuffs and cached.maxDuration == groupDb.maxDuration
            and cached.hidePermanent == groupDb.hidePermanent and cached.hideBoss == groupDb.hideBoss
            and cached.hideText == hideText and cached.onlyText == onlyText and cached.version == ns.spellNameVersion then
            signature = cached.signature
        else
            signature = table.concat({ tostring(allBuffs), tostring(groupDb.maxDuration), tostring(groupDb.hidePermanent), tostring(groupDb.hideBoss), hideText, onlyText, ns.spellNameVersion }, "|")
            byState[group.key] = {
                allBuffs = allBuffs,
                maxDuration = groupDb.maxDuration,
                hidePermanent = groupDb.hidePermanent,
                hideBoss = groupDb.hideBoss,
                hideText = hideText,
                onlyText = onlyText,
                version = ns.spellNameVersion,
                signature = signature,
            }
        end
        local nameplateOnly = groupDb.nameplateOnly ~= false and NAMEPLATE_ONLY or ""
        for index, key in ipairs(container.keys) do
            local filter = group.parts[index].filter .. nameplateOnly
            if container.filters[index] ~= filter then
                container.filters[index] = filter
                container:SetAuraGroupFilterString(key, filter)
            end
        end
        if container.filterSignature ~= signature then
            container.filterSignature = signature
            for index, key in ipairs(container.keys) do
                local base = group.parts[index].candidates
                if group.key == "purge" and index == 1 and allBuffs then
                    base = nil
                end
                container:SetAuraGroupCandidateFilters(key, Candidates(base, groupDb, group.key))
            end
        end
    end
    if Restricted() then
        for _, group in ipairs(GROUPS) do
            MarkDirty(plate.auras[group.key])
        end
    else
        for _, group in ipairs(GROUPS) do
            local container = plate.auras[group.key]
            dirtyContainers[container] = nil
            StyleContainerButtons(container)
        end
    end
end

local function SetOn(container, on)
    if container.isOn ~= on then
        container.isOn = on
        container:SetEnabled(on)
    end
end

function Auras:Enable(plate, unit)
    for _, group in ipairs(GROUPS) do
        local container = plate.auras[group.key]
        if container.currentUnit ~= unit then
            container.currentUnit = unit
            container:SetUnit(unit)
        end
        SetOn(container, configs[plate.state][group.key].enabled == true)
        if dirtyContainers[container] then
            if Restricted() then
                MarkDirty(container)
            else
                dirtyContainers[container] = nil
                StyleContainerButtons(container)
            end
        end
    end
    if plate.fakeAuras then
        for _, fake in pairs(plate.fakeAuras) do
            fake:Hide()
        end
    end
end

function Auras:Disable(plate)
    for _, group in ipairs(GROUPS) do
        local container = plate.auras[group.key]
        SetOn(container, false)
        container.currentUnit = nil
    end
    if plate.fakeAuras then
        for _, fake in pairs(plate.fakeAuras) do
            fake:Hide()
        end
    end
end

function Auras:OnEvent()
end

local SAMPLE_ICONS = {
    mine = { "Interface\\Icons\\Spell_Shadow_ShadowWordPain", "Interface\\Icons\\Spell_Shadow_AbominationExplosion", "Interface\\Icons\\Spell_Nature_FaerieFire" },
    cc = { "Interface\\Icons\\Spell_Nature_Polymorph" },
    purge = { "Interface\\Icons\\Spell_Holy_PowerWordShield", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy" },
    important = { "Interface\\Icons\\Spell_Nature_LightningShield" },
}
local CLASS_SAMPLES = {
    DRUID = { mine = { 77758, 106830, 8921, 93402, 1822, 1079, 202347 }, cc = { 99, 5211, 339, 33786, 2637 } },
    PRIEST = { mine = { 589, 34914, 335467 }, cc = { 8122, 9484, 64044 } },
    WARLOCK = { mine = { 980, 172, 316099, 348 }, cc = { 5782, 6789, 30283 } },
    HUNTER = { mine = { 271788, 257284 }, cc = { 187650, 19577, 213691 } },
    ROGUE = { mine = { 703, 1943, 121411 }, cc = { 6770, 408, 2094, 1833 } },
    DEATHKNIGHT = { mine = { 77575, 50842, 85948 }, cc = { 221562, 108194, 207167 } },
    MAGE = { mine = { 12654, 44614 }, cc = { 118, 122, 31661 } },
    SHAMAN = { mine = { 188389 }, cc = { 51514, 118905, 192058 } },
    WARRIOR = { mine = { 772, 6343, 12294 }, cc = { 107570, 5246, 46968 } },
    PALADIN = { mine = { 20271, 26573 }, cc = { 853, 20066, 115750 } },
    MONK = { mine = { 115098 }, cc = { 115078, 119381 } },
    DEMONHUNTER = { mine = { 204596, 204021 }, cc = { 217832, 179057, 207684 } },
    EVOKER = { mine = { 357208 }, cc = { 360806, 357210 } },
}

local function KnownIcons(list)
    local icons = {}
    if not list then return icons end
    for _, id in ipairs(list) do
        if C_SpellBook.IsSpellKnown(id) then
            local texture = C_Spell.GetSpellTexture(id)
            if texture then
                icons[#icons + 1] = texture
            end
        end
    end
    return icons
end

local SAMPLE_BORDER = { mine = nil, cc = { 0.8, 0.2, 0.8, 1 }, purge = { 0.2, 0.6, 1, 1 }, important = { 1, 0.8, 0.2, 1 } }

local function FakeGroup(plate, key)
    plate.fakeAuras = plate.fakeAuras or {}
    local fake = plate.fakeAuras[key]
    if fake then return fake end
    fake = CreateFrame("Frame", nil, plate.overlay)
    fake:SetSize(1, 1)
    fake.icons = {}
    for i = 1, 6 do
        local icon = CreateFrame("Frame", nil, fake)
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon.border = ns.CreateBorder(icon, icon, "OVERLAY", 1)
        icon.dispel = ns.CreateBorder(icon, icon, "OVERLAY", 2)
        icon.timer = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        icon.timer:SetPoint("CENTER")
        icon.stacks = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        icon.stacks:SetPoint("BOTTOMRIGHT", 2, -1)
        fake.icons[i] = icon
    end
    plate.fakeAuras[key] = fake
    return fake
end

function Auras:Preview(plate, state)
    local config = configs[plate.state]
    for _, group in ipairs(GROUPS) do
        local key = group.key
        SetOn(plate.auras[key], false)
        local db = config[key]
        local count = state.auras and state.auras[key] or 0
        local extra = count > 0 and db.nameplateOnly ~= false
        local others = count > 0 and key == "mine" and db.includeOthers == true
        if others then
            count = count + 1
        end
        if extra then
            count = count + 1
        end
        count = math.min(count, db.maxIcons)
        local fake = FakeGroup(plate, key)
        fake:SetShown(db.enabled and count > 0)
        if db.enabled and count > 0 then
            local point, relative, horizontal, vertical, axis, anchor = Placement(db)
            local perRow = math.max(1, db.perRow)
            local step = db.size + db.spacing
            local across = math.min(count, perRow)
            local lines = math.ceil(count / perRow)
            if axis == VERTICAL then
                across, lines = lines, across
            end
            fake:SetSize(across * step - db.spacing, lines * step - db.spacing)
            fake:ClearAllPoints()
            fake:SetPoint(anchor, plate, relative, db.offsetX, db.offsetY)
            local samples = SAMPLE_ICONS[key]
            local _, onlyText = SpecLists(key)
            local chosen = SpellSet(onlyText)
            if chosen then
                local ids, own = {}, {}
                for id in pairs(chosen) do
                    ids[#ids + 1] = id
                end
                table.sort(ids)
                for _, id in ipairs(ids) do
                    local texture = C_Spell.GetSpellTexture(id)
                    if texture then
                        own[#own + 1] = texture
                    end
                end
                if #own > 0 then
                    samples = own
                end
            elseif key == "mine" or key == "cc" then
                local class = CLASS_SAMPLES[UnitClassBase("player")]
                local own = KnownIcons(class and class[key])
                if #own > 0 then
                    samples = own
                end
            end
            for i, icon in ipairs(fake.icons) do
                if i <= count then
                    local column = (i - 1) % perRow
                    local row = math.floor((i - 1) / perRow)
                    if axis == VERTICAL then
                        column, row = row, column
                    end
                    icon:SetSize(db.size, db.size)
                    icon:ClearAllPoints()
                    icon:SetPoint(point, fake, point, column * step * horizontal, row * step * vertical)
                    if others and i == count - (extra and 1 or 0) then
                        icon.texture:SetTexture(OTHERS_SAMPLE)
                    elseif extra and i == count then
                        icon.texture:SetTexture(NAMEPLATE_ONLY_SAMPLE)
                    else
                        icon.texture:SetTexture(samples[(i - 1) % #samples + 1])
                    end
                    icon.border:Layout(1)
                    icon.border:SetColor(0, 0, 0, 1)
                    local dispel = SAMPLE_BORDER[key]
                    icon.dispel:Layout(1)
                    if dispel then
                        icon.dispel:SetColor(dispel[1], dispel[2], dispel[3], dispel[4])
                    end
                    icon.dispel:SetShown(db.dispelBorder and dispel ~= nil)
                    ns.ApplyFont(icon.timer, config.font, db.timerSize, config.outline)
                    ns.ApplyFont(icon.stacks, config.font, db.stackSize, config.outline)
                    icon.timer:SetText(tostring(4 + i * 3))
                    icon.timer:SetShown(db.showTimer)
                    icon.stacks:SetText(i == 2 and "3" or "")
                    icon.stacks:SetShown(db.showStacks)
                    icon:Show()
                else
                    icon:Hide()
                end
            end
        end
    end
end

local specWatcher = CreateFrame("Frame")
specWatcher:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
specWatcher:SetScript("OnEvent", function()
    if configs.enemy then
        ns.Driver:RequestRestyle(true)
    end
end)

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("PLAYER_REGEN_ENABLED")
if C_EventUtils.IsEventValid("ADDON_RESTRICTION_STATE_CHANGED") then
    watcher:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
end
watcher:SetScript("OnEvent", function()
    if #dirtyOrder > 0 and configs.enemy then
        FlushDirtyButtons()
    end
end)

ns.Driver:RegisterElement(Auras)
