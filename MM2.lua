-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V8.5.2 [CORRECTED SOURCE URL]
-- ============================================================================
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

-- URL corregida al archivo correcto de la interfaz
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- 1. PESTAÑA SHERIFF
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- 2. CONFIGURACIÓN COMPLETA
local SheriffConfig = {
    SilentAim = false,
    WallCheck = true,
    
    -- Ajustes Predictivos Avanzados
    PredictMode = "Híbrido Definitivo", 
    SmoothIntensity = 0.22,
    HorizontalPred = 1.0, 
    VerticalPred = 1.0,   
    
    -- Tracers Activos
    ShowTargetTracer = false, -- Rojo (Capa Suprema)
    ShowPingTracer = false,   -- Azul Fuerte
    ShowLagTracer = false,    -- Morado
    ShowLeadTracer = false,   -- Mano Verde Neón
    LeadTimePred = 0.05,      
    
    -- Interfaz Base
    UseWeaponDetector = false,
    AutoUnequip = false,
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95,
    ButtonLocked = false,
    ButtonX = 0.7,
    ButtonY = 0.6
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite_V8_5.txt"

local function saveConfig()
    if writefile then
        local data = {
            ButtonX = SheriffConfig.ButtonX,
            ButtonY = SheriffConfig.ButtonY,
            PredictMode = SheriffConfig.PredictMode,
            SmoothIntensity = SheriffConfig.SmoothIntensity,
            HorizontalPred = SheriffConfig.HorizontalPred,
            VerticalPred = SheriffConfig.VerticalPred,
            UseWeaponDetector = SheriffConfig.UseWeaponDetector,
            AutoUnequip = SheriffConfig.AutoUnequip,
            ShowTargetTracer = SheriffConfig.ShowTargetTracer,
            ShowPingTracer = SheriffConfig.ShowPingTracer,
            ShowLagTracer = SheriffConfig.ShowLagTracer,
            ShowLeadTracer = SheriffConfig.ShowLeadTracer,
            LeadTimePred = SheriffConfig.LeadTimePred
        }
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end
end

local function loadConfig()
    if readfile and isfile and isfile(CONFIG_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(data) == "table" then
            SheriffConfig.ButtonX = data.ButtonX or SheriffConfig.ButtonX
            SheriffConfig.ButtonY = data.ButtonY or SheriffConfig.ButtonY
            SheriffConfig.PredictMode = data.PredictMode or SheriffConfig.PredictMode
            SheriffConfig.SmoothIntensity = data.SmoothIntensity or SheriffConfig.SmoothIntensity
            SheriffConfig.HorizontalPred = data.HorizontalPred or SheriffConfig.HorizontalPred
            SheriffConfig.VerticalPred = data.VerticalPred or SheriffConfig.VerticalPred
            SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
            if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
            if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
            if data.ShowTargetTracer ~= nil then SheriffConfig.ShowTargetTracer = data.ShowTargetTracer end
            if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
            if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
            if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
        end
    end
end
loadConfig()

-- ============================================================================
-- ⚙️ INTERFAZ GRÁFICA CONTROLADA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Verificar Paredes Físicas (Estricto)", function(estado)
    SheriffConfig.WallCheck = estado
end)

SheriffTab:CreateSection("Motor de Predicción")

SheriffTab:CreateDropdown("PredictModeDropdown", "Filtro de Escenario Target:", {"Híbrido Definitivo", "Adaptativo Automático", "Anti-ZigZag", "Agresivo"}, function(seleccionado)
    SheriffConfig.PredictMode = seleccionado
    saveConfig()
end)

SheriffTab:CreateSlider("SmoothIntensitySlider", "Suavizado de Trayectoria (%)", 5, 50, function(valor)
    SheriffConfig.SmoothIntensity = valor / 100
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Ajuste Fino Horizontal (%)", 50, 150, function(valor)
    SheriffConfig.HorizontalPred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Ajuste Fino Vertical (%)", 50, 150, function(valor)
    SheriffConfig.VerticalPred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers)")

SheriffTab:CreateToggle("TargetTracerToggle", "Mostrar Tracer de Impacto (Rojo)", function(estado)
    SheriffConfig.ShowTargetTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("PingTracerToggle", "Mostrar Ping Prediction (Azul Fuerte)", function(estado)
    SheriffConfig.ShowPingTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LagTracerToggle", "Mostrar Lag Realtime (Morado)", function(estado)
    SheriffConfig.ShowLagTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LeadTracerToggle", "Activar Lead Tracer (Mano Verde Neón)", function(estado)
    SheriffConfig.ShowLeadTracer = estado
    saveConfig()
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Ver anticipación (Mano)", 0, 100, function(valor)
    SheriffConfig.LeadTimePred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Condiciones de Interfaz / Tácticas")
SheriffTab:CreateToggle("WeaponDetectToggle", "Ocultar Botón si no tengo Arma", function(estado)
    SheriffConfig.UseWeaponDetector = estado
    saveConfig()
end)

SheriffTab:CreateToggle("AutoUnequipToggle", "Auto-Desequipar Arma (Fast Unequip)", function(estado)
    SheriffConfig.AutoUnequip = estado
    saveConfig()
end)

SheriffTab:CreateToggle("ShowVoidButton", "Mostrar Botón en Pantalla", function(estado)
    SheriffConfig.ShowShootButton = estado
end)

SheriffTab:CreateSlider("VoidBtnSize", "Tamaño del Botón Void", 50, 200, function(valor)
    SheriffConfig.ButtonSize = valor
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.Size = UDim2.new(0, valor, 0, valor)
        if btn:FindFirstChild("UICorner") then btn.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.24)) end
        if btn:FindFirstChild("GlowOverlay") and btn.GlowOverlay:FindFirstChild("UICorner") then
            btn.GlowOverlay.UICorner.CornerRadius = UDim.new(0, math.floor(valor * 0.24))
        end
    end
end)

SheriffTab:CreateSlider("VoidBtnOpacity", "Opacidad del Botón", 10, 100, function(valor)
    SheriffConfig.ButtonOpacity = valor / 100
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
        if btn:FindFirstChild("DecalTexture") then btn.DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity end
        if btn:FindFirstChild("Label") then btn.Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity end
    end
end)

SheriffTab:CreateToggle("LockVoidBtn", "Bloquear Posición del Botón", function(estado)
    SheriffConfig.ButtonLocked = estado
end)

-- ============================================================================
-- 🧠 MOTOR CINEMÁTICO INTEGRADO (LÓGICA HÍBRIDA)
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

local smoothVelocity = Vector3.new()
local lastRawVelocity = Vector3.new()
local smoothedPing = 0.03

task.spawn(function()
    while task.wait(0.5) do
        if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
            local rawPing = Stats.Network.ServerToClientPing:GetValue() / 1000
            smoothedPing = smoothedPing + (rawPing - smoothedPing) * 0.3
        end
    end
end)

local wallcastParams = RaycastParams.new()
wallcastParams.FilterType = Enum.RaycastFilterType.Exclude
local ignoreInstances = {}

local function getGunLocation()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Gun") then return char:FindFirstChild("Gun"), char
    elseif LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun") then return LocalPlayer.Backpack.Gun, LocalPlayer.Backpack end
    return nil, nil
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local char = player.Character
            if (char and char:FindFirstChild("Knife")) or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then return player end
        end
    end
    return nil
end

local function isPartVisible(targetPart, murdererChar)
    if not SheriffConfig.WallCheck then return true end
    if not targetPart or not murdererChar or not LocalPlayer.Character then return false end
    
    table.clear(ignoreInstances)
    table.insert(ignoreInstances, LocalPlayer.Character)
    table.insert(ignoreInstances, murdererChar)
    table.insert(ignoreInstances, Camera)
    wallcastParams.FilterDescendantsInstances = ignoreInstances
    
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local pathCheck = workspace:Raycast(hrp.Position, targetPart.Position - hrp.Position, wallcastParams)
    return not pathCheck
end

local function getAbsoluteTargetPart(murdererChar)
    if not murdererChar then return nil end
    local priorityParts = {"HumanoidRootPart", "Head", "UpperTorso"}
    for _, name in ipairs(priorityParts) do
        local part = murdererChar:FindFirstChild(name)
        if part and isPartVisible(part, murdererChar) then return part end
    end
    return murdererChar:FindFirstChild("HumanoidRootPart")
end

local function calculateStablePrediction(targetChar)
    if not targetChar then return nil end
    local mainPart = getAbsoluteTargetPart(targetChar)
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    
    if not mainPart or not localHrp or not humanoid or humanoid.Health <= 0 then return nil end
    
    local targetPos = mainPart.Position
    local rawVelocity = mainPart.AssemblyLinearVelocity
    
    if rawVelocity.Magnitude > 80 then 
        rawVelocity = rawVelocity.Unit * 16 
    end
    
    local smoothWeight = SheriffConfig.SmoothIntensity
    smoothVelocity = smoothVelocity:Lerp(rawVelocity, smoothWeight)
    
    local distance = (targetPos - localHrp.Position).Magnitude
    local bulletTravelTime = distance / 275
    local timeToTarget = bulletTravelTime + smoothedPing
    
    local dotDirection = smoothVelocity.Unit:Dot(lastRawVelocity.Unit)
    
    -- 🔥 EJECUCIÓN DEL MODO: HÍBRIDO DEFINITIVO
    if SheriffConfig.PredictMode == "Híbrido Definitivo" then
        if distance < 10 then
            timeToTarget = timeToTarget * 0.08
        elseif distance < 30 then
            timeToTarget = timeToTarget * 0.9
        else
            timeToTarget = timeToTarget * 1.15
        end
        
        if dotDirection < 0.4 and smoothVelocity.Magnitude > 5 then
            timeToTarget = timeToTarget * 0.65
        elseif dotDirection > 0.95 and smoothVelocity.Magnitude > 11 then
            timeToTarget = timeToTarget * 1.25
        end
    else
        if SheriffConfig.PredictMode == "Anti-ZigZag" or (dotDirection < 0.4 and smoothVelocity.Magnitude > 5) then
            timeToTarget = timeToTarget * 0.65
        end
        
        if distance < 10 then
            timeToTarget = timeToTarget * 0.08
        elseif distance < 30 then
            timeToTarget = timeToTarget * 0.9
        else
            timeToTarget = timeToTarget * 1.15
        end
        
        if SheriffConfig.PredictMode == "Agresivo" then
            timeToTarget = timeToTarget * 1.3
        end
    end
    
    local tH = timeToTarget * SheriffConfig.HorizontalPred
    local tV = timeToTarget * SheriffConfig.VerticalPred
    
    local predictedX = targetPos.X + (smoothVelocity.X * tH)
    local predictedZ = targetPos.Z + (smoothVelocity.Z * tH)
    local predictedY = targetPos.Y
    
    if humanoid.FloorMaterial == Enum.Material.Air or math.abs(rawVelocity.Y) > 0.5 then
        predictedY = targetPos.Y + (smoothVelocity.Y * tV) - (0.5 * workspace.Gravity * (tV ^ 2))
        if predictedY < (targetPos.Y - 4) then predictedY = targetPos.Y - 4 end
    else
        predictedY = targetPos.Y + (smoothVelocity.Y * tV * 0.5)
    end
    
    lastRawVelocity = rawVelocity
    return Vector3.new(predictedX, predictedY, predictedZ)
end

-- ============================================================================
-- 🟦 🟣 🟥 🟩 SISTEMA DE TRACERS OPTIMIZADO
-- ============================================================================
local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 85, 255)
PingLine.Thickness = 1.0
PingLine.Visible = false
PingLine.ZIndex = 1 
table.insert(_G.KillerHubLines, PingLine)

