-- The Concord System: fly the shuttle between the station and each delegation's world.
-- The world is bigger than the screen; the camera follows the ship.
-- Enter from the card scene or with `love . map`; leave by entering the court of today's planet.

local Scene = require("src.ecs.Scene")
local RunState = require("src.state.RunState")
local aliens = require("src.data.aliens")
local MapData = require("src.data.map")

local MapInputSystem = require("src.systems.MapInputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local TileCollisionSystem = require("src.systems.TileCollisionSystem")
local MapBoundsSystem = require("src.systems.MapBoundsSystem")
local ShipFacingSystem = require("src.systems.ShipFacingSystem")
local CameraSystem = require("src.systems.CameraSystem")
local ProximitySystem = require("src.systems.ProximitySystem")
local CourtEntrySystem = require("src.systems.CourtEntrySystem")
local StarfieldRenderSystem = require("src.systems.StarfieldRenderSystem")
local CameraBeginSystem = require("src.systems.CameraBeginSystem")
local TilemapRenderSystem = require("src.systems.TilemapRenderSystem")
local PoiRenderSystem = require("src.systems.PoiRenderSystem")
local ShipRenderSystem = require("src.systems.ShipRenderSystem")
local CameraEndSystem = require("src.systems.CameraEndSystem")
local MapHudRenderSystem = require("src.systems.MapHudRenderSystem")
local MinimapRenderSystem = require("src.systems.MinimapRenderSystem")

local CELL = MapData.CELL

return function(payload)
    local scene = Scene.new("map")
    local grid = MapData.build()

    scene.registry:setResource("runState", RunState.get())
    scene.registry:setResource("map", {
        speed = 170, normalize = true, nearby = nil,
        bounds = { w = grid.width * CELL, h = grid.height * CELL },
    })

    scene.registry:setResource("camera", { x = 0, y = 0 })

    -- one tilemap entity, not one entity per cell
    scene.registry:spawn({ tilemap = { grid = grid, cell = CELL, pois = MapData.pois } })

    for _, data in ipairs(MapData.pois) do
        local alien = data.alien and aliens[data.alien]
        scene.registry:spawn({
            position = { x = (data.col - 1 + data.w / 2) * CELL, y = (data.row - 1 + data.h / 2) * CELL },
            poi = {
                id = data.id,
                kind = data.kind,
                alien = data.alien,
                name = alien and alien.planet:upper() or data.name,
                subtitle = alien and (alien.name .. " - " .. alien.court) or nil,
                half = data.h * CELL / 2,
                range = data.range * CELL,
            },
        })
    end

    scene.registry:spawn({
        position = { x = MapData.start.col * CELL, y = MapData.start.row * CELL },
        moveIntent = { dx = 0, dy = 0 },
        velocity = { x = 0, y = 0 },
        collider = { hw = 7, hh = 7 },
        ship = { turns = 0, thrusting = false },
    })

    scene:addSystem(MapInputSystem)
    scene:addSystem(MovementSystem)
    scene:addSystem(TileCollisionSystem)
    scene:addSystem(MapBoundsSystem)
    scene:addSystem(ShipFacingSystem)
    scene:addSystem(CameraSystem)
    scene:addSystem(ProximitySystem)
    scene:addSystem(CourtEntrySystem)
    scene:addSystem(StarfieldRenderSystem)
    scene:addSystem(CameraBeginSystem)
    scene:addSystem(TilemapRenderSystem)
    scene:addSystem(PoiRenderSystem)
    scene:addSystem(ShipRenderSystem)
    scene:addSystem(CameraEndSystem)
    scene:addSystem(MapHudRenderSystem)
    scene:addSystem(MinimapRenderSystem)

    return scene
end
