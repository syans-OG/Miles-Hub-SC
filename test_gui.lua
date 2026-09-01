-- ═══ DIAGNOSTIC: Test paste ini dulu, cek output di Dev Console (F9) ═══
print("[TEST] Script loaded!")
print("[TEST] Players service:", game:GetService("Players") ~= nil)
print("[TEST] LocalPlayer:", game:GetService("Players").LocalPlayer.Name)

local ok, err = pcall(function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "TestGUI"
    sg.ResetOnSpawn = false
    sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 300, 0, 60)
    f.Position = UDim2.new(0.5, -150, 0.5, -30)
    f.BackgroundColor3 = Color3.fromRGB(130, 90, 220)
    f.BorderSizePixel = 0
    
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, 0, 1, 0)
    t.BackgroundTransparency = 1
    t.Text = "TEST GUI WORKS!"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 18
end)

if ok then
    print("[TEST] GUI created SUCCESS!")
else
    print("[TEST] GUI FAILED:", err)
end