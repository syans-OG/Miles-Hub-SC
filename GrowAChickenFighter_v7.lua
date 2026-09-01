--[[ Miles-HUB v7.0 - Grow A Chicken - V1 loop inti ]]
--[[ Hotkey: RightShift = toggle GUI. Pure ASCII. ]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local LP = Players.LocalPlayer

local function Notify(t)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Miles-HUB", Text = t, Duration = 4 })
    end)
end

-- GUI (CoreGui: survives game clearing PlayerGui on UI switches)
local CoreGui = game:GetService("CoreGui")
local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.Parent = CoreGui

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local gw = isMobile and 280 or 400
local gh = isMobile and 350 or 480

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, gw, 0, gh)
main.Position = UDim2.new(0.5, -gw/2, 0.5, -gh/2)
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
tt.Text = "Miles-HUB v7.0"
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
Instance.new("UIListLayout", tabBtns).Padding = UDim.new(0, 3)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, isMobile and -76 or -96, 1, -40)
content.Position = UDim2.new(0, isMobile and 74 or 94, 0, 36)
content.BackgroundTransparency = 1

local tabContent = {}
local tabBtnList = {}
local tabCount = 0

local function CreateTab(name)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -6, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tabCount = tabCount + 1
    btn.LayoutOrder = tabCount
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
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
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
    AutoCollect = false, AutoClaimIncubator = false,
    AutoHatch = false, SelectedEgg = "Basic Egg", HatchDelay = 0.5,
    AutoSell = false, AutoFuse = false,
    AutoCoop = false, AutoFeeder = false, AutoRecycler = false,
    AutoTower = false, TargetFloor = 25, FeedBefore = true, AutoRebirth = false,
    AutoEvents = false, Events = {["Hot Eggs"] = true, ["UFO Invasion"] = true, ["Golden Goose"] = true, ["Chicken Boss"] = true},
    FPS = false, AntiAFK = true, Reconnect = false,
    InfJump = false, WalkSpeed = 16, JumpPower = 50,
}

-- LOOP STATUS (shown in Debug tab)
local LoopStatus = {}
local function SetStatus(name, txt)
    LoopStatus[name] = txt
end

-- FIRE gateway: only fires existing remotes, random delay, logs status
local Remotes = {}
local function ScanRemotes()
    Remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name] = obj
        end
    end
    local ps = LP:FindFirstChild("PlayerScripts")
    if ps then
        for _, obj in ipairs(ps:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                Remotes[obj.Name] = obj
            end
        end
    end
end
ScanRemotes()

local function Fire(name, ...)
    local r = Remotes[name]
    if not r then return false end
    local args = { ... }
    task.wait(math.random(100, 400) / 1000)
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(unpack(args)) else r:InvokeServer(unpack(args)) end
    end)
    return true
end

local function Try(name, ...)
    if Fire(name, ...) then return "fired" end
    return "no remote (" .. name .. ")"
end

-- Auto re-scan: remotes may replicate after load
task.spawn(function()
    while task.wait(8) do ScanRemotes() end
end)

local eggOptions = { "colossus", "KrakenEgg", "ascension", "trick", "demonic", "blessed", "basic" }
local eventOptions = { "Hot Eggs", "UFO Invasion", "Golden Goose", "Chicken Boss" }

-- --- TAB: EGG ---
local egg = CreateTab("Egg")
Section(egg, "COLLECT")
Toggle(egg, "Auto Collect Egg", false, function(v) Flags.AutoCollect = v end)
Toggle(egg, "Auto Claim Incubator", false, function(v) Flags.AutoClaimIncubator = v end)
Section(egg, "AUTO HATCH")
Toggle(egg, "Auto Hatch", false, function(v) Flags.AutoHatch = v end)
Slider(egg, "Hatch Delay", 0.1, 2, 0.5, "s", function(v) Flags.HatchDelay = v end)
for _, en in ipairs(eggOptions) do
    Btn(egg, "Egg: " .. en, function() Flags.SelectedEgg = en; Notify(en) end)
