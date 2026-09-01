--[[
    ⚡ Miles-HUB v4.1 — INLINE (no GitHub fetch needed)
    Paste langsung ke executor.
    Hotkey: RightShift = Toggle GUI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

local function Notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 4
        })
    end)
    print("[Miles-HUB] " .. text)
end

Notify("Loading...")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999

local attached = false
pcall(function() gui.Parent = gethui(); if gui.Parent then attached = true end end)
if not attached then pcall(function() gui.Parent = game:GetService("CoreGui"); if gui.Parent then attached = true end end) end
if not attached then pcall(function() gui.Parent = LP:WaitForChild("PlayerGui", 5); if gui.Parent then attached = true end end) end

if not attached then
    Notify("ERROR: GUI failed!")
    return
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 280 or 400
local guiH = isMobile and 350 or 480

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, guiW, 0, guiH)
main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color = Color3.fromRGB(60, 60, 80)

local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 32)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -32, 1, 0)
tt.Position = UDim2.new(0, 10, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "Miles-HUB v4.1"
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

local tabBtns = Instance.new("Frame", main)
tabBtns.Size = UDim2.new(0, isMobile and 70 or 90, 1, -36)
tabBtns.Position = UDim2.new(0, 0, 0, 34)
tabBtns.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
tabBtns.BorderSizePixel = 0
Instance.new("UICorner", tabBtns).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, isMobile and -76 or -96, 1, -40)
content.Position = UDim2.new(0, isMobile and 74 or 94, 0, 36)
content.BackgroundTransparency = 1

local tabContent = {}
local tabBtnList = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = " " .. name
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
        dot:TweenPosition(v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
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

-- FLAGS
local Flags = {
    InfJump = false, NoClip = false, WalkSpeed = 16, JumpPower = 50,
    AutoHatch = false, SelectedEgg = "Basic Egg", HatchDelay = 0.5,
    AutoSellOnHatch = false, AutoFuse = false, AutoTrain = false, AutoPunch = false,
    AutoCollectScrap = false, AutoTowerGrind = false,
    AutoBuyCoop = false, AutoBuyFeeder = false, AutoBuyRecycler = false,
    AntiAFK = true, FarmSpeed = 0.3,
}

-- REMOTES
local Remotes = {}
pcall(function()
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name] = obj
        end
    end
end)

local function Fire(name, ...)
    local r = Remotes[name]
    if not r then return false end
    task.wait(math.random(100, 400) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(...) else r:InvokeServer(...) end
    end)
    return true
end

-- ═══ TABS ═══

-- HOME
local home = CreateTab("Home")
Section(home, "INFO")
Btn(home, "Player: " .. LP.Name, function() end)
Btn(home, "Rejoin Server", function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end)
Btn(home, "Server Hop", function()
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
end)
Section(home, "MOVEMENT")
Toggle(home, "Inf Jump", false, function(v) Flags.InfJump = v end)
Toggle(home, "NoClip", false, function(v) Flags.NoClip = v end)
Slider(home, "WalkSpeed", 16, 250, 16, " Spd", function(v) Flags.WalkSpeed = v end)
Slider(home, "JumpPower", 50, 300, 50, " Pwr", function(v) Flags.JumpPower = v end)
Section(home, "SAFETY")
Toggle(home, "Anti-AFK", true, function(v) Flags.AntiAFK = v end)

-- EGG
local egg = CreateTab("Egg")
Section(egg, "AUTO HATCH")
Toggle(egg, "Auto Hatch", false, function(v) Flags.AutoHatch = v end)
Slider(egg, "Hatch Delay", 0.1, 2, 0.5, "s", function(v) Flags.HatchDelay = v end)
for _, en in ipairs({"Basic Egg", "Forest Egg", "Desert Egg", "Magma Egg", "Cyber Egg", "Void Egg"}) do
    Btn(egg, "Hatch " .. en, function() Flags.SelectedEgg = en end)
end
Section(egg, "SELL & FUSE")
Toggle(egg, "Auto Sell After Hatch", false, function(v) Flags.AutoSellOnHatch = v end)
Btn(egg, "Sell All Chickens", function() Fire("SellChicken", "All") end)
Toggle(egg, "Auto Fuse", false, function(v) Flags.AutoFuse = v end)
Btn(egg, "Fuse Now", function() Fire("FuseChicken", "AutoFuseDuplicates", true) end)

-- FARM
local farm = CreateTab("Farm")
Section(farm, "TOWER")
Toggle(farm, "Auto Tower Grind", false, function(v) Flags.AutoTowerGrind = v end)
Btn(farm, "Start Tower", function() Fire("TowerFight", "Start") end)
Btn(farm, "Attack", function() Fire("TowerFight", "Attack") end)
Section(farm, "TRAIN & FIGHT")
Toggle(farm, "Auto Train", false, function(v) Flags.AutoTrain = v end)
Toggle(farm, "Auto Punch", false, function(v) Flags.AutoPunch = v end)
Slider(farm, "Farm Speed", 0.1, 1, 0.3, "s", function(v) Flags.FarmSpeed = v end)
Section(farm, "COLLECT")
Toggle(farm, "Auto Collect Scrap", false, function(v) Flags.AutoCollectScrap = v end)

