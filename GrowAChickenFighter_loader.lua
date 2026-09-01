--[[ ⚡ Miles-HUB v2.2 — Mobile-Compatible Loader ]]
-- Works on cloud phone / mobile executors

-- ============ SCRIPT URL ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua"
-- ====================================

-- Anti-detection hooks (safe on mobile)
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

-- Mobile-safe HTTP fetch (try multiple methods)
local function safeHttpGet(url)
    -- Method 1: game:HttpGet (standard)
    local ok, result = pcall(function() return game:HttpGet(url) end)
    if ok and result and #result > 100 then return result end

    -- Method 2: game.HttpGetAsync
    ok, result = pcall(function() return game:HttpGetAsync(url) end)
    if ok and result and #result > 100 then return result end

    -- Method 3: syn.request / http_request
    ok, result = pcall(function()
        if syn and syn.request then
            local r = syn.request({Url = url, Method = "GET"})
            return r.Body
        elseif http_request then
            local r = http_request({Url = url, Method = "GET"})
            return r.Body
        end
    end)
    if ok and result and #result > 100 then return result end

    -- Method 4: fluxus request
    ok, result = pcall(function()
        if fluxus and fluxus.request then
            local r = fluxus.request({Url = url, Method = "GET"})
            return r.Body
        end
    end)
    if ok and result and #result > 100 then return result end

    return nil
end

-- Fetch & execute
print("[Miles-HUB] Fetching script...")
local src = safeHttpGet(SCRIPT_URL)

if not src then
    warn("[Miles-HUB] All HTTP methods failed. Trying direct loadstring fallback...")
    -- Last resort: try loadstring with game:HttpGet inside pcall
    local ok2, err2 = pcall(function()
        local code = game:HttpGet(SCRIPT_URL)
        if code and #code > 100 then
            loadstring(code)()
        end
    end)
    if not ok2 then
        warn("[Miles-HUB] Fallback also failed:", err2)
        warn("[Miles-HUB] Your executor may not support HttpGet.")
        warn("[Miles-HUB] Try pasting the full script directly instead.")
    end
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
