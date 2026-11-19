-- Draws the title screen: name, the menu with its cursor and the credits panel.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")
local Sprites = require("src.graphics.Sprites")
local Fonts = require("src.graphics.Fonts")

local MenuRenderSystem = { name = "menuRender" }

local titleFont, subtitleFont, itemFont, smallFont

function MenuRenderSystem.setup(scene)
    titleFont = Fonts.new(46)
    subtitleFont = Fonts.new(22)
    itemFont = Fonts.new(20)
    smallFont = Fonts.new(12)
end

function MenuRenderSystem.unload(scene)
    -- drop the references, the GC collects them; never release() fonts
    titleFont, subtitleFont, itemFont, smallFont = nil, nil, nil, nil
end

local function drawTitle()
    if Sprites.has("bg_menu") then return end -- the title is painted in the backdrop
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf("DIPLOMACY", 0, 34, Screen.w, "center")
    love.graphics.setFont(subtitleFont)
    love.graphics.setColor(palette.silver)
    love.graphics.printf("IS IN SPACE", 0, 88, Screen.w, "center")
end

local function drawCredits()
    local w, h = 400, 150
    local x, y = (Screen.w - w) / 2, 190
    Panel.draw(x, y, w, h)
    love.graphics.setFont(itemFont)
    love.graphics.setColor(palette.amber)
    love.graphics.printf("CREDITS", x, y + 16, w, "center")
    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.cream)
    love.graphics.printf("Design and code: DiegoDuaS\nMade with LOVE 11.5 and a hand-written ECS\nCourse: CC3096 Game Engine Architecture",
        x + 16, y + 52, w - 32, "center")
    love.graphics.setColor(palette.grey)
    love.graphics.printf("ENTER / BACKSPACE  back", x, y + h - 26, w, "center")
end

function MenuRenderSystem.draw(scene)
    local registry = scene.registry

    drawTitle()

    for _, pos, menu in registry:each("position", "menu") do
        if not menu.active then break end -- the credits panel covers the menu
        love.graphics.setFont(itemFont)
        for i, option in ipairs(menu.options) do
            local y = pos.y + (i - 1) * menu.spacing
            local selected = i == menu.cursor
            love.graphics.setColor(selected and palette.amber or palette.cream)
            love.graphics.printf(option.label, 0, y, Screen.w, "center")
            if selected then
                local half = itemFont:getWidth(option.label) / 2
                local frame = Sprites.frameAt("ui_cursor", love.timer.getTime())
                -- the cursor points right; the one on the right side is mirrored
                local drawn = Sprites.draw("ui_cursor", frame, Screen.w / 2 - half - 36, y + 2, { sx = 2 })
                    and Sprites.draw("ui_cursor", frame, Screen.w / 2 + half + 16, y + 2, { sx = -2, sy = 2, ox = 10 })
                if not drawn and math.sin(love.timer.getTime() * 7) > -0.3 then -- no art: blinking squares
                    love.graphics.setColor(palette.amber)
                    love.graphics.rectangle("fill", Screen.w / 2 - half - 26, y + 7, 12, 8)
                    love.graphics.rectangle("fill", Screen.w / 2 + half + 14, y + 7, 12, 8)
                end
            end
        end
    end

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.grey)
    love.graphics.printf("UP/DOWN choose    ENTER confirm    ESC quit", 0, Screen.h - 22, Screen.w, "center")

    if registry:resource("credits").open then drawCredits() end
    love.graphics.setColor(1, 1, 1)
end

return MenuRenderSystem
