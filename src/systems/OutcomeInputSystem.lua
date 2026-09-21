-- After the negotiation ends: retry or go back to the menu.

local OutcomeInputSystem = { name = "outcomeInput" }

function OutcomeInputSystem.update(scene, dt)
    local registry = scene.registry
    if not registry:resource("negotiation").outcome then return end

    for _, event in registry:each("keyPressed") do
        if event.key == "r" then
            registry:spawn({ switchRequest = { to = "negotiation" } })
        elseif event.key == "m" then
            registry:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

return OutcomeInputSystem
