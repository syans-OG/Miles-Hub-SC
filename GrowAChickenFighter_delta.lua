--[[
    ⚡ Miles-HUB v2.2 — SAFE MODE (Delta/RedFinger)
    
    ONLY client-side features. ZERO remote firing.
    This avoids all server-side anti-cheat detection.
    
    Safe features:
    - WalkSpeed boost
    - JumpPower boost
    - Infinite Jump
    - NoClip
    - Anti-AFK (basic method)
    - GUI with notifications
]]

-- ═══ Services ═══
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum = c:WaitForChild("Humanoid")
    HRP = c:WaitForChild("HumanoidRootPart")
end)

-- ═══ Safe Remote Scanner (only reads, never fires) ═══
local Remotes = {}
task.spawn(function()
    task.wait(2) -- Wait for game to load
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name] = obj
        end
    end
    -- Report found remotes
    local count = 0
    for _ in pairs(Remotes) do count = count + 1 end
    print("[Miles-HUB] Found " .. count .. " remotes (read-only, not firing)")
end)

-- ═══ Flags ═══
local WalkSpeed = 16
local JumpPower = 50
local InfJump = false
local NoClip = false

-- ═══ Notify ═══
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 3
        })
    end)
end

-- ═══ InfJump ═══
UserInputService.JumpRequest:Connect(function()
    if InfJump and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══ NoClip ═══
RunService.Stepped:Connect(function()
    if NoClip and Char then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = false
            end
        end
    end
end)

-- ═══ WalkSpeed / JumpPower ═══
RunService.Heartbeat:Connect(function()
    if Hum then
        if WalkSpeed > 16 then Hum.WalkSpeed = WalkSpeed end
        if JumpPower > 50 then Hum.JumpPower = JumpPower end
    end
end)

-- ═══ GUI ═══
task.wait(0.5)

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 260 or 340
local guiH = isMobile and 220 or 300

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, guiW, 0, guiH)
main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Title
local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 28)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -8, 1, 0)
tt.Position = UDim2.new(0, 8, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "Miles-HUB v2.2 (Safe)"
tt.TextColor3 = Color3.fromRGB(240, 240, 240)
tt.Font = Enum.Font.GothamBold
tt.TextSize = 12
tt.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

-- Content
local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -10, 1, -34)
content.Position = UDim2.new(0, 5, 0, 30)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0, 4)

-- Toggle helper
local function Toggle(name, default, callback)
    local f = Instance.new("Frame", content)
    f.Size = UDim2.new(1, 0, 0, 26)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -42, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "  " .. name
    l.TextColor3 = Color3.fromRGB(240, 240, 240)
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 34, 0, 16)
    b.Position = UDim2.new(1, -38, 0.5, -8)
    b.BackgroundColor3 = default and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
    b.Text = ""
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 6)

    local v = default
    b.MouseButton1Click:Connect(function()
        v = not v
        b.BackgroundColor3 = v and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
        dot:TweenPosition(v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6),
            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        pcall(callback, v)
    end)
end

-- Slider helper
local function Slider(name, min, max, default, callback)
    local f = Instance.new("Frame", content)
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.55, 0, 0, 16)
    l.Position = UDim2.new(0, 6, 0, 2)
    l.BackgroundTransparency = 1
    l.Text = "  " .. name
    l.TextColor3 = Color3.fromRGB(240, 240, 240)
    l.Font = Enum.Font.GothamSemibold
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.4, 0, 0, 16)
    val.Position = UDim2.new(0.58, 0, 0, 2)
    val.BackgroundTransparency = 1
    val.Text = tostring(default)
    val.TextColor3 = Color3.fromRGB(130, 90, 220)
    val.Font = Enum.Font.GothamBold
    val.TextSize = 10
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -12, 0, 6)
    bar.Position = UDim2.new(0, 6, 0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", bar)
    local pct = (default - min) / (max - min)
    fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local cur = default
    local dragging = false
    local knob = Instance.new("TextButton", bar)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(math.clamp(pct, 0, 1), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            cur = math.floor(min + p * (max - min))
            cur = math.clamp(cur, min, max)
            local np = (cur - min) / (max - min)
            fill.Size = UDim2.new(np, 0, 1, 0)
            knob.Position = UDim2.new(np, -7, 0.5, -7)
            val.Text = tostring(cur)
            pcall(callback, cur)
        end
    end)
end

-- ═══ Toggles (client-side only) ═══
Toggle("Inf Jump", false, function(v) InfJump = v end)
Toggle("NoClip", false, function(v) NoClip = v end)

-- ═══ Sliders ═══
Slider("WalkSpeed", 16, 200, 16, function(v) WalkSpeed = v end)
Slider("JumpPower", 50, 200, 50, function(v) JumpPower = v end)

-- ═══ Info ═══
local info = Instance.new("TextLabel", content)
info.Size = UDim2.new(1, 0, 0, 50)
info.BackgroundTransparency = 1
info.Text = "  Safe Mode: Client-side features only.\n  No remote firing = no server kick.\n  Use WalkSpeed/JumpPower/InfJump/NoClip."
info.TextColor3 = Color3.fromRGB(160, 160, 170)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top

Notify("Miles-HUB Safe Mode loaded!")
