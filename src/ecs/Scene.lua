-- A scene is one screen: a registry (data) plus an ordered list of systems (logic).
-- A system is a table with any of: setup(scene), update(scene, dt), draw(scene), unload(scene).
-- There is no input hook: keys arrive as `keyPressed` event entities (see Game.keypressed).

local Registry = require("src.ecs.Registry")

local Scene = {}
Scene.__index = Scene

function Scene.new(name)
    return setmetatable({
        name = name,
        registry = Registry.new(),
        systems = {},
        disabledSystems = {}, -- [system] = true, set by the debug overlay
    }, Scene)
end

function Scene:addSystem(system)
    table.insert(self.systems, system)
end

-- Calls `hook` on every system that has it; setup and unload ignore the disabled set.
local function run(scene, hook, honorDisabled, ...)
    for _, system in ipairs(scene.systems) do
        local fn = system[hook]
        if fn and not (honorDisabled and scene.disabledSystems[system]) then
            fn(scene, ...)
        end
    end
end

function Scene:setup()
    run(self, "setup", false)
end

function Scene:unload()
    run(self, "unload", false)
end

function Scene:update(dt)
    run(self, "update", true, dt)
end

function Scene:draw()
    run(self, "draw", true)
end

return Scene
