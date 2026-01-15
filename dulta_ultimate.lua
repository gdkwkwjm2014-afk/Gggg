--[[
    DULTA ULTIMATE - Alpha
    Загрузка через loadstring активна.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Глобальные настройки
getgenv().DultaSettings = {
    Aimbot = false,
    ESP = false,
    SpeedEnabled = false,
    SpeedValue = 50,
    MenuKey = Enum.KeyCode.RightShift
}

-- Блок Anti-Ban
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Ban" or method == "Kick" then 
        return nil 
    end
    return oldNamecall(self, ...)
end)

-- Интерфейс
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "DultaGui"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Можно двигать

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "DULTA ULTIMATE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold

-- Иконка "D" для разворачивания
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0.5, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
OpenButton.Text = "D"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 25
OpenButton.Visible = false
Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
OpenButton.Draggable = true

-- Функция создания кнопок
local function CreateButton(text, yPos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 210, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(250, 250, 250)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

-- Логика кнопок
CreateButton("Aimbot: OFF", 60, function(self)
    getgenv().DultaSettings.Aimbot = not getgenv().DultaSettings.Aimbot
    self.Text = getgenv().DultaSettings.Aimbot and "Aimbot: ON" or "Aimbot: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.Aimbot and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 60)
end)

CreateButton("ESP (Wallhack): OFF", 110, function(self)
    getgenv().DultaSettings.ESP = not getgenv().DultaSettings.ESP
    self.Text = getgenv().DultaSettings.ESP and "ESP: ON" or "ESP: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.ESP and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 60)
end)

CreateButton("Speedhack: OFF", 160, function(self)
    getgenv().DultaSettings.SpeedEnabled = not getgenv().DultaSettings.SpeedEnabled
    self.Text = getgenv().DultaSettings.SpeedEnabled and "Speed: ON" or "Speed: OFF"
    self.BackgroundColor3 = getgenv().DultaSettings.SpeedEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 60)
end)

CreateButton("Close Menu", 230, function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- РАБОТА ФУНКЦИЙ (LOOP)
RunService.RenderStepped:Connect(function()
    -- Speed
    if getgenv().DultaSettings.SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().DultaSettings.SpeedValue
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end

    -- ESP & Aim
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            -- ESP Highlight
            local hasHighlight = plr.Character:FindFirstChild("DultaHighlight")
            if getgenv().DultaSettings.ESP then
                if not hasHighlight then
                    local hl = Instance.new("Highlight", plr.Character)
                    hl.Name = "DultaHighlight"
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                end
            elseif hasHighlight then
                hasHighlight:Destroy()
            end
        end
    end
end)

-- Простой Аимбот (на правую кнопку мыши)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and getgenv().DultaSettings.Aimbot then
        local closest = nil
        local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mDist < dist then
                        dist = mDist
                        closest = p
                    end
                end
            end
        end
        if closest then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
        end
    end
end)

print("DULTA ULTIMATE LOADED!")
