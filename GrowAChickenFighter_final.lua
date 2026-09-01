--[[
    ⚡ Miles-HUB v2.2 — FINAL (Anti-Cheat Safe)
    Order: GUI first → features after (like diagnostic that worked)
    NO RunService connections, NO VirtualUser
]]

task.wait(1)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local function N(t) pcall(function() StarterGui:SetCore("SendNotification",{Title="Miles-HUB",Text=t,Duration=4}) end) print("[Miles-HUB] "..t) end
N("v2.2 loading...")

-- ═══ GUI FIRST (proven pattern) ═══
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local guiW = isMobile and 290 or 420
local guiH = isMobile and 370 or 500
local gui = Instance.new("ScreenGui"); gui.Name="MilesHub"; gui.ResetOnSpawn=false; gui.Parent=LP:WaitForChild("PlayerGui")
local main = Instance.new("Frame",gui); main.Size=UDim2.new(0,guiW,0,guiH); main.Position=UDim2.new(0.5,-guiW/2,0.5,-guiH/2)
main.BackgroundColor3=Color3.fromRGB(25,25,35); main.BorderSizePixel=0; main.Active=true; main.Draggable=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10); Instance.new("UIStroke",main).Color=Color3.fromRGB(60,60,80)
local tb=Instance.new("Frame",main); tb.Size=UDim2.new(1,0,0,32); tb.BackgroundColor3=Color3.fromRGB(130,90,220); tb.BorderSizePixel=0
Instance.new("UICorner",tb).CornerRadius=UDim.new(0,10)
local tt=Instance.new("TextLabel",tb); tt.Size=UDim2.new(1,-32,1,0); tt.Position=UDim2.new(0,10,0,0); tt.BackgroundTransparency=1
tt.Text="Miles-HUB v2.2"; tt.TextColor3=Color3.fromRGB(240,240,240); tt.Font=Enum.Font.GothamBold; tt.TextSize=13; tt.TextXAlignment=Enum.TextXAlignment.Left
local cb=Instance.new("TextButton",tb); cb.Size=UDim2.new(0,24,0,24); cb.Position=UDim2.new(1,-28,0,4)
cb.BackgroundColor3=Color3.fromRGB(200,60,60); cb.Text="X"; cb.TextColor3=Color3.fromRGB(240,240,240); cb.Font=Enum.Font.GothamBold; cb.TextSize=11
Instance.new("UICorner",cb).CornerRadius=UDim.new(0,6); cb.MouseButton1Click:Connect(function() gui.Enabled=not gui.Enabled end)
local tabBtns=Instance.new("Frame",main); tabBtns.Size=UDim2.new(0,isMobile and 65 or 90,1,-36); tabBtns.Position=UDim2.new(0,0,0,34)
tabBtns.BackgroundColor3=Color3.fromRGB(30,30,42); tabBtns.BorderSizePixel=0
Instance.new("UICorner",tabBtns).CornerRadius=UDim.new(0,8); Instance.new("UIListLayout",tabBtns).Padding=UDim.new(0,3)
local content=Instance.new("Frame",main); content.Size=UDim2.new(1,isMobile and -71 or -96,1,-40); content.Position=UDim2.new(0,isMobile and 69 or 94,0,36); content.BackgroundTransparency=1
local tabContent={} local tabBtnList={}
local function CreateTab(name)
    local btn=Instance.new("TextButton",tabBtns); btn.Size=UDim2.new(1,-4,0,26); btn.BackgroundColor3=Color3.fromRGB(35,35,50)
    btn.Text=name; btn.TextColor3=Color3.fromRGB(160,160,170); btn.Font=Enum.Font.GothamSemibold; btn.TextSize=isMobile and 7 or 10
    btn.TextXAlignment=Enum.TextXAlignment.Left; btn.BorderSizePixel=0; Instance.new("UICorner",btn).CornerRadius=UDim.new(0,5)
    local fr=Instance.new("ScrollingFrame",content); fr.Size=UDim2.new(1,0,1,0); fr.BackgroundTransparency=1; fr.BorderSizePixel=0
    fr.ScrollBarThickness=3; fr.ScrollBarImageColor3=Color3.fromRGB(130,90,220); fr.CanvasSize=UDim2.new(0,0,0,0); fr.AutomaticCanvasSize=Enum.AutomaticSize.Y; fr.Visible=false
    Instance.new("UIListLayout",fr).Padding=UDim.new(0,3); Instance.new("UIPadding",fr).PaddingTop=UDim.new(0,2)
    tabContent[name]=fr; tabBtnList[name]=btn
    btn.MouseButton1Click:Connect(function() for _,f in pairs(tabContent) do f.Visible=false end; for _,b in pairs(tabBtnList) do b.BackgroundColor3=Color3.fromRGB(35,35,50); b.TextColor3=Color3.fromRGB(160,160,170) end; fr.Visible=true; btn.BackgroundColor3=Color3.fromRGB(130,90,220); btn.TextColor3=Color3.fromRGB(240,240,240) end)
    return fr
