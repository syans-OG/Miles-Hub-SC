-- ══════════════════════════════════════════════
-- ⚡ Miles-HUB v2.2 — Grow A Chicken Fighter
-- Self-contained (no external dependencies)
-- ══════════════════════════════════════════════

-- Immediate visual confirmation that script loaded
pcall(function()
    local sg = Instance.new("ScreenGui")
    sg.Name = "MilesHub_LoadConfirm"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 999999
    -- Try multiple parents for mobile compatibility
    for _, p in ipairs({
        gethui and gethui(),
        game:GetService("CoreGui"),
        game:GetService("StarterGui"),
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"),
    }) do
        if p then
            local ok = pcall(function() sg.Parent = p end)
            if ok and sg.Parent then break end
        end
    end
    if sg.Parent then
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 280, 0, 50)
        f.Position = UDim2.new(0.5, -140, 0, 10)
        f.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        f.BorderSizePixel = 0
        f.Parent = sg
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local s = Instance.new("UIStroke", f)
        s.Color = Color3.fromRGB(168, 85, 247)
        s.Thickness = 2
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -16, 1, 0)
        t.Position = UDim2.new(0, 8, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = "⚡ Miles-HUB v2.2 Loaded!"
        t.TextColor3 = Color3.fromRGB(168, 85, 247)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 14
        t.Parent = f
        task.delay(4, function() pcall(function() sg:Destroy() end) end)
    end
end)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Small delay to avoid rate-based anti-cheat detection
task.wait(0.5)

local SessionStartTime = os.time()
local SessionEggsHatched = 0
local SessionRebirths = 0

-- ══════════════════════════════════════════════
-- 🏷️ Miles-HUB v2.2 — Grow A Chicken Fighter
-- ══════════════════════════════════════════════
local HUB_VERSION = "2.2"
local HUB_TITLE = "⚡ Miles-HUB v" .. HUB_VERSION

-- ═══ Inline MiniRayfield UI (self-contained) ═══
local COLORS = {
    Background = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(130, 90, 220),
    Text = Color3.fromRGB(240, 240, 240),
    Subtext = Color3.fromRGB(160, 160, 170),
    ElementBG = Color3.fromRGB(35, 35, 50),
    ToggleOn = Color3.fromRGB(130, 90, 220),
    ToggleOff = Color3.fromRGB(80, 80, 90),
    SliderBar = Color3.fromRGB(130, 90, 220),
    SliderBG = Color3.fromRGB(50, 50, 65),
    Border = Color3.fromRGB(60, 60, 80),
}
local function addCorner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p end
local function addStroke(p,c,t) local s=Instance.new("UIStroke"); s.Color=c or COLORS.Border; s.Thickness=t or 1; s.Parent=p end
local function addPad(p,t,b,l,r) local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,t or 8); u.PaddingBottom=UDim.new(0,b or 8); u.PaddingLeft=UDim.new(0,l or 10); u.PaddingRight=UDim.new(0,r or 10); u.Parent=p end
local function addList(p,spd) local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,spd or 6); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Parent=p end
local Rayfield = {}
Rayfield.__index = Rayfield
function Rayfield:CreateWindow(opts)
    local w = setmetatable({}, {__index = Rayfield})
    w.Name = opts.Name or "Miles-HUB"
    w.Gui = Instance.new("ScreenGui")
    w.Gui.Name = "MR_"..math.random(1000,9999)
    w.Gui.ResetOnSpawn = false
    w.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    w.Gui.DisplayOrder = 999999
    -- Mobile-safe: try multiple parents (CoreGui often blocked on mobile executors)
    local success = false
    for _, parent in ipairs({
        gethui and gethui(),
        game:GetService("CoreGui"),
        game:GetService("StarterGui"),
        LocalPlayer:WaitForChild("PlayerGui"),
    }) do
        if parent then
            local ok = pcall(function() w.Gui.Parent = parent end)
            if ok and w.Gui.Parent then success = true break end
        end
    end
    if not success then
        warn("[Miles-HUB] Cannot create GUI — all parent containers failed")
        return setmetatable({}, {__index = Rayfield})
    end
    -- Responsive size for mobile
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local guiW = isMobile and 340 or 520
    local guiH = isMobile and 260 or 380
    w.Main = Instance.new("Frame")
    w.Main.Size = UDim2.new(0, guiW, 0, guiH)
    w.Main.Position = UDim2.new(0.5, -guiW/2, 0.5, -guiH/2)
    w.Main.BackgroundColor3 = COLORS.Background
    w.Main.BorderSizePixel = 0
    w.Main.Active = true
    w.Main.Draggable = true
    w.Main.Parent = w.Gui
    addCorner(w.Main, 10)
    addStroke(w.Main, COLORS.Border, 1.5)
    local tb = Instance.new("Frame"); tb.Size=UDim2.new(1,0,0,36); tb.BackgroundColor3=COLORS.Accent; tb.BorderSizePixel=0; tb.Parent=w.Main; addCorner(tb,10)
    local tl = Instance.new("TextLabel"); tl.Size=UDim2.new(1,-20,1,0); tl.Position=UDim2.new(0,10,0,0); tl.BackgroundTransparency=1; tl.Text=w.Name; tl.TextColor3=COLORS.Text; tl.Font=Enum.Font.GothamBold; tl.TextSize=14; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=tb
    local cbtn = Instance.new("TextButton"); cbtn.Size=UDim2.new(0,28,0,28); cbtn.Position=UDim2.new(1,-32,0,4); cbtn.BackgroundColor3=Color3.fromRGB(200,60,60); cbtn.Text="X"; cbtn.TextColor3=COLORS.Text; cbtn.Font=Enum.Font.GothamBold; cbtn.TextSize=12; cbtn.Parent=tb; addCorner(cbtn,6)
    cbtn.MouseButton1Click:Connect(function() w.Gui.Enabled=not w.Gui.Enabled end)
    w.TabBtns = Instance.new("Frame"); w.TabBtns.Size=UDim2.new(0,130,1,-40); w.TabBtns.Position=UDim2.new(0,0,0,38); w.TabBtns.BackgroundColor3=Color3.fromRGB(30,30,42); w.TabBtns.BorderSizePixel=0; w.TabBtns.Parent=w.Main; addCorner(w.TabBtns,8); addPad(w.TabBtns,6,6,6,6); addList(w.TabBtns,4)
    w.Content = Instance.new("Frame"); w.Content.Size=UDim2.new(1,-138,1,-44); w.Content.Position=UDim2.new(0,134,0,40); w.Content.BackgroundTransparency=1; w.Content.BorderSizePixel=0; w.Content.Parent=w.Main
    w.Tabs = {}; w.TabCount = 0
    return w
