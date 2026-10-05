-- Gives each main-menu option its meaning: play, credits, quit.

local RunState = require("src.state.RunState")

local MenuActionSystem = { name = "menuAction" }

function MenuActionSystem.update(scene, dt)
    local registry = scene.registry
    local credits = registry:resource("credits")
    local _, menu = registry:first("menu")

    for _, pick in registry:each("menuPicked") do
        if pick.id == "play" then
            RunState.reset() -- PLAY always starts a new run
            registry:spawn({ switchRequest = { to = "prep" } })
        elseif pick.id == "credits" then
            credits.open, menu.active = true, false
        elseif pick.id == "quit" then
            love.event.quit()
        end
    end

    for _ in registry:each("menuBack") do
        credits.open, menu.active = false, true
    end
end

return MenuActionSystem
