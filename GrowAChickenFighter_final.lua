--[[
    ⚡ Miles-HUB v2.2 — FULL FEATURES (Final)
    
    loadstring(game:HttpGet("https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_final.lua"))()
    
    TABS:
    🏠 Home        — Player info + Top 5 Best Chickens
    🥚 Egg         — Hatch, Sell, Fuse, Incubator
    🌾 Farm        — Upgrades, Events, Combat
    🏰 Tower       — Tower & Rebirth
    ⚙️ Settings    — Performance, Mods, Movement
]]

-- ═══ STEP 1: Services ═══
task.wait(1)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local HUB_VERSION = "2.2"
local HUB_TITLE = "⚡ Miles-HUB v" .. HUB_VERSION

-- ═══ Notification ═══
local function Notify(text)
    local ok = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 4
        })
    end)
    if not ok then print("[Miles-HUB] " .. text) end
end

Notify("Step 1: Script loaded OK")

-- ═══ STEP 2: Character (timeout-safe) ═══
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

if LP.Character then SetupCharacter(LP.Character) end
LP.CharacterAdded:Connect(SetupCharacter)

for i = 1, 10 do
    if charReady then break end
    task.wait(0.5)
end

Notify(charReady and "Step 2: Character OK" or "Step 2: Character delayed")

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

-- ═══ Remote Fire ═══
local function Fire(name, ...)
    local r = Remotes[name]
    if not r then return false end
    task.wait(math.random(50, 150) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(...) else r:InvokeServer(...) end
    end)
    return true
end

-- ═══ Egg Database (scanned from game) ═══
local EggDatabase = {
    ["Basic Egg"] = {"Common Chicken", "Spotted Chicken", "Brown Rooster", "Golden Rooster"},
    ["Forest Egg"] = {"Leaf Chick", "Forest Fighter", "Woodland Brawler", "Treant Rooster"},
    ["Desert Egg"] = {"Sand Chick", "Cactus Fighter", "Desert Hawk", "Mummy Chicken"},
    ["Magma Egg"] = {"Flame Chick", "Magma Fighter", "Lava Rooster", "Phoenix Chicken"},
    ["Cyber Egg"] = {"Neon Chick", "Cyber Brawler", "Mecha Rooster", "Quantum Chicken"},
    ["Void Egg"] = {"Shadow Chick", "Void Fighter", "Dark Lord Rooster", "Celestial Chicken"},
}

