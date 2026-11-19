-- What a delegate announces before each round. `hits` is how many points of each meter one
-- point of the rolled amount moves; the amount is rolled in min..max when the round resolves.
-- Playing the `counter` kind of card keeps only part of it (see negotiation_rules.counterKeeps).

return {
    order = { "press", "stall", "threaten", "calm" },
    press = {
        label = "PRESS", counter = "tact", frame = 1,
        hits = { hostility = 1 }, min = 2, max = 4,
    },
    stall = {
        label = "STALL", counter = "logic", frame = 2,
        hits = { patience = -1 }, min = 1, max = 3,
    },
    threaten = {
        label = "THREATEN", counter = "resolve", frame = 3,
        hits = { hostility = 1, patience = -1 }, min = 3, max = 4,
    },
    calm = {
        label = "CALM", counter = nil, frame = 4,
        hits = { patience = 1 }, min = 1, max = 1,
    },
}
