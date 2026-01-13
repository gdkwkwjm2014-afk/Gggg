-- Улучшенный скрипт Dulta Ultimate v23
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Создаем скрытое меню с иконкой
local Window = Library.CreateLib("", "BloodTheme")
local MainWindow = Window.Main

-- Скрываем основное окно
MainWindow.Visible = false

-- Создаем иконку для открытия меню
local ScreenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("ImageButton")

ScreenGui.Name = "DultaUISoft"
ScreenGui.Parent = game.CoreGui

OpenButton.Name = "OpenMenuBtn"
OpenButton.Parent = ScreenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
OpenButton.BackgroundTransparency = 0.5
OpenButton.BorderSizePixel = 0
OpenButton.Position = UDim2.new(0, 10, 0.5, -25)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Image = "rbxassetid://7072725342" -- Иконка
OpenButton.ZIndex = 100

local OpenButtonText = Instance.new("TextLabel")
OpenButtonText.Name = "BtnText"
OpenButtonText.Parent = OpenButton
OpenButtonText.BackgroundTransparency = 1
OpenButtonText.Position = UDim2.new(0, 0, 1, 5)
OpenButtonText.Size = UDim2.new(1, 0, 0, 20)
OpenButtonText.Font = Enum.Font.SourceSansBold
OpenButtonText.Text = "Dulta"
OpenButtonText.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButtonText.TextSize = 14
OpenButtonText.ZIndex = 100

-- Переменные
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- Настройки
getgenv().DultaConfig = {
    AimEnabled = false,
    AimKey = Enum.UserInputType.MouseButton2,
    AimSmoothness = 0.1,
    AimPart = "Head",
    
    ESPEnabled = false,
    ESPColorEnemy = Color3.fromRGB(255, 0, 0),
    ESPColorTeam = Color3.fromRGB(0, 255, 0),
    ESPColorDrone = Color3.fromRGB(255, 165, 0),
    
    FlyEnabled = false,
    SpeedEnabled = false,
    SpeedValue = 16,
    
    AntiCheat = {
        AntiAimDetection = true,
        RandomizeActions = true,
        HideTraces = true
    }
}

-- Вкладки
local Main = Window:NewTab("Combat")
local Combat = Main:NewSection("Aim Features")

local VisualsTab = Window:NewTab("Visuals")
local Visuals = VisualsTab:NewSection("ESP Settings")

local MovementTab = Window:NewTab("Movement")
local Movement = MovementTab:NewSection("Movement Hacks")

local MiscTab = Window:NewTab("Miscellaneous")
local Misc = MiscTab:NewSection("Settings")

-- Функция для открытия/закрытия меню
local function toggleMenu()
    MainWindow.Visible = not MainWindow.Visible
    if MainWindow.Visible then
        MainWindow.Position = UDim2.new(0.5, -175, 0.5, -150)
    end
end

OpenButton.MouseButton1Click:Connect(toggleMenu)

-- Анти-чит функции
local function safeCall(func, ...)
    if getgenv().DultaConfig.AntiCheat.RandomizeActions then
        wait(math.random(0.01, 0.05))
    end
    local success, result = pcall(func, ...)
    if not success and getgenv().DultaConfig.AntiCheat.HideTraces then
        -- Скрываем ошибки
        return
    end
    return result
end

-- Улучшенный ESP
local ESPObjects = {}
local function createESP(object, color, name)
    if not object or not object.Parent then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "DultaESP"
    highlight.Adornee = object
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = game.CoreGui
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DultaNameTag"
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = game.CoreGui
    
    local label = Instance.new("TextLabel")
    label.Name = "NameTag"
    label.Parent = billboard
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = name or object.Name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    
    ESPObjects[object] = {highlight, billboard}
end

local function clearESP()
    for _, obj in pairs(ESPObjects) do
        for _, v in ipairs(obj) do
            v:Destroy()
        end
    end
    ESPObjects = {}
end

-- Улучшенный аимбот
local function getClosestEnemy()
    local target = nil
    local closestDistance = math.huge
    
    for _, player in safeCall(function() return Players:GetPlayers() end) do
        if player ~= LP and player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            if humanoid.Health > 0 then
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local aimPart = player.Character:FindFirstChild(getgenv().DultaConfig.AimPart or "Head")
                
                if rootPart and aimPart then
                    local screenPoint, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local aimPos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (mousePos - aimPos).Magnitude
                        
                        if distance < closestDistance then
                            closestDistance = distance
                            target = {
                                Player = player,
                                Part = aimPart,
                                Root = rootPart
                            }
                        end
                    end
                end
            end
        end
    end
    
    return target
end

-- Функция полета
local flyBodyVelocity, flyBodyGyro
local function toggleFly(state)
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    if state then
        local hrp = LP.Character.HumanoidRootPart
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
        flyBodyVelocity.P = 1000
        flyBodyVelocity.Parent = hrp
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.CFrame = hrp.CFrame
        flyBodyGyro.MaxTorque = Vector3.new(10000, 10000, 10000)
        flyBodyGyro.P = 1000
        flyBodyGyro.Parent = hrp
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
    end