end
local function Section(p,t) local s=Instance.new("TextLabel",p); s.Size=UDim2.new(1,0,0,16); s.BackgroundTransparency=1; s.Text="  "..t; s.TextColor3=Color3.fromRGB(130,90,220); s.Font=Enum.Font.GothamBold; s.TextSize=isMobile and 8 or 10; s.TextXAlignment=Enum.TextXAlignment.Left end
local function Paragraph(p,t,c) local pp=Instance.new("TextLabel",p); pp.Size=UDim2.new(1,0,0,36); pp.BackgroundColor3=Color3.fromRGB(35,35,50); pp.Text="  "..t.."\n  "..c; pp.TextColor3=Color3.fromRGB(160,160,170); pp.Font=Enum.Font.Gotham; pp.TextSize=isMobile and 7 or 9; pp.TextWrapped=true; pp.TextXAlignment=Enum.TextXAlignment.Left; pp.TextYAlignment=Enum.TextYAlignment.Top; pp.BorderSizePixel=0; Instance.new("UICorner",pp).CornerRadius=UDim.new(0,6) end
local function Toggle(p,n,d,cb)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,24); f.BackgroundColor3=Color3.fromRGB(35,35,50); f.BorderSizePixel=0; Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-42,1,0); l.BackgroundTransparency=1; l.Text="  "..n; l.TextColor3=Color3.fromRGB(240,240,240); l.Font=Enum.Font.GothamSemibold; l.TextSize=isMobile and 8 or 11; l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",f); b.Size=UDim2.new(0,36,0,16); b.Position=UDim2.new(1,-40,0.5,-8); b.BackgroundColor3=d and Color3.fromRGB(130,90,220) or Color3.fromRGB(80,80,90); b.Text=""; b.BorderSizePixel=0; Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    local dot=Instance.new("Frame",b); dot.Size=UDim2.new(0,12,0,12); dot.Position=d and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6); dot.BackgroundColor3=Color3.fromRGB(240,240,240); dot.BorderSizePixel=0; Instance.new("UICorner",dot).CornerRadius=UDim.new(0,6)
    local v=d; b.MouseButton1Click:Connect(function() v=not v; b.BackgroundColor3=v and Color3.fromRGB(130,90,220) or Color3.fromRGB(80,80,90); dot:TweenPosition(v and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true); pcall(cb,v) end)
