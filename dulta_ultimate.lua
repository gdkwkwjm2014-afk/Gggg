local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DULTA ULTIMATE v8.0 (PRO)",
   LoadingTitle = "Интеграция исходников...",
   LoadingSubtitle = "Unloosed + VeryUp Logic",
   ConfigurationSaving = { Enabled = false }
})

-- Сервисы и переменные
local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

getgenv().Aimbot = false
getgenv().ESP = false
getgenv().FOVSize = 150
getgenv().Speed = 16

-- Настройка круга FOV из твоих исходников
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ВКЛАДКА COMBAT (Логика из Unloosed)
local CombatTab = Window:CreateTab("Combat ⚔️")
CombatTab:CreateToggle({
   Name = "Hard Lock (Source Logic)",
   CurrentValue = false,
   Callback = function(v) 
      getgenv().Aimbot = v 
      FOVCircle.Visible = v
   end,
})
CombatTab:CreateSlider({
   Name = "FOV Radius",
   Min = 10, Max = 800, CurrentValue = 150,
   Callback = function(v) 
      getgenv().FOVSize = v
      FOVCircle.Radius = v
   end,
})

-- ВКЛАДКА VISUALS (Логика из VeryUp)
local VisualsTab = Window:CreateTab("Visuals 👁️")
VisualsTab:CreateToggle({
   Name = "Highlight ESP (Team Based)",
   CurrentValue = false,
   Callback = function(v) getgenv().ESP = v end,
})

-- ВКЛАДКА MISC
local MiscTab = Window:CreateTab("Misc ⚙️")
MiscTab:CreateSlider({
   Name = "WalkSpeed Hack",
   Min = 16, Max = 200, CurrentValue = 16,
   Callback = function(v) getgenv().Speed = v end,
})

-- ФУНКЦИЯ ПОИСКА ЦЕЛИ (Из исходника)
local function GetClosest()
    local target = nil
    local dist = getgenv().FOVSize
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Team ~= LP.Team then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v.Character.Head
                    end
                end
            end
        end
    end
    return target
end

-- РАБОЧИЙ ЦИКЛ
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UIS:GetMouseLocation()
    
    -- Логика Аима
    if getgenv().Aimbot then
        local target = GetClosest()
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 0.2)
        end
    end

    -- Логика ESP (Highlight)
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Character then
            local high = v.Character:FindFirstChild("SourceESP")
            if getgenv().ESP and v ~= LP and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if not high then
                    high = Instance.new("Highlight", v.Character)
                    high.Name = "SourceESP"
                end
                high.FillColor = (v.Team == LP.Team and Color3.new(0, 1, 0) or Color3.new(1, 0, 0))
                high.FillAlpha = 0.5
                high.OutlineColor = Color3.new(1, 1, 1)
            else
                if high then high:Destroy() end
            end
        end
    end
    
    -- Speed Hack
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().Speed
    end
end)

Rayfield:Notify({Title = "DULTA v8.0", Content = "Функции из исходников успешно загружены!", Duration = 5})
