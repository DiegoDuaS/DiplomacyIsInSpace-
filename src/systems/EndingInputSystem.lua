-- The ending screen has one exit: back to the main menu.

local EndingInputSystem = { name = "endingInput" }

function EndingInputSystem.update(scene, dt)
    local registry = scene.registry
    for _, event in registry:each("keyPressed") do
        if event.key == "return" or event.key == "space" or event.key == "escape" then
            registry:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

return EndingInputSystem
