-- Writes the id of the nearest place in range (or nil) into `map.nearby`.

local ProximitySystem = { name = "proximity" }

function ProximitySystem.update(scene, dt)
    local registry = scene.registry
    local map = registry:resource("map")

    for _, shipPos in registry:each("position", "ship") do
        local nearest, nearestDist = nil, math.huge
        for _, pos, poi in registry:each("position", "poi") do
            local dist = math.sqrt((pos.x - shipPos.x) ^ 2 + (pos.y - shipPos.y) ^ 2)
            if dist <= poi.range and dist < nearestDist then
                nearest, nearestDist = poi.id, dist
            end
        end
        map.nearby = nearest
    end
end

return ProximitySystem
