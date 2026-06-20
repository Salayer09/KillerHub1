-- ============================================================================
-- 👻 KILLER HUB | SHERIFF V5.0.0 [HYBRID KINETIC ENGINE & STRICT WALLCHECK]
-- ============================================================================
if _G.KillerHubLines then
    for _, line in pairs(_G.KillerHubLines) do
        pcall(function() line:Remove() end)
    end
end
_G.KillerHubLines = {}

local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KillerHub/refs/heads/main/Slayer.lua"))()

-- 1. PESTAÑA SHERIFF
local SheriffTab = KillerHub:CreateTab("Sheriff", "rbxassetid://10747373142")

-- 2. CONFIGURACIÓN GLOBAL AUTOMÁTICA FUSIONADA
local SheriffConfig = {
    SilentAim = false,
    HorizontalPred = 1.00, 
    VerticalPred = 1.00,    
    WallCheck = true,         
    JumpPrediction = true,
    PingAdaptation = false,
    SimDivider = 4,
    
    PredictTracer = false,
    ShowPingTracer = false,    
    ShowLagTracer = false,     
    ShowLeadTracer = true,     
    UseWeaponDetector = false, 
    AutoUnequip = false,        
    ShowShootButton = false,
    ButtonSize = 95,
    ButtonOpacity = 0.95, 
    ButtonLocked = false,
    ButtonX = 0.7, 
    ButtonY = 0.6,
    
    LeadTimePred = 0.30 
}

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "KillerHub_SheriffSuite_V5.txt"

