-- Tunable numbers of one negotiation.

return {
    max = 20,       -- both meters run 0..max
    rounds = 8,     -- rounds the delegate must stay at the table for peace
    handSize = 4,
    patienceDrain = 1, -- patience lost every round (a delegation rule can change it)
    counterKeeps = 0.25, -- share of an announced hit that survives the right counter card
    maxCardEffect = 10, -- no card moves a meter by more than this (half the bar), however strong it is
    -- a risky card hits `multiplier` times harder, but may backfire: it then does nothing good
    -- and raises hostility by `backfireHostility` instead
    risky = { multiplier = 2, backfireChance = 0.35, backfireHostility = 8 },
    -- how the mood bends the delegate's choice: weight multipliers per intent
    moodWeights = {
        CALM = { calm = 2 },
        TENSE = { threaten = 2 },
        FURIOUS = { threaten = 3, calm = 0 },
    },
    moods = {
        { upTo = 0.25, label = "CALM",    color = "light" },
        { upTo = 0.50, label = "WARY",    color = "silver" },
        { upTo = 0.75, label = "TENSE",   color = "amber" },
        { upTo = 1.00, label = "FURIOUS", color = "red" },
    },
}
