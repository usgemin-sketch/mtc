
-- inkgamelol.lua
-- Основной боевой модуль для Ink Game (Squid Game)
-- Намертво привязан к лоадеру. Запускается строго после успешной авторизации.

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Таблица для кэширования графических объектов Drawing API
local VisualsCache = {}

-- Функция очистки объектов при смене или удалении элементов
local function clearVisual(obj)
    if VisualsCache[obj] then
        for _, drawingItem in pairs(VisualsCache[obj]) do
            pcall(function() drawingItem:Remove() end)
        end
        VisualsCache[obj] = nil
    end
end

-- Бесконечный пассивный цикл рендера (RenderStepped)
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character then return end

    -- ============================================================================
    -- МОДУЛЬ 1: GLASS PREDICTOR (Стеклянный мост)
    -- ============================================================================
    local bridge = workspace:FindFirstChild("GlassBridge") or workspace:FindFirstChild("Bridge") or workspace:FindFirstChild("Glass")
    if bridge then
        for _, glass in pairs(bridge:GetDescendants()) do
            if glass:IsA("BasePart") and (string.find(glass.Name:lower(), "glass") or glass.Name == "GlassPane") then
                
                -- Пассивное считывание скрытых параметров, заложенных разработчиками игры
                local isFake = glass:FindFirstChild("Fake") or glass:GetAttribute("IsFake") or glass.Name == "FakeGlass"
                local gPos, gOnScreen = Camera:WorldToViewportPoint(glass.Position)
                
                if gOnScreen then
                    if not VisualsCache[glass] then
                        VisualsCache[glass] = { Box = Drawing.new("Square") }
                    end
                    
                    local draw = VisualsCache[glass].Box
                    draw.Visible = true
                    draw.Thickness = 2
                    draw.Size = Vector2.new(35, 35)
                    draw.Position = Vector2.new(gPos.X - 17.5, gPos.Y - 17.5)
                    
                    -- Если стекло фальшивое — красим в красный, если настоящее — в ярко-зеленый
                    if isFake then
                        draw.Color = Color3.fromRGB(255, 40, 40)
                    else
                        draw.Color = Color3.fromRGB(40, 255, 40)
                    end
                else
                    if VisualsCache[glass] then VisualsCache[glass].Box.Visible = false end
                end
            end
        end
    end

    -- ============================================================================
    -- МОДУЛЬ 2: SAFE PLAYER & GUARD ESP (Подсветка охраны и игроков)
    -- ============================================================================
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    if not VisualsCache[p] then
                        VisualsCache[p] = { Box = Drawing.new("Square") }
                    end
                    
                    local draw = VisualsCache[p].Box
                    draw.Visible = true
                    draw.Thickness = 1.5
                    draw.Size = Vector2.new(24, 38)
                    draw.Position = Vector2.new(screenPos.X - 12, screenPos.Y - 19)
                    
                    -- Охрану плейса (Гвардов) красим в неоновый розовый, обычных игроков — в белый
                    if p:GetAttribute("Role") == "Guard" or string.find(p.Name:lower(), "guard") then
                        draw.Color = Color3.fromRGB(255, 0, 120)
                    else
                        draw.Color = Color3.fromRGB(255, 255, 255)
                    end
                else
                    if VisualsCache[p] then VisualsCache[p].Box.Visible = false end
                end
            end
        end
    end
end)

-- Автоматическая очистка памяти при выходе игроков с сервера
Players.PlayerRemoving:Connect(function(p)
    clearVisual(p)
end)
