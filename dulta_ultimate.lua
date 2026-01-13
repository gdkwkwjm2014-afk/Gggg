-- DULTA ULTIMATE v2.0 (Xan UI & Pro ESP)
-- KEY: Dulta1111

local UI = loadstring(game:HttpGet("https://xan.bar/init.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- КОНФИГ
local Config = {
    ESP_Enabled = false,
    ESP_TeamCheck = true,
    AIM_Enabled = false,
    AIM_FOV = 200,
    AIM_Smooth = 0.1,
    AIM_TargetPart = "Head",
    ShowFOV = true,
    Speed = 16
}

-- СОЗДАНИЕ МЕНЮ
local Window = UI.NewWindow("DULTA ULTIMATE", "v2.0")

local MainTab = Window.NewTab("Combat")
local VisualsTab = Window.NewTab("Visuals")
local MiscTab = Window.NewTab("Movement")

-- ВКЛАДКА COMBAT (AIM)
MainTab.NewToggle("Enable Aimbot", false, function(v) Config.AIM_Enabled = v end)
MainTab.NewSlider("Aimbot FOV", 50, 800, 200, function(v) Config.AIM_FOV = v end)
MainTab.NewDropdown("Target Part", {"Head", "Torso"}, function(v) Config.AIM_TargetPart = v end)
MainTab.NewToggle("Show FOV Circle", true, function(v) Config.ShowFOV = v end)

-- ВКЛАДКА VISUALS (ESP)
VisualsTab.NewToggle("Enable Highlights (WH)", false, function(v) Config.ESP_Enabled = v end)
VisualsTab.NewToggle("Team Check", true, function(v) Config.ESP_TeamCheck = v end)

-- ВКЛАДКА MISC
MiscTab.NewSlider("WalkSpeed", 16, 200, 16, function(v) Config.Speed = v end)

-- РАБОТА FOV КРУГА
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ФУНКЦИЯ ESP (HIGHLIGHTS)
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local highlight = char:FindFirstChild("DultaHighlight")
            
            if Config.ESP_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "DultaHighlight"
                    highlight.Parent = char
                end
                
                -- Проверка тимы
                if Config.ESP_TeamCheck and player.Team == LocalPlayer.Team then
                    highlight.Enabled = false
                else
                    highlight.Enabled = true
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillAlpha = 0.5
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- ЛОГИКА АИМА
local function GetClosestPlayer()
    local target = nil
    local dist = Config.AIM_FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.AIM_TargetPart) then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not (Config.ESP_TeamCheck and player.Team == LocalPlayer.Team) then
                    local part = player.Character[Config.AIM_TargetPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if magnitude < dist then
                            dist = magnitude
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- ЦИКЛ ОБНОВЛЕНИЯ
RunService.RenderStepped:Connect(function()
    -- Обновление круга
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.AIM_FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    -- Обновление Аима
    if Config.AIM_Enabled then
        local target = GetClosestPlayer()
        if target then
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            -- Плавное наведение (Lerp)
            mousemoverel((targetPos.X - mousePos.X) * Config.AIM_Smooth, (targetPos.Y - mousePos.Y) * Config.AIM_Smooth)
        end
    end
    
    -- Скорость
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.Speed
    end
    
    UpdateESP()
end)

UI.Notify("DULTA v2.0", "Script Loaded Successfully!")
