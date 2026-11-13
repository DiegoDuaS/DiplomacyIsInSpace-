-- intent -> velocity -> position, in px/sec times dt. Walls are TileCollisionSystem's job.

local Movement = require("src.world.Movement")

local MovementSystem = { name = "movement" }

function MovementSystem.update(scene, dt)
    local registry = scene.registry
    local map = registry:resource("map")

    for _, pos, intent, velocity in registry:each("position", "moveIntent", "velocity") do
        local dirX, dirY = Movement.direction(intent.dx, intent.dy, map.normalize)

        velocity.x, velocity.y = dirX * map.speed, dirY * map.speed
        pos.x, pos.y = pos.x + velocity.x * dt, pos.y + velocity.y * dt
    end
end

return MovementSystem
