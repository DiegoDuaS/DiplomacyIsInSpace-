-- The HUD's displayed values chase the real negotiation state, so the bars slide.

local HudSystem = { name = "hud" }

local SLIDE_SPEED = 6   -- how fast a bar chases its value (1/sec)
local DELTA_TIME = 1.1  -- seconds a floating "+3" stays on screen

function HudSystem.setup(scene)
    local neg = scene.registry:resource("negotiation")
    scene.registry:spawn({
        position = { x = 12, y = 10 },
        size = { w = 616, h = 74 },
        hud = {
            shown = { patience = neg.patience, hostility = neg.hostility },
            delta = {}, -- meter -> { amount, timer } while a change is fading
        },
    })
end

function HudSystem.update(scene, dt)
    local registry = scene.registry
    local neg = registry:resource("negotiation")

    for _, hud in registry:each("hud") do
        for _, change in registry:each("negotiationChanged") do
            for _, meter in ipairs({ "patience", "hostility" }) do
                if change[meter] ~= 0 then
                    hud.delta[meter] = { amount = change[meter], timer = DELTA_TIME }
                end
            end
        end

        for _, meter in ipairs({ "patience", "hostility" }) do
            local target = neg[meter]
            hud.shown[meter] = hud.shown[meter]
                + (target - hud.shown[meter]) * math.min(1, SLIDE_SPEED * dt)

            local delta = hud.delta[meter]
            if delta then
                delta.timer = delta.timer - dt
                if delta.timer <= 0 then hud.delta[meter] = nil end
            end
        end
    end
end

return HudSystem
