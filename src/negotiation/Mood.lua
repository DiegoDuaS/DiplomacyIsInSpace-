-- The delegate's mood from how full the hostility meter is. Pure.

local rules = require("src.data.negotiation_rules")

local Mood = {}

function Mood.of(hostility)
    local fraction = hostility / rules.max
    for _, mood in ipairs(rules.moods) do
        if fraction <= mood.upTo then return mood end
    end
    return rules.moods[#rules.moods]
end

return Mood
