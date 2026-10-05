-- Typewriter: reveals a textbox's text over time.
-- To restart it, set `text` and reset `visibleChars` to 0.

local TextboxSystem = { name = "textbox" }

function TextboxSystem.update(scene, dt)
    for _, textbox in scene.registry:each("textbox") do
        textbox.visibleChars = math.min(
            textbox.visibleChars + textbox.speed * dt,
            #textbox.text)
    end
end

return TextboxSystem
