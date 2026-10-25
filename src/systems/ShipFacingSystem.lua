-- The ship's heading and whether its engine burns, from the move intent.
-- It keeps its last heading when the player lets go.

local Movement = require("src.world.Movement")

local ShipFacingSystem = { name = "shipFacing" }

-- Movement's sheet rows -> quarter turns clockwise from "pointing up"
local TURNS = {
    [Movement.ROWS.up] = 0,
    [Movement.ROWS.right] = 1,
    [Movement.ROWS.down] = 2,
    [Movement.ROWS.left] = 3,
}

function ShipFacingSystem.update(scene, dt)
    for _, intent, ship in scene.registry:each("moveIntent", "ship") do
        local row = Movement.facing(intent.dx, intent.dy)
        ship.thrusting = row ~= nil
        if row then ship.turns = TURNS[row] end
    end
end

return ShipFacingSystem
