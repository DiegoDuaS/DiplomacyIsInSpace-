-- Saves the run whenever it changes in a way worth keeping: a time slot spent or a day ended
-- (and erases the save once the run is over).
-- Put it AFTER the systems that spawn those events. A failed write is only reported, never fatal.

local SaveGame = require("src.state.SaveGame")

local AutosaveSystem = { name = "autosave" }

local CHANGES = { "actionPerformed", "dayEnded" }

function AutosaveSystem.update(scene, dt)
    local registry = scene.registry
    for _, change in ipairs(CHANGES) do
        for _ in registry:each(change) do
            local runState = registry:resource("runState")
            if runState.ending then
                SaveGame.erase(SaveGame.disk()) -- a finished run has nothing to continue
            else
                local ok, why = SaveGame.save(runState, SaveGame.disk())
                if not ok then print("could not save: " .. tostring(why)) end
            end
            return -- one write per frame is enough
        end
    end
end

return AutosaveSystem
