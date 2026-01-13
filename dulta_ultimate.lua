-- Улучшенный Dulta Ultimate v23.1
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- Создаем иконку меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DultaUIMain"
ScreenGui.Parent = game.CoreGui

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "DultaMenuToggle"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.BackgroundTransparency = 0.3
OpenButton.BorderSizePixel = 0
OpenButton.Position = UDim2.new(0, 20, 0.5, -25)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Image = "rbxassetid://7072725342"
OpenButton.ZIndex = 1000

local OpenButtonCorner = Instance.new("UICorner")
OpenButtonCorner.CornerRadius = UDim.new(0.2, 0)
OpenButtonCorner.Parent = OpenButton

local OpenButtonText = Instance.new("TextLabel")
OpenButtonText.Name = "MenuLabel"
OpenButtonText.Parent = OpenButton
OpenButtonText.BackgroundTransparency = 1
OpenButtonText.Position = UDim2.new(0, 0, 1, 5)
OpenButtonText.Size = UDim2.new(1, 0, 0, 20)
OpenButtonText.Font = Enum.Font.SourceSansBold
OpenButtonText.Text = "Dulta"
OpenButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButtonText.TextSize = 14
OpenButtonText.ZIndex = 1000

-- Загружаем библиотеку после создания иконки
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dulta Ultimate v23.1", "BloodTheme")

-- Скрываем окно при запуске
Window.Main.Visible = false

-- Настройки
getgenv().DultaConfig = {
    AimEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimFOV = 100,
    AimSmoothness = 0.2,
    AimPart = "Head",
    
    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    
    FlyEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 16,
    SpeedKey = Enum.KeyCode.LeftShift,
    
    AntiCheat = {
        AntiAimDetection = true,
        RandomizeActions = false,
        HideTraces = false
    }
}

-- Вкладки
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Aim Features")

local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("ESP Settings")

local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Movement Hacks")

local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Configuration")

-- Функция открытия/закрытия меню
OpenButton.MouseButton1Click:Connect(function()
    Window.Main.Visible = not Window.Main.Visible
    if Window.Main.Visible then
        -- Позиционируем меню рядом с кнопкой
        Window.Main.Position = UDim2.new(0, 80, 0.5, -150)
    end
end)

-- Закрытие меню при клике на крестик
Window.Main.CloseButton.MouseButton1Click:Connect(function()
    Window.Main.Visible = false
end)

-- Улучшенный ESP
local ESPObjects = {}
local function createESP(player)
    if not player or player == LP then return end
    if not player.Character then return end
    
    local char = player.Character
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Определяем цвет
    local isEnemy = true
    if player.Team and LP.Team then
        isEnemy = player.Team ~= LP.Team
    end
    
    local color
    if isEnemy then
        color = Color3.fromRGB(255, 50, 50)  -- Красный для врагов
    else
        color = Color3.fromRGB(50, 255, 50)  -- Зеленый для тиммейтов
    end
    
    -- Создаем Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "DultaESP"
    highlight.Adornee = char
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = game.CoreGui
    
    -- Информационная доска
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DultaInfo"
    billboard.Adornee = char:WaitForChild("HumanoidRootPart", 2) or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
    if not billboard.Adornee then
        highlight:Destroy()
        billboard:Destroy()
        return
    end
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 500
    billboard.Parent = game.CoreGui
    
    -- Имя игрока
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "PlayerName"
    nameLabel.Parent = billboard
    nameLabel.BackgroundTransparency = 1
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = color
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0.5
    
    -- ХП игрока
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "PlayerHealth"
    healthLabel.Parent = billboard
    healthLabel.BackgroundTransparency = 1
    healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    healthLabel.Font = Enum.Font.SourceSans
    healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
    healthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthLabel.TextSize = 14
    
    ESPObjects[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Character = char,
        Humanoid = humanoid
    }
    
    -- Обновление хп
    local connection
    connection = humanoid.HealthChanged:Connect(function()
        if healthLabel and healthLabel.Parent then
            healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
        end
    end)
    
    table.insert(ESPObjects[player].Connections or {}, connection)
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight then
            ESPObjects[player].Highlight:Destroy()
        end
        if ESPObjects[player].Billboard then
            ESPObjects[player].Billboard:Destroy()
        end
        if ESPObjects[player].Connections then
            for _, conn in ipairs(ESPObjects[player].Connections) do
                conn:Disconnect()
            end
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            if getgenv().DultaConfig.ESPEnabled then
                if not ESPObjects[player] and player.Character then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
    
    -- Удаляем ESP для игроков которые вышли
    for player, data in pairs(ESPObjects) do
        if not Players:FindFirstChild(player.Name) then
            removeESP(player)
        end
    end
end

