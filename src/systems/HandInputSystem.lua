-- Hand cursor and card picks: keys become a `cardPlayRequested` event.

local HandInputSystem = { name = "handInput" }

function HandInputSystem.update(scene, dt)
    local registry = scene.registry
    if registry:resource("negotiation").outcome then return end

    for _, event in registry:each("keyPressed") do
        for _, hand in registry:each("hand") do
            if event.key == "left" or event.key == "a" then
                -- -2/+1 instead of -1: Lua arrays are 1-based, % is 0-based
                hand.cursor = (hand.cursor - 2) % #hand.cards + 1
            elseif event.key == "right" or event.key == "d" then
                hand.cursor = hand.cursor % #hand.cards + 1
            elseif event.key == "return" or event.key == "space" then
                registry:spawn({
                    event = true,
                    cardPlayRequested = { slot = hand.cursor },
                })
            end
        end
    end
end

return HandInputSystem
