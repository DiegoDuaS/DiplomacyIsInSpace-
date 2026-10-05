-- The shared state must be plain data:  lua tests/run_state.lua
package.path = "./?.lua;" .. package.path

local RunState = require("src.state.RunState")

local PLAIN = { number = true, string = true, boolean = true, table = true }

-- Walks the whole table; anything that is not plain data (function, userdata,
-- a LÖVE image...) fails, and so does a table that contains itself.
local function assertPlain(value, path, seen)
    assert(PLAIN[type(value)], path .. " is a " .. type(value) .. ", not plain data")
    if type(value) == "table" then
        assert(not seen[value], path .. " is a cycle")
        seen[value] = true
        for key, inner in pairs(value) do
            assert(type(key) == "string" or type(key) == "number", path .. " has a bad key")
            assertPlain(inner, path .. "." .. tostring(key), seen)
        end
        seen[value] = nil
    end
end

-- A fresh run is plain data.
assertPlain(RunState.new(), "runState", {})

-- get() hands every scene the SAME table, so changes survive a scene switch.
local run = RunState.reset()
assert(RunState.get() == run, "get() must return the run in progress")
run.day = 3
run.collection[#run.collection + 1] = { kind = "tact", name = "Warm Greeting", power = 2 }
assert(RunState.get().day == 3 and #RunState.get().collection == 1, "state was lost")
assertPlain(run, "runState", {})

-- reset() starts a new run.
local fresh = RunState.reset()
assert(fresh ~= run and fresh.day == 1 and #fresh.collection == 0, "reset() must start over")

print("run_state ok")
