-- The station in the morning: spend time slots on actions that train skills.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local actions = require("src.data.actions")
local aliens = require("src.data.aliens")
local kinds = require("src.data.card_kinds")

local MenuInputSystem = require("src.systems.MenuInputSystem")
local ActionSystem = require("src.systems.ActionSystem")
local PrepNavigationSystem = require("src.systems.PrepNavigationSystem")
local FeedbackSystem = require("src.systems.FeedbackSystem")
local TextboxSystem = require("src.systems.TextboxSystem")
local ProgressionGateSystem = require("src.systems.ProgressionGateSystem")
local AutosaveSystem = require("src.systems.AutosaveSystem")
local BackgroundRenderSystem = require("src.systems.BackgroundRenderSystem")
local Campaign = require("src.state.Campaign")
local DayRenderSystem = require("src.systems.DayRenderSystem")
local StatsRenderSystem = require("src.systems.StatsRenderSystem")
local ActionMenuRenderSystem = require("src.systems.ActionMenuRenderSystem")
local TextboxRenderSystem = require("src.systems.TextboxRenderSystem")

return function(payload)
    local scene = Scene.new("prep")
    local runState = RunState.get()

    -- the shared state, by reference: the same table every scene sees
    scene.registry:setResource("runState", runState)

    -- the schedule menu: one entity, options built from the actions data
    local options = {}
    for _, id in ipairs(actions.order) do
        local action = actions[id]
        options[#options + 1] = {
            id = id, label = action.label, costsSlot = true,
            hint = ("+%d %s"):format(action.gain, action.stat:upper()),
            color = kinds[action.stat].color,
        }
    end
    options[#options + 1] = {
        id = "collection", label = "VIEW COLLECTION", costsSlot = false,
        hint = "FREE", color = "grey",
    }
    scene.registry:spawn({
        position = { x = 278, y = 92 },
        size = { w = 350, h = 200 },
        menu = { options = options, cursor = 1, spacing = 38, active = true },
    })

    -- what the delegation of the day remembers of the last meeting, if it went badly
    local grudge = Campaign.startingMeters(aliens.ofDay(runState.day), runState.history, runState.day).note

    -- the feedback box: pure output, written by FeedbackSystem
    scene.registry:spawn({
        position = { x = 12, y = 304 },
        size = { w = 616, h = 84 },
        textbox = {
            text = ("Day %d. The %s delegation expects you at the %s. Train, then prepare your case.%s"):format(
                runState.day, aliens.ofDay(runState.day).name, aliens.ofDay(runState.day).court,
                grudge and ("  " .. grudge) or ""),
            visibleChars = 0,
            speed = 60, -- characters per second
        },
    })

    scene:addSystem(MenuInputSystem)
    scene:addSystem(ActionSystem)
    scene:addSystem(AutosaveSystem)
    scene:addSystem(PrepNavigationSystem)
    scene:addSystem(FeedbackSystem)
    scene:addSystem(TextboxSystem)
    scene:addSystem(ProgressionGateSystem)
    scene:addSystem(BackgroundRenderSystem.new(function() return "bg_station" end))
    scene:addSystem(DayRenderSystem)
    scene:addSystem(StatsRenderSystem)
    scene:addSystem(ActionMenuRenderSystem)
    scene:addSystem(TextboxRenderSystem)

    return scene
end
