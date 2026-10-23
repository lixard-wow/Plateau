local SOURCE = "CHANGELOG.md"
local OUTPUT = "Plateau_Options/Changelog.lua"
local check = arg and arg[1] == "--check"

local function Parse(text)
    local versions = {}
    local version, section
    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        line = line:gsub("\r", "")
        local number = line:match("^## (%S+)")
        local heading = line:match("^### (.+)$")
        local item = line:match("^%- (.+)$")
        if number then
            version = { version = number, sections = {} }
            versions[#versions + 1] = version
            section = nil
        elseif version and heading then
            section = { title = heading, items = {} }
            version.sections[#version.sections + 1] = section
        elseif version and line:match("%S") and not line:match("^#") then
            if not section then
                section = { items = {} }
                version.sections[#version.sections + 1] = section
            end
            section.items[#section.items + 1] = item or line
        end
    end
    return versions
end

local function Render(versions)
    local out = { "local _, ns = ...", "", "ns.changelog = {" }
    for _, version in ipairs(versions) do
        out[#out + 1] = "    {"
        out[#out + 1] = ("        version = %q,"):format(version.version)
        out[#out + 1] = "        sections = {"
        for _, section in ipairs(version.sections) do
            out[#out + 1] = "            {"
            if section.title then
                out[#out + 1] = ("                title = %q,"):format(section.title)
            end
            out[#out + 1] = "                items = {"
            for _, item in ipairs(section.items) do
                out[#out + 1] = ("                    %q,"):format(item)
            end
            out[#out + 1] = "                },"
            out[#out + 1] = "            },"
        end
        out[#out + 1] = "        },"
        out[#out + 1] = "    },"
    end
    out[#out + 1] = "}"
    return table.concat(out, "\n") .. "\n"
end

local source = assert(io.open(SOURCE, "rb")):read("*a")
local rendered = Render(Parse(source))

if check then
    local file = io.open(OUTPUT, "rb")
    local current = file and file:read("*a"):gsub("\r\n", "\n") or ""
    if file then file:close() end
    if current == rendered then
        print("PASS the in-game changelog matches CHANGELOG.md")
    else
        print("FAIL the in-game changelog matches CHANGELOG.md (out of date: run lua tests/make_changelog.lua)")
    end
    return
end

local file = assert(io.open(OUTPUT, "wb"))
file:write(rendered)
file:close()
print("wrote " .. OUTPUT)