end

-- Элементы UI
Combat:NewToggle("Aimbot", "Авто-наведение на врагов", function(state)
    getgenv().DultaConfig.AimEnabled = state
end)

Combat:NewDropdown("Aim Part", "Выберите часть тела", {"Head", "HumanoidRootPart", "Torso"}, function(part)
    getgenv().DultaConfig.AimPart = part
end)

Combat:NewSlider("Smoothness", "Плавность аима", 100, 1, function(value)
    getgenv().DultaConfig.AimSmoothness = value / 100
end)

Visuals:NewToggle("ESP Players", "Показывать игроков", function(state)
    getgenv().DultaConfig.ESPEnabled = state
    if not state then
        clearESP()
    end
end)

Visuals:NewToggle("ESP Drones", "Показывать дроны", function(state)
    getgenv().DultaConfig.DroneESP = state
end)

Visuals:NewColorPicker("Enemy Color", "Цвет врагов", Color3.fromRGB(255, 0, 0), function(color)
    getgenv().DultaConfig.ESPColorEnemy = color
end)

Visuals:NewColorPicker("Team Color", "Цвет союзников", Color3.fromRGB(0, 255, 0), function(color)
    getgenv().DultaConfig.ESPColorTeam = color
end)

Movement:NewToggle("Fly", "Режим полета", function(state)
    getgenv().DultaConfig.FlyEnabled = state
    safeCall(toggleFly, state)
end)

Movement:NewToggle("Speed Hack", "Ускорение", function(state)
    getgenv().DultaConfig.SpeedEnabled = state
end)

Movement:NewSlider("Speed Value", "Скорость", 250, 16, function(value)
    getgenv().DultaConfig.SpeedValue = value
end)

Misc:NewToggle("Anti-Aim Detection", "Защита от обнаружения", function(state)
    getgenv().DultaConfig.AntiCheat.AntiAimDetection = state
end)

Misc:NewToggle("Randomize Actions", "Рандомизация действий", function(state)
    getgenv().DultaConfig.AntiCheat.RandomizeActions = state
end)

Misc:NewButton("Unload", "Выгрузить меню", function()
    ScreenGui:Destroy()
    Window:Destroy()
end)

-- Основной цикл
RS.RenderStepped:Connect(function()
    safeCall(function()
        -- ESP
        if getgenv().DultaConfig.ESPEnabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local root = player.Character.HumanoidRootPart
                    if not ESPObjects[root] then
                        local color = player.Team == LP.Team and getgenv().DultaConfig.ESPColorTeam 
                                    or getgenv().DultaConfig.ESPColorEnemy
                        createESP(root, color, player.Name)
                    end
                end
            end
            
            -- Дроны
            if getgenv().DultaConfig.DroneESP then
                for _, obj in pairs(workspace:GetChildren()) do
                    if obj.Name:lower():find("drone") and obj:FindFirstChild("HumanoidRootPart") then
                        if not ESPObjects[obj.HumanoidRootPart] then
                            createESP(obj.HumanoidRootPart, getgenv().DultaConfig.ESPColorDrone, "Drone")
                        end
                    end
                end
            end
        end
        
        -- Аимбот
        if getgenv().DultaConfig.AimEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = getClosestEnemy()
            if target and target.Part then
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Part.Position)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, getgenv().DultaConfig.AimSmoothness)
            end
        end
        
        -- Движение
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            local humanoid = LP.Character.Humanoid
            
            -- Speed
            if getgenv().DultaConfig.SpeedEnabled and humanoid.MoveDirection.Magnitude > 0 then
                local velocity = humanoid.MoveDirection * (getgenv().DultaConfig.SpeedValue / 10)
                LP.Character:TranslateBy(velocity * RS.RenderStepped:Wait())
            end
            
            -- Fly
            if getgenv().DultaConfig.FlyEnabled and flyBodyVelocity then
                local direction = Vector3.new(0, 0, 0)
                
                if UIS:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - Camera.CFrame.LookVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + Camera.CFrame.RightVector
                end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                
                flyBodyVelocity.Velocity = direction.Unit * 50
                if flyBodyGyro then
                    flyBodyGyro.CFrame = Camera.CFrame
                end
            end
        end
    end)
end)

-- Анти-чит: скрываем вызовы
local mt = getrawmetadata(game)
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Скрываем подозрительные вызовы
        if getgenv().DultaConfig.AntiCheat.HideTraces then
            if method == "FireServer" or method == "InvokeServer" then
                if tostring(self):find("Aim") or tostring(self):find("Fly") or tostring(self):find("Speed") then
                    return nil
                end
            end
        end
        
        return oldNamecall(self, unpack(args))
    end)
    
    setreadonly(mt, true)
end

print("Dulta Ultimate v23 | Загружено успешно!")
