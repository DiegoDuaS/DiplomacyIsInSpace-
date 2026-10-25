-- Opens world space: whatever draws until CameraEndSystem is shifted by the camera.

local CameraBeginSystem = { name = "cameraBegin" }

function CameraBeginSystem.draw(scene)
    local camera = scene.registry:resource("camera")
    love.graphics.push()
    -- whole pixels only, or the tiles shimmer while the camera moves
    love.graphics.translate(-math.floor(camera.x), -math.floor(camera.y))
end

return CameraBeginSystem
