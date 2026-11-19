-- Draws the delegate. Each state has its own animation (assets/sprites/alien_<id>_<state>.png):
-- the mood loops while the talk goes on, the ending plays once. A missing PNG falls back to the
-- mood loop, and with no art at all to a flat placeholder.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local Mood = require("src.negotiation.Mood")
local Sprites = require("src.graphics.Sprites")

local AlienRenderSystem = { name = "alienRender" }

local SIZE = 128
local TOP = 84 -- the delegate sits between the HUD and the hand

-- The state to show now: the ending once it is decided, else the mood.
local function stateOf(neg)
    local mood = Mood.of(neg.hostility).label:lower()
    return neg.outcome or mood, mood
end

function AlienRenderSystem.setup(scene)
    scene.registry:setResource("alienAnim", { state = nil, time = 0 })
end

function AlienRenderSystem.update(scene, dt)
    local anim = scene.registry:resource("alienAnim")
    local state = stateOf(scene.registry:resource("negotiation"))
    if state ~= anim.state then
        anim.state, anim.time = state, 0 -- a new state starts from its first frame
    end
    anim.time = anim.time + dt
end

local function drawFlat(alien)
    local cx, cy = Screen.w / 2, 148
    love.graphics.setColor(palette[alien.color])
    love.graphics.circle("fill", cx, cy, 52)
    love.graphics.setColor(palette.white)
    love.graphics.circle("fill", cx - 20, cy - 8, 11)
    love.graphics.circle("fill", cx + 20, cy - 8, 11)
    love.graphics.setColor(palette.ink)
    love.graphics.circle("fill", cx - 20, cy - 8, 5)
    love.graphics.circle("fill", cx + 20, cy - 8, 5)
    love.graphics.rectangle("fill", cx - 18, cy + 22, 36, 5)
    love.graphics.setColor(1, 1, 1)
end

function AlienRenderSystem.draw(scene)
    local neg = scene.registry:resource("negotiation")
    local anim = scene.registry:resource("alienAnim")
    local alien = aliens[neg.alien]
    local state, mood = stateOf(neg)
    local x = (Screen.w - SIZE) / 2
    local top = TOP + (alien.dy or 0) -- a delegation can sit lower, behind the hand

    local name = "alien_" .. alien.id .. "_" .. state
    if Sprites.has(name) then
        local ending = neg.outcome ~= nil
        local frame = ending and Sprites.frameOnce(name, anim.time) or Sprites.frameAt(name, anim.time)
        Sprites.draw(name, frame, x, top)
        return
    end

    -- no animation for this state yet: the mood, then the calm one (whatever is drawn so far)
    for _, fallback in ipairs({ "alien_" .. alien.id .. "_" .. mood, "alien_" .. alien.id .. "_calm" }) do
        if Sprites.has(fallback) then
            Sprites.draw(fallback, Sprites.frameAt(fallback, anim.time), x, top)
            return
        end
    end
    drawFlat(alien)
end

return AlienRenderSystem
