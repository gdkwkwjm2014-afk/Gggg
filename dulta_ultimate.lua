-- Dulta Ultimate v24 - FULLY FIXED
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- ====================
-- СОЗДАЕМ ИКОНКУ МЕНЮ
-- ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DultaUIMain"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "DultaMenuToggle"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenButton.BackgroundTransparency = 0.2
OpenButton.BorderSizePixel = 0
OpenButton.Position = UDim2.new(0, 20, 0, 20)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Image = "rbxassetid://7072725342"
OpenButton.ZIndex = 10000

local OpenButtonCorner = Instance.new("UICorner")
OpenButtonCorner.CornerRadius = UDim.new(0.3, 0)
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
OpenButtonText.TextStrokeTransparency = 0.5
OpenButtonText.ZIndex = 10000

-- ====================
-- ЗАГРУЗКА БИБЛИОТЕКИ
-- ====================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Dulta Ultimate v24", "BloodTheme")

-- Скрываем окно при запуске
Window.Main.Visible = false

-- ====================
-- НАСТРОЙКИ
-- ====================
getgenv().DultaConfig = {
    AimEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimFOV = 100,
    AimSmoothness = 0.3,
    AimPart = "Head",
    
    ESPEnabled = false,
    ESPBox = true,
    ESPName = true,
    ESPHealth = true,
    
    FlyEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 32,
    SpeedKey = Enum.KeyCode.LeftShift,
    
    AntiCheat = {
        AntiAimDetection = true,
        RandomizeActions = false,
        HideTraces = false
    }
}

-- ====================
-- ВКЛАДКИ И СЕКЦИИ
-- ====================
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Aim Features")

local VisualsTab = Window:NewTab("Visuals")
local VisualsSection = VisualsTab:NewSection("ESP Settings")

local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Movement Hacks")

local SettingsTab = Window:NewTab("Settings")
local SettingsSection = SettingsTab:NewSection("Configuration")

-- ====================
-- УПРАВЛЕНИЕ МЕНЮ
-- ====================
local menuVisible = false

OpenButton.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    Window.Main.Visible = menuVisible
    
    if menuVisible then
        -- Позиционируем меню рядом с кнопкой
        Window.Main.Position = UDim2.new(0, 80, 0, 20)
    end
end)

-- Делаем окно перемещаемым
Window.Main.Active = true
Window.Main.Draggable = true

-- Закрытие меню при клике на крестик
Window.Main.CloseButton.MouseButton1Click:Connect(function()
    menuVisible = false
    Window.Main.Visible = false
end)

-- ====================
-- РАБОЧИЙ ESP
-- ====================
local ESPObjects = {}

local function createESP(player)
    if not player or player == LP then return end
    if not player.Character then return end
    
    local char = player.Character
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Проверяем команду
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
    billboard.Adornee = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
    if not billboard.Adornee then return end
    
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
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
    humanoid.HealthChanged:Connect(function()
        if healthLabel and healthLabel.Parent then
            healthLabel.Text = "HP: " .. math.floor(humanoid.Health)
        end
    end)
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Highlight then
            ESPObjects[player].Highlight:Destroy()
        end
        if ESPObjects[player].Billboard then
            ESPObjects[player].Billboard:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            if getgenv().DultaConfig.ESPEnabled then
                if not ESPObjects[player] and player.Character and player.Character:FindFirstChild("Humanoid") then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

-- ====================
-- РАБОЧИЙ АИМБОТ
-- ====================
local function getClosestEnemy()
    if not LP.Team then return nil end
    
    local target = nil
    local closestDistance = getgenv().DultaConfig.AimFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LP then continue end
        
        -- Проверяем команду - только враги
        if player.Team and player.Team ~= LP.Team then
            if player.Character then
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
    end
    
    return target
end

-- ====================
-- ПОЛЕТ
-- ====================
local flyBodyVelocity, flyBodyGyro
local function toggleFly(state)
    if not LP.Character then return end
    local humanoid = LP.Character:FindFirstChild("Humanoid")
    local root = LP.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    if state then
        -- Включаем полет
        humanoid.PlatformStand = true
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
        flyBodyVelocity.Parent = root
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.MaxTorque = Vector3.new(50000, 50000, 50000)
        flyBodyGyro.P = 1000
        flyBodyGyro.Parent = root
    else
        -- Выключаем полет
        humanoid.PlatformStand = false
        
        if flyBodyVelocity then 
            flyBodyVelocity:Destroy() 
            flyBodyVelocity = nil 
        end
        if flyBodyGyro then 
            flyBodyGyro:Destroy() 
            flyBodyGyro = nil 
        end
    end
end

-- ====================
-- НАСТРОЙКИ В МЕНЮ
-- ====================
-- Combat
CombatSection:NewToggle("Aimbot", "Автоматическое наведение на врагов", function(state)
    getgenv().DultaConfig.AimEnabled = state
    if state then
        Library:Notification("Aimbot", "Включен. Удерживайте ПКМ для наведения", "OK")
    end
end)

