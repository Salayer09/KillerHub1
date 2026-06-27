
-- ============================================================================
-- 🚀 KILLER HUB - MÓDULO EXTRAS (V7.0 - OPTIMIZADO)
-- ============================================================================

local KillerHub
if _G.KillerHubInstance then
    KillerHub = _G.KillerHubInstance
else
    -- 🔒 Inyección protegida anti-404 con tu link de repositorio actualizado
    local success, result = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Salayer09/KILLERHUB3/refs/heads/main/Murder.lua"))()
    end)
    
    if success and result then
        KillerHub = result
        _G.KillerHubInstance = KillerHub
    else
        warn("❌ Error Crítico: No se pudo ejecutar el loadstring base desde Murder.lua. Detalles: " .. tostring(result))
        return
    end
end

-- ⏳ BUCLE DE ESPERA SEGURO: Valida que la API cargue sus funciones base
local maxIntentos = 20
local contador = 0
while (not KillerHub or type(KillerHub) ~= "table" or not KillerHub.CreateTab) and contador < maxIntentos do
    task.wait(0.2)
    contador = contador + 1
end

if not KillerHub or type(KillerHub) ~= "table" or not KillerHub.CreateTab then
    warn("❌ Error de Estructura: La API Base de la interfaz no se inicializó a tiempo.")
    return
end

-- 📂 CREACIÓN DE LA PESTAÑA PERSONALIZADA EXTRAS
local ExtrasTab = KillerHub:CreateTab("Extras </>", "rbxassetid://10747373142")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- ⚡ LOCALIZACIÓN DE FUNCIONES NATIVAS PARA MÁXIMO RENDIMIENTO
local Color3_fromRGB = Color3.fromRGB
local Vector3_new = Vector3.new
local string_find = string.find
local os_clock = os.clock 
local pairs = pairs
local ipairs = ipairs
local UDim2_new = UDim2.new
local math_round = math.round
local math_pow = math.pow
local task_spawn = task.spawn

-- 🔥 SALVAGUARDA ANTI-CRASH
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local OriginalCrosshairID = ""
local ARCHIVO_CONFIG = "KillerHub_PerfConfig.json"

-- 📊 MAPA CENTRALIZADO DE ESTADOS (Sincronizado con los componentes de la interfaz)
local states = {
    SpeedGlitchActive = false,
    SpeedGlitchPower = 55,
    
    CrosshairMasterEnabled = false,
    CrosshairRotationEnabled = false,
    CrosshairActiveID = "Original", 
    CrosshairSizeX = 45,
    CrosshairSizeY = 45,
    calculatedRotationSpeed = 47,
    
    CameraControlEnabled = false,
    StretchedResValue = 1.0,  
    
    CurrentAtmosphere = "Por Defecto",
    CurrentSkybox = "Por Defecto",
    MinecraftTexturesEnabled = false,
    
    knifeEspEnabled = false,
    statsBgTransparency = 0
}

-- ============================================================================
-- 💾 FUNCIONES DE CONFIGURACIÓN LOCAL (SISTEMA DE ARCHIVOS EXECUTOR)
-- ============================================================================
local function guardarPosicionLocal(xScale, xOffset, yScale, yOffset)
    local data = {
        X_Scale = xScale,
        X_Offset = xOffset,
        Y_Scale = yScale,
        Y_Offset = yOffset
    }
    pcall(function()
        if writefile then
            writefile(ARCHIVO_CONFIG, HttpService:JSONEncode(data))
        end
    end)
end

local function cargarPosicionLocal()
    local de_vuelta = {ScaleX = 0, OffsetX = 4, ScaleY = 0, OffsetY = 4}
    pcall(function()
        if readfile and isfile and isfile(ARCHIVO_CONFIG) then
            local decoded = HttpService:JSONDecode(readfile(ARCHIVO_CONFIG))
            if decoded then
                de_vuelta.ScaleX = decoded.X_Scale or de_vuelta.ScaleX
                de_vuelta.OffsetX = decoded.X_Offset or de_vuelta.OffsetX
                de_vuelta.ScaleY = decoded.Y_Scale or de_vuelta.ScaleY
                de_vuelta.OffsetY = decoded.Y_Offset or de_vuelta.OffsetY
            end
        end
    end)
    return de_vuelta
end