local function saveConfig()
    if writefile then
        local data = {
            ButtonX = SheriffConfig.ButtonX,
            ButtonY = SheriffConfig.ButtonY,
            HorizontalPred = SheriffConfig.HorizontalPred,
            VerticalPred = SheriffConfig.VerticalPred,
            JumpPrediction = SheriffConfig.JumpPrediction,
            PingAdaptation = SheriffConfig.PingAdaptation,
            SimDivider = SheriffConfig.SimDivider,
            LeadTimePred = SheriffConfig.LeadTimePred,
            UseWeaponDetector = SheriffConfig.UseWeaponDetector,
            AutoUnequip = SheriffConfig.AutoUnequip,
            ShowLeadTracer = SheriffConfig.ShowLeadTracer,
            ShowPingTracer = SheriffConfig.ShowPingTracer,
            ShowLagTracer = SheriffConfig.ShowLagTracer,
            WallCheck = SheriffConfig.WallCheck
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
            SheriffConfig.HorizontalPred = data.HorizontalPred or SheriffConfig.HorizontalPred
            SheriffConfig.VerticalPred = data.VerticalPred or SheriffConfig.VerticalPred
            if data.JumpPrediction ~= nil then SheriffConfig.JumpPrediction = data.JumpPrediction end
            if data.PingAdaptation ~= nil then SheriffConfig.PingAdaptation = data.PingAdaptation end
            SheriffConfig.SimDivider = data.SimDivider or SheriffConfig.SimDivider
            SheriffConfig.LeadTimePred = data.LeadTimePred or SheriffConfig.LeadTimePred
            if data.UseWeaponDetector ~= nil then SheriffConfig.UseWeaponDetector = data.UseWeaponDetector end
            if data.AutoUnequip ~= nil then SheriffConfig.AutoUnequip = data.AutoUnequip end
            if data.ShowLeadTracer ~= nil then SheriffConfig.ShowLeadTracer = data.ShowLeadTracer end
            if data.ShowPingTracer ~= nil then SheriffConfig.ShowPingTracer = data.ShowPingTracer end
            if data.ShowLagTracer ~= nil then SheriffConfig.ShowLagTracer = data.ShowLagTracer end
            if data.WallCheck ~= nil then SheriffConfig.WallCheck = data.WallCheck end
        end
    end
end
loadConfig()

-- ============================================================================
-- ⚙️ INTERFAZ GRÁFICA CONTROLADA NATIVA
-- ============================================================================
SheriffTab:CreateSection("Ajustes del Silent Aim")

SheriffTab:CreateToggle("SheriffSilent", "Activar Silent Aim Pasivo", function(estado)
    SheriffConfig.SilentAim = estado
end)

SheriffTab:CreateToggle("SheriffWallCheckToggle", "Strict Wall Check (Filtro Avanzado)", function(estado)
    SheriffConfig.WallCheck = estado
    saveConfig()
end)

SheriffTab:CreateSlider("HorizontalPredSlider", "Sintonía Horizontal", 0, 150, function(valor)
    SheriffConfig.HorizontalPred = valor / 100 
    saveConfig()
end)

SheriffTab:CreateSlider("VerticalPredSlider", "Sintonía Vertical", 0, 125, function(valor)
    SheriffConfig.VerticalPred = valor / 100
    saveConfig()
end)

SheriffTab:CreateSection("Predicción Avanzada (Filtros Cinemáticos)")

SheriffTab:CreateToggle("PingAdaptToggle", "Adaptación de Ping Dinámica", function(estado)
    SheriffConfig.PingAdaptation = estado
    saveConfig()
end)

SheriffTab:CreateToggle("JumpPredToggle", "Predicción de Salto Adaptativa", function(estado)
    SheriffConfig.JumpPrediction = estado
    saveConfig()
end)

SheriffTab:CreateSlider("SimDividerSlider", "Divisor de Simulación (Pasos)", 1, 8, function(valor)
    SheriffConfig.SimDivider = math.clamp(math.round(valor), 1, 8)
    saveConfig()
end)

SheriffTab:CreateSection("Líneas de Trayectoria (Tracers)")

SheriffTab:CreateToggle("TracerPredToggle", "Mostrar Guía de Predicción (Rojo)", function(estado)
    SheriffConfig.PredictTracer = estado
end)

SheriffTab:CreateToggle("PingTracerToggle", "Mostrar Ping Prediction (Azul)", function(estado)
    SheriffConfig.ShowPingTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LagTracerToggle", "Mostrar Lag Prediction (Violeta)", function(estado)
    SheriffConfig.ShowLagTracer = estado
    saveConfig()
end)

SheriffTab:CreateToggle("LeadTracerToggle", "Activar Lead Tracer (Verde Neón)", function(estado)
    SheriffConfig.ShowLeadTracer = estado
    saveConfig()
end)

SheriffTab:CreateSlider("LeadTimeSlider", "Multiplicador de Anticipación (Mano)", 0, 100, function(valor)
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
    end
end)

SheriffTab:CreateSlider("VoidBtnOpacity", "Opacidad del Botón", 10, 100, function(valor)
    SheriffConfig.ButtonOpacity = valor / 100
    local btn = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui") and game:GetService("CoreGui").KillerHub_VoidGui:FindFirstChild("ShootButton")
    if btn then
        btn.BackgroundTransparency = 1 - SheriffConfig.ButtonOpacity
    end
end)

SheriffTab:CreateToggle("LockVoidBtn", "Bloquear Posición del Botón", function(estado)
    SheriffConfig.ButtonLocked = estado
end)

-- ============================================================================
-- 🧠 VARIABLES DE ENTORNO Y ENTRADAS FÍSICAS
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") 
local Stats = game:GetService("Stats") 
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local gunVelocidadFiltrada = Vector3.new(0,0,0)
local gunAceleracionFiltrada = Vector3.new(0,0,0)
local ultimoPosTarget = Vector3.new(0,0,0)
local ultimoPuntoLead = Vector3.new(0,0,0)

local cachedPingValue = 0.125
task.spawn(function()
    while task.wait(1.2) do
        pcall(function()
            if Stats and Stats:FindFirstChild("Network") and Stats.Network:FindFirstChild("ServerToClientPing") then
                cachedPingValue = Stats.Network.ServerToClientPing:GetValue() / 1000
            end
        end)
    end
end)

local globalRaycastParams = RaycastParams.new()
globalRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
globalRaycastParams.IgnoreWater = true

local function getGunLocation()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Gun") then
        return char:FindFirstChild("Gun"), char
    elseif LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun") then
        return LocalPlayer.Backpack.Gun, LocalPlayer.Backpack
    end
    return nil, nil
end

local function getMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent ~= nil then
            local char = player.Character
            if (char and char:FindFirstChild("Knife")) or (player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("Knife")) then
                return char
            end
        end
    end
    return nil
end

-- ============================================================================
-- 🧱 MOTOR MULTIPARTES AVANZADO (STRICT WALL CHECK)
-- ============================================================================
local function obtenerParteVisible(targetChar)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return targetChar:FindFirstChild("HumanoidRootPart") 
    end
    if not SheriffConfig.WallCheck then
        return targetChar:FindFirstChild("HumanoidRootPart")
    end

    globalRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar, Camera}
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
    return nil