-- UPGRADE
local upgrade = CreateTab("Upgrade")
Section(upgrade, "COOP")
Toggle(upgrade, "Auto Buy + Upgrade Coop", false, function(v) Flags.AutoBuyCoop = v end)
Section(upgrade, "FEEDER")
Toggle(upgrade, "Auto Buy + Upgrade Feeder", false, function(v) Flags.AutoBuyFeeder = v end)
Section(upgrade, "RECYCLER")
Toggle(upgrade, "Auto Upgrade Recycler", false, function(v) Flags.AutoBuyRecycler = v end)

-- Activate first tab
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

-- RightShift toggle
pcall(function()
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            gui.Enabled = not gui.Enabled
        end
    end)
end)

-- Floating button
pcall(function()
    local fg = Instance.new("ScreenGui")
    fg.Name = "Float"
    fg.ResetOnSpawn = false
    fg.DisplayOrder = 999999
    pcall(function() fg.Parent = gethui() end)
    if not fg.Parent then pcall(function() fg.Parent = game:GetService("CoreGui") end) end
    if not fg.Parent then fg.Parent = LP:WaitForChild("PlayerGui", 5) end
    if fg.Parent then
        local fb = Instance.new("TextButton", fg)
        fb.Size = UDim2.new(0, 50, 0, 50)
        fb.Position = UDim2.new(0, 10, 0.3, 0)
        fb.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        fb.Text = "+"
        fb.TextColor3 = Color3.fromRGB(168, 85, 247)
        fb.Font = Enum.Font.GothamBold
        fb.TextSize = 20
        fb.TextTransparency = 0.3
        fb.Active = true
        fb.Draggable = true
        fb.BorderSizePixel = 0
        Instance.new("UICorner", fb).CornerRadius = UDim.new(0.5, 0)
        Instance.new("UIStroke", fb).Color = Color3.fromRGB(168, 85, 247)
        fb.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)
    end
end)

-- ═══ FEATURES ═══

-- InfJump
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Flags.InfJump then
            pcall(function()
                local c = LP.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end)
end)

-- Speed/NoClip
pcall(function()
    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local c = LP.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h then
                        if Flags.WalkSpeed > 16 then h.WalkSpeed = Flags.WalkSpeed end
                        if Flags.JumpPower > 50 then h.JumpPower = Flags.JumpPower end
                        if Flags.NoClip then
                            for _, part in ipairs(c:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

-- Anti-AFK
pcall(function()
    LP.Idled:Connect(function()
        if Flags.AntiAFK then
            pcall(function()
                local VIM = game:GetService("VirtualInputManager")
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                task.wait(0.1)
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end)
        end
    end)
end)

-- Auto loops
task.spawn(function() while task.wait(1) do if Flags.AutoHatch then pcall(function() Fire("HatchEgg", Flags.SelectedEgg, 1) end) end task.wait(Flags.HatchDelay) if Flags.AutoSellOnHatch then pcall(function() Fire("SellChicken", "All") end) end end end)
task.spawn(function() while task.wait(3) do if Flags.AutoFuse then pcall(function() Fire("FuseChicken", "AutoFuseDuplicates", true) end) end end end)
task.spawn(function() while task.wait(1) do if Flags.AutoTrain then pcall(function() Fire("Train") end) end if Flags.AutoPunch then pcall(function() Fire("Punch") end) end task.wait(Flags.FarmSpeed) end end)
task.spawn(function() while task.wait(2) do if Flags.AutoTowerGrind then pcall(function() Fire("FeedChicken", "All"); Fire("TowerFight", "Start"); Fire("TowerFight", "Attack"); Fire("TowerFight", "NextFloor") end) end end end)
task.spawn(function() while task.wait(2) do pcall(function() if Flags.AutoBuyCoop then Fire("BuyCoop", "Buy"); Fire("UpgradeCoop", "Upgrade") end if Flags.AutoBuyFeeder then Fire("BuyFeeder", "Buy"); Fire("UpgradeFeeder", "Upgrade") end if Flags.AutoBuyRecycler then Fire("UpgradeRecycler", "Buy"); Fire("UpgradeRecycler", "Upgrade") end end) end end)
task.spawn(function() while task.wait(2) do if Flags.AutoCollectScrap then pcall(function() Fire("CollectScrap") end) end end)

Notify("Loaded! RightShift = toggle GUI")
print("[Miles-HUB] v4.1 INLINE loaded!")