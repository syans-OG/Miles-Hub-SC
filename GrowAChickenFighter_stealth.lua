--[[ ⚡ Miles-HUB v2.2 — STEALTH MODE ]]
-- Minimal version: ONLY uses RemoteEvents (safest method)
-- No fireproximityprompt, no firetouchinterest, no getconnections
-- Designed for detected executors (BAC-10511)

print("[Miles-HUB] Stealth mode loading...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

task.wait(1) -- Extra delay for stealth

local HUB_TITLE = "⚡ Miles-HUB v2.2 (Stealth)"

-- ═══ Load Confirmation Banner ═══
pcall(function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MilesHub_Stealth"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999
    for _, p in ipairs({game:GetService("CoreGui"), game:GetService("StarterGui"), LocalPlayer:WaitForChild("PlayerGui")}) do
        if p then
            local ok = pcall(function() sg.Parent = p end)
            if ok and sg.Parent then break end
        end
    end
    if sg.Parent then
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 300, 0, 45)
        f.Position = UDim2.new(0.5, -150, 0, 10)
        f.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        f.BorderSizePixel = 0
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", f)
        s.Color = Color3.fromRGB(168, 85, 247)
        s.Thickness = 2
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -12, 1, 0)
        t.Position = UDim2.new(0, 6, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = "⚡ Miles-HUB Stealth Loaded!"
        t.TextColor3 = Color3.fromRGB(168, 85, 247)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.Parent = f
        task.delay(5, function() pcall(function() sg:Destroy() end) end)
    end
end)

-- ═══ Flags (conservative defaults) ═══
local Flags = {
    AntiAFK = true,
    AutoReconnect = false, -- OFF: prevents re-kick loop
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    NoClip = false,
    AutoHatch = false,
    SelectedEgg = "Basic Egg",
    HatchDelay = 1.0,
    AutoTrain = false,
    AutoPunch = false,
    FarmSpeed = 0.3,
}

-- ═══ Safe Remote Scanner ═══
local function ScanRemote(names)
    for _, name in ipairs(names) do
        local r = ReplicatedStorage:FindFirstChild(name, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            return r
        end
    end
    return nil
end

local Remotes = {
    Hatch = ScanRemote({"HatchEgg", "OpenEgg", "BuyEgg", "EggHatch", "Hatch"}),
    Train = ScanRemote({"Train", "GainStrength", "ClickEvent", "TrainEvent", "Tap", "Workout"}),
    Punch = ScanRemote({"Punch", "Attack", "Hit", "Fight", "Swing", "Battle"}),
    Rebirth = ScanRemote({"Rebirth", "RebirthEvent", "BuyRebirth", "DoRebirth"}),
    EquipBest = ScanRemote({"EquipBest", "AutoEquip", "EquipAll", "BestPets"}),
}

-- ═══ Safe Remote Invoke (longer delay for stealth) ═══
local function SafeInvoke(remote, ...)
    if not remote then return false end
    local jitter = math.random(50, 200) / 1000 -- 50-200ms delay
    task.wait(jitter)
    local ok, res = pcall(function(...)
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end, ...)
    return ok, res
end

-- ═══ Safe Notify ═══
local function SafeNotify(opts)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = opts.Title or HUB_TITLE,
            Text = opts.Content or "",
            Duration = opts.Duration or 3
        })
    end)
end

-- ═══ Character Respawn Handler ═══
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ═══ Anti-AFK (safe method) ═══
LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end)

task.spawn(function()
    while true do
        if Flags.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(10, 10))
            end)
        end
        task.wait(300)
    end
end)

-- ═══ InfJump ═══
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ═══ NoClip ═══
RunService.Stepped:Connect(function()
    if Flags.NoClip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end)

-- ═══ WalkSpeed / JumpPower ═══
RunService.Heartbeat:Connect(function()
    if Character and Humanoid then
        if Flags.WalkSpeed > 16 and Humanoid.WalkSpeed ~= Flags.WalkSpeed then
            Humanoid.WalkSpeed = Flags.WalkSpeed
        end
        if Flags.JumpPower > 50 and Humanoid.JumpPower ~= Flags.JumpPower then
            Humanoid.JumpPower = Flags.JumpPower
        end
    end
end)

-- ═══ Auto Train ═══
task.spawn(function()
    while true do
        if Flags.AutoTrain and Remotes.Train then
            SafeInvoke(Remotes.Train)
        end
        task.wait(Flags.FarmSpeed)
    end
end)

-- ═══ Auto Punch ═══
task.spawn(function()
    while true do
        if Flags.AutoPunch and Remotes.Punch then
            SafeInvoke(Remotes.Punch)
        end
        task.wait(Flags.FarmSpeed)
    end
end)

-- ═══ Auto Hatch ═══
task.spawn(function()
    while true do
        if Flags.AutoHatch and Remotes.Hatch then
            SafeInvoke(Remotes.Hatch, Flags.SelectedEgg, 1)
        end
        task.wait(Flags.HatchDelay)
    end
end)

-- ═══ Minimal GUI (only essential controls) ═══
local COLORS = {
    Background = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(130, 90, 220),
    Text = Color3.fromRGB(240, 240, 240),
    ElementBG = Color3.fromRGB(35, 35, 50),
    Border = Color3.fromRGB(60, 60, 80),
}

