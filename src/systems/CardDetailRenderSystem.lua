-- Draws the inspector for the selected card.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local Panel = require("src.graphics.Panel")
local CardEffect = require("src.cards.CardEffect")

local CardDetailRenderSystem = { name = "cardDetailRender" }

local nameFont, bodyFont, numberFont, smallFont

function CardDetailRenderSystem.setup(scene)
    nameFont = love.graphics.newFont(16, "mono")
    bodyFont = love.graphics.newFont(12, "mono")
    numberFont = love.graphics.newFont(30, "mono")
    smallFont = love.graphics.newFont(11, "mono")
end

function CardDetailRenderSystem.unload(scene)
    nameFont, bodyFont, numberFont, smallFont = nil, nil, nil, nil
end

function CardDetailRenderSystem.draw(scene)
    local registry = scene.registry
    local view = registry:resource("collectionView")
    local card = registry:resource("runState").collection[view.selected]
    local x, y, w, h = 12, 60, 232, 296

    Panel.draw(x, y, w, h)

    if not card then
        love.graphics.setFont(bodyFont)
        love.graphics.setColor(palette.grey)
        love.graphics.printf("No cards yet.\n\nSpend your day at the station and finish it to receive your first pack.",
            x + 18, y + 90, w - 36, "center")
        love.graphics.setColor(1, 1, 1)
        return
    end

    local kind = kinds[card.kind]

    love.graphics.setColor(palette[kind.color])
    love.graphics.rectangle("fill", x + 18, y + 20, 84, 20, 3, 3)
    love.graphics.setColor(palette.ink)
    love.graphics.setFont(smallFont)
    love.graphics.printf(kind.label, x + 18, y + 25, 84, "center")

    love.graphics.setColor(palette.cream)
    love.graphics.setFont(nameFont)
    love.graphics.printf(card.name, x + 18, y + 52, w - 36, "left")

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print("POWER", x + 18, y + 96)
    love.graphics.setFont(numberFont)
    love.graphics.setColor(palette.white)
    love.graphics.print(tostring(card.power), x + 18, y + 110)

    love.graphics.setFont(bodyFont)
    for i, line in ipairs(CardEffect.lines(card)) do
        local good = (line.meter == "patience") == (line.delta > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.print(line.text, x + 100, y + 108 + (i - 1) * 18)
    end

    love.graphics.setColor(palette.cream)
    love.graphics.printf(kind.blurb, x + 18, y + 170, w - 36, "left")

    if card.day then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(("Received on day %d"):format(card.day), x + 18, y + h - 30)
    end
    love.graphics.setColor(1, 1, 1)
end

return CardDetailRenderSystem
