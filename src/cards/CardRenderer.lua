-- Draws one card at a position: its kind, power, name and what it does to the meters.
-- Screens decide which cards go where.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local CardEffect = require("src.cards.CardEffect")
local rules = require("src.data.negotiation_rules")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

local CardRenderer = {}

CardRenderer.W, CardRenderer.H = 100, 140

local labelFont, numberFont, smallNumberFont, nameFont, lineFont

local function loadFonts()
    if labelFont then return end
    labelFont = Fonts.new(10)
    numberFont = Fonts.new(20)
    smallNumberFont = Fonts.new(14) -- two digits: they must not reach the kind label
    nameFont = Fonts.new(12)
    lineFont = Fonts.new(11)
end

function CardRenderer.draw(card, x, y)
    loadFonts()
    local w, h = CardRenderer.W, CardRenderer.H

    -- the frame is the kind's frame of card_front (1 tact, 2 logic, 3 resolve); flat until it exists
    local framed = false
    for i, kind in ipairs(kinds.order) do
        if kind == card.kind then framed = Sprites.draw("card_front", i, x, y) end
    end
    if not framed then
        love.graphics.setColor(palette.space)
        love.graphics.rectangle("fill", x, y, w, h)
        love.graphics.setColor(palette.cream)
        love.graphics.rectangle("line", x + 0.5, y + 0.5, w - 1, h - 1)
        love.graphics.rectangle("fill", x, y + 28, w, 1)
    end
    love.graphics.setColor(palette.cream)

    love.graphics.setFont(labelFont)
    local labelX = x + 8
    for i, kind in ipairs(kinds.order) do -- the kind's icon, tinted with its color
        if kind == card.kind and Sprites.draw("ui_icon_skill", i, x + 6, y + 6, { color = palette[kinds[kind].color] }) then
            labelX = x + 25
        end
    end
    love.graphics.setColor(palette.cream)
    love.graphics.print(kinds[card.kind].label, labelX, y + 9)
    local text = tostring(card.power)
    if #text >= 2 then -- a smaller number, lower so it sits in line with the label
        love.graphics.setFont(smallNumberFont)
        love.graphics.printf(text, x, y + 8, w - 5, "right")
    else
        love.graphics.setFont(numberFont)
        love.graphics.printf(text, x, y + 4, w - 8, "right")
    end

    love.graphics.setFont(nameFont)
    love.graphics.printf(card.name, x + 6, y + 38, w - 12, "center")

    love.graphics.setFont(lineFont)
    for i, line in ipairs(CardEffect.lines(card)) do
        local good = (line.meter == "patience") == (line.delta > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.printf(line.text, x + 4, y + 88 + (i - 1) * 16, w - 8, "center")
    end
    if card.risky then -- a red strip at the foot: it hits harder, and may backfire
        love.graphics.setColor(palette.red)
        love.graphics.rectangle("fill", x + 1, y + h - 17, w - 2, 16)
        love.graphics.setColor(palette.white)
        love.graphics.setFont(lineFont)
        love.graphics.printf(("RISKY %d%%"):format(rules.risky.backfireChance * 100), x, y + h - 15, w, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

return CardRenderer
