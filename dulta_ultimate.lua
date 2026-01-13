local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DULTA ULTIMATE v7.0",
   LoadingTitle = "Запуск Elite Софта...",
   LoadingSubtitle = "Team Check & Visuals Edition",
   ConfigurationSaving = { Enabled = true, Folder = "DultaUltimate" }
})

local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- Глобальные настройки
getgenv().AimEnabled = false
getgenv().AimFOV = 150
getgenv().AimPart = "Head"
getgenv().ESPEnabled = false
getgenv().WalkSpeed = 16

-- Рисование круга FOV (Центральный)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255) -- Белый для нейтральности
FOVCircle.NumSides = 100
FOVCircle.Radius = getgenv().AimFOV
FOVCircle.Filled = false
FOVCircle.Visible = true

-- Вкладка Combat
local CombatTab = Window:CreateTab("Combat ⚔️")
CombatTab:CreateToggle({
   Name = "Hard Lock (Враги)",
   CurrentValue = false,
   Callback = function(Value) getgenv().AimEnabled = Value end,
})
CombatTab:CreateSlider({
   Name = "Размер Круга FOV",
   Min = 10, Max = 800, CurrentValue = 150,
   Callback = function(Value) 
      getgenv().AimFOV = Value 
      FOVCircle.Radius = Value
   end,
})
CombatTab:CreateDropdown({
   Name = "Цель",
   Options = {"Head", "HumanoidRootPart"},
   CurrentOption = {"Head"},
   Callback = function(Option) getgenv().AimPart = Option[1] end,
})

-- Вкладка Visuals
local VisualsTab = Window:CreateTab("Visuals 👁️")
VisualsTab:CreateToggle({
   Name = "Highlight ESP (Цветной)",
   CurrentValue = false,
   Callback = function(Value) getgenv().ESPEnabled = Value end,
})

-- Вкладка Misc
local MiscTab = Window:CreateTab("Misc ⚙️")
MiscTab:CreateSlider({
   Name = "Скорость бега",
   Min = 16, Max = 250, CurrentValue = 16,
   Callback = function(Value) getgenv().WalkSpeed = Value end,
})

-- Функция поиска ближайшего ВРАГА
local function GetClosestEnemy()
    local target = nil
    local shortestDist = getgenv().AimFOV
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        -- Проверка: не я, живой, есть нужная часть тела, и ГЛАВНОЕ — не мой тиммейт
        if v ~= LP and v.Team ~= LP.Team and v.Character and v.Character:FindFirstChild(getgenv().AimPart) then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(v.Character[getgenv().AimPart].Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        target = v.Character[getgenv().AimPart]
                    end
                end
            end
        end
    end
    return target
end

-- Основной цикл
game:GetService("RunService").RenderStepped:Connect(function()
    -- Позиция круга всегда в центре
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = getgenv().AimEnabled
    
    -- Аимбот (Только враги)
    if getgenv().AimEnabled then
        local target = GetClosestEnemy()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- ВХ (Враги — Красный, Свои — Синий)
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Character then
            local high = v.Character:FindFirstChild("DultaESP")
            if getgenv().ESPEnabled and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if not high then
                    high = Instance.new("Highlight", v.Character)
                    high.Name = "DultaESP"
                end
                
                -- Установка цвета в зависимости от команды
                if v.Team == LP.Team then
                    high.FillColor = Color3.fromRGB(0, 100, 255) -- Синий (Союзник)
                    high.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    high.FillColor = Color3.fromRGB(255, 0, 0)   -- Красный (Враг)
                    high.OutlineColor = Color3.fromRGB(0, 0, 0)
                end
                high.FillAlpha = 0.5
            else
                if high then high:Destroy() end
            end
        end
    end

    -- Скорость
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
    end
end)

Rayfield:Notify({Title = "DULTA v7.0", Content = "Удачной охоты на врагов!", Duration = 5})
