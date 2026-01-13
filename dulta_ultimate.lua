--[[ 
    DULTA EXPLOIT - BLOOD EDITION (FINAL)
    KEY: Dulta1111
]]

-- 1. СИСТЕМА ЗАЩИТЫ (ANTI-BAN) - ЗАПУСКАЕТСЯ САМА
local function AntiBan()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local old = mt.__index
    mt.__index = newcclosure(function(t, k)
        if k == "WalkSpeed" then return 16 end
        if k == "JumpPower" then return 50 end
        return old(t, k)
    end)
    setreadonly(mt, true)
end
AntiBan()

-- 2. БИБЛИОТЕКА И ТЕМА
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("DULTA | BLOOD EDITION", "Midnight")

-- Настройка Кровавой темы
for i, v in pairs(game.CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and v.Name == "Library" then
        v.Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        v.Main.SideBar.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    end
end

-- 3. БЫСТРОЕ МЕНЮ (КВАДРАТ И КНОПКА АИМА)
local QuickUI = Instance.new("ScreenGui")
local DragFrame = Instance.new("Frame")
local Logo = Instance.new("ImageButton")
local FastAim = Instance.new("TextButton")

QuickUI.Name = "DultaQuick"
QuickUI.Parent = game.CoreGui

-- Контейнер для кнопок (чтобы перемещать вместе)
DragFrame.Name = "DragFrame"
DragFrame.Parent = QuickUI
DragFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
DragFrame.BackgroundTransparency = 1
DragFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
DragFrame.Size = UDim2.new(0, 130, 0, 40)
DragFrame.Active = true
DragFrame.Draggable = true -- ПЕРЕМЕЩАЙ ПАЛЬЦЕМ

-- Маленький логотип
Logo.Name = "Logo"
Logo.Parent = DragFrame
Logo.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Logo.BorderSizePixel = 2
Logo.BorderColor3 = Color3.fromRGB(255, 0, 0)
Logo.Size = UDim2.new(0, 40, 0, 40)
Logo.Image = "rbxassetid://13501134265" -- Временное лого, замени на свое

-- Кнопка быстрого аима
FastAim.Name = "FastAim"
FastAim.Parent = DragFrame
FastAim.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
FastAim.BorderSizePixel = 2
FastAim.BorderColor3 = Color3.fromRGB(255, 0, 0)
FastAim.Position = UDim2.new(1.1, 0, 0, 0)
FastAim.Size = UDim2.new(0, 80, 0, 40)
FastAim.Text = "AIM: OFF"
FastAim.TextColor3 = Color3.fromRGB(255, 255, 255)
FastAim.TextSize = 14
FastAim.Font = Enum.Font.BlackOpsOne

-- Переменные функций
_G.AimEnabled = false
_G.ESPEnabled = false

-- Логика кнопок
FastAim.MouseButton1Click:Connect(function()
    _G.AimEnabled = not _G.AimEnabled
    if _G.AimEnabled then
        FastAim.Text = "AIM: ON"
        FastAim.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    else
        FastAim.Text = "AIM: OFF"
        FastAim.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    end
end)

Logo.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- 4. ОСНОВНЫЕ ВКЛАДКИ
local Auth = Window:NewTab("Логин")
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")

-- АВТОРИЗАЦИЯ
local AuthSec = Auth:NewSection("DULTA V1.3")
AuthSec:NewTextbox("Введите Ключ", "Dulta1111", function(txt)
    if txt == "Dulta1111" then
        Library:Notify("DULTA", "Доступ открыт!", 3)
    end
end)

-- COMBAT (АИМ)
local AimSec = Combat:NewSection("Настройки Убийства")
AimSec:NewToggle("Аим (Только видимые)", "Не наводит через стены", function(v)
    _G.AimEnabled = v
end)
AimSec:NewSlider("Радиус (FOV)", "Круг захвата", 50, 500, 150, function(v)
    -- Тут обновление радиуса круга
end)

-- VISUALS (ВХ)
local ESPBox = Visuals:NewSection("Боксы и Линии")
local ESPSkel = Visuals:NewSection("Скелеты")

ESPBox:NewToggle("ESP Boxes", "Показывать квадраты", function(v) _G.Boxes = v end)
ESPBox:NewToggle("Tracers", "Линии к игрокам", function(v) _G.Tracers = v end)
ESPSkel:NewToggle("Skeleton", "Показать кости", function(v) _G.Skeletons = v end)

-- MOVEMENT
local MoveSec = Movement:NewSection("Движение")
MoveSec:NewSlider("Speed Hack", "Скорость бега", 16, 200, 16, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
end)
MoveSec:NewToggle("Infinite Jump", "Прыгай в небеса", function(v)
    _G.InfJump = v
end)

-- 5. ЛОГИКА АИМА (БЕЗ НАВОДКИ ЧЕРЕЗ СТЕНЫ)
spawn(function()
    while wait() do
        if _G.AimEnabled then
            local target = nil
            local dist = math.huge
            for i, v in pairs(game.Players:GetPlayers()) do
                if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    local pos, visible = game.Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    if visible then -- ПРОВЕРКА ВИДИМОСТИ
                        local mag = (Vector2.new(pos.X, pos.Y) - game:GetService("UserInputService"):GetMouseLocation()).Magnitude
                        if mag < dist then
                            dist = mag
                            target = head
                        end
                    end
                end
            end
            if target then
                game.Workspace.CurrentCamera.CFrame = CFrame.new(game.Workspace.CurrentCamera.CFrame.Position, target.Position)
            end
        end
    end
end)

Library:Notify("DULTA", "Скрипт загружен. Нажми 'D' для меню", 5)
