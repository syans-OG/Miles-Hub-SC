--[[ ⚡ Miles-HUB v2.2 — Self-Contained Loader ]]
-- Includes Rayfield UI inline + fetches game script from GitHub

-- ============ SCRIPT URL ============
local SCRIPT_URL = "https://raw.githubusercontent.com/syans-OG/Miles-Hub-SC/main/GrowAChickenFighter_original.lua"
-- ====================================

-- Anti-detection hooks
pcall(function()
    if hookmetamethod then
        local orig
        orig = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if tostring(method):lower() == "kick" and self == game:GetService("Players").LocalPlayer then
                return nil
            end
            return orig(self, ...)
        end)
    end
end)

-- ══════════════════════════════════════
-- 🎨 Inline MiniRayfield UI Library
-- ══════════════════════════════════════
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

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

local function safeNotify(opts)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = opts.Title or "Miles-HUB",
            Text = opts.Content or opts.Text or "",
            Duration = opts.Duration or 3
        })
    end)
end

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
    w.Gui.Parent = game:GetService("CoreGui")

    w.Main = Instance.new("Frame")
    w.Main.Size = UDim2.new(0, 520, 0, 380)
    w.Main.Position = UDim2.new(0.5,-260, 0.5,-190)
    w.Main.BackgroundColor3 = COLORS.Background
    w.Main.BorderSizePixel = 0
    w.Main.Active = true
    w.Main.Draggable = true
    w.Main.Parent = w.Gui
    addCorner(w.Main, 10)
    addStroke(w.Main, COLORS.Border, 1.5)

    local tb = Instance.new("Frame"); tb.Size=UDim2.new(1,0,0,36); tb.BackgroundColor3=COLORS.Accent; tb.BorderSizePixel=0; tb.Parent=w.Main; addCorner(tb,10)
    local tl = Instance.new("TextLabel"); tl.Size=UDim2.new(1,-20,1,0); tl.Position=UDim2.new(0,10,0,0); tl.BackgroundTransparency=1; tl.Text=w.Name; tl.TextColor3=COLORS.Text; tl.Font=Enum.Font.GothamBold; tl.TextSize=14; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=tb
    local cb = Instance.new("TextButton"); cb.Size=UDim2.new(0,28,0,28); cb.Position=UDim2.new(1,-32,0,4); cb.BackgroundColor3=Color3.fromRGB(200,60,60); cb.Text="X"; cb.TextColor3=COLORS.Text; cb.Font=Enum.Font.GothamBold; cb.TextSize=12; cb.Parent=tb; addCorner(cb,6)
    cb.MouseButton1Click:Connect(function() w.Gui.Enabled=not w.Gui.Enabled end)

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

    function Rayfield:Notify(o) safeNotify(o) end
    return w
end

function Rayfield:Notify(o) safeNotify(o) end

-- ═══ Inject Rayfield into global scope ═══
_G._MilesRayfield = Rayfield

-- ═══ Fetch & execute game script ═══
print("[Miles-HUB] Fetching game script...")
local ok, src = pcall(game.HttpGet, game, SCRIPT_URL)

if not ok or not src then
    warn("[Miles-HUB] Fetch failed:", src)
    return
end

print("[Miles-HUB] Compiling (" .. #src .. " bytes)...")
local chunk, err = loadstring(src)
if not chunk then
    warn("[Miles-HUB] Compile failed:", err)
    return
end

print("[Miles-HUB] Executing...")
local result = table.pack(xpcall(chunk, function(e)
    local t = tostring(e)
    if debug and debug.traceback then return debug.traceback(t, 2) end
    return t
end))

if not result[1] then
    warn("[Miles-HUB] Runtime error:", result[2])
else
    print("[Miles-HUB] Loaded successfully!")
end

return table.unpack(result, 2, result.n)
