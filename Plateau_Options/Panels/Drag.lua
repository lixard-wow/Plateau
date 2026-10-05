local _, ns = ...

local Style = ns.Style
local C = Style.colors

local SNAP = 8
local THRESHOLD = 4
local LIMIT = 80
local DOT = 5

local Drag = {}
ns.Drag = Drag

local dots = {}
local dotParent
local active
local pressed
local selected
local selectionFrame
local keys
local lastDragged = false

local function Apply(values)
    Plateau.DB:SetMany(values)
    if ns.RefreshAll then
        ns.RefreshAll()
    end
end

local function Get(path)
    return Plateau.DB:Get(path)
end

local function PointXY(frame, point)
    local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
    if not left then return nil end
    local x, y = (left + right) / 2, (top + bottom) / 2
    if point:find("LEFT") then
        x = left
    elseif point:find("RIGHT") then
        x = right
    end
    if point:find("TOP") then
        y = top
    elseif point:find("BOTTOM") then
        y = bottom
    end
    return x, y
end

local function Clamp(value, low, high)
    value = math.floor(value + 0.5)
    if value > high then
        return high
    elseif value < low then
        return low
    end
    return value
end

local freePlacement = false
local SPACE = 2
local ATTACH_EDGES = {
    { key = "TOP", id = "above" },
    { key = "BOTTOM", id = "below" },
    { key = "LEFT", id = "left" },
    { key = "RIGHT", id = "right" },
}

function Drag.SnapEnabled()
    local global = Plateau.DB.saved.global
    return global.dragSnap ~= false
end

function Drag.SetSnapEnabled(enabled)
    Plateau.DB.saved.global.dragSnap = enabled and true or false
end

local function Snapping()
    return Drag.SnapEnabled() and not IsShiftKeyDown()
end

local function Offsets(dx, dy)
    dx, dy = Clamp(dx, -LIMIT, LIMIT), Clamp(dy, -LIMIT, LIMIT)
    if not freePlacement then
        if math.abs(dx) <= SNAP then dx = 0 end
        if math.abs(dy) <= SNAP then dy = 0 end
    end
    return dx, dy
end

local function Nearest(candidates)
    local best, bestCandidate, bestX, bestY
    for _, candidate in ipairs(candidates) do
        local ax, ay = PointXY(candidate.anchor, candidate.relPoint)
        if ax and candidate.mx then
            local dx = candidate.mx - ax - (candidate.ox or 0)
            local dy = candidate.my - ay - (candidate.oy or 0)
            local distance = dx * dx + dy * dy
            if not best or distance < best then
                best, bestCandidate, bestX, bestY = distance, candidate, dx, dy
            end
        end
    end
    return bestCandidate, bestX, bestY
end

local function Dot(index)
    local dot = dots[index]
    if not dot then
        dot = dotParent:CreateTexture(nil, "OVERLAY")
        dots[index] = dot
    end
    return dot
end

local function ShowDots(candidates, nearest, ratio)
    local index = 0
    for _, candidate in ipairs(candidates) do
        index = index + 1
        local dot = Dot(index)
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", candidate.anchor, candidate.relPoint,
            (candidate.dotOx or candidate.ox or 0) * ratio + (candidate.dotX or 0), (candidate.oy or 0) * ratio + (candidate.dotY or 0))
        local isNearest = nearest and candidate.id == nearest.id
        local color = isNearest and Style.StateColor() or C.muted
        dot:SetDrawLayer("OVERLAY", isNearest and 7 or 0)
        dot:SetColorTexture(color[1], color[2], color[3], isNearest and 1 or 0.7)
        dot:SetSize(isNearest and DOT + 3 or DOT, isNearest and DOT + 3 or DOT)
        dot:Show()
    end
    for i = index + 1, #dots do
        dots[i]:Hide()
    end
end

local function HideDots()
    for i = 1, #dots do
        dots[i]:Hide()
    end
end

local function Cursor(frame)
    local x, y = GetCursorPosition()
    local scale = frame:GetEffectiveScale()
    return x / scale, y / scale
end

local Start, Stop

