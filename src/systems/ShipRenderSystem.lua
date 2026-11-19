-- Draws the shuttle, rotated in quarter turns: sprite frame 1 with the engine off, frames 2 and 3
-- alternating while it burns. Without art it is a flat triangle with a small flame.

local palette = require("src.data.palette")
local Sprites = require("src.graphics.Sprites")

local ShipRenderSystem = { name = "shipRender" }

local BURN_FPS = 8

local function drawFlat(ship)
    if ship.thrusting then
        love.graphics.setColor(palette.grey)
        love.graphics.polygon("fill", -4, 10, 4, 10, 0, 18)
    end
    love.graphics.setColor(palette.white)
    love.graphics.polygon("fill", 0, -12, 9, 10, -9, 10)
end

function ShipRenderSystem.draw(scene)
    for _, pos, ship in scene.registry:each("position", "ship") do
        local frame = ship.thrusting and 2 + math.floor(love.timer.getTime() * BURN_FPS) % 2 or 1
        -- the sprite is 16x16 and points up; (8, 8) is its centre, so it turns around the ship
        if not Sprites.draw("ship", frame, pos.x, pos.y, { r = ship.turns * math.pi / 2, ox = 8, oy = 8 }) then
            love.graphics.push()
            love.graphics.translate(pos.x, pos.y)
            love.graphics.rotate(ship.turns * math.pi / 2)
            drawFlat(ship)
            love.graphics.pop()
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return ShipRenderSystem
