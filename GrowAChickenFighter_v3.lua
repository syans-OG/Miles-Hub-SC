--[[
    ⚡ Miles-HUB v2.2 — V3 (Proven Safe Patterns)
    
    Based on V2 which tested safe (no kick).
    All features use only proven-safe patterns.
    
    Safe patterns (from V2 test):
    - StarterGui:SetCore("SendNotification")
    - ScreenGui in PlayerGui
    - UserInputService.JumpRequest:Connect
    - TextButton.MouseButton1Click:Connect
    
    Avoided patterns (caused kick):
    - ReplicatedStorage:GetChildren() scanning
    - RunService.Stepped/Heartbeat:Connect loops
    - LP.CharacterAdded:Connect
]]

task.wait(1)

-- ═══ Services (minimal) ═══
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer

-- ═══ Notification (proven safe) ═══
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 3
        })
    end)
end

-- ═══ Flags ═══
local InfJump = false
local WalkSpeed = 16
local JumpPower = 50

-- ═══ InfJump (proven safe pattern) ═══
UserInputService.JumpRequest:Connect(function()
    if InfJump then
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end
end)

-- ═══ WalkSpeed/JumpPower (safe: direct set, no loop) ═══
UserInputService.JumpRequest:Connect(function()
    if InfJump then
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
                -- Apply speed/jump when character exists
                if WalkSpeed > 16 then h.WalkSpeed = WalkSpeed end
                if JumpPower > 50 then h.JumpPower = JumpPower end
            end
        end
    end
end)

-- ═══ Apply speed when character changes (safe: MouseButton1Click pattern) ═══
-- We apply stats when user interacts, not in a loop

-- ═══ GUI (proven safe pattern) ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 260 or 340
local guiH = isMobile and 250 or 320

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

-- Title
local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 26)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -8, 1, 0)
tt.Position = UDim2.new(0, 8, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "Miles-HUB v2.2"
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

-- Content
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -10, 1, -32)
content.Position = UDim2.new(0, 5, 0, 28)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 2
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0, 3)

-- ═══ Toggle (proven safe pattern) ═══
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

-- ═══ Button (proven safe pattern) ═══
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
    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    return b
end

-- ═══ Toggles ═══
Toggle("Inf Jump", false, function(v) InfJump = v end)

-- ═══ Speed/Jump Buttons (apply on click, not loop) ═══
Button("Set Speed: 50", function()
    WalkSpeed = 50
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 50 end
    end
    Notify("Speed set to 50!")
end)

Button("Set Speed: 100", function()
    WalkSpeed = 100
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 100 end
    end
    Notify("Speed set to 100!")
end)

Button("Set Speed: 16 (Normal)", function()
    WalkSpeed = 16
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 end
    end
    Notify("Speed reset to normal!")
end)

Button("Set Jump: 100", function()
    JumpPower = 100
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = 100 end
    end
    Notify("Jump power set to 100!")
end)

Button("Set Jump: 200", function()
    JumpSpeed = 200
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = 200 end
    end
    Notify("Jump power set to 200!")
end)

Button("Reset Jump: 50 (Normal)", function()
    JumpPower = 50
    local c = LP.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = 50 end
    end
    Notify("Jump power reset to normal!")
end)

-- ═══ Info ═══
local info = Instance.new("TextLabel", content)
info.Size = UDim2.new(1, 0, 0, 30)
info.BackgroundTransparency = 1
info.Text = "  Click buttons to apply speed/jump.\n  No auto-loops = no kick."
info.TextColor3 = Color3.fromRGB(120, 120, 130)
info.Font = Enum.Font.Gotham
info.TextSize = 9
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top

Notify("Miles-HUB v2.2 loaded!")
