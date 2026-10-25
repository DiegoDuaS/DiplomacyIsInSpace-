-- Tile collision as pure functions. An empty cell (nil) is open space and any terrain is solid;
-- a mover is a box given by its center and half sizes.

local Collision = {}

-- Is the box touching any solid cell? Touching a wall's face does not count.
function Collision.blocked(grid, cell, x, y, hw, hh)
    local left = math.floor((x - hw) / cell) + 1
    local right = math.ceil((x + hw) / cell)
    local top = math.floor((y - hh) / cell) + 1
    local bottom = math.ceil((y + hh) / cell)

    for cy = top, bottom do
        for cx = left, right do
            if grid:get(cx, cy) ~= nil then return true end
        end
    end
    return false
end

-- Move toward (x, y) one axis at a time, so movers slide along walls.
function Collision.resolve(grid, cell, prevX, prevY, x, y, hw, hh)
    local nx, ny = prevX, prevY
    if not Collision.blocked(grid, cell, x, prevY, hw, hh) then nx = x end
    if not Collision.blocked(grid, cell, nx, y, hw, hh) then ny = y end
    return nx, ny
end

return Collision