-- ============================================================================
-- 🏎️ MOTOR FÍSICO DEL SPEED GLITCH
-- ============================================================================
local function loopSpeedGlitch()
    task_spawn(function()
        local wallCheckParams = RaycastParams.new()
        wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude
        wallCheckParams.IgnoreWater = true
   
        while states.SpeedGlitchActive do
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if hum and root and hum.Health > 0 then
                local currentHandState = hum:GetState()
                local estaEscalando = (currentHandState == Enum.HumanoidStateType.Climbing)

                if hum.FloorMaterial == Enum.Material.Air and root.AssemblyLinearVelocity.Y > 0 and not estaEscalando then
                    local moveDir = hum.MoveDirection
                    if moveDir.Magnitude > 0 then
                        wallCheckParams.FilterDescendantsInstances = {char, workspace.CurrentCamera}
                        local rayoPared = workspace:Raycast(root.Position, moveDir * 2.2, wallCheckParams)
                        
                        if not rayoPared then
                            root.AssemblyLinearVelocity = Vector3_new(
                                moveDir.X * states.SpeedGlitchPower, 
                                root.AssemblyLinearVelocity.Y, 
                                moveDir.Z * states.SpeedGlitchPower
                            )
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait() 
        end
    end)
end

-- 🛠️ ASIGNACIÓN: MODIFICADORES DE MOVIMIENTO
ExtrasTab:CreateSection("Modificadores de Movimiento")

ExtrasTab:CreateToggle("E_SpeedGlitch", "Activar Speed Glitch (Físico)", function(estado)
    states.SpeedGlitchActive = estado
    if estado then loopSpeedGlitch() end
end)

ExtrasTab:CreateSlider("E_GlitchIntensity", "Fuerza del Glitch", 1, 200, function(valor)
    states.SpeedGlitchPower = valor
end)

-- ============================================================================
-- 🎯 SISTEMA DE MIRA CON CACHÉ
-- ============================================================================
local currentRotationDegrees = 0
local cachedCrosshairs = {}
local lastCrosshairUpdate = 0

local crosshairList = {
    "5998624778", "4941755392", "11719595104", "119672509101087", "11759192985",
    "5124214183", "13380318482", "11759192985", "8138092208", "17123709960",
    "12554863225", "5124214183", "78920076068446", "13070257771", "4618023421",
    "2149935582", "5456882455", "86534793846898", "71895353135208", "10644137227",
    "11767037107", "5995357646", "8680062686", "11826465934", "9871562353"
}

local dropdownOptions = {"Mira Original"}
for i = 1, #crosshairList do table.insert(dropdownOptions, "Mira N° " .. i) end

local function localizarObjetosCrosshair()
    local elementosencontrados = {}
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            local mainGui = playerGui:FindFirstChild("MainGUI")
            local gameFrame = mainGui and mainGui:FindFirstChild("Game")
            local crosshairFrame = gameFrame and gameFrame:FindFirstChild("Crosshair")
            if crosshairFrame then
                if crosshairFrame:IsA("ImageLabel") or crosshairFrame:IsA("ImageButton") then table.insert(elementosencontrados, crosshairFrame) end
                for _, obj in ipairs(crosshairFrame:GetDescendants()) do
                    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then table.insert(elementosencontrados, obj) end
                end
            end
            
            local topbar = playerGui:FindFirstChild("GameTopbar")
            local topbarCH = topbar and topbar:FindFirstChild("Crosshair")
            if topbarCH then
                if topbarCH:IsA("ImageLabel") or topbarCH:IsA("ImageButton") then table.insert(elementosencontrados, topbarCH) end
                for _, obj in ipairs(topbarCH:GetDescendants()) do
                    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then table.insert(elementosencontrados, obj) end
                end
            end
        end
    end)
    return elementosencontrados
end

-- 🛠️ ASIGNACIÓN: PERSONALIZACIÓN DE MIRA
ExtrasTab:CreateSection("Personalización de Mira")

ExtrasTab:CreateToggle("C_MasterToggle", "Activar Modificación de Mira", function(estado)
    states.CrosshairMasterEnabled = estado
    if estado then cachedCrosshairs = localizarObjetosCrosshair() end
end)

