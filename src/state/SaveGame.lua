-- Saves the run to disk and loads it back. The file is the RunState wrapped with a version;
-- loading never trusts it: every field is checked and copied into a fresh table, so a damaged
-- or edited file gives "no save" instead of a crash.
--
-- Storage is injected ({ read, write, exists, remove }) so this runs without LÖVE;
-- SaveGame.disk() is the real one, on love.filesystem.

local Serializer = require("src.state.Serializer")
local kinds = require("src.data.card_kinds")
local progression = require("src.data.progression_rules")
local campaign = require("src.data.campaign")
local aliens = require("src.data.aliens")

local SaveGame = {}

SaveGame.VERSION = 1
SaveGame.PATH = "save.json"

local MAX_CARDS = 2000

local function isAlien(id) -- a delegation id, not any key of the aliens table
    return type(id) == "string" and type(aliens[id]) == "table" and aliens[id].id == id
end

local function isCount(n, min)
    return type(n) == "number" and n == math.floor(n) and n >= min
end

local function checkCard(card, index)
    if type(card) ~= "table" then return nil, "card " .. index .. " is not a table" end
    if not kinds[card.kind] or kinds[card.kind].effect == nil then return nil, "card " .. index .. " has no valid kind" end
    if type(card.name) ~= "string" or card.name == "" then return nil, "card " .. index .. " has no name" end
    if not isCount(card.power, 1) then return nil, "card " .. index .. " has a bad power" end
    if card.day ~= nil and not isCount(card.day, 1) then return nil, "card " .. index .. " has a bad day" end

    local clean = { kind = card.kind, name = card.name, power = card.power, day = card.day }
    if card.risky == true then clean.risky = true end
    return clean
end

-- The saved table -> a clean RunState, or nil and why not.
local function check(saved)
    if type(saved) ~= "table" then return nil, "the save is not a table" end
    if saved.version ~= SaveGame.VERSION then
        return nil, "save version " .. tostring(saved.version) .. " is not " .. SaveGame.VERSION
    end
    local run = saved.runState
    if type(run) ~= "table" then return nil, "the save has no run" end

    if not isCount(run.day, 1) then return nil, "bad day" end
    if not (isCount(run.actionsLeft, 0) and run.actionsLeft <= progression.actionsPerDay) then
        return nil, "bad time slots"
    end
    if not isCount(run.packSeed, 1) then return nil, "bad pack seed" end
    if type(run.stats) ~= "table" then return nil, "no skills" end
    if type(run.collection) ~= "table" or #run.collection > MAX_CARDS then return nil, "bad collection" end

    local clean = { day = run.day, actionsLeft = run.actionsLeft, packSeed = run.packSeed,
        stats = {}, collection = {}, history = {} }

    -- how each finished day ended (a save from before the campaign has none)
    local history = run.history or {}
    if type(history) ~= "table" or #history > campaign.days then return nil, "bad history" end
    for i, entry in ipairs(history) do
        if type(entry) ~= "table" or not isCount(entry.day, 1) or not isAlien(entry.alien)
            or not campaign.outcomes[entry.outcome] then
            return nil, "bad history entry " .. i
        end
        clean.history[i] = { day = entry.day, alien = entry.alien, outcome = entry.outcome }
    end
    for _, kind in ipairs(kinds.order) do
        if not isCount(run.stats[kind], 0) then return nil, "bad " .. kind .. " skill" end
        clean.stats[kind] = run.stats[kind]
    end
    for i, card in ipairs(run.collection) do
        local ok, why = checkCard(card, i)
        if not ok then return nil, why end
        clean.collection[i] = ok
    end
    return clean
end

function SaveGame.encode(runState)
    return Serializer.encode({ version = SaveGame.VERSION, runState = runState })
end

function SaveGame.decode(text)
    local saved, why = Serializer.decode(text)
    if saved == nil then return nil, why end
    return check(saved)
end

-- Writes the run. The text is decoded again before touching the disk, so a bad write never
-- replaces a good save. Returns true, or false and why.
function SaveGame.save(runState, storage)
    local ok, text = pcall(SaveGame.encode, runState)
    if not ok then return false, text end
    local back, why = SaveGame.decode(text)
    if not back then return false, "refusing to save: " .. why end
    return storage.write(SaveGame.PATH, text)
end

-- The saved run, or nil and why (a missing file is just "no save").
function SaveGame.load(storage)
    if not storage.exists(SaveGame.PATH) then return nil, "no save" end
    local text, why = storage.read(SaveGame.PATH)
    if not text then return nil, why end
    return SaveGame.decode(text)
end

function SaveGame.erase(storage)
    if storage.exists(SaveGame.PATH) then storage.remove(SaveGame.PATH) end
end

-- The real storage: the game's save folder (love.filesystem; see t.identity in conf.lua).
function SaveGame.disk()
    local fs = love.filesystem
    return {
        exists = function(path) return fs.getInfo(path) ~= nil end,
        read = function(path) return fs.read(path) end,
        write = function(path, text) return fs.write(path, text) end,
        remove = function(path) return fs.remove(path) end,
    }
end

return SaveGame
