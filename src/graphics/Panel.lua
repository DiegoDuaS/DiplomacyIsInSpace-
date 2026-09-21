-- The panel look every UI shares.

local palette = require("src.data.palette")

local Panel = {}

function Panel.draw(x, y, w, h)
    love.graphics.setColor(palette.space)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(palette.dusk)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
    love.graphics.setColor(1, 1, 1)
end

return Panel
