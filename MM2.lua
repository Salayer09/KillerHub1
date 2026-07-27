--==============================================================================
-- KILLER HUB UI - EXTRAS MODULE (WITH KNIFE, TRAPS ESP & PERF OVERLAY)
--==============================================================================

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KILLERHUB3/refs/heads/main/Murder.lua"))()

if getgenv().__KillerHub_Extras_Loaded then
    KillerHub:NotifyWarn("Already Loaded", "The script is already running.", 3)
    return
end
getgenv().__KillerHub_Extras_Loaded = true

-- Services & Optimization Cache
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- Fast Localizations
local os_clock = os.clock
local math_round = math.round
local string_format = string.format

-- Helper Functions
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)
    return string_format("%02d:%02d", math.max(0, mins), math.max(0, secs))
end

-- Tab Creation
local TabExtras = KillerHub:CreateTab("Extras", "Code")

--------------------------------------------------------------------------------
-- 0. SYSTEM PERFORMANCE OVERLAY (COMPACT & ULTRA LIGHT)
--------------------------------------------------------------------------------
local statsConnection = nil
local statsGui = nil
local statsFrame = nil
local statsBgTransparency = 0.25

local function CleanUpPerfOverlay()
    if statsConnection then 
        statsConnection:Disconnect() 
        statsConnection = nil 
    end
    if statsGui then
        statsGui:Destroy()
        statsGui = nil
        statsFrame = nil
    end
end

--------------------------------------------------------------------------------
-- 1. SHOW ROUND TIME LOGIC
--------------------------------------------------------------------------------
local RoundTimerGui = nil
local RoundTimerConnection = nil

local function CreateTimerUI()
    if RoundTimerGui then RoundTimerGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KillerHub_RoundTimer"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Name = "TimeText"
    TimeLabel.Size = UDim2.new(0, 200, 0, 30)
    TimeLabel.Position = UDim2.new(0.5, -100, 0, 0)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Font = Enum.Font.SciFi
    TimeLabel.TextSize = 30
    TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeLabel.TextStrokeTransparency = 0.4
    TimeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TimeLabel.Text = ""
    TimeLabel.Visible = false
    TimeLabel.Parent = ScreenGui

    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end

    RoundTimerGui = ScreenGui
    return TimeLabel
end

local function RemoveTimerUI()
    if RoundTimerGui then
        RoundTimerGui:Destroy()
        RoundTimerGui = nil
    end
end

--------------------------------------------------------------------------------
-- 2. SEE KNIFE ESP LOGIC
--------------------------------------------------------------------------------
local KnifeESP_Connection = nil
local KnifeWorkspaceConnection = nil
local ActiveKnifeAdornments = {}

local function ClearKnifeESP()
    for part, adornment in pairs(ActiveKnifeAdornments) do
        if adornment then adornment:Destroy() end
    end
    table.clear(ActiveKnifeAdornments)
end

local function CreateKnifeBox(targetPart)
    if not targetPart or ActiveKnifeAdornments[targetPart] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "KillerHub_CleanKnifeBox"
    box.Color3 = Color3.fromRGB(0, 255, 100)
    box.Transparency = 0.3
    box.AlwaysOnTop = true
    box.ZIndex = 5
    
    if targetPart:IsA("BasePart") then
        box.Size = targetPart.Size + Vector3.new(0.3, 0.3, 0.3)
    else
        box.Size = Vector3.new(1.2, 2.5, 1.2)
    end

    box.Adornee = targetPart

    if syn and syn.protect_gui then
        syn.protect_gui(box)
        box.Parent = CoreGui
    elseif gethui then
        box.Parent = gethui()
    else
        box.Parent = CoreGui
    end

    ActiveKnifeAdornments[targetPart] = box
end

local function ProcessPartOrModel(obj)
    if not obj then return nil end
    
    if obj:IsA("BasePart") then
        return obj
    elseif obj:IsA("Model") or obj:IsA("Tool") then
        local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
        if handle and handle:IsA("BasePart") then
            return handle
        end
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") then
                return child
            end
        end
    end
    return nil
end

local function IsPartEquippedOrInWorkspace(part)
    if not part or not part.Parent then return false end
    
    local tool = part:FindFirstAncestorOfClass("Tool")
    if tool then
        local character = tool.Parent
        if character and character:FindFirstChildOfClass("Humanoid") then
            return true
        end
        return false
    end

    return part:IsDescendantOf(Workspace)
end

--------------------------------------------------------------------------------
-- 3. SEE TRAPS ESP LOGIC (OPTIMIZED)
--------------------------------------------------------------------------------
local TrapsESP_Connection = nil
local TrapsWorkspaceConnection = nil
local ActiveTrapAdornments = {}

local function ClearTrapsESP()
    for part, adornment in pairs(ActiveTrapAdornments) do
        if adornment then adornment:Destroy() end
    end
    table.clear(ActiveTrapAdornments)
end

