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
    }
end

-- The run in progress; the first call creates it.
function RunState.get()
    current = current or RunState.new()
    return current
end

-- Start over: PLAY on the main menu.
function RunState.reset()
    current = RunState.new()
    return current
end

return RunState
