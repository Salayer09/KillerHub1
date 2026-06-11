-- cargar libreria base desde su propio link
local KillerHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/Paolo0109/KillerHUB/refs/heads/main/InterfazBase.lua"))()
local Sheriff = KillerHub.Tabs.Sheriff
local Extras  = KillerHub.Tabs.Extras

-- estados locales del script
local states = {
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
    SmartVisibility = false
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
            SmartVisibility = states.SmartVisibility
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
        end
    end
end

loadButtonConfig()

-- referencias de ui para control de opacidad
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

-- ============================================================================
-- 🎯 OPCIONES DE LA PESTAÑA SHERIFF (ELEGANT & PREMIUM)
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
-- ⚙️ MOTOR LÓGICO DEL COMBATE (BACKGROUND CORE)
-- ============================================================================
local Players = game:GetService("Players")
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
local camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("KillerHub_OverlayEngine") then
    CoreGui.KillerHub_OverlayEngine:Destroy()
end

local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = "KillerHub_OverlayEngine"
OverlayGui.IgnoreGuiInset = true
OverlayGui.Parent = CoreGui

-- tracer principal rojo (desde la parte inferior)
local TracerLine = Instance.new("Frame")
TracerLine.Name = "ShootPredictionTracer"
TracerLine.AnchorPoint = Vector2.new(0.5, 0.5)
TracerLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TracerLine.BorderSizePixel = 0
TracerLine.Visible = false
TracerLine.ZIndex = 5
TracerLine.Parent = OverlayGui

-- tracer verde neon delgado (desde la mano del jugador)
local GreenTracer = Instance.new("Frame")
GreenTracer.Name = "LeadTimeTracer"
GreenTracer.AnchorPoint = Vector2.new(0.5, 0.5)
GreenTracer.BackgroundColor3 = Color3.fromRGB(0, 255, 120) 
GreenTracer.BorderSizePixel = 0
GreenTracer.Visible = false
GreenTracer.ZIndex = 5
GreenTracer.Parent = OverlayGui

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
            if p.Character:FindFirstChild("Knife") or (p:FindFirstChild("Backpack") and p.Backpack:FindFirstChild("Knife")) then
                return p.Character
            end
        end
    end
    return nil
end

-- raycast rapido para comprobar paredes (wall check)
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

-- buscador automatico de la posicion de la mano derecha
local function getHandPosition()
    local character = LocalPlayer.Character
    if character then
        local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
        if hand then return hand.Position end
        return character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
    end
    return nil
end

-- ejecutor de disparo con boton manual
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

-- ciclo heartbeat para actualizar los trazos (tracers)
RunService.Heartbeat:Connect(function()
    local tieneArma = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun")))
    local ocultarPorRol = states.SmartVisibility and not tieneArma
    
    if ShootButton then
        ShootButton.Visible = states.ShowShootButton and not ocultarPorRol
    end
    
    if ocultarPorRol or rolesPartida[LocalPlayer.Name] == "Murderer" then 
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
        
        -- calculo tracer rojo tradicional
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
        
        -- calculo see lead time (verde neon)
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

-- instanciacion del boton premium flotante
ShootButton = Instance.new("TextButton")
ShootButton.Name = "PremiumSheriffButton"
ShootButton.Size = UDim2.new(0, states.ButtonSize, 0, states.ButtonSize)
ShootButton.Position = UDim2.new(0.80, 0, 0.45, 0) 
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

local ButtonImage = Instance.new("ImageLabel")
ButtonImage.Name = "ButtonIcon"
ButtonImage.Size = UDim2.new(0.52, 0, 0.52, 0)
ButtonImage.Position = UDim2.new(0.5, 0, 0.47, 0) 
ButtonImage.AnchorPoint = Vector2.new(0.5, 0.5) 
ButtonImage.BackgroundTransparency = 1
ButtonImage.Image = "rbxassetid://12471956230"
ButtonImage.ZIndex = 12
ButtonImage.Parent = ShootButton

local ButtonText = Instance.new("TextLabel")
ButtonText.Name = "ButtonLabel"
ButtonText.Size = UDim2.new(1, 0, 0.25, 0)
ButtonText.Position = UDim2.new(0, 0, 0.76, 0) 
ButtonText.BackgroundTransparency = 1
ButtonText.Text = "SHOOT"
ButtonText.TextColor3 = Color3.fromRGB(240, 240, 240)
ButtonText.Font = Enum.Font.GothamBold
ButtonText.TextSize = 13 
ButtonText.ZIndex = 13
ButtonText.Parent = ShootButton

aplicarOpacidadGlobal(states.ButtonOpacity)

-- control anti-conflictos de arrastre y glow neon
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
            saveButtonConfig() 
        end
    end 
end)

print("✅ [KillerHub] Main combat script successfully loaded.")
