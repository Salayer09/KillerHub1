-- ============================================================================
-- 🚀 KILLER HUB - SCRIPT EJECUTOR (VERSIÓN V6.6 - OPTIMIZADO PARA NUEVA UI)
-- ============================================================================

local KillerHub

-- 1️⃣ CONTROLADOR DE INYECCIÓN PROTEGIDO (NUEVA API)
local success, result = pcall(function()
    if _G.KillerHubInstance then
        return _G.KillerHubInstance
    else
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/Killer-Hub-test/refs/heads/main/Test.lua"))()
    end
end)

if not success or not result then
    warn("❌ Error Crítico: No se pudo enlazar el ejecutor con la UI de KillerHub: " .. tostring(result))
    return
end

KillerHub = result
_G.KillerHubInstance = KillerHub

-- 2️⃣ BUCLE DE ESPERA SEGURO (Anti-Index Nil)
local maxIntentos = 10
local contador = 0
while (not KillerHub.Tabs or not KillerHub.Tabs.Visuals) and contador < maxIntentos do
    task.wait(0.5)
    contador = contador + 1
end

if not KillerHub.Tabs or not KillerHub.Tabs.Visuals then
    warn("❌ Error Estructural: La UI se cargó pero no inicializó las tablas a tiempo.")
    return
end

-- 3️⃣ ASIGNACIÓN DE PESTAÑAS INDEXADAS
local Visuals  = KillerHub.Tabs.Visuals
local Murder   = KillerHub.Tabs.Murder
local Sheriff  = KillerHub.Tabs.Sheriff
local Extras   = KillerHub.Tabs.Extras
local Settings = KillerHub.Tabs.Settings

-- ============================================================================
-- 💾 SISTEMA DE CONFIGURACIÓN DE ESTADOS INTERNOS
-- ============================================================================
local states = {
    GunSilentAim = false,       
    TracerPrediction = false,
    JumpPrediction = true, 
    TracerSpeed = 0.85,
    HorizontalPrediction = 1.00, 
    VerticalPrediction = 1.00,   
    ShowShootButton = false,
    LockButton = false,
    ButtonSize = 100,
    ButtonOpacity = 0.25,
    WallCheck = true, 
    SeeLeadTime = false,
    LeadTimePrediction = 0.30,
    SmartVisibility = false,
    
    SimDivider = 4,       
    PredInterval = 5,     
    PingAdaptation = false, 
    
    ButtonScaleX = 0.80,
    ButtonOffsetX = 0,
    ButtonScaleY = 0.45,
    ButtonOffsetY = 0,
    
    KnifeSilentAim = false,
    KnifeWallCheck = true,
    KnifeFovRadius = 100,
    KnifeShowFov = true,
    KnifeFovR = 0,
    KnifeFovG = 255,
    KnifeFovB = 100,
    KnifePredHorizontal = 1.5,
    KnifePredVertical = 1.0,
    KnifeShowTargetDot = true,
    KnifeShowPredCircle = true
}

local COLOR_VOID_BASE = Color3.fromRGB(12, 4, 22)
local COLOR_VOID_GLOW = Color3.fromRGB(22, 6, 38)
local COLOR_STROKE_BASE = Color3.fromRGB(24, 8, 42)
local COLOR_STROKE_GLOW = Color3.fromRGB(95, 25, 175)

local HttpService = game:GetService("HttpService")
local FILE_NAME = "KillerHub_Button_Config.json"

local function saveButtonConfig()
    if writefile then
        local data = {
            GunSilentAim = states.GunSilentAim,
            TracerPrediction = states.TracerPrediction,
            JumpPrediction = states.JumpPrediction,
            TracerSpeed = states.TracerSpeed,
            HorizontalPrediction = states.HorizontalPrediction,
            VerticalPrediction = states.VerticalPrediction,
            ShowShootButton = states.ShowShootButton,
            LockButton = states.LockButton,
            ButtonSize = states.ButtonSize,
            ButtonOpacity = states.ButtonOpacity,
            WallCheck = states.WallCheck,
            SeeLeadTime = states.SeeLeadTime,
            LeadTimePrediction = states.LeadTimePrediction,
            SmartVisibility = states.SmartVisibility,
            SimDivider = states.SimDivider,        
            PredInterval = states.PredInterval,    
            PingAdaptation = states.PingAdaptation, 
            ButtonScaleX = states.ButtonScaleX,
            ButtonOffsetX = states.ButtonOffsetX,
            ButtonScaleY = states.ButtonScaleY,
            ButtonOffsetY = states.ButtonOffsetY,
            KnifeSilentAim = states.KnifeSilentAim,
            KnifeWallCheck = states.KnifeWallCheck,
            KnifeFovRadius = states.KnifeFovRadius,
            KnifeShowFov = states.KnifeShowFov,
            KnifeFovR = states.KnifeFovR,
            KnifeFovG = states.KnifeFovG,
            KnifeFovB = states.KnifeFovB,
            KnifePredHorizontal = states.KnifePredHorizontal,
            KnifePredVertical = states.KnifePredVertical,
            KnifeShowTargetDot = states.KnifeShowTargetDot,
            KnifeShowPredCircle = states.KnifeShowPredCircle
        }
        writefile(FILE_NAME, HttpService:JSONEncode(data))
    end
end

