-- Draws the frame around the collection: title, count, page, new-pack banner and key help.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")

local CollectionChromeRenderSystem = { name = "collectionChromeRender" }

local titleFont, smallFont

function CollectionChromeRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(18, "mono")
    smallFont = love.graphics.newFont(11, "mono")
end

function CollectionChromeRenderSystem.unload(scene)
    titleFont, smallFont = nil, nil
end

function CollectionChromeRenderSystem.draw(scene)
    local registry = scene.registry
    local view = registry:resource("collectionView")
    local pack = registry:resource("pack")
    local collection = registry:resource("runState").collection
    local pageCount = math.max(1, math.ceil(#collection / view.pageSize))

    Panel.draw(12, 10, Screen.w - 24, 38)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(palette.amber)
    love.graphics.print("CARD COLLECTION", 28, 19)

    love.graphics.setFont(smallFont)
    if pack.first then
        love.graphics.setColor(palette.light)
        love.graphics.printf(("NEW PACK  +%d CARDS"):format(pack.last - pack.first + 1),
            230, 22, 200, "center")
    end
    love.graphics.setColor(palette.cream)
    love.graphics.printf(("%d CARDS   PAGE %d/%d"):format(#collection, view.page, pageCount),
        Screen.w - 240, 22, 210, "right")

    love.graphics.setColor(palette.grey)
    love.graphics.printf(
        pack.acquiring and "ARROWS browse    ENTER go to the court"
            or "ARROWS browse    ENTER / BACKSPACE back to the station",
        0, Screen.h - 26, Screen.w, "center")
    love.graphics.setColor(1, 1, 1)
end

return CollectionChromeRenderSystem
