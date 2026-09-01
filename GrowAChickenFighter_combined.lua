--[[
    ⚡ Miles-HUB v2.4 — COMBINED (all features, no HTTP dependency)
    
    Paste this ENTIRE script into your executor's editor, then click EXECUTE.
    Do NOT use loadstring with HttpGet — your executor doesn't support it.
    
    Hotkey: RightShift = Toggle GUI on/off
    
    Run this DIRECTLY in your executor (no loader needed).
    Every step has a VISIBLE notification so you know exactly where it stops.
    
    Features:
    - Full GUI with tabs (Home, Egg, Farm, Upgrade, Settings)
    - Auto Hatch / Sell / Fuse
    - Tower & Rebirth
    - Farm Upgrades
    - WalkSpeed / JumpPower / InfJump / NoClip
    - Anti-AFK
    - Server Hop
]]

-- ═══ STEP 0: Error trap — catch EVERYTHING so script never silently dies ═══
local function SafeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[Miles-HUB] Error:", err) end
    return ok, err
end

-- ═══ STEP 1: Basic services (instant, no wait) ═══
task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

print("[Miles-HUB] v2.3 starting...")
print("[Miles-HUB] Player:", LP.Name)
print("[Miles-HUB] Executor:", (identifyexecutor and identifyexecutor()) or "unknown")

-- ═══ VISIBLE NOTIFICATION SYSTEM ═══
-- Creates a small on-screen notification that ALWAYS shows,
-- even when StarterGui:SetCore doesn't work on your executor.

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "MilesHub_Notif"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.DisplayOrder = 999999
NotifGui.IgnoreGuiInset = true

-- Find best parent for notification GUI
local notifParent = nil
local parentNames = {}

-- Try gethui() first (executors like Synapse, KRNL, Fluxus)
if gethui and type(gethui) == "function" then
    local ok, hui = pcall(gethui)
    if ok and hui then
        local ok2 = pcall(function() NotifGui.Parent = hui end)
        if ok2 and NotifGui.Parent then
            notifParent = hui
            table.insert(parentNames, "gethui ✓")
        end
    end
end

-- Try CoreGui
if not notifParent then
    local ok = pcall(function() NotifGui.Parent = game:GetService("CoreGui") end)
    if ok and NotifGui.Parent then
        notifParent = NotifGui.Parent
        table.insert(parentNames, "CoreGui ✓")
    else
        table.insert(parentNames, "CoreGui ✗")
    end
end

-- Try PlayerGui (last resort)
if not notifParent then
    local ok = pcall(function() NotifGui.Parent = LP:WaitForChild("PlayerGui", 5) end)
    if ok and NotifGui.Parent then
        notifParent = NotifGui.Parent
        table.insert(parentNames, "PlayerGui ✓")
    else
        table.insert(parentNames, "PlayerGui ✗")
    end
end

print("[Miles-HUB] GUI parents tried:", table.concat(parentNames, ", "))

-- Notify function: shows BOTH on-screen toast AND console print
local function Notify(text)
    print("[Miles-HUB] >> " .. text)
    
    -- StarterGui:SetCore notification (works on some executors)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "⚡ Miles-HUB",
            Text = text,
            Duration = 5
        })
    end)
    
    -- VISIBLE on-screen toast (always works)
    pcall(function()
        local toast = Instance.new("Frame")
        toast.Size = UDim2.new(0, 300, 0, 50)
        toast.Position = UDim2.new(0.5, -150, 0, 10)
        toast.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
        toast.BorderSizePixel = 0
        toast.ZIndex = 1000000
        toast.Parent = NotifGui
        Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", toast)
        stroke.Color = Color3.fromRGB(130, 90, 220)
        stroke.Thickness = 1
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -16, 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "⚡ " .. text
        label.TextColor3 = Color3.fromRGB(240, 240, 240)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.ZIndex = 1000001
        label.Parent = toast
        
        -- Auto-destroy after 4 seconds
        task.delay(4, function()
            if toast and toast.Parent then
                -- Fade out
                for i = 0, 10 do
                    toast.BackgroundTransparency = i / 10
                    label.TextTransparency = i / 10
                    task.wait(0.05)
                end
                toast:Destroy()
            end
        end)
    end)
end

Notify("v2.4 Loaded OK")

