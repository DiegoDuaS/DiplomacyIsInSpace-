-- A scene's backdrop: a 640x400 sprite, or the plain starfield until that picture exists.
--
--   BackgroundRenderSystem.new(function(scene) return spriteName, frame end)  -> a system
--
-- The function runs every frame, so the backdrop can depend on the scene's state (the court
-- of the delegation, the ending reached...).

local Sprites = require("src.graphics.Sprites")
local StarfieldRenderSystem = require("src.systems.StarfieldRenderSystem")

local BackgroundRenderSystem = {}

function BackgroundRenderSystem.new(which)
    return {
        name = "background",
        setup = StarfieldRenderSystem.setup, -- the fallback needs its stars
        draw = function(scene)
            local name, frame = which(scene)
            if not (name and Sprites.draw(name, frame or 1, 0, 0)) then
                StarfieldRenderSystem.draw(scene)
            end
        end,
    }
end

return BackgroundRenderSystem