local function loadButtonConfig()
    local success, content = pcall(function() return readfile(FILE_NAME) end)
    if success and content then
        local decodeSuccess, result = pcall(function() return HttpService:JSONDecode(content) end)
        if decodeSuccess and type(result) == "table" then
            if result.GunSilentAim ~= nil then states.GunSilentAim = result.GunSilentAim end
            if result.TracerPrediction ~= nil then states.TracerPrediction = result.TracerPrediction end
            if result.JumpPrediction ~= nil then states.JumpPrediction = result.JumpPrediction end
            states.HorizontalPrediction = result.HorizontalPrediction or 1.00
            states.VerticalPrediction = result.VerticalPrediction or 1.00
            if result.ShowShootButton ~= nil then states.ShowShootButton = result.ShowShootButton end
            if result.LockButton ~= nil then states.LockButton = result.LockButton end
            if result.WallCheck ~= nil then states.WallCheck = result.WallCheck end
            if result.SeeLeadTime ~= nil then states.SeeLeadTime = result.SeeLeadTime end
            if result.SmartVisibility ~= nil then states.SmartVisibility = result.SmartVisibility end
            if result.PingAdaptation ~= nil then states.PingAdaptation = result.PingAdaptation end
            states.TracerSpeed = result.TracerSpeed or 0.85
            states.SimDivider = result.SimDivider or 4
            states.PredInterval = result.PredInterval or 5
            states.ButtonSize = result.ButtonSize or 100
            states.ButtonOpacity = result.ButtonOpacity or 0.25
            states.LeadTimePrediction = result.LeadTimePrediction or 0.30
            states.ButtonScaleX = result.ButtonScaleX or 0.80
            states.ButtonOffsetX = result.ButtonOffsetX or 0
            states.ButtonScaleY = result.ButtonScaleY or 0.45
            states.ButtonOffsetY = result.ButtonOffsetY or 0
            if result.KnifeSilentAim ~= nil then states.KnifeSilentAim = result.KnifeSilentAim end
            if result.KnifeWallCheck ~= nil then states.KnifeWallCheck = result.KnifeWallCheck end
            if result.KnifeShowFov ~= nil then states.KnifeShowFov = result.KnifeShowFov end
            states.KnifeFovRadius = result.KnifeFovRadius or 100
            states.KnifeFovR = result.KnifeFovR or 0
            states.KnifeFovG = result.KnifeFovG or 255
            states.KnifeFovB = result.KnifeFovB or 100
            states.KnifePredHorizontal = result.KnifePredHorizontal or 1.5
            states.KnifePredVertical = result.KnifePredVertical or 1.0
            if result.KnifeShowTargetDot ~= nil then states.KnifeShowTargetDot = result.KnifeShowTargetDot end
            if result.KnifeShowPredCircle ~= nil then states.KnifeShowPredCircle = result.KnifeShowPredCircle end
        end
    end
end

loadButtonConfig()

local ShootButton, ShootStroke, ButtonImage, ButtonText
local cachedPing = 0.125 

task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            cachedPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
    end
end)

local function aplicarOpacidadGlobal(transparencia)
    local tClamped = math.clamp(transparencia, 0, 0.95)
    if ShootButton then ShootButton.BackgroundTransparency = tClamped end
    if ShootStroke then ShootStroke.Transparency = tClamped end
    if ButtonImage then ButtonImage.ImageTransparency = tClamped end
    if ButtonText then ButtonText.TextTransparency = tClamped end
end

local function tieneCuchillo()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    return (character and character:FindFirstChild("Knife") ~= nil) or (backpack and backpack:FindFirstChild("Knife") ~= nil)
end

local function tienePistola()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local backpack = player:FindFirstChild("Backpack")
    return (character and character:FindFirstChild("Gun") ~= nil) or (backpack and backpack:FindFirstChild("Gun") ~= nil)
end

local function getHandPosition()
    local character = game:GetService("Players").LocalPlayer.Character
    if character then
        local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
        if hand then return hand.Position end
        return character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
    end
    return nil
end

-- ============================================================================
-- 🧱 VINCULACIÓN CON MENÚS NATIVOS
-- ============================================================================
Sheriff:CreateSection("Target Prediction")
Sheriff:CreateToggle("S_GunSilentAim", "Gun Silent Aim (Clicks)", function(state) states.GunSilentAim = state saveButtonConfig() end)
Sheriff:CreateToggle("S_TracerPrediction", "Show Tracer Guide", function(state) states.TracerPrediction = state saveButtonConfig() end)
Sheriff:CreateToggle("S_JumpPrediction", "Adaptive Jump Prediction", function(state) states.JumpPrediction = state saveButtonConfig() end)
Sheriff:CreateSlider("S_TracerSpeed", "Tracer Speed Tuning", 25, 125, function(val) states.TracerSpeed = val / 100 saveButtonConfig() end)
Sheriff:CreateSlider("S_HorizontalPred", "Horizontal Tuning", 0, 150, function(val) states.HorizontalPrediction = val / 100 saveButtonConfig() end)
Sheriff:CreateSlider("S_VerticalPred", "Vertical Tuning", 0, 125, function(val) states.VerticalPrediction = val / 100 saveButtonConfig() end)

Sheriff:CreateSection("Advanced Prediction")
Sheriff:CreateToggle("S_PingAdaptation", "Dynamic Ping Adaptation", function(state) states.PingAdaptation = state saveButtonConfig() end)
Sheriff:CreateSlider("S_SimDivider", "Simulation Divider (Steps)", 1, 8, function(val) states.SimDivider = math.clamp(math.round(val), 1, 8) saveButtonConfig() end)
Sheriff:CreateSlider("S_PredInterval", "Prediction Interval (Buffer)", 2, 10, function(val) states.PredInterval = math.clamp(math.round(val), 2, 10) saveButtonConfig() end)

