-- Gives each main-menu option its meaning: play, credits, quit.

local MenuActionSystem = { name = "menuAction" }

function MenuActionSystem.update(scene, dt)
    local registry = scene.registry
    local credits = registry:resource("credits")
    local _, menu = registry:first("menu")

    for _, pick in registry:each("menuPicked") do
        if pick.id == "play" then
            registry:spawn({ switchRequest = { to = "negotiation" } })
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
