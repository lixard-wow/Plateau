local _, ns = ...

local Style = ns.Style
local C = Style.colors
local Widgets = ns.Widgets

local WIDTH, HEIGHT = 600, 560
local PAD = 20
local TITLE = 56
local FOOTER = 56
local CONTENT_WIDTH = WIDTH - PAD * 2 - 14
local BULLET = 14
local WHEEL_STEP = 40

local function Parts(version)
    local parts = {}
    for number in tostring(version):gmatch("%d+") do
        parts[#parts + 1] = tonumber(number)
    end
    return parts
end

local function Newer(a, b)
    local left, right = Parts(a), Parts(b)
    for i = 1, math.max(#left, #right) do
        local x, y = left[i] or 0, right[i] or 0
        if x ~= y then
            return x > y
        end
    end
    return false
end

local function Entries(since)
    local log = ns.changelog or {}
    if since == "latest" then
        return { log[1] }
    end
    local list = {}
    for _, entry in ipairs(log) do
        if since == nil or Newer(entry.version, since) then
            list[#list + 1] = entry
        end
    end
    if #list == 0 and log[1] then
        list[1] = log[1]
    end
    return list
end

local frame = CreateFrame("Frame", "PlateauWhatsNew", UIParent)
frame:SetSize(WIDTH, HEIGHT)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:EnableMouse(true)
frame:Hide()
Style.Panel(frame, C.window, C.border)
tinsert(UISpecialFrames, "PlateauWhatsNew")

local function StopMoving()
    frame:StopMovingOrSizing()
end
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", StopMoving)

local logo = frame:CreateTexture(nil, "ARTWORK")
logo:SetSize(36, 36)
logo:SetPoint("TOPLEFT", PAD, -10)
logo:SetTexture("Interface\\AddOns\\Plateau\\Art\\icon")
Plateau.Brand:OnChange(function(r, g, b)
    logo:SetVertexColor(r, g, b)
end)

local heading = Style.Text(frame, 18, C.title)
Style.SetFont(heading, Style.titleFont, Style.TITLE_SIZE + 4, "")
heading:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, 1)
heading:SetText("What's new in Plateau")

local subheading = Style.Text(frame, 12, C.muted)
subheading:SetPoint("BOTTOMLEFT", logo, "BOTTOMRIGHT", 10, 0)

local closeX = Style.IconButton(frame, "icon_close", Style.ICON_BUTTON, function() frame:Hide() end, "Close")
closeX:SetPoint("TOPRIGHT", -12, -12)

local titleLine = frame:CreateTexture(nil, "ARTWORK")
titleLine:SetPoint("TOPLEFT", 1, -TITLE)
titleLine:SetPoint("TOPRIGHT", -1, -TITLE)
Style.PixelHeight(titleLine)
Style.Paint(titleLine, C.line)

local footerLine = frame:CreateTexture(nil, "ARTWORK")
footerLine:SetPoint("BOTTOMLEFT", 1, FOOTER)
footerLine:SetPoint("BOTTOMRIGHT", -1, FOOTER)
Style.PixelHeight(footerLine)
Style.Paint(footerLine, C.line)

local scroll = CreateFrame("ScrollFrame", nil, frame)
scroll:SetPoint("TOPLEFT", PAD, -(TITLE + 14))
scroll:SetPoint("BOTTOMRIGHT", -(PAD + 14), FOOTER + 10)
scroll:EnableMouseWheel(true)
local content = CreateFrame("Frame", nil, scroll)
content:SetSize(CONTENT_WIDTH, 1)
scroll:SetScrollChild(content)

local track = frame:CreateTexture(nil, "ARTWORK")
track:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 8, 0)
track:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 8, 0)
track:SetWidth(3)
Style.Paint(track, C.border, 0.6)
local thumb = frame:CreateTexture(nil, "OVERLAY")
thumb:SetWidth(3)
Style.Paint(thumb, C.accent, 0.9)

