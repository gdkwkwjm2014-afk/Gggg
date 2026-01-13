local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v19 | TEAM & FLY", "BloodTheme")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FlyEnabled = false
getgenv().Speed = 16
getgenv().FlySpeed = 50
getgenv().FFA = false -- Режим "Все против всех"

-- [ВКЛАДКИ]
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat & Aim")
local Visuals = Main:NewSection("Visuals (Team Check)")
local Movement = Main:NewSection("Movement & Fly")

-- [COMBAT]
Combat:NewToggle("Aimbot (Hard Lock)", "Наведение на ВРАГОВ", function(state)
    getgenv().AimEnabled = state
end)

Combat:NewToggle("FFA Mode", "Аим на ВСЕХ (включай, если не наводится)", function(state)
    getgenv().FFA = state
end)

-- [VISUALS]
Visuals:NewToggle("Smart ESP", "Враги: Красные, Свои: Зеленые", function(state)
    getgenv().ESPEnabled = state
end)

-- [MOVEMENT]
Movement:NewSlider("Safe Speed", "Скорость без телепортов", 250, 16, function(s)
    getgenv().Speed = s
end)

Movement:NewToggle("Fly (Полет)", "Летать по карте", function(state)
    getgenv().FlyEnabled = state
end)

Movement:NewSlider("Fly Speed", "Скорость полета", 300, 50, function(s)
    getgenv().FlySpeed = s
end)

-- [ЛОГИКА ОПРЕДЕЛЕНИЯ ВРАГА]
local function IsEnemy(v)
    if getgenv().FFA then return true end
    if v.Team ~= LP.Team or v.TeamColor ~= LP.TeamColor then
        return true
    end
    return false
end

-- [ПОИСК ЦЕЛИ]
local function GetTarget()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if IsEnemy(v) and v.Character.Humanoid.Health > 0 then
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

-- [ГЛАВНЫЙ ЦИКЛ]
RS.RenderStepped:Connect(function()
    -- АИМБОТ
    if getgenv().AimEnabled then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end

    -- БЕЗОПАСНАЯ СКОРОСТЬ
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and not getgenv().FlyEnabled then
        local hrp = LP.Character.HumanoidRootPart
        local hum = LP.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 and getgenv().Speed > 16 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (getgenv().Speed / 120))
        end
    end

    -- ПОЛЕТ (FLY)
    if getgenv().FlyEnabled and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        hrp.Velocity = Vector3.new(0, 0, 0)
        
        local moveDir = LP.Character.Humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * (getgenv().FlySpeed / 10))
        end
    end

    -- SMART ESP
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaESP")
                if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    if not h then
                        h = Instance.new("Highlight", v.Character)
                        h.Name = "DultaESP"
                    end
                    
                    if IsEnemy(v) then
                        h.FillColor = Color3.fromRGB(255, 0, 0) -- Враг: Красный
                    else
                        h.FillColor = Color3.fromRGB(0, 255, 0) -- Свой: Зеленый
                    end
                    h.FillAlpha = 0.5
                else
                    if h then h:Destroy() end
                end
            end
        end
    else
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("DultaESP") then
                v.Character.DultaESP:Destroy()
            end
        end
    end
end)
