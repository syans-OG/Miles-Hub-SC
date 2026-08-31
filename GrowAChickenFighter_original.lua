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

local SessionStartTime = os.time()
local SessionEggsHatched = 0
local SessionRebirths = 0

-- ══════════════════════════════════════════════
-- 🏷️ Miles-HUB v2.2 — Grow A Chicken Fighter
-- ══════════════════════════════════════════════
local HUB_VERSION = "2.2"
local HUB_TITLE = "⚡ Miles-HUB v" .. HUB_VERSION

local Rayfield = nil
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
end)

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
    AutoReconnect = true,
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
    local jitter = math.random(1, 15) / 1000
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
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parentName = (prompt.Parent and prompt.Parent.Name or ""):lower()
            local grandParentName = (prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""):lower()
            for _, keyword in ipairs(targetKeywords) do
                if string.find(parentName, keyword:lower()) or string.find(grandParentName, keyword:lower()) then
                    pcall(function()
                        fireproximityprompt(prompt)
                    end)
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
                        firetouchinterest(HumanoidRootPart, part, 0)
                        task.wait(0.02)
                        firetouchinterest(HumanoidRootPart, part, 1)
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
                            for _, connection in ipairs(getconnections(gui.MouseButton1Click)) do
                                connection:Fire()
                            end
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
                    firetouchinterest(HumanoidRootPart, part, 0)
                    task.wait(0.05)
                    firetouchinterest(HumanoidRootPart, part, 1)
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
                                firetouchinterest(HumanoidRootPart, part, 0)
                                task.wait(0.05)
                                firetouchinterest(HumanoidRootPart, part, 1)
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

pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not Rayfield then
    warn("[Miles-HUB] Gagal memuat Rayfield UI! Beberapa fitur mungkin tidak tersedia.")
    -- Create a mock Rayfield so the script doesn't crash
    Rayfield = {
        CreateWindow = function(self, opts)
            warn("[Miles-HUB] UI fallback mode — fitur UI dinonaktifkan.")
            return {
                CreateTab = function() return {
                    CreateSection = function() end,
                    CreateParagraph = function() end,
                    CreateButton = function() end,
                    CreateToggle = function() end,
                    CreateSlider = function() end,
                    CreateDropdown = function() end,
                    CreateKeybind = function() end,
                } end
            }
        end,
        Notify = function(self, opts)
            warn("[Miles-HUB] " .. (opts.Content or ""))
        end,
    }
end

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
