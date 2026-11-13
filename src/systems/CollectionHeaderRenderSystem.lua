-- Top bar of the collection screen (title, pack banner, card count) and the key help at the bottom.

local Screen = require("src.Screen")
local palette = require("src.data.palette")
local Panel = require("src.graphics.Panel")

local CollectionHeaderRenderSystem = { name = "collectionHeaderRender" }

local titleFont, smallFont

function CollectionHeaderRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(18, "mono")
    smallFont = love.graphics.newFont(11, "mono")
end

function CollectionHeaderRenderSystem.unload(scene)
    titleFont, smallFont = nil, nil
end

function CollectionHeaderRenderSystem.draw(scene)
    local registry = scene.registry
    local pack = registry:resource("pack")
    local total = #registry:resource("runState").collection

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
    love.graphics.printf(("%d CARDS"):format(total), Screen.w - 140, 22, 112, "right")

    love.graphics.setColor(palette.grey)
    local help = "UP/DOWN browse   LEFT/RIGHT close/open folder   "
        .. (pack.acquiring and "ENTER fly to the delegation" or "ENTER back to the station")
    love.graphics.printf(help, 0, Screen.h - 22, Screen.w, "center")
    love.graphics.setColor(1, 1, 1)
end

return CollectionHeaderRenderSystem
