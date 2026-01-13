local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v22 | LOST FRONT EDITION", "BloodTheme")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FlyEnabled = false
getgenv().Speed = 16

-- [ВКЛАДКИ]
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat (Custom Aim)")
local Visuals = Main:NewSection("Visuals (Source ESP)")
local Movement = Main:NewSection("Movement & Fly")

Combat:NewToggle("Aimbot Hard Lock", "Захват вражеских солдат", function(state) 
    getgenv().AimEnabled = state 
end)

Visuals:NewToggle("Source ESP (Players + Drones)", "ВХ из присланных скриптов", function(state) 
    getgenv().ESPEnabled = state 
end)

Movement:NewSlider("Bypass Speed", "Скорость", 250, 16, function(s) getgenv().Speed = s end)
Movement:NewToggle("Fly Mode", "Полет (для разведки)", function(state) getgenv().FlyEnabled = state end)

-- [[ ЛОГИКА ESP ИЗ ТВОИХ ИСХОДНИКОВ ]]
local function ApplyESP(obj, isEnemy)
    if not obj:FindFirstChild("DultaHighlight") then
        local h = Instance.new("Highlight")
        h.Name = "DultaHighlight"
        h.Parent = obj
        h.FillAlpha = 0.5
        h.OutlineTransparency = 0
        h.FillColor = isEnemy and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        h.OutlineColor = Color3.new(1, 1, 1)
    end
end

-- [[ ЛОГИКА АИМА ]]
local function GetClosestEnemy()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Team ~= LP.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
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
    return target
end

-- [[ ОСНОВНОЙ ЦИКЛ ОБРАБОТКИ ]]
RS.RenderStepped:Connect(function()
    -- Работа Аима
    if getgenv().AimEnabled then
        local t = GetClosestEnemy()
        if t then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end

    -- Работа ESP (Игроки + Дроны)
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local isEnemy = (v.Team ~= LP.Team)
                ApplyESP(v.Character, isEnemy)
            end
        end
        -- Поиск дронов в Workspace (логика из исходника)
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name:lower():find("drone") or obj.Name:lower():find("uav") then
                ApplyESP(obj, true) -- Дроны обычно вражеские
            end
        end
    else
        -- Очистка ВХ
        for _, v in pairs(game:GetDescendants()) do
            if v.Name == "DultaHighlight" then v:Destroy() end
        end
    end

    -- Передвижение
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if getgenv().FlyEnabled then
            hrp.Velocity = Vector3.new(0,0,0)
            if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.5)
            end
        elseif getgenv().Speed > 16 and LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (LP.Character.Humanoid.MoveDirection * (getgenv().Speed / 100))
        end
    end
end)
