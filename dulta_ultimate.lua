local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🔥 DULTA ULTIMATE | Private v10.0",
   LoadingTitle = "Загрузка системы DULTA...",
   LoadingSubtitle = "by gdkwkwjm2014-afk",
   ConfigurationSaving = {
      Enabled = true,
      Folder = "DultaSettings",
      FileName = "MainConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- // ПЕРЕМЕННЫЕ (ЯДРО) //
local LP = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

getgenv().AimbotEnabled = false
getgenv().ESPEnabled = false
getgenv().FOVSize = 150
getgenv().SpeedVal = 16
getgenv().NoRecoil = false

-- // ФУНКЦИЯ ОТРИСОВКИ КРУГА //
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0) -- Красный
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Visible = false

-- // ЛОГИКА АИМА (ИЗ ИСХОДНИКА) //
local function GetClosest()
    local target = nil
    local dist = getgenv().FOVSize
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
            if v.Team == LP.Team then continue end -- Team Check
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
    return target
end

-- // ВКЛАДКИ МЕНЮ //
local MainTab = Window:CreateTab("Combat ⚔️")
local VisualsTab = Window:CreateTab("Visuals 👁️")
local MiscTab = Window:AddTab("Misc ⚙️")

-- // СЕКЦИЯ COMBAT //
MainTab:CreateSection("Настройки Убийства")

MainTab:CreateToggle({
   Name = "Enable Aimbot (Hard Lock)",
   CurrentValue = false,
   Callback = function(Value) 
      getgenv().AimbotEnabled = Value 
      FOVCircle.Visible = Value
   end,
})

MainTab:CreateSlider({
   Name = "Aimbot FOV (Радиус)",
   Min = 10, Max = 800, CurrentValue = 150,
   Callback = function(Value) 
      getgenv().FOVSize = Value
      FOVCircle.Radius = Value
   end,
})

MainTab:CreateToggle({
   Name = "No Recoil (Без отдачи)",
   CurrentValue = false,
   Callback = function(Value) getgenv().NoRecoil = Value end,
})

-- // СЕКЦИЯ VISUALS //
VisualsTab:CreateSection("Визуальные функции")

VisualsTab:CreateToggle({
   Name = "Highlight ESP (Wallhack)",
   CurrentValue = false,
   Callback = function(Value) getgenv().ESPEnabled = Value end,
})

-- // СЕКЦИЯ MISC //
MiscTab:CreateSection("Игрок")

MiscTab:CreateSlider({
   Name = "WalkSpeed (Скорость)",
   Min = 16, Max = 200, CurrentValue = 16,
   Callback = function(Value) getgenv().SpeedVal = Value end,
})

-- // ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ //
RunService.RenderStepped:Connect(function()
    -- Центрируем круг
    FOVCircle.Position = UIS:GetMouseLocation()
    
    -- Аимбот
    if getgenv().AimbotEnabled then
        local target = GetClosest()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- ESP (Подсветка врагов)
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Character then
            local highlight = v.Character:FindFirstChild("DultaESP")
            if getgenv().ESPEnabled and v ~= LP and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", v.Character)
                    highlight.Name = "DultaESP"
                end
                highlight.FillColor = (v.Team == LP.Team and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                highlight.FillAlpha = 0.4
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
    
    -- Скорость
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().SpeedVal
    end
end)

Rayfield:Notify({
   Title = "DULTA ULTIMATE",
   Content = "Скрипт успешно активирован. Приятной игры!",
   Duration = 6.5,
   Image = 4483362458,
})
