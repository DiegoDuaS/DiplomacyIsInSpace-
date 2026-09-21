-- Draws the negotiation HUD: mood, meters, round, last play and the outcome banner.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local rules = require("src.data.negotiation_rules")
local Panel = require("src.graphics.Panel")

local HudRenderSystem = { name = "hudRender" }

local BAR_X, BAR_W, BAR_H = 276, 190, 14

local BANNERS = {
    peace = { title = "PEACE HOLDS", color = "light",
        text = "The summit survives. The delegate signs." },
    war = { title = "WAR!", color = "red",
        text = "Hostility boiled over. Fleets are scrambling." },
    walkout = { title = "WALKOUT", color = "amber",
        text = "Patience ran out. The delegate leaves the table." },
}

local nameFont, smallFont, valueFont, bannerFont

function HudRenderSystem.setup(scene)
    nameFont = love.graphics.newFont(18, "mono")
    smallFont = love.graphics.newFont(11, "mono")
    valueFont = love.graphics.newFont(13, "mono")
    bannerFont = love.graphics.newFont(30, "mono")
end

function HudRenderSystem.unload(scene)
    nameFont, smallFont, valueFont, bannerFont = nil, nil, nil, nil
end

local function moodOf(hostility)
    local fraction = hostility / rules.max
    for _, mood in ipairs(rules.moods) do
        if fraction <= mood.upTo then return mood end
    end
    return rules.moods[#rules.moods]
end

local function drawMeter(label, y, shown, color, delta)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print(label, 196, y + 1)

    love.graphics.setColor(palette.ink)
    love.graphics.rectangle("fill", BAR_X - 2, y - 2, BAR_W + 4, BAR_H + 4)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", BAR_X, y, BAR_W * shown / rules.max, BAR_H)
    love.graphics.setColor(palette.ink)
    for i = 1, rules.max - 1 do
        love.graphics.rectangle("fill", BAR_X + BAR_W * i / rules.max - 0.5, y, 1, BAR_H)
    end

    love.graphics.setFont(valueFont)
    love.graphics.setColor(palette.white)
    love.graphics.print(("%d/%d"):format(math.floor(shown + 0.5), rules.max), BAR_X + BAR_W + 10, y)

    if delta then
        local rise = (1 - delta.timer / 1.1) * 8
        local good = (label == "PATIENCE") == (delta.amount > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.print(("%+d"):format(delta.amount), BAR_X + BAR_W + 62, y - rise)
    end
end

local function drawBanner(outcome)
    local banner = BANNERS[outcome]
    local w, h = 420, 96
    local x, y = (Screen.w - w) / 2, 112
    Panel.draw(x, y, w, h)
    love.graphics.setFont(bannerFont)
    love.graphics.setColor(palette[banner.color])
    love.graphics.printf(banner.title, x, y + 12, w, "center")
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf(banner.text, x + 12, y + 52, w - 24, "center")
    love.graphics.setColor(palette.amber)
    love.graphics.printf("R  try again        M  main menu", x, y + 72, w, "center")
end

function HudRenderSystem.draw(scene)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    local mood = moodOf(neg.hostility)

    for _, pos, size, hud in registry:each("position", "size", "hud") do
        Panel.draw(pos.x, pos.y, size.w, size.h)

        love.graphics.setFont(nameFont)
        love.graphics.setColor(palette.cream)
        love.graphics.print("DELEGATE", pos.x + 16, pos.y + 12)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette[mood.color])
        love.graphics.print("MOOD " .. mood.label, pos.x + 16, pos.y + 40)

        drawMeter("PATIENCE", pos.y + 14, hud.shown.patience, palette.silver, hud.delta.patience)
        drawMeter("HOSTILITY", pos.y + 42, hud.shown.hostility, palette.red, hud.delta.hostility)

        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.amber)
        love.graphics.printf(("ROUND %d/%d"):format(math.min(neg.round, rules.rounds), rules.rounds),
            pos.x, pos.y + 12, size.w - 16, "right")

        if neg.message then
            love.graphics.setColor(palette.cream)
            love.graphics.printf(neg.message, 0, pos.y + size.h + 6, Screen.w, "center")
        end
    end

    if neg.outcome then drawBanner(neg.outcome) end
    love.graphics.setColor(1, 1, 1)
end

return HudRenderSystem
