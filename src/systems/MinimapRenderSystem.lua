-- Screen-space minimap of the whole world, top right: asteroids, the places, today's planet
-- blinking, the ship and the rectangle the camera currently shows.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local Panel = require("src.graphics.Panel")

local MinimapRenderSystem = { name = "minimapRender" }

local SCALE = 0.125 -- one minimap pixel per 8 world pixels

function MinimapRenderSystem.draw(scene)
    local registry = scene.registry
    local camera = registry:resource("camera")
    local today = aliens.ofDay(registry:resource("runState").day)
    local _, tilemap = registry:first("tilemap")
    local cell = tilemap.cell
    local mapW = tilemap.grid.width * cell * SCALE
    local mapH = tilemap.grid.height * cell * SCALE
    local x0, y0 = Screen.w - 12 - mapW - 6, 12 + 6

    Panel.draw(x0 - 6, y0 - 6, mapW + 12, mapH + 12)
    love.graphics.setColor(palette.void)
    love.graphics.rectangle("fill", x0, y0, mapW, mapH)

    love.graphics.setColor(palette.slate)
    for cx, cy, terrain in tilemap.grid:each() do
        if terrain == "asteroid" then
            love.graphics.rectangle("fill", x0 + (cx - 1) * cell * SCALE,
                y0 + (cy - 1) * cell * SCALE, cell * SCALE, cell * SCALE)
        end
    end

    local blink = math.sin(love.timer.getTime() * 6) > 0
    for _, pos, poi in registry:each("position", "poi") do
        local px, py = x0 + pos.x * SCALE, y0 + pos.y * SCALE
        local half = poi.half * SCALE
        if poi.kind == "station" then
            love.graphics.setColor(palette.white)
        else
            love.graphics.setColor(palette[aliens[poi.alien].color])
        end
        love.graphics.rectangle("fill", px - half, py - half, half * 2, half * 2)
        if poi.alien == today.id and blink then
            love.graphics.setColor(palette.amber)
            love.graphics.rectangle("line", px - half - 2.5, py - half - 2.5, half * 2 + 5, half * 2 + 5)
        end
    end

    for _, pos in registry:each("position", "ship") do
        love.graphics.setColor(palette.amber)
        love.graphics.rectangle("fill", x0 + pos.x * SCALE - 1, y0 + pos.y * SCALE - 1, 3, 3)
    end

    love.graphics.setColor(palette.cream[1], palette.cream[2], palette.cream[3], 0.6)
    love.graphics.rectangle("line", x0 + camera.x * SCALE + 0.5, y0 + camera.y * SCALE + 0.5,
        Screen.w * SCALE, Screen.h * SCALE)
    love.graphics.setColor(1, 1, 1)
end

return MinimapRenderSystem
