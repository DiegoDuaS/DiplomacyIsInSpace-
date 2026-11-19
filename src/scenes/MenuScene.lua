-- The main menu.

local Scene = require("src.ecs.Scene")
local SaveGame = require("src.state.SaveGame")

local MenuInputSystem = require("src.systems.MenuInputSystem")
local MenuActionSystem = require("src.systems.MenuActionSystem")
local BackgroundRenderSystem = require("src.systems.BackgroundRenderSystem")
local MenuRenderSystem = require("src.systems.MenuRenderSystem")

return function(payload)
    local scene = Scene.new("menu")

    -- SCENE state: whether the credits panel is showing. Never saved.
    scene.registry:setResource("credits", { open = false })

    -- CONTINUE only exists while there is a valid save, and says how far it got
    local options = {
        { id = "play", label = "PLAY" },
        { id = "credits", label = "CREDITS" },
        { id = "quit", label = "QUIT" },
    }
    local saved = SaveGame.load(SaveGame.disk())
    if saved then
        table.insert(options, 1, { id = "continue", label = ("CONTINUE  DAY %d"):format(saved.day), save = saved })
    end

    -- the menu: one entity, pure data
    scene.registry:spawn({
        position = { x = 0, y = 168 },
        menu = {
            options = options,
            cursor = 1,
            spacing = 34,
            active = true,
        },
    })

    scene:addSystem(MenuInputSystem)
    scene:addSystem(MenuActionSystem)
    scene:addSystem(BackgroundRenderSystem.new(function() return "bg_menu" end))
    scene:addSystem(MenuRenderSystem)

    return scene
end