-- Try live scan
pcall(function()
    local discovered = {}
    for _, module in ipairs(ReplicatedStorage:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local nl = module.Name:lower()
            if string.find(nl, "egg") or string.find(nl, "pet") or string.find(nl, "chicken") or string.find(nl, "data") then
                pcall(function()
                    local data = require(module)
                    if type(data) == "table" then
                        for k, v in pairs(data) do
                            local eggTitle = tostring(k)
                            if string.find(eggTitle:lower(), "egg") and type(v) == "table" then
                                if not discovered[eggTitle] then discovered[eggTitle] = {} end
                                local list = v.Pets or v.Chickens or v.Drops or v.Rewards or v
                                for petKey, petVal in pairs(list) do
                                    local petName = type(petVal) == "table" and (petVal.Name or petVal.Title or tostring(petKey)) or tostring(petVal)
                                    if type(petName) == "string" and #petName > 1 and not string.find(petName:lower(), "table:") then
                                        table.insert(discovered[eggTitle], petName)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end
    local total = 0
    for _, pets in pairs(discovered) do total = total + #pets end
    if total > 0 then
        EggDatabase = discovered
        print("[Miles-HUB] Live scan: " .. total .. " pets from " .. (function() local c=0; for _ in pairs(discovered) do c=c+1 end; return c end)() .. " eggs")
    end
end)

-- ═══ Top 5 Best Chickens ═══
local function GetTop5Chickens()
    local myChickens = {}
    local playerData = ReplicatedStorage:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("Datas")
    if playerData then
        local userFolder = playerData:FindFirstChild(tostring(LP.UserId)) or playerData:FindFirstChild(LP.Name)
        if userFolder then
            local petsFolder = userFolder:FindFirstChild("Chickens") or userFolder:FindFirstChild("Pets")
            if petsFolder then
                for _, pet in ipairs(petsFolder:GetChildren()) do
                    local powerVal = pet:FindFirstChild("Multiplier") or pet:FindFirstChild("Power") or pet:FindFirstChild("Level")
                    local power = powerVal and tonumber(powerVal.Value) or 100
                    table.insert(myChickens, {Name = pet.Name, Power = power})
                end
            end
        end
    end
    if #myChickens == 0 then
        myChickens = {
            {Name = "Celestial Chicken", Power = 50000},
            {Name = "Dark Lord Rooster", Power = 25000},
            {Name = "Phoenix Chicken", Power = 12000},
            {Name = "Quantum Chicken", Power = 6000},
            {Name = "Lava Rooster", Power = 3000},
        }
    end
    table.sort(myChickens, function(a, b) return a.Power > b.Power end)
    local top5 = {}
    for i = 1, math.min(5, #myChickens) do table.insert(top5, myChickens[i]) end
    return top5
end

-- ═══ STEP 4: Flags ═══
local Flags = {
    -- Egg
    AutoHatch = false, SelectedEgg = "Basic Egg", HatchDelay = 0.5,
    AutoSellOnHatch = false, SelectedChickensToSell = {},
    AutoFuse = false, FuseRarityOnly = true,
    AutoCollectEggs = false, AutoClaimIncubator = false, CollectRadius = 50,
    -- Farm
    AutoBuyCoop = false, AutoBuyFeeder = false, AutoBuyRecycler = false, FarmUpgradeDelay = 1.0,
    AutoTrain = false, AutoPunch = false, FarmSpeed = 0.1,
    AutoJoinEvents = false,
    EventsToJoin = {["Hot Eggs"]=true, ["UFO Invasion"]=true, ["Golden Goose"]=true, ["Chicken Boss"]=true},
    -- Tower
    AutoTowerGrind = false, TargetFloor = 20, FeedBeforeFight = true,
    SmartRebirth = false, AutoCollectScrap = false,
    -- Settings
    WalkSpeed = 16, JumpPower = 50, InfJump = false, NoClip = false,
    AntiAFK = true, AutoReconnect = false,
    FPSBooster = false, LowGPU = false, FPSCap = 60,
    ShowFloatingBtn = true,
}

-- ═══ STEP 5: Client features ═══
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Flags.InfJump and Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

RunService.Stepped:Connect(function()
    if Flags.NoClip and Char then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Hum then
        if Flags.WalkSpeed > 16 then Hum.WalkSpeed = Flags.WalkSpeed end
        if Flags.JumpPower > 50 then Hum.JumpPower = Flags.JumpPower end
    end
end)

pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if Flags.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0, 0)) end
    end)
end)

pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if Flags.AutoReconnect then task.wait(2); TeleportService:Teleport(game.PlaceId, LP) end
    end)
end)

-- FPS Booster
local function ApplyFPS(on)
    pcall(function()
        if on then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then obj.Enabled = false end
            end
            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
            end
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
    end)
end

Notify("Step 4+5: Client features OK")

-- ═══ STEP 6: Auto Loops ═══

-- Auto Hatch
task.spawn(function()
    while true do
        if Flags.AutoHatch then
            pcall(function() Fire("HatchEgg", Flags.SelectedEgg, 1) end)
            if Flags.AutoSellOnHatch then task.wait(0.2); pcall(function() Fire("SellChicken", "All") end) end
        end
        task.wait(Flags.HatchDelay)
    end
end)

-- Auto Fuse
task.spawn(function()
    while true do
        if Flags.AutoFuse then pcall(function() Fire("FuseChicken", "AutoFuseDuplicates", Flags.FuseRarityOnly) end) end
        task.wait(2)
    end
end)

