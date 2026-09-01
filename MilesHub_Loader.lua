--[[
    ⚡ Miles-HUB Loader v2.4
    
    STEP 1: Shows loading screen (instant, no fetch needed)
    STEP 2: Fetches and executes game script
    
    Usage:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/MilesHub_Loader.lua"))()
]]

-- ═══ IMMEDIATE FEEDBACK: Loading Screen ═══
-- This shows INSTANTLY before any fetch, so you know the script started

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- Create loading screen immediately
local function CreateLoadingScreen()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MilesHub_Loading"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999
    sg.IgnoreGuiInset = true
    
    -- Try to parent it
    local parented = false
    pcall(function()
        if gethui and type(gethui) == "function" then
            local ok, hui = pcall(gethui)
            if ok and hui then sg.Parent = hui; parented = true end
        end
    end)
    if not parented then
        pcall(function() sg.Parent = game:GetService("CoreGui"); parented = true end)
    end
    if not parented then
        pcall(function() sg.Parent = LP:WaitForChild("PlayerGui", 5); parented = true end)
    end
    
    if not parented then return nil end
    
    -- Background overlay
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0
    bg.Parent = sg
    
    -- Center card
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, 320, 0, 180)
    card.Position = UDim2.new(0.5, -160, 0.5, -90)
    card.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    card.BorderSizePixel = 0
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(130, 90, 220)
    stroke.Thickness = 2
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Miles-HUB"
    title.TextColor3 = Color3.fromRGB(130, 90, 220)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.Parent = card
    
    -- Status text
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 70)
    status.BackgroundTransparency = 1
    status.Text = "Initializing..."
    status.TextColor3 = Color3.fromRGB(160, 160, 170)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.Parent = card
    
    -- Progress bar background
    local barBG = Instance.new("Frame")
    barBG.Size = UDim2.new(0.8, 0, 0, 8)
    barBG.Position = UDim2.new(0.1, 0, 0, 100)
    barBG.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    barBG.BorderSizePixel = 0
    barBG.Parent = card
    Instance.new("UICorner", barBG).CornerRadius = UDim.new(0, 4)
    
    -- Progress bar fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    fill.BorderSizePixel = 0
    fill.Parent = barBG
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    
    -- Version
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(1, -20, 0, 20)
    ver.Position = UDim2.new(0, 10, 1, -35)
    ver.BackgroundTransparency = 1
    ver.Text = "v2.4"
    ver.TextColor3 = Color3.fromRGB(100, 100, 110)
    ver.Font = Enum.Font.Gotham
    ver.TextSize = 11
    ver.Parent = card
    
    return sg, status, fill
end

print("[Miles-HUB Loader] Starting...")
local loadingGui, statusLabel, fillBar = CreateLoadingScreen()

local function UpdateStatus(text, progress)
    print("[Miles-HUB Loader] " .. text)
    if statusLabel then
        pcall(function() statusLabel.Text = text end)
    end
    if fillBar then
        pcall(function()
            fillBar:TweenSize(
                UDim2.new(progress, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.3,
                true
            )
        end)
    end
end

-- ═══ STEP 1: Test HttpGet ═══
UpdateStatus("Testing HttpGet...", 0.1)

local httpOk, httpResult = pcall(function()
    return game:HttpGet("https://httpstat.us/200")
end)

if not httpOk then
    UpdateStatus("❌ HttpGet not available!", 1)
    warn("[Miles-HUB Loader] CRITICAL: game:HttpGet() not supported by your executor!")
    warn("[Miles-HUB Loader] Error: " .. tostring(httpResult))
    task.wait(3)
    if loadingGui then loadingGui:Destroy() end
    return
end

UpdateStatus("HttpGet OK ✓", 0.2)
task.wait(0.3)

-- ═══ STEP 2: Fetch game script ═══
UpdateStatus("Fetching game script...", 0.3)

local GAME_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_game.lua"

local fetchOk, gameSrc = pcall(function()
    return game:HttpGet(GAME_URL)
end)

if not fetchOk or not gameSrc or #gameSrc < 100 then
    UpdateStatus("❌ Fetch failed! Check URL", 1)
    warn("[Miles-HUB Loader] Fetch failed:", gameSrc)
    task.wait(3)
    if loadingGui then loadingGui:Destroy() end
    return
end

UpdateStatus("Downloaded (" .. #gameSrc .. " bytes) ✓", 0.5)
task.wait(0.3)

-- ═══ STEP 3: Compile ═══
UpdateStatus("Compiling...", 0.6)

local chunk, compileErr = loadstring(gameSrc)
if not chunk then
    UpdateStatus("❌ Compile error!", 1)
    warn("[Miles-HUB Loader] Compile error:", compileErr)
    task.wait(3)
    if loadingGui then loadingGui:Destroy() end
    return
end

UpdateStatus("Compiled ✓", 0.7)
task.wait(0.3)

-- ═══ STEP 4: Execute ═══
UpdateStatus("Executing game script...", 0.8)

local execOk, execErr = pcall(function()
    chunk()
end)

if not execOk then
    UpdateStatus("❌ Runtime error!", 1)
    warn("[Miles-HUB Loader] Runtime error:", execErr)
    task.wait(3)
    if loadingGui then loadingGui:Destroy() end
    return
end

UpdateStatus("✅ All loaded! ✓", 1.0)
task.wait(1)

-- ═══ STEP 5: Remove loading screen ═══
if loadingGui then
    -- Fade out
    pcall(function()
        local bg = loadingGui:FindFirstChildWhichIsA("Frame")
        if bg then
            for i = 0, 10 do
                bg.BackgroundTransparency = 0.3 + (i * 0.07)
                task.wait(0.03)
            end
        end
    end)
    loadingGui:Destroy()
end

print("[Miles-HUB Loader] Done! Script loaded successfully ✓")
