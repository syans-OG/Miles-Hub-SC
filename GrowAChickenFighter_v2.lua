--[[
    ⚡ Miles-HUB v2.2 — Incremental Build
    Tested: notif only = no kick ✅
    Adding features ONE BY ONE to find kick trigger
]]

task.wait(1)

-- ═══ Step 1: Notification (PROVEN SAFE) ═══
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Miles-HUB",
        Text = "Step 1: Notification OK",
        Duration = 3
    })
end)

-- ═══ Step 2: Simple GUI (test) ═══
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 200, 0, 150)
main.Position = UDim2.new(0.5, -100, 0.5, -75)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
title.Text = "Miles-HUB v2.2"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local info = Instance.new("TextLabel", main)
info.Size = UDim2.new(1, -10, 1, -30)
info.Position = UDim2.new(0, 5, 0, 28)
info.BackgroundTransparency = 1
info.Text = "  Testing...\n  If you see this,\n  GUI creation works!"
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Miles-HUB",
        Text = "Step 2: GUI OK",
        Duration = 3
    })
end)

-- ═══ Step 3: InfJump (client-side only) ═══
local UserInputService = game:GetService("UserInputService")
local InfJump = false

UserInputService.JumpRequest:Connect(function()
    if InfJump then
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ═══ Step 4: Toggle Button ═══
local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(1, -10, 0, 28)
btn.Position = UDim2.new(0, 5, 1, -33)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
btn.Text = "  Inf Jump: OFF"
btn.TextColor3 = Color3.fromRGB(200, 200, 200)
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 11
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

btn.MouseButton1Click:Connect(function()
    InfJump = not InfJump
    btn.Text = InfJump and "  Inf Jump: ON" or "  Inf Jump: OFF"
    btn.BackgroundColor3 = InfJump and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(35, 35, 50)
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Miles-HUB",
        Text = "All steps OK! Inf Jump available.",
        Duration = 5
    })
end)