-- ═══ STEP 2: Character (with TIMEOUT — won't hang) ═══
local Char, Hum, HRP
local charReady = false

local function SetupCharacter(c)
    Char = c
    Hum = nil
    HRP = nil
    pcall(function()
        Hum = c:WaitForChild("Humanoid", 10)
        HRP = c:WaitForChild("HumanoidRootPart", 10)
    end)
    charReady = (Hum and HRP) and true or false
end

if LP.Character then
    SetupCharacter(LP.Character)
end
LP.CharacterAdded:Connect(SetupCharacter)

-- Wait max 5 seconds for character
for i = 1, 10 do
    if charReady then break end
    task.wait(0.5)
end

if charReady then
    Notify("Step 2: Character OK")
else
    Notify("Step 2: Character delayed (GUI still works)")
end

-- ═══ STEP 3: Remote Scanner ═══
local Remotes = {}
pcall(function()
    task.wait(1)
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name] = obj
        end
    end
end)

local rCount = 0
for _ in pairs(Remotes) do rCount = rCount + 1 end
Notify("Step 3: Found " .. rCount .. " remotes")

-- Print remote names for debugging
for name, _ in pairs(Remotes) do
    print("[Miles-HUB] Remote:", name)
end

-- ═══ Safe Remote Fire ═══
local function Fire(name, ...)
    local r = Remotes[name]
    if not r then return false end
    task.wait(math.random(50, 150) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then
            r:FireServer(...)
        else
            r:InvokeServer(...)
        end
    end)
    return true
end

-- ═══ Flags ═══
local Flags = {
    InfJump = false,
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AutoHatch = false,
    SelectedEgg = "Basic Egg",
    HatchDelay = 0.5,
    AutoSellOnHatch = false,
    AutoFuse = false,
    AutoTrain = false,
    AutoPunch = false,
    AutoCollectScrap = false,
    AutoTowerGrind = false,
    AutoBuyCoop = false,
    AutoBuyFeeder = false,
    AutoBuyRecycler = false,
    AntiAFK = true,
    AutoReconnect = false,
    FarmSpeed = 0.1,
}

-- ═══ STEP 4: Client-side features ═══

-- InfJump
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Flags.InfJump and Hum then
            Hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- NoClip
RunService.Stepped:Connect(function()
    if Flags.NoClip and Char then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then
                p.CanCollide = false
            end
        end
    end
end)

-- Speed/Jump heartbeat
RunService.Heartbeat:Connect(function()
    if Hum then
        if Flags.WalkSpeed > 16 then Hum.WalkSpeed = Flags.WalkSpeed end
        if Flags.JumpPower > 50 then Hum.JumpPower = Flags.JumpPower end
    end
end)

-- Anti-AFK
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if Flags.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end
    end)
end)

-- Rejoin on disconnect
pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if Flags.AutoReconnect then
            task.wait(2)
            TeleportService:Teleport(game.PlaceId, LP)
        end
    end)
end)

Notify("Step 4: Client features OK")

-- ═══ STEP 5: Background auto loops ═══

-- Auto Hatch loop
task.spawn(function()
    while true do
        if Flags.AutoHatch then
            pcall(function() Fire("HatchEgg", Flags.SelectedEgg, 1) end)
            if Flags.AutoSellOnHatch then
                task.wait(0.2)
                pcall(function() Fire("SellChicken", "All") end)
            end
        end
        task.wait(Flags.HatchDelay)
    end
end)

-- Auto Fuse loop
task.spawn(function()
    while true do
        if Flags.AutoFuse then
            pcall(function() Fire("FuseChicken", "AutoFuseDuplicates", true) end)
        end
        task.wait(2)
    end
end)

-- Auto Train loop
task.spawn(function()
    while true do
        if Flags.AutoTrain then pcall(function() Fire("Train") end) end
        if Flags.AutoPunch then pcall(function() Fire("Punch") end) end
        task.wait(Flags.FarmSpeed)
    end
end)

-- Auto Tower loop
task.spawn(function()
    while true do
        if Flags.AutoTowerGrind then
            pcall(function()
                Fire("FeedChicken", "All")
                Fire("TowerFight", "Start")
                Fire("TowerFight", "Attack")
                Fire("TowerFight", "NextFloor")
            end)
        end
        task.wait(0.3)
    end
end)

