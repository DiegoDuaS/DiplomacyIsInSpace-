-- Bottom panel: the open "file". Shows the selected card, or a summary when a folder is selected.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local Panel = require("src.graphics.Panel")
local CardEffect = require("src.cards.CardEffect")

local CardInspectorRenderSystem = { name = "cardInspectorRender" }

local X, Y, W, H = 12, 268, 616, 104

local nameFont, bodyFont, numberFont, smallFont

function CardInspectorRenderSystem.setup(scene)
    nameFont = love.graphics.newFont(16, "mono")
    bodyFont = love.graphics.newFont(12, "mono")
    numberFont = love.graphics.newFont(30, "mono")
    smallFont = love.graphics.newFont(11, "mono")
end

function CardInspectorRenderSystem.unload(scene)
    nameFont, bodyFont, numberFont, smallFont = nil, nil, nil, nil
end

local function drawTag(kind)
    love.graphics.setColor(palette[kind.color])
    love.graphics.rectangle("fill", X + 18, Y + 14, 84, 20, 3, 3)
    love.graphics.setColor(palette.ink)
    love.graphics.setFont(smallFont)
    love.graphics.printf(kind.label, X + 18, Y + 19, 84, "center")
end

local function drawFolder(row)
    local kind = kinds[row.folder]
    drawTag(kind)
    love.graphics.setFont(nameFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print(kind.label:sub(1, 1) .. kind.label:sub(2):lower() .. " folder", X + 18, Y + 44)
    love.graphics.setFont(bodyFont)
    love.graphics.setColor(palette.silver)
    love.graphics.printf(kind.blurb, X + 330, Y + 16, W - 350, "left")
    love.graphics.setColor(palette.grey)
    love.graphics.print(("%d card%s inside"):format(row.count, row.count == 1 and "" or "s"),
        X + 18, Y + H - 26)
end

local function drawCard(card)
    local kind = kinds[card.kind]
    drawTag(kind)

    love.graphics.setColor(palette.cream)
    love.graphics.setFont(nameFont)
    love.graphics.print(card.name, X + 18, Y + 44)
    if card.day then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(("Received on day %d"):format(card.day), X + 18, Y + H - 26)
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print("POWER", X + 250, Y + 14)
    love.graphics.setFont(numberFont)
    love.graphics.setColor(palette.white)
    love.graphics.print(tostring(card.power), X + 250, Y + 30)

    love.graphics.setFont(bodyFont)
    for i, line in ipairs(CardEffect.lines(card)) do
        local good = (line.meter == "patience") == (line.delta > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.print(line.text, X + 330, Y + 16 + (i - 1) * 18)
    end
    love.graphics.setColor(palette.silver)
    love.graphics.printf(kind.blurb, X + 330, Y + 58, W - 350, "left")
end

function CardInspectorRenderSystem.draw(scene)
    local registry = scene.registry
    local view = registry:resource("collectionView")
    local row = view.rows and view.rows[view.cursor]

    Panel.draw(X, Y, W, H)
    if row then
        if row.folder then
            drawFolder(row)
        else
            drawCard(registry:resource("runState").collection[row.card])
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return CardInspectorRenderSystem