end
local inRow = Instance.new("Frame", egg)
inRow.Size = UDim2.new(1, 0, 0, 30)
inRow.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Instance.new("UICorner", inRow).CornerRadius = UDim.new(0, 6)
local bx = Instance.new("TextBox", inRow)
bx.Size = UDim2.new(0.7, -4, 0, 24)
bx.Position = UDim2.new(0, 4, 0, 3)
bx.PlaceholderText = "custom egg name"
bx.ClearTextOnFocus = true
bx.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bx.BorderSizePixel = 0
bx.Font = Enum.Font.Gotham
bx.TextSize = 10
bx.TextColor3 = Color3.fromRGB(240, 240, 240)
Instance.new("UICorner", bx).CornerRadius = UDim.new(0, 6)
local st = Instance.new("TextButton", inRow)
st.Size = UDim2.new(0.26, -4, 0, 24)
st.Position = UDim2.new(0.72, 0, 0, 3)
st.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
st.Text = "Set"
st.TextColor3 = Color3.fromRGB(240, 240, 240)
st.Font = Enum.Font.GothamBold
st.TextSize = 10
Instance.new("UICorner", st).CornerRadius = UDim.new(0, 6)
st.MouseButton1Click:Connect(function()
    local t = bx.Text:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if t ~= "" then Flags.SelectedEgg = t; Notify("Egg set: " .. t) end
end)
Section(egg, "SELL AND FUSE")
Toggle(egg, "Auto Sell After Hatch", false, function(v) Flags.AutoSell = v end)
Toggle(egg, "Auto Fuse Duplicate", false, function(v) Flags.AutoFuse = v end)

-- --- TAB: FARM ---
local farm = CreateTab("Farm")
Section(farm, "UPGRADES")
Toggle(farm, "Auto Buy + Upgrade Coop", false, function(v) Flags.AutoCoop = v end)
Toggle(farm, "Auto Buy + Upgrade Feeder", false, function(v) Flags.AutoFeeder = v end)
Toggle(farm, "Auto Upgrade Recycler", false, function(v) Flags.AutoRecycler = v end)

-- --- TAB: TOWER ---
local tower = CreateTab("Tower")
Section(tower, "TOWER")
Toggle(tower, "Auto Tower Grind", false, function(v) Flags.AutoTower = v end)
Slider(tower, "Target Floor", 1, 100, 20, "", function(v) Flags.TargetFloor = v end)
Toggle(tower, "Encourage Before Fight", true, function(v) Flags.FeedBefore = v end)
Section(tower, "REBIRTH")
Toggle(tower, "Auto Rebirth (game native)", false, function(v)
    Fire("SetAutoRebirth", v)
    Flags.AutoRebirth = v
end)
Btn(tower, "Rebirth Now (Manual)", function() Fire("Rebirth") end)

-- --- TAB: EVENT ---
local eventTab = CreateTab("Event")
Section(eventTab, "WORLD EVENTS")
Toggle(eventTab, "Auto Join Events", false, function(v) Flags.AutoEvents = v end)
for _, en in ipairs(eventOptions) do
    Toggle(eventTab, en, true, function(v) Flags.Events[en] = v end)
end

-- --- TAB: SETTING ---
local setting = CreateTab("Setting")
Section(setting, "PERFORMANCE")
Toggle(setting, "FPS Booster", false, function(v)
    Flags.FPS = v
    pcall(function()
        settings().Rendering.QualityLevel = v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        game:GetService("Lighting").GlobalShadows = not v
    end)
end)
Section(setting, "SAFETY")
Toggle(setting, "Anti-AFK", true, function(v) Flags.AntiAFK = v end)
Toggle(setting, "Rejoin on Disconnect", false, function(v) Flags.Reconnect = v end)
Section(setting, "MOVEMENT")
Toggle(setting, "Inf Jump", false, function(v) Flags.InfJump = v end)
Slider(setting, "WalkSpeed", 16, 250, 16, " Spd", function(v) Flags.WalkSpeed = v end)
Slider(setting, "JumpPower", 50, 300, 50, " Pwr", function(v) Flags.JumpPower = v end)

