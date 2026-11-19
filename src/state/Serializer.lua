-- Turns plain data (tables, numbers, strings, booleans) into text and back. The text is JSON, so
-- the save file is readable, but both directions are written here: decode is a small parser,
-- never load(), so a tampered save file cannot run code. Pure: no LÖVE.
--
--   Serializer.encode(value)  -> text   (keys sorted: the same data gives the same text)
--   Serializer.decode(text)   -> value, or nil + a message with the position of the problem

local Serializer = {}

local INDENT = "  "

---------------------------------------------------------------------------- encode

local function isArray(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    for i = 1, count do
        if t[i] == nil then return false end
    end
    return count > 0
end

local function quote(text)
    return '"' .. text:gsub('[%c"\\]', function(c) return ("\\%03d"):format(c:byte()) end) .. '"'
end

local function number(n)
    assert(n == n and n ~= math.huge and n ~= -math.huge, "cannot save NaN or infinity")
    if n == math.floor(n) and math.abs(n) < 2 ^ 53 then return ("%d"):format(n) end
    return ("%.17g"):format(n)
end

local function write(value, depth, out)
    local kind = type(value)
    if kind == "number" then
        out[#out + 1] = number(value)
    elseif kind == "string" then
        out[#out + 1] = quote(value)
    elseif kind == "boolean" then
        out[#out + 1] = tostring(value)
    elseif kind == "table" then
        local pad, inner = "\n" .. INDENT:rep(depth), "\n" .. INDENT:rep(depth + 1)
        if next(value) == nil then
            out[#out + 1] = "[]"
        elseif isArray(value) then
            out[#out + 1] = "["
            for i, item in ipairs(value) do
                out[#out + 1] = (i > 1 and "," or "") .. inner
                write(item, depth + 1, out)
            end
            out[#out + 1] = pad .. "]"
        else
            local keys = {}
            for key in pairs(value) do
                assert(type(key) == "string", "only string keys can be saved in an object")
                keys[#keys + 1] = key
            end
            table.sort(keys)
            out[#out + 1] = "{"
            for i, key in ipairs(keys) do
                out[#out + 1] = (i > 1 and "," or "") .. inner .. quote(key) .. ": "
                write(value[key], depth + 1, out)
            end
            out[#out + 1] = pad .. "}"
        end
    else
        error("cannot save a " .. kind)
    end
end

function Serializer.encode(value)
    local out = {}
    write(value, 0, out)
    return table.concat(out) .. "\n"
end

---------------------------------------------------------------------------- decode

local MAX_DEPTH = 32

local function fail(text, pos, message)
    error({ message = ("%s at character %d"):format(message, pos) }, 0)
end

local function skip(text, pos)
    return text:find("[^ \t\r\n]", pos) or #text + 1
end

local parseValue

local function parseString(text, pos)
    local out, i = {}, pos + 1
    while true do
        local c = text:sub(i, i)
        if c == "" then fail(text, pos, "unterminated string") end
        if c == '"' then return table.concat(out), i + 1 end
        if c == "\\" then
            local code = text:match("^%d%d%d", i + 1)
            if code then
                out[#out + 1] = string.char(tonumber(code))
                i = i + 4
            else
                local escaped = text:sub(i + 1, i + 1)
                local simple = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", n = "\n", t = "\t", r = "\r" }
                if not simple[escaped] then fail(text, i, "bad escape") end
                out[#out + 1] = simple[escaped]
                i = i + 2
            end
        else
            out[#out + 1] = c
            i = i + 1
        end
    end
end

local function parseNumber(text, pos)
    local token = text:match("^-?%d+%.?%d*[eE]?[+-]?%d*", pos)
    local n = token and tonumber(token)
    if not n then fail(text, pos, "bad number") end
    return n, pos + #token
end

local function parseTable(text, pos, depth)
    local open = text:sub(pos, pos)
    local close = open == "{" and "}" or "]"
    local result, i = {}, skip(text, pos + 1)
    if text:sub(i, i) == close then return result, i + 1 end

    local index = 1
    while true do
        i = skip(text, i)
        if open == "{" then
            if text:sub(i, i) ~= '"' then fail(text, i, "expected a key") end
            local key
            key, i = parseString(text, i)
            i = skip(text, i)
            if text:sub(i, i) ~= ":" then fail(text, i, "expected ':'") end
            result[key], i = parseValue(text, skip(text, i + 1), depth + 1)
        else
            result[index], i = parseValue(text, i, depth + 1)
            index = index + 1
        end
        i = skip(text, i)
        local c = text:sub(i, i)
        if c == close then return result, i + 1 end
        if c ~= "," then fail(text, i, "expected ',' or '" .. close .. "'") end
        i = i + 1
    end
end

function parseValue(text, pos, depth)
    if depth > MAX_DEPTH then fail(text, pos, "nested too deep") end
    local c = text:sub(pos, pos)
    if c == "{" or c == "[" then return parseTable(text, pos, depth) end
    if c == '"' then return parseString(text, pos) end
    if text:sub(pos, pos + 3) == "true" then return true, pos + 4 end
    if text:sub(pos, pos + 4) == "false" then return false, pos + 5 end
    if c:match("[%d-]") then return parseNumber(text, pos) end
    fail(text, pos, "unexpected " .. (c == "" and "end of file" or "'" .. c .. "'"))
end

function Serializer.decode(text)
    if type(text) ~= "string" then return nil, "no text" end
    local ok, value, pos = pcall(function()
        local v, p = parseValue(text, skip(text, 1), 1)
        if skip(text, p) <= #text then fail(text, skip(text, p), "unexpected text after the data") end
        return v, p
    end)
    if ok then return value end
    return nil, type(value) == "table" and value.message or tostring(value)
end

return Serializer
