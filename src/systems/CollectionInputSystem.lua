-- Keys become collection requests: move, fold, jump, continue.

local CollectionInputSystem = { name = "collectionInput" }

local STEPS = { up = -1, w = -1, down = 1, s = 1 }
local FOLDS = { left = false, a = false, right = true, d = true } -- value: open?
local JUMPS = { home = "first", ["end"] = "last" }

function CollectionInputSystem.update(scene, dt)
    local registry = scene.registry

    for _, press in registry:each("keyPressed") do
        local key = press.key
        if STEPS[key] then
            registry:spawn({ event = true, collectionMoveRequested = { step = STEPS[key] } })
        elseif FOLDS[key] ~= nil then
            registry:spawn({ event = true, collectionFoldRequested = { open = FOLDS[key] } })
        elseif JUMPS[key] then
            registry:spawn({ event = true, collectionJumpRequested = { edge = JUMPS[key] } })
        elseif key == "return" or key == "backspace" then
            registry:spawn({ event = true, continueRequested = true })
        end
    end
end

return CollectionInputSystem
