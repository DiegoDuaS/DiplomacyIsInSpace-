-- The kinds of negotiation card. `effect` is what one point of power does to each meter.

return {
    order = { "tact", "logic", "resolve" },
    tact = {
        label = "TACT", color = "light",
        blurb = "Calms an offended delegate.",
        effect = { patience = 0, hostility = -1 },
    },
    logic = {
        label = "LOGIC", color = "silver",
        blurb = "Wins you more time at the table.",
        effect = { patience = 1, hostility = 0 },
    },
    resolve = {
        label = "RESOLVE", color = "grey",
        blurb = "A firm stance: calms hard, but burns patience.",
        effect = { patience = -1, hostility = -2 },
    },
}