ExtrasTab:CreateDropdown("C_SelectDropdown", "Seleccionar Diseño de Mira:", dropdownOptions, function(seleccion)
    if seleccion == "Mira Original" then 
        states.CrosshairActiveID = "Original"
    else
        local numero = tonumber(seleccion:match("%d+"))
        if numero and crosshairList[numero] then states.CrosshairActiveID = crosshairList[numero] end
    end
end)

ExtrasTab:CreateSlider("C_SizeX", "Ancho de la Mira (Eje X)", 1, 200, function(valor) states.CrosshairSizeX = valor end)
ExtrasTab:CreateSlider("C_SizeY", "Alto de la Mira (Eje Y)", 1, 200, function(valor) states.CrosshairSizeY = valor end)

ExtrasTab:CreateSection("Efecto de Rotación")
ExtrasTab:CreateToggle("C_RotateToggle", "Habilitar Giro Continuo", function(estado)
    states.CrosshairRotationEnabled = estado
    if not estado then currentRotationDegrees = 0 end
end)

ExtrasTab:CreateSlider("C_RotSpeed", "Ajuste de Velocidad de Giro", 0, 100, function(valor) 
    states.calculatedRotationSpeed = (valor * 2) + (math_pow(valor, 2) * 0.12)
end)

-- ============================================================================
-- 👑 MÓDULO: CONTROL DE CÁMARA MEJORADO
-- ============================================================================
ExtrasTab:CreateSection("Configuración de Cámara")

ExtrasTab:CreateToggle("Cam_ControlToggle", "Activar Ajustes de Cámara", function(estado)
    states.CameraControlEnabled = estado
    local camera = Workspace.CurrentCamera
    if not estado then
        if camera then camera.FieldOfView = 70 end
    end
end)

ExtrasTab:CreateSlider("Cam_TrueStretched", "Verdadera Res. Estirada (%)", 40, 100, function(valor)
    states.StretchedResValue = valor / 100
end)

-- ============================================================================
-- 🪐 MÓDULO: AMBIENTE VISUAL & MOTOR MINECRAFT OPTIMIZADO
-- ============================================================================
local lastLightingEnforce = 0
local originalMapLights = {}
local originalNeonParts = {}
local originalBloomSettings = {}
local originalMaterials = {}

local originalLightingSettings = {
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation,
    EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
    EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
}

local MinecraftAssets = {
    Stone       = "rbxassetid://117292871457681",
    WoodPlanks  = "rbxassetid://87376137354977",
    Grass       = "rbxassetid://96094743851836",
    RedWool     = "rbxassetid://12618677424",
    Brick       = "rbxassetid://13017216585", -- ✨ Tus nuevas IDs integradas
    Obsidiana   = "rbxassetid://10480259773",
    Iron        = "rbxassetid://8677286748",
    Glass       = "rbxassetid://11384458772"
}

local function restaurarLucesYBrillos()
    for light, oldProps in pairs(originalMapLights) do
        if light and light.Parent then 
            light.Enabled = oldProps.Enabled 
            light.Brightness = oldProps.Brightness
        end
    end
    for part, oldMat in pairs(originalNeonParts) do
        if part and part.Parent then part.Material = oldMat end
    end
    for effect, oldProps in pairs(originalBloomSettings) do
        if effect and effect.Parent then 
            effect.Enabled = oldProps.Enabled
            effect.Intensity = oldProps.Intensity
        end
    end
    table.clear(originalMapLights)
    table.clear(originalNeonParts)
    table.clear(originalBloomSettings)
end

