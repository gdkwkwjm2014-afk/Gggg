local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- Создаем меню с возможностью перемещения
local Window = Library.CreateLib("DULTA ULTIMATE v13", "BloodTheme")

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Настройки
getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FOVSize = 150
getgenv().Speed = 16

-- FOV Circle (Круг аима)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Visible = false

-- Вкладки (Main теперь со скроллом, если нужно)
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat Settings")
local Visuals = Main:NewSection("Visuals (Team Based)")
local Misc = Main:NewSection("Player Mods")

-- [COMBAT]
Combat:NewToggle("Aimbot (Hard Lock)", "Наведение на ВРАГОВ", function(state)
    getgenv().AimEnabled = state
    FOVCircle.Visible = state
end)

Combat:NewSlider("FOV Size", "Радиус круга", 800, 50, function(s)
    getgenv().FOVSize = s
    FOVCircle.Radius = s
end)

-- [VISUALS]
Visuals:NewToggle("Team ESP", "Красный - Враг, Синий - Друг", function(state)
    getgenv().ESPEnabled = state
end)

-- [MISC]
Misc:NewSlider("WalkSpeed", "Скорость бега", 250, 16, function(s)
    getgenv().Speed = s
end)

Misc:NewButton("Reset Speed", "Вернуть обычную скорость", function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Функция поиска ЦЕЛИ (только ВРАГИ)
local function GetTarget()
    local target = nil
    local dist = getgenv().FOVSize
    for _, v in pairs(Players:GetPlayers()) do
        -- Проверка: не я, другая команда, живой
        if v ~= LP and v.Team ~= LP.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    target = v.Character.HumanoidRootPart
                end
            end
        end
    end
    return target
end

-- ГЛАВНЫЙ ЦИКЛ
RS.RenderStepped:Connect(function()
    -- Центрируем круг за мышкой
    FOVCircle.Position = UIS:GetMouseLocation()
    
    -- Логика Аима
    if getgenv().AimEnabled then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- Логика Скорости
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().Speed
    end

    -- Логика ESP (Разделение по командам)
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaHighlight")
                if not h and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "DultaHighlight"
                    -- Цвет: Если команда совпадает - Синий, если нет - Красный
                    if v.Team == LP.Team then
                        h.FillColor = Color3.fromRGB(0, 0, 255) -- Синий
                    else
                        h.FillColor = Color3.fromRGB(255, 0, 0) -- Красный
                    end
                    h.FillAlpha = 0.5
                    h.OutlineColor = Color3.new(1, 1, 1)
                elseif not getgenv().ESPEnabled and h then
                    h:Destroy()
                end
            end
        end
    else
        -- Очистка если выключили
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("DultaHighlight") then
                v.Character.DultaHighlight:Destroy()
            end
        end
    end
end)