local function KeepInside(spec, mover, x, y)
    local left, right, top, bottom = dotParent:GetLeft(), dotParent:GetRight(), dotParent:GetTop(), dotParent:GetBottom()
    if not left then return x, y end
    local ratio = dotParent:GetEffectiveScale() / spec.spot:GetEffectiveScale()
    left, right, top, bottom = left * ratio, right * ratio, top * ratio, bottom * ratio
    local halfW, halfH = mover:GetWidth() / 2, mover:GetHeight() / 2
    local lowX, highX = left + halfW, right - halfW
    local lowY, highY = bottom + halfH, top - halfH
    if lowX > highX then lowX, highX = (left + right) / 2, (left + right) / 2 end
    if lowY > highY then lowY, highY = (top + bottom) / 2, (top + bottom) / 2 end
    return math.max(lowX, math.min(highX, x)), math.max(lowY, math.min(highY, y))
end

local targetSource

function Drag.SetTargets(source)
    targetSource = source
end

local EDGES = {
    { id = "above", point = "BOTTOM", relPoint = "TOP", ox = 0, oy = SPACE },
    { id = "below", point = "TOP", relPoint = "BOTTOM", ox = 0, oy = -SPACE },
    { id = "left", point = "RIGHT", relPoint = "LEFT", ox = -SPACE, oy = 0 },
    { id = "right", point = "LEFT", relPoint = "RIGHT", ox = SPACE, oy = 0 },
}

local function FromCenter(point, width, height)
    local x = point:find("LEFT") and -width / 2 or point:find("RIGHT") and width / 2 or 0
    local y = point:find("TOP") and height / 2 or point:find("BOTTOM") and -height / 2 or 0
    return x, y
end

local function Within(region, frame)
    local parent = region
    while parent do
        if parent == frame then
            return true
        end
        parent = parent:GetParent()
    end
    return false
end

local function Box(region)
    local left, right, top, bottom = region:GetLeft(), region:GetRight(), region:GetTop(), region:GetBottom()
    if left and region.GetStringWidth then
        local width = region:GetStringWidth()
        if width and width > 0 and width < right - left then
            local justify = region:GetJustifyH()
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
    return left, right, top, bottom
end

local function BoxPoint(box, point)
    local x, y = (box[1] + box[2]) / 2, (box[3] + box[4]) / 2
    if point:find("LEFT") then
        x = box[1]
    elseif point:find("RIGHT") then
        x = box[2]
    end
    if point:find("TOP") then
        y = box[3]
    elseif point:find("BOTTOM") then
        y = box[4]
    end
    return x, y
end

local function Inside(box, other)
    local area = (box[2] - box[1]) * (box[3] - box[4])
    local otherArea = (other[2] - other[1]) * (other[3] - other[4])
    return area < otherArea and box[1] >= other[1] - 0.5 and box[2] <= other[2] + 0.5
        and box[3] <= other[3] + 0.5 and box[4] >= other[4] - 0.5
end

