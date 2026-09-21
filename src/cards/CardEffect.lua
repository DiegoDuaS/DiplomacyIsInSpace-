-- What a card does to the meters. Pure: no registry, no LÖVE.

local kinds = require("src.data.card_kinds")

local CardEffect = {}

function CardEffect.of(card)
    local kind = assert(kinds[card.kind], "unknown card kind: " .. tostring(card.kind))
    return {
        patience = kind.effect.patience * card.power,
        hostility = kind.effect.hostility * card.power,
    }
end

-- The non-zero effects as short lines for a card face: "PATIENCE +3".
function CardEffect.lines(card)
    local effect = CardEffect.of(card)
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