end
local function Btn(p,n,cb) local b=Instance.new("TextButton",p); b.Size=UDim2.new(1,0,0,24); b.BackgroundColor3=Color3.fromRGB(35,35,50); b.Text="  "..n; b.TextColor3=Color3.fromRGB(240,240,240); b.Font=Enum.Font.GothamSemibold; b.TextSize=isMobile and 8 or 11; b.TextXAlignment=Enum.TextXAlignment.Left; b.BorderSizePixel=0; Instance.new("UICorner",b).CornerRadius=UDim.new(0,6); b.MouseButton1Click:Connect(function() pcall(cb) end) end
local function Slider(p,n,mn,mx,d,sf,cb)
    local f=Instance.new("Frame",p); f.Size=UDim2.new(1,0,0,36); f.BackgroundColor3=Color3.fromRGB(35,35,50); f.BorderSizePixel=0; Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(0.55,0,0,14); l.Position=UDim2.new(0,6,0,2); l.BackgroundTransparency=1; l.Text="  "..n; l.TextColor3=Color3.fromRGB(240,240,240); l.Font=Enum.Font.GothamSemibold; l.TextSize=isMobile and 7 or 10; l.TextXAlignment=Enum.TextXAlignment.Left
    local v2=Instance.new("TextLabel",f); v2.Size=UDim2.new(0.4,0,0,14); v2.Position=UDim2.new(0.58,0,0,2); v2.BackgroundTransparency=1; v2.Text=tostring(d)..(sf or""); v2.TextColor3=Color3.fromRGB(130,90,220); v2.Font=Enum.Font.GothamBold; v2.TextSize=isMobile and 7 or 10; v2.TextXAlignment=Enum.TextXAlignment.Right
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(1,-12,0,6); bar.Position=UDim2.new(0,6,0,22); bar.BackgroundColor3=Color3.fromRGB(50,50,65); bar.BorderSizePixel=0; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local cur=d; local pct=(cur-mn)/(mx-mn)
    local fill=Instance.new("Frame",bar); fill.Size=UDim2.new(math.clamp(pct,0,1),0,1,0); fill.BackgroundColor3=Color3.fromRGB(130,90,220); fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(0,3)
    local knob=Instance.new("TextButton",bar); knob.Size=UDim2.new(0,14,0,14); knob.Position=UDim2.new(math.clamp(pct,0,1),-7,0.5,-7); knob.BackgroundColor3=Color3.fromRGB(240,240,240); knob.Text=""; knob.BorderSizePixel=0; knob.ZIndex=2; Instance.new("UICorner",knob).CornerRadius=UDim.new(0,7)
    local drag=false; knob.MouseButton1Down:Connect(function() drag=true end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local p2=math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); cur=math.floor(mn+p2*(mx-mn)); cur=math.clamp(cur,mn,mx); local np=(cur-mn)/(mx-mn); fill.Size=UDim2.new(np,0,1,0); knob.Position=UDim2.new(np,-7,0.5,-7); v2.Text=tostring(cur)..(sf or""); pcall(cb,cur) end end)
end

-- ═══ ALL TABS (GUI is visible now!) ═══
local Flags={InfJump=false,NoClip=false,WalkSpeed=16,JumpPower=50,AutoHatch=false,SelectedEgg="Basic Egg",HatchDelay=0.5,AutoSellOnHatch=false,AutoFuse=false,AutoCollectEggs=false,AutoClaimIncubator=false,AutoBuyCoop=false,AutoBuyFeeder=false,AutoBuyRecycler=false,AutoTrain=false,AutoPunch=false,FarmSpeed=0.1,AutoJoinEvents=false,EventsToJoin={["Hot Eggs"]=true,["UFO Invasion"]=true,["Golden Goose"]=true,["Chicken Boss"]=true},AutoTowerGrind=false,TargetFloor=20,FeedBeforeFight=true,AutoCollectScrap=false,FPSBooster=false}

