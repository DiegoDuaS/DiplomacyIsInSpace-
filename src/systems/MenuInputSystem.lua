-- Menu cursor and picks: keys become a `menuPicked` event. An inactive menu only emits `menuBack`.

local MenuInputSystem = { name = "menuInput" }

function MenuInputSystem.update(scene, dt)
    local registry = scene.registry

    for _, event in registry:each("keyPressed") do
        for _, menu in registry:each("menu") do
            local key = event.key
            if not menu.active then
                if key == "return" or key == "space" or key == "backspace" then
                    registry:spawn({ event = true, menuBack = true })
                end
            elseif key == "up" or key == "w" then
                -- -2/+1 instead of -1: Lua arrays are 1-based, % is 0-based
                menu.cursor = (menu.cursor - 2) % #menu.options + 1
            elseif key == "down" or key == "s" then
                menu.cursor = menu.cursor % #menu.options + 1
            elseif key == "return" or key == "space" then
                registry:spawn({
                    event = true,
                    menuPicked = { id = menu.options[menu.cursor].id },
                })
            elseif key == "backspace" then
                registry:spawn({ event = true, menuBack = true })
            end
        end
    end
end

return MenuInputSystem