end

-- ============================================================================
-- 🧠 MOTOR CINEMÁTICO V5.0.0 (SIMULACIÓN EXPONENCIAL Y ANTI-TEMBLOR)
-- ============================================================================
local function getPredictedPosition(murdererChar)
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    local targetPart = obtenerParteVisible(murdererChar)
    if not targetPart then return nil end -- No hay línea de visión limpia a ninguna extremidad
    
    local targetHum = murdererChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetPart then return nil end
    
    local dist = (myHRP.Position - targetPart.Position).Magnitude
    local ping = cachedPingValue or 0.125
    local bulletSpeed = 310
    local tiempoDeVuelo = (dist / bulletSpeed) + ping
    
    local multiH = SheriffConfig.HorizontalPred or 1.00
    local multiV = SheriffConfig.VerticalPred or 1.00
    
    local avatarScale = 1
    if targetHum then
        local heightScale = targetHum:FindFirstChild("HeightScale")
        if heightScale then avatarScale = math.clamp(heightScale.Value, 0.3, 1) end
    end
    
    if SheriffConfig.PingAdaptation then
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
    local totalSteps = SheriffConfig.SimDivider or 4
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
        if SheriffConfig.JumpPrediction then
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
    
    -- Suavizado Cinético Estricto de Aceleración (Heredado de tu script V6)
    local accOffset = 0.5 * gunAceleracionFiltrada * tSq
    accOffset = Vector3.new(math.clamp(accOffset.X, -1.2, 1.2), math.clamp(accOffset.Y, -0.6, 1.0), math.clamp(accOffset.Z, -1.2, 1.2))
    
    local finalPos = Vector3.new(posSimulada.X, posSimulada.Y + yOffset, posSimulada.Z) + accOffset
    
    if avatarScale < 0.75 and targetPart.Name == "HumanoidRootPart" then
        finalPos = finalPos - Vector3.new(0, 0.6 * (1 - avatarScale), 0)
    end
    
    return finalPos
end

-- ============================================================================
-- 🔄 BUCLE DE FILTRADO EXPO-PASABAJAS (HEARTBEAT LOOP)
-- ============================================================================
RunService.Heartbeat:Connect(function(dt)
    local character = LocalPlayer.Character
    local murdererChar = getMurderer()
    
    if murdererChar and murdererChar:FindFirstChild("HumanoidRootPart") and character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = murdererChar.HumanoidRootPart
        local hum = murdererChar:FindFirstChildOfClass("Humanoid")
        
        -- CAPTURA HÍBRIDA FUSIONADA: Inmune por completo al lag de replicación de red
        local rbVel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.new()
        local velCalculada = rbVel
        
        if hum and hum.MoveDirection.Magnitude > 0 then
            local walkSpeed = hum.WalkSpeed > 0 and hum.WalkSpeed or 16.2
            velCalculada = Vector3.new(hum.MoveDirection.X * walkSpeed, rbVel.Y, hum.MoveDirection.Z * walkSpeed)
        end

        local antiguaVelocidad = gunVelocidadFiltrada
        -- Filtro Pasabajas Exponencial Adaptativo
        gunVelocidadFiltrada = gunVelocidadFiltrada:Lerp(velCalculada, 1 - math.exp(-14 * dt))
        
        if dt > 0 then 
            local rawAcc = (gunVelocidadFiltrada - antiguaVelocidad) / dt
            if rawAcc.Magnitude > 32 then
                rawAcc = rawAcc.Unit * 32
            end
            gunAceleracionFiltrada = gunAceleracionFiltrada:Lerp(rawAcc, 1 - math.exp(-5 * dt)) 
        end
    end
end)

-- ============================================================================
-- 🟦 🟣 🟥 🟩 MOTOR DE TRACERS COMPLETO DE ALTA FRECUENCIA
-- ============================================================================
local PingLine = Drawing.new("Line")
PingLine.Color = Color3.fromRGB(0, 45, 167) 
PingLine.Thickness = 1.0
PingLine.Visible = false
table.insert(_G.KillerHubLines, PingLine)

