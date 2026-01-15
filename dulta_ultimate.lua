--[[
    DULTA ULTIMATE - Alpha (Fixed Aim)
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- Очистка логов для защиты
pcall(function()
    if getconnections then
        for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do v:Disable() end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

getgenv().DultaSettings = {
    Aimbot = false,
    AimPart = "Head", -- Можно сменить на "HumanoidRootPart"
    Smoothness = 0.2, -- Плавность (чем меньше, тем быстрее)
    ESP = false,
    SpeedEnabled = false,
    SpeedValue = 50
}

-- Блок Anti-Ban (Базовый)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Ban" or method == "Kick" then return nil end
    return oldNamecall(self, ...)
end)

-- Интерфейс (Твое меню)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 320)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DULTA ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
OpenButton.Text = "D"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 25
OpenButton.Visible = false
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
OpenButton.Draggable = true

local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 210, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

-- Функциональные кнопки
CreateButton("Aimbot: OFF", 60, function(self)
    getgenv().DultaSettings.Aimbot = not getgenv().DultaSettings.Aimbot
    self.Text = getgenv().DultaSettings.Aimbot and "Aimbot: ON" or "Aimbot: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.Aimbot and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 55)
end)

CreateButton("ESP: OFF", 110, function(self)
    getgenv().DultaSettings.ESP = not getgenv().DultaSettings.ESP
    self.Text = getgenv().DultaSettings.ESP and "ESP: ON" or "ESP: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.ESP and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 55)
end)

CreateButton("Speed: OFF", 160, function(self)
    getgenv().DultaSettings.SpeedEnabled = not getgenv().DultaSettings.SpeedEnabled
    self.Text = getgenv().DultaSettings.SpeedEnabled and "Speed: ON" or "Speed: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.SpeedEnabled and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 55)
end)

CreateButton("Close Menu", 250, function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- Улучшенный алгоритм Аимбота
local function GetClosestPlayer()
    local target = nil
    local distance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().DultaSettings.AimPart) then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character[getgenv().DultaSettings.AimPart].Position)
            if onScreen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mouseDist < distance then
                    distance = mouseDist
                    target = player
                end
            end
        end
    end
    return target
end

-- Основной цикл работы
RunService.RenderStepped:Connect(function()
    -- Спидхак
    if getgenv().DultaSettings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().DultaSettings.SpeedValue
    end

    -- Аимбот (работает при зажатой Правой Кнопке Мыши)
    if getgenv().DultaSettings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPos = target.Character[getgenv().DultaSettings.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), getgenv().DultaSettings.Smoothness)
        end
    end

    -- ВХ (ESP)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hl = plr.Character:FindFirstChild("DultaHL")
            if getgenv().DultaSettings.ESP then
                if not hl then
                    hl = Instance.new("Highlight", plr.Character)
                    hl.Name = "DultaHL"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end
end)

print("DULTA V2 FIXED LOADED")
