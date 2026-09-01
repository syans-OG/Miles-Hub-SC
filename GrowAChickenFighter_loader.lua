--[[ ⚡ Miles-HUB v2.2 — LOADER ]]--
-- Paste satu ini ke executor. Fetch script lengkap dari GitHub.

local URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_core.lua"

-- Show loading
pcall(function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MH_Loader"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999999
    sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 280, 0, 40); f.Position = UDim2.new(0.5, -140, 0, 10)
    f.BackgroundColor3 = Color3.fromRGB(20, 16, 35); f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(168, 85, 247)
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -16, 1, 0); t.Position = UDim2.new(0, 8, 0, 0)
    t.BackgroundTransparency = 1; t.Text = "Miles-HUB Loading..."
    t.TextColor3 = Color3.fromRGB(168, 85, 247); t.Font = Enum.Font.GothamBold; t.TextSize = 13
    task.delay(8, function() pcall(function() sg:Destroy() end) end)
end)

-- Fetch & execute
local ok, src = pcall(game.HttpGet, game, URL)
if not ok or not src or #src < 100 then
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title="Miles-HUB", Text="Fetch failed!", Duration=5})
    end)
    warn("[Miles-HUB] Fetch failed: " .. tostring(src))
    return
end

local fn, err = loadstring(src)
if not fn then
    warn("[Miles-HUB] Compile error: " .. tostring(err))
    return
end

local runOk, runErr = pcall(fn)
if not runOk then
    warn("[Miles-HUB] Runtime error: " .. tostring(runErr))
end
