-- One negotiation with one delegate: the HUD and the hand of cards over the same state.
-- With payload `run` it is the day's court case: the hand comes from the collection, the delegation
-- remembers the last meeting, there is no retry, and finishing it ends the day (RunProgressSystem).

local Scene = require("src.ecs.Scene")
local aliens = require("src.data.aliens")
local rules = require("src.data.negotiation_rules")
local starterDeck = require("src.data.starter_deck")
local RunState = require("src.state.RunState")
local Screen = require("src.Screen")
local Round = require("src.negotiation.Round")
local Campaign = require("src.state.Campaign")

local HandInputSystem = require("src.systems.HandInputSystem")
local NegotiationSystem = require("src.systems.NegotiationSystem")
local OutcomeInputSystem = require("src.systems.OutcomeInputSystem")
local RunProgressSystem = require("src.systems.RunProgressSystem")
local AutosaveSystem = require("src.systems.AutosaveSystem")
local HudSystem = require("src.systems.HudSystem")
local BackgroundRenderSystem = require("src.systems.BackgroundRenderSystem")
local AlienRenderSystem = require("src.systems.AlienRenderSystem")
local HandRenderSystem = require("src.systems.HandRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")
local IntentRenderSystem = require("src.systems.IntentRenderSystem")

return function(payload)
    local scene = Scene.new("negotiation")
    local alien = aliens[payload and payload.alien or "kelari"]
    local run = payload ~= nil and payload.run == true
    local runState = RunState.get()
    scene.registry:setResource("runState", runState)

    -- SCENE state (never saved): the negotiation in progress
    local rng = love.math.newRandomGenerator(run and runState.day * 1000 + #alien.id or os.time())
    local function random(low, high) -- random() -> [0,1), random(lo, hi) -> integer
        if low == nil then return rng:random() end
        return rng:random(low, high)
    end

    -- a court case remembers how the last one with this delegation ended
    local start = run and Campaign.startingMeters(alien, runState.history, runState.day)
        or { patience = alien.patience, hostility = alien.hostility, temper = alien.temper }

    local negotiation = {
        alien = alien.id,
        patience = start.patience,
        hostility = start.hostility,
        temper = start.temper,
        round = 1,
        outcome = nil, -- "peace" | "war" | "walkout" once decided
        message = start.note, -- what the last card did (at first: why the meters are not the usual ones)
        run = run,
        day = runState.day,
        payload = payload, -- so a retry (outside a run) rebuilds the same case
    }
    Round.begin(negotiation, alien, random) -- adds the court's state and the first announced move
    scene.registry:setResource("negotiation", negotiation)

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
    if run then
        scene:addSystem(RunProgressSystem)
        scene:addSystem(AutosaveSystem)
    end
    scene:addSystem(HudSystem)
    scene:addSystem(BackgroundRenderSystem.new(function(s) -- the delegation's own court
        return aliens[s.registry:resource("negotiation").alien].background
    end))
    scene:addSystem(AlienRenderSystem)
    scene:addSystem(IntentRenderSystem)
    scene:addSystem(HandRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
