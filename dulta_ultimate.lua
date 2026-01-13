local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- [[ НАСТРОЙКИ ]]
getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FlyEnabled = false
getgenv().Speed = 16

-- [[ СОЗДАНИЕ МЕНЮ (GUI) ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", MainFrame)
local ToggleAim = Instance.new("TextButton", MainFrame)
local ToggleESP = Instance.new("TextButton", MainFrame)
local ToggleFly = Instance.new("TextButton", MainFrame)
local SpeedSlider = Instance.new("TextBox", MainFrame)
local CloseBtn = Instance.new("TextButton", MainFrame)

-- Стиль меню
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Можно таскать!

Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DULTA ULTIMATE v26"
Title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Title.TextColor3 = Color3.new(1,1,1)

-- Кнопка Аим
ToggleAim.Size = UDim2.new(0, 180, 0, 40)
ToggleAim.Position = UDim2.new(0, 10, 0, 40)
ToggleAim.Text = "Aimbot: OFF"
ToggleAim.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleAim.TextColor3 = Color3.new(1,1,1)

-- Кнопка ВХ
ToggleESP.Size = UDim2.new(0, 180, 0, 40)
ToggleESP.Position = UDim2.new(0, 10, 0, 90)
ToggleESP.Text = "ESP: OFF"
ToggleESP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleESP.TextColor3 = Color3.new(1,1,1)

-- Кнопка Полет
ToggleFly.Size = UDim2.new(0, 180, 0, 40)
ToggleFly.Position = UDim2.new(0, 10, 0, 140)
ToggleFly.Text = "Fly: OFF"
ToggleFly.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleFly.TextColor3 = Color3.new(1,1,1)

-- Поле скорости
SpeedSlider.Size = UDim2.new(0, 180, 0, 40)
SpeedSlider.Position = UDim2.new(0, 10, 0, 190)
SpeedSlider.PlaceholderText = "Speed (16-200)"
SpeedSlider.Text = "16"
SpeedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SpeedSlider.TextColor3 = Color3.new(1,1,1)

-- Иконка открытия
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0, 10, 0.5, 0)
Icon.Text = "DULTA"
Icon.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Draggable = true

Icon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [[ ЛОГИКА КНОПОК ]]
ToggleAim.MouseButton1Click:Connect(function()
    getgenv().AimEnabled = not getgenv().AimEnabled
    ToggleAim.Text = getgenv().AimEnabled and "Aimbot: ON" or "Aimbot: OFF"
    ToggleAim.BackgroundColor3 = getgenv().AimEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

ToggleESP.MouseButton1Click:Connect(function()
    getgenv().ESPEnabled = not getgenv().ESPEnabled
    ToggleESP.Text = getgenv().ESPEnabled and "ESP: ON" or "ESP: OFF"
    ToggleESP.BackgroundColor3 = getgenv().ESPEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

ToggleFly.MouseButton1Click:Connect(function()
    getgenv().FlyEnabled = not getgenv().FlyEnabled
    ToggleFly.Text = getgenv().FlyEnabled and "Fly: ON" or "Fly: OFF"
    ToggleFly.BackgroundColor3 = getgenv().FlyEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

SpeedSlider.FocusLost:Connect(function()
    getgenv().Speed = tonumber(SpeedSlider.Text) or 16
end)

-- [[ ФУНКЦИИ ]]
local function IsEnemy(v)
    return v.Team ~= LP.Team or v.TeamColor ~= LP.TeamColor
end

RS.RenderStepped:Connect(function()
    if getgenv().AimEnabled then
        local target = nil
        local dist = 500
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
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaESP") or Instance.new("Highlight", v.Character)
                h.Name = "DultaESP"
                h.FillColor = IsEnemy(v) and Color3.new(1,0,0) or Color3.new(0,1,0)
                h.FillAlpha = 0.5
            end
        end
    else
        for _, v in pairs(game:GetDescendants()) do if v.Name == "DultaESP" then v:Destroy() end end
    end

    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if getgenv().FlyEnabled then
            hrp.Velocity = Vector3.new(0,0.1,0)
            if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.2)
            end
        elseif getgenv().Speed > 16 and LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (LP.Character.Humanoid.MoveDirection * (getgenv().Speed / 100))
        end
    end
end)