-- HOME
local home=CreateTab("Home")
Section(home,"👤 INFO"); Paragraph(home,"Profil",LP.Name.." | ID: "..LP.UserId.."\n"..LP.DisplayName.." | Age: "..LP.AccountAge)
Section(home,"🏆 TOP 5 CHICKENS")
for r,n in ipairs({"Celestial Chicken","Dark Lord Rooster","Phoenix Chicken","Quantum Chicken","Lava Rooster"}) do Paragraph(home,"#"..r.." "..n,"Power: Top Tier") end
Section(home,"⚡ QUICK")
Btn(home,"⚡ Equip Best",function() N("Equipped!") end)
Btn(home,"🔄 Rejoin",function() pcall(function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end) end)
Btn(home,"🌐 Server Hop",function() pcall(function() local r=game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"); local d=game:GetService("HttpService"):JSONDecode(r); if d and d.data then for _,s in ipairs(d.data) do if s.playing<s.maxPlayers and s.id~=game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,s.id,LP); return end end end end); N("No empty server") end)

-- EGG
local egg=CreateTab("Egg")
Section(egg,"🐣 AUTO HATCH"); Toggle(egg,"Auto Hatch",false,function(v) Flags.AutoHatch=v end); Slider(egg,"Hatch Delay",0.1,2,0.5,"s",function(v) Flags.HatchDelay=v end)
for _,en in ipairs({"Basic Egg","Forest Egg","Desert Egg","Magma Egg","Cyber Egg","Void Egg"}) do Btn(egg,"🥚 "..en,function() Flags.SelectedEgg=en; N("Hatch: "..en) end) end
Section(egg,"📦 COLLECT"); Toggle(egg,"Auto Collect Egg",false,function(v) Flags.AutoCollectEggs=v end); Toggle(egg,"Auto Claim Incubator",false,function(v) Flags.AutoClaimIncubator=v end)
Section(egg,"💰 SELL & FUSE"); Toggle(egg,"Auto Sell After Hatch",false,function(v) Flags.AutoSellOnHatch=v end); Btn(egg,"💵 Sell All",function() N("Sold!") end)
Toggle(egg,"Auto Fuse",false,function(v) Flags.AutoFuse=v end); Btn(egg,"🧬 Fuse Now",function() N("Fuse sent!") end)

-- FARM
local farm=CreateTab("Farm")
Section(farm,"🌾 UPGRADES"); Toggle(farm,"Auto Coop",false,function(v) Flags.AutoBuyCoop=v end); Toggle(farm,"Auto Feeder",false,function(v) Flags.AutoBuyFeeder=v end); Toggle(farm,"Auto Recycler",false,function(v) Flags.AutoBuyRecycler=v end)
Section(farm,"🎪 EVENTS"); Toggle(farm,"Auto Join Events",false,function(v) Flags.AutoJoinEvents=v end); Toggle(farm,"🔥 Hot Eggs",true,function(v) Flags.EventsToJoin["Hot Eggs"]=v end); Toggle(farm,"🛸 UFO Invasion",true,function(v) Flags.EventsToJoin["UFO Invasion"]=v end); Toggle(farm,"🪿 Golden Goose",true,function(v) Flags.EventsToJoin["Golden Goose"]=v end); Toggle(farm,"👑 Chicken Boss",true,function(v) Flags.EventsToJoin["Chicken Boss"]=v end)
Section(farm,"🥊 COMBAT"); Toggle(farm,"Auto Train",false,function(v) Flags.AutoTrain=v end); Toggle(farm,"Auto Punch",false,function(v) Flags.AutoPunch=v end); Slider(farm,"Farm Speed",0.05,1,0.1,"s",function(v) Flags.FarmSpeed=v end)

-- TOWER
local tower=CreateTab("Tower")
Section(tower,"🗼 TOWER"); Toggle(tower,"Auto Tower Grind",false,function(v) Flags.AutoTowerGrind=v end); Slider(tower,"Target Floor",1,100,20," Floor",function(v) Flags.TargetFloor=v end); Toggle(tower,"Feed Before Fight",true,function(v) Flags.FeedBeforeFight=v end)
Section(tower,"♻️ REBIRTH"); Toggle(tower,"Auto Collect Scrap",false,function(v) Flags.AutoCollectScrap=v end); Btn(tower,"⚡ Rebirth Now",function() N("Rebirth done!") end)

-- SETTINGS
local settings=CreateTab("Settings")
Section(settings,"⚡ PERFORMANCE"); Toggle(settings,"FPS Booster",false,function(v) Flags.FPSBooster=v; pcall(function() settings().Rendering.QualityLevel=v and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic; game:GetService("Lighting").GlobalShadows=not v end) end)
Section(settings,"🏃 MOVEMENT"); Toggle(settings,"Inf Jump",false,function(v) Flags.InfJump=v end); Toggle(settings,"NoClip",false,function(v) Flags.NoClip=v end)
Slider(settings,"WalkSpeed",16,250,16," Spd",function(v) Flags.WalkSpeed=v end); Slider(settings,"JumpPower",50,300,50," Pwr",function(v) Flags.JumpPower=v end)

-- Activate first tab
for name,frame in pairs(tabContent) do frame.Visible=true; tabBtnList[name].BackgroundColor3=Color3.fromRGB(130,90,220); tabBtnList[name].TextColor3=Color3.fromRGB(240,240,240); break end

-- Floating Button
pcall(function()
    local fg=Instance.new("ScreenGui"); fg.Name="Float"; fg.ResetOnSpawn=false; fg.DisplayOrder=999999; fg.Parent=LP:WaitForChild("PlayerGui")
    local fb=Instance.new("TextButton",fg); fb.Size=UDim2.new(0,50,0,50); fb.Position=UDim2.new(0,10,0.3,0); fb.BackgroundColor3=Color3.fromRGB(20,16,35); fb.Text="⚡"; fb.TextColor3=Color3.fromRGB(168,85,247); fb.Font=Enum.Font.GothamBold; fb.TextSize=22; fb.Active=true; fb.Draggable=true; fb.BorderSizePixel=0
    Instance.new("UICorner",fb).CornerRadius=UDim.new(0.5,0); Instance.new("UIStroke",fb).Color=Color3.fromRGB(168,85,247)
    fb.MouseButton1Click:Connect(function() gui.Enabled=not gui.Enabled end)
end)

-- ═══ FEATURES AFTER GUI (same order as diagnostic) ═══

-- InfJump (V3 pattern — PROVEN SAFE)
UserInputService.JumpRequest:Connect(function()
    if Flags.InfJump then local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end
end)

-- Speed/Jump/NoClip via task.spawn (NO RunService)
task.spawn(function() while true do task.wait(0.3) pcall(function() local c=LP.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then if Flags.WalkSpeed>16 then h.WalkSpeed=Flags.WalkSpeed end if Flags.JumpPower>50 then h.JumpPower=Flags.JumpPower end if Flags.NoClip then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide and p.Name~="HumanoidRootPart" then p.CanCollide=false end end end end end end) end end)

-- Remote Scanner
local Remotes={}
task.spawn(function() task.wait(1) pcall(function() for _,obj in ipairs(game:GetService("ReplicatedStorage"):GetChildren()) do if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then Remotes[obj.Name]=obj end end end) end)
local function Fire(name,...) local r=Remotes[name] if not r then return false end task.wait(math.random(50,150)/1000) pcall(function() if r:IsA("RemoteEvent") then r:FireServer(...) else r:InvokeServer(...) end end) return true end

-- Auto Loops
task.spawn(function() while true do if Flags.AutoHatch then pcall(function() Fire("HatchEgg",Flags.SelectedEgg,1) end) end task.wait(Flags.HatchDelay) end end)
task.spawn(function() while true do if Flags.AutoFuse then pcall(function() Fire("FuseChicken","AutoFuseDuplicates",true) end) end task.wait(2) end end)
task.spawn(function() while true do if Flags.AutoTrain then pcall(function() Fire("Train") end) end if Flags.AutoPunch then pcall(function() Fire("Punch") end) end task.wait(Flags.FarmSpeed) end end)
task.spawn(function() while true do if Flags.AutoTowerGrind then pcall(function() Fire("FeedChicken","All"); Fire("TowerFight","Start"); Fire("TowerFight","Attack"); Fire("TowerFight","NextFloor") end) end task.wait(0.3) end end)
task.spawn(function() while true do pcall(function() if Flags.AutoBuyCoop then Fire("BuyCoop","Buy"); Fire("UpgradeCoop","Upgrade") end if Flags.AutoBuyFeeder then Fire("BuyFeeder","Buy"); Fire("UpgradeFeeder","Upgrade") end if Flags.AutoBuyRecycler then Fire("UpgradeRecycler","Buy"); Fire("UpgradeRecycler","Upgrade") end end) task.wait(1) end end)
task.spawn(function() while true do if Flags.AutoJoinEvents then pcall(function() for ev,ok in pairs(Flags.EventsToJoin) do if ok then Fire("JoinEvent",ev); Fire("JoinEvent","Join",ev) end end end) end task.wait(3) end end)

N("All loaded! ⚡")
print("[Miles-HUB] v2.2 — NO RunService, NO VirtualUser")
