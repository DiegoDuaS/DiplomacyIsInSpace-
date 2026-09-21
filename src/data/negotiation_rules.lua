-- Tunable numbers of one negotiation.

return {
    max = 20,       -- both meters run 0..max
    rounds = 8,     -- rounds the delegate must stay at the table for peace
    handSize = 4,
    patienceDrain = 1, -- patience lost every round
    moods = {
        { upTo = 0.25, label = "CALM",    color = "light" },
        { upTo = 0.50, label = "WARY",    color = "silver" },
        { upTo = 0.75, label = "TENSE",   color = "amber" },
        { upTo = 1.00, label = "FURIOUS", color = "red" },
    },
}
