local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DULTA ULTIMATE v25 | FIXED",
   LoadingTitle = "Загрузка Dulta System...",
   LoadingStatus = "By Gemini Fix",
   ConfigurationSaving = {
      Enabled = false
   },
   KeySystem = false
})

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().SpeedValue = 16
getgenv().FlyEnabled = false

-- [[ ВКЛАДКИ ]]
local MainTab = Window:CreateTab("Главная", 4483362458) 
local MoveTab = Window:CreateTab("Движение", 4483362458)

-- [ГЛАВНАЯ]
MainTab:CreateSection("Бой и Визуалы")

MainTab:CreateToggle({
   Name = "Аимбот (На Врагов)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AimEnabled = Value
   end,
})

MainTab:CreateToggle({
   Name = "ВХ (Highlights)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().ESPEnabled = Value
   end,
})

-- [ДВИЖЕНИЕ]
MoveTab:CreateSection("Перемещение")

MoveTab:CreateSlider({
   Name = "Скорость бега",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      getgenv().SpeedValue = Value
   end,
})

MoveTab:CreateToggle({
   Name = "Полет",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().FlyEnabled = Value
   end,
})

-- [[ ЛОГИКА ОПРЕДЕЛЕНИЯ ВРАГА ]]
local function IsEnemy(v)
    if v.Team ~= LP.Team or v.TeamColor ~= LP.TeamColor or v.Neutral then
        return true
    end
    return false
end

-- [[ ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ (БЕЗ ЛАГОВ) ]]
RS.RenderStepped:Connect(function()
    -- АИМБОТ
    if getgenv().AimEnabled then
        local target = nil
        local dist = 600
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and IsEnemy(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hum = v.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
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
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), 0.15)
        end
    end

    -- ВХ (SMART TEAM CHECK)
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaHighlight")
                if not h then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "DultaHighlight"
                    h.OutlineTransparency = 0
                end
                h.FillAlpha = 0.5
                -- Фикс цветов: Враги красные, Свои зеленые
                h.FillColor = IsEnemy(v) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
            end
        end
    else
        for _, v in pairs(game:GetDescendants()) do
            if v.Name == "DultaHighlight" then v:Destroy() end
        end
    end

    -- ДВИЖЕНИЕ
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        
        if getgenv().FlyEnabled then
            hrp.Velocity = Vector3.new(0,0,0)
            if hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.5)
            end
        elseif getgenv().SpeedValue > 16 and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (getgenv().SpeedValue / 110))
        end
    end
end)

Rayfield:Notify({
   Title = "DULTA LOADED",
   Content = "Приятной игры! Меню на Rayfield.",
   Duration = 5,
   Image = 4483362458,
})
