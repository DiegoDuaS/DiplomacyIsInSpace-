-- The shared state of a run: one plain-data table (no functions, images or scenes)
-- that outlives every scene switch.

local rules = require("src.data.progression_rules")

local RunState = {}

local current

function RunState.new()
    return {
        day = 1,
        actionsLeft = rules.actionsPerDay,
        stats = { tact = 1, logic = 1, resolve = 1 },
        collection = {},
        packSeed = 1,
        history = {}, -- how each finished day ended (see Campaign)
        ending = nil, -- "win" | "meh" | "bad" once the run is over
    }
end

-- The run in progress; the first call creates it.
function RunState.get()
    current = current or RunState.new()
    return current
end

-- Continue a saved run: CONTINUE on the main menu (see SaveGame).
function RunState.set(state)
    current = state
    return current
end

-- Start over: PLAY on the main menu.
function RunState.reset()
    current = RunState.new()
    return current
end

return RunState