local function procesarBloqueMinecraft(part, activar)
    if not part:IsA("BasePart") then return end
    if part.Transparency > 0.4 and part.Material ~= Enum.Material.Glass then return end 
    local size = part.Size
    if (size.X * size.Y * size.Z) < 3.5 then return end 
    
    local mat = part.Material
    if mat == Enum.Material.Neon or mat == Enum.Material.ForceField then return end
    if part:IsDescendantOf(Players) or part.Name == "Handle" or part.Name == "Knife" or part.Name == "Gun" then return end

    if activar then
        local materialName = mat.Name
        local partColor = part.Color
        local textureId = nil
        
        if string_find(materialName, "Grass") or string_find(materialName, "Terrain") or (partColor.G > 0.38 and partColor.R < 0.4 and partColor.B < 0.4) then
            textureId = MinecraftAssets.Grass
        elseif string_find(materialName, "Fabric") or string_find(materialName, "Carpet") or (partColor.R > 0.35 and partColor.G < 0.15 and partColor.B < 0.15 and size.Y <= 1) then
            textureId = MinecraftAssets.RedWool
        elseif string_find(materialName, "Wood") or string_find(materialName, "Plank") then
            textureId = MinecraftAssets.WoodPlanks
        elseif string_find(materialName, "Glass") then
            textureId = MinecraftAssets.Glass
        elseif string_find(materialName, "Brick") then
            textureId = MinecraftAssets.Brick
        elseif string_find(materialName, "Metal") or string_find(materialName, "DiamondPlate") or string_find(materialName, "CorrodedMetal") then
            if partColor.R < 0.25 and partColor.G < 0.25 and partColor.B < 0.25 then
                textureId = MinecraftAssets.Obsidiana
            else
                textureId = MinecraftAssets.Iron
            end
        elseif string_find(materialName, "Stone") or string_find(materialName, "Slate") or string_find(materialName, "Rock") or string_find(materialName, "Concrete") or string_find(materialName, "Cement") then
            textureId = MinecraftAssets.Stone
        end

        if textureId then
            if not originalMaterials[part] then
                originalMaterials[part] = {Material = part.Material, Color = part.Color}
            end
            
            part.Material = Enum.Material.SmoothPlastic
            
            for _, face in ipairs(Enum.NormalId:GetEnumItems()) do
                local texName = "MC_" .. face.Name
                local existingTex = part:FindFirstChild(texName)
                if not existingTex then
                    local tex = Instance.new("Texture")
                    tex.Name = texName
                    tex.Texture = textureId
                    tex.Face = face
                    tex.StudsPerTileU = 2
                    tex.StudsPerTileV = 2
                    tex.Parent = part
                end
            end
        end
    else
        if originalMaterials[part] then
            part.Material = originalMaterials[part].Material
            part.Color = originalMaterials[part].Color
        end
        for _, obj in ipairs(part:GetChildren()) do
            if string_find(obj.Name, "MC_") then obj:Destroy() end
        end
    end
end

local function actualizarMapaCompletoMinecraft(estado)
    task_spawn(function()
        local todosLosBloques = Workspace:GetDescendants()
        for i = 1, #todosLosBloques do
            procesarBloqueMinecraft(todosLosBloques[i], estado)
            if i % 150 == 0 then task.wait() end 
        end
        if not estado then
            table.clear(originalMaterials)
        end
    end)
end

Workspace.DescendantAdded:Connect(function(desc)
    if states.MinecraftTexturesEnabled then
        task.defer(function()
            procesarBloqueMinecraft(desc, true)
        end)
    end
end)

local function escanearLucesYNeon(esClimaOscuro)
    task_spawn(function()
        local desc = Workspace:GetDescendants()
        for i = 1, #desc do
            local obj = desc[i]
            
            if obj:IsA("Light") then
                if originalMapLights[obj] == nil then
                    originalMapLights[obj] = {Enabled = obj.Enabled, Brightness = obj.Brightness}
                end
                if esClimaOscuro then
                    obj.Enabled = true
                    obj.Brightness = math.min(originalMapLights[obj].Brightness, 0.25)
                else
                    obj.Enabled = originalMapLights[obj].Enabled
                end
            elseif obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
                if originalNeonParts[obj] == nil then
                    originalNeonParts[obj] = obj.Material
                end
                obj.Material = Enum.Material.SmoothPlastic
            end
            
            if i % 200 == 0 then task.wait() end 
        end
    end)
end

