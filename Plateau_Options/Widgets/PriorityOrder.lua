local _, ns = ...

local PriorityOrder = {}
ns.PriorityOrder = PriorityOrder

function PriorityOrder.SlotAt(offset, rowHeight, count)
    local slot = math.floor(offset / rowHeight) + 1
    if slot < 1 then
        return 1
    elseif slot > count then
        return count
    end
    return slot
end

function PriorityOrder.Display(count, from, to)
    local display = {}
    for i = 1, count do
        if i ~= from then
            display[#display + 1] = i
        end
    end
    table.insert(display, to, from)
    return display
end

function PriorityOrder.Reorder(list, from, to)
    local reordered = {}
    for position, original in ipairs(PriorityOrder.Display(#list, from, to)) do
        reordered[position] = list[original]
    end
    return reordered
end

function PriorityOrder.Complete(list, keys)
    local seen = {}
    for _, key in ipairs(list) do
        seen[key] = true
    end
    for index, key in ipairs(keys) do
        if not seen[key] then
            seen[key] = true
            local position = 1
            local previous = keys[index - 1]
            if previous then
                for i = 1, #list do
                    if list[i] == previous then
                        position = i + 1
                        break
                    end
                end
            end
            table.insert(list, position, key)
        end
    end
    return list
end
