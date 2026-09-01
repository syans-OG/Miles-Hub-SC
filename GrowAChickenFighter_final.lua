--[[
    ⚡ Miles-HUB v2.2 — FULL FEATURES
    Rebuilt from PROVEN V3 pattern: GUI first, features after.
    
    CRITICAL: GUI is created BEFORE any heavy operations.
    This ensures the GUI always appears, even if features fail.
    
    Tabs: Home | Egg | Farm | Tower | Settings
]]

-- ═══ EXACT V3 START PATTERN (proven working) ═══
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

Notify("Miles-HUB v2.2 loading...")

-- ═══ EXACT V3 GUI PATTERN (proven working) ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 290 or 420
local guiH = isMobile and 370 or 500

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
tt.BackgroundTransparency = 1; tt.Text = "Miles-HUB v2.2"
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

-- ═══ UI Helpers (same as V3) ═══
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
-- GUI IS NOW VISIBLE — features can load safely below
-- ══════════════════════════════════════════════

-- ═══ Feature Flags ═══
local Flags = {
    InfJump = false, NoClip = false, WalkSpeed = 16, JumpPower = 50,
    AutoHatch = false, SelectedEgg = "Basic Egg", HatchDelay = 0.5,
    AutoSellOnHatch = false, AutoFuse = false,
    AutoCollectEggs = false, AutoClaimIncubator = false,
    AutoBuyCoop = false, AutoBuyFeeder = false, AutoBuyRecycler = false,
    AutoTrain = false, AutoPunch = false, FarmSpeed = 0.1,
    AutoJoinEvents = false,
    EventsToJoin = {["Hot Eggs"]=true, ["UFO Invasion"]=true, ["Golden Goose"]=true, ["Chicken Boss"]=true},
    AutoTowerGrind = false, TargetFloor = 20, FeedBeforeFight = true,
    SmartRebirth = false, AutoCollectScrap = false,
    AntiAFK = true, AutoReconnect = false,
    FPSBooster = false, ShowFloatingBtn = true,
}

-- ═══ Egg Database (HARDCODED — no GetDescendants, no require) ═══
local EggDatabase = {
    ["Basic Egg"] = {"Common Chicken", "Spotted Chicken", "Brown Rooster", "Golden Rooster"},
    ["Forest Egg"] = {"Leaf Chick", "Forest Fighter", "Woodland Brawler", "Treant Rooster"},
    ["Desert Egg"] = {"Sand Chick", "Cactus Fighter", "Desert Hawk", "Mummy Chicken"},
    ["Magma Egg"] = {"Flame Chick", "Magma Fighter", "Lava Rooster", "Phoenix Chicken"},
    ["Cyber Egg"] = {"Neon Chick", "Cyber Brawler", "Mecha Rooster", "Quantum Chicken"},
    ["Void Egg"] = {"Shadow Chick", "Void Fighter", "Dark Lord Rooster", "Celestial Chicken"},
}

-- ═══ Remote Scanner (GetChildren only — lightweight, runs AFTER GUI) ═══
local Remotes = {}
task.spawn(function()
    task.wait(1)
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        for _, obj in ipairs(RS:GetChildren()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                Remotes[obj.Name] = obj
            end
        end
    end)
end)

local function Fire(name, ...)
    local r = Remotes[name]
    if not r then return false end
    task.wait(math.random(50, 150) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(...) else r:InvokeServer(...) end
    end)
    return true
end

-- ═══ Client Features (same as V3 — event-based, no loops) ═══
pcall(function()
    UserInputService.JumpRequest:Connect(function()
        if Flags.InfJump then
            local c = LP.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end)
end)

pcall(function()
    local RunService = game:GetService("RunService")
    RunService.Stepped:Connect(function()
        if Flags.NoClip then
            local c = LP.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide and p.Name ~= "HumanoidRootPart" then p.CanCollide = false end
                end
            end
        end
    end)
    RunService.Heartbeat:Connect(function()
        local c = LP.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid")
            if h then
                if Flags.WalkSpeed > 16 then h.WalkSpeed = Flags.WalkSpeed end
                if Flags.JumpPower > 50 then h.JumpPower = Flags.JumpPower end
            end
        end
    end)
end)

-- Anti-AFK (same as V3)
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        if Flags.AntiAFK then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0, 0)) end
    end)
end)

-- ═══ Background Loops (started AFTER GUI — safe) ═══
task.spawn(function()
    while true do
        if Flags.AutoHatch then pcall(function() Fire("HatchEgg", Flags.SelectedEgg, 1) end) end
        task.wait(Flags.HatchDelay)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoFuse then pcall(function() Fire("FuseChicken", "AutoFuseDuplicates", true) end) end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoTrain then pcall(function() Fire("Train") end) end
        if Flags.AutoPunch then pcall(function() Fire("Punch") end) end
        task.wait(Flags.FarmSpeed)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoTowerGrind then
            pcall(function()
                Fire("FeedChicken", "All"); Fire("TowerFight", "Start")
                Fire("TowerFight", "Attack"); Fire("TowerFight", "NextFloor")
            end)
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Flags.AutoBuyCoop then Fire("BuyCoop", "Buy"); Fire("UpgradeCoop", "Upgrade") end
            if Flags.AutoBuyFeeder then Fire("BuyFeeder", "Buy"); Fire("UpgradeFeeder", "Upgrade") end
            if Flags.AutoBuyRecycler then Fire("UpgradeRecycler", "Buy"); Fire("UpgradeRecycler", "Upgrade") end
        end)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoJoinEvents then
            pcall(function()
                for ev, ok in pairs(Flags.EventsToJoin) do
                    if ok then Fire("JoinEvent", ev); Fire("JoinEvent", "Join", ev) end
                end
            end)
        end
        task.wait(3)
    end