local function aplicarAtmosphere(tipo)
    local esClimaOscuro = (tipo == "Anochecer" or tipo == "Media Noche (Apagón)" or tipo == "Tormenta Oscura")
    
    Lighting.EnvironmentSpecularScale = esClimaOscuro and 0.12 or 0
    Lighting.EnvironmentDiffuseScale = esClimaOscuro and 0.25 or 0
    
    if tipo == "Anochecer" then
        Lighting.ClockTime = 18.9
        Lighting.Brightness = 0.75
        Lighting.Ambient = Color3_fromRGB(85, 85, 110)
        Lighting.OutdoorAmbient = Color3_fromRGB(70, 70, 95)
        Lighting.ExposureCompensation = -0.05
    elseif tipo == "Media Noche (Apagón)" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0.40 
        Lighting.Ambient = Color3_fromRGB(60, 60, 75)
        Lighting.OutdoorAmbient = Color3_fromRGB(45, 45, 60)
        Lighting.ExposureCompensation = -0.15
    elseif tipo == "Tormenta Oscura" then
        Lighting.ClockTime = 14.5
        Lighting.Brightness = 0.55
        Lighting.Ambient = Color3_fromRGB(75, 80, 85)
        Lighting.OutdoorAmbient = Color3_fromRGB(60, 65, 70)
        Lighting.ExposureCompensation = -0.10
    end

    escanearLucesYNeon(esClimaOscuro)

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("BloomEffect") then
            if originalBloomSettings[effect] == nil then
                originalBloomSettings[effect] = {Enabled = effect.Enabled, Intensity = effect.Intensity}
            end
            if esClimaOscuro then
                effect.Enabled = true
                effect.Intensity = 0.05 
            else
                effect.Enabled = false
            end
        end
    end
end

local function aplicarSkybox(tipo)
    local sky = Lighting:FindFirstChild("KillerHubSky")
    
    if tipo == "Por Defecto" then
        if sky then sky:Destroy() end
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Sky") and obj.Name ~= "KillerHubSky" then obj.Enabled = true end
        end
        return
    end

    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") and obj.Name ~= "KillerHubSky" then obj.Enabled = false end
    end

    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "KillerHubSky"
        sky.Parent = Lighting
    end

    sky.CelestialBodiesShown = false 

    if tipo == "Galaxia Cósmica" then
        sky.SkyboxBk = "rbxassetid://159454299"
        sky.SkyboxDn = "rbxassetid://159454296"
        sky.SkyboxFt = "rbxassetid://159454293"
        sky.SkyboxLf = "rbxassetid://159454286"
        sky.SkyboxRt = "rbxassetid://159454300"
        sky.SkyboxUp = "rbxassetid://159454288"
    end
end

-- 🛠️ ASIGNACIÓN: AMBIENTE VISUAL
ExtrasTab:CreateSection("Ambiente Visual")

local listaClimas = {"Por Defecto", "Anochecer", "Media Noche (Apagón)", "Tormenta Oscura"}
ExtrasTab:CreateDropdown("E_SkyAtmosphere", "Seleccionar Clima / Hora:", listaClimas, function(seleccion)
    states.CurrentAtmosphere = seleccion
    if seleccion == "Por Defecto" then
        restaurarLucesYBrillos()
        Lighting.ClockTime = originalLightingSettings.ClockTime
        Lighting.Brightness = originalLightingSettings.Brightness
        Lighting.Ambient = originalLightingSettings.Ambient
        Lighting.OutdoorAmbient = originalLightingSettings.OutdoorAmbient
        Lighting.ExposureCompensation = originalLightingSettings.ExposureCompensation
        Lighting.EnvironmentSpecularScale = originalLightingSettings.EnvironmentSpecularScale or 1
        Lighting.EnvironmentDiffuseScale = originalLightingSettings.EnvironmentDiffuseScale or 1
    else
        aplicarAtmosphere(seleccion)
    end
end)

local listaSkyboxes = { "Por Defecto", "Galaxia Cósmica" }
ExtrasTab:CreateDropdown("E_CustomSkybox", "Modificar Cielo (Skybox):", listaSkyboxes, function(seleccion)
    states.CurrentSkybox = seleccion
    aplicarSkybox(seleccion)
end)

ExtrasTab:CreateToggle("E_MinecraftMode", "Modo Minecraft (Texturas 16x16)", function(estado)
    states.MinecraftTexturesEnabled = estado
    actualizarMapaCompletoMinecraft(estado)
end)

-- ============================================================================
-- 🔪 MÓDULO INTEGRADO: KNIFE TRACKER ESP
-- ============================================================================
local knifeStates = {}
local lastScanTime = 0
local SCAN_INTERVAL = 0.05 

local Knife3DBox = Instance.new("BoxHandleAdornment")
Knife3DBox.Color3 = Color3_fromRGB(0, 255, 100)
Knife3DBox.Transparency = 0.25 
Knife3DBox.AlwaysOnTop = true 
Knife3DBox.ZIndex = 5 
Knife3DBox.Parent = CoreGui
Knife3DBox.Visible = false

