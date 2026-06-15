-- ============================================================================
-- 🚀 KILLER HUB - SCRIPT EJECUTOR OPTIMIZADO (LOGICA ANTI-MISS V4.0 NITRO-AIM)
-- ============================================================================

-- 1️⃣ Cargar la librería base desde su link oficial
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/Killer-Hub-test/main/Test.lua"))()

-- 2️⃣ Acceso directo a las pestañas de la nueva API
local Visuals  = KillerHub.Tabs.Visuals
local Murder   = KillerHub.Tabs.Murder
local Sheriff  = KillerHub.Tabs.Sheriff
local Extras   = KillerHub.Tabs.Extras
local Settings = KillerHub.Tabs.Settings

-- Estados locales unificados del motor de combate
local states = {
    -- Ajustes Sheriff (Calibración milimétrica)
    TracerPrediction = false,
    JumpPrediction = false,
    TracerSpeed = 0.85,
    HorizontalPrediction = 1.00, -- Por defecto en 100
    VerticalPrediction = 1.00,   -- Por defecto en 100
    ShowShootButton = false,
    LockButton = false,
    ButtonSize = 100,
    ButtonOpacity = 0.25,
    WallCheck = false,
    SeeLeadTime = false,
    LeadTimePrediction = 0.30,
    SmartVisibility = false,
    
    -- Coordenadas guardadas para el botón físico
    ButtonScaleX = 0.80,
    ButtonOffsetX = 0,
    ButtonScaleY = 0.45,
    ButtonOffsetY = 0,
    
    -- Ajustes Murder
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

-- Paleta satinada premium para UI manuales
local COLOR_VOID_BASE = Color3.fromRGB(12, 4, 22)
local COLOR_VOID_GLOW = Color3.fromRGB(42, 14, 75)
local COLOR_STROKE_BASE = Color3.fromRGB(24, 8, 42)
local COLOR_STROKE_GLOW = Color3.fromRGB(140, 45, 255)

-- Sistema avanzado de persistencia JSON
local HttpService = game:GetService("HttpService")
local FILE_NAME = "KillerHub_Button_Config.json"

local function saveButtonConfig()
    if writefile then
        local data = {
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
            if result.TracerPrediction ~= nil then states.TracerPrediction = result.TracerPrediction end
            if result.JumpPrediction ~= nil then states.JumpPrediction = result.JumpPrediction end
            states.TracerSpeed = result.TracerSpeed or 0.85
            states.HorizontalPrediction = result.HorizontalPrediction or 1.00
            states.VerticalPrediction = result.VerticalPrediction or 1.00
            if result.ShowShootButton ~= nil then states.ShowShootButton = result.ShowShootButton end
            if result.LockButton ~= nil then states.LockButton = result.LockButton end
            if result.WallCheck ~= nil then states.WallCheck = result.WallCheck end
            if result.SeeLeadTime ~= nil then states.SeeLeadTime = result.SeeLeadTime end
            if result.SmartVisibility ~= nil then states.SmartVisibility = result.SmartVisibility end
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

local ShootButton
local ShootStroke
local ButtonImage
local ButtonText

local function aplicarOpacidadGlobal(transparencia)
    local tClamped = math.clamp(transparencia, 0, 0.95)
    if ShootButton then ShootButton.BackgroundTransparency = tClamped end
    if ShootStroke then ShootStroke.Transparency = tClamped end
    if ButtonImage then ButtonImage.ImageTransparency = tClamped end
    if ButtonText then ButtonText.TextTransparency = tClamped end
end

local function tieneCuchillo()
    local character = game:GetService("Players").LocalPlayer.Character
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    return (character and character:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
end

local function tienePistola()
    local character = game:GetService("Players").LocalPlayer.Character
    local backpack = game:GetService("Players").LocalPlayer:FindFirstChild("Backpack")
    return (character and character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun"))
end

-- ============================================================================
-- 🧱 CONSTRUCCIÓN DE COMPONENTES INTERFAZ
-- ============================================================================

Sheriff:CreateSection("Target Prediction")
Sheriff:CreateToggle("S_TracerPrediction", "Prediction Guide", function(state) states.TracerPrediction = state saveButtonConfig() end)
Sheriff:CreateToggle("S_JumpPrediction", "Jump Prediction", function(state) states.JumpPrediction = state saveButtonConfig() end)
Sheriff:CreateSlider("S_TracerSpeed", "Tracer Speed Tuning", 25, 125, function(val) states.TracerSpeed = val / 100 saveButtonConfig() end)
Sheriff:CreateSlider("S_HorizontalPred", "Horizontal Tuning", 0, 150, function(val) states.HorizontalPrediction = val / 100 saveButtonConfig() end)
Sheriff:CreateSlider("S_VerticalPred", "Vertical Tuning", 0, 125, function(val) states.VerticalPrediction = val / 100 saveButtonConfig() end)

Sheriff:CreateSection("Combat Filters")
Sheriff:CreateToggle("S_WallCheck", "Wall Check", function(state) states.WallCheck = state saveButtonConfig() end)
Sheriff:CreateToggle("S_SeeLeadTime", "See Lead Time", function(state) states.SeeLeadTime = state saveButtonConfig() end)
Sheriff:CreateSlider("S_LeadTimePred", "Lead Multiplier", 0, 100, function(val) states.LeadTimePrediction = val / 100 saveButtonConfig() end)

Sheriff:CreateSection("Button Settings")
Sheriff:CreateToggle("S_ShowShootButton", "Show Button", function(state) states.ShowShootButton = state if ShootButton then ShootButton.Visible = state end saveButtonConfig() end)
Sheriff:CreateToggle("S_SmartVisibility", "Smart Visibility", function(state) states.SmartVisibility = state saveButtonConfig() end)
Sheriff:CreateToggle("S_LockButton", "Lock Position", function(state) states.LockButton = state saveButtonConfig() end)
Sheriff:CreateSlider("S_ButtonSize", "Button Size", 50, 180, function(val) states.ButtonSize = val if ShootButton then ShootButton.Size = UDim2.new(0, val, 0, val) end saveButtonConfig() end)
Sheriff:CreateSlider("S_ButtonOpacity", "Button Opacity", 0, 100, function(val) local targetTransparency = 1 - (val / 100) states.ButtonOpacity = targetTransparency aplicarOpacidadGlobal(targetTransparency) saveButtonConfig() end)

-- 🔪 PESTAÑA MURDER
Murder:CreateSection("Knife Silent Aim")
Murder:CreateToggle("M_SilentActive", "Silent Aim Activo", function(state) states.KnifeSilentAim = state saveButtonConfig() end)
Murder:CreateToggle("M_WallCheck", "Filtro de Paredes (Wall Check)", function(state) states.KnifeWallCheck = state saveButtonConfig() end)
Murder:CreateSlider("M_FovRadius", "Radio de Captura (FOV)", 30, 350, function(val) states.KnifeFovRadius = val saveButtonConfig() end)

Murder:CreateSection("Ajustes de Predicción")
Murder:CreateSlider("M_PredHoriz", "Intensidad Pred. Horizontal", 0, 320, function(val) states.KnifePredHorizontal = val / 100 saveButtonConfig() end)
Murder:CreateSlider("M_PredVert", "Intensidad Pred. Vertical", 0, 320, function(val) states.KnifePredVertical = val / 100 saveButtonConfig() end)

Murder:CreateSection("Configuración Visual Knife FOV")
Murder:CreateToggle("M_ShowFovCircle", "Mostrar Círculo FOV", function(state) states.KnifeShowFov = state saveButtonConfig() end)
Murder:CreateToggle("M_ShowTargetDot", "Mostrar Punto Target", function(state) states.KnifeShowTargetDot = state saveButtonConfig() end)
Murder:CreateToggle("M_ShowPredCircle", "Mostrar Círculo Predicción", function(state) states.KnifeShowPredCircle = state saveButtonConfig() end)
Murder:CreateColorPicker("KnifeFovColor", "Color Dinámico del FOV", Color3.fromRGB(states.KnifeFovR, states.KnifeFovG, states.KnifeFovB), function(colorElegido)
    states.KnifeFovR = math.floor(colorElegido.R * 255)
    states.KnifeFovG = math.floor(colorElegido.G * 255)
    states.KnifeFovB = math.floor(colorElegido.B * 255)
    saveButtonConfig()
end)

-- 🚀 PESTAÑA EXTRAS
Extras:CreateSection("Extras de Rendimiento")

-- ⚙️ PESTAÑA SETTINGS
Settings:CreateSection("Configuración del Framework")
Settings:CreateKeybind("MenuToggle", "Tecla para Ocultar Hub", Enum.KeyCode.RightControl, function(key) end)

-- ============================================================================
-- LÓGICA DE COMBATE AUXILIAR Y RENDERIZADOS
-- ============================================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local rolesPartida = {}
local ultimoPosTarget = Vector3.new()
local ultimoPuntoLead = Vector3.new()
local gunVelocidadFiltrada = Vector3.new()
local gunAceleracionFiltrada = Vector3.new()
local knifeVelocidadFiltrada = Vector3.new()
local lastKnifeTarget = nil
local lastGunTarget = nil
local camera = workspace.CurrentCamera
local currentTarget = nil

-- Hilo asíncrono secundario para la actualización estática de Ping (Optimización Móvil FPS)
local cachedPing = 0.125 -- Base inicial optimizada para conexiones móviles altas (+125ms)
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            cachedPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
    end
end)

if CoreGui:FindFirstChild("KillerHub_OverlayEngine") then
    CoreGui.KillerHub_OverlayEngine:Destroy()
end

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "KillerHub_OverlayEngine"
OverlayGui.IgnoreGuiInset = true
OverlayGui.Parent = CoreGui

local TracerLine = Instance.new("Frame", OverlayGui)
TracerLine.Name = "ShootPredictionTracer"
TracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
TracerLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TracerLine.BorderSizePixel = 0
TracerLine.Visible = false
TracerLine.ZIndex = 5

local GreenTracer = Instance.new("Frame", OverlayGui)
GreenTracer.Name = "LeadTimeTracer"
GreenTracer.AnchorPoint = Vector2.new(0.5, 0.5)
GreenTracer.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
GreenTracer.BorderSizePixel = 0
GreenTracer.Visible = false
GreenTracer.ZIndex = 5

local FovCircleFrame = Instance.new("Frame", OverlayGui)
FovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircleFrame.BackgroundTransparency = 1

local fovUICorner = Instance.new("UICorner", FovCircleFrame)
fovUICorner.CornerRadius = UDim.new(1, 0)

local fovUIStroke = Instance.new("UIStroke", FovCircleFrame)
fovUIStroke.Thickness = 1.5
fovUIStroke.Transparency = 0.35

local KnifeTargetDot = Instance.new("Frame", OverlayGui)
KnifeTargetDot.Name = "KnifeTargetDot"
KnifeTargetDot.AnchorPoint = Vector2.new(0.5, 0.5)
KnifeTargetDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KnifeTargetDot.BorderSizePixel = 0
KnifeTargetDot.Visible = false
KnifeTargetDot.ZIndex = 15

local DotCorner = Instance.new("UICorner", KnifeTargetDot)
DotCorner.CornerRadius = UDim.new(1, 0)

local KnifePredictionCircle = Instance.new("Frame", OverlayGui)
KnifePredictionCircle.Name = "KnifePredictionCircle"
KnifePredictionCircle.AnchorPoint = Vector2.new(0.5, 0.5)
KnifePredictionCircle.BackgroundTransparency = 1
KnifePredictionCircle.Visible = false
KnifePredictionCircle.ZIndex = 16

local PredCorner = Instance.new("UICorner", KnifePredictionCircle)
PredCorner.CornerRadius = UDim.new(1, 0)

local PredStroke = Instance.new("UIStroke", KnifePredictionCircle)
PredStroke.Thickness = 1.8
PredStroke.Color = Color3.fromRGB(240, 0, 0)
PredStroke.Parent = KnifePredictionCircle

local function updateFovVisual()
    if not tieneCuchillo() then FovCircleFrame.Visible = false; return end
    if camera then
        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FovCircleFrame.Position = UDim2.new(0, center.X, 0, center.Y)
        local size = states.KnifeFovRadius * 2
        FovCircleFrame.Size = UDim2.new(0, size, 0, size)
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

-- 🛠️ OPTIMIZACIÓN: Instancia única de RaycastParams declarada globalmente (Previene micro-lag móvil)
local globalRaycastParams = RaycastParams.new()
globalRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
globalRaycastParams.IgnoreWater = true

local function isMurdererVisible(murdererChar)
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character then return false end
    
    local origin = camera and camera.CFrame.Position or (LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head.Position)
    if not origin then return false end
    
    globalRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, murdererChar, camera}
    
    local puntosEscanear = {
        murdererChar.HumanoidRootPart.Position,
        murdererChar:FindFirstChild("Head") and murdererChar.Head.Position,
        murdererChar:FindFirstChild("LeftFoot") and murdererChar.LeftFoot.Position,
        murdererChar:FindFirstChild("RightFoot") and murdererChar.RightFoot.Position
    }
    
    for _, puntoDestino in pairs(puntosEscanear) do
        if puntoDestino then
            local resultadoRay = Workspace:Raycast(origin, puntoDestino - origin, globalRaycastParams)
            if not resultadoRay then
                return true
            end
        end
    end
    
    return false
end

local function hasLineOfSight(targetChar)
    if not states.KnifeWallCheck then return true end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local targetPos = targetChar.HumanoidRootPart.Position
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar, camera}
    return workspace:Raycast(origin, targetPos - origin, raycastParams) == nil
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

local function getHandPosition()
    local character = LocalPlayer.Character
    if character then
        local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
        if hand then return hand.Position end
        return character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
   end
    return nil
end

-- ============================================================================
-- 🎯 MOTOR DE PREDICCIÓN CON ESCALAMIENTO POR RANGOS (CALIBRADO PARA PING +125ms)
-- ============================================================================
local function getGunPredictedPosition(murdererChar)
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = murdererChar.HumanoidRootPart
    local targetHum = murdererChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetHRP then return nil end
    
    local dist = (myHRP.Position - targetHRP.Position).Magnitude
    local ping = cachedPing or 0.125
    
    local tiempoDeVuelo = (dist / 310) + (ping * 1.12)
    
    local multiH = states.HorizontalPrediction or 1.00
    local multiV = states.VerticalPrediction or 1.00
    
    local rangeMultiplier = 1.0
    local accelerationWeight = 1.0
    
    if dist < 14 then
        rangeMultiplier = math.clamp(dist / 14, 0.05, 0.40)
        accelerationWeight = 0.0
    elseif dist >= 14 and dist < 38 then
        rangeMultiplier = 1.02
        accelerationWeight = 0.50
    else
        rangeMultiplier = 1.30
        accelerationWeight = 0.65
        
        if gunVelocidadFiltrada.Magnitude > 0.1 then
            local desaceleracionBrusca = gunAceleracionFiltrada.Magnitude
            if desaceleracionBrusca > 15 then
                rangeMultiplier = rangeMultiplier * math.clamp(20 / desaceleracionBrusca, 0.45, 1.0)
            end
        end
    end
    
    local tSq = tiempoDeVuelo * tiempoDeVuelo
    local xOffset = (gunVelocidadFiltrada.X * tiempoDeVuelo) + (0.5 * gunAceleracionFiltrada.X * tSq * accelerationWeight)
    local zOffset = (gunVelocidadFiltrada.Z * tiempoDeVuelo) + (0.5 * gunAceleracionFiltrada.Z * tSq * accelerationWeight)
    
    local horizOffset = Vector3.new(xOffset, 0, zOffset) * multiH * rangeMultiplier
    
    local maxOffsetRadius = math.clamp(dist * 0.5, 2.0, 20)
    if horizOffset.Magnitude > maxOffsetRadius then
        horizOffset = horizOffset.Unit * maxOffsetRadius
    end
    
    local yOffset = 0
    if targetHum and targetHum.FloorMaterial == Enum.Material.Air then
        if states.JumpPrediction then
            yOffset = (gunVelocidadFiltrada.Y * tiempoDeVuelo) - (0.5 * 196.2 * tSq)
            yOffset = yOffset * multiV * rangeMultiplier
        else
            yOffset = gunVelocidadFiltrada.Y * tiempoDeVuelo * 0.35 * multiV * rangeMultiplier
        end
    else
        yOffset = gunVelocidadFiltrada.Y * tiempoDeVuelo * multiV * 0.15 * rangeMultiplier
    end
    
    yOffset = math.clamp(yOffset, -8, 10)
     
    return targetHRP.Position + Vector3.new(horizOffset.X, yOffset, horizOffset.Z)
end

-- 🔥 ACCIÓN DE DISPARO SIN RETRASO REDISEÑADA COMPLETAMENTE SÍNCRONA
local function dispararAlMurderer()
    local murdererChar = buscarMurderer()
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") or (states.WallCheck and not isMurdererVisible(murdererChar)) then return end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local arma = (character and character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun"))
    
    if arma and humanoid and character:FindFirstChild("HumanoidRootPart") then
        local yaEquipada = (arma.Parent == character)
        if not yaEquipada then 
            humanoid:EquipTool(arma) 
            task.wait()
        end
        
        if arma and arma:FindFirstChild("Shoot") then
            local originCFrame = character.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") and character.HumanoidRootPart.GunRaycastAttachment.WorldCFrame or character.HumanoidRootPart.CFrame
            
            local targetPos = murdererChar.HumanoidRootPart.Position
            if states.TracerPrediction then
                local predicted = getGunPredictedPosition(murdererChar)
                if predicted then targetPos = predicted end
            end
            
            arma.Shoot:FireServer(originCFrame, CFrame.new(targetPos))
        end
        if not yaEquipada then
            task.wait(0.01)
            if humanoid then humanoid:UnequipTools() end
        end
    end
