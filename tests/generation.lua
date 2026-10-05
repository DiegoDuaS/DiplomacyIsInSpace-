-- Proves the card generation rule without opening LÖVE:  lua tests/generation.lua
package.path = "./?.lua;" .. package.path

local CardGenerator = require("src.generation.CardGenerator")
local kinds = require("src.data.card_kinds")
local rules = require("src.data.card_rules")

-- Tiny deterministic RNG (Park-Miller): random() -> [0,1), random(n), random(lo, hi)
local function seededRandom(seed)
    return function(low, high)
        seed = (seed * 48271) % 2147483647
        local unit = seed / 2147483647
        if low == nil then return unit end
        if high == nil then return math.floor(unit * low) + 1 end
        return low + math.floor(unit * (high - low + 1))
    end
end

-- 1. Power stays inside its band: [50% of the skill, 100% of the skill], min 1.
local skills = { tact = 20, logic = 5, resolve = 10 }
local random = seededRandom(3096)
local counts = { tact = 0, logic = 0, resolve = 0 }
local samples = 10000

for _ = 1, samples do
    local card = CardGenerator.card(skills, random)
    local skill = skills[card.kind]
    assert(card.power >= math.max(1, math.ceil(skill * rules.powerMin)),
        card.kind .. " power fell under its floor")
    assert(card.power <= skill, card.kind .. " power broke its ceiling")
    assert(type(card.name) == "string" and card.name ~= "", "card needs a name")
    counts[card.kind] = counts[card.kind] + 1
end

-- 2. Kinds follow the skills: 20/5/10 -> about 57% / 14% / 29%.
local total = skills.tact + skills.logic + skills.resolve
for _, kind in ipairs(kinds.order) do
    local expected = skills[kind] / total
    local actual = counts[kind] / samples
    assert(math.abs(actual - expected) < 0.03,
        ("%s share %.3f is far from %.3f"):format(kind, actual, expected))
end

-- 3. A skill at zero never produces its kind.
local specialist = { tact = 5, logic = 0, resolve = 0 }
for _, card in ipairs(CardGenerator.pack(specialist, 200, seededRandom(1))) do
    assert(card.kind == "tact", "a zero skill produced a card")
end

-- 4. Same seed, same pack (replayable).
local a = CardGenerator.pack(skills, 5, seededRandom(42))
local b = CardGenerator.pack(skills, 5, seededRandom(42))
for i = 1, 5 do
    assert(a[i].kind == b[i].kind and a[i].name == b[i].name and a[i].power == b[i].power,
        "same seed gave a different pack")
end

-- 5. No skills at all is invalid input and must say so.
local ok = pcall(CardGenerator.card, { tact = 0, logic = 0, resolve = 0 }, seededRandom(1))
assert(not ok, "zero skills should be rejected")

print(("generation ok: %d cards, tact %.0f%% logic %.0f%% resolve %.0f%%"):format(
    samples, counts.tact / samples * 100, counts.logic / samples * 100,
    counts.resolve / samples * 100))
