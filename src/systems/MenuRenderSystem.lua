-- Draws the title screen: name, the menu with its cursor and the credits panel.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")

local MenuRenderSystem = { name = "menuRender" }

local titleFont, subtitleFont, itemFont, smallFont

function MenuRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(46, "mono")
    subtitleFont = love.graphics.newFont(22, "mono")
    itemFont = love.graphics.newFont(20, "mono")
    smallFont = love.graphics.newFont(12, "mono")
end

function MenuRenderSystem.unload(scene)
    -- drop the references, the GC collects them; never release() fonts
    titleFont, subtitleFont, itemFont, smallFont = nil, nil, nil, nil
end

local function drawTitle()
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf("DIPLOMACY", 0, 34, Screen.w, "center")
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(palette.silver)
    love.graphics.printf("IS IN SPACE", 0, 88, Screen.w, "center")
end

local function drawCredits()
    local w, h = 400, 150
    local x, y = (Screen.w - w) / 2, 190
    Panel.draw(x, y, w, h)
    love.graphics.setFont(itemFont)
    love.graphics.setColor(palette.amber)
    love.graphics.printf("CREDITS", x, y + 16, w, "center")
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf("Design and code: DiegoDuaS\nMade with LOVE 11.5 and a hand-written ECS\nCourse: CC3096 Game Engine Architecture",
        x + 16, y + 52, w - 32, "center")
    love.graphics.setColor(palette.grey)
    love.graphics.printf("ENTER / BACKSPACE  back", x, y + h - 26, w, "center")
end

function MenuRenderSystem.draw(scene)
    local registry = scene.registry

    drawTitle()

    for _, pos, menu in registry:each("position", "menu") do
        if not menu.active then break end -- the credits panel covers the menu
        love.graphics.setFont(itemFont)
        for i, option in ipairs(menu.options) do
            local y = pos.y + (i - 1) * menu.spacing
            local selected = i == menu.cursor
            love.graphics.setColor(selected and palette.amber or palette.cream)
            love.graphics.printf(option.label, 0, y, Screen.w, "center")
            if selected and math.sin(love.timer.getTime() * 7) > -0.3 then
                local half = itemFont:getWidth(option.label) / 2
                love.graphics.rectangle("fill", Screen.w / 2 - half - 26, y + 7, 12, 8)
                love.graphics.rectangle("fill", Screen.w / 2 + half + 14, y + 7, 12, 8)
            end
        end
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.printf("UP/DOWN choose    ENTER confirm    ESC quit", 0, Screen.h - 22, Screen.w, "center")

    if registry:resource("credits").open then drawCredits() end
    love.graphics.setColor(1, 1, 1)
end

return MenuRenderSystem
