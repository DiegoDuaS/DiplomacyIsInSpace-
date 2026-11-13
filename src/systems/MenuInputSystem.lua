-- Menu cursor and picks: keys become a `menuPicked` event. An inactive menu only emits `menuBack`.

local MenuInputSystem = { name = "menuInput" }

local COMMANDS = {
    up = "up", w = "up",
    down = "down", s = "down",
    ["return"] = "pick", space = "pick",
    backspace = "back",
}

local function apply(registry, menu, command)
    local count = #menu.options

    if not menu.active then
        if command == "pick" or command == "back" then
            registry:spawn({ event = true, menuBack = true })
        end
    elseif command == "up" then
        menu.cursor = menu.cursor == 1 and count or menu.cursor - 1
    elseif command == "down" then
        menu.cursor = menu.cursor == count and 1 or menu.cursor + 1
    elseif command == "pick" then
        registry:spawn({ event = true, menuPicked = { id = menu.options[menu.cursor].id } })
    elseif command == "back" then
        registry:spawn({ event = true, menuBack = true })
    end
end

function MenuInputSystem.update(scene, dt)
    local registry = scene.registry

    for _, press in registry:each("keyPressed") do
        local command = COMMANDS[press.key]
        if command then
            for _, menu in registry:each("menu") do
                apply(registry, menu, command)
            end
        end
    end
end

return MenuInputSystem