local function UpdateThumb()
    local view, height = scroll:GetHeight(), content:GetHeight()
    local range = math.max(0, height - view)
    local shown = range > 0 and view > 0
    track:SetShown(shown)
    thumb:SetShown(shown)
    if not shown then
        scroll:SetVerticalScroll(0)
        return
    end
    local offset = math.min(scroll:GetVerticalScroll(), range)
    scroll:SetVerticalScroll(offset)
    local size = math.max(24, view * view / height)
    thumb:SetHeight(size)
    thumb:ClearAllPoints()
    thumb:SetPoint("TOP", track, "TOP", 0, -(view - size) * offset / range)
end

scroll:SetScript("OnMouseWheel", function(self, delta)
    local range = math.max(0, content:GetHeight() - self:GetHeight())
    self:SetVerticalScroll(math.max(0, math.min(range, self:GetVerticalScroll() - delta * WHEEL_STEP)))
    UpdateThumb()
end)
scroll:SetScript("OnSizeChanged", UpdateThumb)

local pool = {}
local used = 0

local function Line(kind)
    used = used + 1
    local line = pool[used]
    if not line then
        line = {
            text = Style.Text(content, 12, C.text),
            bullet = Style.Rounded(content, C.accent, "ARTWORK", 0, "circle"),
        }
        line.text:SetWordWrap(true)
        line.text:SetJustifyV("TOP")
        line.bullet:SetSize(5, 5)
        pool[used] = line
    end
    if kind == "version" then
        Style.SetFont(line.text, Style.headingFont, 17, "")
        Style.PaintText(line.text, C.title)
    elseif kind == "section" then
        Style.SetFont(line.text, Style.sectionFont, Style.SECTION_SIZE + 1, "")
        Style.PaintText(line.text, C.accent)
    else
        Style.SetFont(line.text, Style.font, 13, "")
        Style.PaintText(line.text, C.text)
    end
    line.text:Show()
    line.bullet:SetShown(kind == "item")
    return line
end

local function Place(line, y, indent)
    line.text:ClearAllPoints()
    line.text:SetPoint("TOPLEFT", indent, -y)
    line.text:SetWidth(CONTENT_WIDTH - indent)
    if line.bullet:IsShown() then
        line.bullet:ClearAllPoints()
        line.bullet:SetPoint("TOPLEFT", 3, -(y + 6))
    end
    return y + math.ceil(line.text:GetStringHeight())
end

local function Fill(entries)
    used = 0
    local y = 0
    for index, entry in ipairs(entries) do
        if index > 1 then
            y = y + 18
        end
        local line = Line("version")
        line.text:SetFormattedText("Version %s", entry.version)
        y = Place(line, y, 0) + 8
        for _, section in ipairs(entry.sections) do
            if section.title then
                line = Line("section")
                line.text:SetText(section.title)
                y = Place(line, y, 0) + 6
            end
            for _, item in ipairs(section.items) do
                line = Line(section.title and "item" or "plain")
                line.text:SetText(item)
                y = Place(line, y, section.title and BULLET or 0) + 6
            end
            y = y + 4
        end
    end
    for i = used + 1, #pool do
        pool[i].text:Hide()
        pool[i].bullet:Hide()
    end
    content:SetHeight(math.max(1, y))
    scroll:SetVerticalScroll(0)
    UpdateThumb()
end

local stopButton = Widgets.Button(frame, "Don't show again", 150, function()
    Plateau.DB.saved.global.whatsNewOff = true
    frame:Hide()
end)
stopButton:SetPoint("BOTTOMLEFT", PAD, 16)
Style.Tooltip(stopButton, { label = "Don't show again", tooltip = "Stops this window opening after updates. Turn it back on with Show what's new after updates under Plateau settings (the gear), or open it any time with /plt whatsnew." })

local closeButton = Widgets.PrimaryButton(frame, "Close", 110, function() frame:Hide() end)
closeButton:SetPoint("BOTTOMRIGHT", -PAD, 16)

frame:SetScript("OnHide", function()
    Plateau.DB.saved.global.lastSeenVersion = Plateau.version
end)

function frame:Open(since)
    local entries = Entries(since)
    if #entries == 0 then return end
    if since == nil then
        subheading:SetText("Every change so far")
    elseif #entries == 1 then
        subheading:SetFormattedText("Version %s", entries[1].version)
    else
        subheading:SetFormattedText("Versions %s to %s", entries[#entries].version, entries[1].version)
    end
    stopButton:SetShown(since ~= nil)
    self:Show()
    Fill(entries)
end