Sheriff:CreateSection("Combat Filters")
Sheriff:CreateToggle("S_WallCheck", "Strict Wall Check", function(state) states.WallCheck = state saveButtonConfig() end)
Sheriff:CreateToggle("S_SeeLeadTime", "See Lead Time", function(state) states.SeeLeadTime = state saveButtonConfig() end)
Sheriff:CreateSlider("S_LeadTimePred", "Lead Multiplier", 0, 100, function(val) states.LeadTimePrediction = val / 100 saveButtonConfig() end)

Sheriff:CreateSection("Legacy Settings")
Sheriff:CreateToggle("S_ShowShootButton", "Show Screen Button", function(state) states.ShowShootButton = state if ShootButton then ShootButton.Visible = state end saveButtonConfig() end)
Sheriff:CreateToggle("S_SmartVisibility", "Smart Visibility", function(state) states.SmartVisibility = state saveButtonConfig() end)
Sheriff:CreateToggle("S_LockButton", "Lock Position", function(state) states.LockButton = state saveButtonConfig() end)
Sheriff:CreateSlider("S_ButtonSize", "Button Size", 50, 180, function(val) states.ButtonSize = val if ShootButton then ShootButton.Size = UDim2.new(0, val, 0, val) end saveButtonConfig() end)
Sheriff:CreateSlider("S_ButtonOpacity", "Button Opacity", 0, 100, function(val) local targetTransparency = 1 - (val / 100) states.ButtonOpacity = targetTransparency aplicarOpacidadGlobal(targetTransparency) saveButtonConfig() end)

Murder:CreateSection("Knife Silent Aim")
Murder:CreateToggle("M_SilentActive", "Silent Aim Activo", function(state) states.KnifeSilentAim = state saveButtonConfig() end)
Murder:CreateToggle("M_WallCheck", "Filtro de Paredes (Wall Check)", function(state) states.KnifeWallCheck = state saveButtonConfig() end)
Murder:CreateSlider("M_FovRadius", "Radio de Captura (FOV)", 30, 350, function(val) states.KnifeFovRadius = val saveButtonConfig() end)

Murder:CreateSection("Ajustes de Predicción")
Murder:CreateSlider("M_PredHoriz", "Intensidad Pred. Horizontal", 0, 320, function(val) states.KnifePredHorizontal = val / 100 saveButtonConfig() end)
Murder:CreateSlider("M_PredVert", "Intensidad Pred. Vertical", 0, 320, function(val) states.KnifePredVertical = val / 100 saveButtonConfig() end)

Murder:CreateSection("Configuración Visual Knife FOV")
Murder:CreateToggle("M_ShowFovCircle", "Mostrar Círculo FOV", function(state) states.KnifeShowFov = state saveButtonConfig() end)

Murder:CreateColorPicker("M_KnifeFovColor", "Color del Círculo FOV", Color3.fromRGB(states.KnifeFovR, states.KnifeFovG, states.KnifeFovB), function(colorElegido)
    states.KnifeFovR = math.round(colorElegido.R * 255)
    states.KnifeFovG = math.round(colorElegido.G * 255)
    states.KnifeFovB = math.round(colorElegido.B * 255)
    saveButtonConfig()
end)

Murder:CreateToggle("M_ShowTargetDot", "Mostrar Punto Target", function(state) states.KnifeShowTargetDot = state saveButtonConfig() end)
Murder:CreateToggle("M_ShowPredCircle", "Mostrar Círculo Predicción", function(state) states.KnifeShowPredCircle = state saveButtonConfig() end)

Extras:CreateSection("Extras de Rendimiento")
Settings:CreateSection("Configuración del Framework")
Settings:CreateKeybind("MenuToggle", "Tecla para Ocultar Hub", Enum.KeyCode.RightControl, function(key) end)

-- ============================================================================
-- 🎯 NÚCLEO MATEMÁTICO Y MOTOR DE PROCESAMIENTO
-- ============================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local rolesPartida = {}
local ultimoPosTarget = Vector3.new()
local ultimoPuntoLead = Vector3.new()
local gunVelocityBuffer = {}
local knifeVelocityBuffer = {}
local gunVelocidadFiltrada = Vector3.new()
local gunAceleracionFiltrada = Vector3.new()
local knifeVelocidadFiltrada = Vector3.new()
local lastVelHorizontalBase = Vector3.new() 
local camera = workspace.CurrentCamera
local currentTarget = nil

-- Variables de Optimización y Delta Posición
local ultimaPosReal = nil
local lastHookTick = 0
local cachedHookPos = nil

if CoreGui:FindFirstChild("KillerHub_OverlayEngine") then CoreGui.KillerHub_OverlayEngine:Destroy() end

local OverlayGui = Instance.new("ScreenGui", CoreGui) OverlayGui.Name = "KillerHub_OverlayEngine" OverlayGui.IgnoreGuiInset = true
local TracerLine = Instance.new("Frame", OverlayGui) TracerLine.AnchorPoint = Vector2.new(0.5, 0.5) TracerLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0) TracerLine.BorderSizePixel = 0 TracerLine.Visible = false
local GreenTracer = Instance.new("Frame", OverlayGui) GreenTracer.AnchorPoint = Vector2.new(0.5, 0.5) GreenTracer.BackgroundColor3 = Color3.fromRGB(0, 255, 120) GreenTracer.BorderSizePixel = 0 GreenTracer.Visible = false

