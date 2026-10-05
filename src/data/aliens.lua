-- The delegations, one race per summit day: home planet, court and starting mood.
-- temper is the hostility they gain every round.

local aliens = {
    {
        id = "kelari", name = "Kelari", planet = "Thalassa",
        court = "Tribunal of Tides",
        patience = 12, hostility = 5, temper = 1,
    },
    {
        id = "vorn", name = "Vorn", planet = "Krag",
        court = "Court of Blades",
        patience = 8, hostility = 9, temper = 2,
    },
    {
        id = "ixili", name = "Ixili", planet = "Hexa",
        court = "Assembly of Many",
        patience = 14, hostility = 3, temper = 1,
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
