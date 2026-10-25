-- Draws the shuttle as a triangle rotated in quarter turns, with a small flame while the engine burns.

local palette = require("src.data.palette")

local ShipRenderSystem = { name = "shipRender" }

function ShipRenderSystem.draw(scene)
    for _, pos, ship in scene.registry:each("position", "ship") do
        love.graphics.push()
        love.graphics.translate(pos.x, pos.y)
        love.graphics.rotate(ship.turns * math.pi / 2)
        if ship.thrusting then
            love.graphics.setColor(palette.grey)
            love.graphics.polygon("fill", -4, 10, 4, 10, 0, 18)
        end
        love.graphics.setColor(palette.white)
        love.graphics.polygon("fill", 0, -12, 9, 10, -9, 10)
        love.graphics.pop()
    end
    love.graphics.setColor(1, 1, 1)
end

return ShipRenderSystem
