--[[ 
    Miles-HUB v2.2 — Loader
    Fetches the fixed script directly from GitHub.
    If you want to use an obfuscated version,
    paste script asli ke WeAreDevs Obfuscator:
    https://wearedevs.net/obfuscator
    Then update SCRIPT_URL to your Gist raw URL.
]]

-- ============ SCRIPT URL (Fixed Original) ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua"
-- ====================================================

-- Anti-detection loader
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

-- Load & execute
local success, err = pcall(function()
    local code = game:HttpGet(SCRIPT_URL)
    if code and #code > 0 then
        local fn = loadstring(code)
        if fn then
            fn()
        else
            warn("[Miles-HUB] Failed to compile script")
        end
    else
        warn("[Miles-HUB] Failed to fetch script from URL")
    end
end)

if not success then
    warn("[Miles-HUB] Error:", err)
end
