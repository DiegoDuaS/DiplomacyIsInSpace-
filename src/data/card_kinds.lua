-- The kinds of negotiation card. `effect` is what one point of power does to each meter.

return {
    order = { "tact", "logic", "resolve" },
    tact = {
        label = "TACT", color = "light",
        effect = { patience = 0, hostility = -1 },
    },
    logic = {
        label = "LOGIC", color = "silver",
        effect = { patience = 1, hostility = 0 },
    },
    resolve = {
        label = "RESOLVE", color = "grey",
        effect = { patience = -1, hostility = -2 },
    },
}
