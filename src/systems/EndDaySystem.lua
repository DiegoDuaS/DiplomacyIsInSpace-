-- The only writer of the day cycle: `dayEnded` advances the day, refills the time slots
-- and returns to the station.

local rules = require("src.data.progression_rules")

local EndDaySystem = { name = "endDay" }

function EndDaySystem.update(scene, dt)
    local registry = scene.registry

    for _ in registry:each("dayEnded") do
        local runState = registry:resource("runState")
        runState.day = runState.day + 1
        runState.actionsLeft = rules.actionsPerDay
        registry:spawn({ switchRequest = { to = "prep" } })
    end
end

return EndDaySystem
