-- Proves the tile collision rules without opening LÖVE:  lua tests/collision.lua
package.path = "./?.lua;" .. package.path

local TileGrid = require("src.world.TileGrid")
local Collision = require("src.world.Collision")

local CELL = 32
local HALF = 10

-- 6x4 world with one wall column at x = 4 (pixels 96..128)
local grid = TileGrid.new(6, 4)
for y = 1, 4 do grid:set(4, y, "asteroid") end

-- open space is not blocked; a box inside the wall is
assert(not Collision.blocked(grid, CELL, 48, 64, HALF, HALF), "open space blocked")
assert(Collision.blocked(grid, CELL, 112, 64, HALF, HALF), "wall not blocking")

-- a box that only touches the wall's face is not inside it
assert(not Collision.blocked(grid, CELL, 96 - HALF, 64, HALF, HALF), "touching counts as inside")
assert(Collision.blocked(grid, CELL, 96 - HALF + 1, 64, HALF, HALF), "one pixel in must block")

-- moving straight into the wall is refused
local x, y = Collision.resolve(grid, CELL, 80, 64, 100, 64, HALF, HALF)
assert(x == 80 and y == 64, "head-on move must be refused")

-- moving diagonally into the wall slides: x refused, y kept
x, y = Collision.resolve(grid, CELL, 80, 64, 100, 80, HALF, HALF)
assert(x == 80 and y == 80, ("expected to slide along the wall, got %g,%g"):format(x, y))

-- free movement goes through untouched
x, y = Collision.resolve(grid, CELL, 40, 40, 44, 46, HALF, HALF)
assert(x == 44 and y == 46, "free move was altered")

print("collision ok")