local function obtenerMurderer()
    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local v = playersList[i]
        if v ~= LocalPlayer and v.Character then
            local backpack = v:FindFirstChild("Backpack")
            local tieneCuchillo = v.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife"))

            if tieneCuchillo then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local targetPart = v.Character:FindFirstChild("Torso") or v.Character:FindFirstChild("UpperTorso") or v.Character:FindFirstChild("HumanoidRootPart")
                    return targetPart, v.Character 
                end
            end
        end
    end
    return nil, nil
end

local function buscarCuchilloFisico(charTarget)
    if charTarget then
        local knifeTool = charTarget:FindFirstChild("Knife")
        if knifeTool and knifeTool:FindFirstChild("Handle") then 
            return knifeTool.Handle 
        end
    end
    return nil
end

-- 🛠️ ASIGNACIÓN: RASTREADOR DE CUCHILLOS
ExtrasTab:CreateSection("Rastreador de Cuchillos")

ExtrasTab:CreateToggle("KnifeTrackerESP", "Knife Tracker ESP (Equipado y Lanzado)", function(estado)
    states.knifeEspEnabled = estado
    if not estado then
        Knife3DBox.Visible = false
        for _, obj in ipairs(Workspace:GetChildren()) do
            local hl = obj:FindFirstChild("KillerHubKnifeHighlight")
            if hl then hl:Destroy() end
        end
        table.clear(knifeStates)
    end
end)

-- ============================================================================
-- 🔄 BUCLE UNIFICADO DE ALTO RENDIMIENTO (RENDERSTEPPED)
-- ============================================================================
RunService.RenderStepped:Connect(function(dt)
    local tiempoActual = os_clock()

    -- 🔴 CONTROL DE CÁMARA
    if states.CameraControlEnabled then
        local camera = Workspace.CurrentCamera
        if camera then
            if camera.FieldOfView ~= 70 then camera.FieldOfView = 70 end
            if states.StretchedResValue < 1.0 then
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, states.StretchedResValue, 0, 0, 0, 1)
            end
        end
    end

    -- 🔴 CONTROL DE MIRA RETICULAR
    if states.CrosshairMasterEnabled then
        if tiempoActual - lastCrosshairUpdate > 2 or #cachedCrosshairs == 0 then
            cachedCrosshairs = localizarObjetosCrosshair()
            lastCrosshairUpdate = tiempoActual
        end

        if OriginalCrosshairID == "" and #cachedCrosshairs > 0 then
            for _, uiElement in ipairs(cachedCrosshairs) do
                if uiElement.Image ~= "" and not string_find(uiElement.Image, "0") then
                    local esPersonalizada = false
                    for _, id in ipairs(crosshairList) do
                        if string_find(uiElement.Image, id) then esPersonalizada = true break end
                    end
                    if not esPersonalizada then OriginalCrosshairID = uiElement.Image break end
                end
            end
        end

        if #cachedCrosshairs > 0 then
            if states.CrosshairRotationEnabled then
                currentRotationDegrees = (currentRotationDegrees + (states.calculatedRotationSpeed * dt)) % 360
            end
             
            local targetID = states.CrosshairActiveID == "Original" and OriginalCrosshairID or ("rbxassetid://" .. states.CrosshairActiveID)
            for _, uiElement in ipairs(cachedCrosshairs) do
                pcall(function()
                    if targetID ~= "" then uiElement.Image = targetID end
                    uiElement.Size = UDim2_new(0, states.CrosshairSizeX, 0, states.CrosshairSizeY)
                    uiElement.Rotation = currentRotationDegrees
                end)
            end
        end
    end

    -- 🔴 MANTENIMIENTO LIGERO DE ILUMINACIÓN
    if tiempoActual - lastLightingEnforce > 0.8 then
        if states.CurrentAtmosphere ~= "Por Defecto" then
            if states.CurrentAtmosphere == "Anochecer" then Lighting.ClockTime = 18.9
            elseif states.CurrentAtmosphere == "Media Noche (Apagón)" then Lighting.ClockTime = 0
            elseif states.CurrentAtmosphere == "Tormenta Oscura" then Lighting.ClockTime = 14.5 end
        end
        lastLightingEnforce = tiempoActual
    end

    -- 🟢 RASTREADOR DE CUCHILLOS INDEPENDIENTE
    if states.knifeEspEnabled then
        local mBodyPart, charTarget = obtenerMurderer()
        if charTarget then
            local objCuchillo = buscarCuchilloFisico(charTarget)
            if objCuchillo and objCuchillo:IsA("BasePart") then
                if Knife3DBox.Adornee ~= objCuchillo then 
                    Knife3DBox.Adornee = objCuchillo 
                    Knife3DBox.Size = objCuchillo.Size + Vector3_new(0.4, 0.4, 0.4) 
                end
                Knife3DBox.Visible = true
            else 
                Knife3DBox.Visible = false 
            end
        else 
            Knife3DBox.Visible = false 
        end

        if tiempoActual - lastScanTime >= SCAN_INTERVAL then
            lastScanTime = tiempoActual

            for knife in pairs(knifeStates) do 
                if not knife or not knife.Parent then 
                    knifeStates[knife] = nil 
                end 
            end
            
            local workspaceChildren = Workspace:GetChildren()
            for i = 1, #workspaceChildren do
                local obj = workspaceChildren[i]
                if (obj:IsA("BasePart") or obj:IsA("Model")) and (string_find(obj.Name, "Knife") or string_find(obj.Name, "Weapon")) then
                    if not obj:IsDescendantOf(Players) then
                        local mainPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                        if mainPart then
                            local currentPos = mainPart.Position
                            local state = knifeStates[obj]
                            local isMoving = true
          
                            if not state then 
                                knifeStates[obj] = {lastPosition = currentPos, framesStuck = 0}
                            else
                                local distanceMoved = (currentPos - state.lastPosition).Magnitude
                                if distanceMoved < 0.05 then 
                                    state.framesStuck = state.framesStuck + 1 
                                else 
                                    state.framesStuck = 0 
                                end
                   
                                state.lastPosition = currentPos
                        
                                if state.framesStuck > 3 then 
                                    isMoving = false 
                                end
                            end
                            
                            local hl = obj:FindFirstChild("KillerHubKnifeHighlight")
                            if isMoving then
                                if not hl then
                                    hl = Instance.new("Highlight")
                                    hl.Name = "KillerHubKnifeHighlight"
                                    hl.FillColor = Color3_fromRGB(136, 0, 0)      
                                    hl.FillTransparency = 0.35 
                                    hl.OutlineColor = Color3_fromRGB(255, 0, 0)    
                                    hl.OutlineTransparency = 0
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Parent = obj
                                end
                            else 
                                if hl then hl:Destroy() end 
                            end
                        end
                    end
                end
            end
        end
    else
        if Knife3DBox.Visible then Knife3DBox.Visible = false end
    end
