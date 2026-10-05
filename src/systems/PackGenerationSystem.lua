-- Generates one pack from the skills and appends it to the collection.
-- The RNG is local and seeded from RunState.packSeed, so a pack can be replayed.

local CardGenerator = require("src.generation.CardGenerator")

local PackGenerationSystem = { name = "packGeneration" }

function PackGenerationSystem.update(scene, dt)
    local registry = scene.registry

    for _ in registry:each("packRequested") do
        local runState = registry:resource("runState")
        local rng = love.math.newRandomGenerator(runState.packSeed)
        local cards = CardGenerator.pack(runState.stats, nil,
            function(...) return rng:random(...) end)

        local first = #runState.collection + 1
        for _, card in ipairs(cards) do
            card.day = runState.day -- when it was received
            runState.collection[#runState.collection + 1] = card
        end
        runState.packSeed = runState.packSeed + 1

        local pack = registry:resource("pack")
        pack.first, pack.last = first, #runState.collection

        registry:spawn({
            event = true,
            packGenerated = { first = first, last = #runState.collection },
        })
    end
end

return PackGenerationSystem
