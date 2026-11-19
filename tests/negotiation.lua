-- Proves the negotiation rules (announced moves, courts, rounds) without LÖVE:  lua tests/negotiation.lua
package.path = "./?.lua;" .. package.path

local aliens = require("src.data.aliens")
local intents = require("src.data.intents")
local rules = require("src.data.negotiation_rules")
local CardGenerator = require("src.generation.CardGenerator")
local Intent = require("src.negotiation.Intent")
local Modifiers = require("src.negotiation.Modifiers")
local Mood = require("src.negotiation.Mood")
local Round = require("src.negotiation.Round")
local Campaign = require("src.state.Campaign")

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

local function fixed(value) -- random() = 0.5, random(lo, hi) = value
    return function(low) if low == nil then return 0.5 end return value end
end

local function newNegotiation(alien, day) -- as the scene starts it: with the cycle's ease
    local start = Campaign.startingMeters(alien, {}, day)
    return { alien = alien.id, patience = start.patience, hostility = start.hostility, temper = start.temper, round = 1 }
end

-- 1. Announced moves follow the delegation's odds, and the mood bends them.
do
    local random, counts, samples = seededRandom(3096), {}, 20000
    for _ = 1, samples do
        local id = Intent.roll(random, aliens.kelari, "WARY").id
        counts[id] = (counts[id] or 0) + 1
    end
    local total = 0
    for _, weight in pairs(aliens.kelari.intents) do total = total + weight end
    for id, weight in pairs(aliens.kelari.intents) do
        local expected, got = weight / total, counts[id] / samples
        assert(math.abs(expected - got) < 0.02, id .. " odds drifted: " .. got)
    end
    for _ = 1, 2000 do
        assert(Intent.roll(random, aliens.vorn, "FURIOUS").id ~= "calm", "a furious delegate must never calm down")
    end
end

-- 2. A hit rolls inside its announced range; the matching kind keeps only part of it.
do
    for _, id in ipairs(intents.order) do
        local def = intents[id]
        local intent = Intent.new(id)
        local random = seededRandom(7)
        for _ = 1, 200 do
            local hit = Intent.resolve(intent, { kind = "none" }, random)
            assert(hit.amount >= def.min and hit.amount <= def.max, id .. " rolled out of range")
            assert(not hit.countered)
        end
        if def.counter then
            local plain = Intent.resolve(intent, { kind = "none" }, fixed(def.max))
            local blunted = Intent.resolve(intent, { kind = def.counter }, fixed(def.max))
            assert(blunted.countered and blunted.amount == math.floor(plain.amount * rules.counterKeeps),
                id .. " is not softened by " .. def.counter)
        end
    end
    local press = Intent.resolve(Intent.new("press"), { kind = "logic" }, fixed(2))
    assert(press.hostility == 2 and press.patience == 0, "press raises hostility only")
    local threaten = Intent.resolve(Intent.new("threaten"), { kind = "tact" }, fixed(2))
    assert(threaten.hostility == 2 and threaten.patience == -2, "threaten hits both meters")
end

