-- Entities are numbers; components are plain tables kept in one store per component name:
--   registry.stores.position[entity] = { x = 1, y = 2 }
-- The registry holds data only. Logic lives in systems.

local Registry = {}
Registry.__index = Registry

function Registry.new()
    return setmetatable({ nextId = 1, stores = {} }, Registry)
end

-- Create an entity from a { name = data } table and return its id.
function Registry:spawn(components)
    local entity = self.nextId
    self.nextId = entity + 1
    for name, data in pairs(components) do
        self:add(entity, name, data)
    end
    return entity
end

function Registry:add(entity, name, data)
    local store = self.stores[name]
    if not store then
        store = {}
        self.stores[name] = store
    end
    store[entity] = data
end

function Registry:get(entity, name)
    local store = self.stores[name]
    if store then return store[entity] end
end

-- Destroying an entity just removes it from every store.
function Registry:destroy(entity)
    for _, store in pairs(self.stores) do
        store[entity] = nil
    end
end

local function storesFor(registry, names)
    local list = {}
    for i, name in ipairs(names) do
        list[i] = registry.stores[name]
        if not list[i] then return nil end
    end
    return list
end

-- Sorted list of the entities that have every named component.
function Registry:query(...)
    local names = { ... }
    local list = storesFor(self, names)
    local found = {}
    if not list then return found end

    for entity in pairs(list[1]) do
        local complete = true
        for i = 2, #list do
            if list[i][entity] == nil then
                complete = false
                break
            end
        end
        if complete then found[#found + 1] = entity end
    end
    table.sort(found)
    return found
end

-- for entity, a, b in registry:each("a", "b") do ... end
-- Works on a snapshot, so spawning or destroying inside the loop is safe.
function Registry:each(...)
    local names = { ... }
    local ids = self:query(...)
    local n, position = #names, 0

    return function()
        while position < #ids do
            position = position + 1
            local entity = ids[position]
            local values, complete = {}, true
            for i = 1, n do
                values[i] = self.stores[names[i]][entity]
                if values[i] == nil then complete = false end
            end
            if complete then
                return entity, unpack(values, 1, n) -- LuaJIT: unpack, not table.unpack
            end
        end
    end
end

-- Tools only (debug overlay): every entity, and the components of one.
function Registry:entities()
    local present = {}
    for _, store in pairs(self.stores) do
        for entity in pairs(store) do present[entity] = true end
    end
    local list = {}
    for entity in pairs(present) do list[#list + 1] = entity end
    table.sort(list)
    return list
end

function Registry:componentsOf(entity)
    local names = {}
    for name, store in pairs(self.stores) do
        if store[entity] ~= nil then names[#names + 1] = name end
    end
    table.sort(names)
    return names
end

-- Resources: one-off values (run state, map settings) stored as a single-entity component.
function Registry:first(name)
    local store = self.stores[name]
    if store then
        local entity, data = next(store)
        return entity, data
    end
end

function Registry:setResource(name, value)
    local entity = self:first(name)
    if entity then
        self.stores[name][entity] = value
    else
        self:spawn({ [name] = value })
    end
end

function Registry:resource(name)
    local _, value = self:first(name)
    return value
end

return Registry
