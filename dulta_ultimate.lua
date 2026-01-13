-- DULTA V4.0 ULTIMATE "MASTER PASTA" 
-- Смесь Unloosed, Neverlose и Lost Front

if not game:IsLoaded() then game.Loaded:Wait() end

-- [ СЕРВИСЫ ]
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- [ НАСТРОЙКИ ]
getgenv().Config = {
    Enabled = false,
    TeamCheck = true,
    VisibleCheck = true,
    
    -- Aim
    AimFOV = 150,
    AimPart = "Head",
    Prediction = 0.165,
    HitChance = 100,
    
    -- Visuals
    ShowFOV = true,
    ESP_Enabled = false,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Health = true,
    
    -- Misc
    WalkSpeed = 16,
    JumpPower = 50
}

-- [ UI LIBRARY ]
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/cueshut/saves/main/compact"))()
UI = UI.init("DULTA ULTIMATE", "v4.0", "Private")

-- [ РИСОВАНИЕ FOV ]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Radius = Config.AimFOV
FOVCircle.Filled = false
FOVCircle.Visible = Config.ShowFOV
FOVCircle.Color = Color3.fromRGB(255, 50, 50)

-- [ ТАБЫ ]
local AimTab = UI:AddTab("Aim", "Combat")
local VisualTab = UI:AddTab("Visuals", "ESP")
local MiscTab = UI:AddTab("Misc", "Character")

-- [ НАПОЛНЕНИЕ AIM ]
local AimSection = AimTab:AddSeperator("Silent Aim Settings")
AimSection:AddToggle({title = "Enabled", checked = false, callback = function(v) Config.Enabled = v end})
AimSection:AddSlider({title = "FOV Radius", values = {min=50, max=800, default=150}, callback = function(v) Config.AimFOV = v end})
AimSection:AddToggle({title = "Show FOV", checked = true, callback = function(v) Config.ShowFOV = v end})
AimSection:AddSelection({title = "Target", options = {"Head", "HumanoidRootPart"}, callback = function(v) Config.AimPart = (v[1] == 1 and "Head" or "HumanoidRootPart") end})

-- [ НАПОЛНЕНИЕ VISUALS ]
local EspSection = VisualTab:AddSeperator("ESP Settings")
EspSection:AddToggle({title = "Enable ESP", callback = function(v) Config.ESP_Enabled = v end})
EspSection:AddToggle({title = "Show Boxes", callback = function(v) Config.ESP_Boxes = v end})
EspSection:AddToggle({title = "Show Names", callback = function(v) Config.ESP_Names = v end})

-- [ НАПОЛНЕНИЕ MISC ]
local CharSection = MiscTab:AddSeperator("Movement")
CharSection:AddSlider({title = "Speed", values = {min=16, max=200, default=16}, callback = function(v) Config.WalkSpeed = v end})

-- [ ЛОГИКА АИМА ]
local function GetClosestPlayer()
    local target = nil
    local dist = Config.AimFOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild(Config.AimPart) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if Config.TeamCheck and p.Team == LP.Team then continue end
                
                local head = p.Character[Config.AimPart]
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if mag < dist then
                        dist = mag
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- [ ХУК ДЛЯ БЕЗОПАСНОСТИ ]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" then return nil end
    return oldNamecall(self, ...)
end))

-- [ ГЛАВНЫЙ ЦИКЛ ]
RS.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.AimFOV
    FOVCircle.Position = UIS:GetMouseLocation()
    
    if Config.Enabled then
        local target = GetClosestPlayer()
        if target then
            -- Silent Aim Logic (Плавная доводка)
            local targetPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UIS:GetMouseLocation()
            local moveX = (targetPos.X - mousePos.X) * 0.15
            local moveY = (targetPos.Y - mousePos.Y) * 0.15
            
            -- Имитация движения мыши (безопасно для мобилок и ПК)
            if mousemoverel then mousemoverel(moveX, moveY) end
        end
    end
    
    -- ESP Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local highlight = p.Character:FindFirstChild("DultaHighlight")
            if Config.ESP_Enabled and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "DultaHighlight"
                end
                highlight.FillColor = (p.Team == LP.Team and Color3.new(0,1,0) or Color3.new(1,0,0))
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
    
    -- Speed
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end
end)

UI:Notify("DULTA v4.0", "Все системы запущены!")
