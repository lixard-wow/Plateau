local OUTPUT = "localization/template.lua"
local check = arg and arg[1] == "--check"

local FIELDS = {
    label = true, tooltip = true, title = true, text = true, intro = true, summary = true, subtitle = true,
    empty = true, tooltipTitle = true, resetLabel = true, hint = true, limited = true, reason = true, desc = true,
}

local CALLS = {
    "L%[%s*$", "%f[%w_]T%(%s*$", "SetText%(%s*$", "SetFormattedText%(%s*$", "AddLine%(%s*$", "Say%(%s*$",
}

local function ListFiles()
    local files = {}
    local pipe = io.popen('git ls-files "Plateau/*.lua" "Plateau_Options/*.lua"')
    for line in pipe:lines() do
        local path = line:gsub("\r", "")
        if not path:find("/Libs/") and not path:find("/Locales/") then
            files[#files + 1] = path
        end
    end
    pipe:close()
    table.sort(files)
    return files
end

local ESCAPES = { n = "\n", t = "\t", r = "\r", a = "\a", b = "\b", f = "\f", v = "\v", ["\\"] = "\\", ['"'] = '"', ["'"] = "'", ["\n"] = "\n" }

local function ReadString(src, i, quote)
    local parts = {}
    local j = i + 1
    while j <= #src do
        local c = src:sub(j, j)
        if c == quote then
            return table.concat(parts), j
        elseif c == "\\" then
            local n = src:sub(j + 1, j + 1)
            if ESCAPES[n] then
                parts[#parts + 1] = ESCAPES[n]
                j = j + 2
            elseif n:match("%d") then
                local digits = src:match("^%d%d?%d?", j + 1)
                parts[#parts + 1] = string.char(tonumber(digits))
                j = j + 1 + #digits
            else
                parts[#parts + 1] = n
                j = j + 2
            end
        else
            parts[#parts + 1] = c
            j = j + 1
        end
    end
    return table.concat(parts), j
end

local function Literals(src)
    local found = {}
    local i = 1
    while i <= #src do
        local c = src:sub(i, i)
        if c == "-" and src:sub(i, i + 1) == "--" then
            local open = src:match("^%-%-%[(=*)%[", i)
            if open then
                local close = "]" .. open .. "]"
                local stop = src:find(close, i, true)
                i = (stop or #src) + #close
            else
                local stop = src:find("\n", i, true)
                i = (stop or #src) + 1
            end
        elseif c == "[" and src:match("^%[=*%[", i) then
            local open = src:match("^%[(=*)%[", i)
            local close = "]" .. open .. "]"
            local stop = src:find(close, i, true)
            i = (stop or #src) + #close
        elseif c == '"' or c == "'" then
            local value, stop = ReadString(src, i, c)
            found[#found + 1] = { value = value, start = i }
            i = stop + 1
        else
            i = i + 1
        end
    end
    return found
end

local function Prose(value)
    if not value:find("%a") or not value:find(" ") then return false end
    if value:find("^%s") or value:find("%s$") then return false end
    if value:find("\\") or value:find("^look%.") or value:find("^global%.") then return false end
    if value:find("^[%u%d_ ]+$") then return false end
    return true
end

local function Wanted(src, literal, options)
    local before = src:sub(math.max(1, literal.start - 60), literal.start - 1)
    for _, pattern in ipairs(CALLS) do
        if before:find(pattern) then return true end
    end
    local field = before:match("([%a_]+)%s*=%s*$")
    if field and FIELDS[field] then return true end
    return options and Prose(literal.value)
end

local function Escape(text)
    return '"' .. text:gsub('[\\"\n\r\t%c]', function(c)
        if c == "\\" then return "\\\\" end
        if c == '"' then return '\\"' end
        if c == "\n" then return "\\n" end
        if c == "\r" then return "\\r" end
        if c == "\t" then return "\\t" end
        return ("\\%03d"):format(c:byte())
    end) .. '"'
end

local function Collect()
    local keys = {}
    for _, path in ipairs(ListFiles()) do
        local handle = assert(io.open(path, "rb"))
        local src = handle:read("*a"):gsub("\r\n", "\n")
        handle:close()
        local options = path:find("^Plateau_Options/") or path == "Plateau/Core/Presets.lua"
        for _, literal in ipairs(Literals(src)) do
            local value = literal.value
            if value ~= "" and value:find("%a") and Wanted(src, literal, options) then
                keys[value] = true
            end
        end
    end
    local list = {}
    for key in pairs(keys) do
        list[#list + 1] = key
    end
    table.sort(list)
    return list
end

local function Render(list)
    local lines = { "local _, ns = ...", "local L = ns.L", "" }
    for _, key in ipairs(list) do
        local quoted = Escape(key)
        lines[#lines + 1] = ("L[%s] = %s"):format(quoted, quoted)
    end
    return table.concat(lines, "\n") .. "\n"
end

local list = Collect()
local text = Render(list)

local existing
local handle = io.open(OUTPUT, "rb")
if handle then
    existing = handle:read("*a"):gsub("\r\n", "\n")
    handle:close()
end

if check then
    if existing == text then
        print(("template up to date: %d strings"):format(#list))
        os.exit(0)
    end
    print(("template out of date: run lua tests/make_locale_template.lua (%d strings now)"):format(#list))
    os.exit(1)
end

local old = {}
if existing then
    for key in existing:gmatch('\nL%[("[^\n]-")%] = ') do
        old[key] = true
    end
end
local added, removed, now = 0, 0, {}
for _, key in ipairs(list) do
    local quoted = Escape(key)
    now[quoted] = true
    if not old[quoted] then added = added + 1 end
end
for quoted in pairs(old) do
    if not now[quoted] then
        removed = removed + 1
        print("removed: " .. quoted)
    end
end
local out = assert(io.open(OUTPUT, "wb"))
out:write(text)
out:close()
print(("wrote %s: %d strings (%d new, %d removed)"):format(OUTPUT, #list, added, removed))
