-- ENTER at today's planet enters its court: the negotiation of the day.
-- The other planets are closed until their day comes.

local aliens = require("src.data.aliens")

local CourtEntrySystem = { name = "courtEntry" }

function CourtEntrySystem.update(scene, dt)
    local registry = scene.registry
    local nearby = registry:resource("map").nearby
    local today = aliens.ofDay(registry:resource("runState").day)

    for _ in registry:each("interactRequested") do
        for _, poi in registry:each("poi") do
            if poi.id == nearby and poi.alien == today.id then
                registry:spawn({
                    switchRequest = { to = "negotiation", payload = { run = true, alien = today.id } },
                })
            end
        end
    end
end

return CourtEntrySystem
