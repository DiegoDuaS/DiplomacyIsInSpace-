-- Held keys become move intent (polled, since a held key is not an event); ENTER becomes `interactRequested`.

local MapInputSystem = { name = "mapInput" }

local LEFT  = { "left", "a" }
local RIGHT = { "right", "d" }
local UP    = { "up", "w" }
local DOWN  = { "down", "s" }

local function anyDown(keys)
    for _, key in ipairs(keys) do
        if love.keyboard.isDown(key) then return true end
    end
    return false
end

function MapInputSystem.update(scene, dt)
    local registry = scene.registry

    local dx = (anyDown(RIGHT) and 1 or 0) - (anyDown(LEFT) and 1 or 0)
    local dy = (anyDown(DOWN) and 1 or 0) - (anyDown(UP) and 1 or 0)

    for _, intent in registry:each("moveIntent") do
        intent.dx = dx
        intent.dy = dy
    end

    for _, event in registry:each("keyPressed") do
        if event.key == "return" then
            registry:spawn({ event = true, interactRequested = true })
        end
    end
end

return MapInputSystem
