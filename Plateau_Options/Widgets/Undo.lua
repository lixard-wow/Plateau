local _, ns = ...

local LIMIT = 20
local GROUP_SECONDS = 0.6

local Undo = {}
ns.Undo = Undo

local stack = {}
local redo = {}
local listeners = {}
local lastAt = 0
local restoring = false
local labels, titles
local nextLabel

local function Notify()
    for i = 1, #listeners do
        listeners[i](#stack > 0, #redo > 0)
    end
end

local function Watching()
    return (PlateauOptions and PlateauOptions:IsShown()) or (PlateauSetup and PlateauSetup:IsShown())
end

local function BuildLabels()
    labels, titles = {}, {}
    for _, section in ipairs(ns.sections or {}) do
        for _, spec in ipairs(type(section.controls) == "table" and section.controls or {}) do
            for _, path in ipairs({ spec.path or false, spec.colorPath or false }) do
                if path and not titles[path] then
                    titles[path] = section.title
                end
            end
            if spec.label then
                for _, path in ipairs({ spec.path, spec.colorPath }) do
                    if path and not labels[path] then
                        labels[path] = spec.label
                    end
                end
                for _, path in ipairs(spec.paths or {}) do
                    labels[path] = labels[path] or spec.label
                end
            end
        end
    end
end

local function Label(path)
    if not path then return nil end
    if not labels then
        BuildLabels()
    end
    return labels[path]
end

local function T(text)
    return Plateau.T(text)
end

local DESCRIBE = {
    Set = function(path) return T(Label(path) or "A setting") end,
    SetMany = function(values)
        if nextLabel then return nextLabel end
        if not labels then
            BuildLabels()
        end
        local labelSet, titleSet, moving = {}, {}, true
        local labelCount, titleCount = 0, 0
        for path in pairs(values or {}) do
            local label, title = labels[path], titles[path]
            if label and not labelSet[label] then
                labelSet[label] = true
                labelCount = labelCount + 1
            end
            if title and not titleSet[title] then
                titleSet[title] = true
                titleCount = titleCount + 1
            end
            if not path:match("%.(%w+)$"):find("^offset") and not path:find("%.position$") and not path:find("%.anchor$") and not path:find("%.side$") and not path:find("%.align$") and not path:find("%.gap$") then
                moving = false
            end
        end
        if labelCount == 1 then
            return T((next(labelSet)))
        end
        if titleCount == 1 then
            return (moving and T("Moved %s") or T("Changed %s")):format(T((next(titleSet))))
        end
        return T("Several settings")
    end,
    Reset = function(path) return path and T("Reset %s"):format(T(Label(path) or "a setting")) or T("Reset everything") end,
    ResetEverywhere = function(paths) return T("Reset %s"):format(T((type(paths) == "table" and Label(paths[1])) or "a setting")) end,
    SetSpecSpells = function() return T("Spell list") end,
    CVarSet = function(name) return T(Label("cvar." .. tostring(name))) or tostring(name) end,
    CVarRelease = function(name) return T("Reset %s"):format(T(Label("cvar." .. tostring(name))) or tostring(name)) end,
}

local function Capture(label)
    return { profile = Plateau.DB:Snapshot(), cvars = Plateau.CVars:ManagedCopy(), label = label }
end

local function Apply(entry)
    restoring = true
    local ok = Plateau.DB:Restore(entry.profile)
    if ok then
        Plateau.CVars:RestoreManaged(entry.cvars)
    end
    restoring = false
    lastAt = 0
    return ok
end

function Undo.Next(label)
    nextLabel = label
end

function Undo.Remember(kind, ...)
    if restoring or not Watching() then
        nextLabel = nil
        return
    end
    local now = GetTime()
    local pending = nextLabel
    nextLabel = nil
    local recent = now - lastAt < GROUP_SECONDS
    lastAt = now
    if recent and #stack > 0 then return end
    nextLabel = pending
    local label = DESCRIBE[kind] and DESCRIBE[kind](...) or T("A change")
    nextLabel = nil
    stack[#stack + 1] = Capture(label)
    if #stack > LIMIT then
        table.remove(stack, 1)
    end
    wipe(redo)
    Notify()
end

local function Finish()
    if ns.RefreshAll then
        ns.RefreshAll()
    end
    Notify()
end

function Undo.Undo(steps)
    steps = math.min(steps or 1, #stack)
    if steps < 1 then return end
    local after = Capture()
    local target
    for _ = 1, steps do
        target = table.remove(stack)
        after.label = target.label
        redo[#redo + 1] = after
        after = target
    end
    if not Apply(target) then
        wipe(stack)
        wipe(redo)
    end
    Finish()
end

function Undo.Redo()
    local entry = table.remove(redo)
    if not entry then return end
    local before = Capture(entry.label)
    if Apply(entry) then
        stack[#stack + 1] = before
    else
        wipe(stack)
        wipe(redo)
    end
    Finish()
end

function Undo.History()
    local list = {}
    for i = #stack, 1, -1 do
        list[#list + 1] = stack[i].label
    end
    return list
end

function Undo.NextRedo()
    local entry = redo[#redo]
    return entry and entry.label
end

function Undo.Count()
    return #stack
end

function Undo.OnChanged(callback)
    listeners[#listeners + 1] = callback
end

local function Wrap(target, method, kind)
    local original = target[method]
    if not original then return end
    target[method] = function(self, ...)
        Undo.Remember(kind, ...)
        return original(self, ...)
    end
end

for _, method in ipairs({ "Set", "SetMany", "Reset", "ResetEverywhere", "SetSpecSpells" }) do
    Wrap(Plateau.DB, method, method)
end
Wrap(Plateau.CVars, "Set", "CVarSet")
Wrap(Plateau.CVars, "Release", "CVarRelease")