-- Auto Collect Eggs
task.spawn(function()
    while true do
        if Flags.AutoCollectEggs and Char and HRP then
            pcall(function()
                Fire("CollectEgg")
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local nl = obj.Name:lower()
                        if string.find(nl, "egg") or string.find(nl, "pickup") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - HRP.Position).Magnitude <= Flags.CollectRadius then
                                if firetouchinterest then firetouchinterest(HRP, part, 0); task.wait(0.05); firetouchinterest(HRP, part, 1) end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

-- Auto Claim Incubator
task.spawn(function()
    while true do
        if Flags.AutoClaimIncubator then
            pcall(function()
                for slot = 1, 10 do Fire("ClaimIncubator", slot) end
            end)
        end
        task.wait(1)
    end
end)

-- Auto Buy/Upgrade
task.spawn(function()
    while true do
        pcall(function()
            if Flags.AutoBuyCoop then Fire("BuyCoop", "Buy"); Fire("UpgradeCoop", "Upgrade") end
            if Flags.AutoBuyFeeder then Fire("BuyFeeder", "Buy"); Fire("UpgradeFeeder", "Upgrade") end
            if Flags.AutoBuyRecycler then Fire("UpgradeRecycler", "Buy"); Fire("UpgradeRecycler", "Upgrade") end
        end)
        task.wait(Flags.FarmUpgradeDelay)
    end
end)

-- Auto Train/Punch
task.spawn(function()
    while true do
        if Flags.AutoTrain then pcall(function() Fire("Train") end) end
        if Flags.AutoPunch then pcall(function() Fire("Punch") end) end
        task.wait(Flags.FarmSpeed)
    end
end)

-- Auto Join Events
task.spawn(function()
    while true do
        if Flags.AutoJoinEvents then
            pcall(function()
                for eventName, isEnabled in pairs(Flags.EventsToJoin) do
                    if isEnabled then
                        Fire("JoinEvent", eventName)
                        Fire("JoinEvent", "Join", eventName)
                        Fire("JoinEvent", "Enter", eventName)
                    end
                end
            end)
        end
        task.wait(3)
    end
end)

-- Auto Tower
task.spawn(function()
    while true do
        if Flags.AutoTowerGrind then
            pcall(function()
                if Flags.FeedBeforeFight then Fire("FeedChicken", "All") end
                Fire("TowerFight", "Start")
                Fire("TowerFight", "Attack")
                Fire("TowerFight", "NextFloor")
            end)
        end
        task.wait(0.3)
    end
end)

-- Auto Collect Scrap
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
                                if firetouchinterest then firetouchinterest(HRP, part, 0); task.wait(0.05); firetouchinterest(HRP, part, 1) end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.5)
    end
end)

Notify("Step 6: Auto loops OK")

-- ═══ STEP 7: GUI ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 290 or 420
local guiH = isMobile and 370 or 500

local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999

-- Mobile-safe parent
local guiOk = false
for _, parent in ipairs({gethui and gethui(), game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui"), LP:WaitForChild("PlayerGui", 5)}) do
    if parent then
        local ok = pcall(function() gui.Parent = parent end)
        if ok and gui.Parent then guiOk = true break end
    end
end
if not guiOk then pcall(function() gui.Parent = LP:WaitForChild("PlayerGui", 10) end) end

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
tt.Size = UDim2.new(1, -32, 1, 0); tt.Position = UDim2.new(0, 10, 0, 0)
tt.BackgroundTransparency = 1; tt.Text = HUB_TITLE
tt.TextColor3 = Color3.fromRGB(240, 240, 240); tt.Font = Enum.Font.GothamBold; tt.TextSize = 13
tt.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60); closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240); closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 11
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

-- Tab buttons
local tabBtns = Instance.new("Frame", main)
tabBtns.Size = UDim2.new(0, isMobile and 65 or 90, 1, -36)
tabBtns.Position = UDim2.new(0, 0, 0, 34)
tabBtns.BackgroundColor3 = Color3.fromRGB(30, 30, 42); tabBtns.BorderSizePixel = 0
Instance.new("UICorner", tabBtns).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, isMobile and -71 or -96, 1, -40)
content.Position = UDim2.new(0, isMobile and 69 or 94, 0, 36)
content.BackgroundTransparency = 1

