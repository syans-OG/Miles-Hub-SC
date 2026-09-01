--[[ ⚡ Miles-HUB v2.2 — Mobile-Compatible Loader ]]
-- Paste script ini di executor. Otomatis fetch & jalankan script lengkap.
-- Jika ada masalah, lihat pesan error di layar & F9 console.

-- ============ SCRIPT URL ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_delta.lua"
-- ====================================

-- ═══ Helper: tampilkan pesan di layar ═══
local function ShowScreenMessage(text, bgColor, textColor, duration)
    pcall(function()
        local Players = game:GetService("Players")
        local LP = Players.LocalPlayer
        local sg = Instance.new("ScreenGui")
        sg.Name = "MilesHub_Msg"
        sg.ResetOnSpawn = false
        sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder = 999999

        for _, p in ipairs({
            gethui and gethui(),
            game:GetService("CoreGui"),
            LP:FindFirstChild("PlayerGui"),
        }) do
            if p then
                local ok = pcall(function() sg.Parent = p end)
                if ok and sg.Parent then break end
            end
        end

        if sg.Parent then
            local f = Instance.new("Frame")
            f.Size = UDim2.new(0, 320, 0, 50)
            f.Position = UDim2.new(0.5, -160, 0, 10)
            f.BackgroundColor3 = bgColor or Color3.fromRGB(20, 16, 35)
            f.BorderSizePixel = 0
            f.Parent = sg
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
            local s = Instance.new("UIStroke", f)
            s.Color = textColor or Color3.fromRGB(168, 85, 247)
            s.Thickness = 2

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -16, 1, 0)
            t.Position = UDim2.new(0, 8, 0, 0)
            t.BackgroundTransparency = 1
            t.Text = text
            t.TextColor3 = textColor or Color3.fromRGB(168, 85, 247)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 13
            t.TextWrapped = true
            t.Parent = f

            task.delay(duration or 6, function() pcall(function() sg:Destroy() end) end)
            return sg
        end
    end)
end

-- ═══ Step 1: Show loading banner ═══
local loaderGui = ShowScreenMessage("⚡ Miles-HUB Loading...", Color3.fromRGB(20, 16, 35), Color3.fromRGB(168, 85, 247), 15)
print("[Miles-HUB] Loader started — fetching script...")

-- ═══ Step 2: HTTP Fetch (try multiple methods) ═══
local function safeHttpGet(url)
    -- Method 1: game:HttpGet (most common)
    local ok, result = pcall(function() return game:HttpGet(url, true) end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] HttpGet OK (" .. #result .. " bytes)")
        return result
    end

    -- Method 2: game:HttpGet (without async flag)
    ok, result = pcall(function() return game:HttpGet(url) end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] HttpGet(2) OK (" .. #result .. " bytes)")
        return result
    end

    -- Method 3: game:HttpGetAsync
    ok, result = pcall(function() return game:HttpGetAsync(url) end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] HttpGetAsync OK (" .. #result .. " bytes)")
        return result
    end

    -- Method 4: syn.request (some executors)
    ok, result = pcall(function()
        if syn and syn.request then
            local r = syn.request({Url = url, Method = "GET"})
            return r and r.Body
        end
    end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] syn.request OK (" .. #result .. " bytes)")
        return result
    end

    -- Method 5: http_request (some executors)
    ok, result = pcall(function()
        if http_request then
            local r = http_request({Url = url, Method = "GET"})
            return r and r.Body
        end
    end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] http_request OK (" .. #result .. " bytes)")
        return result
    end

    -- Method 6: request (fluxus/some executors)
    ok, result = pcall(function()
        if request then
            local r = request({Url = url, Method = "GET"})
            return r and r.Body
        end
    end)
    if ok and result and type(result) == "string" and #result > 100 then
        print("[Miles-HUB] request OK (" .. #result .. " bytes)")
        return result
    end

    warn("[Miles-HUB] ALL HTTP methods failed. Executor may not support HttpGet.")
    return nil
end

-- ═══ Step 3: Fetch script ═══
local src = safeHttpGet(SCRIPT_URL)

if not src then
    -- DESTROY loading banner
    pcall(function() if loaderGui then loaderGui:Destroy() end end)

    -- SHOW ERROR with detailed instructions
    ShowScreenMessage(
        "❌ Fetch Failed!\nExecutor tidak support HttpGet.\nPaste GrowAChickenFighter_combined.lua langsung.",
        Color3.fromRGB(40, 15, 15),
        Color3.fromRGB(255, 80, 80),
        30
    )
    warn("═══════════════════════════════════════════════")
    warn("[Miles-HUB] FETCH FAILED!")
    warn("[Miles-HUB] Executor kamu TIDAK support game:HttpGet()")
    warn("[Miles-HUB] SOLUSI: Jalankan GrowAChickenFighter_combined.lua")
    warn("[Miles-HUB] langsung di executor (copy-paste, tanpa loader)")
    warn("═══════════════════════════════════════════════")
    return
end

-- ═══ Step 4: Compile ═══
local chunk, err = loadstring(src)
if not chunk then
    pcall(function() if loaderGui then loaderGui:Destroy() end end)
    ShowScreenMessage(
        "❌ Compile Error!\n" .. tostring(err),
        Color3.fromRGB(40, 15, 15),
        Color3.fromRGB(255, 80, 80),
        20
    )
    warn("[Miles-HUB] Compile error:", err)
    return
end

-- ═══ Step 5: Execute ═══
print("[Miles-HUB] Compiled OK — executing...")
task.delay(0.3, function() pcall(function() if loaderGui then loaderGui:Destroy() end end) end)

local ok, runErr = pcall(chunk)
if not ok then
    ShowScreenMessage(
        "❌ Runtime Error!\n" .. tostring(runErr):sub(1, 100),
        Color3.fromRGB(40, 15, 15),
        Color3.fromRGB(255, 80, 80),
        15
    )
    warn("[Miles-HUB] Runtime error:", runErr)
else
    print("[Miles-HUB] ✅ Script loaded successfully!")
end
