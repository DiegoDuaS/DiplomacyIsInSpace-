local Screen = require("src.Screen") -- the game's resolution, one source

function love.conf(t)
    t.identity = "diplomacy-is-in-space" -- names the per-user save directory
    t.window.title = "Diplomacy Is In Space"
    t.window.width = Screen.w
    t.window.height = Screen.h
    t.window.display = Screen.display
    t.version = "11.5"
end