local function CreateTrapBox(targetPart)
    if not targetPart or ActiveTrapAdornments[targetPart] then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "KillerHub_TrapBox"
    box.Color3 = Color3.fromRGB(255, 30, 30)
    box.Transparency = 0.3
    box.AlwaysOnTop = true
    box.ZIndex = 5

    if targetPart:IsA("BasePart") then
        box.Size = targetPart.Size + Vector3.new(0.4, 0.4, 0.4)
    else
        box.Size = Vector3.new(2, 2, 2)
    end

    box.Adornee = targetPart

    if syn and syn.protect_gui then
        syn.protect_gui(box)
        box.Parent = CoreGui
    elseif gethui then
        box.Parent = gethui()
    else
        box.Parent = CoreGui
    end

    ActiveTrapAdornments[targetPart] = box
end

--------------------------------------------------------------------------------
-- CONTROLS
--------------------------------------------------------------------------------
TabExtras:CreateSection("Performance")

TabExtras:CreateToggle("Extras_PerformanceStats", "Show Stats", function(estado)
    CleanUpPerfOverlay()

    if estado then
        statsGui = Instance.new("ScreenGui")
        statsGui.Name = "KillerHub_PerformanceOverlay"
        statsGui.ResetOnSpawn = false

        statsFrame = Instance.new("Frame")
        statsFrame.Size = UDim2.new(0, 155, 0, 72)
        statsFrame.Position = UDim2.new(1, -162, 0, 2)
        statsFrame.BackgroundColor3 = Color3.fromRGB(12, 4, 22)
        statsFrame.BackgroundTransparency = statsBgTransparency
        statsFrame.BorderSizePixel = 0

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = statsFrame

        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1.2
        Stroke.Color = Color3.fromRGB(40, 15, 65)
        Stroke.Parent = statsFrame

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(1, -10, 1, -6)
        TextLabel.Position = UDim2.new(0, 8, 0, 3)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        TextLabel.TextSize = 12
        TextLabel.LineHeight = 1.25
        TextLabel.RichText = true
        TextLabel.Text = "Loading..."
        TextLabel.Parent = statsFrame

        statsFrame.Parent = statsGui

        if syn and syn.protect_gui then
            syn.protect_gui(statsGui)
            statsGui.Parent = CoreGui
        elseif gethui then
            statsGui.Parent = gethui()
        else
            statsGui.Parent = CoreGui
        end

        local lastTime = os_clock()
        local frameCount = 0
        local currentFps = 60

        local pingObject = nil
        pcall(function() pingObject = StatsService.Network.ServerStatsItem["Data Ping"] end)

        statsConnection = RunService.Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local currentTime = os_clock()
            
            if currentTime - lastTime >= 0.35 then
                currentFps = math_round(frameCount / (currentTime - lastTime))
                frameCount = 0
                lastTime = currentTime

                local ping = 0
                if pingObject then
                    pcall(function() ping = math_round(pingObject:GetValue()) end)
                elseif LocalPlayer then
                    pcall(function() ping = math_round(LocalPlayer:GetNetworkPing() * 1000) end)
                end
                
                local memoria = math_round(StatsService:GetTotalMemoryUsageMb())

                TextLabel.Text = string_format(
                    "FPS:  <font color=\"rgb(160,60,255)\">%d</font>\nPING: <font color=\"rgb(0,255,120)\">%d ms</font>\nRAM:  <font color=\"rgb(240,240,240)\">%d MB</font>",
                    currentFps, ping, memoria
                )
            end
        end)
    end
end)

TabExtras:CreateSlider("Extras_StatsOpacity", "BG Opacity (%)", 0, 100, function(valor)
    statsBgTransparency = valor / 100
    if statsFrame then 
        statsFrame.BackgroundTransparency = statsBgTransparency 
    end
end)

TabExtras:CreateSection("Round Info")

TabExtras:CreateToggle("Extras_ShowRoundTime", "Round Time", function(enabled)
    if enabled then
        local label = CreateTimerUI()
        local zeroTime = nil
        local lastCheck = 0

        RoundTimerConnection = RunService.Heartbeat:Connect(function()
            if os_clock() - lastCheck < 0.2 then return end
            lastCheck = os_clock()

            local timerPart = Workspace:FindFirstChild("RoundTimerPart")
            if timerPart then
                local secondsRemaining = timerPart:GetAttribute("Time")
                if secondsRemaining and tonumber(secondsRemaining) and secondsRemaining > 0 then
                    zeroTime = nil
                    label.Visible = true
                    label.Text = FormatTime(secondsRemaining)
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    return
                end
            end

            if not zeroTime then
                zeroTime = tick()
            end

            if tick() - zeroTime <= 3 then
                label.Visible = true
                label.Text = "00:00"
                label.TextColor3 = Color3.fromRGB(255, 40, 40)
            else
                label.Visible = false
            end
        end)
    else
        if RoundTimerConnection then
            RoundTimerConnection:Disconnect()
            RoundTimerConnection = nil
        end
        RemoveTimerUI()
    end
end)

TabExtras:CreateSection("Visuals")