-- Auto Buy/Upgrade loop
task.spawn(function()
    while true do
        pcall(function()
            if Flags.AutoBuyCoop then
                Fire("BuyCoop", "Buy")
                Fire("UpgradeCoop", "Upgrade")
            end
            if Flags.AutoBuyFeeder then
                Fire("BuyFeeder", "Buy")
                Fire("UpgradeFeeder", "Upgrade")
            end
            if Flags.AutoBuyRecycler then
                Fire("UpgradeRecycler", "Buy")
                Fire("UpgradeRecycler", "Upgrade")
            end
        end)
        task.wait(1)
    end
end)

-- Auto Collect Scrap loop
task.spawn(function()
    while true do
        if Flags.AutoCollectScrap and Char and HRP then
            pcall(function()
                Fire("CollectScrap")
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local nl = obj.Name:lower()
                        if string.find(nl, "scrap") or string.find(nl, "trash") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - HRP.Position).Magnitude <= 50 then
                                if firetouchinterest then
                                    firetouchinterest(HRP, part, 0)
                                    task.wait(0.05)
                                    firetouchinterest(HRP, part, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

Notify("Step 5: Auto loops OK")

-- ═══ STEP 6: GUI ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 280 or 400
local guiH = isMobile and 350 or 480

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999

-- Mobile-safe parent — try ALL options, with extra safety
local guiParent = nil

-- 1. gethui() — executor custom UI container
pcall(function()
    if gethui and type(gethui) == "function" then
        local hui = gethui()
        if hui then
            gui.Parent = hui
            if gui.Parent then guiParent = hui end
        end
    end
end)

-- 2. CoreGui — standard Roblox internal GUI
if not guiParent then
    pcall(function()
        gui.Parent = game:GetService("CoreGui")
        if gui.Parent then guiParent = gui.Parent end
    end)
end

-- 3. PlayerGui — always works, but visible to other scripts
if not guiParent then
    pcall(function()
        local pg = LP:WaitForChild("PlayerGui", 5)
        if pg then
            gui.Parent = pg
            if gui.Parent then guiParent = pg end
        end
    end)
end

if not guiParent then
    warn("[Miles-HUB] CRITICAL: Could not parent GUI anywhere!")
    Notify("ERROR: GUI parent failed!")
else
    print("[Miles-HUB] GUI parented to:", guiParent:GetFullName())
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, guiW, 0, guiH)
main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color = Color3.fromRGB(60, 60, 80)

-- Title bar
local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 32)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -32, 1, 0)
tt.Position = UDim2.new(0, 10, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "⚡ Miles-HUB v2.3"
tt.TextColor3 = Color3.fromRGB(240, 240, 240)
tt.Font = Enum.Font.GothamBold
tt.TextSize = 13
tt.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

-- Tab buttons (left sidebar)
local tabBtns = Instance.new("Frame", main)
tabBtns.Size = UDim2.new(0, isMobile and 70 or 90, 1, -36)
tabBtns.Position = UDim2.new(0, 0, 0, 34)
tabBtns.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
tabBtns.BorderSizePixel = 0
Instance.new("UICorner", tabBtns).CornerRadius = UDim.new(0, 8)

-- Content area
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, isMobile and -76 or -96, 1, -40)
content.Position = UDim2.new(0, isMobile and 74 or 94, 0, 36)
content.BackgroundTransparency = 1

local tabContent = {}
local tabBtnList = {}

-- ═══ UI Helper functions ═══
local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = (icon or "") .. " " .. name
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = isMobile and 8 or 10
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local frame = Instance.new("ScrollingFrame", content)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3
    frame.ScrollBarImageColor3 = Color3.fromRGB(130, 90, 220)
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 3)
    Instance.new("UIPadding", frame).PaddingTop = UDim.new(0, 2)

    tabContent[name] = frame
    tabBtnList[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabContent) do f.Visible = false end
        for _, b in pairs(tabBtnList) do
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            b.TextColor3 = Color3.fromRGB(160, 160, 170)
        end
        frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)

    return frame
end

local function Section(parent, text)
    local s = Instance.new("TextLabel", parent)
    s.Size = UDim2.new(1, 0, 0, 18)
    s.BackgroundTransparency = 1
    s.Text = "  " .. text
    s.TextColor3 = Color3.fromRGB(130, 90, 220)
    s.Font = Enum.Font.GothamBold
    s.TextSize = isMobile and 9 or 10
    s.TextXAlignment = Enum.TextXAlignment.Left
