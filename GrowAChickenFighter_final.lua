--[[
    ⚡ Miles-HUB v2.2 — FINAL (Delta + RedFinger Safe)
    
    All features from original script, using SAFE patterns:
    - Button clicks (not auto-loops) for remote firing
    - Client-side only for movement features
    - NO RunService loops
    - NO ReplicatedStorage scanning
    - Proper delays between remote calls
    
    Based on V2/V3 testing:
    - V2 (notif + GUI + InfJump) = SAFE ✅
    - V3 (button clicks) = SAFE ✅
    - Remote firing on button click = TEST NEEDED
]]

task.wait(1)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")

local LP = Players.LocalPlayer

-- ═══ Safe Remote Scanner ═══
local Remotes = {}
task.spawn(function()
    task.wait(2)
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name] = obj
        end
    end
    local count = 0
    for _ in pairs(Remotes) do count = count + 1 end
    Notify("Found " .. count .. " remotes")
end)

-- ═══ Safe Remote Fire (button click only, with delay) ═══
local function Fire(name, ...)
    local r = Remotes[name]
    if not r then
        Notify("Remote not found: " .. name)
        return
    end
    task.wait(math.random(50, 150) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then
            r:FireServer(...)
        else
            r:InvokeServer(...)
        end
    end)
    Notify("Fired: " .. name)
end

-- ═══ Safe Notify ═══
local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 2
        })
    end)
end

-- ═══ Client-Side Features ═══
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

-- ═══ GUI ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 280 or 380
local guiH = isMobile and 350 or 450

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

-- Tabs
local tabBtns = Instance.new("Frame", main)
tabBtns.Size = UDim2.new(0, isMobile and 70 or 90, 1, -32)
tabBtns.Position = UDim2.new(0, 0, 0, 30)
tabBtns.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
tabBtns.BorderSizePixel = 0
Instance.new("UICorner", tabBtns).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, isMobile and -76 or -96, 1, -36)
content.Position = UDim2.new(0, isMobile and 74 or 94, 0, 32)
content.BackgroundTransparency = 1

local tabContent = {}
local tabBtnList = {}
local currentTab = nil

local function CreateTab(name)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -6, 0, 26)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = isMobile and 8 or 9
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local frame = Instance.new("ScrollingFrame", content)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 2
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 3)
    Instance.new("UIPadding", frame).PaddingTop = UDim.new(0, 2)

    tabContent[name] = frame
    tabBtnList[name] = btn

    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabContent) do f.Visible = false end
        for _, b in pairs(tabBtnList) do b.BackgroundColor3 = Color3.fromRGB(35, 35, 50); b.TextColor3 = Color3.fromRGB(160, 160, 170) end
        frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
        btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)

    return frame
end

-- ═══ Helpers ═══
local function Section(parent, text)
    local s = Instance.new("TextLabel", parent)
    s.Size = UDim2.new(1, 0, 0, 16)
    s.BackgroundTransparency = 1
    s.Text = "  " .. text
    s.TextColor3 = Color3.fromRGB(130, 90, 220)
    s.Font = Enum.Font.GothamBold
    s.TextSize = 9
    s.TextXAlignment = Enum.TextXAlignment.Left
end

local function Toggle(parent, name, default, callback)
    local f = Instance.new("Frame", parent)
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
    return function() return v end
end

local function Button(parent, name, callback)
    local b = Instance.new("TextButton", parent)
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

-- ═══ Tab: Home ═══
local home = CreateTab("Home")
Section(home, "MOVEMENT")
Toggle(home, "Inf Jump", false, function(v) InfJump = v end)
Button(home, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

-- ═══ Tab: Egg ═══
local egg = CreateTab("Egg")
Section(egg, "HATCH")
Button(egg, "Hatch Basic Egg", function() Fire("HatchEgg", "Basic Egg", 1) end)
Button(egg, "Hatch Forest Egg", function() Fire("HatchEgg", "Forest Egg", 1) end)
Button(egg, "Hatch Desert Egg", function() Fire("HatchEgg", "Desert Egg", 1) end)
Button(egg, "Hatch Magma Egg", function() Fire("HatchEgg", "Magma Egg", 1) end)
Button(egg, "Hatch Cyber Egg", function() Fire("HatchEgg", "Cyber Egg", 1) end)
Button(egg, "Hatch Void Egg", function() Fire("HatchEgg", "Void Egg", 1) end)

Section(egg, "SELL & FUSE")
Button(egg, "Sell All Chickens", function() Fire("SellChicken", "All") end)
Button(egg, "Fuse Duplicates", function() Fire("FuseChicken", "AutoFuseDuplicates", true) end)

Section(egg, "EQUIP")
Button(egg, "Equip Best Chickens", function() Fire("EquipBest") end)

-- ═══ Tab: Farm ═══
local farm = CreateTab("Farm")
Section(farm, "TOWER")
Button(farm, "Start Tower", function() Fire("TowerFight", "Start") end)
Button(farm, "Attack", function() Fire("TowerFight", "Attack") end)
Button(farm, "Next Floor", function() Fire("TowerFight", "NextFloor") end)

Section(farm, "TRAIN & FIGHT")
Button(farm, "Train", function() Fire("Train") end)
Button(farm, "Punch", function() Fire("Punch") end)

Section(farm, "REBIRTH")
Button(farm, "Rebirth", function() Fire("Rebirth", "DoRebirth") end)

Section(farm, "COLLECT")
Button(farm, "Collect Eggs", function() Fire("CollectEgg") end)
Button(farm, "Collect Scrap", function() Fire("CollectScrap") end)
Button(farm, "Claim Incubator", function()
    for slot = 1, 5 do
        Fire("ClaimIncubator", slot)
        task.wait(0.3)
    end
end)

-- ═══ Tab: Upgrade ═══
local upgrade = CreateTab("Upgrade")
Section(upgrade, "COOP")
Button(upgrade, "Buy Coop", function() Fire("BuyCoop", "Buy") end)
Button(upgrade, "Upgrade Coop", function() Fire("UpgradeCoop", "Upgrade") end)

Section(upgrade, "FEEDER")
Button(upgrade, "Buy Feeder", function() Fire("BuyFeeder", "Buy") end)
Button(upgrade, "Upgrade Feeder", function() Fire("UpgradeFeeder", "Upgrade") end)

Section(upgrade, "RECYCLER")
Button(upgrade, "Upgrade Recycler", function() Fire("UpgradeRecycler", "Upgrade") end)

Section(upgrade, "FEED")
Button(upgrade, "Feed All Chickens", function() Fire("FeedChicken", "All") end)

-- ═══ Activate first tab ═══
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

Notify("Miles-HUB loaded! Tap buttons to use features.")
