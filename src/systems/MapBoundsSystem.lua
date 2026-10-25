-- Keeps every collider inside the map's rectangle.

local MapBoundsSystem = { name = "mapBounds" }

local function clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

function MapBoundsSystem.update(scene, dt)
    local registry = scene.registry
    local _, tilemap = registry:first("tilemap")
    local worldW = tilemap.grid.width * tilemap.cell
    local worldH = tilemap.grid.height * tilemap.cell

    for _, pos, collider in registry:each("position", "collider") do
        pos.x = clamp(pos.x, collider.hw, worldW - collider.hw)
        pos.y = clamp(pos.y, collider.hh, worldH - collider.hh)
    end
end

return MapBoundsSystem
