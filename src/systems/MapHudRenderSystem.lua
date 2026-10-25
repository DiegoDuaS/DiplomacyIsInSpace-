-- Screen-space map HUD: the day and what the ship is close to.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local Panel = require("src.graphics.Panel")

local MapHudRenderSystem = { name = "mapHudRender" }

local dayFont, titleFont, smallFont

function MapHudRenderSystem.setup(scene)
    dayFont = love.graphics.newFont(20, "mono")
    titleFont = love.graphics.newFont(14, "mono")
    smallFont = love.graphics.newFont(11, "mono")
end

function MapHudRenderSystem.unload(scene)
    dayFont, titleFont, smallFont = nil, nil, nil
end

local function poiById(registry, id)
    for _, poi in registry:each("poi") do
        if poi.id == id then return poi end
    end
end

function MapHudRenderSystem.draw(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local nearby = poiById(registry, registry:resource("map").nearby)
    local today = aliens.ofDay(runState.day)

    Panel.draw(12, 12, 200, 40)
    love.graphics.setFont(dayFont)
    love.graphics.setColor(palette.amber)
    love.graphics.print(("DAY %d"):format(runState.day), 26, 20)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print("CONCORD SPACE", 98, 26)

    local x, y, w, h = 12, Screen.h - 62, Screen.w - 24, 50
    Panel.draw(x, y, w, h)
    love.graphics.setFont(titleFont)
    if not nearby then
        love.graphics.setColor(palette.cream)
        love.graphics.print("DEEP SPACE", x + 18, y + 9)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(("WASD / ARROWS fly    today's court: %s (%s)"):format(
            today.court, today.planet:upper()), x + 18, y + 30)
    elseif nearby.kind == "station" then
        love.graphics.setColor(palette.cream)
        love.graphics.print(nearby.name, x + 18, y + 9)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(("Today's court: %s on %s"):format(today.court, today.planet:upper()), x + 18, y + 30)
    else
        local alien = aliens[nearby.alien]
        love.graphics.setColor(palette.cream)
        love.graphics.print(("%s  -  %s DELEGATION"):format(nearby.name, alien.name:upper()), x + 18, y + 9)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(alien.court, x + 18, y + 30)
        local open = alien.id == today.id
        love.graphics.setColor(open and palette.amber or palette.grey)
        love.graphics.printf(open and "ENTER  enter the court" or "CLOSED TODAY", x, y + 30, w - 18, "right")
    end
    love.graphics.setColor(1, 1, 1)
end

return MapHudRenderSystem