local LagLine = Drawing.new("Line")
LagLine.Color = Color3.fromRGB(114, 39, 214) 
LagLine.Thickness = 1.0
LagLine.Visible = false
table.insert(_G.KillerHubLines, LagLine)

local LeadLine = Drawing.new("Line")
LeadLine.Color = Color3.fromRGB(103, 255, 89) 
LeadLine.Thickness = 1.0
LeadLine.Visible = false
table.insert(_G.KillerHubLines, LeadLine)

local PredictionLine = Drawing.new("Line")
PredictionLine.Color = Color3.fromRGB(255, 35, 35)
PredictionLine.Thickness = 1.2 
PredictionLine.Visible = false
table.insert(_G.KillerHubLines, PredictionLine)

local vec2New, vec3New = Vector2.new, Vector3.new
local worldToViewport = Camera.WorldToViewportPoint

RunService.RenderStepped:Connect(function()
    local gun, _ = getGunLocation()
    local hasGun = not SheriffConfig.UseWeaponDetector or (gun ~= nil)
    local murdererChar = getMurderer()
    local screenGui = game:GetService("CoreGui"):FindFirstChild("KillerHub_VoidGui")
    if screenGui then screenGui.Enabled = SheriffConfig.ShowShootButton and hasGun end

    if not hasGun or not murdererChar then
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
        return
    end

    local targetHrp = murdererChar:FindFirstChild("HumanoidRootPart")
    local localChar = LocalPlayer.Character
    local localHrp = localChar and localChar:FindFirstChild("HumanoidRootPart")

    if targetHrp and localHrp then
        local ping = cachedPingValue or 0.125
        local predictedPos = getPredictedPosition(murdererChar)
        
        if predictedPos and SheriffConfig.PredictTracer then
            ultimoPosTarget = ultimoPosTarget:Lerp(predictedPos, 0.85)
            local screenPos, onScreen = worldToViewport(Camera, ultimoPosTarget)
            if onScreen then
                PredictionLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PredictionLine.To = vec2New(screenPos.X, screenPos.Y)
                PredictionLine.Visible = true
            else PredictionLine.Visible = false end
        else PredictionLine.Visible = false end

        if SheriffConfig.ShowPingTracer then
            local pingPos = targetHrp.Position + (gunVelocidadFiltrada * ping)
            local screenPos, onScreen = worldToViewport(Camera, pingPos)
            if onScreen then
                PingLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                PingLine.To = vec2New(screenPos.X, screenPos.Y)
                PingLine.Visible = true
            else PingLine.Visible = false end
        else PingLine.Visible = false end

        if SheriffConfig.ShowLagTracer then
            local lagPos = targetHrp.Position + (gunVelocidadFiltrada * (SheriffConfig.HorizontalPred * 0.1))
            local screenPos, onScreen = worldToViewport(Camera, lagPos)
            if onScreen then
                LagLine.From = vec2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                LagLine.To = vec2New(screenPos.X, screenPos.Y)
                LagLine.Visible = true
            else LagLine.Visible = false end
        else LagLine.Visible = false end

        local hand = localChar and (localChar:FindFirstChild("RightHand") or localChar:FindFirstChild("Right Arm"))
        if SheriffConfig.ShowLeadTracer and hand then
            ultimoPuntoLead = ultimoPuntoLead:Lerp(targetHrp.Position + (gunVelocidadFiltrada * (SheriffConfig.LeadTimePred * 1.1)), 0.85)
            local handScreenPos, handOnScreen = worldToViewport(Camera, hand.Position)
            local targetScreenPos, targetOnScreen = worldToViewport(Camera, ultimoPuntoLead)

            if handOnScreen and targetOnScreen then
                LeadLine.From = vec2New(handScreenPos.X, handScreenPos.Y)
                LeadLine.To = vec2New(targetScreenPos.X, targetScreenPos.Y)
                LeadLine.Visible = true
            else LeadLine.Visible = false end
        else LeadLine.Visible = false end
    else
        PredictionLine.Visible = false; PingLine.Visible = false; LagLine.Visible = false; LeadLine.Visible = false
    end
end)

