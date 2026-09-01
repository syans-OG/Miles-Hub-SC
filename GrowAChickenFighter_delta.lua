--[[
    ⚡ Miles-HUB v2.2 — Delta/RedFinger Compatible
    
    Pattern matched to working scripts (1337hub, VoidHub):
    - NO VirtualUser (detected by Byfron)
    - NO workspace:GetDescendants() scanning
    - GUI in PlayerGui only (not CoreGui/StarterGui)
    - Simple remote calls with natural delays
    - Minimal UI footprint
]]

-- ═══ Minimal Services ═══
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum = c:WaitForChild("Humanoid")
    HRP = c:WaitForChild("HumanoidRootPart")
end)

-- ═══ Remote Scanner (safe - no Descendants) ═══
local function FindRemote(names)
    for _, n in ipairs(names) do
        local r = ReplicatedStorage:FindFirstChild(n, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            return r
        end
    end
    return nil
end

-- ═══ Safe Fire ═══
local function Fire(remote, ...)
    if not remote then return end
    task.wait(math.random(50, 150) / 1000)
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        else
            remote:InvokeServer(...)
        end
    end)
end

-- ═══ Discover Remotes ═══
local R = {
    Hatch = FindRemote({"HatchEgg", "OpenEgg", "BuyEgg", "Hatch"}),
    Train = FindRemote({"Train", "GainStrength", "ClickEvent", "Tap", "Workout"}),
    Punch = FindRemote({"Punch", "Attack", "Hit", "Fight", "Swing", "Battle"}),
    Rebirth = FindRemote({"Rebirth", "RebirthEvent", "DoRebirth"}),
    EquipBest = FindRemote({"EquipBest", "AutoEquip", "EquipAll", "BestPets"}),
}

-- ═══ Flags ═══
local AutoTrain = false
local AutoPunch = false
local AutoHatch = false
local SelectedEgg = "Basic Egg"
local InfJump = false
local NoClip = false

-- ═══ No VirtualUser - use SafeNotify instead ═══
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 3
        })
    end)
end

-- ═══ InfJump (safe - no VirtualUser) ═══
UserInputService.JumpRequest:Connect(function()
    if InfJump and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══ NoClip (safe) ═══
RunService.Stepped:Connect(function()
    if NoClip and Char then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = false
            end
        end
    end
end)

-- ═══ Background Loops (with human-like delays) ═══
task.spawn(function()
    while true do
        if AutoTrain then Fire(R.Train) end
        task.wait(0.5 + math.random() * 0.5)
    end
end)

task.spawn(function()
    while true do
        if AutoPunch then Fire(R.Punch) end
        task.wait(0.5 + math.random() * 0.5)
    end
end)

task.spawn(function()
    while true do
        if AutoHatch then Fire(R.Hatch, SelectedEgg, 1) end
        task.wait(1 + math.random())
    end
end)

-- ═══ GUI (PlayerGui only - NOT CoreGui) ═══
task.wait(0.5)

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 260 or 340
local guiH = isMobile and 180 or 260

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LP:WaitForChild("PlayerGui") -- PlayerGui only!

local main = Instance.new("Frame")
main.Size = UDim2.new(0, guiW, 0, guiH)
main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 28)
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
tt.TextSize = 12
tt.TextXAlignment = Enum.TextXAlignment.Left

local cb = Instance.new("TextButton", tb)
cb.Size = UDim2.new(0, 22, 0, 22)
cb.Position = UDim2.new(1, -26, 0, 3)
cb.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
cb.Text = "X"
cb.TextColor3 = Color3.fromRGB(240, 240, 240)
cb.Font = Enum.Font.GothamBold
cb.TextSize = 10
Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 6)
cb.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, -10, 1, -34)
content.Position = UDim2.new(0, 5, 0, 30)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", content).Padding = UDim.new(0, 4)

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

-- ═══ Toggles ═══
Toggle("Auto Train", false, function(v) AutoTrain = v end)
Toggle("Auto Punch", false, function(v) AutoPunch = v end)
Toggle("Auto Hatch", false, function(v) AutoHatch = v end)
Toggle("Inf Jump", false, function(v) InfJump = v end)
Toggle("NoClip", false, function(v) NoClip = v end)

-- ═══ Button: Equip Best ═══
local btn = Instance.new("TextButton", content)
btn.Size = UDim2.new(1, 0, 0, 26)
btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
btn.Text = "  Equip Best Chickens"
btn.TextColor3 = Color3.fromRGB(240, 240, 240)
btn.Font = Enum.Font.GothamSemibold
btn.TextSize = 11
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.BorderSizePixel = 0
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
btn.MouseButton1Click:Connect(function()
    Fire(R.EquipBest)
    Notify("Equipped best chickens!")
end)

-- ═══ Button: Rebirth ═══
local rb = Instance.new("TextButton", content)
rb.Size = UDim2.new(1, 0, 0, 26)
rb.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
rb.Text = "  Rebirth"
rb.TextColor3 = Color3.fromRGB(240, 240, 240)
rb.Font = Enum.Font.GothamSemibold
rb.TextSize = 11
rb.TextXAlignment = Enum.TextXAlignment.Left
rb.BorderSizePixel = 0
Instance.new("UICorner", rb).CornerRadius = UDim.new(0, 6)
rb.MouseButton1Click:Connect(function()
    Fire(R.Rebirth)
    Notify("Rebirth triggered!")
end)

Notify("Miles-HUB loaded! Open PlayerGui to see UI.")
