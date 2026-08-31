--[[ 
    Miles-HUB v2.2 — Loader
    Paste script asli kamu ke WeAreDevs Obfuscator:
    https://wearedevs.net/obfuscator
    
    Setelah obfuscate, save hasilnya ke GitHub Gist,
    lalu update URL di bawah ini:
]]

-- ============ UPDATE URL HASIL OBFUSCATE ============
local SCRIPT_URL = "https://gist.githubusercontent.com/syans-OG/HASIL_OBFUSCATE/raw/script.lua"
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
