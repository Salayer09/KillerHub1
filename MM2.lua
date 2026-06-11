-- cargar libreria base desde su propio link
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()
local Sheriff = KillerHub.Tabs.Sheriff
local Murder  = KillerHub.Tabs.Murder
local Extras  = KillerHub.Tabs.Extras

-- estados locales del script (Combinado Completo)
local states = {
    -- Ajustes Sheriff
    TracerPrediction = false,
    PredictionSmoothing = 0.4,
    HorizontalPrediction = 0.3,
    VerticalPrediction = 0.15,
    ShowShootButton = false,
    LockButton = false,
    ButtonSize = 100, 
    ButtonOpacity = 0.25,
    WallCheck = false,
    SeeLeadTime = false,
    LeadTimePrediction = 0.3,
    SmartVisibility = false,
    -- Coordenadas guardadas para la posición del botón
    ButtonScaleX = 0.80,
    ButtonOffsetX = 0,
    ButtonScaleY = 0.45,
    ButtonOffsetY = 0,
    
    -- Ajustes Murder (Optimizados)
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

-- paleta de colores morado premium satinado
local COLOR_VOID_BASE = Color3.fromRGB(12, 4, 22)  
local COLOR_VOID_GLOW = Color3.fromRGB(42, 14, 75) 
local COLOR_STROKE_BASE = Color3.fromRGB(24, 8, 42)
local COLOR_STROKE_GLOW = Color3.fromRGB(140, 45, 255)

-- sistema de guardado avanzado
local HttpService = game:GetService("HttpService")
local FILE_NAME = "KillerHub_Button_Config.json"

local function saveButtonConfig()
    if writefile then
        local data = {
            ShowShootButton = states.ShowShootButton,
            LockButton = states.LockButton,
            ButtonSize = states.ButtonSize,
            ButtonOpacity = states.ButtonOpacity,
            WallCheck = states.WallCheck,
            SeeLeadTime = states.SeeLeadTime,
            LeadTimePrediction = states.LeadTimePrediction,
            SmartVisibility = states.SmartVisibility,
            -- Guardar posición en el archivo
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
            if result.ShowShootButton ~= nil then states.ShowShootButton = result.ShowShootButton end
            if result.LockButton ~= nil then states.LockButton = result.LockButton end
            if result.WallCheck ~= nil then states.WallCheck = result.WallCheck end
            if result.SeeLeadTime ~= nil then states.SeeLeadTime = result.SeeLeadTime end
            if result.SmartVisibility ~= nil then states.SmartVisibility = result.SmartVisibility end
            states.ButtonSize = result.ButtonSize or 100
            states.ButtonOpacity = result.ButtonOpacity or 0.25
            states.LeadTimePrediction = result.LeadTimePrediction or 0.3
            
            -- Cargar posición si existe guardada
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

local function desnormalizarSlider(val)
    if val > 1 then
        return val / 100
    end
    return val
end

-- DETECTORES DE INVENTARIO EN TIEMPO REAL
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
-- OPCIONES DE LA PESTAÑA SHERIFF (PREDICCIÓN 100% INTACTA)
-- ============================================================================
Sheriff:CreateSection("Target Prediction")

Sheriff:CreateToggle("S_TracerPrediction", "Prediction Guide", function(state)
    states.TracerPrediction = state
end)

Sheriff:CreateSlider("S_PredictionSmooth", "Smoothness", function(val)
    states.PredictionSmoothing = val
end)

Sheriff:CreateSlider("S_HorizontalPred", "Horizontal Tuning", function(val)
    states.HorizontalPrediction = val
end)

Sheriff:CreateSlider("S_VerticalPred", "Vertical Tuning", function(val)
    states.VerticalPrediction = val
end)

Sheriff:CreateSection("Combat Filters")

Sheriff:CreateToggle("S_WallCheck", "Wall Check", function(state)
    states.WallCheck = state
    saveButtonConfig()
end)

Sheriff:CreateToggle("S_SeeLeadTime", "See Lead Time", function(state)
    states.SeeLeadTime = state
    saveButtonConfig()
end)

Sheriff:CreateSlider("S_LeadTimePred", "Lead Multiplier", function(val)
    local finalVal = val
    if val > 1 then
        finalVal = val / 100
    end
    states.LeadTimePrediction = finalVal
    saveButtonConfig()
end)

Sheriff:CreateSection("Button Settings")

Sheriff:CreateToggle("S_ShowShootButton", "Show Button", function(state)
    states.ShowShootButton = state
    if ShootButton then
        ShootButton.Visible = state
        saveButtonConfig()
    end
end)

Sheriff:CreateToggle("S_SmartVisibility", "Smart Visibility", function(state)
    states.SmartVisibility = state
    saveButtonConfig()
end)

Sheriff:CreateToggle("S_LockButton", "Lock Position", function(state)
    states.LockButton = state
    saveButtonConfig()
end)

Sheriff:CreateSlider("S_ButtonSize", "Button Size", function(val)
    local finalSize = val
    if val <= 1 then
        finalSize = 50 + (val * 130)
    else
        finalSize = 50 + (val * 1.3)
    end
    states.ButtonSize = finalSize
    if ShootButton then
        ShootButton.Size = UDim2.new(0, finalSize, 0, finalSize)
        saveButtonConfig()
    end
end)

Sheriff:CreateSlider("S_ButtonOpacity", "Button Opacity", function(val)
    local targetTransparency = 0.25
    if val <= 1 then
        targetTransparency = 1 - val
    else
        targetTransparency = 1 - (val / 100)
    end
    states.ButtonOpacity = targetTransparency
    aplicarOpacidadGlobal(targetTransparency)
    saveButtonConfig()
end)

-- ============================================================================
-- OPCIONES DE LA PESTAÑA MURDER
-- ============================================================================
Murder:CreateSection("Knife Silent Aim")

Murder:CreateToggle("M_SilentActive", "Silent Aim Activo", function(state)
    states.KnifeSilentAim = state
    saveButtonConfig()
end)

Murder:CreateToggle("M_WallCheck", "Filtro de Paredes (Wall Check)", function(state)
    states.KnifeWallCheck = state
    saveButtonConfig()
end)

Murder:CreateSlider("M_FovRadius", "Radio de Captura (FOV)", function(val)
    states.KnifeFovRadius = 30 + (val * 320)
    saveButtonConfig()
end)

Murder:CreateSection("Configuración Visual del FOV")

Murder:CreateToggle("M_ShowFovCircle", "Mostrar Círculo FOV", function(state)
    states.KnifeShowFov = state
    saveButtonConfig()
end)

Murder:CreateToggle("M_ShowTargetDot", "Mostrar Punto Target", function(state)
    states.KnifeShowTargetDot = state
    saveButtonConfig()
end)

Murder:CreateToggle("M_ShowPredCircle", "Mostrar Círculo Predicción", function(state)
    states.KnifeShowPredCircle = state
    saveButtonConfig()
end)

Murder:CreateSlider("M_FovR", "Color FOV: Rojo (R)", function(val)
    states.KnifeFovR = math.floor(val * 255)
    saveButtonConfig()
end)

Murder:CreateSlider("M_FovG", "Color FOV: Verde (G)", function(val)
    states.KnifeFovG = math.floor(val * 255)
    saveButtonConfig()
end)

Murder:CreateSlider("M_FovB", "Color FOV: Azul (B)", function(val)
    states.KnifeFovB = math.floor(val * 255)
    saveButtonConfig()
end)

Murder:CreateSection("Ajustes de Predicción")

Murder:CreateSlider("M_PredHoriz", "Intensidad Pred. Horizontal", function(val)
    states.KnifePredHorizontal = desnormalizarSlider(val) * 3.2
    saveButtonConfig()
end)

Murder:CreateSlider("M_PredVert", "Intensidad Pred. Vertical", function(val)
    states.KnifePredVertical = desnormalizarSlider(val) * 3.2
    saveButtonConfig()
end)


-- ============================================================================
-- MOTOR LÓGICO DEL COMBATE (SISTEMA DE ARMAS SIN MODIFICAR)
-- ============================================================================
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local rolesPartida = {}
local ultimoPosTarget = Vector3.new()
local ultimoPosLeadTarget = Vector3.new()
local velocidadSuavizada = Vector3.new()
local knifeVelocidadFiltrada = Vector3.new() 
local lastKnifeTarget = nil
local camera = workspace.CurrentCamera
local currentTarget = nil

if CoreGui:FindFirstChild("KillerHub_OverlayEngine") then
    CoreGui.KillerHub_OverlayEngine:Destroy()
end

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "KillerHub_OverlayEngine"
OverlayGui.IgnoreGuiInset = true
OverlayGui.Parent = CoreGui

local TracerLine = Instance.new("Frame")
TracerLine.Name = "ShootPredictionTracer"
TracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
TracerLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TracerLine.BorderSizePixel = 0
TracerLine.Visible = false
TracerLine.ZIndex = 5
TracerLine.Parent = OverlayGui

local GreenTracer = Instance.new("Frame")
GreenTracer.Name = "LeadTimeTracer"
GreenTracer.AnchorPoint = Vector2.new(0.5, 0.5)
GreenTracer.BackgroundColor3 = Color3.fromRGB(0, 255, 120)
GreenTracer.BorderSizePixel = 0
GreenTracer.Visible = false
GreenTracer.ZIndex = 5
GreenTracer.Parent = OverlayGui

local FovCircleFrame = Instance.new("Frame", OverlayGui)
FovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovCircleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FovCircleFrame.BackgroundTransparency = 1

local fovUICorner = Instance.new("UICorner", FovCircleFrame)
fovUICorner.CornerRadius = UDim.new(1, 0)

local fovUIStroke = Instance.new("UIStroke", FovCircleFrame)
fovUIStroke.Thickness = 1.5
fovUIStroke.Transparency = 0.35

local KnifeTargetDot = Instance.new("Frame")
KnifeTargetDot.Name = "KnifeTargetDot"
KnifeTargetDot.AnchorPoint = Vector2.new(0.5, 0.5)
KnifeTargetDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
KnifeTargetDot.BorderSizePixel = 0
KnifeTargetDot.Visible = false
KnifeTargetDot.ZIndex = 15
KnifeTargetDot.Parent = OverlayGui

local DotCorner = Instance.new("UICorner", KnifeTargetDot)
DotCorner.CornerRadius = UDim.new(1, 0)

local KnifePredictionCircle = Instance.new("Frame")
KnifePredictionCircle.Name = "KnifePredictionCircle"
KnifePredictionCircle.AnchorPoint = Vector2.new(0.5, 0.5)
KnifePredictionCircle.BackgroundTransparency = 1
KnifePredictionCircle.Visible = false
KnifePredictionCircle.ZIndex = 16
KnifePredictionCircle.Parent = OverlayGui

local PredCorner = Instance.new("UICorner", KnifePredictionCircle)
PredCorner.CornerRadius = UDim.new(1, 0)

local PredStroke = Instance.new("UIStroke", KnifePredictionCircle)
PredStroke.Thickness = 1.8
PredStroke.Color = Color3.fromRGB(240, 0, 0) 
PredStroke.Transparency = 0
PredStroke.Parent = KnifePredictionCircle

local function updateFovVisual()
    if not tieneCuchillo() then
        FovCircleFrame.Visible = false
        return
    end
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
                if type(info) == "table" and info.Role then
                    rolesPartida[playerName] = info.Role
                end
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
            if p.Character:FindFirstChild("Gun") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Gun")) then
                -- Si alguien más tiene la pistola visible, no es el asesino de forma obvia
            elseif p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p.Character
            end
        end
    end
    return nil
end

local function isMurdererVisible(murdererChar)
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    local origin = LocalPlayer.Character.HumanoidRootPart.Position
    local target = murdererChar.HumanoidRootPart.Position
    local direction = target - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, murdererChar, camera}
    
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    return raycastResult == nil
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

    local result = workspace:Raycast(origin, targetPos - origin, raycastParams)
    return result == nil
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
                    if fovDist <= states.KnifeFovRadius then
                        if fovDist < minFovDist then
                            if hasLineOfSight(v.Character) then
                                minFovDist = fovDist
                                near = v
                            end
                        end
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

local function dispararAlMurderer()
    local murdererChar = buscarMurderer()
    if not murdererChar or not murdererChar:FindFirstChild("HumanoidRootPart") then return end
    
    if states.WallCheck and not isMurdererVisible(murdererChar) then
        return
    end
    
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local arma = (character and character:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun"))
    
    if arma and humanoid and character:FindFirstChild("HumanoidRootPart") then
        local yaEquipada = (arma.Parent == character)
        if not yaEquipada then
            humanoid:EquipTool(arma)
            task.wait(0.02)
        end
        if arma:FindFirstChild("Shoot") then
            local originCFrame = character.HumanoidRootPart:FindFirstChild("GunRaycastAttachment") and character.HumanoidRootPart.GunRaycastAttachment.WorldCFrame or character.HumanoidRootPart.CFrame
            local targetPos = states.TracerPrediction and ultimoPosTarget or murdererChar.HumanoidRootPart.Position
            local correctedTargetCFrame = CFrame.new(targetPos)
            arma.Shoot:FireServer(originCFrame, correctedTargetCFrame)
        end
        if not yaEquipada then
            task.wait(0.02)
            humanoid:UnequipTools()
        end
    end
end

local function getPredictedPosition()
    if not currentTarget or not currentTarget.Character or not currentTarget.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHRP = currentTarget.Character.HumanoidRootPart
    local targetHum = currentTarget.Character:FindFirstChildOfClass("Humanoid")
    if not myHRP or not targetHRP then return nil end

    local origin = myHRP.Position
    local targetPos = targetHRP.Position
    local dist = (origin - targetPos).Magnitude
    
    local pHoriz = tonumber(states.KnifePredHorizontal) or 1.5
    local pVert = tonumber(states.KnifePredVertical) or 1.0

    local knifeSpeed = 245
    local ping = 0.06
    pcall(function()
        ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
    
    local timeToTarget = (dist / knifeSpeed) + (ping * 1.12)

    if not lastKnifeTarget or lastKnifeTarget ~= currentTarget then
        lastKnifeTarget = currentTarget
        knifeVelocidadFiltrada = targetHRP.Velocity
    else
        knifeVelocidadFiltrada = knifeVelocidadFiltrada:Lerp(targetHRP.Velocity, 0.22)
    end
    
    local horizOffsetX = knifeVelocidadFiltrada.X * pHoriz * timeToTarget
    local horizOffsetZ = knifeVelocidadFiltrada.Z * pHoriz * timeToTarget
    
    horizOffsetX = math.clamp(horizOffsetX, -35, 35)
    horizOffsetZ = math.clamp(horizOffsetZ, -35, 35)

    local verticalOffset = knifeVelocidadFiltrada.Y * timeToTarget
    
    if targetHum and targetHum.FloorMaterial == Enum.Material.Air then
        local gravedadRoblox = 196.2
        verticalOffset = (knifeVelocidadFiltrada.Y * timeToTarget) - (0.5 * gravedadRoblox * math.pow(timeToTarget, 2))
    else
        verticalOffset = knifeVelocidadFiltrada.Y * timeToTarget * 0.55
    end
    
    verticalOffset = verticalOffset * pVert
    verticalOffset = math.clamp(verticalOffset, -12, 22)

    local rawPrediction = targetPos + Vector3.new(horizOffsetX, verticalOffset, horizOffsetZ)

    local floorParams = RaycastParams.new()
    floorParams.FilterType = Enum.RaycastFilterType.Exclude
    floorParams.FilterDescendantsInstances = {currentTarget.Character, LocalPlayer.Character, camera}
    
    local floorRay = workspace:Raycast(targetPos, Vector3.new(0, -22, 0), floorParams)
    if floorRay then
        local limiteSueloY = floorRay.Position.Y + 2.45
        if rawPrediction.Y < limiteSueloY then
            rawPrediction = Vector3.new(rawPrediction.X, limiteSueloY, rawPrediction.Z)
        end
    end

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
            local tamanoPunto = math.round(6 * factorEscala)
            local tamanoCirculo = math.round(11 * factorEscala)
            
            KnifeTargetDot.Size = UDim2.new(0, tamanoPunto, 0, tamanoPunto)
            KnifePredictionCircle.Size = UDim2.new(0, tamanoCirculo, 0, tamanoCirculo)

            local screenPosTarget, onScreenTarget = camera:WorldToViewportPoint(hrp.Position)
            if onScreenTarget and states.KnifeShowTargetDot then
                KnifeTargetDot.Position = UDim2.new(0, screenPosTarget.X, 0, screenPosTarget.Y)
                KnifeTargetDot.Visible = true
            else
                KnifeTargetDot.Visible = false
            end
            
            local predictedPos = getPredictedPosition()
            if predictedPos then
                local screenPosPred, onScreenPred = camera:WorldToViewportPoint(predictedPos)
                if onScreenPred and states.KnifeShowPredCircle then
                    KnifePredictionCircle.Position = UDim2.new(0, screenPosPred.X, 0, screenPosPred.Y)
                    KnifePredictionCircle.Visible = true
                else
                    KnifePredictionCircle.Visible = false
                end
            else
                KnifePredictionCircle.Visible = false
            end
        else
            KnifeTargetDot.Visible = false
            KnifePredictionCircle.Visible = false
            currentTarget = nil
        end
    else
        KnifeTargetDot.Visible = false
        KnifePredictionCircle.Visible = false
        currentTarget = nil
    end
end)

local WeaponService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("WeaponService"))

local oldGetTargetPosition = WeaponService.GetTargetPosition
WeaponService.GetTargetPosition = function(self, ...)
    if states.KnifeSilentAim and tieneCuchillo() then
        local success, pos = pcall(getPredictedPosition)
        if success and pos then return CFrame.new(pos) end
    end
    return oldGetTargetPosition(self, ...)
end

local oldGetMouseTargetCFrame = WeaponService.GetMouseTargetCFrame
WeaponService.GetMouseTargetCFrame = function(self, ...)
    if states.KnifeSilentAim and tieneCuchillo() then
        local success, pos = pcall(getPredictedPosition)
        if success and pos then return CFrame.new(pos) end
    end
    return oldGetMouseTargetCFrame(self, ...)
end

-- Ciclo Heartbeat con corrección de SMART VISIBILITY nativo
RunService.Heartbeat:Connect(function()
    -- Analizar la condición de visibilidad inteligente
    local tieneLaPistola = tienePistola()
    local ocultarPorSmartVisibility = states.SmartVisibility and not tieneLaPistola

    if ShootButton then
        if ocultarPorSmartVisibility then
            ShootButton.Visible = false
        else
            ShootButton.Visible = states.ShowShootButton
        end
    end
    
    if rolesPartida[LocalPlayer.Name] == "Murderer" or ocultarPorSmartVisibility then
        TracerLine.Visible = false
        GreenTracer.Visible = false
        return
    end
    
    local murdererChar = buscarMurderer()
    if murdererChar and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = murdererChar.HumanoidRootPart
        local miHrp = LocalPlayer.Character.HumanoidRootPart
        
        velocidadSuavizada = velocidadSuavizada:Lerp(hrp.Velocity, 0.15)
        local distancia = (hrp.Position - miHrp.Position).Magnitude
        local tiempoDeVuelo = math.clamp(distancia / 165, 0, 0.32)
        local suavizadoLerp = math.clamp(states.PredictionSmoothing or 0.4, 0.03, 1)
        
        if states.TracerPrediction then
            local multiH = (states.HorizontalPrediction or 0.3) * 2.2
            local multiV = (states.VerticalPrediction or 0.15) * 2.2
 
            if distancia > 50 then
                local factorReduccion = math.clamp(50 / distancia, 0.35, 1)
                multiH = multiH * factorReduccion
                multiV = multiV * factorReduccion
            end
          
            local puntoDestinoRaw = hrp.Position + Vector3.new(velocidadSuavizada.X * multiH, velocidadSuavizada.Y * multiV, velocidadSuavizada.Z * multiH) * tiempoDeVuelo
            if ultimoPosTarget == Vector3.new() then ultimoPosTarget = hrp.Position end
            ultimoPosTarget = ultimoPosTarget:Lerp(puntoDestinoRaw, suavizadoLerp)
            
            local screenPos, onScreen = camera:WorldToViewportPoint(ultimoPosTarget)
        
            if onScreen then
                local inicioTracer = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                local finTracer = Vector2.new(screenPos.X, screenPos.Y)
                local vectorDistancia = finTracer - inicioTracer
                TracerLine.Size = UDim2.new(0, vectorDistancia.Magnitude, 0, 1.2)
                TracerLine.Position = UDim2.new(0, inicioTracer.X + vectorDistancia.X / 2, 0, inicioTracer.Y + vectorDistancia.Y / 2)
                TracerLine.Rotation = math.deg(math.atan2(vectorDistancia.Y, vectorDistancia.X))
                TracerLine.Visible = true
            else
                TracerLine.Visible = false
            end
        else
            TracerLine.Visible = false
        end
        
        if states.SeeLeadTime then
            local multiLead = (states.LeadTimePrediction or 0.3) * 2.2
            local puntoLeadRaw = hrp.Position + (velocidadSuavizada * multiLead) * tiempoDeVuelo
            
            if ultimoPosLeadTarget == Vector3.new() then ultimoPosLeadTarget = hrp.Position end
            ultimoPosLeadTarget = ultimoPosLeadTarget:Lerp(puntoLeadRaw, suavizadoLerp)
            
            local handPos = getHandPosition()
            if handPos then
                local screenHandPos, handOnScreen = camera:WorldToViewportPoint(handPos)
                local screenTargetPos, targetOnScreen = camera:WorldToViewportPoint(ultimoPosLeadTarget)
                
                if handOnScreen and targetOnScreen then
                    local inicioMano = Vector2.new(screenHandPos.X, screenHandPos.Y)
                    local finMano = Vector2.new(screenTargetPos.X, screenTargetPos.Y)
                    local vectorMano = finMano - inicioMano
                    
                    GreenTracer.Size = UDim2.new(0, vectorMano.Magnitude, 0, 1.1)
                    GreenTracer.Position = UDim2.new(0, inicioMano.X + vectorMano.X / 2, 0, inicioMano.Y + vectorMano.Y / 2)
                    GreenTracer.Rotation = math.deg(math.atan2(vectorMano.Y, vectorMano.X))
                    GreenTracer.Visible = true
                else
                    GreenTracer.Visible = false
                end
            else
                GreenTracer.Visible = false
            end
        else
            GreenTracer.Visible = false
        end
    else
        TracerLine.Visible = false
        GreenTracer.Visible = false
    end
end)

-- Creación de interfaz física utilizando las coordenadas del archivo JSON cargado
ShootButton = Instance.new("TextButton")
ShootButton.Name = "PremiumSheriffButton"
ShootButton.Size = UDim2.new(0, states.ButtonSize, 0, states.ButtonSize)
ShootButton.Position = UDim2.new(states.ButtonScaleX, states.ButtonOffsetX, states.ButtonScaleY, states.ButtonOffsetY)
ShootButton.BackgroundColor3 = COLOR_VOID_BASE
ShootButton.Text = ""
ShootButton.AutoButtonColor = false
ShootButton.Visible = states.ShowShootButton
ShootButton.Active = true
ShootButton.ZIndex = 10
ShootButton.Parent = OverlayGui

local ShootCorner = Instance.new("UICorner")
ShootCorner.CornerRadius = UDim.new(0, 22)
ShootCorner.Parent = ShootButton

ShootStroke = Instance.new("UIStroke")
ShootStroke.Thickness = 1.2
ShootStroke.Color = COLOR_STROKE_BASE
ShootStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ShootStroke.Parent = ShootButton

local ButtonImageLabel = Instance.new("ImageLabel")
ButtonImageLabel.Name = "ButtonIcon"
ButtonImageLabel.Size = UDim2.new(0.52, 0, 0.52, 0)
ButtonImageLabel.Position = UDim2.new(0.5, 0, 0.47, 0)
ButtonImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
ButtonImageLabel.BackgroundTransparency = 1
ButtonImageLabel.Image = "rbxassetid://12471956230"
ButtonImageLabel.ZIndex = 12
ButtonImageLabel.Parent = ShootButton
ButtonImage = ButtonImageLabel

local ButtonTextLabel = Instance.new("TextLabel")
ButtonTextLabel.Name = "ButtonLabel"
ButtonTextLabel.Size = UDim2.new(1, 0, 0.25, 0)
ButtonTextLabel.Position = UDim2.new(0, 0, 0.76, 0)
ButtonTextLabel.BackgroundTransparency = 1
ButtonTextLabel.Text = "SHOOT"
ButtonTextLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
ButtonTextLabel.Font = Enum.Font.GothamBold
ButtonTextLabel.TextSize = 13
ButtonTextLabel.ZIndex = 13
ButtonTextLabel.Parent = ShootButton
ButtonText = ButtonTextLabel

aplicarOpacidadGlobal(states.ButtonOpacity)

local shootDragStart, shootStartPos, shootDraggingInput
local haSidoArrastrado = false
local tweenInfoGlow = TweenInfo.new(0.14, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

ShootButton.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        shootDraggingInput = input
        shootDragStart = input.Position
        shootStartPos = ShootButton.Position
        haSidoArrastrado = false
        
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_GLOW}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_GLOW, Thickness = 1.6}):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == shootDraggingInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - shootDragStart
        if delta.Magnitude > 8 then haSidoArrastrado = true end
        if not states.LockButton then
            ShootButton.Position = UDim2.new(shootStartPos.X.Scale, shootStartPos.X.Offset + delta.X, shootStartPos.Y.Scale, shootStartPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input) 
    if input == shootDraggingInput then 
        shootDraggingInput = nil 
        
        TweenService:Create(ShootButton, tweenInfoGlow, {BackgroundColor3 = COLOR_VOID_BASE}):Play()
        TweenService:Create(ShootStroke, tweenInfoGlow, {Color = COLOR_STROKE_BASE, Thickness = 1.2}):Play()
        
        if not haSidoArrastrado then
            dispararAlMurderer()
        else
            -- Actualizar las coordenadas en la tabla de estados y guardar la nueva ubicación
            states.ButtonScaleX = ShootButton.Position.X.Scale
            states.ButtonOffsetX = ShootButton.Position.X.Offset
            states.ButtonScaleY = ShootButton.Position.Y.Scale
            states.ButtonOffsetY = ShootButton.Position.Y.Offset
            saveButtonConfig()
        end
    end
end)

print("✅ [KillerHub] Smart Visibility fully fixed and connected to live inventory scanning successfully.")
