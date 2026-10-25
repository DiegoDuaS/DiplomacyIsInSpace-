-- Draws the delegate as a flat placeholder: a colored head with eyes and a mouth.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")

local AlienRenderSystem = { name = "alienRender" }

function AlienRenderSystem.draw(scene)
    local alien = aliens[scene.registry:resource("negotiation").alien]
    local cx, cy = Screen.w / 2, 148

    love.graphics.setColor(palette[alien.color])
    love.graphics.circle("fill", cx, cy, 52)
    love.graphics.setColor(palette.white)
    love.graphics.circle("fill", cx - 20, cy - 8, 11)
    love.graphics.circle("fill", cx + 20, cy - 8, 11)
    love.graphics.setColor(palette.ink)
    love.graphics.circle("fill", cx - 20, cy - 8, 5)
    love.graphics.circle("fill", cx + 20, cy - 8, 5)
    love.graphics.rectangle("fill", cx - 18, cy + 22, 36, 5)
    love.graphics.setColor(1, 1, 1)
end

return AlienRenderSystem