end

-- ============================================================================
-- MOTOR DE PREDICCIÓN DE CUCHILLO ESTABILIZADO
-- ============================================================================
local function getPredictedPosition()
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = currentTarget.Character.HumanoidRootPart
    local targetHum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetHRP then return nil end
    
    local dist = (myHRP.Position - targetHRP.Position).Magnitude
    local pHoriz, pVert = tonumber(states.KnifePredHorizontal) or 1.5, tonumber(states.KnifePredVertical) or 1.0
    local ping = cachedPing or 0.06
    local timeToTarget = (dist / 245) + (ping * 1.12)
    
    if not lastKnifeTarget or lastKnifeTarget ~= currentTarget then
        lastKnifeTarget = currentTarget
        knifeVelocidadFiltrada = targetHRP.Velocity
    else
        knifeVelocidadFiltrada = knifeVelocidadFiltrada:Lerp(targetHRP.Velocity, 0.11)
    end
    
    local velHorizontal = Vector3.new(knifeVelocidadFiltrada.X, 0, knifeVelocidadFiltrada.Z)
    local magH = velHorizontal.Magnitude
    local adaptiveDampener = 1
    
    if magH < 14 then
        adaptiveDampener = math.clamp(magH / 14, 0.35, 1)
    end
    
    local horizOffsetX = math.clamp(knifeVelocidadFiltrada.X * pHoriz * timeToTarget * adaptiveDampener, -35, 35)
    local horizOffsetZ = math.clamp(knifeVelocidadFiltrada.Z * pHoriz * timeToTarget * adaptiveDampener, -35, 35)
    
    local verticalOffset = (targetHum and targetHum.FloorMaterial == Enum.Material.Air) and ((knifeVelocidadFiltrada.Y * timeToTarget) - (0.5 * 196.2 * math.pow(timeToTarget, 2))) or (knifeVelocidadFiltrada.Y * timeToTarget * 0.55)
    verticalOffset = math.clamp(verticalOffset * pVert, -12, 22)
    
    local rawPrediction = targetHRP.Position + Vector3.new(horizOffsetX, verticalOffset, horizOffsetZ)
    
    local floorParams = RaycastParams.new()
    floorParams.FilterType = Enum.RaycastFilterType.Exclude
    floorParams.FilterDescendantsInstances = {currentTarget.Character, LocalPlayer.Character, camera}
    local floorRay = workspace:Raycast(targetHRP.Position, Vector3.new(0, -22, 0), floorParams)
    if floorRay and rawPrediction.Y < (floorRay.Position.Y + 2.45) then rawPrediction = Vector3.new(rawPrediction.X, floorRay.Position.Y + 2.45, rawPrediction.Z) end
    
    return rawPrediction
