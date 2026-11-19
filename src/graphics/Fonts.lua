-- The game's fonts: the bitmap font drawn in src/data/font_main.lua, built at runtime as a LÖVE
-- image font. A size asks for a whole-number scale of the 9px-tall glyphs (the same pixels,
-- bigger), so every size keeps the hard pixel look.
--
--   Fonts.new(size) -> a Font ; sizes up to 13 are the base glyphs, 14-22 twice as big, and so on

local font = require("src.data.font_main")

local Fonts = {}

local SPACER = { 1, 0, 1, 1 }  -- the column colour that separates glyphs inside the image
local LINE_HEIGHT = 1.3
local cache = {}               -- scale -> Font (fonts are shared, never released)

function Fonts.scaleFor(size)
    return math.max(1, math.floor(size / font.height + 0.5))
end

local function build(scale)
    local width = 1 -- the first column is a spacer
    for _, g in ipairs(font.glyphs) do width = width + (g.width + 1) * scale + 1 end

    local data = love.image.newImageData(width, font.height * scale)
    data:mapPixel(function() return 0, 0, 0, 0 end)

    local x, order = 0, {}
    local function spacer()
        data:setPixel(x, 0, SPACER[1], SPACER[2], SPACER[3], SPACER[4])
        x = x + 1
    end
    spacer()
    for _, g in ipairs(font.glyphs) do
        for row, line in ipairs(g.rows) do
            for col = 1, g.width do
                if line:sub(col, col) == "#" then
                    for dy = 0, scale - 1 do
                        for dx = 0, scale - 1 do
                            data:setPixel(x + (col - 1) * scale + dx, (row - 1) * scale + dy, 1, 1, 1, 1)
                        end
                    end
                end
            end
        end
        x = x + (g.width + 1) * scale -- the glyph and one empty column after it
        spacer()
        order[#order + 1] = g.ch
    end

    local built = love.graphics.newImageFont(data, table.concat(order))
    built:setLineHeight(LINE_HEIGHT)
    return built
end

function Fonts.new(size)
    local scale = Fonts.scaleFor(size)
    cache[scale] = cache[scale] or build(scale)
    return cache[scale]
end

return Fonts