end
function Rayfield:CreateTab(name)
    self.TabCount = self.TabCount + 1
    local tab = {}
    tab.Window = self
    tab.Order = self.TabCount
    local btn = Instance.new("TextButton"); btn.Size=UDim2.new(1,0,0,30); btn.BackgroundColor3=COLORS.ElementBG; btn.Text=name; btn.TextColor3=COLORS.Subtext; btn.Font=Enum.Font.GothamSemibold; btn.TextSize=11; btn.BorderSizePixel=0; btn.LayoutOrder=self.TabCount; btn.Parent=self.TabBtns; addCorner(btn,6)
    local cf = Instance.new("ScrollingFrame"); cf.Size=UDim2.new(1,0,1,0); cf.BackgroundTransparency=1; cf.BorderSizePixel=0; cf.ScrollBarThickness=4; cf.ScrollBarImageColor3=COLORS.Accent; cf.CanvasSize=UDim2.new(0,0,0,0); cf.AutomaticCanvasSize=Enum.AutomaticSize.Y; cf.Visible=false; cf.Parent=self.Content; addPad(cf,6,6,6,6); addList(cf,4)
    tab.ContentFrame = cf
    tab.Button = btn
    self.Tabs[name] = tab
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.Tabs) do t.ContentFrame.Visible=false; t.Button.BackgroundColor3=COLORS.ElementBG; t.Button.TextColor3=COLORS.Subtext end
        cf.Visible=true; btn.BackgroundColor3=COLORS.Accent; btn.TextColor3=COLORS.Text
    end)
    if self.TabCount == 1 then cf.Visible=true; btn.BackgroundColor3=COLORS.Accent; btn.TextColor3=COLORS.Text end
    function tab:CreateSection(n)
        local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,0,0,24); l.BackgroundTransparency=1; l.Text="  "..n; l.TextColor3=COLORS.Accent; l.Font=Enum.Font.GothamBold; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; l.Parent=self.ContentFrame
    end
    function tab:CreateParagraph(o)
        local p=Instance.new("TextLabel"); p.Size=UDim2.new(1,0,0,40); p.BackgroundColor3=COLORS.ElementBG; p.Text="  "..(o.Title or "").."\n  "..(o.Content or ""); p.TextColor3=COLORS.Subtext; p.Font=Enum.Font.Gotham; p.TextSize=11; p.TextWrapped=true; p.TextXAlignment=Enum.TextXAlignment.Left; p.TextYAlignment=Enum.TextYAlignment.Top; p.BorderSizePixel=0; p.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; p.Parent=self.ContentFrame; addCorner(p,6); addPad(p,4,4,8,8)
        local obj={Label=p}
        function obj:Set(n) p.Text="  "..(n.Title or "").."\n  "..(n.Content or "") end
        return obj
    end
    function tab:CreateButton(o)
        local b=Instance.new("TextButton"); b.Size=UDim2.new(1,0,0,32); b.BackgroundColor3=COLORS.ElementBG; b.Text="  "..(o.Name or "Button"); b.TextColor3=COLORS.Text; b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.TextXAlignment=Enum.TextXAlignment.Left; b.BorderSizePixel=0; b.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; b.Parent=self.ContentFrame; addCorner(b,6); addPad(b,0,0,8,8)
        b.MouseButton1Click:Connect(function() pcall(o.Callback) end)
        b.MouseEnter:Connect(function() b.BackgroundColor3=Color3.fromRGB(50,50,65) end)
        b.MouseLeave:Connect(function() b.BackgroundColor3=COLORS.ElementBG end)
    end
    function tab:CreateToggle(o)
        local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,32); f.BackgroundColor3=COLORS.ElementBG; f.BorderSizePixel=0; f.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; f.Parent=self.ContentFrame; addCorner(f,6); addPad(f,0,0,8,8)
        local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(1,-50,1,0); lb.BackgroundTransparency=1; lb.Text="  "..(o.Name or "Toggle"); lb.TextColor3=COLORS.Text; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
        local bg=Instance.new("TextButton"); bg.Size=UDim2.new(0,40,0,20); bg.Position=UDim2.new(1,-46,0.5,-10); bg.BackgroundColor3=o.CurrentValue and COLORS.ToggleOn or COLORS.ToggleOff; bg.Text=""; bg.BorderSizePixel=0; bg.Parent=f; addCorner(bg,10)
        local ci=Instance.new("Frame"); ci.Size=UDim2.new(0,16,0,16); ci.Position=o.CurrentValue and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8); ci.BackgroundColor3=COLORS.Text; ci.BorderSizePixel=0; ci.Parent=bg; addCorner(ci,8)
        local v=o.CurrentValue or false
        bg.MouseButton1Click:Connect(function() v=not v; bg.BackgroundColor3=v and COLORS.ToggleOn or COLORS.ToggleOff; ci:TweenPosition(v and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true); pcall(o.Callback,v) end)
        return {Set=function(_,nv) v=nv; bg.BackgroundColor3=v and COLORS.ToggleOn or COLORS.ToggleOff; ci.Position=v and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8) end}
    end
    function tab:CreateSlider(o)
        local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,44); f.BackgroundColor3=COLORS.ElementBG; f.BorderSizePixel=0; f.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; f.Parent=self.ContentFrame; addCorner(f,6); addPad(f,4,4,8,8)
        local rng=o.Range or {0,100}; local inc=o.Increment or 1; local cur=o.CurrentValue or rng[1]; local suf=o.Suffix or ""
        local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.6,0,0,18); lb.BackgroundTransparency=1; lb.Text="  "..(o.Name or "Slider"); lb.TextColor3=COLORS.Text; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
        local vl=Instance.new("TextLabel"); vl.Size=UDim2.new(0.35,0,0,18); vl.Position=UDim2.new(0.63,0,0,0); vl.BackgroundTransparency=1; vl.Text=tostring(cur)..suf; vl.TextColor3=COLORS.Accent; vl.Font=Enum.Font.GothamBold; vl.TextSize=11; vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=f
        local bb=Instance.new("Frame"); bb.Size=UDim2.new(1,0,0,8); bb.Position=UDim2.new(0,0,0,26); bb.BackgroundColor3=COLORS.SliderBG; bb.BorderSizePixel=0; bb.Parent=f; addCorner(bb,4)
        local fill=(cur-rng[1])/(rng[2]-rng[1])
        local bf=Instance.new("Frame"); bf.Size=UDim2.new(math.clamp(fill,0,1),0,1,0); bf.BackgroundColor3=COLORS.SliderBar; bf.BorderSizePixel=0; bf.Parent=bb; addCorner(bf,4)
        local kn=Instance.new("TextButton"); kn.Size=UDim2.new(0,16,0,16); kn.Position=UDim2.new(math.clamp(fill,0,1),-8,0.5,-8); kn.BackgroundColor3=COLORS.Text; kn.Text=""; kn.BorderSizePixel=0; kn.ZIndex=2; kn.Parent=bb; addCorner(kn,8)
        local drag=false
        kn.MouseButton1Down:Connect(function() drag=true end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                local pct=math.clamp((i.Position.X-bb.AbsolutePosition.X)/bb.AbsoluteSize.X,0,1)
                cur=math.floor((rng[1]+pct*(rng[2]-rng[1]))/inc+0.5)*inc
                cur=math.clamp(cur,rng[1],rng[2])
                local nf=(cur-rng[1])/(rng[2]-rng[1])
                bf.Size=UDim2.new(nf,0,1,0); kn.Position=UDim2.new(nf,-8,0.5,-8); vl.Text=tostring(cur)..suf
                pcall(o.Callback,cur)
            end
        end)
        return {Set=function(_,v) cur=math.clamp(v,rng[1],rng[2]); local nf=(cur-rng[1])/(rng[2]-rng[1]); bf.Size=UDim2.new(nf,0,1,0); kn.Position=UDim2.new(nf,-8,0.5,-8); vl.Text=tostring(cur)..suf end}
    end
    function tab:CreateDropdown(o)
        local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,32); f.BackgroundColor3=COLORS.ElementBG; f.BorderSizePixel=0; f.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; f.Parent=self.ContentFrame; addCorner(f,6)
        local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.45,0,1,0); lb.BackgroundTransparency=1; lb.Text="  "..(o.Name or "Dropdown"); lb.TextColor3=COLORS.Text; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=11; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
        local sel=Instance.new("TextLabel"); sel.Size=UDim2.new(0.5,-10,1,0); sel.Position=UDim2.new(0.48,0,0,0); sel.BackgroundTransparency=1; local co=o.CurrentOption; if type(co)=="table" then co=co[1] end; sel.Text=co or "None"; sel.TextColor3=COLORS.Accent; sel.Font=Enum.Font.Gotham; sel.TextSize=11; sel.TextXAlignment=Enum.TextXAlignment.Right; sel.Parent=f
        local open=false; local lf=nil
        local bt=Instance.new("TextButton"); bt.Size=UDim2.new(1,0,1,0); bt.BackgroundTransparency=1; bt.Text=""; bt.Parent=f
        bt.MouseButton1Click:Connect(function()
            open=not open
            if open then
                lf=Instance.new("Frame"); lf.Size=UDim2.new(1,0,0,math.min(#o.Options*28,140)); lf.Position=UDim2.new(0,0,1,4); lf.BackgroundColor3=COLORS.ElementBG; lf.BorderSizePixel=0; lf.ZIndex=10; lf.Parent=f; addCorner(lf,6); addStroke(lf,COLORS.Border); addList(lf,2)
                for _,opt in ipairs(o.Options) do
                    local ob=Instance.new("TextButton"); ob.Size=UDim2.new(1,0,0,26); ob.BackgroundColor3=COLORS.Background; ob.Text="  "..opt; ob.TextColor3=COLORS.Text; ob.Font=Enum.Font.Gotham; ob.TextSize=11; ob.TextXAlignment=Enum.TextXAlignment.Left; ob.BorderSizePixel=0; ob.ZIndex=11; ob.Parent=lf; addCorner(ob,4); addPad(ob,0,0,6,6)
                    ob.MouseButton1Click:Connect(function() sel.Text=opt; open=false; if lf then lf:Destroy() end; pcall(o.Callback,{opt}) end)
                end
            else if lf then lf:Destroy() end end
        end)
        return {Set=function(_,no) if type(no)=="table" then o.Options=no; if no[1] then sel.Text=no[1] end end end}
    end
    function tab:CreateKeybind(o)
        local f=Instance.new("Frame"); f.Size=UDim2.new(1,0,0,32); f.BackgroundColor3=COLORS.ElementBG; f.BorderSizePixel=0; f.LayoutOrder=#self.ContentFrame:GetChildren()*10+1; f.Parent=self.ContentFrame; addCorner(f,6); addPad(f,0,0,8,8)
        local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.6,0,1,0); lb.BackgroundTransparency=1; lb.Text="  "..(o.Name or "Keybind"); lb.TextColor3=COLORS.Text; lb.Font=Enum.Font.GothamSemibold; lb.TextSize=12; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=f
        local kl=Instance.new("TextLabel"); kl.Size=UDim2.new(0.35,0,1,0); kl.Position=UDim2.new(0.63,0,0,0); kl.BackgroundTransparency=1; kl.Text=o.CurrentKeybind or "None"; kl.TextColor3=COLORS.Accent; kl.Font=Enum.Font.GothamBold; kl.TextSize=11; kl.TextXAlignment=Enum.TextXAlignment.Right; kl.Parent=f
        local listen=false
        local kb=Instance.new("TextButton"); kb.Size=UDim2.new(1,0,1,0); kb.BackgroundTransparency=1; kb.Text=""; kb.Parent=f
        kb.MouseButton1Click:Connect(function() listen=true; kl.Text="..."; kl.TextColor3=COLORS.Text end)
        UserInputService.InputBegan:Connect(function(i,gpe)
            if gpe then return end
            if listen then listen=false; local n=i.KeyCode.Name; if n=="Unknown" then n=i.UserInputType.Name end; kl.Text=n; kl.TextColor3=COLORS.Accent; o.CurrentKeybind=n; pcall(o.Callback)
            elseif i.KeyCode.Name==(o.CurrentKeybind or "") then pcall(o.Callback) end
        end)
    end
    function Rayfield:Notify(o) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title=o.Title or "Miles-HUB", Text=o.Content or "", Duration=o.Duration or 3}) end) end
    return w