end

RunService.RenderStepped:Connect(function()
    updateFovVisual()
    if states.KnifeSilentAim and tieneCuchillo() then
        currentTarget = getClosestTargetInFOV()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = currentTarget.Character.HumanoidRootPart
            local distAlTarget = (camera.CFrame.Position - hrp.Position).Magnitude
            local factorEscala = math.clamp(38 / distAlTarget, 0.35, 1.0)
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

local WeaponService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService"))
local oldGetTargetPosition = WeaponService.GetTargetPosition
WeaponService.GetTargetPosition = function(self, ...)
    if states.KnifeSilentAim and tieneCuchillo() then local success, pos = pcall(getPredictedPosition);
    if success and pos then return CFrame.new(pos) end end
    return oldGetTargetPosition(self, ...)
end
local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
WeaponService.GetMouseTargetCFrame = function(self, ...)
    if states.KnifeSilentAim and tieneCuchillo() then local success, pos = pcall(getPredictedPosition);
    if success and pos then return CFrame.new(pos) end end
    return oldGetMouseTargetCFrame(self, ...)
end

-- ============================================================================
-- HEARTBEAT ENGINE: TRACKING CINEMÁTICO INTEGRAL & FILTRO ANTI-LAG
-- ============================================================================
local lastRealPosGun = Vector3.new()

RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    local tieneLaPistola = tienePistola()
    local ocultarPorSmartVisibility = states.SmartVisibility and not tieneLaPistola

    if ShootButton then
        if ocultarPorSmartVisibility then ShootButton.Visible = false else ShootButton.Visible = states.ShowShootButton end
    end
    
    if rolesPartida[LocalPlayer.Name] == "Murderer" or ocultarPorSmartVisibility then
        TracerLine.Visible = false; GreenTracer.Visible = false; return
    end
    
    local murdererChar = buscarMurderer()
    if murdererChar and character and character:FindFirstChild("HumanoidRootPart") then
        
        local realVelocity = Vector3.new()
        if dt > 0 then
            realVelocity = (murdererChar.HumanoidRootPart.Position - lastRealPosGun) / dt
        end
        lastRealPosGun = murdererChar.HumanoidRootPart.Position

        local rawVelocity = murdererChar.HumanoidRootPart.Velocity
        
        if rawVelocity.Magnitude > 5 and realVelocity.Magnitude < 2 then
            rawVelocity = Vector3.new(0, rawVelocity.Y, 0)
        end

        if not lastGunTarget or lastGunTarget ~= murdererChar then
            lastGunTarget = murdererChar
            gunVelocidadFiltrada = rawVelocity
            gunAceleracionFiltrada = Vector3.new()
        else
            local esCambioBrusco = (gunVelocidadFiltrada - rawVelocity).Magnitude > 12
            local lerpFactor = esCambioBrusco and 0.35 or 0.15
            
            local antiguaVelocidad = gunVelocidadFiltrada
            gunVelocidadFiltrada = gunVelocidadFiltrada:Lerp(rawVelocity, lerpFactor)
            
            if dt > 0 then
                local rawAcceleration = (gunVelocidadFiltrada - antiguaVelocidad) / dt
                gunAceleracionFiltrada = gunAceleracionFiltrada:Lerp(rawAcceleration, 0.22)
            end
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
        
        -- Lead Time Visual Suave
        if states.SeeLeadTime then
            local factorLead = states.LeadTimePrediction or 0.30
            local puntoLeadRaw
            
            if factorLead == 0 then
                puntoLeadRaw = murdererChar.HumanoidRootPart.Position
            else
                puntoLeadRaw = murdererChar.HumanoidRootPart.Position + (gunVelocidadFiltrada * (factorLead * 1.1))
            end
            
            if ultimoPuntoLead == Vector3.new() then ultimoPuntoLead = puntoLeadRaw end
            ultimoPuntoLead = ultimoPuntoLead:Lerp(puntoLeadRaw, 0.85)
            
            local handPos = getHandPosition()
            if handPos then
                local screenHandPos, handOnScreen = camera:WorldToViewportPoint(handPos)
                local screenTargetPos, targetOnScreen = camera:WorldToViewportPoint(ultimoPuntoLead)
                 if handOnScreen and targetOnScreen then
                    local inicioMano = Vector2.new(screenHandPos.X, screenHandPos.Y)
                    local vectorMano = Vector2.new(screenTargetPos.X, screenTargetPos.Y) - inicioMano
                    GreenTracer.Size = UDim2.new(0, vectorMano.Magnitude, 0, 1.1)
                    GreenTracer.Position = UDim2.new(0, inicioMano.X + vectorMano.X / 2, 0, inicioMano.Y + vectorMano.Y / 2)
                    GreenTracer.Rotation = math.deg(math.atan2(vectorMano.Y, vectorMano.X))
                    GreenTracer.Visible = true
                else GreenTracer.Visible = false end
            else GreenTracer.Visible = false end
        else GreenTracer.Visible = false end
    else 
        TracerLine.Visible = false
        GreenTracer.Visible = false
        ultimoPuntoLead = Vector3.new()
    end
end)