local FovCircleFrame = Instance.new("Frame", OverlayGui) FovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5) FovCircleFrame.BackgroundTransparency = 1
local fovUICorner = Instance.new("UICorner", FovCircleFrame) fovUICorner.CornerRadius = UDim.new(1, 0)
local fovUIStroke = Instance.new("UIStroke", FovCircleFrame) fovUIStroke.Thickness = 1.5 fovUIStroke.Transparency = 0.35

local KnifeTargetDot = Instance.new("Frame", OverlayGui) KnifeTargetDot.AnchorPoint = Vector2.new(0.5, 0.5) KnifeTargetDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) KnifeTargetDot.BorderSizePixel = 0 KnifeTargetDot.Visible = false
Instance.new("UICorner", KnifeTargetDot).CornerRadius = UDim.new(1, 0)

local KnifePredictionCircle = Instance.new("Frame", OverlayGui) KnifePredictionCircle.AnchorPoint = Vector2.new(0.5, 0.5) KnifePredictionCircle.BackgroundTransparency = 1 KnifePredictionCircle.Visible = false
Instance.new("UICorner", KnifePredictionCircle).CornerRadius = UDim.new(1, 0)
local PredStroke = Instance.new("UIStroke", KnifePredictionCircle) PredStroke.Thickness = 1.8 PredStroke.Color = Color3.fromRGB(240, 0, 0)

local function updateFovVisual()
    if not tieneCuchillo() then FovCircleFrame.Visible = false; return end
    if camera then
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FovCircleFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        FovCircleFrame.Size = UDim2.new(0, states.KnifeFovRadius * 2, 0, states.KnifeFovRadius * 2)
    end
    FovCircleFrame.Visible = states.KnifeShowFov and states.KnifeSilentAim
    fovUIStroke.Color = Color3.fromRGB(states.KnifeFovR, states.KnifeFovG, states.KnifeFovB)
end

local playerDataRemote = ReplicatedStorage:FindFirstChild("PlayerDataChanged", true)
if playerDataRemote then
    playerDataRemote.OnClientEvent:Connect(function(roundData)
        if type(roundData) == "table" then
            rolesPartida = {}
            for playerName, info in pairs(roundData) do
                if type(info) == "table" and info.Role then rolesPartida[playerName] = info.Role end
            end
        end
    end)
end

local function buscarMurderer()
    if rolesPartida[LocalPlayer.Name] == "Murderer" then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if rolesPartida[p.Name] == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            return p.Character
        end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
             if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p.Character
            end
        end
    end
    return nil
end

local globalRaycastParams = RaycastParams.new()
globalRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
globalRaycastParams.IgnoreWater = true

local function hasLineOfSight(targetChar)
    if not states.KnifeWallCheck then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    globalRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar, camera}
    return workspace:Raycast(LocalPlayer.Character.HumanoidRootPart.Position, targetChar.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position, globalRaycastParams) == nil
end

local function getClosestTargetInFOV()
    local near = nil
    local minFovDist = math.huge
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetHum = v.Character:FindFirstChildOfClass("Humanoid")
            if targetHum and targetHum.Health > 0 then
                local hrp = v.Character.HumanoidRootPart
                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if fovDist <= states.KnifeFovRadius and fovDist < minFovDist and hasLineOfSight(v.Character) then
                        minFovDist = fovDist
                        near = v
                    end
                end
             end
        end
    end
    return near
end

local function obtenerParteVisible(targetChar)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return targetChar:FindFirstChild("HumanoidRootPart") 
    end
    globalRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar, camera}
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    
    if targetChar:FindFirstChild("HumanoidRootPart") and not workspace:Raycast(origin, targetChar.HumanoidRootPart.Position - origin, globalRaycastParams) then
        return targetChar.HumanoidRootPart
    end
    if targetChar:FindFirstChild("Head") and not workspace:Raycast(origin, targetChar.Head.Position - origin, globalRaycastParams) then
        return targetChar.Head
    end
    if targetChar:FindFirstChild("LeftUpperLeg") and not workspace:Raycast(origin, targetChar.LeftUpperLeg.Position - origin, globalRaycastParams) then
        return targetChar.LeftUpperLeg
    end
    if targetChar:FindFirstChild("RightUpperLeg") and not workspace:Raycast(origin, targetChar.RightUpperLeg.Position - origin, globalRaycastParams) then
        return targetChar.RightUpperLeg
    end
    return targetChar:FindFirstChild("HumanoidRootPart")
end

