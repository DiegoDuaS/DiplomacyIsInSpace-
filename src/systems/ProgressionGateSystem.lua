-- When the last time slot is spent, waits a beat and heads to the briefing.

local rules = require("src.data.progression_rules")

local ProgressionGateSystem = { name = "progressionGate" }

function ProgressionGateSystem.setup(scene)
    scene.registry:setResource("gate", { timer = 0, fired = false })
end

function ProgressionGateSystem.update(scene, dt)
    local registry = scene.registry
    local gate = registry:resource("gate")
    if gate.fired or registry:resource("runState").actionsLeft > 0 then return end

    gate.timer = gate.timer + dt
    if gate.timer >= rules.gateDelay then
        gate.fired = true -- ask once; the Game switches after this frame
        registry:spawn({
            switchRequest = { to = "collection", payload = { acquire = true } },
        })
    end
end

return ProgressionGateSystem
