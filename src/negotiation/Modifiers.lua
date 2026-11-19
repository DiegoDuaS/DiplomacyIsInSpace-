-- What makes each court different. A delegation's `rule` (src/data/aliens.lua) picks a handler by
-- id; the handler bends the round without the rest of the game knowing which court it is.
-- Pure: no LÖVE, no registry. State lives in a plain table made by start().
--
--   start(rule)                   -> state for one negotiation
--   powerBonus(rule, state, card) -> points added to the played card's power
--   drain(rule, state, base)      -> patience lost at the end of this round
--   advance(rule, state, card)    -> called once the round is over
--   describe(rule, state)         -> { frame, headline, lines } for the HUD

local Modifiers = {}

local handlers = {}

-- Kelari: the tide flips every `period` rounds. High tide barely wears patience, low tide doubles it.
handlers.tides = {
    start = function() return { step = 0 } end,
    phase = function(rule, state)
        return math.floor(state.step / rule.period) % 2 == 0 and "high" or "low"
    end,
    drain = function(rule, state)
        return rule.drain[handlers.tides.phase(rule, state)]
    end,
    advance = function(rule, state) state.step = state.step + 1 end,
    describe = function(rule, state)
        local phase = handlers.tides.phase(rule, state)
        local left = rule.period - state.step % rule.period
        return {
            frame = phase == "high" and 1 or 2,
            headline = phase == "high" and "HIGH TIDE" or "LOW TIDE",
            bad = phase == "low",
            lines = {
                ("Patience drain this round: %d"):format(rule.drain[phase]),
                ("The tide turns in %d round%s"):format(left, left == 1 and "" or "s"),
            },
        }
    end,
}

-- Vorn: they respect strength. Some kinds hit harder against them, others softer.
handlers.blades = {
    powerBonus = function(rule, state, card) return rule.bonus[card.kind] or 0 end,
    describe = function(rule)
        local lines = {}
        for _, kind in ipairs({ "tact", "logic", "resolve" }) do
            local bonus = rule.bonus[kind]
            if bonus then lines[#lines + 1] = ("%s %+d power"):format(kind:upper(), bonus) end
        end
        return { frame = 3, headline = "FORCE IS RESPECTED", lines = lines }
    end,
}

-- Ixili: the Assembly hates repetition. A different kind than last round is a bonus, the same kind a penalty.
handlers.assembly = {
    start = function() return { last = nil } end,
    powerBonus = function(rule, state, card)
        if state.last == nil then return 0 end
        return card.kind == state.last and rule.repeated or rule.fresh
    end,
    advance = function(rule, state, card) state.last = card.kind end,
    describe = function(rule, state)
        return {
            frame = 4,
            headline = "VARIETY WINS",
            lines = {
                ("A new kind: %+d power"):format(rule.fresh),
                ("The same kind: %+d power"):format(rule.repeated),
                state.last and ("Last played: " .. state.last:upper()) or "Nothing played yet",
            },
        }
    end,
}

local function handler(rule)
    return rule and handlers[rule.id]
end

function Modifiers.start(rule)
    local h = handler(rule)
    return h and h.start and h.start(rule) or {}
end

function Modifiers.powerBonus(rule, state, card)
    local h = handler(rule)
    return h and h.powerBonus and h.powerBonus(rule, state, card) or 0
end

function Modifiers.drain(rule, state, base)
    local h = handler(rule)
    return h and h.drain and h.drain(rule, state, base) or base
end

function Modifiers.advance(rule, state, card)
    local h = handler(rule)
    if h and h.advance then h.advance(rule, state, card) end
end

function Modifiers.describe(rule, state)
    local h = handler(rule)
    local info = h and h.describe and h.describe(rule, state)
    info = info or { frame = 1, headline = "", lines = {} }
    info.title = rule and rule.label or ""
    return info
end

return Modifiers
