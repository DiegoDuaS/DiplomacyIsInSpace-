-- The delegate announces a move before each round: which one and how big (a range), not the
-- exact amount. The amount is rolled when the round resolves. Pure: the random source is
-- injected as random() -> [0,1) and random(low, high) -> integer, like CardGenerator.

local intents = require("src.data.intents")
local rules = require("src.data.negotiation_rules")

local Intent = {}

local METERS = { "patience", "hostility" }

function Intent.new(id)
    local def = assert(intents[id], "unknown intent: " .. tostring(id))
    return { id = id, min = def.min, max = def.max }
end

-- Picks the next move: the delegation's odds, bent by its current mood.
function Intent.roll(random, alien, moodLabel)
    local bend = rules.moodWeights[moodLabel] or {}
    local weights, total = {}, 0
    for _, id in ipairs(intents.order) do
        local weight = (alien.intents[id] or 0) * (bend[id] or 1)
        weights[id] = weight
        total = total + weight
    end
    if total == 0 then return Intent.new("press") end

    local target, cumulative = random() * total, 0
    for _, id in ipairs(intents.order) do
        cumulative = cumulative + weights[id]
        if target < cumulative then return Intent.new(id) end
    end
    return Intent.new(intents.order[#intents.order]) -- defensive: random() == 1
end

-- What the hit does once the card is known: rolls the amount, shrinks it if countered.
function Intent.resolve(intent, card, random)
    local def = intents[intent.id]
    local amount = random(intent.min, intent.max)
    local countered = def.counter ~= nil and card.kind == def.counter
    if countered then
        amount = math.floor(amount * rules.counterKeeps)
    end

    local result = { id = intent.id, amount = amount, countered = countered, patience = 0, hostility = 0 }
    for _, meter in ipairs(METERS) do
        result[meter] = (def.hits[meter] or 0) * amount
    end
    return result
end

-- The announced effect for the HUD: one entry per meter it touches, as a range.
function Intent.describe(intent)
    local def = intents[intent.id]
    local lines = {}
    for _, meter in ipairs(METERS) do
        local factor = def.hits[meter]
        if factor then
            local low, high = factor * intent.min, factor * intent.max
            local text = low == high and ("%+d"):format(low) or ("%+d to %+d"):format(low, high)
            lines[#lines + 1] = {
                meter = meter,
                text = meter:upper() .. " " .. text,
                good = (factor > 0) == (meter == "patience"),
            }
        end
    end
    return lines
end

return Intent
