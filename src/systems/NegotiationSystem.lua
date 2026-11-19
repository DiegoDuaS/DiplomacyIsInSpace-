-- Plays the requested card through Round (src/negotiation/Round.lua), which holds the rules:
-- hostility at max -> war, patience at 0 -> walkout, last round survived -> peace.

local aliens = require("src.data.aliens")
local intents = require("src.data.intents")
local CardEffect = require("src.cards.CardEffect")
local Round = require("src.negotiation.Round")

local NegotiationSystem = { name = "negotiation" }

-- "Warm Greeting: HOSTILITY -3  |  Press: HOSTILITY +2 (softened)"
local function describe(card, report)
    local parts = {}
    for _, line in ipairs(CardEffect.linesOf(report.effect)) do
        parts[#parts + 1] = line.text
    end
    local text = card.name .. ": " .. (report.backfired and "BACKFIRED! " or "") .. table.concat(parts, ", ")

    local hit, meters = report.hit, {}
    for _, meter in ipairs({ "patience", "hostility" }) do
        if hit[meter] ~= 0 then meters[#meters + 1] = ("%s %+d"):format(meter:upper(), hit[meter]) end
    end
    if #meters > 0 then
        text = text .. "   |   " .. intents[hit.id].label .. ": " .. table.concat(meters, ", ")
            .. (hit.countered and " (softened)" or "")
    end
    return text
end

function NegotiationSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    local alien = aliens[neg.alien]

    for _, request in registry:each("cardPlayRequested") do
        local _, hand = registry:first("hand")
        local card = hand.cards[request.slot]
        local before = { patience = neg.patience, hostility = neg.hostility }

        local report = Round.play(neg, alien, card)
        neg.message = describe(card, report)
        neg.lastHit = report.hit

        hand.cards[request.slot] = hand.deck[hand.deckIndex]
        hand.deckIndex = hand.deckIndex % #hand.deck + 1

        registry:spawn({
            event = true,
            negotiationChanged = {
                patience = neg.patience - before.patience,
                hostility = neg.hostility - before.hostility,
            },
        })
    end
end

return NegotiationSystem