-- Interfaz física del botón Shoot
ShootButton = Instance.new("TextButton", OverlayGui)
ShootButton.Name = "PremiumSheriffButton"
ShootButton.Size = UDim2.new(0, states.ButtonSize, 0, states.ButtonSize)
ShootButton.Position = UDim2.new(states.ButtonScaleX, states.ButtonOffsetX, states.ButtonScaleY, states.ButtonOffsetY)
ShootButton.BackgroundColor3 = COLOR_VOID_BASE
ShootButton.Text = ""
ShootButton.AutoButtonColor = false
ShootButton.Visible = states.ShowShootButton
ShootButton.Active = true
ShootButton.ZIndex = 10

ShootCorner = Instance.new("UICorner", ShootButton)
ShootCorner.CornerRadius = UDim.new(0, 22)

ShootStroke = Instance.new("UIStroke", ShootButton)
ShootStroke.Thickness = 1.2
ShootStroke.Color = COLOR_STROKE_BASE
ShootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

ButtonImageLabel = Instance.new("ImageLabel", ShootButton)
ButtonImageLabel.Name = "ButtonIcon"
ButtonImageLabel.Size = UDim2.new(0.52, 0, 0.52, 0)
ButtonImageLabel.Position = UDim2.new(0.5, 0, 0.47, 0)
ButtonImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonImageLabel.BackgroundTransparency = 1
ButtonImageLabel.Image = "rbxassetid://12471956230"
ButtonImageLabel.ZIndex = 12
ButtonImage = ButtonImageLabel

