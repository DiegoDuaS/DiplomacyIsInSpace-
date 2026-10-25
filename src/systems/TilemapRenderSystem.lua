-- Draws the terrain grid as flat tiles: grey asteroids, a light station and one block per planet in
-- its alien's color. Each block gets an outline only where it meets open space, so neighboring
-- cells read as one shape. Only cells inside the camera's view are drawn. Real tile art
-- replaces this system later.

local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local Screen = require("src.Screen")

local TilemapRenderSystem = { name = "tilemapRender" }

local function colors(terrain, pois)
    if terrain == "asteroid" then return palette.slate, palette.grey end
    if terrain == "station" then return palette.light, palette.slate end
    for _, poi in ipairs(pois) do
        if poi.id == terrain and poi.alien then
            local color = palette[aliens[poi.alien].color]
            return color, color
        end
    end
    return palette.grey, palette.grey
end

function TilemapRenderSystem.draw(scene)
    local registry = scene.registry
    local _, tilemap = registry:first("tilemap")
    local grid, cell = tilemap.grid, tilemap.cell
    local camera = registry:resource("camera")

    for x, y, terrain in grid:each() do
        local px, py = (x - 1) * cell, (y - 1) * cell
        if px + cell >= camera.x and px <= camera.x + Screen.w
            and py + cell >= camera.y and py <= camera.y + Screen.h then
            local fill, edge = colors(terrain, tilemap.pois)

            love.graphics.setColor(fill)
            love.graphics.rectangle("fill", px, py, cell, cell)

            love.graphics.setColor(edge)
            if grid:get(x, y - 1) ~= terrain then love.graphics.rectangle("fill", px, py, cell, 1) end
            if grid:get(x, y + 1) ~= terrain then love.graphics.rectangle("fill", px, py + cell - 1, cell, 1) end
            if grid:get(x - 1, y) ~= terrain then love.graphics.rectangle("fill", px, py, 1, cell) end
            if grid:get(x + 1, y) ~= terrain then love.graphics.rectangle("fill", px + cell - 1, py, 1, cell) end
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return TilemapRenderSystem
