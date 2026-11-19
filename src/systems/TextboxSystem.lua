-- Typewriter: reveals a textbox's text over time.
-- To restart it, set `text` and reset `visibleChars` to 0.

local TextboxSystem = { name = "textbox" }

function TextboxSystem.update(scene, dt)
    for _, box in scene.registry:each("textbox") do
        box.visibleChars = math.min(#box.text, box.visibleChars + box.speed * dt)
    end
end

return TextboxSystem
