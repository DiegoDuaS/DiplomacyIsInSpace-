-- Decides where the card screen goes on continue: to the map after a pack, back to the station on review.

local CollectionExitSystem = { name = "collectionExit" }

function CollectionExitSystem.update(scene, dt)
    local registry = scene.registry
    local pack = registry:resource("pack")

    for _ in registry:each("continueRequested") do
        if pack.acquiring then
            registry:spawn({ switchRequest = { to = "map" } })
        else
            registry:spawn({ switchRequest = { to = "prep" } })
        end
    end
end

return CollectionExitSystem
