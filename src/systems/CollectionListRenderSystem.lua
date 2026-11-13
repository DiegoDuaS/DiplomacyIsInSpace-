-- Draws the collection as a file browser: folders per card kind, one file row per card.

local palette = require("src.data.palette")
local kinds = require("src.data.card_kinds")
local Panel = require("src.graphics.Panel")
local CardEffect = require("src.cards.CardEffect")

local CollectionListRenderSystem = { name = "collectionListRender" }

local PANEL_X, PANEL_Y, PANEL_W, PANEL_H = 12, 56, 616, 204
local ROW_H, ROWS_Y = 18, 64

local font, boldFont

function CollectionListRenderSystem.setup(scene)
    font = love.graphics.newFont(11, "mono")
    boldFont = love.graphics.newFont(12, "mono")
end

function CollectionListRenderSystem.unload(scene)
    font, boldFont = nil, nil
end

local function drawFolderIcon(x, y, color, open)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y + 1, 7, 3) -- the tab
    if open then
        love.graphics.rectangle("line", x + 0.5, y + 3.5, 15, 9)
    else
        love.graphics.rectangle("fill", x, y + 3, 16, 10)
    end
end

local function drawFileIcon(x, y, color)
    love.graphics.setColor(color)
    love.graphics.polygon("line", x + 0.5, y + 0.5, x + 7.5, y + 0.5, x + 10.5, y + 3.5,
        x + 10.5, y + 13.5, x + 0.5, y + 13.5)
end

local function drawArrow(x, y, open, color)
    love.graphics.setColor(color)
    if open then
        love.graphics.polygon("fill", x, y + 4, x + 8, y + 4, x + 4, y + 9)
    else
        love.graphics.polygon("fill", x + 1, y + 1, x + 1, y + 11, x + 7, y + 6)
    end
end

local function effectText(card)
    local parts = {}
    for _, line in ipairs(CardEffect.lines(card)) do
        parts[#parts + 1] = line.text
    end
    return table.concat(parts, "  ")
end

local function drawFolderRow(row, y, view)
    local kind = kinds[row.folder]
    local open = view.open[row.folder]

    drawArrow(24, y + 3, open, palette.grey)
    drawFolderIcon(40, y + 1, palette[kind.color], open)
    love.graphics.setFont(boldFont)
    love.graphics.setColor(palette.cream)
    love.graphics.print(kind.label, 64, y + 2)
    love.graphics.setFont(font)
    love.graphics.setColor(palette.grey)
    love.graphics.print(row.count == 0 and "empty" or ("%d card%s"):format(row.count, row.count == 1 and "" or "s"),
        136, y + 3)
end

local function drawFileRow(row, y, collection, pack)
    local card = collection[row.card]

    drawFileIcon(58, y + 1, palette.silver)
    love.graphics.setFont(font)
    love.graphics.setColor(palette.cream)
    love.graphics.print(card.name, 78, y + 3)

    love.graphics.setColor(palette.white)
    love.graphics.print(("POWER %d"):format(card.power), 250, y + 3)

    love.graphics.setColor(palette.silver)
    love.graphics.print(effectText(card), 340, y + 3)

    if pack.first and row.card >= pack.first and row.card <= pack.last then
        love.graphics.setColor(palette.amber)
        love.graphics.rectangle("fill", 578, y + 2, 34, 14, 3, 3)
        love.graphics.setColor(palette.ink)
        love.graphics.printf("NEW", 578, y + 3, 34, "center")
    end
end

function CollectionListRenderSystem.draw(scene)
    local registry = scene.registry
    local view = registry:resource("collectionView")
    local pack = registry:resource("pack")
    local collection = registry:resource("runState").collection

    Panel.draw(PANEL_X, PANEL_Y, PANEL_W, PANEL_H)

    for slot = 0, view.visible - 1 do
        local row = view.rows[view.top + slot]
        if not row then break end
        local y = ROWS_Y + slot * ROW_H

        if view.top + slot == view.cursor then
            love.graphics.setColor(palette.dusk)
            love.graphics.rectangle("fill", PANEL_X + 6, y, PANEL_W - 12, ROW_H - 1)
            love.graphics.setColor(palette.amber)
            love.graphics.rectangle("fill", PANEL_X + 6, y, 3, ROW_H - 1)
        end

        if row.folder then
            drawFolderRow(row, y, view)
        else
            drawFileRow(row, y, collection, pack)
        end
    end

    if #collection == 0 then
        love.graphics.setFont(font)
        love.graphics.setColor(palette.grey)
        love.graphics.printf("No cards yet. Spend your day at the station and finish it to receive your first pack.",
            PANEL_X + 40, ROWS_Y + 110, PANEL_W - 80, "center")
    end

    -- more rows above / below the window
    love.graphics.setColor(palette.grey)
    if view.top > 1 then
        love.graphics.polygon("fill", 616, ROWS_Y + 8, 622, ROWS_Y + 8, 619, ROWS_Y + 3)
    end
    if view.top + view.visible - 1 < #view.rows then
        local bottom = ROWS_Y + view.visible * ROW_H - 4
        love.graphics.polygon("fill", 616, bottom - 5, 622, bottom - 5, 619, bottom)
    end
    love.graphics.setColor(1, 1, 1)
end

return CollectionListRenderSystem