-- --- TAB: DEBUG ---
local debugTab = CreateTab("Debug")
Section(debugTab, "REMOTE LIST")
local remoteLbl = Instance.new("TextLabel", debugTab)
remoteLbl.Size = UDim2.new(1, 0, 0, 200)
remoteLbl.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
remoteLbl.Text = "Scanning..."
remoteLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
remoteLbl.Font = Enum.Font.Gotham
remoteLbl.TextSize = 9
remoteLbl.TextWrapped = true
remoteLbl.TextXAlignment = Enum.TextXAlignment.Left
remoteLbl.TextYAlignment = Enum.TextYAlignment.Top
remoteLbl.BorderSizePixel = 0
Instance.new("UICorner", remoteLbl).CornerRadius = UDim.new(0, 6)
local function RefreshRemoteLabel()
    local names = {}
    for n in pairs(Remotes) do table.insert(names, n) end
    table.sort(names)
    remoteLbl.Text = (#names == 0 and "No remotes found." or table.concat(names, "\n"))
end
RefreshRemoteLabel()
Btn(debugTab, "Refresh Remotes", function() ScanRemotes(); RefreshRemoteLabel(); Notify("Scanned: " .. tostring(#Remotes)) end)
Btn(debugTab, "Copy Remote List", function()
    local names = {}
    for n in pairs(Remotes) do table.insert(names, n) end
    table.sort(names)
    local txt = #names == 0 and "(no remotes found)" or table.concat(names, "\n")
    local ok = pcall(function() setclipboard(txt) end)
    if not ok then ok = pcall(function() game:GetService("Clipboard"):settext(txt) end) end
    Notify(ok and "Copied " .. tostring(#names) .. " names" or "Copy failed")
end)
Section(debugTab, "LOOP STATUS")
local statusLbl = Instance.new("TextLabel", debugTab)
statusLbl.Size = UDim2.new(1, 0, 0, 200)
statusLbl.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
statusLbl.Text = ""
statusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 9
statusLbl.TextWrapped = true
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.BorderSizePixel = 0
Instance.new("UICorner", statusLbl).CornerRadius = UDim.new(0, 6)
local function RefreshStatus()
    local lines = {}
    for k, v in pairs(LoopStatus) do table.insert(lines, k .. ": " .. v) end
    table.sort(lines)
    statusLbl.Text = #lines == 0 and "No loops running." or table.concat(lines, "\n")
end

-- PLAYER DATA READER (no F9 needed)
Section(debugTab, "PLAYER DATA")
local dataLbl = Instance.new("TextLabel", debugTab)
dataLbl.Size = UDim2.new(1, 0, 0, 240)
dataLbl.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
dataLbl.Text = "Press Scan Data."
dataLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
dataLbl.Font = Enum.Font.Gotham
dataLbl.TextSize = 9
dataLbl.TextWrapped = true
dataLbl.TextXAlignment = Enum.TextXAlignment.Left
dataLbl.TextYAlignment = Enum.TextYAlignment.Top
dataLbl.BorderSizePixel = 0
Instance.new("UICorner", dataLbl).CornerRadius = UDim.new(0, 6)

local function ser(v, d)
    d = d or 0
    if type(v) ~= "table" then return tostring(v) end
    if d > 1 then return tostring(v) end
    local t = {}
    for k, val in pairs(v) do
        table.insert(t, tostring(k) .. "=" .. ser(val, d + 1))
    end
    return "{" .. table.concat(t, ", ") .. "}"
end

local dataLines = {}
local function scanOneLevel(root, max)
    local n = 0
    for _, c in ipairs(root:GetChildren()) do
        if n >= max then break end
        n = n + 1
        table.insert(dataLines, c.Name .. " [" .. c.ClassName .. "]")
    end
end
local function deepFind(root, name)
    if not root then return nil end
    for _, c in ipairs(root:GetChildren()) do
        if c.Name == name then return c end
    end
    for _, c in ipairs(root:GetChildren()) do
        local r = deepFind(c, name)
        if r then return r end
    end
    return nil
end
local function readRebirthText()
    local rb = LP.PlayerGui:FindFirstChild("Rebirth")
    if not rb then return "", "" end
    local req, count = "", ""
    local rc = deepFind(rb, "reqCard")
    if rc then
        local tl = deepFind(rc, "text")
        if tl and tl:IsA("TextLabel") then req = tl.Text end
    end
    local cn = deepFind(rb, "count")
    if cn then
        local tl = deepFind(cn, "s2")
        if tl and tl:IsA("TextLabel") then count = tl.Text end
    end
    return req, count
end
local function clickBtn(btn)
    if not btn or not btn:IsDescendantOf(game) then return false end
    local p = btn.AbsolutePosition + btn.AbsoluteSize / 2
    local VIM = game:GetService("VirtualInputManager")
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 1)
    task.wait(0.08)
    VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 1)
    return true
end
local function ScanData()
    dataLines = {}
    table.insert(dataLines, "== ReplicatedStorage top ==")
    scanOneLevel(ReplicatedStorage, 50)
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if assets then
        table.insert(dataLines, "== Assets.Eggs ==")
        local eggs = assets:FindFirstChild("Eggs")
        if eggs then scanOneLevel(eggs, 40) end
        table.insert(dataLines, "== Assets.Chickens ==")
        local ch = assets:FindFirstChild("Chickens")
        if ch then scanOneLevel(ch, 60) end
    end
    table.insert(dataLines, "== Content (top) ==")
    local content = ReplicatedStorage:FindFirstChild("Content")
    if content then scanOneLevel(content, 40) end
    table.insert(dataLines, "== workspace top ==")
    scanOneLevel(game.Workspace, 60)
    table.insert(dataLines, "== My plot ==")
    local plot = game.Workspace:FindFirstChild(LP.Name)
    if plot then scanOneLevel(plot, 40) else table.insert(dataLines, "(none)") end
    table.insert(dataLines, "== Rebirth window ==")
    local req, count = readRebirthText()
    table.insert(dataLines, "reqText: " .. (req == "" and "(empty, opening UI...)" or req))
    table.insert(dataLines, "count: " .. count)
    dataLbl.Text = table.concat(dataLines, "\n")
    if req == "" then
        local rail = LP.PlayerGui:FindFirstChild("ArenaSideRail")
        local btn = rail and deepFind(rail, "Rebirth")
        if clickBtn(btn) then
            task.delay(1.5, function()
                local r2, c2 = readRebirthText()
                for i, l in ipairs(dataLines) do
                    if l:sub(1, 2) == "re" and l:find("^reqText") then
                        dataLines[i] = "reqText: " .. (r2 == "" and "(still empty)" or r2)
                    elseif l:sub(1, 2) == "co" and l:find("^count") then
                        dataLines[i] = "count: " .. c2
                    end
                end
                dataLbl.Text = table.concat(dataLines, "\n")
            end)
        end
    end
end
Btn(debugTab, "Scan Player Data", ScanData)
Btn(debugTab, "Copy Player Data", function()
    local txt = table.concat(dataLines, "\n")
    if txt == "" then txt = "(no data)" end
    local ok = pcall(function() setclipboard(txt) end)
    if not ok then ok = pcall(function() game:GetService("Clipboard"):settext(txt) end) end
    Notify(ok and "Data copied" or "Copy failed")
end)

local function DumpTexts()
    local out = {}
    local function walk(o, depth)
        if #out >= 300 then return end
        for _, c in ipairs(o:GetChildren()) do
            if #out >= 300 then return end
            if c:IsA("ScreenGui") then
                if c.Enabled and c.Name ~= "MilesHub" and c.Name ~= "Float" then walk(c, depth + 1) end
            elseif c:IsA("GuiObject") then
                if c.Visible then
                    if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text ~= "" then
                        out[#out + 1] = string.rep(" ", math.min(depth, 3)) .. c.Name .. ": " .. c.Text
                    end
                    walk(c, depth + 1)
                end
            else
                walk(c, depth + 1)
            end
        end
    end
    walk(LP.PlayerGui, 0)
    if #out == 0 then out[1] = "(no visible text found)" end
    dataLines = out
    dataLbl.Text = table.concat(out, "\n")
    Notify("Dumped " .. tostring(#out) .. " visible texts")
end
Btn(debugTab, "Dump Visible GUI", DumpTexts)

local function OpenRailAndDump(railName)
    local rail = LP.PlayerGui:FindFirstChild("ArenaSideRail")
    local btn = rail and deepFind(rail, railName)
    if not clickBtn(btn) then Notify("Rail button not found: " .. railName); return end
    Notify(railName .. " opened, dumping in 2s...")
    task.delay(2, DumpTexts)
end
Btn(debugTab, "Open Shop > Dump", function() OpenRailAndDump("Shop") end)
Btn(debugTab, "Open Flock > Dump", function() OpenRailAndDump("Flock") end)

-- Activate first tab
for name, frame in pairs(tabContent) do
    frame.Visible = true
    tabBtnList[name].BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    tabBtnList[name].TextColor3 = Color3.fromRGB(240, 240, 240)
    break
end

-- RightShift toggle
pcall(function()
    UIS.InputBegan:Connect(function(input, gpe)
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
    fg.Parent = CoreGui
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
end)

-- GUI watchdog (game may clear/disable PlayerGui children on UI switches)
task.spawn(function()
    while task.wait(4) do
        pcall(function()
            if gui and gui.Parent ~= CoreGui then gui.Parent = CoreGui end
            local fg = CoreGui:FindFirstChild("Float")
            if fg and fg.Parent ~= CoreGui then fg.Parent = CoreGui end
        end)
    end
end)

-- --- FEATURES ---

-- InfJump
pcall(function()
    UIS.JumpRequest:Connect(function()
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

-- WalkSpeed / JumpPower (slow loop, reset when not boosted)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local c = LP.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then
                    if Flags.WalkSpeed > 16 then h.WalkSpeed = Flags.WalkSpeed end
                    if Flags.JumpPower > 50 then h.JumpPower = Flags.JumpPower end
                end
            end
        end)
    end
end)

-- Anti-AFK (safe: Idled event only, no VirtualUser)
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

-- Rejoin on disconnect
pcall(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        if Flags.Reconnect then
            task.wait(3)
            pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
        end
    end)
end)

-- --- LOOPS (all idle features) ---

-- Auto Collect egg + incubator
task.spawn(function()
    while task.wait(1.5) do
        if Flags.AutoCollect then SetStatus("Collect", "auto (server-side)") end
        if Flags.AutoClaimIncubator then SetStatus("Incubator", Try("IncubatorClaim")) end
        if Flags.AutoCollect or Flags.AutoClaimIncubator then RefreshStatus() end
    end
end)

-- Auto Hatch + incubator insert/claim + optional Sell
task.spawn(function()
    while task.wait(Flags.HatchDelay) do
        if Flags.AutoHatch then
            SetStatus("Hatch", Try("HatchEgg", Flags.SelectedEgg, 1))
            if Flags.AutoClaimIncubator then Fire("IncubatorInsert", Flags.SelectedEgg) end
            if Flags.AutoSell then task.wait(0.3) SetStatus("Sell", Try("SellChickens", "All")) end
            RefreshStatus()
        end
    end
end)

-- Auto Fuse
task.spawn(function()
    while task.wait(3) do
        if Flags.AutoFuse then
            SetStatus("Fuse", Try("FuseChickens", "Duplicates"))
            RefreshStatus()
        end
    end
end)

-- Auto farm upgrades (Feeder: no remote in game - auto buy tag removed)
task.spawn(function()
    while task.wait(5) do
        if Flags.AutoCoop then
            Fire("ExpandCoop")
            SetStatus("Coop", "fired")
        else SetStatus("Coop", "off") end
        if Flags.AutoFeeder then
            SetStatus("Feeder", "no remote available")
        else SetStatus("Feeder", "off") end
        if Flags.AutoRecycler then
            Fire("UpgradeRecycler")
            SetStatus("Recycler", "fired")
        else SetStatus("Recycler", "off") end
        RefreshStatus()
    end
end)

-- Auto Tower Grind + Feed Before (event-driven: retreat/defeat handling)
local towerState = { grinding = false, ready = true, floored = 0 }
local function listenTower()
    local function on(ev, fn)
        local r = Remotes[ev]
        if r and r:IsA("RemoteEvent") then
            pcall(function() r.OnClientEvent:Connect(fn) end)
        end
    end
    on("TowerFloorCleared", function() towerState.floored = towerState.floored + 1 end)
    on("TowerRunStarted", function() towerState.floored = 0 end)
    on("TowerDefeat", function()
        towerState.grinding = false
        towerState.ready = false
        SetStatus("Tower", "defeat, waiting...")
        RefreshStatus()
        task.delay(math.random(6, 15), function() towerState.ready = true end)
    end)
    on("TowerContinueOffer", function()
        Fire("TowerContinueDecline")
        towerState.grinding = false
        towerState.ready = false
        SetStatus("Tower", "declined continue, waiting...")
        RefreshStatus()
        task.delay(math.random(5, 10), function() towerState.ready = true end)
    end)
end
listenTower()
task.spawn(function()
    while task.wait(2) do
        if Flags.AutoTower and towerState.ready then
            if Flags.FeedBefore then Fire("EncourageChicken") end
            if not towerState.grinding then
                Fire("TowerStart")
                towerState.grinding = true
            end
            Fire("TowerElevator")
            if towerState.floored >= Flags.TargetFloor then
                Fire("TowerSurrender")
                if Flags.AutoRebirth then Fire("Rebirth") end
                towerState.grinding = false
                towerState.ready = false
                SetStatus("Tower", "floor " .. towerState.floored .. "/" .. Flags.TargetFloor .. " reached, retreating")
                task.delay(math.random(3, 8), function() towerState.ready = true end)
            else
                SetStatus("Tower", "floor " .. towerState.floored .. "/" .. Flags.TargetFloor)
            end
            RefreshStatus()
        elseif not Flags.AutoTower then
            SetStatus("Tower", "off")
        end
    end
end)

-- Auto join events
task.spawn(function()
    while task.wait(7) do
        if Flags.AutoEvents then
            for _, en in ipairs(eventOptions) do
                if Flags.Events[en] then Fire("EventRsvp", en) end
            end
            SetStatus("Events", "fired")
            RefreshStatus()
        end
    end
end)

Notify("Loaded! RightShift = toggle GUI")