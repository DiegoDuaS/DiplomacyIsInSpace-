-- Draws the top strip of the station screen: day, today's delegation and time slots.

local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local rules = require("src.data.progression_rules")
local Panel = require("src.graphics.Panel")
local Campaign = require("src.state.Campaign")
local campaign = require("src.data.campaign")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

local DayRenderSystem = { name = "dayRender" }

local dayFont, nameFont, smallFont

function DayRenderSystem.setup(scene)
    dayFont = Fonts.new(28)
    nameFont = Fonts.new(14)
    smallFont = Fonts.new(11)
end

function DayRenderSystem.unload(scene)
    dayFont, nameFont, smallFont = nil, nil, nil
end

function DayRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local alien = aliens.ofDay(runState.day)
    local x, y, w, h = 12, 12, 616, 64

    Panel.draw(x, y, w, h)

    love.graphics.setFont(dayFont)
    love.graphics.setColor(palette.amber)
    love.graphics.print(("DAY %d"):format(runState.day), x + 18, y + 16)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print(("OF %d"):format(campaign.days), x + 112, y + 18)
    love.graphics.print(("CYCLE %d/%d"):format(Campaign.cycleOf(runState.day), Campaign.cycles()), x + 112, y + 32)

    love.graphics.setFont(nameFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print("Delegate today: " .. alien.name:upper(), x + 190, y + 14)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print(alien.court .. ", planet " .. alien.planet, x + 190, y + 36)

    -- time slots: a filled pip is a slot still to spend
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print("TIME SLOTS", x + 470, y + 14)
    for i = 1, rules.actionsPerDay do
        local px = x + 470 + (i - 1) * 28
        if Sprites.draw("ui_slot", i <= runState.actionsLeft and 1 or 2, px, y + 32, { sx = 2 }) then
            -- drawn by the sprite: free, or spent
        elseif i <= runState.actionsLeft then
            love.graphics.setColor(palette.silver)
            love.graphics.rectangle("fill", px, y + 34, 18, 18)
        else
            love.graphics.setColor(palette.slate)
            love.graphics.rectangle("line", px + 0.5, y + 34.5, 17, 17)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return DayRenderSystem
