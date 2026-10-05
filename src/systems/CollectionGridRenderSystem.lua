-- Lays out a page of cards and marks the cursor and the new pack.

local palette = require("src.data.palette")
local CardRenderer = require("src.cards.CardRenderer")

local CollectionGridRenderSystem = { name = "collectionGridRender" }

local GAP_X, GAP_Y = 12, 14
local GRID_X, GRID_Y = 264, 60

local font

function CollectionGridRenderSystem.setup(scene)
    font = love.graphics.newFont(10, "mono")
end

function CollectionGridRenderSystem.unload(scene)
    font = nil
end

function CollectionGridRenderSystem.draw(scene)
    local registry = scene.registry
    local collection = registry:resource("runState").collection
    local view = registry:resource("collectionView")
    local pack = registry:resource("pack")
    local first = (view.page - 1) * view.pageSize + 1
    local last = math.min(first + view.pageSize - 1, #collection)

    for index = first, last do
        local slot = index - first
        local x = GRID_X + (slot % view.columns) * (CardRenderer.W + GAP_X)
        local y = GRID_Y + math.floor(slot / view.columns) * (CardRenderer.H + GAP_Y)

        CardRenderer.draw(collection[index], x, y)

        if pack.first and index >= pack.first and index <= pack.last then
            love.graphics.setColor(palette.amber)
            love.graphics.rectangle("fill", x + CardRenderer.W - 34, y - 6, 34, 14, 3, 3)
            love.graphics.setColor(palette.ink)
            love.graphics.setFont(font)
            love.graphics.printf("NEW", x + CardRenderer.W - 34, y - 3, 34, "center")
        end

        if index == view.selected then
            love.graphics.setColor(palette.amber)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", x - 3, y - 3,
                CardRenderer.W + 6, CardRenderer.H + 6, 5, 5)
            love.graphics.setLineWidth(1)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return CollectionGridRenderSystem
