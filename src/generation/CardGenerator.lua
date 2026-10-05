-- Turns skills into cards: the kind's odds are proportional to its skill and the power
-- rolls between 50% and 100% of it. Pure, with the random source injected.

local kinds = require("src.data.card_kinds")
local names = require("src.data.card_names")
local rules = require("src.data.card_rules")

local CardGenerator = {}

local function defaultRandom(...)
    return love.math.random(...)
end

-- The raffle tickets each kind owns, and how many exist in total.
function CardGenerator.weights(stats)
    local weights, total = {}, 0
    for _, kind in ipairs(kinds.order) do
        local value = stats[kind]
        assert(type(value) == "number" and value >= 0,
            kind .. " skill must be a non-negative number")
        weights[kind] = value ^ rules.weightPower
        total = total + weights[kind]
    end
    return weights, total
end

-- One roll lands on one strip of tickets.
local function weightedKind(weights, total, random)
    local target = random() * total
    local cumulative = 0
    for _, kind in ipairs(kinds.order) do
        cumulative = cumulative + weights[kind]
        if target < cumulative then return kind end
    end
    return kinds.order[#kinds.order] -- defensive: random() == 1
end

local function rollPower(skill, random)
    local low = math.max(1, math.ceil(skill * rules.powerMin))
    local high = math.max(low, math.floor(skill))
    return random(low, high)
end

function CardGenerator.card(stats, random)
    random = random or defaultRandom
    local weights, total = CardGenerator.weights(stats)
    assert(total > 0, "cannot generate a card from zero total skill")

    local kind = weightedKind(weights, total, random)
    local pool = names[kind]
    return {
        kind = kind,
        name = pool[random(1, #pool)],
        power = rollPower(stats[kind], random),
    }
end

function CardGenerator.pack(stats, count, random)
    count = count or rules.packSize
    assert(count >= 0 and count == math.floor(count),
        "pack size must be a non-negative integer")
    local cards = {}
    for i = 1, count do
        cards[i] = CardGenerator.card(stats, random)
    end
    return cards
end

return CardGenerator