end
function Rayfield:Notify(o) pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title=o.Title or "Miles-HUB", Text=o.Content or "", Duration=o.Duration or 3}) end) end
-- ═══ End Inline Rayfield ═══

local function SafeNotify(opts)
    if Rayfield then
        pcall(function() Rayfield:Notify(opts) end)
    else
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = opts.Title or HUB_TITLE,
                Text = opts.Content or "",
                Duration = opts.Duration or 3
            })
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Anti-cheat hooks removed (BAC-2515 detection vector)

local EggDatabase = {}

local function ScanLiveGameDatabase()
    local discovered = {}
    local totalFound = 0

    for _, module in ipairs(ReplicatedStorage:GetDescendants()) do
        if module:IsA("ModuleScript") then
            local nameLower = module.Name:lower()
            if string.find(nameLower, "egg") or string.find(nameLower, "pet") or string.find(nameLower, "chicken") or string.find(nameLower, "item") or string.find(nameLower, "data") then
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
                                        totalFound = totalFound + 1
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local nameLower = obj.Name:lower()
            if string.find(nameLower, "egg") and not string.find(nameLower, "icon") and not string.find(nameLower, "spawn") then
                local eggName = obj.Name
                if not discovered[eggName] then discovered[eggName] = {} end
                for _, child in ipairs(obj:GetChildren()) do
                    if child:IsA("Model") or child:IsA("BasePart") or child:IsA("BillboardGui") then
                        local childName = child.Name
                        if not string.find(childName:lower(), "part") and not string.find(childName:lower(), "egg") and not string.find(childName:lower(), "stand") then
                            table.insert(discovered[eggName], childName)
                            totalFound = totalFound + 1
                        end
                    end
                end
            end
        end
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                local frameName = gui.Name:lower()
                if string.find(frameName, "egg") or string.find(frameName, "index") or string.find(frameName, "collection") or string.find(frameName, "pet") then
                    for _, child in ipairs(gui:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("ImageButton") then
                            local petLabel = child:FindFirstChildWhichIsA("TextLabel")
                            local petName = petLabel and petLabel.Text or child.Name
                            if petName and #petName > 2 and not string.find(petName:lower(), "frame") and not string.find(petName:lower(), "uicorner") and not string.find(petName:lower(), "layout") then
                                local parentEgg = gui.Name
                                if not discovered[parentEgg] then discovered[parentEgg] = {} end
                                table.insert(discovered[parentEgg], petName)
                                totalFound = totalFound + 1
                            end
                        end
                    end
                end
            end
        end
    end

    if totalFound == 0 then
        discovered = {
            ["Basic Egg"] = {"Common Chicken", "Spotted Chicken", "Brown Rooster", "Golden Rooster"},
            ["Forest Egg"] = {"Leaf Chick", "Forest Fighter", "Woodland Brawler", "Treant Rooster"},
            ["Desert Egg"] = {"Sand Chick", "Cactus Fighter", "Desert Hawk", "Mummy Chicken"},
            ["Magma Egg"] = {"Flame Chick", "Magma Fighter", "Lava Rooster", "Phoenix Chicken"},
            ["Cyber Egg"] = {"Neon Chick", "Cyber Brawler", "Mecha Rooster", "Quantum Chicken"},
            ["Void Egg"] = {"Shadow Chick", "Void Fighter", "Dark Lord Rooster", "Celestial Chicken"}
        }
    end

    for egg, pets in pairs(discovered) do
        local seen = {}
        local cleanList = {}
        for _, p in ipairs(pets) do
            if not seen[p] then
                seen[p] = true
                table.insert(cleanList, p)
            end
        end
        discovered[egg] = cleanList
    end

    EggDatabase = discovered
    return discovered, totalFound
end

ScanLiveGameDatabase()

local Flags = {
    AntiAFK = true,
    FPSBooster = false,
    LowGPUMode = false,
    FPSCap = 60,
    AutoReconnect = false, -- Disabled: can cause re-kick loop with anti-cheat
    ShowFloatingButton = true,

    AutoJoinEvents = false,
    AutoHopOnEventEnd = false,
    EventsToJoin = {
        ["Hot Eggs"] = true,
        ["UFO Invasion"] = true,
        ["Golden Goose"] = true,
        ["Chicken Boss"] = true,
    },

    AutoTowerGrind = false,
    TargetTowerFloor = 20,
    FeedBeforeFight = true,
    SmartRebirthExploit = false,
    AutoCollectScrap = false,
    TowerAttackDelay = 0.15,

    AutoCollectEggs = false,
    AutoClaimIncubator = false,
    CollectRadius = 50,

    AutoHatch = false,
    SelectedEgg = "Basic Egg",
    HatchDelay = 0.5,
    InventoryEggsList = {},

    AutoSellOnHatch = false,
    SelectedChickensToSell = {},

    AutoFuseDuplicates = false,
    SelectedChickenToFuse = "All Duplicates",
    FuseRarityOnly = true,

    AutoBuyUpgradeCoop = false,
    AutoBuyUpgradeFeeder = false,
    AutoBuyUpgradeRecycler = false,
    FarmUpgradeDelay = 1.0,

    AutoTrain = false,
    AutoPunch = false,
    FarmSpeed = 0.1,

    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    NoClip = false,
}

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
    JoinEvent = ScanRemote({"JoinEvent", "EventJoin", "EnterEvent", "TeleportEvent", "EventTeleport", "ParticipateEvent", "Event", "JoinWorldEvent"}),
    Tower = ScanRemote({"TowerFight", "StartTower", "TowerNextFloor", "ClimbTower", "TowerAttack", "EnterTower", "Tower", "FloorFight"}),
    FeedChicken = ScanRemote({"FeedChicken", "Feed", "FeedAll", "GiveFood", "FeedEvent", "FeederFeed"}),
    CollectScrap = ScanRemote({"CollectScrap", "PickupScrap", "ScrapPickup", "CollectTrash", "Scrap", "CollectDebris"}),
    RecycleScrap = ScanRemote({"RecycleScrap", "DepositRecycler", "Recycle", "SellScrap", "RecyclerDeposit", "RecyclerEvent", "DepositScrap"}),
    Rebirth = ScanRemote({"Rebirth", "RebirthEvent", "BuyRebirth", "DoRebirth"}),
    CollectEgg = ScanRemote({"CollectEgg", "PickupEgg", "Collect", "Pickup", "EggPickup"}),
    ClaimIncubator = ScanRemote({"ClaimIncubator", "IncubatorClaim", "ClaimEgg", "Incubator"}),
    Hatch = ScanRemote({"HatchEgg", "OpenEgg", "BuyEgg", "EggHatch", "Hatch"}),
    SellChicken = ScanRemote({"SellChicken", "DeleteChicken", "SellPet", "DeletePet", "Sell", "TrashPet"}),
    FuseChicken = ScanRemote({"FuseChicken", "FusePet", "Fuse", "Combine", "Craft", "EvolveChicken"}),
    EquipBest = ScanRemote({"EquipBest", "AutoEquip", "EquipAll", "BestPets"}),
    BuyCoop = ScanRemote({"BuyCoop", "PurchaseCoop", "UnlockCoop", "CoopBuy", "Coop", "BuyChickenCoop"}),
    UpgradeCoop = ScanRemote({"UpgradeCoop", "CoopUpgrade", "UpgradeChickenCoop", "CoopLevel"}),
    BuyFeeder = ScanRemote({"BuyFeeder", "PurchaseFeeder", "UnlockFeeder", "FeederBuy", "Feeder"}),
    UpgradeFeeder = ScanRemote({"UpgradeFeeder", "FeederUpgrade", "UpgradeFood", "FeederLevel"}),
    UpgradeRecycler = ScanRemote({"UpgradeRecycler", "RecyclerUpgrade", "BuyRecycler", "RecycleUpgrade", "RecyclerEvent", "Recycler"}),
    Train = ScanRemote({"Train", "GainStrength", "ClickEvent", "TrainEvent", "Tap", "Workout"}),
    Punch = ScanRemote({"Punch", "Attack", "Hit", "Fight", "Swing", "Battle"}),
}

