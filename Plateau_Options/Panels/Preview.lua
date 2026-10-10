local _, ns = ...

local Style = ns.Style
local C = Style.colors
local layout = ns.layout

local PLATE_SCALE = 1.5
local HINT = "Click a part to edit it. Drag to move it; hold Shift to place it freely."

local sectionKey, editingTitle

local STATE_NOTES = {
    target = "The preview plate is shown as your target.",
    focus = "The preview plate is shown as your focus.",
    mouseover = "The preview plate is shown as the plate under your cursor.",
}

local WORLD_ONLY = { size = true, fading = true, layering = true, combat = true, game = true }

local function Hint()
    local T = Style.T
    local parts = {}
    if editingTitle then
        parts[#parts + 1] = T("Editing: %s (outlined)."):format(T(editingTitle))
    end
    if WORLD_ONLY[sectionKey] then
        parts[#parts + 1] = T("Applies to in-world nameplates; the preview does not show it.")
    else
        if STATE_NOTES[sectionKey] then
            parts[#parts + 1] = T(STATE_NOTES[sectionKey])
        end
        parts[#parts + 1] = T(HINT)
    end
    return table.concat(parts, " ")
end

local frame = PlateauOptions

local panel = CreateFrame("Frame", nil, frame)
panel:SetPoint("TOPLEFT", layout.rail + 1, -layout.title)
panel:SetPoint("TOPRIGHT", -1, -layout.title)
panel:SetHeight(layout.preview)
Style.Fill(panel, C.rail)

local line = panel:CreateTexture(nil, "ARTWORK")
line:SetPoint("BOTTOMLEFT")
line:SetPoint("BOTTOMRIGHT")
line:SetHeight(1)
line:SetColorTexture(C.border[1], C.border[2], C.border[3], 1)

local hint = Style.Text(panel, 11, C.muted)
hint:SetPoint("BOTTOMLEFT", layout.pad, 10)
hint:SetPoint("BOTTOMRIGHT", -layout.pad, 10)
hint:SetJustifyH("CENTER")
hint:SetWordWrap(true)
hint:SetText(Hint())

local outline = CreateFrame("Frame", nil, panel)
outline:SetFrameLevel(panel:GetFrameLevel() + 200)
Style.Border(outline, C.accent)
Style.ThemedBorder(outline)
outline:Hide()

local playerName, playerSurname = UnitName("player")
local playerClass = UnitClassBase and UnitClassBase("player")
if issecretvalue(playerClass) then
    playerClass = nil
end
local friendlySampleName = playerName
if Plateau.flavor == "forever" and not issecretvalue(playerSurname) and playerSurname and playerSurname ~= "" then
    friendlySampleName = playerName .. " " .. playerSurname
end

local function Sample()
    return {
        health = 0.72,
        maxHealth = 72700,
        name = "Wastelander Phaseblade",
        levelOffset = 1,
        classification = "elite",
        mobType = "caster",
        raidMarker = 8,
        quest = true,
        forces = { count = 4, percent = 0.84, text = "0.84" },
        auras = {},
        absorb = 0.15,
        cast = {
            progress = 0.6,
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            timer = "1.4",
            important = true,
            target = playerName,
        },
    }
end

local PICK_DEFAULTS = { cast = "normal", enemy = "caster", threat = "none", badge = "elite" }
local picks = {}

local function ResetPicks()
    for key, value in pairs(PICK_DEFAULTS) do
        picks[key] = value
    end
end
ResetPicks()

function ns.GetPreviewPick(key)
    return picks[key]
end

local MOB_TYPES = { caster = true, boss = true, lieutenant = true, higher = true, elite = true, trivial = true }
local AURA_COUNTS = { mine = 3, cc = 1, purge = 1, important = 1 }

local function On(path)
    return ns.Get(path) == true
end

local sample = Sample()
local castData = sample.cast
local baseHealth = sample.health
local baseMarker = sample.raidMarker
local baseQuest = sample.quest
local baseForces = sample.forces

local friendlySample = {
    isFriendly = true,
    isPlayer = true,
    class = playerClass or "PALADIN",
    health = 0.9,
    maxHealth = 81400,
    name = friendlySampleName,
    levelOffset = 0,
    classification = "elite",
    raidMarker = 1,
    auras = {},
    cast = {
        progress = 0.4,
        name = "Holy Light",
        icon = "Interface\\Icons\\Spell_Holy_HolyBolt",
        timer = "1.8",
    },
}
sample.alerts = {}

local spots = {}

local function Hotspot(plate, region, sectionKey, label, level, pad, drag)
    local spot = CreateFrame("Frame", nil, plate)
    spot:SetPoint("TOPLEFT", region, "TOPLEFT", -pad, pad)
    spot:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", pad, -pad)
    spot.region = region
    spot.plate = plate
    spot.level = level
    spot.label = label
    spot.sectionKey = sectionKey
    spot.drag = drag
    if drag then
        ns.Drag.Register(spot, drag)
    end
    spots[#spots + 1] = spot
    return spot
end

local function Resolve(value)
    if type(value) == "function" then
        return value()
    end
    return value
end

local function Bounds(spot)
    local left, right, top, bottom = spot:GetLeft(), spot:GetRight(), spot:GetTop(), spot:GetBottom()
    if left and spot.fitText then
        local text = spot.region
        local width = text:GetStringWidth()
        if width and width > 0 and width + 2 < right - left then
            width = width + 2
            local justify = text:GetJustifyH()
            if justify == "LEFT" then
                right = left + width
            elseif justify == "RIGHT" then
                left = right - width
            else
                local middle = (left + right) / 2
                left, right = middle - width / 2, middle + width / 2
            end
        end
    end
    if left and spot.clipTo then
        local clip = spot.clipTo
        local cl, cr, ct, cb = clip:GetLeft(), clip:GetRight(), clip:GetTop(), clip:GetBottom()
        if cl then
            left, right = math.max(left, cl), math.min(right, cr)
            top, bottom = math.min(top, ct), math.max(bottom, cb)
        end
    end
    return left, right, top, bottom
end

local function SpotAt()
    local best, bestArea
    for _, spot in ipairs(spots) do
        if spot:IsShown() then
            local left, right, top, bottom = Bounds(spot)
            if left then
                local x, y = GetCursorPosition()
                local scale = spot:GetEffectiveScale()
                x, y = x / scale, y / scale
                if x >= left and x <= right and y >= bottom and y <= top then
                    local area = (right - left) * (top - bottom)
                    if not best or spot.level > best.level or (spot.level == best.level and area < bestArea) then
                        best, bestArea = spot, area
                    end
                end
            end
        end
    end
    return best
end

local hovered

local function PlaceOutline(spot)
    outline:ClearAllPoints()
    local left, right, top, bottom = Bounds(spot)
    if (spot.fitText or spot.clipTo) and left then
        local ratio = spot:GetEffectiveScale() / outline:GetParent():GetEffectiveScale()
        outline:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left * ratio, top * ratio)
        outline:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", right * ratio, bottom * ratio)
    else
        outline:SetPoint("TOPLEFT", spot, "TOPLEFT")
        outline:SetPoint("BOTTOMRIGHT", spot, "BOTTOMRIGHT")
    end
end

local function SetHovered(spot)
    if spot == hovered then
        if spot and (spot.fitText or spot.clipTo) then
            PlaceOutline(spot)
        end
        return
    end
    hovered = spot
    if spot then
        PlaceOutline(spot)
        outline:Show()
        hint:SetFormattedText(spot.drag and "%s  -  click to edit, drag to move, arrow keys to nudge" or "%s  -  click to edit", Style.T(Resolve(spot.label)))
        local tint = Style.StateColor()
        hint:SetTextColor(tint[1], tint[2], tint[3])
    else
        outline:Hide()
        hint:SetText(Hint())
        hint:SetTextColor(C.muted[1], C.muted[2], C.muted[3])
    end
end

local layer = CreateFrame("Frame", nil, panel)
layer:SetAllPoints(panel)
layer:SetFrameLevel(panel:GetFrameLevel() + 180)
layer:EnableMouse(true)
local pressedSpot

layer:SetScript("OnUpdate", function(self)
    if ns.Drag.IsDragging() then
        if hovered and (hovered.fitText or hovered.clipTo) then
            PlaceOutline(hovered)
        end
        return
    end
    SetHovered(self:IsMouseOver() and SpotAt() or nil)
end)
layer:SetScript("OnLeave", function()
    if not ns.Drag.IsDragging() then
        SetHovered(nil)
    end
end)

layer:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" then return end
    pressedSpot = SpotAt()
    if pressedSpot and pressedSpot.drag then
        ns.Drag.Press(pressedSpot.drag, pressedSpot)
    end
end)
layer:SetScript("OnMouseUp", function(_, button)
    if button ~= "LeftButton" then return end
    local spot = pressedSpot
    pressedSpot = nil
    local dragged = spot and spot.drag and ns.Drag.Release()
    if dragged or not spot then return end
    if spot.drag then
        spot.drag.spot = spot
    end
    ns.Drag.Select(spot.drag)
    local key = Resolve(spot.sectionKey)
    ns.SelectSection(key)
    local opened
    if spot.setting then
        for _, section in ipairs(ns.sections) do
            if section.key == key then
                for i, control in ipairs(section.controls) do
                    if control.label == spot.setting then
                        ns.OpenSetting(key, i)
                        opened = true
                        break
                    end
                end
            end
        end
    end
    if not opened then
        ns.FlashTitle()
    end
end)

local function AtPlate(plate)
    return function() return plate end
end

local function AtHealth(plate)
    return function() return plate.health end
end

local function AddHotspots(plate)
    local Drag = ns.Drag
    local castbarDrag = Drag.CastbarSpec(plate)
    Hotspot(plate, plate, "size", "Size", 1, 6)
    Hotspot(plate, plate, "target", "Target", 1, 6)
    Hotspot(plate, plate, "focus", "Focus", 1, 6)
    Hotspot(plate, plate, "mouseover", "Mouseover", 1, 6)
    Hotspot(plate, plate, "shield", "Buff warnings", 1, 6)
    Hotspot(plate, plate.health, "health", "Health bar", 20, 0)
    Hotspot(plate, plate.castbar, "castbar", "Cast bar", 60, 0, castbarDrag)
    Hotspot(plate, plate.healthText, "healthText", "Health text", 80, 3,
        Drag.PositionSpec({ path = "look.healthText", positionKey = "anchor", text = true, fixedGap = 3, region = plate.healthText, anchor = AtHealth(plate) })).setting = "Show health text"
    Hotspot(plate, plate.enemyTarget, "name", "Enemy target name", 80, 3,
        Drag.PositionSpec({ path = "look.enemyTarget", positionKey = "anchor", text = true, fixedGap = 3, region = plate.enemyTarget, anchor = AtHealth(plate) })).setting = "Show enemy target name"
    Hotspot(plate, plate.level, "level", "Level", 80, 3,
        Drag.PositionSpec({ path = "look.level", positionKey = "anchor", text = true, fixedGap = 3, region = plate.level, anchor = AtHealth(plate) }))
    Hotspot(plate, plate.name, "name", "Name", 70, 1, Drag.NameSpec(plate)).fitText = true
    Hotspot(plate, plate.raidMarker, "raidMarker", "Raid target icon", 80, 0,
        Drag.PositionSpec({
            path = function() return sectionKey == "friendly" and "look.friendly.raidMarker" or "look.raidMarker" end,
            readPath = function()
                if sectionKey == "friendly" and Plateau.DB:Get("look.friendly.raidMarker.own") then
                    return "look.friendly.raidMarker"
                end
                return "look.raidMarker"
            end,
            extra = function()
                if sectionKey ~= "friendly" then
                    return {}
                end
                local own = Plateau.DB:Get("look.friendly.raidMarker.own")
                return { ["look.friendly.raidMarker.own"] = true, ["look.friendly.raidMarker.gap"] = Plateau.DB:Get(own and "look.friendly.raidMarker.gap" or "look.raidMarker.gap") }
            end,
            region = plate.raidMarker,
            anchor = AtPlate(plate),
        }))
    Hotspot(plate, plate.classification, "classification", "Elite icon", 80, 1,
        Drag.PositionSpec({ path = "look.classification", region = plate.classification, anchor = AtPlate(plate) }))
    Hotspot(plate, plate.quest, "quest", "Quest icon", 80, 1,
        Drag.PositionSpec({ path = "look.quest", region = plate.quest, anchor = AtPlate(plate) }))
    Hotspot(plate, plate.enemyPowerBar, "enemyPower", "Enemy power bar", 85, 1, Drag.EnemyPowerSpec(plate))
    Hotspot(plate, plate.classPower, "classPower", "Class resource", 80, 2,
        Drag.PositionSpec({ path = "look.classPower", region = plate.classPower, anchor = AtPlate(plate), noRing = true }))
    Hotspot(plate, plate.forces, "forces", "Mythic+ enemy forces", 80, 3,
        Drag.PositionSpec({ path = "look.forces", region = plate.forces, anchor = AtPlate(plate) }))
    Hotspot(plate, plate.threatText, "threatText", "Threat percent", 80, 3,
        Drag.PositionSpec({ path = "look.threatText", region = plate.threatText, anchor = AtPlate(plate) })).fitText = true
    Hotspot(plate, plate.faction, "faction", "Faction icon", 80, 1,
        Drag.PositionSpec({ path = "look.faction", region = plate.faction, anchor = AtPlate(plate) }))
    Hotspot(plate, plate.subtitle, "friendly", "Guild and title line", 75, 2).fitText = true
    Hotspot(plate, plate.castbar.icon, "castbar", "Spell icon", 60, 0, castbarDrag).setting = "Show spell icon"
    local castTarget = Hotspot(plate, plate.castbar.target, "castbar", "Cast target", 65, 2,
        Drag.PositionSpec({ path = "look.castbar", positionKey = "targetPosition", xKey = "targetOffsetX", yKey = "targetOffsetY", fixedGap = 2, region = plate.castbar.target, anchor = function() return plate.castbar end }))
    castTarget.fitText = true
    castTarget.setting = "Show cast target"
    local castName = Hotspot(plate, plate.castbar.text, "castbar",
        function() return picks.cast == "interrupted" and "Interrupted text" or "Spell name" end, 65, 1, castbarDrag)
    castName.fitText = true
    castName.setting = "Text"
    local castTimer = Hotspot(plate, plate.castbar.timer, "castbar", "Cast time", 65, 1,
        Drag.PositionSpec({ path = "look.castbar", positionKey = "timerPosition", xKey = "timerOffsetX", yKey = "timerOffsetY", fixedGap = 3, region = plate.castbar.timer, anchor = function() return plate.castbar end }))
    castTimer.fitText = true
    castTimer.setting = "Show remaining cast time"
    local absorb = Hotspot(plate, plate.absorb, "health", "Absorbs", 30, 0)
    absorb.clipTo = plate.health
    absorb.setting = "Show absorbs"
    Hotspot(plate, plate.targetSet.arrowLeft, "target", "Target", 40, 2).setting = "Show target arrows"
    Hotspot(plate, plate.targetSet.arrowRight, "target", "Target", 40, 2).setting = "Show target arrows"
    Hotspot(plate, plate.focusSet.arrowLeft, "focus", "Focus", 40, 2).setting = "Show focus arrows"
    Hotspot(plate, plate.focusSet.arrowRight, "focus", "Focus", 40, 2).setting = "Show focus arrows"
    local auraSections = { mine = "auraMine", cc = "auraCC", purge = "auraPurge", important = "auraImportant" }
    local auraNames = { mine = "Your debuffs", cc = "Crowd control", purge = "Enemy buffs", important = "Important auras" }
    for key, fake in pairs(plate.fakeAuras or {}) do
        local auraDrag = Drag.AuraSpec(plate, key)
        Hotspot(plate, fake, auraSections[key], auraNames[key], 75, 0, auraDrag).snapTarget = fake
    end
end

local function SnapTargets(dragged)
    local list, seen = {}, {}
    local plate = dragged and dragged.plate
    for _, spot in ipairs(spots) do
        local target = spot.snapTarget or spot.region
        if spot.plate == plate and target ~= plate and not spot.clipTo and not seen[target] then
            seen[target] = true
            list[#list + 1] = target
        end
    end
    return list
end

local editOutline = CreateFrame("Frame", nil, panel)
editOutline:SetFrameLevel(outline:GetFrameLevel() - 1)
Style.Border(editOutline, C.accent)
Style.ThemedBorder(editOutline)
editOutline:SetAlpha(0.6)
editOutline:Hide()

local function UpdateEditing()
    local left, right, top, bottom, scale
    if sectionKey then
        for _, spot in ipairs(spots) do
            if spot:IsShown() and Resolve(spot.sectionKey) == sectionKey then
                local l, r, t, b = Bounds(spot)
                if l then
                    scale = spot:GetEffectiveScale()
                    left = left and math.min(left, l) or l
                    right = right and math.max(right, r) or r
                    top = top and math.max(top, t) or t
                    bottom = bottom and math.min(bottom, b) or b
                end
            end
        end
    end
    if not left then
        editOutline:Hide()
        return
    end
    local panelLeft, panelBottom = panel:GetLeft(), panel:GetBottom()
    if not panelLeft or not panelBottom then
        editOutline:Hide()
        return
    end
    local ratio = scale / panel:GetEffectiveScale()
    editOutline:ClearAllPoints()
    editOutline:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", (left - 2) * ratio - panelLeft, (top + 2) * ratio - panelBottom)
    editOutline:SetPoint("BOTTOMRIGHT", panel, "BOTTOMLEFT", (right + 2) * ratio - panelLeft, (bottom - 2) * ratio - panelBottom)
    editOutline:Show()
end

local function UpdateHotspots()
    if not panel:IsVisible() then return end
    for _, spot in ipairs(spots) do
        local region = spot.region
        local visible = region:IsVisible() and region:GetAlpha() > 0
        spot:SetShown(visible)
    end
    UpdateEditing()
end

local holder = CreateFrame("Frame", nil, panel)
holder:SetSize(1, 1)
holder:SetScale(PLATE_SCALE)
holder:SetPoint("CENTER", 0, 0)

local plate = Plateau.CreatePreview(holder, sample)
plate:SetPoint("CENTER")
ns.Drag.SetDotParent(panel)
ns.Drag.SetTargets(SnapTargets)
AddHotspots(plate)

local redoButton = ns.Widgets.Button(panel, "Redo", 94, function() ns.Undo.Redo() end)
redoButton:SetFrameLevel(outline:GetFrameLevel() + 1)

local undoButton = ns.Widgets.Button(panel, "Undo", 94)
Style.DropArrow(undoButton)
undoButton:SetPoint("TOPRIGHT", -layout.pad, -8)
redoButton:SetPoint("TOPRIGHT", undoButton, "BOTTOMRIGHT", 0, -4)
undoButton:SetFrameLevel(outline:GetFrameLevel() + 1)
undoButton:SetScript("OnClick", function(self)
    local options = {}
    for i, label in ipairs(ns.Undo.History()) do
        options[i] = { value = i, label = Style.T(i == 1 and "Undo: %s" or "Undo back to: %s"):format(Style.T(label)) }
    end
    if #options == 0 then return end
    ns.ShowList(self, options, nil, function(steps)
        ns.Undo.Undo(steps)
    end, { width = 280, alignRight = true, maxVisible = 20 })
end)

local function UpdateUndo(canUndo, canRedo)
    undoButton:SetEnabled(canUndo)
    undoButton:SetAlpha(canUndo and 1 or 0.4)
    local count = ns.Undo.Count()
    if count > 0 then
        undoButton.label:SetFormattedText("Undo (%d)", count)
    else
        undoButton.label:SetText("Undo")
    end
    redoButton:SetEnabled(canRedo)
    redoButton:SetAlpha(canRedo and 1 or 0.4)
end
ns.Undo.OnChanged(UpdateUndo)
UpdateUndo(false, false)
Style.Tooltip(undoButton, { label = "Undo", tooltip = "Undoes your last change. Open the list to undo up to 20. Switching profiles clears it." })
redoButton:HookScript("OnEnter", function(self)
    local label = ns.Undo.NextRedo()
    if not label then return end
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    local accent = Style.StateColor()
    GameTooltip:SetText(Style.T("Redo"), accent[1], accent[2], accent[3])
    GameTooltip:AddLine(Style.T("Puts back: %s"):format(Style.T(label)), 1, 1, 1, true)
    GameTooltip:Show()
end)
redoButton:HookScript("OnLeave", function() GameTooltip:Hide() end)

local function ApplySample()
    local cast = castData
    local kind = picks.cast
    cast.important = kind == "important" or kind == "importantStop"
    cast.onCooldown = kind == "kickCooldown"
    cast.notInterruptible = kind == "cantInterrupt" or kind == "importantStop"
    cast.interrupted = kind == "interrupted"
    sample.cast = cast
    local executeOn = On("look.execute.highlight") or On("look.execute.lines")
    sample.health = (sectionKey == "health" and executeOn) and 0.12 or baseHealth
    local enemy = picks.enemy
    sample.mobType = MOB_TYPES[enemy] and enemy or "caster"
    sample.isPlayer = enemy == "enemyPlayer" or nil
    sample.class = enemy == "enemyPlayer" and playerClass or nil
    sample.neutral = enemy == "neutral" or nil
    sample.tapped = enemy == "tapped" or nil
    sample.classification = picks.badge
    sample.threat = picks.threat ~= "none" and picks.threat or nil
    sample.questColor = (sectionKey == "quest" and On("look.colors.quest")) or nil
    sample.levelOffset = 1
    sample.outOfRange = nil
    sample.isTarget = sectionKey == "target"
    sample.isFocus = sectionKey == "focus"
    sample.mouseover = sectionKey == "mouseover"
    sample.absorb = On("look.shield.absorbs") and 0.15 or 0
    sample.raidMarker = On("look.raidMarker.enabled") and baseMarker or nil
    sample.quest = On("look.quest.enabled") and baseQuest or nil
    sample.classPower = On("look.classPower.enabled")
    sample.showFaction = sectionKey == "faction" or nil
    sample.enemyPower = On("look.enemyPower.enabled")
    sample.forces = (On("look.forces.enabled") and Plateau.flavor ~= "forever") and baseForces or nil
    local auras = {}
    if On("look.auras.enabled") then
        for key, count in pairs(AURA_COUNTS) do
            if On("look.auras." .. key .. ".enabled") then
                auras[key] = count
            end
        end
    end
    sample.auras = auras
    local warnings = sectionKey == "shield"
    sample.alerts.important = warnings and On("look.shield.alertImportant")
    sample.alerts.defensive = warnings and On("look.shield.alertDefensive")
    sample.alerts.enrage = warnings and On("look.shield.alertEnrage")
    sample.alerts.magic = warnings and On("look.shield.alertMagic")
end
ApplySample()
Plateau.SetPreviewState(plate, sample)

local CAST_TIME, HOLD, KICK_BACK = 2.5, 0.4, 0.85
local castPlayer = CreateFrame("Frame", nil, panel)
castPlayer:Hide()
local castElapsed = 0

local function DrawCast(progress)
    local bar = plate.castbar
    bar:SetValue(progress)
    bar.kickPositioner:SetValue(progress)
    local back = KICK_BACK - progress
    bar.kickMarker:SetValue(back > 0 and back or 0)
    bar.kickLine:SetAlpha(back > 0 and 1 or 0)
    bar.timer:SetFormattedText("%.1f", (1 - progress) * CAST_TIME)
end

castPlayer:SetScript("OnUpdate", function(self, delta)
    castElapsed = castElapsed + delta
    if castElapsed >= CAST_TIME + HOLD then
        self:Hide()
        Plateau.SetPreviewState(plate, sample)
        UpdateHotspots()
        return
    end
    DrawCast(math.min(castElapsed / CAST_TIME, 1))
end)
panel:HookScript("OnHide", function() castPlayer:Hide() end)

local function PlayCast()
    if not sample.cast or picks.cast == "interrupted" then return end
    castElapsed = 0
    DrawCast(0)
    castPlayer:Show()
end

local function PreviewChanged()
    ApplySample()
    if sectionKey ~= "friendly" then
        Plateau.SetPreviewState(plate, sample)
    end
    UpdateHotspots()
end
ns.RefreshChips = PreviewChanged

function ns.SetPreviewPick(key, value)
    picks[key] = value
    PreviewChanged()
    if key == "cast" then
        PlayCast()
    end
end

function ns.ShowKickMarkerCast()
    ns.SetPreviewPick("cast", "kickCooldown")
end

local snapButton = ns.Widgets.Button(panel, "", 94)
snapButton:SetPoint("TOPRIGHT", redoButton, "BOTTOMRIGHT", 0, -4)
snapButton:SetFrameLevel(outline:GetFrameLevel() + 1)
local function PaintSnap()
    snapButton.label:SetText(ns.Drag.SnapEnabled() and "Snap: On" or "Snap: Off")
end
snapButton:SetScript("OnClick", function()
    ns.Drag.SetSnapEnabled(not ns.Drag.SnapEnabled())
    PaintSnap()
end)
PaintSnap()
Style.Tooltip(snapButton, { label = "Snapping", tooltip = "On: dragged parts snap to the guide dots. Off: they land where you drop them. Hold Shift to skip snapping once." })

function ns.SetPreviewSection(key)
    if key ~= sectionKey then
        castPlayer:Hide()
        ResetPicks()
    end
    sectionKey = key
    editingTitle = nil
    for _, section in ipairs(ns.sections) do
        if section.key == key then
            editingTitle = section.title
            break
        end
    end
    ApplySample()
    Plateau.SetPreviewState(plate, key == "friendly" and friendlySample or sample)
    UpdateHotspots()
    if key == "castbar" and not castPlayer:IsShown() then
        PlayCast()
    end
    if not hovered then
        hint:SetText(Hint())
    end
end

ns.tour.preview, ns.tour.undo, ns.tour.snap = panel, undoButton, snapButton

ns.RefreshPreviewEditing = UpdateHotspots

Plateau.OnRestyle(UpdateHotspots)
panel:SetScript("OnShow", UpdateHotspots)
UpdateHotspots()
