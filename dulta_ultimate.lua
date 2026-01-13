local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- [[ НАСТРОЙКИ ]]
getgenv().Config = {
    Aim = false,
    Silent = true, -- Булет трак
    ESP = false,
    NoRecoil = true,
    RapidFire = true,
    Fly = false,
    Speed = 16
}

-- [[ ПРОВЕРКА ДРУЗЕЙ ]]
local function IsFriend(Player)
    if Player == LP then return true end
    return LP:IsFriendsWith(Player.UserId)
end

-- [[ GUI ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 320)
Main.Position = UDim2.new(0.5, -110, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "DULTA ULTIMATE | FLICK"
Title.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Title.TextColor3 = Color3.new(1,1,1)

local function CreateBtn(name, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

CreateBtn("Rage Aimbot", 40, function(b)
    getgenv().Config.Aim = not getgenv().Config.Aim
    b.Text = "Rage Aimbot: " .. (getgenv().Config.Aim and "ON" or "OFF")
    b.BackgroundColor3 = getgenv().Config.Aim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 40)
end)

CreateBtn("Bullet Track", 85, function(b)
    getgenv().Config.Silent = not getgenv().Config.Silent
    b.Text = "Bullet Track: " .. (getgenv().Config.Silent and "ON" or "OFF")
end)

CreateBtn("Visuals", 130, function(b)
    getgenv().Config.ESP = not getgenv().Config.ESP
    b.Text = "Visuals: " .. (getgenv().Config.ESP and "ON" or "OFF")
end)

CreateBtn("Fly Mode", 175, function(b)
    getgenv().Config.Fly = not getgenv().Config.Fly
    b.Text = "Fly: " .. (getgenv().Config.Fly and "ON" or "OFF")
end)

local SpdInput = Instance.new("TextBox", Main)
SpdInput.Size = UDim2.new(0, 200, 0, 35)
SpdInput.Position = UDim2.new(0, 10, 0, 220)
SpdInput.PlaceholderText = "Speed Value"
SpdInput.Text = "16"
SpdInput.FocusLost:Connect(function() getgenv().Config.Speed = tonumber(SpdInput.Text) or 16 end)

-- Иконка
local Icon = Instance.new("TextButton", ScreenGui)
Icon.Size = UDim2.new(0, 50, 0, 50)
Icon.Position = UDim2.new(0, 10, 0.5, 0)
Icon.Text = "DULTA"
Icon.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Icon.TextColor3 = Color3.new(1,1,1)
Icon.Draggable = true
Icon.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- [[ ГЛАВНАЯ ЛОГИКА (RAGE) ]]
local function GetClosest()
    local target, dist = nil, 2000
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LP and not IsFriend(v) and v.Character and v.Character:FindFirstChild("Head") then
            local head = v.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if m < dist then dist = m; target = head end
            end
        end
    end
    return target
end

-- Взлом стрельбы (No Recoil & Rapid Fire)
task.spawn(function()
    while task.wait() do
        if getgenv().Config.NoRecoil or getgenv().Config.RapidFire then
            for _, v in pairs(getreg()) do
                if type(v) == "table" and rawget(v, "Recoil") then
                    v.Recoil = 0
                    v.Spread = 0
                    v.FireRate = 0.05 -- Очень быстро
                    v.Ammo = 999
                    v.MaxAmmo = 999
                end
            end
        end
    end
end)

-- Булет Трак (Silent Aim)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "FindPartOnRayWithIgnoreList" and getgenv().Config.Silent then
        local t = GetClosest()
        if t then
            return t, t.Position, t.CFrame.LookVector, t.Material
        end
    end
    return oldNamecall(self, ...)
end)

RS.RenderStepped:Connect(function()
    -- Аимбот (Резкий)
    if getgenv().Config.Aim then
        local t = GetClosest()
        if t then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Position) end
    end

    -- ВХ
    if getgenv().Config.ESP then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local h = v.Character:FindFirstChild("DultaESP") or Instance.new("Highlight", v.Character)
                h.Name = "DultaESP"
                h.FillColor = IsFriend(v) and Color3.new(0,1,0) or Color3.new(1,0,0)
                h.FillAlpha = 0.4
            end
        end
    else
        for _, v in pairs(game:GetDescendants()) do if v.Name == "DultaESP" then v:Destroy() end end
    end

    -- Флай и Спид
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LP.Character.HumanoidRootPart
        if getgenv().Config.Fly then
            hrp.Velocity = Vector3.new(0, 2, 0)
            if LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (Camera.CFrame.LookVector * 1.8)
            end
        elseif getgenv().Config.Speed > 16 and LP.Character.Humanoid.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + (LP.Character.Humanoid.MoveDirection * (getgenv().Config.Speed / 100))
        end
    end
end)