-- ============================================================================
-- 🔗 VERIFICACIÓN DE INTERCEPTACIÓN Y DISPARO REMOTO
-- ============================================================================
local function fireAtMurdererDirectly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local gun, parent = getGunLocation()
    local murdererChar = getMurderer()

    if gun and murdererChar then
        local targetPart = obtenerParteVisible(murdererChar)
        if targetPart then 
            local predictedPos = getPredictedPosition(murdererChar)
            if predictedPos then
                local startedInBackpack = (parent == LocalPlayer.Backpack)
                if startedInBackpack then 
                    humanoid:EquipTool(gun) 
                    RunService.Heartbeat:Wait() 
                end
                
                -- Doble verificación estricta de clips e impactos en entorno físico
                if SheriffConfig.WallCheck and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
                    local originPos = hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame.Position or hrp.CFrame.Position
                    globalRaycastParams.FilterDescendantsInstances = {char, murdererChar, Camera}
                    local clipCheck = workspace:Raycast(hrp.Position, originPos - hrp.Position, globalRaycastParams)
                    local pathCheck = workspace:Raycast(originPos, predictedPos - originPos, globalRaycastParams)
                    if clipCheck or pathCheck then return end -- Obstrucción detectada
                end

                if gun:FindFirstChild("Shoot") then
                    local originCFrame = char.HumanoidRootPart.CFrame
                    if char.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") then
                        originCFrame = char.HumanoidRootPart.GunRaycastAttachment.WorldCFrame
                    end
                    gun.Shoot:FireServer(originCFrame, CFrame.new(predictedPos))
                end
                if SheriffConfig.AutoUnequip then 
                    task.wait(0.02) 
                    humanoid:UnequipTools() 
                end
            end
        end
    end
end

-- ============================================================================
-- 🌌 INTERFAZ V3.6 (BOTÓN CON TRASLACIÓN DE REFLEJO INTERNO CLÁSICO)
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
UiGradient.Rotation = 90 
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

local SIDE_ANGLES = {90, 270}

local function processGlowAtCoordinates(inputPosition)
    local buttonAbsolutePos = ShootButton.AbsolutePosition
    local buttonSize = ShootButton.AbsoluteSize
    local localY = inputPosition.Y - buttonAbsolutePos.Y
    local relY = (localY / buttonSize.Y) - 0.5
    
    UiGradient.Offset = Vector2.new(0, relY * 1.5) 
    UiGradient.Rotation = SIDE_ANGLES[math.random(1, #SIDE_ANGLES)]
    
    TweenService:Create(GlowOverlay, TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.06
    }):Play()
end

local function fadeGlowReflection()
    TweenService:Create(GlowOverlay, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    }):Play()
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
-- ⚡ HOOKEO DE METAMÉTODOS OPTIMIZADO (SILENT AIM SEGURO)
-- ============================================================================
local ClientServices = ReplicatedStorage:WaitForChild("ClientServices", 5)
if ClientServices then
    local WeaponService = require(ClientServices:WaitForChild("WeaponService"))
    local oldGetTargetPosition = WeaponService.GetTargetPosition
    local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame

    local function checkAndPredict()
        local gun, _ = getGunLocation()
        if SheriffConfig.SilentAim and (not SheriffConfig.UseWeaponDetector or (gun ~= nil)) then
            local murdererChar = getMurderer()
            if murdererChar then
                local targetPart = obtenerParteVisible(murdererChar)
                if targetPart then
                    local predictedPos = getPredictedPosition(murdererChar)
                    if predictedPos then
                        if SheriffConfig.WallCheck then
                            local char = LocalPlayer.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local originCFrame = hrp and (hrp:FindFirstChild("GunRaycastAttachment") and hrp.GunRaycastAttachment.WorldCFrame or hrp.CFrame)
                            if originCFrame then
                                globalRaycastParams.FilterDescendantsInstances = {char, murdererChar, Camera}
                                local clipCheck = workspace:Raycast(hrp.Position, originCFrame.Position - hrp.Position, globalRaycastParams)
                                local pathCheck = workspace:Raycast(originCFrame.Position, predictedPos - originCFrame.Position, globalRaycastParams)
                                if not clipCheck and not pathCheck then return CFrame.new(predictedPos) end
                            end
                        else
                            return CFrame.new(predictedPos)
                        end
                    end
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
