-- Keys become collection requests: move, jump, continue.

local CollectionInputSystem = { name = "collectionInput" }

local DIRECTIONS = {
    left = "left", a = "left",
    right = "right", d = "right",
    up = "up", w = "up",
    down = "down", s = "down",
}

function CollectionInputSystem.update(scene, dt)
    local registry = scene.registry
    for _, event in registry:each("keyPressed") do
        local direction = DIRECTIONS[event.key]
        if direction then
            registry:spawn({
                event = true,
                collectionMoveRequested = { direction = direction },
            })
        elseif event.key == "home" then
            registry:spawn({ event = true, collectionJumpRequested = { edge = "first" } })
        elseif event.key == "end" then
            registry:spawn({ event = true, collectionJumpRequested = { edge = "last" } })
        elseif event.key == "return" or event.key == "backspace" then
            registry:spawn({ event = true, continueRequested = true })
        end
    end
end

return CollectionInputSystem
