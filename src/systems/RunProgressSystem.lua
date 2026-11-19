-- The only writer of the run's progress: the moment a court case is decided it is recorded in the
-- history and the run moves on (next day, or its ending). It happens at once, not when the player
-- presses ENTER, so closing the game on the result screen cannot be used to play the day again.

local Campaign = require("src.state.Campaign")

local RunProgressSystem = { name = "runProgress" }

function RunProgressSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    if not neg.outcome or neg.recorded then return end

    neg.recorded = true
    Campaign.finishDay(registry:resource("runState"), neg.alien, neg.outcome)
    registry:spawn({ event = true, dayEnded = true }) -- AutosaveSystem saves the run (or erases it at its end)
end

return RunProgressSystem