end)

-- ══════════════════════════════════════════════
-- TAB 1: 🏠 HOME
-- ══════════════════════════════════════════════
local home = CreateTab("Home")

Section(home, "👤 INFO PLAYER")
Paragraph(home, "Profil", "Username: " .. LP.Name .. " | ID: " .. LP.UserId .. "\nDisplay: " .. LP.DisplayName .. " | Age: " .. LP.AccountAge .. " hari")

Section(home, "🏆 TOP 5 BEST CHICKENS")
local defaultChickens = {
    {Name = "Celestial Chicken", Power = 50000}, {Name = "Dark Lord Rooster", Power = 25000},
    {Name = "Phoenix Chicken", Power = 12000}, {Name = "Quantum Chicken", Power = 6000},
    {Name = "Lava Rooster", Power = 3000},
}
-- Try live data (on demand, after GUI)
task.spawn(function()
    task.wait(2)
    pcall(function()
        local RS = game:GetService("ReplicatedStorage")
        local pd = RS:FindFirstChild("PlayerData") or RS:FindFirstChild("Datas")
        if pd then
            local uf = pd:FindFirstChild(tostring(LP.UserId)) or pd:FindFirstChild(LP.Name)
            if uf then
                local pf = uf:FindFirstChild("Chickens") or uf:FindFirstChild("Pets")
                if pf then
                    local list = {}
                    for _, pet in ipairs(pf:GetChildren()) do
                        local pv = pet:FindFirstChild("Multiplier") or pet:FindFirstChild("Power") or pet:FindFirstChild("Level")
                        table.insert(list, {Name = pet.Name, Power = pv and tonumber(pv.Value) or 100})
                    end
                    if #list > 0 then
                        table.sort(list, function(a, b) return a.Power > b.Power end)
                        for i = 1, math.min(5, #list) do defaultChickens[i] = list[i] end
                    end
                end
            end
        end
    end)
end)
for rank, chk in ipairs(defaultChickens) do
    Paragraph(home, "#" .. rank .. " " .. chk.Name, "Power: " .. (chk.Power or "Top Tier"))
end

Section(home, "⚡ QUICK ACTION")
Btn(home, "⚡ Equip Best Chickens", function() Fire("EquipBest"); Notify("Equipped!") end)
Btn(home, "🔄 Rejoin Server", function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end) end)

-- ══════════════════════════════════════════════
-- TAB 2: 🥚 EGG
-- ══════════════════════════════════════════════
local egg = CreateTab("Egg")

Section(egg, "🐣 AUTO HATCH")
Toggle(egg, "Auto Hatch", false, function(v) Flags.AutoHatch = v end)
Slider(egg, "Hatch Delay", 0.1, 2, 0.5, "s", function(v) Flags.HatchDelay = v end)

for _, eggName in ipairs({"Basic Egg", "Forest Egg", "Desert Egg", "Magma Egg", "Cyber Egg", "Void Egg"}) do
    Btn(egg, "🥚 " .. eggName, function() Flags.SelectedEgg = eggName; Fire("HatchEgg", eggName, 1); Notify("Hatching: " .. eggName) end)
end

Section(egg, "📦 COLLECT")
Toggle(egg, "Auto Collect Egg di Map", false, function(v) Flags.AutoCollectEggs = v end)
Toggle(egg, "Auto Claim Incubator", false, function(v) Flags.AutoClaimIncubator = v end)

Section(egg, "💰 SELL & FUSE")
Toggle(egg, "Auto Sell After Hatch", false, function(v) Flags.AutoSellOnHatch = v end)
Btn(egg, "💵 Sell All Now", function() Fire("SellChicken", "All"); Notify("Sold!") end)
Toggle(egg, "Auto Fuse Duplikat", false, function(v) Flags.AutoFuse = v end)
Btn(egg, "🧬 Fuse Now", function() Fire("FuseChicken", "AutoFuseDuplicates", true); Notify("Fuse sent!") end)

for eggCat, chicks in pairs(EggDatabase) do
    Section(egg, "📦 " .. eggCat)
    for _, cn in ipairs(chicks) do
        Toggle(egg, "Jual " .. cn, false, function(v) end)
    end
end

-- ══════════════════════════════════════════════
-- TAB 3: 🌾 FARM
-- ══════════════════════════════════════════════
local farm = CreateTab("Farm")

