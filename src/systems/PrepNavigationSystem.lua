-- Routes the free "collection" menu entry to the collection scene.

local PrepNavigationSystem = { name = "prepNavigation" }

function PrepNavigationSystem.update(scene, dt)
    local registry = scene.registry
    for _, pick in registry:each("menuPicked") do
        if pick.id == "collection" then
            registry:spawn({ switchRequest = { to = "collection" } })
        end
    end
end

return PrepNavigationSystem
