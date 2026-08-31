--[[ ⚡ Miles-HUB v2.2 — Grow A Chicken Fighter ]]--
-- Direct loader (akkiwi.com pattern)
-- No obfuscation - script is clean without hookmetamethod

print("[Miles-HUB] v2.2 loading...")

-- Fetch the script directly
local ok, src = pcall(game.HttpGet, game, 
    "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua")

if not ok or not src then
    warn("[Miles-HUB] Fetch failed:", src)
    return
end

print("[Miles-HUB] Script fetched (" .. #src .. " bytes), compiling...")

-- Compile
local chunk, err = loadstring(src)
if not chunk then
    warn("[Miles-HUB] Compile failed:", err)
    return
end

-- Execute with error handling
print("[Miles-HUB] Executing...")
local result = table.pack(xpcall(chunk, function(e)
    local t = tostring(e)
    if debug and debug.traceback then return debug.traceback(t, 2) end
    return t
end))

if not result[1] then
    warn("[Miles-HUB] Runtime error:", result[2])
else
    print("[Miles-HUB] ✓ Loaded successfully!")
end

return table.unpack(result, 2, result.n)