local tabContent = {}
local tabBtnList = {}

-- ═══ UI Helpers ═══
local function CreateTab(name)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -4, 0, 26); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = isMobile and 7 or 10
    btn.TextXAlignment = Enum.TextXAlignment.Left; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local frame = Instance.new("ScrollingFrame", content)
    frame.Size = UDim2.new(1, 0, 1, 0); frame.BackgroundTransparency = 1; frame.BorderSizePixel = 0
    frame.ScrollBarThickness = 3; frame.ScrollBarImageColor3 = Color3.fromRGB(130, 90, 220)
    frame.CanvasSize = UDim2.new(0, 0, 0, 0); frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.Visible = false
    Instance.new("UIListLayout", frame).Padding = UDim.new(0, 3)
    Instance.new("UIPadding", frame).PaddingTop = UDim.new(0, 2)

    tabContent[name] = frame; tabBtnList[name] = btn
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabContent) do f.Visible = false end
        for _, b in pairs(tabBtnList) do b.BackgroundColor3 = Color3.fromRGB(35, 35, 50); b.TextColor3 = Color3.fromRGB(160, 160, 170) end
        frame.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(130, 90, 220); btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
    return frame
end

local function Section(parent, text)
    local s = Instance.new("TextLabel", parent)
    s.Size = UDim2.new(1, 0, 0, 16); s.BackgroundTransparency = 1
    s.Text = "  " .. text; s.TextColor3 = Color3.fromRGB(130, 90, 220)
    s.Font = Enum.Font.GothamBold; s.TextSize = isMobile and 8 or 10; s.TextXAlignment = Enum.TextXAlignment.Left
end

local function Paragraph(parent, title, content)
    local p = Instance.new("TextLabel", parent)
    p.Size = UDim2.new(1, 0, 0, 36); p.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    p.Text = "  " .. title .. "\n  " .. content; p.TextColor3 = Color3.fromRGB(160, 160, 170)
    p.Font = Enum.Font.Gotham; p.TextSize = isMobile and 7 or 9; p.TextWrapped = true
    p.TextXAlignment = Enum.TextXAlignment.Left; p.TextYAlignment = Enum.TextYAlignment.Top
    p.BorderSizePixel = 0; Instance.new("UICorner", p).CornerRadius = UDim.new(0, 6)
end

local function Toggle(parent, name, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 24); f.BackgroundColor3 = Color3.fromRGB(35, 35, 50); f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -42, 1, 0); l.BackgroundTransparency = 1; l.Text = "  " .. name
    l.TextColor3 = Color3.fromRGB(240, 240, 240); l.Font = Enum.Font.GothamSemibold
    l.TextSize = isMobile and 8 or 11; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 36, 0, 16); b.Position = UDim2.new(1, -40, 0.5, -8)
    b.BackgroundColor3 = default and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
    b.Text = ""; b.BorderSizePixel = 0; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = default and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240); dot.BorderSizePixel = 0
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
    b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = "  " .. name; b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = isMobile and 8 or 11
    b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(50, 50, 65) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(35, 35, 50) end)
end

local function Slider(parent, name, min, max, default, suffix, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundColor3 = Color3.fromRGB(35, 35, 50); f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.55, 0, 0, 14); l.Position = UDim2.new(0, 6, 0, 2); l.BackgroundTransparency = 1
    l.Text = "  " .. name; l.TextColor3 = Color3.fromRGB(240, 240, 240); l.Font = Enum.Font.GothamSemibold
    l.TextSize = isMobile and 7 or 10; l.TextXAlignment = Enum.TextXAlignment.Left
    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.4, 0, 0, 14); val.Position = UDim2.new(0.58, 0, 0, 2); val.BackgroundTransparency = 1
    val.Text = tostring(default) .. (suffix or ""); val.TextColor3 = Color3.fromRGB(130, 90, 220)
    val.Font = Enum.Font.GothamBold; val.TextSize = isMobile and 7 or 10; val.TextXAlignment = Enum.TextXAlignment.Right
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -12, 0, 6); bar.Position = UDim2.new(0, 6, 0, 22)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65); bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    local cur = default; local pct = (cur - min) / (max - min)
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    fill.BorderSizePixel = 0; Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    local knob = Instance.new("TextButton", bar)
    knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(math.clamp(pct, 0, 1), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(240, 240, 240); knob.Text = ""; knob.BorderSizePixel = 0; knob.ZIndex = 2
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 7)
    local dragging = false
    knob.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            cur = math.floor(min + p * (max - min)); cur = math.clamp(cur, min, max)
            local np = (cur - min) / (max - min)
            fill.Size = UDim2.new(np, 0, 1, 0); knob.Position = UDim2.new(np, -7, 0.5, -7)
            val.Text = tostring(cur) .. (suffix or ""); pcall(callback, cur)
        end
    end)
