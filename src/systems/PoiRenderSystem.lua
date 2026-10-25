-- Draws what labels the places: the ring around the nearby one, its name and today's marker.
-- The blocks themselves are tiles (TilemapRenderSystem).

local palette = require("src.data.palette")
local aliens = require("src.data.aliens")

local PoiRenderSystem = { name = "poiRender" }

local nameFont, smallFont

function PoiRenderSystem.setup(scene)
    nameFont = love.graphics.newFont(12, "mono")
    smallFont = love.graphics.newFont(10, "mono")
end

function PoiRenderSystem.unload(scene)
    nameFont, smallFont = nil, nil
end

function PoiRenderSystem.draw(scene)
    local registry = scene.registry
    local map = registry:resource("map")
    local today = aliens.ofDay(registry:resource("runState").day)

    for _, pos, poi in registry:each("position", "poi") do
        if map.nearby == poi.id then
            love.graphics.setColor(palette.amber)
            love.graphics.circle("line", pos.x, pos.y, poi.range)
        end

        local below = poi.kind ~= "station" and pos.y + poi.half + 36 < map.bounds.h + 18
        local ly = below and pos.y + poi.half + 6 or pos.y - poi.half - 34
        local isToday = poi.alien == today.id
        love.graphics.setFont(nameFont)
        love.graphics.setColor(isToday and palette.amber or palette.cream)
        love.graphics.printf(poi.name .. (isToday and "  [TODAY]" or ""), pos.x - 100, ly, 200, "center")
        if poi.subtitle then
            love.graphics.setFont(smallFont)
            love.graphics.setColor(palette.grey)
            love.graphics.printf(poi.subtitle, pos.x - 100, ly + 15, 200, "center")
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return PoiRenderSystem
