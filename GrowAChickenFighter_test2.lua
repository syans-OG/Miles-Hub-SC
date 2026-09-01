--[[
    ⚡ DIAGNOSTIC TEST
    Paste this di executor. Report notif mana yang TERAKHIR muncul.
    Kalau notif X muncul tapi X+1 tidak → crash di antara X dan X+1.
]]

task.wait(1)

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function N(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Miles-HUB",
            Text = text,
            Duration = 5
        })
    end)
    print("[TEST] " .. text)
end

N("TEST 1: Script loaded ✅")

-- ═══ TEST 2: Simple GUI (V3 pattern — PROVEN) ═══
local gui = Instance.new("ScreenGui")
gui.Name = "MilesHub"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 200)
main.Position = UDim2.new(0.5, -150, 0.5, -100)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 28)
tb.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)

local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, 0, 1, 0)
tt.BackgroundTransparency = 1
tt.Text = "TEST 2: GUI OK ✅"
tt.TextColor3 = Color3.fromRGB(240, 240, 240)
tt.Font = Enum.Font.GothamBold
tt.TextSize = 14

N("TEST 2: Simple GUI ✅")

-- ═══ TEST 3: Tabs ═══
local tabBtns = Instance.new("Frame", main)
tabBtns.Size = UDim2.new(0, 80, 1, -32)
tabBtns.Position = UDim2.new(0, 0, 0, 30)
tabBtns.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
tabBtns.BorderSizePixel = 0
Instance.new("UICorner", tabBtns).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -86, 1, -36)
content.Position = UDim2.new(0, 84, 0, 32)
content.BackgroundTransparency = 1

local tabFrames = {}

local function MakeTab(name)
    local btn = Instance.new("TextButton", tabBtns)
    btn.Size = UDim2.new(1, -4, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 160, 170)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local fr = Instance.new("ScrollingFrame", content)
    fr.Size = UDim2.new(1, 0, 1, 0)
    fr.BackgroundTransparency = 1
    fr.BorderSizePixel = 0
    fr.ScrollBarThickness = 2
    fr.CanvasSize = UDim2.new(0, 0, 0, 0)
    fr.AutomaticCanvasSize = Enum.AutomaticSize.Y
    fr.Visible = false
    Instance.new("UIListLayout", fr).Padding = UDim.new(0, 3)

    tabFrames[name] = {frame = fr, btn = btn}
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabFrames) do t.frame.Visible = false; t.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50); t.btn.TextColor3 = Color3.fromRGB(160, 160, 170) end
        fr.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(130, 90, 220); btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    end)
    return fr
end

local home = MakeTab("Home")
local egg = MakeTab("Egg")
local farm = MakeTab("Farm")
local tower = MakeTab("Tower")
local settings = MakeTab("Settings")

-- Activate first tab
home.Visible = true
tabFrames["Home"].btn.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
tabFrames["Home"].btn.TextColor3 = Color3.fromRGB(240, 240, 240)

N("TEST 3: 5 Tabs ✅")

-- ═══ TEST 4: Toggle + Button + Slider ═══
local function AddToggle(parent, name)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 24); f.BackgroundColor3 = Color3.fromRGB(35, 35, 50); f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -42, 1, 0); l.BackgroundTransparency = 1; l.Text = "  " .. name
    l.TextColor3 = Color3.fromRGB(240, 240, 240); l.Font = Enum.Font.GothamSemibold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 36, 0, 16); b.Position = UDim2.new(1, -40, 0.5, -8)
    b.BackgroundColor3 = Color3.fromRGB(80, 80, 90); b.Text = ""; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    local dot = Instance.new("Frame", b)
    dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240); dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(0, 6)
    local v = false
    b.MouseButton1Click:Connect(function()
        v = not v
        b.BackgroundColor3 = v and Color3.fromRGB(130, 90, 220) or Color3.fromRGB(80, 80, 90)
        dot:TweenPosition(v and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)
end

local function AddButton(parent, name)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = "  " .. name; b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold; b.TextSize = 10; b.TextXAlignment = Enum.TextXAlignment.Left; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
end

local function AddSection(parent, text)
    local s = Instance.new("TextLabel", parent)
    s.Size = UDim2.new(1, 0, 0, 16); s.BackgroundTransparency = 1
    s.Text = "  " .. text; s.TextColor3 = Color3.fromRGB(130, 90, 220)
    s.Font = Enum.Font.GothamBold; s.TextSize = 10; s.TextXAlignment = Enum.TextXAlignment.Left
end

AddSection(home, "INFO")
AddButton(home, "Player: " .. LP.Name)
AddSection(home, "MOVEMENT")
AddToggle(home, "Inf Jump")
AddToggle(home, "NoClip")

AddSection(egg, "HATCH")
AddToggle(egg, "Auto Hatch")
AddButton(egg, "🥚 Basic Egg")
AddButton(egg, "🥚 Forest Egg")
AddButton(egg, "🥚 Void Egg")
AddSection(egg, "SELL & FUSE")
AddButton(egg, "💵 Sell All")
AddButton(egg, "🧬 Fuse Now")

AddSection(farm, "UPGRADES")
AddToggle(farm, "Auto Coop")
AddToggle(farm, "Auto Feeder")
AddSection(farm, "EVENTS")
AddToggle(farm, "Auto Join Events")
AddToggle(farm, "🔥 Hot Eggs")

AddSection(tower, "TOWER")
AddToggle(tower, "Auto Tower")
AddButton(tower, "⚡ Rebirth Now")

AddSection(settings, "PERFORMANCE")
AddToggle(settings, "FPS Booster")
AddSection(settings, "MOVEMENT")
AddToggle(settings, "Inf Jump")
AddToggle(settings, "NoClip")

N("TEST 4: Toggles + Buttons ✅")

-- ═══ TEST 5: Floating Button ═══
pcall(function()
    local fg = Instance.new("ScreenGui")
    fg.Name = "Float"; fg.ResetOnSpawn = false; fg.DisplayOrder = 999999
    fg.Parent = LP:WaitForChild("PlayerGui")
    local fb = Instance.new("TextButton", fg)
    fb.Size = UDim2.new(0, 50, 0, 50); fb.Position = UDim2.new(0, 10, 0.3, 0)
    fb.BackgroundColor3 = Color3.fromRGB(20, 16, 35); fb.Text = "⚡"
    fb.TextColor3 = Color3.fromRGB(168, 85, 247); fb.Font = Enum.Font.GothamBold; fb.TextSize = 22
    fb.Active = true; fb.Draggable = true; fb.BorderSizePixel = 0
    Instance.new("UICorner", fb).CornerRadius = UDim.new(0.5, 0)
    Instance.new("UIStroke", fb).Color = Color3.fromRGB(168, 85, 247)
    fb.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)
end)

N("TEST 5: Floating Button ✅")
N("ALL TESTS PASSED! ⚡")
