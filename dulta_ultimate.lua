local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v17 | TEAM FIX", "BloodTheme")

-- Сервисы
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Настройки
getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FFA = false -- Режим "Все против всех"
getgenv().WalkSpeed = 16

-- [[ ФУНКЦИЯ ПЕРЕМЕЩЕНИЯ (DRAGGABLE) ]]
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

task.spawn(function()
    local mainFrame = game:GetService("CoreGui"):WaitForChild("Library", 5)
    if mainFrame then MakeDraggable(mainFrame:FindFirstChild("Main")) end
end)

-- [[ ВКЛАДКИ ]]
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat ⚔️")
local Visuals = Main:NewSection("Visuals 👁️")
local Player = Main:NewSection("Player ⚡")

-- [COMBAT]
Combat:NewToggle("Aimbot Hard Lock", "Приклеивает прицел к цели", function(state)
    getgenv().AimEnabled = state
end)

Combat:NewToggle("FFA Mode (Аим на всех)", "Включи, если аим не видит врагов", function(state)
    getgenv().FFA = state
end)

-- [VISUALS]
Visuals:NewToggle("Smart ESP", "Разделение на врагов/друзей", function(state)
    getgenv().ESPEnabled = state
end)

-- [PLAYER]
Player:NewSlider("WalkSpeed", "Скорость", 250, 16, function(s)
    getgenv().WalkSpeed = s
end)

-- [[ ЛОГИКА ОПРЕДЕЛЕНИЯ ВРАГА ]]
local function IsEnemy(Player)
    if getgenv().FFA then return true end -- Если FFA включен, все враги
    
    -- Проверка по команде и цвету команды
    if Player.Team ~= LP.Team or (Player.TeamColor ~= LP.TeamColor) then
        return true
    end
    return false
end

-- [[ ПОИСК ЦЕЛИ ]]
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if IsEnemy(v) and v.Character.Humanoid.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < shortestDist then
                        shortestDist = mag
                        target = v.Character.HumanoidRootPart
                    end
                end
            end
        end
    end
    return target
end

-- [[ ГЛАВНЫЙ ЦИКЛ ]]
RS.RenderStepped:Connect(function()
    -- Аим
    if getgenv().AimEnabled then
        local t = GetClosestTarget()
        if t then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position)
        end
    end

    -- Скорость
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = getgenv().WalkSpeed
    end

    -- ESP
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaESP")
                if v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                    if not h then
                        h = Instance.new("Highlight", v.Character)
                        h.Name = "DultaESP"
                        h.FillAlpha = 0.5
                    end
                    
                    -- Умная раскраска
                    if IsEnemy(v) then
                        h.FillColor = Color3.fromRGB(255, 0, 0) -- Красный враг
                    else
                        h.FillColor = Color3.fromRGB(0, 255, 0) -- Зеленый друг
                    end
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
