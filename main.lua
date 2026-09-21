-- Bootstrap only: register scenes, start one, forward the LÖVE callbacks to the Game.
-- `love . <scene>` starts on that scene; `--debug` opens the editor.

local Game = require("src.Game")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")

function love.load(args)
    Game.registerScene("menu", require("src.scenes.MenuScene"))
    Game.registerScene("negotiation", require("src.scenes.NegotiationScene"))

    local known, startScene = {}, "menu"
    for _, name in ipairs(Game.sceneNames()) do
        known[name] = true
    end
    if known[args[1]] then
        startScene = args[1]
    end
    Game.start(startScene)

    attachDebugOverlay(Game)
    for _, arg in ipairs(args) do
        if arg == "--debug" then
            DebugOverlay.enterEditor()
        end
    end
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.quit()
    Game.quit()
end
