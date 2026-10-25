-- The view follows the ship and stops at the world's edges. Owns the `camera` resource:
-- the world position of the view's top-left corner.

local Screen = require("src.Screen")

local CameraSystem = { name = "camera" }

local function clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

function CameraSystem.update(scene, dt)
    local registry = scene.registry
    local camera = registry:resource("camera")
    local _, tilemap = registry:first("tilemap")
    local worldW = tilemap.grid.width * tilemap.cell
    local worldH = tilemap.grid.height * tilemap.cell

    for _, pos in registry:each("position", "ship") do
        camera.x = clamp(pos.x - Screen.w / 2, 0, worldW - Screen.w)
        camera.y = clamp(pos.y - Screen.h / 2, 0, worldH - Screen.h)
    end
end

return CameraSystem