-- ============================================================================
-- 🧠 MOTOR PISTOLA (MEJORADO CON ACELERACIÓN Y PING FLUIDO)
-- ============================================================================
local function getGunPredictedPosition(murdererChar)
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    local targetPart = obtenerParteVisible(murdererChar) or murdererChar.HumanoidRootPart
    local targetHum = murdererChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetPart then return nil end
    
    local dist = (myHRP.Position - targetPart.Position).Magnitude
    local ping = cachedPing or 0.125
    local bulletSpeed = 310
    local tiempoDeVuelo = (dist / bulletSpeed) + ping
    
    local multiH = states.HorizontalPrediction or 1.00
    local multiV = states.VerticalPrediction or 1.00
    
    local avatarScale = 1
    if targetHum then
        local heightScale = targetHum:FindFirstChild("HeightScale")
        if heightScale then
            avatarScale = math.clamp(heightScale.Value, 0.3, 1)
        end
    end
    
    -- 📉 Adaptación de Ping Fluida/Lineal (Sin saltos bruscos)
    if states.PingAdaptation then
        local factorCompensacion = 1 + (ping * 3.65) 
        multiH = multiH * factorCompensacion
    end
    
    local rangeMultiplier = 1.0
    if dist < 50 then
        rangeMultiplier = 0.10 + (0.90 * (dist / 50))
    else
        rangeMultiplier = math.max(0.85, 1.00 - ((dist - 50) * 0.003))
    end
    
    if gunVelocidadFiltrada.Magnitude < 1.0 then 
        if avatarScale < 0.75 and targetPart.Name == "HumanoidRootPart" then
            return targetPart.Position - Vector3.new(0, 0.5 * (1 - avatarScale), 0)
        end
        return targetPart.Position 
    end
    
    local dirToMe = (myHRP.Position - targetPart.Position).Unit
    local dot = gunVelocidadFiltrada.Unit:Dot(dirToMe)
    if dot > 0.25 then
        local threatFactor = 1 + (dot * 0.35)
        multiH = multiH * threatFactor
    end
    
    local posSimulada = targetPart.Position
    local velSimulada = gunVelocidadFiltrada * multiH * rangeMultiplier
    local totalSteps = states.SimDivider or 4
    local stepTime = tiempoDeVuelo / totalSteps
    
    local environmentParams = RaycastParams.new()
    environmentParams.FilterType = Enum.RaycastFilterType.Exclude
    environmentParams.FilterDescendantsInstances = {murdererChar, LocalPlayer.Character}
    local ceilingRay = workspace:Raycast(targetPart.Position, Vector3.new(0, 13, 0), environmentParams)
    local hasLowCeiling = ceilingRay ~= nil
    
    for i = 1, totalSteps do
        velSimulada = velSimulada * 0.88 
        posSimulada = posSimulada + Vector3.new(velSimulada.X * stepTime, 0, velSimulada.Z * stepTime)
    end
    
    local yOffset = 0
    local tSq = tiempoDeVuelo * tiempoDeVuelo
    if targetHum and targetHum.FloorMaterial == Enum.Material.Air then
        if states.JumpPrediction then
            if hasLowCeiling then
                yOffset = (gunVelocidadFiltrada.Y * tiempoDeVuelo) * 0.15 * multiV
            else
                yOffset = (gunVelocidadFiltrada.Y * tiempoDeVuelo) - (0.5 * workspace.Gravity * tSq)
                yOffset = yOffset * multiV * rangeMultiplier
            end
        else yOffset = gunVelocidadFiltrada.Y * tiempoDeVuelo * 0.20 * multiV end
    else 
        yOffset = 0 
    end
    
    yOffset = math.clamp(yOffset, -4.0, 6.0)
    
    -- 🚀 Integración Cinética de la Aceleración Filtrada (Evita overshoots drásticos)
    local accOffset = 0.5 * gunAceleracionFiltrada * tSq
    accOffset = Vector3.new(math.clamp(accOffset.X, -4, 4), math.clamp(accOffset.Y, -2, 3), math.clamp(accOffset.Z, -4, 4))
    
    local finalPos = Vector3.new(posSimulada.X, posSimulada.Y + yOffset, posSimulada.Z) + accOffset
    
    if avatarScale < 0.75 and targetPart.Name == "HumanoidRootPart" then
        finalPos = finalPos - Vector3.new(0, 0.6 * (1 - avatarScale), 0)
    end
    
    return finalPos
end