end)

-- ============================================================================
-- 🛠️ ASIGNACIÓN: MONITOREO DE SISTEMA (CON AUTOGUARDADO DE POSICIÓN)
-- ============================================================================
ExtrasTab:CreateSection("Monitoreo de Sistema")
ExtrasTab:CreateToggle("E_PerformanceStats", "Mostrar Contador de Rendimiento", function(estado)
    if CoreGui:FindFirstChild("KillerHub_PerformanceOverlay") then
        CoreGui.KillerHub_PerformanceOverlay:Destroy()
    end
    if statsConnection then 
        statsConnection:Disconnect() 
        statsConnection = nil 
    end

    if estado then
        local UserInputService = game:GetService("UserInputService")
        
        statsGui = Instance.new("ScreenGui")
        statsGui.Name = "KillerHub_PerformanceOverlay"
        statsGui.Parent = CoreGui

        -- Carga la última ubicación que salvaste
        local posGuardada = cargarPosicionLocal()

        statsFrame = Instance.new("Frame", statsGui)
        statsFrame.Size = UDim2_new(0, 145, 0, 75)
        statsFrame.Position = UDim2_new(posGuardada.ScaleX, posGuardada.OffsetX, posGuardada.ScaleY, posGuardada.OffsetY)
        statsFrame.BackgroundColor3 = Color3_fromRGB(12, 4, 22)
        statsFrame.BackgroundTransparency = states.statsBgTransparency
        statsFrame.BorderSizePixel = 0
        statsFrame.Active = true

        local Corner = Instance.new("UICorner", statsFrame) Corner.CornerRadius = UDim.new(0, 8)
        local Stroke = Instance.new("UIStroke", statsFrame) Stroke.Thickness = 1.2 Stroke.Color = Color3_fromRGB(24, 8, 42)

        local TextLabel = Instance.new("TextLabel", statsFrame)
        TextLabel.Size = UDim2_new(1, -10, 1, -10)
        TextLabel.Position = UDim2_new(0, 10, 0, 5)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.TextColor3 = Color3_fromRGB(230, 230, 230)
        TextLabel.TextSize = 12
        TextLabel.LineHeight = 1.3
        TextLabel.RichText = true
        TextLabel.Text = "Calculando..."

        -- 🔒 BOTÓN DE BLOQUEO / DESBLOQUEO DE POSICIÓN
        local LockButton = Instance.new("TextButton", statsFrame)
        LockButton.Size = UDim2_new(0, 16, 0, 16)
        LockButton.Position = UDim2_new(1, -20, 0, 6)
        LockButton.BackgroundTransparency = 1
        LockButton.Font = Enum.Font.GothamBold
        LockButton.TextSize = 11
        LockButton.TextColor3 = Color3_fromRGB(0, 255, 120)
        LockButton.Text = "🔓"
        
        local posicionBloqueada = false

        LockButton.MouseButton1Click:Connect(function()
            posicionBloqueada = not posicionBloqueada
            if posicionBloqueada then
                LockButton.Text = "🔒"
                LockButton.TextColor3 = Color3_fromRGB(255, 65, 65)
            else
                LockButton.Text = "🔓"
                LockButton.TextColor3 = Color3_fromRGB(0, 255, 120)
            end
        end)

        -- 🖐️ SISTEMA NATIVO DE ARRASTRE (DRAG) CON RESPALDO AL SOLTAR
        local dragging, dragInput, dragStart, startPos

        statsFrame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not posicionBloqueada then
                dragging = true
                dragStart = input.Position
                startPos = statsFrame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        -- 💾 Guarda en disco al levantar el dedo o soltar clic
                        guardarPosicionLocal(
                            statsFrame.Position.X.Scale, 
                            statsFrame.Position.X.Offset, 
                            statsFrame.Position.Y.Scale, 
                            statsFrame.Position.Y.Offset
                        )
                    end
                end)
            end
        end)

        statsFrame.InputChanged:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and not posicionBloqueada then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging and not posicionBloqueada then
                local delta = input.Position - dragStart
                statsFrame.Position = UDim2_new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            end
        end)

        -- 📊 BUCLE DE ACTUALIZACIÓN DE DATOS (FPS / PING / RAM)
        local lastTime = os_clock()
        local frameCount = 0
        local currentFps = 60

        local pingObject = nil
        pcall(function() pingObject = Stats.Network.ServerStatsItem["Data Ping"] end)

        statsConnection = RunService.Heartbeat:Connect(function()
            frameCount = frameCount + 1
            local currentTime = os_clock()
            
            if currentTime - lastTime >= 0.3 then
                currentFps = math_round(frameCount / (currentTime - lastTime))
                frameCount = 0
                lastTime = currentTime

                local ping = 0
                if pingObject then
                    pcall(function() ping = math_round(pingObject:GetValue()) end)
                else
                    pcall(function() ping = math_round(LocalPlayer:GetNetworkPing() * 1000) end)
                end
                
                local memoria = math_round(Stats:GetTotalMemoryUsageMb())

                TextLabel.Text = string.format(
                    "FPS:  <font color=\"rgb(140,45,255)\">%d</font>\nPING: <font color=\"rgb(0,255,120)\">%d ms</font>\nRAM:  <font color=\"rgb(240,240,240)\">%d MB</font>",
                    currentFps, ping, memoria
                )
            end
        end)
    end
end)

ExtrasTab:CreateSection("Estilo de Interfaz")

ExtrasTab:CreateSlider("E_StatsOpacity", "Transparencia Fondo (%)", 0, 100, function(valor)
    states.statsBgTransparency = valor / 100
    if statsFrame then statsFrame.BackgroundTransparency = states.statsBgTransparency end
end)

-- 💡 RETORNO EXIGIDO PARA LA CADENA INFINITA DE INTEGRACIÓN DE APIS
return KillerHub
