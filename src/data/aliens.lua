-- The delegations, one race per summit day: color, home planet, court and starting mood.
-- temper is the hostility they gain every round. `intents` are the odds of each announced
-- move; `rule` is what makes the court different (see src/negotiation/Modifiers.lua).

local aliens = {
    {
        id = "kelari", name = "Kelari", planet = "Thalassa",
        court = "Tribunal of Tides",
        patience = 12, hostility = 6, temper = 2,
        color = "silver", background = "bg_court_tides",
        intents = { press = 2, stall = 3, threaten = 1, calm = 2 },
        rule = { id = "tides", label = "TIDES", period = 2, drain = { high = 0, low = 2 } },
    },
    {
        id = "vorn", name = "Vorn", planet = "Krag",
        court = "Court of Blades",
        patience = 16, hostility = 6, temper = 1,
        color = "grey", background = "bg_court_blades",
        intents = { press = 2, stall = 1, threaten = 3, calm = 1 },
        rule = { id = "blades", label = "RESPECT FORCE", bonus = { resolve = 2, tact = -1 } },
    },
    {
        id = "ixili", name = "Ixili", planet = "Hexa",
        court = "Assembly of Many",
        patience = 9, hostility = 5, temper = 2,
        color = "light", background = "bg_court_many",
        intents = { press = 2, stall = 2, threaten = 2, calm = 2 },
        rule = { id = "assembly", label = "THE MANY", fresh = 1, repeated = -1 },
    },
}

for _, alien in ipairs(aliens) do
    aliens[alien.id] = alien
end

-- One delegation per day; after the last race the cycle starts over.
function aliens.ofDay(day)
    return aliens[(day - 1) % #aliens + 1]
end

return aliens
