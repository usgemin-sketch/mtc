if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

print("[INK-FUNC]: Запуск финальной Drawing-версии без багов!")

local ActiveVisuals = {}

-- Универсальная функция полной зачистки 2D элемента из памяти
local function removeVisual(obj)
    if ActiveVisuals[obj] then
        pcall(function() ActiveVisuals[obj]:Remove() end)
        ActiveVisuals[obj] = nil
    end
end

RunService.RenderStepped:Connect(function()
    -- ПРОВЕРКА НА УДАЛЕННЫЕ ОБЪЕКТЫ (Фикс зависших рамок)
    for obj, draw in pairs(ActiveVisuals) do
        -- Если объект (стекло или игрок) удален из игры или провалился в небытие
        if typeof(obj) == "Instance" and (not obj:IsDescendantOf(workspace) or not obj.Parent) then
            removeVisual(obj)
        end
    end

    -- 1. СТЕЛЬС-ОБРАБОТКА МОСТА (Поиск строго glasspart)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "glasspart" then
            local gPos, gOnScreen = Camera:WorldToViewportPoint(obj.Position)
            
            -- Если плита на экране и она еще жива
            if gOnScreen and obj.Parent then
                if not ActiveVisuals[obj] then
                    ActiveVisuals[obj] = Drawing.new("Square")
                end
                
                local draw = ActiveVisuals[obj]
                draw.Visible = true
                draw.Thickness = 2.5
                draw.Filled = false
                draw.Size = Vector2.new(55, 35)
                draw.Position = Vector2.new(gPos.X - 27.5, gPos.Y - 17.5)
                
                local isKiller = false
                local success, result = pcall(function() return obj:GetAttribute("ActuallyKilling") end)
                if success and result == true then isKiller = true end
                
                if isKiller then
                    draw.Color = Color3.fromRGB(255, 35, 35) -- Красный (Ловушка)
                else
                    draw.Color = Color3.fromRGB(35, 255, 35) -- Зеленый (Безопасно)
                end
            else
                -- Если плита ушла за экран, просто временно скрываем рамку
                if ActiveVisuals[obj] then ActiveVisuals[obj].Visible = false end
            end
        end
    end

    -- 2. ESP НА ИГРОКОВ И ОХРАНУ
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            
            if hum and hum.Health > 0 then
                local pPos, pOnScreen = Camera:WorldToViewportPoint(root.Position)
                
                if pOnScreen then
                    if not ActiveVisuals[p] then
                        ActiveVisuals[p] = Drawing.new("Square")
                    end
                    
                    local draw = ActiveVisuals[p]
                    draw.Visible = true
                    draw.Thickness = 1.5
                    draw.Filled = false
                    draw.Size = Vector2.new(20, 35)
                    draw.Position = Vector2.new(pPos.X - 10, pPos.Y - 17.5)
                    
                    if p:GetAttribute("Role") == "Guard" or string.find(p.Name:lower(), "guard") then
                        draw.Color = Color3.fromRGB(255, 0, 120) -- Розовый (Охрана)
                    else
                        draw.Color = Color3.fromRGB(255, 255, 255) -- Белый (Обычные игроки)
                    end
                else
                    if ActiveVisuals[p] then ActiveVisuals[p].Visible = false end
                end
            else
                removeVisual(p) -- Убираем ESP, если игрок погиб
            end
        else
            removeVisual(p) -- Убираем ESP, если персонаж исчез
        end
    end
end)

-- Очистка памяти при выходе игроков с сервера
Players.PlayerRemoving:Connect(removeVisual)
