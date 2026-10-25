-- Pushes a mover out of solid cells after MovementSystem, sliding along walls.
-- The position before the move is position - velocity * dt.

local Collision = require("src.world.Collision")

local TileCollisionSystem = { name = "tileCollision" }

function TileCollisionSystem.update(scene, dt)
    local registry = scene.registry
    local _, tilemap = registry:first("tilemap")

    for _, pos, velocity, collider in registry:each("position", "velocity", "collider") do
        pos.x, pos.y = Collision.resolve(tilemap.grid, tilemap.cell,
            pos.x - velocity.x * dt, pos.y - velocity.y * dt,
            pos.x, pos.y, collider.hw, collider.hh)
    end
end

return TileCollisionSystem
