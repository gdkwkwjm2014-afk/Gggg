-- DULTA ULTIMATE v1.7 (ANTI-DEAD & SMART AIM)
local p = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

-- ГЛАВНЫЙ ИНТЕРФЕЙС
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "Dulta_v17"

local mainBtn = Instance.new("TextButton", sg)
mainBtn.Size = UDim2.new(0, 45, 0, 45)
mainBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
mainBtn.Text = "D"
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Draggable = true

local menu = Instance.new("Frame", sg)
menu.Size = UDim2.new(0, 190, 0, 220)
menu.Position = UDim2.new(0.05, 50, 0.2, 0)
menu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
menu.BorderColor3 = Color3.fromRGB(255, 0, 0)
menu.Visible = false

local function createToggle(name, y, callback)
    local b = Instance.new("TextButton", menu)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Position = UDim2.new(0, 5, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    b.Text = name .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = name .. ": " .. (state and "ON" or "OFF")
        b.BackgroundColor3 = state and Color3.fromRGB(180, 0, 0) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

mainBtn.MouseButton1Click:Connect(function() menu.Visible = not menu.Visible end)

-- ПЕРЕМЕННЫЕ
local aimOn, espOn, speedOn = false, false, false

createToggle("SMART AIM", 10, function(v) aimOn = v end)
createToggle("ESP BOX", 55, function(v) espOn = v end)
createToggle("FAST SPEED", 100, function(v) speedOn = v end)
createToggle("SERVER HOP", 145, function(v) 
    if v then game:GetService("TeleportService"):Teleport(game.PlaceId) end 
end)

-- ЛОГИКА АИМА (БЕЗ ТРУПОВ)
rs.RenderStepped:Connect(function()
    if aimOn then
        local target = nil
        local dist = 500
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then
                local head = v.Character.Head
                local hum = v.Character.Humanoid
                
                -- ПРОВЕРКА: ЖИВОЙ ЛИ ИГРОК И НЕ В СПАВН-ЗАЩИТЕ
                if hum.Health > 0 and not v.Character:FindFirstChildOfClass("ForceField") then
                    local pos, vis = camera:WorldToViewportPoint(head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                        if mag < dist then
                            dist = mag
                            target = head
                        end
                    end
                end
            end
        end
        if target then
            -- Плавная доводка (0.2), чтобы не палиться античиту
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Position), 0.2)
        end
    end

    -- ESP (ВХ)
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= p and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = v.Character.HumanoidRootPart
            local esp = hrp:FindFirstChild("DultaESP")
            if espOn and v.Character.Humanoid.Health > 0 then
                if not esp then
                    local b = Instance.new("BoxHandleAdornment", hrp)
                    b.Name = "DultaESP"
                    b.AlwaysOnTop, b.Size, b.Transparency = true, Vector3.new(4, 5, 1), 0.5
                    b.Color3 = Color3.new(1, 0, 0)
                end
            elseif esp then esp:Destroy() end
        end
    end
    
    -- Скорость
    if speedOn and p.Character and p.Character:FindFirstChild("Humanoid") then
        p.Character.Humanoid.WalkSpeed = 40
    end
end)
