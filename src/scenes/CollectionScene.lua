-- The briefing room: receive a pack (payload `acquire`) or just review the collection.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local CollectionInputSystem = require("src.systems.CollectionInputSystem")
local PackGenerationSystem = require("src.systems.PackGenerationSystem")
local CollectionSelectionSystem = require("src.systems.CollectionSelectionSystem")
local CollectionExitSystem = require("src.systems.CollectionExitSystem")
local EndDaySystem = require("src.systems.EndDaySystem")
local CollectionChromeRenderSystem = require("src.systems.CollectionChromeRenderSystem")
local CollectionGridRenderSystem = require("src.systems.CollectionGridRenderSystem")
local CardDetailRenderSystem = require("src.systems.CardDetailRenderSystem")

return function(payload)
    local scene = Scene.new("collection")
    local runState = RunState.get()
    local acquiring = payload ~= nil and payload.acquire == true

    scene.registry:setResource("runState", runState)

    scene.registry:setResource("collectionView", {
        selected = #runState.collection > 0 and 1 or 0,
        page = 1,
        columns = 3,
        pageSize = 6,
    })
    scene.registry:setResource("pack", { acquiring = acquiring, first = nil, last = nil })

    if acquiring then
        scene.registry:spawn({ event = true, packRequested = true })
    end

    scene:addSystem(CollectionInputSystem)
    scene:addSystem(PackGenerationSystem)
    scene:addSystem(CollectionSelectionSystem)
    scene:addSystem(CollectionExitSystem)
    scene:addSystem(EndDaySystem)
    scene:addSystem(CollectionChromeRenderSystem)
    scene:addSystem(CollectionGridRenderSystem)
    scene:addSystem(CardDetailRenderSystem)

    return scene
end