CombatSection:NewDropdown("Aim Part", "Часть тела для аима", {"Head", "HumanoidRootPart", "UpperTorso"}, function(part)
    getgenv().DultaConfig.AimPart = part
    Library:Notification("Aim Part", "Установлено: " .. part, "OK")
end)

CombatSection:NewSlider("Aim FOV", "Угол обзора аима", 500, 50, function(value)
    getgenv().DultaConfig.AimFOV = value
end)

CombatSection:NewSlider("Smoothness", "Плавность наведения", 100, 1, function(value)
    getgenv().DultaConfig.AimSmoothness = value / 100
end)

-- Visuals
VisualsSection:NewToggle("ESP Players", "Показать игроков через стены", function(state)
    getgenv().DultaConfig.ESPEnabled = state
    if not state then
        for player in pairs(ESPObjects) do
            removeESP(player)
        end
    else
        Library:Notification("ESP", "Включен. Враги - красные, тиммейты - зеленые", "OK")
    end
end)

VisualsSection:NewToggle("ESP Names", "Показать имена игроков", function(state)
    getgenv().DultaConfig.ESPName = state
    for player, data in pairs(ESPObjects) do
        if data.Billboard then
            data.Billboard.Enabled = state
        end
    end
end)

VisualsSection:NewToggle("ESP Health", "Показать здоровье", function(state)
    getgenv().DultaConfig.ESPHealth = state
end)

-- Movement
MovementSection:NewToggle("Fly", "Включить режим полета", function(state)
    getgenv().DultaConfig.FlyEnabled = state
    toggleFly(state)
    
    if state then
        Library:Notification("Fly", "Включен. Управление: WASD + Space/LCtrl", "OK")
    end
end)

MovementSection:NewToggle("Speed Hack", "Ускорение передвижения", function(state)
    getgenv().DultaConfig.SpeedEnabled = state
    
    if state then
        Library:Notification("Speed", "Ускорение включено. Значение: " .. getgenv().DultaConfig.SpeedValue, "OK")
    end
end)

MovementSection:NewSlider("Speed Value", "Значение скорости", 100, 16, function(value)
    getgenv().DultaConfig.SpeedValue = value
end)

-- Settings
SettingsSection:NewToggle("Anti-Cheat Bypass", "Обход античита", function(state)
    getgenv().DultaConfig.AntiCheat.AntiAimDetection = state
end)

SettingsSection:NewButton("Refresh ESP", "Обновить ESP", function()
    for player in pairs(ESPObjects) do
        removeESP(player)
    end
    updateESP()
    Library:Notification("ESP", "ESP обновлен", "OK")
end)

SettingsSection:NewButton("Unload Menu", "Выгрузить меню", function()
    -- Очищаем ESP
    for player in pairs(ESPObjects) do
        removeESP(player)
    end
    
    -- Выключаем полет
    toggleFly(false)
    
    -- Удаляем UI
    ScreenGui:Destroy()
    Window:Destroy()
    
    Library:Notification("Dulta", "Меню выгружено", "OK")
end)

-- ====================
-- ОСНОВНОЙ ЦИКЛ
-- ====================
RS.RenderStepped:Connect(function()
    -- ESP
    if getgenv().DultaConfig.ESPEnabled then
        updateESP()
    end
    
    -- Аимбот
    if getgenv().DultaConfig.AimEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestEnemy()
        if target then
            local currentCF = Camera.CFrame
            local targetPos = target.Position
            local newCF = CFrame.new(currentCF.Position, targetPos)
            Camera.CFrame = currentCF:Lerp(newCF, getgenv().DultaConfig.AimSmoothness)
        end
    end
    
    -- Speed Hack
    if getgenv().DultaConfig.SpeedEnabled and LP.Character then
        local humanoid = LP.Character:FindFirstChild("Humanoid")
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and root and humanoid.MoveDirection.Magnitude > 0 then
            root.Velocity = humanoid.MoveDirection * getgenv().DultaConfig.SpeedValue
        end
    end
    
    -- Fly
    if getgenv().DultaConfig.FlyEnabled and flyBodyVelocity then
        local moveDirection = Vector3.new(0, 0, 0)
        
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
end)

-- ====================
-- ОЧИСТКА ПРИ ВЫХОДЕ
-- ====================
game.Players.PlayerRemoving:Connect(function(player)
    if player == LP then
        for p in pairs(ESPObjects) do
            removeESP(p)
        end
        toggleFly(false)
    end
end)

-- ====================
-- СТАРТ
-- ====================
Library:Notification("Dulta Ultimate v24", "Успешно загружен! Нажмите на иконку Dulta для открытия меню.", "OK")
print("✅ Dulta Ultimate v24 загружен!")
print("📌 Нажмите на иконку 'Dulta' для открытия меню")
print("🎯 ESP: Враги - красные, Тиммейты - зеленые")
print("🚀 Аимбот работает при зажатой ПКМ (только на врагов)")