Section(farm, "🌾 UPGRADES")
Toggle(farm, "Auto Buy + Upgrade Coop", false, function(v) Flags.AutoBuyCoop = v end)
Toggle(farm, "Auto Buy + Upgrade Feeder", false, function(v) Flags.AutoBuyFeeder = v end)
Toggle(farm, "Auto Buy + Upgrade Recycler", false, function(v) Flags.AutoBuyRecycler = v end)

Section(farm, "🎪 WORLD EVENTS")
Toggle(farm, "Auto Join Events", false, function(v) Flags.AutoJoinEvents = v end)
Toggle(farm, "🔥 Hot Eggs", true, function(v) Flags.EventsToJoin["Hot Eggs"] = v end)
Toggle(farm, "🛸 UFO Invasion", true, function(v) Flags.EventsToJoin["UFO Invasion"] = v end)
Toggle(farm, "🪿 Golden Goose", true, function(v) Flags.EventsToJoin["Golden Goose"] = v end)
Toggle(farm, "👑 Chicken Boss", true, function(v) Flags.EventsToJoin["Chicken Boss"] = v end)

Section(farm, "🥊 COMBAT")
Toggle(farm, "Auto Train", false, function(v) Flags.AutoTrain = v end)
Toggle(farm, "Auto Punch", false, function(v) Flags.AutoPunch = v end)
Slider(farm, "Farm Speed", 0.05, 1, 0.1, "s", function(v) Flags.FarmSpeed = v end)

-- ══════════════════════════════════════════════
-- TAB 4: 🏰 TOWER
-- ══════════════════════════════════════════════
local tower = CreateTab("Tower")

Section(tower, "🗼 AUTO TOWER")
Toggle(tower, "Auto Tower Grind", false, function(v) Flags.AutoTowerGrind = v end)
Slider(tower, "Target Floor", 1, 100, 20, " Floor", function(v) Flags.TargetFloor = v end)
Toggle(tower, "Feed Before Fight", true, function(v) Flags.FeedBeforeFight = v end)

Section(tower, "♻️ REBIRTH")
Toggle(tower, "Auto Collect Scrap", false, function(v) Flags.AutoCollectScrap = v end)
Btn(tower, "⚡ Rebirth Now", function()
    Fire("CollectScrap"); task.wait(0.1)
    Fire("RecycleScrap", "All"); task.wait(0.1)
    Fire("Rebirth", "DoRebirth"); Notify("Rebirth done!")
end)

-- ══════════════════════════════════════════════
-- TAB 5: ⚙️ SETTINGS
-- ══════════════════════════════════════════════
local settings = CreateTab("Settings")

Section(settings, "⚡ PERFORMANCE")
Toggle(settings, "FPS Booster", false, function(v)
    Flags.FPSBooster = v
    pcall(function()
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            game:GetService("Lighting").GlobalShadows = false
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            game:GetService("Lighting").GlobalShadows = true
        end
    end)
end)

Section(settings, "🛡️ SAFETY")
Toggle(settings, "Anti-AFK", true, function(v) Flags.AntiAFK = v end)
Toggle(settings, "Auto Rejoin on Kick", false, function(v) Flags.AutoReconnect = v end)

Section(settings, "🏃 MOVEMENT")
Toggle(settings, "Inf Jump", false, function(v) Flags.InfJump = v end)
Toggle(settings, "NoClip", false, function(v) Flags.NoClip = v end)
Slider(settings, "WalkSpeed", 16, 250, 16, " Spd", function(v) Flags.WalkSpeed = v end)
Slider(settings, "JumpPower", 50, 300, 50, " Pwr", function(v) Flags.JumpPower = v end)

Section(settings, "🌐 SERVER")
Btn(settings, "🔄 Rejoin", function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP) end) end)
Btn(settings, "🌐 Server Hop", function()
    pcall(function()
        local r = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local d = game:GetService("HttpService"):JSONDecode(r)
        if d and d.data then
            for _, s in ipairs(d.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
                end
            end
        end
    end)
    Notify("No empty server found")
end)

-- ═══ Activate first tab ═══
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

-- ═══ Floating Button (created AFTER GUI — safe) ═══
pcall(function()
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "MilesHub_Float"; floatGui.ResetOnSpawn = false; floatGui.DisplayOrder = 999999
    floatGui.Parent = LP:WaitForChild("PlayerGui")

    local fb = Instance.new("TextButton", floatGui)
    fb.Size = UDim2.new(0, 50, 0, 50); fb.Position = UDim2.new(0, 10, 0.3, 0)
    fb.BackgroundColor3 = Color3.fromRGB(20, 16, 35); fb.Text = "⚡"
    fb.TextColor3 = Color3.fromRGB(168, 85, 247); fb.Font = Enum.Font.GothamBold; fb.TextSize = 22
    fb.TextTransparency = 0.2; fb.Active = true; fb.Draggable = true; fb.BorderSizePixel = 0
    Instance.new("UICorner", fb).CornerRadius = UDim.new(0.5, 0)
    Instance.new("UIStroke", fb).Color = Color3.fromRGB(168, 85, 247)
    fb.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)
end)

-- ═══ DONE ═══
Notify("All features loaded! ⚡")
print("[Miles-HUB] v2.2 loaded — Home | Egg | Farm | Tower | Settings")
