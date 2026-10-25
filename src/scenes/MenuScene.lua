-- The main menu.

local Scene = require("src.ecs.Scene")

local MenuInputSystem = require("src.systems.MenuInputSystem")
local MenuActionSystem = require("src.systems.MenuActionSystem")
local StarfieldRenderSystem = require("src.systems.StarfieldRenderSystem")
local MenuRenderSystem = require("src.systems.MenuRenderSystem")

return function(payload)
    local scene = Scene.new("menu")

    -- SCENE state: whether the credits panel is showing. Never saved.
    scene.registry:setResource("credits", { open = false })

    -- the menu: one entity, pure data
    scene.registry:spawn({
        position = { x = 0, y = 168 },
        menu = {
            options = {
                { id = "play", label = "PLAY" },
                { id = "credits", label = "CREDITS" },
                { id = "quit", label = "QUIT" },
            },
            cursor = 1,
            spacing = 34,
            active = true,
        },
    })

    scene:addSystem(MenuInputSystem)
    scene:addSystem(MenuActionSystem)
    scene:addSystem(StarfieldRenderSystem)
    scene:addSystem(MenuRenderSystem)

    return scene
end