-- Дроны
local DroneESP = {}
local function updateDroneESP()
    if not getgenv().DultaConfig.ESPEnabled then return end
    
    for _, obj in pairs(workspace:GetChildren()) do
        local name = obj.Name:lower()
        if (name:find("drone") or name:find("uav")) and obj:IsA("Model") then
            if not DroneESP[obj] then
                local highlight = Instance.new("Highlight")
                highlight.Name = "DultaDroneESP"
                highlight.Adornee = obj
                highlight.FillColor = Color3.fromRGB(255, 165, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0
                highlight.Parent = game.CoreGui
                
                DroneESP[obj] = highlight
            end
        end
    end
    
    -- Удаляем уничтоженные дроны
    for drone, highlight in pairs(DroneESP) do
        if not drone or not drone.Parent then
            highlight:Destroy()
            DroneESP[drone] = nil
        end
    end
end

-- Улучшенный аимбот
local function getClosestEnemy()
    local target = nil
    local closestDistance = getgenv().DultaConfig.AimFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LP then continue end
        
        -- Проверяем команду
        local isEnemy = true
        if player.Team and LP.Team then
            isEnemy = player.Team ~= LP.Team
        end
        
        if isEnemy and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local aimPart = player.Character:FindFirstChild(getgenv().DultaConfig.AimPart)
                
                if rootPart and aimPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local aimPos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (mousePos - aimPos).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            target = aimPart
                        end
                    end
                end
            end
        end
    end
    
    return target
end

-- Полет
local flyBodyVelocity, flyBodyGyro
local function toggleFly(state)
    if not LP.Character then return end
    local humanoid = LP.Character:FindFirstChild("Humanoid")
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    if state then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        flyBodyVelocity.P = 1250
        flyBodyVelocity.Parent = root
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.MaxTorque = Vector3.new(50000, 50000, 50000)
        flyBodyGyro.P = 1000
        flyBodyGyro.Parent = root
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    end
end

-- Настройки UI
CombatSection:NewToggle("Aimbot", "Автоматическое наведение", function(state)
    getgenv().DultaConfig.AimEnabled = state
end)

CombatSection:NewDropdown("Aim Part", "Часть тела для аима", {"Head", "HumanoidRootPart", "UpperTorso"}, function(part)
    getgenv().DultaConfig.AimPart = part
end)

CombatSection:NewSlider("Aim FOV", "Угол обзора аима", 500, 50, function(value)
    getgenv().DultaConfig.AimFOV = value
end)

CombatSection:NewSlider("Smoothness", "Плавность наведения", 100, 1, function(value)
    getgenv().DultaConfig.AimSmoothness = value / 100
end)

VisualsSection:NewToggle("ESP Players", "Показать игроков", function(state)
    getgenv().DultaConfig.ESPEnabled = state
    if not state then
        for player in pairs(ESPObjects) do
            removeESP(player)
        end
        for drone, highlight in pairs(DroneESP) do
            highlight:Destroy()
        end
        DroneESP = {}
    end
end)

VisualsSection:NewToggle("ESP Drones", "Показать дроны", function(state)
    getgenv().DultaConfig.ESPDrones = state
end)

VisualsSection:NewToggle("Show Names", "Показать имена", function(state)
    getgenv().DultaConfig.ESPName = state
    -- Обновляем ESP
    for player, data in pairs(ESPObjects) do
        if data.Billboard then
            data.Billboard.Enabled = state
        end
    end
end)

VisualsSection:NewToggle("Show Health", "Показать здоровье", function(state)
    getgenv().DultaConfig.ESPHealth = state
end)

MovementSection:NewToggle("Fly", "Включить полет (Hover)", function(state)
    getgenv().DultaConfig.FlyEnabled = state
    toggleFly(state)
end)

MovementSection:NewToggle("Speed Hack", "Ускорение", function(state)
    getgenv().DultaConfig.SpeedEnabled = state
end)

MovementSection:NewSlider("Speed Value", "Значение скорости", 100, 16, function(value)
    getgenv().DultaConfig.SpeedValue = value
end)

SettingsSection:NewToggle("Anti-Cheat Bypass", "Обход античита", function(state)
    getgenv().DultaConfig.AntiCheat.AntiAimDetection = state
end)

SettingsSection:NewButton("Refresh ESP", "Обновить ESP", function()
    for player in pairs(ESPObjects) do
        removeESP(player)
    end
    updateESP()
end)

SettingsSection:NewButton("Unload Menu", "Выгрузить меню", function()
    ScreenGui:Destroy()
    Window:Destroy()
    getgenv().DultaConfig = nil
end)

-- Основной цикл
local aimbotConnection
RS.RenderStepped:Connect(function()
    -- ESP
    updateESP()
    updateDroneESP()
    
    -- Аимбот
    if getgenv().DultaConfig.AimEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy()
        if target then
            local cameraCFrame = Camera.CFrame
            local targetPosition = target.Position
            local newCFrame = CFrame.new(cameraCFrame.Position, targetPosition)
            Camera.CFrame = cameraCFrame:Lerp(newCFrame, getgenv().DultaConfig.AimSmoothness)
        end
    end
    
    -- Движение
    if LP.Character then
        local humanoid = LP.Character:FindFirstChild("Humanoid")
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and root then
            -- Speed Hack
            if getgenv().DultaConfig.SpeedEnabled and humanoid.MoveDirection.Magnitude > 0 then
                local moveDir = humanoid.MoveDirection
                root.CFrame = root.CFrame + (moveDir * (getgenv().DultaConfig.SpeedValue / 100))
            end
            
            -- Fly
            if getgenv().DultaConfig.FlyEnabled and flyBodyVelocity then
                local moveDirection = Vector3.new(0, 0, 0)
                
                -- Управление полетом
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end
                
                if moveDirection.Magnitude > 0 then
                    flyBodyVelocity.Velocity = moveDirection.Unit * 50
                else
                    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                end
                
                if flyBodyGyro then
                    flyBodyGyro.CFrame = Camera.CFrame
                end
            end
        end
    end
end)

-- Очистка при выходе
game.Players.PlayerRemoving:Connect(function(player)
    if player == LP then
        for p in pairs(ESPObjects) do
            removeESP(p)
        end
        for drone, highlight in pairs(DroneESP) do
            highlight:Destroy()
        end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end
end)

print("✅ Dulta Ultimate v23.1 успешно загружен!")
print("📌 Меню открывается по клику на иконку в левой части экрана")
print("🎯 ESP показывает врагов красным, союзников зеленым")
print("🚀 Аимбот наводится только на врагов при зажатой ПКМ")
