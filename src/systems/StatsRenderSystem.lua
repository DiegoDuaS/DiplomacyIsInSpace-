-- Draws the three skills as bars.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local rules = require("src.data.progression_rules")
local Panel = require("src.graphics.Panel")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

local StatsRenderSystem = { name = "statsRender" }

local titleFont, labelFont, valueFont

function StatsRenderSystem.setup(scene)
    titleFont = Fonts.new(12)
    labelFont = Fonts.new(12)
    valueFont = Fonts.new(16)
end

function StatsRenderSystem.unload(scene)
    titleFont, labelFont, valueFont = nil, nil, nil
end

function StatsRenderSystem.draw(scene)
    local stats = scene.registry:resource("runState").stats
    local x, y, w, h = 12, 92, 250, 200

    Panel.draw(x, y, w, h)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.amber)
    love.graphics.print("YOUR SKILLS", x + 16, y + 14)

    for i, kind in ipairs(kinds.order) do
        local ry = y + 44 + (i - 1) * 48
        local color = palette[kinds[kind].color]

        love.graphics.setFont(labelFont)
        love.graphics.setColor(palette.cream)
        local textX = x + 16
        if Sprites.draw("ui_icon_skill", i, x + 16, ry - 2, { color = color }) then textX = x + 38 end
        love.graphics.print(kinds[kind].label, textX, ry)

        local barW = 160
        love.graphics.setColor(palette.ink)
        love.graphics.rectangle("fill", x + 16, ry + 18, barW, 10)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", x + 16, ry + 18,
            barW * math.min(stats[kind] / rules.statDisplayMax, 1), 10)

        love.graphics.setFont(valueFont)
        love.graphics.setColor(palette.white)
        love.graphics.printf(tostring(stats[kind]), x + w - 60, ry + 6, 44, "right")
    end
    love.graphics.setColor(1, 1, 1)
end

return StatsRenderSystem
