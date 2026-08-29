-- =================================================================
-- Client Key System Loader v2.1 (Fixed UI Lifetime & Time Display)
-- =================================================================

local SERVER_URL = "https://server-ca9b.onrender.com"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function GetHWID()
    if gethwid then return gethwid() end
    if get_hwid then return get_hwid() end
    if getdeviceid then return getdeviceid() end
    
    local clientId = game:GetService("RbxAnalyticsService"):GetClientId()
    return clientId or "UNKNOWN_HWID"
end

local function HttpRequest(url)
    local reqFn = (http and http.request) or (http_request) or (syn and syn.request) or request
    if reqFn then
        local res = reqFn({
            Url = url,
            Method = "GET"
        })
        return res.Body
    else
        return game:HttpGet(url)
    end
end

local function CreateKeyUI()
    local CoreGui = gethui and gethui() or game:GetService("CoreGui")
    if CoreGui:FindFirstChild("InkKeySystemUI") then
        CoreGui.InkKeySystemUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local KeyInput = Instance.new("TextBox")
    local SubmitBtn = Instance.new("TextButton")
    
    -- Информационные строки
    local StatusLabel = Instance.new("TextLabel")      -- Строка 1: Статус
    local ExpireLabel = Instance.new("TextLabel")      -- Строка 2: Время подписки

    ScreenGui.Name = "InkKeySystemUI"
    ScreenGui.Parent = CoreGui

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -115)
    MainFrame.Size = UDim2.new(0, 320, 0, 230)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 8)
    frameCorner.Parent = MainFrame

    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "INK HUB — АВТОРИЗАЦИЯ"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18

    KeyInput.Name = "KeyInput"
    KeyInput.Parent = MainFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    KeyInput.Position = UDim2.new(0.1, 0, 0.20, 0)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
    KeyInput.Font = Enum.Font.SourceSans
    KeyInput.PlaceholderText = "Введите лицензионный ключ..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = KeyInput

    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Parent = MainFrame
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    SubmitBtn.Position = UDim2.new(0.1, 0, 0.40, 0)
    SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
    SubmitBtn.Font = Enum.Font.SourceSansBold
    SubmitBtn.Text = "АКТИВИРОВАТЬ / ВОЙТИ"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = SubmitBtn

    -- 1-я строка статуса
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = MainFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0.05, 0, 0.62, 0)
    StatusLabel.Size = UDim2.new(0.9, 0, 0, 22)
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.Text = "Статус: Ожидание ввода..."
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.TextSize = 13

    -- 2-я строка статуса (остаток времени подписки)
    ExpireLabel.Name = "ExpireLabel"
    ExpireLabel.Parent = MainFrame
    ExpireLabel.BackgroundTransparency = 1
    ExpireLabel.Position = UDim2.new(0.05, 0, 0.76, 0)
    ExpireLabel.Size = UDim2.new(0.9, 0, 0, 22)
    ExpireLabel.Font = Enum.Font.SourceSansBold
    ExpireLabel.Text = "Подписка: Не активирована"
    ExpireLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    ExpireLabel.TextSize = 13

    SubmitBtn.MouseButton1Click:Connect(function()
        local inputKey = KeyInput.Text:gsub("%s+", "")
        if inputKey == "" then
            StatusLabel.Text = "Ошибка: Введите ключ!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            return
        end

        SubmitBtn.Active = false
        StatusLabel.Text = "Проверка ключа на сервере..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        ExpireLabel.Text = "Ожидание ответа..."
        ExpireLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

        task.spawn(function()
            local hwid = GetHWID()
            local username = LocalPlayer.Name
            local endpoint = string.format("%s/verify?key=%s&hwid=%s&username=%s",
                SERVER_URL,
                HttpService:UrlEncode(inputKey),
                HttpService:UrlEncode(hwid),
                HttpService:UrlEncode(username)
            )

            local success, rawResponse = pcall(function()
                return HttpRequest(endpoint)
            end)

            if success and rawResponse then
                local decodeSuccess, response = pcall(function()
                    return HttpService:JSONDecode(rawResponse)
                end)

                if decodeSuccess and response then
                    if response.status == "success" and response.script then
                        StatusLabel.Text = "Доступ разрешён!"
                        StatusLabel.TextColor3 = Color3.fromRGB(75, 255, 75)
                        
                        -- Фиксируем отображение оставшегося времени
                        if response.expiresIn then
                            ExpireLabel.Text = "Подписка: осталось " .. tostring(response.expiresIn)
                            ExpireLabel.TextColor3 = Color3.fromRGB(0, 230, 120)
                        else
                            ExpireLabel.Text = "Подписка: Активна"
                            ExpireLabel.TextColor3 = Color3.fromRGB(0, 230, 120)
                        end

                        -- Даём 2.5 секунды, чтобы пользователь прочитал остаток времени
                        task.wait(2.5)
                        ScreenGui:Destroy()

                        local executable, err = loadstring(response.script)
                        if executable then
                            executable()
                        else
                            warn("[INK-LOADER]: Ошибка выполнения скрипта: " .. tostring(err))
                        end
                    else
                        SubmitBtn.Active = true
                        StatusLabel.Text = "Ошибка: " .. (response.message or "Неверный ключ")
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                        ExpireLabel.Text = "Подписка: Отказано"
                        ExpireLabel.TextColor3 = Color3.fromRGB(200, 60, 60)
                    end
                else
                    SubmitBtn.Active = true
                    StatusLabel.Text = "Ошибка: Некорректный JSON от сервера"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
                end
            else
                SubmitBtn.Active = true
                StatusLabel.Text = "Ошибка: Нет связи с Render"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 75, 75)
            end
        end)
    end)
end

CreateKeyUI()
