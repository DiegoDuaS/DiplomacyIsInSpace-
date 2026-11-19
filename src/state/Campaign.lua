-- The rules of the whole run, on plain data (the RunState): how a past outcome changes the next
-- meeting with the same delegation, and when and how the run ends. Pure: no LÖVE, no registry.
--
--   history = { { day = 1, alien = "kelari", outcome = "peace" }, ... }   one entry per finished day

local aliens = require("src.data.aliens")
local rules = require("src.data.campaign")
local progression = require("src.data.progression_rules")

local Campaign = {}

function Campaign.cycleOf(day)
    return math.floor((day - 1) / rules.cycleLength) + 1
end

function Campaign.cycles()
    return rules.days / rules.cycleLength
end

-- How the last meeting with this delegation ended, or nil on the first one.
function Campaign.lastOutcome(history, alienId)
    for i = #history, 1, -1 do
        if history[i].alien == alienId then return history[i].outcome end
    end
end

-- The meters this negotiation starts with (and the hostility gained per round), and a line saying
-- why they are not the usual ones. `day` is optional: it picks the cycle's ease.
function Campaign.startingMeters(alien, history, day)
    local ease = day and rules.ease[Campaign.cycleOf(day)] or {}
    local patience = alien.patience + (ease.patience or 0)
    local hostility = math.max(0, alien.hostility + (ease.hostility or 0))
    local temper = math.max(0, alien.temper + (ease.temper or 0))
    local note
    local last = Campaign.lastOutcome(history, alien.id)
    local carry = rules.carry[last]

    if carry and carry.patience then
        patience = math.max(rules.carry.minPatience, math.min(patience, patience + carry.patience))
        note = ("%s walked out last time: they sit down with less patience."):format(alien.name)
    elseif carry and carry.hostility then
        hostility = math.min(rules.carry.maxHostility, hostility + carry.hostility)
        note = ("%s remember the war: they sit down angrier."):format(alien.name)
    end
    return { patience = patience, hostility = hostility, temper = temper, note = note }
end

-- Did the cycle that ends with the latest entry end with everyone at war?
local function cycleAtWar(history)
    local first = #history - rules.cycleLength + 1
    if first < 1 then return false end
    for i = first, #history do
        if history[i].outcome ~= "war" then return false end
    end
    return true
end

-- "win", "meh" or "bad" once the run is decided by the history so far; nil while it goes on.
function Campaign.ending(history)
    if #history % rules.cycleLength ~= 0 then return nil end -- endings are decided between cycles
    if cycleAtWar(history) then return "bad" end
    if #history < rules.days then return nil end

    for i = #history - rules.cycleLength + 1, #history do
        if history[i].outcome ~= "peace" then return "meh" end
    end
    return "win"
end

-- Records how the day's negotiation ended and moves the run on: the next day (slots refilled),
-- or its ending. Returns the ending, if there is one.
function Campaign.finishDay(runState, alienId, outcome)
    assert(rules.outcomes[outcome], "unknown outcome: " .. tostring(outcome))
    assert(type(aliens[alienId]) == "table" and aliens[alienId].id == alienId, "unknown delegation: " .. tostring(alienId))
    local history = runState.history
    history[#history + 1] = { day = runState.day, alien = alienId, outcome = outcome }

    runState.ending = Campaign.ending(history)
    if not runState.ending then
        runState.day = runState.day + 1
        runState.actionsLeft = progression.actionsPerDay
    end
    return runState.ending
end

return Campaign
