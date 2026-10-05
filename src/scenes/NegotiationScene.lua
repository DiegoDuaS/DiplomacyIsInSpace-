-- One negotiation with one delegate: the HUD and the hand of cards over the same state.
-- With payload `run` it is the day's court case: the hand comes from the collection and
-- finishing it ends the day.

local Scene = require("src.ecs.Scene")
local aliens = require("src.data.aliens")
local rules = require("src.data.negotiation_rules")
local starterDeck = require("src.data.starter_deck")
local RunState = require("src.state.RunState")
local Screen = require("src.Screen")

local HandInputSystem = require("src.systems.HandInputSystem")
local NegotiationSystem = require("src.systems.NegotiationSystem")
local OutcomeInputSystem = require("src.systems.OutcomeInputSystem")
local EndDaySystem = require("src.systems.EndDaySystem")
local HudSystem = require("src.systems.HudSystem")
local HandRenderSystem = require("src.systems.HandRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")

return function(payload)
    local scene = Scene.new("negotiation")
    local alien = aliens[payload and payload.alien or "kelari"]
    local run = payload ~= nil and payload.run == true
    local runState = RunState.get()
    scene.registry:setResource("runState", runState)

    -- SCENE state (never saved): the negotiation in progress
    scene.registry:setResource("negotiation", {
        alien = alien.id,
        patience = alien.patience,
        hostility = alien.hostility,
        round = 1,
        outcome = nil, -- "peace" | "war" | "walkout" once decided
        message = nil, -- what the last card did
        run = run,
        day = runState.day,
        payload = payload, -- so a retry rebuilds the same case
    })

    -- a court case deals from the operator's collection, shuffled per day
    local deck = starterDeck
    if run and #runState.collection >= rules.handSize then
        local rng = love.math.newRandomGenerator(runState.day)
        deck = {}
        for i, card in ipairs(runState.collection) do
            local j = rng:random(1, i)
            deck[i] = deck[j]
            deck[j] = card
        end
    end

    -- the hand: the first cards of the deck; the rest wait their turn
    local cards = {}
    for i = 1, rules.handSize do
        cards[i] = deck[i]
    end
    scene.registry:spawn({
        position = { x = Screen.w / 2, y = 246 },
        hand = { cards = cards, cursor = 1, deck = deck, deckIndex = rules.handSize + 1 },
    })

    -- OutcomeInput runs BEFORE the rules so the key that decides the outcome
    -- cannot also dismiss it in the same frame
    scene:addSystem(HandInputSystem)
    scene:addSystem(OutcomeInputSystem)
    scene:addSystem(NegotiationSystem)
    if run then scene:addSystem(EndDaySystem) end
    scene:addSystem(HudSystem)
    scene:addSystem(HandRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
