local _, ns = ...

local Style = ns.Style
local C = Style.colors
local layout = ns.layout

local PLATE_SCALE = layout.plateScale
local HINT = "Click a part to edit it. Drag to move it, or drag it to Turned off to hide it. Shift places it freely; arrow keys move it 1 px, with Shift 10 px."

local sectionKey, editingTitle
local here = {}
local focus

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
    local worldOnly = next(here) ~= nil
    for key in pairs(here) do
        if not WORLD_ONLY[key] then
            worldOnly = false
        end
    end
    if worldOnly then
        parts[#parts + 1] = T("Applies to in-world nameplates; the preview does not show it.")
    else
        if STATE_NOTES[sectionKey] then
            parts[#parts + 1] = T(STATE_NOTES[sectionKey])
        end
        parts[#parts + 1] = T(HINT)
    end
    return table.concat(parts, " ")
end

local panel = ns.previewStage

local hint = Style.Text(panel, 11, C.muted)
hint:SetPoint("BOTTOMLEFT", layout.pad, 10)
hint:SetPoint("BOTTOMRIGHT", -layout.pad, 10)
hint:SetJustifyH("CENTER")
hint:SetWordWrap(true)
hint:SetText(Hint())

local outline = CreateFrame("Frame", nil, panel)
outline:SetFrameLevel(panel:GetFrameLevel() + 200)
Style.OutlineEdges(outline, Style.HOVER_MARK)
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
        health = 0.84,
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
            progress = 1,
            name = "Shadow Bolt",
            icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
            timer = "0.0",
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

local function DragOf(spot)
    if spot and spot.friendlyHere and here.friendly then
        return nil
    end
    return spot and spot.drag
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
        left, right = ns.Drag.FitText(spot.region, left, right, 2)
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

local OUTLINE_GAP = 2

local function PixelFactor()
    return PixelUtil and PixelUtil.GetPixelToUIUnitFactor and PixelUtil.GetPixelToUIUnitFactor() or 1
end

local function DrawnBounds(region)
    if region.icons then
        local l, r, t, b = ns.Drag.IconBounds(region)
        if l then
            return l, r, t, b
        end
    end
    return region:GetLeft(), region:GetRight(), region:GetTop(), region:GetBottom()
end

local function Whole(v)
    return math.floor(v + 0.5)
end

local function PixelBox(spot)
    local ring = spot.ring and Resolve(spot.ring)
    local l, r, t, b, scale
    if ring then
        local region = spot.region
        l, r, t, b = DrawnBounds(region)
        scale = region:GetEffectiveScale()
    else
        l, r, t, b = Bounds(spot)
        scale = spot:GetEffectiveScale()
    end
    if not l then return nil end
    local toPx = scale / PixelFactor()
    ring = math.max(0, math.floor((ring or 0) + 0.5))
    return Whole(l * toPx) - ring, Whole(r * toPx) + ring, Whole(t * toPx) + ring, Whole(b * toPx) - ring
end

local function Put(texture, back, x1, y1, x2, y2)
    texture:ClearAllPoints()
    texture:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x1 * back, y1 * back)
    texture:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", x2 * back, y2 * back)
end

local function FrameAround(frame, l, r, t, b)
    local grow = OUTLINE_GAP + 1
    local back = PixelFactor() / frame:GetEffectiveScale()
    l, r, t, b = l - grow, r + grow, t + grow, b - grow
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", l * back, t * back)
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", r * back, b * back)
    local edges = frame.outlineEdges
    if edges then
        Put(edges[1], back, l, t, r, t - 1)
        Put(edges[2], back, l, b + 1, r, b)
        Put(edges[3], back, l, t - 1, l + 1, b + 1)
        Put(edges[4], back, r - 1, t - 1, r, b + 1)
    end
end

local function OwnBorders(spot, list)
    local region = spot.region
    if not region then return list end
    if spot.borders then
        for _, border in ipairs(spot.borders()) do
            list[#list + 1] = border
        end
    elseif region.icons then
        for _, icon in ipairs(region.icons) do
            if icon.border then
                list[#list + 1] = icon.border
            end
            if icon.dispel and icon.dispel.SetHighlight then
                list[#list + 1] = icon.dispel
            end
        end
    elseif type(region.border) == "table" and region.border.SetHighlight then
        list[#list + 1] = region.border
    end
    return list
end

local ownScratch = {}

local function HasOwnBorder(spot)
    if not spot.region then return false end
    wipe(ownScratch)
    for _, border in ipairs(OwnBorders(spot, ownScratch)) do
        local owner = border.owner
        if border:IsDrawn() and (not owner or owner:IsVisible()) then
            return true
        end
    end
    return false
end

function ns.OutlineSpot(frame, spot, keep)
    local own = HasOwnBorder(spot)
    if own and not keep then return false end
    local l, r, t, b = PixelBox(spot)
    if not l then return false end
    FrameAround(frame, l, r, t, b)
    for _, edge in ipairs(frame.outlineEdges or {}) do
        edge:SetShown(not own)
    end
    return true
end

local function SpotAt()
    local best, bestArea
    local cursorX, cursorY = GetCursorPosition()
    for _, spot in ipairs(spots) do
        if spot:IsShown() then
            local left, right, top, bottom = Bounds(spot)
            if left then
                local scale = spot:GetEffectiveScale()
                local x, y = cursorX / scale, cursorY / scale
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
local marksDirty = true

local function PlaceOutline(spot)
    local selected = ns.Drag.GetSelected()
    if (selected and selected.spot == spot) or not ns.OutlineSpot(outline, spot) then
        outline:Hide()
        return
    end
    outline:Show()
end

local function SetHovered(spot)
    if spot == hovered then
        if spot then
            PlaceOutline(spot)
        end
        return
    end
    hovered = spot
    if spot then
        PlaceOutline(spot)
        hint:SetFormattedText(DragOf(spot) and "%s  -  click to edit, drag to move, arrow keys to nudge" or "%s  -  click to edit", Style.T(Resolve(spot.label)))
        local tint = Style.StateColor()
        Style.PaintText(hint, tint)
    else
        outline:Hide()
        hint:SetText(Hint())
        Style.PaintText(hint, C.muted)
    end
end

local layer = CreateFrame("Frame", nil, panel)
layer:SetAllPoints(panel)
layer:SetFrameLevel(panel:GetFrameLevel() + 180)
layer:EnableMouse(true)
local pressedSpot

local function HoverTick(self)
    if ns.Drag.IsDragging() then
        if hovered then
            PlaceOutline(hovered)
        end
        return
    end
    SetHovered(self:IsMouseOver() and SpotAt() or nil)
end
layer:SetScript("OnLeave", function()
    if not ns.Drag.IsDragging() then
        SetHovered(nil)
    end
end)

layer:SetScript("OnMouseDown", function(_, button)
    if button ~= "LeftButton" then return end
    pressedSpot = SpotAt()
    local drag = DragOf(pressedSpot)
    if drag then
        ns.Drag.Press(drag, pressedSpot)
    end
end)
layer:SetScript("OnMouseUp", function(_, button)
    if button ~= "LeftButton" then return end
    local spot = pressedSpot
    pressedSpot = nil
    local drag = DragOf(spot)
    local dragged = drag and ns.Drag.Release()
    if dragged or not spot then return end
    if drag then
        drag.spot = spot
    end
    ns.Drag.Select(drag)
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
    Hotspot(plate, plate, "shield", "Warnings", 1, 6)
    Hotspot(plate, plate.health, function() return here.healthColors and "healthColors" or "health" end,
        function() return here.healthColors and "Colors" or "Health bar" end, 20, 0)
    Hotspot(plate, plate.castbar, "castbar", "Cast bar", 60, 0, castbarDrag)
    Hotspot(plate, plate.healthText, "healthText", "Health text", 80, 3,
        Drag.PositionSpec({ path = "look.healthText", positionKey = "anchor", text = true, fixedGap = 3, region = plate.healthText, anchor = AtHealth(plate) })).setting = "Show health text"
    Hotspot(plate, plate.enemyTarget, "name", "Enemy target name", 80, 3,
        Drag.PositionSpec({ path = "look.enemyTarget", positionKey = "anchor", text = true, fixedGap = 3, region = plate.enemyTarget, anchor = AtHealth(plate) })).setting = "Show enemy target name"
    Hotspot(plate, plate.level, "level", "Level", 80, 3,
        Drag.PositionSpec({ path = "look.level", positionKey = "anchor", text = true, fixedGap = 3, region = plate.level, anchor = AtHealth(plate) }))
    local nameSpot = Hotspot(plate, plate.name, function() return here.friendly and "friendly" or "name" end, "Name", 70, 1, Drag.NameSpec(plate))
    nameSpot.fitText = true
    nameSpot.friendlyHere = true
    Hotspot(plate, plate.raidMarker, "raidMarker", "Raid target icon", 80, 0,
        Drag.PositionSpec({
            path = function() return here.friendly and "look.friendly.raidMarker" or "look.raidMarker" end,
            readPath = function()
                if here.friendly and Plateau.DB:Get("look.friendly.raidMarker.own") then
                    return "look.friendly.raidMarker"
                end
                return "look.raidMarker"
            end,
            extra = function()
                if not here.friendly then
                    return {}
                end
                local own = Plateau.DB:Get("look.friendly.raidMarker.own")
                return { ["look.friendly.raidMarker.own"] = true, ["look.friendly.raidMarker.gap"] = Plateau.DB:Get(own and "look.friendly.raidMarker.gap" or "look.raidMarker.gap") }
            end,
            region = plate.raidMarker,
            anchor = AtPlate(plate),
        })).ring = 0
    Hotspot(plate, plate.classification, "classification", "Elite icon", 80, 1,
        Drag.PositionSpec({ path = "look.classification", region = plate.classification, anchor = AtPlate(plate) })).ring = 0
    Hotspot(plate, plate.quest, "quest", "Quest icon", 80, 1,
        Drag.PositionSpec({ path = "look.quest", region = plate.quest, anchor = AtPlate(plate) })).ring = 0
    Hotspot(plate, plate.questProgress, "quest", "Quest progress", 81, 2,
        Drag.PositionSpec({ path = "look.quest.progress", text = true, region = plate.questProgress, anchor = AtPlate(plate) })).fitText = true
    Hotspot(plate, plate.enemyPowerBar, "enemyPower", "Enemy power bar", 85, 1, Drag.EnemyPowerSpec(plate))
    Hotspot(plate, plate.classPower, "classPower", "Class resource", 80, 2,
        Drag.PositionSpec({ path = "look.classPower", region = plate.classPower, anchor = AtPlate(plate), noRing = true }))
    Hotspot(plate, plate.forces, "forces", "Mythic+ enemy forces", 80, 3,
        Drag.PositionSpec({ path = "look.forces", region = plate.forces, anchor = AtPlate(plate) }))
    local threatSpot = Hotspot(plate, plate.threatText, "threatText", "Threat percent", 80, 3,
        Drag.PositionSpec({ path = "look.threatText", region = plate.threatText, anchor = AtPlate(plate) }))
    threatSpot.fitText = true
    threatSpot.setting = "Show threat percent"
    Hotspot(plate, plate.faction, "faction", "Faction icon", 80, 1,
        Drag.PositionSpec({ path = "look.faction", region = plate.faction, anchor = AtPlate(plate) })).ring = 0
    Hotspot(plate, plate.kickHolder, "kickers", "Kicker icons", 80, 1,
        Drag.PositionSpec({ path = "look.kickers", region = plate.kickHolder, anchor = AtPlate(plate) })).ring = function()
            return Plateau.DB:Get("look.kickers.borderSize") or 1
        end
    Hotspot(plate, plate.subtitle, "friendly", "Guild and title line", 75, 2).fitText = true
    local castIcon = Hotspot(plate, plate.castbar.icon, "castbar", "Spell icon", 62, 0, Drag.CastIconSpec(plate))
    castIcon.setting = "Show spell icon"
    local castIconBorders = { plate.castbar.iconBorder }
    castIcon.borders = function()
        return castIconBorders
    end
    castIcon.ring = function()
        return Plateau.HealthBorderOuter({
            borderStyle = Plateau.DB:Get("look.castbar.borderStyle"),
            borderSize = Plateau.DB:Get("look.castbar.borderSize"),
        })
    end
    local castTarget = Hotspot(plate, plate.castbar.target, "castbar", "Cast target", 65, 2,
        Drag.PositionSpec({ path = "look.castbar", positionKey = "targetPosition", xKey = "targetOffsetX", yKey = "targetOffsetY", fixedGap = 2, region = plate.castbar.target, anchor = function() return plate.castbar end }))
    castTarget.fitText = true
    castTarget.setting = "Show cast target"
    local castName = Hotspot(plate, plate.castbar.text, "castbar",
        function() return picks.cast == "interrupted" and "Interrupted text" or "Spell name" end, 65, 1, Drag.SpellNameSpec(plate))
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
        local auraSpot = Hotspot(plate, fake, auraSections[key], auraNames[key], 75, 1, auraDrag)
        auraSpot.snapTarget = fake
        auraSpot.ring = function()
            return Plateau.DB:Get("look.auras." .. key .. ".borderSize") or 1
        end
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

local editOutlines = {}
local TOUCH = 4

local function EditOutline(index)
    local frame = editOutlines[index]
    if not frame then
        frame = CreateFrame("Frame", nil, panel)
        frame:SetFrameLevel(outline:GetFrameLevel() - 1)
        Style.OutlineEdges(frame)
        frame:SetAlpha(0.6)
        editOutlines[index] = frame
    end
    return frame
end

local function Touching(a, b)
    return a[1] <= b[2] + TOUCH and b[1] <= a[2] + TOUCH and a[4] <= b[3] + TOUCH and b[4] <= a[3] + TOUCH
end

local function UpdateEditing()
    local boxes = {}
    local function Collect(only)
        local found, bordered, plain = 0, {}, {}
        for _, spot in ipairs(spots) do
            local key = Resolve(spot.sectionKey)
            if spot:IsShown() and here[key] and (not only or only == key) then
                found = found + 1
                local l, r, t, b = PixelBox(spot)
                if l then
                    local list = HasOwnBorder(spot) and bordered or plain
                    list[#list + 1] = { l, r, t, b }
                end
            end
        end
        for _, box in ipairs(plain) do
            local inside = false
            for _, cover in ipairs(bordered) do
                if box[1] >= cover[1] - 1 and box[2] <= cover[2] + 1 and box[3] <= cover[3] + 1 and box[4] >= cover[4] - 1 then
                    inside = true
                    break
                end
            end
            if not inside then
                boxes[#boxes + 1] = box
            end
        end
        return found
    end
    if sectionKey and not ns.Drag.Active() then
        if Collect(focus) == 0 and focus then
            Collect(nil)
        end
    end
    local merged = true
    while merged do
        merged = false
        for i = #boxes, 2, -1 do
            for j = 1, i - 1 do
                local a, b = boxes[j], boxes[i]
                if Touching(a, b) then
                    a[1], a[2] = math.min(a[1], b[1]), math.max(a[2], b[2])
                    a[3], a[4] = math.max(a[3], b[3]), math.min(a[4], b[4])
                    table.remove(boxes, i)
                    merged = true
                    break
                end
            end
        end
    end
    local count = 0
    for i, box in ipairs(boxes) do
        local frame = EditOutline(i)
        FrameAround(frame, box[1], box[2], box[3], box[4])
        frame:Show()
        count = i
    end
    for i = count + 1, #editOutlines do
        editOutlines[i]:Hide()
    end
end

local RefreshTray

local function UpdateHotspots()
    if not panel:IsVisible() then return end
    marksDirty = true
    if ns.PinPreview then
        ns.PinPreview()
    end
    for _, spot in ipairs(spots) do
        local region = spot.region
        local visible = region:IsVisible() and region:GetAlpha() > 0
        spot:SetShown(visible)
    end
    if RefreshTray then
        RefreshTray()
    end
    UpdateEditing()
end

local holder = CreateFrame("Frame", nil, panel)
holder:SetSize(1, 1)
holder:SetScale(PLATE_SCALE)
holder:SetPoint("CENTER", 0, 0)

local plate = Plateau.CreatePreview(holder, sample)
local holderX = 0

function ns.PinPreview()
    holder:ClearAllPoints()
    holder:SetPoint("CENTER", holderX, 0)
    local left, top = plate:GetLeft(), plate:GetTop()
    if type(left) ~= "number" or type(top) ~= "number" then return end
    local toPx = plate:GetEffectiveScale() / PixelFactor()
    local back = PixelFactor() / holder:GetEffectiveScale()
    local dx = math.floor(left * toPx + 0.5) - left * toPx
    local dy = math.floor(top * toPx + 0.5) - top * toPx
    holder:SetPoint("CENTER", holderX + dx * back, dy * back)
end

function ns.OnWindowScale()
    plate.pixelScale = nil
    if Plateau.RepixelPlate then
        Plateau.RepixelPlate(plate)
    end
    ns.PinPreview()
    UpdateEditing()
end
plate:SetPoint("CENTER")
ns.Drag.SetDotParent(panel)
ns.Drag.SetTargets(SnapTargets)
AddHotspots(plate)

local slot = layout.undoSlot
local redoButton = ns.TextButton(slot, "Redo", function() ns.Undo.Redo() end)
redoButton:SetPoint("RIGHT", slot, "RIGHT", 0, 0)

local undoButton = ns.TextButton(slot, "Undo")
undoButton:SetPoint("RIGHT", redoButton, "LEFT", -10, 0)
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
    undoButton.restColor = canUndo and C.text or C.faint
    Style.PaintText(undoButton.label, undoButton.restColor)
    local count = ns.Undo.Count()
    if count > 0 then
        undoButton.label:SetFormattedText("Undo (%d)", count)
    else
        undoButton.label:SetText("Undo")
    end
    undoButton:Fit()
    redoButton:SetEnabled(canRedo)
    redoButton.restColor = canRedo and C.text or C.faint
    Style.PaintText(redoButton.label, redoButton.restColor)
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
    sample.health = (here.health and executeOn) and 0.12 or baseHealth
    local enemy = picks.enemy
    sample.mobType = MOB_TYPES[enemy] and enemy or "caster"
    sample.isPlayer = enemy == "enemyPlayer" or nil
    sample.class = enemy == "enemyPlayer" and playerClass or nil
    sample.neutral = enemy == "neutral" or nil
    sample.tapped = enemy == "tapped" or nil
    sample.classification = picks.badge
    sample.threat = picks.threat ~= "none" and picks.threat or nil
    sample.questColor = (here.quest and On("look.colors.quest")) or nil
    sample.levelOffset = 1
    sample.outOfRange = nil
    sample.isTarget = here.target == true
    sample.isFocus = here.focus == true
    sample.mouseover = here.mouseover == true
    sample.absorb = On("look.shield.absorbs") and 0.15 or 0
    sample.raidMarker = On("look.raidMarker.enabled") and baseMarker or nil
    sample.quest = On("look.quest.enabled") and baseQuest or nil
    sample.classPower = On("look.classPower.enabled")
    sample.showFaction = here.faction or On("look.faction.enabled")
    sample.showKickers = here.kickers or On("look.kickers.enabled")
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
    local warnings = here.shield == true
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
    if not here.friendly then
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

local snapButton = ns.TextButton(ns.previewBar, "")
snapButton:SetPoint("RIGHT", ns.previewBar, "RIGHT", -10, 0)
local function PaintSnap()
    snapButton.label:SetFormattedText(Style.T("Snap %s"), "|cffe2dccf" .. Style.T(ns.Drag.SnapEnabled() and "on" or "off") .. "|r")
    snapButton:Fit()
end
snapButton:SetScript("OnClick", function()
    ns.Drag.SetSnapEnabled(not ns.Drag.SnapEnabled())
    PaintSnap()
end)
PaintSnap()
Style.Tooltip(snapButton, { label = "Snapping", tooltip = "On: dragged parts snap to the guide dots. Off: they land where you drop them. Hold Shift to skip snapping once." })

function ns.SetPreviewSection(key, parts, title)
    if key ~= sectionKey then
        castPlayer:Hide()
        ResetPicks()
    end
    sectionKey = key
    here = parts or { [key] = true }
    focus = nil
    editingTitle = title
    ApplySample()
    Plateau.SetPreviewState(plate, here.friendly and friendlySample or sample)
    UpdateHotspots()
    if here.castbar and not castPlayer:IsShown() then
        PlayCast()
    end
    if not hovered then
        hint:SetText(Hint())
    end
end



local waiting = CreateFrame("Frame", nil, panel)
waiting:SetFrameLevel(panel:GetFrameLevel() + 240)
waiting:SetPoint("TOPLEFT", layout.pad, -8)
waiting:SetHeight(18)
Style.Fill(waiting, C.hover)
Style.Border(waiting, C.edge)
waiting.text = Style.Text(waiting, 11, C.text)
waiting.text:SetPoint("LEFT", 6, 0)
waiting:Hide()
local waitCheck = 0
waiting.watch = CreateFrame("Frame", nil, panel)
waiting.watch:SetScript("OnUpdate", function(_, elapsed)
    waitCheck = waitCheck - elapsed
    if waitCheck > 0 then return end
    waitCheck = 0.5
    local list = Plateau.WaitingForCombat and Plateau.WaitingForCombat() or {}
    if #list == 0 then
        waiting:Hide()
        return
    end
    waiting.text:SetText(Style.T("Waiting for combat to end: %s"):format("|cffd07a3c" .. table.concat(list, ", ") .. "|r"))
    waiting:SetWidth(waiting.text:GetStringWidth() + 12)
    waiting:Show()
end)

function ns.SetPreviewFocus(key)
    if key == focus then return end
    focus = key
    if panel:IsVisible() then
        UpdateEditing()
    end
end

local rulerTop, rulerLeft = layout.rulerTop, layout.rulerLeft
local cross = CreateFrame("Frame", nil, panel:GetParent())
cross:SetAllPoints(panel:GetParent())
cross:SetFrameLevel(panel:GetFrameLevel() + 230)
cross:Hide()

local crossV = cross:CreateTexture(nil, "OVERLAY")
crossV:SetPoint("TOP", rulerTop, "TOP")
crossV:SetPoint("BOTTOM", panel, "BOTTOM")
Style.PixelWidth(crossV)
local crossH = cross:CreateTexture(nil, "OVERLAY")
crossH:SetPoint("LEFT", rulerLeft, "LEFT")
crossH:SetPoint("RIGHT", panel, "RIGHT")
Style.PixelHeight(crossH)

local function CrossTag()
    local tag = CreateFrame("Frame", nil, cross)
    tag:SetFrameLevel(cross:GetFrameLevel() + 2)
    tag:SetHeight(12)
    tag.fill = Style.Fill(tag, C.accent)
    tag.text = Style.Text(tag, 9, C.primaryText, "CENTER")
    tag.text:SetPoint("CENTER", 0, 0)
    return tag
end
local tagX, tagY = CrossTag(), CrossTag()

local function PaintCross()
    Style.Paint(crossV, C.accent, 0.35)
    Style.Paint(crossH, C.accent, 0.35)
    Style.Paint(tagX.fill, C.accent, 1)
    Style.Paint(tagY.fill, C.accent, 1)
    Style.PaintText(tagX.text, C.primaryText)
    Style.PaintText(tagY.text, C.primaryText)
end
PaintCross()
Style.OnTheme(PaintCross)

local function MoverCenter(spec)
    local mover = spec.Mover and spec.Mover()
    local left, right, top, bottom = mover and mover:GetLeft(), mover and mover:GetRight(), mover and mover:GetTop(), mover and mover:GetBottom()
    local stageLeft, stageTop = panel:GetLeft(), panel:GetTop()
    if not (left and stageLeft) then return nil end
    local ratio = mover:GetEffectiveScale() / panel:GetEffectiveScale()
    return (left + right) / 2 * ratio - stageLeft, stageTop - (top + bottom) / 2 * ratio
end

local function SetTag(tag, value)
    tag.text:SetText(math.floor(value + 0.5))
    tag:SetWidth(math.max(18, tag.text:GetStringWidth() + 6))
end

local markBorders = {}
local markedHover, markedPick

local function MarksTick()
    local chosen = ns.Drag.GetSelected()
    chosen = chosen and chosen.spot
    if not marksDirty and chosen == markedPick and hovered == markedHover then return end
    marksDirty, markedPick, markedHover = false, chosen, hovered
    for _, spot in ipairs(spots) do
        local tint = (spot == chosen and Style.PICK_MARK) or (spot == hovered and Style.HOVER_MARK) or nil
        wipe(markBorders)
        for _, border in ipairs(OwnBorders(spot, markBorders)) do
            border:SetHighlight(tint)
        end
    end
end

local dragging = false
local panelLeft, panelTop

local function CrossTick()
    local spec = ns.Drag.Active()
    local left, top = panel:GetLeft(), panel:GetTop()
    if (spec ~= nil) ~= dragging or left ~= panelLeft or top ~= panelTop then
        dragging = spec ~= nil
        panelLeft, panelTop = left, top
        ns.PinPreview()
        UpdateEditing()
    end
    local x, y
    if spec then
        x, y = MoverCenter(spec)
    end
    if not x or x < 0 or y < 0 or x > panel:GetWidth() or y > panel:GetHeight() then
        cross:Hide()
        return
    end
    crossV:ClearAllPoints()
    crossV:SetPoint("TOP", rulerTop, "TOPLEFT", x, 0)
    crossV:SetPoint("BOTTOM", panel, "BOTTOMLEFT", x, 0)
    crossH:ClearAllPoints()
    crossH:SetPoint("LEFT", rulerLeft, "TOPLEFT", 0, -y)
    crossH:SetPoint("RIGHT", panel, "TOPRIGHT", 0, -y)
    SetTag(tagX, (x - (math.floor(panel:GetWidth() / 2) - layout.centerShift)) / PLATE_SCALE)
    tagX:ClearAllPoints()
    tagX:SetPoint("CENTER", rulerTop, "TOPLEFT", x, -rulerTop:GetHeight() / 2)
    SetTag(tagY, (math.floor(panel:GetHeight() / 2) - y) / PLATE_SCALE)
    tagY:ClearAllPoints()
    tagY:SetPoint("CENTER", rulerLeft, "TOPLEFT", rulerLeft:GetWidth() / 2, -y)
    cross:Show()
end

local TRAY_WIDTH, TILE_HEIGHT, TILE_GAP, TRAY_PAD, TRAY_HEAD = 164, 18, 3, 6, 16
local SKULL = { 0.75, 1, 0.25, 0.5 }

local tray = CreateFrame("Frame", nil, panel)
tray:SetPoint("TOPRIGHT", -8, -8)
tray:SetPoint("BOTTOMRIGHT", -8, 8)
tray:SetWidth(TRAY_WIDTH)
tray:SetFrameLevel(panel:GetFrameLevel() + 185)
tray:EnableMouse(true)
local trayFill = Style.Fill(tray, C.window)
Style.Paint(trayFill, C.window, 0.85)
local trayBorder = CreateFrame("Frame", nil, tray)
trayBorder:SetAllPoints()
Style.Border(trayBorder, C.edge)
tray.title = Style.Text(tray, 10, C.muted)
tray.title:SetPoint("TOPLEFT", TRAY_PAD, -TRAY_PAD)
tray.title:SetPoint("TOPRIGHT", -TRAY_PAD, -TRAY_PAD)
tray.title:SetText("Turned off")
tray.empty = Style.Text(tray, 10, C.faint)
tray.empty:SetPoint("TOPLEFT", tray.title, "BOTTOMLEFT", 0, -8)
tray.empty:SetPoint("RIGHT", -TRAY_PAD, 0)
tray.empty:SetWordWrap(true)
tray.empty:SetText("Everything is on the plate. Drag a part here to turn it off.")
Style.Tooltip(tray, { label = "Turned off", tooltip = "Parts that are turned off wait here. Drag one onto the plate to turn it on, or drag a part from the plate here to turn it off. Click one to open its settings." })
ns.Drag.SetDropZone(tray)

hint:ClearAllPoints()
hint:SetPoint("BOTTOMLEFT", layout.pad, 10)
hint:SetPoint("BOTTOMRIGHT", -(TRAY_WIDTH + 16), 10)

local TRAY = {
    { label = "Name", section = "name", region = plate.name, paths = { "look.name.enabled" }, text = "Name" },
    { label = "Health text", section = "healthText", region = plate.healthText, paths = { "look.healthText.enabled" }, text = "84%" },
    { label = "Level", section = "level", region = plate.level, paths = { "look.level.enabled" }, text = "81" },
    { label = "Enemy target", section = "name", region = plate.enemyTarget, paths = { "look.enemyTarget.enabled" }, text = "Tar" },
    { label = "Threat", section = "threatText", region = plate.threatText, paths = { "look.threatText.enabled" }, text = "99" },
    { label = "Raid icon", section = "raidMarker", region = plate.raidMarker, paths = { "look.raidMarker.enabled" }, texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", coords = SKULL },
    { label = "Elite icon", section = "classification", region = plate.classification, paths = { "look.classification.enabled" }, atlas = "nameplates-icon-elite-gold" },
    { label = "Quest icon", section = "quest", region = plate.quest, paths = { "look.quest.enabled" }, atlas = "QuestNormal" },
    { label = "Quest count", section = "quest", region = plate.questProgress, paths = { "look.quest.enabled", "look.quest.showProgress" }, text = "3/8" },
    { label = "Faction", section = "faction", region = plate.faction, paths = { "look.faction.enabled" }, atlas = "UI-HUD-UnitFrame-Player-PVP-AllianceIcon" },
    { label = "Kickers", section = "kickers", region = plate.kickHolder, paths = { "look.kickers.enabled" }, texture = "Interface\\Icons\\Ability_Kick" },
    { label = "Enemy forces", section = "forces", region = plate.forces, paths = { "look.forces.enabled" }, text = "0.8", retail = true },
    { label = "Enemy power", section = "enemyPower", region = plate.enemyPowerBar, paths = { "look.enemyPower.enabled" }, bar = { 0.2, 0.45, 1 } },
    { label = "Class resource", section = "classPower", region = plate.classPower, paths = { "look.classPower.enabled" }, bar = { 1, 0.84, 0.3 } },
    { label = "Spell icon", section = "castbar", region = plate.castbar.icon, paths = { "look.castbar.showIcon" }, texture = "Interface\\Icons\\Spell_Shadow_ShadowBolt" },
    { label = "Cast target", section = "castbar", region = plate.castbar.target, paths = { "look.castbar.showTarget" }, text = "You" },
    { label = "Cast time", section = "castbar", region = plate.castbar.timer, paths = { "look.castbar.showTimer" }, text = "1.2" },
    { label = "Your debuffs", section = "auraMine", aura = "mine", paths = { "look.auras.enabled", "look.auras.mine.enabled" }, texture = "Interface\\Icons\\Spell_Shadow_ShadowWordPain" },
    { label = "Crowd control", section = "auraCC", aura = "cc", paths = { "look.auras.enabled", "look.auras.cc.enabled" }, texture = "Interface\\Icons\\Spell_Nature_Polymorph" },
    { label = "Enemy buffs", section = "auraPurge", aura = "purge", paths = { "look.auras.enabled", "look.auras.purge.enabled" }, texture = "Interface\\Icons\\Spell_Holy_PowerWordShield" },
    { label = "Important", section = "auraImportant", aura = "important", paths = { "look.auras.enabled", "look.auras.important.enabled" }, texture = "Interface\\Icons\\Spell_Nature_LightningShield" },
}

local function TrayRegion(item)
    if item.aura then
        return plate.fakeAuras and plate.fakeAuras[item.aura]
    end
    return item.region
end

local function TraySpot(item)
    local region = TrayRegion(item)
    if not region then return nil end
    for _, spot in ipairs(spots) do
        if (spot.snapTarget or spot.region) == region and spot.drag then
            return spot
        end
    end
end

local function ItemOn(item)
    for _, path in ipairs(item.paths) do
        if not On(path) then
            return false
        end
    end
    return true
end

for _, item in ipairs(TRAY) do
    local spot = TraySpot(item)
    if spot then
        spot.trayOff = { [item.paths[#item.paths]] = false }
    end
end

local function Glyph(tile, item, size)
    local glyph
    if item.text then
        glyph = Style.Text(tile, 9, C.text, "CENTER")
        glyph:SetText(item.text)
        glyph:SetWidth(size + 8)
    elseif item.bar then
        glyph = tile:CreateTexture(nil, "ARTWORK")
        glyph:SetColorTexture(item.bar[1], item.bar[2], item.bar[3], 1)
        glyph:SetSize(size, math.max(3, math.floor(size / 4)))
    else
        glyph = tile:CreateTexture(nil, "ARTWORK")
        if item.atlas then
            glyph:SetAtlas(item.atlas)
        else
            glyph:SetTexture(item.texture)
            if item.coords then
                glyph:SetTexCoord(unpack(item.coords))
            else
                glyph:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            end
        end
        glyph:SetSize(size, size)
    end
    return glyph
end

local pressedTile
local grabWaiter = CreateFrame("Frame", nil, tray)

local function GrabFromTray(item)
    local values = {}
    for _, path in ipairs(item.paths) do
        values[path] = true
    end
    ns.Drag.Enable(values)
    local tries = 0
    grabWaiter:SetScript("OnUpdate", function(self)
        tries = tries + 1
        PreviewChanged()
        local spot = TraySpot(item)
        if spot and spot:IsShown() and IsMouseButtonDown("LeftButton") and ns.Drag.Grab(spot.drag, spot) then
            self:SetScript("OnUpdate", nil)
            SetHovered(spot)
        elseif tries >= 10 or not IsMouseButtonDown("LeftButton") then
            self:SetScript("OnUpdate", nil)
            ns.SelectSection(item.section)
        end
    end)
end

local function MakeTile(item)
    local tile = CreateFrame("Button", nil, tray)
    tile:SetFrameLevel(tray:GetFrameLevel() + 2)
    tile.fill = Style.Fill(tile, C.hover)
    tile.full = Glyph(tile, item, 12)
    tile.full:SetPoint("CENTER", tile, "LEFT", 11, 0)
    tile.label = Style.Text(tile, 10, C.text)
    tile.label:SetPoint("LEFT", 22, 0)
    tile.label:SetPoint("RIGHT", -2, 0)
    tile.label:SetText(item.label)
    tile.small = Glyph(tile, item, 14)
    tile.small:SetPoint("CENTER")
    tile:HookScript("OnEnter", function(self)
        Style.Paint(self.fill, C.buttonHover)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(Style.T(item.label), 1, 1, 1)
        GameTooltip:AddLine(Style.T("Drag onto the plate to turn it on. Click to open its settings."), 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    tile:HookScript("OnLeave", function(self)
        Style.Paint(self.fill, C.hover)
        GameTooltip:Hide()
    end)
    tile:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" then return end
        local x, y = GetCursorPosition()
        pressedTile = { item = item, x = x, y = y }
    end)
    tile:SetScript("OnClick", function()
        if pressedTile and pressedTile.item == item then
            pressedTile = nil
            ns.SelectSection(item.section)
        end
    end)
    return tile
end

for _, item in ipairs(TRAY) do
    item.tile = MakeTile(item)
end

local function CenterPlate()
    local shift = tray:IsShown() and math.floor((TRAY_WIDTH + 8) / 2) or 0
    holderX = -shift / PLATE_SCALE
    ns.PinPreview()
    layout.SetCenterShift(shift)
end

function RefreshTray()
    if here.friendly then
        tray:Hide()
        CenterPlate()
        return
    end
    tray:Show()
    CenterPlate()
    local off = {}
    for _, item in ipairs(TRAY) do
        local available = not (item.retail and Plateau.flavor == "forever")
        if available and not ItemOn(item) then
            off[#off + 1] = item
        end
        item.tile:Hide()
    end
    tray.empty:SetShown(#off == 0)
    local inner = TRAY_WIDTH - TRAY_PAD * 2
    local room = (tray:GetHeight() or 0) - TRAY_PAD * 2 - TRAY_HEAD
    local rows = math.max(1, math.floor((room + TILE_GAP) / (TILE_HEIGHT + TILE_GAP)))
    local compact = #off > rows * 2
    local columns = compact and 6 or 2
    local width = math.floor((inner - TILE_GAP * (columns - 1)) / columns)
    local height = compact and width or TILE_HEIGHT
    for i, item in ipairs(off) do
        local tile = item.tile
        local column, row = (i - 1) % columns, math.floor((i - 1) / columns)
        tile:ClearAllPoints()
        tile:SetPoint("TOPLEFT", tray, "TOPLEFT", TRAY_PAD + column * (width + TILE_GAP), -(TRAY_PAD + TRAY_HEAD + row * (height + TILE_GAP)))
        tile:SetSize(width, height)
        tile.full:SetShown(not compact)
        tile.label:SetShown(not compact)
        tile.small:SetShown(compact)
        tile:Show()
    end
end

local function TileTick()
    local press = pressedTile
    if not press then return end
    if not IsMouseButtonDown("LeftButton") then
        pressedTile = nil
        return
    end
    local x, y = GetCursorPosition()
    if math.abs(x - press.x) + math.abs(y - press.y) >= 4 * UIParent:GetEffectiveScale() then
        pressedTile = nil
        GameTooltip:Hide()
        GrabFromTray(press.item)
    end
end

local function TrayTick()
    if not tray:IsShown() then return end
    local over = ns.Drag.OverTray(ns.Drag.Active())
    if over ~= tray.over then
        tray.over = over
        Style.Paint(trayFill, over and C.hover or C.window, 0.85)
        Style.SetBorderColor(trayBorder, over and C.accent or C.edge)
    end
end

layer:SetScript("OnUpdate", function(self)
    HoverTick(self)
    MarksTick()
    CrossTick()
    TileTick()
    TrayTick()
end)
tray:SetScript("OnSizeChanged", function() RefreshTray() end)
RefreshTray()

Plateau.OnRestyle(UpdateHotspots)
panel:SetScript("OnShow", UpdateHotspots)
UpdateHotspots()
