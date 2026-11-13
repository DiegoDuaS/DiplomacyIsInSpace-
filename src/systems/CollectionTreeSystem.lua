-- Owns the collection as a folder tree: one folder per card kind, one file per card.
-- Builds the visible rows, moves the cursor, folds folders, scrolls, and jumps to a new pack.

local kinds = require("src.data.card_kinds")

local CollectionTreeSystem = { name = "collectionTree" }

local function clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

-- Rows top to bottom: a folder, then (if open) its cards sorted by name.
-- A row is { folder = kind, count = n } or { card = index into the collection }.
local function buildRows(collection, open)
    local rows = {}
    for _, kind in ipairs(kinds.order) do
        local members = {}
        for index, card in ipairs(collection) do
            if card.kind == kind then members[#members + 1] = index end
        end
        table.sort(members, function(a, b)
            local nameA, nameB = collection[a].name, collection[b].name
            if nameA ~= nameB then return nameA < nameB end
            return a < b
        end)

        rows[#rows + 1] = { folder = kind, count = #members }
        if open[kind] then
            for _, index in ipairs(members) do
                rows[#rows + 1] = { card = index }
            end
        end
    end
    return rows
end

local function rowOf(rows, selection)
    for i, row in ipairs(rows) do
        if selection.card and row.card == selection.card then return i end
        if selection.folder and row.folder == selection.folder then return i end
    end
end

local function select(view, row)
    view.selection = row.card and { card = row.card } or { folder = row.folder }
end

-- The scene draws once before its first update, so the rows must exist already.
function CollectionTreeSystem.setup(scene)
    local view = scene.registry:resource("collectionView")
    view.rows = buildRows(scene.registry:resource("runState").collection, view.open)
    view.cursor = 1
end

function CollectionTreeSystem.update(scene, dt)
    local registry = scene.registry
    local view = registry:resource("collectionView")
    local collection = registry:resource("runState").collection

    -- a new pack: open the folder of its first card and select it
    for _, pack in registry:each("packGenerated") do
        local card = collection[pack.first]
        view.open[card.kind] = true
        view.selection = { card = pack.first }
    end

    -- folding applies to the folder that holds the selection
    for _, request in registry:each("collectionFoldRequested") do
        local sel = view.selection
        local kind = sel.folder or collection[sel.card].kind
        view.open[kind] = request.open
        view.selection = { folder = kind }
    end

    local rows = buildRows(collection, view.open)
    local cursor = rowOf(rows, view.selection) or 1

    for _, request in registry:each("collectionMoveRequested") do
        cursor = clamp(cursor + request.step, 1, #rows)
    end
    for _, request in registry:each("collectionJumpRequested") do
        cursor = request.edge == "first" and 1 or #rows
    end
    select(view, rows[cursor])

    -- keep the cursor inside the visible window
    view.top = clamp(view.top, cursor - view.visible + 1, cursor)
    view.top = clamp(view.top, 1, math.max(1, #rows - view.visible + 1))
    view.rows, view.cursor = rows, cursor
end

return CollectionTreeSystem
