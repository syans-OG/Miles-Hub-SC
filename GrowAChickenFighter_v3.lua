--[[
    ⚡ Miles-HUB v2.2 — V3.1 (BAC-8705 Fix)
    
    BAC-8705 = WalkSpeed/JumpPower modification detected!
    Byfron threshold: ~25-30 for WalkSpeed, ~60-70 for JumpPower
    
    This version limits speed/jump to SAFE values below threshold.
    NO RunService loops, NO remote firing, NO ReplicatedStorage scan.
]]

task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 3
        })
    end)
end

-- ═══ InfJump (proven safe) ═══
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

-- ═══ Safe Speed/Jump (below Byfron threshold) ═══
-- Byfron detects: WalkSpeed > ~25, JumpPower > ~60
-- Stay BELOW these values to avoid BAC-8705

local function SetSpeed(val)
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = val
            Notify("Speed: " .. val)
        end
    end
end

local function SetJump(val)
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            h.JumpPower = val
            Notify("Jump: " .. val)
        end
    end
end

-- ═══ GUI ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 260 or 320
local guiH = isMobile and 280 or 360

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, guiW, 0, guiH)
main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 26)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -8, 1, 0)
tt.Position = UDim2.new(0, 8, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "Miles-HUB v2.2 (Safe Speed)"
tt.TextColor3 = Color3.fromRGB(240, 240, 240)
tt.Font = Enum.Font.GothamBold
tt.TextSize = 11
tt.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 9
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -10, 1, -32)
content.Position = UDim2.new(0, 5, 0, 28)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0, 3)

-- ═══ Helpers ═══
local function Toggle(name, default, callback)
    local f = Instance.new("Frame", content)
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -40, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "  " .. name
    l.TextColor3 = Color3.fromRGB(240, 240, 240)
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 32, 0, 14)
    b.Position = UDim2.new(1, -36, 0.5, -7)
    b.BackgroundColor3 = default and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
    b.Text = ""
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)

    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
    dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 5)

    local v = default
    b.MouseButton1Click:Connect(function()
        v = not v
        b.BackgroundColor3 = v and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
        dot:TweenPosition(v and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        pcall(callback, v)
    end)
end

local function Button(name, callback)
    local b = Instance.new("TextButton", content)
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 10
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- ═══ Section: Jump ═══
local sec1 = Instance.new("TextLabel", content)
sec1.Size = UDim2.new(1, 0, 0, 16)
sec1.BackgroundTransparency = 1
sec1.Text = "  JUMP"
sec1.TextColor3 = Color3.fromRGB(130, 90, 220)
sec1.Font = Enum.Font.GothamBold
sec1.TextSize = 9
sec1.TextXAlignment = Enum.TextXAlignment.Left

Toggle("Inf Jump", false, function(v) InfJump = v end)

-- ═══ Section: Speed (SAFE VALUES ONLY) ═══
local sec2 = Instance.new("TextLabel", content)
sec2.Size = UDim2.new(1, 0, 0, 16)
sec2.BackgroundTransparency = 1
sec2.Text = "  SPEED (Safe: max 24)"
sec2.TextColor3 = Color3.fromRGB(130, 90, 220)
sec2.Font = Enum.Font.GothamBold
sec2.TextSize = 9
sec2.TextXAlignment = Enum.TextXAlignment.Left

Button("Speed: 20", function() SetSpeed(20) end)
Button("Speed: 24 (Max Safe)", function() SetSpeed(24) end)
Button("Speed: 16 (Normal)", function() SetSpeed(16) end)

-- ═══ Section: Jump Power (SAFE VALUES ONLY) ═══
local sec3 = Instance.new("TextLabel", content)
sec3.Size = UDim2.new(1, 0, 0, 16)
sec3.BackgroundTransparency = 1
sec3.Text = "  JUMP POWER (Safe: max 55)"
sec3.TextColor3 = Color3.fromRGB(130, 90, 220)
sec3.Font = Enum.Font.GothamBold
sec3.TextSize = 9
sec3.TextXAlignment = Enum.TextXAlignment.Left

Button("Jump: 55 (Max Safe)", function() SetJump(55) end)
Button("Jump: 50 (Normal)", function() SetJump(50) end)

-- ═══ Warning ═══
local warn1 = Instance.new("TextLabel", content)
warn1.Size = UDim2.new(1, 0, 0, 30)
warn1.BackgroundTransparency = 1
warn1.Text = "  ⚠️ Speed >24 or Jump >55 = BAC-8705 kick\n  Stay within safe limits!"
warn1.TextColor3 = Color3.fromRGB(255, 200, 100)
warn1.Font = Enum.Font.Gotham
warn1.TextSize = 9
warn1.TextWrapped = true
warn1.TextXAlignment = Enum.TextXAlignment.Left
warn1.TextYAlignment = Enum.TextYAlignment.Top

Notify("Miles-HUB loaded! Stay under speed limits!")
