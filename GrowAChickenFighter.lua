--[[
    ⚡ Miles-HUB v2.2 — Grow A Chicken Fighter
    Obfuscated version — loadstring from Gist
    
    How to execute:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter.lua"))()
]]

-- Anti-detect: block client-side kick
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

-- Fetch obfuscated script from Gist and execute
local ok, err = pcall(function()
    local code = game:HttpGet("https://gist.githubusercontent.com/syans-OG/5be2d43e870cbc58d2f66261e1bc63b2/raw/b126394feb5c0110c246023d1d04d138774a13a8/gistfile1.txt")
    if code and #code > 0 then
        loadstring(code)()
    else
        warn("[Miles-HUB] Failed to fetch obfuscated script")
    end
end)

if not ok then
    warn("[Miles-HUB] Error:", err)
end