-- 3. Each court bends the round in its own way.
do
    local tides, state = aliens.kelari.rule, Modifiers.start(aliens.kelari.rule)
    local drains = {}
    for round = 1, 6 do
        drains[round] = Modifiers.drain(tides, state, rules.patienceDrain)
        Modifiers.advance(tides, state, { kind = "tact" })
    end
    assert(table.concat(drains, ",") == "0,0,2,2,0,0", "the tide must flip every 2 rounds: " .. table.concat(drains, ","))

    local blades = aliens.vorn.rule
    assert(Modifiers.powerBonus(blades, {}, { kind = "resolve" }) == 2)
    assert(Modifiers.powerBonus(blades, {}, { kind = "tact" }) == -1)
    assert(Modifiers.powerBonus(blades, {}, { kind = "logic" }) == 0)

    local assembly = aliens.ixili.rule
    local seen = Modifiers.start(assembly)
    assert(Modifiers.powerBonus(assembly, seen, { kind = "tact" }) == 0, "the first card has nothing to repeat")
    Modifiers.advance(assembly, seen, { kind = "tact" })
    assert(Modifiers.powerBonus(assembly, seen, { kind = "tact" }) == -1, "repeating a kind is a penalty")
    assert(Modifiers.powerBonus(assembly, seen, { kind = "logic" }) == 1, "a new kind is a bonus")

    assert(Modifiers.drain(nil, {}, 1) == 1 and Modifiers.powerBonus(nil, {}, { kind = "tact" }) == 0,
        "no rule means no change")
    for _, alien in ipairs(aliens) do
        local info = Modifiers.describe(alien.rule, Modifiers.start(alien.rule))
        assert(info.headline ~= "" and #info.lines > 0, alien.id .. " has nothing to show the player")
    end
end

-- 4. A round: the meters stay in 0..max, the outcome follows the meters, the next move is announced.
do
    local alien = aliens.vorn
    local neg = Round.begin(newNegotiation(alien), alien, fixed(1))
    assert(neg.intent, "a negotiation starts with an announced move")

    neg.hostility = rules.max - 1
    local report = Round.play(neg, alien, { kind = "logic", name = "x", power = 1 })
    assert(neg.hostility == rules.max and neg.outcome == "war", "hostility at max is war")
    assert(neg.intent == nil and report.hit, "no next move once it is over")

    local weary = Round.begin(newNegotiation(alien), alien, fixed(1))
    weary.patience = 1
    Round.play(weary, alien, { kind = "tact", name = "x", power = 1 })
    assert(weary.outcome == "walkout" and weary.patience == 0, "patience at 0 is a walkout")

    local calm = newNegotiation(aliens.ixili)
    calm.hostility, calm.patience = 0, rules.max
    Round.begin(calm, aliens.ixili, fixed(1))
    for _ = 1, rules.rounds do
        Round.play(calm, aliens.ixili, { kind = "tact", name = "x", power = 4 })
        assert(calm.patience >= 0 and calm.patience <= rules.max and calm.hostility >= 0 and calm.hostility <= rules.max)
    end
    assert(calm.outcome == "peace" or calm.outcome == "war", "surviving every round ends in peace")
end

-- 4b. A risky card hits twice as hard, or backfires into hostility.
do
    local alien = aliens.ixili
    local function fresh()
        local neg = newNegotiation(alien)
        neg.patience, neg.hostility = 10, 10
        return Round.begin(neg, alien, fixed(1))
    end
    local card = { kind = "tact", name = "x", power = 2, risky = true }

    local boldly = Round.play(fresh(), alien, card) -- random() = 0.5: above the backfire chance
    assert(not boldly.backfired and boldly.effect.hostility == -2 * rules.risky.multiplier, "a risky card hits harder")

    -- random() = 0 is below the chance: it backfires
    local neg = fresh()
    neg.random = function(low, high) if low == nil then return 0 end return high or 1 end
    local report = Round.play(neg, alien, card)
    assert(report.backfired and report.effect.hostility == rules.risky.backfireHostility and report.effect.patience == 0,
        "a backfire raises hostility instead")

    local plain = Round.play(fresh(), alien, { kind = "tact", name = "x", power = 2 })
    assert(not plain.backfired and plain.effect.hostility == -2, "a normal card never backfires")
end

-- 4c. However strong the card, one play never moves a meter by more than the cap.
do
    local CardEffect = require("src.cards.CardEffect")
    for _, kind in ipairs({ "tact", "logic", "resolve" }) do
        for _, risky in ipairs({ false, true }) do
            local effect = CardEffect.of({ kind = kind, name = "x", power = 40, risky = risky or nil })
            assert(math.abs(effect.patience) <= rules.maxCardEffect and math.abs(effect.hostility) <= rules.maxCardEffect,
                kind .. " broke the cap")
        end
    end
    assert(CardEffect.of({ kind = "tact", name = "x", power = 3 }).hostility == -3, "small cards are untouched")
end

-- 5. Same seed, same negotiation.
do
    local function run(seed)
        local alien = aliens.kelari
        local random = seededRandom(seed)
        local neg = Round.begin(newNegotiation(alien), alien, random)
        local log = {}
        while not neg.outcome do
            log[#log + 1] = neg.intent.id
            Round.play(neg, alien, { kind = "tact", name = "x", power = 2 })
        end
        return table.concat(log, ",") .. ":" .. neg.outcome
    end
    assert(run(11) == run(11), "a seed must replay the same negotiation")
end

-- 6. Balance report (printed, not asserted): a careless player against an attentive one.
local function copy(neg)
    local c = {}
    for key, value in pairs(neg) do c[key] = value end
    c.intent = neg.intent and { id = neg.intent.id, min = neg.intent.min, max = neg.intent.max }
    c.ruleState = {}
    for key, value in pairs(neg.ruleState) do c.ruleState[key] = value end
    return c
end

local function pickSmart(neg, alien, hand)
    local best, bestScore = 1, -math.huge
    for slot, card in ipairs(hand) do
        local score = 0
        -- the cautious estimate (smallest hit), weighing a risky card's backfire by its chance
        for _, outcome in ipairs({ { 0.5, 1 - rules.risky.backfireChance }, { 0, rules.risky.backfireChance } }) do
            local trial = copy(neg)
            trial.random = function(low) if low == nil then return outcome[1] end return 1 end
            Round.play(trial, alien, card)
            score = score + outcome[2] * (trial.patience * 0.6 - trial.hostility)
        end
        if score > bestScore then best, bestScore = slot, score end
    end
    return best
end

-- The deck a player would have on a given day: a pack each day, from skills trained +2 per action.
local TRAINING = { { 2, 1, 0 }, { 1, 1, 1 }, { 1, 1, 1 } } -- actions per skill (tact, logic, resolve) on days 1..3
for day = 4, 9 do TRAINING[day] = { 1, 1, 1 } end -- three more actions every day, spread evenly

local function deckFor(day, random)
    local stats, deck = { tact = 1, logic = 1, resolve = 1 }, {}
    for d = 1, day do
        local actions = TRAINING[d]
        stats.tact, stats.logic, stats.resolve =
            stats.tact + 2 * actions[1], stats.logic + 2 * actions[2], stats.resolve + 2 * actions[3]
        for _, card in ipairs(CardGenerator.pack(stats, 5, random)) do deck[#deck + 1] = card end
    end
    return deck
end

local function winRate(alien, day, strategy, games)
    local wins, wars, peak = 0, 0, 0
    for game = 1, games do
        local random = seededRandom(1000 + game)
        local deck, hand = deckFor(day, random), {}
        for i = 1, rules.handSize do hand[i] = deck[(i - 1) % #deck + 1] end
        local nextIndex = rules.handSize % #deck + 1

        local neg = Round.begin(newNegotiation(alien, day), alien, random)
        while not neg.outcome do
            local slot = strategy == "smart" and pickSmart(neg, alien, hand) or random(1, #hand)
            Round.play(neg, alien, hand[slot])
            peak = math.max(peak, neg.hostility)
            hand[slot] = deck[nextIndex]
            nextIndex = nextIndex % #deck + 1
        end
        if neg.outcome == "peace" then wins = wins + 1 end
        if neg.outcome == "war" then wars = wars + 1 end
    end
    return wins / games, wars / games, peak
end

print("peace rate over 1000 negotiations each, with the deck of that day (no grudges):")
for day = 1, 9 do
    local alien = aliens.ofDay(day)
    local cPeace, cWar = winRate(alien, day, "random", 1000)
    local aPeace, aWar = winRate(alien, day, "smart", 1000)
    print(("  day %d %-7s careless %3.0f%% peace %3.0f%% war   attentive %3.0f%% peace %3.0f%% war"):format(
        day, alien.name, cPeace * 100, cWar * 100, aPeace * 100, aWar * 100))
end
print("negotiation ok")
