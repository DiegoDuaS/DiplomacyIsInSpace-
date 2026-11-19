-- Proves the rules of the whole run without LÖVE:  lua tests/campaign.lua
package.path = "./?.lua;" .. package.path

local aliens = require("src.data.aliens")
local rules = require("src.data.campaign")
local Campaign = require("src.state.Campaign")
local RunState = require("src.state.RunState")
local progression = require("src.data.progression_rules")

-- Plays a whole run from a list of outcomes, one per day; returns the run.
local function play(outcomes)
    local run = RunState.new()
    for _, outcome in ipairs(outcomes) do
        assert(not run.ending, "the run should already be over")
        Campaign.finishDay(run, aliens.ofDay(run.day).id, outcome)
    end
    return run
end

local function repeated(outcome, n)
    local list = {}
    for i = 1, n do list[i] = outcome end
    return list
end

local function concat(...)
    local list = {}
    for _, part in ipairs({ ... }) do
        for _, item in ipairs(part) do list[#list + 1] = item end
    end
    return list
end

-- 1. Days and cycles.
do
    assert(Campaign.cycleOf(1) == 1 and Campaign.cycleOf(3) == 1 and Campaign.cycleOf(4) == 2 and Campaign.cycleOf(9) == 3)
    assert(Campaign.cycles() == 3)
    assert(aliens.ofDay(1).id == "kelari" and aliens.ofDay(4).id == "kelari" and aliens.ofDay(9).id == "ixili",
        "each cycle visits the three delegations in the same order")
end

-- 2. A bad meeting is remembered by the next one with the same delegation (and only by it).
do
    local kelari, vorn = aliens.kelari, aliens.vorn
    local none = Campaign.startingMeters(kelari, {})
    assert(none.patience == kelari.patience and none.hostility == kelari.hostility and none.note == nil, "first meeting is normal")

    local peace = { { day = 1, alien = "kelari", outcome = "peace" } }
    local calm = Campaign.startingMeters(kelari, peace)
    assert(calm.patience == kelari.patience and calm.hostility == kelari.hostility, "peace: starts normally")

    local walkout = { { day = 1, alien = "kelari", outcome = "walkout" } }
    local tired = Campaign.startingMeters(kelari, walkout)
    assert(tired.patience == kelari.patience + rules.carry.walkout.patience and tired.hostility == kelari.hostility
        and tired.note, "walkout: less patience")

    local war = { { day = 1, alien = "kelari", outcome = "war" } }
    local angry = Campaign.startingMeters(kelari, war)
    assert(angry.hostility == kelari.hostility + rules.carry.war.hostility and angry.patience == kelari.patience
        and angry.note, "war: more hostility")

    local other = Campaign.startingMeters(vorn, war)
    assert(other.patience == vorn.patience and other.hostility == vorn.hostility, "Vorn must not remember a war with Kelari")

    -- only the LAST meeting counts
    local healed = { war[1], { day = 4, alien = "kelari", outcome = "peace" } }
    assert(Campaign.startingMeters(kelari, healed).hostility == kelari.hostility, "a later peace clears the grudge")

    -- never starts already lost
    for _, alien in ipairs(aliens) do
        for _, outcome in ipairs({ "walkout", "war" }) do
            local m = Campaign.startingMeters(alien, { { day = 1, alien = alien.id, outcome = outcome } })
            assert(m.patience >= rules.carry.minPatience and m.hostility <= rules.carry.maxHostility)
        end
    end
end

-- 2b. The first cycle is gentler; later ones are the delegation's usual numbers.
do
    local kelari = aliens.kelari
    local easy = Campaign.startingMeters(kelari, {}, 1)
    assert(easy.patience > kelari.patience and easy.hostility < kelari.hostility and easy.temper < kelari.temper)
    local usual = Campaign.startingMeters(kelari, {}, 4)
    assert(usual.patience == kelari.patience and usual.hostility == kelari.hostility and usual.temper == kelari.temper)
    -- a grudge still counts on top of the ease
    local war = { { day = 1, alien = "kelari", outcome = "war" } }
    assert(Campaign.startingMeters(kelari, war, 4).hostility == kelari.hostility + rules.carry.war.hostility)
end

-- 3. finishDay moves the run on.
do
    local run = RunState.new()
    run.actionsLeft = 0
    Campaign.finishDay(run, "kelari", "peace")
    assert(run.day == 2 and run.actionsLeft == progression.actionsPerDay and #run.history == 1 and not run.ending)
    assert(run.history[1].day == 1 and run.history[1].alien == "kelari" and run.history[1].outcome == "peace")
    assert(not pcall(Campaign.finishDay, run, "kelari", "victory"), "unknown outcomes are refused")
end

-- 4. Endings.
do
    -- win: days 7, 8, 9 all peace (whatever happened before)
    assert(play(repeated("peace", 9)).ending == "win")
    assert(play(concat(repeated("walkout", 2), { "peace" }, repeated("war", 2), { "walkout" }, repeated("peace", 3))).ending == "win",
        "the first six days may go badly: only the last cycle decides the win")

    -- meh: someone in days 7, 8, 9 at war or walking out
    assert(play(concat(repeated("peace", 6), { "peace", "peace", "walkout" })).ending == "meh")
    assert(play(concat(repeated("peace", 6), { "war", "peace", "peace" })).ending == "meh")
    assert(play(concat(repeated("peace", 6), { "war", "walkout", "peace" })).ending == "meh")

    -- bad: every delegation at war in one cycle
    for cycle = 1, 3 do
        local run = play(concat(repeated("peace", (cycle - 1) * 3), repeated("war", 3)))
        assert(run.ending == "bad", "cycle " .. cycle .. " at war must end the run")
        assert(#run.history == cycle * 3 and run.day == cycle * 3, "the run stops where it ended")
    end

    -- two wars and a peace is not enough; the run goes on
    local run = play({ "war", "war", "peace" })
    assert(run.ending == nil and run.day == 4)
    assert(play(concat(repeated("war", 2), { "walkout" })).ending == nil, "a walkout in the cycle saves it from 'bad'")

    -- no ending before the cycle is over
    assert(Campaign.ending({ { outcome = "war" }, { outcome = "war" } }) == nil)
end

print("campaign ok")