local LagLine = Drawing.new("Line")
LagLine.Color = Color3.fromRGB(160, 32, 240)
LagLine.Thickness = 1.0
LagLine.Visible = false
LagLine.ZIndex = 2 
table.insert(_G.KillerHubLines, LagLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(103, 255, 89)
LeadLine.Thickness = 1.0
LeadLine.Visible = false
LeadLine.ZIndex = 3 
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35)
PredictionLine.Thickness = 1.6 
PredictionLine.Visible = false
PredictionLine.ZIndex = 4 
table.insert(_G.KillerHubLines, PredictionLine)

RunService.RenderStepped:Connect(function()
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local murderer = getMurderer()
    
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not murderer or not murderer.Character then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        return
    end

    local mainPart = getAbsoluteTargetPart(murderer.Character)
    local localChar = LocalPlayer.Character
    
    if mainPart and localChar then
        local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        local predictedLocation = calculateStablePrediction(murderer.Character)
        local distance = (mainPart.Position - (localChar:FindFirstChild("HumanoidRootPart") and localChar.HumanoidRootPart.Position or Vector3.new())).Magnitude
        
        if predictedLocation and SheriffConfig.ShowTargetTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedLocation)
            if onScreen then
                PredictionLine.From = viewportCenter
                PredictionLine.To = Vector2.new(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        if SheriffConfig.ShowPingTracer then
            local pingPos = mainPart.Position + (smoothVelocity * smoothedPing)
            local screenPos, onScreen = Camera:WorldToViewportPoint(pingPos)
            if onScreen then
                PingLine.From = viewportCenter
                PingLine.To = Vector2.new(screenPos.X, screenPos.Y)
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        if predictedLocation and SheriffConfig.ShowLagTracer then
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedLocation)
            if onScreen then
                LagLine.From = viewportCenter
                LagLine.To = Vector2.new(screenPos.X, screenPos.Y)
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        local hand = localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm")
        if SheriffConfig.ShowLeadTracer and hand then
            local distFactor = math.clamp((distance - 4) / 16, 0, 1)
            local balancedVelocity = Vector3.new(smoothVelocity.X, smoothVelocity.Y * 0.5, smoothVelocity.Z)
            local leadPredictedPos = mainPart.Position + (balancedVelocity * SheriffConfig.LeadTimePred * distFactor)
            
            local handScreenPos, handOnScreen = Camera:WorldToViewportPoint(hand.Position)
            local targetScreenPos, targetOnScreen = Camera:WorldToViewportPoint(leadPredictedPos)

            if handOnScreen and targetOnScreen then
                LeadLine.From = Vector2.new(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
    end
end)

