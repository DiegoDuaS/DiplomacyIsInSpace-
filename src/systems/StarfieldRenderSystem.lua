-- Clears to the void color and draws a field of stars; where a scene has a camera (the map)
-- the stars drift at a fraction of its speed.

local Screen = require("src.Screen")
local palette = require("src.data.palette")

local StarfieldRenderSystem = { name = "starfieldRender" }

local STARS = 80
local PARALLAX = 0.25 -- stars are far away: they move at this fraction of the camera

function StarfieldRenderSystem.setup(scene)
    local rng = love.math.newRandomGenerator(2026)
    local stars = {}
    for i = 1, STARS do
        stars[i] = { x = rng:random(0, Screen.w - 1), y = rng:random(0, Screen.h - 1) }
    end
    scene.registry:setResource("starfield", { stars = stars })
end

function StarfieldRenderSystem.draw(scene)
    love.graphics.clear(palette.void)
    local camera = scene.registry:resource("camera")
    local shiftX = camera and math.floor(camera.x * PARALLAX) or 0
    local shiftY = camera and math.floor(camera.y * PARALLAX) or 0
    love.graphics.setColor(palette.grey)
    for _, star in ipairs(scene.registry:resource("starfield").stars) do
        love.graphics.rectangle("fill", (star.x - shiftX) % Screen.w, (star.y - shiftY) % Screen.h, 2, 2)
    end
    love.graphics.setColor(1, 1, 1)
end

return StarfieldRenderSystem
