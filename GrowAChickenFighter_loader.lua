--[[ ⚡ Miles-HUB v2.2 — Self-Contained Loader ]]
-- Original script now includes Rayfield UI inline.
-- Just fetch & execute.

-- ============ SCRIPT URL ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua"
-- ====================================

-- Anti-detection hooks
pcall(function()
    if hookmetamethod then
        local orig
        orig = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if tostring(method):lower() == "kick" and self == game:GetService("Players").LocalPlayer then
                return nil
            end
            return orig(self, ...)
        end)
    end
end)

-- Fetch & execute
print("[Miles-HUB] Fetching script...")
local ok, src = pcall(game.HttpGet, game, SCRIPT_URL)

if not ok or not src then
    warn("[Miles-HUB] Fetch failed:", src)
    return
end

print("[Miles-HUB] Compiling (" .. #src .. " bytes)...")
local chunk, err = loadstring(src)
if not chunk then
    warn("[Miles-HUB] Compile failed:", err)
    return
end

print("[Miles-HUB] Executing...")
local ranOk, runErr = pcall(chunk)
if not ranOk then
    warn("[Miles-HUB] Runtime error:", runErr)
else
    print("[Miles-HUB] Loaded successfully!")
end