local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local murderer = getMurderer()

    if gun and murderer and murderer.Character then
        local mainPart = getAbsoluteTargetPart(murderer.Character)
        if mainPart and isPartVisible(mainPart, murderer.Character) then
            local predictedPos = calculateStablePrediction(murderer.Character)
            if predictedPos then
                if parent == LocalPlayer.Backpack then
                    humanoid:EquipTool(gun)
                    RunService.Heartbeat:Wait()
                end
                if gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then
                        originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame
                    end
                    gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                end
                if SheriffConfig.AutoUnequip then
                    task.wait(0.01)
                    humanoid:UnequipTools()
                end
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ DE USUARIO INTERACTIVA
-- ============================================================================
local VoidGui = Instance.new("ScreenGui")
VoidGui.Name = "KillerHub_VoidGui"
VoidGui.ResetOnSpawn = false
VoidGui.Parent = game:GetService("CoreGui")

local ShootButton = Instance.new("ImageButton")
ShootButton.Name = "ShootButton"
ShootButton.Size = UDim2.new(0, SheriffConfig.ButtonSize, 0, SheriffConfig.ButtonSize)
ShootButton.Position = UDim2.new(SheriffConfig.ButtonX, 0, SheriffConfig.ButtonY, 0)
ShootButton.BackgroundColor3 = Color3.fromRGB(15, 6, 26)
ShootButton.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
ShootButton.BorderSizePixel = 0
ShootButton.AutoButtonColor = false
ShootButton.ClipsDescendants = true
ShootButton.Parent = VoidGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, math.floor(SheriffConfig.ButtonSize * 0.24))
Corner.Parent = ShootButton

