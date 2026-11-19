-- One round of a negotiation, as plain data in and out: the played card (bent by the court's
-- rule) moves the meters, the announced move lands, the round ends and the next move is
-- announced. Pure: the random source is injected.

local rules = require("src.data.negotiation_rules")
local CardEffect = require("src.cards.CardEffect")
local Intent = require("src.negotiation.Intent")
local Modifiers = require("src.negotiation.Modifiers")
local Mood = require("src.negotiation.Mood")

local Round = {}

local function clamp(value)
    return math.max(0, math.min(value, rules.max))
end

-- Adds what a negotiation needs besides its meters: the court's state and the first announced move.
function Round.begin(neg, alien, random)
    neg.random = random
    neg.ruleState = Modifiers.start(alien.rule)
    neg.intent = Intent.roll(random, alien, Mood.of(neg.hostility).label)
    return neg
end

-- Plays `card`. Mutates `neg` and returns a report of what happened.
function Round.play(neg, alien, card)
    local rule, state, random = alien.rule, neg.ruleState, neg.random

    local bonus = Modifiers.powerBonus(rule, state, card)
    local played = { kind = card.kind, name = card.name, power = math.max(0, card.power + bonus), risky = card.risky }
    local effect = CardEffect.of(played)
    local backfired = card.risky and random() < rules.risky.backfireChance or false
    if backfired then effect = { patience = 0, hostility = rules.risky.backfireHostility } end
    neg.patience = clamp(neg.patience + effect.patience)
    neg.hostility = clamp(neg.hostility + effect.hostility)

    local hit = Intent.resolve(neg.intent, card, random)
    neg.patience = clamp(neg.patience + hit.patience)
    neg.hostility = clamp(neg.hostility + hit.hostility)

    -- the round ends: the delegate grows tired (as the court dictates) and touchier
    local drain = Modifiers.drain(rule, state, rules.patienceDrain)
    neg.patience = clamp(neg.patience - drain)
    neg.hostility = clamp(neg.hostility + (neg.temper or alien.temper))
    Modifiers.advance(rule, state, card)
    neg.round = neg.round + 1

    if neg.hostility >= rules.max then
        neg.outcome = "war"
    elseif neg.patience <= 0 then
        neg.outcome = "walkout"
    elseif neg.round > rules.rounds then
        neg.outcome = "peace"
    end

    neg.intent = nil
    if not neg.outcome then
        neg.intent = Intent.roll(random, alien, Mood.of(neg.hostility).label)
    end

    return { played = played, bonus = bonus, effect = effect, hit = hit, drain = drain, backfired = backfired }
end

return Round
