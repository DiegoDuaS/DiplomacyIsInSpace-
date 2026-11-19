-- The panel look every UI shares.

local palette = require("src.data.palette")
local Sprites = require("src.graphics.Sprites")

local Panel = {}

-- Uses assets/sprites/ui_panel.png when it exists (frame 2 = highlighted), flat shapes otherwise.
function Panel.draw(x, y, w, h, highlighted)
    if Sprites.panel("ui_panel", highlighted and 2 or 1, x, y, w, h) then return end

    love.graphics.setColor(palette.space)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(palette.dusk)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
    love.graphics.setColor(1, 1, 1)
end

return Panel
