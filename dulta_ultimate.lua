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

-- [[ СОЗДАНИЕ GUI (БЕЗ ЛАГОВ) ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
local Title = Instance.new("TextLabel", MainFrame)
local ToggleAim = Instance.new("TextButton", MainFrame)
local ToggleESP = Instance.new("TextButton", MainFrame)
local ToggleFly = Instance.new("TextButton", MainFrame)
local SpeedInput = Instance.new("TextBox", MainFrame)
local Icon = Instance.new("TextButton", ScreenGui)

-- Стиль главного окна
MainFrame.Size = UDim2.new(0, 200, 0, 260)
MainFrame.Position = UDim2.new(0.5, -100, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false

local UICorner = Instance.new("UICorner", MainFrame)

Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "DULTA | RUST ALPHA"
Title.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.SourceSansBold

-- Настройка кнопок (универсальная функция)
local function StyleButton(btn, pos, text)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    Instance.new("UICorner", btn)
end

StyleButton(ToggleAim, 45, "Aimbot: OFF")
StyleButton(ToggleESP, 95, "Visuals: OFF")
StyleButton(ToggleFly, 145, "Fly: OFF")
StyleButton(SpeedInput, 195, "Speed: 16")
SpeedInput.PlaceholderText = "Type Speed here"
SpeedInput.Text = "16"

-- Иконка открытия
Icon.Size = UDim2.new(0, 60, 0, 60)
Icon.Position = UDim2.new(0, 10, 0.5, 0)
Icon.Text = "DULTA"
Icon.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Font = Enum.Font.SourceSansBold
Icon.Draggable = true
Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)

Icon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- [[ ЛОГИКА ФУНКЦИЙ ]]
ToggleAim.MouseButton1Click:Connect(function()
    getgenv().AimEnabled = not getgenv().AimEnabled
    ToggleAim.Text = getgenv().AimEnabled and "Aimbot: ON" or "Aimbot: OFF"
    ToggleAim.BackgroundColor3 = getgenv().AimEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
end)

ToggleESP.MouseButton1Click:Connect(function()
    getgenv().ESPEnabled = not getgenv().ESPEnabled
    ToggleESP.Text = getgenv().ESPEnabled and "Visuals: ON" or "Visuals: OFF"
    ToggleESP.BackgroundColor3 = getgenv().ESPEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
end)

ToggleFly.MouseButton1Click:Connect(function()
    getgenv().FlyEnabled = not getgenv().FlyEnabled
    ToggleFly.Text = getgenv().FlyEnabled and "Fly: ON" or "Fly: OFF"
    ToggleFly.BackgroundColor3 = getgenv().FlyEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
end)

SpeedInput.FocusLost:Connect(function()
    getgenv().Speed = tonumber(SpeedInput.Text) or 16
end)

-- [[ ПРОВЕРКА ТИМЕЙТА ]]
local function IsEnemy(v)
    if v.Team ~= LP.Team or v.TeamColor ~= LP.TeamColor then return true end
    return false
end

-- [[ ГЛАВНЫЙ ЦИКЛ (RUST FIX) ]]
RS.RenderStepped:Connect(function()
    -- AIMBOT (Legit Smooth)
    if getgenv().AimEnabled then
        local target = nil
        local dist = 600
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and IsEnemy(v) and v.Character and v.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then dist = mag; target = v.Character.Head end
                end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target.Position), 0.15)
        end
    end

    -- ESP
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

    -- MOVEMENT
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        local hum = LP.Character:FindFirstChildOfClass("Humanoid")
        if getgenv().FlyEnabled then
            hrp.Velocity = Vector3.new(0, 1.5, 0) -- Плавное парение
            if hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.5)
            end
        elseif getgenv().Speed > 16 and hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (getgenv().Speed / 100))
        end
    end
end)
