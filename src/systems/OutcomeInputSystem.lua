-- After the negotiation ends. In a run there is no retry: ENTER goes on to the next day, or to the
-- ending if the run is over. Outside a run (testing one court) R retries and M goes back to the menu.

local OutcomeInputSystem = { name = "outcomeInput" }

function OutcomeInputSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    if not neg.outcome then return end

    for _, event in registry:each("keyPressed") do
        if event.key == "return" and neg.run then
            local ending = registry:resource("runState").ending
            registry:spawn({ switchRequest = { to = ending and "ending" or "prep" } })
        elseif event.key == "r" and not neg.run then
            registry:spawn({ switchRequest = { to = "negotiation", payload = neg.payload } })
        elseif event.key == "m" and not neg.run then
            registry:spawn({ switchRequest = { to = "menu" } })
        end
    end
end

return OutcomeInputSystem
