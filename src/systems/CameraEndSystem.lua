-- Closes the world space opened by CameraBeginSystem.

local CameraEndSystem = { name = "cameraEnd" }

function CameraEndSystem.draw(scene)
    love.graphics.pop()
end

return CameraEndSystem
