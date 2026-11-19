-- Draws the negotiation HUD: delegate, mood, meters, round, last play and the outcome banner.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local aliens = require("src.data.aliens")
local rules = require("src.data.negotiation_rules")
local Panel = require("src.graphics.Panel")
local Mood = require("src.negotiation.Mood")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

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
    nameFont = Fonts.new(18)
    smallFont = Fonts.new(11)
    valueFont = Fonts.new(13)
    bannerFont = Fonts.new(30)
end

function HudRenderSystem.unload(scene)
    nameFont, smallFont, valueFont, bannerFont = nil, nil, nil, nil
end

-- One meter: its icon, the bar (a row of ui_meter segments, or a flat bar while the art is missing),
-- the value and the floating change. `frame` picks the icon and the full-segment color (1 patience, 2 hostility).
local function drawMeter(label, frame, y, shown, color, delta)
    local hasIcon = Sprites.has("ui_icons_meter")
    local barX = hasIcon and 226 or BAR_X
    if hasIcon then
        Sprites.draw("ui_icons_meter", frame, 200, y + 1)
    else
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.cream)
        love.graphics.print(label, 196, y + 1)
    end

    local barW
    if Sprites.has("ui_meter") then
        local segment = 12 -- the sheet's frame width: the segments sit side by side
        barW = segment * rules.max
        local filled = math.floor(shown + 0.5)
        for i = 1, rules.max do
            Sprites.draw("ui_meter", i <= filled and frame or 3, barX + (i - 1) * segment, y)
        end
    else
        barW = BAR_W
        love.graphics.setColor(palette.ink)
        love.graphics.rectangle("fill", barX - 2, y - 2, barW + 4, BAR_H + 4)
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", barX, y, barW * shown / rules.max, BAR_H)
        love.graphics.setColor(palette.ink)
        for i = 1, rules.max - 1 do
            love.graphics.rectangle("fill", barX + barW * i / rules.max - 0.5, y, 1, BAR_H)
        end
    end

    love.graphics.setFont(valueFont)
    love.graphics.setColor(palette.white)
    love.graphics.print(("%d/%d"):format(math.floor(shown + 0.5), rules.max), barX + barW + 10, y + 1)

    if delta then
        local rise = (1 - delta.timer / 1.1) * 8
        local good = (label == "PATIENCE") == (delta.amount > 0)
        love.graphics.setColor(good and palette.light or palette.red)
        love.graphics.print(("%+d"):format(delta.amount), barX + barW + 62, y - rise)
    end
end

local STAMP_FRAME = { peace = 1, war = 2, walkout = 3 }

local function drawBanner(outcome, run, ending)
    local banner = BANNERS[outcome]
    local w, h = 420, 96
    local x, y = (Screen.w - w) / 2, 250 -- below the delegate, so its ending animation stays visible
    Panel.draw(x, y, w, h)
    -- the result is a 160x48 stamp (ui_stamps: 1 peace, 2 war, 3 walkout), or big text until it exists
    local stamped = Sprites.draw("ui_stamps", STAMP_FRAME[outcome], (Screen.w - 160) / 2, y + 6)
    if not stamped then
        love.graphics.setFont(bannerFont)
        love.graphics.setColor(palette[banner.color])
        love.graphics.printf(banner.title, x, y + 12, w, "center")
    end
    local shift = stamped and 6 or 0
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf(banner.text, x + 12, y + 52 + shift, w - 24, "center")
    love.graphics.setColor(palette.amber)
    love.graphics.printf(run and (ending and "ENTER  see the ending" or "ENTER  next day")
        or "R  try again        M  main menu",
        x, y + 72 + shift, w, "center")
end

function HudRenderSystem.draw(scene)
    local registry = scene.registry
    local neg = registry:resource("negotiation")
    local alien = aliens[neg.alien]
    local mood = Mood.of(neg.hostility)

    for _, pos, size, hud in registry:each("position", "size", "hud") do
        Panel.draw(pos.x, pos.y, size.w, size.h)

        love.graphics.setFont(nameFont)
        love.graphics.setColor(palette.cream)
        love.graphics.print(alien.name:upper(), pos.x + 16, pos.y + 12)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.grey)
        love.graphics.print(neg.run and ("DAY %d  -  %s"):format(neg.day, alien.court) or alien.court,
            pos.x + 16, pos.y + 34)
        love.graphics.setColor(palette[mood.color])
        love.graphics.print("MOOD " .. mood.label, pos.x + 16, pos.y + 50)

        drawMeter("PATIENCE", 1, pos.y + 14, hud.shown.patience, palette.silver, hud.delta.patience)
        drawMeter("HOSTILITY", 2, pos.y + 42, hud.shown.hostility, palette.red, hud.delta.hostility)

        love.graphics.setFont(smallFont)
        love.graphics.setColor(palette.amber)
        love.graphics.printf(("ROUND %d/%d"):format(math.min(neg.round, rules.rounds), rules.rounds),
            pos.x, pos.y + 12, size.w - 16, "right")

        if neg.message then
            -- a dark strip behind the text, so it reads over any court background
            local width = smallFont:getWidth(neg.message) + 20
            love.graphics.setColor(palette.void[1], palette.void[2], palette.void[3], 0.75)
            love.graphics.rectangle("fill", (Screen.w - width) / 2, pos.y + size.h + 3, width, 17, 4, 4)
            love.graphics.setColor(palette.cream)
            love.graphics.printf(neg.message, 0, pos.y + size.h + 6, Screen.w, "center")
        end
    end

    if neg.outcome then drawBanner(neg.outcome, neg.run, registry:resource("runState").ending) end
    love.graphics.setColor(1, 1, 1)
end

return HudRenderSystem
