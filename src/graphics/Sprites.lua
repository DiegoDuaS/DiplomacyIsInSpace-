-- Loads sprite sheets (horizontal strips, see src/data/sprites.lua) and draws their frames.
-- A missing PNG is not an error: every draw function returns false, so the caller keeps
-- drawing its flat placeholder until the real art exists.

local defs = require("src.data.sprites")

local Sprites = {}

local DIR = "assets/sprites/"
local sheets = {} -- name -> sheet, or false when the file does not exist

local function load(name)
    local def = assert(defs[name], "unknown sprite: " .. tostring(name))
    local path = DIR .. name .. ".png"
    if not love.filesystem.getInfo(path) then return false end

    local image = love.graphics.newImage(path)
    image:setFilter("nearest", "nearest")
    local width, height = image:getDimensions()
    -- frames = "auto": any number of frames, counted from the width
    local count = def.frames == "auto" and width / def.w or def.frames
    assert(count >= 1 and count == math.floor(count) and width == def.w * count and height == def.h,
        ("%s is %dx%d but must be %s frame(s) of %dx%d"):format(
            path, width, height, def.frames == "auto" and "N" or tostring(count), def.w, def.h))

    local quads = {}
    for i = 1, count do
        quads[i] = love.graphics.newQuad((i - 1) * def.w, 0, def.w, def.h, width, height)
    end
    return { image = image, quads = quads, def = def, count = count, patches = {} }
end

local function sheet(name)
    local found = sheets[name]
    if found == nil then
        found = load(name)
        sheets[name] = found
    end
    return found
end

function Sprites.has(name)
    return sheet(name) ~= false
end

-- Frame number of an animated sheet at `time` seconds (uses the sheet's fps).
function Sprites.frameAt(name, time)
    local def = assert(defs[name], "unknown sprite: " .. tostring(name))
    local s = sheet(name)
    local count = s and s.count or def.frames
    if count == "auto" then return 1 end -- no PNG yet
    return math.floor(time * (def.fps or 1)) % count + 1
end

-- Plays an animation once: the frame at `time` seconds, stopping on the last one.
function Sprites.frameOnce(name, time)
    local def = assert(defs[name], "unknown sprite: " .. tostring(name))
    local s = sheet(name)
    local count = s and s.count or def.frames
    if count == "auto" then return 1 end
    return math.min(math.floor(time * (def.fps or 1)) + 1, count)
end

-- opts (all optional): r rotation, sx/sy scale, ox/oy origin, color tint { r, g, b }.
function Sprites.draw(name, frame, x, y, opts)
    local s = sheet(name)
    if not s then return false end
    opts = opts or {}

    love.graphics.setColor(opts.color or { 1, 1, 1 })
    love.graphics.draw(s.image, s.quads[frame or 1], x, y, opts.r or 0,
        opts.sx or 1, opts.sy or opts.sx or 1, opts.ox or 0, opts.oy or 0)
    love.graphics.setColor(1, 1, 1)
    return true
end

-- The nine quads of a nine-patch frame: corners keep their size, edges and centre stretch.
local function patchQuads(s, frame)
    local def, b = s.def, s.def.border
    local x0 = (frame - 1) * def.w
    local cols = { { 0, b }, { b, def.w - 2 * b }, { def.w - b, b } }
    local rows = { { 0, b }, { b, def.h - 2 * b }, { def.h - b, b } }
    local width, height = s.image:getDimensions()

    local list = {}
    for _, row in ipairs(rows) do
        for _, col in ipairs(cols) do
            list[#list + 1] = {
                quad = love.graphics.newQuad(x0 + col[1], row[1], col[2], row[2], width, height),
                w = col[2], h = row[2],
            }
        end
    end
    return list
end

-- A frame of a sheet stretched to w x h as a nine-patch.
function Sprites.panel(name, frame, x, y, w, h)
    local s = sheet(name)
    if not s then return false end

    local b = s.def.border
    assert(b, name .. " has no border in src/data/sprites.lua")
    s.patches[frame] = s.patches[frame] or patchQuads(s, frame)

    local xs, ys = { x, x + b, x + w - b }, { y, y + b, y + h - b }
    local ws, hs = { b, w - 2 * b, b }, { b, h - 2 * b, b }

    love.graphics.setColor(1, 1, 1)
    for i, piece in ipairs(s.patches[frame]) do
        local col, row = (i - 1) % 3 + 1, math.floor((i - 1) / 3) + 1
        love.graphics.draw(s.image, piece.quad, xs[col], ys[row], 0, ws[col] / piece.w, hs[row] / piece.h)
    end
    return true
end

return Sprites
