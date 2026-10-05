-- Spends a time slot on an action: the trained skill goes up, the day gets shorter.

local actions = require("src.data.actions")

local ActionSystem = { name = "action" }

function ActionSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")

    for _, pick in registry:each("menuPicked") do
        local action = actions[pick.id]
        if action and runState.actionsLeft > 0 then
            runState.stats[action.stat] = runState.stats[action.stat] + action.gain
            runState.actionsLeft = runState.actionsLeft - 1
            registry:spawn({
                event = true,
                actionPerformed = { id = pick.id, stat = action.stat, gain = action.gain },
            })
        elseif action then
            registry:spawn({ event = true, actionRefused = { id = pick.id } })
        end
    end
end

return ActionSystem
