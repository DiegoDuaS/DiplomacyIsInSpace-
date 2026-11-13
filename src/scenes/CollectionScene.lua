-- The briefing room: receive a pack (payload `acquire`) or just review the collection.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")

local CollectionInputSystem = require("src.systems.CollectionInputSystem")
local PackGenerationSystem = require("src.systems.PackGenerationSystem")
local CollectionTreeSystem = require("src.systems.CollectionTreeSystem")
local CollectionExitSystem = require("src.systems.CollectionExitSystem")
local EndDaySystem = require("src.systems.EndDaySystem")
local StarfieldRenderSystem = require("src.systems.StarfieldRenderSystem")
local CollectionHeaderRenderSystem = require("src.systems.CollectionHeaderRenderSystem")
local CollectionListRenderSystem = require("src.systems.CollectionListRenderSystem")
local CardInspectorRenderSystem = require("src.systems.CardInspectorRenderSystem")

return function(payload)
    local scene = Scene.new("collection")
    local runState = RunState.get()
    local acquiring = payload ~= nil and payload.acquire == true

    scene.registry:setResource("runState", runState)

    -- the file browser: which folders are open, what is selected, how far it is scrolled
    scene.registry:setResource("collectionView", {
        open = { tact = true, logic = true, resolve = true },
        selection = { folder = "tact" },
        cursor = 1,
        top = 1,
        visible = 10,
    })
    scene.registry:setResource("pack", { acquiring = acquiring, first = nil, last = nil })

    if acquiring then
        scene.registry:spawn({ event = true, packRequested = true })
    end

    scene:addSystem(CollectionInputSystem)
    scene:addSystem(PackGenerationSystem)
    scene:addSystem(CollectionTreeSystem)
    scene:addSystem(CollectionExitSystem)
    scene:addSystem(EndDaySystem)
    scene:addSystem(StarfieldRenderSystem)
    scene:addSystem(CollectionHeaderRenderSystem)
    scene:addSystem(CollectionListRenderSystem)
    scene:addSystem(CardInspectorRenderSystem)

    return scene
end
