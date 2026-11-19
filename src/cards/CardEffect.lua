-- What a card does to the meters. Pure: no registry, no LÖVE.

local kinds = require("src.data.card_kinds")
local rules = require("src.data.negotiation_rules")

local CardEffect = {}

function CardEffect.of(card)
    local kind = assert(kinds[card.kind], "unknown card kind: " .. tostring(card.kind))
    local power = card.power * (card.risky and rules.risky.multiplier or 1)
    local cap = rules.maxCardEffect
    return {
        patience = math.max(-cap, math.min(cap, kind.effect.patience * power)),
        hostility = math.max(-cap, math.min(cap, kind.effect.hostility * power)),
    }
end

-- The non-zero effects as short lines for a card face: "PATIENCE +3".
function CardEffect.lines(card)
    return CardEffect.linesOf(CardEffect.of(card))
end

-- The same lines for an effect that is already worked out (a backfire, for example).
function CardEffect.linesOf(effect)
    local lines = {}
    for _, meter in ipairs({ "patience", "hostility" }) do
        local delta = effect[meter]
        if delta ~= 0 then
            lines[#lines + 1] = { meter = meter, delta = delta,
                text = ("%s %+d"):format(meter:upper(), delta) }
        end
    end
    return lines
end

return CardEffect
