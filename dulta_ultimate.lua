-- [[ ЛОКАЛЬНЫЕ ПЕРЕМЕННЫЕ ]]
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

getgenv().AimEnabled = false
getgenv().ESPEnabled = false
getgenv().FlyEnabled = false
getgenv().Speed = 16

-- [[ СОЗДАНИЕ ИКОНКИ ОТКРЫТИЯ ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ImageButton = Instance.new("ImageButton", ScreenGui)
ImageButton.Size = UDim2.new(0, 50, 0, 50)
ImageButton.Position = UDim2.new(0, 10, 0.5, 0)
ImageButton.Image = "rbxassetid://7072725342" -- Иконка Dulta
ImageButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ImageButton.Active = true
ImageButton.Draggable = true

-- [[ ЗАГРУЗКА БИБЛИОТЕКИ (VORTEX) ]]
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA ULTIMATE v24", "BloodTheme")

-- Переключение видимости по клику на иконку
ImageButton.MouseButton1Click:Connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.RightControl, false, game)
end)

-- [[ ВКЛАДКИ ]]
local Main = Window:NewTab("Main")
local Combat = Main:NewSection("Combat & Aim")
local Visuals = Main:NewSection("Visuals (Team Check)")
local Misc = Main:NewSection("Movement")

Combat:NewToggle("Aimbot (Only Enemies)", "Наводить на красных", function(state)
    getgenv().AimEnabled = state
end)

Visuals:NewToggle("Highlight ESP", "Враги: Красные, Свои: Зеленые", function(state)
    getgenv().ESPEnabled = state
end)

Misc:NewSlider("Bypass Speed", "Скорость бега", 250, 16, function(s)
    getgenv().Speed = s
end)

Misc:NewToggle("Fly Mode", "Полет (упр. камерой)", function(state)
    getgenv().FlyEnabled = state
end)

-- [[ ФУНКЦИЯ ПРОВЕРКИ ВРАГА ]]
local function IsEnemy(p)
    if p.Team ~= LP.Team or p.TeamColor ~= LP.TeamColor then
        return true
    end
    return false
end

-- [[ ОСНОВНОЙ ЦИКЛ ]]
RS.RenderStepped:Connect(function()
    -- AIMBOT LOGIC
    if getgenv().AimEnabled then
        local target = nil
        local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and IsEnemy(v) and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
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
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        end
    end

    -- ESP LOGIC
    if getgenv().ESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaHighlight")
                if not h then
                    h = Instance.new("Highlight", v.Character)
                    h.Name = "DultaHighlight"
                end
                h.FillColor = IsEnemy(v) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                h.FillAlpha = 0.5
            end
        end
    else
        for _, v in pairs(game:GetDescendants()) do
            if v.Name == "DultaHighlight" then v:Destroy() end
        end
    end

    -- MOVEMENT LOGIC
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if getgenv().FlyEnabled then
            hrp.Velocity = Vector3.zero
            if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.5)
            end
        elseif getgenv().Speed > 16 and LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (LP.Character.Humanoid.MoveDirection * (getgenv().Speed / 100))
        end
    end
end)