local function Targets(spec, mover)
    local list = {}
    if not targetSource then return list end
    local exclude = spec.Exclude and spec.Exclude() or {}
    for _, target in ipairs(targetSource(spec.spot)) do
        local skip = Within(target, mover)
        for _, frame in ipairs(exclude) do
            if Within(target, frame) then
                skip = true
            end
        end
        if not skip and target:IsVisible() and target:GetLeft() and target:GetWidth() > 0 and target:GetHeight() > 0 then
            list[#list + 1] = target
        end
    end
    return list
end

local function TargetCandidates(spec, list)
    if not spec.Place then return end
    local mover = spec.Mover()
    local width, height = mover:GetWidth(), mover:GetHeight()
    local lockX = spec.axis == "y"
    local targets, boxes = Targets(spec, mover), {}
    for i, target in ipairs(targets) do
        boxes[i] = { Box(target) }
    end
    for i, target in ipairs(targets) do
        local box = boxes[i]
        local inner = false
        for j, other in ipairs(boxes) do
            if j ~= i and Inside(box, other) then
                inner = true
            end
        end
        for _, edge in ipairs(EDGES) do
            if (not lockX or edge.ox == 0) and (not inner or edge.oy == 0) then
                local tx, ty = PointXY(target, edge.relPoint)
                local mx, my = PointXY(mover, edge.point)
                if tx and mx then
                    local fx, fy = FromCenter(edge.point, width, height)
                    local bx = BoxPoint(box, edge.relPoint)
                    local ox, dotOx = edge.ox + bx - tx, nil
                    if lockX then
                        ox, dotOx = mx - tx, bx - tx
                    end
                    local function Resolve(dx, dy)
                        return spec.Place(tx + ox + dx - fx, ty + edge.oy + dy - fy)
                    end
                    if Resolve(0, 0) then
                        list[#list + 1] = {
                            id = edge.id .. ":" .. tostring(target),
                            point = edge.point,
                            anchor = target,
                            relPoint = edge.relPoint,
                            ox = ox,
                            oy = edge.oy,
                            dotOx = dotOx,
                            mx = mx,
                            my = my,
                            Values = function(dx, dy)
                                dx, dy = Offsets(dx, dy)
                                return Resolve(dx, dy) or {}
                            end,
                        }
                    end
                end
            end
        end
    end
end

local function Dedupe(list)
    local kept, seen = {}, {}
    for _, candidate in ipairs(list) do
        local ax, ay = PointXY(candidate.anchor, candidate.relPoint)
        if ax then
            local x = ax + (candidate.dotOx or candidate.ox or 0)
            local y = ay + (candidate.oy or 0)
            local duplicate = false
            for _, spot in ipairs(seen) do
                if spot[3] == candidate.point and math.abs(spot[1] - x) < 2 and math.abs(spot[2] - y) < 2 then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                seen[#seen + 1] = { x, y, candidate.point }
                kept[#kept + 1] = candidate
            end
        end
    end
    return kept
end

local function AllCandidates(spec)
    local list = spec.Candidates()
    TargetCandidates(spec, list)
    return Dedupe(list)
end

local function OnUpdate()
    if pressed and not active then
        if not IsMouseButtonDown("LeftButton") then
            pressed = nil
            return
        end
        local x, y = GetCursorPosition()
        if math.abs(x - pressed.x) + math.abs(y - pressed.y) >= THRESHOLD * UIParent:GetEffectiveScale() then
            Start(pressed.spec)
        end
        return
    end
    local spec = active
    if not spec then return end
    if not IsMouseButtonDown("LeftButton") then
        Stop(spec)
        return
    end
    local x, y = Cursor(spec.spot)
    if spec.axis == "y" then
        x = spec.startX
    end
    local mover = spec.Mover()
    local moverX, moverY = KeepInside(spec, mover, x - spec.grabX, y - spec.grabY)
    mover:ClearAllPoints()
    mover:SetPoint("CENTER", UIParent, "BOTTOMLEFT", moverX, moverY)
    local candidates = AllCandidates(spec)
    local candidate, dx, dy = Nearest(candidates)
    if candidate and candidate.point and Snapping() and dx * dx + dy * dy <= SNAP * SNAP then
        mover:ClearAllPoints()
        mover:SetPoint(candidate.point, candidate.anchor, candidate.relPoint, candidate.ox or 0, candidate.oy or 0)
    end
    ShowDots(candidates, candidate, spec.spot:GetEffectiveScale() / dotParent:GetEffectiveScale())
end

local driver = CreateFrame("Frame")
driver:Hide()
driver:SetScript("OnUpdate", OnUpdate)

function Start(spec)
    local mover = spec.Mover()
    local left, right, top, bottom = mover:GetLeft(), mover:GetRight(), mover:GetTop(), mover:GetBottom()
    if not left then
        pressed = nil
        return
    end
    if spec.keepSize then
        mover:SetSize(right - left, top - bottom)
    end
    local x, y = Cursor(spec.spot)
    spec.startX = x
    spec.grabX = x - (left + right) / 2
    spec.grabY = y - (top + bottom) / 2
    active = spec
    lastDragged = true
    driver:Show()
end

function Stop(spec)
    if active ~= spec then return end
    active = nil
    pressed = nil
    driver:Hide()
    HideDots()

    local candidate, dx, dy = Nearest(AllCandidates(spec))
    if not candidate then
        Apply({})
        return
    end
    freePlacement = not Snapping()
    local values = candidate.Values(dx, dy)
    freePlacement = false
    Apply(values)
end

function Drag.Cancel()
    pressed = nil
    if not active then
        driver:Hide()
        return
    end
    active = nil
    driver:Hide()
    HideDots()
    Apply({})
end

local function Nudge(dx, dy)
    local spec = selected
    if not spec or not spec.Nudge then return end
    local values = spec.Nudge(dx, dy)
    if not values then return end
    Apply(values)
end

local function OffsetNudge(xPath, yPath)
    return function(dx, dy)
        return {
            [xPath] = Clamp((Get(xPath) or 0) + dx, -LIMIT, LIMIT),
            [yPath] = Clamp((Get(yPath) or 0) + dy, -LIMIT, LIMIT),
        }
    end
end

function Drag.PositionSpec(opts)
    local function Resolve()
        local path = type(opts.path) == "function" and opts.path() or opts.path
        local read = opts.readPath and opts.readPath() or path
        return path, path .. "." .. (opts.positionKey or "position"), path .. "." .. (opts.xKey or "offsetX"), path .. "." .. (opts.yKey or "offsetY"), read
    end
    local function Extra(values)
        if opts.extra then
            for key, value in pairs(opts.extra()) do
                values[key] = value
            end
        end
        return values
    end
    local path, positionPath, xPath, yPath = Resolve()
    local spec = {
        name = path,
        paths = { positionPath, xPath, yPath },
    }
    function spec.Nudge(dx, dy)
        local _, _, nudgeX, nudgeY = Resolve()
        return Extra(OffsetNudge(nudgeX, nudgeY)(dx, dy))
    end
    function spec.Mover()
        return opts.region
    end
    function spec.Place(cx, cy)
        local _, positionPath, xPath, yPath, read = Resolve()
        local positions = opts.text and Plateau.textPositions or Plateau.iconPositions
        local gap = opts.fixedGap or Get(read .. ".gap") or 0
        local anchor = opts.anchor()
        local width, height = opts.region:GetWidth(), opts.region:GetHeight()
        local best, bestKey, bestX, bestY
        for key, position in pairs(positions) do
            local rx, ry = PointXY(anchor, position[2])
            if rx then
                local fx, fy = FromCenter(position[1], width, height)
                local x = cx + fx - rx - position[3] * gap
                local y = cy + fy - ry - position[4] * gap
                local size = x * x + y * y
                if not best or size < best then
                    best, bestKey, bestX, bestY = size, key, x, y
                end
            end
        end
        if not bestKey or math.abs(bestX) > LIMIT + 0.5 or math.abs(bestY) > LIMIT + 0.5 then
            return nil
        end
        return Extra({ [positionPath] = bestKey, [xPath] = Clamp(bestX, -LIMIT, LIMIT), [yPath] = Clamp(bestY, -LIMIT, LIMIT) })
    end
    function spec.Candidates()
        local _, positionPath, xPath, yPath, read = Resolve()
        local positions = opts.text and Plateau.textPositions or Plateau.iconPositions
        local gap = opts.fixedGap or Get(read .. ".gap") or 0
        local space = gap == 0 and SPACE or 0
        local anchor = opts.anchor()
        local list = {}
        for key, position in pairs(opts.noRing and {} or positions) do
            local mx, my = PointXY(opts.region, position[1])
            list[#list + 1] = {
                id = key,
                point = position[1],
                anchor = anchor,
                relPoint = position[2],
                ox = position[3] * (gap + space),
                oy = position[4] * (gap + space),
                mx = mx,
                my = my,
                Values = function(dx, dy)
                    dx, dy = Offsets(dx, dy)
                    return Extra({ [positionPath] = key, [xPath] = dx + position[3] * space, [yPath] = dy + position[4] * space })
                end,
            }
        end
        for _, target in ipairs(opts.attach and opts.attach() or {}) do
            if target:IsVisible() and target:GetLeft() then
                for _, edge in ipairs(ATTACH_EDGES) do
                    local key = edge.key
                    local position = positions[key]
                    local mx, my = PointXY(opts.region, position[1])
                    list[#list + 1] = {
                        id = edge.id .. ":" .. tostring(target),
                        point = position[1],
                        anchor = target,
                        relPoint = position[2],
                        ox = position[3] * SPACE,
                        oy = position[4] * SPACE,
                        mx = mx,
                        my = my,
                        Values = function(dx, dy)
                            dx, dy = Offsets(dx, dy)
                            local tx, ty = PointXY(target, position[2])
                            local px, py = PointXY(anchor, position[2])
                            return Extra({
                                [positionPath] = key,
                                [xPath] = Clamp(tx - px + position[3] * SPACE + dx - position[3] * gap, -LIMIT, LIMIT),
                                [yPath] = Clamp(ty - py + position[4] * SPACE + dy - position[4] * gap, -LIMIT, LIMIT),
                            })
                        end,
                    }
                end
            end
        end
        return list
    end
    return spec
end

local AURA_SPOTS = {
    { side = "TOP", align = "LEFT" },
    { side = "TOP", align = "CENTER" },
    { side = "TOP", align = "RIGHT" },
    { side = "BOTTOM", align = "LEFT" },
    { side = "BOTTOM", align = "CENTER" },
    { side = "BOTTOM", align = "RIGHT" },
    { side = "LEFT" },
    { side = "RIGHT" },
}

function Drag.AuraSpec(plate, key)
    local path = "look.auras." .. key
    local sidePath, alignPath = path .. ".side", path .. ".align"
    local xPath, yPath = path .. ".offsetX", path .. ".offsetY"
    local spec = {
        name = path,
        paths = { sidePath, alignPath, xPath, yPath },
        Nudge = OffsetNudge(xPath, yPath),
    }
    local function Group()
        return plate.fakeAuras[key]
    end
    function spec.Mover()
        return Group()
    end
    local function Bounds()
        local left, right, top, bottom
        for _, icon in ipairs(Group().icons) do
            if icon:IsShown() and icon:GetLeft() then
                left = math.min(left or icon:GetLeft(), icon:GetLeft())
                right = math.max(right or icon:GetRight(), icon:GetRight())
                top = math.max(top or icon:GetTop(), icon:GetTop())
                bottom = math.min(bottom or icon:GetBottom(), icon:GetBottom())
            end
        end
        return left, right, top, bottom
    end
    function spec.Place(cx, cy)
        local group = Group()
        local width, height = group:GetWidth(), group:GetHeight()
        local currentAlign = Get(alignPath)
        local grow = Get(path .. ".grow")
        local best, bestSpot, bestX, bestY
        for _, spot in ipairs(AURA_SPOTS) do
            local _, relative, _, _, _, point = Plateau.AuraPlacement({ side = spot.side, align = spot.align or currentAlign, grow = grow })
            local rx, ry = PointXY(plate, relative)
            if rx then
                local fx, fy = FromCenter(point, width, height)
                local x, y = cx + fx - rx, cy + fy - ry
                local size = x * x + y * y
                if not best or size < best then
                    best, bestSpot, bestX, bestY = size, spot, x, y
                end
            end
        end
        if not bestSpot or math.abs(bestX) > LIMIT + 0.5 or math.abs(bestY) > LIMIT + 0.5 then
            return nil
        end
        local values = { [sidePath] = bestSpot.side, [xPath] = Clamp(bestX, -LIMIT, LIMIT), [yPath] = Clamp(bestY, -LIMIT, LIMIT) }
        if bestSpot.align then
            values[alignPath] = bestSpot.align
        end
        return values
    end
    function spec.Candidates()
        local left, right, top, bottom = Bounds()
        local list = {}
        if not left then return list end
        local currentAlign = Get(alignPath)
        local grow = Get(path .. ".grow")
        for i, spot in ipairs(AURA_SPOTS) do
            local _, relative, _, _, _, point = Plateau.AuraPlacement({ side = spot.side, align = spot.align or currentAlign, grow = grow })
            local mx = point:find("LEFT") and left or point:find("RIGHT") and right or (left + right) / 2
            local my = point:find("TOP") and top or point:find("BOTTOM") and bottom or (top + bottom) / 2
            local sx = spot.side == "LEFT" and -SPACE or spot.side == "RIGHT" and SPACE or 0
            local sy = spot.side == "TOP" and SPACE or spot.side == "BOTTOM" and -SPACE or 0
            list[#list + 1] = {
                id = i,
                point = point,
                anchor = plate,
                relPoint = relative,
                ox = sx,
                oy = sy,
                mx = mx,
                my = my,
                Values = function(dx, dy)
                    dx, dy = Offsets(dx, dy)
                    local values = { [sidePath] = spot.side, [xPath] = dx + sx, [yPath] = dy + sy }
                    if spot.align then
                        values[alignPath] = spot.align
                    end
                    return values
                end,
            }
        end
        return list
    end
    return spec
end

local NAME_NUDGE = DOT - 1
local NAME_SPOTS = {
    { id = "TOP", relPoint = "TOP", measure = "BOTTOM", sign = 1, dotX = 0, dotY = NAME_NUDGE },
    { id = "BOTTOM", relPoint = "BOTTOM", measure = "TOP", sign = -1, dotX = 0, dotY = -NAME_NUDGE },
    { id = "CENTER", relPoint = "CENTER", measure = "CENTER", sign = 1, dotX = -DOT - 2, dotY = 0 },
    { id = "INSIDETOP", relPoint = "TOP", measure = "TOP", sign = -1, dotX = DOT + 2, dotY = -NAME_NUDGE },
}

function Drag.NameSpec(plate)
    local positionPath, gapPath = "look.name.position", "look.name.gap"
    local spec = {
        name = "look.name",
        paths = { positionPath, gapPath },
        axis = "y",
        keepSize = true,
    }
    function spec.Mover()
        return plate.nameClip
    end
    function spec.Place(_, cy)
        local top, bottom = plate:GetTop(), plate:GetBottom()
        if not top then return nil end
        local half = plate.nameClip:GetHeight() / 2
        local gaps = {
            TOP = cy - half - top,
            BOTTOM = bottom - cy - half,
            CENTER = cy - (top + bottom) / 2,
            INSIDETOP = top - cy - half,
        }
        local bestId, bestGap
        for _, spot in ipairs(NAME_SPOTS) do
            local gap = gaps[spot.id]
            if gap >= -10.5 and gap <= 30.5 and (not bestGap or math.abs(gap) < math.abs(bestGap)) then
                bestId, bestGap = spot.id, gap
            end
        end
        if not bestId then return nil end
        return { [positionPath] = bestId, [gapPath] = Clamp(bestGap, -10, 30) }
    end
    function spec.Candidates()
        local list = {}
        for _, spot in ipairs(NAME_SPOTS) do
            local _, my = PointXY(plate.nameClip, spot.measure)
            local ax = PointXY(plate, spot.relPoint)
            list[#list + 1] = {
                id = spot.id,
                point = spot.measure,
                anchor = plate,
                relPoint = spot.relPoint,
                dotX = spot.dotX,
                dotY = spot.dotY,
                mx = ax,
                my = my,
                Values = function(_, dy)
                    return { [positionPath] = spot.id, [gapPath] = Clamp(dy * spot.sign, -10, 30) }
                end,
            }
        end
        return list
    end
    function spec.Nudge(_, dy)
        if dy == 0 then return nil end
        local sign = Get(positionPath) == "BOTTOM" and -1 or 1
        return { [gapPath] = Clamp((Get(gapPath) or 0) + dy * sign, -10, 30) }
    end
    return spec
end

function Drag.CastbarSpec(plate)
    local gapPath = "look.castbar.gap"
    local spec = {
        name = "look.castbar",
        paths = { gapPath },
        axis = "y",
        keepSize = true,
    }
    function spec.Mover()
        return plate.castbar
    end
    function spec.Place(_, cy)
        local bottom = plate:GetBottom()
        if not bottom then return nil end
        local gap = bottom - (cy + plate.castbar:GetHeight() / 2) - (plate.castShift or 0)
        if gap < -0.5 or gap > 30.5 then return nil end
        return { [gapPath] = Clamp(gap, 0, 30) }
    end
    function spec.Candidates()
        local _, my = PointXY(plate.castbar, "TOP")
        local ax = PointXY(plate, "BOTTOM")
        return {
            {
                id = "BELOW",
                point = "TOP",
                anchor = plate,
                relPoint = "BOTTOM",
                mx = ax,
                my = my,
                Values = function(_, dy)
                    return { [gapPath] = Clamp(-dy, 0, 30) }
                end,
            },
        }
    end
    function spec.Nudge(_, dy)
        if dy == 0 then return nil end
        return { [gapPath] = Clamp((Get(gapPath) or 0) - dy, 0, 30) }
    end
    return spec
end

local ENEMY_POWER_SPOTS = {
    { id = "below", position = "below", point = "TOP", relPoint = "BOTTOM" },
    { id = "above", position = "above", point = "BOTTOM", relPoint = "TOP" },
}

function Drag.EnemyPowerSpec(plate)
    local path = "look.enemyPower"
    local positionPath, xPath, yPath = path .. ".position", path .. ".offsetX", path .. ".offsetY"
    local spec = {
        name = path,
        paths = { positionPath, xPath, yPath },
        Nudge = OffsetNudge(xPath, yPath),
    }
    function spec.Mover()
        return plate.enemyPowerBar
    end
    function spec.Exclude()
        return { plate.castbar }
    end
    function spec.Place(cx, cy)
        local half = plate.enemyPowerBar:GetHeight() / 2
        local best, bestSpot, bestX, bestY
        for _, spot in ipairs(ENEMY_POWER_SPOTS) do
            local rx, ry = PointXY(plate.health, spot.relPoint)
            if rx then
                local x = cx - rx
                local y = (spot.point == "TOP" and cy + half or cy - half) - ry
                local size = x * x + y * y
                if not best or size < best then
                    best, bestSpot, bestX, bestY = size, spot, x, y
                end
            end
        end
        if not bestSpot or math.abs(bestX) > LIMIT + 0.5 or math.abs(bestY) > LIMIT + 0.5 then
            return nil
        end
        return { [positionPath] = bestSpot.position, [xPath] = Clamp(bestX, -LIMIT, LIMIT), [yPath] = Clamp(bestY, -LIMIT, LIMIT) }
    end
    function spec.Candidates()
        local list = {}
        for _, spot in ipairs(ENEMY_POWER_SPOTS) do
            local mx, my = PointXY(plate.enemyPowerBar, spot.point)
            list[#list + 1] = {
                id = spot.id,
                point = spot.point,
                anchor = plate.health,
                relPoint = spot.relPoint,
                mx = mx,
                my = my,
                Values = function(dx, dy)
                    dx, dy = Offsets(dx, dy)
                    return { [positionPath] = spot.position, [xPath] = dx, [yPath] = dy }
                end,
            }
        end
        return list
    end
    return spec
end

local ARROWS = { UP = { 0, 1 }, DOWN = { 0, -1 }, LEFT = { -1, 0 }, RIGHT = { 1, 0 } }

function Drag.Select(spec)
    selected = spec
    if spec and spec.spot then
        selectionFrame:ClearAllPoints()
        selectionFrame:SetPoint("TOPLEFT", spec.spot, "TOPLEFT", -2, 2)
        selectionFrame:SetPoint("BOTTOMRIGHT", spec.spot, "BOTTOMRIGHT", 2, -2)
        selectionFrame:Show()
    else
        selectionFrame:Hide()
    end
    if not InCombatLockdown() then
        keys:EnableKeyboard(spec ~= nil)
    end
end

function Drag.GetSelected()
    return selected
end

function Drag.SetDotParent(frame)
    dotParent = CreateFrame("Frame", nil, frame)
    dotParent:SetAllPoints()
    dotParent:SetFrameLevel(frame:GetFrameLevel() + 220)

    selectionFrame = CreateFrame("Frame", nil, frame)
    selectionFrame:SetFrameLevel(frame:GetFrameLevel() + 190)
    Style.Border(selectionFrame, C.accent)
    Style.ThemedBorder(selectionFrame)
    selectionFrame:Hide()

    keys = CreateFrame("Frame", nil, frame)
    keys:EnableKeyboard(false)
    local propagatePending = false
    local function ApplyPropagate()
        if InCombatLockdown() then
            propagatePending = true
            return
        end
        propagatePending = false
        keys:SetPropagateKeyboardInput(true)
    end
    ApplyPropagate()
    keys:SetScript("OnKeyDown", function(self, key)
        if InCombatLockdown() then return end
        local arrow = ARROWS[key]
        if not arrow or not selected then
            self:SetPropagateKeyboardInput(true)
            return
        end
        self:SetPropagateKeyboardInput(false)
        local step = IsShiftKeyDown() and 5 or 1
        Nudge(arrow[1] * step, arrow[2] * step)
    end)
    keys:RegisterEvent("PLAYER_REGEN_DISABLED")
    keys:RegisterEvent("PLAYER_REGEN_ENABLED")
    keys:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_REGEN_ENABLED" then
            if propagatePending then
                ApplyPropagate()
            end
            return
        end
        selected = nil
        selectionFrame:Hide()
    end)
    frame:HookScript("OnHide", function()
        Drag.Select(nil)
    end)
end

function Drag.Register(spot, spec)
    spec.spot = spec.spot or spot
    spot:HookScript("OnHide", function()
        if active == spec or (pressed and pressed.spec == spec) then
            Drag.Cancel()
        end
        if selected == spec then
            Drag.Select(nil)
        end
    end)
end

function Drag.Press(spec, spot)
    lastDragged = false
    spec.spot = spot or spec.spot
    local x, y = GetCursorPosition()
    pressed = { spec = spec, x = x, y = y }
    driver:Show()
end

function Drag.Release()
    if active then
        Stop(active)
    elseif pressed then
        pressed = nil
        driver:Hide()
    end
    local dragged = lastDragged
    lastDragged = false
    return dragged
end

function Drag.IsDragging()
    return active ~= nil
end