end

-- ══════════════════════════════════════════════
-- TAB 1: 🏠 HOME
-- ══════════════════════════════════════════════
local home = CreateTab("Home")

Section(home, "👤 INFO PLAYER")
Paragraph(home, "Profil", "Username: " .. LP.Name .. " | ID: " .. LP.UserId .. "\nDisplay: " .. LP.DisplayName .. " | Age: " .. LP.AccountAge .. " hari")

Section(home, "🏆 TOP 5 BEST CHICKENS")
local topChickens = GetTop5Chickens()
for rank, chk in ipairs(topChickens) do
    Paragraph(home, "#" .. rank .. " " .. chk.Name, "Power: " .. (chk.Power or "Top Tier"))
end

Section(home, "⚡ QUICK ACTION")
Btn(home, "⚡ Equip Best 5 Chickens", function() Fire("EquipBest"); Notify("Equipped best chickens!") end)
Btn(home, "🔄 Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LP) end)
Btn(home, "🌐 Server Hop (Sepi)", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            table.sort(d.data, function(a, b) return a.playing < b.playing end)
            for _, s in ipairs(d.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
                end
            end
        end
    end)
    Notify("No empty server found")
end)

-- ══════════════════════════════════════════════
-- TAB 2: 🥚 EGG (Hatch + Sell + Fuse + Incubator)
-- ══════════════════════════════════════════════
local egg = CreateTab("Egg")

Section(egg, "🐣 AUTO HATCH")
Toggle(egg, "Auto Hatch Telur", false, function(v) Flags.AutoHatch = v end)
Slider(egg, "Hatch Delay", 0.1, 2, 0.5, "s", function(v) Flags.HatchDelay = v end)

local eggOptions = {"Basic Egg", "Forest Egg", "Desert Egg", "Magma Egg", "Cyber Egg", "Void Egg"}
-- Add any extra eggs from live scan
for eggName, _ in pairs(EggDatabase) do
    local found = false
    for _, e in ipairs(eggOptions) do if e == eggName then found = true; break end end
    if not found then table.insert(eggOptions, eggName) end
end

for _, eggName in ipairs(eggOptions) do
    Btn(egg, "🥚 " .. eggName, function()
        Flags.SelectedEgg = eggName
        Fire("HatchEgg", eggName, 1)
        Notify("Hatching: " .. eggName)
    end)
end

Section(egg, "📦 MAP COLLECTOR & INCUBATOR")
Toggle(egg, "Auto Collect Egg di Map", false, function(v) Flags.AutoCollectEggs = v end)
Toggle(egg, "Auto Claim Incubator (All Slot)", false, function(v) Flags.AutoClaimIncubator = v end)

Section(egg, "💰 AUTO SELL")
Toggle(egg, "Auto Sell All After Hatch", false, function(v) Flags.AutoSellOnHatch = v end)
Btn(egg, "💵 Sell All Chickens Now", function() Fire("SellChicken", "All"); Notify("Sold all chickens!") end)

-- Per-egg sell toggles
for eggCategory, chickensList in pairs(EggDatabase) do
    Section(egg, "📦 " .. eggCategory)
    for _, chickenName in ipairs(chickensList) do
        Toggle(egg, "Jual " .. chickenName, false, function(v)
            Flags.SelectedChickensToSell[chickenName] = v
        end)
    end
end

Section(egg, "🧬 FUSE SYSTEM")
Toggle(egg, "Lock: Fuse Rarity Sama Saja", true, function(v) Flags.FuseRarityOnly = v end)
Toggle(egg, "Auto Fuse Duplikat", false, function(v) Flags.AutoFuse = v end)
Btn(egg, "⚡ Instant Fuse Now", function() Fire("FuseChicken", "InstantFuse", Flags.FuseRarityOnly); Notify("Fuse sent!") end)

-- ══════════════════════════════════════════════
-- TAB 3: 🌾 FARM (Upgrades + Events + Combat)
-- ══════════════════════════════════════════════
local farm = CreateTab("Farm")

Section(farm, "🌾 FARM UPGRADES")
Toggle(farm, "Auto Buy + Upgrade Coop", false, function(v) Flags.AutoBuyCoop = v end)
Toggle(farm, "Auto Buy + Upgrade Feeder", false, function(v) Flags.AutoBuyFeeder = v end)
Toggle(farm, "Auto Buy + Upgrade Recycler", false, function(v) Flags.AutoBuyRecycler = v end)
Slider(farm, "Upgrade Loop Delay", 0.2, 5, 1.0, "s", function(v) Flags.FarmUpgradeDelay = v end)

Section(farm, "🎪 WORLD EVENTS")
Toggle(farm, "Master Auto Join Events", false, function(v) Flags.AutoJoinEvents = v end)
Toggle(farm, "🔥 Hot Eggs", true, function(v) Flags.EventsToJoin["Hot Eggs"] = v end)
Toggle(farm, "🛸 UFO Invasion", true, function(v) Flags.EventsToJoin["UFO Invasion"] = v end)
Toggle(farm, "🪿 Golden Goose", true, function(v) Flags.EventsToJoin["Golden Goose"] = v end)
Toggle(farm, "👑 Chicken Boss", true, function(v) Flags.EventsToJoin["Chicken Boss"] = v end)

Section(farm, "🥊 COMBAT & TRAINING")
Toggle(farm, "Auto Train / Click Power", false, function(v) Flags.AutoTrain = v end)
Toggle(farm, "Auto Punch / Open World Fight", false, function(v) Flags.AutoPunch = v end)
Slider(farm, "Farm Speed (Delay)", 0.05, 1, 0.1, "s", function(v) Flags.FarmSpeed = v end)

-- ══════════════════════════════════════════════
-- TAB 4: 🏰 TOWER (Tower + Rebirth)
-- ══════════════════════════════════════════════
local tower = CreateTab("Tower")

Section(tower, "🗼 TOWER AUTO GRIND")
Toggle(tower, "Auto Tower Grind", false, function(v) Flags.AutoTowerGrind = v end)
Slider(tower, "Target Max Floor", 1, 100, 20, " Floor", function(v) Flags.TargetFloor = v end)
Toggle(tower, "Feed Before Fight", true, function(v) Flags.FeedBeforeFight = v end)

Section(tower, "♻️ SMART REBIRTH GLITCH")
Paragraph(tower, "💡 Cara Kerja", "Scrap dijual bersamaan Rebirth → uang masuk ke siklus baru!")
Toggle(tower, "Aktifkan Smart Rebirth (Auto di Max Floor)", false, function(v) Flags.SmartRebirth = v end)
Toggle(tower, "Auto Collect Scrap", false, function(v) Flags.AutoCollectScrap = v end)
Btn(tower, "⚡ Rebirth Now (Manual)", function()
    Fire("CollectScrap"); task.wait(0.1)
    Fire("RecycleScrap", "All"); task.wait(0.1)
    Fire("Rebirth", "DoRebirth")
    Notify("Rebirth done!")
end)

-- ══════════════════════════════════════════════
-- TAB 5: ⚙️ SETTINGS (Performance + Mods + Movement)
-- ══════════════════════════════════════════════
local settings = CreateTab("Settings")

Section(settings, "📱 UI")
Toggle(settings, "Tampilkan Floating Button", true, function(v)
    Flags.ShowFloatingBtn = v
    if FloatingGui then FloatingGui.Enabled = v end
end)

Section(settings, "⚡ PERFORMANCE & MODS")
Toggle(settings, "FPS Booster (No Shadows, Smooth)", false, function(v) Flags.FPSBooster = v; ApplyFPS(v) end)
Toggle(settings, "Ultra Low GPU Mode (Hemat Baterai)", false, function(v)
    Flags.LowGPU = v
    pcall(function() RunService:Set3dRenderingEnabled(not v) end)
end)
Slider(settings, "Max FPS Cap", 30, 240, 60, " FPS", function(v)
    Flags.FPSCap = v
    pcall(function() if setfpscap then setfpscap(v) end end)
end)

Section(settings, "🛡️ SAFETY")
Toggle(settings, "Anti-AFK (Anti Disconnect 20 Menit)", true, function(v) Flags.AntiAFK = v end)
Toggle(settings, "Auto Rejoin Saat Disconnect", false, function(v) Flags.AutoReconnect = v end)

Section(settings, "🏃 MOVEMENT")
Toggle(settings, "Inf Jump", false, function(v) Flags.InfJump = v end)
Toggle(settings, "NoClip (Tembus Dinding)", false, function(v) Flags.NoClip = v end)
Slider(settings, "WalkSpeed", 16, 250, 16, " Spd", function(v) Flags.WalkSpeed = v end)
Slider(settings, "JumpPower", 50, 300, 50, " Pwr", function(v) Flags.JumpPower = v end)

Section(settings, "🌐 SERVER")
Btn(settings, "🔄 Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LP) end)
Btn(settings, "🌐 Server Hop (Sepi)", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            table.sort(d.data, function(a, b) return a.playing < b.playing end)
            for _, s in ipairs(d.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
                end
            end
        end
    end)
    Notify("No empty server found")
end)
Btn(settings, "🌐 Server Hop (Ramai)", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            for _, s in ipairs(d.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
                end
            end
        end
    end)
end)

-- ═══ Activate first tab ═══
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

-- ═══ Floating Draggable Button ═══
FloatingGui = nil
pcall(function()
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "MilesHub_Float"
    floatGui.ResetOnSpawn = false
    floatGui.DisplayOrder = 999999

    for _, p in ipairs({gethui and gethui(), game:GetService("CoreGui"), LP:FindFirstChild("PlayerGui")}) do
        if p then
            local ok = pcall(function() floatGui.Parent = p end)
            if ok and floatGui.Parent then break end
        end
    end

    if floatGui.Parent then
        FloatingGui = floatGui

        local fb = Instance.new("TextButton", floatGui)
        fb.Size = UDim2.new(0, 55, 0, 55)
        fb.Position = UDim2.new(0, 10, 0.3, 0)
        fb.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        fb.Text = "⚡"
        fb.TextColor3 = Color3.fromRGB(168, 85, 247)
        fb.Font = Enum.Font.GothamBold
        fb.TextSize = 22
        fb.TextTransparency = 0.2
        fb.Active = true
        fb.Draggable = true
        fb.BorderSizePixel = 0
        Instance.new("UICorner", fb).CornerRadius = UDim.new(0.5, 0)
        local btnStroke = Instance.new("UIStroke", fb)
        btnStroke.Color = Color3.fromRGB(168, 85, 247)
        btnStroke.Thickness = 2

        fb.MouseButton1Click:Connect(function()
            gui.Enabled = not gui.Enabled
        end)

        -- Pulse animation
        task.spawn(function()
            while true do
                pcall(function()
                    fb.TextTransparency = 0.2
                    task.wait(0.8)
                    fb.TextTransparency = 0.6
                    task.wait(0.8)
                end)
            end
        end)
    end
end)

-- ═══ DONE ═══
Notify("Step 7: All loaded! ⚡")
print("[Miles-HUB] v2.2 FULL loaded successfully ✓")
print("[Miles-HUB] Tabs: Home | Egg | Farm | Tower | Settings")
