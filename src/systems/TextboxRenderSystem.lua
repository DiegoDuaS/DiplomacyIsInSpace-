-- Draws every textbox with the visible slice of its text.

local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")

local TextboxRenderSystem = { name = "textboxRender" }

local PAD = 16

local font

function TextboxRenderSystem.setup(scene)
    font = love.graphics.newFont(14, "mono")
end

function TextboxRenderSystem.unload(scene)
    font = nil
end

function TextboxRenderSystem.draw(scene)
    for _, pos, size, textbox in scene.registry:each("position", "size", "textbox") do
        Panel.draw(pos.x, pos.y, size.w, size.h)
        love.graphics.setColor(palette.cream)
        love.graphics.setFont(font)
        love.graphics.printf(textbox.text:sub(1, math.floor(textbox.visibleChars)),
            pos.x + PAD, pos.y + PAD, size.w - 2 * PAD, "left")
    end
    love.graphics.setColor(1, 1, 1)
end

return TextboxRenderSystem
