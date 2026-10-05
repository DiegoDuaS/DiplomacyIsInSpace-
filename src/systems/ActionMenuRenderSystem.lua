-- Draws the schedule menu, dimmed once the day is out of time slots.

local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")

local ActionMenuRenderSystem = { name = "actionMenuRender" }

local titleFont, labelFont, hintFont

function ActionMenuRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(12, "mono")
    labelFont = love.graphics.newFont(13, "mono")
    hintFont = love.graphics.newFont(12, "mono")
end

function ActionMenuRenderSystem.unload(scene)
    titleFont, labelFont, hintFont = nil, nil, nil
end

function ActionMenuRenderSystem.draw(scene)
    local registry = scene.registry
    local spent = registry:resource("runState").actionsLeft == 0

    for _, pos, size, menu in registry:each("position", "size", "menu") do
        Panel.draw(pos.x, pos.y, size.w, size.h)
        love.graphics.setFont(titleFont)
        love.graphics.setColor(palette.amber)
        love.graphics.print("TODAY'S SCHEDULE", pos.x + 16, pos.y + 14)

        for i, option in ipairs(menu.options) do
            local ry = pos.y + 38 + (i - 1) * menu.spacing
            local selected = i == menu.cursor
            local dim = spent and option.costsSlot

            if selected then
                love.graphics.setColor(palette.dusk)
                love.graphics.rectangle("fill", pos.x + 10, ry, size.w - 20, menu.spacing - 6, 3, 3)
                if math.sin(love.timer.getTime() * 7) > -0.3 then
                    love.graphics.setColor(palette.amber)
                    love.graphics.rectangle("fill", pos.x + 16, ry + 11, 8, 8)
                end
            end

            love.graphics.setFont(labelFont)
            love.graphics.setColor(dim and palette.slate or palette.cream)
            love.graphics.print(option.label, pos.x + 34, ry + 8)

            love.graphics.setFont(hintFont)
            love.graphics.setColor(dim and palette.slate or palette[option.color])
            love.graphics.printf(option.hint, pos.x, ry + 8, size.w - 22, "right")
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return ActionMenuRenderSystem
