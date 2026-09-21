-- The delegates, one per summit day, with their starting mood.
-- temper is the hostility they gain every round.

local aliens = {
    { id = "delegate1", patience = 12, hostility = 5, temper = 1 },
    { id = "delegate2", patience = 8, hostility = 9, temper = 2 },
    { id = "delegate3", patience = 14, hostility = 3, temper = 1 },
}

for _, alien in ipairs(aliens) do
    aliens[alien.id] = alien
end

return aliens
