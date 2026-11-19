-- The end of a run: win, meh or bad ending, with how each of the nine days went.
-- ENTER goes back to the main menu.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local BackgroundRenderSystem = require("src.systems.BackgroundRenderSystem")
local EndingInputSystem = require("src.systems.EndingInputSystem")
local EndingRenderSystem = require("src.systems.EndingRenderSystem")

return function(payload)
    local scene = Scene.new("ending")
    local runState = RunState.get()
    scene.registry:setResource("runState", runState)

    -- the ending frame of bg_endings: 1 win, 2 bad, 3 meh (until that art exists: the starfield)
    local frames = { win = 1, bad = 2, meh = 3 }
    scene.registry:setResource("ending", { kind = runState.ending or "meh", frame = frames[runState.ending] or 3 })

    scene:addSystem(EndingInputSystem)
    scene:addSystem(BackgroundRenderSystem.new(function(s)
        return "bg_endings", s.registry:resource("ending").frame
    end))
    scene:addSystem(EndingRenderSystem)

    return scene
end
