-- One negotiation with one delegate: the HUD and the hand of cards over the same state.

local Scene = require("src.ecs.Scene")
local aliens = require("src.data.aliens")
local rules = require("src.data.negotiation_rules")
local deck = require("src.data.starter_deck")
local Screen = require("src.Screen")

local HandInputSystem = require("src.systems.HandInputSystem")
local NegotiationSystem = require("src.systems.NegotiationSystem")
local OutcomeInputSystem = require("src.systems.OutcomeInputSystem")
local HudSystem = require("src.systems.HudSystem")
local HandRenderSystem = require("src.systems.HandRenderSystem")
local HudRenderSystem = require("src.systems.HudRenderSystem")

return function(payload)
    local scene = Scene.new("negotiation")
    local alien = aliens[payload and payload.alien or "delegate1"]

    -- SCENE state (never saved): the negotiation in progress
    scene.registry:setResource("negotiation", {
        alien = alien.id,
        patience = alien.patience,
        hostility = alien.hostility,
        round = 1,
        outcome = nil, -- "peace" | "war" | "walkout" once decided
        message = nil, -- what the last card did
    })

    -- the hand: the first cards of the deck; the rest wait their turn
    local cards = {}
    for i = 1, rules.handSize do
        cards[i] = deck[i]
    end
    scene.registry:spawn({
        position = { x = Screen.w / 2, y = 246 },
        hand = { cards = cards, cursor = 1, deck = deck, deckIndex = rules.handSize + 1 },
    })

    scene:addSystem(HandInputSystem)
    scene:addSystem(NegotiationSystem)
    scene:addSystem(OutcomeInputSystem)
    scene:addSystem(HudSystem)
    scene:addSystem(HandRenderSystem)
    scene:addSystem(HudRenderSystem)

    return scene
end
