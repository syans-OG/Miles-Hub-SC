--[[ ⚡ Miles-HUB v2.2 — Grow A Chicken Fighter ]]--
-- Fetches and executes obfuscated payload from GitHub

local payloadUrl = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/payload_final.lua"

-- Step 1: Fetch payload safely
local ok, payload = pcall(game.HttpGet, game, payloadUrl)
if not ok then
    warn("[Miles-HUB] Fetch failed:", payload)
    -- Fallback: try the original script directly
    local ok2, src = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua")
    if ok2 and src then
        local fn, err = loadstring(src)
        if fn then
            local ran, runErr = pcall(fn)
            if not ran then warn("[Miles-HUB] Runtime:", runErr) end
        else
            warn("[Miles-HUB] Compile fallback:", err)
        end
    end
    return
end

-- Step 2: Compile
local chunk, compileError = loadstring(payload)
if not chunk then
    warn("[Miles-HUB] Compile failed:", compileError)
    return
end

-- Step 3: Execute with error tracing
local result = table.pack(xpcall(chunk, function(err)
    local text = tostring(err)
    if debug and debug.traceback then return debug.traceback(text, 2) end
    return text
end))
if not result[1] then
    warn("[Miles-HUB] Runtime error:", result[2])
    return
end

return table.unpack(result, 2, result.n)
