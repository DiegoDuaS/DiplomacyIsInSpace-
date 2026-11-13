-- Pure movement rules (no registry, no LÖVE), so they can be tested without a window.

local Movement = {}

-- Which strip of a directional sheet to draw for each facing.
Movement.ROWS = { down = 1, left = 2, right = 3, up = 4 }

-- Raw axes (-1/0/1) to a travel direction. Returns dx, dy and the raw length.
-- Normalized, a diagonal is no faster than a straight line.
function Movement.direction(dx, dy, normalize)
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then
        return 0, 0, 0
    end
    local scale = normalize and 1 / length or 1
    return dx * scale, dy * scale, length
end

-- The facing row for a raw press: the dominant axis wins, horizontal on a tie.
-- Returns nil when standing still, so the caller can keep the last facing.
function Movement.facing(dx, dy)
    if dx == 0 and dy == 0 then
        return nil
    end
    if math.abs(dx) >= math.abs(dy) then
        return dx < 0 and Movement.ROWS.left or Movement.ROWS.right
    end
    return dy < 0 and Movement.ROWS.up or Movement.ROWS.down
end

return Movement
