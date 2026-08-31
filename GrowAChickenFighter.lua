--[[ ⚡ Miles-HUB v2.2 — Grow A Chicken Fighter ]]--
-- Loader pattern optimized like synex.lat

local payloadUrl = "https://gist.githubusercontent.com/syans-OG/deec366994592a60e40e633ce71258c2/raw/6c78b9bd9f80feb32808cdc3687e18a6b83fc37c/payload_light.lua"

local function traceError(err)
    local text = tostring(err)
    if debug and debug.traceback then return debug.traceback(text, 2) end
    return text
end

-- Step 1: Fetch payload safely
local sourceOk, source = pcall(game.HttpGet, game, payloadUrl)
if not sourceOk then
    warn("[Miles-HUB] Fetch failed:", source)
    return
end

-- Step 2: Compile
local chunk, compileError = loadstring(source)
if not chunk then
    warn("[Miles-HUB] Compile failed:", compileError)
    return
end

-- Step 3: Execute with error tracing
local result = table.pack(xpcall(chunk, traceError))
if not result[1] then
    warn("[Miles-HUB] Runtime error:", result[2])
    return
end

return table.unpack(result, 2, result.n)
