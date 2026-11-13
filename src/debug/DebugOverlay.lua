-- Debug overlay (`love . --debug`): inspect and edit the registry, switch scenes, pause and
-- step, switch systems off. It draws over the game and uses keys the game never uses,
-- so you can keep playing while you watch the state change.
--
--   F1 show/hide        F2/F3 previous/next scene   F9 pause     F10 one frame
--   F4/F5 entity        F6/F7 component             PgUp/PgDn field
--   - / =  edit the field (numbers +-1, booleans toggle; hold shift for x10)
--   ;  next system      '  switch that system on/off

local Game = require("src.Game")
local Screen = require("src.Screen")

local DebugOverlay = {}

local PANEL_W = 260
local MAX_DEPTH = 3

local visible, paused, stepOnce = false, false, false
local entityIndex, componentIndex, fieldIndex, systemIndex = 1, 1, 1, 1
local watchedScene = nil
local font

local function clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

-- Fields of a component as a flat list, sorted so the rows don't reshuffle every frame.
local function collectFields(container, depth, indent, out)
    local keys = {}
    for key in pairs(container) do keys[#keys + 1] = key end
    table.sort(keys, function(a, b)
        if type(a) == type(b) then return a < b end
        return type(a) == "number"
    end)

    for _, key in ipairs(keys) do
        local value = container[key]
        out[#out + 1] = { container = container, key = key, indent = indent }
        if type(value) == "table" and depth < MAX_DEPTH then
            collectFields(value, depth + 1, indent .. "  ", out)
        end
    end
end

-- The current selection, recomputed every frame from the live registry.
local function inspect(scene)
    local registry = scene.registry
    local entities = registry:entities()
    entityIndex = clamp(entityIndex, 1, math.max(1, #entities))
    local entity = entities[entityIndex]

    local names = entity and registry:componentsOf(entity) or {}
    componentIndex = clamp(componentIndex, 1, math.max(1, #names))
    local name = names[componentIndex]

    local fields, root = {}, nil
    if name then
        local data = registry:get(entity, name)
        if type(data) == "table" then
            collectFields(data, 1, "", fields)
        else
            root = { registry = registry, entity = entity, name = name, value = data }
            fields[1] = { root = root, key = name, indent = "" }
        end
    end
    fieldIndex = clamp(fieldIndex, 1, math.max(1, #fields))

    systemIndex = clamp(systemIndex, 1, math.max(1, #scene.systems))
    return { entities = entities, entity = entity, names = names, name = name, fields = fields }
end

local function fieldValue(field)
    if field.root then return field.root.value end
    return field.container[field.key]
end

local function writeField(field, value)
    if field.root then
        field.root.registry:add(field.root.entity, field.root.name, value)
        field.root.value = value
    else
        field.container[field.key] = value
    end
end

local function editField(field, direction)
    if not field then return end
    local value = fieldValue(field)
    if type(value) == "boolean" then
        writeField(field, not value)
    elseif type(value) == "number" then
        local step = (value % 1 ~= 0 and math.abs(value) < 10) and 0.1 or 1
        if love.keyboard.isDown("lshift", "rshift") then step = step * 10 end
        writeField(field, value + direction * step)
    end
end

local function switchScene(offset)
    local names = Game.sceneNames()
    local current = Game.current().name
    local index = 1
    for i, name in ipairs(names) do
        if name == current then index = i end
    end
    Game.start(names[(index - 1 + offset) % #names + 1])
end

-- Returns true when the overlay used the key, so the game doesn't see it.
local function handleKey(key)
    if key == "f1" then visible = not visible; return true end
    if key == "f9" then paused = not paused; return true end
    if key == "f10" then paused, stepOnce = true, true; return true end
    if not visible then return false end

    local scene = Game.current()
    local view = inspect(scene)
    if key == "f2" then switchScene(-1)
    elseif key == "f3" then switchScene(1)
    elseif key == "f4" then entityIndex, componentIndex, fieldIndex = entityIndex - 1, 1, 1
    elseif key == "f5" then entityIndex, componentIndex, fieldIndex = entityIndex + 1, 1, 1
    elseif key == "f6" then componentIndex, fieldIndex = componentIndex - 1, 1
    elseif key == "f7" then componentIndex, fieldIndex = componentIndex + 1, 1
    elseif key == "pageup" then fieldIndex = fieldIndex - 1
    elseif key == "pagedown" then fieldIndex = fieldIndex + 1
    elseif key == "-" then editField(view.fields[fieldIndex], -1)
    elseif key == "=" then editField(view.fields[fieldIndex], 1)
    elseif key == ";" then systemIndex = systemIndex % math.max(1, #scene.systems) + 1
    elseif key == "'" then
        local system = scene.systems[systemIndex]
        if system then scene.disabledSystems[system] = not scene.disabledSystems[system] or nil end
    else
        return false
    end
    return true
end

local function drawPanel(scene)
    font = font or love.graphics.newFont(10, "mono")
    love.graphics.setFont(font)
    local x, lineHeight = Screen.w - PANEL_W, 12
    local view = inspect(scene)
    local lines = {}

    local function add(text, color) lines[#lines + 1] = { text = text, color = color } end

    add(("DEBUG  scene: %s  %d fps%s"):format(scene.name, love.timer.getFPS(), paused and "  PAUSED" or ""))
    add(("entity %d/%d   (F4/F5)"):format(entityIndex, #view.entities))
    add(("component: %s %d/%d   (F6/F7)"):format(view.name or "-", componentIndex, #view.names))
    add("")

    local first = clamp(fieldIndex - 8, 1, math.max(1, #view.fields - 16))
    for i = first, math.min(#view.fields, first + 16) do
        local field = view.fields[i]
        local value = fieldValue(field)
        local shown = type(value) == "table" and "" or tostring(value)
        add(("%s%s %s %s"):format(i == fieldIndex and ">" or " ", field.indent, tostring(field.key), shown),
            i == fieldIndex and { 0.93, 0.71, 0.25 } or nil)
    end

    local system = scene.systems[systemIndex]
    if system then
        add("")
        add(("system %d/%d: %s %s"):format(systemIndex, #scene.systems, system.name or "?",
            scene.disabledSystems[system] and "OFF" or "on"))
    end
    add("")
    add("F2/F3 scene  PgUp/PgDn field  -/= edit", { 0.52, 0.53, 0.56 })
    add(";/' system   F9 pause  F10 step  F1 hide", { 0.52, 0.53, 0.56 })

    love.graphics.setColor(0, 0, 0, 0.82)
    love.graphics.rectangle("fill", x, 0, PANEL_W, Screen.h)
    for i, line in ipairs(lines) do
        love.graphics.setColor(line.color or { 0.92, 0.91, 0.88 })
        love.graphics.print(line.text, x + 6, 6 + (i - 1) * lineHeight)
    end
    love.graphics.setColor(1, 1, 1)
end

function DebugOverlay.show()
    visible = true
end

-- Wraps the LÖVE callbacks main.lua defined, so the game never knows it is watched.
function DebugOverlay.install()
    local update, draw, keypressed = love.update, love.draw, love.keypressed

    love.update = function(dt)
        if paused and not stepOnce then return end
        stepOnce = false
        update(dt)
    end

    love.draw = function()
        draw()
        local scene = Game.current()
        if scene ~= watchedScene then -- new scene: start from its first entity
            watchedScene = scene
            entityIndex, componentIndex, fieldIndex, systemIndex = 1, 1, 1, 1
        end
        if visible then drawPanel(scene) end
    end

    love.keypressed = function(key, ...)
        if not handleKey(key) then keypressed(key, ...) end
    end
end

return DebugOverlay
