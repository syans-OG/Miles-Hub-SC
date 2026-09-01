--[[ ⚡ Miles-HUB v2.2 — Mobile-Compatible Loader ]]
-- Pattern: loadstring(game:HttpGet(url))() — proven to work on RedFinger + Delta

-- ============ SCRIPT URL ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_delta.lua"
-- ====================================

-- Mobile-safe HTTP fetch
local function safeHttpGet(url)
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if ok and result and #result > 100 then return result end

    ok, result = pcall(function() return game:HttpGetAsync(url) end)
    if ok and result and #result > 100 then return result end

    return nil
end

-- Fetch & execute
print("[Miles-HUB] Fetching...")
local src = safeHttpGet(SCRIPT_URL)

if not src then
    warn("[Miles-HUB] Fetch failed")
    return
end

print("[Miles-HUB] Running (" .. #src .. " bytes)...")
local chunk, err = loadstring(src)
if not chunk then
    warn("[Miles-HUB] Compile error:", err)
    return
end

local ok, runErr = pcall(chunk)
if not ok then
    warn("[Miles-HUB] Runtime error:", runErr)
end
