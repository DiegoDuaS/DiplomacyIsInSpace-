-- Proves the serializer and the save file without LÖVE:  lua tests/save.lua
package.path = "./?.lua;" .. package.path

local Serializer = require("src.state.Serializer")
local SaveGame = require("src.state.SaveGame")
local RunState = require("src.state.RunState")
local CardGenerator = require("src.generation.CardGenerator")

local function equal(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for key, value in pairs(a) do
        if not equal(value, b[key]) then return false end
    end
    for key in pairs(b) do
        if a[key] == nil then return false end
    end
    return true
end

-- An in-memory disk, so no LÖVE and no real file is touched.
local function memoryDisk()
    local files = {}
    return {
        files = files,
        exists = function(path) return files[path] ~= nil end,
        read = function(path) return files[path] end,
        write = function(path, text) files[path] = text; return true end,
        remove = function(path) files[path] = nil end,
    }
end

-- A run that has been played a bit: skills trained, packs received (some risky cards).
local function playedRun()
    local run = RunState.new()
    run.day, run.actionsLeft = 3, 1
    run.stats = { tact = 5, logic = 3, resolve = 2 }
    local seed = 7
    local function random(low, high)
        seed = (seed * 48271) % 2147483647
        local unit = seed / 2147483647
        if low == nil then return unit end
        if high == nil then return math.floor(unit * low) + 1 end
        return low + math.floor(unit * (high - low + 1))
    end
    for day = 1, 3 do
        for _, card in ipairs(CardGenerator.pack(run.stats, 30, random)) do
            card.day = day
            run.collection[#run.collection + 1] = card
        end
    end
    run.packSeed = 4
    run.history = {
        { day = 1, alien = "kelari", outcome = "peace" },
        { day = 2, alien = "vorn", outcome = "walkout" },
    }
    return run
end

-- 1. The serializer round-trips every kind of plain data.
do
    local samples = {
        42, -7, 0, 3.14159, 1e21, "plain", "", 'quotes " and \\ backslash', "line\nbreak\ttab", "ñandú ✓",
        true, false, {}, { 1, 2, 3 }, { a = 1, b = { c = { d = "deep" } } }, { { x = 1 }, { x = 2 } },
        { list = { "a", "b" }, flag = true, n = 0.5 },
    }
    for i, sample in ipairs(samples) do
        local text = Serializer.encode(sample)
        local back, why = Serializer.decode(text)
        assert(back ~= nil or sample == nil, "sample " .. i .. " failed to decode: " .. tostring(why))
        assert(equal(sample, back), "sample " .. i .. " changed on the way: " .. text)
    end
    assert(Serializer.encode({ b = 1, a = 2 }) == Serializer.encode({ a = 2, b = 1 }), "same data, same text")
end

-- 2. The serializer refuses what it cannot save, and never runs what it reads.
do
    assert(not pcall(Serializer.encode, { f = function() end }), "functions cannot be saved")
    assert(not pcall(Serializer.encode, 0 / 0), "NaN cannot be saved")
    assert(not pcall(Serializer.encode, { [1.5] = "x" }), "only string keys in an object")

    for _, bad in ipairs({ "", "{", '{"a":', '{"a" 1}', "[1,2", "[1 2]", '"open', "tru", "{} extra", "-", "{'a':1}",
        "return os.exit()", string.rep("[", 100) .. string.rep("]", 100) }) do
        local value, why = Serializer.decode(bad)
        assert(value == nil and type(why) == "string", "should have refused: " .. bad)
    end
end

-- 3. A saved run comes back exactly as it was.
do
    local disk, run = memoryDisk(), playedRun()
    assert(SaveGame.load(disk) == nil, "an empty disk has no save")
    assert(SaveGame.save(run, disk))
    local back = assert(SaveGame.load(disk))
    assert(equal(run, back), "the run changed on the way through the disk")
    assert(#back.collection == 90 and back.day == 3 and back.actionsLeft == 1)

    local risky = 0
    for _, card in ipairs(back.collection) do if card.risky then risky = risky + 1 end end
    assert(risky > 0, "the sample should include risky cards, to prove they survive")

    SaveGame.erase(disk)
    assert(SaveGame.load(disk) == nil, "erase removes the save")
end

-- 4. A damaged or edited save gives "no save", never an error.
do
    local function loadEdited(change)
        local disk, run = memoryDisk(), playedRun()
        change(run)
        disk.files[SaveGame.PATH] = Serializer.encode({ version = SaveGame.VERSION, runState = run })
        return SaveGame.load(disk)
    end
    local function refuses(name, change)
        local run, why = loadEdited(change)
        assert(run == nil and type(why) == "string", name .. " should have been refused")
    end

    refuses("day 0", function(r) r.day = 0 end)
    refuses("fractional day", function(r) r.day = 1.5 end)
    refuses("too many slots", function(r) r.actionsLeft = 99 end)
    refuses("negative skill", function(r) r.stats.tact = -1 end)
    refuses("missing skill", function(r) r.stats.logic = nil end)
    refuses("unknown card kind", function(r) r.collection[1].kind = "bribery" end)
    refuses("nameless card", function(r) r.collection[2].name = "" end)
    refuses("zero power", function(r) r.collection[3].power = 0 end)
    refuses("collection is not a list", function(r) r.collection = "lots" end)
    refuses("unknown outcome", function(r) r.history[1].outcome = "victory" end)
    refuses("unknown delegation", function(r) r.history[1].alien = "ofDay" end)
    refuses("history of the wrong shape", function(r) r.history = "long" end)
    refuses("too many days", function(r) for i = 1, 12 do r.history[i] = { day = i, alien = "kelari", outcome = "peace" } end end)

    -- extra fields are dropped, not carried into the game
    local run = assert(loadEdited(function(r) r.cheat = "infinite cards"; r.collection[1].hack = true end))
    assert(run.cheat == nil and run.collection[1].hack == nil)

    local disk = memoryDisk()
    for _, text in ipairs({ "garbage", "", "{}", '{"version": 99, "runState": {}}', '{"version": 1}' }) do
        disk.files[SaveGame.PATH] = text
        local loaded, why = SaveGame.load(disk)
        assert(loaded == nil and why, "should refuse: " .. text)
    end

    -- a run that cannot be saved must not replace a good save
    local good = playedRun()
    assert(SaveGame.save(good, disk))
    local before = disk.files[SaveGame.PATH]
    local broken = playedRun()
    broken.day = -4
    local ok = SaveGame.save(broken, disk)
    assert(not ok and disk.files[SaveGame.PATH] == before, "a bad run overwrote a good save")
end

-- 5. A fresh run saves and loads too (the very first autosave).
do
    local disk = memoryDisk()
    assert(SaveGame.save(RunState.new(), disk))
    assert(equal(RunState.new(), SaveGame.load(disk)))
end

print("save ok")