local function SafeInvoke(remote, ...)
    if not remote then return false end
    local jitter = math.random(10, 80) / 1000
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

local function TriggerPromptByName(targetKeywords)
    if not fireproximityprompt then return end
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parentName = (prompt.Parent and prompt.Parent.Name or ""):lower()
            local grandParentName = (prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""):lower()
            for _, keyword in ipairs(targetKeywords) do
                if string.find(parentName, keyword:lower()) or string.find(grandParentName, keyword:lower()) then
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
                    task.wait(0.05)
                end
            end
        end
    end
end

local function GetTop5Chickens()
    local myChickens = {}

    local playerData = ReplicatedStorage:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("Datas")
    if playerData then
        local userFolder = playerData:FindFirstChild(tostring(LocalPlayer.UserId)) or playerData:FindFirstChild(LocalPlayer.Name)
        if userFolder and (userFolder:FindFirstChild("Chickens") or userFolder:FindFirstChild("Pets")) then
            local petsFolder = userFolder:FindFirstChild("Chickens") or userFolder:FindFirstChild("Pets")
            for _, pet in ipairs(petsFolder:GetChildren()) do
                local powerVal = pet:FindFirstChild("Multiplier") or pet:FindFirstChild("Power") or pet:FindFirstChild("Damage") or pet:FindFirstChild("Level")
                local power = powerVal and tonumber(powerVal.Value) or 100
                table.insert(myChickens, {Name = pet.Name, Power = power})
            end
        end
    end

    if #myChickens == 0 then
        table.insert(myChickens, {Name = "Celestial Chicken", Power = 50000, Tier = "Mythic"})
        table.insert(myChickens, {Name = "Dark Lord Rooster", Power = 25000, Tier = "Legendary"})
        table.insert(myChickens, {Name = "Phoenix Chicken", Power = 12000, Tier = "Legendary"})
        table.insert(myChickens, {Name = "Quantum Chicken", Power = 6000, Tier = "Epic"})
        table.insert(myChickens, {Name = "Lava Rooster", Power = 3000, Tier = "Rare"})
    end

    table.sort(myChickens, function(a, b) return a.Power > b.Power end)

    local top5 = {}
    for i = 1, math.min(5, #myChickens) do
        table.insert(top5, myChickens[i])
    end
    return top5
end

local function ApplyFPSBooster(enable)
    pcall(function()
        if enable then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1

            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 0
            end

            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = false
                end
            end

            for _, v in ipairs(game:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
            end
        end
    end)
end

local function SetLowGPUMode(enable)
    pcall(function()
        RunService:Set3dRenderingEnabled(not enable)
    end)
end

local function GetPlayerInventoryEggs()
    local foundEggs = {}
    local eggSet = {}

    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(item.Name:lower(), "egg") then
            if not eggSet[item.Name] then
                eggSet[item.Name] = true
                table.insert(foundEggs, item.Name)
            end
        end
    end

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, guiItem in ipairs(playerGui:GetDescendants()) do
            if guiItem:IsA("TextLabel") or guiItem:IsA("ImageLabel") then
                local text = guiItem.Name
                if string.find(text:lower(), "egg") and not string.find(text:lower(), "icon") then
                    if not eggSet[text] then
                        eggSet[text] = true
                        table.insert(foundEggs, text)
                    end
                end
            end
        end
    end

    local playerData = ReplicatedStorage:FindFirstChild("PlayerData") or ReplicatedStorage:FindFirstChild("Datas")
    if playerData then
        local userFolder = playerData:FindFirstChild(tostring(LocalPlayer.UserId)) or playerData:FindFirstChild(LocalPlayer.Name)
        if userFolder and userFolder:FindFirstChild("Eggs") then
            for _, egg in ipairs(userFolder.Eggs:GetChildren()) do
                if not eggSet[egg.Name] then
                    eggSet[egg.Name] = true
                    table.insert(foundEggs, egg.Name)
                end
            end
        end
    end

    if #foundEggs == 0 then
        for eggName, _ in pairs(EggDatabase) do
            table.insert(foundEggs, eggName)
        end
    end

    return foundEggs
end

local function CollectScrapInMap()
    if Character and HumanoidRootPart then
        SafeInvoke(Remotes.CollectScrap)
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local nameLower = obj.Name:lower()
                if string.find(nameLower, "scrap") or string.find(nameLower, "trash") or string.find(nameLower, "debris") then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part and (part.Position - HumanoidRootPart.Position).Magnitude <= Flags.CollectRadius * 2 then
                        if firetouchinterest then
                            firetouchinterest(HumanoidRootPart, part, 0)
                            task.wait(0.05)
                            firetouchinterest(HumanoidRootPart, part, 1)
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
    end
end

local function TryJoinEvent(eventName)
    SafeInvoke(Remotes.JoinEvent, eventName)
    SafeInvoke(Remotes.JoinEvent, "Join", eventName)
    SafeInvoke(Remotes.JoinEvent, "Enter", eventName)

    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and gui.Visible then
                local parentText = (gui.Parent and gui.Parent:FindFirstChildWhichIsA("TextLabel") and gui.Parent:FindFirstChildWhichIsA("TextLabel").Text or ""):lower()
                local btnText = (gui:IsA("TextButton") and gui.Text or gui.Name):lower()
                if string.find(parentText, eventName:lower()) or string.find(gui.Name:lower(), eventName:lower()) then
                    if string.find(btnText, "join") or string.find(btnText, "enter") or string.find(btnText, "yes") or string.find(btnText, "go") then
                        pcall(function()
                            gui.MouseButton1Click:Fire()
                        end)
                    end
                end
            end
        end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local nameLower = obj.Name:lower()
            local cleanName = eventName:lower():gsub("%s+", "")
            if string.find(nameLower, cleanName) or (string.find(nameLower, "portal") and string.find(nameLower, eventName:lower():sub(1, 4))) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                if part and Character and HumanoidRootPart then
                    if firetouchinterest then
                        firetouchinterest(HumanoidRootPart, part, 0)
                        task.wait(0.05)
                        firetouchinterest(HumanoidRootPart, part, 1)
                    end
                end
            end
        end
    end
end

local function ExecuteSmartRebirthGlitch()
    CollectScrapInMap()
    task.wait(0.15)
    SafeInvoke(Remotes.FeedChicken, "All")

    task.spawn(function()
        SafeInvoke(Remotes.RecycleScrap, "All")
        TriggerPromptByName({"recycle", "recycler", "deposit", "depositscrap"})
    end)

    task.spawn(function()
        SafeInvoke(Remotes.Rebirth, "DoRebirth")
        SafeInvoke(Remotes.Rebirth)
        SessionRebirths = SessionRebirths + 1
    end)

    SafeNotify({
        Title = HUB_TITLE,
        Content = "Scrap berhasil dijual bersamaan dengan Rebirth (Uang masuk ke siklus baru)!",
        Duration = 3.5,
        Image = 4483362458
    })
end

local function DoServerHop(mode)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local res = game:HttpGet(url)
        local data = HttpService:JSONDecode(res)
        if data and data.data then
            local serverList = data.data
            if mode == "lowest" then
                table.sort(serverList, function(a, b) return a.playing < b.playing end)
            elseif mode == "highest" then
                table.sort(serverList, function(a, b) return a.playing > b.playing end)
            end

            for _, server in ipairs(serverList) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end)
end

GuiService.ErrorMessageChanged:Connect(function()
    if Flags.AutoReconnect then
        task.wait(1.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

LocalPlayer.Idled:Connect(function()
    if Flags.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
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

UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump and Character and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Stepped:Connect(function()
    if Flags.NoClip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
    end
end)

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

task.spawn(function()
    while true do
        if Flags.AutoJoinEvents then
            pcall(function()
                for eventName, isEnabled in pairs(Flags.EventsToJoin) do
                    if isEnabled then
                        TryJoinEvent(eventName)
                    end
                end
            end)
        end
        task.wait(2.5)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoTowerGrind then
            pcall(function()
                if Flags.FeedBeforeFight and Remotes.FeedChicken then
                    SafeInvoke(Remotes.FeedChicken, "All")
                    TriggerPromptByName({"feeder", "feed", "givefood"})
                end

                if Flags.AutoCollectScrap then
                    CollectScrapInMap()
                end

                if Remotes.Tower then
                    SafeInvoke(Remotes.Tower, "Start")
                    SafeInvoke(Remotes.Tower, "Attack")
                    SafeInvoke(Remotes.Tower, "NextFloor")
                end
                if Remotes.Punch then
                    SafeInvoke(Remotes.Punch)
                end

                local currentFloor = 1
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                if leaderstats then
                    local floorVal = leaderstats:FindFirstChild("Floor") or leaderstats:FindFirstChild("Tower") or leaderstats:FindFirstChild("Stage")
                    if floorVal and floorVal.Value then
                        currentFloor = tonumber(floorVal.Value) or 1
                    end
                end

                if currentFloor >= Flags.TargetTowerFloor then
                    if Flags.SmartRebirthExploit then
                        ExecuteSmartRebirthGlitch()
                        task.wait(2.5)
                    end
                end
            end)
        end
        task.wait(Flags.TowerAttackDelay)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoCollectEggs and Character and HumanoidRootPart then
            pcall(function()
                SafeInvoke(Remotes.CollectEgg)
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") or obj:IsA("Model") then
                        local nameLower = obj.Name:lower()
                        if string.find(nameLower, "egg") or string.find(nameLower, "pickup") or string.find(nameLower, "drop") then
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                            if part and (part.Position - HumanoidRootPart.Position).Magnitude <= Flags.CollectRadius then
                                if firetouchinterest then
                                    firetouchinterest(HumanoidRootPart, part, 0)
                                    task.wait(0.05)
                                    firetouchinterest(HumanoidRootPart, part, 1)
                                end
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoClaimIncubator then
            pcall(function()
                if Remotes.ClaimIncubator then
                    for slot = 1, 10 do
                        SafeInvoke(Remotes.ClaimIncubator, slot)
                    end
                else
                    TriggerPromptByName({"incubator", "claim", "hatcher"})
                end
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoHatch and Remotes.Hatch then
            pcall(function()
                local eggToHatch = Flags.SelectedEgg
                SafeInvoke(Remotes.Hatch, eggToHatch, 1)
                SessionEggsHatched = SessionEggsHatched + 1

                if Flags.AutoSellOnHatch and Remotes.SellChicken then
                    task.wait(0.2)
                    for chickenName, shouldSell in pairs(Flags.SelectedChickensToSell) do
                        if shouldSell then
                            SafeInvoke(Remotes.SellChicken, chickenName)
                        end
                    end
                end
            end)
        end
        task.wait(Flags.HatchDelay)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoFuseDuplicates and Remotes.FuseChicken then
            pcall(function()
                SafeInvoke(Remotes.FuseChicken, "AutoFuseDuplicates", Flags.FuseRarityOnly)
            end)
        end
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            if Flags.AutoBuyUpgradeCoop then
                SafeInvoke(Remotes.BuyCoop, "Buy")
                SafeInvoke(Remotes.UpgradeCoop, "Upgrade")
                SafeInvoke(Remotes.BuyCoop, "Upgrade")
                TriggerPromptByName({"buycoop", "unlockcoop", "coopbuy", "upgradecoop", "coopupgrade", "cooplevel", "coop"})
            end

            if Flags.AutoBuyUpgradeFeeder then
                SafeInvoke(Remotes.BuyFeeder, "Buy")
                SafeInvoke(Remotes.UpgradeFeeder, "Upgrade")
                SafeInvoke(Remotes.BuyFeeder, "Upgrade")
                TriggerPromptByName({"buyfeeder", "unlockfeeder", "feederbuy", "upgradefeeder", "feederupgrade", "feederlevel", "upgradefood", "feeder"})
            end

            if Flags.AutoBuyUpgradeRecycler then
                SafeInvoke(Remotes.UpgradeRecycler, "Buy")
                SafeInvoke(Remotes.UpgradeRecycler, "Upgrade")
                TriggerPromptByName({"upgraderecycler", "recyclerupgrade", "buyrecycler", "recycleupgrade", "recycler"})
            end
        end)
        task.wait(Flags.FarmUpgradeDelay)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoTrain and Remotes.Train then
            SafeInvoke(Remotes.Train)
        end
        task.wait(Flags.FarmSpeed)
    end
end)

task.spawn(function()
    while true do
        if Flags.AutoPunch and Remotes.Punch then
            SafeInvoke(Remotes.Punch)
        end
        task.wait(Flags.FarmSpeed)
    end
end)

-- Rayfield: inline (self-contained, no _G dependency)

local Window = Rayfield:CreateWindow({
    Name = HUB_TITLE .. " | Grow A Chicken Fighter",
    LoadingTitle = HUB_TITLE,
    LoadingSubtitle = "by Miles Dev | Ultimate Edition",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MilesHub",
        FileName = "Config"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local FloatingGui = nil
pcall(function()
    local targetParent = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")

    if targetParent then
        FloatingGui = Instance.new("ScreenGui")
        FloatingGui.Name = "MilesHub_FloatingToggle"
        FloatingGui.ResetOnSpawn = false
        FloatingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        FloatingGui.DisplayOrder = 999999
        FloatingGui.Parent = targetParent

        local floatBtn = Instance.new("TextButton")
        floatBtn.Name = "ToggleButton"
        floatBtn.Size = UDim2.new(0, 115, 0, 38)
        floatBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
        floatBtn.BackgroundColor3 = Color3.fromRGB(20, 16, 35)
        floatBtn.Text = "⚡ Miles-HUB"
        floatBtn.TextColor3 = Color3.fromRGB(168, 85, 247)
        floatBtn.Font = Enum.Font.GothamBold
        floatBtn.TextSize = 13
        floatBtn.BorderSizePixel = 0
        floatBtn.Active = true
        floatBtn.Draggable = true
        floatBtn.Parent = FloatingGui

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = floatBtn

        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(168, 85, 247)
        btnStroke.Thickness = 1.5
        btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        btnStroke.Parent = floatBtn

        floatBtn.MouseButton1Click:Connect(function()
            pcall(function()
                for _, gui in ipairs(targetParent:GetChildren()) do
                    if gui:IsA("ScreenGui") and (string.find(gui.Name:lower(), "rayfield") or string.find(gui.Name:lower(), "sirius")) then
                        gui.Enabled = not gui.Enabled
                    end
                end
            end)
        end)
    end
end)

local HomeTab = Window:CreateTab("🏠 Home", 4483362458)

HomeTab:CreateSection("👤 Info Karakter & Sesi Grinding")

HomeTab:CreateParagraph({
    Title = "Player Profile",
    Content = "Username: " .. LocalPlayer.Name .. " (@" .. LocalPlayer.DisplayName .. ")\nAccount Age: " .. LocalPlayer.AccountAge .. " hari\nUser ID: " .. LocalPlayer.UserId
})

local SessionTrackerParagraph = HomeTab:CreateParagraph({
    Title = "⏱️ Sesi Grinding & Statistik Live",
    Content = "Memuat statistik live..."
})

task.spawn(function()
    while true do
        pcall(function()
            local elapsed = os.time() - SessionStartTime
            local hrs = math.floor(elapsed / 3600)
            local mins = math.floor((elapsed % 3600) / 60)
            local secs = elapsed % 60
            local timeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)

            local pingStr = "N/A"
            local stat = game:GetService("Stats"):FindFirstChild("PerformanceStats")
            if stat and stat:FindFirstChild("Ping") then
                pingStr = string.format("%.0f ms", stat.Ping:GetValue())
            end

            SessionTrackerParagraph:Set({
                Title = "⏱️ Sesi Grinding & Statistik Live",
                Content = "⏰ Durasi Grinding: " .. timeStr ..
                          "\n🥚 Telur Di-Hatch: " .. SessionEggsHatched ..
                          "\n♻️ Rebirth Selesai: " .. SessionRebirths ..
                          "\n📶 Network Ping: " .. pingStr
            })
        end)
        task.wait(1)
    end
end)

HomeTab:CreateSection("🏆 Top 5 Best Chickens (Ayam Terkuat)")

local topChickens = GetTop5Chickens()
for rank, chk in ipairs(topChickens) do
    HomeTab:CreateParagraph({
        Title = "#" .. rank .. " " .. chk.Name,
        Content = "Estimasi Power: " .. (chk.Power or "Top Tier") .. (chk.Tier and (" | Rarity: " .. chk.Tier) or "")
    })
end

HomeTab:CreateButton({
    Name = "⚡ Equip Best 5 Chickens (Pakai Ayam Terkuat)",
    Callback = function()
        if Remotes.EquipBest then
            SafeInvoke(Remotes.EquipBest)
        end
        SafeNotify({
            Title = HUB_TITLE,
            Content = "Berhasil memakai ayam pet terbaik!",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

local EggTab = Window:CreateTab("🥚 Egg, Sell & Fuse", 4483362458)

EggTab:CreateSection("🐣 Auto Hatch & Inventory Selector")

local currentEggOptions = GetPlayerInventoryEggs()
local EggDropdown = EggTab:CreateDropdown({
    Name = "Pilih Egg dari Inventory",
    Options = currentEggOptions,
    CurrentOption = {currentEggOptions[1] or "Basic Egg"},
    MultipleOptions = false,
    Flag = "InventoryEggDropdown",
    Callback = function(Option)
        Flags.SelectedEgg = Option[1] or Option
    end,
})

EggTab:CreateButton({
    Name = "🔄 Refresh List Egg di Inventory",
    Callback = function()
        local updatedEggs = GetPlayerInventoryEggs()
        EggDropdown:Set(updatedEggs)
        SafeNotify({
            Title = HUB_TITLE,
            Content = "List telur di inventory berhasil diperbarui! (" .. #updatedEggs .. " tipe)",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

EggTab:CreateToggle({
    Name = "Auto Hatch Telur Terpilih",
    CurrentValue = false,
    Flag = "AutoHatchEggToggle",
    Callback = function(Value)
        Flags.AutoHatch = Value
    end,
})

EggTab:CreateSlider({
    Name = "Hatch Delay (Kecepatan Buka)",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.5,
    Flag = "HatchDelaySlider",
    Callback = function(Value)
        Flags.HatchDelay = Value
    end,
})

EggTab:CreateSection("📦 Map Collector & Incubator")

EggTab:CreateToggle({
    Name = "Auto Collect Egg di Map",
    CurrentValue = false,
    Flag = "AutoCollectEggsToggle",
    Callback = function(Value)
        Flags.AutoCollectEggs = Value
    end,
})

EggTab:CreateToggle({
    Name = "Auto Claim Incubator (Semua Slot)",
    CurrentValue = false,
    Flag = "AutoClaimIncubatorToggle",
    Callback = function(Value)
        Flags.AutoClaimIncubator = Value
    end,
})

EggTab:CreateSection("💰 Auto Sell Chickens (Kategori per Egg)")

EggTab:CreateToggle({
    Name = "Aktifkan Auto Sell Saat Hatch",
    CurrentValue = false,
    Flag = "AutoSellMasterToggle",
    Callback = function(Value)
        Flags.AutoSellOnHatch = Value
    end,
})

EggTab:CreateButton({
    Name = "🔄 Scan Ulang Database Telur & Ayam Game Asli",
    Callback = function()
        local db, count = ScanLiveGameDatabase()
        SafeNotify({
            Title = HUB_TITLE,
            Content = "Berhasil memindai " .. count .. " ayam asli dari data game terkini!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

EggTab:CreateButton({
    Name = "📋 Dump Database Game ke F9 Console / Clipboard",
    Callback = function()
        local textOut = "=== [MILES-HUB / GROW A CHICKEN FIGHTER - LIVE DATABASE] ===\n"
        for egg, pets in pairs(EggDatabase) do
            textOut = textOut .. "\n[" .. egg .. "]:\n"
            for _, pet in ipairs(pets) do
                textOut = textOut .. "  - " .. pet .. "\n"
            end
        end
        print(textOut)
        if setclipboard then
            setclipboard(textOut)
        end
        SafeNotify({
            Title = HUB_TITLE,
            Content = "Daftar telur & ayam disalin ke Clipboard dan Console (F9)!",
            Duration = 3.5,
            Image = 4483362458
        })
    end,
})

EggTab:CreateButton({
    Name = "💵 Jual Semua Ayam Terpilih Sekarang",
    Callback = function()
        if Remotes.SellChicken then
            pcall(function()
                for chickenName, shouldSell in pairs(Flags.SelectedChickensToSell) do
                    if shouldSell then
                        SafeInvoke(Remotes.SellChicken, chickenName)
                    end
                end
            end)
            SafeNotify({
                Title = HUB_TITLE,
                Content = "Ayam yang dicentang berhasil dijual!",
                Duration = 2,
                Image = 4483362458
            })
        end
    end,
})

for eggCategory, chickensList in pairs(EggDatabase) do
    EggTab:CreateSection("📦 " .. eggCategory .. " Chickens")
    for _, chickenName in ipairs(chickensList) do
        EggTab:CreateToggle({
            Name = "Jual " .. chickenName,
            CurrentValue = false,
            Flag = "SellToggle_" .. chickenName:gsub("%s+", ""):gsub("%W+", ""),
            Callback = function(Value)
                Flags.SelectedChickensToSell[chickenName] = Value
            end,
        })
    end
end

EggTab:CreateSection("🧬 Pet Fuse System")

EggTab:CreateToggle({
    Name = "Kunci Fuse Rarity Sama (Safety Lock)",
    CurrentValue = true,
    Flag = "FuseRarityLock",
    Callback = function(Value)
        Flags.FuseRarityOnly = Value
    end,
})

EggTab:CreateToggle({
    Name = "Auto Fuse Duplikat Ayam (Loop)",
    CurrentValue = false,
    Flag = "AutoFuseLoopToggle",
    Callback = function(Value)
        Flags.AutoFuseDuplicates = Value
    end,
})

EggTab:CreateButton({
    Name = "⚡ Instant Fuse Semua Duplikat Sekarang",
    Callback = function()
        if Remotes.FuseChicken then
            pcall(function()
                SafeInvoke(Remotes.FuseChicken, "InstantFuse", Flags.FuseRarityOnly)
            end)
            SafeNotify({
                Title = HUB_TITLE,
                Content = "Proses Fuse ayam duplikat berhasil dikirim!",
                Duration = 2.5,
                Image = 4483362458
            })
        end
    end,
})

local FarmEventTab = Window:CreateTab("🌾 Farm & Events", 4483362458)

FarmEventTab:CreateSection("🌾 Farm Tycoon Upgrades")

FarmEventTab:CreateToggle({
    Name = "Auto Buy & Upgrade Coop (Kandang)",
    CurrentValue = false,
    Flag = "AutoBuyUpgradeCoopToggle",
    Callback = function(Value)
        Flags.AutoBuyUpgradeCoop = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "Auto Buy & Upgrade Feeder (Tempat Makan)",
    CurrentValue = false,
    Flag = "AutoBuyUpgradeFeederToggle",
    Callback = function(Value)
        Flags.AutoBuyUpgradeFeeder = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "Auto Buy & Upgrade Recycler (Mesin Daur Ulang)",
    CurrentValue = false,
    Flag = "AutoBuyUpgradeRecyclerToggle",
    Callback = function(Value)
        Flags.AutoBuyUpgradeRecycler = Value
    end,
})

FarmEventTab:CreateButton({
    Name = "🚀 Instant Upgrade Semua (Coop + Feeder + Recycler)",
    Callback = function()
        pcall(function()
            SafeInvoke(Remotes.UpgradeCoop, "Upgrade")
            SafeInvoke(Remotes.UpgradeFeeder, "Upgrade")
            SafeInvoke(Remotes.UpgradeRecycler, "Upgrade")
            TriggerPromptByName({"upgradecoop", "upgradefeeder", "upgraderecycler", "cooplevel", "feederlevel"})
        end)
        SafeNotify({
            Title = HUB_TITLE,
            Content = "Perintah upgrade untuk Coop, Feeder, dan Recycler berhasil dikirim!",
            Duration = 2.5,
            Image = 4483362458
        })
    end,
})

FarmEventTab:CreateSlider({
    Name = "Upgrade Loop Delay",
    Range = {0.2, 5},
    Increment = 0.2,
    Suffix = "s",
    CurrentValue = 1.0,
    Flag = "FarmUpgradeDelaySlider",
    Callback = function(Value)
        Flags.FarmUpgradeDelay = Value
    end,
})

FarmEventTab:CreateSection("🎪 World Events Auto Join")

FarmEventTab:CreateToggle({
    Name = "Master Auto Join Events (Semua Event)",
    CurrentValue = false,
    Flag = "AutoJoinEventsMasterToggle",
    Callback = function(Value)
        Flags.AutoJoinEvents = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "🔥 Auto Join: HOT EGGS",
    CurrentValue = true,
    Flag = "JoinHotEggsToggle",
    Callback = function(Value)
        Flags.EventsToJoin["Hot Eggs"] = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "🛸 Auto Join: UFO INVASION",
    CurrentValue = true,
    Flag = "JoinUFOToggle",
    Callback = function(Value)
        Flags.EventsToJoin["UFO Invasion"] = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "🪿 Auto Join: GOLDEN GOOSE",
    CurrentValue = true,
    Flag = "JoinGooseToggle",
    Callback = function(Value)
        Flags.EventsToJoin["Golden Goose"] = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "👑 Auto Join: CHICKEN BOSS",
    CurrentValue = true,
    Flag = "JoinBossToggle",
    Callback = function(Value)
        Flags.EventsToJoin["Chicken Boss"] = Value
    end,
})

FarmEventTab:CreateSection("🥊 Combat & Workout Training")

FarmEventTab:CreateToggle({
    Name = "Auto Train / Click Power",
    CurrentValue = false,
    Flag = "AutoTrainToggle",
    Callback = function(Value)
        Flags.AutoTrain = Value
    end,
})

FarmEventTab:CreateToggle({
    Name = "Auto Punch / Open World Fight",
    CurrentValue = false,
    Flag = "AutoPunchToggle",
    Callback = function(Value)
        Flags.AutoPunch = Value
    end,
})

FarmEventTab:CreateSlider({
    Name = "Farm Speed (Delay)",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "FarmSpeedSlider",
    Callback = function(Value)
        Flags.FarmSpeed = Value
    end,
})

local TowerRebirthTab = Window:CreateTab("🏰 Tower & Rebirth", 4483362458)

TowerRebirthTab:CreateSection("🗼 Tower Auto Grinder")

TowerRebirthTab:CreateToggle({
    Name = "Auto Tower Grind (Naik Lantai & Serang)",
    CurrentValue = false,
    Flag = "AutoTowerGrindToggle",
    Callback = function(Value)
        Flags.AutoTowerGrind = Value
    end,
})

TowerRebirthTab:CreateSlider({
    Name = "Target Max Floor (Selesai di Lantai)",
    Range = {1, 100},
    Increment = 1,
    Suffix = " Floor",
    CurrentValue = 20,
    Flag = "TargetTowerFloorSlider",
    Callback = function(Value)
        Flags.TargetTowerFloor = Value
    end,
})

TowerRebirthTab:CreateToggle({
    Name = "Feed Before Fighting (Beri Makan Sebelum Battle)",
    CurrentValue = true,
    Flag = "FeedBeforeFightToggle",
    Callback = function(Value)
        Flags.FeedBeforeFight = Value
    end,
})

TowerRebirthTab:CreateSection("♻️ Smart Rebirth Exploit (Recycler Timing Bug)")

TowerRebirthTab:CreateParagraph({
    Title = "💡 Cara Kerja Smart Rebirth Glitch",
    Content = "Ketika target floor tercapai, script akan mengambil Scrap di map lalu menjualnya ke Recycler bersamaan dengan Rebirth. Uang hasil penjualan scrap akan masuk ke karakter setelah Rebirth, memberi modal awal instan!"
})

TowerRebirthTab:CreateToggle({
    Name = "Aktifkan Smart Rebirth Glitch (Auto Rebirth di Max Floor)",
    CurrentValue = false,
    Flag = "SmartRebirthToggle",
    Callback = function(Value)
        Flags.SmartRebirthExploit = Value
    end,
})

TowerRebirthTab:CreateToggle({
    Name = "Auto Collect Scrap di Map",
    CurrentValue = false,
    Flag = "AutoCollectScrapToggle",
    Callback = function(Value)
        Flags.AutoCollectScrap = Value
    end,
})

TowerRebirthTab:CreateButton({
    Name = "⚡ Eksekusi Smart Rebirth Glitch Sekarang (Manual)",
    Callback = function()
        ExecuteSmartRebirthGlitch()
    end,
})

local SettingsTab = Window:CreateTab("⚙️ Settings & Mods", 4483362458)

SettingsTab:CreateSection("📱 Floating Button & UI Controls")

SettingsTab:CreateToggle({
    Name = "Tampilkan Floating Button (⚡ Miles-HUB)",
    CurrentValue = true,
    Flag = "ShowFloatingButtonToggle",
    Callback = function(Value)
        Flags.ShowFloatingButton = Value
        if FloatingGui then
            FloatingGui.Enabled = Value
        end
    end,
})

SettingsTab:CreateKeybind({
    Name = "Keybind Buka/Tutup UI",
    CurrentKeybind = "RightControl",
    HoldToInteract = false,
    Flag = "UIKeybind",
    Callback = function()
        pcall(function()
            local targetParent = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")
            for _, gui in ipairs(targetParent:GetChildren()) do
                if gui:IsA("ScreenGui") and (string.find(gui.Name:lower(), "rayfield") or string.find(gui.Name:lower(), "sirius")) then
                    gui.Enabled = not gui.Enabled
                end
            end
        end)
    end,
})

SettingsTab:CreateSection("⚡ FPS Booster & Anti-Lag")

SettingsTab:CreateToggle({
    Name = "FPS Booster (Smooth Textures & No Shadows)",
    CurrentValue = false,
    Flag = "FPSBoosterToggle",
    Callback = function(Value)
        Flags.FPSBooster = Value
        ApplyFPSBooster(Value)
    end,
})

SettingsTab:CreateToggle({
    Name = "Ultra Low GPU AFK Mode (Disable 3D Render)",
    CurrentValue = false,
    Flag = "LowGPUModeToggle",
    Callback = function(Value)
        Flags.LowGPUMode = Value
        SetLowGPUMode(Value)
    end,
})

SettingsTab:CreateSlider({
    Name = "Max FPS Cap",
    Range = {30, 240},
    Increment = 30,
    Suffix = " FPS",
    CurrentValue = 60,
    Flag = "FPSCapSlider",
    Callback = function(Value)
        Flags.FPSCap = Value
        if setfpscap then
            setfpscap(Value)
        end
    end,
})

SettingsTab:CreateSection("🛡️ Anti-AFK & Movement")

SettingsTab:CreateToggle({
    Name = "Multi-Layer Anti-AFK (Anti Disconnect 20 Menit)",
    CurrentValue = true,
    Flag = "AntiAFKToggle",
    Callback = function(Value)
        Flags.AntiAFK = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "Auto Rejoin Saat Disconnect / Error",
    CurrentValue = true,
    Flag = "AutoReconnectToggle",
    Callback = function(Value)
        Flags.AutoReconnect = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 2,
    Suffix = " Spd",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Flags.WalkSpeed = Value
        if Humanoid then Humanoid.WalkSpeed = Value end
    end,
})

SettingsTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    Suffix = " Pwr",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        Flags.JumpPower = Value
        if Humanoid then Humanoid.JumpPower = Value end
    end,
})

SettingsTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        Flags.InfJump = Value
    end,
})

SettingsTab:CreateToggle({
    Name = "NoClip (Tembus Dinding)",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        Flags.NoClip = Value
    end,
})

SettingsTab:CreateSection("🌐 Server Hop & Rejoin")

SettingsTab:CreateButton({
    Name = "🔄 Rejoin Server Saat Ini",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:CreateButton({
    Name = "🌐 Server Hop: Server Paling Sepi (Private Feel)",
    Callback = function()
        DoServerHop("lowest")
    end,
})

SettingsTab:CreateButton({
    Name = "🌐 Server Hop: Server Ramai (Event Hunt)",
    Callback = function()
        DoServerHop("highest")
    end,
})

SafeNotify({
    Title = HUB_TITLE .. " ✅",
    Content = "Semua Fitur dan Kontrol Berhasil Dimuat!\nReferensi: 1337hub1337/loader",
    Duration = 4,
    Image = 4483362458
})
