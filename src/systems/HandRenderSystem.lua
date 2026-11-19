-- Draws the hand along the bottom of the screen; the selected card lifts.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local CardRenderer = require("src.cards.CardRenderer")
local intents = require("src.data.intents")
local Fonts = require("src.graphics.Fonts")

local HandRenderSystem = { name = "handRender" }

local GAP = 12
local LIFT = 14

local hintFont

function HandRenderSystem.setup(scene)
    hintFont = Fonts.new(11)
end

function HandRenderSystem.unload(scene)
    hintFont = nil
end

function HandRenderSystem.draw(scene)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    local over = neg.outcome ~= nil
    local counter = neg.intent and intents[neg.intent.id].counter -- the kind that softens the next hit

    for _, pos, hand in registry:each("position", "hand") do
        local count = #hand.cards
        local left = pos.x - (count * CardRenderer.W + (count - 1) * GAP) / 2

        for i, card in ipairs(hand.cards) do
            local x = left + (i - 1) * (CardRenderer.W + GAP)
            local selected = (i == hand.cursor) and not over
            local y = selected and pos.y - LIFT or pos.y

            CardRenderer.draw(card, x, y)

            if counter and card.kind == counter and not over then
                love.graphics.setFont(hintFont)
                love.graphics.setColor(palette.amber)
                love.graphics.rectangle("fill", x + CardRenderer.W / 2 - 31, y - 13, 62, 13, 3, 3)
                love.graphics.setColor(palette.ink)
                love.graphics.printf("COUNTER", x, y - 12, CardRenderer.W, "center")
            end

            if selected then
                love.graphics.setColor(palette.amber)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", x - 3, y - 3,
                    CardRenderer.W + 6, CardRenderer.H + 6, 5, 5)
                love.graphics.setLineWidth(1)
            elseif over then
                love.graphics.setColor(palette.void[1], palette.void[2], palette.void[3], 0.6)
                love.graphics.rectangle("fill", x, y, CardRenderer.W, CardRenderer.H, 4, 4)
            end
        end
    end

    if not over then
        local text = "LEFT/RIGHT choose a card    ENTER play it"
        local width = hintFont:getWidth(text) + 20
        love.graphics.setFont(hintFont)
        love.graphics.setColor(palette.void[1], palette.void[2], palette.void[3], 0.75)
        love.graphics.rectangle("fill", (Screen.w - width) / 2, 384, width, 15, 4, 4)
        love.graphics.setColor(palette.silver)
        love.graphics.printf(text, 0, 386, Screen.w, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

return HandRenderSystem
