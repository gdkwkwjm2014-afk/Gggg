local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DULTA ULTIMATE v7.0",
   LoadingTitle = "Загрузка модулей...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- Переменные управления
local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

getgenv().Aimbot = false
getgenv().ESP = false
getgenv().FOVSize = 150
getgenv().Speed = 16

-- Отрисовка FOV Круга
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Thickness = 1
Circle.NumSides = 100
Circle.Radius = getgenv().FOVSize
Circle.Filled = false
Circle.Visible = false

-- Вкладка Combat
local CombatTab = Window:CreateTab("Combat ⚔️")

CombatTab:CreateToggle({
   Name = "Hard Lock (Враги)",
   CurrentValue = false,
   Callback = function(Value) 
      getgenv().Aimbot = Value 
      Circle.Visible = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Размер Круга FOV",
   Min = 10, Max = 800, CurrentValue = 150,
   Callback = function(Value) 
      getgenv().FOVSize = Value
      Circle.Radius = Value
   end,
})

-- Вкладка Visuals
local VisualsTab = Window:CreateTab("Visuals 👁️")

VisualsTab:CreateToggle({
   Name = "ESP (Highlight + Health)",
   CurrentValue = false,
   Callback = function(Value) getgenv().ESP = Value end,
})

-- Вкладка Misc
local MiscTab = Window:CreateTab("Misc ⚙️")

MiscTab:CreateSlider({
   Name = "Safe Speed",
   Min = 16, Max = 100, CurrentValue = 16,
   Callback = function(Value) getgenv().Speed = Value end,
})

-- Логика поиска цели
local function GetClosestPlayer()
    local Target = nil
    local MaxDist = getgenv().FOVSize
    
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Team ~= LP.Team and v.Character and v.Character:FindFirstChild("Head") then
            local Head = v.Character.Head
            local Pos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            
            if OnScreen then
                local MousePos = UIS:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                
                if Dist < MaxDist then
                    MaxDist = Dist
                    Target = Head
                end
            end
        end
    end
    return Target
end

-- ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ
RunService.RenderStepped:Connect(function()
    -- Центрируем круг FOV
    Circle.Position = UIS:GetMouseLocation()
    
    -- Работа Аима
    if getgenv().Aimbot then
        local Target = GetClosestPlayer()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        end
    end

    -- Работа ВХ и Скорости
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Character then
            -- ESP Логика
            local Highlight = v.Character:FindFirstChild("DultaHighlight")
            if getgenv().ESP and v ~= LP and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if not Highlight then
                    Highlight = Instance.new("Highlight", v.Character)
                    Highlight.Name = "DultaHighlight"
                end
                Highlight.FillColor = (v.Team == LP.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                Highlight.FillAlpha = 0.5
            else
                if Highlight then Highlight:Destroy() end
            end
        end
    end

    -- Безопасная скорость (через CFrame, чтобы не кикало)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and getgenv().Speed > 16 then
        local HRP = LP.Character.HumanoidRootPart
        local MoveDir = LP.Character.Humanoid.MoveDirection
        HRP.CFrame = HRP.CFrame + (MoveDir * (getgenv().Speed / 100))
    end
end)

Rayfield:Notify({Title = "DULTA V7.1", Content = "Скрипт полностью перенастроен!", Duration = 5})