end

local function Toggle(parent, name, default, callback)
    local f = Instance.new("Frame", parent)
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
    l.TextSize = isMobile and 9 or 11
    l.TextXAlignment = Enum.TextXAlignment.Left

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 36, 0, 16)
    b.Position = UDim2.new(1, -40, 0.5, -8)
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

local function Btn(parent, name, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = isMobile and 9 or 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(35, 35, 50) end)
end

local function Slider(parent, name, min, max, default, suffix, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 38)
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
    l.TextSize = isMobile and 8 or 10
    l.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.4, 0, 0, 16)
    val.Position = UDim2.new(0.58, 0, 0, 2)
    val.BackgroundTransparency = 1
    val.Text = tostring(default) .. (suffix or "")
    val.TextColor3 = Color3.fromRGB(130, 90, 220)
    val.Font = Enum.Font.GothamBold
    val.TextSize = isMobile and 8 or 10
    val.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -12, 0, 6)
    bar.Position = UDim2.new(0, 6, 0, 24)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

    local cur = default
    local pct = (cur - min) / (max - min)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("TextButton", bar)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(math.clamp(pct, 0, 1), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)

    local dragging = false
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
            val.Text = tostring(cur) .. (suffix or "")
            pcall(callback, cur)
        end
    end)
end

-- ═══ TAB: HOME ═══
local home = CreateTab("Home")
Section(home, "ℹ️ INFO")
Btn(home, "Player: " .. LP.Name, function() end)
Btn(home, "Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LP) end)
Btn(home, "Server Hop (Sepi)", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            table.sort(d.data, function(a, b) return a.playing < b.playing end)
            for _, s in ipairs(d.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                    return
                end
            end
        end
    end)
    Notify("No empty server found")
end)

Section(home, "🏃 MOVEMENT")
Toggle(home, "Inf Jump", false, function(v) Flags.InfJump = v end)
Toggle(home, "NoClip", false, function(v) Flags.NoClip = v end)
Slider(home, "WalkSpeed", 16, 250, 16, " Spd", function(v) Flags.WalkSpeed = v end)
Slider(home, "JumpPower", 50, 300, 50, " Pwr", function(v) Flags.JumpPower = v end)

Section(home, "🛡️ SAFETY")
Toggle(home, "Anti-AFK", true, function(v) Flags.AntiAFK = v end)
Toggle(home, "Auto Rejoin on Kick", false, function(v) Flags.AutoReconnect = v end)

-- ═══ TAB: EGG ═══
local egg = CreateTab("Egg")
Section(egg, "🥚 AUTO HATCH")
Toggle(egg, "Auto Hatch", false, function(v) Flags.AutoHatch = v end)
Slider(egg, "Hatch Delay", 0.1, 2, 0.5, "s", function(v) Flags.HatchDelay = v end)

local eggOptions = {"Basic Egg", "Forest Egg", "Desert Egg", "Magma Egg", "Cyber Egg", "Void Egg"}
for _, eggName in ipairs(eggOptions) do
    Btn(egg, "Hatch " .. eggName, function()
        Flags.SelectedEgg = eggName
        Fire("HatchEgg", eggName, 1)
        Notify("Hatching: " .. eggName)
    end)
end

Section(egg, "💰 SELL & FUSE")
Toggle(egg, "Auto Sell All After Hatch", false, function(v) Flags.AutoSellOnHatch = v end)
Btn(egg, "💵 Sell All Chickens Now", function() Fire("SellChicken", "All"); Notify("Sold all chickens!") end)
Toggle(egg, "Auto Fuse Duplicates", false, function(v) Flags.AutoFuse = v end)
Btn(egg, "🧬 Fuse Now", function() Fire("FuseChicken", "AutoFuseDuplicates", true); Notify("Fuse sent!") end)
Btn(egg, "⚡ Equip Best Chickens", function() Fire("EquipBest"); Notify("Equipped best!") end)

-- ═══ TAB: FARM ═══
local farm = CreateTab("Farm")
Section(farm, "🗼 TOWER")
Toggle(farm, "Auto Tower Grind", false, function(v) Flags.AutoTowerGrind = v end)
Btn(farm, "⚔️ Start Tower", function() Fire("TowerFight", "Start") end)
Btn(farm, "🗡️ Attack", function() Fire("TowerFight", "Attack") end)
Btn(farm, "⬆️ Next Floor", function() Fire("TowerFight", "NextFloor") end)

Section(farm, "💪 TRAIN & FIGHT")
Toggle(farm, "Auto Train", false, function(v) Flags.AutoTrain = v end)
Toggle(farm, "Auto Punch", false, function(v) Flags.AutoPunch = v end)
Slider(farm, "Farm Speed", 0.05, 1, 0.1, "s", function(v) Flags.FarmSpeed = v end)

Section(farm, "♻️ REBIRTH")
Btn(farm, "🔄 Rebirth Now", function()
    Fire("CollectScrap")
    task.wait(0.1)
    Fire("RecycleScrap", "All")
    task.wait(0.1)
    Fire("Rebirth", "DoRebirth")
    Notify("Rebirth executed!")
end)

Section(farm, "📦 COLLECT")
Btn(farm, "🥚 Collect Eggs", function() Fire("CollectEgg"); Notify("Collect eggs sent!") end)
Toggle(farm, "Auto Collect Scrap", false, function(v) Flags.AutoCollectScrap = v end)

-- ═══ TAB: UPGRADE ═══
local upgrade = CreateTab("Upgrade")
Section(upgrade, "🏠 COOP")
Toggle(upgrade, "Auto Buy + Upgrade Coop", false, function(v) Flags.AutoBuyCoop = v end)
Btn(upgrade, "Buy Coop", function() Fire("BuyCoop", "Buy") end)
Btn(upgrade, "Upgrade Coop", function() Fire("UpgradeCoop", "Upgrade") end)

Section(upgrade, "🍽️ FEEDER")
Toggle(upgrade, "Auto Buy + Upgrade Feeder", false, function(v) Flags.AutoBuyFeeder = v end)
Btn(upgrade, "Buy Feeder", function() Fire("BuyFeeder", "Buy") end)
Btn(upgrade, "Upgrade Feeder", function() Fire("UpgradeFeeder", "Upgrade") end)

Section(upgrade, "♻️ RECYCLER")
Toggle(upgrade, "Auto Upgrade Recycler", false, function(v) Flags.AutoBuyRecycler = v end)
Btn(upgrade, "Upgrade Recycler", function() Fire("UpgradeRecycler", "Buy"); Fire("UpgradeRecycler", "Upgrade") end)

Section(upgrade, "🍗 FEED")
Btn(upgrade, "Feed All Chickens", function() Fire("FeedChicken", "All"); Notify("Fed all chickens!") end)

-- ═══ Activate first tab ═══
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

-- ═══ STEP 7: Floating toggle button ═══
pcall(function()
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "MilesHub_Float"
    floatGui.ResetOnSpawn = false
    floatGui.DisplayOrder = 999999

    local floatParent = nil
    for _, p in ipairs({
        gethui and type(gethui) == "function" and gethui() or nil,
        guiParent,  -- Use same parent as main GUI
    }) do
        if p then
            local ok = pcall(function() floatGui.Parent = p end)
            if ok and floatGui.Parent then floatParent = p break end
        end
    end

    if floatGui.Parent then
        local fb = Instance.new("TextButton", floatGui)
        fb.Size = UDim2.new(0, 50, 0, 50)
        fb.Position = UDim2.new(0, 10, 0.3, 0)
        fb.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        fb.Text = "⚡"
        fb.TextColor3 = Color3.fromRGB(168, 85, 247)
        fb.Font = Enum.Font.GothamBold
        fb.TextSize = 20
        fb.TextTransparency = 0.3
        fb.Active = true
        fb.Draggable = true
        fb.BorderSizePixel = 0
        Instance.new("UICorner", fb).CornerRadius = UDim.new(0.5, 0)
        Instance.new("UIStroke", fb).Color = Color3.fromRGB(168, 85, 247)

        fb.MouseButton1Click:Connect(function()
            gui.Enabled = not gui.Enabled
        end)
    end
end)

-- ═══ RightShift keybind to toggle GUI ═══
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            gui.Enabled = not gui.Enabled
        end
    end)
end)

-- ═══ DONE ═══
Notify("Step 6+7: GUI OK — All loaded! ⚡")
print("[Miles-HUB] v2.4 COMBINED loaded successfully ✓")
print("[Miles-HUB] RightShift to toggle GUI")
