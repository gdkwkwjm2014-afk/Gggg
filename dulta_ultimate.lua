--[[
    DULTA ULTIMATE - VERSION ALPHA
    Developer: StepBroFurious & Gemini
    Functions: Aim on Shoot, ESP, Speed, Anti-Ban
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- Глобальные настройки
getgenv().DultaSettings = {
    Aimbot = false,
    ESP = false,
    Speed = false,
    WalkSpeedValue = 60,
    AimPart = "Head"
}

-- 1. АНТИ-БАН И АНТИ-КИК
local X;
X = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "Ban" or method == "Kick" or method == "Panic" then
        warn("DULTA: Попытка бана/кика заблокирована!")
        return nil
    end
    return X(self, ...)
end)

-- 2. ГРАФИЧЕСКИЙ ИНТЕРФЕЙС (UI)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DultaRoot"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно перемещать
local MainCorner = Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "DULTA SOFT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold

-- Иконка "D" для сворачивания
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 55, 0, 55)
OpenButton.Position = UDim2.new(0, 20, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
OpenButton.Text = "D"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 28
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
local btnCorner = Instance.new("UICorner", OpenButton)
btnCorner.CornerRadius = UDim.new(1, 0)
OpenButton.Draggable = true

-- Функция для создания кнопок в меню
local function AddButton(text, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 220, 0, 45)
    btn.Position = UDim2.new(0.5, -110, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

-- Логика кнопок меню
AddButton("AIMBOT: OFF", 60, function(self)
    getgenv().DultaSettings.Aimbot = not getgenv().DultaSettings.Aimbot
    self.Text = getgenv().DultaSettings.Aimbot and "AIMBOT: ON" or "AIMBOT: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.Aimbot and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(40, 40, 45)
end)

AddButton("WALLHACK (ESP): OFF", 115, function(self)
    getgenv().DultaSettings.ESP = not getgenv().DultaSettings.ESP
    self.Text = getgenv().DultaSettings.ESP and "WALLHACK: ON" or "WALLHACK: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.ESP and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(40, 40, 45)
end)

AddButton("SPEEDHACK: OFF", 170, function(self)
    getgenv().DultaSettings.Speed = not getgenv().DultaSettings.Speed
    self.Text = getgenv().DultaSettings.Speed and "SPEED: ON" or "SPEED: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.Speed and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(40, 40, 45)
end)

AddButton("HIDE MENU", 260, function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- 3. ЛОГИКА ФУНКЦИЙ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Поиск ближайшего игрока к прицелу
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local part = player.Character:FindFirstChild(getgenv().DultaSettings.AimPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    return target
end

-- Основной цикл (обновление каждый кадр)
RunService.RenderStepped:Connect(function()
    -- AIMBOT (Наводится при выстреле - Левая Кнопка Мыши)
    if getgenv().DultaSettings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local closest = GetClosestPlayer()
        if closest and closest.Character and closest.Character:FindFirstChild(getgenv().DultaSettings.AimPart) then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character[getgenv().DultaSettings.AimPart].Position)
        end
    end

    -- ESP (Подсветка)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hl = player.Character:FindFirstChild("DultaHighlight")
            if getgenv().DultaSettings.ESP then
                if not hl then
                    hl = Instance.new("Highlight", player.Character)
                    hl.Name = "DultaHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0) -- Красный цвет
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if hl then hl:Destroy() end
            end
        end
    end

    -- SPEED
    if getgenv().DultaSettings.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().DultaSettings.WalkSpeedValue
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

print("DULTA ULTIMATE LOADED SUCCESSFULLY")