local GlowOverlay = Instance.new("Frame")
GlowOverlay.Name = "GlowOverlay"
GlowOverlay.Size = UDim2.new(1, 0, 1, 0)
GlowOverlay.Position = UDim2.new(0, 0, 0, 0)
GlowOverlay.BackgroundTransparency = 1
GlowOverlay.ZIndex = ShootButton.ZIndex + 1
GlowOverlay.Parent = ShootButton

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = Corner.CornerRadius
GlowCorner.Parent = GlowOverlay

local UiGradient = Instance.new("UIGradient")
UiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 8, 43)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(131, 46, 222)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 8, 43))
})
UiGradient.Rotation = 45
UiGradient.Parent = GlowOverlay

local DecalTexture = Instance.new("ImageLabel")
DecalTexture.Name = "DecalTexture"
DecalTexture.Size = UDim2.new(0.39, 0, 0.39, 0)
DecalTexture.AnchorPoint = Vector2.new(0.5, 0.5)
DecalTexture.Position = UDim2.new(0.5, 0, 0.43, 0)
DecalTexture.BackgroundTransparency = 1
DecalTexture.Image = "rbxassetid://125754446555599"
DecalTexture.ImageTransparency = 1 - SheriffConfig.ButtonOpacity
DecalTexture.ZIndex = ShootButton.ZIndex + 2
DecalTexture.Parent = ShootButton

