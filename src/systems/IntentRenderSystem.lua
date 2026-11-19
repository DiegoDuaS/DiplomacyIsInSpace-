-- The two panels beside the delegate: on the right the move it just announced (what and how
-- big, as a range, and which card kind softens it); on the left what makes this court different.

local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local intents = require("src.data.intents")
local Intent = require("src.negotiation.Intent")
local Modifiers = require("src.negotiation.Modifiers")
local Panel = require("src.graphics.Panel")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

local IntentRenderSystem = { name = "intentRender" }

local LEFT = { x = 12, y = 106, w = 236, h = 96 }
local RIGHT = { x = 392, y = 106, w = 236, h = 96 }
local PAD = 14

local titleFont, bodyFont, smallFont

function IntentRenderSystem.setup(scene)
    titleFont = Fonts.new(16)
    bodyFont = Fonts.new(11)
    smallFont = Fonts.new(10)
end

function IntentRenderSystem.unload(scene)
    titleFont, bodyFont, smallFont = nil, nil, nil
end

-- A 16x16 icon scaled x2 from its sheet, or a flat square while the art is missing.
local function icon(name, frame, x, y, color, tint)
    if Sprites.draw(name, frame, x, y, { sx = 2, color = tint }) then return end
    love.graphics.setColor(color)
    love.graphics.rectangle("line", x + 1, y + 1, 30, 30)
    love.graphics.rectangle("fill", x + 8, y + 8, 16, 16)
end

local function drawIntent(neg)
    local box = RIGHT
    Panel.draw(box.x, box.y, box.w, box.h)
    local x, y = box.x + PAD, box.y + 10

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print("NEXT MOVE", x, y)

    local def = intents[neg.intent.id]
    icon("ui_intents", def.frame, x, y + 16, palette.amber)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print(def.label, x + 42, y + 18)

    love.graphics.setFont(bodyFont)
    local lineY = y + 22 + 16
    for _, line in ipairs(Intent.describe(neg.intent)) do
        love.graphics.setColor(line.good and palette.light or palette.red)
        love.graphics.print(line.text, x + 42, lineY)
        lineY = lineY + 14
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.amber)
    love.graphics.print(def.counter and ("SOFTENED BY " .. def.counter:upper()) or "NOTHING SOFTENS IT",
        x, box.y + box.h - 22)
end

local function drawRule(alien, neg)
    local box = LEFT
    Panel.draw(box.x, box.y, box.w, box.h)
    local x, y = box.x + PAD, box.y + 10
    local info = Modifiers.describe(alien.rule, neg.ruleState)

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.print("COURT RULE  -  " .. info.title, x, y)

    icon("ui_rules", info.frame, x, y + 16, palette.amber)
    love.graphics.setFont(bodyFont)
    love.graphics.setColor(info.bad and palette.red or palette.cream)
    love.graphics.print(info.headline, x + 42, y + 18)

    love.graphics.setColor(palette.silver)
    local lineY = y + 36
    for _, line in ipairs(info.lines) do
        love.graphics.print(line, x + 42, lineY)
        lineY = lineY + 14
    end
end

function IntentRenderSystem.draw(scene)
    local neg = scene.registry:resource("negotiation")
    if neg.outcome or not neg.intent then return end

    drawRule(aliens[neg.alien], neg)
    drawIntent(neg)
    love.graphics.setColor(1, 1, 1)
end

return IntentRenderSystem