-- ============================================================================
-- 🧠 MOTOR CUCHILLO
-- ============================================================================
local function getPredictedPosition()
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = currentTarget.Character.HumanoidRootPart
    local targetHum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetHRP then return nil end
    
    local targetPart = obtenerParteVisible(currentTarget.Character) or targetHRP
    local dist = (myHRP.Position - targetPart.Position).Magnitude
    
    local pHoriz, pVert = tonumber(states.KnifePredHorizontal) or 1.5, tonumber(states.KnifePredVertical) or 1.0
    local ping = cachedPing or 0.06
    
    local timeToTarget = (dist / 245) * 1.05 + (ping * 1.12)
    
    if states.PingAdaptation then
        pHoriz = pHoriz * (1 + (ping * 3.10))
    end
    
    local rawVelocity = targetHRP.Velocity
    local maxSafeSpeed = 26
    if rawVelocity.Magnitude > maxSafeSpeed then
        rawVelocity = rawVelocity.Unit * maxSafeSpeed
    end
    
    if #knifeVelocityBuffer > 0 then
        local lastVel = knifeVelocityBuffer[#knifeVelocityBuffer]
        rawVelocity = lastVel:Lerp(rawVelocity, 0.25)
    end
    
    table.insert(knifeVelocityBuffer, rawVelocity)
    while #knifeVelocityBuffer > (states.PredInterval or 5) do table.remove(knifeVelocityBuffer, 1) end
    
    local sumVel = Vector3.new()
    for _, v in pairs(knifeVelocityBuffer) do sumVel = sumVel + v end
    knifeVelocidadFiltrada = sumVel / #knifeVelocityBuffer
    
    local velHorizontal = Vector3.new(knifeVelocidadFiltrada.X, 0, knifeVelocidadFiltrada.Z)
    local magH = velHorizontal.Magnitude
    
    if lastVelHorizontalBase.Magnitude > 0 and magH > 0 then
        local direccionDot = lastVelHorizontalBase.Unit:Dot(velHorizontal.Unit)
        if direccionDot < 0.2 then
            pHoriz = pHoriz * 0.35 
        end
    end
    lastVelHorizontalBase = velHorizontal
    
    local adaptiveDampener = 1
    if magH < 2 then
        adaptiveDampener = 0 
    elseif magH < 14 then 
        adaptiveDampener = math.clamp(magH / 14, 0.15, 1) 
    end
    
    local horizOffsetX = math.clamp(knifeVelocidadFiltrada.X * pHoriz * timeToTarget * adaptiveDampener, -35, 35)
    local horizOffsetZ = math.clamp(knifeVelocidadFiltrada.Z * pHoriz * timeToTarget * adaptiveDampener, -35, 35)
    
    local verticalOffset = 0
    local deVerdadEstaEnElAire = (targetHum and targetHum.FloorMaterial == Enum.Material.Air) or (math.abs(knifeVelocidadFiltrada.Y) > 3.5)
    
    if deVerdadEstaEnElAire then
        if knifeVelocidadFiltrada.Y > 0.5 then
            verticalOffset = knifeVelocidadFiltrada.Y * timeToTarget * 0.85
        else
            verticalOffset = knifeVelocidadFiltrada.Y * timeToTarget * 0.35
        end
    else
        verticalOffset = 0
    end
    
    local finalVertical = math.clamp(verticalOffset * pVert, -1.8, 12)
    local destinoPred = targetPart.Position + Vector3.new(horizOffsetX, finalVertical, horizOffsetZ)
    
    if states.KnifeWallCheck then
        local wallPathParams = RaycastParams.new()
        wallPathParams.FilterType = Enum.RaycastFilterType.Exclude
        wallPathParams.FilterDescendantsInstances = {currentTarget.Character, LocalPlayer.Character, camera}
        
        local golpePared = workspace:Raycast(targetPart.Position, destinoPred - targetPart.Position, wallPathParams)
        if golpePared then
            destinoPred = golpePared.Position - (magH > 0 and velHorizontal.Unit * 0.4 or Vector3.new())
        end
    end
    
    return destinoPred
end

-- ============================================================================
-- 🧱 LÓGICA INTERNA DISPARADOR AUTOMÁTICO
-- ============================================================================
local function dispararAlMurderer()
    local murdererChar = buscarMurderer()
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") then return end
    
    local character = LocalPlayer.Character 
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid then return end
    
    local arma = (character and character:FindFirstChild("Gun")) or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
    if not arma then return end
    
    local originCFrame = hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame
    local originPos = originCFrame.Position
    
    local targetPos = murdererChar.HumanoidRootPart.Position
    local predicted = getGunPredictedPosition(murdererChar)
    if predicted then targetPos = predicted end
    
    if states.WallCheck then
        globalRaycastParams.FilterDescendantsInstances = {character, murdererChar, camera}
        local clipCheck = workspace:Raycast(hrp.Position, originPos - hrp.Position, globalRaycastParams)
        if clipCheck then return end
        local pathCheck = workspace:Raycast(originPos, targetPos - originPos, globalRaycastParams)
        if pathCheck then return end
    end
    
    local yaEquipada = false
    if arma and arma:FindFirstChild("Shoot") then
        yaEquipada = (arma.Parent == character)
        if not yaEquipada then humanoid:EquipTool(arma) task.wait() end
        if predicted then
            local freshPredicted = getGunPredictedPosition(murdererChar)
            if freshPredicted then targetPos = freshPredicted end
        end
        arma.Shoot:FireServer(originCFrame, CFrame.new(targetPos))
    end
    if not yaEquipada then task.wait(0.01) if humanoid then humanoid:UnequipTools() end end
end

RunService.RenderStepped:Connect(function()
    updateFovVisual()
    if states.KnifeSilentAim and tieneCuchillo() then
        currentTarget = getClosestTargetInFOV()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = currentTarget.Character.HumanoidRootPart
            local factorEscala = math.clamp(38 / (camera.CFrame.Position - hrp.Position).Magnitude, 0.35, 1.0)
            KnifeTargetDot.Size = UDim2.new(0, math.round(6 * factorEscala), 0, math.round(6 * factorEscala))
            KnifePredictionCircle.Size = UDim2.new(0, math.round(11 * factorEscala), 0, math.round(11 * factorEscala))
            local screenPosTarget, onScreenTarget = camera:WorldToViewportPoint(hrp.Position)
            KnifeTargetDot.Position = UDim2.new(0, screenPosTarget.X, 0, screenPosTarget.Y)
            KnifeTargetDot.Visible = onScreenTarget and states.KnifeShowTargetDot
            local predictedPos = getPredictedPosition()
            if predictedPos then
                local screenPosPred, onScreenPred = camera:WorldToViewportPoint(predictedPos)
                KnifePredictionCircle.Position = UDim2.new(0, screenPosPred.X, 0, screenPosPred.Y)
                KnifePredictionCircle.Visible = onScreenPred and states.KnifeShowPredCircle
            else KnifePredictionCircle.Visible = false end
        else KnifeTargetDot.Visible = false; KnifePredictionCircle.Visible = false; currentTarget = nil end
    else KnifeTargetDot.Visible = false; KnifePredictionCircle.Visible = false; currentTarget = nil end
end)

-- ============================================================================
-- 🔗 METAMÉTODOS HOOKEADOS CON CACHÉ ANTI MICRO-STUTTERING
-- ============================================================================
local WeaponService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
local oldGetTargetPosition = WeaponService.GetTargetPosition
local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

local function ejecutarPrediccionCore()
    local currentTick = os.clock()
    -- Retorna el valor guardado si ya se calculó en este mismísimo frame
    if currentTick == lastHookTick and cachedHookPos ~= nil then
        return cachedHookPos
    end

    local finalCFrame = nil
    if states.KnifeSilentAim and tieneCuchillo() then 
        local success, pos = pcall(getPredictedPosition)
        if success and pos then finalCFrame = CFrame.new(pos) end 
    elseif states.GunSilentAim and tienePistola() then 
        local murderer = buscarMurderer()
        if murderer then
            local success, pos = pcall(getGunPredictedPosition, murderer)
            if success and pos then
                if states.WallCheck then
                    local character = LocalPlayer.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    local originCFrame = hrp and (hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame)
                    if originCFrame then
                        globalRaycastParams.FilterDescendantsInstances = {character, murderer, camera}
                        local clipCheck = workspace:Raycast(hrp.Position, originCFrame.Position - hrp.Position, globalRaycastParams)
                        local pathCheck = workspace:Raycast(originCFrame.Position, pos - originCFrame.Position, globalRaycastParams)
                        if not clipCheck and not pathCheck then finalCFrame = CFrame.new(pos) end
                    end
                else
                    finalCFrame = CFrame.new(pos)
                end
            end
        end
    end

    lastHookTick = currentTick
    cachedHookPos = finalCFrame
    return finalCFrame
end

WeaponService.GetTargetPosition = function(self, ...)
    local customCFrame = ejecutarPrediccionCore()
    if customCFrame then return customCFrame end
    return oldGetTargetPosition(self, ...)
end

WeaponService.GetMouseTargetCFrame = function(self, ...)
    local customCFrame = ejecutarPrediccionCore()
    if customCFrame then return customCFrame end
    return oldGetMouseTargetCFrame(self, ...)
end

-- ============================================================================
-- 🔄 BUCLE PRINCIPAL (ESTABILIZACIÓN DELTA DE VELOCIDAD Y FILTRADOS)
-- ============================================================================
RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    local ocultarPorSmartVisibility = states.SmartVisibility and not tienePistola()
    if ShootButton then if ocultarPorSmartVisibility then ShootButton.Visible = false else ShootButton.Visible = states.ShowShootButton end end
    if rolesPartida[LocalPlayer.Name] == "Murderer" or ocultarPorSmartVisibility then TracerLine.Visible = false; GreenTracer.Visible = false; return end
    
    local murdererChar = buscarMurderer()
    if murdererChar and murdererChar:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
        
        -- 📈 Extracción de velocidad ultrasuave basada en Delta de Posición manual
        local posActual = murdererChar.HumanoidRootPart.Position
        local velCalculada = murdererChar.HumanoidRootPart.Velocity
        
        if ultimaPosReal and dt > 0 then
            local velDelta = (posActual - ultimaPosReal) / dt
            -- Ignora saltos de teletransportación o fallas físicas extremas del mapa
            if velDelta.Magnitude < 65 then
                velCalculada = velDelta
            end
        end
        ultimaPosReal = posActual

        table.insert(gunVelocityBuffer, velCalculada)
        while #gunVelocityBuffer > (states.PredInterval or 5) do table.remove(gunVelocityBuffer, 1) end
        
        local sumX, sumY, sumZ, totalWeight = 0, 0, 0, 0
        for idx, vel in ipairs(gunVelocityBuffer) do
            local weight = idx 
            sumX = sumX + (vel.X * weight) 
            sumY = sumY + (vel.Y * weight) 
            sumZ = sumZ + (vel.Z * weight) 
            totalWeight = totalWeight + weight
        end
        
        local antiguaVelocidad = gunVelocidadFiltrada
        gunVelocidadFiltrada = Vector3.new(sumX / totalWeight, sumY / totalWeight, sumZ / totalWeight)
        
        if dt > 0 then 
            gunAceleracionFiltrada = gunAceleracionFiltrada:Lerp((gunVelocidadFiltrada - antiguaVelocidad) / dt, 0.22) 
        end

        if states.TracerPrediction then
            local predictedPos = getGunPredictedPosition(murdererChar)
            if predictedPos then
                ultimoPosTarget = ultimoPosTarget:Lerp(predictedPos, states.TracerSpeed or 0.85)
                local screenPos, onScreen = camera:WorldToViewportPoint(ultimoPosTarget)
                if onScreen then
                    local inicioTracer = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    local vectorDistancia = Vector2.new(screenPos.X, screenPos.Y) - inicioTracer
                    TracerLine.Size = UDim2.new(0, vectorDistancia.Magnitude, 0, 1.2)
                    TracerLine.Position = UDim2.new(0, inicioTracer.X + vectorDistancia.X / 2, 0, inicioTracer.Y + vectorDistancia.Y / 2)
                    TracerLine.Rotation = math.deg(math.atan2(vectorDistancia.Y, vectorDistancia.X))
                    TracerLine.Visible = true
                else TracerLine.Visible = false end
            else TracerLine.Visible = false end
        else TracerLine.Visible = false end
        
        if states.SeeLeadTime then
            local factorLead = states.LeadTimePrediction or 0.30
            local handPos = getHandPosition()
            if handPos then
                ultimoPuntoLead = ultimoPuntoLead:Lerp(murdererChar.HumanoidRootPart.Position + (gunVelocidadFiltrada * (factorLead * 1.1)), 0.85)
                local screenHandPos, handOnScreen = camera:WorldToViewportPoint(handPos)
                local screenTargetPos, targetOnScreen = camera:WorldToViewportPoint(ultimoPuntoLead)
                if handOnScreen and targetOnScreen then
                    local vectorMano = Vector2.new(screenTargetPos.X, screenTargetPos.Y) - Vector2.new(screenHandPos.X, screenHandPos.Y)
                    GreenTracer.Size = UDim2.new(0, vectorMano.Magnitude, 0, 1.1)
                    GreenTracer.Position = UDim2.new(0, screenHandPos.X + vectorMano.X / 2, 0, screenHandPos.Y + vectorMano.Y / 2)
                    GreenTracer.Rotation = math.deg(math.atan2(vectorMano.Y, vectorMano.X))
                    GreenTracer.Visible = true
                else GreenTracer.Visible = false end
            else GreenTracer.Visible = false end
        else GreenTracer.Visible = false end
    else 
        TracerLine.Visible = false; 
        GreenTracer.Visible = false;
        ultimaPosReal = nil -- Reinicia la posición si no hay un objetivo activo
    end
end)

