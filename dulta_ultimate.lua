-- DULTA ULTIMATE V1.5 (MOBILE REBUILD)
local p = game.Players.LocalPlayer
local mouse = p:GetMouse()
local camera = workspace.CurrentCamera
local rs = game:GetService("RunService")

-- СОЗДАЕМ ИНТЕРФЕЙС
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "Dulta_V15"

-- ГЛАВНАЯ КНОПКА (D)
local mainBtn = Instance.new("TextButton", sg)
mainBtn.Size = UDim2.new(0, 45, 0, 45)
mainBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
mainBtn.Text = "D"
mainBtn.TextColor3 = Color3.new(1,1,1)
mainBtn.Draggable = true

-- ПАНЕЛЬ УПРАВЛЕНИЯ
local menu = Instance.new("Frame", sg)
menu.Size = UDim2.new(0, 200, 0, 250)
menu.Position = UDim2.new(0.05, 50, 0.2, 0)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menu.BorderSizePixel = 2
menu.BorderColor3 = Color3.fromRGB(255, 0, 0)
menu.Visible = false

local function createToggle(name, pos, callback)
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
        callback(state)
    end)
end

-- ПЕРЕМЕННЫЕ ФУНКЦИЙ
local aimOn = false
local espOn = false
local flyOn = false

-- ЛОГИКА ОТКРЫТИЯ МЕНЮ
mainBtn.MouseButton1Click:Connect(function()
    menu.Visible = not menu.Visible
end)

-- ФУНКЦИИ
createToggle("AIMBOT", 10, function(v) aimOn = v end)
createToggle("ESP (ВХ)", 60, function(v) espOn = v end)
createToggle("FLY (ПОЛЕТ)", 110, function(v) flyOn = v end)
createToggle("SPEED (БЕГ)", 160, function(v) 
    p.Character.Humanoid.WalkSpeed = v and 100 or 16 
end)

-- РАБОТА ESP (ВХ)
local function makeEsp(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "DultaESP"
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = player.Character
    box.Color3 = Color3.new(1, 0, 0)
    box.Size = player.Character:GetExtentsSize()
    box.Transparency = 0.5
    box.Parent = player.Character
end

-- ЦИКЛ ОБНОВЛЕНИЯ
rs.RenderStepped:Connect(function()
    -- AIMBOT LOGIC
    if aimOn then
        local target = nil
        local maxDist = 500
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= p and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local pos, vis = camera:WorldToViewportPoint(head.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                    if mag < maxDist then
                        maxDist = mag
                        target = head
                    end
                end
            end
        end
        if target then
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
        end
    end
    
    -- ESP LOGIC
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hasEsp = v.Character:FindFirstChild("DultaESP")
            if espOn and not hasEsp then
                makeEsp(v)
            elseif not espOn and hasEsp then
                hasEsp:Destroy()
            end
        end
    end
    
    -- FLY LOGIC
    if flyOn and p.Character then
        p.Character.HumanoidRootPart.Velocity = Vector3.new(0, 50, 0) -- Простой подлет
    end
end)
