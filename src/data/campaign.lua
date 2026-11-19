-- The shape of a whole run: 9 days, three cycles of three (each cycle visits every delegation once).
-- What a bad outcome costs next time you sit with the same delegation, and how the run ends.

return {
    days = 9,
    cycleLength = 3,

    -- applied to the starting meters of the NEXT negotiation with the same delegation
    carry = {
        walkout = { patience = -3 }, -- they left: they come back with less patience
        war = { hostility = 4 },     -- you fought: they come back angrier
        minPatience = 4,             -- a negotiation never starts already lost
        maxHostility = 14,
    },

    -- the first cycle is gentler (the operator has few cards yet): shifts to the starting meters
    -- and to the hostility the delegate gains every round
    ease = {
        [1] = { patience = 3, hostility = -2, temper = -1 },
    },

    -- the three outcomes of one negotiation, as the run records them
    outcomes = { peace = true, walkout = true, war = true },

    endings = {
        win = {
            title = "PEACE FOR THE CONCORD",
            lines = { "The last three delegations all signed.", "The summit closes with every fleet at rest." },
            color = "light",
        },
        meh = {
            title = "AN UNEASY PEACE",
            lines = { "The summit ends, but not everyone signed.", "Somewhere out there a delegate is still angry." },
            color = "amber",
        },
        bad = {
            title = "THE CONCORD BREAKS",
            lines = { "All three delegations went to war in the same cycle.", "There is no summit left to save." },
            color = "red",
        },
    },
}
