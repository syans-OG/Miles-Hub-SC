--[[ SC DataMiner v1 - data extraction only (run alongside MilesHub v7) ]]
--[[ No features. Just tools to read game data. Hotkey LeftShift = toggle. ]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local function Notify(t)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "SC DataMiner", Text = t, Duration = 4 })
    end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "SCDataMiner"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.Parent = CoreGui

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 420)
main.Position = UDim2.new(0.5, -150, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
main.Visible = false

local chip = Instance.new("TextButton", gui)
chip.Size = UDim2.new(0, 96, 0, 28)
chip.Position = UDim2.new(1, -106, 0, 10)
chip.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
chip.BorderSizePixel = 0
chip.ZIndex = 5
chip.Text = "SC DataMiner"
chip.TextColor3 = Color3.fromRGB(240, 240, 240)
chip.Font = Enum.Font.GothamBold
chip.TextSize = 12
Instance.new("UICorner", chip).CornerRadius = UDim.new(0, 8)
chip.Visible = true

local tb = Instance.new("Frame", main)
tb.Size = UDim2.new(1, 0, 0, 28)
tb.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
tb.BorderSizePixel = 0
Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
local tt = Instance.new("TextLabel", tb)
tt.Size = UDim2.new(1, -30, 1, 0)
tt.Position = UDim2.new(0, 8, 0, 0)
tt.BackgroundTransparency = 1
tt.Text = "SC DataMiner v1"
tt.TextColor3 = Color3.fromRGB(240, 240, 240)
tt.Font = Enum.Font.GothamBold
tt.TextSize = 13
tt.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", tb)
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    chip.Visible = true
end)
chip.MouseButton1Click:Connect(function()
    main.Visible = true
    chip.Visible = false
end)

local scr = Instance.new("ScrollingFrame", main)
scr.Size = UDim2.new(1, 0, 1, -34)
scr.Position = UDim2.new(0, 0, 0, 31)
scr.BackgroundTransparency = 1
scr.BorderSizePixel = 0
scr.ScrollBarThickness = 3
scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UIListLayout", scr).Padding = UDim.new(0, 3)
Instance.new("UIPadding", scr).PaddingLeft = UDim.new(0, 6)
Instance.new("UIPadding", scr).PaddingRight = UDim.new(0, 6)

local function Btn(parent, name, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    b.Text = "  " .. name
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
    return b
end

local outLbl = Instance.new("TextLabel", scr)
outLbl.Size = UDim2.new(1, 0, 0, 220)
outLbl.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
outLbl.Text = "Press a tool below."
outLbl.TextColor3 = Color3.fromRGB(210, 210, 210)
outLbl.Font = Enum.Font.Gotham
outLbl.TextSize = 9
outLbl.TextWrapped = true
outLbl.TextXAlignment = Enum.TextXAlignment.Left
outLbl.TextYAlignment = Enum.TextYAlignment.Top
outLbl.BorderSizePixel = 0
Instance.new("UICorner", outLbl).CornerRadius = UDim.new(0, 6)

local out = {}
local function Show(lines)
    out = lines
    outLbl.Text = table.concat(lines, "\n")
end

local function CopyOut()
    local txt = table.concat(out, "\n")
    if txt == "" then txt = "(no output)" end
    local ok = pcall(function() setclipboard(txt) end)
    if not ok then ok = pcall(function() game:GetService("Clipboard"):settext(txt) end) end
    Notify(ok and "Copied" or "Copy failed")
end

pcall(function()
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.LeftShift then
            main.Visible = not main.Visible
            chip.Visible = not main.Visible
        end
    end)
end)

-- --- TOOLS ---

