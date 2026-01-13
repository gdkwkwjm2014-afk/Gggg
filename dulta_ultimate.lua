-- Упрощенный стабильный скрипт DULTA
local p = game.Players.LocalPlayer
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "DultaMobile"

-- КНОПКА МЕНЮ (Маленький красный квадрат)
local btn = Instance.new("TextButton", sg)
btn.Size = UDim2.new(0, 50, 0, 50)
btn.Position = UDim2.new(0.1, 0, 0.2, 0)
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.Text = "D"
btn.TextColor3 = Color3.new(1,1,1)
btn.Draggable = true -- Можно двигать!

-- КНОПКА АИМА
local aimBtn = Instance.new("TextButton", sg)
aimBtn.Size = UDim2.new(0, 80, 0, 40)
aimBtn.Position = UDim2.new(0.1, 60, 0.2, 5)
aimBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
aimBtn.Text = "AIM: OFF"
aimBtn.TextColor3 = Color3.new(1,1,1)

-- ПЕРЕМЕННЫЕ
local aimOn = false
local keyPassed = false

-- ЛОГИКА АИМА
aimBtn.MouseButton1Click:Connect(function()
    aimOn = not aimOn
    if aimOn then
        aimBtn.Text = "AIM: ON"
        aimBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        aimBtn.Text = "AIM: OFF"
        aimBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
    end
end)

-- САМ АИМ (БЕЗ НАВОДКИ ЧЕРЕЗ СТЕНЫ)
game:GetService("RunService").RenderStepped:Connect(function()
    if aimOn then
        local target = nil
        local maxDist = 500
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if vis then -- Проверка видимости
                    local mag = (Vector2.new(pos.X, pos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = head
                    end
                end
            end
        end
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end)

-- УВЕДОМЛЕНИЕ О ЗАПУСКЕ
print("DULTA LOADED")