TweenService:Create(DecalTexture, TweenInfo.new(0.85, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Rotation = 360}):Play()

local Label = Instance.new("TextLabel")
Label.Name = "Label"
Label.Size = UDim2.new(1, 0, 0.2, 0)
Label.Position = UDim2.new(0, 0, 0.75, 0)
Label.BackgroundTransparency = 1
Label.Text = "SHOOT"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextSize = 15
Label.Font = Enum.Font.GothamBold
Label.TextTransparency = 1 - SheriffConfig.ButtonOpacity
Label.ZIndex = ShootButton.ZIndex + 2
Label.Parent = ShootButton

local function processGlowAtCoordinates(inputPosition)
    local buttonAbsolutePos = ShootButton.AbsolutePosition
    local buttonSize = ShootButton.AbsoluteSize
    local localX = inputPosition.X - buttonAbsolutePos.X
    local relX = (localX / buttonSize.X) - 0.5
    
    UiGradient.Offset = Vector2.new(relX * 1.5, 0)
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.18}):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
end

local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
local DRAG_THRESHOLD = 8

ShootButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        processGlowAtCoordinates(input.Position)
        task.spawn(fireAtMurdererDirectly)
        
        if not SheriffConfig.ButtonLocked then
            dragStart = input.Position
            startPos = ShootButton.Position
            dragging = false
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragging then
                        SheriffConfig.ButtonX = ShootButton.Position.X.Scale
                        SheriffConfig.ButtonY = ShootButton.Position.Y.Scale
                        saveConfig()
                    end
                    dragStart, dragging = nil, false
                end
            end)
        end
    end
end)

ShootButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        fadeGlowReflection()
    end
end)

ShootButton.InputChanged:Connect(function(input)
    if not SheriffConfig.ButtonLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragStart then
        local delta = input.Position - dragStart
        if not dragging and delta.Magnitude > DRAG_THRESHOLD then dragging = true end
        if dragging then
            ShootButton.Position = UDim2.new(startPos.X.Scale + (delta.X / Camera.ViewportSize.X), 0, startPos.Y.Scale + (delta.Y / Camera.ViewportSize.Y), 0)
        end
    end
end)

-- ============================================================================
-- ⚡ INTERCEPTACIÓN REMOTA
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    local function checkAndPredict()
        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murderer = getMurderer()
            if murderer and murderer.Character then
                local mainPart = getAbsoluteTargetPart(murderer.Character)
                if mainPart and isPartVisible(mainPart, murderer.Character) then
                    local predictedPos = calculateStablePrediction(murderer.Character)
                    if predictedPos then return CFrame.new(predictedPos) end
                end
            end
        end
        return nil
    end

    WeaponService.GetTargetPosition = function(self, ...)
        local prediction = checkAndPredict()
        return prediction or oldGetTargetPosition(self, ...)
    end

    WeaponService.GetMouseTargetCFrame = function(self, ...)
        local prediction = checkAndPredict()
        return prediction or oldGetMouseTargetCFrame(self, ...)
    end
end

return KillerHub