-- ============================================================================
-- 🧱 INTERFAZ FÍSICA BOTÓN EN PANTALLA (SHOOT)
-- ============================================================================
ShootButton = Instance.new("TextButton", OverlayGui)
ShootButton.Size = UDim2.new(0, states.ButtonSize, 0, states.ButtonSize)
ShootButton.Position = UDim2.new(states.ButtonScaleX, states.ButtonOffsetX, states.ButtonScaleY, states.ButtonOffsetY)
ShootButton.BackgroundColor3 = COLOR_VOID_BASE ShootButton.Text = "" ShootButton.AutoButtonColor = false ShootButton.Visible = states.ShowShootButton ShootButton.Active = true ShootButton.ZIndex = 10
Instance.new("UICorner", ShootButton).CornerRadius = UDim.new(0, 22)
ShootStroke = Instance.new("UIStroke", ShootButton) ShootStroke.Thickness = 1.2 ShootStroke.Color = COLOR_STROKE_BASE ShootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local ButtonImageLabel = Instance.new("ImageLabel", ShootButton) 
ButtonImageLabel.Size = UDim2.new(0.52, 0, 0.52, 0) 
ButtonImageLabel.Position = UDim2.new(0.5, 0, 0.47, 0) 
ButtonImageLabel.AnchorPoint = Vector2.new(0.5, 0.5) 
ButtonImageLabel.BackgroundTransparency = 1 
ButtonImageLabel.Image = "rbxassetid://12471956230" 
ButtonImageLabel.ZIndex = 12 
ButtonImage = ButtonImageLabel

