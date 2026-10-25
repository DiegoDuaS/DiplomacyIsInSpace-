-- A rectangular grid of terrain: a width, a height and a flat array of cells. No LÖVE, no registry.
-- x grows right, y grows down, both 1-based. A cell is any terrain value (a string like "asteroid")
-- or nil for empty; reading outside the grid returns nil.

local TileGrid = {}
TileGrid.__index = TileGrid

function TileGrid.new(width, height)
    return setmetatable({
        width = width,
        height = height,
        cells = {}, -- flat [y*width + x] store; nil == empty
    }, TileGrid)
end

function TileGrid:inBounds(x, y)
    return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function TileGrid:get(x, y)
    if not self:inBounds(x, y) then
        return nil
    end
    return self.cells[(y - 1) * self.width + x]
end

function TileGrid:set(x, y, terrain)
    if not self:inBounds(x, y) then
        return
    end
    self.cells[(y - 1) * self.width + x] = terrain
end

function TileGrid:clear()
    self.cells = {}
end

-- Every (x, y, terrain) that is non-empty, in a stable row-major order.
-- Render systems use it to skip the empty air and touch only real tiles.
function TileGrid:each()
    local i = 0
    local total = self.width * self.height
    return function()
        while i < total do
            i = i + 1
            local x = (i - 1) % self.width + 1
            local y = math.floor((i - 1) / self.width) + 1
            local terrain = self.cells[i]
            if terrain ~= nil then
                return x, y, terrain
            end
        end
        return nil
    end
end

return TileGrid
