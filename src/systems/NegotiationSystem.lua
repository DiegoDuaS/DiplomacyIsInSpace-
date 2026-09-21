-- The rules of one negotiation: a played card moves the meters, the round ends, the outcome is decided.
-- hostility at max -> war, patience at 0 -> walkout, last round survived -> peace.

local aliens = require("src.data.aliens")
local rules = require("src.data.negotiation_rules")
local CardEffect = require("src.cards.CardEffect")

local NegotiationSystem = { name = "negotiation" }

local function clamp(value)
    return math.max(0, math.min(value, rules.max))
end

function NegotiationSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    local alien = aliens[neg.alien]

    for _, request in registry:each("cardPlayRequested") do
        local _, hand = registry:first("hand")
        local card = hand.cards[request.slot]
        local effect = CardEffect.of(card)
        local before = { patience = neg.patience, hostility = neg.hostility }

        neg.patience = clamp(neg.patience + effect.patience)
        neg.hostility = clamp(neg.hostility + effect.hostility)
        local parts = {}
        for _, line in ipairs(CardEffect.lines(card)) do
            parts[#parts + 1] = line.text
        end
        neg.message = ("%s %d: %s"):format(card.kind:upper(), card.power, table.concat(parts, ", "))

        hand.cards[request.slot] = hand.deck[hand.deckIndex]
        hand.deckIndex = hand.deckIndex % #hand.deck + 1

        -- the round ends: the alien grows tired and touchier
        neg.patience = clamp(neg.patience - rules.patienceDrain)
        neg.hostility = clamp(neg.hostility + alien.temper)
        neg.round = neg.round + 1

        if neg.hostility >= rules.max then
            neg.outcome = "war"
        elseif neg.patience <= 0 then
            neg.outcome = "walkout"
        elseif neg.round > rules.rounds then
            neg.outcome = "peace"
        end

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
