-- Draws the three skills as bars.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local rules = require("src.data.progression_rules")
local Panel = require("src.graphics.Panel")

local StatsRenderSystem = { name = "statsRender" }

local titleFont, labelFont, valueFont

function StatsRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(12, "mono")
    labelFont = love.graphics.newFont(12, "mono")
    valueFont = love.graphics.newFont(16, "mono")
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
        love.graphics.print(kinds[kind].label, x + 16, ry)

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
