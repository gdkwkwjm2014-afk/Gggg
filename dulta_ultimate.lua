local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v23", "BloodTheme")

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FlyEnabled = false
getgenv().Speed = 16

-- [[ СОЗДАНИЕ ИКОНКИ ДЛЯ ОТКРЫТИЯ ]]
local OpenGui = Instance.new("ScreenGui")
local OpenButton = Instance.new("TextButton")
local Corner = Instance.new("UICorner")

OpenGui.Name = "DultaOpenGui"
OpenGui.Parent = game:GetService("CoreGui")
OpenGui.Enabled = false -- По умолчанию скрыта

OpenButton.Name = "OpenButton"
OpenButton.Parent = OpenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
OpenButton.Position = UDim2.new(0.02, 0, 0.45, 0)
OpenButton.Size = UDim2.new(0, 60, 0, 60)
OpenButton.Font = Enum.Font.SourceSansBold
OpenButton.Text = "DULTA"
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.TextSize = 14

Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = OpenButton

-- Логика кнопки открытия
OpenButton.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
    OpenGui.Enabled = false
end)

-- Следим за закрытием меню (RightControl - стандартный бинд Kavo)
UIS.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightControl and not gpe then
        task.wait(0.1)
        -- Если само меню скрыто, показываем нашу кнопку
        OpenGui.Enabled = true
    end
end)

-- [[ ВКЛАДКИ ]]
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat & Aim")
local Visuals = Main:NewSection("Visuals (Team Fix)")
local Movement = Main:NewSection("Movement & Fly")

Combat:NewToggle("Aimbot Hard Lock", "Только на врагов", function(state) getgenv().AimEnabled = state end)

Visuals:NewToggle("Smart Highlight ESP", "Враги-Красные, Свои-Зеленые", function(state) getgenv().ESPEnabled = state end)

Movement:NewSlider("Safe Speed", "Скорость", 250, 16, function(s) getgenv().Speed = s end)
Movement:NewToggle("Fly Mode", "Полет", function(state) getgenv().FlyEnabled = state end)

-- [[ УМНАЯ ПРОВЕРКА КОМАНДЫ ]]
local function IsEnemy(Player)
    if Player.Team ~= LP.Team then return true end
    if Player.Team == LP.Team and Player.TeamColor ~= LP.TeamColor then return true end
    if Player.Neutral then return true end
    return false
end

-- [[ ФУНКЦИЯ ESP ]]
local function ApplyESP(obj, p)
    if not obj:FindFirstChild("DultaHighlight") then
        local h = Instance.new("Highlight")
        h.Name = "DultaHighlight"
        h.Parent = obj
        h.FillAlpha = 0.5
        h.OutlineTransparency = 0
        
        RS.RenderStepped:Connect(function()
            if not h or not h.Parent then return end
            if IsEnemy(p) then
                h.FillColor = Color3.fromRGB(255, 0, 0) -- Враг
            else
                h.FillColor = Color3.fromRGB(0, 255, 0) -- Тим
            end
        end)
    end
end

-- [[ ЦИКЛЫ ]]
RS.RenderStepped:Connect(function()
    if getgenv().AimEnabled then
        local target = nil
        local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and IsEnemy(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then dist = mag; target = v.Character.HumanoidRootPart end
                end
            end
        end
        if target then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position) end
    end

    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then ApplyESP(v.Character, v) end
        end
    else
        for _, v in pairs(game:GetDescendants()) do
            if v.Name == "DultaHighlight" then v:Destroy() end
        end
    end

    -- Движение
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
