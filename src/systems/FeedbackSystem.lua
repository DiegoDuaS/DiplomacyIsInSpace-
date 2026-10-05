-- Turns what just happened into a line of text in the textbox.

local actions = require("src.data.actions")

local FeedbackSystem = { name = "feedback" }

local function say(scene, text)
    local _, textbox = scene.registry:first("textbox")
    textbox.text = text
    textbox.visibleChars = 0
end

function FeedbackSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")

    for _, done in registry:each("actionPerformed") do
        local pool = actions[done.id].lines
        local text = ("%s  [+%d %s]"):format(
            pool[love.math.random(#pool)], done.gain, done.stat:upper())
        if runState.actionsLeft == 0 then
            text = text .. "\nThe day is over. Heading to the briefing room..."
        end
        say(scene, text)
    end

    for _ in registry:each("actionRefused") do
        say(scene, "No time slots left today.")
    end
end

return FeedbackSystem
