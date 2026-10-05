-- Draws one card at a position: its kind, power, name and what it does to the meters.
-- Screens decide which cards go where.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local CardEffect = require("src.cards.CardEffect")

local CardRenderer = {}

CardRenderer.W, CardRenderer.H = 100, 140

local labelFont, numberFont, nameFont, lineFont

local function loadFonts()
    if labelFont then return end
    labelFont = love.graphics.newFont(11, "mono")
    numberFont = love.graphics.newFont(20, "mono")
    nameFont = love.graphics.newFont(12, "mono")
    lineFont = love.graphics.newFont(11, "mono")
end

function CardRenderer.draw(card, x, y)
    loadFonts()
    local w, h = CardRenderer.W, CardRenderer.H

    love.graphics.setColor(palette.space)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(palette.cream)
    love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
    love.graphics.rectangle("fill", x, y + 28, w, 1)

    love.graphics.setFont(labelFont)
    love.graphics.print(kinds[card.kind].label, x + 8, y + 8)
    love.graphics.setFont(numberFont)
    love.graphics.printf(tostring(card.power), x, y + 4, w - 8, "right")

    love.graphics.setFont(nameFont)
    love.graphics.printf(card.name, x + 6, y + 38, w - 12, "center")

    love.graphics.setFont(lineFont)
    for i, line in ipairs(CardEffect.lines(card)) do
        local good = (line.meter == "patience") == (line.delta > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.printf(line.text, x + 4, y + 88 + (i - 1) * 16, w - 8, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

return CardRenderer