TabExtras:CreateToggle("Extras_SeeKnifeESP", "Knife ESP", function(enabled)
    if enabled then
        local lastScan = 0

        KnifeESP_Connection = RunService.Heartbeat:Connect(function()
            if os_clock() - lastScan < 0.15 then return end
            lastScan = os_clock()

            local currentTargets = {}

            -- 1. Equipped Knife
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    if char then
                        local knifeTool = char:FindFirstChild("Knife")
                        if knifeTool then
                            local validPart = ProcessPartOrModel(knifeTool)
                            if validPart then
                                currentTargets[validPart] = true
                            end
                        end
                    end
                end
            end

            -- 2. Thrown Knife
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "Knife" or obj.Name == "FlyingKnife" or obj:GetAttribute("ThrowSpeed") or obj:FindFirstChild("KnifeClient") then
                    local validPart = ProcessPartOrModel(obj)
                    if validPart then
                        currentTargets[validPart] = true
                    end
                end
            end

            -- Clean up
            for part, adornment in pairs(ActiveKnifeAdornments) do
                if not currentTargets[part] or not IsPartEquippedOrInWorkspace(part) then
                    adornment:Destroy()
                    ActiveKnifeAdornments[part] = nil
                end
            end

            -- Assign ESP
            for part in pairs(currentTargets) do
                if not ActiveKnifeAdornments[part] and IsPartEquippedOrInWorkspace(part) then
                    CreateKnifeBox(part)
                end
            end
        end)

        KnifeWorkspaceConnection = Workspace.ChildAdded:Connect(function(child)
            task.spawn(function()
                if child.Name == "Knife" or child.Name == "FlyingKnife" or child:GetAttribute("ThrowSpeed") or child:FindFirstChild("KnifeClient") then
                    local validPart = ProcessPartOrModel(child)
                    local attempts = 0
                    while not validPart and attempts < 10 do
                        task.wait(0.05)
                        attempts = attempts + 1
                        validPart = ProcessPartOrModel(child)
                    end
                    if validPart and IsPartEquippedOrInWorkspace(validPart) then
                        CreateKnifeBox(validPart)
                    end
                end
            end)
        end)
    else
        if KnifeESP_Connection then
            KnifeESP_Connection:Disconnect()
            KnifeESP_Connection = nil
        end
        if KnifeWorkspaceConnection then
            KnifeWorkspaceConnection:Disconnect()
            KnifeWorkspaceConnection = nil
        end
        ClearKnifeESP()
    end
end)

TabExtras:CreateToggle("Extras_SeeTraps", "Traps ESP", function(enabled)
    if enabled then
        local lastScan = 0

        TrapsESP_Connection = RunService.Heartbeat:Connect(function()
            if os_clock() - lastScan < 0.5 then return end
            lastScan = os_clock()

            local currentTraps = {}

            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj.Name == "Trap" and (obj:IsA("Model") or obj:IsA("BasePart")) then
                    local validPart = ProcessPartOrModel(obj)
                    if validPart then
                        currentTraps[validPart] = true
                    end
                end
            end

            -- Clean up
            for part, adornment in pairs(ActiveTrapAdornments) do
                if not currentTraps[part] or not part.Parent then
                    adornment:Destroy()
                    ActiveTrapAdornments[part] = nil
                end
            end

            -- Assign ESP
            for part in pairs(currentTraps) do
                if not ActiveTrapAdornments[part] then
                    CreateTrapBox(part)
                end
            end
        end)

        TrapsWorkspaceConnection = Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Trap" then
                task.spawn(function()
                    local validPart = ProcessPartOrModel(descendant)
                    local attempts = 0
                    while not validPart and attempts < 10 do
                        task.wait(0.05)
                        attempts = attempts + 1
                        validPart = ProcessPartOrModel(descendant)
                    end
                    if validPart and validPart:IsDescendantOf(Workspace) then
                        CreateTrapBox(validPart)
                    end
                end)
            end
        end)
    else
        if TrapsESP_Connection then
            TrapsESP_Connection:Disconnect()
            TrapsESP_Connection = nil
        end
        if TrapsWorkspaceConnection then
            TrapsWorkspaceConnection:Disconnect()
            TrapsWorkspaceConnection = nil
        end
        ClearTrapsESP()
    end
end)

--------------------------------------------------------------------------------
-- CLEANUP TASK
--------------------------------------------------------------------------------
KillerHub:AddTask(function()
    CleanUpPerfOverlay()
    if RoundTimerConnection then
        RoundTimerConnection:Disconnect()
        RoundTimerConnection = nil
    end
    if KnifeESP_Connection then
        KnifeESP_Connection:Disconnect()
        KnifeESP_Connection = nil
    end
    if KnifeWorkspaceConnection then
        KnifeWorkspaceConnection:Disconnect()
        KnifeWorkspaceConnection = nil
    end
    if TrapsESP_Connection then
        TrapsESP_Connection:Disconnect()
        TrapsESP_Connection = nil
    end
    if TrapsWorkspaceConnection then
        TrapsWorkspaceConnection:Disconnect()
        TrapsWorkspaceConnection = nil
    end
    RemoveTimerUI()
    ClearKnifeESP()
    ClearTrapsESP()
    getgenv().__KillerHub_Extras_Loaded = nil
end)

KillerHub:NotifySuccess("Extras", "Loaded successfully", 3)