local ButtonTextLabel = Instance.new("TextLabel", ShootButton) 
ButtonTextLabel.Size = UDim2.new(1, 0, 0.25, 0) 
ButtonTextLabel.Position = UDim2.new(0, 0, 0.76, 0) 
ButtonTextLabel.BackgroundTransparency = 1 
ButtonTextLabel.Text = "SHOOT" 
ButtonTextLabel.TextColor3 = Color3.fromRGB(240, 240, 240) 
ButtonTextLabel.Font = Enum.Font.GothamBold 
ButtonTextLabel.TextSize = 13 
ButtonTextLabel.ZIndex = 12 
ButtonText = ButtonTextLabel

aplicarOpacidadGlobal(states.ButtonOpacity)
local shootDragStart, shootStartPos, shootDraggingInput local haSidoArrastrado = false local tweenInfoGlow = TweenInfo.new(0.14, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

ShootButton.InputBegan:Connect(function(input)
     if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        shootDraggingInput = input shootDragStart = input.Position shootStartPos = ShootButton.Position haSidoArrastrado = false
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_GLOW}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_GLOW, Thickness = 1.6}):Play()
        dispararAlMurderer()
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == shootDraggingInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - shootDragStart if delta.Magnitude > 22 then haSidoArrastrado = true end
        if not states.LockButton then ShootButton.Position = UDim2.new(shootStartPos.X.Scale, shootStartPos.X.Offset + delta.X, shootStartPos.Y.Scale, shootStartPos.Y.Offset + delta.Y) end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input == shootDraggingInput then
        shootDraggingInput = nil
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_BASE}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_BASE, Thickness = 1.2}):Play()
        if haSidoArrastrado then
            states.ButtonScaleX = ShootButton.Position.X.Scale states.ButtonOffsetX = ShootButton.Position.X.Offset states.ButtonScaleY = ShootButton.Position.Y.Scale states.ButtonOffsetY = ShootButton.Position.Y.Offset saveButtonConfig()
        end
    end
end)

warn([[
  _  _  _  _  _                     _    _         _       
 | |/ / (_)| | |                   | |  | |       | |      
 | ' /   _ | | |  ___  _ __        | |__| |_   _  | |__    
 |  <   | || | | / _ \| '__|       |  __  | | | | | '_ \   
 | . \  | || | ||  __/| |          | |  | | |_| | | |_) |  
 |_|\_\ |_||_|_| \___||_|          |_|  |_|\__,_| |_.__/   
                                                           
                ____   __     __                           
               |  _ \  \ \   / /                           
               | |_) |  \ \_/ /                            
               |  _ <    \   /                             
               | |_) |    | |                              
               |____/     |_|                              
                                                           
  _____                 _                                  
 |  __ \               | |                                 
 | |__) | __ _   ___   | |  ___                            
 |  ___/ / _` | / _ \  | | / _ \                           
 | |    | (_| || (_) | | || (_) |                          
 |_|     \__,_| \___/  |_| \___/                           
]])

return KillerHub
