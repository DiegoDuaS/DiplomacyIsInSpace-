-- intent -> velocity -> position, in px/sec times dt. Walls are TileCollisionSystem's job.

local Movement = require("src.world.Movement")

local MovementSystem = { name = "movement" }

function MovementSystem.update(scene, dt)
    local registry = scene.registry
    local map = registry:resource("map")

    for _, pos, intent, velocity in
        registry:each("position", "moveIntent", "velocity") do

        local vx, vy = Movement.direction(intent.dx, intent.dy, map.normalize)

        -- speed is authored in px/sec: independent of the frame rate
        velocity.x = vx * map.speed
        velocity.y = vy * map.speed
        pos.x = pos.x + velocity.x * dt
        pos.y = pos.y + velocity.y * dt
    end
end

return MovementSystem