local Remotes = {}
local function ScanRemotes()
    Remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then Remotes[obj.Name] = obj end
    end
    local ps = LP:FindFirstChild("PlayerScripts")
    if ps then
        for _, obj in ipairs(ps:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then Remotes[obj.Name] = obj end
        end
    end
end
ScanRemotes()

Btn(scr, "List Remotes", function()
    local names = {}
    for k in pairs(Remotes) do names[#names + 1] = k end
    table.sort(names)
    Show(#names == 0 and { "(none)" } or names)
    Notify(#names .. " remotes")
end)

local ser = function(v, d)
    d = d or 0
    if type(v) ~= "table" then return tostring(v) end
    if d > 1 then return tostring(v) end
    local t = {}
    for k, val in pairs(v) do t[#t + 1] = tostring(k) .. "=" .. ser(val, d + 1) end
    return "{" .. table.concat(t, ", ") .. "}"
end

local captureOn = false
local captured = {}
local noisePatterns = { "Analytics", "ClientKit", "Telemetry", "ReportIssue", "Stats" }
local function isNoise(path)
    for _, p in ipairs(noisePatterns) do
        if string.find(path, p, 1, true) then return true end
    end
    return false
end
pcall(function()
    if not hookmetamethod or not getnamecallmethod then return end
    local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if captureOn and not SelfFire and (method == "FireServer" or method == "InvokeServer") then
            local sPath = typeof(self) == "Instance" and tostring(self:GetFullName()) or tostring(self)
            if not isNoise(sPath) then
                local args = { ... }
                pcall(function()
                    local line = tostring(self) .. "("
                    local n = math.min(#args, 6)
                    for i = 1, n do
                        local a = args[i]
                        line = line .. (i > 1 and ", " or "") .. (typeof(a) == "Instance" and a.ClassName or ser(a, 2))
                    end
                    if #args > n then line = line .. ", ..." end
                    captured[#captured + 1] = line .. ")"
                    if #captured > 80 then table.remove(captured, 1) end
                end)
            end
        end
        return oldNamecall(self, ...)
    end)
end)

local capBtn = nil
capBtn = Btn(scr, "CAPTURE FIRES: OFF", function()
    captureOn = not captureOn
    capBtn.Text = "CAPTURE FIRES: " .. (captureOn and "ON" or "OFF")
    Notify(captureOn and "Capturing remote args" or "Capture off")
end)
Btn(scr, "Show Captured", function()
    Show(#captured == 0 and { "(no captures yet)" } or captured)
    Notify(#captured .. " captured")
end)

local function deepSer(v, d, outArr, cap, seen)
    if #outArr >= cap then return end
    d = d or 0
    local pad = string.rep("  ", d)
    if type(v) == "table" then
        if seen[v] then outArr[#outArr + 1] = pad .. "(cycle)"; return end
        seen[v] = true
        local keys = {}
        for k in pairs(v) do keys[#keys + 1] = k end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        if #keys == 0 then outArr[#outArr + 1] = pad .. "{}"; return end
        if d > 3 then outArr[#outArr + 1] = pad .. "{...}"; return end
        for _, k in ipairs(keys) do
            if #outArr >= cap then return end
            local val = v[k]
            local vt = type(val)
            local line = pad .. tostring(k) .. " = "
            if vt == "table" then
                outArr[#outArr + 1] = line .. "{"
                deepSer(val, d + 1, outArr, cap, seen)
            elseif vt == "function" then
                outArr[#outArr + 1] = line .. "fn"
            elseif vt == "userdata" then
                outArr[#outArr + 1] = line .. "ud"
            else
                outArr[#outArr + 1] = line .. tostring(val)
            end
        end
    else
        outArr[#outArr + 1] = pad .. tostring(v)
    end
end

local function DumpModuleData()
    local roots = { ReplicatedStorage }
    local lpPs = LP:FindFirstChild("PlayerScripts")
    if lpPs then roots[#roots + 1] = lpPs end
    local candidates = {}
    local kw = { egg = true, chick = true, shop = true, config = true, data = true, item = true, reward = true, animal = true, def = true, index = true }
    for _, root in ipairs(roots) do
        for _, m in ipairs(root:GetDescendants()) do
            if m:IsA("ModuleScript") then
                local n = m.Name:lower()
                for k in pairs(kw) do
                    if n:find(k, 1, true) then candidates[#candidates + 1] = m; break end
                end
            end
        end
    end
    local outArr = {}
    for i = 1, math.min(#candidates, 25) do
        if #outArr >= 400 then break end
        local m = candidates[i]
        local bc
        local ok1 = pcall(function() bc = getscriptbytecode(m) end)
        local f = nil
        if ok1 and bc and bc ~= "" then
            local ok2 = pcall(function() f = loadstring(bc) end)
            if ok2 and f then
                local rok, res = pcall(f)
                if rok and type(res) == "table" then
                    outArr[#outArr + 1] = "== " .. m:GetFullName() .. " =="
                    deepSer(res, 1, outArr, 400, {})
                elseif rok then
                    outArr[#outArr + 1] = "== " .. m:GetFullName() .. " -> " .. tostring(res)
                else
                    outArr[#outArr + 1] = "== " .. m:GetFullName() .. " (run error)"
                end
            else
                outArr[#outArr + 1] = "== " .. m:GetFullName() .. " (bad bytecode)"
            end
        else
            local rok, res = pcall(require, m)
            if rok and type(res) == "table" then
                outArr[#outArr + 1] = "== " .. m:GetFullName() .. " =="
                deepSer(res, 1, outArr, 400, {})
            else
                outArr[#outArr + 1] = "== " .. m:GetFullName() .. " (no access)"
            end
        end
    end
    if #outArr == 0 then outArr[1] = "(no candidate modules found)" end
    Show(outArr)
    Notify("Module candidates: " .. tostring(#candidates))
end
Btn(scr, "Dump Module Data", DumpModuleData)

local function FindHatchLogic()
    local roots = { ReplicatedStorage }
    local lpPs = LP:FindFirstChild("PlayerScripts")
    if lpPs then roots[#roots + 1] = lpPs end
    local names = { "hatch", "incub", "egg", "flock", "cluck", "farm", "fuse" }
    local outArr = {}
    local limit = 140
    for _, root in ipairs(roots) do
        for _, m in ipairs(root:GetDescendants()) do
            if #outArr >= limit then break end
            if m:IsA("ModuleScript") then
                local n = m.Name:lower()
                local matchName = false
                for _, k in ipairs(names) do if n:find(k, 1, true) then matchName = true break end end
                if matchName then
                    local src = nil
                    local ok = pcall(function() src = decompile(m) end)
                    if ok and src and #src > 0 then
                        local marked = false
                        local count = 0
                        for line in (src .. "\n"):gmatch("(.-)\n") do
                            if #outArr < limit then
                                local low = line:lower()
                                if low:find("hatch") or low:find("incub") or low:find("fireserver") or low:find("invoke") then
                                    if not marked then
                                        outArr[#outArr + 1] = "== " .. m:GetFullName() .. " =="
                                        marked = true
                                    end
                                    local t = line:gsub("^%s+", ""):gsub("%s+", " ")
                                    outArr[#outArr + 1] = "  " .. t:sub(1, 150)
                                    count = count + 1
                                    if count >= 40 then break end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if #outArr == 0 then outArr[1] = "(no hatch logic found; maybe decompile unsupported)" end
    Show(outArr)
    Notify("Hatch-logic lines: " .. tostring(#outArr))
end
Btn(scr, "Find Hatch Logic", FindHatchLogic)

local hookedEvents = {}
local eventsLog = {}
local function HookDataEvents()
    local roots = { ReplicatedStorage }
    local ps = LP:FindFirstChild("PlayerScripts")
    if ps then roots[#roots + 1] = ps end
    local kw = { "data", "flock", "replica", "sync", "update", "roster", "own", "index", "invent", "bag", "chicken" }
    local n = 0
    for _, root in ipairs(roots) do
        for _, r in ipairs(root:GetDescendants()) do
            if r:IsA("RemoteEvent") and not hookedEvents[r] then
                local full = r:GetFullName():lower()
                local nm = r.Name:lower()
                local hit = full:find("dataservice") or nm:find("dataservice")
                if not hit and nm ~= "remotevent" and nm ~= "remoteevent" then
                    for _, k in ipairs(kw) do
                        if nm:find(k, 1, true) then hit = true break end
                    end
                end
                if hit then
                    hookedEvents[r] = true
                    n = n + 1
                    pcall(function()
                        r.OnClientEvent:Connect(function(...)
                            local args = { ... }
                            local outArr = {}
                            for i, a in ipairs(args) do
                                outArr[#outArr + 1] = "#" .. i
                                deepSer(a, 1, outArr, 60, {})
                            end
                            local keys = ""
                            if type(args[2]) == "table" then
                                local ks = {}
                                for _, kv in ipairs(args[2]) do ks[#ks + 1] = tostring(kv) end
                                keys = "[" .. table.concat(ks, ",") .. "] "
                            end
                            eventsLog[#eventsLog + 1] = r.Name .. keys .. " <- " .. table.concat(outArr, " ")
                            if #eventsLog > 60 then table.remove(eventsLog, 1) end
                        end)
                    end)
                end
            end
        end
    end
    Notify("Hooked " .. tostring(n) .. " data events (do a sync action now)")
end
Btn(scr, "Hook Data Events", HookDataEvents)
Btn(scr, "Show Data Events", function()
    Show(#eventsLog == 0 and { "(none yet)" } or eventsLog)
end)

local function scanOneLevel(root, max)
    local dataLines = {}
    local n = 0
    for _, c in ipairs(root:GetChildren()) do
        if n >= max then break end
        n = n + 1
        dataLines[#dataLines + 1] = c.Name .. " [" .. c.ClassName .. "]"
    end
    return dataLines
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

local function ScanTree()
    local outArr = {}
    local function add(l) outArr[#outArr + 1] = l end
    add("== ReplicatedStorage top ==")
    for _, l in ipairs(scanOneLevel(ReplicatedStorage, 50)) do add(l) end
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    if assets then
        add("== Assets.Eggs ==")
        local eggs = assets:FindFirstChild("Eggs")
        if eggs then for _, l in ipairs(scanOneLevel(eggs, 40)) do add(l) end end
        add("== Assets.Chickens ==")
        local ch = assets:FindFirstChild("Chickens")
        if ch then for _, l in ipairs(scanOneLevel(ch, 60)) do add(l) end end
    end
    add("== Content (top) ==")
    local content = ReplicatedStorage:FindFirstChild("Content")
    if content then for _, l in ipairs(scanOneLevel(content, 40)) do add(l) end end
    add("== workspace top ==")
    for _, l in ipairs(scanOneLevel(game.Workspace, 60)) do add(l) end
    add("== My plot ==")
    local plot = game.Workspace:FindFirstChild(LP.Name)
    if plot then for _, l in ipairs(scanOneLevel(plot, 40)) do add(l) end else add("(none)") end
    add("== Rebirth window ==")
    local req, count = readRebirthText()
    add("reqText: " .. (req == "" and "(empty, open Rebirth UI first)" or req))
    add("count: " .. count)
    Show(outArr)
end
Btn(scr, "Scan Tree + Rebirth", ScanTree)

local function DumpVisible()
    local outArr = {}
    local function walk(o, depth)
        if #outArr >= 300 then return end
        for _, c in ipairs(o:GetChildren()) do
            if #outArr >= 300 then return end
            if c:IsA("ScreenGui") then
                if c.Enabled and c.Name ~= "SCDataMiner" and c.Name ~= "MilesHub" then walk(c, depth + 1) end
            elseif c:IsA("GuiObject") then
                if c.Visible then
                    if (c:IsA("TextLabel") or c:IsA("TextButton")) and c.Text ~= "" then
                        outArr[#outArr + 1] = string.rep(" ", math.min(depth, 3)) .. c.Name .. ": " .. c.Text
                    end
                    walk(c, depth + 1)
                end
            else
                walk(c, depth + 1)
            end
        end
    end
    walk(LP.PlayerGui, 0)
    Show(#outArr == 0 and { "(no visible text found)" } or outArr)
    Notify("Dumped " .. tostring(#outArr) .. " visible texts")
end
Btn(scr, "Dump Visible GUI", DumpVisible)

local function OpenRailAndDump(railName)
    local rail = LP.PlayerGui:FindFirstChild("ArenaSideRail")
    local btn = rail and deepFind(rail, railName)
    if not clickBtn(btn) then Notify("Rail button not found: " .. railName); return end
    Notify(railName .. " opened, dumping in 2s...")
    task.delay(2, DumpVisible)
end
Btn(scr, "Open Shop > Dump", function() OpenRailAndDump("Shop") end)
Btn(scr, "Open Flock > Dump", function() OpenRailAndDump("Flock") end)

Btn(scr, "Copy Output", CopyOut)

-- Miners GUI watchdog
task.spawn(function()
    while task.wait(4) do
        pcall(function()
            if gui and gui.Parent ~= CoreGui then gui.Parent = CoreGui end
        end)
    end
end)

Notify("DataMiner ready")