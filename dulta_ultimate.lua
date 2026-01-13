local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v15", "BloodTheme")

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Настройки
getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().Speed = 16

-- [[ СКРИПТ ДЛЯ ПЕРЕМЕЩЕНИЯ МЕНЮ ]]
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Применяем перетаскивание ко всему окну
for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
    if v.Name == "Main" and v:IsA("Frame") then
        MakeDraggable(v)
    end
end

-- Вкладки
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat")
local Visuals = Main:NewSection("Visuals")
local Misc = Main:NewSection("Misc")

-- [КНОПКИ]
Combat:NewToggle("Aimbot (Hard Lock)", "Наводит на ближайшего врага", function(state)
    getgenv().AimEnabled = state
end)

Visuals:NewToggle("Team ESP", "Враги - Красные, Свои - Синие", function(state)
    getgenv().ESPEnabled = state
end)

Misc:NewSlider("WalkSpeed", "Скорость", 250, 16, function(s)
    getgenv().Speed = s
end)

-- [ЛОГИКА АИМА]
local function GetClosest()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Team ~= LP.Team and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if v.Character.Humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
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

-- [ОСНОВНОЙ ЦИКЛ]
RS.RenderStepped:Connect(function()
    -- Работа Аима
    if getgenv().AimEnabled then
        local target = GetClosest()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- Работа Скорости
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().Speed
    end

    -- Работа ВХ
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaHighlight")
                if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    if not h then
                        h = Instance.new("Highlight", v.Character)
                        h.Name = "DultaHighlight"
                    end
                    h.FillColor = (v.Team == LP.Team and Color3.new(0, 0.5, 1) or Color3.new(1, 0, 0))
                else
                    if h then h:Destroy() end
                end
            end
        end
    end
end)
