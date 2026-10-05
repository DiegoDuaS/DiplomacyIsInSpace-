-- After the negotiation ends: retry, go on to the next day (in a run) or back to the menu.

local OutcomeInputSystem = { name = "outcomeInput" }

function OutcomeInputSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    if not neg.outcome then return end

    for _, event in registry:each("keyPressed") do
        if event.key == "r" then
            registry:spawn({ switchRequest = { to = "negotiation", payload = neg.payload } })
        elseif event.key == "return" and neg.run then
            registry:spawn({ event = true, dayEnded = true })
        elseif event.key == "m" and not neg.run then
            registry:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

return OutcomeInputSystem
