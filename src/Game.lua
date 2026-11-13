-- The Game owns the scenes. To change scene a system spawns a `switchRequest` event;
-- the Game honors it after the frame's update, never in the middle of one.

local Game = {}

local factories = {} -- scene name -> function(payload) -> Scene
local active = nil

function Game.registerScene(name, factory)
    factories[name] = factory
end

local function enter(name, payload)
    local factory = assert(factories[name], "unknown scene: " .. tostring(name))
    if active then active:unload() end
    active = factory(payload)
    active:setup()
end

function Game.start(name)
    enter(name, nil)
end

-- Events live for exactly one update: anything spawned with `event = true` is removed here.
local function sweepEvents(registry)
    for _, entity in ipairs(registry:query("event")) do
        registry:destroy(entity)
    end
end

function Game.update(dt)
    active:update(dt)
    sweepEvents(active.registry)

    local _, request = active.registry:first("switchRequest")
    if request then
        enter(request.to, request.payload)
    end
end

function Game.draw()
    active:draw()
end

-- Keys enter the world as data, so systems read them during update like any other event.
function Game.keypressed(key)
    if key == "escape" then
        love.event.quit()
    else
        active.registry:spawn({ event = true, keyPressed = { key = key } })
    end
end

function Game.quit()
    if active then active:unload() end
end

-- For tools and tests.
function Game.current()
    return active
end

function Game.sceneNames()
    local names = {}
    for name in pairs(factories) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return Game
