-- Held keys become move intent (polled: a held key is state, not an event).
-- ENTER becomes `interactRequested`.

local MapInputSystem = { name = "mapInput" }

local function held(...)
    return love.keyboard.isDown(...)
end

local function axis(negative, positive)
    local value = 0
    if held(unpack(positive)) then value = value + 1 end
    if held(unpack(negative)) then value = value - 1 end
    return value
end

function MapInputSystem.update(scene, dt)
    local registry = scene.registry

    local dx = axis({ "left", "a" }, { "right", "d" })
    local dy = axis({ "up", "w" }, { "down", "s" })
    for _, intent in registry:each("moveIntent") do
        intent.dx, intent.dy = dx, dy
    end

    for _, press in registry:each("keyPressed") do
        if press.key == "return" then
            registry:spawn({ event = true, interactRequested = true })
        end
    end
end

return MapInputSystem