ButtonTextLabel = Instance.new("TextLabel", ShootButton)
ButtonTextLabel.Name = "ButtonLabel"
ButtonTextLabel.Size = UDim2.new(1, 0, 0.25, 0)
ButtonTextLabel.Position = UDim2.new(0, 0, 0.76, 0)
ButtonTextLabel.BackgroundTransparency = 1
ButtonTextLabel.Text = "SHOOT"
ButtonTextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ButtonTextLabel.Font = Enum.Font.GothamBold
ButtonTextLabel.TextSize = 13
ButtonTextLabel.ZIndex = 13
ButtonText = ButtonTextLabel

aplicarOpacidadGlobal(states.ButtonOpacity)

local shootDragStart, shootStartPos, shootDraggingInput
local haSidoArrastrado = false
local tickInicioPresion = 0
local tweenInfoGlow = TweenInfo.new(0.14, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

ShootButton.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        shootDraggingInput = input
        shootDragStart = input.Position
        shootStartPos = ShootButton.Position; haSidoArrastrado = false
        tickInicioPresion = os.clock() -- Registrar tiempo exacto del Clic
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_GLOW}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_GLOW, Thickness = 1.6}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == shootDraggingInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - shootDragStart
        -- Aumento de zona muerta a 18px para mitigar falsos arrastres táctiles en móviles
        if delta.Magnitude > 18 then haSidoArrastrado = true end
        if not states.LockButton then ShootButton.Position = UDim2.new(shootStartPos.X.Scale, shootStartPos.X.Offset + delta.X, shootStartPos.Y.Scale, shootStartPos.Y.Offset + delta.Y) end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == shootDraggingInput then
        shootDraggingInput = nil
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_BASE}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_BASE, Thickness = 1.2}):Play()
        
        -- Cláusula bypass: Si fue un toque ultra veloz (< 0.15s), forzar el disparo sin importar pequeños temblores físicos
        local duracionToque = os.clock() - tickInicioPresion
        if not haSidoArrastrado or duracionToque < 0.15 then
            dispararAlMurderer()
        else
            states.ButtonScaleX = ShootButton.Position.X.Scale
            states.ButtonOffsetX = ShootButton.Position.X.Offset
            states.ButtonScaleY = ShootButton.Position.Y.Scale
            states.ButtonOffsetY = ShootButton.Position.Y.Offset
            saveButtonConfig()
        end
    end
end)

print([[
============================================================
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
                                                           
============================================================
]])

return KillerHub
