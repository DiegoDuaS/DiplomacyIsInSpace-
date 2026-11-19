-- Draws the ending: its title and text, and a table with how each of the nine days went.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local campaign = require("src.data.campaign")
local Panel = require("src.graphics.Panel")
local Campaign = require("src.state.Campaign")
local Fonts = require("src.graphics.Fonts")

local EndingRenderSystem = { name = "endingRender" }

local OUTCOME = {
    peace = { label = "PEACE", color = "light" },
    walkout = { label = "WALKOUT", color = "amber" },
    war = { label = "WAR", color = "red" },
}

local titleFont, bodyFont, smallFont

function EndingRenderSystem.setup(scene)
    titleFont = Fonts.new(28)
    bodyFont = Fonts.new(13)
    smallFont = Fonts.new(11)
end

function EndingRenderSystem.unload(scene)
    titleFont, bodyFont, smallFont = nil, nil, nil
end

-- The nine days as three columns, one per cycle.
local function drawHistory(history, x, y)
    local cycleW, rowH = 190, 20
    for cycle = 1, Campaign.cycles() do
        local cx = x + (cycle - 1) * cycleW
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(("CYCLE %d"):format(cycle), cx, y)

        for slot = 1, campaign.cycleLength do
            local day = (cycle - 1) * campaign.cycleLength + slot
            local entry = history[day]
            local ry = y + 18 + (slot - 1) * rowH
            love.graphics.setFont(bodyFont)
            love.graphics.setColor(palette.cream)
            love.graphics.print(("DAY %d"):format(day), cx, ry)
            if entry then
                love.graphics.setColor(palette.silver)
                love.graphics.print(aliens[entry.alien].name:upper(), cx + 48, ry)
                local outcome = OUTCOME[entry.outcome]
                love.graphics.setColor(palette[outcome.color])
                love.graphics.print(outcome.label, cx + 106, ry)
            else
                love.graphics.setColor(palette.slate)
                love.graphics.print("-", cx + 48, ry)
            end
        end
    end
end

function EndingRenderSystem.draw(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local ending = campaign.endings[registry:resource("ending").kind]

    -- text on top and at the bottom: the band between them (y 118-256) is left for the picture
    Panel.draw(60, 12, Screen.w - 120, 100)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette[ending.color])
    love.graphics.printf(ending.title, 60, 24, Screen.w - 120, "center")
    love.graphics.setFont(bodyFont)
    love.graphics.setColor(palette.cream)
    for i, line in ipairs(ending.lines) do
        love.graphics.printf(line, 60, 64 + (i - 1) * 20, Screen.w - 120, "center")
    end

    Panel.draw(30, 266, Screen.w - 60, 106)
    drawHistory(runState.history, 56, 276)

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.void[1], palette.void[2], palette.void[3], 0.75)
    love.graphics.rectangle("fill", Screen.w / 2 - 70, Screen.h - 25, 140, 17, 4, 4)
    love.graphics.setColor(palette.silver)
    love.graphics.printf("ENTER  main menu", 0, Screen.h - 22, Screen.w, "center")
    love.graphics.setColor(1, 1, 1)
end

return EndingRenderSystem
