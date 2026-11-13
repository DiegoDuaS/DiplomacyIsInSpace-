-- A rectangular grid of terrain values, kept as rows. Pure: no LÖVE, no registry.
-- x grows right, y grows down, both 1-based. nil means empty; reading outside returns nil.

local TileGrid = {}
TileGrid.__index = TileGrid

function TileGrid.new(width, height)
    local self = setmetatable({ width = width, height = height }, TileGrid)
    self:clear()
    return self
end

function TileGrid:inBounds(x, y)
    return x >= 1 and y >= 1 and x <= self.width and y <= self.height
end

function TileGrid:get(x, y)
    if self:inBounds(x, y) then
        return self.rows[y][x]
    end
end

function TileGrid:set(x, y, terrain)
    if self:inBounds(x, y) then
        self.rows[y][x] = terrain
    end
end

function TileGrid:clear()
    self.rows = {}
    for y = 1, self.height do
        self.rows[y] = {}
    end
end

-- Iterates every non-empty cell as (x, y, terrain), row by row.
function TileGrid:each()
    local x, y = 0, 1
    return function()
        while y <= self.height do
            x = x + 1
            if x > self.width then
                x, y = 0, y + 1
            else
                local terrain = self.rows[y][x]
                if terrain ~= nil then
                    return x, y, terrain
                end
            end
        end
    end
end

return TileGrid