local function addCorner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
end

-- Try multiple parents for mobile
local guiParent = nil
for _, p in ipairs({game:GetService("CoreGui"), game:GetService("StarterGui"), LocalPlayer:WaitForChild("PlayerGui")}) do
    if p then
        local ok = pcall(function() local t = Instance.new("ScreenGui"); t.Parent = p; t:Destroy() end)
        if ok then guiParent = p; break end
    end
end

if guiParent then
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local guiW = isMobile and 300 or 400
    local guiH = isMobile and 200 or 300

    local gui = Instance.new("ScreenGui")
    gui.Name = "MilesHub_StealthUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999
    gui.Parent = guiParent

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, guiW, 0, guiH)
    main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
    main.BackgroundColor3 = COLORS.Background
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = gui
    addCorner(main, 10)

    -- Title bar
    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, 0, 0, 30)
    tb.BackgroundColor3 = COLORS.Accent
    tb.BorderSizePixel = 0
    tb.Parent = main
    addCorner(tb, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = HUB_TITLE .. " (Stealth)"
    title.TextColor3 = COLORS.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = tb

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = COLORS.Text
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 10
    closeBtn.Parent = tb
    addCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

    -- Content frame
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -12, 1, -38)
    content.Position = UDim2.new(0, 6, 0, 34)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = COLORS.Accent
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Parent = main

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    -- Helper: Create Toggle
    local function makeToggle(name, default, callback)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 28)
        f.BackgroundColor3 = COLORS.ElementBG
        f.BorderSizePixel = 0
        f.Parent = content
        addCorner(f, 6)

        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(1, -46, 1, 0)
        lb.BackgroundTransparency = 1
        lb.Text = "  " .. name
        lb.TextColor3 = COLORS.Text
        lb.Font = Enum.Font.GothamSemibold
        lb.TextSize = 11
        lb.TextXAlignment = Enum.TextXAlignment.Left
        lb.Parent = f

        local bg = Instance.new("TextButton")
        bg.Size = UDim2.new(0, 36, 0, 18)
        bg.Position = UDim2.new(1, -42, 0.5, -9)
        bg.BackgroundColor3 = default and COLORS.Accent or Color3.fromRGB(80, 80, 90)
        bg.Text = ""
        bg.BorderSizePixel = 0
        bg.Parent = f
        addCorner(bg, 9)

        local ci = Instance.new("Frame")
        ci.Size = UDim2.new(0, 14, 0, 14)
        ci.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        ci.BackgroundColor3 = COLORS.Text
        ci.BorderSizePixel = 0
        ci.Parent = bg
        addCorner(ci, 7)

        local v = default
        bg.MouseButton1Click:Connect(function()
            v = not v
            bg.BackgroundColor3 = v and COLORS.Accent or Color3.fromRGB(80, 80, 90)
            ci:TweenPosition(v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            pcall(callback, v)
        end)
    end

    -- Toggles
    makeToggle("Auto Train", false, function(v) Flags.AutoTrain = v end)
    makeToggle("Auto Punch", false, function(v) Flags.AutoPunch = v end)
    makeToggle("Auto Hatch", false, function(v) Flags.AutoHatch = v end)
    makeToggle("Anti-AFK", true, function(v) Flags.AntiAFK = v end)
    makeToggle("Inf Jump", false, function(v) Flags.InfJump = v end)
    makeToggle("NoClip", false, function(v) Flags.NoClip = v end)

    -- Equip Best Button
    local equipBtn = Instance.new("TextButton")
    equipBtn.Size = UDim2.new(1, 0, 0, 28)
    equipBtn.BackgroundColor3 = COLORS.ElementBG
    equipBtn.Text = "  ⚡ Equip Best Chickens"
    equipBtn.TextColor3 = COLORS.Text
    equipBtn.Font = Enum.Font.GothamSemibold
    equipBtn.TextSize = 11
    equipBtn.TextXAlignment = Enum.TextXAlignment.Left
    equipBtn.BorderSizePixel = 0
    equipBtn.Parent = content
    addCorner(equipBtn, 6)
    equipBtn.MouseButton1Click:Connect(function()
        SafeInvoke(Remotes.EquipBest)
        SafeNotify({Title = HUB_TITLE, Content = "Equipped best chickens!", Duration = 2})
    end)

    -- Info
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 0, 40)
    info.BackgroundTransparency = 1
    info.Text = "  ⚠️ Stealth Mode: Only RemoteEvent-based\n  features are enabled for anti-cheat safety."
    info.TextColor3 = Color3.fromRGB(160, 160, 170)
    info.Font = Enum.Font.Gotham
    info.TextSize = 10
    info.TextWrapped = true
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.Parent = content

    print("[Miles-HUB] Stealth GUI created!")
else
    warn("[Miles-HUB] Cannot create GUI — no suitable parent found")
end

SafeNotify({Title = HUB_TITLE, Content = "Stealth mode loaded! Use GUI to control features.", Duration = 5})
print("[Miles-HUB] Stealth mode loaded successfully!")
